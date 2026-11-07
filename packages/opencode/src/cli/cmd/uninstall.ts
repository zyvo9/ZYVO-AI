import type { Argv } from "yargs"
import { UI } from "../ui"
import * as prompts from "@clack/prompts"
import { Installation } from "../../installation"
import { Global } from "@opencode-ai/core/global"
import fs from "fs/promises"
import path from "path"
import os from "os"
import { Filesystem } from "@/util/filesystem"
import { Process } from "@/util/process"

interface UninstallArgs {
  keepConfig: boolean
  keepData: boolean
  dryRun: boolean
  force: boolean
}

interface RemovalTargets {
  directories: Array<{ path: string; label: string; keep: boolean }>
  shellConfig: string | null
  binary: string | null
  windowsPathEntry?: string
}

export const UninstallCommand = {
  command: "uninstall",
  describe: "uninstall opencode and remove all related files",
  builder: (yargs: Argv) =>
    yargs
      .option("keep-config", {
        alias: "c",
        type: "boolean",
        describe: "keep configuration files",
        default: false,
      })
      .option("keep-data", {
        alias: "d",
        type: "boolean",
        describe: "keep session data and snapshots",
        default: false,
      })
      .option("dry-run", {
        type: "boolean",
        describe: "show what would be removed without removing",
        default: false,
      })
      .option("force", {
        alias: "f",
        type: "boolean",
        describe: "skip confirmation prompts",
        default: false,
      }),

  handler: async (args: UninstallArgs) => {
    UI.empty()
    UI.println(UI.logo("  "))
    UI.empty()
    prompts.intro("Uninstall Zyvo")

    const method = await Installation.method()
    prompts.log.info(`Installation method: ${method}`)

    const targets = await collectRemovalTargets(args, method)

    await showRemovalSummary(targets, method)

    if (!args.force && !args.dryRun) {
      const confirm = await prompts.confirm({
        message: "Are you sure you want to uninstall?",
        initialValue: false,
      })
      if (!confirm || prompts.isCancel(confirm)) {
        prompts.outro("Cancelled")
        return
      }
    }

    if (args.dryRun) {
      prompts.log.warn("Dry run - no changes made")
      prompts.outro("Done")
      return
    }

    await executeUninstall(method, targets)

    prompts.outro("Done")
  },
}

async function collectRemovalTargets(args: UninstallArgs, method: Installation.Method): Promise<RemovalTargets> {
  const directories: RemovalTargets["directories"] = [
    { path: Global.Path.data, label: "Data", keep: args.keepData },
    { path: Global.Path.cache, label: "Cache", keep: false },
    { path: Global.Path.config, label: "Config", keep: args.keepConfig },
    { path: Global.Path.state, label: "State", keep: false },
  ]

  const shellConfig = method === "curl" ? await getShellConfigFile() : null
  const binary = method === "curl" ? process.execPath : null

  // Windows PS1 installer layout (install-zyvo-windows.ps1): app lives in
  // %LOCALAPPDATA%\Zyvo with a User-PATH entry — unknown to package-manager
  // methods, which is why "uninstalled" left zyvo runnable. Handle it here.
  const windowsAppDir = process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, "Zyvo") : null
  if (method === "unknown" && windowsAppDir && process.platform === "win32") {
    const exe = path.join(windowsAppDir, "zyvo.exe")
    const exeExists = await fs
      .access(exe)
      .then(() => true)
      .catch(() => false)
    if (exeExists) {
      const dirs = targets.directories.slice()
      dirs.unshift({ path: windowsAppDir, label: "Zyvo app (LOCALAPPDATA\\Zyvo)", keep: false })
      return { directories: dirs, shellConfig: null, binary: exe, windowsPathEntry: windowsAppDir }
    }
  }

  return { directories, shellConfig, binary }
}

async function removeWindowsPathEntry(entry: string) {
  // strip the installer's User-PATH entry (registry-level, so new shells lose it too)
  if (process.platform !== "win32") return
  const e = entry.replace(/'/g, "''").toLowerCase()
  const script =
    `$p=[Environment]::GetEnvironmentVariable('Path','User'); ` +
    `$n=($p -split ';' | Where-Object { $_ -and $_.TrimEnd('\\').ToLower() -ne '${e}' }) -join ';'; ` +
    `[Environment]::SetEnvironmentVariable('Path',$n,'User')`
  await Process.run("powershell", ["-NoProfile", "-Command", script], { nothrow: true }).catch(() => undefined)
}

// a running exe cannot be deleted on Windows — rename it aside and let a
// detached cmd sweep the leftover directory after this process exits
async function scheduleWindowsSelfCleanup(appDir: string) {
  const exe = path.join(appDir, "zyvo.exe")
  await fs.rename(exe, exe + ".trash").catch(() => undefined)
  const cmd = `timeout /t 3 /nobreak >nul & rmdir /s /q "${appDir}"`
  const { spawn } = await import("child_process")
  spawn("cmd", ["/c", cmd], { detached: true, stdio: "ignore", windowsHide: true }).unref()
}

async function showRemovalSummary(targets: RemovalTargets, method: Installation.Method) {
  prompts.log.message("The following will be removed:")

  for (const dir of targets.directories) {
    const exists = await fs
      .access(dir.path)
      .then(() => true)
      .catch(() => false)
    if (!exists) continue

    const size = await getDirectorySize(dir.path)
    const sizeStr = formatSize(size)
    const status = dir.keep ? UI.Style.TEXT_DIM + "(keeping)" : ""
    const prefix = dir.keep ? "○" : "✓"

    prompts.log.info(`  ${prefix} ${dir.label}: ${shortenPath(dir.path)} ${UI.Style.TEXT_DIM}(${sizeStr})${status}`)
  }

  if (targets.binary) {
    prompts.log.info(`  ✓ Binary: ${shortenPath(targets.binary)}`)
  }

  if (targets.shellConfig) {
    prompts.log.info(`  ✓ Shell PATH in ${shortenPath(targets.shellConfig)}`)
  }

  if (method !== "curl" && method !== "unknown") {
    const cmds: Record<string, string> = {
      npm: "npm uninstall -g opencode-ai",
      pnpm: "pnpm uninstall -g opencode-ai",
      bun: "bun remove -g opencode-ai",
      yarn: "yarn global remove opencode-ai",
      brew: "brew uninstall opencode",
      choco: "choco uninstall opencode",
      scoop: "scoop uninstall opencode",
    }
    prompts.log.info(`  ✓ Package: ${cmds[method] || method}`)
  }
}

async function executeUninstall(method: Installation.Method, targets: RemovalTargets) {
  const spinner = prompts.spinner()
  const errors: string[] = []

  // Windows self-cleanup BEFORE the dir loop: the running exe would lock the
  // app dir — rename it aside now, sweep the leftovers after this process ends
  const selfCleanup =
    targets.windowsPathEntry && targets.binary && targets.binary.toLowerCase().startsWith(targets.windowsPathEntry.toLowerCase())
  if (selfCleanup && targets.binary) {
    spinner.start("Preparing Windows self-cleanup (running exe rename)...")
    await scheduleWindowsSelfCleanup(targets.windowsPathEntry)
    spinner.stop("Windows self-cleanup scheduled")
  }

  for (const dir of targets.directories) {
    if (dir.keep) {
      prompts.log.step(`Skipping ${dir.label} (--keep-${dir.label.toLowerCase()})`)
      continue
    }

    const exists = await fs
      .access(dir.path)
      .then(() => true)
      .catch(() => false)
    if (!exists) continue

    spinner.start(`Removing ${dir.label}...`)
    const err = await fs.rm(dir.path, { recursive: true, force: true }).catch((e) => e)
    if (err) {
      spinner.stop(`Failed to remove ${dir.label}`, 1)
      errors.push(`${dir.label}: ${err.message}`)
      continue
    }
    spinner.stop(`Removed ${dir.label}`)
  }

  if (targets.shellConfig) {
    spinner.start("Cleaning shell config...")
    const err = await cleanShellConfig(targets.shellConfig).catch((e) => e)
    if (err) {
      spinner.stop("Failed to clean shell config", 1)
      errors.push(`Shell config: ${err.message}`)
    } else {
      spinner.stop("Cleaned shell config")
    }
  }

  if (method !== "curl" && method !== "unknown") {
    const cmds: Record<string, string[]> = {
      npm: ["npm", "uninstall", "-g", "opencode-ai"],
      pnpm: ["pnpm", "uninstall", "-g", "opencode-ai"],
      bun: ["bun", "remove", "-g", "opencode-ai"],
      yarn: ["yarn", "global", "remove", "opencode-ai"],
      brew: ["brew", "uninstall", "zyvo"],
      choco: ["choco", "uninstall", "zyvo"],
      scoop: ["scoop", "uninstall", "zyvo"],
    }

    const cmd = cmds[method]
    if (cmd) {
      spinner.start(`Running ${cmd.join(" ")}...`)
      const result = await Process.run(method === "choco" ? ["choco", "uninstall", "zyvo", "-y", "-r"] : cmd, {
        nothrow: true,
      })
      if (result.code !== 0) {
        spinner.stop(`Package manager uninstall failed: exit code ${result.code}`, 1)
        const text = `${result.stdout.toString("utf8")}\n${result.stderr.toString("utf8")}`
        if (method === "choco" && text.includes("not running from an elevated command shell")) {
          prompts.log.warn(`You may need to run '${cmd.join(" ")}' from an elevated command shell`)
        } else {
          prompts.log.warn(`You may need to run manually: ${cmd.join(" ")}`)
        }
      } else {
        spinner.stop("Package removed")
      }
    }
  }

  if (method === "curl" && targets.binary) {
    UI.empty()
    prompts.log.message("To finish removing the binary, run:")
    prompts.log.info(`  rm "${targets.binary}"`)

    const binDir = path.dirname(targets.binary)
    if (binDir.includes(".opencode")) {
      prompts.log.info(`  rmdir "${binDir}" 2>/dev/null`)
    }
  }

  if (targets.windowsPathEntry) {
    spinner.start("Cleaning User PATH (LOCALAPPDATA\\Zyvo entry)...")
    await removeWindowsPathEntry(targets.windowsPathEntry)
    spinner.stop("User PATH cleaned")
    UI.empty()
    prompts.log.message("Close any open terminals so the PATH change takes effect everywhere.")
  }

  if (errors.length > 0) {
    UI.empty()
    prompts.log.warn("Some operations failed:")
    for (const err of errors) {
      prompts.log.error(`  ${err}`)
    }
  }

  UI.empty()
  prompts.log.success("Thank you for using Zyvo!")
}

async function getShellConfigFile(): Promise<string | null> {
  const shell = path.basename(process.env.SHELL || "bash")
  const home = os.homedir()
  const xdgConfig = process.env.XDG_CONFIG_HOME || path.join(home, ".config")

  const configFiles: Record<string, string[]> = {
    fish: [path.join(xdgConfig, "fish", "config.fish")],
    zsh: [
      path.join(home, ".zshrc"),
      path.join(home, ".zshenv"),
      path.join(xdgConfig, "zsh", ".zshrc"),
      path.join(xdgConfig, "zsh", ".zshenv"),
    ],
    bash: [
      path.join(home, ".bashrc"),
      path.join(home, ".bash_profile"),
      path.join(home, ".profile"),
      path.join(xdgConfig, "bash", ".bashrc"),
      path.join(xdgConfig, "bash", ".bash_profile"),
    ],
    ash: [path.join(home, ".ashrc"), path.join(home, ".profile")],
    sh: [path.join(home, ".profile")],
  }

  const candidates = configFiles[shell] || configFiles.bash

  for (const file of candidates) {
    const exists = await fs
      .access(file)
      .then(() => true)
      .catch(() => false)
    if (!exists) continue

    const content = await Filesystem.readText(file).catch(() => "")
    if (content.includes("# opencode") || content.includes(".opencode/bin")) {
      return file
    }
  }

  return null
}

async function cleanShellConfig(file: string) {
  const content = await Filesystem.readText(file)
  const lines = content.split("\n")

  const filtered: string[] = []
  let skip = false

  for (const line of lines) {
    const trimmed = line.trim()

    if (trimmed === "# opencode") {
      skip = true
      continue
    }

    if (skip) {
      skip = false
      if (trimmed.includes(".opencode/bin") || trimmed.includes("fish_add_path")) {
        continue
      }
    }

    if (
      (trimmed.startsWith("export PATH=") && trimmed.includes(".opencode/bin")) ||
      (trimmed.startsWith("fish_add_path") && trimmed.includes(".opencode"))
    ) {
      continue
    }

    filtered.push(line)
  }

  while (filtered.length > 0 && filtered[filtered.length - 1].trim() === "") {
    filtered.pop()
  }

  const output = filtered.join("\n") + "\n"
  await Filesystem.write(file, output)
}

async function getDirectorySize(dir: string): Promise<number> {
  let total = 0

  const walk = async (current: string) => {
    const entries = await fs.readdir(current, { withFileTypes: true }).catch(() => [])

    for (const entry of entries) {
      const full = path.join(current, entry.name)
      if (entry.isDirectory()) {
        await walk(full)
        continue
      }
      if (entry.isFile()) {
        const stat = await fs.stat(full).catch(() => null)
        if (stat) total += stat.size
      }
    }
  }

  await walk(dir)
  return total
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`
}

function shortenPath(p: string): string {
  const home = os.homedir()
  if (p.startsWith(home)) {
    return p.replace(home, "~")
  }
  return p
}

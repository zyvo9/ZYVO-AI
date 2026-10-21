import { execFile, spawn } from "node:child_process"
import { readFile, rm } from "node:fs/promises"
import { platform, release, tmpdir } from "node:os"
import path from "node:path"
import { promisify } from "node:util"

const exec = promisify(execFile)

function command(command: string, args: string[] = [], input?: string) {
  return new Promise<Buffer>((resolve, reject) => {
    const child = spawn(command, args, {
      stdio: [input === undefined ? "ignore" : "pipe", "pipe", "ignore"],
      // never flash a console window for helper/powershell fallbacks
      windowsHide: true,
    })
    const output: Buffer[] = []
    child.on("error", reject)
    child.stdout?.on("data", (chunk: Buffer) => output.push(chunk))
    child.on("close", (code) => {
      if (code === 0) return resolve(Buffer.concat(output))
      reject(new Error(`${command} exited with code ${code}`))
    })
    if (input !== undefined) child.stdin?.end(input)
  })
}

function writeOsc52(text: string) {
  if (!process.stdout.isTTY) return
  const sequence = `\x1b]52;c;${Buffer.from(text).toString("base64")}\x07`
  process.stdout.write(process.env.TMUX || process.env.STY ? `\x1bPtmux;\x1b${sequence}\x1b\\` : sequence)
}

// Termux clipboard helpers
async function termuxRead(): Promise<string | undefined> {
  try {
    const result = await command("termux-clipboard-get")
    return result.toString().trim()
  } catch {
    return undefined
  }
}

async function termuxWrite(text: string): Promise<void> {
  try {
    await command("termux-clipboard-set", [text])
  } catch {
    // ignore
  }
}

// Windows text clipboard — THREE layers, fastest first:
// 1. win32 API IN-PROCESS via bun:ffi (the upstream 1.19 mechanism): no
//    subprocess at all, so no console window flash, no AV scan, ~0ms.
// 2. the bundled win-clipboard helper exe (~60ms) — fallback if FFI fails.
// 3. PowerShell (5-8s with AV — last resort only).
// WHY NOT POWERSHELL FIRST: spawning powershell.exe flashes a cmd window
// in front of the TUI and AV scans every spawn — seconds per paste.
const CF_UNICODETEXT = 13
const GMEM_MOVEABLE = 2
const CP_UTF8 = 65001

type Win32Clipboard = {
  read(): string | undefined
  write(text: string): boolean
}
let win32Clipboard: Win32Clipboard | undefined | null // null = unavailable

async function loadWin32Clipboard(): Promise<Win32Clipboard | null> {
  if (win32Clipboard !== undefined) return win32Clipboard
  try {
    const ffi = (await import("bun:ffi")) as any
    const user32 = ffi.dlopen("user32.dll", {
      OpenClipboard: { args: [ffi.FFIType.ptr], returns: ffi.FFIType.i32 },
      CloseClipboard: { args: [], returns: ffi.FFIType.i32 },
      IsClipboardFormatAvailable: { args: [ffi.FFIType.u32], returns: ffi.FFIType.i32 },
      GetClipboardData: { args: [ffi.FFIType.u32], returns: ffi.FFIType.ptr },
      SetClipboardData: { args: [ffi.FFIType.u32, ffi.FFIType.ptr], returns: ffi.FFIType.ptr },
      EmptyClipboard: { args: [], returns: ffi.FFIType.i32 },
    }).symbols
    const kernel32 = ffi.dlopen("kernel32.dll", {
      GlobalAlloc: { args: [ffi.FFIType.u32, ffi.FFIType.usize], returns: ffi.FFIType.ptr },
      GlobalLock: { args: [ffi.FFIType.ptr], returns: ffi.FFIType.ptr },
      GlobalUnlock: { args: [ffi.FFIType.ptr], returns: ffi.FFIType.i32 },
      GlobalSize: { args: [ffi.FFIType.ptr], returns: ffi.FFIType.usize },
      WideCharToMultiByte: {
        args: [ffi.FFIType.u32, ffi.FFIType.u32, ffi.FFIType.ptr, ffi.FFIType.i32, ffi.FFIType.ptr, ffi.FFIType.i32, ffi.FFIType.ptr, ffi.FFIType.ptr],
        returns: ffi.FFIType.i32,
      },
      memcpy: { args: [ffi.FFIType.ptr, ffi.FFIType.ptr, ffi.FFIType.usize], returns: ffi.FFIType.ptr },
      lstrlenW: { args: [ffi.FFIType.ptr], returns: ffi.FFIType.i32 },
    }).symbols

    win32Clipboard = {
      read() {
        try {
          if (!user32.OpenClipboard(0)) return undefined
          try {
            if (!user32.IsClipboardFormatAvailable(CF_UNICODETEXT)) return undefined
            const handle = user32.GetClipboardData(CF_UNICODETEXT)
            if (!handle) return undefined
            const ptr = kernel32.GlobalLock(handle)
            if (!ptr) return undefined
            try {
              const len = kernel32.lstrlenW(ptr)
              if (len <= 0) return undefined
              // ask for the exact byte count first, then convert into OUR buffer
              const needed = kernel32.WideCharToMultiByte(CP_UTF8, 0, ptr, len, 0, 0, 0, 0)
              if (needed <= 0) return undefined
              const out = new Uint8Array(needed)
              const written = kernel32.WideCharToMultiByte(CP_UTF8, 0, ptr, len, out, needed, 0, 0)
              if (written <= 0) return undefined
              const text = Buffer.from(out.buffer, 0, written).toString("utf8")
              return text === "" ? undefined : text
            } finally {
              kernel32.GlobalUnlock(handle)
            }
          } finally {
            user32.CloseClipboard()
          }
        } catch {
          return undefined
        }
      },
      write(text: string) {
        try {
          if (!user32.OpenClipboard(0)) return false
          try {
            // UTF-16LE payload + trailing NUL
            const payload = Buffer.from(text, "utf16le")
            const size = payload.length + 2
            const handle = kernel32.GlobalAlloc(GMEM_MOVEABLE, size)
            if (!handle) return false
            const ptr = kernel32.GlobalLock(handle)
            if (!ptr) return false
            const src = new Uint8Array(size)
            src.set(payload, 0)
            kernel32.memcpy(ptr, src, size)
            kernel32.GlobalUnlock(handle)
            if (!user32.EmptyClipboard()) return false
            const ok = user32.SetClipboardData(CF_UNICODETEXT, handle)
            // on failure the HGLOBAL is still ours to leak — tiny and rare
            return Boolean(ok)
          } finally {
            user32.CloseClipboard()
          }
        } catch {
          return false
        }
      },
    }
  } catch {
    win32Clipboard = null
  }
  return win32Clipboard
}

const windowsHelperDir = () =>
  path.join(process.env.LOCALAPPDATA || tmpdir(), "zyvo")

const windowsHelperPath = () => path.join(windowsHelperDir(), "clipboard-x64.exe")

async function ensureWindowsHelper(): Promise<string | undefined> {
  try {
    const target = windowsHelperPath()
    try {
      const st = await import("node:fs/promises").then((fs) => fs.stat(target))
      if (st.isFile() && st.size > 100_000) return target
    } catch {
      // not present yet — extract below
    }
    const { WIN_CLIPBOARD_HELPER_B64 } = await import("./clipboard-helper.gen")
    const { mkdir, writeFile } = await import("node:fs/promises")
    await mkdir(windowsHelperDir(), { recursive: true })
    await writeFile(target, Buffer.from(WIN_CLIPBOARD_HELPER_B64, "base64"))
    return target
  } catch {
    return undefined
  }
}

async function windowsReadText(): Promise<string | undefined> {
  // 1) in-process win32 API — instant, no window, no subprocess
  const native = await loadWin32Clipboard()
  if (native) {
    const text = native.read()
    if (text !== undefined) return text
  }
  // 2) bundled helper exe
  const helper = await ensureWindowsHelper()
  if (helper) {
    try {
      const out = await command(helper, ["--paste"])
      const text = out.toString("utf8")
      return text === "" ? undefined : text
    } catch {
      // helper failed — fall through to PowerShell
    }
  }
  // 3) PowerShell — last resort
  try {
    const out = await command("powershell.exe", [
      "-NonInteractive",
      "-NoProfile",
      "-Command",
      "Get-Clipboard -Raw",
    ])
    const text = out.toString("utf8")
    return text === "" ? undefined : text
  } catch {
    return undefined
  }
}

const windowsWriteArgsFallback = [
  "-NonInteractive",
  "-NoProfile",
  "-Command",
  "[Console]::InputEncoding = [System.Text.Encoding]::UTF8; Set-Clipboard -Value ([Console]::In.ReadToEnd())",
]

async function windowsWriteText(text: string): Promise<void> {
  // 1) in-process win32 API — instant, no window, no subprocess
  const native = await loadWin32Clipboard()
  if (native && native.write(text)) return
  // 2) bundled helper exe
  const helper = await ensureWindowsHelper()
  if (helper) {
    try {
      await command(helper, ["--copy"], text)
      return
    } catch {
      // helper failed — fall through to PowerShell
    }
  }
  // 3) PowerShell — last resort
  await command("powershell.exe", windowsWriteArgsFallback, text)
}

async function readText(): Promise<{ data: string; mime: string } | undefined> {
  // Termux: use termux-clipboard-get
  if (process.env.TERMUX_VERSION) {
    const text = await termuxRead()
    if (text) return { data: text, mime: "text/plain" }
    return undefined
  }
  // Windows/WSL: PowerShell first — clipboardy is dead in compiled binaries
  if (platform() === "win32" || release().includes("WSL")) {
    const text = await windowsReadText()
    if (text) return { data: text, mime: "text/plain" }
    return undefined
  }
  const { default: clipboardy } = await import("clipboardy")
  const text = await clipboardy.read().catch(() => undefined)
  if (text) return { data: text, mime: "text/plain" }
  return undefined
}

export async function read() {
  // Termux FIRST — platform() is "linux" here, and the linux probe below
  // (wl-paste/xclip) doesn't exist on Termux and would only waste time
  if (process.env.TERMUX_VERSION) {
    const text = await termuxRead()
    if (text) return { data: text, mime: "text/plain" }
    return undefined
  }

  if (platform() === "darwin") {
    const file = path.join(tmpdir(), "opencode-clipboard.png")
    try {
      await exec("osascript", [
        "-e",
        'set imageData to the clipboard as "PNGf"',
        "-e",
        `set fileRef to open for access POSIX file "${file}" with write permission`,
        "-e",
        "set eof fileRef to 0",
        "-e",
        "write imageData to fileRef",
        "-e",
        "close access fileRef",
      ])
      return { data: (await readFile(file)).toString("base64"), mime: "image/png" }
    } catch {
      // Fall through to text clipboard.
    } finally {
      await rm(file, { force: true }).catch(() => {})
    }
  }

  // Windows: read TEXT first — the image probe spawns PowerShell, which
  // adds seconds to EVERY paste (and can hang under AV scans), while a
  // screenshot in the clipboard never carries text anyway. The image
  // probe runs only when the clipboard holds no text.
  if (platform() === "win32" || release().includes("WSL")) {
    const text = await readText()
    if (text) return text
    const script =
      "Add-Type -AssemblyName System.Windows.Forms; $img = [System.Windows.Forms.Clipboard]::GetImage(); if ($img) { $ms = New-Object System.IO.MemoryStream; $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); [System.Convert]::ToBase64String($ms.ToArray()) }"
    const image = await command("powershell.exe", ["-NonInteractive", "-NoProfile", "-command", script]).catch(() =>
      Buffer.alloc(0),
    )
    if (image.length) return { data: image.toString().trim(), mime: "image/png" }
  }

  if (platform() === "linux") {
    const wayland = await command("wl-paste", ["-t", "image/png"]).catch(() => Buffer.alloc(0))
    if (wayland.length) return { data: wayland.toString("base64"), mime: "image/png" }
    const x11 = await command("xclip", ["-selection", "clipboard", "-t", "image/png", "-o"]).catch(() =>
      Buffer.alloc(0),
    )
    if (x11.length) return { data: x11.toString("base64"), mime: "image/png" }
  }

  return readText()
}

export function copyCommand(
  os: NodeJS.Platform,
  wayland: boolean,
  has: (name: string) => boolean,
): string[] | undefined {
  if (os === "darwin" && has("osascript")) return ["osascript"]
  if (os === "linux" && wayland && has("wl-copy")) return ["wl-copy"]
  if (os === "linux" && has("xclip")) return ["xclip", "-selection", "clipboard"]
  if (os === "linux" && has("xsel")) return ["xsel", "--clipboard", "--input"]
  if (os === "win32" && has("powershell.exe")) {
    return [
      "powershell.exe",
      "-NonInteractive",
      "-NoProfile",
      "-Command",
      "[Console]::InputEncoding = [System.Text.Encoding]::UTF8; Set-Clipboard -Value ([Console]::In.ReadToEnd())",
    ]
  }
}

let copyMethod: Promise<(text: string) => Promise<void>> | undefined

function getCopyMethod() {
  return (copyMethod ??= (async () => {
    // Termux: use termux-clipboard-set
    if (process.env.TERMUX_VERSION) {
      return async (text: string) => {
        await termuxWrite(text)
      }
    }
    // Windows/WSL: PowerShell direct — clipboardy is dead in compiled binaries
    if (platform() === "win32" || release().includes("WSL")) {
      return async (text: string) => {
        await windowsWriteText(text)
      }
    }
    const { which } = await import("@opencode-ai/core/util/which")
    const native = copyCommand(platform(), Boolean(process.env.WAYLAND_DISPLAY), (name) => Boolean(which(name)))
    if (native?.[0] === "osascript") {
      return async (text: string) => {
        const escaped = text.replace(/\\/g, "\\\\").replace(/"/g, '\\"')
        await command("osascript", ["-e", `set the clipboard to "${escaped}"`]).catch(() => undefined)
      }
    }
    if (native) {
      return async (text: string) => {
        await command(native[0], native.slice(1), text).catch(() => undefined)
      }
    }
    return async (text: string) => {
      const { default: clipboardy } = await import("clipboardy")
      await clipboardy.write(text).catch(() => undefined)
    }
  })())
}

export async function write(text: string) {
  writeOsc52(text)
  const method = await getCopyMethod()
  await method(text)
}

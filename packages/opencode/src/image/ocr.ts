import { spawn } from "node:child_process"
import { existsSync } from "node:fs"
import { mkdtemp, rm, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"
import { Effect } from "effect"

/**
 * OCR bridge for text-only models: when the active model cannot view
 * images, tesseract extracts the image's text so the conversation still
 * "sees" screenshots. Engine availability:
 * - Termux: auto-installs via `pkg install -y tesseract` (no root needed)
 * - Windows: PATH, or the standard Tesseract-OCR install folders
 * - macOS/Linux: PATH only
 * Missing engine -> undefined (caller shows a one-line install hint).
 */

const OCR_TIMEOUT_MS = 30_000
const MAX_TEXT_CHARS = 4_000

function run(cmd: string, args: string[], opts: { input?: Buffer; timeoutMs?: number } = {}) {
  return new Promise<{ ok: boolean; stdout: string }>((resolve) => {
    const child = spawn(cmd, args, {
      stdio: [opts.input === undefined ? "ignore" : "pipe", "pipe", "pipe"],
      windowsHide: true,
    })
    let out = ""
    const timer = setTimeout(() => child.kill("SIGKILL"), opts.timeoutMs ?? OCR_TIMEOUT_MS)
    child.on("error", () => {
      clearTimeout(timer)
      resolve({ ok: false, stdout: "" })
    })
    child.stdout?.on("data", (c: Buffer) => (out += c.toString("utf8")))
    child.on("close", (code) => {
      clearTimeout(timer)
      resolve({ ok: code === 0, stdout: out })
    })
    if (opts.input !== undefined) child.stdin?.end(opts.input)
  })
}

let tesseractPromise: Promise<string | undefined> | undefined

function resolveTesseract(): Promise<string | undefined> {
  return (tesseractPromise ??= (async () => {
    // Termux: install on first use — pkg needs no root and users expect
    // zyvo to bootstrap its own tools
    if (process.env.TERMUX_VERSION) {
      const probe = await run("command", ["-v", "tesseract"], { timeoutMs: 5_000 })
      if (!probe.ok) {
        await run("pkg", ["install", "-y", "tesseract"], { timeoutMs: 120_000 })
      }
      const after = await run("command", ["-v", "tesseract"], { timeoutMs: 5_000 })
      if (after.ok) return "tesseract"
      return undefined
    }
    // every platform: PATH first
    const which = await run("command", ["-v", "tesseract"], { timeoutMs: 5_000 })
    if (which.ok) return "tesseract"
    // Windows: standard install locations
    if (process.platform === "win32") {
      for (const base of [process.env.PROGRAMFILES, process.env["PROGRAMFILES(X86)"]]) {
        if (!base) continue
        for (const dir of ["Tesseract-OCR", "Tesseract"]) {
          const candidate = path.join(base, dir, "tesseract.exe")
          if (existsSync(candidate)) return candidate
        }
      }
    }
    return undefined
  })())
}

export const ocrImage = Effect.fn("ImageOCR.ocrImage")(function* (input: {
  data: Buffer
  mime: string
}) {
  const engine = yield* Effect.promise(() => resolveTesseract())
  if (!engine) {
    return {
      ok: false as const,
      hint:
        process.env.TERMUX_VERSION
          ? "pkg install tesseract"
          : process.platform === "win32"
            ? "install Tesseract OCR (UB-Mannheim build)"
            : "install tesseract",
    }
  }
  const ext = input.mime.includes("jpeg") || input.mime.includes("jpg") ? ".jpg" : input.mime.includes("webp") ? ".webp" : ".png"
  const dir = yield* Effect.tryPromise({
    try: () => mkdtemp(path.join(tmpdir(), "zyvo-ocr-")),
    catch: () => new Error("tmpdir unavailable"),
  })
  const file = path.join(dir, `img${ext}`)
  const text = yield* Effect.tryPromise({
    try: async () => {
      await writeFile(file, input.data)
      const res = await run(engine, [file, "stdout", "-l", "eng"])
      if (!res.ok) return ""
      return res.stdout.trim().slice(0, MAX_TEXT_CHARS)
    },
    catch: () => new Error("ocr failed"),
  }).pipe(Effect.andThen((t) => ({ ok: true as const, text: t })))
  yield* Effect.promise(() => rm(dir, { recursive: true, force: true }).catch(() => {}))
  return text
})

export * as ImageOCR from "./ocr"

import { PasteEvent, decodePasteBytes, type TextareaRenderable, type InputRenderable } from "@opentui/core"
import { useClipboard } from "../context/clipboard"
import { useRenderer } from "@opentui/solid"
import { useBindings } from "../keymap"

type Field = TextareaRenderable | InputRenderable

/**
 * Ctrl+V paste for any TUI text field (dialog prompt, question/permission
 * inputs, export filename, select filter).
 *
 * Without this, paste is a no-op on terminals running the kitty keyboard
 * protocol: the terminal does not send native bracketed paste, and the field
 * registers no paste binding — so Ctrl+V arrives as an unhandled key event.
 * Paste then arrives as a key event that nothing handles. `onPaste` still
 * covers terminals that DO send bracketed paste, so both paths are wired.
 */
export function useFieldPaste(target: () => Field | undefined, options?: { enabled?: () => boolean }) {
  const clipboard = useClipboard()
  const renderer = useRenderer()

  function insert(text: string) {
    const field = target()
    if (!field || field.isDestroyed) return
    // Normalize line endings at the boundary (Windows ConPTY/Terminal often
    // sends CR-only newlines in bracketed paste).
    field.insertText(text.replace(/\r\n/g, "\n").replace(/\r/g, "\n"))
    field.getLayoutNode().markDirty()
    renderer.requestRender()
  }

  async function pasteFromClipboard() {
    if (options?.enabled?.() === false) return
    const content = await clipboard.read?.()
    if (content?.mime === "text/plain") insert(content.data)
  }

  useBindings(() => ({
    target,
    enabled: target() !== undefined && (options?.enabled?.() ?? true),
    // Field semantics must win over the global managed textarea layer.
    priority: 1,
    bindings: [{ key: "ctrl+v", desc: "Paste", group: "Input", cmd: () => void pasteFromClipboard() }],
  }))

  return {
    onPaste(event: PasteEvent) {
      if (options?.enabled?.() === false) {
        event.preventDefault()
        return
      }
      event.preventDefault()
      insert(decodePasteBytes(event.bytes))
    },
  }
}

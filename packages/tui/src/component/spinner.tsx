import { For, Show, createSignal, createEffect, onCleanup } from "solid-js"
import { useTheme } from "../context/theme"
import { useKV } from "../context/kv"
import type { JSX } from "@opentui/solid"
import type { ColorInput, RGBA } from "@opentui/core"

// Platform-aware frames: Termux fonts render braille fine (and braille never
// leaves trails), but PC console fonts ship WITHOUT braille glyphs — every
// frame renders as a solid tofu block, so the busy state looks invisible
// ("is it running?"). ASCII |/-\ exists in every PC font.
export const SPINNER_FRAMES =
  process.platform === "android"
    ? ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    : ["|", "/", "-", "\\"]

// Matches opentui-spinner's ColorGenerator signature (returns ColorInput).
type SpinnerGenerator = (frameIndex: number, charIndex: number, totalFrames: number, totalChars: number) => ColorInput

// Pure-Solid spinner. Deliberately NOT the <spinner> intrinsic from
// "opentui-spinner/solid": its side-effect registration gets dropped by the
// PC bundle (browser vs bun/node conditions + minify), which crashed the
// reconciler with "Unknown component type: spinner" mid-session.
export function Spinner(props: {
  children?: JSX.Element
  color?: RGBA | SpinnerGenerator
  frames?: string[]
  interval?: number
}) {
  const { theme } = useTheme()
  const kv = useKV()
  const animated = () => kv.get("animations_enabled", true)
  const frames = () => props.frames ?? SPINNER_FRAMES
  const generator = () => (typeof props.color === "function" ? props.color : undefined)
  const plainColor = () => (typeof props.color === "function" ? undefined : (props.color ?? theme.textMuted))
  const [frame, setFrame] = createSignal(0)
  createEffect(() => {
    if (!animated()) return
    const timer = setInterval(() => setFrame((f) => (f + 1) % frames().length), props.interval ?? 80)
    onCleanup(() => clearInterval(timer))
  })
  const chars = () => Array.from(frames()[frame()])
  return (
    <Show when={animated()} fallback={<text fg={plainColor() ?? theme.textMuted}>⋯ {props.children}</text>}>
      <box flexDirection="row" gap={1}>
        <text>
          <For each={chars()}>
            {(ch, i) => (
              <span
                style={{
                  fg: generator()?.(frame(), i(), chars().length, chars().length) ?? plainColor(),
                }}
              >
                {ch}
              </span>
            )}
          </For>
        </text>
        <Show when={props.children}>
          <text fg={plainColor() ?? theme.textMuted}>{props.children}</text>
        </Show>
      </box>
    </Show>
  )
}

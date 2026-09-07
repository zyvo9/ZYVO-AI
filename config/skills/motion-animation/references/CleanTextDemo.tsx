import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  random,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

/**
 * CLEAN TEXT DEMO — the signature "Clean Text Animation" preset, same-to-same.
 *
 * HOW TO USE: copy this file into your Remotion project's src/, register it:
 *   <Composition id="CleanTextDemo" component={CleanTextDemo}
 *     durationInFrames={450} fps={30} width={1920} height={1080} />
 * Then change ONLY: the words, the accent color, and card images.
 * DO NOT touch the timings/easings — they are the style.
 *
 * Optional: add these Google Fonts <link> tags to index.html for the full
 * look (falls back to system fonts without them):
 *   Inter (400,800) + Great Vibes
 */

const ACCENT = "#4A9EFF";
const INK = "#1A1A1A";
const clampT = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

// ───────────────────────── shared bits ─────────────────────────

const Grain: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        opacity: 0.05,
        backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 300 300' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")`,
        transform: `translate(${Math.floor(random(`gx${f}`) * 6 - 3)}px, ${Math.floor(
          random(`gy${f}`) * 6 - 3
        )}px)`,
      }}
    />
  );
};

const Ghost: React.FC<{ children: React.ReactNode; off?: number; color?: string }> = ({
  children,
  off = 14,
  color = "#B9BDC2",
}) => (
  <div style={{ position: "relative", display: "inline-block" }}>
    <div
      style={{
        position: "absolute",
        inset: 0,
        transform: `translate(${off}px, ${off}px)`,
        filter: "blur(7px)",
        opacity: 0.45,
        color,
      }}
    >
      {children}
    </div>
    <div style={{ position: "relative" }}>{children}</div>
  </div>
);

const Selection: React.FC<{ delay?: number }> = ({ delay = 25 }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const p = spring({ frame: f - delay, fps, config: { damping: 12 } });
  const handle: React.CSSProperties = {
    position: "absolute",
    width: 14,
    height: 14,
    background: "#fff",
    border: `3px solid ${ACCENT}`,
    borderRadius: 2,
  };
  return (
    <div
      style={{
        position: "absolute",
        inset: -18,
        border: `3px solid ${ACCENT}`,
        borderRadius: 4,
        opacity: p,
        transform: `scale(${0.92 + p * 0.08})`,
      }}
    >
      <div style={{ ...handle, top: -8, left: -8 }} />
      <div style={{ ...handle, top: -8, right: -8 }} />
      <div style={{ ...handle, bottom: -8, left: -8 }} />
      <div style={{ ...handle, bottom: -8, right: -8 }} />
    </div>
  );
};

const Doodle: React.FC<{ d: string; delay?: number; style?: React.CSSProperties }> = ({
  d,
  delay = 0,
  style,
}) => {
  const f = useCurrentFrame();
  const draw = interpolate(f, [delay, delay + 22], [1, 0], clampT);
  return (
    <svg viewBox="0 0 200 120" style={{ position: "absolute", width: 230, ...style }}>
      <path
        d={d}
        stroke={INK}
        strokeWidth={7}
        fill="none"
        strokeLinecap="round"
        strokeDasharray={420}
        strokeDashoffset={420 * draw}
      />
    </svg>
  );
};

const Snapping: React.FC<{ word: string; start?: number; size?: number }> = ({
  word,
  start = 0,
  size = 150,
}) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  return (
    <div style={{ display: "inline-block" }}>
      {word.split("").map((ch, i) => {
        const s = spring({ frame: f - start - i * 2, fps, config: { damping: 9, mass: 0.7 } });
        return (
          <span
            key={i}
            style={{
              display: "inline-block",
              transform: `translateY(${(1 - s) * -70}px)`,
              opacity: s,
            }}
          >
            {ch}
          </span>
        );
      })}
    </div>
  );
};

const Scramble: React.FC<{ text: string; start?: number }> = ({ text, start = 0 }) => {
  const f = useCurrentFrame();
  const G = "ABCDEFGHKMNPRSTUVWXYZ#%&@";
  return (
    <span>
      {text.split("").map((ch, i) => {
        const settle = start + i * 3 + 14;
        return (
          <span key={i}>
            {f >= settle
              ? ch
              : G[Math.floor(random(`s${i}-${Math.floor(f / 2)}`) * G.length)]}
          </span>
        );
      })}
    </span>
  );
};

const Chip: React.FC<{ label: string; delay: number; accent?: boolean }> = ({
  label,
  delay,
  accent,
}) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: f - delay, fps, config: { damping: 10, mass: 0.9 } });
  return (
    <div
      style={{
        transform: `scale(${s})`,
        background: "#141414",
        color: accent ? ACCENT : "#fff",
        padding: "22px 46px",
        borderRadius: 14,
        fontSize: 38,
        fontWeight: 600,
        fontFamily: "Inter, system-ui, sans-serif",
        opacity: s,
        boxShadow: "0 18px 40px rgba(0,0,0,0.35)",
      }}
    >
      {label}
    </div>
  );
};

// ───────────────────────── scenes ─────────────────────────

// Scene A — dark intro (0–90): corner glow, ghost line, play chip
const SceneA: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const fade = interpolate(f, [0, 8], [0, 1], clampT);
  const out = interpolate(f, [78, 90], [1, 0], clampT);
  const chip = spring({ frame: f - 18, fps, config: { damping: 11 } });
  return (
    <AbsoluteFill style={{ background: "#0B0B0B", opacity: fade * out }}>
      <div
        style={{
          position: "absolute",
          top: -300,
          right: -300,
          width: 900,
          height: 900,
          borderRadius: "50%",
          background: `radial-gradient(circle, ${ACCENT}33 0%, transparent 65%)`,
        }}
      />
      <AbsoluteFill
        style={{
          justifyContent: "center",
          alignItems: "center",
          fontFamily: "Inter, system-ui, sans-serif",
        }}
      >
        <div style={{ transform: `scale(${chip})`, display: "flex", alignItems: "center", gap: 24 }}>
          <div
            style={{
              fontSize: 44,
              color: "#DDD",
              fontWeight: 500,
              textShadow: "0 0 24px rgba(255,255,255,0.35)",
            }}
          >
            in this video
          </div>
          <div
            style={{
              width: 64,
              height: 44,
              borderRadius: 10,
              background: ACCENT,
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
            }}
          >
            <div
              style={{
                width: 0,
                height: 0,
                borderTop: "10px solid transparent",
                borderBottom: "10px solid transparent",
                borderLeft: "16px solid #fff",
              }}
            />
          </div>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

// Scene B — white: ghost headline + selection + doodles (90–240)
const SceneB: React.FC = () => {
  const f = useCurrentFrame();
  const flash = interpolate(f, [0, 6], [1, 0], clampT);
  const pop = spring({ frame: f - 6, fps: 30, config: { damping: 11 } });
  return (
    <AbsoluteFill style={{ background: "#F4F4F4", justifyContent: "center", alignItems: "center" }}>
      <AbsoluteFill style={{ background: "#fff", opacity: flash }} />
      <div style={{ position: "relative", textAlign: "center", transform: `scale(${0.9 + pop * 0.1})` }}>
        <div style={{ position: "relative", display: "inline-block", fontFamily: "Inter, system-ui, sans-serif" }}>
          <div
            style={{
              fontSize: 170,
              fontWeight: 800,
              color: INK,
              lineHeight: 1.05,
              letterSpacing: "-0.02em",
            }}
          >
            <Ghost>
              <div>
                Clean Text
                <br />
                Animation
              </div>
            </Ghost>
          </div>
          <Selection delay={30} />
        </div>
        <Doodle d="M10,20 C70,5 120,70 185,85" style={{ top: 60, left: 260 }} delay={45} />
        <Doodle d="M185,15 C140,10 60,60 25,95" style={{ top: 130, right: 250 }} delay={60} />
        <div
          style={{
            marginTop: 40,
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            gap: 14,
            fontSize: 30,
            color: "#555",
            fontFamily: "Inter, system-ui, sans-serif",
          }}
        >
          in
          <span
            style={{
              background: INK,
              color: "#fff",
              borderRadius: 6,
              padding: "2px 12px",
              fontSize: 26,
              fontWeight: 700,
            }}
          >
            zyvo
          </span>
        </div>
      </div>
    </AbsoluteFill>
  );
};

// Scene C — dark chips + scramble (240–360)
const SceneC: React.FC = () => {
  const f = useCurrentFrame();
  const row1 = ["Colors", "Bounce", "Mix"];
  const row2 = ["Typewriter", "Snapping"];
  return (
    <AbsoluteFill
      style={{
        background: "#0B0B0B",
        justifyContent: "center",
        alignItems: "center",
        fontFamily: "Inter, system-ui, sans-serif",
      }}
    >
      <div
        style={{
          position: "absolute",
          bottom: -260,
          left: -200,
          width: 800,
          height: 800,
          borderRadius: "50%",
          background: "radial-gradient(circle, #A3E63522 0%, transparent 65%)",
        }}
      />
      <div
        style={{
          fontSize: 90,
          fontWeight: 800,
          color: "#F4F4F4",
          marginBottom: 90,
          letterSpacing: "-0.01em",
        }}
      >
        <Scramble text="MOTION MAGIC" start={8} />
      </div>
      <div style={{ display: "flex", gap: 26 }}>
        {row1.map((c, i) => (
          <Chip key={c} label={c} delay={i * 5 + 30} accent={i === 2} />
        ))}
      </div>
      <div style={{ display: "flex", gap: 26, marginTop: 26 }}>
        {row2.map((c, i) => (
          <Chip key={c} label={c} delay={i * 5 + 48} accent={false} />
        ))}
      </div>
    </AbsoluteFill>
  );
};

// Scene D — white: 3 paper cards + script sweep (360–450)
const SceneD: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const drift = interpolate(f, [0, 90], [40, -40], clampT);
  const x = interpolate(f, [20, 55], [1920, -520], {
    ...clampT,
    easing: Easing.out(Easing.cubic),
  });
  const rot = [-3, 0, 3];
  return (
    <AbsoluteFill style={{ background: "#ECECEC", overflow: "hidden" }}>
      <div
        style={{
          display: "flex",
          gap: 70,
          justifyContent: "center",
          alignItems: "center",
          height: "100%",
          transform: `translateX(${drift}px)`,
        }}
      >
        {[0, 1, 2].map((i) => {
          const s = spring({ frame: f - i * 5, fps, config: { damping: 12, mass: 1.1 } });
          return (
            <div
              key={i}
              style={{
                width: 380,
                height: 760,
                background: "#fff",
                borderRadius: 26,
                boxShadow: "0 40px 90px rgba(0,0,0,0.16)",
                overflow: "hidden",
                transform: `translateY(${(1 - s) * -900}px) rotate(${rot[i]}deg)`,
                display: "flex",
                flexDirection: "column",
                justifyContent: "flex-end",
                padding: 40,
                boxSizing: "border-box",
              }}
            >
              {/* swap this block for <Img src={staticFile("card1.jpg")} /> when you have images */}
              <div
                style={{
                  height: "100%",
                  borderRadius: 16,
                  background: `linear-gradient(160deg, ${
                    ["#D8D8D8", "#C9CFC9", "#D8CFC4"][i]
                  }, #F2F2F2)`,
                  marginBottom: 26,
                }}
              />
              <div style={{ fontSize: 30, fontWeight: 700, color: INK }}>zyvo</div>
              <div style={{ fontSize: 20, color: "#8A8A8E" }}>motion preset {i + 1}</div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 40,
          left: x,
          whiteSpace: "nowrap",
          fontFamily: "'Great Vibes', cursive",
          fontSize: 160,
          color: INK,
        }}
      >
        Motion Graphics
      </div>
    </AbsoluteFill>
  );
};

// ───────────────────────── root ─────────────────────────

export const CleanTextDemo: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: "#0B0B0B" }}>
      <AbsoluteFill>
        <SceneA />
      </AbsoluteFill>
      <AbsoluteFill style={{ display: frame >= 90 ? "block" : "none" }}>
        <SceneB />
      </AbsoluteFill>
      <AbsoluteFill style={{ display: frame >= 240 ? "block" : "none" }}>
        <SceneC />
      </AbsoluteFill>
      <AbsoluteFill style={{ display: frame >= 360 ? "block" : "none" }}>
        <SceneD />
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

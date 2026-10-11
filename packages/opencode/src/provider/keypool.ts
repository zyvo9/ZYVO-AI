// Per-provider API-key pools. When one key's quota dies, the SAME model
// continues on the next key instead of hopping to a weaker fallback model —
// the user chose that model and wants to keep using it. Keys come from the
// provider config: "options": { "apiKeys": ["sk-..", "sk-.."] }. The model
// picker still shows the model ONCE — the pool is invisible plumbing.
const pools = new Map<string, { keys: string[]; cursor: number }>()

function normalize(keys: unknown): string[] {
  return Array.isArray(keys)
    ? [...new Set(keys.filter((k): k is string => typeof k === "string" && k.trim().length > 0).map((k) => k.trim()))]
    : []
}

export function configure(providerID: string, keys: unknown) {
  const clean = normalize(keys)
  if (clean.length === 0) return
  const existing = pools.get(providerID)
  // same key list → keep the rotation cursor (config re-reads must not
  // reset which key is currently active)
  if (existing && existing.keys.join("|") === clean.join("|")) return
  pools.set(providerID, { keys: clean, cursor: 0 })
}

export function size(providerID: string): number {
  return pools.get(providerID)?.keys.length ?? 0
}

export function current(providerID: string): string | undefined {
  const pool = pools.get(providerID)
  if (!pool || pool.keys.length === 0) return undefined
  return pool.keys[pool.cursor % pool.keys.length]
}

// advance to the next key in the pool; false when there is no pool worth
// rotating (single key or empty)
export function rotate(providerID: string): boolean {
  const pool = pools.get(providerID)
  if (!pool || pool.keys.length < 2) return false
  pool.cursor = (pool.cursor + 1) % pool.keys.length
  return true
}

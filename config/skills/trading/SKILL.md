---
name: trading
description: Trading tools playbook for crypto (Binance) and Forex — write TradingView Pine Script v6 indicators and strategies from any described strategy (entries, exits, SL/TP, alerts, webhooks), build trading bots with ccxt/python-binance (spot + futures, testnet-first, websocket streams), write MetaTrader 5 EAs (MQL5) and the MetaTrader5 Python bridge for Forex, backtest with realistic fees/slippage (vectorbt/backtrader), and mandatory risk management (position sizing, stop-loss, take-profit, R:R) in every output. Use when the user asks for a TradingView indicator or strategy, a Binance/crypto trading bot, a Forex EA, to convert a described strategy into code, backtest a strategy, set up exchange API access, or says "indicator banao", "pine script likho", "binance bot banao", "tradingview strategy", "forex ea likho", "trading bot chalao".
---

# Trading Playbook (TradingView · Binance · Forex)

You are a trading-tools engineer. The user explains a strategy in their own
words (often Banglish) — you turn it into WORKING code: a TradingView
indicator/strategy, an exchange bot, or a Forex EA. You never lecture, but
every output carries risk management and one honest line: markets carry real
loss risk — no tool guarantees profit.

## Golden rules

1. **Risk management is never optional**: every strategy/bot output includes
   stop-loss, take-profit, and position sizing (risk a fixed % per trade,
   e.g. 1-2%: `size = account * risk% / (entry - stop)`). No SL = no code.
2. **TESTNET FIRST**: any bot that can place real orders runs against the
   exchange testnet until the user explicitly says "real money". API keys
   come from environment variables — never hardcoded, never committed.
3. **Honesty**: never promise profit. "somponno profit" does not exist in
   markets — say it in one line when the user implies it, then build the
   best tool anyway.
4. **No financial advice**: you build indicators/bots from the USER'S
   strategy. The decisions are theirs; you state risk in one line.
5. Small, verifiable steps: build one indicator/bot → test → iterate, like
   every other zyvo workflow (MOD_NOTES if the project spans sessions).

## PART A — TradingView (Pine Script v6)

The user describes a strategy → you write ONE script they paste into
TradingView (Pine Editor → paste → Add to chart).

### Indicator template

```pine
//@version=6
indicator("My Indicator", overlay=true)

// inputs the user can tweak on the chart
lenFast = input.int(9,  "Fast EMA")
lenSlow = input.int(21, "Slow EMA")
src     = input.source(close, "Source")

fast = ta.ema(src, lenFast)
slow = ta.ema(src, lenSlow)
longSignal  = ta.crossover(fast, slow)
shortSignal = ta.crossunder(fast, slow)

plot(fast, "Fast EMA", color=color.aqua)
plot(slow, "Slow EMA", color=color.orange)
plotshape(longSignal,  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(shortSignal, style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)
alertcondition(longSignal,  "Long alert",  "EMA cross UP on {{ticker}}")
alertcondition(shortSignal, "Short alert", "EMA cross DOWN on {{ticker}}")
```

### Strategy template (backtestable — Strategy Tester tab)

```pine
//@version=6
strategy("My Strategy", overlay=true, default_qty_type=strategy.percent_of_equity,
     default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.1)

longCondition  = ta.crossover(ta.ema(close, 9),  ta.ema(close, 21))
shortCondition = ta.crossunder(ta.ema(close, 9), ta.ema(close, 21))

if longCondition
    strategy.entry("Long", strategy.long)
if shortCondition
    strategy.close("Long")
```

### Translating a described strategy (the real skill)

Break the user's words into: ENTRY condition + EXIT condition + RISK
(stop/TP) + FILTER (trend/volume/session). Example — user says: "RSI 30 er
niche namle kine, 50 upte charle boncbo, ar 200 EMA-er upore hole sudhu":

```pine
rsiVal   = ta.rsi(close, 14)
trendOK  = close > ta.ema(close, 200)
entry    = ta.crossover(rsiVal, 30) and trendOK
exit     = ta.crossover(rsiVal, 50)
if entry and strategy.position_size == 0
    strategy.entry("Long", strategy.long)
if exit
    strategy.close("Long")
```

Common building blocks: `ta.rsi`, `ta.macd`, `ta.bb`, `ta.atr` (stops),
`ta.supertrend`, `ta.vwap`, `ta.highest/lowest` (breakouts), volume filters
(`volume > ta.sma(volume, 20) * 2`), session filters. Alerts: TradingView
webhook URL → the user's bot receives JSON (`alert()` + placeholder vars).

## PART B — Binance / crypto (ccxt — python)

Setup (keys from env, testnet first):

```python
import ccxt, os
ex = ccxt.binance({
    "apiKey": os.environ["BINANCE_KEY"],
    "secret": os.environ["BINANCE_SECRET"],
    "enableRateLimit": True,
})
ex.set_sandbox_mode(True)   # TESTNET until the user says real money
```

Fetch data + a signal:

```python
import pandas as pd, pandas_ta as ta
o = pd.DataFrame(ex.fetch_ohlcv("BTC/USDT", "15m"), columns=["t","o","h","l","c","v"])
o["rsi"] = ta.rsi(o["c"], 14)
print(o["rsi"].iloc[-1])
```

Bot skeleton (poll → signal → order → SL/TP):

```python
def position_size(balance_usdt, risk_pct, entry, stop):
    return round((balance_usdt * risk_pct / 100) / abs(entry - stop), 4)

if entry_signal and not ex.fetch_balance()["USDT"]["free"] == 0:
    amount = position_size(1000, 1, price, stop_price)
    ex.create_order("BTC/USDT", "market", "buy", amount)
    ex.create_order("BTC/USDT", "limit", "sell", amount, take_profit)
    ex.create_order("BTC/USDT", "stop_market" if ex.id == "binance" else "stop",
                    "sell", amount, None, {"stopPrice": stop_price})
```

- **Futures**: `ex.set_leverage(3, symbol)` — warn: leverage cuts BOTH ways,
  keep it low, liquidation is real.
- **WebSocket streams** for live prices: `ccxt.pro` or Binance websocket
  (`wss://stream.binance.com:9443/ws/btcusdt@kline_15m`).
- Binance testnet: testnet.binance.vision (spot), testnet.binancefuture.com
  (futures) — keys are separate from the real account.

## PART B2 — BINARY OPTIONS (Quotex & similar platforms)

Binary = fixed-time up/down trades. Payout ~80-92%, but a wrong call loses
100% — so the break-even win rate is 1/(1+payout) ≈ **55.6% at 80% payout**.
State this math in one line: below that win rate, ANY strategy loses
long-term. Then build the tool anyway — that is the job.

- **pyquotex** (unofficial Quotex client, `pip install pyquotex`):

```python
from quotexapi import Quotex
client = Quotex("email", "password")   # demo account first — always
await client.connect()
balance = await client.get_balance()
# candles for the signal logic
candles = await client.get_candles(asset, end_from_time, offset, period)
# the trade: amount, asset, direction ("call"/"put"), duration in seconds
result = await client.buy(amount=1, asset="EURUSD_otc", direction="call", duration=60)
```

- **Signal bot skeleton**: poll candles → run the same indicator stack
  (pandas_ta — RSI/EMA/BB from Part A) → call/put signal → `client.buy` →
  log win/loss → win-rate tracker (the tracker is what proves the strategy).
- **Manual-signal mode** (no API / platform without one): the user pastes or
  screenshots the candles → you compute the signal → the user clicks the
  trade by hand. Works for ANY binary platform.
- **"Binary Fund" / fund-management platforms**: if they expose an API, the
  same ccxt-style pattern applies; if they only take deposits and promise
  returns, that is not a trading tool — say it in one line.
- **Practice account first** (Quotex demo), OTC pairs are broker-generated
  candles — strategy behavior differs from real pairs.

## PART B3 — FUNDED CHALLENGES (prop firms: BinaryFunded etc.)

Binary-options prop firms: pay a small challenge fee → hit a profit target
within drawdown limits → trade the firm's capital → keep 80-90% of profits.
BinaryFunded example: $3 Mini Challenge → $1,500 funded; up to $100K funded
accounts; 85% profit split; per-trade payout up to 94% (indices), crypto
84-92%, commodities 82-88%, forex 78-82%; no time limit; free $10K demo.
Platform reality (researched): own JS web terminal (no MT5/API) — signals
run in MANUAL mode or via browser automation; exact challenge numbers
(target %, drawdown %) are behind registration — verify inside the
dashboard before trading, never trust marketing numbers.

**The math that decides everything:**
- Break-even win rate = 1/(1+payout) → indices at 94% = 51.5%, forex at 80%
  = 55.6%. Trade the HIGHEST-payout market available (indices) — the edge
  needed is smallest there.
- The challenge is a SURVIVAL test, not a profit race: max daily drawdown
  (~3%) and total drawdown (~5%) kill more accounts than losing trades do.

**Passing framework (any funded binary challenge):**
1. Fixed 1-2% risk per trade — never more, the drawdown limit is the boss.
2. ONE setup only (e.g. S/R level + reversal candle + RSI confirmation on
   1-5 min expiry), mastered on the free demo first.
3. Trade ONLY the best windows: London open + NY overlap; skip OTC/choppy
   sessions.
4. Daily stop: after -2% day (or 2 losses), STOP until tomorrow — protects
   the daily drawdown limit.
5. Progression flat (same size every trade) — no martingale EVER (one
   streak = total drawdown breach = challenge failed).
6. Track every trade: asset, setup, win/loss, payout — the win-rate tracker
   (Part B2) tells you when the edge is real (need >55% at 90% payout).
7. Verify the firm: payout proofs/withdrawal reviews BEFORE paying more
   than the minimum challenge fee — the smallest fee IS the verification.

Red flags to state in one line: unregulated niche, aggressive marketing
("$3 to $1,500"), some firms delay/deny payouts — start minimum, withdraw
early and often.

## MONEY MANAGEMENT — the full math (explain this to users)

Money management IS the strategy. A mediocre setup with great risk control
passes challenges; a great setup with bad sizing blows them. When the user
asks about money management, teach THIS.

### Universal rules (every account, every market)

1. **Fixed fractional sizing**: risk the same small % every trade (1-5%).
   Never size by feeling, never double after a loss.
2. **Streak survival — the sizing table** (losses WILL come in streaks;
   at a 55% win rate a 5-6 loss streak is NORMAL, expected every ~100-150
   trades):

   | Risk/trade | Survives | Drawdown after 6 straight losses |
   |---|---|---|
   | 10% | 9 losses | -46.8% (account crippled) |
   | 5% | 19 losses | -26.5% |
   | 3% | 32 losses | -16.7% |
   | 2% | 49 losses | -11.4% |
   | 1% | 99 losses | -5.9% (challenge-safe) |

3. **Kelly-lite**: Kelly% = (winrate × (payout+1) − 1) / payout. Example:
   58% win rate at 0.85 payout → Kelly 8.6% → trade **HALF Kelly ≈ 4%**
   max. Full Kelly swings destroy accounts; half-Kelly is the ceiling.
4. **Daily stop**: stop after 2-3 losses or -2/-3% in a day. The market
   exists tomorrow; the account must too.
5. **Recovery trading BAN**: never increase size to "win it back" — that is
   how -5% becomes -50%. After a losing streak, size stays the same.

### Funded-challenge money management (BinaryFunded type)

The challenge is a SURVIVAL test: the drawdown limits decide everything.

- **Challenge phase (passing)**: risk 1% per trade (hard cap 2%). With a
  ~3% daily / ~5% total drawdown, 1% risk = you can be wrong 5 times TOTAL
  and still be in the game.
- **The pass math**: profit target ÷ risk per trade = net wins needed.
  Example: +10% target at 1% risk = +10 net wins. At 90% payout, a 58% win
  rate gives +1.22R per 10 trades → ~8 net wins per 100 trades → pass in
  roughly 2-4 weeks of patient trading. Bigger risk = faster, but one bad
  day = breach.
- **Flat sizing during the challenge** — compounding near the drawdown
  cliff means one loss eats two wins. Compound AFTER funded.
- **Funded phase**: same 1-2% risk, withdraw the 85% split regularly
  (firm-risk reduction), keep a personal copy of every payout proof.

### Binary-options money management (payout asymmetry)

Binary is asymmetric: you risk 100 to win ~85 — the sizing must compensate:

- **Payout-adjusted sizing**: to WIN a target W at payout b (0.85),
  stake = W / b. Example: to net $85 you must stake $100 — plan targets in
  RISK terms, not reward terms.
- **Break-even win rate** = 1/(1+payout): 0.85 → 55.6%, 0.92 → 52.1%.
  Track your REAL win rate (the tracker) — if it sits under break-even,
  no sizing saves the strategy; stop and fix the setup.
- **Streak rule for binary**: same table as above — at 1-2% sizing a 6-loss
  streak costs 6-12%, survivable; at 10% it costs ~47%, account dead.
- **Compounding** only after 100+ tracked trades above break-even, capped
  at half-Kelly.

### Teach it back

When a user asks "koto taka diye khelbo", answer with THE TABLE + the
streak math, then their number. "100% lagbe" is always the wrong answer —
say what the survivable size is and why.

## EDGE BOOSTERS — grow the profit margin (the full framework)

The formula behind everything: **Expectancy = (Win% × AvgWin) − (Loss% × AvgLoss)**.
When the user asks "profit margin barano jay?", THIS framework is the answer —
every technique touches exactly one of the three terms.

### Win-rate boosters

1. **Confluence stacking** — enter only with 3+ confirmations together
   (S/R level + rejection candle + RSI zone + volume spike): one signal alone
   wins ~50-55%; three-four confluences test at 65%+ (verify in backtest).
2. **Multi-timeframe alignment** — trade ONLY in the higher-timeframe
   trend's direction (1H trend up → only CALL signals on 5m). The HTF is
   the filter, the LTF is the trigger.
3. **Session filter** — London open + NY overlap = the cleanest moves;
   Asian chop and OTC candles behave differently — reduce size or skip.
4. **News filter** — no entries 15 minutes around red-folder economic
   events (spikes are random); integrate an economic calendar feed and
   gate the signals.
5. **Journal + cut weak setups** — log every trade (setup, session,
   confluence count, result). Any setup under break-even after 30 trades
   gets CUT. Killing two weak setups raises the blended win rate for free —
   the most underrated boost.

### Average-win boosters

6. **Partial exits** — close 50% at 1R, trail the remainder (ATR trail) to
   2-3R: the win stops being cut short.
7. **Structure-based TP** — the next S/R level, never a fixed distance.
8. **Trend mode** — trailing stop instead of fixed TP while the trend holds.

### Average-loss reducers

9. **Retest entries** — never chase breakouts; enter on the retest → the
   stop sits closer → the same $ risk buys a bigger position → bigger win.
10. **ATR-based stops** — `entry − 2×ATR` adapts to volatility; fixed pips
    get spiked out.
11. **The no-trade IS a position** — every trade costs spread/fees; a
    marginal setup skipped = margin saved.

### Market & cost selection

12. **Highest payout / lowest spread market first** (indices on binary
    platforms = lowest break-even win rate; tight-spread sessions on forex).
13. **Over-trading is the biggest hidden margin killer** — 3 A+ trades beat
    100 mediocre ones. Fewer, better, bigger.

### The tools zyvo can build for the edge

- **MTF dashboard indicator** — 4 timeframes' trend direction on one screen
- **News-filter integration** — economic calendar feed → signals OFF around
  red events
- **Setup tracker** — per-setup win rate live (kill weak setups with data)
- **Backtest engine** — expectancy numbers per setup (vectorbt / Pine
  Strategy Tester) before real trades
- **Journal analyzer** — auto-report: which session, pair, and confluence
  count actually win
- **Drawdown guard + win-rate tracker** (Part B2/B3) — the survival layer

### The honest truth

The biggest margin killers are psychological: over-trading, revenge
trading, moving the stop. The rules above only work followed MECHANICALLY —
that is why the automated path (Part B bots with hard-coded rules) often
beats manual trading on the same strategy: code has no feelings.

## PART C — FOREX (MetaTrader + MQL5)

- **MetaTrader5 python bridge** (Windows, `pip install MetaTrader5`):
  `mt5.initialize()` → `mt5.copy_rates_from_pos("EURUSD", mt5.TIMEFRAME_M15, 0, 500)`
  → pandas → same indicator/signal logic → `mt5.order_send(request)` with
  SL/TP in the request dict.
- **MQL5 EA** (the .mq5 file the user compiles in MetaEditor): give a full
  skeleton — `OnInit`, `OnTick` with signal check, `CTrade` for orders,
  input parameters (Lots, SL, TP) so the user tweaks without code.
- Forex risk note: leverage is the norm — position sizing (Part Golden rule)
  matters MORE than in crypto; always size from the stop distance.

## PART D — BACKTESTING (prove it before it trades)

- **TradingView**: strategy template → Strategy Tester tab → read net
  profit, drawdown, win rate — WITH commission set (default 0.1%).
- **Python**: vectorbt or backtrader; always subtract fees + slippage:
  `pf = vbt.Portfolio.from_signals(close, entries, exits, fees=0.001)`
- Overfitting warning (one line): a strategy tuned to look perfect on past
  data usually fails live — test on data the parameters were not tuned on.

## Risk management (in EVERY output)

- Stop-loss: ATR-based (`entry - 2*ATR`) or structure-based (recent low)
- Take-profit: minimum 1.5-2R (risk:reward); partial exits are fine
- Position sizing: fixed % risk (1-2% default) — never "all in"
- One honest line per delivery: markets carry real loss risk; this tool
  manages risk, it does not remove it.

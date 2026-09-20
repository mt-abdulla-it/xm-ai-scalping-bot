# AI Scalping Bot - Known Rules & Fixes

When maintaining or updating the AI Scalping Bot (MQL5 EA and Python Brain), ALWAYS adhere to these learned rules based on past bugs:

1. **Reasoning Model Outputs (LLMs)**: When using reasoning models (like Qwen, DeepSeek), they often output `<THINK>` blocks before their final decision. A simple `if "BUY" in response` WILL FAIL because the model might mention the word "BUY" while reasoning (e.g. "Since RSI is 50, I should not BUY"). 
   * **Rule**: Always use Regex to extract the LAST occurrence of the command keywords: `matches = re.findall(r'\b(BUY|SELL|WAIT)\b', raw_response); decision = matches[-1] if matches else "WAIT"`.

2. **Broker Stop Levels (MT5)**: Some ECN brokers (like XM) return `0` for `StopsLevel()`, but they still reject trades with "Error 4756 (Invalid Stops)" if the SL/TP distance is smaller than the current spread.
   * **Rule**: NEVER trust `if (minStop > 0)` to apply a fallback limit. Instead, use: `if (minStop <= 0) minStop = m_symbol.Spread() * _Point * 2.0;` to guarantee a minimum distance.

3. **Small Account Risk Guards (MT5)**: EAs often have a "Strict Risk Guard" that calculates if the minimum lot size (0.01) exceeds the allowed risk percentage. On tiny accounts (e.g., $15), even a 0.01 lot trade might risk 10% of the account.
   * **Rule**: If the EA strictly aborts the trade (`return 0`), the bot will be permanently blocked on small accounts. Instead of aborting, log a warning and execute at the minimum lot size (`lotSize = minLot;`).

4. **Optimal Scalping Defaults (MT5)**: When updating the `XM_AI_ScalpingBot.mq5` file, always ensure the following default inputs are maintained for high-frequency scalping (M5 timeframe):
   * **Rule**: EMA Crossover Lookback: Keep the `recentBuyCross` and `recentSellCross` lookback at **24 bars** (not 6 bars) to allow "Trend Surfing" on the M5 timeframe.
   * **Rule**: AI Filter: `InpUseONNX_AI` must default to `false` and `InpONNX_MinProb` to `0.50` while the user is gathering the initial 1000+ trades for their dataset.
   * **Rule**: SMC & Correlation: `InpUseSMC_FVG` and `InpUseCorrelation` must default to `false` to prevent blocking fast momentum trades.
   * **Rule**: DOM Filter: `InpUseDOM_Filter` should remain `true` to block institutional sell/buy walls.

5. **Perry Kaufman - Trading Systems & Methods (TSaM) Rules**:
   * **Noise vs Trend Selection (Efficiency Ratio)**: Use Kaufman's Efficiency Ratio \(ER = \frac{|\Delta \text{Price}|}{\sum |\Delta \text{Bar Prices}|}\). When \(ER > 0.40\) (Low Noise), prioritize Trend-Following (EMA/Breakout). When \(ER < 0.25\) (High Noise), prioritize Mean-Reversion / Range trading.
   * **Dynamic Volatility Box Sizing**: Never use fixed point sizes for Point-and-Figure or Breakouts over long history; scale box sizes using ATR (\(1 \times \text{ATR}\) or fixed % of price) to maintain consistent sensitivity across high and low volatility regimes.
   * **Turtle Risk Management**: Calculate unit size as \(1 \text{ Unit} = \frac{1\% \text{ Portfolio Risk}}{\text{ATR} \times \text{Point Value}}\) and place trailing stop loss at \(2 \times \text{ATR}\).
   * **Pin Bar Reversal Filtering**: Pin Bar reversal trades must have a tail at least \(2\times\) the body size, preceded by at least 3 consecutive directional candles, with Stop Loss pinned at the extreme tail.
   * **Kaufman Adaptive Moving Average (KAMA)**: Use KAMA instead of fixed-period EMA when market regime changes frequently. KAMA auto-adjusts its smoothing constant using ER: fast SC (2-period) in trending, slow SC (30-period) in noise. This reduces whipsaws without adding lag.
   * **Momentum Divergence as Exit Signal**: When price makes a new High but RSI/MACD fails to confirm (Bearish Divergence), treat as exit/tighten-stop signal, NOT immediate reversal entry. Reverse applies for Bullish Divergence at lows.
   * **Day Trading Breakout Window**: For intraday breakout strategies, highest-probability window is first 30-90 minutes after market open. Breakouts after first 2 hours have significantly lower success rates due to declining volume.
   * **Robustness over Optimization**: Prefer strategies working across many markets with fewer rules. Never optimize with more than 4-5 free parameters. A robust strategy with lower Sharpe is superior to an over-fitted one.
   * **Kaufman on Stops**: Wide stops produce better results than tight stops for trend systems. Stops must be ATR-based (not fixed pips). Profit targets reduce trend-following performance; use trailing stops instead.
   * **Fat Tails & Extreme Events**: Price distributions have fat tails. Always assume worst-case drawdown = 2× historical max. Size positions to survive simultaneous adverse moves in all correlated positions.
   * **Volume Confirms Trend**: Rising price + Rising volume = Strong continuation. Rising price + Falling volume = Weakening trend. Always check volume alignment before breakout entries.
   * **Multiple Time Frame Confirmation (Elder Triple Screen)**: Use 3 TFs: Higher for trend direction, Middle for entry signals, Lower for precise timing. Never trade counter to the higher TF trend.
   * **Support/Resistance Flip (S/R Flip)**: When price breaks above a resistance level, that level becomes new support (and vice versa). After a breakout, wait for price to retest the broken level before confirming the trade. Place trailing stop loss just below the flipped S/R level rather than at arbitrary distances.
   * **Price Shock Filter (Crisis Management)**: Trend-following systems disconnect during extreme price shocks. If the recent price move (e.g., current bar or session) exceeds 5× ATR, moving averages become invalid (out of phase). Suspend new trend entries until volatility normalizes. If a shock yields a windfall profit, take it immediately rather than waiting for the trailing stop.
   * **Never Average Down (Anti-Martingale)**: Never add to a losing position to improve the average entry price (averaging down). If scaling into a position, only add on new high profits. Optimal risk sizing prohibits averaging down.

6. **Small Account Hard Max Lot Safety Cap**:
   * On small accounts ($100-$150 balance), tight Stop Losses (e.g. 7.5 pips) can cause risk-based lot sizing equations `riskAmount / (slPoints * tickValue)` or Kelly Criterion scaling to calculate large lot sizes (0.22 - 0.34 lot).
   * **Rule**: ALWAYS enforce a hard safety lot cap: `if (balance < 200.0) lotSize = MathMin(lotSize, 0.03);` so no single trade can ever exceed 0.03 lot on $100-$150 accounts.

7. **Universal Symbol Hard Loss Shield**:
   * In `ManageOpenPositions()`, position management must NOT filter out trades using `m_position.Symbol() != _Symbol` when `InpAutoMultiSymbol = true`.
   * **Rule**: Ensure `ManageOpenPositions()` checks all positions matching `InpMagicNumber` so that the Hard Dollar Loss Shield (`InpMaxDollarLossPerTrade = 2.50`) applies universally across ALL open positions regardless of symbol.

8. **MT5 Strategy Tester XML Optimization Reports**:
   * MT5 exports optimization reports as Excel-compatible XML (`ReportOptimizer-<account>.xml`).
   * **Rule**: When analyzing `ReportOptimizer-*.xml`, extract `Symbol`, `Pass`, `Profit`, `Profit Factor`, `Equity DD %`, and `Trades` to evaluate multi-symbol historical performance.

9. **AI Ecosystem Differences (MQL5 vs Python Agent Platforms)**:
   * Do not conflate Python-based AI agent platforms (like `HKUDS/AI-Trader` which use LLMs to debate and trade) with Native MT5 bots (like `XM_AI_ScalpingBot.mq5`).
   * **Rule**: The native MT5 EA is completely self-contained (using built-in ONNX ML logic) and operates directly inside the MetaTrader 5 ecosystem. Python AI platforms are completely different architectures and are not needed to execute native MQL5 EAs.

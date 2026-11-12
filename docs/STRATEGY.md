# 📐 Quantitative Trading Strategy & Mathematical Specification

The **XM AI Scalping Bot** is an institutional-grade, multi-asset algorithmic trading engine combining classical quantitative market microstructure models with real-time ONNX Machine Learning inference.

---

## 1. Market Noise vs. Trend Detection: Kaufman Efficiency Ratio (ER)

Market regimes oscillate between directional momentum (trending) and random Brownian motion (noise). To avoid whipsaws, the bot dynamically calculates **Perry Kaufman's Efficiency Ratio (ER)** across a rolling lookback window of $n$ periods:

$$\Delta \text{Price} = |P_t - P_{t-n}|$$

$$\text{Volatility} = \sum_{i=0}^{n-1} |P_{t-i} - P_{t-i-1}|$$

$$\text{ER} = \frac{\Delta \text{Price}}{\text{Volatility}} = \frac{|P_t - P_{t-n}|}{\sum_{i=0}^{n-1} |P_{t-i} - P_{t-i-1}|}$$

### Operational Regimes:
* **$\text{ER} > 0.40$ (Low Noise / High Trend)**: Prioritizes trend continuation, momentum breakouts, and exponential moving average surf entries.
* **$\text{ER} < 0.25$ (High Noise / Range Bound)**: Tightens breakout gates, engages mean-reversion filters, or suspends new market orders to protect capital from whipsaws.

---

## 2. Kaufman Adaptive Moving Average (KAMA)

Standard fixed-period EMAs suffer from a fundamental trade-off: fast averages generate excessive false signals in choppy markets, while slow averages suffer from severe lag during directional breakouts.

KAMA resolves this by scaling its smoothing constant ($\alpha_t$) dynamically based on current market noise:

$$\text{Fast SC} = \frac{2}{2 + 1} \approx 0.6667$$

$$\text{Slow SC} = \frac{2}{30 + 1} \approx 0.0645$$

$$\text{Scaled Smoothing Constant } (SC_t) = \left[ \text{ER}_t \times (\text{Fast SC} - \text{Slow SC}) + \text{Slow SC} \right]^2$$

$$\text{KAMA}_t = \text{KAMA}_{t-1} + SC_t \times (P_t - \text{KAMA}_{t-1})$$

When the market is noisy ($\text{ER} \to 0$), $SC_t$ drops to its minimum, causing KAMA to flatten out and ignore chop. When momentum breaks out ($\text{ER} \to 1$), $SC_t$ surges, tracking price movements rapidly without lag.

---

## 3. Multiple Time Frame (MTF) Alignment: Elder Triple Screen

To guarantee that intraday micro-scalps are never executed against institutional macro trends, the engine implements Dr. Alexander Elder's Triple Screen framework:

1. **Higher Timeframe (H1 - Macro Tide)**: Evaluates trend direction using the 50-period Exponential Moving Average ($\text{EMA}_{50}$).
   - $\text{Price} > \text{EMA}_{50} \implies$ Bullish Bias (Only BUY setups permitted).
   - $\text{Price} < \text{EMA}_{50} \implies$ Bearish Bias (Only SELL setups permitted).
2. **Middle Timeframe (M5 - Momentum Wave)**: Fast EMA crossovers ($EMA_9$ / $EMA_{21}$) and Kaufman ER confirmation.
3. **Lower Timeframe (M1 - Execution Ripple)**: Pinpoint tick execution with micro-spread and Depth of Market (DOM) checks.

---

## 4. Volatility-Scaled Risk & Dynamic ATR Trailing Stops

Fixed pip stop-losses fail across changing volatility regimes. The bot scales all risk parameters relative to the **Average True Range (ATR)**:

$$\text{TR}_t = \max\left( (H_t - L_t),\, |H_t - C_{t-1}|,\, |L_t - C_{t-1}| \right)$$

$$\text{ATR}_t = \frac{\text{ATR}_{t-1} \times (n - 1) + \text{TR}_t}{n}$$

### Trailing Stop Protocol:
* **Initial Protective Stop**: Pinned at $1.5 \times \text{ATR}$ or the extreme tail of the confirmation candle.
* **Profit Activation**: Once floating profit reaches $1.0 \times \text{ATR}$, trailing stop activates and steps forward in micro-units.
* **Hard Dollar Loss Shield**: Irrespective of ATR, an uncompromising server-side hard ceiling terminates individual orders at `-InpMaxDollarLossPerTrade` (e.g., -$30.00) to protect against unexpected liquidity gaps.

---

## 5. Anti-Martingale Capital Preservation & Kelly Criterion

The bot strictly enforces **Perry Kaufman's Anti-Martingale Rule**:
> *"Never add to a losing position to improve the average entry price. Scaling in is only permitted at new profit highs."*

### Position Sizing:
$$Lot = \min\left( \frac{\text{Equity} \times \text{Risk}\%}{\text{StopLoss Points} \times \text{TickValue}},\, \text{InpMaxAllowedLot} \right)$$

On small accounts ($<\$200$), a strict safety lot cap ($0.03$ lot max) supersedes all equations to guarantee survival against catastrophic black swan events.

---

## 6. ONNX Neural Network Inference Pipeline

When `InpUseONNX_AI = true`, every potential technical setup must be validated by an embedded Machine Learning model before an order ticket is dispatched:

```
[Technical Indicators] ──> [Feature Normalization] ──> [ONNX Runtime] ──> Win Probability
  - RSI (14)                 - RobustScaler               (RandomForest     - Threshold: >= 0.50
  - Spread (pts)                                           or MLP)          - Decision: APPROVE / REJECT
  - Kaufman ER
  - MACD Histogram
  - ATR Volatility
```

If predicted win probability is below `InpONNX_MinProb`, the signal is rejected, logging telemetry to `XMBot_ML_Data.csv` for continuous retraining.


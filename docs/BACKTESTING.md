# 🧪 MetaTrader 5 Strategy Tester & Backtesting Guide

This guide provides step-by-step instructions for running high-fidelity, institutional backtests and multi-symbol genetic optimizations on the **XM AI Scalping Bot**.

---

## 1. Prerequisites for 99.9% Modeling Quality

Scalping systems are hypersensitive to bid/ask spreads, slippage, and execution latency. Testing on synthetic 1-minute OHLC bars will yield unrealistic results.

1. **Modeling Mode**: Always select **"Every tick based on real ticks"** in the MT5 Strategy Tester settings.
2. **Historical Data Download**:
   - Open MT5 → **View** → **Symbols** (**Ctrl + U**).
   - Select your target symbol (e.g., `EURUSD`, `GOLD`, `US30Cash`).
   - Navigate to the **Bars** and **Ticks** tabs and click **Request** to pull maximum tick history from your broker's servers.

---

## 2. Recommended Strategy Tester Configuration

| Field | Recommended Value | Notes |
|---|---|---|
| **Expert Advisor** | `XM_AI_ScalpingBot.ex5` | Ensure latest build from `compile_bot.sh` |
| **Symbol** | `EURUSD` or multi-currency | Select primary test asset |
| **Period** | `M1` (1 Minute) | Core scalping timeframe |
| **Date Range** | Custom (Minimum 3-6 months) | Covers multiple market volatility regimes |
| **Forward** | 1/3 Forward Testing | Validates out-of-sample robustness |
| **Execution** | Random delay (e.g. 50-100 ms) | Simulates real-world VPS network ping |
| **Deposit** | Match intended live capital | e.g. `$100,000` or `$1,000` |
| **Leverage** | `1:100` to `1:500` | Account broker leverage setting |

---

## 3. Parameter Optimization Protocols

When running genetic optimization across parameters:

### Rule of Robustness (TSaM Principle):
> *"Never optimize more than 4 to 5 free parameters simultaneously. Over-optimized strategies fit historical noise rather than persistent market inefficiencies."*

### Key Optimization Variables:
1. `InpTrailingStopPoints`: Test step range `15.0` to `45.0` (step `5.0`).
2. `InpRecentCrossLookback`: Test step range `12` to `36` (step `4`).
3. `InpMaxSpreadPoints`: Keep fixed to your broker's 95th percentile spread.
4. `InpMaxDollarLossPerTrade`: Scale to `0.03% - 0.05%` of total balance.

---

## 4. Analyzing Strategy Tester XML Reports

MetaTrader 5 outputs comprehensive optimization datasets as Excel-compatible XML (`ReportOptimizer-<account>.xml`).

When evaluating multi-pass runs, filter and sort by:

$$\text{Recovery Factor} = \frac{\text{Net Profit}}{\text{Maximum Equity Drawdown (\$)}}$$

$$\text{Sharpe Ratio} = \frac{R_p - R_f}{\sigma_p} > 1.80$$

$$\text{Profit Factor} = \frac{\text{Gross Profit}}{\text{Gross Loss}} \ge 1.40$$

### Critical Rejection Criteria:
- **Maximum Equity Drawdown > 12.0%**: Discard setup.
- **Trades < 300**: Sample size is statistically insufficient.
- **Profit Concentration**: If >30% of total net profit comes from a single trade or day, the model is curve-fitted.

---

## 5. Transition to Paper Trading (Forward Demo)

Once backtest criteria are satisfied:
1. Deploy to a 24/7 Linux VPS or dedicated desktop instance.
2. Run on live XM Demo for a minimum of **2 weeks (1000+ executed trades)**.
3. Validate that real-time slippage and spread logs match Strategy Tester telemetry before live capital deployment.


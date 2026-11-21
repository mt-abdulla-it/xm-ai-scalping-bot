# 🎛️ Pre-configured Trading Presets (.set)

This folder contains institutional configuration files (`.set`) optimized for specific account sizes, risk appetites, and evaluation guidelines.

---

## 📁 Available Presets

### 1. 🛡️ `EURUSD_M1_Conservative.set`
- **Target Audience:** Personal trading accounts ($100 – $5,000) focusing on steady, low-drawdown capital preservation.
- **Risk per Trade:** `0.5%` (`InpRiskPercent = 0.5`)
- **Max Lot Size:** `0.05`
- **Daily Target:** `+5.0%`
- **Max Daily Loss:** `2.0%`
- **Hard Drawdown Cap:** `2.5%`
- **Max Concurrent Trades:** 10 total (1 per symbol)
- **News Event Filter:** Active (10 min buffer)

### 2. ⚡ `EURUSD_M1_Aggressive.set`
- **Target Audience:** Micro / Cent accounts seeking rapid compounding growth.
- **Risk per Trade:** `2.0%` (`InpRiskPercent = 2.0`)
- **Max Lot Size:** `0.25`
- **Daily Target:** `+15.0%`
- **Max Daily Loss:** `4.5%`
- **Hard Drawdown Cap:** `5.0%`
- **Max Concurrent Trades:** 25 total (2 per symbol)
- **News Event Filter:** Active (5 min buffer)

### 3. 🏆 `PropFirm_FTMO_FundedNext.set`
- **Target Audience:** FTMO, FundedNext, The5ers, and Funding Pips evaluation and funded phases.
- **Risk per Trade:** `0.5%` (`InpRiskPercent = 0.5`)
- **Compounding:** `false` (Strict fixed risk)
- **Daily Target:** `+5.0%` (With trailing profit lock)
- **Max Daily Loss:** `3.0%` (Safely protects the 5.0% prop firm disqualification rule)
- **Hard Drawdown Cap:** `4.0%` (Safely protects the 10.0% max loss rule)
- **Max Concurrent Trades:** 5 total (1 per symbol)
- **News Event Filter:** Strict (15 min buffer)

---

## 🚀 How to Load a Preset in MetaTrader 5

1. Open MetaTrader 5 and attach `XM_AI_ScalpingBot` to any M1 chart (recommended: `EURUSD`).
2. In the EA settings popup, switch to the **Inputs** tab.
3. Click the **Load** button in the lower-right corner.
4. Select your preferred `.set` file from this `presets/` directory.
5. Click **OK** to apply settings and begin automated execution.

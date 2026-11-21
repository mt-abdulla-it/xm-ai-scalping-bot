# 🏆 Prop Firm Challenge Passing Guide

A comprehensive institutional playbook for passing **FTMO, FundedNext, The5ers, and Funding Pips** evaluation challenges using **XM AI Scalping Bot**.

---

## 🎯 Challenge Rules vs. Bot Safety Shields

Prop trading firms enforce strict loss boundaries. The table below illustrates how the **Prop Firm VIP Preset** protects your evaluation account:

| Prop Firm Requirement | Typical Firm Rule | Bot Hard-Coded Guard | Safety Buffer |
| :--- | :---: | :---: | :---: |
| **Max Daily Drawdown** | 5.0% | **3.0% (`InpDailyLossLimitPercent`)** | **+2.0% Safety Margin** |
| **Max Overall Drawdown** | 10.0% | **4.0% (`InpMaxDrawdownPercent`)** | **+6.0% Safety Margin** |
| **Max Risk per Trade** | No hard limit | **0.50% (`InpRiskPercent`)** | Ultra-conservative |
| **Hard Loss per Trade** | No limit | **$25.00 Hard Stop (`InpMaxDollarLossPerTrade`)** | Zero runaway losses |
| **Max Open Exposure** | 10–20 lots | **Max 5 concurrent orders (`InpMaxOpenTrades`)** | Controlled margin utilization |
| **Weekend Holding** | Prohibited (Standard rules) | Automatic Friday close option | 100% compliant |

---

## 📋 Step-by-Step Challenge Setup

### Step 1: Deploy on MetaTrader 5
1. Log in to your Prop Firm challenge credentials in MT5.
2. Attach `XM_AI_ScalpingBot` to the **EURUSD M1 chart**.

### Step 2: Load the Official Prop Firm Preset
1. In the EA configuration window, navigate to the **Inputs** tab.
2. Click **Load** and select:
   ```
   presets/PropFirm_FTMO_FundedNext.set
   ```
3. Verify that:
   - `InpUseCompounding = false` (Ensures fixed fractional risk)
   - `InpRiskPercent = 0.5`
   - `InpDailyLossLimitPercent = 3.0`
   - `InpMaxDrawdownPercent = 4.0`

### Step 3: Phase 1 & Phase 2 Roadmap
- **Phase 1 (Target: 8% – 10% Profit):**
  - Expected completion: 12 to 18 active trading days with the Golden Window (13:00–17:00 GMT).
  - Daily profit target lock `InpDailyProfitTrailingLockPercent=1.5` banks gains systematically.
- **Phase 2 (Target: 5% Profit):**
  - Expected completion: 6 to 10 active trading days.
  - Reduced profit target allows even lower trade frequency and maximum risk defense.

---

## 🛡️ Key Rules to Never Break
1. **Never increase risk percent above 1.0%** during an active challenge.
2. **Never override the hard daily loss limit** — if the bot hits the daily pause, let it rest until the next trading day.
3. **Always use a low-latency VPS (< 20ms)** to ensure stop losses are acknowledged at the broker level instantly.


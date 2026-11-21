# 🛡️ Live Trading Pre-Flight Safety Checklist

Before deploying **XM AI Scalping Bot** on real capital or a live funded account, execute this 10-point institutional verification protocol.

---

## ✈️ 10-Point Pre-Flight Verification Protocol

- [ ] **1. Broker Account Type:**
  Verify that your MT5 account is configured for **Raw Spread / Zero Spread ECN** execution with raw market pricing and commission per lot.

- [ ] **2. Automated Trading Permissions:**
  In MT5, press **Ctrl+O** (Options) → select **Expert Advisors** tab → ensure **"Allow automated trading"** and **"Allow WebRequest for listed URL"** are enabled.

- [ ] **3. VPS Connection & Latency:**
  Verify your Forex VPS ping time to your broker's trading server is **under 20ms** (Check the connection status icon at the bottom-right of MT5).

- [ ] **4. Embedded Neural Model Check:**
  Confirm that `ai_brain.onnx` is located in your MT5 `MQL5/Files/` directory and is recognized upon EA attachment without errors in the Experts tab.

- [ ] **5. Preset Verification:**
  Load the appropriate preset from `presets/` matching your capital tier:
  - Micro / Cent Accounts ($50–$500) ➔ `presets/EURUSD_M1_Conservative.set`
  - High-Growth Accounts ($1,000+) ➔ `presets/EURUSD_M1_Aggressive.set`
  - Prop Firm Challenges ➔ `presets/PropFirm_FTMO_FundedNext.set`

- [ ] **6. Spread Guard Active:**
  Ensure `InpMaxSpreadPoints` is set between **20.0 and 30.0 points** to prevent execution during rollover spread spikes.

- [ ] **7. Hard Dollar Stop Loss Guard:**
  Confirm `InpMaxDollarLossPerTrade` is configured with an absolute dollar loss limit that matches your risk tolerance.

- [ ] **8. Daily Circuit Breaker Active:**
  Verify `InpDailyLossLimitPercent` is enabled (Recommended: 2.0% – 3.0%) to prevent emotional drawdown on turbulent days.

- [ ] **9. Initial 0.01 Micro-Lot Pilot Test:**
  Run the bot with `InpMaxAllowedLot=0.01` for the first 48 hours to confirm proper order execution, trailing stop tracking, and close commands.

- [ ] **10. Telemetry & Log Monitoring:**
  Check the **Journal** and **Experts** tabs in the MT5 Terminal to ensure zero `trade error 4756` (Trade disabled) or `4014` (System busy) codes.

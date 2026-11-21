# 🕒 Market Sessions & Trading Hours Guide

Optimal scalping execution relies on liquidity density, tight bid-ask spreads, and clean directional volatility. This guide outlines the institutional trading session schedule for **XM AI Scalping Bot**.

---

## 🌐 Global Trading Sessions (GMT Schedule)

```
00:00 GMT              08:00 GMT              13:00 GMT       17:00 GMT       21:00 GMT       24:00 GMT
  |----------------------|                      |               |               |               |
  |    Asian (Tokyo)     |                      |               |               |               |
  |----------------------|                      |               |               |               |
                         |----------------------|               |               |               |
                         |    London Session    |               |               |               |
                         |--------------------------------------|               |               |
                                                |   New York Session   |        |               |
                                                |----------------------|        |               |
                                                                                | Roll-over     |
```

---

## 📊 Asset-by-Session Allocation Matrix

| Trading Session | Time (GMT) | Best Performing Assets | Volatility | Average Spread | Strategy Focus |
| :--- | :---: | :--- | :---: | :---: | :--- |
| **London Open** | 07:00 – 11:00 | `EURUSD`, `GBPUSD`, `EURGBP`, `GER40` | 🔥 High | Lowest (0.1–0.8 pips) | Trend breakout & momentum scalping |
| **London / NY Overlap** | **13:00 – 17:00** | **`EURUSD`, `GBPUSD`, `XAUUSD (Gold)`, `US30`** | 🚀 Peak | **Tightest & Deepest** | **Prime execution window (Highest Win Rate)** |
| **New York Afternoon** | 17:00 – 20:00 | `US30`, `NAS100`, `USDJPY`, `USDCAD` | ⚡ Moderate | Low (0.6–1.2 pips) | Mean reversion & trailing TP harvests |
| **Asian Session** | 00:00 – 07:00 | `USDJPY`, `AUDUSD`, `NZDUSD`, `AUDJPY` | 💤 Mild | Moderate (0.8–1.5 pips) | Range-bound oscillator scalping |
| **Daily Rollover** | **21:00 – 23:00** | ⚠️ *All Assets Paused* | ❌ Widened | ⚠️ High Spreads | **Auto-Pause (Spread Filter Guards Capital)** |

---

## 💡 Best Practices for Algorithmic Scalpers

1. **Focus on the "Golden Window" (13:00 – 16:30 GMT):**
   - The overlap between the London and New York sessions produces over 50% of daily global Forex turnover.
   - The embedded ONNX model experiences its highest signal clarity during this window.

2. **Automated Spread Protection:**
   - During Asian night hours or daily 22:00 GMT swap rollover, spreads typically widen 3x–5x.
   - The bot's `InpMaxSpreadPoints` (set to 20–30 points) automatically disables trade execution until spreads normalize.

3. **News Event Windows:**
   - Never scalp through high-impact red-folder news (US Non-Farm Payrolls, FOMC Interest Rates, CPI).
   - Ensure `InpAvoidHighImpactNews=true` with a 15-minute buffer before and after releases.


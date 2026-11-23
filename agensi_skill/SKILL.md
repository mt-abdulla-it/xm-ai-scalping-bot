---
name: xm-ai-scalping-bot
description: AI-powered MetaTrader 5 and Python scalping engine combining ONNX neural network inference with quantitative Kaufman Efficiency Ratio filters for high-probability Forex, Crypto, and Gold market signal analysis and automated trade execution.
---

# 🤖 XM AI Scalping Bot — AI Agent Skill

**XM AI Scalping Bot** is an institutional-grade algorithmic trading and market analysis engine. It bridges machine learning neural inference (`ai_brain.onnx`) with quantitative volatility filtering (Kaufman Efficiency Ratio + KAMA) to generate low-latency scalping signals and automated MetaTrader 5 execution.

---

## ⚡ Core Capabilities

1. **Standalone AI Signal Inference:**  
   Evaluates tick/candle telemetry using the embedded ONNX Random Forest classifier across 9 normalized market dimensions (RSI Momentum, Spread-to-ATR Ratio, Velocity, Session Timing).
2. **Prop Firm Drawdown Shield:**  
   Hard-coded 3.0% daily circuit breaker and 4.0% relative drawdown cap engineered specifically for FTMO, FundedNext, and The5ers evaluation challenges.
3. **Multi-Asset Execution:**  
   Pre-calibrated profiles for Major Forex (`EURUSD`, `GBPUSD`, `USDJPY`), Commodities (`XAUUSD Gold`), Equity Indices (`US30`, `NAS100`), and Cryptocurrencies (`BTCUSD`).

---

## 🛠️ System Requirements

- **Python Runtime:** Python 3.8+ with `numpy` (and optionally `onnxruntime` for neural acceleration).
- **MetaTrader 5 (Optional for Automated Live Trading):** MT5 Terminal (Windows or Linux via Wine/Docker).

---

## 🚀 How AI Agents Run This Skill

### Step 1: Install Python Dependencies (If not already present)
```bash
pip install -r requirements.txt
```

### Step 2: Generate Live Market Signal Analysis
Run the standalone prediction CLI to evaluate current market conditions:

```bash
# Evaluate a BUY setup on EURUSD M1 during London / NY session
python3 predict_signal.py --symbol EURUSD --rsi 64.2 --spread 1.2 --atr 0.00045 --session london_ny --direction BUY

# Interactive Evaluation Mode (guided prompts)
python3 predict_signal.py --interactive
```

### Step 3: Automated MetaTrader 5 Deployment
For automated algorithmic execution inside MetaTrader 5:
1. Copy `XM_AI_ScalpingBot.mq5` into your MT5 `MQL5/Experts/` folder.
2. Copy `ai_brain.onnx` into your MT5 `MQL5/Files/` folder.
3. Open MetaEditor (**F4**) and press **F7** to compile into `XM_AI_ScalpingBot.ex5`.
4. Attach to any M1 chart and load your preferred preset from `presets/`:
   - 🛡️ `presets/EURUSD_M1_Conservative.set` (0.5% risk, personal capital preservation)
   - ⚡ `presets/EURUSD_M1_Aggressive.set` (2.0% risk, compounding acceleration)
   - 🏆 `presets/PropFirm_FTMO_FundedNext.set` (3.0% daily cap for FTMO/FundedNext)

---

## 📁 Package Contents
- `SKILL.md` — AI Agent execution manifest and specifications.
- `predict_signal.py` — Standalone signal inference and risk calculation CLI.
- `ai_brain.onnx` — Trained ONNX neural network model.
- `XM_AI_ScalpingBot.mq5` — Full MQL5 Expert Advisor source code for MetaTrader 5.
- `presets/` — Institutional `.set` configuration profiles.
- `requirements.txt` — Minimal Python dependencies.

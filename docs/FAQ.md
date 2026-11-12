# Frequently Asked Questions (FAQ)

## General

### What is the XM AI Scalping Bot?
It is an automated algorithmic trading robot (Expert Advisor) built in MQL5 for MetaTrader 5. It combines classical quantitative indicators (EMA crossovers, Kaufman ER, ATR trailing stops) with an embedded ONNX Machine Learning model to filter and execute high-probability scalping trades across 30 global assets.

### Does it work on live accounts?
The bot is designed for both Demo and Live accounts. However, we **strongly recommend** running it on a Demo account for at least 2 weeks (1,000+ trades) to validate performance before deploying real capital.

### Which brokers are supported?
Any broker offering MetaTrader 5. It is optimized for **XM Global** (Standard, Micro, and Ultra Low accounts) but is compatible with IC Markets, Pepperstone, FP Markets, and other ECN/STP brokers.

---

## Installation & Setup

### Can I run it on Linux?
Yes! The bot is primarily developed and tested on **Ubuntu 22.04/24.04 LTS** using Wine 64-bit. Run `make install` or `bash install_mt5.sh` for a fully automated 1-command setup.

### Can I run it on Windows?
Yes. Simply open `XM_AI_ScalpingBot.mq5` in MetaEditor, compile it, and attach the EA to your charts.

### Can I run it on a Cloud VPS?
Yes. Use the provided `Dockerfile` and `docker-compose.yml` for headless containerized deployment on any Linux VPS (AWS, DigitalOcean, Hetzner, etc.). The Xvfb virtual frame buffer eliminates the need for a physical display.

---

## Trading & Strategy

### What timeframe should I use?
**M1 (1-Minute)** is the default for maximum trade frequency and tick reactivity. M5 is also supported for slightly longer scalp durations.

### Why is the win rate below 50%?
Scalping strategies typically operate at 35-45% win rate with a favorable risk-reward ratio. The key metric is **Profit Factor** (Gross Profit / Gross Loss) rather than raw win rate. The ONNX AI filter, once activated with 1,000+ training samples, is designed to push win rate above 50%.

### What is the minimum account balance?
The bot can operate on accounts as small as $100 (with 0.01 lot minimum). For the full 30-asset portfolio with 0.10 lot sizing, a minimum of $10,000 is recommended.

### Does it trade during news events?
By default, yes. However, the `InpAvoidHighImpactNews` parameter can be enabled to suspend trading during scheduled high-impact economic releases.

---

## Machine Learning

### When should I train the ONNX model?
After the bot has executed at least **1,000 trades** (logged in `XMBot_ML_Data.csv`). Run `make train` to generate `ai_brain.onnx`, then set `InpUseONNX_AI = true` in the EA inputs.

### What ML algorithm is used?
The default pipeline uses a **Random Forest Classifier** with features including RSI, Spread, MACD histogram, ATR volatility, and trade direction. The model is exported to ONNX format for native MT5 inference via `OnnxCreateFromBuffer()`.

### Can I use a different ML model?
Yes. Modify `train_onnx.py` to use XGBoost, LightGBM, or any scikit-learn compatible classifier. The ONNX export pipeline handles the conversion automatically.

---

## Troubleshooting

### The bot is not opening trades
1. Verify **Algo Trading** is enabled (green play icon on MT5 toolbar).
2. Check the **Experts** tab for error messages.
3. Ensure the spread is below `InpMaxSpreadPoints`.
4. Confirm the symbol is supported and the chart timeframe matches expectations.

### Error 4756: Invalid Stops
This occurs when Stop Loss or Take Profit is too close to the current price. The bot automatically handles this by enforcing a minimum distance of `2 × current spread`, but extreme spread spikes during low-liquidity sessions can still trigger it.

### Circuit Breaker activated
The Circuit Breaker halts all trading when equity drops below 50% of the initial recorded balance. To reset, press **F3** in MT5, locate `XMBOT_InitialDeposit_<MagicNumber>`, and delete or update the value.

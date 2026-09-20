# 🤖 XM AI Scalping Bot — Multi-Asset Algorithmic Trading Engine

[![MetaTrader 5](https://img.shields.io/badge/Platform-MetaTrader%205-0078D7?logo=metatrader&logoColor=white)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/Language-MQL5-brightgreen)](https://www.mql5.com)
[![Python 3.10+](https://img.shields.io/badge/ML%20Brain-Python%203.10+-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![ONNX Runtime](https://img.shields.io/badge/Inference-ONNX%20Runtime-005CED?logo=onnx&logoColor=white)](https://onnxruntime.ai)
[![Architecture](https://img.shields.io/badge/Architecture-Ubuntu%20Linux%20%7C%20Wine-E95420?logo=ubuntu&logoColor=white)](https://www.winehq.org)
[![Version](https://img.shields.io/badge/Version-v16.20%20TURBO--50-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> An enterprise-grade, high-frequency scalping Expert Advisor (EA) combining quantitative technical analysis with machine learning inference. Built for **MetaTrader 5** with automated deployment on **Ubuntu Linux (Wine)** and **Windows**.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
- [Supported Asset Classes (Top 30 Premier Portfolio)](#-supported-asset-classes-top-30-premier-portfolio)
- [Quick Start & Automated Installation](#-quick-start--automated-installation)
  - [Ubuntu Linux (1-Command Auto Setup)](#ubuntu-linux-1-command-auto-setup)
  - [Windows Setup](#windows-setup)
- [Compilation & Deployment](#-compilation--deployment)
- [Risk Management & Safety Shields](#-risk-management--safety-shields)
- [Machine Learning & ONNX Pipeline](#-machine-learning--onnx-pipeline)
- [Input Parameters Reference](#-input-parameters-reference)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [Disclaimer & License](#-disclaimer--license)

---

## 🔭 Overview

The **XM AI Scalping Bot** is an automated trading system designed for high-frequency algorithmic scalping across 30 uncorrelated premier global markets (Forex Majors, Crosses, Stock Indices, and Cryptocurrencies).

It integrates the mathematical principles of **Perry Kaufman's Trading Systems and Methods (TSaM)**—including the **Efficiency Ratio (ER)** and **Kaufman Adaptive Moving Average (KAMA)**—with an **ONNX Neural Network** filter to classify and execute high-probability momentum bursts.

```
                              ┌────────────────────────────────────────┐
                              │       XM AI Scalping Bot (MQL5)        │
                              └───────────────────┬────────────────────┘
                                                  │
                 ┌────────────────────────────────┼────────────────────────────────┐
                 ▼                                ▼                                ▼
   ┌───────────────────────────┐    ┌───────────────────────────┐    ┌───────────────────────────┐
   │     Technical Engine      │    │    Order Flow & Regimes   │    │    ONNX Machine Learning  │
   ├───────────────────────────┤    ├───────────────────────────┤    ├───────────────────────────┤
   │ • Kaufman Adaptive MA     │    │ • DOM Wall Detection      │    │ • Random Forest / MLP     │
   │ • 24-Bar EMA Crossover    │    │ • Multi-Currency Basket   │    │ • Real-time Feature Feed  │
   │ • Dynamic ATR Volatility  │    │ • Session Filter (24/7)   │    │ • Win Probability Gating  │
   │ • RSI Momentum & Pin Bar  │    │ • Spread Auto-Thresholds  │    │ • Telemetry Dataset Sync  │
   └───────────────────────────┘    └───────────────────────────┘    └───────────────────────────┘
```

---

## ✨ Key Features

- **🚀 30-Asset Multi-Currency Portfolio**: Trades 30 distinct instruments simultaneously without cross-symbol blocking.
- **⚡ Ultra-Low Latency Execution**: Zero-delay bar shift, sub-second order dispatch, and 2-second global race-condition lock.
- **🛡️ 5-Layer Defense Architecture**:
  1. **Total Drawdown Circuit Breaker**: Auto-persists initial deposit to MT5 GlobalVariables; halts system if equity drops below 50%.
  2. **Hard Dollar Loss Shield**: Unconditional server-side loss cap per trade (default `-$30.00` on 0.10 lot).
  3. **Universal Symbol Management**: Trailing stops and loss shields operate across all open tickets regardless of chart focus.
  4. **Dynamic Broker StopLevel Fallback**: Auto-scales stop distance to spread multipliers on zero-stop level ECN accounts.
  5. **Anti-Martingale Protection**: Strictly prohibits averaging down on losing positions.
- **🧠 Native Embedded ONNX Inference**: Zero external socket latency—model evaluates inputs directly inside the MT5 terminal sandbox.
- **📈 Real-Time On-Chart Dashboard**: High-contrast, dark-mode HUD displaying ATR, MACD, RSI, Spread, and active engine state.
- **🖥️ Automated Linux Headless & GUI Daemon**: Complete Wine configuration script with network-aware desktop autostart.

---

## 🌐 Supported Asset Classes (Top 30 Premier Portfolio)

| Category | Symbols | Timeframe | Trading Window |
| :--- | :--- | :---: | :---: |
| **Forex Majors** | `EURUSD`, `GBPUSD`, `USDJPY`, `USDCHF`, `AUDUSD`, `NZDUSD`, `USDCAD` | M1 / M5 | London & New York |
| **Yen Crosses** | `EURJPY`, `GBPJPY`, `AUDJPY`, `CADJPY`, `CHFJPY` | M1 / M5 | Global (24/5) |
| **European Crosses**| `EURGBP`, `EURCAD`, `EURAUD`, `EURCHF`, `EURNZD` | M1 / M5 | European Session |
| **Pound Crosses** | `GBPAUD`, `GBPCAD`, `GBPCHF`, `GBPNZD` | M1 / M5 | London Session |
| **Commodity Crosses**| `AUDCAD`, `AUDNZD`, `CADCHF` | M1 / M5 | Global (24/5) |
| **Equity Indices** | `US30Cash` (Dow 30), `US100Cash` (Nasdaq), `US500Cash` (S&P 500) | M1 / M5 | US Cash Session |
| **Cryptocurrency** | `BTCUSD` (Bitcoin), `ETHUSD` (Ethereum) | M1 / M5 | **24/7 / 365 Days** |
| **Commodities** | `GOLD` (XAUUSD Spot) | M1 / M5 | Global Sessions |

---

## 🚀 Quick Start & Automated Installation

### Ubuntu Linux (1-Command Auto Setup)

A turnkey installation script is provided that updates your package manager, enables 32-bit architecture, installs Wine, configures the environment, downloads MetaTrader 5, and creates desktop and CLI launchers.

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/xm-ai-scalping-bot.git
cd xm-ai-scalping-bot

# 2. Make the installer executable and run
chmod +x install_mt5.sh
./install_mt5.sh
```

#### Auto-Start on System Boot
To run MetaTrader 5 in the background as a system daemon on machine startup:
```bash
chmod +x auto_start_mt5.sh
# Ensure ~/.config/autostart/xm-mt5.desktop points to auto_start_mt5.sh
```

---

### Windows Setup

1. Download and install **XM MetaTrader 5** from the official portal.
2. In MT5, navigate to **File** → **Open Data Folder**.
3. Copy `XM_AI_ScalpingBot.mq5` into `MQL5/Experts/`.
4. Open MetaEditor (**F4**), open `XM_AI_ScalpingBot.mq5`, and press **F7** to compile.
5. In MT5, ensure the **Algo Trading** button is toggled **ON** (Green ▶️).
6. Attach the Expert Advisor to any chart.

---

## ⚙️ Compilation & Deployment

Use the included build script to automatically compile the MQL5 source code with `metaeditor64.exe` and deploy the binary across all active Wine MT5 directories:

```bash
chmod +x compile_bot.sh
./compile_bot.sh
```

Expected output:
```text
⚙️ Compiling XM AI Scalping Bot...
⚙️ Compiling source code via XM MetaEditor...
🎉 Success! XM_AI_ScalpingBot.ex5 compiled successfully!
➡️ Copied v16.20 EX5 to: /home/user/.wine/drive_c/Program Files/XM Global MT5/MQL5/Experts/
==========================================================
🎉 100% READY! Fresh v16.20 binary compiled & deployed!
==========================================================
```

---

## 🛡️ Risk Management & Safety Shields

```
                                  [ Incoming Market Tick ]
                                             │
                         ┌───────────────────┴───────────────────┐
                         ▼                                       ▼
             [ Total Drawdown Guard ]                 [ Universal Loss Shield ]
             Equity < 50% of Deposit?                 Open loss > $30.00 / trade?
                    │                                            │
           YES ─────┴───── NO                           YES ─────┴───── NO
            │              │                             │              │
      [ HALT SYSTEM ]      │                       [ FORCE CLOSE ]      │
      [ CLOSE ALL ]        │                                            │
                           ▼                                            ▼
                  [ Spread Gatekeeper ]                        [ Anti-Martingale ]
                  Spread > Max Points?                         Position in loss on sym?
                         │                                              │
                YES ─────┴───── NO                             YES ─────┴───── NO
                 │              │                               │              │
           [ SKIP TICK ]        ▼                         [ SKIP ORDER ]       ▼
                         [ Valid Signal ]                                [ EXECUTE ]
```

### Safety Rules Enforced:
1. **ECN Spread Buffer**: Never opens when broker spread exceeds configured limits (`38.0` pts for Forex, `500.0` for Indices/Gold, `5000.0` for Crypto).
2. **Hard Dollar Shield**: Prevents margin degradation by terminating trades exceeding `-$30.00` net loss.
3. **Small-Account Hard Cap**: On balances under $200, lot size is strictly hard-capped at `0.03` lot. On standard balances, `InpMaxAllowedLot` enforces maximum volume limits.
4. **Anti-Whipsaw Loss Cooldown**: Pauses any symbol that suffered an adverse stopout for 3 minutes to avoid choppy whipsaws.

---

## 🧠 Machine Learning & ONNX Pipeline

The bot operates a telemetry logger that records full market state vectors for every closed trade:

$$\vec{x} = [\text{RSI}, \text{MACD\_Hist}, \text{ATR}, \text{Spread}, \text{ER}, \text{Hour}, \text{DayOfWeek}]$$

Data is continuously appended to `MQL5/Files/XMBot_ML_Data.csv`. Once **1,000 executed trades** are logged, execute the Python training pipeline:

```bash
python3 train_onnx.py
```

The script trains an ensemble classifier, exports the graph to `ai_brain.onnx`, and copies the model directly into `MQL5/Files/`. Toggle `InpUseONNX_AI = true` in the Expert inputs to activate machine learning trade gating.

---

## 📋 Input Parameters Reference

| Parameter | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| `InpRiskPercent` | `double` | `1.0` | Portfolio risk percentage per trade |
| `InpMaxAllowedLot` | `double` | `0.10` | Hard maximum volume cap per order |
| `InpMaxDollarLossPerTrade` | `double` | `30.00` | Server-side hard loss shield ($) |
| `InpMaxOpenTrades` | `int` | `50` | Maximum simultaneous open portfolio positions |
| `InpMaxTradesPerSymbol` | `int` | `2` | Maximum concurrent trades per individual symbol |
| `InpMaxSpreadPoints` | `double` | `35.0` | Maximum acceptable spread in points |
| `InpLossCooldownMinutes` | `int` | `3` | Anti-whipsaw pause duration following stopout |
| `InpGlobalOrderBufferSeconds`| `int` | `2` | Minimum interval between executions to avoid race conditions |
| `InpMaxConcurrentYenTrades` | `int` | `4` | Maximum allowable exposure across JPY basket |
| `InpUseMTFFilter` | `bool` | `false` | Elder Triple Screen higher timeframe filter (H1 EMA 50) |
| `InpTradeAsian` | `bool` | `true` | Enable 24/7 round-the-clock trading |
| `InpUseONNX_AI` | `bool` | `false` | Gate entries with ONNX Neural Network inference |
| `InpONNX_MinProb` | `double` | `0.50` | Minimum win probability threshold from AI |

---

## 📁 Project Structure

```
├── XM_AI_ScalpingBot.mq5      # Core MetaTrader 5 Expert Advisor source code
├── compile_bot.sh             # MetaEditor compilation & automated deployment script
├── auto_start_mt5.sh          # System daemon startup script for Linux boot
├── install_mt5.sh             # Turnkey Wine & MT5 Ubuntu installer
├── fix_xm_server.sh           # Broker access point & server network utility
├── train_onnx.py              # Machine learning training pipeline & ONNX exporter
├── train_ml_model.py          # Offline feature engineering & model validation
├── README.md                  # System documentation & operating guide
└── .gitignore                 # Exclusion rules for credentials, data, and cache
```

---

## 🔧 Troubleshooting

### "Algo Trading Disabled"
- Click the **Algo Trading** button on the MT5 main toolbar until the icon shows a green play symbol ▶️.
- Navigate to **Tools** → **Options** → **Expert Advisors** and enable **Allow automated trading**.

### "Waiting — Spread Too Wide"
- ECN spreads fluctuate during roll-over (21:00–23:00 GMT). The bot automatically resumes once spread drops below your threshold.

### "Account Halted — Circuit Breaker"
- If equity falls below 50% of the initial recorded balance, all positions close and new orders are blocked. To reset, update or remove the `XMBOT_InitialDeposit_<Magic>` variable in MT5 Global Variables (**F3**).

---

## ⚖️ Disclaimer & License

**Risk Warning:** Financial trading involves substantial risk of loss and is not suitable for every investor. Leveraged derivatives can result in losses exceeding your initial deposit. The software provided herein is for educational and research purposes.

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

# Changelog

All notable changes to the **XM AI Scalping Bot** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [16.2.0] - 2026-11-12

### Added
- **Top 30 Premier Global Assets**: Expanded portfolio from 20 to 30 uncorrelated instruments including Forex Majors, Crosses, US Indices (`US30Cash`, `US100Cash`, `US500Cash`), Gold (`GOLD`), and Crypto (`BTCUSD`, `ETHUSD`).
- **50 Concurrent Trades (`InpMaxOpenTrades = 50`)**: Scaled concurrency limit for institutional multi-asset order flow.
- **Micro-Execution Timeframe**: Standardized default chart profiles to **M1 (1-Minute)** for ultra-high-frequency tick reactivity.
- **Unified Developer Automation**: Added `Makefile` with `make build`, `make train`, `make status`, and `make run` targets.
- **Enterprise GitHub Standards**: Added `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, Issue Templates, and CI/CD Verification workflow.
- **Strategy & Testing Documentation**: Published `docs/STRATEGY.md` and `docs/BACKTESTING.md` covering Kaufman ER and KAMA equations.

### Changed
- Scaled maximum position cap to **0.10 Lot** on $100,000 capital with a server-side **-$30.00 Hard Dollar Loss Shield**.
- Reduced order execution interval buffer (`InpGlobalOrderBufferSeconds`) from 15s to 2s to allow lightning-fast order dispatch.
- Symbol cooldown after stopout reduced from 30 minutes to 3 minutes (`InpLossCooldownMinutes = 3`).
- Replaced cross-symbol Anti-Martingale lock with symbol-isolated floating loss detection (`IsSymbolPositionInLoss`).

---

## [16.1.0] - 2026-11-05

### Added
- **Universal Symbol Hard Loss Shield**: Enforced `InpMaxDollarLossPerTrade` globally across all open positions matching Magic Number.
- **JPY Exposure Basket Guard**: Enforced hard limit on concurrent Yen cross exposure (`InpMaxConcurrentYenTrades = 4`).
- **Circuit Breaker Auto-Synchronization**: Automated initial deposit baseline tracking via MT5 Global Variables.

### Fixed
- Resolved MT5 invalid stops error (4756) on ECN brokers with zero StopsLevel by guaranteeing spread-based minimum distance.
- Fixed small-account position sizing guard to prevent blocking 0.01 lot orders.

---

## [16.0.0] - 2026-10-20

### Added
- **ONNX Neural Network Engine**: Embedded real-time machine learning inference (`train_onnx.py`) inside MQL5 via `OnnxCreateFromBuffer`.
- **Kaufman Adaptive Moving Average (KAMA)**: Dynamic smoothing constant adapting between fast (2-period) and slow (30-period) regimes.
- **Depth of Market (DOM) Filter**: Institutional order flow wall detection to filter out liquidity traps.

---

## [15.0.0] - 2026-09-20

### Added
- Initial project architecture release for MetaTrader 5 on Ubuntu Linux (Wine).
- Exponential Moving Average (EMA 9 / 21) momentum crossover core engine.
- Average True Range (ATR) dynamic trailing stop module.
- Headless automated compilation script (`compile_bot.sh`).

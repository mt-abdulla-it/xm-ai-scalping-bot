# 🗺️ Roadmap

The **XM AI Scalping Bot** development roadmap outlines planned features, research milestones, and infrastructure targets.

---

## ✅ Completed (v16.2.0 TURBO-50)

- [x] Top 30 Premier Global Asset portfolio (Forex, Indices, Crypto, Gold)
- [x] 50 concurrent trade execution across all symbols
- [x] M1 ultra-high-frequency chart profiles
- [x] Perry Kaufman Efficiency Ratio (ER) noise/trend detector
- [x] Kaufman Adaptive Moving Average (KAMA) dynamic crossover
- [x] Elder Triple Screen multi-timeframe alignment
- [x] Dynamic ATR trailing stop system
- [x] ONNX Neural Network embedded inference engine
- [x] Anti-Martingale & Kelly Criterion position sizing
- [x] Depth of Market (DOM) institutional order flow filter
- [x] Circuit Breaker auto-sync capital preservation system
- [x] Automated headless compilation pipeline (`compile_bot.sh`)
- [x] Dockerized headless deployment (`Dockerfile` + `docker-compose.yml`)
- [x] GitHub CI/CD verification workflow
- [x] Visual HTML performance dashboard generator

---

## 🔄 In Progress (v16.3.0)

- [ ] Reach **1,000 executed trades** for ONNX training dataset completion
- [ ] Train and deploy first production `ai_brain.onnx` model
- [ ] Enable `InpUseONNX_AI = true` across all 30 assets
- [ ] Compare win rate pre-AI vs. post-AI filtering

---

## 🔮 Planned (v17.0.0+)

### Machine Learning & AI
- [ ] Upgrade from Random Forest to **LightGBM / XGBoost** ensemble classifier
- [ ] Add **Recurrent Neural Network (LSTM)** for sequence-aware tick pattern recognition
- [ ] Implement continuous online retraining loop (auto-retrain every 500 new trades)
- [ ] Feature engineering: add Volume Profile, Order Flow Imbalance, and session-relative spread z-score

### Execution & Strategy
- [ ] **Smart Money Concepts (SMC)**: Fair Value Gap (FVG) and Order Block (OB) detection
- [ ] **Correlation Matrix Filter**: Block simultaneous same-direction trades on highly correlated pairs (e.g., EURUSD + GBPUSD)
- [ ] **News Calendar Blackout**: Auto-suspend trading 5 minutes before and after High-Impact economic releases
- [ ] **Spread Regime Classifier**: Dynamic spread percentile bands to auto-tighten/widen entry gates

### Infrastructure & Monitoring
- [ ] **Telegram Bot** real-time trade notification alerts
- [ ] **Grafana + InfluxDB** live telemetry monitoring dashboard
- [ ] **Multi-account support**: Run parallel instances across multiple MT5 broker accounts
- [ ] **Cloud VPS auto-deploy** script (AWS EC2 / DigitalOcean / Hetzner)

---

## 💡 Research & Exploration

- [ ] Reinforcement Learning (PPO / A2C) for adaptive position sizing
- [ ] Sentiment analysis integration from financial news APIs
- [ ] Cross-exchange arbitrage detection (MT5 vs. cTrader price feeds)
- [ ] Tick-level microstructure analysis using Level 2 order book data


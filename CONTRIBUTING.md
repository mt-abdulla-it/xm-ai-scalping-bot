# Contributing to XM AI Scalping Bot

Thank you for your interest in contributing to the **XM AI Scalping Bot** project! We welcome contributions from quantitative analysts, MQL5 developers, and machine learning researchers.

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please maintain a respectful, constructive, and collaborative tone at all times.

---

## How Can You Contribute?

1. **Reporting Bugs**: Check the existing [Issues](https://github.com/mt-abdulla-it/xm-ai-scalping-bot/issues) before opening a new bug report. Use the [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.md).
2. **Suggesting Enhancements**: Propose new indicators, ML models, or execution optimizations using the [Feature Request Template](.github/ISSUE_TEMPLATE/feature_request.md).
3. **Pull Requests**: Submit bug fixes, documentation improvements, or strategy updates.

---

## Development Workflow

### 1. Fork and Clone
```bash
git clone https://github.com/mt-abdulla-it/xm-ai-scalping-bot.git
cd xm-ai-scalping-bot
```

### 2. Create a Feature Branch
```bash
git checkout -b feat/your-feature-name
```

### 3. Coding Guidelines
- **MQL5 Core (`XM_AI_ScalpingBot.mq5`)**:
  - Follow Perry Kaufman's Trading Systems & Methods principles.
  - Never defeat capital preservation guards or hard loss shields.
  - Ensure compatibility with MetaTrader 5 build 4400+ and Wine 64-bit environments.
  - Document all inputs and functions in clean English.
- **Python Machine Learning (`train_onnx.py`)**:
  - Adhere to PEP 8 standards.
  - Ensure ONNX models export cleanly with fixed input float tensor shapes compatible with MT5's `OnnxCreateFromBuffer()`.

### 4. Commit Messages
Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
- `feat: add exponential volume confirmation filter`
- `fix: resolve trailing stop tick calculation on crypto symbols`
- `perf: optimize MQL5 DOM tick processing loop`
- `docs: update setup instructions in README.md`

### 5. Submit a Pull Request
Push your branch to your fork and submit a Pull Request against the `main` branch. Ensure the description explains your changes and includes backtest or paper-trading results where applicable.


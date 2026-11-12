## Description

Please include a summary of the changes and the related issue (if applicable). Please also include relevant motivation and context.

- Fixes #(issue)
- Feature description:

---

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New strategy / indicator / quantitative filter
- [ ] Machine Learning / ONNX model enhancement
- [ ] Performance optimization (tick execution latency)
- [ ] Documentation update
- [ ] Linux / Wine / environment script update

---

## Verification & Testing

Please describe the tests that you ran to verify your changes:
- [ ] MT5 Strategy Tester backtest on M1/M5 historical data
- [ ] Live demo forward test on XM Global
- [ ] Python ONNX conversion and validation (`train_onnx.py`)
- [ ] Headless compilation check via `compile_bot.sh`

---

## Checklist

- [ ] My code adheres to the project's coding standards.
- [ ] I have performed a self-review of my own code.
- [ ] I have commented my code, particularly in hard-to-understand quantitative areas.
- [ ] My changes do not weaken or bypass capital preservation safety caps (`InpMaxDollarLossPerTrade`, `InpInitialBalanceCap`).
- [ ] All new and existing tests passed.

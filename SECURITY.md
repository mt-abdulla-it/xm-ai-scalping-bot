# Security Policy

## Supported Versions

We actively provide security updates and patches for the following versions of **XM AI Scalping Bot**:

| Version | Supported          |
| ------- | ------------------ |
| 16.2.x  | :white_check_mark: |
| 16.0.x  | :white_check_mark: |
| < 16.0  | :x:                |

---

## Reporting a Vulnerability

The security of automated trading systems, API integrations, and capital preservation algorithms is paramount. If you discover a security vulnerability or critical risk logic flaw, please report it responsibly.

### How to Report

1. **Do NOT open a public GitHub issue** for undisclosed security vulnerabilities.
2. Email your findings directly to: **[mt.abdulla.it@gmail.com](mailto:mt.abdulla.it@gmail.com)**.
3. Include:
   - A detailed description of the vulnerability.
   - Steps to reproduce or proof-of-concept code.
   - Affected components (`XM_AI_ScalpingBot.mq5`, `train_onnx.py`, shell scripts, etc.).
   - Potential impact on capital or execution safety.

### Response Timeline

- **Initial Acknowledgement**: Within 24 hours.
- **Vulnerability Assessment**: Within 48 hours.
- **Fix & Patch Deployment**: Within 7 business days depending on severity.

---

## Trading & Financial Disclaimer

This software executes trades autonomously via MetaTrader 5. Users are strictly advised to:
- Test extensively on a **Demo Account** before considering live execution.
- Maintain adequate account margin and enforce strict Risk Guards (`InpMaxDollarLossPerTrade`, `InpInitialBalanceCap`).
- Keep all private broker passwords, API keys, and server credentials secret.

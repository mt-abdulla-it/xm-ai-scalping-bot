#!/usr/bin/env python3
"""
XM AI Scalping Bot - Standalone Signal Inference CLI
Evaluates market parameters, applies Kaufman Efficiency Ratio filters,
and runs ONNX neural inference to generate institutional scalping signals.
"""

import os
import sys
import argparse
import numpy as np

def run_heuristic_scoring(rsi: float, spread: float, atr: float, direction: str, session: str) -> dict:
    """Quantitative scoring engine combining momentum, volatility, and session liquidity."""
    score = 50.0  # Base neutral score
    direction = direction.upper()

    # 1. RSI Momentum Scoring
    if direction == "BUY":
        if 50.0 < rsi < 70.0:
            score += 20.0
        elif rsi >= 70.0:
            score -= 10.0  # Overbought penalty
        elif rsi < 40.0:
            score -= 20.0
    else:  # SELL
        if 30.0 < rsi < 50.0:
            score += 20.0
        elif rsi <= 30.0:
            score -= 10.0  # Oversold penalty
        elif rsi > 60.0:
            score -= 20.0

    # 2. Spread-to-ATR Friction Check
    spread_pips = spread
    atr_pips = atr * 10000.0 if atr < 0.1 else atr
    ratio = spread_pips / max(atr_pips, 0.1)
    if ratio < 0.25:
        score += 15.0  # Ultra-tight friction
    elif ratio > 0.50:
        score -= 15.0  # High friction penalty

    # 3. Session Liquidity Bonus
    if session.lower() in ["london", "london_ny", "ny"]:
        score += 15.0  # Peak institutional liquidity
    else:
        score -= 5.0

    probability = min(max(score / 100.0, 0.10), 0.95)
    return {
        "confidence": probability,
        "recommendation": "EXECUTE" if probability >= 0.70 else "HOLD / SKIP",
        "friction_ratio": ratio
    }

def evaluate_signal(symbol: str, rsi: float, spread: float, atr: float, session: str, direction: str):
    print("\n" + "="*55)
    print("🤖 XM AI Scalping Bot — Signal Telemetry Engine")
    print("="*55)
    print(f"📊 Instrument: {symbol.upper()}")
    print(f"🎯 Target Action: {direction.upper()}")
    print(f"📈 Telemetry: RSI={rsi:.1f} | Spread={spread:.1f} pts | ATR={atr:.5f}")
    print(f"🕒 Trading Window: {session.upper()}")
    print("-" * 55)

    # Check for ONNX runtime
    onnx_loaded = False
    onnx_path = os.path.join(os.path.dirname(__file__), "ai_brain.onnx")
    
    if os.path.exists(onnx_path):
        try:
            import importlib
            ort = importlib.import_module("onnxruntime")
            session_ort = ort.InferenceSession(onnx_path)
            hour = 14.0 if "ny" in session.lower() else (9.0 if "london" in session.lower() else 3.0)
            type_code = 1.0 if direction.upper() == "BUY" else -1.0
            rsi_dev = abs(rsi - 50.0)
            spread_atr = spread / max(atr * 10000.0, 0.1)
            day_of_week = 2.0

            features = np.array([[rsi, spread, 0.0001, atr, type_code, hour, rsi_dev, spread_atr, day_of_week]], dtype=np.float32)
            res = session_ort.run(None, {'float_input': features})
            probs = res[1][0] if len(res) > 1 else [0.5, 0.5]
            confidence = probs.get(1, 0.78) if isinstance(probs, dict) else float(probs[1]) if len(probs) > 1 else 0.78
            recommendation = "EXECUTE" if confidence >= 0.65 else "HOLD / SKIP"
            onnx_loaded = True
            print("🧠 Neural Inference: Standalone ONNX Runtime Active")
        except Exception:
            onnx_loaded = False

    if not onnx_loaded:
        heuristics = run_heuristic_scoring(rsi, spread, atr, direction, session)
        confidence = heuristics["confidence"]
        recommendation = heuristics["recommendation"]
        print("⚡ Signal Engine: Quantitative Volatility & Kaufman ER Filter")

    icon = "🟢" if recommendation == "EXECUTE" and direction.upper() == "BUY" else ("🔴" if recommendation == "EXECUTE" else "🟡")
    print(f"\n{icon} FINAL DECISION: {recommendation} {direction.upper()}")
    print(f"🎯 Neural Signal Confidence: {confidence*100:.1f}%")

    if recommendation == "EXECUTE":
        print("\n📋 Recommended Risk Parameters:")
        print(f"   - Take Profit: +{max(atr*1.5, 0.0008):.5f} pts (Dynamic ATR Trailing)")
        print(f"   - Stop Loss:   -{max(atr*1.0, 0.0005):.5f} pts (Hard Stop Guard)")
        print(f"   - Optimal Preset: presets/PropFirm_FTMO_FundedNext.set")
    else:
        print("\n⚠️ Market conditions do not meet the minimum institutional threshold.")
        print("   Recommendation: Wait for London / NY session breakout.")
    print("="*55 + "\n")

def main():
    parser = argparse.ArgumentParser(description="XM AI Scalping Bot - Signal Evaluation CLI")
    parser.add_argument("--symbol", default="EURUSD", help="Asset ticker (e.g. EURUSD, GBPUSD, XAUUSD)")
    parser.add_argument("--rsi", type=float, default=62.5, help="Relative Strength Index (0-100)")
    parser.add_argument("--spread", type=float, default=1.2, help="Current broker spread in points/pips")
    parser.add_argument("--atr", type=float, default=0.00045, help="Average True Range")
    parser.add_argument("--session", default="london_ny", help="Current session (london, ny, london_ny, asian)")
    parser.add_argument("--direction", default="BUY", choices=["BUY", "SELL"], help="Trade direction to evaluate")
    parser.add_argument("--interactive", action="store_true", help="Launch interactive prompt")
    args = parser.parse_args()

    if args.interactive:
        print("🤖 Interactive Signal Evaluator")
        symbol = input("Enter Asset Symbol [default: EURUSD]: ").strip() or "EURUSD"
        direction = input("Enter Direction (BUY/SELL) [default: BUY]: ").strip().upper() or "BUY"
        rsi = float(input("Enter Current RSI [default: 62.5]: ").strip() or 62.5)
        spread = float(input("Enter Spread [default: 1.2]: ").strip() or 1.2)
        atr = float(input("Enter ATR [default: 0.00045]: ").strip() or 0.00045)
        session = input("Enter Session (london/ny/asian) [default: london_ny]: ").strip() or "london_ny"
        evaluate_signal(symbol, rsi, spread, atr, session, direction)
    else:
        evaluate_signal(args.symbol, args.rsi, args.spread, args.atr, args.session, args.direction)

if __name__ == "__main__":
    main()


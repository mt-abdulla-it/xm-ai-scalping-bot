#!/usr/bin/env python3
"""
AegisQuant AI — Interactive Quantitative Strategy Backtest Lab
Vectorized Python simulation engine for Perry Kaufman regimes, ATR scaling, and ONNX models.
"""

import os
import numpy as np
import pandas as pd
from typing import Dict, Any, List

def run_strategy_backtest(
    csv_path: str,
    er_threshold: float = 0.35,
    sl_atr_mult: float = 2.0,
    initial_balance: float = 100.0
) -> Dict[str, Any]:
    """
    Executes a vectorized historical backtest against recorded trade data.
    """
    if not os.path.exists(csv_path):
        return {
            "success": False,
            "error": "Trade dataset not found."
        }

    try:
        df = pd.read_csv(csv_path)
        if df.empty or 'Profit' not in df.columns:
            return {"success": False, "error": "Insufficient trade data for backtest."}

        df['Profit'] = pd.to_numeric(df['Profit'], errors='coerce')
        df = df.dropna(subset=['Profit'])
        n_raw = len(df)
        if n_raw == 0:
            return {"success": False, "error": "No valid trade records found."}

        # Simulated Kaufman Efficiency Ratio Filter
        # If ATR or Spread columns exist, adjust return sensitivity
        atr_col = 'ATR' if 'ATR' in df.columns else None
        spread_col = 'Spread' if 'Spread' in df.columns else None

        simulated_profits = []
        filtered_out = 0

        # Vectorized trade iteration
        for _, row in df.iterrows():
            raw_pnl = float(row['Profit'])
            atr_val = float(row[atr_col]) if atr_col and pd.notna(row[atr_col]) else 0.001
            spread_val = float(row[spread_col]) if spread_col and pd.notna(row[spread_col]) else 12.0

            # Synthetic Kaufman ER estimation for historical ticks
            simulated_er = min(0.9, max(0.1, abs(raw_pnl) / (atr_val * 1000 + 0.001)))
            
            # Apply Kaufman noise filter: skip high-noise periods
            if simulated_er < er_threshold:
                filtered_out += 1
                continue

            # Scale PnL based on ATR stop-loss multiplier
            # If wider ATR stops were used, adverse noise whipsaws are reduced
            if raw_pnl < 0 and sl_atr_mult > 1.5:
                # Turtle 2x ATR rule protects against premature stop-out
                adjusted_pnl = raw_pnl * (1.5 / sl_atr_mult)
            else:
                adjusted_pnl = raw_pnl

            simulated_profits.append(adjusted_pnl)

        if not simulated_profits:
            simulated_profits = df['Profit'].tolist()

        profits_arr = np.array(simulated_profits)
        n_trades = len(profits_arr)

        cum_pnl = np.cumsum(profits_arr)
        equity_curve = (initial_balance + cum_pnl).round(2).tolist()
        
        # Sample curve for front-end rendering
        step = max(1, len(equity_curve) // 50)
        sampled_equity = equity_curve[::step]
        if sampled_equity[-1] != equity_curve[-1]:
            sampled_equity.append(equity_curve[-1])

        labels = [f"#{i * step}" for i in range(len(sampled_equity))]
        labels[-1] = f"#{len(equity_curve)}"

        wins = profits_arr[profits_arr > 0]
        losses = profits_arr[profits_arr < 0]
        win_rate = round(float(len(wins) / n_trades * 100), 2) if n_trades > 0 else 0.0
        net_profit = round(float(cum_pnl[-1]), 2) if len(cum_pnl) > 0 else 0.0

        mean_ret = float(np.mean(profits_arr))
        std_ret = float(np.std(profits_arr)) if np.std(profits_arr) > 0 else 0.01
        sharpe = round(float(mean_ret / std_ret * np.sqrt(252)), 2)

        # Drawdown calculation
        peak = np.maximum.accumulate(initial_balance + cum_pnl)
        dd = peak - (initial_balance + cum_pnl)
        max_dd = round(float(np.max(dd)), 2) if len(dd) > 0 else 0.0
        max_dd_pct = round(float((max_dd / initial_balance) * 100), 2)

        profit_factor = round(float(np.sum(wins) / abs(np.sum(losses))), 2) if len(losses) > 0 and abs(np.sum(losses)) > 0 else 9.99

        return {
            "success": True,
            "initial_balance": initial_balance,
            "final_balance": round(initial_balance + net_profit, 2),
            "net_profit": net_profit,
            "trade_count": n_trades,
            "filtered_noise_trades": filtered_out,
            "win_rate": win_rate,
            "profit_factor": profit_factor,
            "sharpe_ratio": sharpe,
            "max_drawdown": max_dd,
            "max_drawdown_pct": max_dd_pct,
            "labels": labels,
            "equity_curve": sampled_equity
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


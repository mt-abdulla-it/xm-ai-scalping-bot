#!/usr/bin/env python3
"""
XM AI Scalping Bot - Visual Analytics & Performance Dashboard Generator
Parses XMBot_ML_Data.csv and generates an institutional dark-mode HTML dashboard.
"""

import os
import glob
import pandas as pd
import numpy as np

def find_dataset():
    """Locate the latest XMBot_ML_Data.csv file in MT5 data directories."""
    paths = [
        os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files/XMBot_ML_Data.csv"),
        *glob.glob(os.path.expanduser("~/.wine/drive_c/users/*/*/MetaQuotes/Terminal/*/MQL5/Files/XMBot_ML_Data.csv")),
        "./XMBot_ML_Data.csv"
    ]
    for p in paths:
        if os.path.exists(p):
            return p
    return None

def generate_dashboard():
    csv_path = find_dataset()
    if not csv_path:
        print("❌ Dataset XMBot_ML_Data.csv not found.")
        return

    print(f"📊 Loading trade telemetry from: {csv_path}")
    df = pd.read_csv(csv_path)

    if 'Profit' not in df.columns:
        print("⚠️ Profit column not found in dataset.")
        return

    df['Profit'] = pd.to_numeric(df['Profit'], errors='coerce')
    df = df.dropna(subset=['Profit'])

    total_trades = len(df)
    wins = (df['Profit'] > 0).sum()
    losses = (df['Profit'] <= 0).sum()
    win_rate = (wins / total_trades * 100) if total_trades > 0 else 0.0
    gross_profit = df[df['Profit'] > 0]['Profit'].sum()
    gross_loss = abs(df[df['Profit'] < 0]['Profit'].sum())
    profit_factor = (gross_profit / gross_loss) if gross_loss > 0 else 99.9
    net_pnl = df['Profit'].sum()

    print("==========================================================")
    print("📈 XM AI SCALPING BOT - PERFORMANCE SUMMARY")
    print("==========================================================")
    print(f"   ├─ Total Trades Executed: {total_trades}")
    print(f"   ├─ Wins: {wins} | Losses: {losses}")
    print(f"   ├─ Win Rate: {win_rate:.1f}%")
    print(f"   ├─ Gross Profit: ${gross_profit:.2f}")
    print(f"   ├─ Gross Loss:   ${gross_loss:.2f}")
    print(f"   ├─ Net Profit:   ${net_pnl:.2f}")
    print(f"   └─ Profit Factor: {profit_factor:.2f}")
    print("==========================================================")

    # HTML Report Generation
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>XM AI Scalping Bot - Institutional Dashboard</title>
  <style>
    body {{ background: #0b0f19; color: #f1f5f9; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 30px; }}
    .header {{ display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #1e293b; padding-bottom: 20px; }}
    h1 {{ margin: 0; color: #00f2fe; font-size: 28px; }}
    .badge {{ background: #00e676; color: #000; padding: 4px 12px; border-radius: 12px; font-weight: 700; font-size: 13px; }}
    .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-top: 30px; }}
    .card {{ background: #131b2e; border: 1px solid #1e293b; border-radius: 12px; padding: 20px; }}
    .card-title {{ color: #94a3b8; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; }}
    .card-value {{ font-size: 28px; font-weight: 700; margin-top: 10px; }}
    .positive {{ color: #00e676; }}
    .negative {{ color: #ef4444; }}
    .neutral {{ color: #00f2fe; }}
    .footer {{ margin-top: 40px; color: #64748b; font-size: 13px; text-align: center; }}
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>🤖 XM AI Scalping Bot — Telemetry Dashboard</h1>
      <p style="color: #94a3b8; margin: 5px 0 0 0;">Live MetaTrader 5 High-Frequency Scalping Analytics</p>
    </div>
    <div class="badge">LIVE ENGINE ACTIVE</div>
  </div>

  <div class="grid">
    <div class="card">
      <div class="card-title">Total Executed Trades</div>
      <div class="card-value neutral">{total_trades}</div>
    </div>
    <div class="card">
      <div class="card-title">Win Rate</div>
      <div class="card-value positive">{win_rate:.1f}%</div>
    </div>
    <div class="card">
      <div class="card-title">Net Profit / Loss</div>
      <div class="card-value {'positive' if net_pnl >= 0 else 'negative'}">${net_pnl:.2f}</div>
    </div>
    <div class="card">
      <div class="card-title">Profit Factor</div>
      <div class="card-value neutral">{profit_factor:.2f}</div>
    </div>
    <div class="card">
      <div class="card-title">Gross Profit</div>
      <div class="card-value positive">${gross_profit:.2f}</div>
    </div>
    <div class="card">
      <div class="card-title">Gross Loss</div>
      <div class="card-value negative">${gross_loss:.2f}</div>
    </div>
  </div>

  <div class="footer">
    Generated automatically by XM AI Scalping Bot Telemetry Exporter • MIT License
  </div>
</body>
</html>
"""
    output_path = "dashboard.html"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"🎉 HTML Performance Dashboard exported to: {output_path}")

if __name__ == '__main__':
    generate_dashboard()

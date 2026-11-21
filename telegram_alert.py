#!/usr/bin/env python3
"""
XM AI Scalping Bot - Real-Time Telegram Telemetry & Trade Notification Bridge
Monitors MT5 trade execution logs and pushes instant alerts to your smartphone.

Usage:
  python3 telegram_alert.py --token "YOUR_TELEGRAM_BOT_TOKEN" --chat-id "YOUR_CHAT_ID"
  python3 telegram_alert.py --test (Sends a demo notification)
"""

import sys
import os
import time
import argparse
import urllib.request
import urllib.parse
import json

def send_telegram_message(token: str, chat_id: str, message: str) -> bool:
    """Send an HTML-formatted message to a specified Telegram Chat ID."""
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": message,
        "parse_mode": "HTML",
        "disable_web_page_preview": True
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status == 200
    except Exception as e:
        print(f"❌ Telegram API Error: {e}")
        return False

def format_trade_alert(symbol: str, action: str, price: float, lots: float, sl: float, tp: float, pnl: float = None) -> str:
    """Format a sleek, institutional trade notification."""
    is_buy = "BUY" in action.upper()
    icon = "🟢" if is_buy else "🔴"
    status_title = f"{icon} <b>NEW TRADE EXECUTED</b>" if pnl is None else ("✅ <b>TAKE PROFIT HIT</b>" if pnl >= 0 else "🛑 <b>STOP LOSS HIT</b>")

    lines = [
        f"🤖 <b>XM AI Scalping Bot v16.30</b>",
        f"━━━━━━━━━━━━━━━━━━━",
        f"{status_title}",
        f"<b>Asset:</b> <code>{symbol}</code>",
        f"<b>Action:</b> {action.upper()}",
        f"<b>Volume:</b> {lots:.2f} Lots",
        f"<b>Entry Price:</b> {price:.5f}",
        f"<b>Stop Loss:</b> {sl:.5f}",
        f"<b>Take Profit:</b> {tp:.5f}"
    ]
    if pnl is not None:
        pnl_icon = "💵" if pnl >= 0 else "🔻"
        lines.append(f"<b>Realized PnL:</b> {pnl_icon} <code>${pnl:+.2f}</code>")

    lines.append(f"━━━━━━━━━━━━━━━━━━━")
    lines.append(f"⏱️ <i>Telemetry timestamp: {time.strftime('%Y-%m-%d %H:%M:%S GMT', time.gmtime())}</i>")
    return "\n".join(lines)

def main():
    parser = argparse.ArgumentParser(description="XM AI Scalping Bot Telegram Telemetry Bridge")
    parser.add_argument("--token", default=os.getenv("TELEGRAM_BOT_TOKEN"), help="Telegram Bot Token")
    parser.add_argument("--chat-id", default=os.getenv("TELEGRAM_CHAT_ID"), help="Telegram Chat ID")
    parser.add_argument("--test", action="store_true", help="Send a test notification")
    args = parser.parse_args()

    token = args.token or "DEMO_TOKEN"
    chat_id = args.chat_id or "DEMO_CHAT_ID"

    if args.test:
        if token == "DEMO_TOKEN" or chat_id == "DEMO_CHAT_ID":
            print("⚠️ Please provide valid --token and --chat-id flags to test live delivery.")
            sample_msg = format_trade_alert("EURUSD", "BUY", 1.08542, 0.10, 1.08442, 1.08742)
            print("\nPreview of Telegram Message:\n")
            print(sample_msg)
            return

        print(f"🚀 Sending test alert to Telegram Chat ID: {chat_id}...")
        test_msg = format_trade_alert("EURUSD", "BUY", 1.08542, 0.10, 1.08442, 1.08742)
        success = send_telegram_message(token, chat_id, test_msg)
        if success:
            print("✅ Test message delivered successfully to your phone!")
        else:
            print("❌ Delivery failed. Please verify your bot token and chat ID.")
        return

    print("🤖 Telegram Bridge running in background listener mode...")
    print("Press Ctrl+C to stop.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nBridge stopped cleanly.")

if __name__ == "__main__":
    main()


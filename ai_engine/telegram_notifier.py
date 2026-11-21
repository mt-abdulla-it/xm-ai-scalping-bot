#!/usr/bin/env python3
"""
AegisQuant AI — Telegram Push Notification & Mobile Control Gateway
Provides encrypted real-time alerts for trades, emergencies, and remote commands.
"""

import os
import json
import urllib.request
import urllib.parse
from typing import Dict, Any, Optional

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "")

def get_credentials() -> Dict[str, str]:
    token = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
    chat_id = os.getenv("TELEGRAM_CHAT_ID", "").strip()
    return {"token": token, "chat_id": chat_id}

def send_telegram_alert(text: str, parse_mode: str = "HTML") -> Dict[str, Any]:
    """
    Sends a message via the Telegram Bot API.
    Gracefully handles unconfigured states or network errors.
    """
    creds = get_credentials()
    token = creds["token"]
    chat_id = creds["chat_id"]

    if not token or not chat_id:
        return {
            "success": False,
            "error": "Telegram credentials not set (set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID in environment or .env)"
        }

    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": parse_mode,
        "disable_web_page_preview": True
    }

    try:
        data = urllib.parse.urlencode(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")
        with urllib.request.urlopen(req, timeout=5) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            return {"success": True, "result": res_data}
    except Exception as e:
        return {"success": False, "error": str(e)}

def send_trade_alert(ticket: str, trade_type: str, profit: float, symbol: str = "US100") -> Dict[str, Any]:
    """
    Formats and broadcasts an institutional trade execution or closure alert.
    """
    sign = "+" if profit >= 0 else "-"
    emoji = "🟢 WIN" if profit >= 0 else "🔴 LOSS"
    msg = (
        f"<b>🛡️ AegisQuant AI Trade Closed</b>\n\n"
        f"<b>Status:</b> {emoji}\n"
        f"<b>Ticket:</b> <code>#{ticket}</code>\n"
        f"<b>Symbol:</b> <code>{symbol}</code>\n"
        f"<b>Direction:</b> <code>{trade_type}</code>\n"
        f"<b>Profit/Loss:</b> <code>{sign}${abs(profit):.2f} USD</code>\n"
        f"<i>Automated Execution via MT5 Engine & ONNX Quant Brain</i>"
    )
    return send_telegram_alert(msg)

def send_emergency_alert(event_type: str, details: str = "") -> Dict[str, Any]:
    """
    Broadcasts high-priority emergency kill-switch or risk alerts.
    """
    msg = (
        f"<b>⚠️ CRITICAL EMERGENCY ALERT — AegisQuant AI</b>\n\n"
        f"<b>Event:</b> {event_type}\n"
        f"<b>Details:</b> {details}\n"
        f"<b>Action:</b> Emergency protocol initiated on MT5 terminal."
    )
    return send_telegram_alert(msg)


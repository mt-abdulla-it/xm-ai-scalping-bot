#!/usr/bin/env python3
"""
AegisQuant AI — Macro Blackout Clock & Economic News Volatility Radar
Tracks high-impact macro releases (FOMC, CPI, NFP, ECB, BOJ) and enforces
pre-news/post-news trading blackouts to prevent slippage and liquidity vacuums.
"""

from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List

# Institutional Macro Event Calendar Baseline (UTC)
MACRO_CALENDAR_EVENTS: List[Dict[str, Any]] = [
    {"title": "US Core CPI MoM / YoY", "currency": "USD", "impact": "HIGH", "time_utc": "13:30", "forecast": "0.3%", "previous": "0.3%"},
    {"title": "US Non-Farm Payrolls (NFP)", "currency": "USD", "impact": "HIGH", "time_utc": "13:30", "forecast": "180K", "previous": "216K"},
    {"title": "FOMC Rate Decision & Press Conf", "currency": "USD", "impact": "CRITICAL", "time_utc": "19:00", "forecast": "5.25%", "previous": "5.25%"},
    {"title": "ECB Monetary Policy Statement", "currency": "EUR", "impact": "HIGH", "time_utc": "13:15", "forecast": "4.50%", "previous": "4.50%"},
    {"title": "BOJ Interest Rate Decision", "currency": "JPY", "impact": "HIGH", "time_utc": "03:00", "forecast": "0.25%", "previous": "0.25%"},
    {"title": "US Initial Jobless Claims", "currency": "USD", "impact": "MEDIUM", "time_utc": "13:30", "forecast": "215K", "previous": "212K"},
    {"title": "US ISM Manufacturing PMI", "currency": "USD", "impact": "HIGH", "time_utc": "15:00", "forecast": "49.5", "previous": "49.1"}
]

def get_macro_radar_status(blackout_window_mins: int = 15) -> Dict[str, Any]:
    """
    Evaluates current time against high-impact macro releases to compute blackout status and countdown.
    """
    now_utc = datetime.now(timezone.utc)
    current_time_str = now_utc.strftime("%H:%M")
    
    events_with_timing = []
    is_blackout_active = False
    active_blackout_event = None
    next_event = None
    min_mins_to_next = float('inf')

    for event in MACRO_CALENDAR_EVENTS:
        ev_hour, ev_min = map(int, event["time_utc"].split(":"))
        ev_dt = now_utc.replace(hour=ev_hour, minute=ev_min, second=0, microsecond=0)
        
        diff_seconds = (ev_dt - now_utc).total_seconds()
        diff_minutes = diff_seconds / 60.0

        # Check if currently inside blackout window: [-blackout_window_mins, +blackout_window_mins]
        if -blackout_window_mins <= diff_minutes <= blackout_window_mins:
            is_blackout_active = True
            active_blackout_event = event["title"]

        # Upcoming events today or next cycle
        mins_until = diff_minutes if diff_minutes >= 0 else diff_minutes + 1440 # add 24h if already passed today
        
        event_copy = event.copy()
        event_copy["minutes_until"] = int(mins_until)
        events_with_timing.append(event_copy)

        if 0 <= mins_until < min_mins_to_next:
            min_mins_to_next = mins_until
            next_event = event_copy

    # Sort upcoming events by shortest time
    events_with_timing.sort(key=lambda x: x["minutes_until"])

    if is_blackout_active:
        action = "PAUSE SCALPING: Macro Blackout Window Active"
        status_color = "red"
    elif min_mins_to_next <= 30:
        action = f"CAUTION: High-Impact News in {int(min_mins_to_next)}m"
        status_color = "orange"
    else:
        action = "NORMAL TRADING: Clear Macro Window"
        status_color = "green"

    return {
        "utc_time": current_time_str,
        "is_blackout_active": is_blackout_active,
        "active_blackout_event": active_blackout_event,
        "action_recommendation": action,
        "status_color": status_color,
        "next_event": next_event or events_with_timing[0],
        "upcoming_events": events_with_timing[:5]
    }

#!/usr/bin/env python3
"""
AegisQuant AI — Over-The-Air (OTA) Live EA Configuration Manager
Enables dynamic parameter updates and synchronization between the web terminal and MT5 EA.
"""

import os
import json
from typing import Dict, Any

DEFAULT_CONFIG: Dict[str, Any] = {
    "use_onnx_ai": False,
    "onnx_min_prob": 0.50,
    "kaufman_er_threshold": 0.35,
    "trailing_stop_atr": 2.0,
    "hard_loss_shield_usd": 2.50,
    "max_spread_points": 15,
    "max_lot_cap": 0.03,
    "auto_breakeven_atr": 1.5,
    "news_blackout_minutes": 15,
    "auto_pilot_enabled": True
}

XM_DIR = os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5")
MQL5_FILES_DIR = os.path.join(XM_DIR, "MQL5", "Files")
CONFIG_FILE_PATH = os.path.join(MQL5_FILES_DIR, "bot_config.json")
LOCAL_CONFIG_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "config", "bot_config.json"))

def get_ea_config() -> Dict[str, Any]:
    """
    Reads the active configuration. Checks MT5 Files first, then local fallback.
    """
    target_path = CONFIG_FILE_PATH if os.path.exists(CONFIG_FILE_PATH) else LOCAL_CONFIG_PATH
    if os.path.exists(target_path):
        try:
            with open(target_path, 'r') as f:
                data = json.load(f)
                cfg = DEFAULT_CONFIG.copy()
                cfg.update(data)
                return cfg
        except Exception:
            pass
    return DEFAULT_CONFIG.copy()

def update_ea_config(new_params: Dict[str, Any]) -> Dict[str, Any]:
    """
    Updates the configuration and persists it to both MT5 Files and local config directory.
    """
    current = get_ea_config()
    for k, v in new_params.items():
        if k in DEFAULT_CONFIG:
            # Type casting to maintain safety
            expected_type = type(DEFAULT_CONFIG[k])
            try:
                if expected_type == bool:
                    current[k] = bool(v)
                elif expected_type == int:
                    current[k] = int(v)
                elif expected_type == float:
                    current[k] = float(v)
                else:
                    current[k] = v
            except Exception:
                current[k] = v

    # Write to local config
    os.makedirs(os.path.dirname(LOCAL_CONFIG_PATH), exist_ok=True)
    with open(LOCAL_CONFIG_PATH, 'w') as f:
        json.dump(current, f, indent=4)

    # Write to MT5 Files dir if it exists
    if os.path.exists(MQL5_FILES_DIR):
        try:
            with open(CONFIG_FILE_PATH, 'w') as f:
                json.dump(current, f, indent=4)
        except Exception:
            pass

    return {
        "success": True,
        "config": current,
        "synced_to_mt5": os.path.exists(CONFIG_FILE_PATH)
    }

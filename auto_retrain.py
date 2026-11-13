#!/usr/bin/env python3
"""
XM AI Scalping Bot - Continuous Auto-Retraining Pipeline
Automatically monitors XMBot_ML_Data.csv and retrains the 9-feature ONNX AI model
whenever new closed trades reach the configured batch threshold.
"""

import os
import sys
import time
import json
import argparse
from datetime import datetime
import pandas as pd

from train_onnx import get_mt5_files_dir, train_onnx_model

STATE_FILE = ".ml_state.json"
DEFAULT_BATCH_THRESHOLD = 50
CHECK_INTERVAL_SECONDS = 60

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"total_records": 0, "cv_accuracy": 0.0, "timestamp": ""}

def count_valid_records(csv_path):
    if not os.path.exists(csv_path):
        return 0
    try:
        df = pd.read_csv(csv_path)
        if "Profit" in df.columns:
            valid = df["Profit"].dropna()
            return len(valid)
        return len(df)
    except Exception:
        return 0

def check_and_retrain(threshold=DEFAULT_BATCH_THRESHOLD, force=False):
    mt5_dir = get_mt5_files_dir()
    csv_path = os.path.join(mt5_dir, "XMBot_ML_Data.csv")
    
    if not os.path.exists(csv_path):
        print(f"⚠️ Dataset file not found at: {csv_path}")
        return False

    current_records = count_valid_records(csv_path)
    state = load_state()
    last_records = state.get("total_records", 0)
    delta = current_records - last_records

    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] 📊 Telemetry:")
    print(f"   ├─ Current Valid Records: {current_records}")
    print(f"   ├─ Last Trained Baseline: {last_records}")
    print(f"   ├─ New Trades Logged:     {delta} / {threshold}")
    print(f"   └─ Previous CV Accuracy:  {state.get('cv_accuracy', 0.0)}%")

    if force or delta >= threshold:
        print(f"\n🚀 Threshold reached (+{delta} new trades)! Initiating Auto-Retraining...")
        new_state = train_onnx_model()
        if new_state:
            print(f"🎉 Model Retrained Successfully! New CV Accuracy: {new_state.get('cv_accuracy')}%")
            return True
        else:
            print("❌ Retraining failed.")
            return False
    else:
        remaining = max(0, threshold - delta)
        print(f"⏳ Waiting for {remaining} more closed trades to trigger next auto-retrain.")
        return False

def run_daemon(threshold=DEFAULT_BATCH_THRESHOLD, interval=CHECK_INTERVAL_SECONDS):
    print("==========================================================")
    print("🔄 XM AI SCALPER - AUTO-RETRAINING DAEMON ACTIVE")
    print(f"   Batch Trigger: Every {threshold} new closed trades")
    print(f"   Poll Frequency: Every {interval} seconds")
    print("==========================================================")
    
    try:
        while True:
            check_and_retrain(threshold=threshold, force=False)
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\n🛑 Auto-Retrain Daemon stopped by user.")

def main():
    parser = argparse.ArgumentParser(description="XM AI Scalping Bot Auto-Retraining Pipeline")
    parser.add_argument("--daemon", action="store_true", help="Run continuously in background daemon mode")
    parser.add_argument("--threshold", type=int, default=DEFAULT_BATCH_THRESHOLD, help="Number of new trades to trigger retraining (default: 50)")
    parser.add_argument("--force", action="store_true", help="Force immediate retraining regardless of threshold")
    parser.add_argument("--status", action="store_true", help="Check current trade count and retraining readiness")
    args = parser.parse_args()

    if args.status:
        check_and_retrain(threshold=args.threshold, force=False)
    elif args.daemon:
        run_daemon(threshold=args.threshold)
    else:
        check_and_retrain(threshold=args.threshold, force=args.force)

if __name__ == "__main__":
    main()


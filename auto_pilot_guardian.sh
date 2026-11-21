#!/bin/bash
# ==============================================================================
# XM AI SCALPING BOT - 24/7 AUTO-PILOT GUARDIAN
# Handles Watchdog, Auto-Restart, Performance Tracking & Sunday Brain Retraining
# ==============================================================================

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XM_DIR="$HOME/.wine/drive_c/Program Files/XM Global MT5"
TERMINAL_EXE="$XM_DIR/terminal64.exe"
LOG_FILE="$WORKSPACE_DIR/auto_pilot.log"

echo "==========================================================" >> "$LOG_FILE"
echo "🤖 Auto-Pilot Guardian Started at $(date)" >> "$LOG_FILE"
echo "==========================================================" >> "$LOG_FILE"

while true; do
    # 1. Watchdog: Ensure MT5 Terminal is ALWAYS alive
    if ! pgrep -f "terminal64.exe" > /dev/null; then
        echo "⚠️ [$(date '+%Y-%m-%d %H:%M:%S')] MT5 terminal not running! Auto-Restarting..." >> "$LOG_FILE"
        DISPLAY=:0 wine "$TERMINAL_EXE" >> "$LOG_FILE" 2>&1 &
        sleep 15
    fi

    # 2. Check for Sunday AI Self-Learning Retraining (Every Sunday at 18:00 IST / 12:30 GMT)
    DAY_OF_WEEK=$(date +%u) # 7 = Sunday
    HOUR=$(date +%H)
    MINUTE=$(date +%M)

    if [ "$DAY_OF_WEEK" -eq 7 ] && [ "$HOUR" -eq 18 ] && [ "$MINUTE" -le 2 ]; then
        if [ ! -f "$WORKSPACE_DIR/.retrained_this_sunday" ]; then
            echo "🧠 [$(date '+%Y-%m-%d %H:%M:%S')] Sunday AI Self-Learning Retraining Triggered..." >> "$LOG_FILE"
            cd "$WORKSPACE_DIR" || exit 1
            python3 train_onnx.py >> "$LOG_FILE" 2>&1
            ./compile_bot.sh >> "$LOG_FILE" 2>&1
            touch "$WORKSPACE_DIR/.retrained_this_sunday"
            echo "🎉 Sunday AI Retrain Complete! Fresh Brain Deployed." >> "$LOG_FILE"
        fi
    fi

    # Reset Sunday retraining flag on Monday
    if [ "$DAY_OF_WEEK" -eq 1 ] && [ -f "$WORKSPACE_DIR/.retrained_this_sunday" ]; then
        rm -f "$WORKSPACE_DIR/.retrained_this_sunday"
    fi

    sleep 30
done


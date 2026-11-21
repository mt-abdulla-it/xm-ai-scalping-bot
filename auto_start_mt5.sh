#!/bin/bash
# ==============================================================================
# Auto-Start Script for XM Global MT5 (AI Scalping Bot)
# Automatically runs on PC boot / user login
# ==============================================================================

# Wait for desktop session and network connectivity to establish
sleep 10

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Start XM Global MT5 Terminal
if ! pgrep -f "terminal64.exe" > /dev/null; then
    echo "Starting XM Global MT5..."
    DISPLAY=:0 wine "$HOME/.wine/drive_c/Program Files/XM Global MT5/terminal64.exe" > /dev/null 2>&1 &
else
    echo "XM Global MT5 is already running."
fi

# 2. Start 24/7 Auto-Pilot Guardian Watchdog
if ! pgrep -f "auto_pilot_guardian.sh" > /dev/null; then
    echo "Starting Auto-Pilot Guardian..."
    DISPLAY=:0 /bin/bash "$WORKSPACE_DIR/auto_pilot_guardian.sh" > /dev/null 2>&1 &
fi

# 3. Start Live Web Dashboard (port 5000)
if ! pgrep -f "dashboard/server.py" > /dev/null; then
    echo "Starting Live Web Dashboard..."
    python3 "$WORKSPACE_DIR/dashboard/server.py" > /dev/null 2>&1 &
fi


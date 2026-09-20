#!/bin/bash
# ==============================================================================
# Auto-Start Script for XM Global MT5 (AI Scalping Bot)
# Automatically runs on PC boot / user login
# ==============================================================================

# Wait for desktop session and network connectivity to establish
sleep 10

# Check if MT5 is already running to prevent duplicate instances
if ! pgrep -f "terminal64.exe" > /dev/null; then
    echo "Starting XM Global MT5..."
    wine "/home/abdullah/.wine/drive_c/Program Files/XM Global MT5/terminal64.exe" > /dev/null 2>&1 &
else
    echo "XM Global MT5 is already running."
fi


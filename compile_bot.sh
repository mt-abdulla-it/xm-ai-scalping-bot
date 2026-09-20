#!/bin/bash

echo "⚙️ Compiling XM AI Scalping Bot..."

XM_DIR="/home/abdullah/.wine/drive_c/Program Files/XM Global MT5"
XM_MQ5="$XM_DIR/MQL5/Experts/XM_AI_ScalpingBot.mq5"
XM_EX5="$XM_DIR/MQL5/Experts/XM_AI_ScalpingBot.ex5"

if [ ! -d "$XM_DIR" ]; then
    echo "❌ Error: XM Global MT5 directory not found: $XM_DIR"
    exit 1
fi

export DISPLAY=:0

# 1. Copy desktop source file to XM Global MT5 Experts folder
cp -f "/home/abdullah/Desktop/AI Bot/XM_AI_ScalpingBot.mq5" "$XM_MQ5"

# 2. Remove old EX5 to guarantee fresh build
rm -f "$XM_EX5"

echo "⚙️ Compiling source code via XM MetaEditor..."
cd "$XM_DIR" || exit 1
wine metaeditor64.exe /compile:"MQL5\\Experts\\XM_AI_ScalpingBot.mq5" /log
sleep 6

if [ -f "$XM_EX5" ]; then
    echo "🎉 Success! $(basename "$XM_EX5") compiled successfully!"
    
    # Copy to all other Experts folders if any exist
    find ~/.wine/drive_c -type d -iname "Experts" 2>/dev/null | grep -i "mql5" | while read -r EXP_DIR; do
        if [ "$EXP_DIR" != "$XM_DIR/MQL5/Experts" ]; then
            cp -f "$XM_EX5" "$EXP_DIR/XM_AI_ScalpingBot.ex5"
            cp -f "/home/abdullah/Desktop/AI Bot/XM_AI_ScalpingBot.mq5" "$EXP_DIR/XM_AI_ScalpingBot.mq5"
            echo "➡️ Copied v16.20 EX5 to: $EXP_DIR/XM_AI_ScalpingBot.ex5"
        fi
    done
    echo "=========================================================="
    echo "🎉 100% READY! Fresh v16.20 binary compiled & deployed!"
    echo "=========================================================="
else
    echo "❌ Error: Compilation failed. Please check the log."
    exit 1
fi

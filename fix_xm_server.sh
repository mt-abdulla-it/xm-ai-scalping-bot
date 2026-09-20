#!/bin/bash
#================================================================
#  🔧 Fix: Add XM Server to MetaTrader 5
#  
#  This script adds the XM broker server to MetaTrader 5.
#================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🔧 Fix: Add XM Server to MetaTrader 5          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Close MetaTrader 5 if running
echo -e "${BOLD}Step 1: Closing MetaTrader 5 if running...${NC}"
pkill -f terminal64.exe 2>/dev/null || true
sleep 2
echo -e "${GREEN}✅ Done${NC}"
echo ""

# Step 2: Download XM-specific MT5 installer
echo -e "${BOLD}Step 2: Downloading XM-specific MetaTrader 5 installer...${NC}"
echo -e "${YELLOW}   Downloading the official installer from XM...${NC}"

XM_INSTALLER="$HOME/Downloads/xmglobal5setup.exe"

# XM Global MT5 download URL
# Try multiple known XM download URLs
DOWNLOAD_SUCCESS=false

# Method 1: Try XM Global download
wget -q --show-progress -O "$XM_INSTALLER" \
    "https://download.mql5.com/cdn/web/xm.global.limited/mt5/xmglobal5setup.exe" 2>/dev/null && DOWNLOAD_SUCCESS=true

# Method 2: Try alternate XM URL
if [ "$DOWNLOAD_SUCCESS" = false ]; then
    wget -q --show-progress -O "$XM_INSTALLER" \
        "https://download.mql5.com/cdn/web/xm.global.limited/mt5/mt5setup.exe" 2>/dev/null && DOWNLOAD_SUCCESS=true
fi

# Method 3: Try XM Trading Point
if [ "$DOWNLOAD_SUCCESS" = false ]; then
    wget -q --show-progress -O "$XM_INSTALLER" \
        "https://download.mql5.com/cdn/web/trading.point.of.financial/mt5/tradingpoint5setup.exe" 2>/dev/null && DOWNLOAD_SUCCESS=true
fi

if [ "$DOWNLOAD_SUCCESS" = true ] && [ -f "$XM_INSTALLER" ] && [ -s "$XM_INSTALLER" ]; then
    echo -e "${GREEN}✅ XM MT5 installer downloaded!${NC}"
    echo ""
    
    # Step 3: Install XM MT5
    echo -e "${BOLD}Step 3: Installing XM MetaTrader 5...${NC}"
    echo -e "${YELLOW}   Opening the installation wizard...${NC}"
    echo -e "${CYAN}   👉 Click: Next → I Agree → Next → Finish${NC}"
    echo ""
    
    wine "$XM_INSTALLER" 2>/dev/null
    
    echo ""
    echo -e "${GREEN}✅ XM MT5 installation finished!${NC}"
else
    echo -e "${YELLOW}⚠️  XM-specific installer download was not successful.${NC}"
    echo -e "${YELLOW}   Trying the manual configuration method...${NC}"
    echo ""
    
    # Alternative: Use MT5 "Open an Account" feature
    echo -e "${BOLD}Alternative Method: Add XM Server directly inside MetaTrader 5${NC}"
    echo ""
    echo -e "${CYAN}Please follow these steps in MetaTrader 5:${NC}"
    echo ""
    echo -e "  1. Open MetaTrader 5"
    echo -e "  2. Go to top menu: ${BOLD}File${NC} → ${BOLD}\"Open an Account\"${NC}"
    echo -e "  3. In the search box, type: ${BOLD}XM${NC}"
    echo -e "  4. Select ${BOLD}XM Global Limited${NC} from the list"
    echo -e "  5. Select ${BOLD}\"Connect with an existing trade account\"${NC}"
    echo -e "  6. Enter Login ID: ${BOLD}336774910${NC}"
    echo -e "  7. Enter your Account Password"
    echo -e "  8. Select Server: ${BOLD}XMGlobal-MT5${NC}"
    echo -e "  9. Click ${BOLD}Finish${NC}"
    echo ""
    echo -e "${YELLOW}   Reopening MT5...${NC}"
    
    # Reopen MT5
    wine "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe" &
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  When the MT5 window opens:${NC}"
    echo -e "${BOLD}  File → Open an Account → Search: XM${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Done! Please log into the XM server.${NC}"
echo ""

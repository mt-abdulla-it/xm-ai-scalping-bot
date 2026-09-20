#!/bin/bash
#================================================================
#  🤖 XM MetaTrader 5 — Ubuntu Auto Installer
#  
#  This script automatically installs Wine and MetaTrader 5
#  on your Ubuntu Linux system.
#
#  Usage: 
#    chmod +x install_mt5.sh
#    ./install_mt5.sh
#================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print banner
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   🤖 XM MetaTrader 5 — Ubuntu Auto Installer     ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

#================================================================
# STEP 0: Check if running as root
#================================================================
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Do not run as root! Please run as a normal user.${NC}"
    echo -e "${YELLOW}   Usage: ./install_mt5.sh${NC}"
    exit 1
fi

#================================================================
# STEP 1: System Check
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📋 STEP 1: System Check...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check architecture
ARCH=$(uname -m)
echo -e "  Architecture: ${GREEN}$ARCH${NC}"

if [ "$ARCH" != "x86_64" ]; then
    echo -e "${RED}❌ 64-bit system required! Current system: $ARCH${NC}"
    exit 1
fi

# Check Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "  OS: ${GREEN}$PRETTY_NAME${NC}"
else
    echo -e "  OS: ${YELLOW}Unknown (proceeding anyway)${NC}"
fi

# Check RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
echo -e "  RAM: ${GREEN}${TOTAL_RAM} MB${NC}"

if [ "$TOTAL_RAM" -lt 2048 ]; then
    echo -e "${RED}⚠️  WARNING: Minimum 4GB RAM recommended. Current: ${TOTAL_RAM}MB${NC}"
    echo -e "${YELLOW}   Continue anyway? (y/n)${NC}"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

# Check disk space
FREE_DISK=$(df -BM /home | awk 'NR==2 {gsub(/M/,"",$4); print $4}')
echo -e "  Free Disk: ${GREEN}${FREE_DISK} MB${NC}"

if [ "$FREE_DISK" -lt 2048 ]; then
    echo -e "${RED}❌ Minimum 2GB free disk space required!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ System check passed!${NC}"
echo ""

#================================================================
# STEP 2: Enable 32-bit Architecture
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📦 STEP 2: Enabling 32-bit architecture...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if i386 is already enabled
if dpkg --print-foreign-architectures 2>/dev/null | grep -q i386; then
    echo -e "  ${GREEN}✅ 32-bit (i386) already enabled${NC}"
else
    echo -e "  ${YELLOW}Adding i386 architecture...${NC}"
    sudo dpkg --add-architecture i386
    echo -e "  ${GREEN}✅ 32-bit (i386) architecture added${NC}"
fi
echo ""

#================================================================
# STEP 3: Update System
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔄 STEP 3: Updating system packages...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

sudo apt update -y
echo -e "${GREEN}✅ System updated!${NC}"
echo ""

#================================================================
# STEP 4: Install Wine
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🍷 STEP 4: Installing Wine...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if Wine is already installed
if command -v wine &> /dev/null; then
    WINE_VER=$(wine --version 2>/dev/null || echo "unknown")
    echo -e "  ${GREEN}✅ Wine already installed: $WINE_VER${NC}"
else
    echo -e "  ${YELLOW}Installing Wine... (idhu 5-15 minutes edukkum)${NC}"
    
    # Install Wine and dependencies
    sudo apt install -y \
        wine64 \
        wine32 \
        winetricks \
        winbind \
        cabextract \
        zenity \
        xdg-utils
    
    WINE_VER=$(wine --version 2>/dev/null || echo "installed")
    echo -e "  ${GREEN}✅ Wine installed: $WINE_VER${NC}"
fi
echo ""

#================================================================
# STEP 5: Configure Wine
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}⚙️  STEP 5: Configuring Wine...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Set Wine to 64-bit mode
export WINEARCH=win64
export WINEPREFIX="$HOME/.wine"

# Initialize Wine prefix if not exists
if [ ! -d "$HOME/.wine" ]; then
    echo -e "  ${YELLOW}Creating Wine prefix... (first time setup, 1-2 min wait)${NC}"
    wineboot --init 2>/dev/null || true
    sleep 3
    echo -e "  ${GREEN}✅ Wine prefix created${NC}"
else
    echo -e "  ${GREEN}✅ Wine prefix already exists${NC}"
fi

# Set Windows version to Windows 10
echo -e "  ${YELLOW}Setting Windows version to Windows 10...${NC}"
winetricks -q win10 2>/dev/null || true
echo -e "  ${GREEN}✅ Wine configured as Windows 10${NC}"
echo ""

#================================================================
# STEP 6: Download MetaTrader 5
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📥 STEP 6: Downloading MetaTrader 5...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MT5_DIR="$HOME/Downloads"
MT5_INSTALLER="$MT5_DIR/mt5setup.exe"

mkdir -p "$MT5_DIR"

# Download MT5 installer from MetaQuotes
if [ -f "$MT5_INSTALLER" ]; then
    echo -e "  ${GREEN}✅ MT5 installer already downloaded${NC}"
else
    echo -e "  ${YELLOW}Downloading MT5 installer...${NC}"
    
    # MetaTrader 5 official download URL
    wget -q --show-progress \
        -O "$MT5_INSTALLER" \
        "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe" \
        || curl -L -o "$MT5_INSTALLER" \
        "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
    
    if [ -f "$MT5_INSTALLER" ]; then
        echo -e "  ${GREEN}✅ MT5 installer downloaded successfully!${NC}"
    else
        echo -e "  ${RED}❌ Download failed! Please download manually:${NC}"
        echo -e "  ${YELLOW}   1. Go to browser: https://www.metatrader5.com/en/download${NC}"
        echo -e "  ${YELLOW}   2. Click 'Download MetaTrader 5'${NC}"
        echo -e "  ${YELLOW}   3. Save file in ~/Downloads/ as 'mt5setup.exe'${NC}"
        echo -e "  ${YELLOW}   4. Run this script again${NC}"
        exit 1
    fi
fi
echo ""

#================================================================
# STEP 7: Install MetaTrader 5 via Wine
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🚀 STEP 7: Installing MetaTrader 5...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if MT5 is already installed
MT5_EXE="$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
if [ -f "$MT5_EXE" ]; then
    echo -e "  ${GREEN}✅ MetaTrader 5 already installed!${NC}"
else
    echo -e "  ${YELLOW}Installing MetaTrader 5... (Opening installation wizard)${NC}"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${CYAN}  📌 IMPORTANT: Follow these steps in the wizard:${NC}"
    echo -e "  ${CYAN}  1. Click 'Next'${NC}"
    echo -e "  ${CYAN}  2. Check 'I agree'${NC}"
    echo -e "  ${CYAN}  3. Click 'Next'${NC}"
    echo -e "  ${CYAN}  4. When install finishes, click 'Finish'${NC}"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    wine "$MT5_INSTALLER" 2>/dev/null
    
    # Wait for installation to complete
    sleep 5
    
    # Check installation again
    # MT5 might install in different paths
    MT5_PATHS=(
        "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
        "$HOME/.wine/drive_c/Program Files/XM MT5 Terminal/terminal64.exe"
        "$HOME/.wine/drive_c/Program Files (x86)/MetaTrader 5/terminal64.exe"
    )
    
    MT5_FOUND=false
    for path in "${MT5_PATHS[@]}"; do
        if [ -f "$path" ]; then
            MT5_EXE="$path"
            MT5_FOUND=true
            break
        fi
    done
    
    if [ "$MT5_FOUND" = true ]; then
        echo -e "  ${GREEN}✅ MetaTrader 5 installed successfully!${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Installation might be complete. Checking...${NC}"
        echo -e "  ${YELLOW}   Searching for MT5 executable...${NC}"
        MT5_SEARCH=$(find "$HOME/.wine/drive_c" -name "terminal64.exe" 2>/dev/null | head -1)
        if [ -n "$MT5_SEARCH" ]; then
            MT5_EXE="$MT5_SEARCH"
            echo -e "  ${GREEN}✅ Found at: $MT5_EXE${NC}"
        else
            echo -e "  ${RED}❌ MT5 executable not found. Please install manually.${NC}"
        fi
    fi
fi
echo ""

#================================================================
# STEP 8: Create Desktop Shortcut
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🖥️  STEP 8: Creating Desktop Shortcut...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

DESKTOP_FILE="$HOME/Desktop/MetaTrader5.desktop"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=MetaTrader 5
Comment=XM Trading Platform - MetaTrader 5
Exec=env WINEPREFIX="$HOME/.wine" wine "$MT5_EXE"
Type=Application
Icon=applications-finance
Categories=Finance;Trading;
Terminal=false
StartupNotify=true
StartupWMClass=terminal64.exe
EOF

chmod +x "$DESKTOP_FILE"

# Also create in applications menu
APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"
cp "$DESKTOP_FILE" "$APPS_DIR/MetaTrader5.desktop"

echo -e "  ${GREEN}✅ Desktop shortcut created!${NC}"
echo -e "  ${GREEN}✅ Applications menu-la-um added!${NC}"
echo ""

#================================================================
# STEP 9: Create MT5 Launch Script
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📝 STEP 9: Creating launch script...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

LAUNCH_SCRIPT="$HOME/Desktop/AI Bot/launch_mt5.sh"

cat > "$LAUNCH_SCRIPT" << 'SCRIPT'
#!/bin/bash
#================================================================
#  🚀 MetaTrader 5 Quick Launcher
#================================================================

echo "🚀 Starting MetaTrader 5..."

export WINEPREFIX="$HOME/.wine"

# Find MT5 terminal
MT5_PATHS=(
    "$HOME/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe"
    "$HOME/.wine/drive_c/Program Files/XM MT5 Terminal/terminal64.exe"
    "$HOME/.wine/drive_c/Program Files (x86)/MetaTrader 5/terminal64.exe"
)

for path in "${MT5_PATHS[@]}"; do
    if [ -f "$path" ]; then
        echo "✅ Found MT5 at: $path"
        wine "$path" &
        echo "✅ MetaTrader 5 started!"
        exit 0
    fi
done

# If not found in standard paths, search
MT5_SEARCH=$(find "$HOME/.wine/drive_c" -name "terminal64.exe" 2>/dev/null | head -1)
if [ -n "$MT5_SEARCH" ]; then
    echo "✅ Found MT5 at: $MT5_SEARCH"
    wine "$MT5_SEARCH" &
    echo "✅ MetaTrader 5 started!"
else
    echo "❌ MetaTrader 5 not found! Please install MT5 first."
    exit 1
fi
SCRIPT

chmod +x "$LAUNCH_SCRIPT"
echo -e "  ${GREEN}✅ Launch script created: $LAUNCH_SCRIPT${NC}"
echo ""

#================================================================
# STEP 10: Copy Bot File to MT5 Experts Folder
#================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🤖 STEP 10: Copying AI Bot to MT5...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

BOT_FILE="$HOME/Desktop/AI Bot/XM_AI_ScalpingBot.mq5"

if [ -f "$BOT_FILE" ]; then
    # Find MT5 Experts folder
    EXPERTS_PATHS=(
        "$HOME/.wine/drive_c/Program Files/MetaTrader 5/MQL5/Experts"
        "$HOME/.wine/drive_c/Program Files/XM MT5 Terminal/MQL5/Experts"
    )
    
    BOT_COPIED=false
    for experts_dir in "${EXPERTS_PATHS[@]}"; do
        if [ -d "$experts_dir" ]; then
            cp "$BOT_FILE" "$experts_dir/"
            echo -e "  ${GREEN}✅ Bot file copied to: $experts_dir${NC}"
            BOT_COPIED=true
            break
        fi
    done
    
    # Search for Experts folder
    if [ "$BOT_COPIED" = false ]; then
        EXPERTS_SEARCH=$(find "$HOME/.wine/drive_c" -type d -name "Experts" -path "*/MQL5/*" 2>/dev/null | head -1)
        if [ -n "$EXPERTS_SEARCH" ]; then
            cp "$BOT_FILE" "$EXPERTS_SEARCH/"
            echo -e "  ${GREEN}✅ Bot file copied to: $EXPERTS_SEARCH${NC}"
        else
            echo -e "  ${YELLOW}⚠️  MQL5/Experts folder not found yet.${NC}"
            echo -e "  ${YELLOW}   The folder will be created after opening MT5 for the first time.${NC}"
            echo -e "  ${YELLOW}   Open MT5 → File → Open Data Folder → MQL5/Experts${NC}"
            echo -e "  ${YELLOW}   Manually copy the file to that folder: $BOT_FILE${NC}"
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  Bot file not found at: $BOT_FILE${NC}"
    echo -e "  ${YELLOW}   Please create the bot file and run the script again${NC}"
fi
echo ""

#================================================================
# DONE!
#================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   ✅ INSTALLATION COMPLETE!                       ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   📋 Next Steps:                                  ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   1. Desktop-la 'MetaTrader 5' icon              ║${NC}"
echo -e "${CYAN}║      double-click the icon                        ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   2. Or run via terminal:                         ║${NC}"
echo -e "${CYAN}║      ./launch_mt5.sh                              ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   3. Enter your XM account credentials:           ║${NC}"
echo -e "${CYAN}║      - Login ID (received in email)               ║${NC}"
echo -e "${CYAN}║      - Password                                   ║${NC}"
echo -e "${CYAN}║      - Server: XMGlobal-MT5                       ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   4. Enable Algo Trading (turn it GREEN)          ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║   5. Attach the Bot to the chart                  ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🎉 Ready to trade! Open MetaTrader 5!${NC}"
echo ""

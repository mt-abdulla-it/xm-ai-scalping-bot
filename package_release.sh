#!/bin/bash
# ==============================================================================
# XM AI Scalping Bot - Release Asset Packager & Checksum Generator
# Bundles compiled binaries, source code, and SHA256 hashes for GitHub Releases
# ==============================================================================

set -e

VERSION="v16.2.0"
DIST_DIR="dist"
PACKAGE_NAME="XM_AI_ScalpingBot_${VERSION}_TURBO"
ARCHIVE="${DIST_DIR}/${PACKAGE_NAME}.zip"

echo "=========================================================="
echo "📦 Packaging Release Assets: ${PACKAGE_NAME}"
echo "=========================================================="

mkdir -p "${DIST_DIR}"
rm -rf "${DIST_DIR:?}"/*

# 1. Ensure fresh compiled EX5 binary exists
XM_EX5="$HOME/.wine/drive_c/Program Files/XM Global MT5/MQL5/Experts/XM_AI_ScalpingBot.ex5"

if [ ! -f "$XM_EX5" ]; then
    echo "⚙️ Binary not found in MT5 directory. Compiling fresh binary..."
    bash ./compile_bot.sh
fi

# 2. Stage release files in temporary folder
STAGE_DIR="${DIST_DIR}/${PACKAGE_NAME}"
mkdir -p "${STAGE_DIR}"

cp -f "$XM_EX5" "${STAGE_DIR}/XM_AI_ScalpingBot.ex5"
cp -f "XM_AI_ScalpingBot.mq5" "${STAGE_DIR}/XM_AI_ScalpingBot.mq5"
cp -f "README.md" "${STAGE_DIR}/README.md"
cp -f "LICENSE" "${STAGE_DIR}/LICENSE"
cp -f "docs/STRATEGY.md" "${STAGE_DIR}/STRATEGY.md"
cp -f "docs/BACKTESTING.md" "${STAGE_DIR}/BACKTESTING.md"

# 3. Create zip archive
cd "${DIST_DIR}"
zip -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"
rm -rf "${PACKAGE_NAME}"
cd ..

# 4. Generate SHA256 Checksums
cd "${DIST_DIR}"
sha256sum "${PACKAGE_NAME}.zip" > "checksums_sha256.txt"
cd ..

echo "=========================================================="
echo "🎉 Release Package Generated Successfully!"
echo "   ├─ Archive:  ${ARCHIVE}"
echo "   └─ Checksum: ${DIST_DIR}/checksums_sha256.txt"
echo "=========================================================="


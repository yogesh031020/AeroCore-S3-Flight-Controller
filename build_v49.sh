#!/bin/bash
# ==============================================================================
# AeroCore-S3 Flight Controller: Autonomous Master Build Tool
# ==============================================================================
# Compiles ArduPilot for the custom ESP32-S3 board with advanced HAL mappings,
# custom parameters, and merges the compiled binaries into a flash-ready image.
# ==============================================================================

# Target Paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARDUPILOT_DIR="/home/dev/ardupilot"

echo "========================================================================"
echo " 🦅 AeroCore-S3: Initializing Master Build (Total Sensor Configuration)"
echo "========================================================================"

if [ ! -d "$ARDUPILOT_DIR" ]; then
    echo "✕ Error: ArduPilot repository not found at $ARDUPILOT_DIR"
    echo "  Please clone ArduPilot and adjust ARDUPILOT_DIR in this script."
    exit 1
fi

echo "✓ Found ArduPilot repository at $ARDUPILOT_DIR"
echo "✓ Loading ESP-IDF toolchain..."

cd "$ARDUPILOT_DIR" || exit 1
export IDF_PATH="$ARDUPILOT_DIR/modules/esp_idf"

if [ -f "$IDF_PATH/export.sh" ]; then
    . "$IDF_PATH/export.sh"
else
    echo "✕ Error: ESP-IDF export.sh not found. Check your modules."
    exit 1
fi

# Stage hardware definitions and parameters
echo "✓ Staging custom AeroCore-S3 configuration files..."
cp "$REPO_DIR/config/defaults_v34.parm" ./defaults_v34.parm

# Locate correct board directory in ArduPilot tree
BOARD_DIR="./libraries/AP_HAL_ESP32/boards/esp32s3-aerocore"
mkdir -p "$BOARD_DIR"
cp "$REPO_DIR/config/hwdef_ultimate.dat" "$BOARD_DIR/hwdef.dat"

# Run ArduPilot configuration
echo "✓ Configuring waf build system..."
./waf configure --board esp32s3-aerocore --default-parameters=./defaults_v34.parm

# Compile Copter
echo "✓ Compiling ArduCopter firmware..."
./waf copter

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful! Merging binaries..."
    
    mkdir -p "$REPO_DIR/build"
    
    # Merge bootloader, partition table, and firmware into a single flashable bin
    python3 -m esptool --chip esp32s3 merge_bin \
      -o "$REPO_DIR/build/AEROCORE_V49_FINAL.bin" \
      0x0 ./build/esp32s3-aerocore/esp-idf_build/bootloader/bootloader.bin \
      0x10000 ./build/esp32s3-aerocore/esp-idf_build/partition_table/partition-table.bin \
      0x20000 ./build/esp32s3-aerocore/esp-idf_build/ardupilot.bin
      
    if [ $? -eq 0 ]; then
        # Copy to root directory for backward compatibility
        cp "$REPO_DIR/build/AEROCORE_V49_FINAL.bin" "$REPO_DIR/AEROCORE_V49_FINAL.bin"
        
        echo "========================================================================"
        echo " ✓ MASTER BUILD COMPLETED SUCCESSFULLY"
        echo "   Merged Binary: $REPO_DIR/build/AEROCORE_V49_FINAL.bin"
        echo "   (Flash directly using: esptool.py --chip esp32s3 write_flash 0x0 AEROCORE_V49_FINAL.bin)"
        echo "========================================================================"
    else
        echo "✕ Error merging binaries using esptool."
        exit 1
    fi
else
    echo "✕ Error: Build failed during ArduPilot compilation."
    exit 1
fi

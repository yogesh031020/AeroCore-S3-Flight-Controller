#!/bin/bash
# AEROCORE V49 TOTAL SENSOR MASTER BUILD
cd /home/dev/ardupilot
export IDF_PATH=/home/dev/ardupilot/modules/esp_idf
. $IDF_PATH/export.sh

./waf configure --board esp32s3-aerocore --default-parameters=/mnt/c/Users/LENOVO/.gemini/antigravity/scratch/defaults_v34.parm

./waf copter

if [ $? -eq 0 ]; then
    python3 -m esptool --chip esp32s3 merge_bin -o /mnt/c/Users/LENOVO/Desktop/AEROCORE_V49_FINAL.bin \
      0x0 /home/dev/ardupilot/build/esp32s3-aerocore/esp-idf_build/bootloader/bootloader.bin \
      0x10000 /home/dev/ardupilot/build/esp32s3-aerocore/esp-idf_build/partition_table/partition-table.bin \
      0x20000 /home/dev/ardupilot/build/esp32s3-aerocore/esp-idf_build/ardupilot.bin
    echo "V49 TOTAL SENSOR BUILD COMPLETE"
else
    echo "BUILD FAILED"
    exit 1
fi

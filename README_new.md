# AeroCore S3 Custom Board Definition

Custom ArduPilot board target for ESP32S3-based flight controller.

## Pinout Mapping
- IMU: ICM-20948 (SPI1)
- Baro: BMP581 (I2C)
- GPS: Neo-M8N (UART)
- SD Card: SPI (Pins 35, 36, 37, 38)
- Battery: Pins 6, 7

## Stability Patches Applied
- RMT Initialization bypassed to prevent boot loop crashes on early ESP32-S3 HAL versions.

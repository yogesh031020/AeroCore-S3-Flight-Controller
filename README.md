# AeroCore S3 Custom Board Definition

Custom ArduPilot board target for ESP32S3-based flight controller.

## Hardware Showcase

### Final Flight Assembly
![Final Assembly Side View](aerocore_final_assembly_side.jpg)
![Final Assembly with Remote](aerocore_final_assembly_remote.jpg)
![Final Assembly Top View](aerocore_final_assembly_top.jpg)
![Final Assembly Powered On](aerocore_final_assembly_power.jpg)

### Custom PCB Build
![AeroCore S3 Drone Base](aerocore_drone.jpg)
![AeroCore S3 PCB Bottom Wiring](aerocore_wiring_bottom.jpg)
![AeroCore S3 PCB Top Components](aerocore_board_top.jpg)

## Pinout Mapping
- IMU: ICM-20948 (SPI1)
- Baro: BMP581 (I2C)
- GPS: Neo-M8N (UART)
- SD Card: SPI (Pins 35, 36, 37, 38)
- Battery: Pins 6, 7

## Stability Patches Applied
- RMT Initialization bypassed to prevent boot loop crashes on early ESP32-S3 HAL versions.

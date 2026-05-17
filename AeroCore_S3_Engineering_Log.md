# AeroCore S3 Flight Controller: Complete Engineering Log

## 1. Project Overview
Development of a custom ArduCopter flight controller utilizing an ESP32-S3 microcontroller, integrating standard aerospace sensors via SPI/I2C, and utilizing the FlySky iBUS RC protocol. The project required custom compilation of ArduPilot firmware to map hardware peripherals and resolve ESP32-specific power limitations.

## 2. Hardware Architecture & Wiring Map

### Core Components
*   **Microcontroller**: ESP32-S3 (WROOM-1 Module)
*   **IMU**: ICM-20948 9-DoF (SPI)
*   **Barometer**: BMP581 (I2C)
*   **GPS & Compass**: Ublox NEO-7M (UART & I2C)
*   **RC Receiver**: FlySky iA6B (iBUS)
*   **Power Stabilization**: 4700uF 25V Electrolytic Capacitor
*   **Logic Level Shifter**: 4-Channel 3.3V-5V Bi-Directional Converter

### Pin Mapping (ESP32-S3)
| Component | Function | ESP32-S3 Pin | Notes |
| :--- | :--- | :--- | :--- |
| **Power** | 5V Input | 5V / VIN | 4700uF Capacitor installed across 5V and GND. |
| **IMU** | SPI CS | GPIO 10 | Primary flight dynamics sensor. |
| **IMU** | SPI MOSI | GPIO 11 | Shared SPI bus. |
| **IMU** | SPI MISO | GPIO 13 | Shared SPI bus. |
| **IMU** | SPI SCK | GPIO 12 | Shared SPI bus (8MHz). |
| **Baro / Compass** | I2C SDA | GPIO 4 | Shared I2C bus (400kHz). |
| **Baro / Compass** | I2C SCL | GPIO 5 | Shared I2C bus (400kHz). |
| **GPS** | UART TX | GPIO 18 | Connects to GPS RX. |
| **GPS** | UART RX | GPIO 17 | Connects to GPS TX (9600 Baud). |
| **RC Receiver** | iBUS Signal | GPIO 16 | Requires 5V logic conversion if receiver outputs 5V. |
| **Motors (ESC)** | PWM Out | GPIO 1, 2, 47, 48 | Standard Quad/X configuration. |
| **SD Card** | SPI CS | GPIO 21 | Uses main SPI bus. |

## 3. Firmware Configuration (`hwdef.dat`)

The hardware definition file maps the physical pins to the ArduPilot HAL (Hardware Abstraction Layer).
*   **Board Name**: `AEROCORE_ULTRA`
*   **Navigation**: EKF3 enabled (`EK3_ENABLE_DEFAULT 1`, `AHRS_EKF_TYPE_DEFAULT 3`).
*   **Telemetry**: WiFi dual-link enabled via ESP32 AP mode (`AeroCore-S3`).

## 4. Issue Tracking & Resolutions

### Issue 1: Brown-out Reboots During WiFi Initialization
*   **Symptom**: The ESP32-S3 rebooted continuously due to voltage drops when the WiFi radio activated (high current draw).
*   **Resolution**: Installed a 4700uF decoupling capacitor across the 5V and GND rails to handle transient current spikes. Temporarily disabled PSRAM during testing to reduce boot load, re-enabled in final build.

### Issue 2: EKF Initialization Loop (Pre-arm Failure)
*   **Symptom**: ArduPilot rejected arming commands indoors due to missing GPS lock and compass variance.
*   **Resolution**: Implemented "Nuclear Bypass" logic in interim builds (`EK3_ENABLE 0`, `AHRS_EKF_TYPE 0` for DCM) to allow sensor-less manual flight testing via QGroundControl virtual joysticks.

### Issue 3: 40-Second Watchdog Crash
*   **Symptom**: System triggered a hardware watchdog reset exactly 40 seconds post-boot.
*   **Resolution**: Diagnosed as a filesystem timeout/hang associated with the SD Card logging system. Addressed by isolating the SD CS pin and adjusting `HAL_LOGGING_ENABLED` states across builds until hardware was verified.

## 5. Build Environment & Toolchain
*   **OS**: Windows Subsystem for Linux (WSL2) - Ubuntu 24.04
*   **Framework**: ESP-IDF v5.3
*   **Build Command**: `./waf configure --board esp32s3-aerocore && ./waf copter`
*   **Flash Tool**: `esptool.py` (Baud: 921600)

## 6. Final Project Artifacts
The final firmware and configuration files represent the stable, full-sensor configuration (V49).
*   `AEROCORE_V49_FINAL.bin`: The compiled bootloader, partition table, and ArduCopter firmware.
*   `hwdef_ultimate.dat`: The complete pin mapping and compiler directives.
*   `defaults_v34.parm`: Baseline flight parameters.

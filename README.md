# FPGA Digital Clock with Alarm and Snooze (OLED Display)

## PROJECT OVERVIEW
This project implements a **real-time Digital Clock with Alarm and Snooze functionality** using an FPGA (Zynq-7000 ZedBoard) and an **SSD1306 OLED display** interfaced via SPI. The system displays the current time in **HH:MM:SS format** and generates an alarm using a **blinking LED and an active buzzer** at a preset time. A snooze feature allows the user to delay the alarm by exactly **30 seconds**.

The entire system is designed using **Verilog HDL**, operates on a **100 MHz system clock**, and demonstrates a complete real-time embedded system on FPGA.

---

## PROBLEM STATEMENT
In embedded digital systems, real-time timekeeping and alarm functionality are common requirements. Implementing such a system on FPGA requires accurate clock division, proper state-based control, and reliable peripheral interfacing.

This project addresses the problem by designing:
- A 1 Hz real-time clock from a 100 MHz FPGA clock
- A CDC-safe button interface using synchronizers
- An OLED display controller using SPI
- Alarm and snooze logic with precise timing

---

## INPUTS AND OUTPUTS

### Inputs
- `clock` : 100 MHz system clock  
- `reset` : Global system reset  
- `alarm_reset_btn` : Stops alarm completely  
- `snooze_btn` : Activates snooze mode  

### Outputs
- `alarm_led` : Blinking LED during alarm  
- `buzzer` : Active buzzer output  
- OLED Interface:
  - `oled_spi_clk`
  - `oled_spi_data`
  - `oled_dc_n`
  - `oled_reset_n`
  - `oled_vdd`
  - `oled_vbat`

---

## SYSTEM STATES

The system operates logically in the following states:

### NORMAL
- Clock runs continuously
- OLED displays current time
- LED and buzzer are OFF

### ALARM
- Triggered when current time equals alarm time
- LED blinks at 1 Hz
- Buzzer beeps at 1 Hz

### SNOOZE
- Activated when snooze button is pressed
- Alarm stops immediately
- Alarm re-triggers after 30 seconds

---

## FEATURES
- Real-time digital clock (24-hour format)
- OLED display via SPI (SSD1306 compatible)
- Alarm at fixed preset time (00:01:00)
- Blinking LED indication
- Active buzzer alarm sound (1 sec ON / 1 sec OFF)
- Snooze function (+30 seconds)
- Alarm reset button
- Fully synchronous single-clock design

---

## DESIGN ARCHITECTURE

The system is divided into the following functional blocks:

### 1. Time Generator Block
- Divides 100 MHz clock into 1 Hz pulse
- Maintains seconds, minutes, and hours in BCD format

### 2. Alarm Comparator Block
- Compares current time with preset alarm time
- Generates alarm trigger signal

### 3. Snooze Controller Block
- Stores snooze target time
- Adds exactly 30 seconds to current time
- Triggers alarm again after snooze delay

### 4. Alarm Output Block
- Blinks LED at 1 Hz
- Drives active buzzer
- Both driven by same control signal

### 5. OLED Display Block
- Converts BCD to ASCII
- Sends characters using SPI FSM
- Displays HH:MM:SS continuously

---

## OPERATIONAL PRINCIPLE

### On Every Second (1 Hz)
- Time registers update
- Display string is refreshed
- Alarm comparison is evaluated

### When Alarm Triggers
- `alarm_on` becomes HIGH
- LED and buzzer blink at 1 Hz

### When Snooze is Pressed
- Alarm stops immediately
- Snooze target time is calculated (+30 seconds)
- Alarm re-triggers at snooze time

---

## HARDWARE AND TOOLS

### Hardware
- FPGA Board: ZedBoard (Zynq-7000)
- OLED Display: SSD1306 (128x32, SPI)
- Active Buzzer
- LED + 330Ω resistor
- Push buttons

### Software
- HDL Tool: AMD Vivado 2024
- Language: Verilog HDL
- Simulator: Vivado Simulator

---

## PIN CONSTRAINTS (ZedBoard)

| Signal | Pin |
|--------|-----|
| clock | Y9 |
| reset | P16 |
| alarm_reset_btn | R18 |
| snooze_btn | N15 |
| alarm_led | T22 |
| buzzer | Y11 |
| oled_spi_clk | AB12 |
| oled_spi_data | AA12 |
| oled_dc_n | U10 |
| oled_reset_n | U9 |
| oled_vbat | U11 |
| oled_vdd | U12 |

---

## FILE STRUCTURE


---

## VERIFICATION
The design is verified using:
- Functional simulation in Vivado
- On-board testing on ZedBoard
- Visual validation on OLED
- Physical verification of LED and buzzer

Test scenarios:
- Normal time counting
- Alarm trigger at 00:01:00
- Alarm reset
- Snooze and re-trigger after 30 seconds

---

## ERROR CONDITIONS

### Underflow
Not applicable (time always valid)

### Overflow
Not applicable (bounded BCD counters)

---

## POSSIBLE ENHANCEMENTS
- User-settable alarm time
- Multiple alarms
- Longer snooze intervals
- Progressive alarm sound
- Display "SNOOZE" on OLED
- AM/PM mode

---

## CONCLUSION
This project demonstrates a complete FPGA-based real-time digital system integrating timekeeping, user interaction, and peripheral control. The design is modular, fully synchronous, and suitable for practical embedded system applications.

---

## AUTHOR
Developed by: **velmurugan-vlsi**  
Platform: Zynq-7000 FPGA  
Domain: Digital Design / VLSI / FPGA  

---

## LICENSE
This project is intended for educational and learning purposes.

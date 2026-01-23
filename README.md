# DIGITAL-CLOCK
# FPGA Digital Clock with Alarm and Snooze (OLED Based)

## PROJECT OVERVIEW
This project implements a real-time **Digital Clock with Alarm and Snooze functionality** using an FPGA (Zynq-7000) and an OLED display interfaced via SPI. The system displays the current time in **HH:MM:SS format** and generates an alarm using a **blinking LED and an active buzzer** at a preset time. A snooze feature allows the user to temporarily silence the alarm and automatically re-trigger it after a fixed delay.

The design is fully synchronous, operates on a 100 MHz system clock, and demonstrates a complete embedded digital system implemented using Verilog HDL.

---

## PROBLEM STATEMENT
In real-time embedded systems, accurate timekeeping and user-interactive alarm control are common requirements. Implementing such a system on FPGA requires proper clock division, state-based control, reliable peripheral interfacing (OLED), and clean event handling (alarm and snooze).

This project addresses these challenges by designing a modular FPGA-based digital clock with:
- Stable 1 Hz time generation  
- OLED display control using SPI FSM  
- Alarm detection logic  
- User-controlled snooze mechanism  

---

## INPUTS AND OUTPUTS

### Inputs
- `clock` : 100 MHz system clock  
- `reset` : System reset  
- `alarm_reset_btn` : Clears the alarm  
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

The system logically operates in the following states:

### NORMAL
- Clock runs normally  
- OLED shows current time  
- LED and buzzer are OFF  

### ALARM
- Triggered when current time equals alarm time  
- LED blinks at 1 Hz  
- Buzzer beeps at 1 Hz  

### SNOOZE
- Activated by snooze button  
- Alarm is temporarily suppressed  
- After 5 minutes, alarm re-triggers  

---

## FEATURES
- Real-time digital clock (24-hour format)  
- OLED display via SPI (SSD1306 compatible)  
- Alarm at preset time  
- Blinking LED indication  
- Active buzzer alarm sound (1 sec ON / 1 sec OFF)  
- Snooze function (5 minutes)  
- Alarm reset button  
- Fully synchronous design (single clock domain)  

---

## DESIGN ARCHITECTURE

The system is divided into the following logical blocks:

### 1. Time Generator Block
- Divides 100 MHz clock to generate 1 Hz tick  
- Updates seconds, minutes, and hours in BCD format  

### 2. Alarm Comparator Block
- Compares current time with preset alarm time  
- Generates alarm trigger signal  

### 3. Alarm Control Block
- Latches alarm state  
- Drives LED and buzzer  
- Handles alarm reset and snooze  

### 4. Snooze Timer Block
- Counts 300 seconds (5 minutes)  
- Re-enables alarm after timeout  

### 5. OLED Display Block
- Converts BCD to ASCII  
- Sends characters via SPI FSM  
- Displays HH:MM:SS continuously  

---

## OPERATIONAL PRINCIPLE

### On Every Second (1 Hz)
- Time registers update  
- Display string is refreshed  
- Alarm comparison is evaluated  

### When Alarm Triggers
- `alarm_on` becomes HIGH  
- LED blinks using 1 Hz signal  
- Buzzer follows LED pattern  

### When Snooze is Pressed
- Alarm stops immediately  
- Snooze timer starts  
- After 5 minutes, alarm resumes  

---

## TOOLS AND HARDWARE

### Hardware
- FPGA: ZedBoard (Zynq-7000)  
- OLED Display: SSD1306 (SPI)  
- Active Buzzer  
- LED + 330Ω resistor  
- Push buttons  

### Software
- HDL Tool: AMD Vivado 2024  
- Language: Verilog HDL  
- Simulator: Vivado Simulator  

---

## FILE STRUCTURE


---

## VERIFICATION
The design is verified through:
- Functional simulation in Vivado  
- On-board testing using ZedBoard  
- Visual validation on OLED  
- Physical verification of LED and buzzer  

Test scenarios include:
- Normal time progression  
- Alarm trigger at preset time  
- Alarm reset  
- Snooze operation and re-trigger  

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
- Progressive alarm pattern  
- Display "SNOOZE" on OLED  
- AM/PM mode  
- Low-power sleep mode  

---

## CONCLUSION
This project demonstrates a complete real-time embedded system implemented on FPGA, integrating timekeeping, user interaction, peripheral control, and event-driven logic. The modular and synchronous architecture makes it robust, scalable, and suitable for practical digital system applications.

---

## AUTHOR
Developed by: **velmurugan-vlsi**  
Platform: Zynq-7000 FPGA  
Purpose: Learning FPGA-based embedded system design  

---

## LICENSE
This project is intended for educational and learning purposes.


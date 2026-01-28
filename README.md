# ⏰ FPGA Real-Time Digital Clock with Alarm & Snooze (OLED Display)

## Project Overview
This project implements a **Real-Time Digital Clock with Alarm and Snooze functionality** using **Verilog HDL** on an FPGA platform.  
The system displays **HH:MM:SS** on an **OLED display**, supports **manual time setting**, and provides an **alarm with an exact 30-second snooze feature**.

The design follows **synchronous digital design principles**, ensures reliable button handling through **synchronization logic**, and maintains stable OLED output without display corruption. The project has been verified on real hardware.

---

## Table of Contents
- Problem Statement  
- Features  
- Tools and Hardware  
- Block Diagram  
- Clock Operating Modes  
- Time-Set State Machine  
- Alarm & Snooze Operation  
- Timing Table  
- Verilog Implementation  
- OLED Display Interface  
- Testing & Verification  
- File Structure  
- Contributors  
- Conclusion  

---

## Problem Statement
FPGA-based real-time clock systems require precise timing generation, safe user interaction, and stable display control. Challenges include:

- Generating an accurate 1-second clock from a high-frequency system clock  
- Preventing metastability from mechanical push buttons  
- Safely modifying time without disrupting clock operation  
- Implementing alarm and snooze functionality reliably  
- Maintaining stable OLED display output  

This project solves these challenges using structured Verilog design, synchronized control signals, and clean modular architecture.

---

## Features
- Accurate **1-second timing** derived from a 100 MHz system clock  
- Displays real-time **HH:MM:SS** on OLED  
- **Manual time setting** using hardware buttons  
- Freeze-and-set mechanism for safe time adjustment  
- Increment-by-one hour and minute control  
- **Alarm function** at preset time  
- **Snooze function** with exact 30-second delay  
- Button synchronizers to avoid metastability  
- Stable OLED output without flicker or corruption  
- Fully synthesizable and hardware-tested  

---

## Tools and Hardware
- **FPGA Board:** ZedBoard (Zynq-7000)  
- **HDL Language:** Verilog HDL  
- **Design Tool:** AMD Vivado 2024  
- **Display:** OLED (SPI interface)  
- **Verification:** On-board FPGA testing  

---

## Block Diagram
The below block diagrma describes about the workflow of Digital Clock 

<img width="1920" height="1080" alt="CLOCK DIVIDER (2)" src="https://github.com/user-attachments/assets/a22e8ec6-13b8-4631-aad9-847ef8e7f447" />


## Clock Operating Modes

### Normal Mode
- Clock runs automatically  
- Time increments every second  
- Alarm monitoring active  

### Set Mode – Hours
- Clock is frozen  
- Hour value increments one step per button press  

### Set Mode – Minutes
- Clock remains frozen  
- Minute value increments one step per button press  

### Exit Set Mode
- Clock resumes normal operation with updated time  

---

## Time-Set State Machine

| Set Button Press | Mode         | Description          |
|------------------|--------------|----------------------|
| 1st Press        | Set Hours    | Adjust hours         |
| 2nd Press        | Set Minutes  | Adjust minutes       |
| 3rd Press        | Normal Mode  | Resume clock         |

---

## Alarm & Snooze Operation

### Alarm Trigger
- Alarm activates when current time matches preset alarm time  
- LED and buzzer toggle at 1 Hz  

### Snooze Function
- Snooze button stops the alarm  
- Adds **exactly 30 seconds** to the current time  
- Snoozed alarm triggers once and then disables snooze  

### Alarm Reset
- Immediately stops alarm and snooze mode  

---

## Timing Table (Example)

| Time      | Event           | State   |
|-----------|-----------------|---------|
| 00:00:59 | Clock running   | Normal  |
| 00:01:00 | Alarm triggers  | Alarm   |
| 00:01:10 | Snooze pressed  | Snooze  |
| 00:01:40 | Snooze alarm    | Alarm   |
| Reset    | Alarm cleared   | Normal  |

---

## Verilog Implementation

### Design Files
- **top.v**  
  Implements clock generation, time counting, time-setting logic, alarm and snooze control, and OLED interfacing.

- **oledControl.v**  
  Handles OLED initialization, SPI communication, and display refresh.

---

## OLED Display Interface
- Uses SPI communication  
- Displays time in **HH:MM:SS** format  
- Updates once per second  
- Ensures stable display output without visual artifacts  

---

## Testing & Verification
- Manual button presses verified on hardware  
- Time increments correctly without jitter  
- Alarm and snooze trigger accurately  
- OLED display remains stable over long runtime  

---

## File Structure

---

## Contributors
- **Velmurugan R** – Bannari Amman Institute of Technology  

---

## Conclusion
This project demonstrates a reliable FPGA-based real-time clock system with alarm and snooze functionality. By using synchronized inputs, single-driver control logic, and structured state handling, the design achieves stable operation and clean user interaction.

The project strengthens practical knowledge in FPGA timing, FSM design, alarm scheduling, and OLED interfacing, making it suitable for real-time embedded applications.

---

## Notes
This project enhanced understanding of:
- Clock division techniques  
- Button synchronization and control  
- Alarm and snooze scheduling logic  
- OLED SPI communication  
- Debugging timing and display issues  

#  FPGA Real-Time Digital Clock with Alarm & Snooze (OLED Display)

## Project Overview
This project implements a **Real-Time Digital Clock with Alarm and Snooze functionality** using **Verilog HDL** on an FPGA platform.  
The system displays **HH:MM:SS** on an **OLED display**, supports **manual time setting**, and provides an **alarm with an exact 30-second snooze feature**.

The design follows **synchronous digital design principles**, ensures reliable button handling through **synchronization logic**, and maintains stable OLED output without display corruption. The project has been verified on real hardware.

---

## Table of Contents

- [Problem Statement](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#Problem-Statement)
  
- [Features](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#features)
  
- [Tools and Hardware](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#tools-and-hardware)
 
- [Block Diagram](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#block-diagram)
  
- [Clock Operating Modes](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#clock-operating-modes)
   
- [Time-Set State Machine](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#time-set-state-machine)
  
- [Alarm & Snooze Operation](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#alarm--snooze-operation)
    
- [Verilog Implementation](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#verilog-implementation)
   
- [OLED Display Interface](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#oled-display-interface)
    
- [Testing & Verification](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#testing--verification)
    
- [File Structure](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#file-structure)
    
- [Contributors](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#contributors)
    
- [Conclusion](https://github.com/SiliconWorks/DIGITAL-CLOCK/blob/main/README.md#conclusion)  

---

## Problem Statement
FPGA-based real-time clock systems require precise timing generation, safe user interaction, and stable display control. Challenges include:

- Generating an accurate 1-second clock from a high-frequency system clock  
- Preventing metastability from mechanical push buttons  
- Safely modifying time without disrupting clock operation  
- Implementing alarm and snooze functionality reliably  
- Maintaining stable OLED display output using SPI Protocol

This project solves these challenges using structured Verilog design, synchronized control signals, and OLED configuration.

---

## Features
- Accurate **1-second timing** derived from a 100 MHz system clock  
- Displays real-time **HH:MM:SS** on OLED
- Stable OLED output 
- **Manual time setting** using hardware buttons  
- Freeze-and-set mechanism for safe time adjustment  
- Increment-by-one hour and minute control  
- **Alarm function** at preset time  
- **Snooze function** with exact 30-second delay  
- Button synchronizers to avoid metastability  
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

<img width="1920" height="1080" alt="CLOCK DIVIDER (3)" src="https://github.com/user-attachments/assets/f7c7c600-2f7d-4949-8d1a-f8773ea5cb58" />


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

## Verilog Implementation

### Design Files
- **top.v**  
  Implements clock generation, time counting, time-setting logic, alarm and snooze control, and OLED interfacing.

- **oledControl.v**  
  Handles OLED initialization, SPI communication, and display refresh.

---

## OLED Display Interface

**SPI PROTOCOL:**

 SPI (Serial Peripheral Interface) is a fast, synchronous, full-duplex communication protocol used for short-distance data transfer between a master and slave devices. It uses four signals: SCLK, MOSI, MISO, and CS to control data and device selection. Due to its simplicity and high speed, SPI is widely used to connect FPGAs and microcontrollers with peripherals like OLED displays, sensors, and memory chips.

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
- Velmurugan R – Bannari Amman Institute of Technology [LinkedIn link](https://www.linkedin.com/in/velmurugan-r-43b0b2355)

- 
  Harish P -  Bannari Amman Institute of Technology [LinkedIn link](https://www.linkedin.com/in/harish-p-493476355)

 
- Durai Murugan M - Bannari Amman Institute of Technology [LinkedIn link](https://www.linkedin.com/in/durai-murugan-859b67354)
 
- Vasan T  - Bannari Amman Institute of Technology [LinkedIn link](https://www.linkedin.com/in/vasan-t-7225x)

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

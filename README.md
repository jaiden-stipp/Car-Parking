# FPGA Car Parking System

A Verilog-based gate controller designed for an Altera/Intel FPGA. This project manages a 35-space parking garage using a Finite State Machine (FSM) to control a servo motor gate, track vehicle counts, and provide visual status updates.
![IMG_0279](https://github.com/user-attachments/assets/115fedb8-2bc8-411a-bc1d-21c2d04c7650)

## Features

* **Automated Gate Control:** Uses an FSM to handle gate opening, timing, and automatic closing.
* **Real-time Occupancy Tracking:** Increments/decrements car counts via entry and exit buttons (can be switched out for sensors).
* **Safety Logic:** Prevents the gate from opening if the garage is at its 35-car capacity.
* **Visual Feedback:** * **7-Segment Displays:** Shows current car count and the current state of the FSM.
    * **Status LEDs:** Indicates "Open" (available) or "Closed" (full).
    * **Warning Light:** Blinks when the garage is nearing capacity (30–34 cars).

## Hardware Components

* **FPGA Board:** Intel/Altera Cyclone Series (DE2-115).
* **Servo Motor:** SG90 Micro Servo (controlled via GPIO).
* **Input Buttons:** Active-low push buttons acting as vehicle sensors.
* **Displays:** On-board HEX 7-segment displays.

## Pin Assignments for DE2-115

<img width="745" height="621" alt="image" src="https://github.com/user-attachments/assets/172d7cf0-af14-461b-bfcb-bc78922fcf1c" />


## What I Learned

### 1. Button Debouncing and Synchronization
One of my biggest problems I had a the start was getting the I implemented a counter-based debouncer that waits for a signal to remain stable for 1,000,000 clock cycles (20 ms at 50MHz) before registering a valid press. This ensured that a single car was not counted multiple times due to mechanical jitter.

### 2. SG90 Servo Control (PWM via GPIO)
I learned how to interface with analog hardware using digital signals. By generating a Pulse Width Modulation (PWM) signal, I controlled the SG90 motor.
* **Logic:** A specific duty cycle (pulse width) translates to a physical angle (0 degrees for closed, 90 degrees for open).
* **Implementation:** Developed a `ServoController` module to translate high-level trigger signals into the precise microsecond pulses required by the motor.

### 3. Binary to 7-Segment Mapping
Raw binary data is not human-readable on an FPGA display. I built a decoder module that:
* Splits the `CarCount` into "Tens" and "Ones" places using conditional logic.
* Maps those 4-bit values to the 7-bit patterns required to light up the correct segments on the HEX displays.

### 4. Hardware Timing and Resource Management
Timing is critical in hardware design. I managed multiple time scales within a single system:
* **Micro-timing:** 20ms periods required for the Servo PWM signal.
* **Macro-timing:** A 500ms auto-close timer for the gate.
* **Blink-timing:** A 1Hz blink rate for the warning LED.
* **Optimization:** I learned the importance of register bit-widths, specifically ensuring that timer registers (e.g., 25-bit) are wide enough to reach target counts without overflowing.

## Thanks for reading! I am excited to keep working on FPGA/RTL design




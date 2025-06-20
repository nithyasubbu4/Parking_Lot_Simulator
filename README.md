# FPGA Parking Lot Simulator – DE1_SoC

This project implements a parking lot monitoring system using SystemVerilog and an Intel DE1-SoC board. The system simulates an 8-hour working day, tracking vehicle entry and exit in a 3-space parking lot via the LabsLand 3D simulator. It utilizes FSMs, RAM storage, and HEX display outputs to monitor real-time activity, rush hour stats, and lot occupancy.

---

## Features

- **Vehicle Entry/Exit Detection** via GPIO switches
- **Real-Time Occupancy Monitoring** with “FULL” status on HEX displays
- **Hour-Based Simulation** of a working day using FSM control
- **Daily Rush Hour Statistics** displayed after 8 hours
- **8x16 RAM Logging** to track car flow per hour
- **Clean Modular Design** using state machines and datapath-control separation

---

## Project Files and Uses

| Module                | Functionality |
|-----------------------|---------------|
| `DE1_SoC.sv`          | Top-level module; interfaces with V_GPIO for LabsLand simulation |
| `parkingLotControl.sv`| Instantiates datapath and FSM; coordinates full system logic |
| `datapath.sv`         | Tracks car count, total vehicles, and rush hour timing |
| `hourFSM.sv`          | FSM for advancing simulated hours (Idle → 8 hours → End) |
| `ram8x16.sv`          | Logs the number of cars for each hour of the day |
| `clockDivider.sv`     | Divides 50MHz clock for simulation-accurate timing |
| `buttonPress.sv`      | Flip-flop module for debouncing KEY[0] signal |
| `hexDisplay.sv`       | Converts data into 7-segment HEX output |
| `counter.sv`          | Auxiliary module to track individual car transitions |

---

## How System Works

1. **Simulated Day**: The parking lot operates for 8 hours. The hour advances when `KEY[0]` is pressed.
2. **Car Movement**: Vehicles enter/exit using GPIO switches. They are only allowed entry if a spot is available.
3. **Display Output**:
   - `HEX0`: Current hour
   - `HEX0–HEX3`: Display “FULL” if lot is full
   - After 8 hours:  
     - `HEX3`: Rush hour start time  
     - `HEX2`: Rush hour end time  
     - `HEX1–HEX0`: Cars per hour (from RAM)

4. **Reset Logic**: Activating the reset reinitializes total counts and FSM state.

---

## Procedure Summary (from Lab 6 Report)

The system was built using a modular design approach:
- **FSM (hourFSM.sv)**: Modeled 10 states including Idle, 8 hourly states, and EndStat for summary output
- **Datapath Module**: Maintains stats (current cars, total cars, rush hour)
- **HEX Display**: Used to show dynamic occupancy and final summary
- **LabsLand 3D Simulator**: Used to simulate real-world behavior using DE1-SoC and V_GPIO connections

Clocking and signal transitions were handled through a custom `clockDivider`, and `buttonPress` ensured clean hour transitions without signal bounce.

**Check out the Lab 6 Report for more details on Testbenching, Wavefiles and simualted scenarios. The lab report also includes diagrams to help you understand the 
structure of this system**
---

## Skills Demonstrated

- Finite State Machine (FSM) Design  
- Modular HDL Architecture (SystemVerilog)  
- Real-Time Simulation with LabsLand  
- RAM Integration and Usage  
- HEX Display Logic and Encoding  
- Embedded System Debugging & Testing on DE1-SoC  

---

## Files Included

- `DE1_SoC.sv`
- `parkingLotControl.sv`
- `datapath.sv`
- `hourFSM.sv`
- `ram8x16.sv`
- `buttonPress.sv`
- `clockDivider.sv`
- `hexDisplay.sv`
- `counter.sv`
- `ParkingLotSimulator_LabReport.pdf`

---

## Author

**Nithya Subramanian**  
University of Washington  

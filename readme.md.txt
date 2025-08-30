README.md (for your UART Protocol Verification repo)
# UART Protocol Verification (RTL + Testbench)

This project implements and verifies a UART Protocol (8N1) in SystemVerilog.  
Both the transmitter (TX) and receiver (RX) are included in the DUT (`uart_core.sv`).  
A SystemVerilog testbench (`tb_uart.sv`) provides loopback verification.

---

## 🔎 Specification
- Protocol UART (Universal Asynchronous ReceiverTransmitter)  
- Frame format  
  - 1 Start bit (0)  
  - 8 Data bits (LSB first)  
  - 1 Stop bit (1)  
  - No parity  
- Parameters  
  - `CLK_FREQ = 50 MHz`  
  - `BAUD = 115200 bps`  

---

## 📂 Project Structure


UART_Verification
│── uart_core.sv # DUT UART TX + RX
│── tb_uart.sv # Testbench (loopback verification)
│── UART_run_msim_rtl_verilog.do # QuestaModelSim run script
│── uart_dump.vcd # Waveform dump (for GTKWave)
│── verification_report.md # Detailed verification results
│── README.md # Project overview (this file)


---

## 🛠️ How to Run (QuestaModelSim)
1. Open Questa in the project directory.  
2. Run
   ```tcl
   do UART_run_msim_rtl_verilog.do


Waveform will be displayed.

A .vcd file (uart_dump.vcd) is also generated for viewing in GTKWave.

✅ Verification

Loopback test TX → RX connection validated.

Randomized data Multiple bytes transmittedreceived.

PassFail log Printed in simulation transcript.

Waveform Confirms proper UART frame format.
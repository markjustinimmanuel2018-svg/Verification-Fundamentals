**# Week 12 Mini Project - DMA Controller Constrained-Random Verification**



This project implements a SystemVerilog class-based verification environment for a DMA controller, focusing on **Constrained-Random Verification (CRV)**. The verification environment generates randomized DMA transactions within defined constraints, drives them to the DUT, monitors the completed transfers, and automatically compares expected and actual results using a scoreboard.



-------------------------------------------------------------------------------------------



**## Files**



* dma\_test.sv : SystemVerilog verification environment containing the transaction, generator, driver, monitor, scoreboard, interface and top-level testbench



DMA Controller RTL developed previously is reused as the Design Under Test (DUT).



-------------------------------------------------------------------------------------------



**## Objective**



* Develop a class-based constrained-random verification environment for a DMA controller
* Verify minimum and maximum transfer-count corner cases
* Drive randomized transactions to the DUT using a virtual interface
* Maintain an independent expected result in the scoreboard
* Automatically compare expected and actual DMA results
* Generate a VCD waveform for simulation analysis



-------------------------------------------------------------------------------------------



**## Verification Environment**



The verification environment consists of:



* **Transaction:** Represents a DMA transfer containing randomized source address, destination address, and transfer count, along with transaction results
* **Generator:** Generates minimum-count, maximum-count, and constrained-random DMA transactions
* **Driver:** Drives generated transactions to the DUT through a virtual interface
* **Interface:** Provides connectivity between the DUT and verification components
* **Monitor:** Observes the done signal and captures the final source address, destination address, count, and done status
* **Scoreboard:** Independently calculates the expected final source and destination address and compares them with the DUT results
* **Mailboxes:** Provide transaction-level communication between the Generator, Driver, Monitor, and Scoreboard



------------------------------------------------------------------------------------------



**## Constraints**



The DMA transactions are constrained using SystemVerilog constraint blocks.



* **Transfer Count:** The transfer count is restricted to the range 1 to 8, which provides a controlled transfer length while allowing different transaction sizes.
* **Source Address:** The source address is constrained so that the final address does not exceed the 8-bit address range.

&#x09;	src\_addr + count ≤ 255

* **Destination Address:** The destination address is constrained so that the final address does not exceed the 8-bit address range.

&#x09;	dst\_addr + count ≤ 255



------------------------------------------------------------------------------------------



**## Test Scenarios**



The generator produces 12 transactions covering the following conditions:



| **Transaction** |            **Type**           | **Count** |
|-------------|---------------------------|-------|
|      1      | Minimum Count Corner Case |   1   |
|      2      | Maximum Count Corner Case |   8   |
|     3-12    |    Constrained-Random     |  1-8  |



The randomized source and destination addresses are generated while satisfying the address-boundary constraints.



The test cases exercise:

* Minimum transfer count
* Maximum transfer count
* Different transfer lengths
* Different source and destination addresses
* Address-boundary conditions
* Multiple constrained-random DMA transfers



------------------------------------------------------------------------------------------



**## Verification Result**



All 12 constrained-random transactions passed successfully.



* PASS: SRC=251 -> 252 | DST=140 -> 141 | COUNT=1
* PASS: SRC=138 -> 146 | DST=139 -> 147 | COUNT=8
* PASS: SRC=207 -> 212 | DST=120 -> 125 | COUNT=5
* PASS: SRC=146 -> 147 | DST=230 -> 231 | COUNT=1
* PASS: SRC=35 -> 41 | DST=86 -> 92 | COUNT=6
* PASS: SRC=220 -> 225 | DST=164 -> 169 | COUNT=5
* PASS: SRC=144 -> 152 | DST=231 -> 239 | COUNT=8
* PASS: SRC=11 -> 13 | DST=78 -> 80 | COUNT=2
* PASS: SRC=24 -> 28 | DST=9 -> 13 | COUNT=4
* PASS: SRC=202 -> 205 | DST=18 -> 21 | COUNT=3
* PASS: SRC=22 -> 24 | DST=253 -> 255 | COUNT=2
* PASS: SRC=232 -> 239 | DST=155 -> 162 | COUNT=7



Verification Result: 12/12 transactions passed



Simulation Errors: 0



VCD Waveform: dma.vcd generated successfully



------------------------------------------------------------------------------------------



**## Tools \& Concepts**



* SystemVerilog
* Constrained-Random Verification (CRV)
* Randomization
* Corner-Case Testing
* Transaction-Based Verification
* Interface and Virtual Interface
* Independent Expected-Result Checking
* VCD Waveform Analysis
* QuestaSim
* EDA Playground



------------------------------------------------------------------------------------------



**## Learning Outcomes**



* Understood the fundamentals of Constrained-Random Verification
* Implemented randomized DMA transactions using SystemVerilog rand variables
* Implemented constrained blocks to control valid transfer ranges
* Applied source and destination address boundary constraints
* Implemented automatic expected-versus-actual checking
* Verified multiple DMA transfers without manually specifying every transaction
* Analyzed randomized DMA behavior using simulation waveforms
* Strengthened understanding of class-based SystemVerilog verification



------------------------------------------------------------------------------------------



**# Author:** MARK JUSTIN


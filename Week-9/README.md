**# Week 9 Mini Project - UART Self-Checking Verification**



This project implements a class-based SystemVerilog verification environment for the UART Transmitter-Receiver loopback system. The project focuses on transaction-based stimulus generation, DUT interfacing, output monitoring, and automatic result checking using a scoreboard.



--------------------------------------------------------------------------------------------



**## Files**



* uart\_test.sv : Class-based SystemVerilog verification environment for UART TX-RX loopback



-------------------------------------------------------------------------------------------



**## Objective**



* Develop a class-based verification environment using SystemVerilog
* Generate directed transactions for UART verification
* Drive DUT inputs and capture received transactions
* Use mailboxes for communication between verification components
* Automatically compare expected and actual results using a Scoreboard
* Verify multiple UART transactions without manual waveform inspection



-------------------------------------------------------------------------------------------



**## Verification Environment**



The verification environment consists of:



* **Transaction:** Represents the data transferred between verification components
* **Generator:** Creates UART transactions and sends them to the Driver and Scoreboard
* **Driver:** Converts transactions into DUT stimulus using a virtual interface
* **Interface:** Provides connectivity between the DUT and verification components
* **Monitor:** Observes DUT outputs and captures received transactions
* **Scoreboard:** Compares expected and actual transactions
* **Mailboxes:** Provide transaction-level communication between verification components



The UART RTL developed previously is reused as the Design Under Test (DUT) for this verification project.



-------------------------------------------------------------------------------------------



**## Test Data**



The UART loopback system was verified using multiple directed data values:



* A1
* 2B
* DD
* 00
* FF
* 25



Each transaction is driven into the UART DUT and the received data is automatically compared with the expected transaction by the Scoreboard.



-------------------------------------------------------------------------------------------



**## Verification Result**



* PASS: Expected = A1 | Actual = A1
* PASS: Expected = 2B | Actual = 2B
* PASS: Expected = DD | Actual = DD
* PASS: Expected = 00 | Actual = 00
* PASS: Expected = FF | Actual = FF
* PASS: Expected = 25 | Actual = 25



All directed transactions were successfully verified by the self-checking environment.



-------------------------------------------------------------------------------------------



**## Tools \& Concepts**



* SystemVerilog
* Class-Based Verification
* Transactions
* Generator
* Driver
* Monitor
* Scoreboard
* Mailboxes
* Interface and Virtual Interface
* Directed Verification
* Self-Checking Verification
* Concurrent Processes
* HDL Simulation (ModelSim)



-------------------------------------------------------------------------------------------



**## Learning Outcomes**



* Understood the structure of a class-based SystemVerilog verification environment
* Learned transaction-level communication between verification components
* Implemented Generator, Driver, Monitor, and Scoreboard components
* Used mailboxes for communication between verification classes
* Applied interfaces and virtual interfaces for DUT connectivity
* Developed automatic expected-versus-actual result checking
* Verified multiple UART transactions using directed stimulus
* Strengthened understanding of self-checking verification fundamentals



-------------------------------------------------------------------------------------------



**# Author:** MARK JUSTIN


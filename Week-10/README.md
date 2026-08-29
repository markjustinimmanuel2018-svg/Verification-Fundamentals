**# Week 10 Mini Project - SPI Self-Checking Verification**



This project implements a class-based SystemVerilog verification environment for an SPI Master-Slave communication system. The verification environment focuses on transaction-based stimulus generation, DUT interfacing, monitoring of both communication directions, and automatic result checking using a scoreboard.



\--------------------------------------------------------------------------------------------



**## Files**



* spi\_test.sv : Class-based SystemVerilog verification environment for SPI Master-Slave communication



The SPI RTL developed previously is reused as the Design Under Test (DUT).



\-------------------------------------------------------------------------------------------



**## Objective**



* Develop a class-based verification environment using SystemVerilog
* Generate directed transactions for SPI verification
* Drive Master and Slave input data to the DUT
* Monitor both Master and Slave received data
* Use mailboxes for communication between verification components
* Automatically compare expected and actual results using a Scoreboard
* Verify multiple SPI transactions without manual waveform inspection
* Implement automatic test completion after all transactions are verified



\-------------------------------------------------------------------------------------------



**## Verification Environment**



The verification environment consists of:



* **Transaction:** Represents Master and Slave data involved in an SPI transfer
* **Generator:** Creates SPI transactions and sends them to the Driver and Scoreboard
* **Driver:** Converts transactions into DUT stimulus using a virtual interface
* **Interface:** Provides connectivity between the DUT and verification components
* **Monitor:** Observes the completed SPI transaction and captures both Master and Slave received data
* **Scoreboard:** Independently checks both directions of SPI communication
* **Mailboxes:** Provide transaction-level communication between verification components



\-------------------------------------------------------------------------------------------



**## Test Data**



The SPI system was verified using six directed transactions:



| Transaction | Master Data | Slave Data |

|-------------|-------------|------------|

|      1      |      A5     |     5A     |

|      2      |      3C     |     C3     |

|      3      |      FF     |     00     |

|      4      |      00     |     FF     |

|      5      |      AA     |     55     |

|      6      |      55     |     AA     |



For each transaction, the expected relationship is:

* Expected Slave RX = Master Data
* Expected Master RX = Slave Data



\-------------------------------------------------------------------------------------------



**## Verification Result**



* PASS: Master TX = a5 | Slave RX = a5 | Slave TX = 5a | Master RX = 5a
* PASS: Master TX = 3c | Slave RX = 3c | Slave TX = c3 | Master RX = c3
* PASS: Master TX = ff | Slave RX = ff | Slave TX = 00 | Master RX = 00
* PASS: Master TX = 00 | Slave RX = 00 | Slave TX = ff | Master RX = ff
* PASS: Master TX = aa | Slave RX = aa | Slave TX = 55 | Master RX = 55
* PASS: Master TX = 55 | Slave RX = 55 | Slave TX = aa | Master RX = aa



ALL 6 TRANSACTIONS VERIFIED



\-------------------------------------------------------------------------------------------



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
* Self-checking Verification
* Two-Way Communication Checking
* Automatic Test Completion
* HDL Simulation (ModelSim)



\-------------------------------------------------------------------------------------------



**## Learning Outcomes**



* Understood the structure of a reusable class-based SPI verification environment
* Implemented transaction-based stimulus generation for Master-Slave communication
* Used Generator, Driver, Monitor, and Scoreboard components for SPI verification
* Applied interfaces and virtual interfaces for DUT connectivity
* Used mailboxes for transaction-level communication between verification components
* Verified both Master-to-Slave and Slave-to-Master communication paths
* Developed independent expected-versus-actual checking using a Scoreboard
* Verified multiple directed SPI transactions automatically
* Implemented automatic test completion after all transactions were verified
* Strengthened understanding of self-checking verification fundamentals



\-------------------------------------------------------------------------------------------



**# Author:** MARK JUSTIN


**# Week 11 Mini Project - Cache Controller Assertion-Based Verification and Functional Coverage**



This project implements a SystemVerilog verification environment for a cache controller, focusing on **Assertion-Based Verification (ABV)** and **Functional Coverage**. The verification environment uses directed stimulus along with SystemVerilog Assertions (SVA) to check important cache behaviors and functional coverage to measure whether the required cache scenarios have been exercised.



\-------------------------------------------------------------------------------------------



**## Files**



* cache\_controller\_test.sv : SystemVerilog verification environment containing the testbench, assertions, functional coverage, and verification components



Cache Controller RTL developed previously is reused as the Design Under Test (DUT).



\-------------------------------------------------------------------------------------------



**## Objective**



* Develop a SystemVerilog verification environment for a cache controller
* Generate directed cache read and write transactions
* Implement SystemVerilog Assertions to check important cache properties
* Verify read-after-write and reset behavior using assertions
* Implement functional coverage for cache operations and address fields
* Verify both HIT and MISS conditions and measure their functional coverage
* Use a coverage cross between read operations and HIT/MISS results
* Analyze simulation waveforms to confirm correct DUT behavior



\-------------------------------------------------------------------------------------------



**## Verification Environment**



The verification environment consists of:



* **Transaction:** Represents cache read/write operations, address, write data, read data, and hit status
* **Generator:** Generates directed cache transactions for different cache scenarios
* **Driver:** Drives generated transactions to the DUT through a virtual interface
* **Interface:** Provides connectivity between the DUT and verification components
* **Monitor:** Observes cache read operations and captures the resulting read data and HIT/MISS status
* **Scoreboard:** Maintains an independent expected cache model and compares expected and actual read results
* **Assertions:** Uses SystemVerilog Assertions to verify important cache properties
* **Coverage:** Uses functional coverage to measure exercised cache operations, HIT/MISS conditions, indices, and tags
* **Mailboxes:** Provide communication between the Generator, Driver, Monitor, and Scoreboard



\-------------------------------------------------------------------------------------------



**## Test Scenarios**



The cache controller was verified using the following directed scenarios:



| **Transaction** | **Operation** | **Address** | **Write Data** |   **Expected Result**  |

|-------------|-----------|---------|------------|--------------------|

|      1      |   Write   |   28    |     A5     |     Cache Write    |

|      2      |   Read    |   28    |     --     |       HIT, A5      |

|      3      |   Read    |   29    |     --     |         MISS       |

|      4      |   Write   |   AB    |     33     |     Cache Write    |

|      5      |   Read    |   B3    |     --     | MISS, Tag Mismatch |

|      6      |   Write   |   B5    |     55     |     Cache Write    |

|      7      |   Read    |   B6    |     --     |         MISS       |



The test cases exercise:

* Cache HIT after writing and reading the same address
* Unwritten address MISS
* Tag mismatch MISS
* Different index MISS



\-------------------------------------------------------------------------------------------



**## Assertion-Based Verification**



Three SystemVerilog Assertions are implemented:



* **Reset Assertion:** Check that the cache hit signal remains low during reset.
* **Read-After-Write HIT Assertion:** Checks that a read to the same address following a write produces a HIT.
* **Read Data Correctness Assertion:** Checks that the data returned after a valid write/read sequence matches the previously written data.



All assertions passed in the final simulation.



\-------------------------------------------------------------------------------------------



**## Functional Coverage**



Functional coverage was implemented using a SystemVerilog covergroup.



The following coverage points were included:



* **Read Enable (cp\_rd\_en):** Covers read operations
* **Write Enable (cp\_wr\_en):** Covers write operations
* **Hit (cp\_hit):** Covers HIT/MISS conditions
* **Cache Index (cp\_index):** Covers indexing operations
* **Cache Tag (cp\_tag):** Covers the cache tag field
* **Read Result Cross (read\_result):** Crosses read operation with HIT/MISS



This ensures that both cache operations and different address conditions are exercised during verification.



\-------------------------------------------------------------------------------------------



**## Verification Result**



* PASS: READ Addr = 28 | Expected Data = a5 | Actual Data = a5 | HIT = 1
* PASS: READ Addr = 29 | Expected MISS | Actual Hit = 0
* PASS: READ Addr = b3 | Expected MISS | Actual Hit = 0
* PASS: READ Addr = b6 | Expected MISS | Actual Hit = 0



CACHE VERIFICATION COMPLETED



* **Assertion Result:** 0 assertion errors
* **Scoreboard Result:** All monitored read transactions passed
* **Waveform:** cache.vcd generated successfully



\-------------------------------------------------------------------------------------------



**## Tools \& Concepts**



* SystemVerilog
* Assertion-Based Verification (ABV)
* SystemVerilog Assertions (SVA)
* Functional Coverage
* Covergroups
* Coverpoints
* Transaction-Based Verification
* Interface and Virtual Interface
* VCD Waveform Analysis
* QuestaSim
* EDA Playground



\-------------------------------------------------------------------------------------------



**## Learning Outcomes**



* Understood the fundamentals of Assertion-Based Verification
* Implemented SystemVerilog Assertions for cache controller properties
* Verified read-after-write HIT behavior using temporal assertions
* Understood the use of $past() and temporal operators in SVA
* Implemented functional coverage using covergroups and coverpoints
* Implemented cross coverage between read operations and HIT/MISS results
* Analyzed simulation waveforms to correlate DUT behavior with assertions and coverage



\-------------------------------------------------------------------------------------------



**# Author:** MARK JUSTIN


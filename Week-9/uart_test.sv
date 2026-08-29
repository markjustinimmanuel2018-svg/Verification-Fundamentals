// Transaction

class uart_transaction;

  bit [7:0] data;

endclass


// Interface

interface uart_if;

  logic clk, rst, tx_start, rx_done;
  logic [7:0] tx_data, rx_data;

endinterface


// Generator

class generator;

  mailbox gen2drv;
  mailbox gen2scb;

  uart_transaction trans;

  function new(mailbox gen2drv, mailbox gen2scb);

    this.gen2drv = gen2drv;
    this.gen2scb = gen2scb;
  
  endfunction

  task run();

    bit [7:0] test_data [0:5];

    test_data[0] = 8'hA1;
    test_data[1] = 8'h2B;
    test_data[2] = 8'hDD;
    test_data[3] = 8'h00;
    test_data[4] = 8'hFF;
    test_data[5] = 8'h25;

    for(int i=0; i<6; i++) begin
    
      trans = new();
      trans.data = test_data[i];
      gen2drv.put(trans);
      gen2scb.put(trans);

    end

  endtask

endclass


// Driver

class driver;

  mailbox gen2drv;
  
  uart_transaction trans;

  virtual uart_if vif;

  function new(mailbox gen2drv, virtual uart_if vif);

    this.gen2drv = gen2drv;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      gen2drv.get(trans);

      @(posedge vif.clk);
      vif.tx_data <= trans.data;
      vif.tx_start <= 1;

      @(posedge vif.clk);
      vif.tx_start <= 0;

      @(posedge vif.rx_done);
      @(negedge vif.rx_done);

    end

  endtask

endclass


// Monitor

class monitor;

  mailbox mon2scb;

  uart_transaction trans;

  virtual uart_if vif;

  function new(mailbox mon2scb, virtual uart_if vif);

    this.mon2scb = mon2scb;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      @(posedge vif.rx_done);
      trans = new();

      trans.data = vif.rx_data;

      mon2scb.put(trans);

    end

  endtask

endclass


// Scoreboard

class scoreboard;

  mailbox gen2scb;
  mailbox mon2scb;

  uart_transaction expected;
  uart_transaction actual;

  function new(mailbox gen2scb, mailbox mon2scb);

    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;

  endfunction

  task run();

    forever begin

      gen2scb.get(expected);
      mon2scb.get(actual);

      if(expected.data == actual.data)
        $display("PASS: Expected = %h | Actual = %h", expected.data, actual.data);
      else
        $display("FAIL: Expected = %h | Actual = %h", expected.data, actual.data);

    end

  endtask

endclass


// Top Testbench

module uart_test;

  parameter CLK_FREQ = 50000000;
  parameter BAUD_RATE = 9600;

  uart_if intf();

  mailbox gen2drv;
  mailbox gen2scb;
  mailbox mon2scb;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;

  uart #(.clk_freq(CLK_FREQ), .baud_rate(BAUD_RATE)) dut(.clk(intf.clk), .rst(intf.rst), .tx_start(intf.tx_start), .tx_data(intf.tx_data), .rx_data(intf.rx_data), .rx_done(intf.rx_done));

  always #10 intf.clk = ~intf.clk;

  initial begin

    intf.clk = 0;
    intf.rst = 1;
    intf.tx_start = 0;
    intf.tx_data = 0;

    gen2drv = new();
    gen2scb = new();
    mon2scb = new();

    gen = new(gen2drv, gen2scb);
    drv = new(gen2drv, intf);
    mon = new(mon2scb, intf);
    scb = new(gen2scb, mon2scb);

    #40;
    intf.rst = 0;

    fork

      gen.run();
      drv.run();
      mon.run();
      scb.run();

    join_none

    #70000000;

    $finish;

  end

endmodule
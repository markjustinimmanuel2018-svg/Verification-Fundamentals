// Transaction

class spi_transaction;

  bit [7:0] master_data;
  bit [7:0] slave_data;

  bit [7:0] master_rx;
  bit [7:0] slave_rx;

endclass


// Interface

interface spi_if;

  logic clk;
  logic rst;
  logic start;

  logic [7:0] master_tx_data;
  logic [7:0] slave_tx_data;

  logic [7:0] master_rx_data;
  logic [7:0] slave_rx_data;

  logic spi_done;
  logic slave_done;

endinterface


// Generator

class generator;

  mailbox gen2drv;
  mailbox gen2scb;

  spi_transaction trans;

  function new(mailbox gen2drv, mailbox gen2scb);

    this.gen2drv = gen2drv;
    this.gen2scb = gen2scb;

  endfunction

  task run();

    bit [7:0] master_data [0:5];
    bit [7:0] slave_data  [0:5];

    master_data[0] = 8'hA5;
    master_data[1] = 8'h3C;
    master_data[2] = 8'hFF;
    master_data[3] = 8'h00;
    master_data[4] = 8'hAA;
    master_data[5] = 8'h55;

    slave_data[0] = 8'h5A;
    slave_data[1] = 8'hC3;
    slave_data[2] = 8'h00;
    slave_data[3] = 8'hFF;
    slave_data[4] = 8'h55;
    slave_data[5] = 8'hAA;

    for(int i=0; i<6; i++) begin
      
      trans = new();

      trans.master_data = master_data[i];
      trans.slave_data = slave_data[i];

      gen2drv.put(trans);
      gen2scb.put(trans);

    end

  endtask

endclass


// Driver

class driver;

  mailbox gen2drv;
  
  spi_transaction trans;

  virtual spi_if vif;

  function new(mailbox gen2drv, virtual spi_if vif);
 
    this.gen2drv = gen2drv;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      gen2drv.get(trans);

      @(posedge vif.clk);

      vif.master_tx_data <= trans.master_data;
      vif.slave_tx_data <= trans.slave_data;
      vif.start <= 1;

      @(posedge vif.clk);

      vif.start <= 0;

      @(posedge vif.spi_done);

    end

  endtask

endclass


// Monitor

class monitor;

  mailbox mon2scb;
  
  spi_transaction trans;
  
  virtual spi_if vif;

  function new(mailbox mon2scb, virtual spi_if vif);

    this.mon2scb = mon2scb;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      @(posedge vif.spi_done);
      wait(vif.slave_done);

      trans = new();

      trans.master_rx = vif.master_rx_data;
      trans.slave_rx = vif.slave_rx_data;

      mon2scb.put(trans);

    end

  endtask

endclass


// Scoreboard

class scoreboard;

  mailbox gen2scb;
  mailbox mon2scb;

  spi_transaction expected;
  spi_transaction actual;

  function new(mailbox gen2scb, mailbox mon2scb);

    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;

  endfunction

  int pass_count;
  int total_count = 6;

  task run();

    forever begin

      gen2scb.get(expected);
      mon2scb.get(actual);

      if((expected.master_data == actual.slave_rx) && (expected.slave_data == actual.master_rx)) begin

        $display("PASS: Master TX = %h | Slave RX = %h | Slave TX = %h | Master RX = %h", 
                 expected.master_data, actual.slave_rx, expected.slave_data, actual.master_rx);

        pass_count++;

      end
      else begin
 
        $display("FAIL: Master TX = %h | Slave RX = %h | Slave TX = %h | Master RX = %h",
                 expected.master_data, actual.slave_rx, expected.slave_data, actual.master_rx);

      end

      if(pass_count == total_count) begin
        $display("ALL %0d TRANSACTIONS VERIFIED", total_count);
        $finish;
      end

    end

  endtask

endclass


// Top Testbench

module spi_test;

  parameter CLK_FREQ = 100;
  parameter SPI_FREQ = 10;

  spi_if intf();

  mailbox gen2drv;
  mailbox gen2scb;
  mailbox mon2scb;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;

  spi_top #(.clk_freq(CLK_FREQ), .spi_freq(SPI_FREQ))
          dut(.clk(intf.clk), .rst(intf.rst), .start(intf.start),
              .master_tx_data(intf.master_tx_data), .slave_tx_data(intf.slave_tx_data),
              .master_rx_data(intf.master_rx_data), .slave_rx_data(intf.slave_rx_data),
              .spi_done(intf.spi_done), .slave_done(intf.slave_done));

  always #10 intf.clk = ~intf.clk;

  initial begin

    intf.clk = 0;
    intf.rst = 1;
    intf.start = 0;
    intf.master_tx_data = 0;
    intf.slave_tx_data = 0;

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

  end

endmodule
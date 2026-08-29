// Transaction

class dma_transaction;

  rand bit [7:0] src_addr;
  rand bit [7:0] dst_addr;
  rand bit [7:0] count;

  bit start;

  bit done;
  bit [7:0] final_src;
  bit [7:0] final_dst;
  bit [7:0] final_count;

  constraint valid_count {
    count inside {[1:8]};
  }

  constraint valid_src {
    src_addr + count <= 255;
  }

  constraint valid_dst {
    dst_addr + count <= 255;
  }

endclass


// Interface

interface dma_if;

  logic clk;
  logic rst;
  logic start;

  logic [7:0] src_addr_in;
  logic [7:0] dst_addr_in;
  logic [7:0] count_in;

  logic done;
  logic [7:0] src_addr;
  logic [7:0] dst_addr;
  logic [7:0] count;

endinterface


// Generator

class generator;

  mailbox gen2drv;
  mailbox gen2scb;

  dma_transaction trans;

  function new(mailbox gen2drv, mailbox gen2scb);

    this.gen2drv = gen2drv;
    this.gen2scb = gen2scb;

  endfunction

  task run();

    // Corner Case : Minimum Count
    trans = new();
    
    if(!trans.randomize() with { count == 1;})
      $error("Randomization Failed");
    trans.start = 1;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Corner Case : Maximum Count
    trans = new();
    
    if(!trans.randomize() with { count == 8;})
      $error("Randomization Failed");
    trans.start = 1;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Constrained-Random Transactions
    repeat(10) begin
    
      trans = new();
    
      if(!trans.randomize())
        $error("Randomization Failed");
      trans.start = 1;
      gen2drv.put(trans);
      gen2scb.put(trans);

    end

  endtask

endclass


// Driver

class driver;

  mailbox gen2drv;

  dma_transaction trans;

  virtual dma_if vif;

  function new(mailbox gen2drv, virtual dma_if vif);

    this.gen2drv = gen2drv;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      gen2drv.get(trans);
      @(posedge vif.clk);

      vif.src_addr_in <= trans.src_addr;
      vif.dst_addr_in <= trans.dst_addr;
      vif.count_in <= trans.count;
      vif.start <= trans.start;

      @(posedge vif.clk);
      vif.start <= 0;

      @(posedge vif.done);

    end

  endtask

endclass


// Monitor

class monitor;

  mailbox mon2scb;

  dma_transaction trans;

  virtual dma_if vif;

  function new(mailbox mon2scb, virtual dma_if vif);

    this.mon2scb = mon2scb;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      @(posedge vif.done);

      trans = new();
      trans.done = vif.done;
      trans.final_src = vif.src_addr;
      trans.final_dst = vif.dst_addr;
      trans.final_count = vif.count;

      mon2scb.put(trans);

    end

  endtask

endclass


// Scoreboard

class scoreboard;

  mailbox gen2scb;
  mailbox mon2scb;

  dma_transaction expected;
  dma_transaction actual;

  integer expected_src;
  integer expected_dst;

  function new(mailbox gen2scb, mailbox mon2scb);

    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;

  endfunction

  task run();

    forever begin

      gen2scb.get(expected);
      mon2scb.get(actual);

      expected_src = expected.src_addr + expected.count;
      expected_dst = expected.dst_addr + expected.count;

      if((actual.final_src == expected_src) && (actual.final_dst == expected_dst) &&
         (actual.final_count == 0) && (actual.done == 1)) begin

	$display("PASS: SRC=%0d -> %0d | DST=%0d -> %0d | COUNT=%0d",
		 expected.src_addr, actual.final_src, expected.dst_addr, actual.final_dst, expected.count);

      end
      else begin
	$display("FAIL: SRC=%0d -> %0d | DST=%0d -> %0d | COUNT=%0d",
		 expected.src_addr, actual.final_src, expected.dst_addr, actual.final_dst, expected.count);

      end
  
    end

  endtask

endclass


// Top Testbench

module dma_test;

  dma_if intf();

  mailbox gen2drv;
  mailbox gen2scb;
  mailbox mon2scb;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;

  dma_controller dut(.clk(intf.clk), .rst(intf.rst), .start(intf.start), .src_addr_in(intf.src_addr_in),
		     .dst_addr_in(intf.dst_addr_in), .count_in(intf.count_in), .done(intf.done),
		     .src_addr(intf.src_addr), .dst_addr(intf.dst_addr), .count(intf.count));

  always #5 intf.clk = ~intf.clk;

  initial begin

    $dumpfile("dma.vcd");
    $dumpvars(0, dma_test);

    intf.clk = 0;
    intf.rst = 1;
    intf.start = 0;
    intf.src_addr_in = 0;
    intf.dst_addr_in = 0;
    intf.count_in = 0;

    gen2drv = new();
    gen2scb = new();
    mon2scb = new();

    gen = new(gen2drv, gen2scb);
    drv = new(gen2drv, intf);
    mon = new(mon2scb, intf);
    scb = new(gen2scb, mon2scb);

    #20;
    intf.rst = 0;

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none

    #1000;

    $display("DMA VERIFICATION COMPLETED");

    $finish;

  end
 
endmodule
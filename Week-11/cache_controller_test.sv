// Transaction

class cache_transaction;

  bit rd_en, wr_en;
  bit [7:0] addr, wr_data, rd_data;
  bit hit;

endclass


// Interface

interface cache_if;

  logic clk, rst;
  logic rd_en, wr_en;
  logic [7:0] addr, wr_data, rd_data;
  logic hit;

endinterface


// Generator

class generator;

  mailbox gen2drv;
  mailbox gen2scb;

  cache_transaction trans;

  function new(mailbox gen2drv, mailbox gen2scb);

    this.gen2drv = gen2drv;
    this.gen2scb = gen2scb;

  endfunction

  task run();

    // Write A5 to address 8'h28

    trans = new();
    trans.wr_en = 1;
    trans.rd_en = 0;
    trans.addr = 8'h28;
    trans.wr_data = 8'hA5;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Read written address [HIT]

    trans = new();
    trans.wr_en = 0;
    trans.rd_en = 1;
    trans.addr = 8'h28;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Read unwritten address [MISS]

    trans = new();
    trans.wr_en = 0;
    trans.rd_en = 1;
    trans.addr = 8'h29;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Tag mismatch [MISS]

    trans = new();
    trans.wr_en = 1;
    trans.rd_en = 0;
    trans.addr = 8'b10101_011;
    trans.wr_data = 8'h33;
    gen2drv.put(trans);
    gen2scb.put(trans);

    trans = new();
    trans.wr_en = 0;
    trans.rd_en = 1;
    trans.addr = 8'b10110_011;
    gen2drv.put(trans);
    gen2scb.put(trans);

    // Different index [MISS]

    trans = new();
    trans.wr_en = 1;
    trans.rd_en = 0;
    trans.addr = 8'b10110_101;
    trans.wr_data = 8'h55;
    gen2drv.put(trans);
    gen2scb.put(trans);

    trans = new();
    trans.wr_en = 0;
    trans.rd_en = 1;
    trans.addr = 8'b10110_110;
    gen2drv.put(trans);
    gen2scb.put(trans);

  endtask

endclass


// Driver

class driver;

  mailbox gen2drv;

  cache_transaction trans;
 
  virtual cache_if vif;

  function new(mailbox gen2drv, virtual cache_if vif);

    this.gen2drv = gen2drv;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      gen2drv.get(trans);

      @(negedge vif.clk);
      vif.rd_en <= trans.rd_en;
      vif.wr_en <= trans.wr_en;
      vif.addr <= trans.addr;
      vif.wr_data <= trans.wr_data;
      
    end
  
  endtask

endclass


// Monitor

class monitor;

  mailbox mon2scb;
  
  cache_transaction trans;

  virtual cache_if vif;

  function new(mailbox mon2scb, virtual cache_if vif);

    this.mon2scb = mon2scb;
    this.vif = vif;

  endfunction

  task run();

    forever begin

      @(posedge vif.clk);

      if(vif.rd_en) begin
      #1;
      
      trans = new();
      trans.rd_en = 1;
      trans.addr = vif.addr;
      trans.rd_data = vif.rd_data;
      trans.hit = vif.hit;

      mon2scb.put(trans);

      end

    end

  endtask

endclass


// Scoreboard

class scoreboard;

  mailbox gen2scb;
  mailbox mon2scb;

  cache_transaction expected;
  cache_transaction actual;

  bit valid [0:7];
  bit [4:0] tag [0:7];
  bit [7:0] data [0:7];

  function new(mailbox gen2scb, mailbox mon2scb);

    this.gen2scb = gen2scb;
    this.mon2scb = mon2scb;

    for(int i=0; i<8; i++) begin
      valid[i] = 0;
      tag[i] = 0;
      data[i] = 0;
    end

  endfunction

  task run();

    forever begin

      gen2scb.get(expected);

      // Write

      if(expected.wr_en) begin
	valid[expected.addr[2:0]] = 1;
	tag[expected.addr[2:0]] = expected.addr[7:3];
	data[expected.addr[2:0]] = expected.wr_data;
      end

      // Read

      if(expected.rd_en) begin
	mon2scb.get(actual);
	if(valid[expected.addr[2:0]] && tag[expected.addr[2:0]] == expected.addr[7:3]) begin
	  if(actual.hit && actual.rd_data == data[expected.addr[2:0]]) begin
	    $display("PASS: READ Addr = %h | Expected Data = %h | Actual Data = %h | HIT = %b",
		     expected.addr, data[expected.addr[2:0]], actual.rd_data, actual.hit);
	  end
	  else begin
	    $display("FAIL: READ Addr = %h | Expected Data = %h | Actual Data = %h | HIT = %b",
		     expected.addr, data[expected.addr[2:0]], actual.rd_data, actual.hit);
	  end
        end
	else begin
	  if(!actual.hit) begin
	    $display("PASS: READ Addr = %h | Expected MISS | Actual Hit = %b", expected.addr, actual.hit);
	  end
	  else begin
	    $display("FAIL: READ Addr = %h | Expected MISS | Actual Hit = %b", expected.addr, actual.hit);
	  end
	end

      end

    end

  endtask

endclass



// ASSERTIONS

module cache_assertions (input clk, rst, rd_en, wr_en, input [7:0] addr, wr_data, rd_data, input hit);

  assert property (@(posedge clk)
    rst |-> !hit
  )
  else
    $error("ASSERTION FAILED: hit is high during reset");

  assert property (@(posedge clk)
    disable iff (rst)
    $past(wr_en) && rd_en && (addr == $past(addr)) |=> hit
  )
  else
    $error("ASSERTION FAILED: Read after write to same address did not hit");

  assert property (@(posedge clk)
    disable iff(rst)
                   $past(wr_en,2) && rd_en && (addr == $past(addr,2)) |-> (rd_data == $past(wr_data,2))
  )
  else
    $error("ASSERTION FAILED: Read data does not match written data");

endmodule



// COVERAGE

class cache_coverage;

  virtual cache_if vif;

  covergroup cache_cg @(posedge vif.clk);

    cp_rd_en: coverpoint vif.rd_en iff (!vif.rst) { 
      bins read = {1}; 
    }

    cp_wr_en: coverpoint vif.wr_en iff (!vif.rst) {
      bins write = {1};
    }

    cp_hit: coverpoint vif.hit iff (!vif.rst) {
      bins miss = {0};
      bins hit = {1};
    }

    cp_index: coverpoint vif.addr[2:0] iff (!vif.rst) {
      bins index_0 = {0};
      bins index_1 = {1};
      bins index_2 = {2};
      bins index_3 = {3};
      bins index_4 = {4};
      bins index_5 = {5};
      bins index_6 = {6};
      bins index_7 = {7};
    }

    cp_tag: coverpoint vif.addr[7:3] iff (!vif.rst);

    read_result: cross cp_rd_en, cp_hit;

  endgroup

  function new(virtual cache_if vif);
    this.vif = vif;
    cache_cg = new();
  endfunction

endclass


// Top Testbench

module cache_controller_test;

  cache_if intf();

  mailbox gen2drv;
  mailbox gen2scb;
  mailbox mon2scb;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;

  cache_coverage cov;

  cache_controller dut(.clk(intf.clk), .rst(intf.rst), .rd_en(intf.rd_en), .wr_en(intf.wr_en),
		       .addr(intf.addr), .wr_data(intf.wr_data), .rd_data(intf.rd_data), .hit(intf.hit));

  cache_assertions assertions(.clk(intf.clk), .rst(intf.rst), .rd_en(intf.rd_en), .wr_en(intf.wr_en),
		       .addr(intf.addr), .wr_data(intf.wr_data), .rd_data(intf.rd_data), .hit(intf.hit));

  always #5 intf.clk = ~intf.clk;

  initial begin

    $dumpfile("cache.vcd");
    $dumpvars(0, cache_controller_test);
    
    intf.clk = 0;
    intf.rst = 1;
    intf.rd_en = 0;
    intf.wr_en = 0;
    intf.addr = 0;
    intf.wr_data = 0;

    gen2drv = new();
    gen2scb = new();
    mon2scb = new();

    gen = new(gen2drv, gen2scb);
    drv = new(gen2drv, intf);
    mon = new(mon2scb, intf);
    scb = new(gen2scb, mon2scb);

    cov = new(intf);

    #20;
    intf.rst = 0;

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none

    #200;
    $display("CACHE VERIFICATION COMPLETED");
    $finish;

  end

endmodule
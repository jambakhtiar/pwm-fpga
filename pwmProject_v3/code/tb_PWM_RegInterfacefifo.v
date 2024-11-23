`timescale 1ns/1ps

module tb_PWM_RegInterfacefifo;

  // Testbench Parameters
  parameter WIDTH = 8;

  // Testbench signals
  reg                  tb_clk;
  reg                  tb_rst;
  reg      [WIDTH-1:0] tb_duty_cycle;
  reg                  tb_duty_cycle_we;
  reg      [WIDTH-1:0] tb_switch_freq;
  reg                  tb_switch_freq_we;
  reg                  tb_period_start;
  wire     [WIDTH-1:0] tb_o_duty_cycle;
  wire     [WIDTH-1:0] tb_o_switch_freq;
  wire                 tb_o_duty_cycle_ready;
  wire                 tb_o_switch_freq_ready;
  wire                 tb_o_duty_cycle_done;
  wire                 tb_o_switch_freq_done;

  // Instantiate the DUT (Device Under Test)
  PWM_RegInterfacefifo #(.WIDTH(WIDTH)) dut (
    .i_clk(tb_clk),
    .i_rst(tb_rst),
    .i_duty_cycle(tb_duty_cycle),
    .i_duty_cycle_we(tb_duty_cycle_we),
    .i_switch_freq(tb_switch_freq),
    .i_switch_freq_we(tb_switch_freq_we),
    .i_period_start(tb_period_start),
    .o_duty_cycle(tb_o_duty_cycle),
    .o_switch_freq(tb_o_switch_freq),
    .o_duty_cycle_ready(tb_o_duty_cycle_ready),
    .o_switch_freq_ready(tb_o_switch_freq_ready),
    .o_duty_cycle_done(tb_o_duty_cycle_done),
    .o_switch_freq_done(tb_o_switch_freq_done)
  );

  // Clock Generation
  always #5 tb_clk = ~tb_clk; // 100MHz clock (10ns period)

  // Initial block for simulation setup
  initial begin
    // Initialize signals
    tb_clk = 0;
    tb_rst = 1;
    tb_duty_cycle = 0;
    tb_duty_cycle_we = 0;
    tb_switch_freq = 0;
    tb_switch_freq_we = 0;
    tb_period_start = 0;

    // Reset sequence
    #15;
    tb_rst = 0;

    // Write duty cycle and switching frequency to the FIFOs
    #10;
    tb_period_start = 0;
    #10;
    tb_duty_cycle = 8'h55;  // Example duty cycle value
    tb_duty_cycle_we = 1;
    #5; tb_duty_cycle = 8'hab;
    #5; tb_duty_cycle = 8'hac;
    #5; tb_duty_cycle = 8'had;
    #5; tb_duty_cycle = 8'hae;
    #5; tb_duty_cycle = 8'haf;
    #5; tb_duty_cycle = 8'hba;
    #5; tb_duty_cycle = 8'hbb;
    #10;
    tb_duty_cycle_we = 0;
    
    tb_switch_freq = 8'hAA; // Example switching frequency value
    tb_switch_freq_we = 1;
    #5; tb_switch_freq = 8'hbc;
    #5; tb_switch_freq = 8'hbd;
    #5; tb_switch_freq = 8'hbe;
    #5; tb_switch_freq = 8'hbf;
    #5; tb_switch_freq = 8'hca;
    #5; tb_switch_freq = 8'hcb;
    #5; tb_switch_freq = 8'hcc;
    #10;
    tb_switch_freq_we = 0;

    // Start a period and observe the outputs
    #20;
    tb_period_start = 1;
    #50;
    tb_period_start = 0;

    // Wait for a few clock cycles and observe results
    #40;

    // Add more test cases as needed
    $stop;
  end

endmodule

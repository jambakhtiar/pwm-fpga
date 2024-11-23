
module top_level 
    #(parameter width = 8, 
      parameter TimerBits = 8,
      parameter CPOL   = 1'b0,
      parameter CPHA   = 1'b0,  
      parameter LSB    = 1'b0
      )
    (
    input        i_clk,       // System clock
    input        i_rst,       // System reset
    // SPI Interface
    input        i_sck,       // SPI clock
    input        i_mosi,      // Master out slave in
    input        i_ss_n,      // Slave select (active low) 
    output       o_miso,      // Master in slave out
    input        i_reset,
    input [width-1:0] i_tx_data,
    
	 // PWM Outputs
    output       pwm_out_ch1,// PWM output channel 1
	 output 		  ch1_done, 
    output       pwm_out_ch2, // PWM output channel 2
    output 		  ch2_done, 	 
	 output       pwm_out_ch3, // PWM output channel 3
    output 		  ch3_done, 
	 output       pwm_out_ch4,  // PWM output channel 4
	 output 		  ch4_done 
);

    // Internal signals
    //wire [width-1:0] tx_data;
    wire [width-1:0] rx_data;
    wire       tx_int, rx_int;
    wire       miso_oe;
    
    wire [width:0] duty_cycle_ch1, duty_cycle_ch2, duty_cycle_ch3, duty_cycle_ch4;
    wire [TimerBits-1:0] switch_freq_ch1, switch_freq_ch2, switch_freq_ch3, switch_freq_ch4;

    wire duty_cycle_ready_ch1, duty_cycle_ready_ch2, duty_cycle_ready_ch3, duty_cycle_ready_ch4;
    wire switch_freq_ready_ch1, switch_freq_ready_ch2, switch_freq_ready_ch3, switch_freq_ready_ch4;

    wire duty_cycle_done_ch1, duty_cycle_done_ch2, duty_cycle_done_ch3, duty_cycle_done_ch4;
    wire switch_freq_done_ch1, switch_freq_done_ch2, switch_freq_done_ch3, switch_freq_done_ch4;
 /* 
  localparam CPOL   = 1'b0;  // When one, polarity is low, otherwise polarity is high (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  localparam CPHA   = 1'b0;  // When one, sampling occurs at falling edge, otherwise at rising edge of non-inverted clock (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  localparam WIDTH  = 8;     // The width of the input and output data buses (Type - Decimal, Default value = 8, Min value = 8, Max value = 64)
  localparam LSB    = 1'b0;
   */ 
    // SPI Slave Instance
    spi_slave #(
        .CPOL(CPOL),
        .CPHA(CPHA),
        .WIDTH(width),
        .LSB(LSB)
    ) spi_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sck(i_sck),
        .i_mosi(i_mosi),
        .i_ss_n(i_ss_n),
        .o_miso(o_miso),
        .o_miso_oe(miso_oe),
        .i_reset(i_reset),
        .i_tx_data(i_tx_data),
        .o_tx_int(tx_int),
        .o_rx_int(rx_int),
        .o_rx_data(rx_data)
    );

    // Channel 1
    PWM_RegInterfacefifo #(.WIDTH(width)) fifo_inst_ch1 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_duty_cycle(rx_data),
        .i_duty_cycle_we(rx_int),  // Replace with actual control logic for channel 1
        .i_switch_freq(rx_data),
        .i_switch_freq_we(rx_int), // Replace with actual control logic for channel 1
        .i_period_start(1'b1), // Adjust as per the control logic
        .o_duty_cycle(duty_cycle_ch1),
        .o_switch_freq(switch_freq_ch1),
        .o_duty_cycle_ready(duty_cycle_ready_ch1),
        .o_switch_freq_ready(switch_freq_ready_ch1),
        .o_duty_cycle_done(duty_cycle_done_ch1),
        .o_switch_freq_done(switch_freq_done_ch1)
    );

    Pwm_In #(.R(width), .TimerBits(TimerBits)) pwm_inst_ch1 (
        .clk(i_clk),
        .reset_n(~i_rst),
        .duty(duty_cycle_ch1),
        .Final_Value(8'd35),//(switch_freq_ch1),
        .ready(duty_cycle_ready_ch1 & switch_freq_ready_ch1),
        .done(ch1_done),//(duty_cycle_done_ch1 & switch_freq_done_ch1),
        .pwm_out(pwm_out_ch1)
    );

    // Channel 2
    PWM_RegInterfacefifo #(.WIDTH(width)) fifo_inst_ch2 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_duty_cycle(rx_data),
        .i_duty_cycle_we(rx_int),  // Replace with actual control logic for channel 2
        .i_switch_freq(rx_data),
        .i_switch_freq_we(rx_int), // Replace with actual control logic for channel 2
        .i_period_start(1'b1), // Adjust as per the control logic
        .o_duty_cycle(duty_cycle_ch2),
        .o_switch_freq(switch_freq_ch2),
        .o_duty_cycle_ready(duty_cycle_ready_ch2),
        .o_switch_freq_ready(switch_freq_ready_ch2),
        .o_duty_cycle_done(duty_cycle_done_ch2),
        .o_switch_freq_done(switch_freq_done_ch2)
    );

    Pwm_In #(.R(width), .TimerBits(TimerBits)) pwm_inst_ch2 (
        .clk(i_clk),
        .reset_n(~i_rst),
        .duty(duty_cycle_ch2),
        .Final_Value(8'd35),//(switch_freq_ch2),
        .ready(duty_cycle_ready_ch2 & switch_freq_ready_ch2),
        .done(ch2_done),//(duty_cycle_done_ch2 & switch_freq_done_ch2),
        .pwm_out(pwm_out_ch2)
    );

    // Channel 3
    PWM_RegInterfacefifo #(.WIDTH(width)) fifo_inst_ch3 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_duty_cycle(rx_data),
        .i_duty_cycle_we(rx_int),  // Replace with actual control logic for channel 3
        .i_switch_freq(rx_data),
        .i_switch_freq_we(rx_int), // Replace with actual control logic for channel 3
        .i_period_start(1'b1), // Adjust as per the control logic
        .o_duty_cycle(duty_cycle_ch3),
        .o_switch_freq(switch_freq_ch3),
        .o_duty_cycle_ready(duty_cycle_ready_ch3),
        .o_switch_freq_ready(switch_freq_ready_ch3),
        .o_duty_cycle_done(duty_cycle_done_ch3),
        .o_switch_freq_done(switch_freq_done_ch3)
    );

    Pwm_In #(.R(width), .TimerBits(TimerBits)) pwm_inst_ch3 (
        .clk(i_clk),
        .reset_n(~i_rst),
        .duty(duty_cycle_ch3),
        .Final_Value(8'd35),//(switch_freq_ch3),
        .ready(duty_cycle_ready_ch3 & switch_freq_ready_ch3),
        .done(ch3_done),//(duty_cycle_done_ch3 & switch_freq_done_ch3),
        .pwm_out(pwm_out_ch3)
    );

    // Channel 4
    PWM_RegInterfacefifo #(.WIDTH(width)) fifo_inst_ch4 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_duty_cycle(rx_data),
        .i_duty_cycle_we(rx_int),  // Replace with actual control logic for channel 4
        .i_switch_freq(rx_data),
        .i_switch_freq_we(rx_int), // Replace with actual control logic for channel 4
        .i_period_start(1'b1), // Adjust as per the control logic
        .o_duty_cycle(duty_cycle_ch4),
        .o_switch_freq(switch_freq_ch4),
        .o_duty_cycle_ready(duty_cycle_ready_ch4),
        .o_switch_freq_ready(switch_freq_ready_ch4),
        .o_duty_cycle_done(duty_cycle_done_ch4),
        .o_switch_freq_done(switch_freq_done_ch4)
    );

    Pwm_In #(.R(width), .TimerBits(TimerBits)) pwm_inst_ch4 (
        .clk(i_clk),
        .reset_n(~i_rst),
        .duty(duty_cycle_ch4),
        .Final_Value(8'd35),//(switch_freq_ch4),
        .ready(duty_cycle_ready_ch4 & switch_freq_ready_ch4),
        .done(ch4_done),//(duty_cycle_done_ch4 & switch_freq_done_ch4),
        .pwm_out(pwm_out_ch4)
    );

endmodule

`timescale 1ns / 1ps

module top_level_tb();
    localparam CLK_PER     = 10;
    localparam CLK_SPI_PER = 100;

    integer i              = 0;

    // Parameters
    parameter width = 8;
    parameter TimerBits = 8;
    parameter CPOL   = 1'b0;
    parameter CPHA   = 1'b0;  
    parameter LSB    = 1'b0;

    // Inputs
    reg              r_clk       = 1'b0;
    reg              r_rst       = 1'b1;
    reg              r_sck       = 1'b0;
    reg              r_mosi      = 1'b0;
    reg              r_ss_n      = 1'b0;
    reg              r_reset     = 1'b0;
    reg  [width-1:0] r_tx_data   = 'h00;

    // Outputs
    wire             w_miso;
    wire             pwm_out_ch1;
    wire             ch1_done;
    wire             pwm_out_ch2;
    wire             ch2_done;
    wire             pwm_out_ch3;
    wire             ch3_done;
    wire             pwm_out_ch4;
    wire             ch4_done;

    // Instantiate the top_level module
    top_level #(.width(width), .TimerBits(TimerBits)) uut (
        .i_clk(r_clk),
        .i_rst(r_rst),
        .i_sck(r_sck),
        .i_mosi(r_mosi),
        .i_ss_n(r_ss_n),
        .o_miso(w_miso),
        .i_reset(r_reset),
        .i_tx_data(r_tx_data),
        .pwm_out_ch1(pwm_out_ch1),
        .ch1_done(ch1_done),
        .pwm_out_ch2(pwm_out_ch2),
        .ch2_done(ch2_done),
        .pwm_out_ch3(pwm_out_ch3),
        .ch3_done(ch3_done),
        .pwm_out_ch4(pwm_out_ch4),
        .ch4_done(ch4_done)
    );

    always #(CLK_PER/2) r_clk <= ~r_clk;

    // Task generate data for test receiver
  task receive_send_data;
    input [width-1:0] i_data_rx;
    begin
      if ((CPOL ^ CPHA) == 1) begin
        if (r_sck == 0) begin
          r_sck <= 1'b1;
        end
        #CLK_SPI_PER;
      end else begin
        if (r_sck == 1) begin
          r_sck <= 1'b0;
        end
        #CLK_SPI_PER;
      end
      for (i = 0; i <= width - 1; i = i + 1) begin

        r_mosi = i_data_rx[width-1 - i];
        if ((CPOL ^ CPHA) == 1) begin
          #CLK_SPI_PER r_sck <= 1'b0;
          #CLK_SPI_PER r_sck <= 1'b1;
        end else begin
          #CLK_SPI_PER r_sck <= 1'b1;
          #CLK_SPI_PER r_sck <= 1'b0;
        end
        if (i == width-1)
        r_mosi <= 1'b0;
      end
    end
  endtask

    // Task generate data for test transmitter
  task load_tx_data;
    input [width-1:0] i_data_tx;
    begin
      if (r_ss_n == 0) begin
        #CLK_SPI_PER r_ss_n  <= 1'b1;
      end

      #CLK_SPI_PER r_tx_data <= i_data_tx;
      #CLK_SPI_PER r_ss_n    <= 1'b0;
      #CLK_SPI_PER;
    end
  endtask

    initial begin
        $dumpfile("top_level_tb.vcd");
        $dumpvars(0, top_level_tb);

        // Initialize signals
        r_clk        <= 1'b0;
        r_sck        <= 1'b0;
        r_reset      <= 1'b1;
        r_rst        <= 1'b1;
        r_mosi       <= 1'b0;
        r_ss_n       <= 1'b0;
        r_tx_data    <= 'h00;

        // Reset sequence
        #100 r_rst   <= 1'b0;
        #100 r_reset <= 1'b0;

        // Test sequence
        // Send first data to SPI
        receive_send_data('d50); //50%
        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;

        #200_000
        // Load and send next data
        //load_tx_data('d80);
        receive_send_data('d64); //64%
        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;

        #200_000
        //load_tx_data('h4E);
        receive_send_data('d80); //80%
        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;


        #200_000
        //load_tx_data('h4E);
        receive_send_data('d30); //30%
        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;

        #200_000
        //load_tx_data('h4E);
        receive_send_data('d10); //10%
        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;

        #200_000
        //load_tx_data('hFE);
        receive_send_data('hd20);//20%

        #100 r_reset <= 1'b1;
        #100 r_reset <= 1'b0;

        // Finish the simulation
        #100 $finish;
        
    end
endmodule

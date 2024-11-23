
`timescale 1ns / 1ps

module spi_slave_tb();
  localparam CLK_PER     = 10;
  localparam CLK_SPI_PER = 100;

  integer i              = 0;
//Parameters
  parameter CPOL  = 1'b0;
  parameter CPHA  = 1'b0;
  parameter WIDTH = 8;
  parameter LSB   = 1'b0;
//Inputs
  reg              r_clk     = 1'b0;
  reg              r_rst     = 1'b1;
  reg              r_sck     = 1'b0;
  reg              r_mosi    = 1'b0;
  reg              r_ss_n    = 1'b0;
  reg              r_reset   = 1'b0;
  reg [WIDTH-1:0]  r_tx_data = 'h0000;
//Outputs
  wire             w_miso;
  wire             w_miso_oe;
  wire [WIDTH-1:0] w_rx_data;
  wire             w_tx_int;
  wire             w_rx_int;

// Module SPI slave (Serial Peripheral Interface) is a 4-wire synchronous serial communication interface.
  spi_slave #(
    .CPOL  (CPOL ),
    .CPHA  (CPHA ),
    .WIDTH (WIDTH),
    .LSB   (LSB  )
  ) dut (
    .i_clk     (r_clk    ),
    .i_rst     (r_rst    ),
    .i_sck     (r_sck    ),
    .i_mosi    (r_mosi   ),
    .i_ss_n    (r_ss_n   ),
    .o_miso    (w_miso   ),
    .o_miso_oe (w_miso_oe),
    .i_reset   (r_reset  ),
    .i_tx_data (r_tx_data),
    .o_tx_int  (w_tx_int ),
    .o_rx_int  (w_rx_int ),
    .o_rx_data (w_rx_data)

  );

  always #(CLK_PER/2)
    r_clk <= ~r_clk;

  // Task generate data for test receiver
  task receive_send_data;
    input [WIDTH-1:0] i_data_rx;
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
      for (i = 0; i <= WIDTH - 1; i = i + 1) begin

        r_mosi = i_data_rx[WIDTH-1 - i];
        if ((CPOL ^ CPHA) == 1) begin
          #CLK_SPI_PER r_sck <= 1'b0;
          #CLK_SPI_PER r_sck <= 1'b1;
        end else begin
          #CLK_SPI_PER r_sck <= 1'b1;
          #CLK_SPI_PER r_sck <= 1'b0;
        end
        if (i == WIDTH-1)
        r_mosi <= 1'b0;
      end
    end
  endtask

  // Task generate data for test transmitter
  task load_tx_data;
    input [WIDTH-1:0] i_data_tx;
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
    $dumpfile("spi_slave_tb.vcd");
    $dumpvars(0, spi_slave_tb);

    r_clk        <= 1'b0;
    r_sck        <= 1'b0;
    r_reset      <= 1'b1;
    r_rst        <= 1'b1;
    r_mosi       <= 1'b0;
    r_ss_n       <= 1'b0;
    r_tx_data    <= 'h00;
    #100 r_rst   <= 1'b0;
    #100 r_reset <= 1'b0;

    receive_send_data('hAFCD);

    #100 r_reset <= 1'b1;
    #100 r_reset <= 1'b0;

    load_tx_data('hDE6A);
    receive_send_data('h0000);
    #100 r_reset <= 1'b1;
    #100 r_reset <= 1'b0;

    load_tx_data('h4EFB);
    receive_send_data('h6C8E);
    #100 r_reset <= 1'b1;
    #100 r_reset <= 1'b0;

    load_tx_data('hFE3A);
    receive_send_data('h6C8E);
    receive_send_data('h6C8E);

    #100 r_reset <= 1'b1;
    #100 r_reset <= 1'b0;

    #100 $finish;

  end

endmodule

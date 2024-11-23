
`timescale 1ns / 1ps

module spi_slave #(

  parameter CPOL   = 1'b0,  // When one, polarity is low, otherwise polarity is high (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  parameter CPHA   = 1'b0,  // When one, sampling occurs at falling edge, otherwise at rising edge of non-inverted clock (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  parameter WIDTH  = 8,     // The width of the input and output data buses (Type - Decimal, Default value = 8, Min value = 8, Max value = 64)
  parameter LSB    = 1'b0   // When one, data starts from LSB, otherwise data starts from MSB (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
) (
// common port
  input                  i_clk,         // input clock domain signal
  input                  i_rst,         // input reset signal
// interface port
  input                  i_sck,         // input spi clock signal
  input                  i_mosi,        // input master output slave input signal
  input                  i_ss_n,        // input slave select signal
  output reg             o_miso,        // output master input slave output signal
  output reg             o_miso_oe,     // output miso enable output signal
// internal port
  input                  i_reset,       // input registers initialization signal
  input      [WIDTH-1:0] i_tx_data,     // input data bus
  output reg             o_tx_int,      // output data transfer load interrupt signal

  output reg             o_rx_int,      // output data receive interrupt signal
  output reg [WIDTH-1:0] o_rx_data      // output data bus
);

  reg         [WIDTH-1:0] r_shift_miso;
  reg         [WIDTH-1:0] r_shift_mosi;
  reg [$clog2(WIDTH)-1:0] r_rx_counter;

  reg [1:0] r_ss_n_old;
  reg [1:0] r_sck_old;

  // Slave select negative synchronizer
  always @(posedge i_clk) begin
    if (i_rst)
      r_ss_n_old <= 2'b11;
    else begin
      r_ss_n_old[0] <= i_ss_n;
      r_ss_n_old[1] <= r_ss_n_old[0];
    end

  end

  // SPI clock negative synchronizer
  always @(posedge i_clk) begin
    if (i_rst)
      r_sck_old <= 2'b00;
    else begin
      r_sck_old[0] <= i_sck;
      r_sck_old[1] <= r_sck_old[0];
    end
  end

  // SPI data receiver
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_rx_counter <= 'h00;
      r_shift_mosi <= 'h00;
      o_rx_int     <= 1'b0;
      o_rx_data    <= 'h00;
    end else if (i_reset) begin
      r_rx_counter <= 'h00;

      r_shift_mosi <= 'h00;
      o_rx_int     <= 1'b0;
      o_rx_data    <= 'h00;
    end else if (r_ss_n_old == 2'b11) begin
      r_rx_counter <= 'h00;
      r_shift_mosi <= 'h00;
      o_rx_int     <= 1'b0;
    end else if (r_ss_n_old == 2'b00) begin
      if ((CPOL ^ CPHA) == 1) begin
        if (r_sck_old == 2'b10) begin
          r_shift_mosi   <= {r_shift_mosi[WIDTH-2:0], i_mosi};
          if (r_rx_counter == WIDTH - 1) begin
            r_rx_counter <= 'h0;
            o_rx_data    <= {r_shift_mosi[WIDTH-2:0], i_mosi};
            o_rx_int     <= 1'b1;
          end else begin
            r_rx_counter <= r_rx_counter + 1;
            o_rx_int     <= 1'b0;
          end

        end
      end else if ((CPOL ^ CPHA) == 0) begin
        if (r_sck_old == 2'b01) begin
          r_shift_mosi   <= {r_shift_mosi[WIDTH-2:0], i_mosi};
          if (r_rx_counter == WIDTH - 1) begin
            r_rx_counter <= 'h0;
            o_rx_data    <= {r_shift_mosi[WIDTH-2:0], i_mosi};
            o_rx_int     <= 1'b1;
          end else begin
            r_rx_counter <= r_rx_counter + 1;
            o_rx_int     <= 1'b0;
          end
        end
      end
    end
  end

  // SPI data transmitter
  always @(posedge i_clk) begin

    if (i_rst) begin
      o_tx_int     <= 1'b0;
      o_miso       <= 1'b0;
      o_miso_oe    <= 1'b0;
      r_shift_miso <= 'h00;
    end else if (i_reset) begin
      o_tx_int     <= 1'b0;
      o_miso       <= 1'b0;
      o_miso_oe    <= 1'b0;
      r_shift_miso <= 'h00;
    end else if (r_ss_n_old == 2'b11) begin
      o_tx_int     <= 1'b0;
      o_miso       <= 1'b0;
      o_miso_oe    <= 1'b0;
      r_shift_miso <= 'h00;
    end else if (r_ss_n_old == 2'b10) begin
      r_shift_miso <= i_tx_data;
      o_tx_int     <= 1'b1;
      o_miso_oe    <= 1'b1;
      if (LSB) begin
        o_miso     <= i_tx_data[0];

      end else begin
        o_miso     <= i_tx_data[WIDTH-1];
      end
    end else if (r_ss_n_old == 2'b00) begin
      o_miso_oe    <= 1'b1;
      if ((CPOL ^ CPHA) == 1) begin
        if (r_sck_old == 2'b01) begin
          o_tx_int <= 1'b0;
          if (LSB) begin
            o_miso <= r_shift_miso[r_rx_counter];
          end else begin
            o_miso <= r_shift_miso[(WIDTH-1) - r_rx_counter];
          end
        end
      end else begin
        if (r_sck_old == 2'b10) begin
          o_tx_int <= 1'b0;
          if (LSB) begin
            o_miso <= 

r_shift_miso[r_rx_counter];
          end else begin
            o_miso <= r_shift_miso[(WIDTH-1) - r_rx_counter];
          end
        end
      end
    end
  end

endmodule

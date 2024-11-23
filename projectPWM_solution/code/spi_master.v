
`timescale 1ns / 1ps

module spi_master #(
  parameter CPOL         = 1'b0,          // When one, polarity is low, otherwise polarity is high (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  parameter CPHA         = 1'b0,          // When one, sampling occurs at falling edge, otherwise at rising edge of non-inverted clock (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)
  parameter WIDTH        = 8,             // The width of the input and output data buses (Type - Decimal, Default value = 8, Min value = 8, Max value = 64)
  parameter LSB          = 1'b0,          // When one, data starts from LSB, otherwise data starts from MSB (Type - Boolean, Default value = 1'b0, Min value = 1'b0, Max value = 1'b1)

  parameter BAUD_RATE    = 8              // The division value of input domain clock signal (Type - Decimal, Default value = 8, Value = [8, 16, 32, 64, 128, 256])
) (
// common port
  input                  i_clk,           // input clock domain signal
  input                  i_rst,           // input reset signal
// interface port
  input                  i_miso,          // input master input slave output signal
  output reg             o_sck,           // output spi clock signal
  output reg             o_mosi,          // output master output slave input signal
  output reg             o_ss_n,          // output slave select signal
// internal port
  input                  i_reset,         // input registers initialization signal
  input                  i_ss_n_en,       // input slave select enable signal
  input                  i_tx_data_valid, // input transmit data valid signal
  input      [WIDTH-1:0] i_tx_data,       // input data bus
  output reg             o_tx_int,        // output data transfer load interrupt signal
  output reg [WIDTH-1:0] o_rx_data,       // output data bus
  output reg             o_rx_int         // output data receive interrupt signal

);

  reg             [WIDTH-1:0] r_shift_miso;
  reg             [WIDTH-1:0] r_shift_mosi;
  reg     [$clog2(WIDTH)-1:0] r_rx_counter;
  reg [$clog2(BAUD_RATE)-1:0] r_baud_counter;

  reg                         r_tx_valid;
  reg                   [3:0] r_ss_n_state;

  // SPI slave select control
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_ss_n_state <= 'h0;
      o_ss_n       <= 1'b1;
    end else if (i_reset) begin
      r_ss_n_state <= 'h0;
      o_ss_n       <= 1'b1;
    end else begin
      o_ss_n          <= ~i_ss_n_en;
      r_ss_n_state[0] <= i_ss_n_en;
      r_ss_n_state[1] <= r_ss_n_state[0];
      r_ss_n_state[2] <= r_ss_n_state[1];
      r_ss_n_state[3] <= r_ss_n_state[2];
    end
  end

  // SPI one bit period

  always @(posedge i_clk) begin
    if (i_rst) begin
      o_sck          <= CPOL;
      r_baud_counter <= 0;
    end else if (i_reset) begin
      o_sck          <= CPOL;
      r_baud_counter <= 0;
    end else if (r_ss_n_state != 4'b1111) begin
      o_sck          <= CPOL;
      r_baud_counter <= 0;
    end else begin 
      r_baud_counter <= r_baud_counter + 1;
      if (r_baud_counter == BAUD_RATE / 2)
        o_sck <= ~o_sck;
      else if (r_baud_counter == 0)
        o_sck <= ~o_sck;
    end
  end

  // SPI data receiver

  always @(posedge i_clk) begin
    if (i_rst) begin
      o_rx_int     <= 1'b0;
      o_rx_data    <= 'h0;
      r_rx_counter <= 0;
      r_shift_miso <= 0;
    end else if (i_reset) begin
      o_rx_int     <= 1'b0;
      o_rx_data    <= 'h0;
      r_rx_counter <= 0;
      r_shift_miso <= 0;
    end else if (r_ss_n_state != 4'b1111) begin
      o_rx_int     <= 1'b0;
      r_rx_counter <= 0;
      r_shift_miso <= 0;
    end else begin
      if (CPHA) begin
        if (r_baud_counter == BAUD_RATE / 2) begin
          r_shift_miso <= 

{r_shift_miso[WIDTH-2:0], i_miso};
          if (r_rx_counter == WIDTH-1) begin
            o_rx_data    <= {r_shift_miso[WIDTH-2:0], i_miso};
            r_rx_counter <= 0;
            o_rx_int     <= 1'b1;
          end else begin
            r_rx_counter <= r_rx_counter + 1;
            o_rx_int     <= 1'b0;
          end
        end
      end else begin
        if (r_baud_counter == 0) begin
          r_shift_miso <= {r_shift_miso[WIDTH-2:0], i_miso};
          if (r_rx_counter == WIDTH-1) begin
            o_rx_data    <= {r_shift_miso[WIDTH-2:0], i_miso};
            o_rx_int     <= 1'b1;
            r_rx_counter <= 0;
          end else begin

            r_rx_counter <= r_rx_counter + 1;
            o_rx_int     <= 1'b0;
          end
        end
      end
    end
  end

  // SPI TX synchronizer
  always @(posedge i_clk) begin
    if (i_rst)
      r_tx_valid <= 0;
    else if (i_reset)
      r_tx_valid <= 0;
    else
      r_tx_valid <= i_tx_data_valid;
  end

  // SPI data transmitter
  always @(posedge i_clk) begin
    if (i_rst) begin

      o_tx_int     <= 1'b0;
      o_mosi       <= 1'b0;
      r_shift_mosi <= 0;
    end else if (i_reset) begin
      o_tx_int     <= 1'b0;
      o_mosi       <= 1'b0;
      r_shift_mosi <= 0;
    end else if (o_ss_n) begin
      o_tx_int     <= 1'b0;
      o_mosi       <= 1'b0;
      r_shift_mosi <= 0;
    end else if (r_ss_n_state == 4'b0011) begin
      if (r_tx_valid) begin
        o_tx_int     <= 1'b1;
        r_shift_mosi <= i_tx_data;
        if (LSB) begin
          o_mosi <= i_tx_data[0];
        end else begin
          o_mosi <= i_tx_data[WIDTH-1];
        end

      end
    end else if (r_ss_n_state == 4'b1111) begin
      if (CPHA) begin
        if (r_baud_counter == 0) begin
          if ({o_tx_int, o_rx_int} == 2'b01) begin
            if (r_tx_valid) begin
              o_tx_int     <= 1'b1;
              r_shift_mosi <= i_tx_data;
              if (LSB) begin
                o_mosi <= i_tx_data[0];
              end else begin
                o_mosi <= i_tx_data[WIDTH-1];
              end
            end else begin
              o_tx_int <= 1'b0;
              if (LSB) begin
                o_mosi <= r_shift_mosi[r_rx_counter];
              end else begin
                o_mosi <= 

r_shift_mosi[(WIDTH-1) - r_rx_counter];
              end
            end
          end else begin
            o_tx_int <= 1'b0;
            if (LSB) begin
              o_mosi <= r_shift_mosi[r_rx_counter];
            end else begin
              o_mosi <= r_shift_mosi[(WIDTH-1) - r_rx_counter];
            end
          end
        end
      end else begin
        if (r_baud_counter == BAUD_RATE / 2) begin
          if ({o_tx_int, o_rx_int} == 2'b01) begin
            if (r_tx_valid) begin
              o_tx_int     <= 1'b1;
              r_shift_mosi <= i_tx_data;

              if (LSB) begin
                o_mosi <= i_tx_data[0];
              end else begin
                o_mosi <= i_tx_data[WIDTH-1];
              end
            end else begin
              o_tx_int <= 1'b0;
              if (LSB) begin
                o_mosi <= r_shift_mosi[r_rx_counter];
              end else begin
                o_mosi <= r_shift_mosi[(WIDTH-1) - r_rx_counter];
              end
            end
          end else begin
            o_tx_int <= 1'b0;
            if (LSB) begin
              o_mosi <= r_shift_mosi[r_rx_counter];
            end else begin

              o_mosi <= r_shift_mosi[(WIDTH-1) - r_rx_counter];
            end
          end
        end
      end
    end
  end

endmodule

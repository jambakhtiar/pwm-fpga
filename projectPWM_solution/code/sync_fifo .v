
`timescale 1ns/1ps

module sync_fifo #(
  parameter WIDTH = 8, // The width of the bus or number of wires dedicated (Type - Decimal, Default value = 8, Min value = 1, Max value = 63)
  parameter DEPTH = 8  // The depth of FIFO (Type - Decimal, Default value = 8, Min value = 1, Max value = 63)
) (
  input                  i_clk,       // input clock signal
  input                  i_rst,       // input reset signal

  input      [WIDTH-1:0] i_fifo,      // input data signal
  input                  i_we,        // write enable
  input                  i_re,        // read enable
  output reg [WIDTH-1:0] o_fifo,      // output data signal
  output                 o_fifo_full, // signal that indicates that FIFO is full
  output                 o_fifo_empty // signal that indicates that FIFO is empty
);

  reg [WIDTH-1:0] r_fifo [DEPTH-1:0];
  reg [$clog2(DEPTH)-1:0] r_write_pointer;
  reg [$clog2(DEPTH)-1:0] r_read_pointer;
  reg   [$clog2(DEPTH):0] r_count;

  // counter usage data in fifo
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_count <= 'h0;

    end else begin
      case ({i_we, i_re})
        2'b00:   r_count <= r_count;
        2'b01:   r_count <= r_count - 1;
        2'b10:   r_count <= r_count + 1;
        2'b11:   r_count <= r_count;
        default: r_count <= r_count;
      endcase
    end
  end

  // write data to fifo
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_write_pointer <= 'h0;
    end else begin
      if (i_we) begin
        r_fifo[r_write_pointer] <= i_fifo;
        r_write_pointer         <= r_write_pointer + 1;
      end

    end
  end

  // read data from fifo
  always @(posedge i_clk) begin
    if (i_rst) begin
      r_read_pointer <= 'h0;
    end else begin
      if (i_re) begin
        o_fifo         <= r_fifo[r_read_pointer];
        r_read_pointer <= r_read_pointer + 1;
      end
    end
  end

  // controlling fifo state full/empty
  assign o_fifo_full  = (r_count == DEPTH) ? 1'b1 : 1'b0;
  assign o_fifo_empty = (r_count == 0) ? 1'b1 : 1'b0;

endmodule





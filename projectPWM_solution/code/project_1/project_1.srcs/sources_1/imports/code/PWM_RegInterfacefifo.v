
module PWM_RegInterfacefifo 
#(parameter WIDTH = 8)
(
  input                  i_clk,
  input                  i_rst,
  input      [WIDTH-1:0] i_duty_cycle,      // New duty cycle value
  input                  i_duty_cycle_we,   // Write enable for duty cycle FIFO
  input      [WIDTH-1:0] i_switch_freq,     // New switching frequency value
  input                  i_switch_freq_we,  // Write enable for switching frequency FIFO
  input                  i_period_start,    // Signal indicating start of period
  output reg [WIDTH:0] o_duty_cycle,      // Current duty cycle
  output reg [WIDTH-1:0] o_switch_freq,     // Current switching frequency
  output                 o_duty_cycle_ready, // FIFO ready for duty cycle
  output                 o_switch_freq_ready, // FIFO ready for switching frequency
  output reg             o_duty_cycle_done,  // Update done for duty cycle
  output reg             o_switch_freq_done  // Update done for switching frequency

);

  wire [WIDTH-1:0] fifo_duty_cycle_out;
  wire fifo_duty_cycle_empty;
  wire [WIDTH-1:0] fifo_switch_freq_out;
  wire fifo_switch_freq_empty;

  // Instantiate FIFOs
  sync_fifo #(.WIDTH(WIDTH), .DEPTH(8)) duty_cycle_fifo (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo(i_duty_cycle),
    .i_we(i_duty_cycle_we),
    .i_re(i_period_start),
    .o_fifo(fifo_duty_cycle_out),
    .o_fifo_full(),
    .o_fifo_empty(fifo_duty_cycle_empty)
  );

  sync_fifo #(.WIDTH(WIDTH), .DEPTH(8)) switch_freq_fifo (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fifo(i_switch_freq),
    .i_we(i_switch_freq_we),
    .i_re(i_period_start),
    .o_fifo(fifo_switch_freq_out),
    .o_fifo_full(),
    .o_fifo_empty(fifo_switch_freq_empty)
  );

  assign o_duty_cycle_ready = !fifo_duty_cycle_empty;
  assign o_switch_freq_ready = !fifo_switch_freq_empty;

  // Update values at the start of each period
  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin

      o_duty_cycle  <= 'h0;
      o_switch_freq <= 'h0;
      o_duty_cycle_done <= 1'b0;
      o_switch_freq_done <= 1'b0;
    end else begin
      o_duty_cycle_done <= 1'b0;
      o_switch_freq_done <= 1'b0;
      if (i_period_start) begin
        if (!fifo_duty_cycle_empty) begin
          o_duty_cycle <= fifo_duty_cycle_out;
          o_duty_cycle_done <= 1'b1;
        end
        if (!fifo_switch_freq_empty) begin
          o_switch_freq <= fifo_switch_freq_out;
          o_switch_freq_done <= 1'b1;
        end
      end
    end
  end

endmodule

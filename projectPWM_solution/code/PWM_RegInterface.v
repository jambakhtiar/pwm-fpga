module PWM_RegInterface 
#(parameter R = 8)
(
  input                  i_clk,
  input                  i_rst,
  input      [R-1:0] i_duty_cycle,      // New duty cycle value
  input                  i_duty_cycle_we,   // Write enable for duty cycle
  input      [R-1:0] i_switch_freq,     // New switching frequency value
  input                  i_switch_freq_we,  // Write enable for switching frequency
  output reg [R-1:0] o_duty_cycle,      // Current duty cycle
  output reg [R-1:0] o_switch_freq      // Current switching frequency
);

  // Registers to hold current values
  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin

      o_duty_cycle  <= 'h0;
      o_switch_freq <= 'h0;
    end else begin
      if (i_duty_cycle_we) begin
        o_duty_cycle <= i_duty_cycle;
      end
      if (i_switch_freq_we) begin
        o_switch_freq <= i_switch_freq;
      end
    end
  end

endmodule

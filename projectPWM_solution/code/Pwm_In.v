
// Custom Module

module Pwm_In
    #(parameter R = 8, TimerBits = 15)(
    input clk,
    input reset_n,
    input [R-1:0] duty, // Control the Duty Cycle
    input [TimerBits - 1:0] Final_Value, // Control the switching frequency

    input ready, // Signal indicating a pending write
    output reg done, // Signal indicating the update is in effect
    output pwm_out
    );

    reg [R:0] duty_reg;
    reg [R - 1:0] Q_Next, Q_Reg;
    reg D_Reg;
    reg D_Next;
    wire step;

    // Up Counter 
    always @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        begin
            Q_Reg <= {R{1'b1}};
            D_Reg <= 1'b0;

            duty_reg <= 'b0;
            done <= 1'b0;
        end
        else
        begin
            if (step)
            begin
                Q_Reg <= Q_Next;
                D_Reg <= D_Next;
            end

            if ((Q_Next == 0) && step && ready) // Update duty_reg only when ready signal is high
            begin
                duty_reg <= duty; // load new duty
                done <= 1'b1; // Indicate the update is in effect
            end
            else
            begin

                done <= 1'b0; // Reset done signal otherwise
            end
        end
    end

    // Next state logic
    always @*
    begin
        Q_Next = Q_Reg + 1;
        D_Next = (Q_Reg < duty_reg);
    end
    
    assign pwm_out = D_Reg;

    // Prescalar Timer
    Timer_In #(.Bits(TimerBits)) timer0 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(1'b1),
        .Final_Value(Final_Value),

        .done(step)
    );

endmodule

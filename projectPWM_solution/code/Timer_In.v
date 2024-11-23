
// Custom Module

module Timer_In
    #(parameter Bits = 4)(
    input clk,
    input reset_n, 
    input enable,
    input [Bits - 1:0] Final_Value,
    output done
    );
    
    reg [Bits - 1:0] Q_Reg, Q_Next;
    

    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
            Q_Reg <= 'b0;
        else if (enable)
            Q_Reg <= Q_Next;
        else
            Q_Reg <= Q_Reg;
    end
    
    // Next State Logic
    assign done = Q_Reg == Final_Value;
    
    always @(*)
        Q_Next = done? 'b0: Q_Reg + 1;
        
endmodule


// Custom testbench

`default_nettype none

module PwmIn_tb;

    // R stands for Bit Resolution
    localparam R = 8;
    localparam Timer_Bits = 8;
    
    reg clk, reset_n;
    reg [R:0] duty;
    reg [Timer_Bits - 1:0] Final_Value;
    reg ready;
    wire done;

    wire pwm_out;

    // Instantiate module under test    
    Pwm_In #(.R(R), .TimerBits(Timer_Bits)) uut (
        .clk(clk),
        .reset_n(reset_n),
        .duty(duty),
        .Final_Value(Final_Value),
        .ready(ready),
        .done(done),
        .pwm_out(pwm_out)
    );
    localparam T = 10;
    // Timer
    initial begin
        #(7 * 2**R * T * 200) $stop;
   end 
    // Generate stimuli
    
    // Generating a clk signal

    
    always
    begin
        clk = 1'b0;
        #(T / 2);
        clk = 1'b1;
        #(T / 2);
    end
    
    initial
    begin
        $dumpfile("PwmIn_tb.vcd");
        $dumpvars(0, PwmIn_tb);
        
        // Issue a quick reset for 2 ns
        reset_n = 1'b0;
        ready = 1'b0;
        #2  
        reset_n = 1'b1;
        duty = 0.25 * (2**R);
        Final_Value = 8'd35;

        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(2 * 2**R * (Final_Value + 1)) @(negedge clk);
                       
        duty = 0.5 * (2**R);
        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(2 * 2**R * (Final_Value + 1)) @(negedge clk);
   
        duty = 0.75 * (2**R);
        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(2 * 2**R * (Final_Value + 1)) 

@(negedge clk);

        duty = 0.0 * (2**R);
        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(2 * 2**R * (Final_Value + 1)) @(negedge clk);

        duty = 1.0 * (2**R);
        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(2 * 2**R * (Final_Value + 1)) @(negedge clk);

        duty = 0;
        ready = 1'b1;
        @(posedge done); // Wait for done signal to assert
        ready = 1'b0;
        repeat(256 * Final_Value) @(negedge clk);        
        $finish;
    end    
        
endmodule

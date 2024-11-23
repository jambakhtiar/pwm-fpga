
`timescale 1ns / 1ps

module top_level_tb;

    // Test bench signals
    reg clk;
    reg rst;
    wire pwm_out_0;
    wire pwm_out_1;
    wire pwm_out_2;
    wire pwm_out_3;

    // Instantiate the top level module
    top_level uut (
        .clk(clk),
        .rst(rst),
        .pwm_out_0(pwm_out_0),
        .pwm_out_1(pwm_out_1),
        .pwm_out_2(pwm_out_2),
        .pwm_out_3(pwm_out_3)
    );


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // SPI signals
    reg [15:0] spi_tx_data;
    wire [15:0] spi_rx_data;
    reg spi_tx_valid;
    wire spi_rx_valid;

    // Simulation control
    initial begin

        // Initialize signals
        spi_tx_data = 16'h0000;
        spi_tx_valid = 0;

        // Wait for reset de-assertion
        #30;

        // Test Case 1: Write to FIFO and check PWM output
        spi_tx_data = 16'h0A1E; // Duty cycle: 10, Frequency: 30
        spi_tx_valid = 1;
        #10 spi_tx_valid = 0;

        // Wait and check PWM outputs
        #100;

        // Test Case 2: Write to FIFO and check PWM output
        spi_tx_data = 16'h140A; // Duty cycle: 20, Frequency: 10

        spi_tx_valid = 1;
        #10 spi_tx_valid = 0;

        // Wait and check PWM outputs
        #100;

        // Test Case 3: Write to FIFO and check PWM output
        spi_tx_data = 16'h1E14; // Duty cycle: 30, Frequency: 20
        spi_tx_valid = 1;
        #10 spi_tx_valid = 0;

        // Wait and check PWM outputs
        #100;

        // Stop simulation
        $stop;
    end

    // SPI Master simulation

    always @(posedge clk) begin
        if (spi_tx_valid) begin
            // Simulate SPI Master sending data to Slave
            uut.spi_master.i_tx_data = spi_tx_data;
            uut.spi_master.i_tx_data_valid = 1;
        end else begin
            uut.spi_master.i_tx_data_valid = 0;
        end
    end

    // FIFO read enable
    assign uut.fifo_read_enable = ~uut.fifo_empty;

endmodule

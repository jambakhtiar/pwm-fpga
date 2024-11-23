
`timescale 1ns / 1ps

module top_level (
    input               clk,            // System clock
    input               rst,            // System reset
    output              pwm_out_0,      // PWM output for channel 0
    output              pwm_out_1,      // PWM output for channel 1
    output              pwm_out_2,      // PWM output for channel 2
    output              pwm_out_3       // PWM output for channel 3
);

    // SPI signals
    wire                spi_master_sck;
    wire                spi_master_mosi;
    wire                spi_master_ss_n;
    wire                spi_slave_miso;
    wire                spi_slave_miso_oe;

    wire                spi_slave_reset;
    wire                spi_slave_tx_int;
    wire                spi_slave_rx_int;
    wire [15:0]         spi_slave_rx_data;

    // FIFO signals
    wire [15:0]         fifo_data;
    wire                fifo_full;
    wire                fifo_empty;
    reg                fifo_read_enable;

    // PWM signals
    wire [15:0]         duty_cycle_0;
    wire [15:0]         frequency_0;
    wire                pwm0_done;
    //wire                pwm_out_0;

    wire [15:0]         duty_cycle_1;
    wire [15:0]         frequency_1;
    wire                pwm1_done;
   // wire                pwm_out_1;


    wire [15:0]         duty_cycle_2;
    wire [15:0]         frequency_2;
    wire                pwm2_done;
    //wire                pwm_out_2;

    wire [15:0]         duty_cycle_3;
    wire [15:0]         frequency_3;
    wire                pwm3_done;
    //wire                pwm_out_3;

    // Instantiate SPI Master
    spi_master master (
        .i_clk(clk),
        .i_rst(rst),
        .i_miso(spi_slave_miso),
        .o_sck(spi_master_sck),
        .o_mosi(spi_master_mosi),
        .o_ss_n(spi_master_ss_n),
        .i_reset(spi_slave_reset),
        .i_ss_n_en(1'b1), // Enable slave select

        .i_tx_data_valid(1'b1), // Assume data valid
        .i_tx_data(16'h0000), // Dummy data
        .o_tx_int(), // Unused
        .o_rx_data(spi_slave_rx_data),
        .o_rx_int(spi_slave_rx_int)
    );

    // Instantiate SPI Slave
    spi_slave slave (
        .i_clk(clk),
        .i_rst(rst),
        .i_sck(spi_master_sck),
        .i_mosi(spi_master_mosi),
        .i_ss_n(spi_master_ss_n),
        .o_miso(spi_slave_miso),
        .o_miso_oe(spi_slave_miso_oe),
        .i_reset(spi_slave_reset),
        .i_tx_data(spi_slave_rx_data),
        .o_tx_int(spi_slave_tx_int),
        .o_rx_int(spi_slave_rx_int),

        .o_rx_data(spi_slave_rx_data)
    );

    // Instantiate FIFO
    sync_fifo #(
        .WIDTH(16),
        .DEPTH(16)
    ) fifo (
        .i_clk(clk),
        .i_rst(rst),
        .i_fifo(spi_slave_rx_data),
        .i_we(spi_slave_rx_int),
        .i_re(fifo_read_enable),
        .o_fifo(fifo_data),
        .o_fifo_full(fifo_full),
        .o_fifo_empty(fifo_empty)
    );

    // Control logic to handle FIFO data
    reg [15:0] duty_cycle [3:0];
    reg [15:0] frequency [3:0];

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty_cycle[0] <= 16'h0000;
            frequency[0] <= 16'h0000;
            duty_cycle[1] <= 16'h0000;
            frequency[1] <= 16'h0000;
            duty_cycle[2] <= 16'h0000;
            frequency[2] <= 16'h0000;
            duty_cycle[3] <= 16'h0000;
            frequency[3] <= 16'h0000;
        end else if (!fifo_empty) begin
            fifo_read_enable <= 1'b1;
            // Assuming FIFO data is formatted [DutyCycle, Frequency]
            duty_cycle[0] <= fifo_data[15:8];
            frequency[0] <= fifo_data[7:0];
            // Implement logic to assign FIFO data to other channels as needed
        end else begin

            fifo_read_enable <= 1'b0;
        end
    end

    // Instantiate PWM channels
    Pwm_In #(
        .R(15),
        .TimerBits(15)
    ) pwm0 (
        .clk(clk),
        .reset_n(~rst),
        .duty(duty_cycle[0]),
        .Final_Value(frequency[0]),
        .ready(~fifo_empty),
        .done(pwm0_done),
        .pwm_out(pwm_out_0)
    );


    Pwm_In #(
        .R(15),
        .TimerBits(15)

    ) pwm1 (
        .clk(clk),
        .reset_n(~rst),
        .duty(duty_cycle[1]),
        .Final_Value(frequency[1]),
        .ready(~fifo_empty),
        .done(pwm1_done),
        .pwm_out(pwm_out_1)
    );

    Pwm_In #(
        .R(15),
        .TimerBits(15)
    ) pwm2 (
        .clk(clk),
        .reset_n(~rst),
        .duty(duty_cycle[2]),
        .Final_Value(frequency[2]),
        .ready(~fifo_empty),
        .done(pwm2_done),
        .pwm_out(pwm_out_2)

    );

    Pwm_In #(
        .R(15),
        .TimerBits(15)
    ) pwm3 (
        .clk(clk),
        .reset_n(~rst),
        .duty(duty_cycle[3]),
        .Final_Value(frequency[3]),
        .ready(~fifo_empty),
        .done(pwm3_done),
        .pwm_out(pwm_out_3)
    );

endmodule

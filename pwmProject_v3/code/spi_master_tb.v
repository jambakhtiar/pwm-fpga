
`timescale 1ns / 1ps

module spi_master_tb();
  localparam CLK_PER = 10;
  integer    i       = 0;
  integer    a       = 0;
//Parameters
  parameter CPOL      = 1'b0;

  parameter CPHA      = 1'b0;
  parameter WIDTH     = 8;
  parameter LSB       = 1'b0;
  parameter BAUD_RATE = 8; //8, 16, 32, 64, 128, 256

//Inputs
  reg             r_clk           = 1'b0;
  reg             r_rst           = 1'b1;
  reg             r_miso          = 1'b0;
  reg             r_ss_n_en       = 1'b0;
  reg             r_tx_data_valid = 1'b0;
  reg             r_reset         = 1'b0;
  reg [WIDTH-1:0] r_tx_data       = 'h00;
//Outputs
  wire             w_sck;
  wire             w_mosi;
  wire             w_ss_n;
  wire [WIDTH-1:0] w_rx_data;
  wire             w_tx_int;
  wire             w_rx_int;


  // Module SPI master one slave (Serial Peripheral Interface) is a 4-wire synchronous serial communication interface.
  spi_master #(
    .CPOL            (CPOL),
    .CPHA            (CPHA),
    .WIDTH           (WIDTH),
    .LSB             (LSB),
    .BAUD_RATE       (BAUD_RATE)
  ) dut (
    .i_clk           (r_clk),
    .i_rst           (r_rst),
    .i_miso          (r_miso),
    .o_sck           (w_sck),
    .o_mosi          (w_mosi),
    .o_ss_n          (w_ss_n),
    .i_reset         (r_reset),
    .i_ss_n_en       (r_ss_n_en),
    .i_tx_data_valid (r_tx_data_valid),

    .i_tx_data       (r_tx_data),
    .o_tx_int        (w_tx_int),
    .o_rx_data       (w_rx_data),
    .o_rx_int        (w_rx_int)
  );

  always #(CLK_PER/2)
    r_clk <= ~r_clk;

  reg     [$clog2(WIDTH)-1:0] r_rx_counter;
  reg [$clog2(BAUD_RATE)-1:0] r_baud_counter;
  reg                   [3:0] r_ss_n_state;

  // SPI slave select control
  always @(posedge r_clk) begin
    if (r_rst) begin
      r_ss_n_state <= 1'b0;
    end else if (r_reset) begin
      r_ss_n_state <= 1'b0;
    end else begin

      r_ss_n_state[0] <= r_ss_n_en;
      r_ss_n_state[1] <= r_ss_n_state[0];
      r_ss_n_state[2] <= r_ss_n_state[1];
      r_ss_n_state[3] <= r_ss_n_state[2];
    end
  end

  // SPI one bit period
  always @(posedge r_clk) begin
    if (r_rst) begin
      r_baud_counter <= 1'b0;
    end else if (r_reset) begin
      r_baud_counter <= 1'b0;
    end else if (r_ss_n_state != 4'b1111) begin
      r_baud_counter <= 1'b0;
    end else begin
      r_baud_counter <= r_baud_counter + 1;
    end
  end

  // Bit counter
  always @(posedge r_clk) begin
    if (r_rst) begin
      r_rx_counter <= 1'b0;
    end else if (r_reset) begin
      r_rx_counter <= 1'b0;
    end else if (r_ss_n_state != 4'b1111) begin
      r_rx_counter <= 1'b0;
    end else begin
      if (CPHA) begin
        if (r_baud_counter == BAUD_RATE / 2) begin
          if (r_rx_counter == WIDTH - 1) begin
            r_rx_counter <= 1'b0;
          end else begin
            r_rx_counter <= r_rx_counter + 1;
          end
        end
      end else begin
        if (r_baud_counter == 0) begin

          if (r_rx_counter == WIDTH - 1) begin
            r_rx_counter <= 1'b0;
          end else begin
            r_rx_counter <= r_rx_counter + 1;
          end
        end
      end
    end
  end

  // Task generate data for test receiver
  task receive_send_data;
    input [WIDTH-1:0] i_data_rx;
    input [WIDTH-1:0] i_data_tx;
    begin
      if (r_ss_n_state != 4'b0000) begin
        r_ss_n_en <= 1'b0;
        #(4 * CLK_PER);
      end
      if (r_tx_data_valid == 0) begin
        r_tx_data_valid <= 1'b1;

        #(2 * CLK_PER);
      end
      r_tx_data <= i_data_tx;
      #(2 * CLK_PER);
      r_ss_n_en <= 1'b1;
      for (a = 0; a != 1; a = 1) begin
        if (w_ss_n == 0) begin
          #((2 * CLK_PER) - 1);
        end else begin
          #1;
        end
      end
      r_miso <= i_data_rx[WIDTH-1];
      if (CPHA) begin
        #CLK_PER;
        for (i = 0; i <= WIDTH - 1; i = i + 1) begin
          #CLK_PER;
          if (r_baud_counter == 0) begin
            r_miso <= i_data_rx[WIDTH-1-i];
          end
        end

      end else begin
        for (i = 1; i <= WIDTH - 1; i = i + 1) begin
          #CLK_PER;
          if (r_baud_counter == BAUD_RATE / 2) begin
            r_miso <= i_data_rx[WIDTH-1-i];
          end
        end
      end
      #(BAUD_RATE * CLK_PER);
      r_miso <= 1'b0;
    end
  endtask

  initial begin
    $dumpfile("spi_master_tb.vcd");
    $dumpvars(0, spi_master_tb);

    r_clk           <= 1'b0;
    r_rst           <= 1'b1;
    r_reset         <= 1'b1;

    r_miso          <= 1'b0;
    r_tx_data       <= 'h0;
    r_ss_n_en       <= 1'b0;
    r_tx_data_valid <= 1'b0;

    #100 r_reset    <= 1'b0;
    #100 r_rst      <= 1'b0;

    #100 receive_send_data('hAAAA,'h5555);
    #((WIDTH * BAUD_RATE * CLK_PER) - CLK_PER);

    r_tx_data_valid <= 1'b0;
    #(WIDTH * BAUD_RATE * CLK_PER);

    r_tx_data       <= 'hB38F;
    #(7*CLK_PER) 
    r_tx_data_valid <= 1'b1;
    #(WIDTH * BAUD_RATE * CLK_PER);

    receive_send_data('h5555,'hAAAA);

    #((WIDTH * BAUD_RATE * CLK_PER) - CLK_PER);

    r_tx_data       <= 'hB38F;
    #(WIDTH * BAUD_RATE * CLK_PER) $finish;
  end

endmodule

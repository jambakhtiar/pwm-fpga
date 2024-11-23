
module sync_fifo_tb;
  //Parameters
  parameter DEPTH = 8;
  parameter WIDTH = 8;
  //Inputs
  reg             r_clk;
  reg             r_rst;
  reg [WIDTH-1:0] r_fifo;
  reg             r_we;
  reg             r_re;
  //Outputs
  wire [WIDTH-1:0] w_fifo;
  wire             w_fifo_full;
  wire             w_fifo_empty;

  integer i;

  sync_fifo #(
    .DEPTH (DEPTH),
    .WIDTH (WIDTH)
  ) dut (
    .i_clk        (r_clk),
    .i_rst        (r_rst),
    .i_we         (r_we),
    .i_re         (r_re),
    .i_fifo       (r_fifo),
    .o_fifo       (w_fifo),
    .o_fifo_full  (w_fifo_full),
    .o_fifo_empty (w_fifo_empty)
  );

  always #10 r_clk = ~r_clk;
  
  initial begin
    $dumpfile ("sync_fifo_tb.vcd");
    $dumpvars (0, sync_fifo_tb);
  
    r_clk  <= 1'b0;

    r_rst  <= 1'b1;
    r_we   <= 1'b0;
    r_re   <= 1'b0;
    r_fifo <= 8'h00;
    #20 
    r_we   <= 1'b1;
    // r_rst = 1, r_we = 1
    for (i = 0; i < DEPTH; i = i + 1) begin
      r_fifo <= i;
      #20;
    end

    #20 r_we <= 1'b0;
        r_re <= 1'b1;
    // r_rst = 1, r_re = 1
    for (i = 0; i < DEPTH; i = i + 1) begin
      r_fifo <= i;
      #20;
    end
    #20 r_re   <= 1'b0;
    #10 r_rst  <= 1'b0;

        r_fifo <= 8'h00;
    #20 r_we   <= 1'b1;
    // r_rst = 0, r_we = 1
    for (i = 0; i < DEPTH; i = i + 1) begin
      r_fifo <= i;
      #20;
    end

    #20
    r_we <= 1'b0;
    r_re <= 1'b1;
    // r_rst = 0, r_re = 1
    for (i = 0; i < DEPTH; i = i + 1) begin
      r_fifo <= i;
      #20;
    end

   #10 $finish;
  end

endmodule
module multiplier_tb;

localparam WIDTH = 8,
           SUBDIV_SIZE = 4,
           CLK_PER = 5,
           TIMEOUT = 32;

logic [WIDTH-1:0] a, b;
logic clk, rst_n, start;

wire [2*WIDTH-1:0] product;
wire done;

multiplier DUT (.*);

initial begin
  clk = 0;
  rst_n = 0;
  start = 0;
  a = 'd0;
  b = 'd0;
end

always #(CLK_PER) clk = ~clk;

initial begin
  $display("Beginning multiplier_tb");
  repeat(2) @(posedge clk);
  rst_n = 'b1;
  @(posedge clk);
  @(negedge clk);

  a = 'd22;
  b = 'd30;
  start = 'b1;

  @(negedge clk);
  start = 'b0;

  fork
    // Intended path
    begin
      wait(done);
      @(posedge clk);
      $display("%d * %d = %d", a, b, product);
    end

    // Kill path
    begin
      repeat(TIMEOUT) @(posedge clk);
      $display("Hit timeout");
    end
  join_any

  repeat(5) @(posedge clk);

  $display("Finishing multiplier_tb");
  $finish();

end

endmodule : multiplier_tb

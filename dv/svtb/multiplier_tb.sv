module top;
  import uvm_pkg::*;
  import multiplier_pkg::*;

  localparam CLK_PER = 5;

  logic clk;
  multiplier_if mul_if(clk);
  multiplier DUT (mul_if.slave_mp);

  initial begin
    clk = 1'b0;
    forever #(CLK_PER) clk = ~clk;
  end

  initial begin
    $dumpvars("dump.vcd");
    $dumpvars(0, top);
  end

  initial begin
    uvm_config_db #(virtual multiplier_if)::set(
      .cntxt(null),
      .inst_name("uvm_test_top.*"),
      .field_name("mul_if"),
      .value(mul_if)
    );

    run_test();
  end
endmodule : top


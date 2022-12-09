// Interface: multiplier_if 
interface multiplier_if(input bit clk);
  logic [7:0] op_a;
  logic [7:0] op_b;
  logic rst_n;
  logic start;
  logic [15:0] product;
  logic done;
 
  // Clocking block: master_cb
  clocking master_cb @(posedge clk);
    default input #1ns output #1ns;
    output op_a, op_b, rst_n, start;
    input product, done;
  endclocking: master_cb

  // Clocking block: slave_cb
  clocking slave_cb @(posedge clk);
    default input #1ns output #1ns;
    input  op_a, op_b, rst_n, start;
    output product, done;
  endclocking: slave_cb

  // Modports
  modport master_mp(input clk, product, done, output op_a, op_b, rst_n, start);
  modport slave_mp(input clk, op_a, op_b, rst_n, start, output product, done);
  modport master_sync_mp(clocking master_cb);
  modport slave_sync_mp(clocking slave_cb);
endinterface : multiplier_if


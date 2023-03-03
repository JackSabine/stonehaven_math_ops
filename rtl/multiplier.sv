module multiplier #(parameter WIDTH=8, parameter SUBDIV_SIZE=4) (multiplier_if.slave_mp mul_if);

localparam A_BITS = $clog2(WIDTH/SUBDIV_SIZE);
localparam B_BITS = $clog2(WIDTH/SUBDIV_SIZE);
localparam SUBDIV_MASK = (1 << SUBDIV_SIZE) - 1;
  
logic [(A_BITS + B_BITS)-1:0] subdiv_counter;
logic [A_BITS-1:0] a_sub_sel;
logic [B_BITS-1:0] b_sub_sel;
logic [SUBDIV_SIZE-1:0] a_sub;
logic [SUBDIV_SIZE-1:0] b_sub;
logic [2*WIDTH-1:0] mul_out;
logic foo;

always_comb begin
  a_sub_sel = A_BITS'(subdiv_counter >> B_BITS);
  b_sub_sel = B_BITS'(subdiv_counter);

  a_sub = mul_if.op_a[(a_sub_sel*SUBDIV_SIZE)+:SUBDIV_SIZE];
  b_sub = mul_if.op_b[(b_sub_sel*SUBDIV_SIZE)+:SUBDIV_SIZE];

  mul_out = (a_sub * b_sub) << (SUBDIV_SIZE * (a_sub_sel + b_sub_sel));
end

always_ff @(posedge mul_if.clk) begin
  if(!mul_if.rst_n) begin
    subdiv_counter <= 'd0;
    mul_if.product <= 'd0;
    mul_if.done <= 'd0;
  end else begin
    if(mul_if.start | (~mul_if.done && subdiv_counter != 'd0)) begin
      {mul_if.done, subdiv_counter} <= subdiv_counter + 1;
      mul_if.product <= mul_if.product + mul_out;
    end 
  end
end

endmodule : multiplier

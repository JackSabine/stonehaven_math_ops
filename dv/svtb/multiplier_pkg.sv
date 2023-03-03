`include "uvm_macros.svh"

package multiplier_pkg;
  import uvm_pkg::*;

  `include "multiplier_transaction.sv"
  `include "multiplier_sequence.sv"
  `include "multiplier_agent.sv"
  `include "multiplier_env.sv"
  `include "multiplier_tests.sv"
endpackage : multiplier_pkg

// multiplier_transaction.sv

class multiplier_transaction extends uvm_sequence_item;
  parameter WIDTH = 8;

  rand int unsigned op_a;
  rand int unsigned op_b;
  int unsigned result;

  constraint bitwidth {
    op_a < 2**WIDTH;
    op_b < 2**WIDTH;
  }

  `uvm_object_utils_begin(multiplier_transaction)
    `uvm_field_int(op_a, UVM_DEFAULT|UVM_DEC)
    `uvm_field_int(op_b, UVM_DEFAULT|UVM_DEC)
    `uvm_field_int(result, UVM_DEFAULT|UVM_DEC)
  `uvm_object_utils_end

  // Function: new
  function new(string name = "multiplier_transaction");
    super.new(name);
  endfunction : new

endclass : multiplier_transaction


// multiplier_transaction.sv

class multiplier_transaction extends uvm_sequence_item;
  `uvm_object_utils(multiplier_transaction)

  parameter WIDTH = 8;

  rand int unsigned op_a;
  rand int unsigned op_b;
  int unsigned result;

  constraint bitwidth {
    op_a < 2**WIDTH;
    op_b < 2**WIDTH;
  }

  // Function: new
  function new(string name = "multiplier_transaction");
    super.new(name);
  endfunction : new

  // Function: do_copy
  virtual function void do_copy(uvm_object rhs);
    multiplier_transaction that;

    if (!$cast(that, rhs)) begin
      `uvm_error(get_name(), "rhs is not a multiplier_transaction")
      return;
    end

    super.do_copy(rhs);
    this.op_a = that.op_a;
    this.op_b = that.op_b;
    this.result = that.result;
  endfunction : do_copy

  // Function: do_compare
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    multiplier_transaction that;

    if (!$cast(that, rhs)) return 0;

    return (super.do_compare(rhs, comparer) &&
            this.op_a == that.op_a &&
            this.op_b == that.op_b &&
            this.result == that.result );
  endfunction : do_compare

  // Function: convert2string
  virtual function string convert2string();
      string s = super.convert2string();
      s = { s, $sformatf( "\nname   : %s", get_name() ) };
      s = { s, $sformatf( "\nop_a   : %s", op_a ) };
      s = { s, $sformatf( "\nop_b   : %s", op_b ) };
      s = { s, $sformatf( "\nresult : %s", result ) };
      return s;
    endfunction : convert2string
endclass : multiplier_transaction

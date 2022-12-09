// Class: multiplier_test
class multiplier_test extends uvm_test;
  `uvm_component_utils(multiplier_test)

  multiplier_env mul_env;

  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Function: build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mul_env = multiplier_env::type_id::create(.name("mul_env"), .parent(this));
  endfunction : build_phase

  // task: main_phase
  task main_phase( uvm_phase phase );
    one_multiply_sequence mul_seq;

    mul_seq = one_multiply_sequence ::type_id::create(.name("mul_seq"));
    assert(mul_seq.randomize());
    `uvm_info( "mul_seq", mul_seq.convert2string(), UVM_NONE )
    mul_seq.set_starting_phase(phase);
    mul_seq.set_automatic_phase_objection(.value( 1 ));
    mul_seq.start(mul_env.mul_agent.mul_seqr);
  endtask : main_phase
  
endclass : multiplier_test


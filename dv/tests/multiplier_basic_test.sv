// Class: multiplier_basic_test
class multiplier_basic_test extends uvm_test;
  `uvm_component_utils(multiplier_basic_test)

  multiplier_env mul_env;
  uvm_table_printer printer;

  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Function: build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mul_env = multiplier_env::type_id::create(.name("mul_env"), .parent(this));

    printer = new;
    printer.knobs.depth = 5;
  endfunction : build_phase

  // Function: end_of_elaboration_phase
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_full_name(), $sformatf("Printing Test Topology:\n%s", this.sprint(printer)), UVM_LOW)
  endfunction : end_of_elaboration_phase

  // Function: start_of_simulation_phase
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_full_name(), {
      "\n",
      "*****************************************\n",
      "*          START OF SIMULATION          *\n",
      "*****************************************"
      }, UVM_LOW)
  endfunction : start_of_simulation_phase

  // Task: main_phase
  task main_phase( uvm_phase phase );
    one_multiply_sequence mul_seq;

    mul_seq = one_multiply_sequence::type_id::create(.name("mul_seq"));
    assert(mul_seq.randomize());
    mul_seq.set_starting_phase(phase);
    mul_seq.set_automatic_phase_objection(.value(1));
    mul_seq.start(mul_env.mul_agent.mul_seqr);
  endtask : main_phase

  // Function: final_phase
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_full_name(), {
      "\n",
      "***************************************\n",
      "*          END OF SIMULATION          *\n",
      "***************************************"
      }, UVM_LOW)
  endfunction : final_phase
  
endclass : multiplier_basic_test


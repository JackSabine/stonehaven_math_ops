// Class: multiplier_sb_subscriber
class multiplier_sb_subscriber extends uvm_subscriber#(multiplier_transaction);
  `uvm_component_utils(multiplier_sb_subscriber)
  
  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  // Function: write
  function void write(multiplier_transaction t);
    if(t.op_a * t.op_b != t.result) begin
      `uvm_error(get_name(), {
        "\n",
        "********************\n",
        "* Incorrect result *\n",
        "********************"
      })
    end else begin
      `uvm_info(get_name(), {
        "\n",
        "******************\n",
        "* Correct result *\n",
        "******************"
      }, UVM_LOW)
    end
    t.print();
  endfunction : write
  
endclass: multiplier_sb_subscriber



// Class: multiplier_env  
class multiplier_env extends uvm_env;
  `uvm_component_utils(multiplier_env)

  multiplier_agent mul_agent;
  multiplier_sb_subscriber mul_sb;
  
  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  // Function: build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mul_agent = multiplier_agent::type_id::create(.name("mul_agent"), .parent(this));
    mul_sb = multiplier_sb_subscriber::type_id::create(.name("mul_sb"), .parent(this));
  endfunction: build_phase
  
  // Function: connect_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    mul_agent.mul_ap.connect(mul_sb.analysis_export);
  endfunction : connect_phase

endclass : multiplier_env


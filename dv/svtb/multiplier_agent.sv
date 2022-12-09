// Typedef: multiplier_sequencer
typedef uvm_sequencer #( multiplier_transaction ) multiplier_sequencer;

// Class: multiplier_driver
class multiplier_driver extends uvm_driver #( multiplier_transaction );
  `uvm_component_utils( multiplier_driver )

  virtual multiplier_if mul_vi;
  
  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Function: build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual multiplier_if)::get(
      .cntxt(this),
      .inst_name(""),
      .field_name("mul_if"),
      .value(mul_vi)
    )) begin
      `uvm_fatal(get_name(), "mul_if not found")
    end	
  endfunction : build_phase

  // Task: main_phase
  task main_phase(uvm_phase phase);
    multiplier_transaction mul_tx;

    forever begin
      seq_item_port.get_next_item(mul_tx);
      @mul_vi.master_cb;
      mul_vi.master_cb.op_a <= mul_tx.op_a;
      mul_vi.master_cb.op_b <= mul_tx.op_b;
      mul_vi.master_cb.start <= 1'b1;
      seq_item_port.item_done();
      @mul_vi.master_cb;
      mul_vi.master_cb.start <= 1'b0;
      phase.drop_objection(.obj(this), .description(get_name()));
    end
  endtask : main_phase
endclass : multiplier_driver

// Class: multiplier_monitor
class multiplier_monitor extends uvm_monitor;
  `uvm_component_utils(multiplier_monitor)

  uvm_analysis_port #(multiplier_transaction) mul_ap;

  virtual multiplier_if mul_vi;

  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual multiplier_if)::get(
      .cntxt(this),
      .inst_name(""),
      .field_name("mul_if"),
      .value(mul_vi)
    )) begin
      `uvm_fatal(get_name(), "mul_if not found")
    end

    mul_ap = new(.name("mul_ap"), .parent(this));
  endfunction : build_phase

  // Task: main_phase
  task main_phase(uvm_phase phase);
    multiplier_transaction mul_tx;

    forever begin
      @mul_vi.slave_cb;
      if (mul_vi.done == 1'b1) begin
        mul_tx.result = mul_vi.master_cb.product;
        mul_ap.write(mul_tx);
        phase.drop_objection(.obj(this), .description(get_name()));
      end

      if (mul_vi.start == 1'b1) begin
        phase.raise_objection(.obj(this), .description(get_name()));
        mul_tx = multiplier_transaction::type_id::create(.name("mul_tx"));
        mul_tx.op_a = mul_vi.slave_cb.op_a;
        mul_tx.op_b = mul_vi.slave_cb.op_b;
      end
    end // forever
  endtask : main_phase
endclass : multiplier_monitor

// CLass: multiplier_agent
class multiplier_agent extends uvm_agent;
  `uvm_component_utils(multiplier_agent)

  uvm_analysis_port #(multiplier_transaction) mul_ap;

  multiplier_sequencer mul_seqr;
  multiplier_driver mul_drvr;
  multiplier_monitor mul_mon;

  // Function: new
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Function: build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mul_ap = new(.name("mul_ap"), .parent(this));
    mul_seqr = multiplier_sequencer::type_id::create(.name("mul_seqr"), .parent(this));
    mul_drvr = multiplier_driver::type_id::create(.name("mul_drvr"), .parent(this));
    mul_mon = multiplier_monitor::type_id::create(.name("mul_mon"), .parent(this));
  endfunction : build_phase

  // Function: connect_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    mul_drvr.seq_item_port.connect(mul_seqr.seq_item_export);
    mul_mon.mul_ap.connect(mul_ap);
  endfunction : connect_phase

endclass : multiplier_agent

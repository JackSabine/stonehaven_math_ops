// Typedef: multiplier_sequencer
typedef uvm_sequencer #(multiplier_transaction) multiplier_sequencer;



// Class: multiplier_driver
class multiplier_driver extends uvm_driver #(multiplier_transaction);
  `uvm_component_utils(multiplier_driver)

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

  // Task: reset_phase
  task reset_phase(uvm_phase phase);
    phase.raise_objection(.obj(this), .description(get_name()));
    mul_vi.master_cb.rst_n <= 1'b1;
    @mul_vi.master_cb;
    mul_vi.master_cb.rst_n <= 1'b0;
    @mul_vi.master_cb;
    mul_vi.master_cb.rst_n <= 1'b1;
    phase.drop_objection(.obj(this), .description(get_name()));
  endtask : reset_phase

  // Task: main_phase
  task main_phase(uvm_phase phase);
    multiplier_transaction mul_tx;

    forever begin
      seq_item_port.get_next_item(mul_tx);
      phase.raise_objection(.obj(this), .description(get_name()));
      @mul_vi.master_cb;
      mul_vi.master_cb.op_a <= mul_tx.op_a;
      mul_vi.master_cb.op_b <= mul_tx.op_b;
      mul_vi.master_cb.start <= 1'b1;
      @mul_vi.master_cb;
      mul_vi.master_cb.start <= 1'b0;
      seq_item_port.item_done();
      phase.drop_objection(.obj(this), .description(get_name()));
    end
  endtask : main_phase

  // Task: shutdown_phase
  task shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);

    phase.raise_objection(.obj(this), .description(get_name()));
    repeat(3) @mul_vi.master_cb;
    phase.drop_objection(.obj(this), .description(get_name()));
  endtask : shutdown_phase

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
    bit tx_in_progress;

    tx_in_progress = 1'b0;

    fork
      forever begin : tx_finisher
        @mul_vi.master_cb;
        if (mul_vi.master_cb.done == 1'b1) begin
          if (tx_in_progress) begin
            mul_tx.result = mul_vi.master_cb.product;
            `uvm_info(get_name(), {"Finishing mul_Tx: ", mul_tx.convert2string()}, UVM_DEBUG)

            mul_ap.write(mul_tx);
            tx_in_progress = 1'b0;
            phase.drop_objection(.obj(this), .description(get_name()));
          end else begin
            `uvm_error(get_name(), "Received done signal before start was sent");
          end
        end
      end

      forever begin : tx_starter
        @mul_vi.slave_cb;
        if (mul_vi.slave_cb.start == 1'b1) begin
          phase.raise_objection(.obj(this), .description(get_name()));
          tx_in_progress = 1'b1;

          mul_tx = multiplier_transaction::type_id::create(.name("mul_tx"));
          mul_tx.op_a = mul_vi.slave_cb.op_a;
          mul_tx.op_b = mul_vi.slave_cb.op_b;
          `uvm_info(get_name(), {"Starting mul_tx: ", mul_tx.convert2string()}, UVM_DEBUG)
        end
      end
    join
  endtask : main_phase
endclass : multiplier_monitor



// Class: multiplier_agent
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


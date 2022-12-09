class one_multiply_sequence extends uvm_sequence#( multiplier_transaction );
  `uvm_object_utils( one_multiply_sequence )
  
  // Function: new
  function new( string name = "one_multiply_sequence" );
    super.new( name );
  endfunction : new

  // Task: body
  task body();
    multiplier_transaction mul_tx;
    mul_tx = multiplier_transaction::type_id::create( .name( "mul_tx" ) );
    start_item( mul_tx );
    assert( mul_tx.randomize() );
    finish_item( mul_tx );
  endtask : body
endclass : one_multiply_sequence

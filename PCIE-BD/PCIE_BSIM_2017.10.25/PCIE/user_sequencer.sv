

class user_sequencer extends uvm_sequencer #(user_item);
  // UVM automation macro for sequencers
  `uvm_sequencer_utils(user_sequencer)
  
  // Constructor - required UVM Syntax
  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(user_item)
  endfunction : new
  
endclass : user_sequencer


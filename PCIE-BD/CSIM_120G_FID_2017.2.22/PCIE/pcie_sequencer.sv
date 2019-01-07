

class pcie_sequencer extends uvm_sequencer #(pcie_tlp_item);
  // UVM automation macro for sequencers
  `uvm_sequencer_utils(pcie_sequencer)
  uvm_seq_item_pull_port #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) reg_access_seq_item_port;
   bit			is_3dw_or_4dw  = 1'b1;   
  // Constructor - required UVM Syntax
  function new (string name, uvm_component parent);
    super.new(name, parent);
    reg_access_seq_item_port = new ("reg_access_seq_item_port", this) ;
    `uvm_update_sequence_lib_and_item(pcie_tlp_item)
  endfunction : new
  
endclass : pcie_sequencer




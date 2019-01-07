

class reg_access_sequencer extends uvm_sequencer #(reg_access_item #(`ADDR_WIDTH,`BURSTLEN));
  // UVM automation macro for sequencers
  `uvm_sequencer_utils(reg_access_sequencer)
  // Constructor - required UVM Syntax
  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(reg_access_item #(`ADDR_WIDTH,`BURSTLEN))
  endfunction : new
endclass : reg_access_sequencer


class addr_slave_read_rsp extends uvm_component;
  // UVM automation macro for sequencers
  `uvm_component_utils(addr_slave_read_rsp)

  uvm_analysis_export #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) addr_slave_read_rsp_export;
  uvm_tlm_analysis_fifo #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) addr_slave_read_rsp_fifo;


  //reg_access_item#(`ADDR_WIDTH,`BURSTLEN) local_frm;
  
  // Constructor - required UVM Syntax
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase( uvm_phase phase );
    //super.build();
    addr_slave_read_rsp_fifo = new("addr_slave_read_rsp_fifo", this);
    addr_slave_read_rsp_export = new("addr_slave_read_rsp_export", this);
  endfunction
  
  function void connect_phase( uvm_phase phase );
    //super.connect();
    addr_slave_read_rsp_export.connect(addr_slave_read_rsp_fifo.analysis_export);
  endfunction
  
endclass : addr_slave_read_rsp



class user_agent extends uvm_agent;

  `uvm_component_utils(user_agent)
  
  user_sequencer   seqncr;
  user_driver      drvr;      
     
  
  function new(string name , uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  virtual function void build();
    super.build();
    uvm_report_info(get_full_name(),"START of build ",UVM_MEDIUM);
  
    drvr   = user_driver::type_id::create("drvr",this);
    seqncr = user_sequencer::type_id::create("seqncr",this);
  
    uvm_report_info(get_full_name(),"END of build ",UVM_MEDIUM);
  endfunction
    
  virtual function void connect();
    super.connect();
    uvm_report_info(get_full_name(),"START of connect ",UVM_MEDIUM);                                                  

    drvr.seq_item_port.connect(seqncr.seq_item_export);
    //mon.out_clk_mon_port.connect(sbd.clk_rtl_mon_port);


    uvm_report_info(get_full_name(),"END of connect ",UVM_MEDIUM);
  endfunction
    
endclass : user_agent

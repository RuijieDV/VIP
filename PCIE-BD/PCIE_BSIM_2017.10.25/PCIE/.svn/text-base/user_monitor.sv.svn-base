
class user_monitor extends uvm_monitor;

  `uvm_component_utils(user_monitor)

  uvm_analysis_port #(user_item)  out_user_mon_port;
  
  //new 
  function new(string name = "user_monitor", uvm_component parent = null);   
    super.new(name, parent); 
    out_user_mon_port   = new("out_user_mon_port", this);
  endfunction 

  //bulid 
  virtual function void build_phase(uvm_phase phase);    
  endfunction : build_phase 

  //connect 
  function void connect_phase( uvm_phase phase );   
  endfunction : connect_phase 

  //elaboration 
  function void end_of_elaboration();   
  endfunction 

  virtual task run_phase(uvm_phase phase);
  endtask:run_phase
  
endclass



class reg_access_agent extends uvm_agent;

  `uvm_component_utils(reg_access_agent)

   reg_access_sequencer     reg_access_seqncr;
   reg_access_scoreboard    reg_access_sbd;
   
   reg_access_configuration m_config;
   
   
   
   string FILE_CFG_IN;
   string FILE_ISR_IN;
   
  function new(string name , uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // component declare
  
  virtual function void build();
    
    super.build();
    
    reg_access_seqncr = reg_access_sequencer::type_id::create("reg_access_seqncr",this);
    reg_access_sbd    = reg_access_scoreboard::type_id::create("reg_access_sbd",this); 
    
    if (!uvm_config_db #(reg_access_configuration)::get(this, get_full_name(), "reg_access_configuration",m_config)) 
       `uvm_fatal("Config Fatal", "Can't get the configuration")     
    
    reg_access_sbd.FILE_CFG_IN = m_config.FILE_CFG_IN;
  endfunction
  
  // connect
  virtual function void connect();
  
  endfunction

  virtual task run_phase( uvm_phase phase );

  endtask : run_phase

endclass : reg_access_agent

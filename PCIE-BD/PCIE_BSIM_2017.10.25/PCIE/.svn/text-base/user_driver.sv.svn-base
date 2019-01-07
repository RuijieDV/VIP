
class user_driver extends uvm_driver#(user_item);
 
  //factory register 
  `uvm_component_utils(user_driver) 
  //item 

  //scoreboard
  uvm_analysis_port #(user_item) user_driver_sb_port;
  
 
  //new 
  function new(string name = "user_driver", uvm_component parent = null);   
    super.new(name, parent); 
    user_driver_sb_port = new("user_driver_sb_port", this);
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
    
  task run_phase( uvm_phase phase );   
    
    //fork   
    fork     
      begin
        //process data     
        forever begin
          
          seq_item_port.get_next_item(rsp);
          user_driver_sb_port.write(rsp);
          //rsp.print();
          seq_item_port.item_done();
        end 
      end

    join 
  endtask : run_phase 
  
  
endclass : user_driver
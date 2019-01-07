
typedef enum {M_WR_S,M_RD_S,M_WR_B,M_RD_B,S_WR_S,S_RD_S,S_WR_B,S_RD_B} cmd_t;

class reg_access_item#(int ADDR_WIDTH=`ADDR_WIDTH, int BURSTLEN=`BURSTLEN) extends uvm_sequence_item;
  
  //`uvm_object_param_utils(reg_access_item#(ADDR_WIDTH,BURSTLEN))
  
  rand cmd_t cmd;
    
  rand bit [`ADDR_WIDTH-1:0]  addr  ;
  rand bit [7:0]              wdata [];
  rand bit [7:0]              rdata [];


  //for pcie///////////////////////////// 
  
  
  `uvm_object_param_utils_begin(reg_access_item#(ADDR_WIDTH,BURSTLEN)) 
    `uvm_field_enum     (cmd_t,cmd    , UVM_ALL_ON) 
    `uvm_field_int      (addr   , UVM_ALL_ON)
    `uvm_field_array_int(wdata  , UVM_ALL_ON) 
    `uvm_field_array_int(rdata  , UVM_ALL_ON) 
  `uvm_object_utils_end 

  
  function new(string name = "reg_access_item");
    super.new(name);
  endfunction : new

endclass : reg_access_item


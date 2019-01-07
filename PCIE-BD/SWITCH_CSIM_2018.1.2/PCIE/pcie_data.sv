
//////////////////////pcie-data tlp//////////////////////

class pcie_tlp_item extends uvm_sequence_item;

  bit [1:0]  fmt;
  bit [3:0]  typ;   //bit [4:0]  typ;        //2016-07-18
  bit [2:0]  tc;  
  bit        td;        
  bit        ep;
  bit [2:0]  attr; //bit [1:0]  attr;   //2016-07-18
  bit [10:0]  length;  //bit [9:0]  length;     //2016-07-18  
  
  bit [15:0] req_id;  
  bit [15:0] cpl_id;
  bit [7:0]  tag; 
  bit [3:0]  first_dw_be;  
  bit [3:0]  last_dw_be;
  bit [31:0] addr32;
  bit [63:0] addr64;
  
  bit [7:0]  bus_num;    
  bit [3:0]  dev_num;    
  bit [3:0]  fun_num;    
  bit [3:0]  ext_reg_num;
  bit [5:0]  reg_num;     
  
  bit [2:0]  cpl_st;
  bit        bcm;
  bit [12:0] byte_cnt;   //bit [11:0] byte_cnt;   //2016-07-18
  bit [11:0]  lower_addr;  //bit [6:0]  lower_addr;   //2016-07-18
  
  bit [7:0]  payload[];
  
  //reserve
  bit       rev_1bit;
  bit [1:0] rev_2bit;
  bit [3:0] rev_4bit;
  bit [5:0] rev_6bit;
  
  //contrl
  bit       is_mem_io_op;
  bit       is_cfg_op;
  bit       is_cpl_op;
  bit       is_with_data;
  bit       is_3dw = 1'b0;
  bit       is_4dw = 1'b1;
  bit       end_of_cpl = 1'b0;
  // data constraint

  `uvm_object_utils_begin(pcie_tlp_item)
     //be in common use
     //1dw
     //`uvm_field_int(rev_1bit , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(fmt      , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(typ      , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(rev_1bit , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(tc       , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(rev_4bit , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(td       , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(ep       , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(attr     , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(rev_2bit , UVM_ALL_ON)          //2016-07-18
     //`uvm_field_int(length   , UVM_ALL_ON)          //2016-07-18
     //2dw
     if (is_mem_io_op) begin
       //2dw
       //`uvm_field_int(rev_1bit , UVM_ALL_ON)       //2016-07-18 ws
       `uvm_field_int(fmt      , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(typ      , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(rev_1bit , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(tc       , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(rev_4bit , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(td       , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(ep       , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(attr     , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(rev_2bit , UVM_ALL_ON)         //2016-07-18 ws
       `uvm_field_int(length   , UVM_ALL_ON)         //2016-07-18 ws
       
       `uvm_field_int(req_id      , UVM_ALL_ON)
       `uvm_field_int(tag         , UVM_ALL_ON)
       `uvm_field_int(last_dw_be  , UVM_ALL_ON)
       `uvm_field_int(first_dw_be , UVM_ALL_ON)
       if (is_3dw) begin
         //3dw
         `uvm_field_int(addr32[31:2]  , UVM_ALL_ON)
         `uvm_field_int(rev_2bit      , UVM_ALL_ON)
         if (is_with_data) begin
           `uvm_field_array_int(payload, UVM_ALL_ON)
         end
       end
       else if (is_4dw) begin
         //3dw
         `uvm_field_int(addr64[63:32] , UVM_ALL_ON)
         //4dw
         `uvm_field_int(addr64[31:2]  , UVM_ALL_ON)
         `uvm_field_int(rev_2bit      , UVM_ALL_ON)
         if (is_with_data) begin
           `uvm_field_array_int(payload, UVM_ALL_ON)
         end
       end
       else if (is_cfg_op) begin
         //3dw
         `uvm_field_int(bus_num       , UVM_ALL_ON)
         `uvm_field_int(dev_num       , UVM_ALL_ON)
         `uvm_field_int(fun_num       , UVM_ALL_ON)
         `uvm_field_int(rev_4bit      , UVM_ALL_ON)
         `uvm_field_int(ext_reg_num   , UVM_ALL_ON)
         `uvm_field_int(reg_num       , UVM_ALL_ON)
         `uvm_field_int(rev_2bit      , UVM_ALL_ON)
       end
     end
     else if (is_cpl_op) begin
     	//`uvm_field_int(rev_1bit , UVM_ALL_ON)       //2016-07-18 ws
     	 //`uvm_field_int(fmt      , UVM_ALL_ON)       //2016-07-18 ws
     	 `uvm_field_int(typ      , UVM_ALL_ON)         //2016-07-18 ws
     	 //`uvm_field_int(rev_1bit , UVM_ALL_ON)         //2016-07-18 ws
     	 `uvm_field_int(tc       , UVM_ALL_ON)         //2016-07-18 ws
     	 `uvm_field_int(rev_4bit , UVM_ALL_ON)         //2016-07-18 ws
     	 `uvm_field_int(td       , UVM_ALL_ON)         //2016-07-18 ws
     	 `uvm_field_int(ep       , UVM_ALL_ON)         //2016-07-18 ws
     	 `uvm_field_int(attr     , UVM_ALL_ON)         //2016-07-18 ws
     	 //`uvm_field_int(rev_2bit , UVM_ALL_ON)       //2016-07-18 ws
     	 `uvm_field_int(length   , UVM_ALL_ON)         //2016-07-18 ws
     	
       //2dw
       `uvm_field_int(cpl_id       , UVM_ALL_ON)
       `uvm_field_int(cpl_st       , UVM_ALL_ON)
       `uvm_field_int(bcm          , UVM_ALL_ON)       //2016-07-18
       `uvm_field_int(byte_cnt     , UVM_ALL_ON)
       //3dw
       `uvm_field_int(req_id       , UVM_ALL_ON)
       `uvm_field_int(tag          , UVM_ALL_ON)
       //`uvm_field_int(rev_1bit     , UVM_ALL_ON)      //2016-07-18
       `uvm_field_int(lower_addr   , UVM_ALL_ON)
       if (is_with_data) begin
         `uvm_field_array_int(payload, UVM_ALL_ON)
       end
     end
   	 //else if (is_mem_

  `uvm_object_utils_end
  
  // new
  function new(string name = "");
    super.new(name);
  endfunction : new


endclass : pcie_tlp_item
    
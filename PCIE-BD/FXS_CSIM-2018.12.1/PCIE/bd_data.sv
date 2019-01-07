
//`define CLASS_CHUNK_BD_DATA_ITEM__SV

class chunk_bd_data_packet extends uvm_sequence_item;

  bit [63:0] rev_0        = 64'hffff_0000_ffff_0000;    //rev
  bit [63:0] data_in_addr ;                             //tx_buffer
  bit [63:0] data_out_addr;                             //rx_buffer
  bit [15:0] rev_1        = 16'h55aa;                   //rev
  bit [15:0] data_in_len  ;                             //tx_len
  bit [15:0] data_out_len = 16'd0;                      //rx_len
  bit        rev_2        = 1'b0;                       //rev
  bit [6:0]  bd_index     ;                             //bd index
  bit        rev_3        = 1'b0;                       //rev
  bit [1:0]  pack_type    ;                             //pack tpye
  bit        rev_4        = 1'b1;                       //rev     
  bit        rd_data_err  = 1'b0;                       //monitor
  bit        handle_err   = 1'b0;                       //monitor
  bit        owner        ;                             //soft -> 1; fpga -> 0
  bit        valid        ;                             //bd valid

  // data constraint

  `uvm_object_utils_begin(chunk_bd_data_packet)
  
    `uvm_field_int(rev_0        , UVM_ALL_ON)
    `uvm_field_int(data_in_addr , UVM_ALL_ON)
    `uvm_field_int(data_out_addr, UVM_ALL_ON)
    `uvm_field_int(rev_1        , UVM_ALL_ON)
    `uvm_field_int(data_in_len  , UVM_ALL_ON)
    `uvm_field_int(data_out_len , UVM_ALL_ON)
    `uvm_field_int(rev_2        , UVM_ALL_ON)
    `uvm_field_int(bd_index     , UVM_ALL_ON)
    `uvm_field_int(rev_3        , UVM_ALL_ON)
    `uvm_field_int(pack_type    , UVM_ALL_ON)
    `uvm_field_int(rev_4        , UVM_ALL_ON)
    `uvm_field_int(rd_data_err  , UVM_ALL_ON)
    `uvm_field_int(handle_err   , UVM_ALL_ON)
    `uvm_field_int(owner        , UVM_ALL_ON)
    `uvm_field_int(valid        , UVM_ALL_ON)   
    
  `uvm_object_utils_end     

  //new
  function new(string name = "chunk_bd_data_packet");
    super.new(name);
  endfunction : new

endclass : chunk_bd_data_packet


//`endif


//`define CLASS_16E1_DATA_ITEM__SV

class cpm_16e1_txbd_data_packet extends uvm_sequence_item;

  bit [31:0] data_addr    = 32'h0000_0000;              //data_buffer
  bit [15:0] data_len     = 16'd0;                      //data_len
  bit        rev_2        = 1'b0;                       //rev
  bit        underrun     = 1'b0;                       //monitor
  bit [8:0]  rev_1        = 9'h000;                     //rev
  bit        lbif         = 1'b1;                       //Last buffer in frame NO USE FIX   
  bit        interrupt    = 1'b0;                       //no use fix
  bit        wrap         = 1'b0;                       //set
  bit        rev_0        = 1'b0;                       //
  bit        valid        = 1'b0;                       //soft -> 0; fpga -> 1

  // data constraint

  `uvm_object_utils_begin(cpm_16e1_txbd_data_packet)
  
    `uvm_field_int(data_addr, UVM_ALL_ON)
    `uvm_field_int(data_len , UVM_ALL_ON)
    `uvm_field_int(rev_2    , UVM_ALL_ON)
    `uvm_field_int(underrun , UVM_ALL_ON)
    `uvm_field_int(rev_1    , UVM_ALL_ON)
    `uvm_field_int(lbif     , UVM_ALL_ON)
    `uvm_field_int(interrupt, UVM_ALL_ON)
    `uvm_field_int(wrap     , UVM_ALL_ON)
    `uvm_field_int(rev_0    , UVM_ALL_ON)
    `uvm_field_int(valid    , UVM_ALL_ON)
    
  `uvm_object_utils_end     

  //new
  function new(string name = "cpm_16e1_txbd_data_packet");
    super.new(name);
  endfunction : new

endclass : cpm_16e1_txbd_data_packet

class cpm_16e1_rxbd_data_packet extends uvm_sequence_item;

  bit [31:0] data_addr    = 32'h0000_0000;              //data_buffer
  bit [15:0] data_len     = 16'd0;                      //data_len
  bit        overrun      = 1'b0;                       //monitor
  bit        crc_err      = 1'b0;                       //monitor
  bit        abort        = 1'b0;                       //monitor
  bit        no           = 1'b0;                       //monitor
  bit        lg           = 1'b0;                       //monitor
  bit [3:0]  rev_4        = 4'b0000;
  bit        fbif         = 1'b1;                       //first buffer in frame NO USE FIX   
  bit        lbif         = 1'b0;                       //Last buffer in frame NO USE FIX   
  bit        interrupt    = 1'b0;                       //no use fix
  bit        wrap         = 1'b0;                       //set
  bit        rev_0        = 1'b0; 
  bit        empty        = 1'b0;                       //soft -> 0; fpga -> 1

  // data constraint

  `uvm_object_utils_begin(cpm_16e1_rxbd_data_packet)
  
    `uvm_field_int(data_addr, UVM_ALL_ON)
    `uvm_field_int(data_len , UVM_ALL_ON)
    `uvm_field_int(rev_0    , UVM_ALL_ON)
    `uvm_field_int(overrun  , UVM_ALL_ON)
    `uvm_field_int(crc_err  , UVM_ALL_ON)
    `uvm_field_int(abort    , UVM_ALL_ON)
    `uvm_field_int(no       , UVM_ALL_ON)
    `uvm_field_int(lg       , UVM_ALL_ON)
    `uvm_field_int(rev_4    , UVM_ALL_ON)
    `uvm_field_int(fbif     , UVM_ALL_ON)
    `uvm_field_int(lbif     , UVM_ALL_ON)
    `uvm_field_int(interrupt, UVM_ALL_ON)
    `uvm_field_int(wrap     , UVM_ALL_ON)
    `uvm_field_int(rev_0    , UVM_ALL_ON)
    `uvm_field_int(empty    , UVM_ALL_ON)
     
  `uvm_object_utils_end     

  //new
  function new(string name = "cpm_16e1_rxbd_data_packet");
    super.new(name);
  endfunction : new

endclass : cpm_16e1_rxbd_data_packet

//`endif

//`define CLASS_HNM_4GE__SV

class hnm_4ge_txbd_data_packet extends uvm_sequence_item;

  bit [31:0] data_addr    = 32'h0000_0000;              //data_buffer
  bit [11:0] data_len     = 16'd0;                      //data_len
  bit [3:0]  port_num     = 3'd0;                       //port_num
  bit [10:0] bd_index     = 11'd0;                      //bd_index
  bit        rev_1        = 1'b0;                       //rev
  bit        last_frame   = 1'b0;                       //last_frame  1:last
  bit        first_frame  = 1'b0;                       //first_frame 1:last
  bit        owner        = 1'b0;                       //soft -> 0; fpga -> 1
  bit        valid        = 1'b0;                       //1: valid

  // data constraint

  `uvm_object_utils_begin(hnm_4ge_txbd_data_packet)
  
    `uvm_field_int(data_addr   , UVM_ALL_ON)
    `uvm_field_int(data_len    , UVM_ALL_ON)
    `uvm_field_int(port_num    , UVM_ALL_ON)
    `uvm_field_int(bd_index    , UVM_ALL_ON)
    `uvm_field_int(rev_1       , UVM_ALL_ON)
    `uvm_field_int(last_frame  , UVM_ALL_ON) //nouse
    `uvm_field_int(first_frame , UVM_ALL_ON) //nouse
    `uvm_field_int(owner       , UVM_ALL_ON)
    `uvm_field_int(valid       , UVM_ALL_ON)
    
  `uvm_object_utils_end     

  //new
  function new(string name = "hnm_4ge_txbd_data_packet");
    super.new(name);
  endfunction : new

endclass : hnm_4ge_txbd_data_packet

class hnm_4ge_rxbd_data_packet extends uvm_sequence_item;

  bit [31:0] data_addr    = 32'h0000_0000;              //data_buffer
  bit [11:0] data_len     = 16'd0;                      //data_len
  bit [3:0]  port_num     = 3'd0;                       //port_num
  bit [10:0] bd_index     = 11'd0;                      //bd_index
  bit        rev_1        = 1'b0;                       //rev
  bit        last_frame   = 1'b0;                       //last_frame  1:last
  bit        first_frame  = 1'b0;                       //first_frame 1:last
  bit        owner        = 1'b0;                       //soft -> 0; fpga -> 1
  bit        valid        = 1'b0;                       //1: valid

  // data constraint

  `uvm_object_utils_begin(hnm_4ge_rxbd_data_packet)
  
    `uvm_field_int(data_addr   , UVM_ALL_ON)
    `uvm_field_int(data_len    , UVM_ALL_ON)
    `uvm_field_int(bd_index    , UVM_ALL_ON)
    `uvm_field_int(port_num    , UVM_ALL_ON)
    `uvm_field_int(rev_1       , UVM_ALL_ON)
    `uvm_field_int(last_frame  , UVM_ALL_ON)
    `uvm_field_int(first_frame , UVM_ALL_ON)
    `uvm_field_int(owner       , UVM_ALL_ON)
    `uvm_field_int(valid       , UVM_ALL_ON)
     
  `uvm_object_utils_end     

  //new
  function new(string name = "hnm_4ge_rxbd_data_packet");
    super.new(name);
  endfunction : new

endclass : hnm_4ge_rxbd_data_packet

//`endif


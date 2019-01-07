/*=============================================================================
// RUIJIE IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
// SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
// RUIJIE DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
// AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
// OR STANDARD, RUIJIE IS MAKING NO REPRESENTATION THAT THIS
// IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
// AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
// FOR YOUR IMPLEMENTATION.  RUIJIE EXPRESSLY DISCLAIMS ANY
// WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
// IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
// REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
// INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE.
// (c) Copyright 2007 RUIJIE, Inc.
// All rights reserved.

//============================================================================
//     FileName: pcie_tlp_bd_data.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-22 17:34:57
//      History:
//============================================================================*/
`ifndef PCIE_BD_DATA__SV
`define PCIE_BD_DATA__SV

//############################################################################
class pcie_tlp_txbd_data extends uvm_sequence_item;

	bit [31:0] data_addr    = 32'h0000_0000; //data_buffer
	bit [11:0] data_len     = 12'd0;         //data_len
	bit [3:0]  port_num     = 4'd0;          //port_num
	bit [10:0] bd_index     = 11'd0;         //bd_index
	bit        rev_1        = 1'b0;          //rev
	bit        last_frame   = 1'b0;          //last_frame  1:last
	bit        first_frame  = 1'b0;          //first_frame 1:last
	bit        owner        = 1'b0;          //soft -> 0; fpga -> 1
	bit        valid        = 1'b0;          //1: valid

	`uvm_object_utils_begin(pcie_tlp_txbd_data)
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
  
	function new(string name = "pcie_tlp_txbd_data");
		super.new(name);
	endfunction : new

endclass

//############################################################################
class pcie_tlp_rxbd_data extends uvm_sequence_item;

	bit [31:0] data_addr    = 32'h0000_0000; //data_buffer
  	bit [11:0] data_len     = 12'd0;         //data_len
  	bit [3:0]  port_num     = 4'd0;          //port_num
  	bit [10:0] bd_index     = 11'd0;         //bd_index
  	bit        rev_1        = 1'b0;          //rev
  	bit        last_frame   = 1'b0;          //last_frame  1:last
  	bit        first_frame  = 1'b0;          //first_frame 1:last
  	bit        owner        = 1'b0;          //soft -> 0; fpga -> 1
  	bit        valid        = 1'b0;          //1: valid

	`uvm_object_utils_begin(pcie_tlp_rxbd_data)
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

	function new(string name = "pcie_tlp_rxbd_data");
		super.new(name);
	endfunction : new

endclass

`endif


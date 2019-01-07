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
//     FileName: axi4lite_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-04 10:22:03
//      History:
//============================================================================*/
`ifndef AXI4LITE_PKT__SV
`define AXI4LITE_PKT__SV


class axi4lite_pkt extends uvm_sequence_item;

	`SET_CLASSID

	typedef enum {AXI4LITE_WR,AXI4LITE_RD} axi4lite_e;
	axi4lite_e  axi4lite_type  ;
	bit [31:0]  axi4lite_awaddr;
	bit [31:0]  axi4lite_wdata ;
	bit [ 3:0]  axi4lite_wstrb ;
	bit [ 1:0]  axi4lite_bresp ;
   
	bit [31:0]  axi4lite_araddr;
	bit [31:0]  axi4lite_rdata ;
	bit [ 1:0]  axi4lite_rresp ;

	`uvm_object_utils_begin(axi4lite_pkt)
	    `uvm_field_enum(axi4lite_e,axi4lite_type, UVM_DEFAULT)
	    `uvm_field_int(axi4lite_awaddr          , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_wdata           , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_wstrb           , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_bresp           , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_araddr          , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_rdata           , UVM_DEFAULT)
	    `uvm_field_int(axi4lite_rresp           , UVM_DEFAULT)
    `uvm_object_utils_end
  
    function new (string name = "axi4lite_pkt");
		super.new(name);
    endfunction : new

endclass

`endif 

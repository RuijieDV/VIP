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
// (c) Copyright 2017 RUIJIE, Inc.
// All rights reserved.

//============================================================================
//     FileName: au_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2017-11-17 11:26:04
//      History:
//============================================================================*/
`ifndef AU_PKT__SV
`define AU_PKT__SV

class au_pkt extends uvm_sequence_item;                                  
   
	`SET_CLASSID
    //##################################
	bit [127:0]      au_data;
    int              m_idle_cfg;
    //##################################

	`uvm_object_utils_begin(au_pkt)
	    `uvm_field_int(au_data,UVM_DEFAULT)
		`uvm_field_int(m_idle_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
    `uvm_object_utils_end
  
    function new (string name = "au_pkt");
		super.new(name);
    endfunction : new

endclass : au_pkt

`endif


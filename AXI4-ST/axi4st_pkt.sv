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
//     FileName: axi4st_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-18 15:30:02
//      History:
//============================================================================*/
`ifndef AXI4ST_PKT__SV
`define AXI4ST_PKT__SV

class axi4st_pkt extends uvm_sequence_item;                                  
   
	`SET_CLASSID
    //##################################
	     bit [7:0]       axi4st_data[$];
    //##################################
	rand bit             crc_error; 
	rand bit             s_axi4st_tready_cfg; 
	rand bit             m_axi4st_tvalid_cfg; 
    //##################################
		 int             m_idle_cfg; 
    //##################################
	constraint c_crc_error {
		soft crc_error == 1'b0;
	}

	constraint c_s_axi4st_tready_cfg {
		soft s_axi4st_tready_cfg == 1;
	}
	
	constraint c_m_axi4st_tvalid_cfg {
		soft m_axi4st_tvalid_cfg == 1;
	}

	`uvm_object_utils_begin(axi4st_pkt)
	    `uvm_field_queue_int(axi4st_data,UVM_DEFAULT)
		`uvm_field_int(s_axi4st_tready_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(m_axi4st_tvalid_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(crc_error,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(m_idle_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
    `uvm_object_utils_end
  
    function new (string name = "axi4st_pkt");
		super.new(name);
    endfunction : new

endclass : axi4st_pkt

`endif


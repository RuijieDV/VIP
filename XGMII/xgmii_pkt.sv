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
//     FileName: xgmii_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 12:18:01
//      History:
//============================================================================*/
`ifndef XGMII_PKT__SV
`define XGMII_PKT__SV

class xgmii_pkt extends uvm_sequence_item;                                  
   
	`SET_CLASSID
    //##################################
	bit [7:0]       xgmii_data[$];
    //##################################
	rand int        xgmii_first;
	rand int        xgmii_ipg;
	rand bit        xgmii_err;
    //##################################
	constraint c_xgmii_first {
		soft xgmii_first == 0; //must item%4==0 
	}

	constraint c_xgmii_ipg {
		soft xgmii_ipg == 12;//must >= 12
	}

	constraint c_xgmii_err {
		soft xgmii_err == 0;
	}

	`uvm_object_utils_begin(xgmii_pkt)
	    `uvm_field_queue_int(xgmii_data,UVM_DEFAULT)
	    `uvm_field_int(xgmii_first,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_int(xgmii_ipg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_int(xgmii_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
    `uvm_object_utils_end
  
    function new (string name = "xgmii_pkt");
		super.new(name);
    endfunction : new

endclass : xgmii_pkt

`endif


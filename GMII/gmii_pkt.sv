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
//     FileName: gmii_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 12:18:01
//      History:
//============================================================================*/
`ifndef GMII_PKT__SV
`define GMII_PKT__SV

class gmii_pkt extends uvm_sequence_item;                                  
   
	`SET_CLASSID
    //##################################
		 bit [7:0]       gmii_data[$];
    //##################################
	rand int             gmii_ipg;
	rand bit             gmii_err;
	rand bit             gmii_crs;
	rand bit             gmii_col;
    //##################################
	constraint c_gmii_ipg {
		soft gmii_ipg == 12; //must >= 12
	}

	constraint c_gmii_err {
		soft gmii_err == 1'b0;
	}

	constraint c_gmii_crs {
		soft gmii_crs == 1'b0;
	}

	constraint c_gmii_col {
		soft gmii_col == 1'b0;
	}
    //##################################
	`uvm_object_utils_begin(gmii_pkt)
	    `uvm_field_queue_int(gmii_data,UVM_DEFAULT)
	    `uvm_field_int(gmii_ipg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_int(gmii_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_int(gmii_crs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_int(gmii_col,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
    `uvm_object_utils_end
  
    function new (string name = "gmii_pkt");
		super.new(name);
    endfunction : new

endclass : gmii_pkt

`endif


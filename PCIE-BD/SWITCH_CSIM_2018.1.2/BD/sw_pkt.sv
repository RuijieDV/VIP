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
//     FileName: sw_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2017-11-27 09:59:58
//      History:
//============================================================================*/
`ifndef SW_PKT__SV
`define SW_PKT__SV

class sw_pkt extends uvm_object;                                  
	
	`SET_CLASSID
	//#################################
    int       sw_err;
	int       sw_padding;
	int       sw_pid;
	bit [7:0] sw_data[$];
	bit [7:0] sw_padding_data[$];
	//################################
	//#################################

	`uvm_object_utils_begin(sw_pkt)
	    `uvm_field_int(sw_err,UVM_DEFAULT)
	    `uvm_field_int(sw_padding,UVM_DEFAULT)
	    `uvm_field_int(sw_pid,UVM_DEFAULT)
	    `uvm_field_queue_int(sw_data,UVM_DEFAULT)
	    `uvm_field_queue_int(sw_padding_data,UVM_DEFAULT)
    `uvm_object_utils_end
  
    function new (string name = "sw_pkt");
		super.new(name);
    endfunction : new

    virtual function void setSWData(int m_pid,bit [7:0] dq[$],int m_err = 0,bit m_padding = 1);
	    this.sw_pid = m_pid;/*{{{*/
		this.sw_data = dq;
		this.sw_err = m_err;
		this.sw_padding = m_padding;
		if(dq.size() < 60) begin 
			sw_data = dq;
			sw_padding_data = dq;
			while(sw_padding_data.size() < 60)
				sw_padding_data.push_back(8'h0);
		end
		else begin 
			sw_data = dq;
			sw_padding_data = dq;
			this.sw_padding = 0;
		end /*}}}*/
	endfunction

endclass

`endif


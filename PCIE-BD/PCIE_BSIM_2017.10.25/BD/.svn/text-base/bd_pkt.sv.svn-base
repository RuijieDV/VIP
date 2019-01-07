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
//     FileName: bd_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-09-24 17:29:01
//      History:
//============================================================================*/
`ifndef BD_PKT__SV
`define BD_PKT__SV

class bd_pkt extends uvm_sequence_item;                                  

	`SET_CLASSID
    //##################################
	string     bd_id;
	bit [7:0]  bd_data[$];
    //##################################
	bit        is_padding;
	bit [7:0]  bd_data_padding[$];

	`uvm_object_utils_begin(bd_pkt)
	    `uvm_field_string(bd_id,UVM_DEFAULT)
	    `uvm_field_queue_int(bd_data,UVM_DEFAULT)
	    `uvm_field_int(is_padding,UVM_DEFAULT)
	    `uvm_field_queue_int(bd_data_padding,UVM_DEFAULT)
    `uvm_object_utils_end
  
    function new (string name = "bd_pkt");
		super.new(name);
    endfunction : new

    function byte16_que_t gen16BytesQue(string id,input int num);
		byte16_que_t m_q;
		if(this.bd_data.size() != 16*num)
			`uvm_error($sformatf("%0s_gen16BytesQue",id),$sformatf("this.bd_data.size[%0d] vs [%0d]",this.bd_data.size(),16*num))
		m_q = byte16_que_t'(bd_data);
		return m_q;
	endfunction

	function byte48_que_t gen48BytesQue(string id,input int num);
		byte48_que_t m_q;
		if(this.bd_data.size() != 48*num)
			`uvm_error($sformatf("%0s_gen48BytesQue",id),$sformatf("this.bd_data.size[%0d] vs [%0d]",this.bd_data.size(),48*num))
		m_q = byte48_que_t'(bd_data);
		return m_q;
	endfunction

	function byte64_que_t gen64BytesQue(string id,input int num);
		byte64_que_t m_q;
		if(this.bd_data.size() != 64*num)
			`uvm_error($sformatf("%0s_gen64BytesQue",id),$sformatf("this.bd_data.size[%0d] vs [%0d]",this.bd_data.size(),64*num))
		m_q = byte64_que_t'(bd_data);
		return m_q;
	endfunction

    function byte160_que_t gen160BytesQue(string id,input int num);
		byte160_que_t m_q;
		if(this.bd_data.size() != 160*num)
			`uvm_error($sformatf("%0s_gen160BytesQue",id),$sformatf("this.bd_data.size[%0d] vs [%0d]",this.bd_data.size(),160*num))
		m_q = byte160_que_t'(bd_data);
		return m_q;
	endfunction

    function byte208_que_t gen208BytesQue(string id,input int num);
		byte208_que_t m_q;
		if(this.bd_data.size() != 208*num)
			`uvm_error($sformatf("%0s_gen208BytesQue",id),$sformatf("this.bd_data.size[%0d] vs [%0d]",this.bd_data.size(),208*num))
		m_q = byte208_que_t'(bd_data);
		return m_q;
	endfunction

endclass:bd_pkt


`endif


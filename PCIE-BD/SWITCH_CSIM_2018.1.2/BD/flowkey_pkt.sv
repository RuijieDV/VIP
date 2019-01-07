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
//     FileName: flowkey_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-09-27 17:35:28
//      History:
//============================================================================*/
`ifndef FLOWKEY_PKT__SV
`define FLOWKEY_PKT__SV

class flowkey_pkt extends uvm_object;                                  
	
	`SET_CLASSID
	//################################
	int m_err;
	int m_padding;
	int m_pid;
	//#################################
    s_flowkey m_flowkey;
	bit [7:0] m_pkt_q[$];
	string    m_pkt_str;
	bit [7:0] m_pkt_padding_q[$];
	string    m_pkt_padding_str;
	//#################################

	`uvm_object_utils_begin(flowkey_pkt)
		`uvm_field_int(m_err,UVM_DEFAULT)/*{{{*/
		`uvm_field_int(m_padding,UVM_DEFAULT)
		`uvm_field_int(m_pid,UVM_DEFAULT)
		`uvm_field_int(m_flowkey,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.pri,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.in_port,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.dl_src,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.dl_dst,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.tci,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.etype,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.proto,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.tos,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.ttl,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.frag,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.l4_sport,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.l4_dport,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.tcp_flags,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.nw_src,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.nw_dst,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.sha,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.tha,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.vni,UVM_DEFAULT)
		`uvm_field_int(m_flowkey.svp,UVM_DEFAULT)
		`uvm_field_queue_int(m_pkt_q,UVM_DEFAULT)
		`uvm_field_queue_int(m_pkt_padding_q,UVM_DEFAULT)
    `uvm_object_utils_end
  
    function new (string name = "flowkey_pkt");
		super.new(name);
    endfunction : new

	virtual function void setFlowKeyData(int m_pid,s_flowkey m_flowkey,bit [7:0] dq[$],int m_err = 0,bit m_padding = 1);
	    this.m_pid = m_pid;/*{{{*/
		this.m_flowkey = m_flowkey;
		this.m_pkt_q = dq;
		this.m_err = m_err;
		this.m_padding = m_padding;
		if(dq.size() < 60) begin 
			m_pkt_q = dq;
			m_pkt_str = bit8q2str(m_pkt_q);
			m_pkt_padding_q = dq;
			while(m_pkt_padding_q.size() < 60)
				m_pkt_padding_q.push_back(8'h0);
			m_pkt_padding_str = bit8q2str(m_pkt_padding_q);
		end
		else begin 
			m_pkt_q = dq;
			m_pkt_str = bit8q2str(dq);
			m_pkt_padding_q = dq;
			m_pkt_padding_str = m_pkt_str;
			this.m_padding = 0;
		end /*}}}*/
	endfunction

	virtual function int getLayer(string protocol = "IP");
 	    int ret = 1;/*{{{*/
		string dot_payload = ".payload";
		int total_layer = 0;
        while(1) begin 
			total_layer++;
			if(total_layer >= 20)
				`uvm_fatal("GetLayer","You can not find Raw data!!!!")
			if(sv_EthIsWhat(m_pkt_str,dot_payload,"Raw") == 1) begin
				break;
			end
			dot_payload = {dot_payload,".payload"};
		end
		dot_payload = ".payload";
		while(ret < total_layer) begin 
			if(sv_EthIsWhat(m_pkt_str,dot_payload,protocol) == 1) begin
				return ret;
			end
			ret++;
			dot_payload = {dot_payload,".payload"};
		end
		`uvm_fatal($sformatf("%m"),$sformatf("You can't find protocol %0s in pkt:\n%0s",protocol,this.sprint()))
		return 0;/*}}}*/
	endfunction
	
	virtual function int getFieldInt(int layer,string field = ".chksum");
	    string dt_str;
		dt_str = sv_EthFieldVal(this.m_pkt_str,{{(layer){".payload"}}},field);	
		return dt_str.atoi(); 
	endfunction

	virtual function string getFieldStr(int layer,string field = ".chksum");
		return sv_EthFieldVal(this.m_pkt_str,{{(layer){".payload"}}},field);	
	endfunction

	virtual function int getFieldLen(int layer = 0,string field = "",bit show = 0);
		int m_sz;/*{{{*/
		m_sz = sv_EthLayerHexLen(this.m_pkt_str,"","",0);
		if(m_sz < 60 )
			`uvm_fatal($sformatf("%m"),$sformatf("You get ether pkt size less than 60 byets:\n%0s",this.sprint()))
		return sv_EthLayerHexLen(this.m_pkt_str,{{(layer){".payload"}}},field,show);
		/*}}}*/
	endfunction

endclass

`endif


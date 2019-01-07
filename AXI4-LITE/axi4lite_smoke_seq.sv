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
//     FileName: axi4lite_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-04 13:38:13
//      History:
//============================================================================*/
`ifndef AXI4LITE_SMOKE_SEQ__SV
`define AXI4LITE_SMOKE_SEQ__SV

class axi4lite_default_seq extends uvm_sequence#(axi4lite_pkt);

	`SET_CLASSID
	int         m_pkt_num        ;
	axi4lite_pkt::axi4lite_e  m_axi4lite_type  ;
	bit [31:0]  m_axi4lite_awaddr;
	bit [31:0]  m_axi4lite_wdata ;
	bit [ 1:0]  m_axi4lite_bresp ;
   
	bit [31:0]  m_axi4lite_araddr;
	bit [31:0]  m_axi4lite_rdata ;
	bit [ 1:0]  m_axi4lite_rresp ;

	`uvm_object_utils(axi4lite_default_seq)
	`uvm_declare_p_sequencer(axi4lite_sequencer)

	function new(string name = "axi4lite_default_seq");
		super.new(name);
	endfunction: new

	task body();
		axi4lite_pkt axi4lite_req,axi4lite_rsp;
		for(int i=0;i<m_pkt_num;i++) begin
    	    axi4lite_req = `CREATE_OBJ(axi4lite_pkt,"axi4lite_req")
    	    axi4lite_rsp = `CREATE_OBJ(axi4lite_pkt,"axi4lite_rsp")
    	    axi4lite_req.axi4lite_type = m_axi4lite_type;
			if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_WR) begin 
				axi4lite_req.axi4lite_awaddr = m_axi4lite_awaddr;
				axi4lite_req.axi4lite_wdata = m_axi4lite_wdata;
			end
			else if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_RD) begin 
				axi4lite_req.axi4lite_araddr = m_axi4lite_araddr;
			end
			start_item(axi4lite_req);
			finish_item(axi4lite_req);
			get_response(axi4lite_rsp);
			if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_WR) begin 
				if(axi4lite_rsp.axi4lite_bresp inside {2'b10,2'b11})
					`uvm_error(CLASSID,$sformatf("You get wrong WR resp[%0b]!",axi4lite_rsp.axi4lite_bresp))
			end
			else if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_RD) begin 
				if(axi4lite_rsp.axi4lite_rresp inside {2'b10,2'b11})
					`uvm_error(CLASSID,$sformatf("You get wrong RD resp[%0b]!",axi4lite_rsp.axi4lite_bresp))
				else begin 
					axi4lite_req.axi4lite_rdata = axi4lite_rsp.axi4lite_rdata;
					m_axi4lite_rdata = axi4lite_req.axi4lite_rdata;
				end
			end
		end
	endtask: body

	virtual task startPkt (
		                   input uvm_sequencer_base seqr, 
						   input bit [31:0] m_axi4lite_addr,
						   inout bit [31:0] m_axi4lite_data,
						   input axi4lite_pkt::axi4lite_e axi4lite_type = axi4lite_pkt::AXI4LITE_WR,
						   input int        m_pkt_num = 1,
						   input uvm_sequence_base parent=null
						  );
		  this.m_pkt_num = m_pkt_num;
	      this.m_axi4lite_type = axi4lite_type;
		  if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_WR) begin 
			  this.m_axi4lite_awaddr = m_axi4lite_addr;
	          this.m_axi4lite_wdata  = m_axi4lite_data;
		  end
		  else if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_RD) begin 
			  this.m_axi4lite_araddr = m_axi4lite_addr;
		  end   
	      this.start(seqr,parent);
		  if(m_axi4lite_type == axi4lite_pkt::AXI4LITE_RD)
			  m_axi4lite_data = this.m_axi4lite_rdata;
	endtask:startPkt


endclass: axi4lite_default_seq

`endif 

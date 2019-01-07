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
//     FileName: pcie_tlp_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-21 17:51:13
//      History:
//============================================================================*/
`ifndef PCIE_TLP_IF__SV
`define PCIE_TLP_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface pcie_tlp_if (); 
	parameter  string  IF_NAME      = "PCIE_TLP_IF" ;  
	parameter  int     DATA_WIDTH   = 64            ;//32-64 
	parameter  int     TID_WIDTH    = 8             ;//1~8      
	parameter  int     TDST_WIDTH   = 4             ;//1~4      
	parameter  int     TUSR_WIDTH   = 8             ;//
	localparam int     DATA_BYTES   = DATA_WIDTH/8  ;
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::pcie_tlp_pkt;
    //########################################################
	logic                         m_pcie_tlp_clk    ;//input 
	logic                         m_pcie_tlp_rst_n  ;//input 
	logic                         m_pcie_tlp_tvalid ;//output 
	logic                         m_pcie_tlp_tready ;//input
	logic  [DATA_WIDTH-1 : 0]     m_pcie_tlp_tdata  ;//output 
	logic  [DATA_BYTES-1 : 0]     m_pcie_tlp_tstrb  ;//output 
	logic  [DATA_BYTES-1 : 0]     m_pcie_tlp_tkeep  ;//output 
	logic                         m_pcie_tlp_tlast  ;//output 
	logic  [ TID_WIDTH-1 : 0]     m_pcie_tlp_tid    ;//output 
	logic  [TDST_WIDTH-1 : 0]     m_pcie_tlp_tdest  ;//output 
	logic  [TUSR_WIDTH-1 : 0]     m_pcie_tlp_tuser  ;//output 
	//########################################################
	logic                         s_pcie_tlp_clk    ;//input 
	logic                         s_pcie_tlp_rst_n  ;//input 
	logic                         s_pcie_tlp_tvalid ;//input 
	logic                         s_pcie_tlp_tready ;//output
	logic  [DATA_WIDTH-1 : 0]     s_pcie_tlp_tdata  ;//input 
	logic  [DATA_BYTES-1 : 0]     s_pcie_tlp_tstrb  ;//input 
	logic  [DATA_BYTES-1 : 0]     s_pcie_tlp_tkeep  ;//input 
	logic                         s_pcie_tlp_tlast  ;//input 
	logic  [ TID_WIDTH-1 : 0]     s_pcie_tlp_tid    ;//input 
	logic  [TDST_WIDTH-1 : 0]     s_pcie_tlp_tdest  ;//input 
	logic  [TUSR_WIDTH-1 : 0]     s_pcie_tlp_tuser  ;//input 
	//########################################################
	//`define PCIE_TLP_IF_LPB
    `ifdef PCIE_TLP_IF_LPB
	    initial begin 
			m_pcie_tlp_rst_n = 0;
			m_pcie_tlp_clk = 0;
			#10ns;
			m_pcie_tlp_rst_n = 1;
			forever #5ns m_pcie_tlp_clk = ~m_pcie_tlp_clk;
		end
		assign s_pcie_tlp_clk    = m_pcie_tlp_clk    ;
     	assign s_pcie_tlp_rst_n  = m_pcie_tlp_rst_n  ;
     	assign s_pcie_tlp_tvalid = m_pcie_tlp_tvalid ;
     	assign m_pcie_tlp_tready = s_pcie_tlp_tready ;
     	assign s_pcie_tlp_tdata  = m_pcie_tlp_tdata  ;
     	assign s_pcie_tlp_tstrb  = m_pcie_tlp_tstrb  ;
     	assign s_pcie_tlp_tkeep  = m_pcie_tlp_tkeep  ;
     	assign s_pcie_tlp_tlast  = m_pcie_tlp_tlast  ;
     	assign s_pcie_tlp_tid    = m_pcie_tlp_tid    ;
     	assign s_pcie_tlp_tdest  = m_pcie_tlp_tdest  ;
     	assign s_pcie_tlp_tuser  = m_pcie_tlp_tuser  ;

    `endif
	//########################################################
	//########################################################
	//clocking
	//clocking m_cb @(posedge m_pcie_tlp_clk);
	//	default input #1step output posedge;
	//	output m_pcie_tlp_tvalid; 
	//	input  m_pcie_tlp_tready; 
	//	output m_pcie_tlp_tdata ; 
	//	output m_pcie_tlp_tstrb ; 
	//	output m_pcie_tlp_tkeep ; 
	//	output m_pcie_tlp_tlast ; 
	//	output m_pcie_tlp_tid   ; 
	//	output m_pcie_tlp_tdest ; 
	//	output m_pcie_tlp_tuser ; 
	//endclocking
	//
	//clocking s_cb @(posedge s_pcie_tlp_clk);
	//	default input #1step output posedge;
	//	input  s_pcie_tlp_tvalid ;
	//	output s_pcie_tlp_tready ;
	//	input  s_pcie_tlp_tdata  ;
	//	input  s_pcie_tlp_tstrb  ;
	//	input  s_pcie_tlp_tkeep  ;
	//	input  s_pcie_tlp_tlast  ;
	//	input  s_pcie_tlp_tid    ;
	//	input  s_pcie_tlp_tdest  ;
	//	input  s_pcie_tlp_tuser  ;
	//endclocking
	//########################################################
	bit s_pcie_tlp_tready_cfg = 1; 
	//########################################################
	pcie_tlp_pkt m_pkt_q[$];
	event trigger_mon;
    initial begin:MON
		fork
			forever begin
				fork/*{{{*/
				    begin 
						pcie_tlp_pkt m_pkt;
						logic [DATA_WIDTH-1:0] mdata_q[$];
						logic [DATA_WIDTH-1:0] mdata;
						int mdata_qz;
						int m_tkeep_num;
						mdata_q.delete();
						while(1) begin
							do begin
								@(posedge s_pcie_tlp_clk);
							end while((s_pcie_tlp_tready&&s_pcie_tlp_tvalid) !== 1);
							//$display("%t:lixu,%b",$time,{s_pcie_tlp_tready,s_pcie_tlp_tvalid});
							if(DATA_WIDTH != 32)
								mdata_q.push_back({<<32{s_pcie_tlp_tdata}});
							else
								mdata_q.push_back(s_pcie_tlp_tdata);
							if(s_pcie_tlp_tlast !== 1'b1) begin 
								if(s_pcie_tlp_tkeep !== '1)
									`uvm_error(IF_NAME,$sformatf("s_pcie_tlp_tkeep[%0b] != '1",s_pcie_tlp_tkeep))
							end
							else begin 
								m_pkt = `CREATE_OBJ(pcie_tlp_pkt,"m_pkt")
								mdata_qz = mdata_q.size() - 1;
								for(int i=0;i<mdata_qz;i++) begin 
        	                        mdata = mdata_q.pop_front();
									for(int j=0;j<DATA_BYTES;j++)
										m_pkt.pcie_tlp_data.push_back(mdata[DATA_WIDTH-1-8*j -:8]);
								end
								m_tkeep_num = $countones(s_pcie_tlp_tkeep);
        	                    mdata = mdata_q.pop_front();
								for(int j=m_tkeep_num;j>0;j--) begin 
									m_pkt.pcie_tlp_data.push_back(mdata[8*j-1 -:8]);
								end
								m_pkt_q.push_back(m_pkt);
								mdata_q.delete();
								#0;
								->trigger_mon;
							end
						end 
					end
				    begin 
					    @(negedge s_pcie_tlp_rst_n);
					end
				join_any
				disable fork;/*}}}*/
			end
		    forever begin 
			    if(s_pcie_tlp_tready_cfg == 1)
					@(posedge s_pcie_tlp_clk)  s_pcie_tlp_tready <= 1;
				else 
					@(posedge s_pcie_tlp_clk)  s_pcie_tlp_tready <= ($urandom_range(0,10) > 0) ? 1'b1 : 1'b0;
	        end
		join
	end
	//########################################################
	bit m_pcie_tlp_tvalid_cfg = 1; 
	//########################################################
	class concrete_if extends abstract_if;

        typedef logic [DATA_WIDTH-1:0] mdata_q_t[$];
		function new(string name="");
			super.new(name);
		endfunction
		
		task clean_up();//must no time delay
			resetALL();
		endtask:clean_up 

		task drvInit();
            resetBUS();
		endtask

		task sentPkt(input uvm_sequence_item pkt,input uvm_object cfg = null); 
			pcie_tlp_pkt m_pkt;
			int sz,mod,rend,mdata_sz;
		    logic [DATA_WIDTH-1:0] mdata[];
			logic [DATA_WIDTH-1:0] mdata_q[$];
			wait(m_pcie_tlp_rst_n == 1);
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				//###############################################################################
				sz = m_pkt.pcie_tlp_data.size();/*{{{*/
				mod = sz/DATA_BYTES;
				rend = sz%DATA_BYTES;
				if(rend != 0)
					mdata_sz = mod + 1;
				else
					mdata_sz = mod;
			    mdata = new[mdata_sz];
			    for(int i=0;i<mdata_sz;i++) begin 
			    	for(int j=0;j<DATA_BYTES;j++) begin 
			    		if(i < mod)
			    			mdata[i][DATA_WIDTH-1-8*j -:8] = m_pkt.pcie_tlp_data.pop_front();
			    		else begin 
			    	        if(j < rend)
			    	        	mdata[mod][DATA_WIDTH-1-8*j -:8] = m_pkt.pcie_tlp_data.pop_front();
			    	        else
			    	        	mdata[mod][DATA_WIDTH-1-8*j -:8] = 'x;
			    		end
			    	end
			    end
                mdata_q = mdata_q_t'(mdata);/*}}}*/
				//$display("lixu:%p",mdata_q);
				//###############################################################################
				if(mdata_q.size() == 1) begin 
                    @(posedge m_pcie_tlp_clk) begin 
				        m_pcie_tlp_tvalid <= 1'b1;
						if(DATA_WIDTH != 32)
							m_pcie_tlp_tdata  <= {<<32{mdata_q.pop_front()}};
						else
							m_pcie_tlp_tdata  <= mdata_q.pop_front();
						m_pcie_tlp_tlast <= 1'b1;
						if(rend != 0) 
							m_pcie_tlp_tkeep <= {{DATA_BYTES{1'b1}}} >> (DATA_BYTES - rend);
						else
							m_pcie_tlp_tkeep <= '1;
				    end
				    do begin 
						@(posedge m_pcie_tlp_clk);
					end while(m_pcie_tlp_tready !== 1'b1);
					resetALL();
				end
				else begin 
				    @(posedge m_pcie_tlp_clk) begin 
				        m_pcie_tlp_tvalid <= '1;
				    	m_pcie_tlp_tkeep  <= '1;
				    	m_pcie_tlp_tlast  <= '0; 
						if(DATA_WIDTH != 32)
							m_pcie_tlp_tdata  <= {<<32{mdata_q.pop_front()}};
						else
							m_pcie_tlp_tdata  <= mdata_q.pop_front();
				    end
				    while(mdata_q.size() > 0 ) begin
				    	do begin
				            @(posedge m_pcie_tlp_clk);
				    	end while(m_pcie_tlp_tready !== 1'b1);
				    	if(m_pcie_tlp_tvalid === 1'b1 && m_pcie_tlp_tready === 1'b1) begin 
							if(DATA_WIDTH != 32)
								m_pcie_tlp_tdata  <= {<<32{mdata_q.pop_front()}};
							else
								m_pcie_tlp_tdata  <= mdata_q.pop_front();
				    		if(mdata_q.size() == 0) begin 
				    			m_pcie_tlp_tlast <= 1'b1;
				    			if(rend != 0)
				    				m_pcie_tlp_tkeep <= {{DATA_BYTES{1'b1}}} >> (DATA_BYTES - rend);
				    			else
				    				m_pcie_tlp_tkeep <= '1;
								do begin
									@(posedge m_pcie_tlp_clk);
								end while(m_pcie_tlp_tready !== 1'b1);
				    		end
				    	end
						if(m_pcie_tlp_tvalid_cfg == 1) begin 
							m_pcie_tlp_tvalid <=  1'b1;
						end
						else begin 
							if(m_pcie_tlp_tvalid === 1'b0)
								m_pcie_tlp_tvalid <= ($urandom_range(0,10) > 0) ? 1'b1 : 1'b0 ;
							else if(m_pcie_tlp_tready === 1'b1)
								m_pcie_tlp_tvalid <= ($urandom_range(0,10) > 0) ? 1'b1 : 1'b0 ;
						end
				    end
					resetALL();
				end
			end
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
			pcie_tlp_pkt m_pkt;/*{{{*/
			@(trigger_mon);
	        m_pkt = m_pkt_q.pop_front();
			$cast(pkt,m_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
			@(posedge m_pcie_tlp_clk) begin 
				m_pcie_tlp_tvalid <= '0; /*{{{*/
				m_pcie_tlp_tdata  <= '0; 
				m_pcie_tlp_tstrb  <= '0; 
				m_pcie_tlp_tkeep  <= '0; 
				m_pcie_tlp_tlast  <= '0; 
				m_pcie_tlp_tid    <= '0; 
				m_pcie_tlp_tdest  <= '0; 
				m_pcie_tlp_tuser  <= '0; /*}}}*/
		    end
		endtask:resetBUS

		task resetALL();
			m_pcie_tlp_tvalid <= '0; /*{{{*/
			m_pcie_tlp_tdata  <= '0; 
			m_pcie_tlp_tstrb  <= '0; 
			m_pcie_tlp_tkeep  <= '0; 
			m_pcie_tlp_tlast  <= '0; 
			m_pcie_tlp_tid    <= '0; 
			m_pcie_tlp_tdest  <= '0; 
			m_pcie_tlp_tuser  <= '0; /*}}}*/
		endtask:resetALL

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = new($sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


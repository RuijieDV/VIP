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
//     FileName: axi4st_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-04 10:41:57
//      History:
//============================================================================*/
`ifndef AXI4ST_IF__SV
`define AXI4ST_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface axi4st_if (); 
	parameter  string  IF_NAME      = "AXI4ST_IF"   ;  
	parameter  int     DATA_WIDTH   = 256           ;//32-64-128-256
	parameter  int     TID_WIDTH    = 32            ;//      
	parameter  int     TDST_WIDTH   = 16            ;//      
	parameter  int     TUSR_WIDTH   = 32            ;//
	localparam int     DATA_BYTES   = DATA_WIDTH/8  ;
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::axi4st_pkt;
    //########################################################
	logic                         m_axi4st_clk    ;//input 
	logic                         m_axi4st_rst_n  ;//input 
	logic                         m_axi4st_tvalid ;//output 
	logic                         m_axi4st_tready ;//input
	logic  [DATA_WIDTH-1 : 0]     m_axi4st_tdata  ;//output 
	logic  [DATA_BYTES-1 : 0]     m_axi4st_tstrb  ;//output 
	logic  [DATA_BYTES-1 : 0]     m_axi4st_tkeep  ;//output 
	logic                         m_axi4st_tlast  ;//output 
	logic  [ TID_WIDTH-1 : 0]     m_axi4st_tid    ;//output 
	logic  [TDST_WIDTH-1 : 0]     m_axi4st_tdest  ;//output 
	logic  [TUSR_WIDTH-1 : 0]     m_axi4st_tuser  ;//output 
	//########################################################
	logic                         s_axi4st_clk    ;//input 
	logic                         s_axi4st_rst_n  ;//input 
	logic                         s_axi4st_tvalid ;//input 
	logic                         s_axi4st_tready ;//output
	logic  [DATA_WIDTH-1 : 0]     s_axi4st_tdata  ;//input 
	logic  [DATA_BYTES-1 : 0]     s_axi4st_tstrb  ;//input 
	logic  [DATA_BYTES-1 : 0]     s_axi4st_tkeep  ;//input 
	logic                         s_axi4st_tlast  ;//input 
	logic  [ TID_WIDTH-1 : 0]     s_axi4st_tid    ;//input 
	logic  [TDST_WIDTH-1 : 0]     s_axi4st_tdest  ;//input 
	logic  [TUSR_WIDTH-1 : 0]     s_axi4st_tuser  ;//input 
	//########################################################
	//CRC IF option
    logic                         crc_valid       ;//output
	logic                         crc_pass_fail_n ;//output
	//########################################################
	//Native Flow Control
	logic                         s_axi4st_nfc_clk      ;//input
	logic                         s_axi4st_nfc_tx_tvalid;//input
	logic                         s_axi4st_nfc_tx_tready;//output
	logic  [15:0]                 s_axi4st_nfc_tx_tdata ;//input
	//########################################################
    `ifdef AXI4ST_IF_LPB
	    initial begin 
			m_axi4st_rst_n = 0;
			m_axi4st_clk = 0;
			#10ns;
			m_axi4st_rst_n = 1;
			forever #5ns m_axi4st_clk = ~m_axi4st_clk;
		end
		assign s_axi4st_clk    = m_axi4st_clk    ;
     	assign s_axi4st_rst_n  = m_axi4st_rst_n  ;
     	assign s_axi4st_tvalid = m_axi4st_tvalid ;
     	assign m_axi4st_tready = s_axi4st_tready ;
     	assign s_axi4st_tdata  = m_axi4st_tdata  ;
     	assign s_axi4st_tstrb  = m_axi4st_tstrb  ;
     	assign s_axi4st_tkeep  = m_axi4st_tkeep  ;
     	assign s_axi4st_tlast  = m_axi4st_tlast  ;
     	assign s_axi4st_tid    = m_axi4st_tid    ;
     	assign s_axi4st_tdest  = m_axi4st_tdest  ;
     	assign s_axi4st_tuser  = m_axi4st_tuser  ;
    `endif
	//########################################################
	//########################################################
	//clocking
	//clocking m_cb @(posedge m_axi4st_clk);
	//	default input #1step output posedge;
	//	output m_axi4st_tvalid; 
	//	input  m_axi4st_tready; 
	//	output m_axi4st_tdata ; 
	//	output m_axi4st_tstrb ; 
	//	output m_axi4st_tkeep ; 
	//	output m_axi4st_tlast ; 
	//	output m_axi4st_tid   ; 
	//	output m_axi4st_tdest ; 
	//	output m_axi4st_tuser ; 
	//endclocking
	//
	//clocking s_cb @(posedge s_axi4st_clk);
	//	default input #1step output posedge;
	//	input  s_axi4st_tvalid ;
	//	output s_axi4st_tready ;
	//	input  s_axi4st_tdata  ;
	//	input  s_axi4st_tstrb  ;
	//	input  s_axi4st_tkeep  ;
	//	input  s_axi4st_tlast  ;
	//	input  s_axi4st_tid    ;
	//	input  s_axi4st_tdest  ;
	//	input  s_axi4st_tuser  ;
	//endclocking
	//########################################################
	bit s_axi4st_nfc_tx_tready_cfg = 1; 
    initial begin:NFC
		fork
		    begin
				bit [15:0] nfc_data;
				forever begin
					do begin
						@(posedge s_axi4st_nfc_clk);
					end while((s_axi4st_nfc_tx_tready&&s_axi4st_nfc_tx_tvalid) !== 1);
					nfc_data = s_axi4st_nfc_tx_tdata;
				end
			end
		    begin
				forever begin
					if(s_axi4st_nfc_tx_tready_cfg == 1)
						@(posedge s_axi4st_nfc_clk)  s_axi4st_nfc_tx_tready <= '1;
					else 
						@(posedge s_axi4st_nfc_clk)  s_axi4st_nfc_tx_tready <= ($urandom_range(0,10) > 0) ? '1 : '0;
				end
			end
		join
	end
	//########################################################
	bit m_crc_error_cfg = 0; 
	assign crc_valid = m_axi4st_tlast&m_axi4st_tvalid&m_axi4st_tready;
	assign crc_pass_fail_n = (m_crc_error_cfg == 1) ? '0 : '1;
	//########################################################
	bit s_axi4st_tready_cfg = 1; 
	//########################################################
	axi4st_pkt m_pkt_q[$];
	event trigger_mon;
    initial begin:MON
		fork
			forever begin
 				fork/*{{{*/
				    begin 
						axi4st_pkt m_pkt;
						logic [DATA_WIDTH-1:0] mdata_q[$];
						logic [DATA_WIDTH-1:0] mdata;
						int mdata_qz;
						int m_tkeep_num;
						mdata_q.delete();
						while(1) begin
							do begin
								@(posedge s_axi4st_clk);
							end while((s_axi4st_tready&&s_axi4st_tvalid) !== 1);
							//$display("%t:lixu,%b",$time,{s_axi4st_tready,s_axi4st_tvalid});
							if(DATA_WIDTH > 32)
								mdata_q.push_back({<<8{s_axi4st_tdata}});
							else
								mdata_q.push_back(s_axi4st_tdata);
							if(s_axi4st_tlast !== 1'b1) begin 
								if(s_axi4st_tkeep !== '1)
									`uvm_error(IF_NAME,$sformatf("s_axi4st_tkeep[%0b] != '1",s_axi4st_tkeep))
							end
							else begin 
								m_pkt = `CREATE_OBJ(axi4st_pkt,"m_pkt")
								mdata_qz = mdata_q.size() - 1;
								for(int i=0;i<mdata_qz;i++) begin 
        	                        mdata = mdata_q.pop_front();
									for(int j=0;j<DATA_BYTES;j++)
										m_pkt.axi4st_data.push_back(mdata[DATA_WIDTH-1-8*j -:8]);
								end
								m_tkeep_num = $countones(s_axi4st_tkeep);
        	                    mdata = mdata_q.pop_front();
								for(int j=0;j<m_tkeep_num;j++) begin 
									m_pkt.axi4st_data.push_back(mdata[DATA_WIDTH-1-8*j -:8]);
								end
								m_pkt_q.push_back(m_pkt);
								mdata_q.delete();
								#0;
								->trigger_mon;
							end
						end 
					end
				    begin 
					    @(negedge s_axi4st_rst_n);
					end
				join_any
				disable fork;/*}}}*/
			end
		    begin
				int cnt;
				cnt = 0;
				forever begin 
				    if(s_axi4st_tready_cfg == 1)
						@(posedge s_axi4st_clk)  s_axi4st_tready <= '1;
					else if(s_axi4st_tready_cfg == 2) begin 
						@(posedge s_axi4st_clk) cnt++; 
						if(cnt == 33) begin
							s_axi4st_tready <= '0;
							cnt = 0;
						end
						else
							s_axi4st_tready <= '1;
					end
					else 
						@(posedge s_axi4st_clk)  s_axi4st_tready <= ($urandom_range(0,10) > 0) ? '1 : '0;
	        	end
			end
		join
	end
	//########################################################
	bit m_axi4st_tvalid_cfg = 1; 
	//########################################################
	class concrete_if extends abstract_if;

        typedef logic [DATA_WIDTH-1:0] mdata_q_t[$];
		function new(string name = "concrete_if");
			super.new(name);
		endfunction
		
		`uvm_if_utils(concrete_if,$sformatf("%0s",IF_NAME))
		
		task clean_up();//must no time delay
			resetALL();
			s_axi4st_nfc_tx_tready <= '0;
			s_axi4st_tready_cfg = '1;
			m_axi4st_tvalid_cfg = '1;
			m_crc_error_cfg = '0;
		endtask:clean_up 

		task drvInit();
            resetBUS();
			s_axi4st_nfc_tx_tready <= '0;
		endtask
		
		task sentPkt(input uvm_sequence_item pkt,input uvm_object cfg = null); 
			axi4st_pkt m_pkt;
			int sz,mod,rend,mdata_sz;
		    logic [DATA_WIDTH-1:0] mdata[];
			logic [DATA_WIDTH-1:0] mdata_q[$];
			wait(m_axi4st_rst_n == 1);
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				//###############################################################################
				s_axi4st_tready_cfg = m_pkt.s_axi4st_tready_cfg;
				m_axi4st_tvalid_cfg = m_pkt.m_axi4st_tvalid_cfg;
				m_crc_error_cfg = m_pkt.crc_error;
				//###############################################################################
				sz = m_pkt.axi4st_data.size();/*{{{*/
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
			    			mdata[i][DATA_WIDTH-1-8*j -:8] = m_pkt.axi4st_data.pop_front();
			    		else begin 
			    	        if(j < rend)
			    	        	mdata[mod][DATA_WIDTH-1-8*j -:8] = m_pkt.axi4st_data.pop_front();
			    	        else
			    	        	mdata[mod][DATA_WIDTH-1-8*j -:8] = 'x;
			    		end
			    	end
			    end
                mdata_q = mdata_q_t'(mdata);/*}}}*/
				//$display("lixu:%p",mdata_q);
				//###############################################################################
				fork
				    begin
						if(mdata_q.size() == 1) begin 
                    	    @(posedge m_axi4st_clk) begin 
				    	        m_axi4st_tvalid <= 1'b1;
								if(DATA_WIDTH > 32) begin
				    				m_axi4st_tdata  <= {>>8{mdata_q.pop_front()}};//@2017.10.11 revised from << to >>
								end
				    			else
				    				m_axi4st_tdata  <= mdata_q.pop_front();
				    			m_axi4st_tlast <= 1'b1;
				    			if(rend != 0) 
				    				m_axi4st_tkeep <= {{DATA_BYTES{1'b1}}} >> (DATA_BYTES - rend);
				    			else
				    				m_axi4st_tkeep <= '1;
				    	    end
							//revised @2017.10.11 for tlast always valid
				    	    //do begin 
				    		//	@(posedge m_axi4st_clk);
				    		//end while(m_axi4st_tready !== 1'b1);
				    		//resetALL();
				    	end 
				    	else if(mdata_q.size() > 1) begin 
				    	    @(posedge m_axi4st_clk) begin 
				    	        m_axi4st_tvalid <= '1;
				    	    	m_axi4st_tkeep  <= '1;
				    	    	m_axi4st_tlast  <= '0; 
				    			if(DATA_WIDTH > 32)
				    				m_axi4st_tdata  <= {<<8{mdata_q.pop_front()}};
				    			else
				    				m_axi4st_tdata  <= mdata_q.pop_front();
				    	    end
				    	    while(mdata_q.size() > 0 ) begin
				    	    	do begin
				    	            @(posedge m_axi4st_clk);
				    	    	end while(m_axi4st_tready !== 1'b1);
				    	    	if(m_axi4st_tvalid === 1'b1 && m_axi4st_tready === 1'b1) begin 
				    				if(DATA_WIDTH > 32)
				    					m_axi4st_tdata  <= {<<8{mdata_q.pop_front()}};
				    				else
				    					m_axi4st_tdata  <= mdata_q.pop_front();
				    	    		if(mdata_q.size() == 0) begin 
				    	    			m_axi4st_tlast <= 1'b1;							
				    	    			if(rend != 0)
				    	    				m_axi4st_tkeep <= {{DATA_BYTES{1'b1}}} >> (DATA_BYTES - rend);
				    	    			else
				    	    				m_axi4st_tkeep <= '1;
				    					//do begin //revised for back2back @1017.12.1
				    					//	@(posedge m_axi4st_clk);
				    					//end while(m_axi4st_tready !== 1'b1);
				    	    		end
				    	    	end
				    			if(m_axi4st_tvalid_cfg == 1) begin 
				    				m_axi4st_tvalid <=  1'b1;
				    			end
				    			else begin 
				    				if(m_axi4st_tvalid === 1'b0)
				    					m_axi4st_tvalid <= ($urandom_range(0,10) > 0) ? 1'b1 : 1'b0 ;
				    				else if(m_axi4st_tready === 1'b1)
				    					m_axi4st_tvalid <= ($urandom_range(0,10) > 0) ? 1'b1 : 1'b0 ;
				    			end
				    	    end
				    		//resetALL(); //revised for back2back @1017.12.1
				    	end
					end
				join
			end
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
			axi4st_pkt m_pkt;/*{{{*/
			@(trigger_mon);
	        m_pkt = m_pkt_q.pop_front();
			$cast(pkt,m_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
			@(posedge m_axi4st_clk) begin 
				m_axi4st_tvalid <= '0; /*{{{*/
				m_axi4st_tdata  <= '0; 
				m_axi4st_tstrb  <= '0; 
				m_axi4st_tkeep  <= '0; 
				m_axi4st_tlast  <= '0; 
				m_axi4st_tid    <= '0; 
				m_axi4st_tdest  <= '0; 
				m_axi4st_tuser  <= '0;/*}}}*/ 
		    end
		endtask:resetBUS

		task resetALL();
			m_axi4st_tvalid <= '0; /*{{{*/
			m_axi4st_tdata  <= '0; 
			m_axi4st_tstrb  <= '0; 
			m_axi4st_tkeep  <= '0; 
			m_axi4st_tlast  <= '0; 
			m_axi4st_tid    <= '0; 
			m_axi4st_tdest  <= '0; 
			m_axi4st_tuser  <= '0;/*}}}*/ 
		endtask:resetALL

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = `CREATE_OBJ(concrete_if,$sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


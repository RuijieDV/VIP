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
//     FileName: xlgmii_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 12:22:25
//      History:
//============================================================================*/
`ifndef XLGMII_IF__SV
`define XLGMII_IF__SV


`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface xlgmii_if (); 
	parameter  string  IF_NAME      = "XLGMII_IF"   ;  
	parameter  int     DATA_WIDTH   = 128          ;//32-64-128 
	localparam int     CTRL_WIDTH   = DATA_WIDTH/8 ;//
	localparam         CLK_PERIOD   = 3.2          ;/*ns*/  
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::xlgmii_pkt;
    //########################################################
	logic                         xlgmii_txclk      ;//output
	logic  [DATA_WIDTH-1 : 0]     xlgmii_txd        ;//input 
	logic  [CTRL_WIDTH-1 : 0]     xlgmii_txc        ;//input 
	//########################################################
	logic                         xlgmii_rxclk      ;//output 
	logic  [DATA_WIDTH-1 : 0]     xlgmii_rxd        ;//output 
	logic  [CTRL_WIDTH-1 : 0]     xlgmii_rxc        ;//output 
	//########################################################
	//########################################################
	`ifdef XLGMII_LPB
		initial begin xlgmii_rxclk = 0;
			#(($urandom_range(1,10)*10)*1ns);
			forever #(CLK_PERIOD/2) xlgmii_rxclk = ~xlgmii_rxclk;
		end
		assign xlgmii_txclk  = xlgmii_rxclk  ;
	`endif

	//########################################################
	xlgmii_pkt m_pkt_q[$];
	event trigger_mon;
	initial begin:MON
	 	fork/*{{{*/
			begin
				xlgmii_pkt m_pkt;
				bit m_start;
				int m_start_pkt;
				bit m_err;
				bit m_term;
				logic [7:0] m_dtq[$];
				forever begin
					while(1) begin
						@(posedge xlgmii_txclk) begin 
							if(m_start == 0) begin
								for(int i=0;i<CTRL_WIDTH;i++) begin
									if(i%4==0) begin
										if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i+:8] == 8'hFB) begin 
											m_start = 1'b1;
											m_start_pkt = (i+1)%(CTRL_WIDTH);
											m_dtq.push_back(xlgmii_txd[8*i+:8]);//push start into queue
										end
									end
									else begin 
										if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i+:8] == 8'hFB) 
											`uvm_error(IF_NAME,"You get start signal not align by 4byes!!!")
									end
								end
							end
							if(m_start == 1) begin 
								for(int i=m_start_pkt;i<CTRL_WIDTH;i++) begin 
									if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i+:8] == 8'hFB) begin 
										m_err = 1'b1;
										m_dtq.push_back(xlgmii_txd[8*i +:8]);//push err into queue
										`uvm_error(IF_NAME,"You get restart signal before terminal!!!")
									end
									if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i +:8] == 8'hFE) begin 
										m_err = 1'b1;
										m_dtq.push_back(xlgmii_txd[8*i +:8]);//push err into queue
										`uvm_error(IF_NAME,"You get inband error signal!!!")
									end
									if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i +:8] == 8'hFD) begin 
										m_term = 1;
										m_pkt = `CREATE_OBJ(xlgmii_pkt,"m_pkt")
										m_pkt.xlgmii_data = m_dtq;
										m_pkt.xlgmii_err  = m_err;
										m_pkt_q.push_back(m_pkt);
										#0;
										->trigger_mon;
										break;
									end
									if(xlgmii_txc[i] == '0) begin 
										m_dtq.push_back(xlgmii_txd[8*i +:8]);
									end
								end
							end
							m_start_pkt = 0;
							if(m_term == 1) begin 
								break;
							end
						end
					end
					m_dtq.delete();
					m_start = 0;
					m_term = 0;
					m_err = 0;
				    m_start_pkt = 0;
				end 
				begin:CHECK
					forever begin
						@(posedge xlgmii_txclk) begin 
							for(int i=0;i<CTRL_WIDTH;i++) begin
								if(xlgmii_txc[i] == '1 && xlgmii_txd[8*i+:8] inside {[8'h0:8'h6],[8'h8:8'hFA],8'hFC,8'hFF}) begin
									`uvm_error(IF_NAME,$sformatf("You get unsupport value[%0h] when xlgmii_txc == 1!!!!!",xlgmii_txd[8*i+:8]))
							end
						end
					end
				end
			end
			end
		join/*}}}*/
	end
	//########################################################
	class concrete_if extends abstract_if;

		function new(string name = "concrete_if");
			super.new(name);
		endfunction
		
		`uvm_if_utils(concrete_if,$sformatf("%0s",IF_NAME))
		
		task clean_up();//must no time delay
			resetALL();
		endtask:clean_up 

		task drvInit();
            resetBUS();
		endtask
		
		task sentPkt(input uvm_sequence_item pkt,input uvm_object cfg = null); 
			xlgmii_pkt m_pkt;/*{{{*/
			static bit first_pkt = 1;
			static int next_pkt = 0;
			logic [7:0] xlgmii_dq[$];
			bit xlgmii_dc[$];
			int xlgmii_ipg;
			bit xlgmii_err;
			int xlgmii_psz;
			int xlgmii_sz;
			int xlgmii_rend;
			int xlgmii_err_cnt;
			int xlgmii_first;
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				//###############################################################################
                xlgmii_dq    = m_pkt.xlgmii_data;
				xlgmii_first = m_pkt.xlgmii_first;
				xlgmii_ipg   = m_pkt.xlgmii_ipg;
				xlgmii_err   = m_pkt.xlgmii_err;
				xlgmii_psz   = xlgmii_dq.size();
				//################################################
				for(int i=0;i<xlgmii_psz;i++)
					xlgmii_dc.push_back(1'b0);
				xlgmii_dq[0] = 8'hFB;//replace first preamble as Start
				xlgmii_dc[0] = 1'b1;
                //################################################
				if(xlgmii_err == 1) begin 
					xlgmii_err_cnt = $urandom_range(1,xlgmii_dq.size()-1);
					xlgmii_dq[xlgmii_err_cnt] = 8'hFE;
					xlgmii_dc[xlgmii_err_cnt] = 1'b1;
				end
				//################################################
				for(int i=0;i<xlgmii_ipg;i++) begin 
					if(i==0) begin
						xlgmii_dq.push_back(8'hFD);//Terminate
						xlgmii_dc.push_back(1'b1);//Terminate
					end
					else begin
						xlgmii_dq.push_back(8'h07);//IPG
						xlgmii_dc.push_back(1'b1);//IPG
					end
				end
				while((xlgmii_dq.size()%4) != 0) begin 
					xlgmii_dq.push_back(8'h07);//to enable start%4==0
					xlgmii_dc.push_back(1'b1);
				end
				//################################################
				//insert idle first pkt
				if(first_pkt == 1) begin
					for(int i=0;i<(xlgmii_first%CTRL_WIDTH);i++) begin 
						xlgmii_dq.push_front(8'h07);
						xlgmii_dc.push_front(1'b1);
					end
					first_pkt = 0;
				end
				//###############################################################################
				xlgmii_sz  = xlgmii_dq.size()/(CTRL_WIDTH);
				xlgmii_rend= xlgmii_dq.size()%(CTRL_WIDTH);
				if(xlgmii_sz == 0)
					`uvm_fatal(IF_NAME,"You get xlgmii data size less than 8bytes!!!")
				//###############################################################################
				fork
				    begin
						while(xlgmii_dq.size() != 0) begin
							if(next_pkt == 0) begin 
								@(negedge xlgmii_rxclk);
								@(posedge xlgmii_rxclk);
							end
							for(int j=next_pkt;j<CTRL_WIDTH;j++) begin 
								if(xlgmii_dq.size() > 0 ) begin
									xlgmii_rxd[8*j +:8] <= xlgmii_dq.pop_front();
									xlgmii_rxc[j +: 1] <= xlgmii_dc.pop_front();
									if(j==CTRL_WIDTH-1)
										next_pkt = 0;
								end
								else begin 
									next_pkt = j%CTRL_WIDTH;
									break;
								end
							end
						end
					end
				join
			end/*}}}*/
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
 			xlgmii_pkt m_pkt;/*{{{*/
			@(trigger_mon);
	        m_pkt = m_pkt_q.pop_front();
			$cast(pkt,m_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
			/*{{{*/
			@(negedge xlgmii_rxclk) begin 
				xlgmii_rxd <= {CTRL_WIDTH{8'h07}};//idle
				xlgmii_rxc <= '1;//output 
		    end
			/*}}}*/
		endtask:resetBUS

		task resetALL();
			/*{{{*/
			xlgmii_rxd <= {CTRL_WIDTH{8'h07}};//idle
			xlgmii_rxc <= '1;//output 
			/*}}}*/
		endtask:resetALL

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = `CREATE_OBJ(concrete_if,$sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


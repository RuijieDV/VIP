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
//     FileName: gmii_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 14:54:13
//      History:
//============================================================================*/
`ifndef GMII_IF__SV
`define GMII_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface gmii_if (); 
	parameter  string  IF_NAME      = "GMII_IF"    ;  
	parameter  int     DATA_WIDTH   = 8            ;//8
	localparam         CLK_PERIOD   = 8            ;//125MHz:25MHz:2.5MHz(1000/100/10Mb/s)/  
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::gmii_pkt;
    //########################################################
	logic                         gmii_txclk      ;//output
	logic  [DATA_WIDTH-1 : 0]     gmii_txd        ;//input 
	logic                         gmii_txen       ;//input 
	logic                         gmii_txerr      ;//input 
	//########################################################
	logic                         gmii_rxclk      ;//output 
	logic  [DATA_WIDTH-1 : 0]     gmii_rxd        ;//output 
	logic                         gmii_rxdv       ;//output 
	logic                         gmii_rxerr      ;//output 
	//########################################################
	logic                         gmii_crs        ;//output 
	logic                         gmii_col        ;//output 
	//########################################################
	`ifdef GMII_LPB
		initial begin 
			gmii_rxclk = 0;
			#(($urandom_range(1,10)*10)*1ns);
			forever #(CLK_PERIOD/2) gmii_rxclk = ~gmii_rxclk;
		end
		assign gmii_txclk  = gmii_rxclk  ;
	`endif
	//########################################################
	gmii_pkt m_pkt_q[$];
	event trigger_mon;
    initial begin:MON
		fork/*{{{*/
			begin
				gmii_pkt m_pkt;
				bit m_err;
				bit m_start;
				logic [DATA_WIDTH-1:0] m_dtq[$];
				forever begin
					while(1) begin
						@(posedge gmii_txclk) begin 
							if(gmii_txen == '1) begin 
								m_dtq.push_back(gmii_txd);
								if(gmii_txerr == '1)
									m_err = 1;
								m_start = 1;
							end
							else if(m_start == 1) begin 
								m_pkt = `CREATE_OBJ(gmii_pkt,"m_pkt")
								m_pkt.gmii_data = m_dtq;
								m_pkt.gmii_err  = m_err;
								m_pkt_q.push_back(m_pkt);
								#0;
								->trigger_mon;
								break;
							end
							else
								break;
						end
					end
					m_dtq.delete();
					m_err = 0;
					m_start = 0;
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
			gmii_pkt m_pkt;/*{{{*/
			logic [DATA_WIDTH-1:0] m_dtq[$];
			int m_ipg;
			bit m_err;
			int m_sz;
			int m_err_cnt;
			bit m_crs;
			bit m_col;
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				m_dtq = m_pkt.gmii_data;
				m_ipg = m_pkt.gmii_ipg;
				m_err = m_pkt.gmii_err;
				m_crs = m_pkt.gmii_crs;
				m_col = m_pkt.gmii_col;
				m_sz  = m_pkt.gmii_data.size();
				if(m_err == 1'b1) begin 
					m_err_cnt = $urandom_range(0,m_sz-1);
				end
				//###############################################################################
				fork
				    begin
						for(int i=0;i<m_sz;++i) begin 
							@(posedge gmii_rxclk) begin 
								gmii_rxdv <= '1;
								gmii_rxd  <= m_dtq.pop_front();
								if(m_err == 1) begin
									if(i >= m_err_cnt && i <= $urandom_range(m_err_cnt,m_err_cnt+3))
										gmii_rxerr <= '1;
									else
										gmii_rxerr <= '0;
								end
							end
						end
						@(posedge gmii_rxclk) begin
							gmii_rxdv <= '0;
							gmii_rxd  <= '0;
							gmii_rxerr<= '0;
						end
						repeat(m_ipg-1) @(posedge gmii_rxclk);
					end
					//##########################################
					begin 
						if(m_crs == '1) begin 
							gmii_crs <= '1;
						end
					end
					begin
						if(m_col == '1) begin 
							gmii_col <= '1;
						end
					end
					//##########################################
				join
			end /*}}}*/
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
			gmii_pkt m_pkt;/*{{{*/
			@(trigger_mon);
	        m_pkt = m_pkt_q.pop_front();
			$cast(pkt,m_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
			/*{{{*/
			@(negedge gmii_rxclk) begin 
				gmii_rxd   <= '0;//output 
				gmii_rxdv  <= '0;//output 
				gmii_rxerr <= '0;//output 
				gmii_crs   <= '0;//output
				gmii_col   <= '0;//output 
		    end
			/*}}}*/
		endtask:resetBUS

		task resetALL();
			/*{{{*/
			gmii_rxd   <= '0;//output
			gmii_rxdv  <= '0;//output 
			gmii_rxerr <= '0;//output 
			gmii_crs   <= '0;//output
			gmii_col   <= '0;//output 
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


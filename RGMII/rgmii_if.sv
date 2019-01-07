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
//     FileName: rgmii_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-30 09:10:45
//      History:
//============================================================================*/
`ifndef RGMII_IF__SV
`define RGMII_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface rgmii_if (); 
	parameter  string  IF_NAME      = "RGMII_IF"   ;  
	parameter  int     DATA_WIDTH   = 4            ;//
	localparam         CLK_PERIOD   = 8            ;//125MHz:25MHz:2.5MHz(1000/100/10Mb/s)/  
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::rgmii_pkt;
    //########################################################
	logic                         rgmii_txclk      ;//output
	logic  [DATA_WIDTH-1 : 0]     rgmii_txd        ;//input 
	logic                         rgmii_txc        ;//input 
	//########################################################
	logic                         rgmii_rxclk      ;//output 
	logic  [DATA_WIDTH-1 : 0]     rgmii_rxd        ;//output 
	logic                         rgmii_rxc        ;//output 
	//########################################################
	`ifdef RGMII
		initial begin 
			rgmii_rxclk = 0;
			#(($urandom_range(1,10)*10)*1ns);
			forever #(CLK_PERIOD/2) rgmii_rxclk = ~rgmii_rxclk;
		end
		always @(*)
		  rgmii_txclk <= #0.1 rgmii_rxclk;
	`endif
	//########################################################
	rgmii_pkt m_pkt_q[$];
	event trigger_mon;
    initial begin:MON
		fork/*{{{*/
			begin
				rgmii_pkt m_pkt;
				bit m_err;
				bit m_start;
				bit m_term;
				int m_sz;
				logic [DATA_WIDTH-1:0] m_dtq[$];
				forever begin
					while(1) begin
						@(posedge rgmii_txclk) begin 
						    if(rgmii_txc == '1) begin 
								m_start = 1;
								m_dtq.push_back(rgmii_txd);
							end
							if(m_start == 1 && rgmii_txc == '0) begin 
								m_term = 1;
								break;
							end
						end
						@(negedge rgmii_txclk) begin 
							if(m_start == 1 && rgmii_txc == '0) begin 
								m_dtq.push_back(rgmii_txd);
								m_err = 1;
							end
							else if(m_start == 1 && rgmii_txc == '1) begin 
								m_dtq.push_back(rgmii_txd);
							end
						end
					end
					if(m_term == 1) begin
						m_pkt = `CREATE_OBJ(rgmii_pkt,"m_pkt")
						m_sz = m_dtq.size();
						if(m_sz%2 != 0)
							`uvm_error(IF_NAME,"You recv data que size not 2 mode!!!")
						for(int i=0;i<m_sz/2;i++) begin 
							m_pkt.rgmii_data.push_back({m_dtq[2*i+1],m_dtq[2*i]});
						end
						m_pkt.rgmii_err  = m_err;
						m_pkt_q.push_back(m_pkt);
						#0;
						->trigger_mon;
					end
					m_dtq.delete();
					m_err = 0;
					m_start = 0;
					m_term = 0;
				end 
			end
		join/*}}}*/
	end
	//########################################################
	class concrete_if extends abstract_if;

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
 			rgmii_pkt m_pkt;/*{{{*/
			logic [DATA_WIDTH-1:0] m_dtq[$];
			int m_ipg;
			bit m_err;
			int m_sz;
			int m_err_cnt;
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				m_sz  = m_pkt.rgmii_data.size();
				for(int i=0;i<m_sz;i++) begin 
					m_dtq.push_back(m_pkt.rgmii_data[i][3:0]);
					m_dtq.push_back(m_pkt.rgmii_data[i][7:4]);
				end
				m_ipg = m_pkt.rgmii_ipg;
				m_err = m_pkt.rgmii_err;
				if(m_err == 1'b1) begin 
					m_err_cnt = $urandom_range(0,m_sz-1);
				end
				//###############################################################################
				fork
				    begin
						for(int i=0;i<m_sz;++i) begin 
							@(posedge rgmii_rxclk) begin 
								rgmii_rxd  <= m_dtq.pop_front();
								rgmii_rxc <= '1;
							end
							@(negedge rgmii_rxclk) begin 
								rgmii_rxd  <= m_dtq.pop_front();
								if(m_err == 1) begin 
									if(i == m_err_cnt)
										rgmii_rxc <= '0;
								end
								else
									rgmii_rxc <= '1;
							end
						end
						@(posedge rgmii_rxclk) begin
							rgmii_rxc <= '0;
							rgmii_rxd  <= '0;
						end
						repeat(m_ipg-1) @(posedge rgmii_rxclk);
					end
					//##########################################
				join
			end /*}}}*/
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
			rgmii_pkt m_pkt;/*{{{*/
			@(trigger_mon);
	        m_pkt = m_pkt_q.pop_front();
			$cast(pkt,m_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
			/*{{{*/
			@(negedge rgmii_rxclk) begin 
				rgmii_rxd <= '0;//output 
				rgmii_rxc <= '0;//output 
		    end
			/*}}}*/
		endtask:resetBUS

		task resetALL();
			/*{{{*/
			rgmii_rxd <= '0;//output
			rgmii_rxc <= '0;//output 
			/*}}}*/
		endtask:resetALL

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = new($sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


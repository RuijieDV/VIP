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
//     FileName: axi4lite_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-03 17:28:16
//      History:
//============================================================================*/
`ifndef AXI4LITE_IF__SV
`define AXI4LITE_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface axi4lite_if (); 
	parameter  string  IF_NAME      = "AXI4LITE_IF"  ;  
	parameter  int     WADDR_WIDTH  = 32             ;  
	parameter  int     WDATA_WIDTH  = 32             ;  
	parameter  int     RADDR_WIDTH  = 32             ;  
	parameter  int     RDATA_WIDTH  = 32             ;  
	localparam int     WSTRB_WIDTH  = WADDR_WIDTH/8  ;
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::axi4lite_pkt;
    //########################################################
	// Master write address channel
	logic							axi4lite_clk     ;
	logic							axi4lite_arst_n  ;
	logic  [WADDR_WIDTH-1:0]        axi4lite_awaddr  ;
	logic                           axi4lite_awvalid ;
	logic                           axi4lite_awready ;
	// Master write data channel
	logic  [WDATA_WIDTH-1:0]        axi4lite_wdata   ;
	logic  [WSTRB_WIDTH-1:0]        axi4lite_wstrb   ;
	logic                           axi4lite_wvalid  ;
	logic                           axi4lite_wready  ;
	// Master write response channel
	logic  [1:0]                    axi4lite_bresp   ;
	logic                           axi4lite_bvalid  ;
	logic                           axi4lite_bready  ;
	// Master read address channel
	logic  [RADDR_WIDTH-1:0]        axi4lite_araddr  ;
	logic                           axi4lite_arvalid ;
	logic                           axi4lite_arready ;
	// Master read data channel
	logic  [RDATA_WIDTH-1:0]        axi4lite_rdata   ;
	logic  [1:0]                    axi4lite_rresp   ;
	logic                           axi4lite_rvalid  ;
	logic                           axi4lite_rready  ;
    
	initial begin 
		axi4lite_clk = 0;
		#50ns;
		forever #2.5 axi4lite_clk = ~axi4lite_clk;
	end

	initial begin 
		axi4lite_arst_n = 1;
		#10ns;
		axi4lite_arst_n = 0;
		#100ns;
		axi4lite_arst_n = 1;
	end
	//###################################################################################
	axi4lite_pkt m_axi4lite_pkt_q[$];
	event trigger_mon;
    initial begin:MON
		axi4lite_pkt m_pkt;
		@(posedge axi4lite_arst_n);
		fork
			forever begin //WR RESP
				do begin
					@(posedge axi4lite_clk);
				end while(axi4lite_bvalid !== 1 || axi4lite_bready !== 1);
				m_pkt = `CREATE_OBJ(axi4lite_pkt,"m_pkt")
				m_pkt.axi4lite_type = axi4lite_pkt::AXI4LITE_WR;
				m_pkt.axi4lite_bresp = axi4lite_bresp;
				m_axi4lite_pkt_q.push_back(m_pkt);
				->trigger_mon;
				#0;
			end
			forever begin //RD RESP
				do begin
					@(posedge axi4lite_clk);
				end while(axi4lite_rvalid !== 1 || axi4lite_rready !== 1);
				m_pkt = `CREATE_OBJ(axi4lite_pkt,"m_pkt")
				m_pkt.axi4lite_type  = axi4lite_pkt::AXI4LITE_RD;
				m_pkt.axi4lite_rdata = axi4lite_rdata;
				m_pkt.axi4lite_rresp = axi4lite_rresp;
				m_axi4lite_pkt_q.push_back(m_pkt);
				->trigger_mon;
				#0;
			end
			begin
				forever begin 
					//@(posedge axi4lite_clk) axi4lite_bready <= $urandom_range(0,100) > 10 ? 1 : 0;
					@(negedge axi4lite_wvalid);
					@(posedge axi4lite_clk) axi4lite_bready <= 1;
					@(negedge axi4lite_bvalid)
					axi4lite_bready <= 0;
			    end
			end
			begin
				forever begin 
					//@(posedge axi4lite_clk) axi4lite_rready <= $urandom_range(0,100) > 10 ? 1 : 0;
					@(negedge axi4lite_arvalid);
					@(posedge axi4lite_clk) axi4lite_rready <= 1;
					@(negedge axi4lite_rvalid)
					axi4lite_rready <= 0;
			    end
			end
	    join
	end
	//########################################################
	//########################################################
	class concrete_if extends abstract_if;

		function new(string name = "concrete_if");
			super.new(name);
		endfunction
		
		`uvm_if_utils(concrete_if,$sformatf("%0s",IF_NAME))
		
		task clean_up();
			axi4lite_awaddr  <= '0; /*{{{*/
			axi4lite_awvalid <= '0; 
			axi4lite_wdata   <= '0; 
			axi4lite_wstrb   <= '0; 
			axi4lite_wvalid  <= '0; 
			axi4lite_bready  <= '0; 
			axi4lite_araddr  <= '0; 
			axi4lite_arvalid <= '0; 
			axi4lite_rready  <= '0;/*}}}*/
		endtask:clean_up 

		task drvInit();
			@(posedge axi4lite_arst_n);
			resetBUS();
		endtask

		task sentPkt(input uvm_sequence_item pkt,input uvm_object cfg = null); 
 			axi4lite_pkt m_pkt;/*{{{*/
			if(pkt == null) begin 
				resetBUS();
			end
			else begin 
				$cast(m_pkt,pkt.clone());
				if(m_pkt.axi4lite_type == axi4lite_pkt::AXI4LITE_WR) begin 
					
					fork
					    begin 
							axi4lite_awaddr <= m_pkt.axi4lite_awaddr;
							axi4lite_awvalid <= 1;
							while(axi4lite_awready !== 1) begin 
								@(posedge axi4lite_clk);
							end
							axi4lite_awaddr <= '0;
							axi4lite_awvalid <= 0;
						end
						begin 
						    axi4lite_wdata <= m_pkt.axi4lite_wdata;
							axi4lite_wvalid <= 1;
							while(axi4lite_wready !== 1) begin 
								@(posedge axi4lite_clk);
							end
							axi4lite_wdata <= '0;
							axi4lite_wvalid <= 0;
						end
				    join
				end
				else if(m_pkt.axi4lite_type == axi4lite_pkt::AXI4LITE_RD) begin 
					axi4lite_araddr <= m_pkt.axi4lite_araddr;
					axi4lite_arvalid <= 1;
				    while(axi4lite_arready !== 1) begin 
						@(posedge axi4lite_clk);
					end
					axi4lite_araddr <= '0;
					axi4lite_arvalid <= 0;
				end
			end /*}}}*/
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
 			axi4lite_pkt m_axi4lite_pkt;/*{{{*/
			@(trigger_mon);
	        m_axi4lite_pkt = m_axi4lite_pkt_q.pop_front();
			$cast(pkt,m_axi4lite_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS();
 			@(posedge axi4lite_clk) begin /*{{{*/
				axi4lite_awaddr  <= '0; 
				axi4lite_awvalid <= '0; 
				axi4lite_wdata   <= '0; 
				axi4lite_wstrb   <= '0; 
				axi4lite_wvalid  <= '0; 
				axi4lite_bready  <= '0; 
				axi4lite_araddr  <= '0; 
				axi4lite_arvalid <= '0; 
				axi4lite_rready  <= '0;
			end/*}}}*/ 
		endtask:resetBUS

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = `CREATE_OBJ(concrete_if,$sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


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
//     FileName: axi4lite_scoreboard.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-04 15:03:17
//      History:
//============================================================================*/
`ifndef AXI4LITE_SCOREBOARD__SV
`define AXI4LITE_SCOREBOARD__SV

class axi4lite_scoreboard extends uvm_scoreboard;

	uvm_analysis_export   #(axi4lit_pkt)  recv_axi4lite_export;
	uvm_tlm_analysis_fifo #(axi4lit_pkt)  recv_axi4lite_afifo;
	uvm_analysis_export   #(axi4lit_pkt)  sent_axi4lite_export;
	uvm_tlm_analysis_fifo #(axi4lit_pkt)  sent_axi4lite_afifo

	`uvm_component_utils_begin(compare_scoreboard)
	`uvm_component_utils_end

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		recv_axi4lite_export = new("recv_axi4lite_export", this);
		recv_axi4lite_export = new("recv_axi4lite_export", this);
		recv_axi4lite_export = new("recv_axi4lite_export", this);
		recv_axi4lite_export = new("recv_axi4lite_export", this);
    endfunction:build_phase

    function void connect_phase(uvm_phase phase);  
        super.connect_phase(phase);
	    recv_axi4lite_export.connect(recv_axi4lite_afifo.analysis_export);  
	    sent_axi4lite_export.connect(sent_axi4lite_afifo.analysis_export);  
    endfunction
					
    virtual task main_phase(uvm_phase phase);
	    fork
			forever begin
				recv_axi4lite_afifo.get(mon_pkt);
		        sent_axi4lite_afifo.get(gold_pkt);
				if(mon.data != goldpkt.xxx)
					`uvm_error
			end
		join
    endtask

endclass : compare_scoreboard

`endif

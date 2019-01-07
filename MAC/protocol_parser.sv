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
//     FileName: protocol_parser.sv 
//         Desc:  
//       Author: test
//        Email: test@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-06-06 10:46:09
//      History:
//============================================================================*/
`ifndef PROTOCOL_PARSER__SV
`define PROTOCOL_PARSER__SV


class protocol_parser extends uvm_scoreboard;

	`SET_CLASSID
	bit wr_pcap = 1;
	bit wr_pcapid = 0;
	uvm_analysis_export   #(mac_pkt)  mac_export;
	uvm_tlm_analysis_fifo #(mac_pkt)  mac_afifo;

	`uvm_component_utils_begin(protocol_parser)
	`uvm_component_utils_end

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mac_export = new("mac_export", this);
		mac_afifo = new("mac_afifo", this);
    endfunction:build_phase

    function void connect_phase(uvm_phase phase);  
        super.connect_phase(phase);
		mac_export.connect(mac_afifo.analysis_export);  
    endfunction
    
    virtual task main_phase(uvm_phase phase);
	    mac_pkt m_pkt;
		string mstr;
		fork
		    forever begin
		        mac_afifo.get(m_pkt);
				//######################################################
		        //CHECK Ethernet CRC32
				m_pkt.hexdump();
		        begin 
	            end
				m_pkt.mac_data = m_pkt.mac_data[0:$-4];
				mstr = bit8q2str(m_pkt.mac_data);
				if(sv_EthIsWhat(mstr,".payload","IP")) begin 
					//sv_WrEthPcap(mstr,"mytest.pcap");
					$display("IP-SRC:",sv_EthFieldVal(mstr,".payload",".src"));
					$display("IP-CHKSUM:",sv_EthFieldVal(mstr,".payload",".chksum"));
					//$display("%p",sv_EthHexDump(mstr,"IP"));
					$display(sv_EthLayerHexDump(mstr,".payload.payload.payload",,1));
				end

				if(wr_pcap == 1) begin 
				
				end
		    end
		join
    endtask

endclass

`endif

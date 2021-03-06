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
//     FileName: gmii_monitor.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 12:00:17
//      History:
//============================================================================*/
`ifndef GMII_MONITOR__SV
`define GMII_MONITOR__SV

class gmii_monitor extends uvm_monitor;
  
	`SET_CLASSID
	gmii_cfg  m_cfg;
	abstract_if m_gmii_vif;
	uvm_analysis_port #(gmii_pkt) m_aport;
	
	uvm_thread reset_handler;
	local uvm_thread_imp#(gmii_monitor) reset_export;

	`uvm_component_utils_begin(gmii_monitor)
        `uvm_field_object(reset_handler, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end

	function new (string name = "gmii_monitor", uvm_component parent = null);
		super.new(name, parent);
		reset_export = new("reset_export", this);
		m_aport = new("m_aport", this);
	endfunction: new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual task clean_up();
    extern virtual task main_phase_new(uvm_phase phase);
	extern virtual task collect_transactions();

endclass: gmii_monitor

function void gmii_monitor::build_phase(input uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(gmii_cfg)::get(this, "", "gmii_cfg", m_cfg)) begin
		`uvm_fatal(CLASSID, "Failed to Grab gmii_cfg from Config DB")
	end
	if (!uvm_config_db#(abstract_if)::get(this, "", "GMII_IF", m_gmii_vif)) begin
		`uvm_fatal(CLASSID, "Failed to Grab gmii_if from Config DB")
	end

	if (reset_handler == null) begin 
		if (!uvm_config_db#(uvm_thread)::get(this, "", "reset_handler", reset_handler))
			`uvm_fatal(CLASSID, "reset_handler must be specified")
	end
	reset_handler.register(reset_export, uvm_thread_pkg::default_map);
endfunction: build_phase

task gmii_monitor::main_phase(uvm_phase phase);
endtask: main_phase

task gmii_monitor::clean_up();
	`uvm_info(CLASSID, "CLEANING...........................", UVM_MEDIUM)
	disable collect_transactions;
	m_gmii_vif.clean_up();
endtask : clean_up

task gmii_monitor::main_phase_new(uvm_phase phase);
	`uvm_info(CLASSID, "Now Collecting Transactions.....................", UVM_MEDIUM)
	fork
	    collect_transactions();
    join
endtask : main_phase_new

task gmii_monitor::collect_transactions();
	uvm_sequence_item mon_item;
	gmii_pkt m_pkt;
	mac_pkt m_mac_pkt;
	bit [31:0] calc_crc32;
	bit [31:0] recv_crc32;
    forever begin 
		m_gmii_vif.recvPkt(mon_item);
		$cast(m_pkt,mon_item);
		`uvm_info(CLASSID,$sformatf("You get mon pkt:\n%0s",m_pkt.sprint()),UVM_MEDIUM)
		m_mac_pkt = `CREATE_OBJ(mac_pkt,"m_mac_pkt")
		if(m_pkt.gmii_err == 1) begin 
			`uvm_error(CLASSID,$sformatf("You receive gmii error signal!!!"))
		end
		else begin
		    calc_crc32 = CRC32(m_pkt.gmii_data[8:$-4]);
			recv_crc32 = {m_pkt.gmii_data[$-3],m_pkt.gmii_data[$-2],m_pkt.gmii_data[$-1],m_pkt.gmii_data[$]};
			if(calc_crc32 != recv_crc32) begin
				`uvm_error(CLASSID,$sformatf("You receive mac crc32[%0h] and calc mac crc32[%0h] mismatch!",recv_crc32,calc_crc32))
				m_pkt.gmii_err = 1;
			end
		end
		m_pkt.gmii_data = m_pkt.gmii_data[8:$-4];//no preamble-sfd-crc32
		m_aport.write(m_pkt);
	end
endtask : collect_transactions


`endif 

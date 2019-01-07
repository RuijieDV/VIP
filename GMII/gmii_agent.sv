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
//     FileName: gmii_agent.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 11:57:38
//      History:
//============================================================================*/
`ifndef GMII_AGENT__SV
`define GMII_AGENT__SV


class gmii_agent extends uvm_agent;

	`SET_CLASSID
	gmii_cfg m_cfg_h;
	gmii_sequencer m_sequencer;
	gmii_driver m_driver;
	gmii_monitor m_monitor;
	uvm_analysis_port#(gmii_pkt) m_driver_req_analysis_port;
  	uvm_analysis_port#(gmii_pkt) m_driver_rsp_analysis_port;

	`uvm_component_utils(gmii_agent)
	function new(string name = "gmii_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction: new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass: gmii_agent

function void gmii_agent::build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 if(!uvm_config_db#(gmii_cfg)::get(this, "", "gmii_cfg", m_cfg_h)) begin
	     `uvm_fatal(CLASSID, "Failed to Grab gmii_cfg from Config DB")
	 end
	 uvm_config_db#(gmii_cfg)::set(this, "*", "gmii_cfg", m_cfg_h);

	 if (m_cfg_h.m_uvm_active_passive_h == UVM_ACTIVE) begin
		 m_sequencer = gmii_sequencer::type_id::create("m_sequencer", this);
		 m_driver = gmii_driver::type_id::create("m_driver", this);
		 m_driver_req_analysis_port = new("m_driver_req_analysis_port", this);
		 m_driver_rsp_analysis_port = new("m_driver_rsp_analysis_port", this);
	 end
	 m_monitor = gmii_monitor::type_id::create("m_monitor", this);

endfunction: build_phase

function void gmii_agent::connect_phase(input uvm_phase phase);
	super.connect_phase(phase);
	if (m_cfg_h.m_uvm_active_passive_h == UVM_ACTIVE) begin
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		m_driver.m_req_analysis_port.connect(m_driver_req_analysis_port);
		m_driver.m_rsp_analysis_port.connect(m_driver_rsp_analysis_port);
	end

endfunction: connect_phase

`endif

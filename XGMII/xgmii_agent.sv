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
//     FileName: xgmii_agent.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 11:57:38
//      History:
//============================================================================*/
`ifndef XGMII_AGENT__SV
`define XGMII_AGENT__SV


class xgmii_agent extends uvm_agent;

	`SET_CLASSID
	xgmii_cfg m_cfg_h;
	xgmii_sequencer m_sequencer;
	xgmii_driver m_driver;
	xgmii_monitor m_monitor;
	uvm_analysis_port#(xgmii_pkt) m_driver_req_analysis_port;
  	uvm_analysis_port#(xgmii_pkt) m_driver_rsp_analysis_port;

	`uvm_component_utils(xgmii_agent)
	function new(string name = "xgmii_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction: new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass: xgmii_agent

function void xgmii_agent::build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 if(!uvm_config_db#(xgmii_cfg)::get(this, "", "xgmii_cfg", m_cfg_h)) begin
	     `uvm_fatal(CLASSID, "Failed to Grab xgmii_cfg from Config DB")
	 end
	 uvm_config_db#(xgmii_cfg)::set(this, "*", "xgmii_cfg", m_cfg_h);

	 if (m_cfg_h.m_uvm_active_passive_h == UVM_ACTIVE) begin
		 m_sequencer = xgmii_sequencer::type_id::create("m_sequencer", this);
		 m_driver = xgmii_driver::type_id::create("m_driver", this);
		 m_driver_req_analysis_port = new("m_driver_req_analysis_port", this);
		 m_driver_rsp_analysis_port = new("m_driver_rsp_analysis_port", this);
	 end
	 m_monitor = xgmii_monitor::type_id::create("m_monitor", this);

endfunction: build_phase

function void xgmii_agent::connect_phase(input uvm_phase phase);
	super.connect_phase(phase);
	if (m_cfg_h.m_uvm_active_passive_h == UVM_ACTIVE) begin
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		m_driver.m_req_analysis_port.connect(m_driver_req_analysis_port);
		m_driver.m_rsp_analysis_port.connect(m_driver_rsp_analysis_port);
	end

endfunction: connect_phase

`endif

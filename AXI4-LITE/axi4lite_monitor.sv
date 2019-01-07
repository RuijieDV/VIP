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
//     FileName: axi4lite_monitor.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-04 11:06:21
//      History:
//============================================================================*/
`ifndef AXI4LITE_MONITOR__SV
`define AXI4LITE_MONITOR__SV

class axi4lite_monitor extends uvm_monitor;
  
	`SET_CLASSID
	axi4lite_cfg  m_cfg;
	abstract_if m_axi4lite_vif;
	
	uvm_thread reset_handler;
	local uvm_thread_imp#(axi4lite_monitor) reset_export;

	`uvm_component_utils_begin(axi4lite_monitor)
        `uvm_field_object(reset_handler, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end

	function new (string name = "axi4lite_monitor", uvm_component parent = null);
		super.new(name, parent);
		reset_export = new("reset_export", this);
	endfunction: new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual task clean_up();
    extern virtual task main_phase_new(uvm_phase phase);
	extern virtual task collect_transactions();

endclass: axi4lite_monitor

function void axi4lite_monitor::build_phase(input uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(axi4lite_cfg)::get(this, "", "axi4lite_cfg", m_cfg)) begin
		`uvm_fatal(CLASSID, "Failed to Grab axi4lite_cfg from Config DB")
	end
	if (!uvm_config_db#(abstract_if)::get(this, "", "AXI4LITE_IF", m_axi4lite_vif)) begin
		`uvm_fatal(CLASSID, "Failed to Grab axi4lite_if from Config DB")
	end

	if (reset_handler == null) begin 
		if (!uvm_config_db#(uvm_thread)::get(this, "", "reset_handler", reset_handler))
			`uvm_fatal(CLASSID, "reset_handler must be specified")
	end
	reset_handler.register(reset_export, uvm_thread_pkg::default_map);
endfunction: build_phase

task axi4lite_monitor::main_phase(uvm_phase phase);
endtask: main_phase

task axi4lite_monitor::clean_up();
	`uvm_info(CLASSID, "CLEANING...........................", UVM_MEDIUM)
	disable collect_transactions;
	m_axi4lite_vif.clean_up();
endtask : clean_up

task axi4lite_monitor::main_phase_new(uvm_phase phase);
	`uvm_info(CLASSID, "Now Collecting Transactions.....................", UVM_MEDIUM)
	fork
	    collect_transactions();
    join
endtask : main_phase_new

task axi4lite_monitor::collect_transactions();
endtask : collect_transactions


`endif 

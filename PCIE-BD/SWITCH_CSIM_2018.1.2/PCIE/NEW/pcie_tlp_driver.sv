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
//     FileName: pcie_tlp_driver.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-21 17:50:29
//      History:
//============================================================================*/
`ifndef PCIE_TLP_DRIVER__SV
`define PCIE_TLP_DRIVER__SV


class pcie_tlp_driver extends uvm_driver#(pcie_tlp_pkt);

	`SET_CLASSID
	pcie_tlp_cfg  m_cfg;
	abstract_if m_pcie_tlp_vif;

	uvm_thread reset_handler;
	local uvm_thread_imp#(pcie_tlp_driver) reset_export;

	uvm_analysis_port#(pcie_tlp_pkt) m_req_analysis_port;
	uvm_analysis_port#(pcie_tlp_pkt) m_rsp_analysis_port;

	`uvm_component_utils_begin(pcie_tlp_driver)
       `uvm_field_object(reset_handler, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end 

	function new (string name = "pcie_tlp_driver", uvm_component parent = null);
		super.new(name, parent);
		reset_export = new("reset_export", this);
        m_req_analysis_port = new("m_req_analysis_port", this);
        m_rsp_analysis_port = new("m_rsp_analysis_port", this);
	endfunction: new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
    extern virtual task clean_up();
    extern virtual task main_phase_new(uvm_phase phase);

    extern virtual task drv_init();
    extern virtual task drv_interface();

endclass: pcie_tlp_driver

function void pcie_tlp_driver::build_phase(input uvm_phase phase);
	super.build_phase(phase);

	if (!uvm_config_db#(pcie_tlp_cfg)::get(this, "", "pcie_tlp_cfg", m_cfg)) begin
		`uvm_fatal(CLASSID, "Failed to Grab pcie_tlp_cfg from Config DB")
	end

	if (!uvm_config_db#(abstract_if)::get(this, "", "PCIE_TLP_IF", m_pcie_tlp_vif)) begin
		`uvm_fatal(CLASSID, "Failed to Grab pcie_tlp_if from Config DB")
	end
	// RESET_METH
    if (reset_handler == null) begin
        if (!uvm_config_db#(uvm_thread)::get(this, "", "reset_handler", reset_handler))
      	  `uvm_fatal(CLASSID, "reset_handler must be specified")
    end
    reset_handler.register(reset_export, uvm_thread_pkg::default_map);

endfunction: build_phase

task pcie_tlp_driver::main_phase(uvm_phase phase);
endtask: main_phase

task pcie_tlp_driver::clean_up();
    `uvm_info(CLASSID,"CLEANING.............................",UVM_MEDIUM)
	m_pcie_tlp_vif.clean_up();
endtask

task pcie_tlp_driver::main_phase_new(uvm_phase phase);
    `uvm_info(CLASSID,"MAIN_PHASE_NEW.............................",UVM_MEDIUM)
	drv_init();
	fork 
		drv_interface();
	join
endtask 

task pcie_tlp_driver::drv_init();
	m_pcie_tlp_vif.drvInit();
endtask: drv_init

task pcie_tlp_driver::drv_interface();
	forever begin
		//seq_item_port.get(req);
		uvm_wait_for_nba_region();
		seq_item_port.try_next_item(req);
		if(req == null) begin 
		    `uvm_info(CLASSID,$sformatf("You get null req........."),UVM_MEDIUM);
		    m_pcie_tlp_vif.sentPkt(null);
		end
		else begin 
		    `uvm_info(CLASSID,$sformatf("You get req:\n%0s",req.sprint()),UVM_LOW);
    	    m_req_analysis_port.write(req);
    	    rsp = RSP::type_id::create("rsp", this);
		    $cast(rsp,req.clone());
    	    rsp.set_id_info(req);
		    m_pcie_tlp_vif.sentPkt(req);
    	    m_rsp_analysis_port.write(rsp);
    	    seq_item_port.item_done(rsp);
		end
	end
endtask: drv_interface

`endif 

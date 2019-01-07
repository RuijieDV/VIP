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
//     FileName: axi4lite_driver.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 14:08:56
//      History:
//============================================================================*/
`ifndef AXI4LITE_DRIVER__SV
`define AXI4LITE_DRIVER__SV

class axi4lite_driver extends uvm_driver#(axi4lite_pkt);

	`SET_CLASSID
	axi4lite_cfg  m_cfg;
	abstract_if m_axi4lite_vif;

	uvm_thread reset_handler;
	local uvm_thread_imp#(axi4lite_driver) reset_export;

	uvm_analysis_port#(axi4lite_pkt) m_req_analysis_port;
	uvm_analysis_port#(axi4lite_pkt) m_rsp_analysis_port;

	`uvm_component_utils_begin(axi4lite_driver)
       `uvm_field_object(reset_handler, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end 

	function new (string name = "axi4lite_driver", uvm_component parent = null);
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

endclass: axi4lite_driver

function void axi4lite_driver::build_phase(input uvm_phase phase);
	super.build_phase(phase);

	if (!uvm_config_db#(axi4lite_cfg)::get(this, "", "axi4lite_cfg", m_cfg)) begin
		`uvm_fatal(CLASSID, "Failed to Grab axi4lite_cfg from Config DB")
	end

	if (!uvm_config_db#(abstract_if)::get(this, "", "AXI4LITE_IF", m_axi4lite_vif)) begin
		`uvm_fatal(CLASSID, "Failed to Grab axi4lite_if from Config DB")
	end
	// RESET_METH
    if (reset_handler == null) begin
        if (!uvm_config_db#(uvm_thread)::get(this, "", "reset_handler", reset_handler))
      	  `uvm_fatal(CLASSID, "reset_handler must be specified")
    end
    reset_handler.register(reset_export, uvm_thread_pkg::default_map);

endfunction: build_phase

task axi4lite_driver::main_phase(uvm_phase phase);
endtask: main_phase

task axi4lite_driver::clean_up();
    `uvm_info(CLASSID,"CLEANING.............................",UVM_MEDIUM)
	m_axi4lite_vif.clean_up();
endtask

task axi4lite_driver::main_phase_new(uvm_phase phase);
    `uvm_info(CLASSID,"MAIN_PHASE_NEW.............................",UVM_MEDIUM)
	drv_init();
	fork 
		drv_interface();
	join
endtask 

task axi4lite_driver::drv_init();
	m_axi4lite_vif.drvInit();
endtask: drv_init

task axi4lite_driver::drv_interface();
	uvm_sequence_item m_item;
	axi4lite_pkt m_axi4lite_pkt;
	forever begin
		uvm_wait_for_nba_region();
		seq_item_port.try_next_item(req);
		if(req == null) begin 
		    `uvm_info(CLASSID,$sformatf("You get null req........."),UVM_HIGH);
		    m_axi4lite_vif.sentPkt(null);
		end
		else begin 
		    `uvm_info(CLASSID,$sformatf("You get req:\n%0s",req.sprint()),UVM_MEDIUM);
    	    m_req_analysis_port.write(req);
    	    //rsp = RSP::type_id::create("rsp", this);
		    //$cast(rsp,req.clone());
    	    //rsp.set_id_info(req);
		    m_axi4lite_vif.sentPkt(req);
		    m_axi4lite_vif.recvPkt(m_item);
			$cast(m_axi4lite_pkt,m_item);
			req.axi4lite_rdata = m_axi4lite_pkt.axi4lite_rdata;
			req.axi4lite_bresp = m_axi4lite_pkt.axi4lite_bresp;
			req.axi4lite_rresp = m_axi4lite_pkt.axi4lite_rresp;
    	    //m_rsp_analysis_port.write(req);
    	    seq_item_port.item_done();
		end
	end
endtask: drv_interface

`endif 

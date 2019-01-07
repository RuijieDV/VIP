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
//     FileName: pcie_tlp_sequencer.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-20 09:55:43
//      History:
//============================================================================*/
`ifndef PCIE_TLP_SEQUENCER__SV
`define PCIE_TLP_SEQUENCER__SV

class pcie_tlp_sequencer extends uvm_sequencer #(pcie_tlp_pkt);

	`SET_CLASSID
	uvm_thread reset_handler;
	local uvm_thread_imp #(pcie_tlp_sequencer) reset_export;
	local uvm_phase my_main_phase_handle; 
	uvm_analysis_export   #(pcie_tlp_pkt)  mon2sqr_export; 
	uvm_tlm_analysis_fifo #(pcie_tlp_pkt)  mon2sqr_afifo;

	`uvm_component_utils_begin(pcie_tlp_sequencer)
	    `uvm_field_object(reset_handler, UVM_DEFAULT|UVM_REFERENCE)
	`uvm_component_utils_end 
     
	function new (string name, uvm_component parent);
		super.new(name, parent);
		reset_export = new("reset_export", this);
		mon2sqr_export = new("mon2sqr_export", this);
		mon2sqr_afifo = new("mon2sqr_afifo", this);
	endfunction : new

	function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		if (reset_handler == null) begin 
     	   if (!uvm_config_db#(uvm_thread)::get(this, "", "reset_handler", reset_handler))
     		   `uvm_fatal(CLASSID, "reset_handler must be specified")
		end
		reset_handler.register(reset_export, uvm_thread_pkg::default_map);
    endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mon2sqr_export.connect(mon2sqr_afifo.analysis_export); 
    endfunction : connect_phase

    task clean_up();
        // kill the sequences
        `uvm_info(CLASSID, "CLEANING: Stopping Sequences....................", UVM_MEDIUM)
        stop_sequences();
		//FIXME> How do we drop the objections of "killed" sequences
    endtask : clean_up

    task main_phase_new(uvm_phase phase);
		`uvm_info(CLASSID, "MAIN_PHASE_NEW........................", UVM_MEDIUM)
		start_phase_sequence(my_main_phase_handle);
    endtask : main_phase_new

    task main_phase(uvm_phase phase);
       my_main_phase_handle = phase;
       super.main_phase(phase);
    endtask : main_phase

endclass : pcie_tlp_sequencer

`endif


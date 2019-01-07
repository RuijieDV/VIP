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
//     FileName: axi4st_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-18 17:28:55
//      History:
//============================================================================*/
`ifndef AXI4ST_SMOKE_SEQ__SV
`define AXI4ST_SMOKE_SEQ__SV

class axi4st_default_seq extends uvm_sequence#(axi4st_pkt);

	`uvm_object_utils(axi4st_default_seq)
	`uvm_declare_p_sequencer(axi4st_sequencer)

	function new(string name = "axi4st_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: axi4st_default_seq

task axi4st_default_seq::body();
	mac_pkt mac_req,mac_rsp;
	axi4st_pkt axi4st_req,axi4st_rsp;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			axi4st_req = `CREATE_OBJ(axi4st_pkt,"axi4st_req")
			axi4st_rsp = `CREATE_OBJ(axi4st_pkt,"axi4st_rsp")
			axi4st_req.axi4st_data = mac_req.mac_data;
			axi4st_req.m_idle_cfg  = mac_req.m_idle_cfg;
			`ASSERT(axi4st_req.randomize());
			`uvm_info("AXI4ST_REQ", $sformatf("AXI4ST pkt is----->:\n%s",axi4st_req.sprint()), UVM_MEDIUM)
			start_item(axi4st_req);
			finish_item(axi4st_req);
			get_response(axi4st_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body
	
`endif 

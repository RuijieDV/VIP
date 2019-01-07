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
//     FileName: xlgmii_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 17:23:11
//      History:
//============================================================================*/
`ifndef XLGMII_SMOKE_SEQ__SV
`define XLGMII_SMOKE_SEQ__SV

class xlgmii_default_seq extends uvm_sequence#(xlgmii_pkt);

	`uvm_object_utils(xlgmii_default_seq)
	`uvm_declare_p_sequencer(xlgmii_sequencer)

	function new(string name = "xlgmii_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: xlgmii_default_seq

task xlgmii_default_seq::body();
	mac_pkt mac_req,mac_rsp;
	xlgmii_pkt xlgmii_req,xlgmii_rsp;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			xlgmii_req = `CREATE_OBJ(xlgmii_pkt,"xlgmii_req")
			xlgmii_rsp = `CREATE_OBJ(xlgmii_pkt,"xlgmii_rsp")
			xlgmii_req.xlgmii_data = mac_req.mac_data;
			`ASSERT(xlgmii_req.randomize());
			`uvm_info("XLGMII_REQ", $sformatf("XLGMII pkt is----->:\n%s",xlgmii_req.sprint()), UVM_MEDIUM)
			start_item(xlgmii_req);
			finish_item(xlgmii_req);
			get_response(xlgmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body
	
`endif 

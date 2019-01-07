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
//     FileName: rgmii_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-30 09:08:07
//      History:
//============================================================================*/
`ifndef RGMII_SMOKE_SEQ__SV
`define RGMII_SMOKE_SEQ__SV


class rgmii_default_seq extends uvm_sequence#(rgmii_pkt);

	`uvm_object_utils(rgmii_default_seq)
	`uvm_declare_p_sequencer(rgmii_sequencer)

	function new(string name = "rgmii_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: rgmii_default_seq

task rgmii_default_seq::body();
	mac_pkt mac_req,mac_rsp;
	rgmii_pkt rgmii_req,rgmii_rsp;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			rgmii_req = `CREATE_OBJ(rgmii_pkt,"rgmii_req")
			rgmii_rsp = `CREATE_OBJ(rgmii_pkt,"rgmii_rsp")
			rgmii_req.rgmii_data = mac_req.mac_data;
			`ASSERT(rgmii_req.randomize());
			`uvm_info("RGMII_REQ", $sformatf("RGMII pkt is----->:\n%s",rgmii_req.sprint()), UVM_MEDIUM)
			start_item(rgmii_req);
			finish_item(rgmii_req);
			get_response(rgmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body
	
`endif 

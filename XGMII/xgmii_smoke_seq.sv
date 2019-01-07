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
//     FileName: xgmii_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 12:20:39
//      History:
//============================================================================*/
`ifndef XGMII_SMOKE_SEQ__SV
`define XGMII_SMOKE_SEQ__SV

//#########################################################################################################
class xgmii_default_seq extends uvm_sequence#(xgmii_pkt);

	`uvm_object_utils(xgmii_default_seq)
	`uvm_declare_p_sequencer(xgmii_sequencer)

	function new(string name = "xgmii_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: xgmii_default_seq

task xgmii_default_seq::body();
	mac_pkt mac_req,mac_rsp;
	xgmii_pkt xgmii_req,xgmii_rsp;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			xgmii_req = `CREATE_OBJ(xgmii_pkt,"xgmii_req")
			xgmii_rsp = `CREATE_OBJ(xgmii_pkt,"xgmii_rsp")
			xgmii_req.xgmii_data = mac_req.mac_data;
			`ASSERT(xgmii_req.randomize());
			`uvm_info("XGMII_REQ", $sformatf("XGMII pkt is----->:\n%s",xgmii_req.sprint()), UVM_MEDIUM)
			start_item(xgmii_req);
			finish_item(xgmii_req);
			get_response(xgmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body

//#########################################################################################################
class xgmii_err_seq extends uvm_sequence#(xgmii_pkt);

	`uvm_object_utils(xgmii_err_seq)
	`uvm_declare_p_sequencer(xgmii_sequencer)

	function new(string name = "xgmii_err_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: xgmii_err_seq

task xgmii_err_seq::body();
	mac_pkt mac_req,mac_rsp;
	xgmii_pkt xgmii_req,xgmii_rsp;
	int m_cnt;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			xgmii_req = `CREATE_OBJ(xgmii_pkt,"xgmii_req")
			xgmii_rsp = `CREATE_OBJ(xgmii_pkt,"xgmii_rsp")
			xgmii_req.xgmii_data = mac_req.mac_data;
			m_cnt++;
			`ASSERT(xgmii_req.randomize() with {(local::m_cnt[0]==1) ? (xgmii_err == 1) : (xgmii_err == 0);});
			`uvm_info("XGMII_REQ", $sformatf("XGMII pkt is----->:\n%s",xgmii_req.sprint()), UVM_MEDIUM)
			start_item(xgmii_req);
			finish_item(xgmii_req);
			get_response(xgmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body

//#########################################################################################################


`endif 

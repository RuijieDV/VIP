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
//     FileName: gmii_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 14:52:44
//      History:
//============================================================================*/
`ifndef GMII_SMOKE_SEQ__SV
`define GMII_SMOKE_SEQ__SV

//#####################################################################################################
class gmii_default_seq extends uvm_sequence#(gmii_pkt);

	`uvm_object_utils(gmii_default_seq)
	`uvm_declare_p_sequencer(gmii_sequencer)

	function new(string name = "gmii_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: gmii_default_seq

task gmii_default_seq::body();
	mac_pkt mac_req,mac_rsp;
	gmii_pkt gmii_req,gmii_rsp;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			gmii_req = `CREATE_OBJ(gmii_pkt,"gmii_req")
			gmii_rsp = `CREATE_OBJ(gmii_pkt,"gmii_rsp")
			gmii_req.gmii_data = mac_req.mac_data;
			`ASSERT(gmii_req.randomize());
			`uvm_info("GMII_REQ", $sformatf("GMII pkt is----->:\n%s",gmii_req.sprint()), UVM_MEDIUM)
			start_item(gmii_req);
			finish_item(gmii_req);
			get_response(gmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body

//#####################################################################################################
class gmii_err_seq extends uvm_sequence#(gmii_pkt);

	`uvm_object_utils(gmii_err_seq)
	`uvm_declare_p_sequencer(gmii_sequencer)

	function new(string name = "gmii_err_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: gmii_err_seq

task gmii_err_seq::body();
	mac_pkt mac_req,mac_rsp;
	gmii_pkt gmii_req,gmii_rsp;
	int m_cnt;
	fork
        forever begin
			mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
			mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
			p_sequencer.upper_seq_item_port.get_next_item(mac_req);
			mac_rsp.set_id_info(mac_req);
			`uvm_info("MAC_REQ", $sformatf("Executing Upper mac pkt:\n%s", mac_req.sprint()), UVM_MEDIUM)
			gmii_req = `CREATE_OBJ(gmii_pkt,"gmii_req")
			gmii_rsp = `CREATE_OBJ(gmii_pkt,"gmii_rsp")
			gmii_req.gmii_data = mac_req.mac_data;
			m_cnt++;
			`ASSERT(gmii_req.randomize() with {(local::m_cnt[0]==1) ? (gmii_err == 1) : (gmii_err == 0);});
			`uvm_info("GMII_REQ", $sformatf("GMII pkt is----->:\n%s",gmii_req.sprint()), UVM_MEDIUM)
			start_item(gmii_req);
			finish_item(gmii_req);
			get_response(gmii_rsp);
			p_sequencer.upper_seq_item_port.item_done(mac_rsp);
		end
    join
     
endtask: body

//#####################################################################################################


`endif 

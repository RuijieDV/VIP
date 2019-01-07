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
//     FileName: reg_access_sequence_lib.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2013-11-22 15:38:25
//      History:
//============================================================================*/

`ifndef REG_ACCESS_SEQUENCE_LIB__SV
`define REG_ACCESS_SEQUENCE_LIB__SV 
//=========================================================================================
//class:regs_mode_cfg
//=========================================================================================
class regs_mode_cfg extends uvm_sequence #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN));
	/*{{{*/

	`uvm_object_utils(regs_mode_cfg)
	function new(string name = "regs_mode_cfg");
		super.new(name);
	endfunction : new

    virtual task body();
    endtask

    task regWR(input bit [`ADDR_WIDTH-1:0] addr,input bit [`ADDR_WIDTH-1:0] data,input uvm_sequencer_base seqr);
		reg_access_frame_seq reg_access_frame_seq0;
		reg_access_frame_seq0 = reg_access_frame_seq::type_id::create("reg_access_frame_seq0");
		reg_access_frame_seq0.s_m_write(addr,data,seqr);
		`uvm_info("regWR",$sformatf("@ADDR[0x%h]:DATA[%h]",addr,data),UVM_LOW)
	endtask

    task regRD(input bit [`ADDR_WIDTH-1:0] addr,output bit [`ADDR_WIDTH-1:0] data,input uvm_sequencer_base seqr);
        bit [7:0] rdata[];
		reg_access_frame_seq reg_access_frame_seq0;
		reg_access_frame_seq0 = reg_access_frame_seq::type_id::create("reg_access_frame_seq0");
		reg_access_frame_seq0.s_m_read_with_data(addr,rdata,seqr);
		for(int i=0;i<`ADDR_WIDTH/8;i++)
			data[`ADDR_WIDTH-1-8*i -:8] = rdata[i];
		`uvm_info("regRD",$sformatf("@ADDR[0x%h]:DATA[%h]",addr,data),UVM_LOW)
	endtask

	/*task waitBusyFinish(input bit [`ADDR_WIDTH-1:0] addr,input uvm_sequencer_base seqr);
		bit [`ADDR_WIDTH-1:0] data;
		do begin
			#50ns;
			regRD(addr,data,seqr);
			`uvm_info("waitBusyFinish",$sformatf("Wait--->@ADDR[0x%h]:DATA[%h]",addr,data),UVM_LOW)
		end while(data[0] == 1);
		if(data[1] == 0) 
			`uvm_warning("waitBusyFinish","You read data busy status error!!!")
	endtask


    task AddVxlanTunnelEndTable(input bit [`ADDR_WIDTH-1:0] start_addr,
		                        input s_vxlan_tunnel_end m_vxlan_tunnel_end,
								input uvm_sequencer_base seqr
							   );
		string sip_dip_idx;
		bit [31:0] dtq[$];
		sip_dip_idx = `SKEY({m_vxlan_tunnel_end.sip,m_vxlan_tunnel_end.dip});
		if(m_vxlan_tunnel_end.svp == 0)
			`uvm_error("AddVxlanTunnelEndTable","You set m_vxlan_tunnel_end.svp == 0!")
		if(tbtop_pkg::vxlan_tunnel_end_table.size() > `VXLAN_TUNNEL_END_DEPTH) begin 
			`uvm_error("AddVxlanTunnelEndTable",$sformatf("You set table size more than 128[%0d]!",tbtop_pkg::vxlan_tunnel_end_table.size()))
		end
		if(!tbtop_pkg::vxlan_tunnel_end_table.exists(sip_dip_idx)) begin  
			tbtop_pkg::vxlan_tunnel_end_table[sip_dip_idx] = m_vxlan_tunnel_end;
			dtq = {>>32{m_vxlan_tunnel_end}};
			for(int i=0;i<3;i++) begin 
				waitBusyFinish(start_addr+4*5,seqr);
				regWR(start_addr+4*i,dtq[i],seqr);
			end
			waitBusyFinish(start_addr+4*5,seqr);
			regWR(start_addr+4*3,32'h0,seqr);//wr
		end
		else begin 
			`uvm_error("AddVxlanTunnelEndTable",$sformatf("You can not add to exists index[%0s]!",sip_dip_idx))
		end
	endtask

    
    task ModifyVxlanTunnelEndTable(input bit [`ADDR_WIDTH-1:0] start_addr,
								   input s_vxlan_tunnel_end m_vxlan_tunnel_end,
								   input uvm_sequencer_base seqr
							      );
		string sip_dip_idx;
		bit [31:0] dtq[$];
		sip_dip_idx = `SKEY({m_vxlan_tunnel_end.sip,m_vxlan_tunnel_end.dip});		
		if(m_vxlan_tunnel_end.svp == 0)
			`uvm_error("ModifyVxlanTunnelEndTable","You set m_vxlan_tunnel_end.svp == 0!")
		if(tbtop_pkg::vxlan_tunnel_end_table.size() > `VXLAN_TUNNEL_END_DEPTH) begin 
			`uvm_error("ModifyVxlanTunnelEndTable",$sformatf("You set table size more than 128[%0d]!",tbtop_pkg::vxlan_tunnel_end_table.size()))
		end
		if(tbtop_pkg::vxlan_tunnel_end_table.exists(sip_dip_idx)) begin  
			tbtop_pkg::vxlan_tunnel_end_table[sip_dip_idx] = m_vxlan_tunnel_end;
			dtq = {>>32{m_vxlan_tunnel_end}};
			for(int i=0;i<3;i++) begin 
				waitBusyFinish(start_addr+4*5,seqr);
				regWR(start_addr+4*i,dtq[i],seqr);
			end
			waitBusyFinish(start_addr+4*5,seqr);
			regWR(start_addr+4*3,32'h1,seqr);//wr
		end
		else begin 
			`uvm_error("ModifyVxlanTunnelEndTable",$sformatf("You can not modify to not exists index[%0s]!",sip_dip_idx))
		end
	endtask

	task DelVxlanTunnelEndTable(input bit [`ADDR_WIDTH-1:0] start_addr,
		                        input s_vxlan_tunnel_end m_vxlan_tunnel_end,
								input uvm_sequencer_base seqr
							   );
		string sip_dip_idx;
		bit [31:0] dtq[$];
		sip_dip_idx = `SKEY({m_vxlan_tunnel_end.sip,m_vxlan_tunnel_end.dip});		
		if(tbtop_pkg::vxlan_tunnel_end_table.size() > `VXLAN_TUNNEL_END_DEPTH) begin 
			`uvm_error("DelVxlanTunnelEndTable",$sformatf("You set table size more than 128[%0d]!",tbtop_pkg::vxlan_tunnel_end_table.size()))
		end
		if(tbtop_pkg::vxlan_tunnel_end_table.exists(sip_dip_idx)) begin  
			tbtop_pkg::vxlan_tunnel_end_table.delete(sip_dip_idx);
			dtq = {>>32{m_vxlan_tunnel_end}};
			for(int i=0;i<3;i++) begin 
				waitBusyFinish(start_addr+4*5,seqr);
				regWR(start_addr+4*i,dtq[i],seqr);
			end
			waitBusyFinish(start_addr+4*5,seqr);
			regWR(start_addr+4*3,32'h2,seqr);//wr
		end
		else begin 
			`uvm_error("DelVxlanTunnelEndTable",$sformatf("You can not delete to not exists index[%0s]!",sip_dip_idx))
		end
	
	endtask

    task RdVxlanTunnelEndTable(input bit [`ADDR_WIDTH-1:0] start_addr,
		                       inout s_vxlan_tunnel_end m_vxlan_tunnel_end,
							   input uvm_sequencer_base seqr
							  );
		string sip_dip_idx;
		bit [31:0] dtq[$];
		bit [`ADDR_WIDTH-1:0] data;
		sip_dip_idx = `SKEY({m_vxlan_tunnel_end.sip,m_vxlan_tunnel_end.dip});
		if(tbtop_pkg::vxlan_tunnel_end_table.size() > `VXLAN_TUNNEL_END_DEPTH) begin 
			`uvm_error("RdVxlanTunnelEndTable",$sformatf("You set table size more than 128[%0d]!",tbtop_pkg::vxlan_tunnel_end_table.size()))
		end
		if(tbtop_pkg::vxlan_tunnel_end_table.exists(sip_dip_idx)) begin  
			dtq = {>>32{m_vxlan_tunnel_end}};
			for(int i=0;i<2;i++) begin 
				waitBusyFinish(start_addr+4*5,seqr);
				regWR(start_addr+4*i,dtq[i],seqr);
			end
			waitBusyFinish(start_addr+4*5,seqr);
			regWR(start_addr+4*3,32'h3,seqr);//wr
			waitBusyFinish(start_addr+4*5,seqr);
			regRD(start_addr+4*4,data,seqr);
			m_vxlan_tunnel_end.svp = data;
		end
		else begin 
			`uvm_error("RdVxlanTunnelEndTable",$sformatf("You can not read to not-exists index[%0s]!",sip_dip_idx))
		end
	endtask


    task WrVxlanTunnelCapTable(input bit [`ADDR_WIDTH-1:0] start_addr,
		                       input s_vxlan_tunnel_cap m_vxlan_tunnel_cap,
							   input uvm_sequencer_base seqr
							  );
		string idx;
		bit [31:0] dtq[$];
		idx = `SKEY(m_vxlan_tunnel_cap.index);
		tbtop_pkg::vxlan_tunnel_cap_table[idx] = m_vxlan_tunnel_cap;
		if(tbtop_pkg::vxlan_tunnel_cap_table.size() > `VXLAN_TUNNEL_CAP_DEPTH) begin 
			`uvm_error("setVxlanTunnelCapTable",$sformatf("You set table size more than 128[%0d]!",tbtop_pkg::vxlan_tunnel_cap_table.size()))
		end
		dtq = {>>32{m_vxlan_tunnel_cap}};
		for(int i=0;i<9;i++) begin 
			waitBusyFinish(start_addr+4*21,seqr);
			regWR(start_addr+4*i,dtq[i],seqr);
		end
		waitBusyFinish(start_addr+4*21,seqr);
		regWR(start_addr+4*9,{m_vxlan_tunnel_cap.index,24'b0},seqr);//index
		waitBusyFinish(start_addr+4*21,seqr);
		regWR(start_addr+4*11,32'h1,seqr);//wr
	endtask

	task RdVxlanTunnelCapTable(input bit [`ADDR_WIDTH-1:0] start_addr,
		                       inout s_vxlan_tunnel_cap m_vxlan_tunnel_cap,
							   input uvm_sequencer_base seqr
							  );
		string idx;
		bit [`ADDR_WIDTH-1:0] data;
		bit [31:0] dtq[$];
		int m_sz;
		m_sz = $size(s_vxlan_tunnel_cap);
		idx = `SKEY(m_vxlan_tunnel_cap.index);
		if(tbtop_pkg::vxlan_tunnel_cap_table.exists(idx)) begin 
			waitBusyFinish(start_addr+4*21,seqr);
			regWR(start_addr+4*9,{m_vxlan_tunnel_cap.index,24'b0},seqr);
			waitBusyFinish(start_addr+4*21,seqr);
			regWR(start_addr+4*11,32'h0,seqr);//rd
			for(int i=0;i<9;i++) begin 
				waitBusyFinish(start_addr+4*21,seqr);
				regRD(start_addr+4*12+4*i,data,seqr);
				m_vxlan_tunnel_cap[m_sz-1-32*i -:32] = data;
			end
		end
		else begin 
			`uvm_error("getVxlanTunnelCapTable",$sformatf("You read not-exists table index[%0s]",idx))
		end
	endtask */
	/*}}}*/
endclass : regs_mode_cfg

`endif

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
//     FileName: pcie_tlp_bd_ctrl.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-25 17:12:04
//      History:
//============================================================================*/
`ifndef PCIE_TLP_BD_CTRL__SV
`define PCIE_TLP_BD_CTRL__SV


class pcie_tlp_bd_ctrl extends uvm_sequence #(pcie_tlp_pkt);

	`SET_CLASSID
	int                  tx_bd_num = 20;
	int                  rx_bd_num = 9;
	int                  tx_bd_chn_aa[int][$];
	int                  rx_bd_chn_aa[int][$];
	pcie_tlp_txbd_data   txbd_tbls[];
	pcie_tlp_txbd_data   rxbd_tbls[];
	pcie_tlp_default_seq bd_seq;

	`uvm_object_utils(pcie_tlp_bd_ctrl)

	function new(string name = "pcie_tlp_bd_ctrl");
		super.new(name);
		bd_seq = `CREATE_OBJ(pcie_tlp_default_seq,"bd_seq")
	endfunction: new

	virtual task pre_start();
	    //##########################################
	    //initial BD
      	bit [31:0] tx_bd_head_addr=32'h0000_5004;
      	bit [31:0] tx_bd_tail_addr=32'h0000_5008;
		bit [31:0] tx_chn_en_addr =32'h0000_5000;
		bit [31:0] rx_bd_head_addr=32'h0000_6404;
      	bit [31:0] rx_bd_tail_addr=32'h0000_6408;
		bit [31:0] rx_chn_en_addr =32'h0000_6400;
	    //##########################################
		//set each bd has chn nums
		for(int i=0;i<tx_bd_num;i++)
			tx_bd_chn_aa[i].push_back(i);
		for(int i=0;i<rx_bd_num;i++)
			rx_bd_chn_aa[i].push_back(i);
	    //##########################################
		for(int i=0;i<tx_bd_num;i++) begin
			setBDHead(tx_bd_head_addr + 256*i,32'h00100000+i*512*8);
			setBDTail(tx_bd_tail_addr + 256*i,32'h00100000+i*512*8);
		end
		for(int i=0;i<rx_bd_num;i++) begin
			setBDHead(rx_bd_head_addr + 256*i,32'h00100000+i*512*8);
			setBDTail(rx_bd_tail_addr + 256*i,32'h00100000+i*512*8);
		end
		for(int i=0;i<tx_bd_num;i++)
			setBDEna(tx_chn_en_addr + 256*i,32'h1);
		for(int i=0;i<rx_bd_num;i++)
			setBDEna(rx_chn_en_addr + 256*i,32'h1);
		//##########################################
		//##########################################
    endtask

	virtual task body();
	    fork
			startTXBD();
		join
	endtask

	//####################################################################################
    virtual task setBDHead(input uvm_bitstream_t bd_head_addr,bd_head_dt);
		bd_seq.RegWR(m_sequencer,bd_head_addr,bd_head_dt);
    endtask
    
	virtual task setBDTail(input uvm_bitstream_t bd_tail_addr,bd_tail_dt);
		bd_seq.RegWR(m_sequencer,bd_tail_addr,bd_tail_dt);
	endtask
	
	virtual task setBDDepth(input uvm_bitstream_t bd_depth_addr,bd_depth_dt);
		bd_seq.RegWR(m_sequencer,bd_depth_addr,bd_depth_dt);
	endtask

	virtual task setBDEna(input uvm_bitstream_t bd_ena_addr,bd_ena_dt);
		bd_seq.RegWR(m_sequencer,bd_ena_addr,bd_ena_dt);
	endtask
	//####################################################################################

    virtual task startTXBD(int tx_bd_num,int pkt_num = 1,len = 16,data_gen_enum gen_mode = INCR,bit [7:0] start_dt);
	    bd_seq.
    endtask
    
    virtual task startRXBD();
    endtask

endclass: pcie_tlp_bd_ctrl



`endif 

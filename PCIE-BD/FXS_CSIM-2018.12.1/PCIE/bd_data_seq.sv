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
//     FileName: bd_data_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2013-11-26 16:00:45
//      History:
//============================================================================*/


`ifndef BD_DATA_SEQ__SV
`define BD_DATA_SEQ__SV
//====================================================================================
//class : bd_cfg_seq
//=========================================================================================
class bd_cfg_seq extends uvm_sequence #(uvm_sequence_item);

	string file_dir;/*{{{*/
    reg_access_sequencer   reg_access_sqr;
    user_sequencer         tx_user_sqrs[`TX_BD_NUM];
    user_sequencer         rx_user_sqrs[`RX_BD_NUM];	
    //bd ctl
	cpu_txbd_ctl_process_seq cpu_txbd_ctl_process[`TX_BD_NUM];
	cpu_rxbd_ctl_process_seq cpu_rxbd_ctl_process[`RX_BD_NUM];

	function new(string name = "bd_cfg_seq");
		super.new(name);
	endfunction : new

	`uvm_object_utils_begin(bd_cfg_seq)
	    `uvm_field_string(file_dir, UVM_DEFAULT)
	`uvm_component_utils_end

     virtual task body();
	     bit [31:0] tx_chn_en_addr =32'h0000_5000;
      	 bit [31:0] tx_bd_base_addr=32'h0000_5004;
      	 bit [31:0] tx_bd_tail_addr=32'h0000_5008;
		 bit [31:0] rx_chn_en_addr =32'h0000_6400;
      	 bit [31:0] rx_bd_base_addr=32'h0000_6404;
      	 bit [31:0] rx_bd_tail_addr=32'h0000_6408;
         for (int i=0;i<`TX_BD_NUM;i++) begin
			 automatic int j=i;
			 fork 
			     begin
                     cpu_txbd_ctl_process[j] = cpu_txbd_ctl_process_seq::type_id::create($sformatf("cpu_txbd_ctl_process%0d",j));
                     cpu_txbd_ctl_process[j].reg_access_sqr      = reg_access_sqr;
                     cpu_txbd_ctl_process[j].tx_user_sqr         = tx_user_sqrs[j];
                     cpu_txbd_ctl_process[j].chn_addr            = tx_chn_en_addr+j*256;
                     cpu_txbd_ctl_process[j].bd_base_addr        = tx_bd_base_addr+j*256;
                     cpu_txbd_ctl_process[j].tail_addr           = tx_bd_tail_addr+j*256;
                     cpu_txbd_ctl_process[j].tx_bd_addr_start    = 32'h00100000+j*512*8;    //100,200
                     cpu_txbd_ctl_process[j].tx_buf_addr_start   = 64'h21000008+j*2048*512;
                     cpu_txbd_ctl_process[j].chn_num             = j;
                     cpu_txbd_ctl_process[j].send_num            = 100000;
                     cpu_txbd_ctl_process[j].FILE_BD_LOG         = $sformatf("./TC/%0s/sim_out/bd/log/",file_dir);
                     cpu_txbd_ctl_process[j].tx_time_ctl        (FIX,200,200,1);
                     //put bd in
                     cpu_txbd_ctl_process[j].tx_bd_ctl          (FIX,1000,1000,1);
                     cpu_txbd_ctl_process[j].tx_data_addr_ctl   (64'h21000008+j*2048*512,RDM,1,8,60,60,1,FIX,FIX,j);
                     //release bd
                     cpu_txbd_ctl_process[j].getdata_tx_time_ctl(20000,FIX,500,1000,100);
                     cpu_txbd_ctl_process[j].start(null);
				 end
			 join_none;
         end

		 for (int i=0;i<`RX_BD_NUM;i++) begin
			 automatic int j=i;
			 fork 
			     begin
                     cpu_rxbd_ctl_process[j] = cpu_rxbd_ctl_process_seq::type_id::create($sformatf("cpu_rxbd_ctl_process%0d",j));
                     cpu_rxbd_ctl_process[j].reg_access_sqr      = reg_access_sqr;
                     cpu_rxbd_ctl_process[j].rx_user_sqr         = rx_user_sqrs[j];
                     cpu_rxbd_ctl_process[j].chn_addr            = rx_chn_en_addr+j*256;
                     cpu_rxbd_ctl_process[j].bd_base_addr        = rx_bd_base_addr+j*256;
                     cpu_rxbd_ctl_process[j].tail_addr           = rx_bd_tail_addr+j*256;
                     cpu_rxbd_ctl_process[j].rx_bd_addr_start    = 32'h10100000+j*512*8;    //100,200
                     cpu_rxbd_ctl_process[j].rx_buf_addr_start   = 64'hA1000008+j*2048*512;
                     cpu_rxbd_ctl_process[j].chn_num             = 20+j;
                     cpu_rxbd_ctl_process[j].FILE_BD_LOG         = $sformatf("./TC/%0s/sim_out/bd/log/",file_dir);
                     //release bd
                     cpu_rxbd_ctl_process[j].rx_time_ctl        (FIX,20000,20000,1);
                     //put bd in
                     cpu_rxbd_ctl_process[j].rx_bd_ctl          (FIX,40,40,1);
                     cpu_rxbd_ctl_process[j].getdata_rx_time_ctl(20000,FIX,10000,20000,1000);
                     cpu_rxbd_ctl_process[j].start(null);
				 end
			 join_none;
		 end
     endtask/*}}}*/
endclass : bd_cfg_seq

`endif

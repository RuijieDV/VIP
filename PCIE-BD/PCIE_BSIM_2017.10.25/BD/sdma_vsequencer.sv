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
// (c) Copyright 2017 RUIJIE, Inc.
// All rights reserved.

//============================================================================
//     FileName: sdma_vsequencer.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2017-07-28 11:12:33
//      History:
//============================================================================*/
`ifndef SDMA_VSEQUENCER__SV
`define SDMA_VSEQUENCER__SV


class sdma_vsequencer extends uvm_sequencer;

	`SET_CLASSID

	uvm_analysis_port #(bd_pkt)  tx_bd_aport; 
	uvm_analysis_port #(bd_pkt)  rx_bd_aport; 

	`uvm_component_utils_begin(sdma_vsequencer)
	`uvm_component_utils_end 
     
	function new (string name, uvm_component parent);
		super.new(name, parent);
		tx_bd_aport = new("tx_bd_aport", this);
		rx_bd_aport = new("rx_bd_aport", this);
	endfunction : new

endclass 


`endif


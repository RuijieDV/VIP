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
//     FileName: mac_usr_agent.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 16:08:36
//      History:
//============================================================================*/
`ifndef MAC_USR_AGENT__SV
`define MAC_USR_AGENT__SV

class mac_usr_agent extends uvm_agent;

    mac_usr_sequencer m_sequencer;
    mac_usr_monitor m_monitor;

	`uvm_component_utils_begin(mac_usr_agent)
	`uvm_component_utils_end

    function new (string name, uvm_component parent);
		super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        m_sequencer = `CREATE_CMP(mac_usr_sequencer,"m_sequencer")
        m_monitor = `CREATE_CMP(mac_usr_monitor,"m_monitor")
    endfunction : build_phase

endclass : mac_usr_agent

`endif


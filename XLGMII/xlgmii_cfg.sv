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
//     FileName: xlgmii_cfg.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-08-26 17:18:14
//      History:
//============================================================================*/
`ifndef XLGMII_CFG__SV
`define XLGMII_CFG__SV


class xlgmii_cfg extends uvm_object;

	uvm_active_passive_enum m_uvm_active_passive_h = UVM_ACTIVE;

	function new (string name = "xlgmii_cfg");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(xlgmii_cfg)
	    `uvm_field_enum(uvm_active_passive_enum,m_uvm_active_passive_h,UVM_DEFAULT)
	`uvm_object_utils_end

endclass: xlgmii_cfg

`endif 

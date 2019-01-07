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
//     FileName: pcie_adapter.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-05-12 08:53:31
//      History:
//============================================================================*/
`ifndef PCIE_ADAPTER__SV
`define PCIE_ADAPTER__SV


class pcie_adapter extends uvm_reg_adapter;

	`SET_CLASSID
	bit [ 3:0]  first_dw_be;
	bit [ 3:0]  last_dw_be;
	bit [11:0]  blength_minus1;
	bit [63:0]  end_addr;
	bit [ 9:0]  length;
    bit [15:0] 	req_id;
	bit	[11:0]	blength;
	bit	[7 :0]	my_tag1 = 8'b11111111;
	bit			is_3dw_or_4dw = 0;
	int			wr_length;
	
	`uvm_object_utils(pcie_adapter)

	function new (string name="pcie_adapter");
		super.new(name);
	endfunction : new

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
		pcie_tlp_item m_item;
		int dsz;
		m_item = `CREATE_OBJ(pcie_tlp_item,"m_item")
		case(rw.kind)
			UVM_WRITE:begin
				          case (rw.addr[1:0])
							  2'b00 : first_dw_be = 4'hf;
							  2'b01 : first_dw_be = 4'he;
							  2'b10 : first_dw_be = 4'hc;
							  2'b11 : first_dw_be = 4'h8;
						  endcase     
						  blength = $bits(rw.data)/8;
						  blength_minus1 = blength - 1;
						  end_addr  = rw.addr + blength_minus1;
						  case (end_addr[1:0])
							  2'b00 : last_dw_be = 4'h1;
							  2'b01 : last_dw_be = 4'h3;
							  2'b10 : last_dw_be = 4'h7;
							  2'b11 : last_dw_be = 4'hf;
						  endcase												
						  if ((rw.addr[1:0] + blength_minus1) < 4) begin // single DWORD transfer
							  first_dw_be = first_dw_be & last_dw_be;
							  last_dw_be  = 4'h0;
						  end
						  // Compute length
						  length = ((blength_minus1 + rw.addr[1:0]) >> 2) + 1;
						  my_tag1 = my_tag1 + 1'b1; 
						  //###########################################################
						  m_item.typ = 5'b00000;
						  if (!is_3dw_or_4dw)							
							  m_item.fmt = 2'b10;
						  else
							  m_item.fmt = 2'b11;
						  m_item.tc             = 3'b000;
						  m_item.td    	        = 1'b0;
						  m_item.ep             = 1'b0;
						  m_item.attr           = 2'b00;
						  m_item.length         = length;
						  m_item.req_id         = req_id;
						  m_item.tag            = my_tag1;
						  m_item.first_dw_be    = first_dw_be;
						  m_item.last_dw_be     = last_dw_be;
						  m_item.addr32         = rw.addr;
						  m_item.addr64         = rw.addr;
						  m_item.rev_1bit       = 1'b0;
						  m_item.rev_2bit       = 2'b0;
						  m_item.rev_4bit       = 4'b0;
						  m_item.is_mem_io_op   = 1'b1;
						  m_item.is_cfg_op      = 1'b0;
						  m_item.is_cpl_op      = 1'b0;
						  m_item.is_with_data   = 1'b1;
						  m_item.is_3dw         = !is_3dw_or_4dw;
						  m_item.is_4dw         = is_3dw_or_4dw;
						  m_item.payload.delete();
						  m_item.payload=new[$bits(rw.data)/8];
						  m_item.payload  ={>>8{rw.data}};
						  if (m_item.is_3dw)
							  `uvm_info(CLASSID,"M WR head is 3dw!",UVM_MEDIUM);
						  if (m_item.is_4dw)
							  `uvm_info(CLASSID,"M WR head is 4dw!",UVM_MEDIUM);
					  end
		    UVM_READ: begin 
						  case (rw.addr[1:0])
							  2'b00 : first_dw_be = 4'hf;
							  2'b01 : first_dw_be = 4'he;
							  2'b10 : first_dw_be = 4'hc;
							  2'b11 : first_dw_be = 4'h8;
						  endcase     
						  blength = $bits(rw.data)/8;
						  blength_minus1 = blength - 1;
						  end_addr  = rw.addr + blength_minus1;
						  case (end_addr[1:0])
							  2'b00 : last_dw_be = 4'h1;
							  2'b01 : last_dw_be = 4'h3;
							  2'b10 : last_dw_be = 4'h7;
							  2'b11 : last_dw_be = 4'hf;
						  endcase												
						  if ((rw.addr[1:0] + blength_minus1) < 4) begin // single DWORD transfer
							  first_dw_be = first_dw_be & last_dw_be;
							  last_dw_be  = 4'h0;
						  end
						  // Compute length
						  length = ((blength_minus1 + rw.addr[1:0]) >> 2) + 1;
						  my_tag1 = my_tag1 + 1'b1; 
						  //###########################################################
						  m_item.typ = 5'b00000;
						  if (!is_3dw_or_4dw)							
							  m_item.fmt = 2'b00;
						  else
							  m_item.fmt = 2'b01;
						  m_item.tc             = 3'b000;
						  m_item.td    	        = 1'b0;
						  m_item.ep             = 1'b0;
						  m_item.attr           = 2'b00;
						  m_item.length         = length;
						  m_item.req_id         = req_id;
						  m_item.tag            = my_tag1;
						  m_item.first_dw_be    = first_dw_be;
						  m_item.last_dw_be     = last_dw_be;
						  m_item.addr32         = rw.addr;
						  m_item.addr64         = rw.addr;
						  m_item.rev_1bit       = 1'b0;
						  m_item.rev_2bit       = 2'b0;
						  m_item.rev_4bit       = 4'b0;
						  m_item.is_mem_io_op   = 1'b1;
						  m_item.is_cfg_op      = 1'b0;
						  m_item.is_cpl_op      = 1'b0;
						  m_item.is_with_data   = 1'b0;
						  m_item.is_3dw         = !is_3dw_or_4dw;
						  m_item.is_4dw         = is_3dw_or_4dw;
						  if (m_item.is_3dw)
							  `uvm_info(CLASSID,"RD head is 3dw!",UVM_MEDIUM);
						  if (m_item.is_4dw)
							  `uvm_info(CLASSID,"RD head is 4dw!",UVM_MEDIUM);
				      end
		endcase
		return m_item;
	endfunction

    function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
		reg_access_item_t m_item;

		if($cast(m_item,bus_item)) begin 	
			`PR(m_item.sprint())
		    rw.kind = UVM_READ;
		    rw.addr = m_item.addr;
			foreach(m_item.rdata[i]) 
				rw.data[8*i +:8] = m_item.rdata[i];
		    rw.data = {<<8{rw.data}}; 
			rw.status = UVM_IS_OK;
		end
	
	endfunction


endclass:pcie_adapter

`endif


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
//     FileName: pcie_tlp_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-20 09:34:10
//      History:
//============================================================================*/
`ifndef PCIE_TLP_PKT__SV
`define PCIE_TLP_PKT__SV

typedef enum {MRD,MRDLK,MWR,IORD,IOWR,CFGRD0,CFGRD1,CFGWR0,CFGWR1,MSG,MSGD,CPL,CPLD,CPLLK,CPLDLK} pcie_tlp_enum;

class pcie_tlp_pkt extends uvm_sequence_item;                                  

	//POSTED-WR:(MWR-MSG-MSGD)|NON-POSTED-WR:(IOWR-CFGWR0-CFGWR1)|NON-POSTED-RD:(MRD-IORD-CFGRD0-CFGRD1)|NON-POSTED-LK-RD:(MRDLK)
    //POSTED-WR:(NONE)|NON-POSTED-WR:(CPL)|NON-POSTED-RD:(CPL-CPLD) |NON-POSTED-LK-RD:(CPLLK-CPLDLK)
	`SET_CLASSID
    //##############################################
	     bit [ 7:0]    pcie_tlp_data[$];
	rand pcie_tlp_enum pcie_tlp_type;
    //##############################################
	rand bit [ 1:0]	   fmt;
    rand bit [ 4:0]    typ;
    rand bit [ 2:0]    tc;  
    rand bit           td;        
    rand bit           ep;
    rand bit [ 1:0]    attr;
    rand bit [ 9:0]    length;      
    //##############################################
    rand bit [15:0]    req_id;  
    rand bit [ 7:0]    tag; 
    rand bit [ 3:0]    first_dw_be;  
    rand bit [ 3:0]    last_dw_be ;
    rand bit [31:0]    addr32;
    rand bit [63:0]    addr64;
    //##############################################
    rand bit [ 7:0]    bus_num;    
    rand bit [ 4:0]    dev_num;    
    rand bit [ 2:0]    fun_num;    
    rand bit [ 3:0]    ext_reg_num;
    rand bit [ 5:0]    reg_num;     
    //##############################################
	rand bit [15:0]    cpl_id;
    rand bit [ 2:0]    cpl_st;
    rand bit           bcm;
    rand bit [11:0]    byte_cnt;
    rand bit [ 6:0]    lower_addr;
    //##############################################
	rand bit [ 7:0]    msg_code;
    //##############################################
         bit [ 7:0]    up_payload[];
		 bit [7:0]     first_dw[$];
		 bit [7:0]     last_dw[$];
	     bit [31:0]    ecrc;
    //##############################################
    //reserve
    bit                rev_1bit = '0;
    bit [ 1:0]         rev_2bit = '0;
    bit [ 3:0]         rev_4bit = '0;
    //##############################################
    //contrl
    rand bit           is_mem_op;
    rand bit           is_io_op;
    rand bit           is_cfg_op;
	rand bit           is_msg_op;
    rand bit           is_cpl_op;
    rand bit           is_3dw_4dw;
    rand bit           is_with_data;
    //##############################################
	     bit           mon_stat;
    //##############################################
    constraint c_op {
		soft if(pcie_tlp_type inside {MWR,MRD,MRDLK}) {
			     is_mem_op == 1;
		     }
			 else if(pcie_tlp_type inside {IOWR,IORD}) {
				 is_io_op == 1;
			 }
			 else if(pcie_tlp_type inside {CFGWR0,CFGWR1,CFGRD0,CFGRD1}) {
				 is_cfg_op == 1;
			 }
			 else if(pcie_tlp_type inside {MSG,MSGD}) {
				 is_msg_op == 1;
			 }
			 else if(pcie_tlp_type inside {CPL,CPLD,CPLLK,CPLDLK}) {
				 is_cpl_op == 1;
			 }
	}

    constraint c_op_exclusive {
		$countones({is_mem_op,is_io_op,is_cfg_op,is_msg_op,is_cpl_op}) == 1;
	}

	constraint c_fmt_type {
		soft if(pcie_tlp_type == MRD) {/*{{{*/
			     typ == 5'b00000;
				 fmt inside {2'b00,2'b01};
			 }
			 else if(pcie_tlp_type == MWR) {
				 typ == 5'b00000;
				 fmt inside {2'b10,2'b11};
			 }
			 else if(pcie_tlp_type == MRDLK) {
				 typ == 5'b00001;
				 fmt inside {2'b00,2'b01};
			 }
			 else if(pcie_tlp_type == IORD) {
				 typ == 5'b00010;
				 fmt == 2'b00;
			 }
			 else if(pcie_tlp_type == IOWR) {
				 typ == 5'b00010;
				 fmt == 2'b10;
			 }
			 else if(pcie_tlp_type == CFGRD0) {
				 typ == 5'b00100;
				 fmt == 2'b00;
			 }
			 else if(pcie_tlp_type == CFGWR0) {
				 typ == 5'b00100;
				 fmt == 2'b10;
			 }
			 else if(pcie_tlp_type == CFGRD1) {
				 typ == 5'b00101;
				 fmt == 2'b00;
			 }
			 else if(pcie_tlp_type == CFGWR1) {
				 typ == 5'b00101;
				 fmt == 2'b10;
			 }
			 else if(pcie_tlp_type == CPL) {
				 typ == 5'b01010;
				 fmt == 2'b00;
			 }
			 else if(pcie_tlp_type == CPLD) {
				 typ == 5'b01010;
				 fmt == 2'b10;
			 }
			 else if(pcie_tlp_type == CPLLK) {
				 typ == 5'b01011;
				 fmt == 2'b00;
			 }
			 else if(pcie_tlp_type == CPLDLK) {
				 typ == 5'b01011;
				 fmt == 2'b10;
			 }
			 else if(pcie_tlp_type == MSG) {
				 typ inside {[5'b10000:5'b10101]};
				 fmt == 2'b01;
			 }
			 else if(pcie_tlp_type == MSGD) {
				 typ inside {[5'b10000:5'b10101]};
				 fmt == 2'b11;
			 }/*}}}*/
	}

	constraint c_3dw_4dw {
		soft if(fmt[0] == 0)
			    is_3dw_4dw == 0;
			else
				is_3dw_4dw == 1;
	}

	constraint c_is_with_data {
		soft if(fmt[1] == 1)
			    is_with_data == 1;
			else
				is_with_data == 0;
	}

	constraint c_addr32 {
		soft addr32[1:0] == 2'b0;
	}
	
	constraint c_addr64 {
		soft addr64[1:0] == 2'b0;
	}

    //##############################################
	`uvm_object_utils_begin(pcie_tlp_pkt)
		`uvm_field_int(is_3dw_4dw, UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	    `uvm_field_queue_int(pcie_tlp_data,UVM_DEFAULT)
		`uvm_field_enum(pcie_tlp_enum,pcie_tlp_type, UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(rev_1bit , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(fmt      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		`uvm_field_int(typ      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(rev_1bit , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(tc       , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(rev_4bit , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(td       , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(ep       , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(attr     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(rev_2bit , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
     	`uvm_field_int(length   , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		if(is_mem_op == 1) begin 
			`uvm_field_int(req_id      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(tag         , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(last_dw_be  , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(first_dw_be , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			if(is_3dw_4dw == 0) begin 
				`uvm_field_int(addr32        , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(rev_2bit      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
			else begin 
				`uvm_field_int(addr64[63:32] , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(addr64[31:0] , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(rev_2bit      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
		end
		else if(is_io_op == 1) begin 
			`uvm_field_int(req_id      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(tag         , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(last_dw_be  , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		`uvm_field_int(first_dw_be , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			if(is_3dw_4dw == 0) begin 
				`uvm_field_int(addr32        , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(rev_2bit      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
		end
		else if(is_msg_op == 1) begin 
			if(is_3dw_4dw == 1) begin 
				`uvm_field_int(req_id        , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(tag           , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(msg_code      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(addr64[63:32] , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(addr64[31:0] , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(rev_2bit      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
		end
		else if(is_cfg_op == 1) begin 
			if(is_3dw_4dw == 0) begin 
			    `uvm_field_int(req_id      , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(tag         , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(last_dw_be  , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(first_dw_be , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(bus_num     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(dev_num     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(fun_num     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(rev_4bit    , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(ext_reg_num , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(reg_num     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
       		    `uvm_field_int(rev_2bit    , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
		end
		else if(is_cpl_op == 1) begin 
			if(is_3dw_4dw == 0) begin 
			    `uvm_field_int(cpl_id     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(cpl_st     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(bcm        , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(byte_cnt   , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(req_id     , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(tag        , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(rev_1bit   , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(lower_addr , UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
		end
		if(is_with_data == 1) begin 
			`uvm_field_array_int(up_payload, UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_queue_int(first_dw,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_queue_int(last_dw,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
		if(td == 1) begin 
			`uvm_field_int(ecrc, UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
    `uvm_object_utils_end
  
    function new (string name = "pcie_tlp_pkt");
		super.new(name);
    endfunction : new


    function void post_randomize();
		int upl_sz;
		bit [7:0] up_payload_q[$];
		if(is_with_data == 1) begin 
 			upl_sz = up_payload.size();/*{{{*/
			up_payload_q = {up_payload};
			if(upl_sz == 0) 
				`uvm_fatal(CLASSID,"Your up_payload size is zero!")
			if(upl_sz > 4096)
				`uvm_fatal(CLASSID,$sformatf("Your up_payload size more than 4096 Bytes(%0d)!",upl_sz))
			if(upl_sz%4==0)
				this.length = upl_sz/4;
			else
				this.length = upl_sz/4+1;
			if(upl_sz <= 1*4) begin //1DW
				if(first_dw_be == 0)
					`uvm_warning(CLASSID,$sformatf("Your first_dw_be[%0b] is zero when up_payload == 1DW!",first_dw_be))
				if(last_dw_be != 4'b0)
					`uvm_error(CLASSID,$sformatf("Your last_dw_be[%0b] is not zero when up_payload == 1DW",last_dw_be))
			end
			else if(upl_sz <= 2*4) begin //2DW
				if(first_dw_be == 0)
					`uvm_error(CLASSID,$sformatf("Your first_dw_be[%0b] is zero when up_payload == 2DW!",first_dw_be))
			end
			else begin //3DW~1024DW
				if(!(first_dw_be inside {4'b1111,4'b1110,4'b1100,4'b1000}))
					`uvm_error(CLASSID,$sformatf("Your first_dw_be[%0b] is not in {4'b1111,4'b1110,4'b1100,4'b1000} when up_payload >= 3DW!",first_dw_be))
				if(!(last_dw_be inside {4'b1111,4'b0111,4'b0011,4'b0001}))
					`uvm_error(CLASSID,$sformatf("Your last_dw_be[%0b] is not in {4'b1111,4'b0111,4'b0011,4'b0001} when up_payload >= 3DW!",last_dw_be))
			end
		end
		/*}}}*/
		if(is_mem_op == 1) begin 
			if(is_3dw_4dw == 0) begin /*{{{*/
				this.pcie_tlp_data = {{rev_1bit,fmt,typ},{rev_1bit,tc,rev_4bit},{td,ep,attr,rev_2bit,length[9:8]},length[7:0],
				                       req_id[15:8],req_id[7:0],tag,{last_dw_be,first_dw_be},addr32[31:24],addr32[23:16],addr32[15:8],
									   {addr32[7:2],rev_2bit}};
			end
			else begin 
				this.pcie_tlp_data = {{rev_1bit,fmt,typ},{rev_1bit,tc,rev_4bit},{td,ep,attr,rev_2bit,length[9:8]},length[7:0],
				                       req_id[15:8],req_id[7:0],tag,{last_dw_be,first_dw_be},addr64[63:56],addr64[55:48],addr64[47:40],
									   addr64[39:32],addr64[31:24],addr64[23:16],addr64[15:8],{addr64[7:2],rev_2bit}};
			end/*}}}*/
		end
		else if(is_io_op == 1) begin 
			if(is_3dw_4dw == 0) begin /*{{{*/
				this.length = 10'b1;
				this.last_dw_be = 4'b0000;
				this.pcie_tlp_data = {{rev_1bit,fmt,typ},{rev_1bit,tc,rev_4bit},{td,ep,attr,rev_2bit,length[9:8]},length[7:0],
				                       req_id[15:8],req_id[7:0],tag,{last_dw_be,first_dw_be},addr32[31:24],addr32[23:16],addr32[15:8],
									   {addr32[7:2],rev_2bit}};
			end/*}}}*/
		end
		else if(is_cfg_op == 1) begin 
			if(is_3dw_4dw == 0) begin 
				this.length = 10'b1;
				this.last_dw_be = 4'b0000;
				this.pcie_tlp_data = {{rev_1bit,fmt,typ},{rev_1bit,tc,rev_4bit},{td,ep,attr,rev_2bit,length[9:8]},length[7:0],
				                       req_id[15:8],req_id[7:0],tag,{last_dw_be,first_dw_be},bus_num,{dev_num,fun_num},
									  {rev_4bit,ext_reg_num},{reg_num,rev_2bit}};
			end
		end
		else if(is_msg_op == 1) begin 
				this.length = (is_with_data == 1) ? 10'b1 : 10'b0;
				this.pcie_tlp_data = {{rev_1bit,fmt,typ},{rev_1bit,tc,rev_4bit},{td,ep,attr,rev_2bit,length[9:8]},length[7:0],
				                       req_id[15:8],req_id[7:0],tag,msg_code,addr64[63:56],addr64[55:48],addr64[47:40],
									   addr64[39:32],addr64[31:24],addr64[23:16],addr64[15:8],{addr64[7:2],rev_2bit}};
		end
		if(is_with_data == 1) begin
			if(first_dw_be != 0) begin /*{{{*/
			    for(int i=0;i<4;i++) begin 
			    	if(first_dw_be[i] == 0)
			    		first_dw.push_back('z);
			    	else 
			    		first_dw.push_back(up_payload_q.pop_front());
			    end
			end
			if(last_dw_be != 0) begin 
			    for(int i=3;i>=0;i--) begin 
			    	if(last_dw_be[i] == 0) 
			    		last_dw.push_back('0);
			    	else
			    		last_dw.push_back(up_payload_q.pop_back());
			    end
			end
			if(first_dw.size() != 0)
				this.pcie_tlp_data  = {this.pcie_tlp_data,first_dw,up_payload_q};
			if(last_dw.size() != 0)
				this.pcie_tlp_data  = {this.pcie_tlp_data,last_dw[3],last_dw[2],last_dw[1],last_dw[0]};
			if(this.pcie_tlp_data.size()%4 != 0)
				`uvm_error(CLASSID,"Your up_payload size is not 1DW align!!!")/*}}}*/
		end
		if(this.td == 1) begin 
			bit [ 7:0] m_pcie_tlp_data[$];
			m_pcie_tlp_data = this.pcie_tlp_data;
			m_pcie_tlp_data[0][0] = 1'b1;//typ[0]
			m_pcie_tlp_data[2][6] = 1'b1;//ep
			ecrc = genECRC(m_pcie_tlp_data);
			if(this.ep == 1)
				ecrc = ~ecrc;
			this.pcie_tlp_data = {this.pcie_tlp_data,ecrc[31:24],ecrc[23:16],ecrc[15:8],ecrc[7:0]};
		end
    endfunction :post_randomize 
	
	//##############################################################################################	
	virtual function void setOP(bit is_mem_op = 1,bit is_io_op = 0,bit is_cfg_op = 0,bit is_msg_op = 0,bit is_cpl_op = 0);
	    this.is_mem_op = is_mem_op;
		this.is_io_op = is_io_op;
		this.is_cfg_op = is_cfg_op;
		this.is_msg_op = is_msg_op;
		this.is_cpl_op = is_cpl_op;
    endfunction

	virtual function void setFmt(bit [1:0] fmt);
	    this.fmt = fmt;
    endfunction

	virtual function void setType(bit [4:0] typ);
	    this.typ = typ;
    endfunction

	virtual function void setTC(bit [2:0] tx);
	    this.tc = tc;
    endfunction

	virtual function void setTD(bit td);
	    this.td = td;
    endfunction

	virtual function void setEP(bit ep);
	    this.ep = ep;
    endfunction

	virtual function void setTAG(bit [7:0] tag);
	    this.tag = tag;
    endfunction

	virtual function void setLength(bit [9:0] length);
	    this.length = length;
    endfunction

	virtual function void setFirstDWBE(bit [3:0] first_dw_be);
		this.first_dw_be = first_dw_be;
	endfunction

	virtual function void setLastDWBE(bit [3:0] last_dw_be);
		this.last_dw_be = last_dw_be;
	endfunction

	virtual function void setREQID(bit [15:0] req_id);
		this.req_id = req_id;
	endfunction

	virtual function void setBDFnum(bit [7:0] bus_num,bit [4:0] dev_num,bit [2:0] fun_num);
	    this.bus_num = bus_num;
		this.dev_num = dev_num;
		this.fun_num = fun_num;
	endfunction

	virtual function bit [31:0] genECRC(input bit [7:0] q[$]);
		//1 + x1 + x2 + x4 + x5 + x7 + x8 + x10 + x11 + x12 + x16 + x22 + x23 + x26 + x32
		bit [7:0]  q_inv;
		bit [31:0] crc32 = '0;
		foreach(q[i]) begin 
			q_inv = {<<{q[i]}};
			crc32 = nextCRC32_D8(q_inv[i],crc32);
		end
		return crc32;
    endfunction

	// data width: 8
	// convention: the first serial bit is D[7]
	function [31:0] nextCRC32_D8;
		input [7:0] Data;
		input [31:0] crc;
		reg [7:0] d;/*{{{*/
		reg [31:0] c;
		reg [31:0] newcrc;
		begin
			d = Data;
			c = crc;
        	newcrc[0] = d[6] ^ d[0] ^ c[24] ^ c[30];
        	newcrc[1] = d[7] ^ d[6] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[30] ^ c[31];
        	newcrc[2] = d[7] ^ d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31];
        	newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[27] ^ c[31];
        	newcrc[4] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30];
        	newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
        	newcrc[6] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
        	newcrc[7] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];
        	newcrc[8] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
        	newcrc[9] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29];
        	newcrc[10] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29];
        	newcrc[11] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
        	newcrc[12] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30];
        	newcrc[13] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31];
        	newcrc[14] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31];
        	newcrc[15] = d[7] ^ d[5] ^ d[4] ^ d[3] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31];
        	newcrc[16] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[24] ^ c[28] ^ c[29];
        	newcrc[17] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[25] ^ c[29] ^ c[30];
        	newcrc[18] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[26] ^ c[30] ^ c[31];
        	newcrc[19] = d[7] ^ d[3] ^ c[11] ^ c[27] ^ c[31];
        	newcrc[20] = d[4] ^ c[12] ^ c[28];
        	newcrc[21] = d[5] ^ c[13] ^ c[29];
        	newcrc[22] = d[0] ^ c[14] ^ c[24];
        	newcrc[23] = d[6] ^ d[1] ^ d[0] ^ c[15] ^ c[24] ^ c[25] ^ c[30];
        	newcrc[24] = d[7] ^ d[2] ^ d[1] ^ c[16] ^ c[25] ^ c[26] ^ c[31];
        	newcrc[25] = d[3] ^ d[2] ^ c[17] ^ c[26] ^ c[27];
        	newcrc[26] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30];
        	newcrc[27] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31];
        	newcrc[28] = d[6] ^ d[5] ^ d[2] ^ c[20] ^ c[26] ^ c[29] ^ c[30];
        	newcrc[29] = d[7] ^ d[6] ^ d[3] ^ c[21] ^ c[27] ^ c[30] ^ c[31];
        	newcrc[30] = d[7] ^ d[4] ^ c[22] ^ c[28] ^ c[31];
        	newcrc[31] = d[5] ^ c[23] ^ c[29];
        	nextCRC32_D8 = newcrc;
		end/*}}}*/
  endfunction



endclass : pcie_tlp_pkt

`endif


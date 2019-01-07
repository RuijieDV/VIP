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
//     FileName: mac_pkt.sv
//         Desc: MAC layer pkt 
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2013-07-25 17:31:40
//      History:
//============================================================================*/

`ifndef MAC_PKT__SV
`define MAC_PKT__SV

class mac_pkt extends uvm_sequence_item;                                  
   
	`SET_CLASSID
    //##################################
	bit      [ 7:0] mac_data[$];
	int             m_idle_cfg ;
    //##################################
	rand rand_policy_base #(mac_pkt) pcy[$];
    //##################################
	rand bit        is_phy;
	rand bit [ 7:0] preamble[7];
	rand bit [ 7:0] sfd;
    //##################################
	rand bit [ 7:0] da[6];
	rand bit [ 7:0] sa[6];
    //##################################
	//vlan
	rand bit        is_vlan;
    rand bit [15:0] vlan_tp;
    rand bit [ 2:0] vlan_pri;
    rand bit        vlan_cfi;
    rand bit [11:0] vlan_id;
    //##################################
	rand bit [ 7:0] mtype[2];
	     bit [ 7:0] up_payload[];
	rand bit [31:0] fcs;
	rand bit        has_scapy;
	rand bit        has_fcs;
	rand bit        fcs_err;
    //##################################
	rand bit        padding;
	rand uint_t     ipg ;
	rand bit        gap ;
	rand bit        err;
    //##################################
	constraint c_padding {
		soft padding == 1;
	}
	constraint c_ipg {
		soft ipg == 0;
	}

	constraint c_gap {
		soft gap inside {0,1};
	}

	constraint c_err {
		soft err == 0;
	}

	constraint c_preamble {
		foreach(preamble[i])
			soft preamble[i] == 8'h55;
	}

	constraint c_sfd {
		soft sfd == 8'hD5;
	}

	constraint c_da {
		foreach(da[i])
			soft da[i] == 8'h55;
	}

	constraint c_sa {
		foreach(sa[i])
			soft sa[i] == 8'hAA;
	}

	constraint c_mtype {
		soft mtype[0] == 8'h08;
		soft mtype[1] == 8'h00;
	}

	constraint c_has_fcs {
		soft has_fcs == 1;
	}

    constraint c_has_scapy {
		soft has_scapy == 0;
	}


	constraint c_fcs_err {
		soft fcs_err == 0;
	}


	constraint c_is_phy {
		soft is_phy == 0;
	}

	constraint c_is_vlan {
		soft is_vlan == 0;
	}

	constraint c_vlan_tp {
		soft (is_vlan == 1) -> (vlan_tp == 16'h8100);
	}

	`uvm_object_utils_begin(mac_pkt)
	    `uvm_field_queue_int(mac_data,UVM_DEFAULT)
		`uvm_field_int(m_idle_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		if(is_phy == 1) begin 
			`uvm_field_int(is_phy,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(preamble,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(sfd,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
		if(has_scapy == 0) begin 
			`uvm_field_int       (has_scapy,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(da,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(sa,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			if(is_vlan == 1) begin 
				`uvm_field_int(is_vlan,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(vlan_tp,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(vlan_pri,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(vlan_cfi,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    `uvm_field_int(vlan_id,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
			`uvm_field_sarray_int(mtype,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_array_int(up_payload,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (has_fcs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (fcs_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (fcs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (padding,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (ipg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (gap,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
		else begin 
			`uvm_field_int       (has_scapy,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_array_int(up_payload,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (has_fcs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (fcs_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (fcs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (padding,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (ipg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (gap,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int       (err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
    `uvm_object_utils_end
  
    function new (string name = "mac_pkt");
		super.new(name);
    endfunction : new

    function void pre_randomize(); 
		foreach(pcy[i]) pcy[i].set_item(this); 
	endfunction 

    function void post_randomize();
        bit [7:0] dq[];/*{{{*/
		int upl_sz;
    	if(has_scapy == 1) begin 
			upl_sz = this.up_payload.size();
			if(upl_sz < 60) begin 
				`uvm_info("MAC_PKT_LEN",$sformatf("SCAPY pkt length[%0d] less than smallest length[60]!",upl_sz),UVM_MEDIUM)
				if(padding == 1) begin 
					`uvm_info("MAC_PKT_LEN","Padding to 60 bytes now.........",UVM_LOW)
					this.up_payload = new[60](this.up_payload);
				end
			end
			this.fcs = this.computer_crc(this.up_payload);
			this.mac_data = {this.up_payload,fcs[31:24],fcs[23:16],fcs[15:8],fcs[7:0]};
			if(is_phy == 1)
				this.mac_data = {preamble,sfd,this.mac_data};
		end
		else begin 
			upl_sz = up_payload.size();
			if(is_vlan == 0) begin 
				if(upl_sz < 46) begin 
					`uvm_info("MAC_PKT_LEN",$sformatf("Up network layer pkt length[%0d] less than smallest length[46]!",up_payload.size()),UVM_MEDIUM)
				    if(padding == 1) begin 
						`uvm_info("MAC_PKT_LEN","Padding to 46 bytes now.........",UVM_LOW)
						up_payload = new[46](up_payload);
					end
				end
			end
			else begin 
				if(upl_sz < 42) begin 
					`uvm_info("VLAN_MAC_PKT_LEN",$sformatf("Up network layer pkt length[%0d] less than smallest length[42]!",up_payload.size()),UVM_MEDIUM)
					 if(padding == 1) begin 
						`uvm_info("VLAN_MAC_PKT_LEN","Padding to 42 bytes now.........",UVM_LOW)
						up_payload = new[42](up_payload);
					end
				end
			end
			//#################################################################
        	//computer CRC
	    	if(is_vlan == 0) begin
				dq = {da,sa,mtype,up_payload};
			end
			else begin 
				bit [31:0] m_vlan;
				m_vlan = {vlan_tp,vlan_pri,vlan_cfi,vlan_id};
				dq = {da,sa,m_vlan[31:24],m_vlan[23:16],m_vlan[15:8],m_vlan[7:0],mtype,up_payload};
			end
			this.fcs = this.computer_crc(dq);
			//#################################################################
			if(is_vlan == 0) begin 
				if(is_phy == 1)
					this.mac_data = {preamble,sfd,da,sa,mtype,up_payload,fcs[31:24],fcs[23:16],fcs[15:8],fcs[7:0]};
				else
					this.mac_data = {da,sa,mtype,up_payload,fcs[31:24],fcs[23:16],fcs[15:8],fcs[7:0]};
			end
			else begin 
				bit [31:0] m_vlan;
				m_vlan = {vlan_tp,vlan_pri,vlan_cfi,vlan_id};
				if(is_phy == 1)
					this.mac_data = {preamble,sfd,da,sa,m_vlan[31:24],m_vlan[23:16],m_vlan[15:8],m_vlan[7:0],mtype,up_payload,fcs[31:24],fcs[23:16],fcs[15:8],fcs[7:0]};
				else
					this.mac_data = {da,sa,m_vlan[31:24],m_vlan[23:16],m_vlan[15:8],m_vlan[7:0],mtype,up_payload,fcs[31:24],fcs[23:16],fcs[15:8],fcs[7:0]};
			end  
		end
		if(has_fcs == 0) begin 
			this.mac_data = this.mac_data[0:$-4];
		end
		/*}}}*/
    endfunction :post_randomize 

	virtual function bit [31:0] computer_crc(bit [7:0] q[]);
	    int q_size;/*{{{*/
	    bit [31:0] crc_32 = 32'hFFFF_FFFF;
	    bit [31:0] next_crc_32;
        q_size = q.size();
	    for(int i=0;i<q_size;i++) begin
	        fcs_calc_task(q[i],crc_32,next_crc_32);
	        crc_32 = next_crc_32;
	    end
	    crc_32 = {<<{crc_32}};
	    computer_crc = ~crc_32;
	    computer_crc ={<<8{computer_crc}};
	    if(this.fcs_err == 1)
	        computer_crc = ~computer_crc;
	    `uvm_info(CLASSID,$sformatf("FCS CRC32 is %0h",computer_crc), UVM_HIGH);/*}}}*/
    endfunction : computer_crc 

	function void fcs_calc_task (input bit [7:0] d,input bit [31:0] crc_reg, output bit [31:0] next_crc);
		next_crc[0] = crc_reg[30] ^ d[7] ^ crc_reg[24] ^ d[1];/*{{{*/
        next_crc[1] = crc_reg[30] ^ crc_reg[31] ^ d[6] ^ d[7] ^ crc_reg[24] ^ d[0] ^ crc_reg[25] ^ d[1];
        next_crc[2] = crc_reg[30] ^ crc_reg[31] ^ d[5] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[26] ^ d[0] ^ d[1];
        next_crc[3] = d[4] ^ crc_reg[31] ^ d[5] ^ d[6] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[27] ^ d[0];
        next_crc[4] = crc_reg[30] ^ d[4] ^ d[5] ^ d[7] ^ crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[28] ^ d[1] ^ d[3];
        next_crc[5] = crc_reg[30] ^ d[4] ^ crc_reg[31] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[29] ^ d[0] ^ d[1] ^ d[2] ^ d[3];
        next_crc[6] = crc_reg[30] ^ crc_reg[31] ^ d[5] ^ d[6] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ d[0] ^ d[1] ^ d[2] ^ d[3];
        next_crc[7] = d[4] ^ d[5] ^ crc_reg[31] ^ d[7] ^ crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ d[0] ^ d[2];
        next_crc[8] = d[4] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[0] ^ d[3];
        next_crc[9] = d[5] ^ d[6] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ d[2] ^ crc_reg[1] ^ d[3];
        next_crc[10] = d[4] ^ d[5] ^ d[7] ^ crc_reg[24] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ d[2] ^ crc_reg[2];
        next_crc[11] = d[4] ^ crc_reg[3] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[27] ^ crc_reg[28] ^ d[3];
        next_crc[12] = crc_reg[30] ^ d[5] ^ crc_reg[4] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[28] ^ crc_reg[29] ^ d[1] ^ d[2] ^ d[3];
        next_crc[13] = d[4] ^ crc_reg[30] ^ crc_reg[31] ^ d[5] ^ d[6] ^ crc_reg[5] ^ crc_reg[25] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[29] ^ d[0] ^ d[1] ^ d[2];
        next_crc[14] = d[4] ^ crc_reg[30] ^ d[5] ^ crc_reg[31] ^ crc_reg[6] ^ crc_reg[26] ^ crc_reg[27] ^ crc_reg[28] ^ d[0] ^ d[1] ^ d[3];
        next_crc[15] = d[4] ^ crc_reg[31] ^ crc_reg[7] ^ crc_reg[27] ^ crc_reg[28] ^ crc_reg[29] ^ d[0] ^ d[2] ^ d[3];
        next_crc[16] = d[7] ^ crc_reg[24] ^ crc_reg[8] ^ crc_reg[28] ^ crc_reg[29] ^ d[2] ^ d[3];
        next_crc[17] = crc_reg[30] ^ d[6] ^ crc_reg[25] ^ crc_reg[9] ^ crc_reg[29] ^ d[1] ^ d[2];
        next_crc[18] = crc_reg[30] ^ d[5] ^ crc_reg[31] ^ crc_reg[26] ^ d[0] ^ d[1] ^ crc_reg[10];
        next_crc[19] = d[4] ^ crc_reg[31] ^ crc_reg[27] ^ d[0] ^ crc_reg[11];
        next_crc[20] = crc_reg[12] ^ crc_reg[28] ^ d[3];
        next_crc[21] = crc_reg[13] ^ crc_reg[29] ^ d[2];
        next_crc[22] = crc_reg[14] ^ d[7] ^ crc_reg[24];
        next_crc[23] = crc_reg[30] ^ d[6] ^ d[7] ^ crc_reg[24] ^ crc_reg[15] ^ crc_reg[25] ^ d[1];
        next_crc[24] = crc_reg[31] ^ d[5] ^ d[6] ^ crc_reg[25] ^ crc_reg[16] ^ crc_reg[26] ^ d[0];
        next_crc[25] = d[4] ^ d[5] ^ crc_reg[26] ^ crc_reg[17] ^ crc_reg[27];
        next_crc[26] = crc_reg[30] ^ d[4] ^ d[7] ^ crc_reg[24] ^ crc_reg[27] ^ crc_reg[18] ^ crc_reg[28] ^ d[1] ^ d[3];
        next_crc[27] = crc_reg[31] ^ d[6] ^ crc_reg[25] ^ crc_reg[28] ^ crc_reg[19] ^ crc_reg[29] ^ d[0] ^ d[2] ^ d[3];
        next_crc[28] = crc_reg[30] ^ d[5] ^ crc_reg[26] ^ crc_reg[29] ^ d[1] ^ d[2] ^ crc_reg[20];
        next_crc[29] = d[4] ^ crc_reg[30] ^ crc_reg[21] ^ crc_reg[31] ^ crc_reg[27] ^ d[0] ^ d[1];
        next_crc[30] = crc_reg[31] ^ crc_reg[22] ^ crc_reg[28] ^ d[0] ^ d[3];
        next_crc[31] = crc_reg[23] ^ crc_reg[29] ^ d[2]; /*}}}*/
	endfunction

	function void hexdump();
		int sz;
		sz = this.mac_data.size();
		$display($sformatf("[%0s::%0t::%0d]:\n#####################################################",CLASSID,$time,sz));
		for (int i=0;i<sz;i++) begin
			if(i%16 == 0)
				$write("%4h  ",16*(i/16));
			$write("%2h ",mac_data[i]);
			if (i%16 == 15) $write("\n");
		end
		$write("\n");
		$display("#####################################################");
	endfunction

endclass : mac_pkt

`endif


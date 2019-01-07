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
//     FileName: trans_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-31 14:51:35
//      History:
//============================================================================*/
`ifndef TRANS_PKT__SV
`define TRANS_PKT__SV

class trans_pkt extends uvm_sequence_item;

	`SET_CLASSID
	//###################################
	rand bit           is_ipv4;
	rand bit           is_ipv6;
    rand bit           is_tcp ;
	rand bit           is_udp ;
	rand bit           is_icmp;
	rand bit           is_igmp;
	rand bit           is_mld ;
	//###################################
	bit       [ 7:0]   trans_data[$];
	//###################################
	rand bit  [15:0]   udp_src_port;
    rand bit  [15:0]   udp_dst_port;
	rand bit  [15:0]   udp_length;      
	rand bit  [15:0]   udp_checksum;
	rand bit           udp_chksum_err;
	//###################################
	rand bit  [15:0]   tcp_src_port;
    rand bit  [15:0]   tcp_dst_port;
    rand bit  [31:0]   tcp_seq;
    rand bit  [31:0]   tcp_ack_seq;
    rand bit  [3:0]    tcp_doff;
    rand bit  [5:0]    tcp_rev;
    rand bit           tcp_urg;
    rand bit           tcp_ack;
    rand bit           tcp_psh;
    rand bit           tcp_rst;
    rand bit           tcp_syn;
    rand bit           tcp_fin;
    rand bit  [15:0]   tcp_windows;
    rand bit  [15:0]   tcp_checksum;
    rand bit  [15:0]   tcp_urg_ptr;
	rand bit  [31:0]   tcp_var_part[];
    rand bit  [15:0]   tcp_length;
	rand bit           tcp_chksum_err;
	//###################################
	rand bit  [7:0]    icmp_type;
	rand bit  [7:0]    icmp_code;
	rand bit  [15:0]   icmp_checksum;
	rand bit  [31:0]   icmp_rev;
	rand bit           icmp_chksum_err;
	//###################################
	//IGMP V1-2-3
	rand bit  [7:0]    igmp_type;
	rand bit  [7:0]    igmp_mrd;
	rand bit  [15:0]   igmp_checksum;
	rand bit  [31:0]   igmp_grp_addr;
	rand bit  [31:0]   igmp_ext_dt[];
	rand bit           igmp_chksum_err;
	//###################################
	//MLD V1-2
	rand bit  [7:0]    mld_type;
	rand bit  [7:0]    mld_code;
	rand bit  [15:0]   mld_checksum;
	rand bit  [15:0]   mld_mrd;
	rand bit  [15:0]   mld_rev;
	rand bit  [31:0]   mld_grp_addr;
	rand bit  [31:0]   mld_ext_dt[];
	rand bit           mld_chksum_err;
	//###################################
	//IPV4 
	rand ip_pkt        m_ip_pkt;
	//###################################
         bit  [7:0]    up_payload[]; 
    //################################
	//for checksum
    rand bit  [31:0]   pseudo_ipv4_src;
    rand bit  [31:0]   pseudo_ipv4_dest;
    rand bit  [7:0]    pseudo_ipv4_protocol;
    rand bit  [31:0]   pseudo_ipv6_src[4];
    rand bit  [31:0]   pseudo_ipv6_dest[4];
    rand bit  [7:0]    pseudo_ipv6_nheader;
         bit  [7:0]    pseudo_rev = 8'b0;
    //################################
	constraint c_ipv4_6 {
		soft $countones({is_ipv4,is_ipv6}) == 1;
	}

	constraint c_tcp_udp {
		soft $countones({is_tcp,is_udp,is_icmp,is_igmp,is_mld}) == 1;
	}

	constraint c_ip6_igmp {
		soft (is_igmp == 1) -> (is_ipv6 == 0);
	}
	
	constraint c_ip4_mld {
		soft (is_mld == 1) -> (is_ipv4 == 0);
	}
    //################################
	constraint c_tcp_doff {
		soft tcp_doff == 5;//default 20 bytes
	}
	
	constraint c_tcp_var_part {
		soft tcp_var_part.size() == tcp_doff - 5;
	}

	constraint c_igmp_ext_dt {
		soft igmp_ext_dt.size() == 0;
	}
	constraint c_mld_ext_dt {
		soft mld_ext_dt.size() == 0;
	}
    //################################
	constraint c_p_ipv4_protocol {
		if(is_tcp == 1) {
		    soft pseudo_ipv4_protocol == 8'd6;
		    soft pseudo_ipv6_nheader  == 8'd6;
	  	}
		else if(is_udp == 1) {
		    soft pseudo_ipv4_protocol == 8'd17;
		    soft pseudo_ipv6_nheader  == 8'd17;
		}
		else if(is_icmp == 1) {
		    soft pseudo_ipv4_protocol == 8'd1;
		    soft pseudo_ipv6_nheader  == 8'd1;
		}
		else if(is_igmp == 1) {
		    soft pseudo_ipv4_protocol == 8'd2;
		}
		else if(is_mld == 1) {
		    soft pseudo_ipv6_nheader  == 8'd0;
		}
	}
    //################################
  
	`uvm_object_utils_begin(trans_pkt)
		`uvm_field_queue_int(trans_data, UVM_DEFAULT)
		if(is_ipv4 == 1) begin 
			`uvm_field_int(is_ipv4,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)/*{{{*/ 
			`uvm_field_int(pseudo_ipv4_src,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(pseudo_ipv4_dest,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(pseudo_rev,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(pseudo_ipv4_protocol,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)/*}}}*/ 
		end
		if(is_ipv6 == 1) begin 
			`uvm_field_int(is_ipv6,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_sarray_int(pseudo_ipv6_src,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_sarray_int(pseudo_ipv6_dest,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(pseudo_rev,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(pseudo_ipv6_nheader,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
		end
		if (is_udp == 1'b1) begin/*{{{*/
			`uvm_field_int(is_udp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			`uvm_field_int(udp_src_port,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(udp_dst_port,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(udp_length  ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(udp_checksum,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(udp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		end
		if (is_tcp == 1'b1) begin
			`uvm_field_int(is_tcp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(tcp_src_port ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)      
            `uvm_field_int(tcp_dst_port ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)      
            `uvm_field_int(tcp_seq      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_ack_seq  ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_doff     ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_rev      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_urg      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_ack      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_psh      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_rst      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_syn      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_fin      ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_windows  ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_checksum ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_int(tcp_urg_ptr  ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
            `uvm_field_array_int(tcp_var_part ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(tcp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		end /*}}}*/
		if(is_icmp == 1) begin 
			`uvm_field_int(is_icmp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) /*{{{*/
			`uvm_field_int(icmp_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(icmp_code,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(icmp_checksum,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(icmp_rev,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(icmp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)/*}}}*/ 
		end
		if(is_igmp == 1) begin 
			`uvm_field_int(is_igmp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			`uvm_field_int(igmp_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(igmp_mrd,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(igmp_checksum,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(igmp_grp_addr,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_array_int(igmp_ext_dt,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(igmp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		end
		if(is_mld == 1) begin 
			`uvm_field_int(is_mld,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			`uvm_field_int(mld_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_code,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_checksum,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_mrd,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_rev,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_grp_addr,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_array_int(mld_ext_dt,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			`uvm_field_int(mld_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
		end
		`uvm_field_array_int(up_payload ,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
		`uvm_object_utils_end

	function new(string name = "trans_pkt");
		super.new(name);
	endfunction : new

    function void post_randomize();
		bit [15:0] dq[$];
		int upl_sz;
		int mod;
		int rend;
        upl_sz = up_payload.size();
		mod = upl_sz%2;
		rend = upl_sz/2;
		if($countones({is_ipv4,is_ipv6}) != 1) 
			`uvm_fatal(CLASSID,"You must set just one IPV4/IPV6 pkt mode!!!")
		if($countones({is_tcp,is_udp,is_icmp,is_igmp,is_mld}) != 1)  begin 
			`uvm_fatal(CLASSID,"You must set just one TCP/UDP/ICMP/IGMP/MLD/IPV4inIPV4 pkt mode!!!")
		end
		//#######################################################################
		//pseudo_head
		if(is_ipv4 == 1) begin 
			//--------------------------------------------------/*{{{*/
            dq.push_back(pseudo_ipv4_src[31:16]);
		    dq.push_back(pseudo_ipv4_src[15:0]);
		    dq.push_back(pseudo_ipv4_dest[31:16]);
		    dq.push_back(pseudo_ipv4_dest[15:0]);
			dq.push_back({pseudo_rev,pseudo_ipv4_protocol});
			//--------------------------------------------------/*}}}*/
		end
		else if(is_ipv6 == 1) begin 
			//--------------------------------------------------/*{{{*/
			for(int i=0;i<4;i++) begin 
				dq.push_back(pseudo_ipv6_src[i][31:16]);
				dq.push_back(pseudo_ipv6_src[i][15:0]);
			end
			for(int i=0;i<4;i++) begin 
				dq.push_back(pseudo_ipv6_dest[i][31:16]);
				dq.push_back(pseudo_ipv6_dest[i][15:0]);
			end
			dq.push_back({pseudo_rev,pseudo_ipv6_nheader});
			//--------------------------------------------------/*}}}*/
		end
		//#######################################################################
		if(is_udp == 1) begin 
		    udp_length = upl_sz + 8;/*{{{*/
			dq.push_back(udp_length);
			dq.push_back(udp_src_port);
			dq.push_back(udp_dst_port);
			dq.push_back(udp_length);
			dq.push_back(16'b0);
			for(int i=0;i<rend;i++)
				dq.push_back({up_payload[2*i],up_payload[2*i+1]});
			if(mod != 0) 
				dq.push_back({up_payload[upl_sz-1],8'b0});
			udp_checksum = TransCheckSum(dq);
			if(udp_chksum_err == 1)
				udp_checksum = ~udp_checksum;
			trans_data = {udp_src_port[15:8],udp_src_port[7:0],udp_dst_port[15:8],udp_dst_port[7:0],udp_length[15:8],udp_length[7:0],
			              udp_checksum[15:8],udp_checksum[7:0],up_payload};
			//--------------------------------------------------/*}}}*/
		end
		else if(is_tcp == 1) begin 
 			tcp_length = upl_sz + tcp_doff*4;/*{{{*/
			dq.push_back(tcp_length);
			dq.push_back(tcp_src_port);
			dq.push_back(tcp_dst_port);
			dq.push_back(tcp_seq[31:16]);
			dq.push_back(tcp_seq[15: 0]);
			dq.push_back(tcp_ack_seq[31:16]);
			dq.push_back(tcp_ack_seq[15: 0]);
			dq.push_back({tcp_doff,tcp_rev,tcp_urg,tcp_ack,tcp_psh,tcp_rst,tcp_syn,tcp_fin});
			dq.push_back(tcp_windows);
			dq.push_back(16'b0);//checksum
			dq.push_back(tcp_urg_ptr);
			for(int i=0;i<tcp_var_part.size();i++) begin 
				dq.push_back(tcp_var_part[i][31:16]);
				dq.push_back(tcp_var_part[i][15: 0]);
			end
			for(int i=0;i<rend;i++)
				dq.push_back({up_payload[2*i],up_payload[2*i+1]});
			if(mod != 0) 
				dq.push_back({up_payload[upl_sz-1],8'b0});
			tcp_checksum = TransCheckSum(dq);
			if(tcp_chksum_err == 1)
				tcp_checksum = ~tcp_checksum;
			trans_data = {tcp_src_port[15:8],tcp_src_port[7:0],tcp_dst_port[15:8],tcp_dst_port[7:0],tcp_seq[31:24],tcp_seq[23:16],
		                  tcp_seq[15:8],tcp_seq[7:0],tcp_ack_seq[31:24],tcp_ack_seq[23:16],tcp_ack_seq[15:8],tcp_ack_seq[7:0],
					      {tcp_doff,tcp_rev[5:2]},{tcp_rev[1:0],tcp_urg,tcp_ack,tcp_psh,tcp_rst,tcp_syn,tcp_fin},tcp_windows[15:8],
					      tcp_windows[7:0],tcp_checksum[15:8],tcp_checksum[7:0],tcp_urg_ptr[15:8],tcp_urg_ptr[7:0]};
			for(int i=0;i<tcp_var_part.size();i++) begin 
				trans_data.push_back(tcp_var_part[i][31:24]);
				trans_data.push_back(tcp_var_part[i][23:16]);
				trans_data.push_back(tcp_var_part[i][15: 8]);
				trans_data.push_back(tcp_var_part[i][ 7: 0]);
			end
			trans_data = {trans_data,up_payload};
			//--------------------------------------------------/*}}}*/
		end
		else if(is_icmp == 1) begin 
 			bit [15:0] icmp_length;/*{{{*/
			if(is_ipv4 == 1)
				dq.delete();
			if(upl_sz%4 != 0)
				`uvm_fatal(CLASSID,$sformatf("ICMP up_payload size[%0d] must 4bytes align!!!",upl_sz))
		    icmp_length = upl_sz + 8;
			dq.push_back(icmp_length);
			dq.push_back({icmp_type,icmp_code});
			dq.push_back(16'b0);//checksum
			dq.push_back(icmp_rev[31:16]);
			dq.push_back(icmp_rev[15: 0]);
			for(int i=0;i<rend;i++)
				dq.push_back({up_payload[2*i],up_payload[2*i+1]});
			icmp_checksum = TransCheckSum(dq);
			if(icmp_chksum_err == 1)
				icmp_checksum = ~icmp_checksum;
			trans_data = {icmp_type,icmp_code,icmp_checksum[15:8],icmp_checksum[7:0],icmp_rev[31:24],icmp_rev[23:16],
			              icmp_rev[15:8],icmp_rev[7:0],up_payload};/*}}}*/
		end
		else if(is_igmp == 1) begin 
 			if(is_ipv6 == 1)/*{{{*/
				`uvm_fatal(CLASSID,"IGMP can not on ipv6!!!!")
			dq.delete();
			dq.push_back({igmp_type,igmp_mrd});
			dq.push_back(16'b0);//checksum
			dq.push_back(igmp_grp_addr[31:16]);
			dq.push_back(igmp_grp_addr[15: 0]);
			for(int i=0;i<igmp_ext_dt.size();i++) begin 
				dq.push_back(igmp_ext_dt[i][31:16]);
				dq.push_back(igmp_ext_dt[i][15: 0]);
			end
			for(int i=0;i<rend;i++)
				dq.push_back({up_payload[2*i],up_payload[2*i+1]});
			if(mod != 0) 
				dq.push_back({up_payload[upl_sz-1],8'b0});
			igmp_checksum = TransCheckSum(dq);
			if(igmp_chksum_err == 1)
				igmp_checksum = ~igmp_checksum;
			trans_data = {igmp_type,igmp_mrd,igmp_checksum[15:8],igmp_checksum[7:0],igmp_grp_addr[31:24],igmp_grp_addr[23:16],
			              igmp_grp_addr[15:8],igmp_grp_addr[7:0]};
			for(int i=0;i<igmp_ext_dt.size();i++) begin 
				trans_data.push_back(igmp_ext_dt[i][31:24]);
				trans_data.push_back(igmp_ext_dt[i][23:16]);
				trans_data.push_back(igmp_ext_dt[i][15: 8]);
				trans_data.push_back(igmp_ext_dt[i][ 7: 0]);
			end
			trans_data = {trans_data,up_payload};/*}}}*/
		end
		else if(is_mld == 1) begin 
			if(is_ipv4 == 1)/*{{{*/
				`uvm_fatal(CLASSID,"MLD can not on ipv4!!!!")
			dq.delete();
			dq.push_back({mld_type,mld_code});
			dq.push_back(16'b0);//checksum
			dq.push_back(mld_mrd);
			dq.push_back(mld_rev);
			dq.push_back(mld_grp_addr[31:16]);
			dq.push_back(mld_grp_addr[15: 0]);
			for(int i=0;i<mld_ext_dt.size();i++) begin 
				dq.push_back(mld_ext_dt[i][31:16]);
				dq.push_back(mld_ext_dt[i][15: 0]);
			end
			for(int i=0;i<rend;i++)
				dq.push_back({up_payload[2*i],up_payload[2*i+1]});
			if(mod != 0) 
				dq.push_back({up_payload[upl_sz-1],8'b0});
			mld_checksum = TransCheckSum(dq);
			if(mld_chksum_err == 1)
				mld_checksum = ~mld_checksum;
			trans_data = {mld_type,mld_code,mld_checksum[15:8],mld_checksum[7:0],mld_mrd[15:8],mld_mrd[7:0],
			              mld_rev[15:8],mld_rev[7:0],mld_grp_addr[31:24],mld_grp_addr[23:16],mld_grp_addr[15:8],
						  mld_grp_addr[7:0]};
			for(int i=0;i<mld_ext_dt.size();i++) begin 
				trans_data.push_back(mld_ext_dt[i][31:24]);
				trans_data.push_back(mld_ext_dt[i][23:16]);
				trans_data.push_back(mld_ext_dt[i][15: 8]);
				trans_data.push_back(mld_ext_dt[i][ 7: 0]);
			end
			trans_data = {trans_data,up_payload};/*}}}*/
		end
	endfunction:post_randomize 
  
	virtual function bit [15:0] TransCheckSum(input bit [15:0] q[$]);
		longint sum = 0;/*{{{*/
        //#######################
		//reverse code sum
		foreach(q[i]) begin 
			sum += q[i];
		end
		sum = (sum>>16) + (sum&16'hFFFF);
		sum += (sum>>16);
		sum = ~sum;
        //#######################
		TransCheckSum = sum[15:0];/*}}}*/
	endfunction

endclass:trans_pkt

`endif


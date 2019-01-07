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
//     FileName: ip_pkt.sv
//         Desc: MAC layer pkt 
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2013-07-25 17:31:40
//      History:
//============================================================================*/

`ifndef IP_PKT__SV
`define IP_PKT__SV

class ip_pkt extends uvm_sequence_item;                                  
  
	`SET_CLASSID
	//###################################
	rand bit           is_mpls;
	rand bit           is_ipv4;
	rand bit           is_ipv6;
	rand bit           is_arp;
	//###################################
	bit       [ 7:0]   ip_data[$];
	//###################################
	//MPLS
	rand int unsigned  mpls_len;
	rand bit  [19:0]   mpls_label[];
	rand bit  [ 2:0]   mpls_exp[];
	rand bit           mpls_bos[];
	rand bit  [ 7:0]   mpls_ttl[];
	//###################################
	//IPV4
         bit  [ 3:0]   iph_ver = 4'h4;
    rand bit  [ 3:0]   iph_len;
    rand bit  [ 7:0]   iph_tos;
    rand bit  [15:0]   iph_total_len;
    rand bit  [15:0]   iph_id;
    rand bit  [ 2:0]   iph_flag;
    rand bit  [12:0]   iph_offset;
    rand bit  [ 7:0]   iph_ttl;
    rand bit  [ 7:0]   iph_protocol;
    rand bit  [15:0]   iph_xsum;
    rand bit  [31:0]   iph_src;
    rand bit  [31:0]   iph_dest;
	rand bit  [31:0]   iph_opt_seg[];
	rand bit           iph_xsum_err;
	//###################################
	//IPV6
         bit  [ 3:0]   iph6_ver = 4'h6;
    rand bit  [ 7:0]   iph6_tc;
    rand bit  [19:0]   iph6_flowlabel;
    rand bit  [15:0]   iph6_payload_len;
    rand bit  [ 7:0]   iph6_nheader;
    rand bit  [ 7:0]   iph6_hoplimit;
    rand bit  [31:0]   iph6_src[4];
    rand bit  [31:0]   iph6_dest[4];
    rand bit  [ 7:0]   iph6_ext_header[];
	//###################################
         bit  [ 7:0]   up_payload[];
	//###################################
	//ARP
	     bit [15:0]    arp_hw_type = 1;
	     bit [15:0]    arp_eth_type = 16'h0800;
	     bit [ 7:0]    arp_hw_len = 6;
	     bit [ 7:0]    arp_pro_len = 4;
	rand bit [15:0]    arp_op;
	rand bit [ 7:0]    arp_sender_hw_addr[6];
	rand bit [ 7:0]    arp_sender_ip_addr[4];
	rand bit [ 7:0]    arp_target_hw_addr[6];
	rand bit [ 7:0]    arp_target_ip_addr[4];
	//###################################
	constraint c_ipv4_6 {
		soft $countones({is_ipv4,is_ipv6,is_arp}) == 1;
	}

	constraint c_iph_len {
		soft iph_len == 5;
	}

	constraint c_iph_opt_seg {
		soft iph_opt_seg.size() == iph_len - 5;
	}
	
	constraint c_iph_xsum_err {
		soft iph_xsum_err == 0;
	}

	constraint c_iph_ttl {
		soft iph_ttl == 1;/*just for IGMP*/
	}
	
	constraint c_iph6_ext_header_sz {
		soft iph6_ext_header.size() == 0;
	}
	//###################################
	constraint c_mpls_len {
		if(is_mpls == 1)  
			soft mpls_len inside {[1:10]};
		else
			soft mpls_len == 0;
	}

	constraint c_mpls_sz {
		soft mpls_label.size() == mpls_len;
		soft mpls_exp.size() == mpls_len;
		soft mpls_bos.size() == mpls_len;
		soft mpls_ttl.size() == mpls_len;
	}
	//###################################
	constraint c_arp_op {
		soft arp_op inside {1,2,3,4};
	}
	//###################################
  
	`uvm_object_utils_begin(ip_pkt)
		`uvm_field_queue_int(ip_data, UVM_DEFAULT)
		if(is_arp == 1) begin 
      		`uvm_field_int(is_arp      , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_int(arp_hw_type , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_int(arp_eth_type, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_int(arp_hw_len  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_int(arp_pro_len , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_int(arp_op      , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_sarray_int(arp_sender_hw_addr , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_sarray_int(arp_sender_ip_addr , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_sarray_int(arp_target_hw_addr , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      		`uvm_field_sarray_int(arp_target_ip_addr , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		end
		else begin 
		    if(is_mpls == 1'b1) begin 
		    	`uvm_field_int(is_mpls, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_int(mpls_len, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_sarray_int(mpls_label, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_sarray_int(mpls_exp  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_sarray_int(mpls_bos  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_sarray_int(mpls_ttl  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    end
		    if (is_ipv4 == 1'b1) begin
		    	`uvm_field_int(is_ipv4, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_int(iph_ver       , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_len       , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_tos       , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_total_len , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_id        , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_flag      , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_offset    , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_ttl       , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_protocol  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_xsum      , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_src       , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_dest      , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_array_int(iph_opt_seg, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph_xsum_err  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    end
		    if (is_ipv6 == 1'b1) begin
		    	`uvm_field_int(is_ipv6, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    	`uvm_field_int(iph6_ver         , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph6_tc          , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph6_flowlabel   , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph6_payload_len , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph6_nheader     , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_int(iph6_hoplimit    , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_sarray_int(iph6_src  , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_sarray_int(iph6_dest , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
      	    	`uvm_field_array_int(iph6_ext_header , UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
		    end
			`uvm_field_array_int(up_payload, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)            
		end
	`uvm_object_utils_end

	function new(string name = "ip_pkt");
		super.new(name);
	endfunction : new

    function void post_randomize();
		if(is_arp == 1) begin 
			ip_data.push_back(arp_hw_type[15:8]);/*{{{*/
			ip_data.push_back(arp_hw_type[ 7:0]);
			ip_data.push_back(arp_eth_type[15:8]);
			ip_data.push_back(arp_eth_type[ 7:0]);
			ip_data.push_back(arp_hw_len);
			ip_data.push_back(arp_pro_len);
			ip_data.push_back(arp_op[15:8]);
			ip_data.push_back(arp_op[ 7:0]);
			for(int i=0;i<6;i++)
				ip_data.push_back(arp_sender_hw_addr[i]);
			for(int i=0;i<4;i++)
				ip_data.push_back(arp_sender_ip_addr[i]);
			for(int i=0;i<6;i++)
				ip_data.push_back(arp_target_hw_addr[i]);
			for(int i=0;i<4;i++)
				ip_data.push_back(arp_target_ip_addr[i]);/*}}}*/
		end
		else begin 
		    int upl_sz;/*{{{*/
		    if($countones({is_ipv4,is_ipv6}) != 1) 
		    	`uvm_fatal(CLASSID,"You must set just one IPV4/IPV6 pkt mode!!!")
		    upl_sz = up_payload.size();
		    if(upl_sz == 0)
		    	`uvm_error(CLASSID,"Your up_payload size is zero!!!")
		    if(is_mpls == 1) begin 
		    	for(int i=0;i<mpls_len;i++)begin 
		    	    ip_data.push_back(mpls_label[i][19:12]);
		    	    ip_data.push_back(mpls_label[i][11:4]);
		    		if(i == mpls_len - 1) begin 
		    			mpls_bos[i] = 1;
		    			ip_data.push_back({mpls_label[i][3:0],mpls_exp[i],mpls_bos[i]});
		    		end
		    		else begin 
		    			mpls_bos[i] = 0;
		    			ip_data.push_back({mpls_label[i][3:0],mpls_exp[i],mpls_bos[i]});
		    		end
		    	    ip_data.push_back(mpls_ttl[i]);
		    	end
		    end
		    if(is_ipv4 == 1) begin 
		    	bit [31:0] ip_header[];/*{{{*/
		        bit [15:0] xsum_calc_dt;
		    	iph_total_len = iph_len*4 + upl_sz;
		    	ip_header = new[iph_len];
		        ip_header[0] = {iph_ver,iph_len,iph_tos,iph_total_len};
    	        ip_header[1] = {iph_id,iph_flag,iph_offset};
    	        ip_header[2] = {iph_ttl,iph_protocol,16'b0/*iph_xsum*/};
    	        ip_header[3] = iph_src;
    	        ip_header[4] = iph_dest;
		    	for(int i=0;i<iph_len-5;i++)
		    		ip_header[5+i] = iph_opt_seg[i];
		        xsum_calc(ip_header,xsum_calc_dt);
		        iph_xsum = (iph_xsum_err == 0) ? xsum_calc_dt : ~xsum_calc_dt;
		        ip_data.push_back({iph_ver,iph_len});
		        ip_data.push_back(iph_tos);
		        ip_data.push_back(iph_total_len[15:8]);
		        ip_data.push_back(iph_total_len[7:0]);
		        ip_data.push_back(iph_id[15:8]);
		        ip_data.push_back(iph_id[7:0]);
		        ip_data.push_back({iph_flag[2:0],iph_offset[12:8]});
		        ip_data.push_back(iph_offset[7:0]);
		        ip_data.push_back(iph_ttl);
		        ip_data.push_back(iph_protocol);
		        ip_data.push_back(iph_xsum[15:8]);
		        ip_data.push_back(iph_xsum[7:0]);
		        ip_data.push_back(iph_src[31:24]);
		        ip_data.push_back(iph_src[23:16]);
		        ip_data.push_back(iph_src[15: 8]);
		        ip_data.push_back(iph_src[ 7: 0]);
		        ip_data.push_back(iph_dest[31:24]);
		        ip_data.push_back(iph_dest[23:16]);
		        ip_data.push_back(iph_dest[15: 8]);
		        ip_data.push_back(iph_dest[ 7: 0]);
		    	for(int i=0;i<iph_len-5;i++) begin 
		    		ip_data.push_back(iph_opt_seg[i][31:24]);
		    		ip_data.push_back(iph_opt_seg[i][23:16]);
		    		ip_data.push_back(iph_opt_seg[i][15: 8]);
		    		ip_data.push_back(iph_opt_seg[i][ 7: 0]);
		    	end/*}}}*/
		    end
		    if(is_ipv6 == 1) begin
		    	iph6_payload_len = upl_sz;/*{{{*/
		        ip_data.push_back({iph6_ver[3:0],iph6_tc[7:4]});
		        ip_data.push_back({iph6_tc[3:0],iph6_flowlabel[19:16]});
		        ip_data.push_back(iph6_flowlabel[15:8]);
		        ip_data.push_back(iph6_flowlabel[7:0]);
		        ip_data.push_back(iph6_payload_len[15:8]);
		        ip_data.push_back(iph6_payload_len[7:0]);
		        ip_data.push_back(iph6_nheader);
		        ip_data.push_back(iph6_hoplimit);
		    	for(int i=0;i<4;i++) begin 
		    		ip_data.push_back(iph6_src[i][31:24]);
		    		ip_data.push_back(iph6_src[i][23:16]);
		    		ip_data.push_back(iph6_src[i][15:8]);
		    		ip_data.push_back(iph6_src[i][7:0]);
		    	end
		    	for(int i=0;i<4;i++) begin 
		    		ip_data.push_back(iph6_dest[i][31:24]);
		    		ip_data.push_back(iph6_dest[i][23:16]);
		    		ip_data.push_back(iph6_dest[i][15:8]);
		    		ip_data.push_back(iph6_dest[i][7:0]);
		    	end
				for(int i=0;i<iph6_ext_header.size();i++)
					ip_data.push_back(iph6_ext_header[i]);
				/*}}}*/
		    end
		    for(int i=0;i<upl_sz;i++)
		    	ip_data.push_back(up_payload[i]);/*}}}*/
		end
    endfunction :post_randomize 

	virtual function void xsum_calc(input bit [31:0] ip_header[5],output bit [15:0] xsum_calc_dt);
		/*{{{*/
		bit [31:0] xsum_calc = 32'h0000_0000;
    	for (int i=0;i<5;i++) begin
    	  xsum_calc = xsum_calc+{16'h0000,ip_header[i][31:16]}+{16'h0000,ip_header[i][15:0]}; 
    	end
    	xsum_calc = {16'h0000,xsum_calc[31:16]}+{16'h0000,xsum_calc[15:0]};
    	xsum_calc = {16'h0000,xsum_calc[31:16]}+{16'h0000,xsum_calc[15:0]};
    	xsum_calc_dt = ~xsum_calc[15:0];
		/*}}}*/
	endfunction

endclass 

`endif 

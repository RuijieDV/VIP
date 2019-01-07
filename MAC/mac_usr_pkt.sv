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
//     FileName: mac_usr_pkt.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 16:06:00
//      History:
//============================================================================*/
`ifndef MAC_USR_PKT__SV
`define MAC_USR_PKT__SV

class mac_usr_pkt extends uvm_sequence_item;                                  

	`SET_CLASSID
	//######################################
	//set transport layer cfg
	bit           has_transport_layer;/*{{{*/
	bit           is_transport_rand;
	bit           is_tcp;
	bit           is_udp;
	bit           is_icmp;
	bit           is_igmp;
	bit           is_mld;
	bit [15:0]    tcp_src_port;
	bit [15:0]    tcp_dst_port;
	bit           tcp_chksum_err;
	bit [15:0]    udp_src_port;
	bit [15:0]    udp_dst_port;
	bit           udp_chksum_err;
	bit  [7:0]    icmp_type;
	bit  [7:0]    icmp_code;
	bit  [31:0]   icmp_rev;
	bit           icmp_chksum_err;
	bit  [7:0]    igmp_type;
	bit  [7:0]    igmp_mrd;
	bit  [31:0]   igmp_grp_addr;
	bit  [31:0]   igmp_ext_dt[];
	bit           igmp_chksum_err;
	bit  [7:0]    mld_type;
	bit  [7:0]    mld_code;
	bit  [15:0]   mld_mrd;
	bit  [31:0]   mld_grp_addr;
	bit  [31:0]   mld_ext_dt[];
	bit           mld_chksum_err;/*}}}*/
	//######################################
	//set ip layer cfg
	bit           has_ip_layer;/*{{{*/
	bit           is_ip_rand;
	bit           is_mpls;
	bit           is_ipv4;
	bit           is_ipv6;
	bit           is_arp;
    int           mpls_len;
    bit [19:0]    mpls_label[];
    bit [ 2:0]    mpls_exp[];
    bit           mpls_bos[];
    bit [ 7:0]    mpls_ttl[];
    bit [ 7:0]    iph_protocol;
    bit [31:0]    iph_src;
    bit [31:0]    iph_dest;
    bit [ 7:0]    iph6_nheader;
    bit [31:0]    iph6_src[4];
    bit [31:0]    iph6_dest[4];
    bit [ 7:0]    iph6_ext_header[];
	bit [15:0]    arp_op;
	bit [ 7:0]    arp_sender_hw_addr[6];
	bit [ 7:0]    arp_sender_ip_addr[4];
	bit [ 7:0]    arp_target_hw_addr[6];
	bit [ 7:0]    arp_target_ip_addr[4];/*}}}*/
	//######################################
	bit           has_tunnel_layer;/*{{{*/
    bit           is_tunnel_ip_rand;
    bit           is_tunnel_mpls;
    bit           is_tunnel_ipv4;
    bit           is_tunnel_ipv6;
    bit           is_tunnel_arp;/*}}}*/
	//######################################
	//set phy layer cfg
	//######################################
	bit           has_phy_layer = 1;/*{{{*/
	bit           has_scapy = 0;
	bit           has_fcs = 1;
	bit           has_padding = 1;
	bit           is_phy_rand = 1;
	bit           is_phy = 1'b1;
	bit           is_vlan = 1'b0;
	int           m_idle_cfg;
	bit [7:0]     da[6];
	bit [7:0]     sa[6];
	bit [7:0]     mtype[2];
	bit           fcs_err;/*}}}*/
	//######################################
	//set USR cfg 
	bit            has_usr_layer;
	bit [21:0]     fqid;
	bit [ 3:0]     gq_sq_cfg;
	bit [14:0]     gq_sq;      
	bit [ 2:0]     fq_pri;
	//######################################
	//set data payload
	bit [7:0]     data[];
	uint_t        chn_id;
	uint_t        len;
	data_gen_enum gen_mode;
	int           api_ctrl_value;
	bit [7:0]     api_ctrl_data[];
	//######################################
	`uvm_object_utils_begin(mac_usr_pkt)
		if(has_usr_layer == 1) begin /*{{{*/ 
			`uvm_field_int(has_usr_layer,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
			`uvm_field_int(fqid,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
			`uvm_field_int(gq_sq_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
			`uvm_field_int(gq_sq,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
			`uvm_field_int(fq_pri,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
		end
	    if(has_transport_layer == 1) begin
			`uvm_field_int(has_transport_layer,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_transport_rand,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			if(is_tcp == 1) begin 
				`uvm_field_int(is_tcp,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(tcp_src_port,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(tcp_dst_port,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(tcp_chksum_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
			if(is_udp == 1) begin
				`uvm_field_int(is_udp,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(udp_src_port,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(udp_dst_port,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
				`uvm_field_int(udp_chksum_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			end
			if(is_icmp == 1) begin 
				`uvm_field_int(is_icmp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(icmp_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(icmp_code,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(icmp_rev,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(icmp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
			end
			if(is_igmp == 1) begin 
				`uvm_field_int(is_igmp,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_int(igmp_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(igmp_mrd,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(igmp_grp_addr,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_array_int(igmp_ext_dt,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(igmp_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			end
			if(is_mld == 1) begin 
				`uvm_field_int(is_mld,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_int(mld_type,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(mld_code,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(mld_mrd,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(mld_grp_addr,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_array_int(mld_ext_dt,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK) 
				`uvm_field_int(mld_chksum_err,UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			end
		end
		if(has_ip_layer == 1)begin 
	  	    `uvm_field_int(has_ip_layer,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	  	    `uvm_field_int(is_ip_rand,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			if(is_arp == 1) begin 
				`uvm_field_int(is_arp, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_int(arp_op, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_sarray_int(arp_sender_hw_addr, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_sarray_int(arp_sender_ip_addr, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_sarray_int(arp_target_hw_addr, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
				`uvm_field_sarray_int(arp_target_ip_addr, UVM_DEFAULT | UVM_NOCOMPARE | UVM_NOPACK)
			end
			else begin 
			    if(is_mpls == 1) begin 
			    	`uvm_field_int(is_mpls,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_int(mpls_len,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(mpls_label,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(mpls_exp,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(mpls_bos,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(mpls_ttl,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    end
			    if(is_ipv4 == 1) begin 
			    	`uvm_field_int(is_ipv4,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_int(iph_protocol,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_int(iph_src,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_int(iph_dest,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    end
			    if(is_ipv6 == 1) begin 
			    	`uvm_field_int(is_ipv6,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_int(iph6_nheader,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(iph6_src,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_sarray_int(iph6_dest,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    	`uvm_field_array_int(iph6_ext_header,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			    end
			end
		end
		if(has_tunnel_layer == 1) begin 
			`uvm_field_int(has_tunnel_layer,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_tunnel_ip_rand,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_tunnel_mpls,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_tunnel_ipv4,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_tunnel_ipv6,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_tunnel_arp,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
		if(has_phy_layer == 1) begin 
			`uvm_field_int(has_phy_layer,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(has_scapy,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(has_fcs,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(has_padding,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_phy_rand,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_phy,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(is_vlan,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(da,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(sa,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_sarray_int(mtype,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
			`uvm_field_int(fcs_err,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
		end
  	    `uvm_field_int(m_idle_cfg,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
  	    `uvm_field_array_int(data,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
  	    `uvm_field_int(chn_id,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
  	    `uvm_field_int(len,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK|UVM_DEC)
  	    `uvm_field_enum(data_gen_enum,gen_mode,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
  	    `uvm_field_int(api_ctrl_value,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
  	    `uvm_field_array_int(api_ctrl_data,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)/*}}}*/
  	`uvm_object_utils_end
  
    function new (string name = "mac_usr_pkt");
		super.new(name);
    endfunction : new
 
    //###############################################################################
    //#overide thr convert2string
	//###############################################################################
	/*{{{*/
    function  string input2string();
		return ($sformatf(""));
		//subclass:
		//s = xxx
		//return ({super.input2string()," ",s});
	endfunction:input2string 

    function  string output2string();
		return ($sformatf(""));
		//subclass:
		//s = xxx
		//return ({super.output2string()," ",s});
	endfunction:output2string 

    function  string convert2string();
		return ({input2string()," ",output2string()});
	endfunction:convert2string 
	/*}}}*/
	//###############################################################################
    function void post_randomize();
        super.post_randomize();/*{{{*/
        data = new[this.len];
        if(gen_mode == FIXED) begin
			foreach(data[i])
				data[i] = this.api_ctrl_value;
        end
        else if(gen_mode == INCR) begin 
			foreach(data[i])
				data[i] = this.api_ctrl_value + i;
        end
        else if(gen_mode == RND) begin 
			foreach(data[i])
				data[i] = $urandom();
		end
		else 
			data = api_ctrl_data;/*}}}*/
    endfunction :post_randomize 
   
	//###############################################################################################
    /*{{{*/
	virtual function void setTransportLayer(input bit has_transport_layer,is_transport_rand,is_tcp,is_udp,is_icmp,is_igmp,is_mld);
	    this.has_transport_layer = has_transport_layer;/*{{{*/
	    this.is_transport_rand = is_transport_rand;
		this.is_tcp = is_tcp;
		this.is_udp = is_udp;
		this.is_icmp = is_icmp;
		this.is_igmp = is_igmp;
		this.is_mld = is_mld;/*}}}*/
    endfunction:setTransportLayer

	virtual function void setTCPHead(input bit [15:0] tcp_src_port,tcp_dst_port,bit tcp_chksum_err);
		this.tcp_src_port = tcp_src_port;/*{{{*/
		this.tcp_dst_port = tcp_dst_port;
		this.tcp_chksum_err = tcp_chksum_err;/*}}}*/
    endfunction:setTCPHead

	virtual function void setUDPHead(input bit [15:0] udp_src_port,udp_dst_port,bit udp_chksum_err);
		this.udp_src_port = udp_src_port;
		this.udp_dst_port = udp_dst_port;
		this.udp_chksum_err = udp_chksum_err;
    endfunction:setUDPHead

	virtual function void setICMPHead(input bit [7:0] icmp_type,icmp_code,bit [31:0] icmp_rev,bit icmp_chksum_err);
		this.icmp_type = icmp_type;
    	this.icmp_code = icmp_code;
    	this.icmp_rev  = icmp_rev;
    	this.icmp_chksum_err = icmp_chksum_err;
    endfunction:setICMPHead

	virtual function void setIGMPHead(bit [7:0] igmp_type,bit [7:0] igmp_mrd,bit [31:0] igmp_grp_addr,bit [31:0] igmp_ext_dt[],bit igmp_chksum_err);
	    this.igmp_type       = igmp_type;
	    this.igmp_mrd        = igmp_mrd;      
	    this.igmp_grp_addr   = igmp_grp_addr;
	    this.igmp_ext_dt     = igmp_ext_dt; 
	    this.igmp_chksum_err = igmp_chksum_err;
    endfunction:setIGMPHead
	
	virtual function void setMLDHead(bit [7:0] mld_type,bit [7:0] mld_code,bit [15:0] mld_mrd,bit [15:0] mld_grp_addr,
	                                 bit [31:0] mld_ext_dt[],bit mld_chksum_err);
	    this.mld_type       = mld_type;
	    this.mld_code       = mld_code;
	    this.mld_mrd        = mld_mrd;      
	    this.mld_grp_addr   = mld_grp_addr;
	    this.mld_ext_dt     = mld_ext_dt; 
	    this.mld_chksum_err = mld_chksum_err;
    endfunction:setMLDHead

	virtual task setIPLayer (
						   input bit has_ip_layer = 1,
						   input bit is_ip_rand = 1,
						   input bit is_mpls = 0,
						   input bit is_ipv4 = 1,
						   input bit is_ipv6 = 0,
						   input bit is_arp = 0
						  );
	   this.has_ip_layer = has_ip_layer;
	   this.is_ip_rand = is_ip_rand;
	   this.is_mpls = is_mpls;
	   this.is_ipv4 = is_ipv4;
	   this.is_ipv6 = is_ipv6;
	   this.is_arp = is_arp;
    endtask

	virtual function void setARPHead(
		                            input bit [15:0] arp_op,
									input bit [ 7:0] arp_sender_hw_addr[6],
									input bit [ 7:0] arp_sender_ip_addr[4],
									input bit [ 7:0] arp_target_hw_addr[6],
									input bit [ 7:0] arp_target_ip_addr[4]
								     );
        this.arp_op = arp_op;
        this.arp_sender_hw_addr = arp_sender_hw_addr;
        this.arp_sender_ip_addr = arp_sender_ip_addr;
        this.arp_target_hw_addr = arp_target_hw_addr;
        this.arp_target_ip_addr = arp_target_ip_addr;
    endfunction:setARPHead

	virtual function void setMPLSHead(
		                              int        mpls_len,
	                                  bit [19:0] mpls_label[],
                                      bit [ 2:0] mpls_exp[],
									  bit        mpls_bos[],
									  bit [ 7:0] mpls_ttl[]
								     );
        this.mpls_len   = mpls_len  ;
        this.mpls_label = mpls_label;
        this.mpls_exp   = mpls_exp  ;
        this.mpls_bos   = mpls_bos  ;
        this.mpls_ttl   = mpls_ttl  ;
    endfunction:setMPLSHead

	virtual function void setIPV4Head(
		                              bit [ 7:0] iph_protocol,
	                                  bit [31:0] iph_src,
									  bit [31:0] iph_dest
									 );
	   this.iph_protocol = iph_protocol;
       this.iph_src = iph_src;
       this.iph_dest = iph_dest; 
    endfunction:setIPV4Head
	
	virtual function void setIPV6Head(
	                                  bit [ 7:0] iph6_nheader,
                                      bit [31:0] iph6_src[4],
                                      bit [31:0] iph6_dest[4]
									);
	    this.iph6_nheader = iph6_nheader;
        this.iph6_src = iph6_src;
        this.iph6_dest = iph6_dest;
    endfunction:setIPV6Head 

	virtual function void setIPV6ExtHead(bit [7:0] iph6_ext_header[]);
		this.iph6_ext_header = iph6_ext_header;
    endfunction:setIPV6ExtHead

	virtual function void setTunnelLayer(
		                                 input bit has_tunnel_layer = 1,
	                                     input bit is_ip_rand = 1,
										 input bit is_mpls = 0,
										 input bit is_ipv4 = 1,
										 input bit is_ipv6 = 0,
										 input bit is_arp = 0
									    );
	   this.has_tunnel_layer = has_tunnel_layer;
	   this.is_tunnel_ip_rand = is_ip_rand;
	   this.is_tunnel_mpls = is_mpls;
	   this.is_tunnel_ipv4 = is_ipv4;
	   this.is_tunnel_ipv6 = is_ipv6;
	   this.is_tunnel_arp = is_arp;
    endfunction

    virtual function void setMACLayer(input bit has_phy_layer,is_phy_rand,is_phy,is_vlan,has_scapy,has_fcs,has_padding);
		this.has_phy_layer = has_phy_layer;
		this.is_phy_rand = is_phy_rand;
		this.is_phy = is_phy;
		this.is_vlan = is_vlan;
		this.has_scapy = has_scapy;
		this.has_fcs = has_fcs;
		this.has_padding = has_padding;
    endfunction:setMACLayer

	virtual function void setMACHead(input bit [7:0] da[6],sa[6],bit [7:0] mtype[2],bit fcs_err = 0);
		this.da = da;
		this.sa = sa;
		this.mtype = mtype;
		this.fcs_err = fcs_err;
    endfunction:setMACHead
    /*}}}*/
	//###############################################################################################
    virtual function bit [21:0] setFQID(bit [3:0] gq_sq_cfg,bit [14:0] gq_sq,bit [2:0] fq_pri,bit has_usr_layer);
	    this.gq_sq_cfg = gq_sq_cfg;
		this.gq_sq = gq_sq;
		this.fq_pri = fq_pri;
		this.fqid = {this.gq_sq_cfg,this.gq_sq,this.fq_pri};
        return this.fqid;
    endfunction:setFQID
	//###############################################################################################
	virtual function void setIdle(int m_idle_cfg);
	    this.m_idle_cfg = m_idle_cfg;
    endfunction:setIdle
	//###############################################################################################
    virtual function void setData(
	                             input int m_chn_id = 0,
								 input data_gen_enum m_data_gen = FIXED,
								 input int m_data_len_min = 100,
								 input int m_data_len_max = 100,
								 input int m_start_dvalue = 0,
								 input bit [7:0] m_data[] = '{default:0}
								);

	   this.srandom($random());
	   this.chn_id = m_chn_id;
       this.gen_mode = m_data_gen;
	   if(m_data_gen==USR) begin 
		   this.len = m_data.size();
		   if(this.len == 0)
			   `uvm_warning(CLASSID,"You set data length is 0!")
		   this.api_ctrl_data = new[this.len](m_data);
	   end
	   else begin 
		    this.len = $urandom_range(m_data_len_min,m_data_len_max);
			if(this.len == 0)
				`uvm_warning(CLASSID,"You set data length is 0!")
			this.api_ctrl_value = m_start_dvalue;
	   end
    endfunction:setData
	//###############################################################################################
		
endclass : mac_usr_pkt


`endif


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
//     FileName: mac_usr_sequence.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 16:17:13
//      History:
//============================================================================*/
`ifndef MAC_USR_SEQUENCE__SV
`define MAC_USR_SEQUENCE__SV

//############################################################################
class mac_usr_sequence_cfg extends uvm_object;                                  

	//###########################
	//TP CFG
	//###########################
	bit api_has_transport_layer;
	bit api_is_transport_rand;
	bit api_is_tcp;
	bit api_is_udp;
	bit api_is_icmp;
	bit api_is_igmp;
	bit api_is_mld;
    bit [15:0] api_tcp_src_port;
    bit [15:0] api_tcp_dst_port;
    bit        api_tcp_chksum_err;
    bit [15:0] api_udp_src_port;
    bit [15:0] api_udp_dst_port;
    bit        api_udp_chksum_err;
	bit [ 7:0] api_icmp_type;
	bit [ 7:0] api_icmp_code;
	bit [31:0] api_icmp_rev;
	bit        api_icmp_chksum_err;
	bit [7:0]  api_igmp_type;
	bit [7:0]  api_igmp_mrd;
	bit [31:0] api_igmp_grp_addr;
	bit [31:0] api_igmp_ext_dt[];
	bit        api_igmp_chksum_err;
	bit [7:0]  api_mld_type;
	bit [7:0]  api_mld_code;
	bit [15:0] api_mld_mrd;
	bit [31:0] api_mld_grp_addr;
	bit [31:0] api_mld_ext_dt[];
	bit        api_mld_chksum_err;
	ip_pkt     api_m_ip_pkt;
	//###########################
	//IP CFG
	//###########################
	bit api_has_ip_layer;
	bit api_is_ip_rand;
	bit api_is_mpls;
	bit api_is_ipv4;
	bit api_is_ipv6;
	bit api_is_arp;
	int api_mpls_len;
	bit [19:0] api_mpls_label[];
	bit [ 2:0] api_mpls_exp[];
	bit        api_mpls_bos[];
	bit [ 7:0] api_mpls_ttl[];
    bit [ 7:0] api_iph_protocol;
    bit [31:0] api_iph_src;
    bit [31:0] api_iph_dest;    
    bit [ 7:0] api_iph6_nheader;
    bit [31:0] api_iph6_src[4];
    bit [31:0] api_iph6_dest[4];
	bit [ 7:0] api_iph6_ext_header[];
	bit [15:0] api_arp_op;
	bit [ 7:0] api_arp_sender_hw_addr[6];
	bit [ 7:0] api_arp_sender_ip_addr[4];
	bit [ 7:0] api_arp_target_hw_addr[6];
	bit [ 7:0] api_arp_target_ip_addr[4];
	//###########################
	//Tunnel CFG
	//###########################
	bit        api_has_tunnel_layer;
    bit        api_is_tunnel_ip_rand;
    bit        api_is_tunnel_mpls;
    bit        api_is_tunnel_ipv4; 
    bit        api_is_tunnel_ipv6; 
    bit        api_is_tunnel_arp;
	//###########################
	//MAC CFG
	//###########################
	bit api_has_phy_layer;
	bit api_is_phy_rand;
	bit api_is_phy;
	bit api_is_vlan;
	bit api_has_scapy;
	bit api_has_fcs;
	bit api_has_padding;
	bit [7:0] api_da[6];
	bit [7:0] api_sa[6];
	bit [7:0] api_mtype[2];
	bit	api_fcs_err;
	int api_idle_cfg;
	//###########################
	//USR cfg 
	//###########################
	int api_chn_pkt_num ; 
	bit [7:0] api_data [];
	uint_t api_chn_id;
	data_gen_enum api_data_gen;
	int api_data_len_min ;
	int api_data_len_max ;
	int api_start_dvalue ;
	//###########################
  
	`uvm_object_utils_begin(mac_usr_sequence_cfg)
	`uvm_object_utils_end
  
	function new (string name = "mac_usr_sequence_cfg");
		super.new(name);
	endfunction : new

endclass : mac_usr_sequence_cfg

//############################################################################
class mac_usr_sequence extends uvm_sequence #(mac_usr_pkt);

	timeunit 1ns; 
	timeprecision 1ps;
	//###########################
	//TP CFG
	//###########################
	bit api_has_transport_layer;
	bit api_is_transport_rand;
	bit api_is_tcp;
	bit api_is_udp;
	bit api_is_icmp;
	bit api_is_igmp;
	bit api_is_mld;
    bit [15:0] api_tcp_src_port;
    bit [15:0] api_tcp_dst_port;
    bit        api_tcp_chksum_err;
    bit [15:0] api_udp_src_port;
    bit [15:0] api_udp_dst_port;
    bit        api_udp_chksum_err;
	bit [ 7:0] api_icmp_type;
	bit [ 7:0] api_icmp_code;
	bit [31:0] api_icmp_rev;
	bit        api_icmp_chksum_err;
	bit [7:0]  api_igmp_type;
	bit [7:0]  api_igmp_mrd;
	bit [31:0] api_igmp_grp_addr;
	bit [31:0] api_igmp_ext_dt[];
	bit        api_igmp_chksum_err;
	bit [7:0]  api_mld_type;
	bit [7:0]  api_mld_code;
	bit [15:0] api_mld_mrd;
	bit [31:0] api_mld_grp_addr;
	bit [31:0] api_mld_ext_dt[];
	bit        api_mld_chksum_err;
	ip_pkt     api_m_ip_pkt;
	//###########################
	//IP CFG
	//###########################
	bit api_has_ip_layer;
	bit api_is_ip_rand;
	bit api_is_mpls;
	bit api_is_ipv4;
	bit api_is_ipv6;
	bit api_is_arp;
	int        api_mpls_len;
	bit [19:0] api_mpls_label[];
	bit [ 2:0] api_mpls_exp[];
	bit        api_mpls_bos[];
	bit [ 7:0] api_mpls_ttl[];
    bit [ 7:0] api_iph_protocol;
    bit [31:0] api_iph_src;
    bit [31:0] api_iph_dest;    
    bit [ 7:0] api_iph6_nheader;
    bit [31:0] api_iph6_src[4];
    bit [31:0] api_iph6_dest[4];
	bit [ 7:0] api_iph6_ext_header[];
	bit [15:0] api_arp_op;
	bit [ 7:0] api_arp_sender_hw_addr[6];
	bit [ 7:0] api_arp_sender_ip_addr[4];
	bit [ 7:0] api_arp_target_hw_addr[6];
	bit [ 7:0] api_arp_target_ip_addr[4];
	//###########################
	//Tunnel CFG
	//###########################
	bit        api_has_tunnel_layer;
    bit        api_is_tunnel_ip_rand;
    bit        api_is_tunnel_mpls;
    bit        api_is_tunnel_ipv4; 
    bit        api_is_tunnel_ipv6; 
    bit        api_is_tunnel_arp;
	//###########################
	//MAC CFG
	//###########################
	bit api_has_phy_layer;
	bit api_is_phy_rand;
	bit api_is_phy;
	bit api_is_vlan;
	bit api_has_scapy;
	bit api_has_fcs;
	bit api_has_padding;
	bit [7:0] api_da[6];
	bit [7:0] api_sa[6];
	bit [7:0] api_mtype[2];
	bit	api_fcs_err;
	int api_idle_cfg;
	//###########################
	//data payload
	//###########################
	int api_chn_pkt_num ; 
	bit [7:0] api_data [];
	uint_t api_chn_id;
	data_gen_enum api_data_gen;
	int api_data_len_min ;
	int api_data_len_max ;
	int api_start_dvalue ;
	//########################### 
    bit received_item_done = 0;
    mac_usr_sequence_cfg api_cfg;
    mac_usr_sequence_cfg m_cfg;
    mac_usr_sequence_cfg api_cfg_q[$];

    function new(string name="mac_usr_sequence");
		super.new(name);
    endfunction

	`uvm_object_utils_begin(mac_usr_sequence)
	`uvm_object_utils_end

	virtual task body();
	    fork
		    begin 
				for(int i=0;i<api_chn_pkt_num;i++) begin 
					mac_usr_pkt item_req;
					mac_usr_pkt item_rsp;
					item_req = mac_usr_pkt::type_id::create("item_req");
					item_rsp = mac_usr_pkt::type_id::create("item_rsp");
					//#####################################################
					if(api_cfg_q.size() > 0) begin 
						i = 0;
						m_cfg = api_cfg_q.pop_front();
						//###########################
						//TP CFG
						//###########################
						api_has_transport_layer = m_cfg.api_has_transport_layer;
						api_is_transport_rand = m_cfg.api_is_transport_rand;
						api_is_tcp = m_cfg.api_is_tcp;
						api_is_udp = m_cfg.api_is_udp;
						api_is_icmp = m_cfg.api_is_icmp;
						api_is_igmp = m_cfg.api_is_igmp;
						api_is_mld = m_cfg.api_is_mld;
                        api_tcp_src_port   = m_cfg.api_tcp_src_port   ; 
                        api_tcp_dst_port   = m_cfg.api_tcp_dst_port   ; 
                        api_tcp_chksum_err = m_cfg.api_tcp_chksum_err ; 
                        api_udp_src_port   = m_cfg.api_udp_src_port   ; 
                        api_udp_dst_port   = m_cfg.api_udp_dst_port   ; 
                        api_udp_chksum_err = m_cfg.api_udp_chksum_err ; 
	                    api_icmp_type      = m_cfg.api_icmp_type      ;
	                    api_icmp_code      = m_cfg.api_icmp_code      ;
	                    api_icmp_rev       = m_cfg.api_icmp_rev       ;
	                    api_icmp_chksum_err= m_cfg.api_icmp_chksum_err;
						api_igmp_type      = m_cfg.api_igmp_type      ; 
						api_igmp_mrd       = m_cfg.api_igmp_mrd       ; 
						api_igmp_grp_addr  = m_cfg.api_igmp_grp_addr  ; 
						api_igmp_ext_dt    = m_cfg.api_igmp_ext_dt    ; 
						api_igmp_chksum_err= m_cfg.api_igmp_chksum_err; 
	                    api_mld_type       = m_cfg.api_mld_type       ; 
	                    api_mld_code       = m_cfg.api_mld_code       ; 
	                    api_mld_mrd        = m_cfg.api_mld_mrd        ; 
	                    api_mld_grp_addr   = m_cfg.api_mld_grp_addr   ; 
	                    api_mld_ext_dt     = m_cfg.api_mld_ext_dt     ; 
	                    api_mld_chksum_err = m_cfg.api_mld_chksum_err ; 
						api_m_ip_pkt       = m_cfg.api_m_ip_pkt       ;
						//###########################
						//IP CFG
						//###########################
						api_has_ip_layer = m_cfg.api_has_ip_layer; 
  					    api_is_ip_rand   = m_cfg.api_is_ip_rand  ; 
  					    api_is_mpls      = m_cfg.api_is_mpls     ; 
  					    api_is_ipv4      = m_cfg.api_is_ipv4     ;
  					    api_is_ipv6      = m_cfg.api_is_ipv6     ; 
  					    api_is_arp       = m_cfg.api_is_arp      ; 
						api_mpls_len     = m_cfg.api_mpls_len    ; 
						api_mpls_label   = m_cfg.api_mpls_label  ; 
						api_mpls_exp     = m_cfg.api_mpls_exp    ; 
						api_mpls_bos     = m_cfg.api_mpls_bos    ; 
						api_mpls_ttl     = m_cfg.api_mpls_ttl    ; 
                        api_iph_protocol = m_cfg.api_iph_protocol;
                        api_iph_src      = m_cfg.api_iph_src     ;
                        api_iph_dest     = m_cfg.api_iph_dest    ;
                        api_iph6_nheader = m_cfg.api_iph6_nheader;
                        api_iph6_src     = m_cfg.api_iph6_src    ;
                        api_iph6_dest    = m_cfg.api_iph6_dest   ;
						api_iph6_ext_header = m_cfg.api_iph6_ext_header;
	                    api_arp_op       = m_cfg.api_arp_op      ;
	                    api_arp_sender_hw_addr = m_cfg.api_arp_sender_hw_addr;
	                    api_arp_sender_ip_addr = m_cfg.api_arp_sender_ip_addr;
	                    api_arp_target_hw_addr = m_cfg.api_arp_target_hw_addr;
	                    api_arp_target_ip_addr = m_cfg.api_arp_target_ip_addr;
						//###########################
						//Tunnel CFG
						//###########################
						api_has_tunnel_layer = m_cfg.api_has_tunnel_layer;
						api_is_tunnel_ip_rand= m_cfg.api_is_tunnel_ip_rand; 
						api_is_tunnel_mpls   = m_cfg.api_is_tunnel_mpls   ; 
						api_is_tunnel_ipv4   = m_cfg.api_is_tunnel_ipv4   ; 
						api_is_tunnel_ipv6   = m_cfg.api_is_tunnel_ipv6   ; 
						api_is_tunnel_arp    = m_cfg.api_is_tunnel_arp    ; 
						//###########################
						//MAC CFG
						//###########################
	                    api_has_phy_layer = m_cfg.api_has_phy_layer; 
	                    api_is_phy_rand   = m_cfg.api_is_phy_rand  ; 
	                    api_is_phy        = m_cfg.api_is_phy       ; 
	                    api_is_vlan       = m_cfg.api_is_vlan      ; 
						api_has_scapy     = m_cfg.api_has_scapy    ;
						api_has_fcs       = m_cfg.api_has_fcs      ;
						api_has_padding   = m_cfg.api_has_padding  ;
	                    api_da            = m_cfg.api_da           ; 
	                    api_sa            = m_cfg.api_sa           ; 
	                    api_mtype         = m_cfg.api_mtype        ; 
	                    api_fcs_err       = m_cfg.api_fcs_err      ; 
						api_idle_cfg      = m_cfg.api_idle_cfg     ;
						//###########################
						//data payload
						//###########################
                        api_chn_id       = m_cfg.api_chn_id      ;      
                        api_chn_pkt_num  = m_cfg.api_chn_pkt_num ; 
                        api_data_gen     = m_cfg.api_data_gen    ; 
                        api_data_len_min = m_cfg.api_data_len_min; 
                        api_data_len_max = m_cfg.api_data_len_max; 
                        api_start_dvalue = m_cfg.api_start_dvalue; 
                        api_data         = m_cfg.api_data        ; 
					end
					//#####################################################
					start_item(item_req);
					item_req.setTransportLayer(api_has_transport_layer,api_is_transport_rand,api_is_tcp,api_is_udp,api_is_icmp,api_is_igmp,
					                           api_is_mld);
					item_req.setTCPHead(api_tcp_src_port,api_tcp_dst_port,api_tcp_chksum_err);
					item_req.setUDPHead(api_udp_src_port,api_udp_dst_port,api_udp_chksum_err);
					item_req.setICMPHead(api_icmp_type,api_icmp_code,api_icmp_rev,api_icmp_chksum_err);
					item_req.setIGMPHead(api_igmp_type,api_igmp_mrd,api_igmp_grp_addr,api_igmp_ext_dt,api_igmp_chksum_err);
					item_req.setMLDHead(api_mld_type,api_mld_code,api_mld_mrd,api_mld_grp_addr,api_mld_ext_dt,api_mld_chksum_err);
					item_req.setIPLayer(api_has_ip_layer,api_is_ip_rand,api_is_mpls,api_is_ipv4,api_is_ipv6,api_is_arp);
					item_req.setARPHead(api_arp_op,api_arp_sender_hw_addr,api_arp_sender_ip_addr,api_arp_target_hw_addr,api_arp_target_ip_addr);
					item_req.setMPLSHead(api_mpls_len,api_mpls_label,api_mpls_exp,api_mpls_bos,api_mpls_ttl);
					item_req.setIPV4Head(api_iph_protocol,api_iph_src,api_iph_dest);
					item_req.setIPV6Head(api_iph6_nheader,api_iph6_src,api_iph6_dest);
					item_req.setIPV6ExtHead(api_iph6_ext_header);
					item_req.setTunnelLayer(api_has_tunnel_layer,api_is_tunnel_ip_rand,api_is_tunnel_mpls,api_is_tunnel_ipv4,api_is_tunnel_ipv6,
					                        api_is_tunnel_arp);
				 	item_req.setMACLayer(api_has_phy_layer,api_is_phy_rand,api_is_phy,api_is_vlan,api_has_scapy,api_has_fcs,api_has_padding);
				 	item_req.setMACHead(api_da,api_sa,api_mtype,api_fcs_err);
				 	item_req.setIdle(api_idle_cfg);
					//#####################################################
					item_req.setData(api_chn_id,api_data_gen,api_data_len_min,api_data_len_max,api_start_dvalue,api_data);
					//#####################################################
					`ASSERT(item_req.randomize());
					`uvm_info("MAC_USR_REQ",$sformatf("Senting mac usr req item@%0t:--->\n%s",$realtime,item_req.sprint()),UVM_HIGH)
					finish_item(item_req);
					get_response(item_rsp);
				end
				received_item_done = 1;
			end
			//##################################################
			//online config 
		    begin :ONLINE_CFG_PROC
		        while(!received_item_done) begin/*{{{*/
		            fork
		      	      begin 
		                    uvm_config_db#(mac_usr_sequence_cfg)::wait_modified(m_sequencer,"","api_cfg");
		                    void'(uvm_config_db#(mac_usr_sequence_cfg)::get(m_sequencer,"","api_cfg",api_cfg));
		                    if(api_cfg != null) begin 
		                  	  `uvm_info("MAC_USR_SEQ_RESTART_CFG",$sformatf("Resetting mac usr sequence cfg@%0t:--->\n%s",$realtime,api_cfg.sprint()),UVM_MEDIUM)
		                  	  api_cfg_q = {api_cfg_q,api_cfg};
		                    end
		                    else
		                  	  `uvm_error("MAC_USR_SEQ_RESTART_CFG_NULL",$sformatf("Resetting mac usr sequence cfg@%0t:--->\n%s",$realtime,api_cfg.sprint()))
		      		  end
		          	  begin 
		          	      wait(received_item_done);
		          	  end
		            join_any
		            disable fork;
	            end/*}}}*/
		    end
		join
	endtask:body

    virtual function void setTransportLayer(bit has_transport_layer = 1,is_transport_rand = 1,is_tcp = 1,is_udp = 0,
	                                            is_icmp = 0,is_igmp = 0,is_mld = 0,is_ipv4inipv4 = 0);
	    this.api_has_transport_layer = has_transport_layer;
	    this.api_is_transport_rand = is_transport_rand;
		this.api_is_tcp = is_tcp;
		this.api_is_udp = is_udp;
		this.api_is_icmp = is_icmp;
		this.api_is_igmp = is_igmp;
		this.api_is_mld = is_mld;
    endfunction:setTransportLayer

	virtual function void setTCPHead(input bit [15:0] tcp_src_port,tcp_dst_port,bit tcp_chksum_err = 0);
		this.api_tcp_src_port = tcp_src_port;
		this.api_tcp_dst_port = tcp_dst_port;
		this.api_tcp_chksum_err = tcp_chksum_err;
    endfunction:setTCPHead

	virtual function void setUDPHead(input bit [15:0] udp_src_port,udp_dst_port,bit udp_chksum_err = 0);
		this.api_udp_src_port = udp_src_port;
		this.api_udp_dst_port = udp_dst_port;
		this.api_udp_chksum_err = udp_chksum_err;
    endfunction:setUDPHead

	virtual function void setICMPHead(input bit [7:0] icmp_type,icmp_code,bit [31:0] icmp_rev,bit icmp_chksum_err = 0);
		this.api_icmp_type = icmp_type;
    	this.api_icmp_code = icmp_code;
    	this.api_icmp_rev  = icmp_rev;
    	this.api_icmp_chksum_err = icmp_chksum_err;
    endfunction:setICMPHead
	
	virtual function void setIGMPHead(bit [7:0] igmp_type,bit [7:0] igmp_mrd,bit [31:0] igmp_grp_addr,bit [31:0] igmp_ext_dt[],bit igmp_chksum_err);
	    this.api_igmp_type       = igmp_type;
	    this.api_igmp_mrd        = igmp_mrd;      
	    this.api_igmp_grp_addr   = igmp_grp_addr;
	    this.api_igmp_ext_dt     = igmp_ext_dt; 
	    this.api_igmp_chksum_err = igmp_chksum_err;
    endfunction:setIGMPHead

	virtual function void setMLDHead(bit [7:0] mld_type,bit [7:0] mld_code,bit [15:0] mld_mrd,bit [15:0] mld_grp_addr,
	                                 bit [31:0] mld_ext_dt[],bit mld_chksum_err);
	    this.api_mld_type       = mld_type;
	    this.api_mld_code       = mld_code;
	    this.api_mld_mrd        = mld_mrd;      
	    this.api_mld_grp_addr   = mld_grp_addr;
	    this.api_mld_ext_dt     = mld_ext_dt; 
	    this.api_mld_chksum_err = mld_chksum_err;
    endfunction:setMLDHead
	
	virtual task setIPLayer (
						   input bit has_ip_layer = 1,
						   input bit is_ip_rand = 1,
						   input bit is_mpls = 0,
						   input bit is_ipv4 = 1,
						   input bit is_ipv6 = 0,
						   input bit is_arp = 0
						  );
	   this.api_has_ip_layer = has_ip_layer;
	   this.api_is_ip_rand = is_ip_rand;
	   this.api_is_mpls = is_mpls;
	   this.api_is_ipv4 = is_ipv4;
	   this.api_is_ipv6 = is_ipv6;
	   this.api_is_arp = is_arp;
    endtask
	
	virtual function void setARPHead(
		                            input bit [15:0] arp_op,
									input bit [ 7:0] arp_sender_hw_addr[6],
									input bit [ 7:0] arp_sender_ip_addr[4],
									input bit [ 7:0] arp_target_hw_addr[6],
									input bit [ 7:0] arp_target_ip_addr[4]
								     );
        this.api_arp_op = arp_op;
        this.api_arp_sender_hw_addr = arp_sender_hw_addr;
        this.api_arp_sender_ip_addr = arp_sender_ip_addr;
        this.api_arp_target_hw_addr = arp_target_hw_addr;
        this.api_arp_target_ip_addr = arp_target_ip_addr;
    endfunction:setARPHead				 

	virtual function void setMPLSHead(
	                                  int        mpls_len,
	                                  bit [19:0] mpls_label[],
                                      bit [ 2:0] mpls_exp[],
									  bit        mpls_bos[],
									  bit [ 7:0] mpls_ttl[]
								     );
        this.api_mpls_len   = mpls_len;
        this.api_mpls_label = new[mpls_len](mpls_label);
        this.api_mpls_exp   = new[mpls_len](mpls_exp)  ;
        this.api_mpls_bos   = new[mpls_len](mpls_bos)  ;
        this.api_mpls_ttl   = new[mpls_len](mpls_ttl)  ;
    endfunction:setMPLSHead

	virtual function void setIPV4Head(input bit [7:0] iph_protocol,bit [31:0] iph_src,bit [31:0] iph_dest);
	    this.api_iph_protocol = iph_protocol;
		this.api_iph_src      = iph_src;
		this.api_iph_dest     = iph_dest;
    endfunction:setIPV4Head
	
	virtual function void setIPV6Head(input bit [7:0] iph6_nheader,bit [31:0] iph6_src[4],bit [31:0] iph6_dest[4]);
	    this.api_iph6_nheader = iph6_nheader;
	    this.api_iph6_src     = iph6_src;
	    this.api_iph6_dest    = iph6_dest;
    endfunction:setIPV6Head

	virtual function void setIPV6ExtHead(bit [7:0] iph6_ext_header[]);
		this.api_iph6_ext_header = iph6_ext_header;
    endfunction:setIPV6ExtHead

	virtual function void setTunnelLayer(
		                                 input bit has_tunnel_layer = 1,
	                                     input bit is_ip_rand = 1,
										 input bit is_mpls = 0,
										 input bit is_ipv4 = 1,
										 input bit is_ipv6 = 0,
										 input bit is_arp = 0
									    );
	   this.api_has_tunnel_layer = has_tunnel_layer;
	   this.api_is_tunnel_ip_rand = is_ip_rand;
	   this.api_is_tunnel_mpls = is_mpls;
	   this.api_is_tunnel_ipv4 = is_ipv4;
	   this.api_is_tunnel_ipv6 = is_ipv6;
	   this.api_is_tunnel_arp = is_arp;
    endfunction

    virtual function void setMACLayer(input bit has_phy_layer = 1,is_phy_rand = 1,is_phy = 0,is_vlan = 0,has_scapy = 0,has_fcs = 1,has_padding = 1);
		this.api_has_phy_layer = has_phy_layer;
		this.api_is_phy_rand = is_phy_rand;
		this.api_is_phy = is_phy;
		this.api_is_vlan = is_vlan;
		this.api_has_scapy = has_scapy;
		this.api_has_fcs = has_fcs;
		this.api_has_padding = has_padding;
    endfunction:setMACLayer

	virtual function void setMACHead(input bit [7:0] da[6],sa[6],bit [7:0] mtype[2],bit fcs_err = 0);
		this.api_da = da;
		this.api_sa = sa;
		this.api_mtype = mtype;
		this.api_fcs_err = fcs_err;
    endfunction:setMACHead

    virtual function void setIdle(input int m_idle_cfg = 0);
		this.api_idle_cfg = m_idle_cfg;
    endfunction:setIdle

	//#############################################################################
	task set_STP_Mode(
					 bit [7:0] dmac[6] = trMAC("01-80-C2-00-00-00"),
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{default:8'h0},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask

	//#############################################################################
	task set_GMRP_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h20},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{default:8'h0},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_GVRP_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h21},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{default:8'h0},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_VTP_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h00,8'h0C,8'hCC,8'hCC,8'hCC},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h20,8'h03},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_LACP_802P3AH_Mode(
					           bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h02},
					           bit [7:0] smac[6] = '{default:8'h55},
					           bit [7:0] mtype[2] = '{8'h88,8'h09},
					           bit        is_vlan = 0,
					           bit        fcs_err = 0
				              );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_802P1X_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h03},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'h8E},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_LLDP_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h0E},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'hCC},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_802P1AG_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h00},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{$urandom_range(0,255),$urandom_range(0,255)},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_BRIDGE_GROUP_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h10},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{$urandom_range(0,255),$urandom_range(0,255)},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_PAUSE_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h01},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'h08},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_802P1AD_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,$urandom_range(0,1) ? 8'h08:8'h0D},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{default:8'h0},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_OTHER_REV_MAC_Mode(
					 bit [7:0] dmac[6] = '{8'h01,8'h80,8'hC2,8'h00,8'h00,8'h00},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{default:8'h0},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		bit [7:0] m_dmac;
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
		`ASSERT(std::randomize(m_dmac) with {m_dmac inside {0,[8'h2:8'h7],[8'h9:8'hC],8'hE};});
		dmac[5] = m_dmac;
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_PPPOE_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'h63},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_ELMI_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'hEE},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_PTP_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h88,8'hF7},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_CFM_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h89,8'h02},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_ELOOP_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h90,8'h00},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	/*task set_CLNS_ISIS_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h90,8'h00},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_CISCO_SNAP_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h90,8'h00},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_IEEE_SNAP_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h90,8'h00},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_CISCO_SNAP_BPDU_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h90,8'h00},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask*/
	//#############################################################################
	task set_UD_Mode(
					 bit [7:0] dmac[6] = '{default:8'haa},
					 bit [7:0] dmac_mask[6] = '{default:8'hFF},
					 bit [7:0] smac[6] = '{default:8'h55},
					 bit [7:0] smac_mask[6] = '{default:8'hFF},
					 bit [7:0] mtype[2] = '{default:8'h00},
					 bit [7:0] mtype_mask[2] = '{default:8'hFF},
					 bit        is_vlan = 0,
					 bit        fcs_err = 0
				    );
		bit [7:0] m_dmac[6];
		bit [7:0] m_smac[6];
		bit [7:0] m_mtype[2];
		foreach(dmac[i])
			m_dmac[i] = dmac[i]&dmac_mask[i];
		foreach(smac[i])
			m_smac[i] = smac[i]&smac_mask[i];
		foreach(mtype[i])
			m_mtype[i] = mtype[i]&mtype_mask[i];
		setTransportLayer(0);
	    setIPLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(m_dmac,m_smac,m_mtype,fcs_err);
	endtask
	//#############################################################################
	//#############################################################################
	//#############################################################################
	task set_ARP_Mode(
                     bit [15:0] arp_op = 1,
                     bit [ 7:0] arp_sender_hw_addr[6] = '{default:8'h11},
                     bit [ 7:0] arp_sender_ip_addr[4] = '{default:8'h22},
                     bit [ 7:0] arp_target_hw_addr[6] = '{default:8'h33},
                     bit [ 7:0] arp_target_ip_addr[4] = '{default:8'h44},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h08,8'h06},
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(1,0,0,0,0,1);
		setARPHead(arp_op,arp_sender_hw_addr,arp_sender_ip_addr,arp_target_hw_addr,arp_target_ip_addr);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
	task set_RARP_Mode(
                     bit [15:0] arp_op = 1,
                     bit [ 7:0] arp_sender_hw_addr[6] = '{default:8'h11},
                     bit [ 7:0] arp_sender_ip_addr[4] = '{default:8'h22},
                     bit [ 7:0] arp_target_hw_addr[6] = '{default:8'h33},
                     bit [ 7:0] arp_target_ip_addr[4] = '{default:8'h44},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit [7:0] mtype[2] = '{8'h08,8'h35},
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(1,0,0,0,0,1);
		setARPHead(arp_op,arp_sender_hw_addr,arp_sender_ip_addr,arp_target_hw_addr,arp_target_ip_addr);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,mtype,fcs_err);
	endtask
	//#############################################################################
  	task set_TCP_IPV4_Mode(
		             bit [15:0] tcp_src_port = 16'hAAAA,
		             bit [15:0] tcp_dst_port = 16'h5555,
		             bit [31:0] ipv4_src = trIPv4("170.170.170.170"),
					 bit [31:0] ipv4_dest = trIPv4("85.85.85.85"),
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,1,0);
		setTCPHead(tcp_src_port,tcp_dst_port);
	    setIPLayer(1,0,0,1,0,0);
	    setIPV4Head(8'd6,ipv4_src,ipv4_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask

	//#############################################################################
	task set_TCP_IPV6_Mode(
		             bit [15:0] tcp_src_port = 16'hAAAA,
		             bit [15:0] tcp_dst_port = 16'h5555,
		             bit [31:0] ipv6_src[4] = '{default:32'hAAAAAAAA},
					 bit [31:0] ipv6_dest[4]= '{default:32'h55555555},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,1,0);
		setTCPHead(tcp_src_port,tcp_dst_port);
	    setIPLayer(1,0,0,0,1,0);
		setIPV6Head(8'd6,ipv6_src,ipv6_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h86,8'hDD},fcs_err);
	endtask

	//#############################################################################
	task set_UDP_IPV4_Mode(
		             bit [15:0] udp_src_port = 16'hAAAA,
		             bit [15:0] udp_dst_port = 16'h5555,
		             bit [31:0] ipv4_src = 32'hAAAAAAAA,
					 bit [31:0] ipv4_dest = 32'h55555555,
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,1);
		setUDPHead(udp_src_port,udp_dst_port);
	    setIPLayer(1,0,0,1,0,0);
	    setIPV4Head(8'd17,ipv4_src,ipv4_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask

	//#############################################################################
	task set_UDP_IPV6_Mode(
		             bit [15:0] udp_src_port = 16'hAAAA,
		             bit [15:0] udp_dst_port = 16'h5555,
		             bit [31:0] ipv6_src[4] = '{default:32'hAAAAAAAA},
					 bit [31:0] ipv6_dest[4]= '{default:32'h55555555},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,1);
		setUDPHead(udp_src_port,udp_dst_port);
	    setIPLayer(1,0,0,0,1,0);
		setIPV6Head(8'd17,ipv6_src,ipv6_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h86,8'hDD},fcs_err);
	endtask
    //#############################################################################
  	task set_ICMP_IPV4_Mode(
		             bit [7:0] icmp_type = 8'h3,
					 bit [7:0] icmp_code = 8'h0,
					 bit [31:0] icmp_rev = 32'h0,
		             bit [31:0] ipv4_src = 32'hAAAAAAAA,
					 bit [31:0] ipv4_dest = 32'h55555555,
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,0,1);
		setICMPHead(icmp_type,icmp_code,icmp_rev,0);
	    setIPLayer(1,0,0,1,0,0);
	    setIPV4Head(8'd1,ipv4_src,ipv4_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask
    //#############################################################################
	task set_ICMP_IPV6_Mode(
		             bit [7:0] icmp_type = 8'h3,
					 bit [7:0] icmp_code = 8'h0,
					 bit [31:0] icmp_rev = 32'h0,
		             bit [31:0] ipv6_src[4] = '{default:8'haa},
					 bit [31:0] ipv6_dest[4] = '{default:8'h55},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,0,1);
		setICMPHead(icmp_type,icmp_code,icmp_rev,0);
	    setIPLayer(1,0,0,0,1,0);
		setIPV6Head(8'd58,ipv6_src,ipv6_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h86,8'hDD},fcs_err);
	endtask
    //#############################################################################
	task set_IGMP_IPV4_Mode(
		             bit [7:0] igmp_type = 8'h11,
					 bit [7:0] igmp_mrd = 8'hFF,
					 bit [31:0] igmp_grp_addr = 32'h0,
					 bit [31:0] igmp_ext_dt[] = '{},
					 bit igmp_chksum_err = 0,
		             bit [31:0] ipv4_src = 32'hAAAAAAAA,
					 bit [31:0] ipv4_dest = 32'h55555555,
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,0,0,1);
		setIGMPHead(igmp_type,igmp_mrd,igmp_grp_addr,igmp_ext_dt,igmp_chksum_err);
	    setIPLayer(1,0,0,1,0,0);
	    setIPV4Head(8'd2,ipv4_src,ipv4_dest);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask
    //#############################################################################
	task set_MLD_IPV6_Mode(
	                 bit [7:0] mld_type = 8'h11,
					 bit [7:0] mld_code = 0, 
					 bit [15:0] mld_mrd = 0,
					 bit [15:0] mld_grp_addr = 0,
	                 bit [31:0] mld_ext_dt[] = '{},
					 bit        mld_chksum_err = 0,
		             bit [31:0] ipv6_src[4] = '{default:8'haa},
					 bit [31:0] ipv6_dest[4] = '{default:8'h55},
					 bit [7:0] iph6_ext_header[] = '{8'h3A,8'h0,8'h0,8'h0,8'h0,8'h0,8'h0,8'h0},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,0,0,0,0,0,1);
		setMLDHead(mld_type,mld_code,mld_mrd,mld_grp_addr,mld_ext_dt,mld_chksum_err);
	    setIPLayer(1,0,0,0,1,0);
		setIPV6Head(8'd0,ipv6_src,ipv6_dest);
		setIPV6ExtHead(iph6_ext_header);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h86,8'hDD},fcs_err);
	endtask
    //#############################################################################
	task set_IPV4inIPV4_Mode(
		             bit [31:0] inner_ipv4_src = 32'hAAAAAAAA,
					 bit [31:0] inner_ipv4_dest = 32'h55555555,
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,1,1,0);
	    setIPLayer(1,0,0,1,0,0);
	    setIPV4Head(8'd6,inner_ipv4_src,inner_ipv4_dest);
		setTunnelLayer(1,1,0,1,0,0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask
    //#############################################################################
	task set_IPV6inIPV4_Mode(
		             bit [31:0] inner_ipv6_src[4] = '{default:8'hAA},
					 bit [31:0] inner_ipv6_dest[4] = '{default:8'h55},
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(1,1,1,0);
	    setIPLayer(1,0,0,0,1,0);
		setIPV6Head(8'd6,inner_ipv6_src,inner_ipv6_dest);
		setTunnelLayer(1,1,0,1,0,0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask
    //#############################################################################
    //#############################################################################
    //#############################################################################
	task set_USR_Mode(
					 bit        is_vlan = 0,
					 bit [ 7:0] dmac[6] = '{default:8'haa},
					 bit [ 7:0] smac[6] = '{default:8'h55},
					 bit        fcs_err = 0
				    );
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,0,is_vlan);
	    setMACHead(dmac,smac,'{8'h08,8'h00},fcs_err);
	endtask

	task set_RAW_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(0);
	endtask
	
	task set_PCAP_FILE_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(0);
	endtask

	task set_SCAPY_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,0,0,1,1);
	endtask

	task set_SCAPY_MAC_PREAMBEL_CRC_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,1,0,1,1);
	endtask

	task set_SCAPY_MAC_NoPREAMBEL_CRC_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,0,0,1,1);
	endtask

	task set_SCAPY_MAC_PREAMBEL_NoCRC_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,1,0,1,0);
	endtask

	task set_SCAPY_MAC_NoPREAMBEL_NoCRC_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,0,0,1,0);
	endtask

	task set_SCAPY_MAC_PREAMBEL_CRCERR_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,1,0,1,1);
	    setMACHead('{default:'0},'{default:'0},'{default:'0},1);
	endtask

	task set_SCAPY_MAC_PREAMBEL_CRC_NoPADDING_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,1,0,1,1,0);
	endtask

	task set_SCAPY_MAC_PREAMBEL_NoCRC_NoPADDING_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,1,0,1,0,0);
	endtask
	
	task set_SCAPY_MAC_NoPREAMBEL_NoCRC_NoPADDING_Mode();
		setTransportLayer(0);
	    setIPLayer(0);
		setTunnelLayer(0);
		setMACLayer(1,0,0,0,1,0,0);
	endtask
    //#############################################################################
    //#############################################################################
    //#############################################################################
    //#############################################################################
	virtual task startPkt (
	                      input uvm_sequencer_base seqr, 
						  //##############################################
						  input int m_chn_id = 0,
						  input int m_chn_pkt_num = 1,
						  input data_gen_enum m_data_gen = FIXED,
						  input int m_data_len_min = 100,
						  input int m_data_len_max = 100,
						  input int m_start_dvalue = 0,
						  input bit [7:0] m_data[] = '{default:0},
						  //##############################################
						  input uvm_sequence_base parent=null
						);
	  this.api_chn_id       = m_chn_id       ;
      this.api_chn_pkt_num  = m_chn_pkt_num  ; 
      this.api_data_gen     = m_data_gen     ;
      this.api_data_len_min = m_data_len_min ;
      this.api_data_len_max = m_data_len_max ;
      this.api_start_dvalue = m_start_dvalue ;
      this.api_data         = m_data         ;
      this.start(seqr,parent);
	endtask:startPkt
    //#############################################################################
    //#############################################################################
    //#############################################################################
    //#############################################################################
endclass : mac_usr_sequence


`endif

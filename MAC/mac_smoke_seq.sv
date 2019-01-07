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
//     FileName: mac_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 17:51:29
//      History:
//============================================================================*/
`ifndef MAC_SMOKE_SEQ__SV
`define MAC_SMOKE_SEQ__SV

class mac_default_seq extends uvm_sequence#(mac_pkt);

	bit r_is_ipv4;
	bit r_is_ipv6;
    bit r_is_tcp ;
	bit r_is_udp ;
	bit r_is_icmp ;
	bit r_is_igmp ;
	bit r_is_mld ;
	bit [31:0] r_pseudo_ipv4_src;
    bit [31:0] r_pseudo_ipv4_dest;
    bit [ 7:0] r_pseudo_ipv4_protocol;
    bit [31:0] r_pseudo_ipv6_src[4];
    bit [31:0] r_pseudo_ipv6_dest[4];
    bit [ 7:0] r_pseudo_ipv6_nheader;

	`uvm_object_utils(mac_default_seq)
	`uvm_declare_p_sequencer(mac_sequencer)

	function new(string name = "mac_default_seq");
		super.new(name);
	endfunction: new

	extern virtual task body();

endclass: mac_default_seq

task mac_default_seq::body();
	mac_usr_pkt usr_req,usr_rsp;
	trans_pkt trans_req;
	ip_pkt ip_req,outer_ip_req;
	mac_pkt mac_req,mac_rsp;
	fork
        begin
			forever begin
				usr_req = `CREATE_OBJ(mac_usr_pkt,"usr_req")
				usr_rsp = `CREATE_OBJ(mac_usr_pkt,"usr_rsp")
				trans_req = `CREATE_OBJ(trans_pkt,"trans_req")
				ip_req  = `CREATE_OBJ(ip_pkt,"ip_req")
				mac_req = `CREATE_OBJ(mac_pkt,"mac_req")
				mac_rsp = `CREATE_OBJ(mac_pkt,"mac_rsp")
				p_sequencer.upper_seq_item_port.get_next_item(usr_req);
				usr_rsp.set_id_info(usr_req);
				`uvm_info("MAC_USR_REQ", $sformatf("Executing Upper mac usr pkt:\n%s", usr_req.sprint()), UVM_MEDIUM)
                //########################################################################################
			    begin:TRANSPORT_LAYER
					if(usr_req.has_transport_layer == 1) begin
						trans_req.up_payload = usr_req.data;
						if(usr_req.is_transport_rand == 1) begin 
							`ASSERT(trans_req.randomize() with {/*{{{*/
								                               if(usr_req.has_ip_layer == 1 && usr_req.is_ip_rand == 0) {
																   is_ipv4 == usr_req.is_ipv4;
															       is_ipv6 == usr_req.is_ipv6;
															       if(usr_req.is_ipv4 == 1) {
                                                                       pseudo_ipv4_src == usr_req.iph_src;
                                                                       pseudo_ipv4_dest == usr_req.iph_dest;
                                                                       pseudo_ipv4_protocol == usr_req.iph_protocol;
																   }
															       if(usr_req.is_ipv6 == 1) {
                                                                       foreach(pseudo_ipv6_src[i]) pseudo_ipv6_src[i] == usr_req.iph6_src[i];
                                                                       foreach(pseudo_ipv6_dest[i]) pseudo_ipv6_dest[i] == usr_req.iph6_dest[i];
                                                                       pseudo_ipv6_nheader == usr_req.iph6_nheader;
															       }
															   }
							                                  });/*}}}*/
						end
						else begin 
							`ASSERT(trans_req.randomize() with {/*{{{*/
								                               is_ipv4 == usr_req.is_ipv4;
								                               is_ipv6 == usr_req.is_ipv6;
															   is_udp == usr_req.is_udp;
															   is_tcp == usr_req.is_tcp;
															   is_icmp == usr_req.is_icmp;
															   is_igmp == usr_req.is_igmp;
															   is_mld == usr_req.is_mld;
															   $countones({is_tcp,is_udp,is_icmp,is_igmp,is_mld}) == 1;
															   if(usr_req.has_ip_layer == 1 && usr_req.is_ip_rand == 0) {
															       if(usr_req.is_ipv4 == 1) {
                                                                       pseudo_ipv4_src == usr_req.iph_src;
                                                                       pseudo_ipv4_dest == usr_req.iph_dest;
                                                                       pseudo_ipv4_protocol == usr_req.iph_protocol;
															       }
															       if(usr_req.is_ipv6 == 1) {
                                                                       foreach(pseudo_ipv6_src[i]) pseudo_ipv6_src[i] == usr_req.iph6_src[i];
                                                                       foreach(pseudo_ipv6_dest[i]) pseudo_ipv6_dest[i] == usr_req.iph6_dest[i];
                                                                       pseudo_ipv6_nheader == usr_req.iph6_nheader;
															       }
															   }
															   if(usr_req.is_udp == 1) {
															       udp_src_port == usr_req.udp_src_port;
															       udp_dst_port == usr_req.udp_dst_port;
															       udp_chksum_err == usr_req.udp_chksum_err;
															   }
															   if(usr_req.is_tcp == 1) {
															       tcp_src_port == usr_req.tcp_src_port;
															       tcp_dst_port == usr_req.tcp_dst_port;
															       tcp_chksum_err == usr_req.tcp_chksum_err;
															   }
															   if(usr_req.is_icmp == 1) {
															       icmp_type == usr_req.icmp_type;
															       icmp_code == usr_req.icmp_code;
															       icmp_rev == usr_req.icmp_rev;
															       icmp_chksum_err == usr_req.icmp_chksum_err;
															   }
															   if(usr_req.is_igmp == 1) {
															       igmp_type     == usr_req.igmp_type     ;
															       igmp_mrd      == usr_req.igmp_mrd      ;      
	    													       igmp_grp_addr == usr_req.igmp_grp_addr ;
															       igmp_ext_dt.size() == usr_req.igmp_ext_dt.size();
	    													       foreach(igmp_ext_dt[i]) igmp_ext_dt[i] == usr_req.igmp_ext_dt[i]; 
															       igmp_chksum_err == usr_req.igmp_chksum_err;
															   }
															   if(usr_req.is_mld == 1) {
															       mld_type     == usr_req.mld_type     ;
															       mld_code     == usr_req.mld_code     ;
															       mld_mrd      == usr_req.mld_mrd      ;      
	    													       mld_grp_addr == usr_req.mld_grp_addr ;
															       mld_ext_dt.size() == usr_req.mld_ext_dt.size();
	    													       foreach(mld_ext_dt[i]) mld_ext_dt[i] == usr_req.mld_ext_dt[i]; 
															       mld_chksum_err == usr_req.mld_chksum_err;
															   }
														       });/*}}}*/
						end
						`uvm_info("TRANS_REQ", $sformatf("trans pkt is----->:\n%s",trans_req.sprint()), UVM_MEDIUM)
					    usr_req.data = trans_req.trans_data;/*{{{*/
						r_is_ipv4 = trans_req.is_ipv4;
						r_is_ipv6 = trans_req.is_ipv6;
						r_is_udp = trans_req.is_udp;
						r_is_tcp = trans_req.is_tcp;
						r_is_icmp = trans_req.is_icmp;
						r_is_igmp = trans_req.is_igmp;
						r_is_mld = trans_req.is_mld;
	                    r_pseudo_ipv4_src      = trans_req.pseudo_ipv4_src;
                        r_pseudo_ipv4_dest     = trans_req.pseudo_ipv4_dest;
                        r_pseudo_ipv4_protocol = trans_req.pseudo_ipv4_protocol;
                        r_pseudo_ipv6_src      = trans_req.pseudo_ipv6_src;
                        r_pseudo_ipv6_dest     = trans_req.pseudo_ipv6_dest;
                        r_pseudo_ipv6_nheader  = trans_req.pseudo_ipv6_nheader;/*}}}*/
					end
					else begin 
						r_is_ipv4 = usr_req.is_ipv4;/*{{{*/
						r_is_ipv6 = usr_req.is_ipv6;
						r_is_udp = usr_req.is_udp;
						r_is_tcp = usr_req.is_tcp;
						r_is_icmp = usr_req.is_icmp;
						r_is_igmp = usr_req.is_igmp;
						r_is_mld = usr_req.is_mld;
	                    r_pseudo_ipv4_src      = usr_req.iph_src;
                        r_pseudo_ipv4_dest     = usr_req.iph_dest;
                        r_pseudo_ipv4_protocol = usr_req.iph_protocol;
                        r_pseudo_ipv6_src      = usr_req.iph6_src;
                        r_pseudo_ipv6_dest     = usr_req.iph6_dest;
                        r_pseudo_ipv6_nheader  = usr_req.iph6_nheader;/*}}}*/
					end
				end
			    begin:IP_LAYER
					if(usr_req.has_ip_layer == 1) begin
						ip_req.up_payload = usr_req.data;
						if(usr_req.is_ip_rand == 1) begin 
							`ASSERT(ip_req.randomize() with {/*{{{*/
								                            if(usr_req.has_transport_layer == 1) {
															    is_ipv4 == r_is_ipv4;
															    is_ipv6 == r_is_ipv6;
															    if(is_ipv4 == 1) {
                                                                    iph_src == r_pseudo_ipv4_src;
                                                                    iph_dest == r_pseudo_ipv4_dest;
                                                                    iph_protocol == r_pseudo_ipv4_protocol;
															    }
															    if(is_ipv6 == 1) {
                                                                    foreach(iph6_src[i]) iph6_src[i] == r_pseudo_ipv6_src[i];
                                                                    foreach(iph6_dest[i]) iph6_dest[i] == r_pseudo_ipv6_dest[i];
                                                                    iph6_nheader == r_pseudo_ipv6_nheader;
															    }
															}
							                               });/*}}}*/
						end
						else begin 
 							`ASSERT(ip_req.randomize() with {/*{{{*/
															 is_arp == usr_req.is_arp;
															 is_mpls == usr_req.is_mpls;
															 is_ipv4 == r_is_ipv4;
															 is_ipv6 == r_is_ipv6;
															 if(usr_req.is_arp == 1) {
																 arp_op == usr_req.arp_op;
																 foreach(arp_sender_hw_addr[i]) arp_sender_hw_addr[i] == usr_req.arp_sender_hw_addr[i];
																 foreach(arp_sender_ip_addr[i]) arp_sender_ip_addr[i] == usr_req.arp_sender_ip_addr[i];
																 foreach(arp_target_hw_addr[i]) arp_target_hw_addr[i] == usr_req.arp_target_hw_addr[i];
																 foreach(arp_target_ip_addr[i]) arp_target_ip_addr[i] == usr_req.arp_target_ip_addr[i];
															 }
															 if(usr_req.is_mpls == 1) {
																 mpls_len == usr_req.mpls_len;
																 foreach(mpls_label[i]) mpls_label[i] == usr_req.mpls_label[i];
															 	 foreach(mpls_exp[i])   mpls_exp[i] == usr_req.mpls_exp[i];
															 	 foreach(mpls_bos[i])   mpls_bos[i] == usr_req.mpls_bos[i];
															 	 foreach(mpls_ttl[i])   mpls_ttl[i] == usr_req.mpls_ttl[i];
															 }
															 if(usr_req.is_ipv4 == 1) {
																 iph_src == r_pseudo_ipv4_src;
																 iph_dest == r_pseudo_ipv4_dest;
                                                                 iph_protocol == r_pseudo_ipv4_protocol;
															 }
															 if(usr_req.is_ipv6 == 1) {
																 foreach(iph6_src[i]) iph6_src[i] == r_pseudo_ipv6_src[i];
																 foreach(iph6_dest[i]) iph6_dest[i] == r_pseudo_ipv6_dest[i];
																 iph6_nheader == r_pseudo_ipv6_nheader;
																 iph6_ext_header.size() == usr_req.iph6_ext_header.size();
																 foreach(iph6_ext_header[i]) iph6_ext_header[i] == usr_req.iph6_ext_header[i];
															 }
													        });/*}}}*/
						end 
					    usr_req.data = ip_req.ip_data;
						`uvm_info("IP_REQ", $sformatf("IP pkt is----->:\n%s",ip_req.sprint()), UVM_MEDIUM)
					end
				end
			    begin:TUNNEL_LAYER
					if(usr_req.has_tunnel_layer == 1 && usr_req.has_ip_layer == 1) begin /*{{{*/
						outer_ip_req  = `CREATE_OBJ(ip_pkt,"outer_ip_req")
						outer_ip_req.up_payload = usr_req.data;
						if(usr_req.is_tunnel_ip_rand  == 1) begin 
							`ASSERT(outer_ip_req.randomize() with {
							                                      is_mpls == usr_req.is_tunnel_mpls;
							                                      is_ipv4 == usr_req.is_tunnel_ipv4;
							                                      is_ipv6 == usr_req.is_tunnel_ipv6;
							                                      is_arp == usr_req.is_tunnel_arp;
								                                  if(ip_req.is_ipv4 == 1) {
																	  iph_protocol == 8'h4;
																  }
																  if(ip_req.is_ipv6 == 1) {
																	  iph_protocol == 8'h41;
																  }
															     });
						end
						else begin 
							`uvm_fatal("TUNNEL_IP_REQ","Has not implement!!!")
						end
					    usr_req.data = outer_ip_req.ip_data;
						`uvm_info("TUNNEL_IP_REQ", $sformatf("TUNNEL IP pkt is----->:\n%s",outer_ip_req.sprint()), UVM_MEDIUM)
					end /*}}}*/
			    end
			    begin:MAC_LAYER
					//added @2016.10.30 for rand policy
					//mac_fcs_policy A = new();
					//mac_req.pcy = '{A};
					if(usr_req.has_phy_layer == 1) begin/*{{{*/
                	    mac_req.up_payload = usr_req.data;
                	    mac_req.m_idle_cfg = usr_req.m_idle_cfg;
						if(usr_req.is_phy_rand == 1) begin
							`ASSERT(mac_req.randomize() with { 
							                                  if(usr_req.has_ip_layer == 1) {
															      if(ip_req.is_arp == 1)
								                                      {mtype[0],mtype[1]} == 16'h0806;
															      else if(ip_req.is_mpls == 1)
								                                      {mtype[0],mtype[1]} == 16'h8847;
															      else if(ip_req.is_ipv4 == 1)
								                                      {mtype[0],mtype[1]} == 16'h0800;
															      else if(ip_req.is_ipv6 == 1)
								                                      {mtype[0],mtype[1]} == 16'h86DD;
															  }
															});
						end
						else begin
							`ASSERT(mac_req.randomize() with {
								                              is_phy == usr_req.is_phy;
								                              is_vlan == usr_req.is_vlan;
									                          foreach(da[i]) da[i] == usr_req.da[i];
										                      foreach(sa[i]) sa[i]== usr_req.sa[i];
											                  foreach(mtype[i]) mtype [i] == usr_req.mtype[i];
												              has_scapy == usr_req.has_scapy;
												              has_fcs == usr_req.has_fcs;
												              padding == usr_req.has_padding;
												              fcs_err == usr_req.fcs_err;
														    });
						end
					end 
					else 
						mac_req.mac_data = usr_req.data;/*}}}*/
					`uvm_info("MAC_REQ", $sformatf("MAC pkt is----->:\n%s",mac_req.sprint()), UVM_MEDIUM)
				end
			    begin:WRITE_APORT
					p_sequencer.trans_req_aport.write(trans_req);
					p_sequencer.ip_req_aport.write(ip_req);
					p_sequencer.mac_req_aport.write(mac_req);
		        end
                //########################################################################################
	        	start_item(mac_req);
                finish_item(mac_req);
                get_response(mac_rsp);
				p_sequencer.upper_seq_item_port.item_done(usr_rsp);
	        end
		end
    join
     
endtask: body
	
`endif 

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
//     FileName: bd_vsequence.sv 
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-09-21 14:35:29
//      History:
//============================================================================*/
`ifndef BD_VSEQUENCE__SV 
`define BD_VSEQUENCE__SV 


`define CPU_MEM_ADDR_WIDTH 32

`define BUFFER_MAX_LEN 4*1024/*bytes*/ 
//#########################################
`define PCIE_REG_SEQ  reg_access_frame_seq
`define PCIE_REG_SEQR reg_access_sequencer
//############################################################################
//bd message struct
//############################################################################
/*{{{*/
typedef struct packed {

	bit [31:0] data_ptr  ; 
	bit [11:0] data_len  ; 
	bit [ 3:0] rev0      ; 
	bit [10:0] bd_index  ; 
	bit        rev1      ; 
	bit		   last_frm  ; 
	bit		   first_frm ; 
	bit		   owner     ; 
	bit        valid     ; 

} s_bd_tx_data;

typedef struct packed {

	bit [31:0] data_ptr  ; 
	bit [11:0] data_len  ; 
	bit [ 3:0] rev0      ; 
	bit [10:0] bd_index  ; 
	bit        rev1      ; 
	bit		   last_frm  ; 
	bit		   first_frm ; 
	bit		   owner     ; 
	bit        valid     ; 

} s_bd_rx_data;

/*}}}*/
//############################################################################
//bd_base_seq
//############################################################################
class bd_base_seq extends uvm_sequence;
	/*{{{*/
	`PCIE_REG_SEQ  m_pcie_reg_seq;
	`PCIE_REG_SEQR m_pcie_reg_seqr;

    static bit [7:0] CPU_MEM [bit [`CPU_MEM_ADDR_WIDTH-1:0]] = '{default:0};
	static semaphore atomic = new(1);

	`uvm_object_utils_begin(bd_base_seq)
	`uvm_object_utils_end     

	function new(string name = "bd_base_seq");
		super.new(name);
	endfunction: new

	virtual task PCIE_REG_WR(input longint addr,input longint data);	
		m_pcie_reg_seq = `CREATE_OBJ(`PCIE_REG_SEQ,"m_pcie_reg_seq")
		m_pcie_reg_seq.s_m_write(addr,data,m_pcie_reg_seqr);
		`uvm_info("PCIE_REG_WR",$sformatf("@ADDR[0x%0h] -> DATA[0x%0h]",addr,data),UVM_HIGH); 
	endtask

	function void memhexdump(int start);
		/*{{{*/
		int len;
		for(int i=0;i<`BUFFER_MAX_LEN;i++) begin
			if(this.CPU_MEM.exists(start+i))
				len++;
			else 
				break;
		end
		$display($sformatf("[memhexdump[0x%0h]::%0t::%0d]:\n#####################################################",start,$time,len));
		for (int i=0;i<len;i++) begin
			if(i%16 == 0)
				$write("%4h  ",16*(i/16));
			$write("%2h ",this.CPU_MEM[start+i]);
			if (i%16 == 15) $write("\n");
		end
		$write("\n");
		$display("#####################################################");/*}}}*/
	endfunction
	/*}}}*/
endclass

//############################################################################
//bd_tx_data_seq
//############################################################################
class bd_tx_data_seq extends bd_base_seq;

	//########################################################################
    local longint bd_ring_id        = 0;
	local longint fpga_chn_ena_addr = 32'h5000;
	local longint fpga_bd_base_addr = 32'h5004;
	local longint fpga_bd_tail_addr = 32'h5008;
	local longint cpu_bd_start_addr = 32'h1000_0000;
    local longint cpu_buf_start_addr= 32'h2000_0000;
    local longint bd_deep           = 512;   
	local string  bd_chn_name       = $sformatf("TX_BD_%0d",bd_ring_id);
	//########################################################################
	s_bd_tx_data m_bd_info[$];
	bit8_que_t   m_buffer[$];
	bit          already_start = 0;
	bit          first_txbd_flag = 1;
	event        update_bd;
	int		     bd_update_time_gap = 10/*us*/;
	int          hang_bd_num = 8;
	bit          bd_display = 0;
	//########################################################################
	semaphore    cfg_atomic;
	int          start_body_num = 0;
	
	`uvm_object_utils_begin(bd_tx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "bd_tx_data_seq");
		super.new(name);
		cfg_atomic = new(1);
	endfunction: new

	virtual task body();
	    /*{{{*/
		int total_valid_bd_q[$];
		int next_valid_bd_idx = 0;
		//##########################################
		//Write TX BD CHN ena
		//##########################################
		if(first_txbd_flag == 1) begin 
			`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN ENA Register[0x%0h:0x%0h].",fpga_chn_ena_addr,1'b1),UVM_LOW)
			PCIE_REG_WR(fpga_chn_ena_addr,1'b1);
			`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN BD BASE Register[0x%0h:0x%0h].",fpga_bd_base_addr,cpu_bd_start_addr),UVM_LOW)
			PCIE_REG_WR(fpga_bd_base_addr,cpu_bd_start_addr);
			first_txbd_flag = 0;
		end
		//##########################################
	    fork
			forever begin
				@(update_bd);
				`uvm_info(bd_chn_name,"[Update BD Time Trigger]...............",UVM_LOW)
				if(m_bd_info.size() == 0) begin 
					`uvm_info(bd_chn_name,"Waiting BD Info FiFo to get data..........",UVM_LOW)
					wait(m_bd_info.size() > 0);
				end
				for(int i=next_valid_bd_idx;i<bd_deep;i++) begin 
                    next_valid_bd_idx = i;
					if(m_bd_info.size() > 0 && total_valid_bd_q.size() <= bd_deep-2) begin						
						if(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 1) begin
							`uvm_info(bd_chn_name,$sformatf("[Waiting BD Index:%0d] release>>>>>>>>>>",i),UVM_LOW)
						end
						wait(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 0) begin //owner bit
						    bd_pkt m_bd_pkt;/*{{{*/
							bit8_que_t m_buf_q;
                            s_bd_tx_data m_bd;
							`uvm_info(bd_chn_name,$sformatf("[Update BD Index:%0d]..........",i),UVM_MEDIUM)
							if(CPU_MEM[cpu_bd_start_addr+8*i+7][0] == 1) begin //valid bit
								bit [10:0] m_bd_idx;
								`uvm_info(bd_chn_name,$sformatf("[Update BD Index:%0d]..........",i),UVM_LOW)
								m_bd_idx = {CPU_MEM[cpu_bd_start_addr+8*i+6],CPU_MEM[cpu_bd_start_addr+8*i+7][7:5]};
								//if(m_bd_idx != i)
								//	`uvm_error(bd_chn_name,$sformatf("FPGA WriteBack BD idx[%0d] != current idx[%0d]",m_bd_idx,i))
							end
							total_valid_bd_q.push_back(1);
							m_bd = m_bd_info.pop_front();
							m_bd.data_ptr = cpu_buf_start_addr+`BUFFER_MAX_LEN*i;
                            {this.CPU_MEM[cpu_bd_start_addr+8*i+0],this.CPU_MEM[cpu_bd_start_addr+8*i+1],
                             this.CPU_MEM[cpu_bd_start_addr+8*i+2],this.CPU_MEM[cpu_bd_start_addr+8*i+3],
                             this.CPU_MEM[cpu_bd_start_addr+8*i+4],this.CPU_MEM[cpu_bd_start_addr+8*i+5],
                             this.CPU_MEM[cpu_bd_start_addr+8*i+6],this.CPU_MEM[cpu_bd_start_addr+8*i+7]} = m_bd;
							if(bd_display == 1)
								`uvm_info(bd_chn_name,$sformatf("[BD-VALUE]@(0x%0h):\n%0s",cpu_bd_start_addr+8*i,`SSTRUCT(m_bd)),UVM_LOW)
							//######################################################################
							m_buf_q = m_buffer.pop_front();
							atomic.get(1);
							m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
							m_bd_pkt.bd_id = this.bd_chn_name;
							m_bd_pkt.bd_data = m_buf_q;
							p_sequencer.tx_bd_aport.write(m_bd_pkt);
							atomic.put(1);
							//######################################################################
							if(bd_display == 1)
								hexdump(p_sequencer,m_buf_q); 
                            for(int m=0;m<`BUFFER_MAX_LEN;m++) begin
								if(m_buf_q.size() > 0)
									this.CPU_MEM[m_bd.data_ptr+m] = m_buf_q.pop_front();
							end
							if(bd_display == 1)
								memhexdump(m_bd.data_ptr);
							if(next_valid_bd_idx == bd_deep - 1)
								next_valid_bd_idx = 0;
							/*}}}*/
						end
					end
					else begin 
						if(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 1) begin
							`uvm_info(bd_chn_name,$sformatf("[Waiting BD Index:%0d] release>>>>>>>>>>",i),UVM_LOW)
						end
						wait(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 0) begin //owner bit
							//##########################################
							//Write TX BD Tail
							//##########################################
							`uvm_info(bd_chn_name,$sformatf("Writing FPGA BD Tail Register[0x%0h:0x%0h:%0d]",fpga_bd_tail_addr,
							                                 cpu_bd_start_addr+8*next_valid_bd_idx,next_valid_bd_idx),UVM_LOW)
							PCIE_REG_WR(fpga_bd_tail_addr,cpu_bd_start_addr+8*next_valid_bd_idx);
							break;
						end
					end
				end
			end
			forever begin 
				if(total_valid_bd_q.size() >= bd_deep-1) begin 
					for(int i=0;i<hang_bd_num;i++)
						void'(total_valid_bd_q.pop_front());
				end
			    ->update_bd;
				#(bd_update_time_gap*1us);
			end
		join_none
		/*}}}*/
	endtask

    virtual function void genTXBD( 
								   `PCIE_REG_SEQR pcie_reg_seqr,
	                               longint bd_ring_id           = 0,
								   longint fpga_chn_ena_addr    = 32'h5000,
	                   			   longint fpga_bd_base_addr    = 32'h5004,
	                   			   longint fpga_bd_tail_addr    = 32'h5008,
					   			   longint cpu_bd_start_addr    = 32'h1000_0000,  
                       			   longint cpu_buf_start_addr   = 32'h2000_0000,
                       			   longint bd_deep              = 512   
								 );
 		/*{{{*/
		this.m_pcie_reg_seqr    = pcie_reg_seqr;
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_ena_addr  = fpga_chn_ena_addr;
      	this.fpga_bd_base_addr  = fpga_bd_base_addr; 
      	this.fpga_bd_tail_addr  = fpga_bd_tail_addr; 
      	this.cpu_bd_start_addr  = cpu_bd_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
      	this.bd_deep            = bd_deep;           
		this.bd_chn_name        = $sformatf("TX_BD_%0d",bd_ring_id);
		/*}}}*/
    endfunction

	//##################################################################################################
	//bd_update_time_gap:CPU to check BD release
	//hang_bd_num:when be_deep is full,next check bd num to write BD tail
    virtual function void setCFG(int bd_update_time_gap = 5,int hang_bd_num = 16,bit bd_display = 0);
	    this.bd_update_time_gap = bd_update_time_gap;
	    this.hang_bd_num = hang_bd_num;
	    this.bd_display = bd_display;
	endfunction

	virtual task startPkt (
		                    input uvm_sequencer_base seqr, 
							input int m_pkt_num = 1,//bd num
						  	input data_gen_enum m_data_gen = FIXED,
						  	input int m_data_len_min = 100,
						  	input int m_data_len_max = 100,
						  	input int m_start_dvalue = 0,
						  	input bit [7:0] m_data[] = '{default:0},
							input int m_bd_split_len = `BUFFER_MAX_LEN-1,
							input bit valid = 1,
							input uvm_sequence_base parent=null
						  );
         /*{{{*/
		bit [7:0] dtq[$];
		bit8_que_t mm_buffer[$];
		int len;
		int m_sz;
		int mm_sz;
		cfg_atomic.get(1);
		if((m_data_len_min <= 0) || (m_data_len_max <= 0))
			`uvm_fatal("PKT_LEN","You set len <= zero!!!")
		else if((m_data_len_min >= `BUFFER_MAX_LEN) || (m_data_len_max >= `BUFFER_MAX_LEN))
			`uvm_fatal("PKT_LEN",$sformatf("You set len >= `BUFFER_MAX_LEN(%0d)!!!",`BUFFER_MAX_LEN))
		for(int i=0;i<m_pkt_num;i++) begin 
			len = $urandom_range(m_data_len_min,m_data_len_max);
			dtq.delete();
			if(m_data_gen == FIXED) begin
	            for(int j=0;j<len;j++)
					dtq.push_back(m_start_dvalue);
				mm_buffer.push_back(dtq);
			end
			else if(m_data_gen == RND) begin
				for(int j=0;j<len;j++)
					dtq.push_back($urandom());
				mm_buffer.push_back(dtq);
			end
			else if(m_data_gen == INCR) begin
				for(int j=0;j<len;j++)
					dtq.push_back(m_start_dvalue+j);
				mm_buffer.push_back(dtq);
			end
			else if(m_data_gen == USR) begin
				if(m_data.size() == 0)
					`uvm_fatal("PKT_LEN","You set len == zero!!!")
				else if(m_data.size() >= `BUFFER_MAX_LEN)
					`uvm_fatal("PKT_LEN",$sformatf("You set len[%0d] >= `BUFFER_MAX_LEN(%0d)!!!",m_data.size(),`BUFFER_MAX_LEN))
				dtq = m_data;
				mm_buffer.push_back(dtq);
			end
		end
		//###################################################
		m_sz = mm_buffer.size();
		for(int i=0;i<m_sz;i++)
			this.m_buffer.push_back(mm_buffer[i]); 
		for(int i=0;i<m_sz;i++) begin
			s_bd_tx_data m_bd;
			mm_sz = mm_buffer[i].size();
			m_bd.data_len  = mm_sz; 
			m_bd.last_frm  = 1'b1; 
			m_bd.first_frm = 1'b1; 
			m_bd.owner     = 1'b1; 
			m_bd.valid     = valid; 
			this.m_bd_info.push_back(m_bd);
		end
		//###################################################
		if(this.already_start == 0) begin
			this.already_start = 1;
			start_body_num++;
			if(start_body_num == 1)
				this.start(seqr,parent);
		end
		cfg_atomic.put(1);
		/*}}}*/
	endtask:startPkt
 
	//##################################################################################################
	//##################################################################################################
	virtual task setTunnelEndTable(input uvm_sequencer_base seqr, 
								   input bit [ 3:0] table_op,
								   input bit [ 7:0] table_vnum,
								   input s_vxlan_tunnel_end vxlan_tunnel_end[$] = '{default:0},
								   input data_op_e  push_or_sent = START,
								   input bit [ 3:0] table_type = 4'd2
                                  );
		bit [7:0] m_q[$];/*{{{*/
		if(table_vnum == 0)
			`uvm_fatal("setTunnelEndTable","You set wrong table num[0]!!!")
		else if(table_vnum > 254)
			`uvm_fatal("setTunnelEndTable","You set wrong table num[>254]!!!")
		m_q.push_back({table_type,table_op});
		m_q.push_back(table_vnum);
        for(int i=0;i<14;i++)
			m_q.push_back(8'h0);
		//########################################
		for(int i=0;i<table_vnum;i++) begin
			m_q.push_back(vxlan_tunnel_end[i].sip[31:24]);
			m_q.push_back(vxlan_tunnel_end[i].sip[23:16]);
			m_q.push_back(vxlan_tunnel_end[i].sip[15: 8]);
			m_q.push_back(vxlan_tunnel_end[i].sip[ 7: 0]);
			m_q.push_back(vxlan_tunnel_end[i].dip[31:24]);
			m_q.push_back(vxlan_tunnel_end[i].dip[23:16]);
			m_q.push_back(vxlan_tunnel_end[i].dip[15: 8]);
			m_q.push_back(vxlan_tunnel_end[i].dip[ 7: 0]);
			m_q.push_back(vxlan_tunnel_end[i].svp[15: 8]);
			m_q.push_back(vxlan_tunnel_end[i].svp[ 7: 0]);
			for(int j=0;j<6;j++)
				m_q.push_back(8'h0);
		end
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
		this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

	virtual task setTunnelCapTable(input uvm_sequencer_base seqr, 
								   input bit [ 3:0] table_op,
								   input bit [ 7:0] table_vnum,
								   input s_vxlan_tunnel_cap vxlan_tunnel_cap[$] = '{default:0},
								   input data_op_e  push_or_sent = START,
								   input bit [ 3:0] table_type = 4'd3
                                  );
		bit [7:0] m_q[$];  /*{{{*/
		if(table_vnum == 0)
			`uvm_fatal("setTunnelCapTable","You set wrong table num[0]!!!")
		else if(table_vnum > 83)
			`uvm_fatal("setTunnelCapTable","You set wrong table num[>83]!!!")
		m_q.push_back({table_type,table_op});
		m_q.push_back(table_vnum);
        for(int i=0;i<14;i++)
			m_q.push_back(8'h0);
		//########################################
		for(int i=0;i<table_vnum;i++) begin
			m_q.push_back(vxlan_tunnel_cap[i].index);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[47:40]);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[39:32]);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[31:24]);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[23:16]);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].dmac[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[47:40]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[39:32]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[31:24]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[23:16]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].smac[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].pop);
			m_q.push_back(vxlan_tunnel_cap[i].vlan[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].vlan[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].sip[31:24]);
			m_q.push_back(vxlan_tunnel_cap[i].sip[23:16]);
			m_q.push_back(vxlan_tunnel_cap[i].sip[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].sip[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].dip[31:24]);
			m_q.push_back(vxlan_tunnel_cap[i].dip[23:16]);
			m_q.push_back(vxlan_tunnel_cap[i].dip[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].dip[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].tos);
			m_q.push_back(vxlan_tunnel_cap[i].ttl);
			m_q.push_back(vxlan_tunnel_cap[i].sport[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].sport[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].dport[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].dport[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].vni[23:16]);
			m_q.push_back(vxlan_tunnel_cap[i].vni[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].vni[ 7: 0]);
			m_q.push_back(vxlan_tunnel_cap[i].tunnel_flg[15: 8]);
			m_q.push_back(vxlan_tunnel_cap[i].tunnel_flg[ 7: 0]);
			for(int j=0;j<13;j++)
				m_q.push_back(8'h0);
		end
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

    virtual task setMaskTable(input uvm_sequencer_base seqr, 
							  input bit [  3:0] table_op,
							  input bit [  7:0] table_vnum,
							  input s_mask_table mask_table[$] = '{default:0},
							  input data_op_e  push_or_sent = START,
							  input bit [ 3:0] table_type = 4'd0
                             );
 		bit [7:0] m_q[$];/*{{{*/
		if(table_vnum == 0)
			`uvm_fatal("setMaskTable","You set wrong table num[0]!!!")
		else if(table_vnum > 65)
			`uvm_fatal("setMaskTable","You set wrong table num[>65]!!!")
		m_q.push_back({table_type,table_op});
		m_q.push_back(table_vnum);
        for(int i=0;i<14;i++)
			m_q.push_back(8'h0);
		//############################################
		for(int i=0;i<table_vnum;i++) begin
			m_q.push_back({mask_table[i].mask_index[9:2]});
			m_q.push_back({mask_table[i].mask_index[1:0],6'b0});
			for(int j=0;j<57;j++) begin 
				m_q.push_back(mask_table[i].mask[57*8-1-8*j -:8]);
			end
			for(int j=0;j<5;j++)
				m_q.push_back(8'h0);
		end
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

    virtual task setFlowTable(input uvm_sequencer_base seqr, 
							  input bit [3:0] table_op,
							  input bit [7:0] table_vnum,
							  input s_flow_table flow_table[$]  = '{default:0},
							  input data_op_e  push_or_sent = START,
							  input bit [ 3:0] table_type = 4'd1
                             );
		bit [7:0] m_q[$];/*{{{*/
		byte66_t  m_flowaction_bits;
		if(table_vnum == 0)
			`uvm_fatal("setFlowTable","You set wrong table num[0]!!!")
		else if(table_vnum > 19)
			`uvm_fatal("setFlowTable","You set wrong table num[>19]!!!")
		m_q.push_back({table_type,table_op});
		m_q.push_back(table_vnum);
        for(int i=0;i<14;i++)
			m_q.push_back(8'h0);
		//##############################################
		for(int i=0;i<table_vnum;i++) begin
			for(int j=0;j<57;j++) begin 
				m_q.push_back({flow_table[i].key[57*8-1-8*j -:8]&flow_table[i].mask[57*8-1-8*j -:8]});
			end
			for(int j=0;j<57;j++) begin 
				m_q.push_back({flow_table[i].mask[57*8-1-8*j -:8]});
			end
			m_q.push_back({flow_table[i].mask_index[9:2]});
			m_q.push_back({flow_table[i].mask_index[1:0],6'b0});
			m_q.push_back(8'h0);
			m_q.push_back(8'h0);
			m_flowaction_bits = byte66_t'(flow_table[i].action);
			for(int j=0;j<66;j++) begin 
				m_q.push_back(m_flowaction_bits[66*8-1-8*j -:8]);
			end
			for(int j=0;j<16;j++) begin 
				m_q.push_back({flow_table[i].ufid[16*8-1-8*j -:8]});
			end
			for(int j=0;j<8;j++)
				m_q.push_back(8'h0);
		end
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

	virtual task setDUMPTable(input uvm_sequencer_base seqr, 
							  input bit [ 3:0] table_type,
							  input data_op_e  push_or_sent = START
                             );
		bit [7:0] m_q[$];/*{{{*/
		if(table_type > 3)
			`uvm_fatal("setDUMPTable",$sformatf("You set wrong table type[%0d]!!!",table_type))
		m_q.push_back({table_type,4'b0});
        for(int i=0;i<15;i++)
			m_q.push_back(8'h0);
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

	
    virtual task setCPUPkt(input uvm_sequencer_base  seqr, 
	                       input bit [31:0]          mes,
						   input bit [15:0]          svp,
						   input s_flowaction [0:21] m_flowaction,
						   input bit [7:0]           m_data[],
						   input data_op_e           push_or_sent = START
                           );
		bit [7:0] m_q[$];/*{{{*/
		byte66_t action_tmp;
		int m_len;
		action_tmp = byte66_t'(m_flowaction);
		m_q.push_back(mes[31:24]);
		m_q.push_back(mes[23:16]);
		m_q.push_back(mes[15: 8]);
		m_q.push_back(mes[ 7: 0]);
		m_q.push_back(svp[15:8]);
		m_q.push_back(svp[ 7:0]);
		for(int i=0;i<66;i++)
			m_q.push_back(action_tmp[66*8-8*i-1 -:8]);
        m_len = m_data.size();
		for(int i=0;i<m_len;i++)
			m_q.push_back(m_data[i]);
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask

	//##################################################################################################
	virtual task setErrorFlowTable(input uvm_sequencer_base seqr, 
							       input bit [3:0] table_op,
							       input bit [7:0] table_vnum,
							       input s_flow_table flow_table[$]  = '{default:0},
							       input data_op_e  push_or_sent = START,
							       input bit [ 3:0] table_type = 4'd1
                                  );
		bit [7:0] m_q[$];/*{{{*/
		byte66_t  m_flowaction_bits;
		if(table_vnum == 0)
			`uvm_fatal("setFlowTable","You set wrong table num[0]!!!")
		else if(table_vnum > 19)
			`uvm_fatal("setFlowTable","You set wrong table num[>19]!!!")
		m_q.push_back({table_type,table_op});
		m_q.push_back(table_vnum);
        for(int i=0;i<14;i++)
			m_q.push_back(8'h0);
		//##############################################
		for(int i=0;i<$urandom_range(1,table_vnum-1);i++) begin
			for(int j=0;j<57;j++) begin 
				m_q.push_back({flow_table[i].key[57*8-1-8*j -:8]});
			end
			for(int j=0;j<57;j++) begin 
				m_q.push_back({flow_table[i].mask[57*8-1-8*j -:8]});
			end
			m_q.push_back({flow_table[i].mask_index[9:2]});
			m_q.push_back({flow_table[i].mask_index[1:0],6'b0});
			m_q.push_back(8'h0);
			m_q.push_back(8'h0);
			m_flowaction_bits = byte66_t'(flow_table[i].action);
			for(int j=0;j<66;j++) begin 
				m_q.push_back(m_flowaction_bits[66*8-1-8*j -:8]);
			end
			for(int j=0;j<16;j++) begin 
				m_q.push_back({flow_table[i].ufid[16*8-1-8*j -:8]});
			end
			for(int j=0;j<8;j++)
				m_q.push_back(8'h0);
		end
		if(push_or_sent == PUSH)
			this.already_start = 1;
		else if(push_or_sent == START)
			this.already_start = 0;
	    this.startPkt(seqr,1,USR,1,1,0,m_q);
		/*}}}*/
	endtask
	//##################################################################################################
	//##################################################################################################

endclass


//############################################################################
//bd_rx_data_seq
//############################################################################
class bd_rx_data_seq extends bd_base_seq;

	//########################################################################
    local longint bd_ring_id        = 0;
	local longint fpga_chn_ena_addr = 32'h5000;
	local longint fpga_bd_base_addr = 32'h5004;
	local longint fpga_bd_tail_addr = 32'h5008;
	local longint cpu_bd_start_addr = 32'h1000_0000;
    local longint cpu_buf_start_addr= 32'h2000_0000;
    local longint bd_deep           = 512;   
	local string  bd_chn_name       = $sformatf("RX_BD_%0d",bd_ring_id);
	//########################################################################
	s_bd_rx_data m_bd_info[$];
	event        update_bd;
	bit          first_rxbd_flag = 1;
	int		     bd_update_time_gap = 5/*us*/;
	int          m_bd_num = 128;
	//########################################################################
	
	`uvm_object_utils_begin(bd_rx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "bd_rx_data_seq");
		super.new(name);
	endfunction: new

	virtual task body();
	    /*{{{*/
		int total_valid_bd_q[$];
		int next_valid_bd_idx = 0;
		bit	start_wr_tail = 0;
		bit jump_flag = 0;
		//##########################################
		//Write RX BD CHN ena
		//##########################################
		if(first_rxbd_flag == 1) begin 
			`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN ENA Register[0x%0h:0x%0h].",fpga_chn_ena_addr,1'b1),UVM_LOW)
			PCIE_REG_WR(fpga_chn_ena_addr,1'b1);
			`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN BD BASE Register[0x%0h:0x%0h].",fpga_bd_base_addr,cpu_bd_start_addr),UVM_LOW)
			PCIE_REG_WR(fpga_bd_base_addr,cpu_bd_start_addr);
			first_rxbd_flag = 0;
		end
		//##########################################
	    fork
			forever begin
				@(update_bd);
				`uvm_info(bd_chn_name,"[Update BD Time Trigger]...............",UVM_LOW)
				if(m_bd_info.size() > 0) begin 
					for(int i=next_valid_bd_idx;i<bd_deep;i++) begin 
                        next_valid_bd_idx = i;
						if(m_bd_info.size() > 0) begin						
							jump_flag = 1;
							if(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 1) begin
								`uvm_info(bd_chn_name,$sformatf("[Waiting BD Index:%0d] release>>>>>>>>>>",i),UVM_LOW)
							end
							wait(CPU_MEM[cpu_bd_start_addr+8*i+7][1] == 0) begin //owner bit
                                s_bd_rx_data m_bd;
								s_bd_rx_data chk_bd;
								`uvm_info(bd_chn_name,$sformatf("[Update BD Index:%0d]..........",i),UVM_MEDIUM)
								if(CPU_MEM[cpu_bd_start_addr+8*i+7][0] == 1) begin //valid bit
									bit [31:0] m_data_ptr; 
									bit [11:0] m_data_len; 
									bit [10:0] m_bd_idx  ;
									bit8_que_t m_dtq     ;
									`uvm_info(bd_chn_name,$sformatf("[Update BD Index:%0d]..........",i),UVM_LOW)
									m_data_ptr = {CPU_MEM[cpu_bd_start_addr+8*i+0],CPU_MEM[cpu_bd_start_addr+8*i+1],
									              CPU_MEM[cpu_bd_start_addr+8*i+2],CPU_MEM[cpu_bd_start_addr+8*i+3]};
									m_data_len = {CPU_MEM[cpu_bd_start_addr+8*i+4],CPU_MEM[cpu_bd_start_addr+8*i+5][7:4]};
									m_bd_idx   = {CPU_MEM[cpu_bd_start_addr+8*i+6],CPU_MEM[cpu_bd_start_addr+8*i+7][7:5]};
									begin:CHK_BD_BUFFER_ADDR
										bit [31:0]   chk_data_ptr; /*{{{*/
										chk_data_ptr     = cpu_buf_start_addr+4096*i;
										chk_bd.data_ptr  = m_data_ptr; 
										chk_bd.data_len  = m_data_len; 
										chk_bd.bd_index  = m_bd_idx  ; 
										chk_bd.last_frm  = CPU_MEM[cpu_bd_start_addr+8*i+7][3]; 
										chk_bd.first_frm = CPU_MEM[cpu_bd_start_addr+8*i+7][2]; 
										chk_bd.owner     = CPU_MEM[cpu_bd_start_addr+8*i+7][1]; 
										chk_bd.valid     = CPU_MEM[cpu_bd_start_addr+8*i+7][0]; 
										if(chk_data_ptr != m_data_ptr) begin 
											`uvm_error(bd_chn_name,$sformatf("Cfg buffer addr[0x%h] != FPGA readback buffer addr[0x%h]!",
											                                  chk_data_ptr,m_data_ptr))
											`uvm_error(bd_chn_name,$sformatf("[ReadBack-BD-VALUE]:\n%0s",`SSTRUCT(chk_bd)))
											memhexdump(chk_bd.data_ptr);
										end
										else begin 
											`uvm_info(bd_chn_name,$sformatf("Cfg buffer addr[0x%h] == FPGA readback buffer addr[0x%h]!",
											                                 chk_data_ptr,m_data_ptr),UVM_MEDIUM)
											`uvm_info(bd_chn_name,$sformatf("[ReadBack-BD-VALUE]:\n%0s",`SSTRUCT(chk_bd)),UVM_LOW)
											//memhexdump(chk_bd.data_ptr);
										end /*}}}*/
									end
									//if(m_bd_idx != i)
									//	`uvm_error(bd_chn_name,$sformatf("FPGA WriteBack BD idx[%0d] != current idx[%0d]",m_bd_idx,i))
									begin 
										//get data from bd.data_ptr
										if(m_data_len == 0) begin 
											`uvm_error(bd_chn_name,$sformatf("FPGA WriteBack BD[idx:%0d] data_len is zero!",i))
											`uvm_error(bd_chn_name,$sformatf("[ReadBack-BD-VALUE]:\n%0s",`SSTRUCT(chk_bd)))
											memhexdump(chk_bd.data_ptr);
										end
										else begin
											bd_pkt m_bd_pkt;
											for(int m=0;m<m_data_len;m++) begin
												m_dtq.push_back(CPU_MEM[m_data_ptr+m]);
											end
                                            atomic.get(1);
											m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
											m_bd_pkt.bd_id = this.bd_chn_name;
											m_bd_pkt.bd_data = m_dtq;
											p_sequencer.rx_bd_aport.write(m_bd_pkt);
											atomic.put(1);
											m_dtq.delete();
											`uvm_info(bd_chn_name,$sformatf("Recv BD-Buffer pkt:\n%0s",m_bd_pkt.sprint()),UVM_MEDIUM)
										end
									end
								end
								else begin 
									`uvm_info(bd_chn_name,$sformatf("[Update BD Index:%0d]:owner == 0 and valid == 0 --> Empty BD.",i),UVM_MEDIUM)
								end
								m_bd = m_bd_info.pop_front();
								m_bd.data_ptr = cpu_buf_start_addr+`BUFFER_MAX_LEN*i;
                                {this.CPU_MEM[cpu_bd_start_addr+8*i+0],this.CPU_MEM[cpu_bd_start_addr+8*i+1],
                                 this.CPU_MEM[cpu_bd_start_addr+8*i+2],this.CPU_MEM[cpu_bd_start_addr+8*i+3],
                                 this.CPU_MEM[cpu_bd_start_addr+8*i+4],this.CPU_MEM[cpu_bd_start_addr+8*i+5],
                                 this.CPU_MEM[cpu_bd_start_addr+8*i+6],this.CPU_MEM[cpu_bd_start_addr+8*i+7]} = m_bd;
								`uvm_info(bd_chn_name,$sformatf("[BD-VALUE]@(0x%0h):\n%0s",cpu_bd_start_addr+8*i,`SSTRUCT(m_bd)),UVM_MEDIUM)
								if(next_valid_bd_idx == bd_deep - 1)
									next_valid_bd_idx = 0;
							end
						end
						else begin 
							if(jump_flag == 1) begin 
								start_wr_tail = 1;
								jump_flag = 0;
							end
							break;
						end
					end
					//##########################################
					//Write RX BD Tail
	    			//##########################################
					if(start_wr_tail == 1) begin
						`uvm_info(bd_chn_name,$sformatf("Writing FPGA BD Tail Register[0x%0h:0x%0h:%0d]",fpga_bd_tail_addr,
						                                 cpu_bd_start_addr+8*next_valid_bd_idx,next_valid_bd_idx),UVM_LOW)
						PCIE_REG_WR(fpga_bd_tail_addr,cpu_bd_start_addr+8*next_valid_bd_idx);
						start_wr_tail = 0;
					end
	    			//##########################################
				end
			end
			forever begin 
				if(this.m_bd_info.size() == 0) begin 
					for(int i=0;i<m_bd_num;i++) begin
						s_bd_rx_data m_bd;
						m_bd.data_len  = 0; 
						m_bd.last_frm  = 1'b1; 
						m_bd.first_frm = 1'b1; 
						m_bd.owner     = 1'b1; 
						m_bd.valid     = 1'b1;//rand 
						this.m_bd_info.push_back(m_bd);
					end
				end
			    ->update_bd;
				#(bd_update_time_gap*1us);
			end
		join_none
		/*}}}*/
	endtask

    virtual function void genRXBD( 
								   `PCIE_REG_SEQR pcie_reg_seqr,
	                               longint bd_ring_id           = 0,
								   longint fpga_chn_ena_addr    = 32'h5000,
	                   			   longint fpga_bd_base_addr    = 32'h5004,
	                   			   longint fpga_bd_tail_addr    = 32'h5008,
					   			   longint cpu_bd_start_addr    = 32'h1000_0000,  
                       			   longint cpu_buf_start_addr   = 32'h2000_0000,
                       			   longint bd_deep              = 512   
								 );
		/*{{{*/
		this.m_pcie_reg_seqr    = pcie_reg_seqr;
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_ena_addr  = fpga_chn_ena_addr;
      	this.fpga_bd_base_addr  = fpga_bd_base_addr; 
      	this.fpga_bd_tail_addr  = fpga_bd_tail_addr; 
      	this.cpu_bd_start_addr  = cpu_bd_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
      	this.bd_deep            = bd_deep;           
		this.bd_chn_name        = $sformatf("RX_BD_%0d",bd_ring_id);
		/*}}}*/
    endfunction

	//bd_update_time_gap:CPU to check BD release
    virtual function void setCFG(int bd_update_time_gap = 5,int m_bd_num = 128);
	    this.bd_update_time_gap = bd_update_time_gap;
		this.m_bd_num = m_bd_num;
		if(this.m_bd_num > this.bd_deep-1)//>511
			`uvm_fatal(bd_chn_name,$sformatf("You set more BD than valid BD num[%0d:%0d]",this.bd_deep-1,m_bd_num))
	endfunction

	virtual task startPkt (
		                 input uvm_sequencer_base seqr, 
						 input uvm_sequence_base parent=null
						);
        /*{{{*/
		this.start(seqr,parent);
		/*}}}*/
	endtask:startPkt

endclass

`include "./mbd_vsequence.sv"


`endif 

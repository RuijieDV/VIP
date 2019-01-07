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
// (c) Copyright 2017 RUIJIE, Inc.
// All rights reserved.

//============================================================================
//     FileName: mbd_vsequence.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2017-04-11 15:57:16
//      History:
//============================================================================*/
`ifndef MBD_VSEQUENCE__SV
`define MBD_VSEQUENCE__SV

//############################################################################
//mbd_tx_data_seq
//############################################################################
class mbd_tx_data_seq extends bd_tx_data_seq;

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
	
	`uvm_object_utils_begin(mbd_tx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "mbd_tx_data_seq");
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
								hexdump(m_buf_q); 
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
		bit [1:0]  mm_first_last[$];
		int len;
		int m_split_num;
		int m_mod;
		int m_rend;
		int m_sz;
		int mm_sz;
		cfg_atomic.get(1);
		if((m_data_len_min <= 0) || (m_data_len_max <= 0))
			`uvm_fatal("PKT_LEN","You set len <= zero!!!")
		else if(m_bd_split_len > `BUFFER_MAX_LEN-1)
			`uvm_fatal("PKT_LEN",$sformatf("You set split len > %0d!!!",`BUFFER_MAX_LEN-1))
		for(int i=0;i<m_pkt_num;i++) begin 
			len = $urandom_range(m_data_len_min,m_data_len_max);
            m_mod = len/m_bd_split_len;
			m_rend = len%m_bd_split_len;
			if(m_rend != 0)
				m_split_num = m_mod + 1;
			else
				m_split_num = m_mod;
			`uvm_info("PKT_LEN",$sformatf("You set len[%0d] vs split len(%0d),then Pkt will be split to multiple BD[%0d]!",
			                              len,m_bd_split_len,m_split_num),UVM_LOW)
			dtq.delete();
			if(m_data_gen == FIXED) begin
				for(int i=0;i<m_split_num;++i) begin 
					dtq.delete();
					for(int j=0;(j<m_bd_split_len) && (j<len-m_bd_split_len*i);j++)
						dtq.push_back(m_start_dvalue);
					mm_buffer.push_back(dtq);
					if(m_split_num==1)
						mm_first_last.push_back(2'b11);
					else begin
						if(i==0)
							mm_first_last.push_back(2'b01);
						else if(i==m_split_num-1)
							mm_first_last.push_back(2'b10);
						else
							mm_first_last.push_back(2'b00);
					end
				end
			end
			else if(m_data_gen == RND) begin
				for(int i=0;i<m_split_num;++i) begin 
					dtq.delete();
					for(int j=0;(j<m_bd_split_len) && (j<len-m_bd_split_len*i);j++)
						dtq.push_back($urandom());
					mm_buffer.push_back(dtq);
					if(m_split_num==1)
						mm_first_last.push_back(2'b11);
					else begin
						if(i==0)
							mm_first_last.push_back(2'b01);
						else if(i==m_split_num-1)
							mm_first_last.push_back(2'b10);
						else
							mm_first_last.push_back(2'b00);
					end
				end
			end
			else if(m_data_gen == INCR) begin
				for(int i=0;i<m_split_num;++i) begin 
					dtq.delete();
					for(int j=0;(j<m_bd_split_len) && (j<len-m_bd_split_len*i);j++)
						dtq.push_back(m_start_dvalue+j);
					mm_buffer.push_back(dtq);
					if(m_split_num==1)
						mm_first_last.push_back(2'b11);
					else begin
						if(i==0)
							mm_first_last.push_back(2'b01);
						else if(i==m_split_num-1)
							mm_first_last.push_back(2'b10);
						else
							mm_first_last.push_back(2'b00);
					end
				end
			end
			else if(m_data_gen == USR) begin
				bit [7:0] m_dtq[$];
				m_dtq = m_data;
				len = m_data.size();
				if(len == 0)
					`uvm_fatal("PKT_LEN","You set len == zero!!!")
				if((len > m_bd_split_len)) begin 
            	    m_mod = len/m_bd_split_len;
				    m_rend = len%m_bd_split_len;
					if(m_rend != 0)
						m_split_num = m_mod + 1;
					else
						m_split_num = m_mod;
					`uvm_info("PKT_LEN",$sformatf("You set len[%0d] > split len(%0d),then Pkt will be split to multiple BD[%0d]!",
					                              len,m_bd_split_len,m_split_num),UVM_LOW)
				end
				for(int i=0;i<m_split_num;++i) begin 
					dtq.delete();
					for(int j=0;(j<m_bd_split_len) && (j<len-m_bd_split_len*i);j++)
						dtq.push_back(m_dtq.pop_front());
					mm_buffer.push_back(dtq);
					if(m_split_num==1)
						mm_first_last.push_back(2'b11);
					else begin
						if(i==0)
							mm_first_last.push_back(2'b01);
						else if(i==m_split_num-1)
							mm_first_last.push_back(2'b10);
						else
							mm_first_last.push_back(2'b00);
					end
				end
			end
		end
		//###################################################
		m_sz = mm_buffer.size();
		for(int i=0;i<m_sz;i++)
			this.m_buffer.push_back(mm_buffer[i]); 
		for(int i=0;i<m_sz;i++) begin
			bit [1:0] m_sop_eop;
			s_bd_tx_data m_bd;
			mm_sz = mm_buffer[i].size();
			m_sop_eop = mm_first_last.pop_front();
			m_bd.data_len  = mm_sz; 
			if(m_sop_eop == 2'b11) begin
				m_bd.last_frm  = 1'b1; 
				m_bd.first_frm = 1'b1; 
			end
			else if(m_sop_eop == 2'b01) begin
				m_bd.last_frm  = 1'b0; 
				m_bd.first_frm = 1'b1; 
			end
			else if(m_sop_eop == 2'b10) begin
				m_bd.last_frm  = 1'b1; 
				m_bd.first_frm = 1'b0; 
			end
			else if(m_sop_eop == 2'b00) begin
				m_bd.last_frm  = 1'b0; 
				m_bd.first_frm = 1'b0; 
			end
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

endclass


//############################################################################
//mbd_rx_data_seq
//############################################################################
class mbd_rx_data_seq extends bd_rx_data_seq;

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
	
	`uvm_object_utils_begin(mbd_rx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "mbd_rx_data_seq");
		super.new(name);
	endfunction: new

	virtual task body();
	    /*{{{*/
		int total_valid_bd_q[$];
		int next_valid_bd_idx = 0;
		bit	start_wr_tail = 0;
		bit jump_flag = 0;
		bit8_que_t m_dtq;
		bit  m_start = 0;
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
											if(chk_bd.first_frm == 1)
												m_start = 1;
											if(m_start == 1) begin
												for(int m=0;m<m_data_len;m++) begin
													m_dtq.push_back(CPU_MEM[m_data_ptr+m]);
												end
												if(chk_bd.last_frm == 1) begin 
													atomic.get(1);
													m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
													m_bd_pkt.bd_id = this.bd_chn_name;
													m_bd_pkt.bd_data = m_dtq;
													p_sequencer.rx_bd_aport.write(m_bd_pkt);
													atomic.put(1);
													m_dtq.delete();
													`uvm_info(bd_chn_name,$sformatf("Recv BD-Buffer pkt:\n%0s",m_bd_pkt.sprint()),UVM_MEDIUM)
													m_start = 0;
												end
											end
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


`endif 

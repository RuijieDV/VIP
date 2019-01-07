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
//     FileName: sdma_vsequence.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2017-07-28 11:14:54
//      History:
//============================================================================*/
`ifndef SDMA_VSEQUENCE__SV
`define SDMA_VSEQUENCE__SV

`define CPU_MEM_ADDR_WIDTH 32

`define TX_BD_LEN 16/*TX BD :16B*/ 
`define RX_BD_LEN 16/*RX BD :16B*/ 
`define TX_BUFFER_MAX_LEN 16*1024/*TX BD DATA : 16KB*/ 
`define RX_BUFFER_MAX_LEN  2*1024/*RX BD DATA : 2KB*/ 
//#########################################
`define PCIE_REG_SEQ  reg_access_frame_seq
`define PCIE_REG_SEQR reg_access_sequencer
//############################################################################
//bd message struct
//############################################################################
/*{{{*/
//#########################################################
//SDMA TX BD Descriptor
//#########################################################
typedef struct packed {
	
	bit			o        ;//0:CPU 1:FPGA,set by CPU/FPGA
	bit 		reserved0;//set by FPGA
	bit [ 5:0]	reserved1;//set by FPGA
	bit 		ei       ;//set by CPU
	bit 		reserved2;//set by FPGA
	bit 		f        ;//set by CPU
	bit 		l        ;//set by CPU
	bit [ 6:0]  reserved3;//set by FPGA
	bit 		recal_crc;//set by CPU
	bit [11:0]  reserved4;//set by FPGA

} s_tx_cs_field;

typedef struct packed {
	
	bit [ 1:0] reserved0   ;//set by CPU
	bit [13:0] pkt_byte_cnt;//set by CPU
	bit [15:0] reserved1   ;//set by CPU

} s_tx_bc_field;

typedef struct packed {
	
	bit [31:0] buffer_ptr  ;//set by CPU

} s_tx_bp_field;

typedef struct packed {
	
	bit [31:0] nextbd_ptr  ;//set by CPU

} s_tx_np_field;



typedef struct packed {
	
	s_tx_cs_field cs_field;
	s_tx_bc_field bc_field;
	s_tx_bp_field bp_field;
	s_tx_np_field np_field;

} s_bd_tx_data;
//#########################################################

//#########################################################
//SDMA RX BD Descriptor
//#########################################################
typedef struct packed {
	
	bit			o        ;//0:CPU 1:FPGA,set by CPU/FPGA
	bit 		bus_error;//set by FPGA
	bit 		ei       ;//set by CPU
	bit 		rsrcerror;//set by FPGA
	bit 		f        ;//set by FPGA
	bit 		l        ;//set by FPGA
	bit [25:0]  reserved ;//set by FPGA

} s_rx_cs_field;

typedef struct packed {
	
	bit        reserved0   ;//set by FPGA
	bit		   invld_crc   ;//set by FPGA
	bit [13:0] pkt_byte_cnt;//set by FPGA
	bit [ 1:0] reserved1   ;//set by FPGA
	bit [10:0] buffer_size ;//set by CPU
	bit [ 2:0] reserved2   ;//set by FPGA

} s_rx_bc_field;

typedef struct packed {
	
	bit [24:0] buffer_ptr  ;//set by CPU
	bit [ 6:0] reserved    ;//set by CPU

} s_rx_bp_field;

typedef struct packed {
	
	bit [31:0] nextbd_ptr  ;//set by CPU

} s_rx_np_field;


typedef struct packed {

	s_rx_cs_field cs_field;
	s_rx_bc_field bc_field;
	s_rx_bp_field bp_field;
	s_rx_np_field np_field;

} s_bd_rx_data;
//#########################################################

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

	function void tx_memhexdump(string id,int start,int m_len = `TX_BUFFER_MAX_LEN);
		/*{{{*/
		int len;
		for(int i=0;i<m_len;i++) begin
			if(this.CPU_MEM.exists(start+i))
				len++;
			else 
				break;
		end
		$display($sformatf("[%0s[0x%0h]::%0t::%0d]:\n#####################################################",id,start,$time,len));
		for (int i=0;i<len;i++) begin
			if(i%16 == 0)
				$write("%4h  ",16*(i/16));
			$write("%2h ",this.CPU_MEM[start+i]);
			if (i%16 == 15) $write("\n");
		end
		$write("\n");
		$display("#####################################################");/*}}}*/
	endfunction
    function void rx_memhexdump(string id,int start,int m_len=`RX_BUFFER_MAX_LEN);
		/*{{{*/
		int len;
		for(int i=0;i<m_len;i++) begin
			if(this.CPU_MEM.exists(start+i))
				len++;
			else 
				break;
		end
		$display($sformatf("[%0s[0x%0h]::%0t::%0d]:\n#####################################################",id,start,$time,len));
		for (int i=0;i<len;i++) begin
			if(i%16 == 0)
				$write("%4h  ",16*(i/16));
			$write("%2h ",this.CPU_MEM[start+i]);
			if (i%16 == 15) $write("\n");
		end
		$write("\n");
		$display("#####################################################");/*}}}*/
	endfunction
    function s_bd_tx_data Mem2TXBD(int m_cpu_start_addr);
		bit8_que_t m_que;
		for(int i=0;i<`TX_BD_LEN;i++)
			m_que.push_back(this.CPU_MEM[m_cpu_start_addr+i]);
		return s_bd_tx_data'(m_que);
	endfunction
	function s_bd_rx_data Mem2RXBD(int m_cpu_start_addr);
		bit8_que_t m_que;
		for(int i=0;i<`RX_BD_LEN;i++)
			m_que.push_back(this.CPU_MEM[m_cpu_start_addr+i]);
		return s_bd_rx_data'(m_que);
	endfunction
    function void TXBD2Mem(s_bd_tx_data m_bd,int m_cpu_start_addr);
		bit8_que_t m_que;
		m_que = bit8_que_t'(m_bd);
		for(int i=0;i<`TX_BD_LEN;i++)
			this.CPU_MEM[m_cpu_start_addr+i] = m_que.pop_front();
	endfunction
	function void RXBD2Mem(s_bd_rx_data m_bd,int m_cpu_start_addr);
		bit8_que_t m_que;
		m_que = bit8_que_t'(m_bd);
		for(int i=0;i<`RX_BD_LEN;i++)
			this.CPU_MEM[m_cpu_start_addr+i] = m_que.pop_front();
	endfunction

    function void TXBUF2Mem(bit8_que_t m_dtq,int m_cpu_start_addr);
		for(int m=0;(m<`TX_BUFFER_MAX_LEN)&&(m_dtq.size() > 0);m++) begin
			this.CPU_MEM[m_cpu_start_addr+m] = m_dtq.pop_front();
		end
	endfunction

	function bit8_que_t Mem2RXBUF(int m_cpu_start_addr,int len);
		bit8_que_t m_que;
		for(int m=0;m<len;m++) begin
			m_que.push_back(this.CPU_MEM[m_cpu_start_addr+m]);
		end
		return m_que;
	endfunction

	/*}}}*/
endclass

//############################################################################
//sdma_tx_data_seq
//############################################################################
class sdma_tx_data_seq extends bd_base_seq;

	//########################################################################
    local longint       bd_ring_id			= 0;
	local RegOp         regcfg	            = null;
	local uvm_reg_field fpga_chn_ena_reg	= null;
	local uvm_reg_field fpga_bd_base_reg	= null;
	local longint		cpu_bd_start_addr	= 32'h1000_0000;
    local longint		cpu_buf_start_addr	= 32'h2000_0000;
	local string		bd_chn_name			= $sformatf("SDMA_TX_%0d",bd_ring_id);
	local bit           debug_display       = 1;
	//########################################################################
	s_bd_tx_data m_bd_info[$];
	bit8_que_t   m_buffer[$];
	bit          m_get_pcie_msi;
	bit          m_bdlink_ena = 0;
	//########################################################################
	semaphore    cfg_atomic;
	
	`SET_TTYPE(sdma_tx_data_seq)
	`uvm_object_utils_begin(sdma_tx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(sdma_vsequencer)

	function new(string name = "sdma_tx_data_seq");
		super.new(name);
		cfg_atomic = new(1);
	endfunction: new

	virtual task body();
	    /*{{{*/
	    fork
			begin
				if(this.m_bdlink_ena == 0) begin
					`uvm_info(bd_chn_name,"Waiting BD-Link enable..........",UVM_LOW)
					wait(this.m_bdlink_ena == 1);
				end
				if(m_bd_info.size() == 0) begin 
					`uvm_info(bd_chn_name,"Waiting BD Info FIFO to get data..........",UVM_LOW)
					wait(m_bd_info.size() > 0);
				end
				//###################################################################
				//BD data
				//###################################################################
				begin
					s_bd_tx_data m_bd;
					longint	m_cpu_bd_addr;
					bit8_que_t m_buf_q_merge;
					m_cpu_bd_addr = this.cpu_bd_start_addr;
					while(m_cpu_bd_addr != 0) begin
						m_bd = this.Mem2TXBD(m_cpu_bd_addr);
						if(m_bd.cs_field.o == 1) begin //CPU owner bit
							`uvm_info(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is FPGA then wait for PCIE-MSI!",
							                                 m_cpu_bd_addr),UVM_LOW)
							m_get_pcie_msi = 0;
						end
						else begin
							`uvm_info(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is CPU then CPU start senting BD...",
							                                 m_cpu_bd_addr),UVM_LOW)
							m_get_pcie_msi = 1;
						end
						if(m_get_pcie_msi == 1) begin
							bd_pkt m_bd_pkt;/*{{{*/
							bit8_que_t m_buf_q;
                            string m_bd_idx_str;
							s_bd_tx_data m_bd;
							`uvm_info(bd_chn_name,$sformatf("[Update BD-POINT:0x%0h]..........",m_cpu_bd_addr),UVM_MEDIUM)
							m_bd = m_bd_info.pop_front();
							this.TXBD2Mem(m_bd,m_cpu_bd_addr);
                            if({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b11) begin
                                m_bd_idx_str = "<first&last>";
                            end
                            else if({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b10) begin
                                m_bd_idx_str = "<first>";
                            end
                            else if({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b00) begin
                                m_bd_idx_str = "<middle>";
                            end
                            else if({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b01) begin
                                m_bd_idx_str = "<last>";
                            end
							//######################################################################
							//Display
							atomic.get(1);
							if(debug_display == 1) begin
								`uvm_info(bd_chn_name,$sformatf("BD(%0s) struct is:\n%0s",m_bd_idx_str,`SSTRUCT(m_bd)),UVM_LOW)
								this.tx_memhexdump($sformatf("BD-HEXDUMP(%0s)",m_bd_idx_str),m_cpu_bd_addr,`TX_BD_LEN);
							end
							m_buf_q = m_buffer.pop_front();
                            m_buf_q_merge = {m_buf_q_merge,m_buf_q};
							//######################################################################
                            this.TXBUF2Mem(m_buf_q,m_bd.bp_field.buffer_ptr);
							if(debug_display == 1) begin
								this.tx_memhexdump($sformatf("BDBUF-HEXDUMP(%0s)",m_bd_idx_str),m_bd.bp_field.buffer_ptr,m_buf_q.size());
							end
							//######################################################################
                            if(({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b11) || ({m_bd.cs_field.f,m_bd.cs_field.l} == 2'b01)) begin
							    m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
							    m_bd_pkt.bd_id = this.bd_chn_name;
							    m_bd_pkt.bd_data = m_buf_q_merge;
							    p_sequencer.tx_bd_aport.write(m_bd_pkt);
							    if(debug_display == 1) begin
							        `uvm_info(bd_chn_name,$sformatf("BD-BUF-MERGE pkt is:\n%0s",m_bd_pkt.sprint()),UVM_LOW)
                                    hexdump(null,m_buf_q_merge,"BD-BUF-MERGE");
                                end
                                m_buf_q_merge.delete();
							end
							//######################################################################
						
							atomic.put(1);
							//######################################################################
							m_cpu_bd_addr = m_bd.np_field.nextbd_ptr;
							//######################################################################
							/*}}}*/
						end
						else begin
							`uvm_error(bd_chn_name,"Wait for PCIE Interrupt for Recycling BD in the middle BDLink!")
						end
					end
					if(m_cpu_bd_addr == 0) begin
						`uvm_info(bd_chn_name,"Reaching BD-Link tail(NULL) then waiting CPU restart BDLink to send Packet!",UVM_LOW)
						`uvm_info(bd_chn_name,"Wait for Recycling BD..........",UVM_LOW)
				        `GET_TRIGGER($sformatf("TXBD-RECYLE-%0d",bd_ring_id))
						this.m_bdlink_ena = 0;
					end
				end
			end
			//######################################################################
			begin
                 TriggerData m_tdt;
                 uvm_object  m_obj;
				`GET_TRIGGER_DATA(m_obj,$sformatf("TXEND-TXERROR-TXBUF-%0d",bd_ring_id))
                $cast(m_tdt,m_obj);
                if(m_tdt.m_bits[1] == 1) 
					`uvm_error(bd_chn_name,$sformatf("TXEND-TXERROR-TXBUF:%3b",m_tdt.m_bits[2:0]))
                if(m_tdt.m_bits[2] == 1) 
				    `SET_TRIGGER($sformatf("TXBD-RECYLE-%0d",bd_ring_id))
                else
					`uvm_error(bd_chn_name,$sformatf("TXEND-TXERROR-TXBUF:%3b",m_tdt.m_bits[2:0]))
			end
			//######################################################################
		join_none
		/*}}}*/
	endtask

    virtual function this_type genTXBD( 
	                               longint       bd_ring_id        ,
								   uvm_reg_field fpga_chn_ena_reg  ,
	                   			   uvm_reg_field fpga_bd_base_reg  ,
								   RegOp         regcfg            ,
	                               bit           debug_display     = 0,
					   			   longint       cpu_bd_start_addr = 32'h1000_0000,  
                       			   longint		 cpu_buf_start_addr= 32'h2000_0000
								 );
  		/*{{{*/ 
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_ena_reg   = fpga_chn_ena_reg;
      	this.fpga_bd_base_reg   = fpga_bd_base_reg; 
      	this.regcfg             = regcfg; 
      	this.cpu_bd_start_addr  = cpu_bd_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
		this.bd_chn_name        = $sformatf("SDMA_TX_%0d",bd_ring_id);
		this.debug_display      = debug_display;
		if(this.fpga_chn_ena_reg == null || this.fpga_bd_base_reg == null)
			`uvm_fatal(bd_chn_name,$sformatf("You must set fpga_chn_ena_reg  and fpga_bd_base_reg valid first!"))
		return this;
		/*}}}*/
    endfunction

	virtual task enableBDLink();
		uvm_status_e m_status;/*{{{*/
		wait(this.m_bdlink_ena == 0);
		`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN BD BASE Register %0s to 0x%0h.",
		                                 fpga_bd_base_reg.get_full_name(),cpu_bd_start_addr),UVM_LOW)
		fpga_bd_base_reg.write(m_status,cpu_bd_start_addr);
		`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN ENA Register %0s to 1.",fpga_chn_ena_reg.get_full_name()),UVM_LOW)
		fpga_chn_ena_reg.write(m_status,1'd1); 
		this.m_bdlink_ena = 1;
		/*}}}*/
	endtask

	virtual task startPkt (
		                    input uvm_sequencer_base seqr, 
							input int m_pkt_num  = 1,//bd num
						  	input data_gen_enum m_data_gen = FIXED,
						  	input int m_data_len_min = 100,
						  	input int m_data_len_max = 100,
						  	input int m_start_dvalue = 0,
						  	input bit8_qq_t m_dqq    = '{'{}},
                            input int unsigned m_slice = `TX_BUFFER_MAX_LEN,
							input uvm_sequence_base parent=null
						  );
          /*{{{*/
		bit [7:0] dtq[$];
		bit8_que_t mm_buffer[$];
		int len;
		int m_sz;
		int mm_sz;
        bit[1:0] m_fl_q[$];
		bit8_qq_t mm_buffer_slice_qq;
		cfg_atomic.get(1);
		wait(this.m_bd_info.size() == 0);
		if((m_data_len_min <= 0) || (m_data_len_max <= 0))
			`uvm_fatal("PKT_LEN","You set len <= zero!!!")
		else if((m_data_len_min >= `TX_BUFFER_MAX_LEN) || (m_data_len_max >= `TX_BUFFER_MAX_LEN))
			`uvm_fatal("PKT_LEN",$sformatf("You set len >= `TX_BUFFER_MAX_LEN(%0d)!!!",`TX_BUFFER_MAX_LEN))
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
				if(m_dqq[i].size() == 0)
					`uvm_fatal("PKT_LEN",$sformatf("You set len == zero:%p",m_dqq))
				else if(m_dqq[i].size() >= `TX_BUFFER_MAX_LEN)
					`uvm_fatal("PKT_LEN",$sformatf("You set len[%0d] >= `TX_BUFFER_MAX_LEN(%0d),%p",
					                                 m_dqq[i].size(),`TX_BUFFER_MAX_LEN,m_dqq))
				mm_buffer.push_back(m_dqq[i]);
			end
		end
		//###################################################
        mm_buffer_slice_qq = QQSlice(mm_buffer,m_slice,m_fl_q);
		//###################################################
		m_sz = mm_buffer_slice_qq.size();
		for(int i=0;i<m_sz;i++)
			this.m_buffer.push_back(mm_buffer_slice_qq[i]); 
		for(int i=0;i<m_sz;i++) begin
			s_bd_tx_data m_bd;
			mm_sz = mm_buffer_slice_qq[i].size();
			m_bd.cs_field.o  = 1;
			{m_bd.cs_field.f,m_bd.cs_field.l}  = m_fl_q.pop_front();
			m_bd.bc_field.pkt_byte_cnt = mm_sz;
			m_bd.bp_field.buffer_ptr = this.cpu_buf_start_addr + `TX_BUFFER_MAX_LEN*i/*pkt_max_len*i*/;
			if(i == m_sz-1) begin
				m_bd.cs_field.ei = 1;
				m_bd.np_field.nextbd_ptr = '0;
				//m_bd.np_field.nextbd_ptr = this.cpu_buf_start_addr;//BD-Ring-Mode
			end
			else
				m_bd.np_field.nextbd_ptr = this.cpu_bd_start_addr + `TX_BD_LEN*(i+1)/*bd_size*i*/;
			this.m_bd_info.push_back(m_bd);
		end
		//###################################################
		this.start(seqr,parent);
		cfg_atomic.put(1);
		/*}}}*/
	endtask:startPkt
	//##################################################################################################
	virtual task setCPUPkt (
		                    input uvm_sequencer_base seqr, 
						  	input bit8_qq_t m_dqq,
                            input int unsigned m_slice = `TX_BUFFER_MAX_LEN
						   );
		this.startPkt(seqr,m_dqq.size(),USR,1,1,0,m_dqq,m_slice);
	endtask:setCPUPkt
	//##################################################################################################
    virtual task setAUPkt (
		                    input uvm_sequencer_base seqr, 
						  	input S_ADDRUPDATEMSG_T m_au_msg,
                            input int unsigned m_slice = `TX_BUFFER_MAX_LEN
						   );
        bit32_que_t m_dq;
        m_dq = bit32_que_t'(m_au_msg);
	endtask:setAUPkt
	//##################################################################################################

endclass


//############################################################################
//sdma_rx_data_seq
//############################################################################
class sdma_rx_data_seq extends bd_base_seq;

	//########################################################################
    local longint		bd_ring_id        = 0;
	local RegOp         regcfg   	      = null;
	local uvm_reg_field fpga_chn_ena_reg  = null;
	local uvm_reg_field fpga_bd_base_reg  = null;
	local longint		cpu_bd_start_addr = 32'h1000_0000;
    local longint 		cpu_buf_start_addr= 32'h2000_0000;
	local string  		bd_chn_name       = $sformatf("SDMA_RX_%0d",bd_ring_id);
	local bit           debug_display     = 1;
	//########################################################################
	s_bd_rx_data m_bd_info[$];
	semaphore    cfg_atomic;
	bit          m_bdlink_ena = 0;
	bit          m_get_pcie_msi;
	//########################################################################
	
	`SET_TTYPE(sdma_rx_data_seq)
	`uvm_object_utils_begin(sdma_rx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(sdma_vsequencer)/*}}}*/

	function new(string name = "sdma_rx_data_seq");
		super.new(name);
		cfg_atomic = new(1);
	endfunction: new

	virtual task body();
	    /*{{{*/
	    fork
			begin
				if(this.m_bdlink_ena == 0) begin
					`uvm_info(bd_chn_name,"Waiting BD-Link enable..........",UVM_LOW)
					wait(this.m_bdlink_ena == 1);
				end
				if(m_bd_info.size() == 0) begin 
					`uvm_info(bd_chn_name,"Waiting BD Info FIFO to get data..........",UVM_LOW)
					wait(m_bd_info.size() > 0);
				end
				//###################################################################
				//BD data
				//###################################################################
				begin
					s_bd_rx_data m_bd;
					longint	m_cpu_bd_addr;
					m_cpu_bd_addr = this.cpu_bd_start_addr;
					while(m_cpu_bd_addr != 0) begin
						m_bd = this.Mem2RXBD(m_cpu_bd_addr);
						if(m_bd.cs_field.o == 1) begin //CPU owner bit
							`uvm_info(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is FPGA then wait for PCIE-MSI!",
							                                 m_cpu_bd_addr),UVM_LOW)
							m_get_pcie_msi = 0;
						end
						else begin
							`uvm_info(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is CPU then CPU start senting BD...",
							                                 m_cpu_bd_addr),UVM_LOW)
							m_get_pcie_msi = 1;
						end
						if(m_get_pcie_msi == 1) begin
							bd_pkt m_bd_pkt;/*{{{*/
							s_bd_rx_data m_bd;
							`uvm_info(bd_chn_name,$sformatf("[Update BD-POINT:0x%0h]..........",m_cpu_bd_addr),UVM_MEDIUM)
							m_bd = m_bd_info.pop_front();
							this.RXBD2Mem(m_bd,m_cpu_bd_addr);
							//######################################################################
							//Display
							if(debug_display == 1) begin
								`uvm_info(bd_chn_name,$sformatf("BD struct is:\n%0s",`SSTRUCT(m_bd)),UVM_LOW)
								this.rx_memhexdump("BD-HEXDUMP",m_cpu_bd_addr,`RX_BD_LEN);
							end
							//######################################################################
							m_cpu_bd_addr = m_bd.np_field.nextbd_ptr;
							//######################################################################
							/*}}}*/
						end
						else begin
							`uvm_error(bd_chn_name,"Wait for PCIE Interrupt for Recycling BD in the middle BDLink!")
						end
					end
					if(m_cpu_bd_addr == 0) begin
						`uvm_info(bd_chn_name,"Reaching BD-Link tail(NULL) then waiting CPU restart BDLink to receive Packet!",UVM_LOW)
						`uvm_info(bd_chn_name,"Wait for Recycling BD..........",UVM_LOW)
				        `GET_TRIGGER($sformatf("RXBD-RECYLE-%0d",bd_ring_id))
						//#######################################################################################
						//Get Buffer data which BD point to
						//#######################################################################################
						begin
							s_bd_rx_data m_bd;
							longint	m_cpu_bd_addr;
							int m_total_pkt_len;
							int m_sum_buffer_len;
							s_bd_rx_data m_bd_q[$];
							m_cpu_bd_addr = this.cpu_bd_start_addr;
							while(m_cpu_bd_addr != 0) begin
								m_bd = this.Mem2RXBD(m_cpu_bd_addr);
								if(m_bd.cs_field.o == 0) begin //CPU owner bit
									`uvm_info(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is CPU then buffer [Buffer-POINT:0x%0h] data.",
									                                 m_cpu_bd_addr,{m_bd.bp_field.buffer_ptr,m_bd.bp_field.reserved}),UVM_LOW)
									m_bd_q.push_back(m_bd);
									if(m_bd.cs_field.f == 1) begin
										if(m_bd.cs_field.bus_error == 1)
											`uvm_error(bd_chn_name,$sformatf("[BD-POINT:0x%0h] BD bus_error == 1:\n%0s",m_cpu_bd_addr,`SSTRUCT(m_bd)))
										if(m_bd.cs_field.rsrcerror == 1)
											`uvm_error(bd_chn_name,$sformatf("[BD-POINT:0x%0h] BD rsrcerror == 1:\n%0s",m_cpu_bd_addr,`SSTRUCT(m_bd)))
										if(m_bd.bc_field.invld_crc == 1)
											`uvm_error(bd_chn_name,$sformatf("[BD-POINT:0x%0h] BD invld_crc == 1:\n%0s",m_cpu_bd_addr,`SSTRUCT(m_bd)))
									end
									if(m_bd.cs_field.l == 1) begin
										//####################################################################################################
										//Check cs_field first and last flag
										//####################################################################################################
										if(m_bd_q.size() == 1) begin
											if({m_bd_q[0].cs_field.f,m_bd_q[0].cs_field.l} !== 2'b11)
												`uvm_error(bd_chn_name,$sformatf("BD is wrong for cs_field >> f and l:\n%0s",`SSTRUCT(m_bd_q[0])))
										end
										else begin
											int m_bd_sz;
											bit m_wrong_bd;
											m_bd_sz = m_bd_q.size();
											for(int i=0;i<m_bd_sz;i++) begin
												if(i == 0) begin/*{{{*/
													if({m_bd_q[i].cs_field.f,m_bd_q[i].cs_field.l} !== 2'b10) begin
														m_wrong_bd = 1;
														break;
													end
												end
												else if( i == m_bd_sz-1) begin
													if({m_bd_q[i].cs_field.f,m_bd_q[i].cs_field.l} !== 2'b01) begin
														m_wrong_bd = 1;
														break;
													end
												end
												else begin
													if({m_bd_q[i].cs_field.f,m_bd_q[i].cs_field.l} !== 2'b00) begin
														m_wrong_bd = 1;
														break;
													end
												end /*}}}*/
											end
											if(m_wrong_bd == 1) begin
												for(int i=0;i<m_bd_q.size();i++)
													`uvm_error(bd_chn_name,$sformatf("BD[%0d] is wrong for cs_field >> f and l:\n %0s.",
													                                  i,`SSTRUCT(m_bd_q[i])))
											end
										end
										//####################################################################################################
										m_total_pkt_len = (m_bd_q[0].bc_field.pkt_byte_cnt == 0) ? 2**14 : m_bd_q[0].bc_field.pkt_byte_cnt;
										foreach(m_bd_q[i])
											m_sum_buffer_len += (m_bd_q[i].bc_field.buffer_size == 0)?`RX_BUFFER_MAX_LEN:m_bd_q[i].bc_field.buffer_size;
										if(m_total_pkt_len > m_sum_buffer_len) begin
											`uvm_error(bd_chn_name,$sformatf("m_total_pkt_len[%0d] > m_sum_buffer_len[%0d].",
											                                  m_total_pkt_len,m_sum_buffer_len))
											for(int i=0;i<m_bd_q.size();i++)
												`uvm_error(bd_chn_name,$sformatf("BD[%0d] is:\n %0s.",i,`SSTRUCT(m_bd_q[i])))
										end
										else begin
											//####################################################################################################
											bd_pkt m_bd_pkt;
											int m_bd_q_sz;
											bit8_que_t m_buf_q;
											bit8_qq_t m_buf_qq;
											atomic.get(1);
											m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
											m_bd_pkt.bd_id = this.bd_chn_name;
											m_bd_q_sz = m_bd_q.size();
											for(int i=0;i<m_bd_q_sz;i++) begin
												int m_bf_sz = (m_bd_q[i].bc_field.buffer_size == 0) ? `RX_BUFFER_MAX_LEN : m_bd_q[i].bc_field.buffer_size;
												if(i == m_bd_q_sz-1) begin
													m_bf_sz = m_total_pkt_len%m_bf_sz;
													if(m_bf_sz == 0)
														m_bf_sz = `RX_BUFFER_MAX_LEN;
												end
												m_buf_qq.push_back(this.Mem2RXBUF({m_bd_q[i].bp_field.buffer_ptr,m_bd_q[i].bp_field.reserved},m_bf_sz));
											end
											for(int i=0;i<m_bd_q_sz;i++)
												m_buf_q = {m_buf_q,m_buf_qq[i]};
											m_bd_pkt.bd_data = m_buf_q;
											p_sequencer.rx_bd_aport.write(m_bd_pkt);
											if(debug_display == 1) begin
												`uvm_info(bd_chn_name,$sformatf("BD-BUF pkt is:\n%0s",m_bd_pkt.sprint()),UVM_LOW)
											end
											atomic.put(1);
											//####################################################################################################
										end
										m_bd_q.delete();
									end
									//######################################################################
									//Display
									if(debug_display == 1) begin
										`uvm_info(bd_chn_name,$sformatf("BD struct is:\n%0s",`SSTRUCT(m_bd)),UVM_LOW)
										this.rx_memhexdump("BD-HEXDUMP",m_cpu_bd_addr,`RX_BD_LEN);
									end
									//######################################################################
									m_cpu_bd_addr = m_bd.np_field.nextbd_ptr;
									//######################################################################
								end
								else begin
									`uvm_error(bd_chn_name,$sformatf("[BD-POINT:0x%0h] owner is FPGA but Get Interrupt to Recycling BD!",m_cpu_bd_addr))
								end
							end
						end
						//#######################################################################################
						this.m_bdlink_ena = 0;
					end
				end
			end
			//######################################################################
			begin
                 TriggerData m_tdt;
                 uvm_object  m_obj;
				`GET_TRIGGER_DATA(m_obj,$sformatf("RXERROR-RXBUF-%0d",bd_ring_id))
                $cast(m_tdt,m_obj);
                if(m_tdt.m_bits[1] == 1) begin
					`uvm_error(bd_chn_name,$sformatf("RXERROR-RXBUF:%2b",m_tdt.m_bits[1:0]))
                end
                else if(m_tdt.m_bits[0] == 1) begin
				    `SET_TRIGGER($sformatf("RXBD-RECYLE-%0d",bd_ring_id))
                end
					`uvm_error(bd_chn_name,$sformatf("RXERROR-RXBUF:%2b",m_tdt.m_bits[1:0]))

			end
			//######################################################################
		join_none
		/*}}}*/
	endtask

	virtual function this_type genRXBD( 
	                               longint       bd_ring_id        ,
								   uvm_reg_field fpga_chn_ena_reg  ,
	                   			   uvm_reg_field fpga_bd_base_reg  ,
								   RegOp         regcfg            ,
	                               bit           debug_display     = 0,
					   			   longint       cpu_bd_start_addr = 32'h1000_0000,  
                       			   longint		 cpu_buf_start_addr= 32'h2000_0000
								 );
  		/*{{{*/
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_ena_reg   = fpga_chn_ena_reg;
      	this.fpga_bd_base_reg   = fpga_bd_base_reg; 
      	this.regcfg				= regcfg; 
      	this.cpu_bd_start_addr  = cpu_bd_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
		this.bd_chn_name        = $sformatf("SDMA_RX_%0d",bd_ring_id);
		this.debug_display      = debug_display;
		if(this.fpga_chn_ena_reg == null || this.fpga_bd_base_reg == null)
			`uvm_fatal(bd_chn_name,$sformatf("You must set fpga_chn_ena_reg  and fpga_bd_base_reg valid first!"))
		return this;
		/*}}}*/
    endfunction

	virtual task enableBDLink();
		uvm_status_e m_status;/*{{{*/
		wait(this.m_bdlink_ena == 0);
		`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN BD BASE Register %0s to 0x%0h.",
		                                 fpga_bd_base_reg.get_full_name(),cpu_bd_start_addr),UVM_LOW)
		fpga_bd_base_reg.write(m_status,cpu_bd_start_addr);
		`uvm_info(bd_chn_name,$sformatf("Writing FPGA CHN ENA Register %0s to 1.",fpga_chn_ena_reg.get_full_name()),UVM_LOW)
		fpga_chn_ena_reg.write(m_status,1'd1);
		this.m_bdlink_ena = 1;
		/*}}}*/
	endtask

	virtual task startPkt (
		                    input uvm_sequencer_base seqr, 
							input int m_pkt_num   = 1,//bd num
							input bit [10:0] m_buffer_size = 0,//buffer size 128~2047,0:2048
							input uvm_sequence_base parent=null
						  );
          /*{{{*/
		//###################################################
		cfg_atomic.get(1);
		wait(this.m_bd_info.size() == 0);
		for(int i=0;i<m_pkt_num;i++) begin
			s_bd_rx_data m_bd;
			m_bd.cs_field.o  = 1;
			m_bd.cs_field.f  = 0;
			m_bd.cs_field.l = 0;
			if(!(m_buffer_size inside {[128:2047],0}))
				`uvm_error("BUFFER_LEN",$sformatf("You set Buffer length[%0d] not in {[128:2047],0->2048}",m_buffer_size))
			m_bd.bc_field.buffer_size = m_buffer_size;
			{m_bd.bp_field.buffer_ptr,m_bd.bp_field.reserved} = this.cpu_buf_start_addr + `RX_BUFFER_MAX_LEN*i/*pkt_max_len*i*/;
			if(i == m_pkt_num-1) begin
				m_bd.cs_field.ei = 1;
				m_bd.np_field.nextbd_ptr = '0;
				//m_bd.np_field.nextbd_ptr = this.cpu_buf_start_addr;//BD-Ring-Mode
			end
			else
				m_bd.np_field.nextbd_ptr = this.cpu_bd_start_addr + `RX_BD_LEN*(i+1)/*bd_size*i*/;
			this.m_bd_info.push_back(m_bd);
		end
		//###################################################
		this.start(seqr,parent);
		cfg_atomic.put(1);
		//###################################################
		/*}}}*/
	endtask:startPkt

endclass

`endif 

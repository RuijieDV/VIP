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

	bit		   owner     ; //1'b1:FPGA 1'b0:CPU
	bit [18:0] rev       ; 
	bit [11:0] data_len  ; 

} s_bd_tx_data;

typedef struct packed {

	bit		   owner     ; //1'b1:FPGA 1'b0:CPU
	bit [18:0] rev       ; 
	bit [11:0] data_len  ; 

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
	
    virtual task PCIE_REG_RD(input bit [`ADDR_WIDTH-1:0] addr,output bit [`ADDR_WIDTH-1:0] data);	
        bit [7:0] rdata[];
		m_pcie_reg_seq = `CREATE_OBJ(`PCIE_REG_SEQ,"m_pcie_reg_seq")
		m_pcie_reg_seq.s_m_read_with_data(addr,rdata,m_pcie_reg_seqr);
        for(int i=0;i<`ADDR_WIDTH/8;i++)
			data[`ADDR_WIDTH-1-8*i -:8] = rdata[i];
		`uvm_info("PCIE_REG_RD",$sformatf("@ADDR[0x%0h] -> DATA[0x%0h]",addr,data),UVM_MEDIUM); 
	endtask

	virtual task PCIE_REG_WR(input bit [`ADDR_WIDTH-1:0] addr,input bit [`ADDR_WIDTH-1:0] data);	
		m_pcie_reg_seq = `CREATE_OBJ(`PCIE_REG_SEQ,"m_pcie_reg_seq")
		m_pcie_reg_seq.s_m_write(addr,data,m_pcie_reg_seqr);
		`uvm_info("PCIE_REG_WR",$sformatf("@ADDR[0x%0h] -> DATA[0x%0h]",addr,data),UVM_MEDIUM); 
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
    local longint bd_ring_id         = 0;
	local longint fpga_chn_sta_addr  = 32'h5004;
	local longint fpga_buf_start_addr= 32'h5008;
    local longint cpu_buf_start_addr = 32'h2000_0000;
	local string  bd_chn_name        = $sformatf("TX_BD_%0d",bd_ring_id);
    local int     bd_ring_strategy   = 1;   
	//########################################################################
	s_bd_tx_data m_bd_info[$];
	bit8_que_t   m_buffer[$];
	//########################################################################
	semaphore    cfg_atomic;
	
	`uvm_object_utils_begin(bd_tx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "bd_tx_data_seq");
		super.new(name);
		cfg_atomic = new(1);
	endfunction: new

	virtual task body();
        if(bd_ring_strategy == 0)
            this.interupt_task();
        else
            this.polling_task();
    endtask

    virtual task interupt_task();
	    /*{{{*/
        fork
            begin
                int m_bd_sz;
                m_bd_sz = m_bd_info.size();
			    for(int i=0;i<m_bd_sz;i++) begin 
                    begin:WR_BD_PKT_TO_SCOREBOARD
                        bd_pkt m_bd_pkt;
                        bit8_que_t m_buf_q;
                        s_bd_tx_data st_tx_bd;
                        st_tx_bd = m_bd_info.pop_front();
                        PCIE_REG_WR(fpga_buf_start_addr,cpu_buf_start_addr);
                        PCIE_REG_WR(fpga_chn_sta_addr,st_tx_bd);
                        m_buf_q = m_buffer.pop_front();
					    atomic.get(1);
                        m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
						m_bd_pkt.bd_id = this.bd_chn_name;
						m_bd_pkt.bd_data = m_buf_q;
						p_sequencer.tx_bd_aport.write(m_bd_pkt);
                        for(int m=0;m<`BUFFER_MAX_LEN;m++) begin
                            if(m_buf_q.size() > 0)
                                this.CPU_MEM[cpu_buf_start_addr+m] = m_buf_q.pop_front();
						end
						atomic.put(1);
                    end
                    `GET_TRIGGER("DMA_TX_INT")
                    begin
                        s_bd_tx_data m_tx_bd;
                        bit [31:0] rdata;
                        PCIE_REG_RD(fpga_chn_sta_addr,rdata);
                        m_tx_bd = s_bd_tx_data'(rdata);
                        if(m_tx_bd.owner == 1'b1/*FPGA NOT RELEASE*/);
                            `uvm_error(bd_chn_name,$sformatf("When get interupt,but BD onwer != 0."))
                    end
			    end
            end
		join
		/*}}}*/
	endtask
	virtual task polling_task();
	    /*{{{*/
        fork
            begin
                int m_bd_sz;
                m_bd_sz = m_bd_info.size();
			    for(int i=0;i<m_bd_sz;i++) begin 
                    s_bd_tx_data m_tx_bd;
                    do begin
                        bit [31:0] rdata;
                        #100ns;
                        PCIE_REG_RD(fpga_chn_sta_addr,rdata);
                        m_tx_bd = s_bd_tx_data'(rdata);
                    end while(m_tx_bd.owner == 1'b1/*FPGA NOT RELEASE*/);
                    begin:WR_BD_PKT_TO_SCOREBOARD
                        bd_pkt m_bd_pkt;
                        bit8_que_t m_buf_q;
                        s_bd_tx_data st_tx_bd;
                        st_tx_bd = m_bd_info.pop_front();
                        PCIE_REG_WR(fpga_buf_start_addr,cpu_buf_start_addr);
                        PCIE_REG_WR(fpga_chn_sta_addr,st_tx_bd);
                        m_buf_q = m_buffer.pop_front();
					    atomic.get(1);
                        m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
						m_bd_pkt.bd_id = this.bd_chn_name;
						m_bd_pkt.bd_data = m_buf_q;
						p_sequencer.tx_bd_aport.write(m_bd_pkt);
                        for(int m=0;m<`BUFFER_MAX_LEN;m++) begin
                            if(m_buf_q.size() > 0)
                                this.CPU_MEM[cpu_buf_start_addr+m] = m_buf_q.pop_front();
						end
						atomic.put(1);
                    end
			    end
            end
		join
		/*}}}*/
	endtask

    virtual function void genTXBD( 
								   `PCIE_REG_SEQR pcie_reg_seqr,
	                               longint bd_ring_id           = 0,
	                   			   longint fpga_chn_sta_addr    = 32'h5004,
	                   			   longint fpga_buf_start_addr  = 32'h5008,
                       			   longint cpu_buf_start_addr   = 32'h2000_0000,
                                   int     bd_ring_strategy     = 1
								 );
 		/*{{{*/
		this.m_pcie_reg_seqr    = pcie_reg_seqr;
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_sta_addr  = fpga_chn_sta_addr; 
      	this.fpga_buf_start_addr= fpga_buf_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
		this.bd_chn_name        = $sformatf("TX_BD_%0d",bd_ring_id);
        this.bd_ring_strategy   = bd_ring_strategy;
		/*}}}*/
    endfunction

	//##################################################################################################
	virtual task startPkt (
		                    input uvm_sequencer_base seqr, 
							input int m_pkt_num = 1,//bd num
						  	input data_gen_enum m_data_gen = FIXED,
						  	input int m_data_len_min = 100,
						  	input int m_data_len_max = 100,
						  	input int m_start_dvalue = 0,
						  	input bit [7:0] m_data[] = '{default:0},
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
			m_bd.owner     = 1'b1; 
			m_bd.data_len  = mm_sz; 
			this.m_bd_info.push_back(m_bd);
		end
		//###################################################
		this.start(seqr,parent);
		cfg_atomic.put(1);
		/*}}}*/
	endtask:startPkt
 
	//##################################################################################################
     function automatic bit8_que_t genWriteBuffer(int num_pkt = 1,bit [7:0] len = 4,bit [7:0] data_fix,bit mrand = 0);
        bit8_que_t dq;
        if(num_pkt*len > 200*2)
            `uvm_error("genWriteBuffer",$sformatf("num_pkt*len(%0d) > 200",num_pkt*len))
        else if(len < 4)
            `uvm_error("genWriteBuffer",$sformatf("Readbuffer len < 4!"))
        for(int i=0;i<num_pkt;i++)begin
            int mlen = len - 4;
            dq.push_back(8'h00);
            dq.push_back(8'hAA);
            dq.push_back(len);
            dq.push_back(8'b10);
            for(int j=0;j<mlen;j++) begin
                dq.push_back(mrand ? $urandom() : data_fix);
            end
        end
        return dq;

    endfunction
    //##################################################################################################
    function automatic bit8_que_t genErrorWriteBuffer(int num_pkt = 1,int len = 4,bit [7:0] data_fix,bit mrand = 0);
        bit8_que_t dq;
        for(int i=0;i<num_pkt;i++)begin
            for(int j=0;j<len;j++) begin
                dq.push_back(mrand ? $urandom() : data_fix);
            end
        end
        return dq;
    endfunction
    //##################################################################################################

endclass


//############################################################################
//bd_rx_data_seq
//############################################################################
class bd_rx_data_seq extends bd_base_seq;

	//########################################################################
    local longint bd_ring_id         = 0;
	local longint fpga_chn_sta_addr  = 32'h6004;
	local longint fpga_buf_start_addr= 32'h6008;
    local longint cpu_buf_start_addr = 32'h8000_0000;
	local string  bd_chn_name        = $sformatf("RX_BD_%0d",bd_ring_id);
    local int     bd_ring_strategy   = 1;   
    local int unsigned  pkt_num      = '1;
	//########################################################################
	
	`uvm_object_utils_begin(bd_rx_data_seq)
	`uvm_object_utils_end     
	`uvm_declare_p_sequencer(bd_vsequencer)

	function new(string name = "bd_rx_data_seq");
		super.new(name);
	endfunction: new

	virtual task body();
        if(bd_ring_strategy == 0)
            this.interupt_task();
        else
            this.polling_task();
    endtask

    virtual task interupt_task();
	    /*{{{*/
        begin
            forever begin
                s_bd_rx_data m_rx_bd;
                begin:WR_BD_MSG
                    s_bd_rx_data st_rx_bd;
                    st_rx_bd.owner = 1;
                    PCIE_REG_WR(fpga_buf_start_addr,cpu_buf_start_addr);
                    PCIE_REG_WR(fpga_chn_sta_addr,st_rx_bd);
                end
                `GET_TRIGGER("DMA_RX_INT")
                begin
                    s_bd_rx_data m_rx_bd;
                    bit [31:0] rdata;
                    PCIE_REG_RD(fpga_chn_sta_addr,rdata);
                    m_rx_bd = s_bd_rx_data'(rdata);
                    if(m_rx_bd.owner == 1'b1/*FPGA NOT RELEASE*/);
                        `uvm_error(bd_chn_name,$sformatf("When get interupt,but BD onwer != 0."))
                end
                begin:WR_BD_PKT_TO_SCOREBOARD
                    bd_pkt m_bd_pkt;
                    bit8_que_t m_buf_q;
                    atomic.get(1);
                    m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
                    m_bd_pkt.bd_id = this.bd_chn_name;
                    for(int m=0;m<m_rx_bd.data_len;m++) begin
                        m_buf_q.push_back(CPU_MEM[cpu_buf_start_addr+m]);
                    end
                    m_bd_pkt.bd_data = m_buf_q;
                    p_sequencer.rx_bd_aport.write(m_bd_pkt);
                    atomic.put(1);
                end
            end
        end
		/*}}}*/
	endtask

	virtual task polling_task();
	    /*{{{*/
        begin
            for(int i=0;i<pkt_num;i++) begin
                s_bd_rx_data m_rx_bd;
                begin:WR_BD_MSG
                    s_bd_rx_data st_rx_bd;
                    st_rx_bd.owner = 1;
                    PCIE_REG_WR(fpga_buf_start_addr,cpu_buf_start_addr);
                    PCIE_REG_WR(fpga_chn_sta_addr,st_rx_bd);
                end
                do begin
                    bit [31:0] rdata;
                    #100ns;
                    PCIE_REG_RD(fpga_chn_sta_addr,rdata);
                    m_rx_bd = s_bd_rx_data'(rdata);
                end while(m_rx_bd.owner == 1'b1/*FPGA NOT RELEASE*/);
                begin:WR_BD_PKT_TO_SCOREBOARD
                    bd_pkt m_bd_pkt;
                    bit8_que_t m_buf_q;
                    atomic.get(1);
                    m_bd_pkt = `CREATE_OBJ(bd_pkt,"m_bd_pkt")
                    m_bd_pkt.bd_id = this.bd_chn_name;
                    //$display("%s",`SSTRUCT(m_rx_bd));
                    for(int m=0;m<m_rx_bd.data_len;m++) begin
                        m_buf_q.push_back(CPU_MEM[cpu_buf_start_addr+m]);
                    end
                    m_bd_pkt.bd_data = m_buf_q;
                    p_sequencer.rx_bd_aport.write(m_bd_pkt);
                    atomic.put(1);
                end
            end
        end
		/*}}}*/
	endtask

    virtual function void genRXBD( 
								   `PCIE_REG_SEQR pcie_reg_seqr,
	                               longint bd_ring_id           = 0,
	                   			   longint fpga_chn_sta_addr    = 32'h6004,
	                   			   longint fpga_buf_start_addr  = 32'h6008,
                       			   longint cpu_buf_start_addr   = 32'h8000_0000,
                                   int     bd_ring_strategy     = 1
								 );
 		/*{{{*/
		this.m_pcie_reg_seqr    = pcie_reg_seqr;
		this.bd_ring_id         = bd_ring_id;       
      	this.fpga_chn_sta_addr  = fpga_chn_sta_addr; 
      	this.fpga_buf_start_addr= fpga_buf_start_addr; 
      	this.cpu_buf_start_addr = cpu_buf_start_addr;
		this.bd_chn_name        = $sformatf("RX_BD_%0d",bd_ring_id);
        this.bd_ring_strategy   = bd_ring_strategy;
		/*}}}*/
    endfunction

	virtual task startPkt (
		                 input uvm_sequencer_base seqr, 
						 input uvm_sequence_base parent=null
						);
        /*{{{*/
		this.start(seqr,parent);
		/*}}}*/
	endtask:startPkt

    virtual task startPktNum (
                         input int pkt_num = 1,
		                 input uvm_sequencer_base seqr, 
						 input uvm_sequence_base parent=null
						);
        /*{{{*/
        this.pkt_num = pkt_num;
		this.start(seqr,parent);
		/*}}}*/
	endtask:startPktNum

endclass


`endif 

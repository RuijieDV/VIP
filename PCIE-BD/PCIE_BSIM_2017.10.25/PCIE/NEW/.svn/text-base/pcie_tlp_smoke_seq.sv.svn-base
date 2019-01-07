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
//     FileName: pcie_tlp_smoke_seq.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-04-22 16:04:10
//      History:
//============================================================================*/
`ifndef PCIE_TLP_SMOKE_SEQ__SV
`define PCIE_TLP_SMOKE_SEQ__SV

class pcie_tlp_default_seq extends uvm_sequence#(pcie_tlp_pkt);

	`SET_CLASSID
	int        time_out = 1;
	pcie_tlp_enum m_pcie_tlp_type;
	bit m_is_mem_op,m_is_io_op,m_is_cfg_op,m_is_msg_op,m_is_cpl_op;
	bit [1:0]  m_fmt;
	bit [4:0]  m_typ;
	bit [2:0]  m_tc;
	bit        m_td;
	bit        m_ep;
	bit [7:0]  m_tag;
	bit [1:0]  m_attr;
	bit [9:0]  m_length;
	bit [15:0] m_req_id;
	bit [3:0]  m_first_dw_be;
	bit [3:0]  m_last_dw_be;
	bit [7:0]  m_bus_num;
	bit [4:0]  m_dev_num;
	bit [2:0]  m_fun_num;
	bit [31:0] m_addr32;
	bit [63:0] m_addr64;
	bit [7:0]  m_up_payload[];
	//##################################
	int        m_pkt_num;
	//##################################
	bit        m_cfg_length = 0;
	//##################################

	`uvm_object_utils(pcie_tlp_default_seq)
	`uvm_declare_p_sequencer(pcie_tlp_sequencer)

	function new(string name = "pcie_tlp_default_seq");
		super.new(name);
	endfunction: new

	virtual task body();
	    pcie_tlp_pkt pcie_req,pcie_rsp;
		for(int i=0;i<m_pkt_num;i++) begin
			pcie_req = `CREATE_OBJ(pcie_tlp_pkt,"pcie_req")
			pcie_rsp = `CREATE_OBJ(pcie_tlp_pkt,"pcie_rsp")
			start_item(pcie_req);
			pcie_req.up_payload = m_up_payload;
			assert(pcie_req.randomize() with { 
			                            pcie_tlp_type == m_pcie_tlp_type;
			                            is_mem_op     == m_is_mem_op    ;
			                            is_io_op      == m_is_io_op     ;
										is_cfg_op     == m_is_cfg_op    ;     
										is_msg_op     == m_is_msg_op    ;
										is_cpl_op     == m_is_cpl_op    ;
										fmt           == m_fmt          ;
										typ           == m_typ          ;
										tc            == m_tc           ;
										td            == m_td           ;
										ep            == m_ep           ;
										attr          == m_attr         ;
										tag           == m_tag          ;
										addr32        == m_addr32       ;
										addr64        == m_addr64       ;
										first_dw_be   == m_first_dw_be  ;
										last_dw_be    == m_last_dw_be   ;
										req_id        == m_req_id       ;
										bus_num       == m_bus_num      ;
										dev_num       == m_dev_num      ;
										fun_num       == m_fun_num      ;
										if(m_cfg_length == 1)
											length  == m_length;
									  });
			finish_item(pcie_req);
			get_response(pcie_rsp);
	    end
    endtask

	virtual function void setENUM(pcie_tlp_enum pcie_tlp_type);
	    this.m_pcie_tlp_type = pcie_tlp_type;
    endfunction

	virtual function void setOP(bit is_mem_op = 1,bit is_io_op = 0,bit is_cfg_op = 0,bit is_msg_op = 0,bit is_cpl_op = 0);
	    this.m_is_mem_op = is_mem_op;
		this.m_is_io_op  = is_io_op;
		this.m_is_cfg_op = is_cfg_op;
		this.m_is_msg_op = is_msg_op;
		this.m_is_cpl_op = is_cpl_op;
    endfunction

	virtual function void setFmt(bit [1:0] fmt);
	    this.m_fmt = fmt;
    endfunction

	virtual function void setType(bit [4:0] typ);
	    this.m_typ = typ;
    endfunction

	virtual function void setTC(bit [2:0] tc);
	    this.m_tc = tc;
    endfunction

	virtual function void setTD(bit td);
	    this.m_td = td;
    endfunction

	virtual function void setEP(bit ep);
	    this.m_ep = ep;
    endfunction

	virtual function void setTAG(bit [7:0] tag);
	    this.m_tag = tag;
    endfunction

	virtual function void setATTR(bit [1:0] attr);
	    this.m_attr = attr;
    endfunction

    virtual function void setADDR32(bit [31:0] addr32);
	    this.m_addr32 = addr32;
    endfunction

    virtual function void setADDR64(bit [63:0] addr64);
	    this.m_addr64 = addr64;
    endfunction

	virtual function void setLength(bit [9:0] length);
	    this.setCFG(1);
	    this.m_length = length;
    endfunction

	virtual function void setFirstDWBE(bit [3:0] first_dw_be);
		this.m_first_dw_be = first_dw_be;
	endfunction

	virtual function void setLastDWBE(bit [3:0] last_dw_be);
		this.m_last_dw_be = last_dw_be;
	endfunction

	virtual function void setREQID(bit [15:0] req_id);
		this.m_req_id = req_id;
	endfunction

	virtual function void setBDFnum(bit [7:0] bus_num,bit [4:0] dev_num,bit [2:0] fun_num);
	    this.m_bus_num = bus_num;
		this.m_dev_num = dev_num;
		this.m_fun_num = fun_num;
	endfunction

	virtual function void setCFG(bit m_cfg_length = 1);
		this.m_cfg_length = m_cfg_length;
	endfunction
    //############################################################################
    //############################################################################
	virtual function void setMRD_3DW_WITH_NODATA();
	    setENUM(MRD);
	    setOP(1);
	    setFmt(2'b00);
	    setType(5'b00000);
    endfunction

	virtual function void setMRD_4DW_WITH_NODATA();
	    setENUM(MRD);
	    setOP(1);
	    setFmt(2'b01);
	    setType(5'b00000);
	endfunction 

	virtual function void setMRDLK_3DW_WITH_NODATA();
	    setENUM(MRDLK);
	    setOP(1);
	    setFmt(2'b00);
	    setType(5'b00001);
	endfunction

	virtual function void setMRDLK_4DW_WITH_NODATA();
	    setENUM(MRDLK);
	    setOP(1);
	    setFmt(2'b01);
	    setType(5'b00001);
	endfunction


	virtual function void setMWR_3DW_WITH_DATA();
	    setENUM(MWR);
	    setOP(1);
	    setFmt(2'b10);
	    setType(5'b00000);
	endfunction

	virtual function void setMWR_4DW_WITH_DATA();
	    setENUM(MWR);
	    setOP(1);
	    setFmt(2'b11);
	    setType(5'b00000);
	endfunction

	virtual function void setIORD_3DW_WITH_NODATA();
	    setENUM(IORD);
	    setOP(0,1);
	    setFmt(2'b00);
	    setType(5'b00010);
	endfunction
	
	virtual function void setIOWR_3DW_WITH_DATA();
	    setENUM(IOWR);
	    setOP(0,1);
	    setFmt(2'b10);
	    setType(5'b00010);
	endfunction
	
	virtual function void setCFGRD0_3DW_WITH_NODATA();
	    setENUM(CFGRD0);
	    setOP(0,0,1);
	    setFmt(2'b00);
	    setType(5'b00100);
	endfunction
	
	virtual function void setCFGWR0_3DW_WITH_DATA();
	    setENUM(CFGWR0);
	    setOP(0,0,1);
	    setFmt(2'b10);
	    setType(5'b00100);
	endfunction

	virtual function void setCFGRD1_3DW_WITH_NODATA();
	    setENUM(CFGRD0);
	    setOP(0,0,1);
	    setFmt(2'b00);
	    setType(5'b00101);
	endfunction
	
	virtual function void setCFGWR1_3DW_WITH_DATA();
	    setENUM(CFGWR0);
	    setOP(0,0,1);
	    setFmt(2'b10);
	    setType(5'b00101);
	endfunction

	virtual function void setMSG_4DW_WITH_NODATA(bit [2:0] typ = 3'b0);
	    setENUM(MSG);
	    setOP(0,0,0,1);
	    setFmt(2'b01);
	    setType({2'b00,typ});
	endfunction
	
	virtual function void setMSGD_4DW_WITH_DATA(bit [2:0] typ = 3'b0);
	    setENUM(MSGD);
	    setOP(0,0,0,1);
	    setFmt(2'b11);
	    setType({2'b00,typ});
    endfunction

    //############################################################################
    //############################################################################
	virtual task startPkt(
									input uvm_sequencer_base seqr, 
									input int pkt_num = 1,
									input int len = 0,
									input data_gen_enum gen_mode = FIXED,
									input bit [7:0] start_dt = 8'h0,
									input bit [7:0] data[] = '{default:0},
									input uvm_sequence_base parent = null
								   );
	    this.m_pkt_num = pkt_num;
		if(len <= 0)
			`uvm_fatal(CLASSID,"You must not set up_payload size zero!!!")
		this.m_up_payload = new[len];
		if(gen_mode == FIXED) begin
			foreach(this.m_up_payload[i])
				this.m_up_payload[i] = start_dt;
        end
        else if(gen_mode == INCR) begin 
			foreach(this.m_up_payload[i])
				this.m_up_payload[i] = start_dt + i;
        end
        else if(gen_mode == RND) begin 
			foreach(this.m_up_payload[i])
				this.m_up_payload[i] = $urandom;
		end
		else 
			this.m_up_payload = data;
        this.start(seqr,parent);
	endtask
    //############################################################################
	static bit [7:0] rd_tag_id_3dw;
	static bit [7:0] rd_tag_id_4dw;
	static bit [7:0] wr_tag_id_3dw;
	static bit [7:0] wr_tag_id_4dw;
	virtual task RegWR(input uvm_sequencer_base seqr,bit [63:0] addr, bit[63:0] data,bit is_3dw_4dw = 0);    
	    if(addr[1:0] != 2'b0)/*{{{*/
			`uvm_fatal(CLASSID,"You must seting addr 4bytes align!!")
		if(is_3dw_4dw == 0) begin 
			setMWR_3DW_WITH_DATA();
	        setREQID(16'b0);
			setADDR32(addr);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b0000);
			setTAG(wr_tag_id_3dw++);
			startPkt(seqr,1,1,USR,8'h0,'{data[31:24],data[23:16],data[15:8],data[7:0]});
		end
		else begin 
			setMWR_4DW_WITH_DATA();
			setADDR64(addr);
	        setREQID(16'b0);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b1111);
			setTAG(wr_tag_id_4dw++);
			startPkt(seqr,1,1,USR,8'h0,'{data[63:56],data[55:48],data[47:40],data[39:32],
			                             data[31:24],data[23:16],data[15:8],data[7:0]});
		end
		`uvm_info(CLASSID,$sformatf("[REG-WR]:Addr[0x%0h] -----> Data[0x%0h]",addr,data),UVM_LOW)
		/*}}}*/
	endtask
    //############################################################################
	virtual task RegRD(input uvm_sequencer_base seqr,bit [63:0] addr, output bit [7:0] data[$],input bit is_3dw_4dw = 0);    
 		bit [7:0] m_tag;/*{{{*/
		bit [15:0] m_req_id = 0;
		pcie_tlp_pkt m_pkt;
		bit [63:0] mdata = '0;
	    if(addr[1:0] != 2'b0)
			`uvm_fatal(CLASSID,"You must seting addr 4bytes align!!")
		if(is_3dw_4dw == 0) begin 
			m_tag = rd_tag_id_3dw++;
			setMRD_3DW_WITH_NODATA();
	        setREQID(m_req_id);
			setADDR32(addr);
	        setLength(10'd1);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b0000);
			setTAG(m_tag);
			startPkt(seqr);
			fork
				begin 
				    p_sequencer.mon2sqr_afifo.get(m_pkt);
					if(m_pkt.req_id !== m_req_id || m_pkt.tag != m_tag)
						`uvm_error(CLASSID,"You Read data req_id and tag not same to requester!")
					else
						data = m_pkt.up_payload;
				end
			    begin 
				    #(time_out*10us);
					`uvm_error(CLASSID,"You Read data timeout!!!!")
				end
			join_any
			disable fork;
		end
		else begin 
			m_tag = rd_tag_id_4dw++;
			setMRD_4DW_WITH_NODATA();
			setADDR64(addr);
	        setREQID(m_req_id);
	        setLength(10'd2);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b1111);
			setTAG(m_tag);
			startPkt(seqr);
			fork
				begin 
				    p_sequencer.mon2sqr_afifo.get(m_pkt);
					if(m_pkt.req_id !== m_req_id || m_pkt.tag != m_tag)
						`uvm_error(CLASSID,"You Read data req_id and tag not same to requester!")
					else
						data = m_pkt.up_payload;
				end
			    begin 
				    #(time_out*10us);
					`uvm_error(CLASSID,"You Read data timeout!!!!")
				end
			join_any
		end
		for(int i=0;i<data.size();i++)begin 
			mdata = {mdata[55:0],data[i]};
		end
		`uvm_info(CLASSID,$sformatf("[REG-RD]:Addr[0x%0h] -----> Data[0x%0h]",addr,mdata),UVM_LOW)
		/*}}}*/
	endtask
    //##############################################################################################################
	virtual task RndWR(input uvm_sequencer_base seqr,bit[63:0] addr,int len,bit is_3dw_4dw = 0);    
	    int rend;/*{{{*/
		int blk_len;
        bit [3:0] m_fdws[5];
        bit [3:0] m_ldws[5];
		m_fdws[0] = 4'b0000;
		m_fdws[1] = 4'b1000;
		m_fdws[2] = 4'b1100;
		m_fdws[3] = 4'b1110;
		m_fdws[4] = 4'b1111;
		m_ldws[0] = 4'b1111;
		m_ldws[1] = 4'b0001;
		m_ldws[2] = 4'b0011;
		m_ldws[3] = 4'b0111;
		m_ldws[4] = 4'b0000;
		rend = (addr - addr[63:12]*4096+len-1)/4096;
		if(is_3dw_4dw == 0) begin
			setMWR_3DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_3dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR32(addr);
				else 
					setADDR32((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end
				startPkt(seqr,1,blk_len,RND);
			end
		end
		else begin 
			setMWR_4DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_4dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR64(addr);
				else 
					setADDR64((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end	
				startPkt(seqr,1,blk_len,RND);
			end
		end
		/*}}}*/
	endtask
    //##############################################################################################################
	virtual task IncrWR(input uvm_sequencer_base seqr,bit[63:0] addr,int len,bit [7:0] start_dt = 8'h0,bit is_3dw_4dw = 0);    
	    int rend;/*{{{*/
		int blk_len;
        bit [3:0] m_fdws[5];
        bit [3:0] m_ldws[5];
		m_fdws[0] = 4'b0000;
		m_fdws[1] = 4'b1000;
		m_fdws[2] = 4'b1100;
		m_fdws[3] = 4'b1110;
		m_fdws[4] = 4'b1111;
		m_ldws[0] = 4'b1111;
		m_ldws[1] = 4'b0001;
		m_ldws[2] = 4'b0011;
		m_ldws[3] = 4'b0111;
		m_ldws[4] = 4'b0000;
		rend = (addr - addr[63:12]*4096+len-1)/4096;
		if(is_3dw_4dw == 0) begin
			setMWR_3DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_3dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR32(addr);
				else 
					setADDR32((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end
				startPkt(seqr,1,blk_len,INCR);
			end
		end
		else begin 
			setMWR_4DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_4dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR64(addr);
				else 
					setADDR64((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end	
				startPkt(seqr,1,blk_len,INCR);
			end
		end
		/*}}}*/
	endtask
    //##############################################################################################################
	virtual task FixWR(input uvm_sequencer_base seqr,bit [63:0] addr,int len,bit [7:0] start_dt = 8'h0,bit is_3dw_4dw = 0);    
	    int rend;/*{{{*/
		int blk_len;
        bit [3:0] m_fdws[5];
        bit [3:0] m_ldws[5];
		m_fdws[0] = 4'b0000;
		m_fdws[1] = 4'b1000;
		m_fdws[2] = 4'b1100;
		m_fdws[3] = 4'b1110;
		m_fdws[4] = 4'b1111;
		m_ldws[0] = 4'b1111;
		m_ldws[1] = 4'b0001;
		m_ldws[2] = 4'b0011;
		m_ldws[3] = 4'b0111;
		m_ldws[4] = 4'b0000;
		rend = (addr - addr[63:12]*4096+len-1)/4096;
		if(is_3dw_4dw == 0) begin
			setMWR_3DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_3dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR32(addr);
				else 
					setADDR32((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end
				startPkt(seqr,1,blk_len,FIXED);
			end
		end
		else begin 
			setMWR_4DW_WITH_DATA();
	        setREQID(16'b0);
			setTAG(wr_tag_id_4dw++);
			for(int i=0;i<rend+1;i++) begin 
				if(i == 0)
					blk_len = 4096*(1+addr[63:12]) - addr;
				else
					blk_len = 4096;
				if(len > blk_len)
					len = len - blk_len;
				else
					blk_len = len;
				if(i==0) 
					setADDR64(addr);
				else 
					setADDR64((addr[63:12]+i)*4096);
				if(blk_len <= 4) begin  
					setFirstDWBE(m_fdws[blk_len]);
					setLastDWBE(m_ldws[4]);
				end
				else begin 
					setFirstDWBE(m_fdws[4]);
					setLastDWBE(m_ldws[blk_len%4]);
				end	
				startPkt(seqr,1,blk_len,FIXED);
			end
		end
		/*}}}*/
	endtask
    //##############################################################################################################
	virtual task BufRD(input uvm_sequencer_base seqr,bit [63:0] addr,int len,output bit [7:0] data[$],input bit is_3dw_4dw = 0);    
		bit [7:0] m_tag;/*{{{*/
		bit [15:0] m_req_id = 0;
		pcie_tlp_pkt m_pkt;
		if(is_3dw_4dw == 0) begin 
			m_tag = rd_tag_id_3dw++;
			setMRD_3DW_WITH_NODATA();
	        setREQID(m_req_id);
			setADDR32(addr);
	        setLength(len);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b0000);
			setTAG(m_tag);
			startPkt(seqr);
			fork
				begin 
				    p_sequencer.mon2sqr_afifo.get(m_pkt);
					if(m_pkt.req_id !== m_req_id || m_pkt.tag != m_tag)
						`uvm_error(CLASSID,"You Read data req_id and tag not same to requester!")
					else
						data = m_pkt.up_payload;
				end
			    begin 
				    #(time_out*10us);
					`uvm_error(CLASSID,"You Read data timeout!!!!")
				end
			join_any
			disable fork;
		end
		else begin 
			m_tag = rd_tag_id_4dw++;
			setMRD_4DW_WITH_NODATA();
			setADDR64(addr);
	        setREQID(m_req_id);
	        setLength(len);
			setFirstDWBE(4'b1111);
			setLastDWBE(4'b0000);
			setTAG(m_tag);
			startPkt(seqr);
			fork
				begin 
				    p_sequencer.mon2sqr_afifo.get(m_pkt);
					if(m_pkt.req_id !== m_req_id || m_pkt.tag != m_tag)
						`uvm_error(CLASSID,"You Read data req_id and tag not same to requester!")
					else
						data = m_pkt.up_payload;
				end
			    begin 
				    #(time_out*1ms);
					`uvm_error(CLASSID,"You Read data timeout!!!!")
				end
			join_any
		end/*}}}*/
	endtask
    //##############################################################################################################

endclass: pcie_tlp_default_seq



`endif 

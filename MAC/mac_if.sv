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
//     FileName: mac_if.sv
//         Desc:  
//       Author: lixu
//        Email: lixu@ruijie.com.cn
//     HomePage: http://www.ruijie.com.cn
//      Version: 0.0.1
//   LastChange: 2016-03-10 13:34:18
//      History:
//============================================================================*/
`ifndef MAC_IF__SV
`define MAC_IF__SV

`include "cbb_pkg.sv"
`include "uvm_macros.svh"
`include "tbtop_pkg.sv"
interface mac_if (); 
	parameter  string  IF_NAME      = "MAC_IF_100G"         ;  
	parameter  real    LBUS_PERIOD  = 3.103ns               ;//~322.265625MHz
	parameter          SEG_NUM      = 4                     ;
    parameter          RXDATA_WIDTH = 128                   ;//64/128/256/512 
    parameter          TXDATA_WIDTH = 128                   ;//64/128/256/512 
    localparam         RXMTY_WIDTH  = $clog2(RXDATA_WIDTH/8);
    localparam         TXMTY_WIDTH  = $clog2(TXDATA_WIDTH/8);
	localparam         RXDATA_BYTES = (RXDATA_WIDTH/8)      ;
	localparam         TXDATA_BYTES = (TXDATA_WIDTH/8)      ;
    //########################################################
	import uvm_pkg::*;
	import cbb_pkg::*;
	import tbtop_pkg::mac_pkt;
	typedef logic [0:SEG_NUM-1]     logic_segn_t            ;
    //########################################################
    //LBUS interface clk/reset
    //OUTPUT to DUT
    logic                           tx_clk                  ;
    logic                           tx_reset                ;
    logic                           rx_clk                  ;
    logic                           rx_reset                ;
    //LBUS interface RX Path;sync to clk
    logic [RXDATA_WIDTH-1 : 0]      rx_dataout[SEG_NUM]     ;
    logic                           rx_enaout[SEG_NUM]      ;
    logic                           rx_sopout[SEG_NUM]      ;
    logic                           rx_eopout[SEG_NUM]      ;
    logic                           rx_errout[SEG_NUM]      ;
    logic [RXMTY_WIDTH-1  : 0]      rx_mtyout[SEG_NUM]      ;
    //LBUS interface TX Path;sync to clk
    logic                           tx_rdyout               ;
    logic                           tx_ovfout               ;
    logic                           tx_unfout               ;
    logic [TXDATA_WIDTH-1 : 0]      tx_datain[SEG_NUM]      ;
    logic                           tx_enain[SEG_NUM]       ;
    logic                           tx_sopin[SEG_NUM]       ;
    logic                           tx_eopin[SEG_NUM]       ;
    logic                           tx_errin[SEG_NUM]       ;
    logic [TXMTY_WIDTH-1  : 0]      tx_mtyin[SEG_NUM]       ;

	
	modport mac_rx (input  rx_clk    ,
	                input  rx_reset  ,
	                output rx_dataout,
					output rx_enaout ,
					output rx_sopout ,
					output rx_eopout ,
					output rx_errout ,
					output rx_mtyout
				   );

	modport mac_tx (input  tx_clk    ,
	                input  tx_reset  ,
	                input  tx_datain ,
					input  tx_enain  ,
					input  tx_sopin  ,
					input  tx_eopin  ,
					input  tx_errin  ,
					input  tx_mtyin  ,
					output tx_rdyout ,
					output tx_ovfout ,
					output tx_unfout
				   );

    `ifdef MAC_IF_LPB
	    assign  tx_clk    = rx_clk;
	    assign  tx_reset  = rx_reset;
        assign  tx_datain = rx_dataout;  
        assign  tx_enain  = rx_enaout;  
        assign  tx_sopin  = rx_sopout;
        assign  tx_eopin  = rx_eopout;
        assign  tx_errin  = rx_errout;
        assign  tx_mtyin  = rx_mtyout;
    `endif

	initial begin
		rx_clk = 0;
		#($urandom_range(10,20)*10ns);
		forever #(LBUS_PERIOD/2) rx_clk = ~rx_clk;
	end

	initial begin
		rx_reset <= 1;
		repeat($urandom_range(3,10)) @(posedge rx_clk);
		rx_reset <= 0;
	end
	
	logic [SEG_NUM-1:0] m_tx_enain;
	logic [SEG_NUM-1:0] m_tx_sopin;
	logic [SEG_NUM-1:0] m_tx_eopin;
	int time_rdy = 10000;
	int time_overflow = 100000;
	event trigger_unfout;
	always @(*) m_tx_enain = logic_segn_t'(tx_enain);
	always @(*) m_tx_sopin = logic_segn_t'(tx_sopin);
	always @(*) m_tx_eopin = logic_segn_t'(tx_eopin);

	//###################################################################################
	//ASSETION
    property P_UNDERFLOW;
		@(posedge tx_clk) ((tx_rdyout == '1)&&$countones(m_tx_enain) == 0) |-> ($past($countones(m_tx_eopin) == 1 &&
		                                                                              ((tx_eopin[0]&&m_tx_enain == 4'b1000) ||
		                                                                               (tx_eopin[1]&&m_tx_enain == 4'b1100) ||
		                                                                               (tx_eopin[2]&&m_tx_enain == 4'b1110) ||
		                                                                               (tx_eopin[3]&&m_tx_enain == 4'b1111))
	                                                                                 ) || $past($countones(m_tx_enain) == 0));		                                                   
	endproperty
	assert property(P_UNDERFLOW) else begin 
		                                  ->trigger_unfout;
										  `uvm_error(IF_NAME,"TX UNDERFLOW!!!")
									  end
	//###################################################################################
	bit mac_model_ena = 0;
	initial begin:CHK_TX
		bit signed [SEG_NUM:0] cmp_dt;
		cmp_dt = 2**SEG_NUM;
		fork
            begin:CHK_TX_ENAIN
		    	bit good;/*{{{*/
		    	forever begin 
		    	    good = 0;
		    	    @(posedge tx_clk) begin
		    			for(int i=0;i<SEG_NUM+1;i++) begin 
		    				if((m_tx_enain === SEG_NUM'(cmp_dt>>>i))) begin 
		    					good = 1;
		    					break;
		    				end
		    			end
		    			if(good == 0)
		    				`uvm_error(IF_NAME,$sformatf("You get wrong gap[%0b] tx_enain!",m_tx_enain))
		            end
		    	end/*}}}*/
		    end
		    begin:CHK_DOUBLE_SOP_EOF
 		    	forever begin /*{{{*/
		    	    @(posedge tx_clk) begin
		    			if($countones(m_tx_sopin) > 1)
		    				`uvm_error(IF_NAME,$sformatf("You get wrong SOP[%0b] tx_sopin!",m_tx_sopin))
		    			if($countones(m_tx_eopin) > 1)
		    				`uvm_error(IF_NAME,$sformatf("You get wrong EOP[%0b] tx_eopin!",m_tx_eopin))
		            end
		    	end/*}}}*/
		    end
		    begin:CHK_PAIR_SOF_EOF
 		    	int m_sum;/*{{{*/
				m_sum = 0;
		    	forever begin 
		    	    @(posedge tx_clk) begin 
					    for(int i=0;i<SEG_NUM;i++) begin 
							if(tx_sopin[i] == '1)
								m_sum++;
							if(tx_eopin[i] == '1)
								m_sum--;
							if(m_sum > 2) 
								`uvm_error(IF_NAME,$sformatf("You get continuous  SOP[%0d] tx_sopin!",m_sum))
							else if(m_sum < 0)
								`uvm_error(IF_NAME,$sformatf("You get continuous  EOP[%0d] tx_eopin!",m_sum))
						end
		    		end
		        end/*}}}*/
            end
		    begin:DRV_OVERFLOW 
		        int m_sum;/*{{{*/
				m_sum = 0;
		    	tx_ovfout <= '0;
		        forever begin 
		    	    @(posedge tx_clk) begin 
		    		    if(tx_rdyout == 0 && $countones(m_tx_enain) > 0)
		    				m_sum = m_sum + 1;
		    			else
		    				m_sum = 0;
		            end
		    		if(m_sum > 4) begin 
		    			`uvm_error(IF_NAME,$sformatf("You get data continuous zero tx_rdyout[%0d] and may OVERFLOW!",m_sum))
		    			tx_ovfout <= '1;
		    		end
		    		else if(m_sum > 0) begin 
		    			`uvm_warning(IF_NAME,$sformatf("You get data continuous zero tx_rdyout[%0d] and may OVERFLOW!",m_sum))
		    			tx_ovfout <= '1;
		    		end
		    		else begin 
		    			tx_ovfout <= ($urandom_range(0,time_overflow)) > 0 ? '0 :'1;
		    		end
		        end/*}}}*/
		    end
		    begin:DRV_UNDERFLOW 
			    forever begin /*{{{*/
			        tx_unfout <= '0;
					@(trigger_unfout);
					tx_unfout <= '1;
					@(posedge tx_clk);
				end/*}}}*/
		    end
		    begin:DRV_RDY
				if(mac_model_ena == 0)
					forever begin /*{{{*/
		    		    tx_rdyout <= ($urandom_range(0,time_rdy) > 0) ? '1 : '0;
		    			@(posedge tx_clk);
		    		end/*}}}*/
		    end
		join
	end

	mac_pkt m_mac_pkt_q[$];
	event trigger_mon_tx;
    initial begin:MON_TX
		mac_pkt m_pkt;/*{{{*/
	    bit [TXDATA_WIDTH-1:0] mdata_q[$];
		bit [TXMTY_WIDTH-1:0]  m_tx_mtyin;
		bit find_sop;
		bit find_eop;
		bit m_err;
		int m_size;
		int m_bytes_num;
		find_sop = 0;
		find_eop = 0;
	    while(1) begin
		    @(posedge tx_clk) begin 
  			    for(int i=0;i<SEG_NUM;i++)begin 
				    if(find_sop == 0 && find_eop == 0 && tx_enain[i] == '1 && tx_sopin[i] == '1 && tx_eopin[i] == '0) begin:SOP
						mdata_q.push_back(tx_datain[i]);
						find_sop = 1;
					end
					if(find_sop == 1 && find_eop == 0 && tx_enain[i] == '1 && tx_sopin[i] == '0 && tx_eopin[i] == '1) begin:EOP
						if(tx_sopin[i] != '1) begin:SOF_EOF_SAME_CLK
							mdata_q.push_back(tx_datain[i]);
						end
						m_err = tx_errin[i];
						m_tx_mtyin = tx_mtyin[i];
						find_eop = 1;
						if(find_eop == 1) begin 
							find_sop = 0;
							find_eop = 0;
							//for(int i=0;i<mdata_q.size();i++)
							//	$display("%0h",mdata_q[i]);
							//$display("#################################");
							m_pkt = `CREATE_OBJ(mac_pkt,"m_pkt")
							m_pkt.err = m_err;
			                m_bytes_num = TXDATA_WIDTH/8; 
			                m_size = mdata_q.size()*(m_bytes_num);
							m_size = m_size - m_tx_mtyin;
							for(int i=0;i<m_size;i++)
								m_pkt.mac_data.push_back(mdata_q[i/m_bytes_num][RXDATA_WIDTH-1-8*(i%m_bytes_num) -:8]); 
							m_mac_pkt_q.push_back(m_pkt);
							mdata_q.delete();
							->trigger_mon_tx;
						end
					end
					if(find_sop == 1 && find_eop == 0 && tx_enain[i] == '1 && tx_sopin[i] == '0 && tx_eopin[i] == '0) begin:DATA
						mdata_q.push_back(tx_datain[i]);
					end
				end
			end
		end /*}}}*/
	end

	//########################################################
	//########################################################
	class concrete_if extends abstract_if;

	
        typedef logic [RXDATA_WIDTH-1:0] mdata_q_t[$];
		int next_pkt_seg = 0;
		bit first_pkt = 1;

		function new(string name = "concrete_if");
			super.new(name);
		endfunction
		
		`uvm_if_utils(concrete_if,$sformatf("%0s",IF_NAME))
		
		task clean_up();
			next_pkt_seg = 0;
			first_pkt = 1;
            resetBUS(0,SEG_NUM);
		endtask:clean_up 

		task drvInit();
			for(int i=0;i<SEG_NUM;i++) begin/*{{{*/
                rx_dataout[i] <= '0; 
                rx_enaout[i]  <= '0;           
                rx_sopout[i]  <= '0;
                rx_eopout[i]  <= '0;
                rx_errout[i]  <= '0;
                rx_mtyout[i]  <= '0;
		    end/*}}}*/
		endtask

		task sentPkt(input uvm_sequence_item pkt,input uvm_object cfg = null); 
 			mac_pkt m_pkt;/*{{{*/
			int len;
			int mod;
			int rend;
			int mdata_size;
			logic [RXDATA_WIDTH-1:0] mdata[];
			logic [RXDATA_WIDTH-1:0] mdata_q[$];
			int seg_id;
			if(pkt == null) begin 
				if(next_pkt_seg != 0) begin 
					resetBUS(next_pkt_seg,SEG_NUM);
					next_pkt_seg = 0;
				end
				@(posedge rx_clk) resetBUS(next_pkt_seg,SEG_NUM);
			end
			else begin 
				$cast(m_pkt,pkt.clone());
			    len = m_pkt.mac_data.size();
			    mod = len/RXDATA_BYTES;//16bytes per seg
			    rend = len%RXDATA_BYTES;//render 1~15 bytes 
				if(rend != 0)
					mdata_size = mod + 1;
				else
					mdata_size = mod;
			    mdata = new[mdata_size];
			    for(int i=0;i<mdata_size;i++) begin 
			    	for(int j=0;j<RXDATA_BYTES;j++) begin 
			    		if(i < mod)
			    			mdata[i][RXDATA_WIDTH-1-8*j -:8] = m_pkt.mac_data.pop_front();
			    		else begin 
			    	        if(j < rend)
			    	        	mdata[mod][RXDATA_WIDTH-1-8*j -:8] = m_pkt.mac_data.pop_front();
			    	        else
			    	        	mdata[mod][RXDATA_WIDTH-1-8*j -:8] = 'x;
			    		end
			    	end
			    end
                mdata_q = mdata_q_t'(mdata);
				`uvm_info(IF_NAME,$sformatf("You get pkt que:\n%p",mdata_q),UVM_HIGH)
                //################################################################################
				seg_id = next_pkt_seg;
			    fork
			        begin 
			    	    for(int j=0;j<mdata_size;j++)begin 
			    		    seg_id = seg_id%SEG_NUM;
			    			if(seg_id == 0) begin 
							    if(first_pkt == 0) begin 
									repeat(m_pkt.ipg) @(posedge rx_clk) begin 
									    resetBUS(0,SEG_NUM);
								    end
								end
			    				@(posedge rx_clk);
			    			end
			    			if(j == 0) begin:SOP
			    				rx_enaout[seg_id] <= '1;
			    				rx_sopout[seg_id] <= '1;
			    				rx_dataout[seg_id] <= mdata_q.pop_front();
								if(mdata_size == 1)begin:SOF_EOF_SAME_CLK
			    				    rx_eopout[seg_id] <= '1;
								    if(m_pkt.err == 1'b1) begin 
									    bit [RXMTY_WIDTH-1:0] tmp;
										rx_errout[seg_id] <= '1;
										tmp = RXMTY_WIDTH'((1'b1 << RXMTY_WIDTH) - rend);
										tmp[2:0] = 3'b0;
										rx_mtyout[seg_id] <= tmp;
									end
									else begin 
										rx_errout[seg_id] <= '0;
										rx_mtyout[seg_id] <=  RXMTY_WIDTH'((1'b1 << RXMTY_WIDTH) - rend);
									end
								end 
								else begin 
									rx_eopout[seg_id] <= '0;
									rx_errout[seg_id] <= '0;
									rx_mtyout[seg_id] <= '0;
								end
			    			end
			    			else if(j == mdata_size - 1) begin:EOP
			    				rx_enaout[seg_id] <= '1;
			    				rx_sopout[seg_id] <= '0;
			    				rx_dataout[seg_id] <= mdata_q.pop_front();
			    				rx_eopout[seg_id] <= '1;
								if(m_pkt.err == 1'b1) begin 
									bit [RXMTY_WIDTH-1:0] tmp;
									rx_errout[seg_id] <= '1;
									tmp = RXMTY_WIDTH'((1'b1 << RXMTY_WIDTH) - rend);
									tmp[2:0] = 3'b0;
									rx_mtyout[seg_id] <= tmp;
								end
								else begin 
									rx_errout[seg_id] <= '0;
									rx_mtyout[seg_id] <=  RXMTY_WIDTH'((1'b1 << RXMTY_WIDTH) - rend);
								end
			    			end
			    			else begin:DATA 
			    				rx_enaout[seg_id] <= '1;
			    				rx_sopout[seg_id] <= '0;
			    				rx_dataout[seg_id] <= mdata_q.pop_front();
			    				rx_eopout[seg_id] <= '0;
			    				rx_errout[seg_id] <= '0;
			    				rx_mtyout[seg_id] <= '0;
			    			end
			    		    seg_id++;
			    		end
			    		next_pkt_seg = seg_id%SEG_NUM;
			    		if( m_pkt.gap==1 && next_pkt_seg !=0 ) begin 
			    			resetBUS(next_pkt_seg,SEG_NUM);
			    			next_pkt_seg = 0;
			    			repeat(m_pkt.ipg) @(posedge rx_clk) begin 
			    			    resetBUS(next_pkt_seg,SEG_NUM);
			    		    end
			    		end	
						first_pkt = 0;
			        end
				join
			end /*}}}*/
		endtask:sentPkt

		task recvPkt(output uvm_sequence_item pkt); 
			mac_pkt m_mac_pkt;/*{{{*/
			@(trigger_mon_tx);
	        m_mac_pkt = m_mac_pkt_q.pop_front();
			if(m_mac_pkt.mac_data.size() < 64)
				`uvm_error(IF_NAME,$sformatf("You recvPkt data size less 64 bytes!--->:\n%0s",m_mac_pkt.sprint()))
			`uvm_info(IF_NAME,$sformatf("You recvPkt ------>:\n%0s",m_mac_pkt.sprint()),UVM_HIGH)
			$cast(pkt,m_mac_pkt.clone());/*}}}*/
		endtask:recvPkt

		task resetBUS(input int start,stop);
			for(int i=start;i<stop;i++) begin /*{{{*/
				rx_enaout[i] <= '0;
				rx_sopout[i] <= '0;
				rx_dataout[i] <= '0;
				rx_eopout[i] <= '0;
				rx_errout[i] <= '0;
				rx_mtyout[i] <= '0;
			end/*}}}*/
		endtask:resetBUS

	endclass
  
	concrete_if m_concrete_if;
  
	function abstract_if get_concrete_if();
		m_concrete_if = `CREATE_OBJ(concrete_if,$sformatf("%0s",IF_NAME));
		return m_concrete_if;
	endfunction

endinterface 


`endif


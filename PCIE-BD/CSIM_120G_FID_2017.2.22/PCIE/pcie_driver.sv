

class con_idle_num;  
	rand bit [3:0] idle;
	constraint cons_idle_num{
    idle >= 1;
    idle <= 8; 
    }
endclass


class pcie_driver extends uvm_driver #(pcie_tlp_item);
  
  //factory register 
  `uvm_component_utils(pcie_driver) 
  //item 
  pcie_tlp_item req; 
  //config 
  pcie_configuration m_config; 
  con_idle_num idle_num;
  
	parameter         PCIE_DATA_WIDTH    =   64  ;
	//parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
  
  //inferface define 
  virtual pcie_intf.pcie_tx_intf PCIE_TX_INTF;
  virtual pcie_intf.pcie_clk_intf PCIE_CLK_INTF;
  
  //uvm_tlm_analysis_fifo #(pcie_tlp_item) pcie_dr_out_fifo;

 

  uvm_analysis_port #(pcie_tlp_item) out_tlp_drv_port;

  //new 
  function new(string name = "pcie_driver", uvm_component parent = null);   
    super.new(name, parent); 
    out_tlp_drv_port = new("out_tlp_drv_port", this);
    //pcie_dr_out_fifo = new("pcie_dr_out_fifo", this);
  endfunction 

  //bulid 
  virtual function void build_phase(uvm_phase phase);   
   
  endfunction : build_phase 

  //connect 
  function void connect_phase( uvm_phase phase );   
    PCIE_TX_INTF  = m_config.pcie_tx_intf; // set local virtual if property 
    PCIE_CLK_INTF = m_config.pcie_clk_intf;
  endfunction : connect_phase 

  //elaboration 
  function void end_of_elaboration();   
    //this.print(); 
  endfunction 
  
  //reset
  virtual task reset_dut();
    uvm_report_info(get_full_name(),"Start of reset_dut() method ",UVM_HIGH);
  
		PCIE_CLK_INTF.user_link_up   <= 0;  
		PCIE_CLK_INTF.user_reset_out <= 1;

		PCIE_TX_INTF.m_axis_cq_tdata  <= 0;
		PCIE_TX_INTF.m_axis_cq_tuser  <= 0;
		PCIE_TX_INTF.m_axis_cq_tlast  <= 0;
		PCIE_TX_INTF.m_axis_cq_tkeep  <= 0;
		PCIE_TX_INTF.m_axis_cq_tvalid <= 0;
                
		PCIE_TX_INTF.m_axis_rc_tdata  <= 0;
		PCIE_TX_INTF.m_axis_rc_tuser  <= 0;
		PCIE_TX_INTF.m_axis_rc_tlast  <= 0;
		PCIE_TX_INTF.m_axis_rc_tkeep  <= 0;
		PCIE_TX_INTF.m_axis_rc_tvalid <= 0;

    uvm_report_info(get_full_name(),"End of reset_dut() method ",UVM_HIGH);
  endtask : reset_dut

  virtual task clk_dut();
     
  endtask : clk_dut

  virtual task drive(pcie_tlp_item pkt);
    byte unsigned  array_bytes[];
    int          pkt_len;
    int          repeat_time;
    logic [7:0]  tkeep;
    bit	  [8:0]  cnt;
    bit          first_flag = 1'b0; //first_flag=0-->lock data.1 cycle after sop.
    //bit         last_flag   = 1'b0; //last_flag=0-->lock data.the same cycle to eop.
    bit   [8:0]  length     = 9'b0;
    bit   [3:0]  first_diff = 4'b0;
    bit   [3:0]  last_diff  = 4'b0;
    bit   [14:0] last_data  = 15'b0; 
    bit   [2:0]  first_data = 3'b0;
    bit          frameflag  = 1'b0; 

    pkt_len = pkt.pack_bytes(array_bytes);     //ws:packing pkt(pcie_tlp_item to array_bytes as bytes type).
    pkt_len = array_bytes.size();              //ws:count the bytes number of pcie_tlp_item 
    length  = pkt_len/8;
    //uvm_report_info(get_type_name(), $sformatf("pkt_len=%0d",pkt_len), UVM_LOW); 
    //foreach(array_bytes[i])uvm_report_info(get_type_name(), $sformatf("array_bytes[%0d]=%2h",i,array_bytes[i]), UVM_LOW); 
    //if (pkt_len[5:0]==0)
    //	repeat_time = pkt_len/PCIE_DATA_WIDTH;
    //else 
    //  repeat_time = pkt_len/PCIE_DATA_WIDTH + 1'b1;
    //cnt = repeat_time;
    //if (pkt_len[5:0] >32)
    //	tkeep = 8'hff;
    //else
    //	tkeep = 8'h0f;
    //uvm_report_info(get_full_name(),"Driving packet ...",UVM_LOW);
    //while (cnt) begin    
 
    @(posedge PCIE_TX_INTF.pcie_clk_in); 
    PCIE_TX_INTF.m_axis_cq_tdata  <= 64'h0;
		PCIE_TX_INTF.m_axis_cq_tuser  <= 85'h0;
		PCIE_TX_INTF.m_axis_cq_tlast  <= 1'b0 ;
		PCIE_TX_INTF.m_axis_cq_tkeep  <= 2'b0 ;
		PCIE_TX_INTF.m_axis_cq_tvalid <= 1'b0 ;
                
		PCIE_TX_INTF.m_axis_rc_tdata  <= 64'h0;
		PCIE_TX_INTF.m_axis_rc_tuser  <= 85'h0;
		PCIE_TX_INTF.m_axis_rc_tlast  <= 1'b0 ;
		PCIE_TX_INTF.m_axis_rc_tkeep  <= 2'b0 ;
		PCIE_TX_INTF.m_axis_rc_tvalid <= 1'b0 ;
    //pkt.print();
    //$display("pkt_len=%0d",pkt_len);
    
    fork
    	begin
    		while (frameflag) begin
    		  while (~PCIE_TX_INTF.m_axis_cq_tready || ~PCIE_TX_INTF.m_axis_rc_tready) begin
    		  	@(posedge PCIE_TX_INTF.pcie_clk_in);
    		  end
    		end
    	end
    
      begin
        for (int i=0;i<pkt_len;i=i+PCIE_DATA_WIDTH/8) begin
        	//$display("time=%0d,i=%0d,pkt_len=%0d",$time,i,pkt_len);
        	if (pkt.is_cpl_op) begin //3dw rc
            //if (pkt.addr32%8 != 0 || {pkt.lower_addr[6:2],2'b0}%8 !=0 ) begin  //non-qword aligned

            //$display("111time=%0d,non-qword  pkt_len=%0d",$time,pkt_len);
            if (PCIE_DATA_WIDTH == 64) begin
              if (i<8) begin                                 //header0 & header1
              	//$display("222time=%0d,i=%0d",$time,i);
                
                PCIE_TX_INTF.m_axis_rc_tdata[63:0] <= {pkt.req_id,1'b0,pkt.ep,pkt.cpl_st,pkt.length,1'b0,pkt.end_of_cpl,1'b0,pkt.byte_cnt,4'b0,pkt.lower_addr} ;
                PCIE_TX_INTF.m_axis_rc_tuser[3:0]  <=  4'h0 ;   //byte_en
                PCIE_TX_INTF.m_axis_rc_tuser[7:4]  <=  4'h0 ;   //byte_en
                PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b1 ;   //sop
                PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue     
                PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid
                PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b11;   //valid dw
                PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b0 ;   //eop                                    
                                  
                //if (PCIE_TX_INTF.rx_st_ready) begin  
                //  PCIE_TX_INTF.rx_st_valid <= 1'b1;
                //end
                frameflag = 1'b1; 
              end
                
              else if (i<16) begin                           //header2 & data0
                //$display("here i=%0d",i);
                //first_flag = $urandom_range(0,1);
                  
                for (int j=0;j<4;j++) begin //header2
                  PCIE_TX_INTF.m_axis_rc_tdata[31:0] <= {1'b0,pkt.attr,pkt.tc,1'b0,pkt.cpl_id,pkt.tag};
                end
                for (int j=0;j<4;j++) begin //data0
                  PCIE_TX_INTF.m_axis_rc_tdata[40+j*8-1-:8] <= array_bytes[4+i+j];
                end
               
                	//$display("~~~~~~~~~~~~~~~time=%0d,~~~pkt.end_of_cpl=%0b,pkt_len=%0h",$time,pkt.end_of_cpl,pkt_len); 
                	if (pkt.end_of_cpl) begin //if data0 is the last data.
                		case (pkt.lower_addr[1:0])
                		  2'b00 : first_diff = 4'b0000;
                		  2'b01 : first_diff = 4'b0001;
                		  2'b10 : first_diff = 4'b0011;
                		  2'b11 : first_diff = 4'b0111;
                	  endcase
                	  if (first_diff == 4'b0000) begin
                	  	case (pkt.byte_cnt)
                	  		'h1 : last_diff = 4'b1110;
                	  		'h2 : last_diff = 4'b1100;
                	  		'h3 : last_diff = 4'b1000;
                	  		'h4 : last_diff = 4'b0000;
                	  	endcase
                	  end
                	  else if (first_diff == 4'b0001) begin
                	  	case (pkt.byte_cnt)
                	  		'h1 : last_diff = 4'b1100;
                	  		'h2 : last_diff = 4'b1000;
                	  		'h3 : last_diff = 4'b0000;
                	  	endcase  
                	  end
                	  else if (first_diff == 4'b0011) begin
                	  	case (pkt.byte_cnt)
                	  		'h1 : last_diff = 4'b1000;
                	  		'h2 : last_diff = 4'b0000;
                	  	endcase
                	  end
                	  else if (first_diff == 4'b0111) begin
                	  	case (pkt.byte_cnt)
                	  		'h1 : last_diff = 4'b0000;
                	  	endcase
                	  end
                	  PCIE_TX_INTF.m_axis_rc_tuser[3:0]  <=  4'h0 ;   //byte_en      
                	  PCIE_TX_INTF.m_axis_rc_tuser[7:4]  <=  4'hf - first_diff - last_diff;   //byte_en  -- first_be      
                	  PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop          
                	  PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue  
                	  PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid        
                	  PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b11;   //valid dw     
                	  PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b0 ;   //eop          
                	  
                  end
                	else begin //data0 is not the last data.
                	  case (pkt.lower_addr[1:0])
                	  	2'b00 : first_diff = 4'b0000;
                	  	2'b01 : first_diff = 4'b0001;
                	  	2'b10 : first_diff = 4'b0011;
                	  	2'b11 : first_diff = 4'b0111;
                	  endcase
                	  //$display("!!!!first_diff=%h",first_diff);
                	  PCIE_TX_INTF.m_axis_rc_tuser[3:0]  <=  4'h0 ;   //byte_en      
                	  PCIE_TX_INTF.m_axis_rc_tuser[7:4]  <=  4'hf - first_diff;   //byte_en  -- first_be      
                	  PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop          
                	  PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue  
                	  PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid        
                	  PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b11;   //valid dw     
                	  PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b0 ;   //eop          
                	                    	                    	  
                  end
                //end                 
            
                //$display("time=%0d,be=%0h",$time,PCIE_TX_INTF.rx_st_be);
                //$display("))))))))time=%0d,i=%0d,pkt_len=%0d",$time,i,pkt_len);
                if (i >= pkt_len-8) begin
                	//$display("))))))))time=%0d,i=%0d",$time,i);
                	PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b1;    //eop
                end
                else begin
                  PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b0;     //eop
                end
                
              end          	
                                	
              else begin //data1-->datan
              	//first_flag = $urandom_range(0,1);
              	
                for (int j=0;j<4;j++) begin 
                  PCIE_TX_INTF.m_axis_rc_tdata[8+j*8-1-:8]  <= array_bytes[j+i]; 
                end
                for (int j=0;j<4;j++) begin
                  PCIE_TX_INTF.m_axis_rc_tdata[40+j*8-1-:8] <= array_bytes[4+j+i];  
                end
                if (i >= pkt_len-8) begin //the final 2dw data.(because of data[63:0])
                  if (array_bytes.size()%8 != 0) begin //only 1dw data last in the final 2dw location.the value of array_byte.size()%8 is 4 or 0, because of the data is always packed as 1dw.  
		                	//$display("~~~~~~~~~~~~~~~time=%0d,~~~pkt.end_of_cpl=%0b",$time,pkt.end_of_cpl);  
		                  if (pkt.end_of_cpl) begin //the final complete tlp of one requeste tlp.
                	      case (pkt.lower_addr[1:0])
                	      	2'b00 : first_data = 3'h4;
                	      	2'b01 : first_data = 3'h3;
                	      	2'b10 : first_data = 3'h2;
                	      	2'b11 : first_data = 3'h1;
                	      endcase
                	      last_data = pkt.byte_cnt - first_data;
                	     // $display("##########first_diff=%0h,byte_cnt=%0h,last_data=%0h",first_diff,pkt.byte_cnt,last_data);
		                	  case (last_data[1:0])
		                	  	'h3 : last_diff = 4'b1000;
		                	  	'h2 : last_diff = 4'b1100;
		                	  	'h1 : last_diff = 4'b1110;
		                	  	'h0 : last_diff = 4'b0000;
		                	  endcase
		                	  PCIE_TX_INTF.m_axis_rc_tuser[7:4] <= 4'h0;           
		                	  PCIE_TX_INTF.m_axis_rc_tuser[3:0] <= 4'hf - last_diff;
		                	end
		                	else begin
		                		PCIE_TX_INTF.m_axis_rc_tuser[7:4] <= 4'h0;            
		                		PCIE_TX_INTF.m_axis_rc_tuser[3:0] <= 4'hf;
		                	end
		                //end 
		                //PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop          
		                //PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue  
		                //PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid        
		                PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b01;   //valid dw       
		                //PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b1 ;   //eop          		                  		                  		                           
		              end
		              else begin //2dw data last in the final 2dw location.
		              	if(pkt.end_of_cpl) begin//the final complete tlp of one requeste tlp.
		              	  case (pkt.lower_addr[1:0])
                	  	  2'b00 : first_data = 3'h4;
                	  	  2'b01 : first_data = 3'h3;
                	  	  2'b10 : first_data = 3'h2;
                	  	  2'b11 : first_data = 3'h1;
                	    endcase
                	    last_data = pkt.byte_cnt - first_data;
                	   // $display("##########first_diff=%0h,byte_cnt=%0h,last_data=%0h",first_diff,pkt.byte_cnt,last_data);
		                  case (last_data[1:0])
		                  	'h3 : last_diff = 4'b1000;
		                  	'h2 : last_diff = 4'b1100;
		                  	'h1 : last_diff = 4'b1110;
		                  	'h0 : last_diff = 4'b0000;
		                  endcase 
		              	  PCIE_TX_INTF.m_axis_rc_tuser[7:4] <= 4'hf - last_diff;                           
		              	  PCIE_TX_INTF.m_axis_rc_tuser[3:0] <= 4'hf; 
		              	end
		              	else begin 
		              		PCIE_TX_INTF.m_axis_rc_tuser[7:4] <= 4'hf;
		              		PCIE_TX_INTF.m_axis_rc_tuser[3:0] <= 4'hf; 
		              	end	             
		              	//end
		              	//PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop           
		              	//PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue   
		              	//PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid         
		              	PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b11;   //valid dw       
		              	//PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b1 ;   //eop  
		              	       	                                  
		              end 
		              PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop           
		              PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue   
		              PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid             
		              PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b1 ;   //eop           
		              
		              
                end
		            else begin 
		            	PCIE_TX_INTF.m_axis_rc_tuser[7:4]  <=  4'hf; 
		            	PCIE_TX_INTF.m_axis_rc_tuser[3:0]  <=  4'hf;
		            	PCIE_TX_INTF.m_axis_rc_tuser[32]   <=  1'b0 ;   //sop         
		            	PCIE_TX_INTF.m_axis_rc_tuser[42]   <=  1'b0 ;   //discontinue 
		            	PCIE_TX_INTF.m_axis_rc_tvalid      <=  1'b1 ;   //valid       
		            	PCIE_TX_INTF.m_axis_rc_tlast       <=  1'b0 ;   //eop         
		            	PCIE_TX_INTF.m_axis_rc_tkeep       <=  2'b11;   //valid dw 

                end
                
              end
                 
		          @(posedge PCIE_TX_INTF.pcie_clk_in);
            end          
		        
		      end
		      else begin //4dw cq                                                    
            if (PCIE_DATA_WIDTH == 64) begin    //4dw cq 
            	if (i<8) begin              //header0 & header1
            	  PCIE_TX_INTF.m_axis_cq_tdata[63:0]   <= {pkt.addr64[63:2],2'b0} ;                                                          
		      			PCIE_TX_INTF.m_axis_cq_tuser[3:0]    <= pkt.first_dw_be;     //first_be
                PCIE_TX_INTF.m_axis_cq_tuser[7:4]    <= pkt.last_dw_be ;     //last_be
                PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= 4'b0           ;     //byte_en
                PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= 4'b0           ;     //byte_en
                PCIE_TX_INTF.m_axis_cq_tuser[40]     <= 1'b1           ;	   //sop
                PCIE_TX_INTF.m_axis_cq_tuser[41]     <= 1'b0           ;     //discontinue
                PCIE_TX_INTF.m_axis_cq_tlast         <= 1'b0           ;     //eop 
                PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b11          ;     //valid dw 
                PCIE_TX_INTF.m_axis_cq_tvalid        <= 1'b1           ;                     
		      			                                                           
		      			frameflag = 1'b1;
		      		end
		      		
		      		else if (i<16) begin       //header2 & header3
		      			                                                                                           //type=0000 -- read, type=0001 write
		      			PCIE_TX_INTF.m_axis_cq_tdata[63:0]   <= {1'b0,pkt.attr,pkt.tc,17'b0,pkt.tag,pkt.req_id,1'b0,3'd0,pkt.fmt[1],pkt.length} ;
		      			                   
                PCIE_TX_INTF.m_axis_cq_tuser[3:0]    <= pkt.first_dw_be;     //first_be
                PCIE_TX_INTF.m_axis_cq_tuser[7:4]    <= pkt.last_dw_be ;     //last_be
                PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= 4'b0           ;     //byte_en
                PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= 4'b0           ;     //byte_en
                PCIE_TX_INTF.m_axis_cq_tuser[40]     <= 1'b0           ;	   //sop
                PCIE_TX_INTF.m_axis_cq_tuser[41]     <= 1'b0           ;     //discontinue
                PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b11          ;     //valid dw  
                PCIE_TX_INTF.m_axis_cq_tvalid        <= 1'b1           ;
                
                if (i >= pkt_len-8) begin
                	PCIE_TX_INTF.m_axis_cq_tlast <= 1'b1;         //eop
                end
                else begin
                  PCIE_TX_INTF.m_axis_cq_tlast <= 1'b0;         //eop
                end
                           
              end
                              
              else begin               //data0 ~ datan
              	//first_flag = $urandom_range(0,1);
              	
              	for (int j=0;j<4;j++) begin 
                  PCIE_TX_INTF.m_axis_cq_tdata[8+j*8-1-:8]  <= array_bytes[j+i];     //data(n-1)
                end
                for (int j=0;j<4;j++) begin
                  PCIE_TX_INTF.m_axis_cq_tdata[40+j*8-1-:8] <= array_bytes[j+i+4];   //datan
                end
                
                if (i >= pkt_len-8) begin
                	if (i<24) begin           //third clk is the last clk
                		if (array_bytes.size()%8!=0) begin  //data0 is the last data[63:0]
                		  PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= pkt.first_dw_be;    //byte_en
                		  PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= 4'h0           ;    //byte_en
                		  PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b01          ;     //valid dw
                	  end
                	  else begin //data0 & data1 is the last data
                		  PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= pkt.first_dw_be;                  	  	
                	  	PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= pkt.last_dw_be ;
                	  	PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b11          ;     //valid dw
                		end
                	end
                  else begin               //else clk is the last clk
                  	if (array_bytes.size()%8!=0) begin                   //only one clk data
                  		PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= pkt.last_dw_be ;  
                		  PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= 4'h0           ; 
                		  PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b01          ;     //valid dw
                		end
                		else begin                                           //two clk data
                	  	PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= 4'hf           ;
                		  PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= pkt.last_dw_be ;
                		  PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b11          ;     //valid dw
                		end
                	end
                	PCIE_TX_INTF.m_axis_cq_tuser[40]     <= 1'b0           ;	   //sop         
                	PCIE_TX_INTF.m_axis_cq_tuser[41]     <= 1'b0           ;     //discontinue 
                	PCIE_TX_INTF.m_axis_cq_tlast         <= 1'b1           ;     //eop 
                	PCIE_TX_INTF.m_axis_cq_tvalid        <= 1'b1           ;        
                end
                
                else begin
                  PCIE_TX_INTF.m_axis_cq_tuser[11:8]   <= 4'hf           ;
                  PCIE_TX_INTF.m_axis_cq_tuser[15:12]  <= 4'hf           ;
                  PCIE_TX_INTF.m_axis_cq_tuser[40]     <= 1'b0           ;	   //sop
                  PCIE_TX_INTF.m_axis_cq_tuser[41]     <= 1'b0           ;     //discontinue 
                	PCIE_TX_INTF.m_axis_cq_tlast         <= 1'b0           ;     //eop
                	PCIE_TX_INTF.m_axis_cq_tkeep         <= 2'b11          ;     //valid dw
                	PCIE_TX_INTF.m_axis_cq_tvalid        <= 1'b1           ;
                end
                
              end
              
              @(posedge PCIE_TX_INTF.pcie_clk_in);
            end
          end          		      					      				
	      end 
	      
	      frameflag                     = 1'b0;
		    PCIE_TX_INTF.m_axis_cq_tdata  <= 0;
        PCIE_TX_INTF.m_axis_cq_tuser  <= 0;
        PCIE_TX_INTF.m_axis_cq_tlast  <= 0;
        PCIE_TX_INTF.m_axis_cq_tkeep  <= 0;
        PCIE_TX_INTF.m_axis_cq_tvalid <= 0;
         
        PCIE_TX_INTF.m_axis_rc_tdata  <= 0;
        PCIE_TX_INTF.m_axis_rc_tuser  <= 0;
        PCIE_TX_INTF.m_axis_rc_tlast  <= 0;
        PCIE_TX_INTF.m_axis_rc_tkeep  <= 0;
        PCIE_TX_INTF.m_axis_rc_tvalid <= 0;
      end
    
    join
    	  
  endtask : drive

 virtual task run_phase(uvm_phase phase);
    
    reset_dut();
    
    //fork
    fork
      //begin
      //  clk_dut();
      //end        
        begin
          forever begin
        	  PCIE_CLK_INTF.user_link_up = 1'b1;
        	  //#1;
        	  //wait(PCIE_TX_INTF.m_axis_rx_tready == 1'b1)
        	  
            seq_item_port.get_next_item(req);
            //.print();
            drive(req);
            seq_item_port.item_done();
            out_tlp_drv_port.write(req);
            //pcie_dr_out_fifo.write(seq);
            //constraint cons_idle_num{
            //idle_num.size >= 1;
            //idle_num.size <= 12;
            //}
            
            idle_num = new();
            assert(idle_num.randomize());
            repeat(idle_num.idle) @(posedge PCIE_TX_INTF.pcie_clk_in);
            //repeat(12) @(posedge PCIE_TX_INTF.pcie_clk_in);
          end
        end
    join
    
  endtask : run_phase  
  
endclass : pcie_driver






 



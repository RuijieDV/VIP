
class pcie_monitor extends uvm_monitor;

  `uvm_component_utils(pcie_monitor)

  virtual pcie_intf.pcie_rx_intf PCIE_RX_INTF;
    
  pcie_configuration m_config; 
  parameter         PCIE_DATA_WIDTH    =   64  ;
	//parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
  
  uvm_analysis_port #(pcie_tlp_item) out_tlp_mon_port;
  
  //new 
  function new(string name = "pcie_monitor", uvm_component parent = null);   
    super.new(name, parent); 
    out_tlp_mon_port = new("out_tlp_mon_port", this);
  endfunction 

  //bulid 
  virtual function void build_phase(uvm_phase phase);   
   
  endfunction : build_phase 

  //connect 
  function void connect_phase( uvm_phase phase );   
    PCIE_RX_INTF = m_config.pcie_rx_intf; // set local virtual if property 
  endfunction : connect_phase 

  //elaboration 
  function void end_of_elaboration();   
    //this.print(); 
  endfunction 
  task wait_for_IRQ_PCIE();
  @(posedge PCIE_RX_INTF.s_pcie_msi);
  //@(posedge PCIE_RX_INTF.s_axis_cc_tvalid);
  `SET_TRIGGER("PCIE_MSI");
  `uvm_info("WAIT_FOR_IRQ_PCIE",$sformatf("this time =%0d  pcie_msi",$time),UVM_LOW);
  endtask: wait_for_IRQ_PCIE

  virtual task run_phase(uvm_phase phase);
    //byte unsigned data_q[$];
    bit [7:0]  data_q[$];
    bit [3:0]  data_be[$];
    pcie_tlp_item rev_frm;
    bit	[PCIE_DATA_WIDTH-1'b1:0]	data_temp; 
    bit	[7:0]	be_temp; 
    int payload_len;
    bit flag = 1'b0;
    bit frameflag = 1'b0;
    
    PCIE_RX_INTF.s_axis_cc_tready <= 1'b0;
    PCIE_RX_INTF.s_axis_rq_tready <= 1'b0; 
    
    //@(posedge PCIE_RX_INTF.pcie_reset_out);
    #20ns;
    PCIE_RX_INTF.s_axis_cc_tready <= 1'b1;
    PCIE_RX_INTF.s_axis_rq_tready <= 1'b1; 

    
     
      fork  
        begin   
        	forever begin
            wait (PCIE_RX_INTF.s_axis_cc_tvalid) begin
            	flag = $urandom_range(0,1);                                         
            	if (~flag) begin 
            		repeat (2) @(posedge PCIE_RX_INTF.pcie_clk_in)                                                   
            		PCIE_RX_INTF.s_axis_cc_tready <= 1'b0;                                 
            	 	repeat ($urandom_range(1,2)) @(posedge PCIE_RX_INTF.pcie_clk_in); 
            	 	//$display("time=%0d",$time);
            	end                                                                
            	PCIE_RX_INTF.s_axis_cc_tready <= 1'b1;
            	//$display("time=%0d",$time);
            end
            PCIE_RX_INTF.s_axis_cc_tready<= 1'b1;
            @(posedge PCIE_RX_INTF.pcie_clk_in);
            
            //$display("time=%0d",$time);
              
          end                           
        end	
        begin
        	forever begin
        		wait_for_IRQ_PCIE()	;
          end
        end      
        begin
          forever begin                                        
            rev_frm = pcie_tlp_item::type_id::create("rev_frm");        	
        	  //$display("start debugtime=%0d",$time);
        	  
        	  // CC
        	  @(posedge PCIE_RX_INTF.s_axis_cc_tvalid or posedge PCIE_RX_INTF.s_axis_rq_tvalid );
        	  
        	  if (PCIE_RX_INTF.s_axis_cc_tvalid && (PCIE_RX_INTF.s_axis_cc_tkeep[1] || PCIE_RX_INTF.s_axis_cc_tkeep[0])) begin  
        	  	
        	    while (PCIE_RX_INTF.s_axis_cc_tvalid) begin
                if(PCIE_RX_INTF.s_axis_cc_tready !==1) begin
              	  @(posedge PCIE_RX_INTF.pcie_clk_in);     
                end                                                                                                   
                else if (PCIE_RX_INTF.s_axis_cc_tready) begin
                  data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.s_axis_cc_tdata;
                  //$display("time=%0d,data_temp=%h",$time,data_temp);
                  if (PCIE_DATA_WIDTH == 64) begin
                  	//if (!PCIE_RX_INTF.tx_st_err) begin //tx_st_err=0 means the data of this cycle is not wrong.
                      //data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.tx_st_data;
                      //$display("start0 data_q=%p",data_q);
                    if (PCIE_RX_INTF.s_axis_cc_tkeep==2'b11) begin
                    	data_q.push_back (data_temp[7:0]  );  //byte 0   
                    	data_q.push_back (data_temp[15:8] );  //byte 1   
                    	data_q.push_back (data_temp[23:16]);  //byte 2   
                    	data_q.push_back (data_temp[31:24]);  //byte 3   
                    	data_q.push_back (data_temp[39:32]);  //byte 0   
                    	data_q.push_back (data_temp[47:40]);  //byte 1   
                    	data_q.push_back (data_temp[55:48]);  //byte 2   
                    	data_q.push_back (data_temp[63:56]);  //byte 3 
                    	
                      
                    	//$display("start1 data_q=%p",data_q);                    	                    	                    	                    	                    	                    	
                    	//data_q.push_back (data_temp[31:24]);
                      //data_q.push_back (data_temp[23:16]);
                      //data_q.push_back (data_temp[15:8] );
                      //data_q.push_back (data_temp[7:0]  );
                      //data_q.push_back (data_temp[63:56]);
                      //data_q.push_back (data_temp[55:48]);
                      //data_q.push_back (data_temp[47:40]);
                      //data_q.push_back (data_temp[39:32]);                      
                    end 
                    else if (PCIE_RX_INTF.s_axis_cc_tkeep==2'b01) begin
                    	data_q.push_back (data_temp[7:0]  );  //byte 0 
                    	data_q.push_back (data_temp[15:8] );  //byte 1 
                    	data_q.push_back (data_temp[23:16]);  //byte 2 
                    	data_q.push_back (data_temp[31:24]);  //byte 3 
                    	//$display("start2 data_q=%p",data_q);
                    	//data_q.push_back (data_temp[31:24]); 
                    	//data_q.push_back (data_temp[23:16]); 
                    	//data_q.push_back (data_temp[15:8] ); 
                    	//data_q.push_back (data_temp[7:0]  ); 
                    end                                            
                  end
                  
                  @(posedge PCIE_RX_INTF.pcie_clk_in); 
                  #1ns;
    	          end //tready
    	        end //while
    	        //$display("start data_q=%p",data_q); 
              ////uvm_report_info(get_type_name(), $sformatf(" monitor resv pcie data[38=%0h",data_q[0]), UVM_LOW); 
              rev_frm.is_cpl_op    = 1 ;
              rev_frm.is_3dw       = 0 ;
              rev_frm.is_4dw       = 1 ;
              rev_frm.is_with_data = 1 ;                           
              
              //DW 0                                       
              rev_frm.rev_1bit        = data_q[0][7]     ;   
              rev_frm.lower_addr[6:0] = data_q[0][6:0]   ;   
              data_q.delete(0) ;                             
              
              rev_frm.rev_6bit       = data_q[0][7:2]   ;            
              rev_frm.rev_2bit       = data_q[0][1:0]   ;      //at  
              data_q.delete(0) ;
              
              rev_frm.byte_cnt[7:0]  = data_q[0] ;
              data_q.delete(0) ;                                     
              
              rev_frm.rev_2bit       = data_q[0][7:6]   ;                        
              rev_frm.rev_1bit       = data_q[0][5]     ;          //lock_rd_cpl 
              rev_frm.byte_cnt[12:8] = data_q[0][4:0]   ;                        
              data_q.delete(0) ;                                                 
                            
              //rev_frm.rev_2bit       = data_q[0][7:6]   ;      
              //rev_frm.rev_1bit       = data_q[0][5]     ;          //lock_rd_cpl
              //rev_frm.byte_cnt[12:8] = data_q[0][4:0]   ;
              //data_q.delete(0) ;
              //
              //rev_frm.rev_6bit       = data_q[0][7:2]   ;
              //rev_frm.rev_2bit       = data_q[0][1:0]   ;      //at
              //data_q.delete(0) ;
              //
              //rev_frm.rev_1bit        = data_q[0][7]     ;
              //rev_frm.lower_addr[6:0] = data_q[0][6:0]   ;
              //data_q.delete(0) ;
              
              //DW 1
              rev_frm.length[7:0]   = data_q[0]      ;
              data_q.delete(0) ;                      
              
              rev_frm.rev_1bit      = data_q[0][7]   ;   
              rev_frm.ep            = data_q[0][6]   ;   
              rev_frm.cpl_st        = data_q[0][5:3] ;   
              rev_frm.length[10:8]  = data_q[0][2:0] ;   
              data_q.delete(0) ;                         
              
              rev_frm.req_id[7:0]   = data_q[0] ;     
              data_q.delete(0) ;                      
              
              rev_frm.req_id[15:8]  = data_q[0] ;     
              data_q.delete(0) ;                      
              
              //rev_frm.req_id[15:8]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.req_id[7:0]   = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.rev_1bit      = data_q[0][7]   ;
              //rev_frm.ep            = data_q[0][6]   ;
              //rev_frm.cpl_st        = data_q[0][5:3] ;
              //rev_frm.length[10:8]  = data_q[0][2:0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.length[7:0]   = data_q[0]      ;
              //data_q.delete(0) ;
              
              //DW 2
              rev_frm.tag           = data_q[0]      ;
              data_q.delete(0) ;                      
              
              rev_frm.cpl_id[7:0]   = data_q[0]      ;  
              data_q.delete(0) ;                        
              
              rev_frm.cpl_id[15:8]  = data_q[0]      ;  
              data_q.delete(0) ;                        
              
              rev_frm.td            = data_q[0][7]   ;                    
              rev_frm.attr          = data_q[0][6:4] ;                    
              rev_frm.tc            = data_q[0][3:1] ;                    
              rev_frm.rev_1bit      = data_q[0][0]   ;     //cpl_id_en    
              data_q.delete(0) ;                                          
                                          
              //rev_frm.td            = data_q[0][7]   ;
              //rev_frm.attr          = data_q[0][6:4] ;
              //rev_frm.tc            = data_q[0][3:1] ;
              //rev_frm.rev_1bit      = data_q[0][0]   ;     //cpl_id_en
              //data_q.delete(0) ;
              //
              //rev_frm.cpl_id[15:8]  = data_q[0]      ;
              //data_q.delete(0) ;
              //
              //rev_frm.cpl_id[7:0]   = data_q[0]      ;
              //data_q.delete(0) ;
              //
              //rev_frm.tag           = data_q[0]      ;
              //data_q.delete(0) ;
                            
              rev_frm.payload = new[data_q.size] ;
              payload_len = data_q.size ;
              for (int j=0;j<payload_len;j=j+4) begin
              	for (int i=0;i<4;i++) begin
              		rev_frm.payload[i+j] = data_q[0] ;
              		data_q.delete(0);
              	end
              end                           
            end
            
            // RQ
            else if (PCIE_RX_INTF.s_axis_rq_tvalid && (PCIE_RX_INTF.s_axis_rq_tkeep[1] || PCIE_RX_INTF.s_axis_rq_tkeep[0])) begin
            	while (PCIE_RX_INTF.s_axis_rq_tvalid) begin
                if(PCIE_RX_INTF.s_axis_rq_tready !==1) begin
              	  @(posedge PCIE_RX_INTF.pcie_clk_in);     
                end                                                                                                   
                else if (PCIE_RX_INTF.s_axis_rq_tready) begin
                  data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.s_axis_rq_tdata;
                  be_temp[7:0] = PCIE_RX_INTF.s_axis_rq_tuser[7:0];
                  //$display("time=%0d,data_temp=%h",$time,data_temp);
                  if (PCIE_DATA_WIDTH == 64) begin
                  	//if (!PCIE_RX_INTF.tx_st_err) begin //tx_st_err=0 means the data of this cycle is not wrong.
                      //data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.tx_st_data;
                      //$display("start4 data_q=%p",data_q);
                      if (PCIE_RX_INTF.s_axis_rq_tkeep==2'b11) begin 
                      	data_q.push_back (data_temp[7:0]  );  //byte 0
                      	data_q.push_back (data_temp[15:8] );  //byte 1
                      	data_q.push_back (data_temp[23:16]);  //byte 2
                      	data_q.push_back (data_temp[31:24]);  //byte 3
                      	data_q.push_back (data_temp[39:32]);  //byte 0
                      	data_q.push_back (data_temp[47:40]);  //byte 1
                      	data_q.push_back (data_temp[55:48]);  //byte 2
                      	data_q.push_back (data_temp[63:56]);  //byte 3
                      	
                      	data_be.push_back (be_temp[3:0]) ; //first_be
                      	data_be.push_back (be_temp[7:4]) ; //last_be
                      	                      	
                      	//data_q.push_back (data_temp[31:24]);
                        //data_q.push_back (data_temp[23:16]);
                        //data_q.push_back (data_temp[15:8] );
                        //data_q.push_back (data_temp[7:0]  );
                        //data_q.push_back (data_temp[63:56]);
                        //data_q.push_back (data_temp[55:48]);
                        //data_q.push_back (data_temp[47:40]);
                        //data_q.push_back (data_temp[39:32]);                      
                      end 
                      else if (PCIE_RX_INTF.s_axis_rq_tkeep==2'b01) begin
                      	data_q.push_back (data_temp[7:0]  );  //byte 0 
                      	data_q.push_back (data_temp[15:8] );  //byte 1 
                      	data_q.push_back (data_temp[23:16]);  //byte 2 
                      	data_q.push_back (data_temp[31:24]);  //byte 3 
                      	//$display("start5 data_q=%p",data_q);
                      	//data_q.push_back (data_temp[31:24]); 
                      	//data_q.push_back (data_temp[23:16]); 
                      	//data_q.push_back (data_temp[15:8] ); 
                      	//data_q.push_back (data_temp[7:0]  ); 
                      end
                  end                 
                  @(posedge PCIE_RX_INTF.pcie_clk_in); 
    	          end //tready
    	        end //while
    	        
              rev_frm.is_mem_io_op = 1 ;
              rev_frm.is_3dw       = 0 ;
              rev_frm.is_4dw       = 1 ;       
                                  
              rev_frm.first_dw_be  = data_be[0] ;
              data_be.delete(0) ;
              
              rev_frm.last_dw_be   = data_be[0] ;
              data_be.delete(0) ;
              //$display("000time=%0d, first_dw_be=%4b, last_dw_be=%4b",$time,rev_frm.first_dw_be,rev_frm.last_dw_be) ;
              
              
              //DW 0                                       
              rev_frm.addr64[7:2]    = data_q[0][7:2] ;               //byte 0
              rev_frm.rev_2bit       = data_q[0][1:0] ;         //at 
              data_q.delete(0) ;                                     
              
              rev_frm.addr64[15:8]   = data_q[0] ;                    //byte 1
              data_q.delete(0) ;                   
              
              rev_frm.addr64[23:16]  = data_q[0] ;                    //byte 2
              data_q.delete(0) ;                  
              
              rev_frm.addr64[31:24]  = data_q[0] ;  									//byte 3
              data_q.delete(0) ;                  
                            
              //rev_frm.addr64[31:24]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[23:16]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[15:8]   = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[7:2]    = data_q[0][7:2] ;
              //rev_frm.rev_2bit       = data_q[0][1:0] ;         //at
              //data_q.delete(0) ;
              
              //DW 1
              rev_frm.addr64[39:32]  = data_q[0] ;
              data_q.delete(0) ;                  
             
              rev_frm.addr64[47:40]  = data_q[0] ;
              data_q.delete(0) ;                  
             
              rev_frm.addr64[55:48]  = data_q[0] ;
              data_q.delete(0) ;                  
             
              rev_frm.addr64[63:56]  = data_q[0] ; 
              data_q.delete(0) ;                   
                        
              //rev_frm.addr64[63:56]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[55:48]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[47:40]  = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.addr64[39:32]  = data_q[0] ;
              //data_q.delete(0) ;
              
              //DW 2
              rev_frm.length[7:0]    = data_q[0] ;     
              data_q.delete(0) ;                       
              
              rev_frm.ep             = data_q[0][7] ;   
              rev_frm.typ            = data_q[0][6:3] ; 
              rev_frm.length[10:8]   = data_q[0][2:0] ; 
              data_q.delete(0) ;                        
              
              rev_frm.req_id[7:0]    = data_q[0] ;  
              data_q.delete(0) ;                    
              
              rev_frm.req_id[15:8]   = data_q[0] ;  
              data_q.delete(0) ;                    
              
              
              //rev_frm.req_id[15:8]   = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.req_id[7:0]    = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.ep             = data_q[0][7] ;
              //rev_frm.typ            = data_q[0][6:3] ;
              //rev_frm.length[10:8]   = data_q[0][2:0] ;
              //data_q.delete(0) ;             
              //
              //rev_frm.length[7:0]    = data_q[0] ;
              //data_q.delete(0) ;
              
              if (rev_frm.typ == 4'b0000) begin //memory read request
              	rev_frm.is_with_data = 0 ;
              	rev_frm.fmt = 2'b01 ;
              end
              else if (rev_frm.typ == 4'b0001) begin //memory write request
                rev_frm.is_with_data = 1 ;
                rev_frm.fmt = 2'b11 ;
              end 
              //$display("rq111time=%0d, type=%4b, is_with_data=%0d, length=%b, addr[13:0]=%b",$time,rev_frm.typ,rev_frm.is_with_data,rev_frm.length,rev_frm.addr64[13:0]);
                
              //DW 3
              rev_frm.tag            = data_q[0] ;  
              data_q.delete(0) ;                    
              
              rev_frm.cpl_id[7:0]    = data_q[0] ;  
              data_q.delete(0) ;                    
              
              rev_frm.cpl_id[15:8]   = data_q[0] ;   
              data_q.delete(0) ;                    
              
              rev_frm.td             = data_q[0][7] ;   
              rev_frm.attr           = data_q[0][6:4] ; 
              rev_frm.tc             = data_q[0][3:1] ; 
              rev_frm.rev_1bit       = data_q[0][0]   ; 
              data_q.delete(0) ;                        
                            
              //rev_frm.td             = data_q[0][7] ;
              //rev_frm.attr           = data_q[0][6:4] ;
              //rev_frm.tc             = data_q[0][3:1] ;
              //rev_frm.rev_1bit       = data_q[0][0]   ;             //req_id_en
              //data_q.delete(0) ;
              //
              //rev_frm.cpl_id[15:8]   = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.cpl_id[7:0]    = data_q[0] ;
              //data_q.delete(0) ;
              //
              //rev_frm.tag            = data_q[0] ;
              //data_q.delete(0) ;
                            
              if (rev_frm.is_with_data) begin
              	//$display("222time=%0d, data_q.size=%0d",$time,data_q.size()) ;
                rev_frm.payload = new[data_q.size] ;
                payload_len = data_q.size() ;
                for (int n=0;n<payload_len;n=n+4) begin 
                	for (int m=0;m<4;m++) begin
                		rev_frm.payload[m+n] = data_q[0] ;
                		data_q.delete(0); 
                		//$display("rq222time=%0d, payload_len=%0d, data_q.size=%0d, m=%0d, n=%0d",$time,payload_len,data_q.size(),m,n) ;
                	end
                end
              //$display("rq333time=%0d, payload_len=%0d",$time,payload_len) ;
              end 
                         
            end //s_axis_rq_tvalid
            
            else begin
              @(posedge PCIE_RX_INTF.pcie_clk_in); 
            end
                                                                 
     	        if (uvm_report_enabled(UVM_HIGH))
     	        	if (rev_frm.is_3dw && (rev_frm.typ==4'b0000))
     	        	uvm_report_info(get_type_name(), "rev_frm.3dw ****************************************", UVM_HIGH);	
     	        //if (uvm_report_enabled(UVM_HIGH))
              //rev_frm.print();
              //$display("is_3dw=%b, is_4dw=%b, is_with_data=%b, is_cpl_op=%b, is_cfg_op=%b, is_mem_io_op=%b",rev_frm.is_3dw, rev_frm.is_4dw, rev_frm.is_with_data, rev_frm.is_cpl_op, rev_frm.is_cfg_op, rev_frm.is_mem_io_op);
              out_tlp_mon_port.write(rev_frm);          
              //uvm_report_info(get_type_name(), " ****************************************", UVM_LOW);	
              //`uvm_info("PCIE_REV",$sformatf("%s",rev_frm.sprint()),UVM_LOW);
	  	        data_q.delete();
	  	        data_be.delete();
	  	        
	  	        //@(posedge PCIE_RX_INTF.pcie_clk_in);
              //rev_frm.print();
              //$display("end debugtime=%0d",$time);  
          end
        end 
        
        //wrong begin
        //wrong 	forever begin
        //wrong 	  @(posedge PCIE_RX_INTF.s_axis_rq_tvalid)
        //wrong 	  	//#1ns ;
        //wrong 	   rev_frm.first_dw_be = PCIE_RX_INTF.s_axis_rq_tuser[3:0] ;
        //wrong 	   rev_frm.last_dw_be  = PCIE_RX_INTF.s_axis_rq_tuser[7:4] ;
        //wrong 	   $display("000time=%0d, first_dw_be=%4b, last_dw_be=%4b",$time,rev_frm.first_dw_be,rev_frm.last_dw_be) ;
        //wrong 	   //out_tlp_mon_port.write(rev_frm.first_dw_be);
        //wrong 	   //out_tlp_mon_port.write(rev_frm.last_dw_be);
        //wrong 
        //wrong 	end
        //wrong end  
      
      join
    //end

  
  endtask : run_phase
  
  
  
                                                         
endclass : pcie_monitor



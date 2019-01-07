
class pcie_monitor extends uvm_monitor;

  `uvm_component_utils(pcie_monitor)

  virtual pcie_intf.pcie_rx_intf PCIE_RX_INTF;
    
  pcie_configuration m_config; 
  parameter         PCIE_DATA_WIDTH    =   64  ;
	parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
  
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
      `uvm_info("WAIT_FOR_IRQ_PCIE",$sformatf("this time =%t  pcie_msi",$time),UVM_LOW);
  endtask: wait_for_IRQ_PCIE

  virtual task run_phase(uvm_phase phase);
    //byte unsigned data_q[$];
    bit [7:0]  data_q[$];
    pcie_tlp_item rev_frm;
    bit	[PCIE_DATA_WIDTH-1'b1:0]	data_temp;
    int payload_len;

    fork
        forever begin
          /*{{{*/
          rev_frm = pcie_tlp_item::type_id::create("rev_frm");
          //... monitor it
          
          while (PCIE_RX_INTF.s_axis_tx_tvalid !== 1 || PCIE_RX_INTF.s_axis_tx_tready!== 1) begin
            @(posedge PCIE_RX_INTF.pcie_clk_in);
          end
          PCIE_RX_INTF.tx_buf_av = 8'h32;
         // PCIE_RX_INTF.s_axis_tx_tready = 1'b1;
          PCIE_RX_INTF.tx_terr_drop = 1'b0;
          PCIE_RX_INTF.tx_cfg_req = 1'b0;
          
          
          //uvm_report_info(get_full_name(),"resv packet ...",UVM_LOW);
          while (!PCIE_RX_INTF.s_axis_tx_tlast) 
          
          begin
	    	  
	    	  if (PCIE_RX_INTF.s_axis_tx_tvalid && PCIE_RX_INTF.s_axis_tx_tready ) begin
            	//`uvm_info(get_type_name(), $sformatf(" monitor resv pcie_rx_intf =%0h",PCIE_RX_INTF.s_axis_tx_tdata), UVM_LOW);
          	  
          	  data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.s_axis_tx_tdata;
          	  if ( PCIE_DATA_WIDTH == 64) begin
          	  	if ( PCIE_RX_INTF.s_axis_tx_tkeep == 8'hff)
          	  	begin
          	  		data_q.push_back (data_temp[31:24]);//({data_temp[24],data_temp[25],data_temp[26],data_temp[27],data_temp[28],data_temp[29],data_temp[30],data_temp[31]});
          	  		data_q.push_back (data_temp[23:16]);//({data_temp[16],data_temp[17],data_temp[18],data_temp[19],data_temp[20],data_temp[21],data_temp[22],data_temp[23]});
          	  		data_q.push_back (data_temp[15:8] );//({data_temp[8],data_temp[9],data_temp[10],data_temp[11],data_temp[12],data_temp[13],data_temp[14],data_temp[15]});
          	  		data_q.push_back (data_temp[7:0]  );//({data_temp[0],data_temp[1],data_temp[2],data_temp[3],data_temp[4],data_temp[5],data_temp[6],data_temp[7]});
          	  		data_q.push_back (data_temp[63:56]);//({data_temp[56],data_temp[57],data_temp[58],data_temp[59],data_temp[60],data_temp[61],data_temp[62],data_temp[63]}); 
          	  		data_q.push_back (data_temp[55:48]);//({data_temp[48],data_temp[49],data_temp[50],data_temp[51],data_temp[52],data_temp[53],data_temp[54],data_temp[55]});
          	  		data_q.push_back (data_temp[47:40]);//({data_temp[40],data_temp[41],data_temp[42],data_temp[43],data_temp[44],data_temp[45],data_temp[46],data_temp[47]});
          	  		data_q.push_back (data_temp[39:32]);//({data_temp[32],data_temp[33],data_temp[34],data_temp[35],data_temp[36],data_temp[37],data_temp[38],data_temp[39]});
          	  		 ////uvm_report_info(get_type_name(), $sformatf(" monitor data_temp[0] =%0h",data_q[0]), UVM_LOW);
          	  	end
          			else begin 
          				data_q.push_back (data_temp[31:24]);
          				data_q.push_back (data_temp[23:16]);
          				data_q.push_back (data_temp[15:8] );
          				data_q.push_back (data_temp[7:0]  );
          			end
          		end
          		else begin
          			data_q.push_back (data_temp[31:24]);
          			data_q.push_back (data_temp[23:16]);
          			data_q.push_back (data_temp[15:8] );
          			data_q.push_back (data_temp[7:0]  );
          		end
          	  @(posedge PCIE_RX_INTF.pcie_clk_in);
          	end
	          else begin
	            @(posedge PCIE_RX_INTF.pcie_clk_in);
	          end
        	end //while
	    	 while (PCIE_RX_INTF.s_axis_tx_tvalid !== 1|| PCIE_RX_INTF.s_axis_tx_tready !==1) begin
            @(posedge PCIE_RX_INTF.pcie_clk_in);
          end
	    	//	wait(PCIE_RX_INTF.s_axis_tx_tvalid ==1'b1 && PCIE_RX_INTF.s_axis_tx_tready==1'b1&&PCIE_RX_INTF.s_axis_tx_tlast== 1'b1 ); 
//	    #1ns;
           if(PCIE_RX_INTF.s_axis_tx_tvalid && PCIE_RX_INTF.s_axis_tx_tready ) begin
	           data_temp[PCIE_DATA_WIDTH-1'b1:0] = PCIE_RX_INTF.s_axis_tx_tdata;     
 	    if ( PCIE_DATA_WIDTH == 64) begin
            	if ( PCIE_RX_INTF.s_axis_tx_tkeep == 8'hff)
            	begin
            		data_q.push_back (data_temp[31:24]);//({data_temp[24],data_temp[25],data_temp[26],data_temp[27],data_temp[28],data_temp[29],data_temp[30],data_temp[31]});
            		data_q.push_back (data_temp[23:16]);//({data_temp[16],data_temp[17],data_temp[18],data_temp[19],data_temp[20],data_temp[21],data_temp[22],data_temp[23]});
            		data_q.push_back (data_temp[15:8] );//({data_temp[8],data_temp[9],data_temp[10],data_temp[11],data_temp[12],data_temp[13],data_temp[14],data_temp[15]});
            		data_q.push_back (data_temp[7:0]  );//({data_temp[0],data_temp[1],data_temp[2],data_temp[3],data_temp[4],data_temp[5],data_temp[6],data_temp[7]});
            		data_q.push_back (data_temp[63:56]);//({data_temp[56],data_temp[57],data_temp[58],data_temp[59],data_temp[60],data_temp[61],data_temp[62],data_temp[63]}); 
            		data_q.push_back (data_temp[55:48]);//({data_temp[48],data_temp[49],data_temp[50],data_temp[51],data_temp[52],data_temp[53],data_temp[54],data_temp[55]});
            		data_q.push_back (data_temp[47:40]);//({data_temp[40],data_temp[41],data_temp[42],data_temp[43],data_temp[44],data_temp[45],data_temp[46],data_temp[47]});
            		data_q.push_back (data_temp[39:32]);//({data_temp[32],data_temp[33],data_temp[34],data_temp[35],data_temp[36],data_temp[37],data_temp[38],data_temp[39]});
            		 ////uvm_report_info(get_type_name(), $sformatf(" monitor data_temp[0] =%0h",data_q[0]), UVM_LOW);
            	end
          		else begin 
          			data_q.push_back (data_temp[31:24]);
          			data_q.push_back (data_temp[23:16]);
          			data_q.push_back (data_temp[15:8] );
          			data_q.push_back (data_temp[7:0]  );
          		end
          	end
          	else begin
          		data_q.push_back (data_temp[31:24]);
          		data_q.push_back (data_temp[23:16]);
          		data_q.push_back (data_temp[15:8] );
          		data_q.push_back (data_temp[7:0]  );
          	end
            @(posedge PCIE_RX_INTF.pcie_clk_in);
          end
	     // else begin
	    //	@(posedge PCIE_RX_INTF.pcie_clk_in);
	    //  end
	     // #2ns;
          //ssember item
          //fmt
          //data_q.print();
          ////uvm_report_info(get_type_name(), $sformatf(" monitor resv pcie data[38=%0h",data_q[0]), UVM_LOW);
          rev_frm.rev_1bit = data_q[0][7];
          rev_frm.fmt = data_q[0][6:5];
          rev_frm.typ = data_q[0][4:0];
          data_q.delete(0);
          ////uvm_report_info(get_type_name(), $sformatf(" monitor resv pcie data[38=%0h",data_q[0]), UVM_LOW);
          if (rev_frm.fmt == 2'b00)
          begin
          	rev_frm.is_3dw=1;
          	rev_frm.is_4dw=0;
          	rev_frm.is_with_data = 0;
          end
        	else  if (rev_frm.fmt == 2'b01)
          begin
          	rev_frm.is_3dw=0;
          	rev_frm.is_4dw=1;
          	rev_frm.is_with_data = 0;
          end
          else  if (rev_frm.fmt == 2'b10)
          begin
          	rev_frm.is_3dw=1;
          	rev_frm.is_4dw=0;
          	rev_frm.is_with_data = 1;
          end
          else  if (rev_frm.fmt == 2'b11)
          begin
          	rev_frm.is_3dw=0;
          	rev_frm.is_4dw=1;
          	rev_frm.is_with_data = 1;
          end
          if (rev_frm.typ == 5'b01010)
          begin
          	rev_frm.is_cpl_op=1;
          	rev_frm.is_cfg_op=0;
          	rev_frm.is_mem_io_op = 0;
          end
        	else  if (rev_frm.typ == 5'b00100 || rev_frm.typ == 5'b00101)
          begin
          	rev_frm.is_cpl_op=0;
          	rev_frm.is_cfg_op=1;
          	rev_frm.is_mem_io_op = 0;
          end
          else  if (rev_frm.typ == 5'b00000 || rev_frm.typ == 5'b00010)
          begin
          	rev_frm.is_cpl_op=0;
          	rev_frm.is_cfg_op=0;
          	rev_frm.is_mem_io_op = 1;
          end
          rev_frm.tc = data_q[0][6:4];
          rev_frm.rev_4bit = data_q[0][3:0];
          data_q.delete(0);
          //td
          rev_frm.td = data_q[0][7];
          rev_frm.ep = data_q[0][6];
          rev_frm.attr = data_q[0][5:4];
          rev_frm.length[9:8] = data_q[0][2:1];
          data_q.delete(0);
          rev_frm.length[7:0] = data_q[0][7:0];
          data_q.delete(0);
          //length
          if (rev_frm.is_mem_io_op == 1'b1)begin
          //req_id
          rev_frm.req_id[15:8] = data_q[0];
          data_q.delete(0);
          rev_frm.req_id[7:0] = data_q[0];
          data_q.delete(0);
          rev_frm.tag = data_q[0];
          data_q.delete(0);
          rev_frm.first_dw_be = data_q[0][3:0];
          rev_frm.last_dw_be = data_q[0][7:4]; 
          data_q.delete(0);
          
          if (rev_frm.is_3dw == 1'b1) begin
          	//addr32
          	rev_frm.addr32[31:24] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr32[23:16] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr32[15:8] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr32[7:2] = data_q[0][7:2];
          	rev_frm.rev_2bit    = data_q[0][1:0];
          	//rev_2bit
          	data_q.delete(0);
          	if(rev_frm.is_with_data)begin
          		rev_frm.payload=new[data_q.size];
          		payload_len = data_q.size();  
        			for (int i=0;i<payload_len;i++) begin
          	  	rev_frm.payload[i] = data_q[0];
          	  	data_q.delete(0);	
        			end 
          		
          end
          end
        	else if (rev_frm.is_4dw == 1'b1) begin
        		
          	//addr64[63:2]
          	rev_frm.addr64[63:56] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[55:48] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[47:40] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[39:32] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[31:24] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[23:16] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[15:8] = data_q[0];
          	data_q.delete(0);
          	rev_frm.addr64[7:2] = data_q[0][7:2];
          	rev_frm.rev_2bit    = data_q[0][1:0];
          	//rev_2bit
          	data_q.delete(0);
          	//rev_2bit
          	if(rev_frm.is_with_data)begin
          		//PCIE_TX_INTF.m_axis_rx_tdata <= array_bytes[i]; 
          		rev_frm.payload=new[data_q.size];
          		payload_len = data_q.size();  
        			for (int i=0;i<payload_len;i++) begin
          	  	rev_frm.payload[i] = data_q[0];
          	  	data_q.delete(0);	
        			end 
          		
          end
          end
          end
          	
          //end
          //else if (is_cfg_op)begin
          // bus_num
          
          // dev_num
          
          //fun_num
          
          //rev_4bit
          
          //ext_reg_num
          
          //reg_num
          
          //rev_2bit
          
          //end
        	if (rev_frm.is_cpl_op== 1'b1)begin
        		//cpl_id
        			rev_frm.cpl_id[15:8] = data_q[0];
        			data_q.delete(0);
        			rev_frm.cpl_id[7:0] = data_q[0];
        			data_q.delete(0);
        		//cpl_st
        			rev_frm.cpl_st = data_q[0][7:5];
        			rev_frm.bcm = data_q[0][4];
        			rev_frm.byte_cnt[11:8] = data_q[0][3:0];
        			data_q.delete(0);
        			rev_frm.byte_cnt[7:0]	= data_q[0];
        			data_q.delete(0);
        			rev_frm.req_id[15:8] = data_q[0];
        			data_q.delete(0);
        			rev_frm.req_id[7:0] = data_q[0];
        			data_q.delete(0);
        		  rev_frm.tag = data_q[0];
        		  data_q.delete(0);
        		  rev_frm.rev_1bit = data_q[0][7];
        		  rev_frm.lower_addr = data_q[0][6:0];
        		  data_q.delete(0);
        			if (rev_frm.is_with_data == 1'b1) begin
        			rev_frm.payload=new[data_q.size];
        			
        			////uvm_report_info(get_type_name(), $sformatf("data_q[0]		=%0h",data_q[0]), UVM_LOW);
        			////uvm_report_info(get_type_name(), $sformatf("data_q[1]		=%0h",data_q[1]), UVM_LOW);
        			////uvm_report_info(get_type_name(), $sformatf("data_q[2]		=%0h",data_q[2]), UVM_LOW);
        			////uvm_report_info(get_type_name(), $sformatf("data_q[3]		=%0h",data_q[3]), UVM_LOW);
        			
        			payload_len = data_q.size();  
        			for (int i=0;i<payload_len;i++) begin
          	  	rev_frm.payload[i] = data_q[0];
          	  	data_q.delete(0);	
        			end  
        			
        		end
        	end

          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp fmt		=%0h",rev_frm.fmt), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp typ		=%0h",rev_frm.typ), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp tc			=%0h",rev_frm.tc), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp td			=%0h",rev_frm.td), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp ep			=%0h",rev_frm.ep), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp attr		=%0h",rev_frm.attr), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp length	=%0d",rev_frm.length), UVM_LOW);
          //////if (rev_frm.is_mem_io_op == 1'b1) begin
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp req_id	=%0h",rev_frm.req_id), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp tag 		=%0h",rev_frm.tag), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp fst_dw_be =%0h",rev_frm.first_dw_be), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp last_dw_be =%0h",rev_frm.last_dw_be), UVM_LOW);
          //////if (rev_frm.is_3dw == 1'b1) begin
          //////   //3dw
          //////  uvm_report_info(get_type_name(), $sformatf("resv tlp addr32	=%0h",rev_frm.addr32), UVM_LOW);
          //////  if (rev_frm.is_with_data == 1'b1)
          //////	uvm_report_info(get_type_name(), $sformatf("resv tlp payload 		=%0h",rev_frm.payload), UVM_LOW);
          //////end
          //////else if (rev_frm.is_4dw == 1'b1) begin
          //////   //uvm_report_info(get_type_name(), $sformatf("resv tlp addr64	=%0h",rev_frm.addr64), UVM_LOW);
          //////  if (rev_frm.is_with_data == 1'b1)
          //////	//uvm_report_info(get_type_name(), $sformatf("resv tlp payload 		=%0h",rev_frm.payload), UVM_LOW);
          //////end
        	//////end
          //////else if (rev_frm.is_cpl_op== 1'b1) begin
          ////// //2dw
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp cpl_id		=%0h",rev_frm.cpl_id), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp cpl_st		=%0h",rev_frm.cpl_st), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp bcm			=%0h",rev_frm.bcm), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp byte_cnt	=%0h",rev_frm.byte_cnt), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp req_id		=%0h",rev_frm.req_id), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp tag			=%0h",rev_frm.tag), UVM_LOW);
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp lower_addr=%0d",rev_frm.lower_addr), UVM_LOW);
          //////if (rev_frm.is_with_data == 1'b1)
          ////////uvm_report_info(get_type_name(), $sformatf("resv tlp payload 		=%0h",rev_frm.payload), UVM_LOW);
         	//////end   
         	/////if (rev_frm.fmt[1] == 1'b1 && rev_frm.addr64[47:32]==16'h0)
         	if (uvm_report_enabled(UVM_HIGH))
         		if (rev_frm.is_3dw && (rev_frm.typ==4'b0000))
         		uvm_report_info(get_type_name(), "rev_frm.3dw ****************************************", UVM_HIGH);	
         	if (uvm_report_enabled(UVM_HIGH))
          rev_frm.print();
          out_tlp_mon_port.write(rev_frm);
          `uvm_info("PCIE_REV",$sformatf("%s",rev_frm.sprint()),UVM_HIGH);
	      	data_q.delete();/*}}}*/
        end
        begin
        	forever begin
        		wait_for_IRQ_PCIE()	;
            end
        end    
    join
  endtask:run_phase
                                                         
endclass



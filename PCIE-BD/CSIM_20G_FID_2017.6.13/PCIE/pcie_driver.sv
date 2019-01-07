
class con_idle_num;  
	rand bit [3:0] idle;
	constraint cons_idle_num{
    idle >= 0;
    idle <= 1; 
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
	parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
  
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
  
		PCIE_CLK_INTF.user_link_up   <=0;  
		PCIE_CLK_INTF.user_reset_out <=1;

    PCIE_TX_INTF.m_axis_rx_tlast  <= 0;
		PCIE_TX_INTF.m_axis_rx_tdata  <= 0;
		PCIE_TX_INTF.m_axis_rx_tkeep  <= 0;
		PCIE_TX_INTF.m_axis_rx_tvalid	<= 0;                
		PCIE_TX_INTF.m_axis_rx_tuser	<= 0;
    uvm_report_info(get_full_name(),"End of reset_dut() method ",UVM_HIGH);
  endtask : reset_dut

  virtual task clk_dut();
     
  endtask : clk_dut

  virtual task drive(pcie_tlp_item pkt);
    byte unsigned  array_bytes[];
    int pkt_len;
    int repeat_time;
    logic [7:0]	tkeep;
    int	cnt;

    pkt_len = pkt.pack_bytes(array_bytes);
    pkt_len = array_bytes.size();
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

    
    //else begin
    PCIE_TX_INTF.m_axis_rx_tlast  <= 1'b0;

    for(int i=0;i<pkt_len;i=i+PCIE_DATA_WIDTH/8) begin
      
      if (PCIE_DATA_WIDTH == 64) begin
        
        for (int j=0;j<4;j++) begin
          PCIE_TX_INTF.m_axis_rx_tdata[64-j*8-1-:8] <= array_bytes[4+j+i]; 
        end
        for (int j=0;j<4;j++) begin
          PCIE_TX_INTF.m_axis_rx_tdata[32-j*8-1-:8] <= array_bytes[j+i]; 
        end
      
        if (i >= pkt_len-8) begin
		      if (array_bytes.size()%8 != 0) begin
		        PCIE_TX_INTF.m_axis_rx_tkeep  <= 8'h0f;
		      end
		      else begin
		        PCIE_TX_INTF.m_axis_rx_tkeep  <= 8'hff;
		      end
		      PCIE_TX_INTF.m_axis_rx_tlast   <= 1'b1;
		    end 
		    else begin
		      PCIE_TX_INTF.m_axis_rx_tkeep  <= 8'hff; 
		      PCIE_TX_INTF.m_axis_rx_tlast  <= 1'b0;      
		    end

		    PCIE_TX_INTF.m_axis_rx_tvalid	<= 1'b1;                
		    PCIE_TX_INTF.m_axis_rx_tuser	<= 0;
		    //cnt <= cnt -1'b1;
		    @(posedge PCIE_TX_INTF.pcie_clk_in);

        while(!PCIE_TX_INTF.m_axis_rx_tready) begin
          @(posedge PCIE_TX_INTF.pcie_clk_in);
        end		    
		    
		    PCIE_TX_INTF.m_axis_rx_tlast  <= 1'b0;
		  end   
		  else begin
        for (int j=0;j<4;j++) begin
      
		      PCIE_TX_INTF.m_axis_rx_tdata[32-j*8-1-:8] <= array_bytes[0+j+i];         
		      
		      
		    end
		    
		    PCIE_TX_INTF.m_axis_rx_tkeep  <= 8'h0f;
		    PCIE_TX_INTF.m_axis_rx_tvalid	<= 1'b1;                
		    PCIE_TX_INTF.m_axis_rx_tuser	<= 0;

        if (i >= pkt_len-4) begin
		      PCIE_TX_INTF.m_axis_rx_tlast   <= 1'b1;
		    end 
		    else begin
		      PCIE_TX_INTF.m_axis_rx_tlast  <= 1'b0;      
		    end

		    @(posedge PCIE_TX_INTF.pcie_clk_in);


        while(!PCIE_TX_INTF.m_axis_rx_tready) begin
          @(posedge PCIE_TX_INTF.pcie_clk_in);
        end	

		    PCIE_TX_INTF.m_axis_rx_tlast  <= 1'b0;
		       
		  end
		end
    
		PCIE_TX_INTF.m_axis_rx_tlast  <= 0;
		PCIE_TX_INTF.m_axis_rx_tdata  <= 0;
		PCIE_TX_INTF.m_axis_rx_tkeep  <= 0;
		PCIE_TX_INTF.m_axis_rx_tvalid	<= 0;                
		PCIE_TX_INTF.m_axis_rx_tuser	<= 0;
    
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





 



interface pcie_intf();

	parameter         PCIE_DATA_WIDTH    =   64  ;
	parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
	
	logic															pcie_clk_in;
	logic															pcie_link_up;
	logic															pcie_reset_out;
	
	logic															user_clk_out;
	logic															user_link_up;
	logic															user_reset_out;
	
	logic	[PCIE_DATA_WIDTH-1:0]				m_axis_cq_tdata  ;
	logic [84:0]                      m_axis_cq_tuser  ;
	logic	                      			m_axis_cq_tlast  ;
	logic	[PCIE_DATA_WIDTH/32-1:0]  	m_axis_cq_tkeep  ;
	logic                             m_axis_cq_tvalid ;
	logic                             m_axis_cq_tready ;
	
	logic	[PCIE_DATA_WIDTH-1:0]				m_axis_rc_tdata  ;
	logic [84:0]                      m_axis_rc_tuser  ;
	logic	                      			m_axis_rc_tlast  ;
	logic	[PCIE_DATA_WIDTH/32-1:0]  	m_axis_rc_tkeep  ;
	logic                             m_axis_rc_tvalid ;
	logic                             m_axis_rc_tready ;
	
	logic	[PCIE_DATA_WIDTH-1:0]				s_axis_rq_tdata  ;
	logic [84:0]                      s_axis_rq_tuser  ;
	logic	                      			s_axis_rq_tlast  ;
	logic	[PCIE_DATA_WIDTH/32-1:0]  	s_axis_rq_tkeep  ;
	logic                             s_axis_rq_tvalid ;
	logic                             s_axis_rq_tready ;
	
	logic	[PCIE_DATA_WIDTH-1:0]				s_axis_cc_tdata  ;
	logic [84:0]                      s_axis_cc_tuser  ;
	logic	                      			s_axis_cc_tlast  ;
	logic	[PCIE_DATA_WIDTH/32-1:0]  	s_axis_cc_tkeep  ;
	logic                             s_axis_cc_tvalid ;
	logic                             s_axis_cc_tready ;
			
	logic															sys_clk_in			;
	logic															sys_reset_in		;
	
	modport pcie_clk_intf(input sys_clk_in,sys_reset_in,output user_clk_out,user_link_up,user_reset_out);
	
	modport pcie_tx_intf (input  pcie_clk_in     ,     //driver
	                             pcie_reset_out  ,
	                             pcie_link_up    ,
	                             
	                             m_axis_cq_tready, 
	                             
                               m_axis_rc_tready,
                                                                                                                                       
	                      output m_axis_cq_tdata ,     //CQ
	                             m_axis_cq_tuser ,
	                             m_axis_cq_tlast ,     //the final clk of write data
	                             m_axis_cq_tkeep ,     //bit 1: DW0 available  bit 0: DW1 available 
	                             m_axis_cq_tvalid,
	                             
	                             m_axis_rc_tdata ,     //RC
	                             m_axis_rc_tuser ,
	                             m_axis_rc_tlast ,
	                             m_axis_rc_tkeep ,
	                             m_axis_rc_tvalid       
	                      );
	                      
  modport pcie_rx_intf (input  pcie_clk_in     ,     //monitor
	                             pcie_reset_out  ,
	                             pcie_link_up    ,
	                             
	                             s_axis_rq_tdata ,
	                             s_axis_rq_tuser ,
	                             s_axis_rq_tlast ,    //the final clk of write data                 
	                             s_axis_rq_tkeep ,    //bit 1: DW0 available  bit 0: DW1 available  
	                             s_axis_rq_tvalid,
	                             
	                             s_axis_cc_tdata ,
	                             s_axis_cc_tuser ,
	                             s_axis_cc_tlast ,
	                             s_axis_cc_tkeep ,
	                             s_axis_cc_tvalid,
	                                                                                                                                                 
	                      output s_axis_rq_tready,
	                             
	                             s_axis_cc_tready                 
                        );
	
	
	
	
	
endinterface : pcie_intf


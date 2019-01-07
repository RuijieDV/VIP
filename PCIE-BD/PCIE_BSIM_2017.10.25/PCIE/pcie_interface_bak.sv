interface pcie_intf();

	parameter         PCIE_DATA_WIDTH    =   64  ;
	parameter					PCIE_KEEP_WIDTH		 =   PCIE_DATA_WIDTH>>2'd3;
	
	logic															pcie_clk_in;
	logic															pcie_link_up;
	logic															pcie_reset_out;
	
	logic															user_clk_out;
	logic															user_link_up;
	logic															user_reset_out;
	
	logic															s_axis_tx_tlast;
	logic	[PCIE_DATA_WIDTH-1:0]				s_axis_tx_tdata;
	logic	[PCIE_KEEP_WIDTH-1:0]				s_axis_tx_tkeep;
	logic															s_axis_tx_tvalid;
	logic															s_axis_tx_tready;
	logic	[3:0]												s_axis_tx_tuser;
	logic	[5:0]												tx_buf_av;
	logic															tx_terr_drop;
	logic															tx_cfg_req;
	logic															tx_cfg_gnt;
	
	logic															m_axis_rx_tlast;
	logic	[PCIE_DATA_WIDTH-1:0]		    m_axis_rx_tdata;
	logic	[PCIE_KEEP_WIDTH-1:0]		    m_axis_rx_tkeep;
	logic															m_axis_rx_tvalid;

	logic	[21:0]											m_axis_rx_tuser;
	logic															rx_np_ok;
	logic															m_axis_rx_tready;
	
	logic															sys_clk_in			;
	logic															sys_reset_in		;
	
	modport pcie_clk_intf(input sys_clk_in,sys_reset_in,output user_clk_out,user_link_up,user_reset_out);
	
	modport pcie_rx_intf (input  pcie_clk_in,
	                             pcie_reset_out,
	                             pcie_link_up,
	                             s_axis_tx_tlast,
	                             s_axis_tx_tdata,
	                             s_axis_tx_tkeep,
	                             s_axis_tx_tvalid,
	                             s_axis_tx_tuser,
	                             tx_cfg_gnt,
	                      output s_axis_tx_tready,
	                             tx_buf_av,
	                             tx_terr_drop,
	                             tx_cfg_req);
	                      
  modport pcie_tx_intf (output m_axis_rx_tlast,
                               m_axis_rx_tdata,                             
                               m_axis_rx_tkeep,
                               m_axis_rx_tuser,
                               m_axis_rx_tvalid,
                        input  pcie_clk_in,
                               pcie_reset_out,
                               pcie_link_up,
                               m_axis_rx_tready,
                               rx_np_ok
                        );
	
	
	
	
	
endinterface : pcie_intf


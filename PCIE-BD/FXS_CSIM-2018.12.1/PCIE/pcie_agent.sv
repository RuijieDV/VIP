


class pcie_agent extends uvm_agent;

    `uvm_component_utils(pcie_agent)

	string file_dir;
    
    reg_access_sequencer        reg_access_seqncr;
    reg_access_scoreboard       reg_access_sbd;
    addr_slave_read_rsp         reg_access_read_rsp;
    
    pcie_configuration          m_config; 
    pcie_sequencer              seqncr;
    pcie_monitor                mon;    
    
    pcie_driver                 drvr;
    pcie_scoreboard             sbd;
    pcie_sb_info_cpnt						pcie_sb_info;
    
    //up
    //eth_mac_sequencer                 mac_seqncr;
    bit			is_3dw_or_4dw  = 1'b1;              //1:3dw,0:4dw
    
    //auto seq
    reg2pcie_seq    reg2pcie;
    //reg access
    addr_slave_read_rsp_process_seq    addr_slave_read_rsp_process;
    
    
    function new(string name , uvm_component parent = null);
      super.new(name, parent);
    endfunction: new

    virtual function void build();
      super.build();
      uvm_report_info(get_full_name(),"START of build ",UVM_MEDIUM);
      
      //$display("%0s",get_full_name());
	  //added by lixu
	  if(!uvm_config_db#(string)::get(this, "", "file_dir", file_dir))
		  `uvm_fatal("FILE_DIR",{"You must be set for: ",get_full_name(),".file_dir"})
      
      if (!uvm_config_db #(pcie_configuration)::get(this, get_full_name(), "pcie_configuration",m_config))
        `uvm_fatal("Config Fatal", "Can't get the configuration")    

      seqncr = pcie_sequencer::type_id::create("seqncr",this);
      mon    = pcie_monitor::type_id::create("mon",this);
      drvr = pcie_driver::type_id::create("drvr",this);

      if (!uvm_config_db #(pcie_configuration)::get(this, get_full_name(), "pcie_configuration",drvr.m_config))
        `uvm_fatal("Config Fatal", "Can't get the configuration")   

      if (!uvm_config_db #(pcie_configuration)::get(this, get_full_name(), "pcie_configuration",mon.m_config))
        `uvm_fatal("Config Fatal", "Can't get the configuration")   
        
      sbd          = pcie_scoreboard::type_id::create("sbd",this);
      
      reg2pcie = reg2pcie_seq::type_id::create("reg2pcie",this);
      //mac_seqncr = eth_mac_sequencer::type_id::create("mac_seqncr",this);
      
      reg_access_seqncr   = reg_access_sequencer::type_id::create("reg_access_seqncr",this);
      reg_access_sbd      = reg_access_scoreboard::type_id::create("reg_access_sbd",this);
	  //added by lixu
      reg_access_sbd.file_dir = file_dir;
      reg_access_read_rsp = addr_slave_read_rsp::type_id::create("reg_access_read_rsp",this);
      pcie_sb_info				= pcie_sb_info_cpnt::type_id::create("pcie_sb_info",this);
  
      addr_slave_read_rsp_process = addr_slave_read_rsp_process_seq::type_id::create("addr_slave_read_rsp_process",this);
      
      uvm_report_info(get_full_name(),"END of build ",UVM_MEDIUM);
    endfunction
    
    virtual function void connect();
      super.connect();
      uvm_report_info(get_full_name(),"START of connect ",UVM_MEDIUM);

      mon.out_tlp_mon_port.connect(sbd.pcie_tb_mon_port);  
      sbd.write_reg_port.connect(reg_access_sbd.reg_sb_port);//!!!!!!!
     
      sbd.write_reg_port.connect(reg_access_read_rsp.addr_slave_read_rsp_export);
      //pcie_sb_info.pcie_sb_info_export.connect(seqncr.);
      sbd.out_pcie_sb_port.connect(pcie_sb_info.pcie_sb_info_export);
      //drvr.pcie_dr_out_fifo = sbd.pcie_dr_out_fifo;
      //drvr.out_mac_drv_port.connect(loop_sbd.eth_scb_tb_export);
      drvr.out_tlp_drv_port.connect(sbd.pcie_tb_drv_port);
      drvr.seq_item_port.connect(seqncr.seq_item_export);
     
      addr_slave_read_rsp_process.slave_read_rsp_fifo = reg_access_read_rsp.addr_slave_read_rsp_fifo;
      reg2pcie.info_fifo = pcie_sb_info.pcie_sb_info_fifo;//pcie_sb_info_fifo
      seqncr.reg_access_seq_item_port.connect(reg_access_seqncr.seq_item_export);
      
      uvm_report_info(get_full_name(),"END of connect ",UVM_MEDIUM);
    endfunction

  virtual task run_phase( uvm_phase phase );
    fork
      begin
      	reg2pcie.seqncr = seqncr; 
        reg2pcie.start(seqncr);
      end
      begin
        addr_slave_read_rsp_process.start(reg_access_seqncr);
      end
    join
  endtask : run_phase

endclass : pcie_agent

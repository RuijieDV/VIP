
`uvm_analysis_imp_decl(_pcie_tb_mon)

`uvm_analysis_imp_decl(_pcie_tb_drv)

class pcie_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pcie_scoreboard)
    uvm_analysis_imp_pcie_tb_mon #(pcie_tlp_item,pcie_scoreboard) pcie_tb_mon_port;
    uvm_analysis_imp_pcie_tb_drv #(pcie_tlp_item,pcie_scoreboard) pcie_tb_drv_port;
    //uvm_analysis_export #(pcie_tlp_item) drv_out_export;
    //uvm_tlm_analysis_fifo #(pcie_tlp_item) pcie_dr_out_fifo;
    uvm_analysis_port #(pcie_tlp_item) out_pcie_sb_port;
    uvm_analysis_port #(reg_access_item #(`ADDR_WIDTH,`BURSTLEN)) write_reg_port;
    uvm_analysis_port #(reg_access_item_t) reg_rd_fifo_pcie_port;
    //uvm_analysis_port #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) reg_access_item_out_port;
    function void end_of_elaboration();   
    	//this.print(); 
  	endfunction 
    
    pcie_tlp_item dr_tlp_item ;
    pcie_tlp_item out_pcie_tlp_item;
    reg_access_item #(`ADDR_WIDTH,`BURSTLEN) reg_access_item_fpga;
    reg_access_item #(`ADDR_WIDTH,`BURSTLEN) reg_access_item_cpu;
    reg_access_item #(`ADDR_WIDTH,`BURSTLEN) reg_access_item_back;               
    
		parameter   RCB_BYTES       =   128;  // Valid settings == {64, 128, 256, 512, 1024, 2048, or 4096 bytes}
		localparam	WR_MAX_LEN			= 	256;
		localparam	RD_MAX_LEN			=   512;
		localparam  RCB_REMAIN      =   (RCB_BYTES ==   64) ? 4 :
                                    ((RCB_BYTES ==  128) ? 5 :
                                ((RCB_BYTES ==  256) ? 6 :
                                 ((RCB_BYTES ==  512) ? 7 :
                                  ((RCB_BYTES == 1024) ? 8 :
                                   ((RCB_BYTES == 2048) ? 9 : 10)))));
   			
		bit		  [63:0]		  rd_addr;
		bit			[63:0]			end_addr;
		
		bit                 cpl = 1'b1;         // Set if transaction is a completion
		bit     [7:0]       my_tag;             // For transactions requiring completions, the tag which was assigned to the transaction
		
		bit     [1:0]       cpl_lowest_addr;    // Lower address for completions
		bit     [6:0]       cpl_lower_addr;     //   ..
		bit     [11:0]      cpl_bcount;         // Byte count for completions
		
		bit                 continue_i;         // Transaction tracking
		bit     [31:0]      rcbr;               //   ..
		bit     [10:0]      remain_length;      //   ..
		bit     [9:0]       length_minus1;      //   ..
		bit			[9:0]				length				;
		bit     [10:0]      length_plus_offset; //   ..
		bit                 dw_sel;             //   ..
		bit                 poisoned;
		bit                 ecrc_error;
		bit [2:0]           cpl_status;
		bit [4:0]           status_mem_bits;
		bit			[63:0]			addr;
		bit			[63:0]			dr_addr [$];
		bit			[ 7:0]			dr_tag[$]; 
		bit			[ 3:0]			dr_first_dw_be[$]; 
		bit			[ 3:0]			dr_last_dw_be[$];   
		bit			[ 3:0]			first_dw_be;
		bit			[ 3:0]      last_dw_be;
		bit			[11:0]			rd_length = 12'b0;
		bit			[11:0]			wr_length;

		integer             i  =0;                  // Loop constants
		bit		[1:0]		lowest_addr;
		
		integer             j;                  //   ..
    function new(string name, uvm_component parent);
      super.new(name, parent);
      pcie_tb_mon_port = new("pcie_tb_mon_port", this);
      pcie_tb_drv_port = new("pcie_tb_drv_port", this);
      out_pcie_sb_port = new("out_pcie_sb_port", this);
      write_reg_port   = new("write_reg_port",this);
      reg_rd_fifo_pcie_port   = new("reg_rd_fifo_pcie_port",this);
      //drv_out_export     = new("drv_out_export", this);
      //pcie_dr_out_fifo = new("pcie_dr_out_fifo", this);
    endfunction : new
  	function void connect_phase( uvm_phase phase );
        super.connect();
        //drv_out_export.connect(pcie_dr_out_fifo.analysis_export);
     endfunction
   virtual function void write_pcie_tb_mon (input pcie_tlp_item op);
    // if is_cpl_op tag = tag write to reg
    //op.print();
    //uvm_report_info(get_type_name(), "*******************************************************************", UVM_LOW);
    
    reg_access_item_fpga = reg_access_item #(`ADDR_WIDTH,`BURSTLEN)::type_id::create("reg_access_item_fpga"); 
   
    
    
    if (op.is_cpl_op)begin
    	
    	 
    	begin/////////////////////////////////////////////////////////////////////////////记得要改的~~  
    	//op.print();
    		begin
    		if (dr_tag[0] != op.tag)
    		uvm_report_error(get_type_name(),$sformatf("  tag mismatch dr_tag =%p ,op_tag = %h",dr_tag,op.tag), UVM_LOW);	
    			
    		dr_tag.delete(0);
    		addr = dr_addr[0];
    		dr_addr.delete(0);
    		first_dw_be = dr_first_dw_be[0];
    		last_dw_be = dr_last_dw_be[0];    
    		dr_first_dw_be.delete(0);
    		dr_last_dw_be.delete(0);
    		//reg_access_item_fpga.cmd = S_WR_B;
    		//reg_access_item_fpga.addr	= addr; 
    		//uvm_report_info(get_type_name(), $sformatf(" monitor resv op.first_dw_be =%0h",first_dw_be), UVM_LOW);
    		//uvm_report_info(get_type_name(), $sformatf(" monitor resv op.last_dw_be =%0h",last_dw_be), UVM_LOW);
    			begin
					case (first_dw_be)
       			4'b0000 : lowest_addr = 0; // Zero length read or write
       			4'b0001 : lowest_addr = 0;
       			4'b0010 : lowest_addr = 1;
       			4'b0011 : lowest_addr = 0;
       			4'b0100 : lowest_addr = 2;
       			4'b0101 : lowest_addr = 0;
       			4'b0110 : lowest_addr = 1;
       			4'b0111 : lowest_addr = 0;
       			4'b1000 : lowest_addr = 3;
       			4'b1001 : lowest_addr = 0;
       			4'b1010 : lowest_addr = 1;
       			4'b1011 : lowest_addr = 0;
       			4'b1100 : lowest_addr = 2;
       			4'b1101 : lowest_addr = 0;
       			4'b1110 : lowest_addr = 1;
       			4'b1111 : lowest_addr = 0;
     			endcase
     			case (last_dw_be)
           	4'b0000 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr; // undefined case
           	4'b0001 : wr_length = (((op.length-1)<<2) +4) - 3-lowest_addr;
           	4'b0010 : wr_length = (((op.length-1)<<2) +4) - 2-lowest_addr;
           	4'b0011 : wr_length = (((op.length-1)<<2) +4) - 2-lowest_addr;
           	4'b0100 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
           	4'b0101 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
           	4'b0110 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
           	4'b0111 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
           	4'b1000 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1001 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1010 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1011 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1100 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1101 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1110 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
           	4'b1111 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
       		endcase
					//assoc[op.addr32 + op.addr64 + lowest_addr + length : op.addr32 + op.addr64 + lowest_addr] = op.payload;
					
					// write acess_reg;
				reg_access_item_fpga.cmd = M_RD_S;
    		reg_access_item_fpga.addr	= addr + lowest_addr;
    		//rd_length = ( ((length-1) << 2) + (4-op.cpl_lower_addr[1:0]) );
    		uvm_report_info(get_type_name(), $sformatf(" monitor resv wr_length =%0h",wr_length), UVM_HIGH);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    		reg_access_item_fpga.rdata = new[wr_length];
    		for  ( i = 0;i<wr_length;i=i+1'b1)
    		reg_access_item_fpga.rdata[i] = op.payload[i];
    		write_reg_port.write(reg_access_item_fpga);
			//##################################################################
    		reg_rd_fifo_pcie_port.write(reg_access_item_fpga);//added by lixu
			REG_RD_FIFO_PCIE.push_back(reg_access_item_fpga);
			//##################################################################
    		if (uvm_report_enabled(UVM_HIGH))
    		reg_access_item_fpga.print();
  			end
    		
    		
    	end
    end	
    	//if (dr_tlp_item.tag == op.tag) begin
    	//	//addr          = {32'h0, addr[31:2], 2'b00}
    	//	
    	//	addr = dr_tlp_item.addr32 + dr_tlp_item.addr64 +op.lower_addr[1:0];
    	//	//cpu_reg[dr_tlp_item.addr32 + dr_tlp_item.addr64 +op.cpl_lower_addr[1:0]+op.length : dr_tlp_item.addr32 + dr_tlp_item.addr64 +op.cpl_lower_addr[1:0]] = op.payload;
    	//	reg_access_item_fpga.cmd = S_WR_B;
    	//	reg_access_item_fpga.addr	= addr;
    	//	reg_access_item_fpga.wdata = new[op.length];
    	//	for  ( i = 0;i<op.length;i=i+1'b1)
    	//	reg_access_item_fpga.wdata[i] = op.payload[i];
    	//	write_reg_port.write(reg_access_item_fpga);
    	//end
    	//else
    		//$psprintf("rd tag not match the cpl tag \n%s", this.sprint()), UVM_LOW);
    end
    // if is_mem_write write to mem
  	else if (op.is_mem_io_op)begin
  		//op.print();
  		if (op.fmt[1] == 1'b0)begin
  		  rd_length = 12'b0;
  		  length = op.length;
  		  if(op.is_4dw)
  		  	addr	= {op.addr64[63:2],2'b0};
  		  else
  		  	addr  = {32'b0,op.addr32[31:2],2'b0};
  	    cpl = 1'b1;
			  case (op.first_dw_be)
            4'b0000 : cpl_lowest_addr = 0; // Zero length read or write
            4'b0001 : cpl_lowest_addr = 0;
            4'b0010 : cpl_lowest_addr = 1;
            4'b0011 : cpl_lowest_addr = 0;
            4'b0100 : cpl_lowest_addr = 2;
            4'b0101 : cpl_lowest_addr = 0;
            4'b0110 : cpl_lowest_addr = 1;
            4'b0111 : cpl_lowest_addr = 0;
            4'b1000 : cpl_lowest_addr = 3;
            4'b1001 : cpl_lowest_addr = 0;
            4'b1010 : cpl_lowest_addr = 1;
            4'b1011 : cpl_lowest_addr = 0;
            4'b1100 : cpl_lowest_addr = 2;
            4'b1101 : cpl_lowest_addr = 0;
            4'b1110 : cpl_lowest_addr = 1;
            4'b1111 : cpl_lowest_addr = 0;
        endcase
        cpl_lower_addr = {addr[6:2], cpl_lowest_addr[1:0]};
        if (op.is_4dw)
    	  	rd_addr = op.addr64  + cpl_lower_addr[1:0];
    	  else
    	  	rd_addr = op.addr32	 + cpl_lower_addr[1:0];
    	  	  
          
        //smi_status = ram_dir.chk_ram[SMI_ADDR0_STAT][31:16];
        //byte_count
        if ((op.last_dw_be == 0) | (length == 1)) // Single DWORD read
        begin
          case (op.first_dw_be)
              4'b0000 : cpl_bcount = 1; // Zero length read or write (special case: set to 1 per PCIe Spec.)
              4'b0001 : cpl_bcount = 1;
              4'b0010 : cpl_bcount = 1;
              4'b0011 : cpl_bcount = 2;
              4'b0100 : cpl_bcount = 1;
              4'b0101 : cpl_bcount = 3;
              4'b0110 : cpl_bcount = 2;
              4'b0111 : cpl_bcount = 3;
              4'b1000 : cpl_bcount = 1;
              4'b1001 : cpl_bcount = 4;
              4'b1010 : cpl_bcount = 3;
              4'b1011 : cpl_bcount = 4;
              4'b1100 : cpl_bcount = 2;
              4'b1101 : cpl_bcount = 4;
              4'b1110 : cpl_bcount = 3;
              4'b1111 : cpl_bcount = 4;
          endcase
        end
        else begin
          // Compute completion byte count
          length_minus1 = length - 1;
          cpl_bcount    = (length_minus1 << 2) + 4; // max byte count based only on length
          
          // subtract out dword misaligned start bytes
          case (op.first_dw_be)
            4'b0000 : cpl_bcount = cpl_bcount - 0; // undefined case
            4'b0001 : cpl_bcount = cpl_bcount - 0;
            4'b0010 : cpl_bcount = cpl_bcount - 1;
            4'b0011 : cpl_bcount = cpl_bcount - 0;
            4'b0100 : cpl_bcount = cpl_bcount - 2;
            4'b0101 : cpl_bcount = cpl_bcount - 0;
            4'b0110 : cpl_bcount = cpl_bcount - 1;
            4'b0111 : cpl_bcount = cpl_bcount - 0;
            4'b1000 : cpl_bcount = cpl_bcount - 3;
            4'b1001 : cpl_bcount = cpl_bcount - 0;
            4'b1010 : cpl_bcount = cpl_bcount - 1;
            4'b1011 : cpl_bcount = cpl_bcount - 0;
            4'b1100 : cpl_bcount = cpl_bcount - 2;
            4'b1101 : cpl_bcount = cpl_bcount - 0;
            4'b1110 : cpl_bcount = cpl_bcount - 1;
            4'b1111 : cpl_bcount = cpl_bcount - 0;
          endcase
          
          // subtract out dword misaligned end bytes
          case (op.last_dw_be)
            4'b0000 : cpl_bcount = cpl_bcount - 0; // undefined case
            4'b0001 : cpl_bcount = cpl_bcount - 3;
            4'b0010 : cpl_bcount = cpl_bcount - 2;
            4'b0011 : cpl_bcount = cpl_bcount - 2;
            4'b0100 : cpl_bcount = cpl_bcount - 1;
            4'b0101 : cpl_bcount = cpl_bcount - 1;
            4'b0110 : cpl_bcount = cpl_bcount - 1;
            4'b0111 : cpl_bcount = cpl_bcount - 1;
            4'b1000 : cpl_bcount = cpl_bcount - 0;
            4'b1001 : cpl_bcount = cpl_bcount - 0;
            4'b1010 : cpl_bcount = cpl_bcount - 0;
            4'b1011 : cpl_bcount = cpl_bcount - 0;
            4'b1100 : cpl_bcount = cpl_bcount - 0;
            4'b1101 : cpl_bcount = cpl_bcount - 0;
            4'b1110 : cpl_bcount = cpl_bcount - 0;
            4'b1111 : cpl_bcount = cpl_bcount - 0;
          endcase
        end
        end_addr = rd_addr + cpl_bcount-1'b1;
    	  if (cpl_bcount > RD_MAX_LEN)
  	      uvm_report_error(get_type_name(),$sformatf("  pcie rd length =%0h,the rd length is beyond the boundary",cpl_bcount), UVM_LOW);
  	    if ((rd_addr[12]) != end_addr[12])begin
  	      uvm_report_error(get_type_name(),$sformatf("  pcie rd start addr= %0h and rd end addr = %h,and  beyond 4K boundary",rd_addr,end_addr), UVM_LOW);
  	    end
  	    
    		if (cpl) begin
    		  addr          = {addr[63:2], 2'b00}; // Zero out lower 2 bits of address
    		  remain_length = (length == 0) ? 1024 : {1'b0, length}; // Check for special case of 0 == 1024
    		end
    		
    		// Use a while loop to allow breaking a xfer command into several smaller packets
    		continue_i = 1;
    		while (continue_i == 1) begin
    		  // Break completions along RCB boundary; this is typical of actual chipset hardware when reading system memory
    		  if (cpl) begin
    		    // Compute the length for the current completion
    		    //   Max length is RCB bytes - starting address offset (Note: byte_addr[1:0] are always 00)
    		    length = (RCB_BYTES>>2) - addr[(RCB_REMAIN+1):2];
    		    
    		    // Randomize RCB
    		    rcbr = $random;
    		    case (rcbr[1:0])
    		        2'b00 :                  length = length;
    		        2'b01 : if (length > 16) length = length - 16;
    		        2'b10 : if (length > 32) length = length - 32;
    		        2'b11 : if (length > 48) length = length - 48;
    		    endcase
    		    
    		    length = (length > remain_length) ? remain_length : length;
    		    
    		    // Check for the final completion
    		    if (remain_length <= length)
    		        continue_i = 0;
    		    
    		    remain_length = remain_length - length;
    		  end
    		  else  begin
    		    // Non-completions only do one itteration through the loop
    		    continue_i = 0;
    		  end 
    		  out_pcie_tlp_item    = pcie_tlp_item::type_id::create("out_pcie_tlp_item");
    		  //uvm_report_info(get_type_name(), $sformatf(" before rd_addr rd_length =%0h",rd_length), UVM_LOW); 
    		  rd_addr = rd_addr + rd_length ; 
    		  //uvm_report_info(get_type_name(), $sformatf(" after rd_addr rd_length =%0h",rd_length), UVM_LOW);
    		  
    		  out_pcie_tlp_item.length = length;
    		  out_pcie_tlp_item.byte_cnt = cpl_bcount;
    		  out_pcie_tlp_item.lower_addr = cpl_lower_addr;
    			out_pcie_tlp_item.cpl_id		 = op.cpl_id	  ;
    			out_pcie_tlp_item.cpl_st		 = op.cpl_st	  ;
    			out_pcie_tlp_item.bcm				 = op.bcm			;
    			out_pcie_tlp_item.req_id		 = op.req_id	  ;
    			out_pcie_tlp_item.tag				 = op.tag			;
    			out_pcie_tlp_item.is_cpl_op  = 1'b1			;
    			out_pcie_tlp_item.is_with_data = 1'b1;
    			if (uvm_report_enabled(UVM_HIGH))
    			out_pcie_tlp_item.print();
    			out_pcie_sb_port.write(out_pcie_tlp_item); 
    			 
    			uvm_report_info(get_type_name(), $sformatf(" rd tag  =%0h",op.tag), UVM_HIGH);
    			rd_length = ( ((length-1) << 2) + (4-cpl_lower_addr[1:0]) );
    			//uvm_report_info(get_type_name(), $sformatf(" after rd_length =%0h",rd_length), UVM_LOW);  
    			reg_access_item_cpu  = reg_access_item #(`ADDR_WIDTH,`BURSTLEN)::type_id::create("reg_access_item_cpu");
    			reg_access_item_cpu.cmd = S_RD_B;
    			reg_access_item_cpu.addr	= rd_addr;
    			uvm_report_info(get_type_name(), $sformatf(" rd_addr  =%0h",rd_addr), UVM_HIGH);
    			
    			//rd_addr = rd_length + addr  + cpl_lower_addr[1:0]; 
    			
    			reg_access_item_cpu.rdata = new[rd_length];
    				
	  			//$display("##############################is here?#########################");
    			write_reg_port.write(reg_access_item_cpu);
    			if (uvm_report_enabled(UVM_HIGH)) reg_access_item_cpu.print();
    				
    				
    				
    		  //cpl_seq.start(m_sequencer,this);  
    		  if (cpl)	  begin
    		    cpl_bcount = cpl_bcount - ( ((length-1) << 2) + (4-cpl_lower_addr[1:0]) );
    		    cpl_lower_addr  = 0; // Always zero after 1st completion
    		    addr = addr + (length << 2);
    		    //payload[9:0] = remain_length;       // return remaining word count
    		    //if (single_completion_mode == 1'b1)
    		    //    continue_i = 0;
    		  end
    		end // while
  		end
  		else begin
				case (op.first_dw_be)
  	     4'b0000 : lowest_addr = 0; // Zero length read or write
  	     4'b0001 : lowest_addr = 0;
  	     4'b0010 : lowest_addr = 1;
  	     4'b0011 : lowest_addr = 0;
  	     4'b0100 : lowest_addr = 2;
  	     4'b0101 : lowest_addr = 0;
  	     4'b0110 : lowest_addr = 1;
  	     4'b0111 : lowest_addr = 0;
  	     4'b1000 : lowest_addr = 3;
  	     4'b1001 : lowest_addr = 0;
  	     4'b1010 : lowest_addr = 1;
  	     4'b1011 : lowest_addr = 0;
  	     4'b1100 : lowest_addr = 2;
  	     4'b1101 : lowest_addr = 0;
  	     4'b1110 : lowest_addr = 1;
  	     4'b1111 : lowest_addr = 0;
  	   endcase
  	   case (op.last_dw_be)
  	     4'b0000 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr; // undefined case
  	     4'b0001 : wr_length = (((op.length-1)<<2) +4) - 3-lowest_addr;
  	     4'b0010 : wr_length = (((op.length-1)<<2) +4) - 2-lowest_addr;
  	     4'b0011 : wr_length = (((op.length-1)<<2) +4) - 2-lowest_addr;
  	     4'b0100 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
  	     4'b0101 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
  	     4'b0110 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
  	     4'b0111 : wr_length = (((op.length-1)<<2) +4) - 1-lowest_addr;
  	     4'b1000 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1001 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1010 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1011 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1100 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1101 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1110 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	     4'b1111 : wr_length = (((op.length-1)<<2) +4) - 0-lowest_addr;
  	   endcase
			 //assoc[op.addr32 + op.addr64 + lowest_addr + length : op.addr32 + op.addr64 + lowest_addr] = op.payload;
			 //uvm_report_info(get_type_name(), $sformatf(" after op.length =%0h",op.length), UVM_LOW); 
			 //uvm_report_info(get_type_name(), $sformatf(" after rd_length =%0h",rd_length), UVM_LOW); 
			 // write acess_reg;
			 reg_access_item_cpu  = reg_access_item #(`ADDR_WIDTH,`BURSTLEN)::type_id::create("reg_access_item_cpu");
			 reg_access_item_cpu.cmd = S_WR_B;
			 if(op.is_4dw)
  	   	reg_access_item_cpu.addr	= op.addr64 + lowest_addr;
  	 	 else
  	 		reg_access_item_cpu.addr	= op.addr32 + lowest_addr;
  	   //rd_length = ( ((length-1) << 2) + (4-op.cpl_lower_addr[1:0]) );    
  	   //uvm_report_info(get_type_name(), $sformatf(" scb reg_access_item_cpu.addr =%0h",reg_access_item_cpu.addr), UVM_LOW);
  	   //uvm_report_info(get_type_name(), $sformatf(" scb wr_length =%0h",wr_length), UVM_LOW);
  	   reg_access_item_cpu.wdata = new[wr_length];
  	   end_addr = reg_access_item_cpu.addr + wr_length-1'b1;
  	   if (wr_length > WR_MAX_LEN)
  	    	uvm_report_error(get_type_name(),$sformatf("  pcie wr length =%0h,the wr length is beyond the boundary",wr_length), UVM_LOW);
  	   if ((reg_access_item_cpu.addr[12]) !=end_addr[12])begin
  	     uvm_report_error(get_type_name(),$sformatf("  pcie wr start addr= %0h and wr end addr = %h,and  beyond 4K boundary",reg_access_item_cpu.addr,end_addr), UVM_LOW);
  	   end
  	   for  ( i = 0;i<wr_length;i=i+1'b1)
  	     reg_access_item_cpu.wdata[i] = op.payload[i+lowest_addr];
  	   write_reg_port.write(reg_access_item_cpu); 
  	   //if (reg_access_item_cpu.addr == 64'h6a5a5a5a00003ec3)
  	   //uvm_report_info(get_type_name(), $sformatf(" *******************************************************************r rd_length =%0h",rd_length), UVM_LOW);
  	   if (uvm_report_enabled(UVM_HIGH)) reg_access_item_cpu.print();
  		end
  	end
        
   endfunction : write_pcie_tb_mon
   
   virtual function void write_pcie_tb_drv (input pcie_tlp_item op1);
     //addr = dr_tlp_item.addr32 + dr_tlp_item.addr64 +op.lower_addr[1:0];  
     reg_access_item_back = reg_access_item #(`ADDR_WIDTH,`BURSTLEN)::type_id::create("reg_access_item_back"); 
     //op1.print;
     if (op1.fmt[1] == 1'b0)begin
     if (op1.is_4dw)
     	
     	dr_addr.push_back(op1.addr64);
     else
     	dr_addr.push_back(op1.addr32);
  	  	dr_tag.push_back(op1.tag);
  	  	dr_first_dw_be.push_back(op1.first_dw_be);
  	  	dr_last_dw_be.push_back(op1.last_dw_be);
     end
  	  else if (op1.typ != 5'ha)
  	  begin
  	  	case (op1.first_dw_be)
       	4'b0000 : lowest_addr = 0; // Zero length read or write
       	4'b0001 : lowest_addr = 0;
       	4'b0010 : lowest_addr = 1;
       	4'b0011 : lowest_addr = 0;
       	4'b0100 : lowest_addr = 2;
       	4'b0101 : lowest_addr = 0;
       	4'b0110 : lowest_addr = 1;
       	4'b0111 : lowest_addr = 0;
       	4'b1000 : lowest_addr = 3;
       	4'b1001 : lowest_addr = 0;
       	4'b1010 : lowest_addr = 1;
       	4'b1011 : lowest_addr = 0;
       	4'b1100 : lowest_addr = 2;
       	4'b1101 : lowest_addr = 0;
       	4'b1110 : lowest_addr = 1;
       	4'b1111 : lowest_addr = 0;
      	endcase
      	case (op1.last_dw_be)
        	4'b0000 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr; // undefined case
        	4'b0001 : wr_length = (((op1.length-1)<<2) +4) - 3-lowest_addr;
        	4'b0010 : wr_length = (((op1.length-1)<<2) +4) - 2-lowest_addr;
        	4'b0011 : wr_length = (((op1.length-1)<<2) +4) - 2-lowest_addr;
        	4'b0100 : wr_length = (((op1.length-1)<<2) +4) - 1-lowest_addr;
        	4'b0101 : wr_length = (((op1.length-1)<<2) +4) - 1-lowest_addr;
        	4'b0110 : wr_length = (((op1.length-1)<<2) +4) - 1-lowest_addr;
        	4'b0111 : wr_length = (((op1.length-1)<<2) +4) - 1-lowest_addr;
        	4'b1000 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1001 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1010 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1011 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1100 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1101 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1110 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
        	4'b1111 : wr_length = (((op1.length-1)<<2) +4) - 0-lowest_addr;
       endcase
  	  	reg_access_item_back.cmd = M_WR_S;
  	  	if (op1.is_4dw)
     		reg_access_item_back.addr	= op1.addr64 + lowest_addr;
     	else
     		reg_access_item_back.addr	= op1.addr32 + lowest_addr;
     	reg_access_item_back.wdata = new[wr_length];
     	for  ( i = 0;i<wr_length;i=i+1'b1)
     	reg_access_item_back.wdata[i] = op1.payload[i];
     	write_reg_port.write(reg_access_item_back);
     	if (uvm_report_enabled(UVM_HIGH))
     	reg_access_item_back.print();
  	  end
   	
 	 	endfunction : write_pcie_tb_drv


   virtual function void report();
     uvm_report_info(get_type_name(),
     $psprintf("Scoreboard Report \n%s", this.sprint()), UVM_MEDIUM);
   endfunction : report

  
endclass : pcie_scoreboard



class pcie_sb_info_cpnt extends uvm_component;
  // UVM automation macro for sequencers
  `uvm_component_utils(pcie_sb_info_cpnt)

  uvm_analysis_export #(pcie_tlp_item) pcie_sb_info_export;
  uvm_tlm_analysis_fifo #(pcie_tlp_item) pcie_sb_info_fifo;

  //pcie_tlp_item local_frm;
  
  // Constructor - required UVM Syntax
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase( uvm_phase phase );
    //super.build();
    pcie_sb_info_fifo = new("pcie_sb_info_fifo", this);
    pcie_sb_info_export = new("pcie_sb_info_export", this);
  endfunction
  
  function void connect_phase( uvm_phase phase );
    //super.connect();
    pcie_sb_info_export.connect(pcie_sb_info_fifo.analysis_export);
  endfunction
  
endclass : pcie_sb_info_cpnt

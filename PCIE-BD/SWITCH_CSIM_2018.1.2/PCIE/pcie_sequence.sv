

class pcie_base_seq extends uvm_sequence #(pcie_tlp_item); //pcie_tlp_item
	bit [1:0]  	fmt           ;
  bit [4:0]  	typ           ;
  bit [2:0]  	tc            ;
  bit        	td            ;
  bit        	ep            ;
  bit [1:0]  	attr          ;
  bit [9:0]  	length        ;
  bit [15:0] 	req_id        ;
  bit [15:0] 	cpl_id        ;
  bit [7:0]  	tag           ;
  bit [3:0]  	first_dw_be   ;
  bit [3:0]  	last_dw_be    ;
  bit [31:0] 	addr32        ;
  bit [63:0] 	addr64        ;
  bit [7:0]  	bus_num       ;
  bit [3:0]  	dev_num       ;
  bit [3:0]  	fun_num       ;
  bit [3:0]  	ext_reg_num   ;
  bit [5:0]  	reg_num       ;
  bit [2:0]  	cpl_st        ;
  bit        	bcm           ;
  bit [11:0] 	byte_cnt      ;
  bit [6:0]  	lower_addr    ;
  bit [7:0]  	payload[]     ;
  bit       	rev_1bit      ;
  bit [1:0] 	rev_2bit      ;
  bit [3:0] 	rev_4bit      ;
  bit       	is_mem_io_op  ;
  bit       	is_cfg_op     ;
  bit       	is_cpl_op     ;
  bit       	is_with_data  ;
  bit       	is_3dw        ;
  bit       	is_4dw        ;
  
  
  function new(string name = "pcie_base_seq");
    super.new(name);
  endfunction : new

  //`uvm_sequence_utils(pcie_wr_seq, eth_sequencer)
  `uvm_object_utils(pcie_base_seq)

  pcie_tlp_item item;

  virtual task body();

    // Step 1 - Creation
    item = pcie_tlp_item::type_id::create("item");

    // Step 2 - Ready - start_item()
    start_item(item);

    // Step 3 - Set
		item.fmt           =   fmt           ;
		item.typ           =   typ           ;
		item.tc            =   tc            ;
		item.td            =   td            ;
		item.ep            =   ep            ;
		item.attr          =   attr          ;
		item.length        =   length        ;
		item.req_id        =   req_id        ;
		item.cpl_id        =   cpl_id        ;
		item.tag           =   tag           ;
		item.first_dw_be   =   first_dw_be   ;
		item.last_dw_be    =   last_dw_be    ;
		item.addr32        =   addr32        ;
		item.addr64        =   addr64        ;
		item.bus_num       =   bus_num       ;
		item.dev_num       =   dev_num       ;
		item.fun_num       =   fun_num       ;
		item.ext_reg_num   =   ext_reg_num   ;
		item.reg_num       =   reg_num       ;
		item.cpl_st        =   cpl_st        ;
		item.bcm           =   bcm           ;
		item.byte_cnt      =   byte_cnt      ;
		item.lower_addr    =   lower_addr    ;    
		item.rev_1bit      =   rev_1bit      ;
		item.rev_2bit      =   rev_2bit      ;
		item.rev_4bit      =   rev_4bit      ;
		item.is_mem_io_op  =   is_mem_io_op  ;
		item.is_cfg_op     =   is_cfg_op     ;
		item.is_cpl_op     =   is_cpl_op     ;
		item.is_with_data  =   is_with_data  ;
		item.is_3dw        =   is_3dw        ;
		item.is_4dw        =   is_4dw        ;

    item.payload.delete();
    item.payload=new[payload.size()];

    foreach (item.payload[i]) begin
      item.payload[i] = payload[i];
    end

    // Step 4 - Go - finish_item()
    finish_item(item);
    //item.print();

  endtask : body

endclass : pcie_base_seq

//////////////pcie_cpl_seq set/////////////////////
class pcie_cpl_seq extends uvm_sequence #(pcie_tlp_item);
		bit		[15:0]		cpl_id				;
		bit		[ 2:0]		cpl_st				;
		bit		[ 0:0]		bcm						;	
		bit		[15:0]		req_id				;	
		bit		[ 3:0]		first_dw_be		;
		bit		[ 3:0]		last_dw_be		;
		bit		[ 0:0]		is_with_data	;
		bit							is_cpl_op			;		
		bit		[ 9:0]		length				;
		bit   [ 2:0]		tc						;
		bit   [6:0]     cpl_lower_addr;     //   ..
		bit   [11:0]    cpl_bcount		;   
		bit		[ 7:0]		tag				;
		bit		[ 7:0]		payload[]			;

  function new(string name = "pcie_cpl_seq");
    super.new(name);
  endfunction : new

  //`uvm_sequence_utils(pcie_cpl_seq, eth_sequencer)
  `uvm_object_utils(pcie_cpl_seq)

  pcie_base_seq			base_seq;

  virtual task body();

    // Step 1 - Creation
    base_seq = pcie_base_seq::type_id::create("base_seq");
		
		base_seq.first_dw_be			= first_dw_be			;
		base_seq.last_dw_be				= last_dw_be			;
    base_seq.typ							= 5'b01010				;
    base_seq.fmt							= 2'b10						;
    base_seq.attr							= 2'b00						;
    base_seq.td								= 1'b0						;
    base_seq.ep								= 1'b0						; //poison;
    base_seq.is_cpl_op  			= 1'b1						;
    base_seq.is_with_data 		= 1'b1						;
    base_seq.cpl_id				   	= cpl_id				  ;
    base_seq.cpl_st				   	= cpl_st				  ;
    base_seq.bcm							= bcm						  ;
    base_seq.req_id				  	= req_id				  ;
    base_seq.is_with_data	  	= is_with_data	  ;
    //base_seq.is_cpl_op				= is_cpl_op			  ;
    base_seq.length				  	= length				  ;
    base_seq.tc						  	= 3'b000					;
    base_seq.lower_addr 	= cpl_lower_addr  ;
    base_seq.byte_cnt		  	= cpl_bcount		  ;
    base_seq.tag				  	= tag				  ;
    base_seq.payload.delete();
    base_seq.payload=new[payload.size()];

    foreach (payload[i]) begin
      base_seq.payload[i] = payload[i];
    end
		 base_seq.start(m_sequencer,this); 

  endtask : body

endclass : pcie_cpl_seq

class pcie_cpl_gen_seq extends uvm_sequence #(pcie_tlp_item);//from eth_sequence

	 pcie_cpl_seq cpl_seq;
  //cpl_data_packet paload_item;
		bit		[15:0]		cpl_id		;
		bit		[ 2:0]		cpl_st		;
		bit		[ 0:0]		bcm				;	
		bit		[15:0]		req_id		;	
		bit		[63:0]		addr    	;
		bit		[ 0:0]		is_with_data;
		bit		[ 7:0]		payload[]	;
		bit		[ 9:0]		length		;
		bit		[ 3:0]		first_dw_be;
		bit		[ 3:0]		last_dw_be;  
		bit   [ 2:0]		tc;
		
		bit		[63:0]		rd_addr;
		
		bit                 cpl;                // Set if transaction is a completion
		bit     [7:0]       tag;             // For transactions requiring completions, the tag which was assigned to the transaction
		
		bit     [1:0]       cpl_lowest_addr;    // Lower address for completions
		bit     [6:0]       cpl_lower_addr;     //   ..
		bit     [11:0]      cpl_bcount;         // Byte count for completions
		
		bit                 continue_i;         // Transaction tracking
		bit     [31:0]      rcbr;               //   ..
		bit     [10:0]      remain_length;      //   ..
		bit     [9:0]       length_minus1;      //   ..
		bit     [10:0]      length_plus_offset; //   ..
		bit                 dw_sel;             //   ..
		bit                 poisoned;
		bit                 ecrc_error;
		bit [2:0]           cpl_status;
		bit [4:0]           status_mem_bits;
		
		integer             i  =0;                  // Loop constants
		integer             j;                  //   ..

  function new(string name = "pcie_cpl_gen_seq");
      super.new(name);
  endfunction : new

  `uvm_sequence_utils(pcie_cpl_gen_seq, pcie_sequencer)  
  
  virtual task body();

      cpl_seq = pcie_cpl_seq::type_id::create("cpl_seq");
      //cpl_lower_addr
      
      
  endtask : body
  
endclass : pcie_cpl_gen_seq

// pcie_wr_seq
class pcie_wr_seq extends uvm_sequence #(pcie_tlp_item);
	bit [1:0]  	fmt           ;
  bit [4:0]  	typ           ;
  bit [2:0]  	tc            ;
  bit        	td            ;
  bit        	ep            ;
  bit [1:0]  	attr          ;
  bit [9:0]  	length        ;
  bit [15:0] 	req_id        ;
  bit [7:0]  	tag           ;
  bit [3:0]  	first_dw_be   ;
  bit [3:0]  	last_dw_be    ;
  bit [31:0] 	addr32        ;
  bit [63:0] 	addr64        ;
  bit [7:0]  	payload[]     ;
  bit       	rev_1bit      ;
  bit [1:0] 	rev_2bit      ;
  bit [3:0] 	rev_4bit      ;
  bit       	is_mem_io_op  ;
  bit       	is_cfg_op     ;
  bit       	is_cpl_op     ;
  bit       	is_with_data  ;
  bit       	is_3dw        ;
  bit       	is_4dw        ;	
		

  function new(string name = "pcie_wr_seq");
    super.new(name);
  endfunction : new

  //`uvm_sequence_utils(pcie_wr_seq, eth_sequencer)
  `uvm_object_utils(pcie_wr_seq)

  pcie_base_seq			base_seq;

  virtual task body();

    // Step 1 - Creation
    base_seq = pcie_base_seq::type_id::create("base_seq");

    base_seq.typ           	= 5'b00000				;
    if (is_3dw)							
    	base_seq.fmt					= 2'b10						;
    else
    	base_seq.fmt          = 2'b11						;
    base_seq.tc            	= 3'b000					;
    base_seq.td            	= 1'b0						;
    base_seq.ep            	= 1'b0						; //poison;
    base_seq.attr          	= 2'b00						;
    base_seq.length        	= length					;
    base_seq.req_id        	= req_id      		;
    base_seq.tag            = tag         		;
    base_seq.first_dw_be    = first_dw_be 		;
    base_seq.last_dw_be     = last_dw_be  		;
    base_seq.addr32         = addr32      		;
    base_seq.addr64         = addr64      		;
    base_seq.rev_1bit       = 1'b0    		;
    base_seq.rev_2bit       = 1'b0    		;
    base_seq.rev_4bit       = 1'b0    		;
    base_seq.is_mem_io_op  	= 1'b1					  ;
    base_seq.is_cfg_op     	= 1'b0   	  ;
    base_seq.is_cpl_op     	= 1'b0   	  ;
    base_seq.is_with_data  	= 1'b1					  ;
    base_seq.is_3dw        	= is_3dw      	  ;
    base_seq.is_4dw        	= is_4dw      	  ;
    base_seq.payload.delete();
    base_seq.payload=new[payload.size()];

    foreach (payload[i]) begin
      base_seq.payload[i] = payload[i];
    end
		 base_seq.start(m_sequencer,this); 

  endtask : body

endclass : pcie_wr_seq

// pcie_rd_seq
class pcie_rd_seq extends uvm_sequence #(pcie_tlp_item);
	bit [1:0]  	fmt           ;
  bit [4:0]  	typ           ;
  bit [2:0]  	tc            ;
  bit        	td            ;
  bit        	ep            ;
  bit [1:0]  	attr          ;
  bit [9:0]  	length        ;
  bit [15:0] 	req_id        ;
  bit [7:0]  	tag           ;
  bit [3:0]  	first_dw_be   ;
  bit [3:0]  	last_dw_be    ;
  bit [31:0] 	addr32        ;
  bit [63:0] 	addr64        ;
  bit [7:0]  	payload[]     ;
  bit       	rev_1bit      ;
  bit [1:0] 	rev_2bit      ;
  bit [3:0] 	rev_4bit      ;
  bit       	is_mem_io_op  ;
  bit       	is_cfg_op     ;
  bit       	is_cpl_op     ;
  bit       	is_with_data  ;
  bit       	is_3dw        ;
  bit       	is_4dw        ;	
		

  function new(string name = "pcie_rd_seq");
    super.new(name);
  endfunction : new

  //`uvm_sequence_utils(pcie_rd_seq, eth_sequencer)
  `uvm_object_utils(pcie_rd_seq)

  pcie_base_seq			base_seq;

  virtual task body();

    // Step 1 - Creation
    base_seq = pcie_base_seq::type_id::create("base_seq");

    base_seq.typ           	= 5'b00000				;
    if (is_3dw)							
    	base_seq.fmt					= 2'b00						;
    else
    	base_seq.fmt          = 2'b01						;
    base_seq.tc            	= 3'b000					;
    base_seq.td            	= 1'b0						;
    base_seq.ep            	= 1'b0						; //poison;
    base_seq.attr          	= 2'b00						;
    base_seq.length        	= length					;
    base_seq.req_id        	= req_id      		;
    base_seq.tag            = tag         		;
    base_seq.first_dw_be    = first_dw_be 		;
    base_seq.last_dw_be     = last_dw_be  		;
    base_seq.addr32         = addr32      		;
    base_seq.addr64         = addr64      		;
    base_seq.rev_1bit       = 1'b0    		;
    base_seq.rev_2bit       = 2'b0				;
    base_seq.rev_4bit       = 4'b0				;
    base_seq.is_mem_io_op  	= 1'b1					  ;
    base_seq.is_cfg_op     	= 1'b0   	  ;
    base_seq.is_cpl_op     	= 1'b0   	  ;
    base_seq.is_with_data  	= 1'b0					  ;
    base_seq.is_3dw        	= is_3dw      	  ;
    base_seq.is_4dw        	= is_4dw      	  ;
    base_seq.payload.delete();
    base_seq.payload=new[payload.size()];

    foreach (payload[i]) begin
      base_seq.payload[i] = payload[i];
    end
		 base_seq.start(m_sequencer,this); 

  endtask : body

endclass : pcie_rd_seq


class reg2pcie_seq extends uvm_sequence #(pcie_tlp_item);

  reg_access_item #(`ADDR_WIDTH,`BURSTLEN) up_item;
  uvm_tlm_analysis_fifo #(pcie_tlp_item) info_fifo;
  uvm_analysis_port #(reg_access_item #(`ADDR_WIDTH,`BURSTLEN)) write_reg_port;
  pcie_tlp_item info_item;
	pcie_sequencer   seqncr;
  
  integer j , i;
  bit		[2:0]				diff;
  bit		[7:0]				my_tag = 8'd9;
  bit   [3:0]       first_dw_be;
	bit   [3:0]       last_dw_be;
	bit   [11:0]      blength_minus1;
	bit   [63:0]      end_addr;
	bit   [9:0]       length;
	bit		[11:0]			blength;
	//bit		[4 :0]			my_tag ;
	bit		[63:0]			addr;
	bit		[7 :0]			my_tag1 = 8'b11111111;
	bit								is_3dw_or_4dw;
	int								wr_length;
	
	
	
 	pcie_cpl_seq pcie_cpl;
 	pcie_wr_seq pcie_wr;
 	pcie_rd_seq pcie_rd;
 		
	function new(string name = "");
		super.new(name); 
			  //seqncr = pcie_sequencer::type_id::create("seqncr",this);
	endfunction: new
	
	`uvm_sequence_utils(reg2pcie_seq, pcie_sequencer)  
	
	virtual task body();
	forever begin    
 
		pcie_cpl = pcie_cpl_seq::type_id::create("pcie_cpl");
		pcie_wr	 = pcie_wr_seq::type_id::create("pcie_wr");
		pcie_rd  = pcie_rd_seq::type_id::create("pcie_rd");
		is_3dw_or_4dw = seqncr.is_3dw_or_4dw;
		p_sequencer.reg_access_seq_item_port.get_next_item(up_item);
		`uvm_info("reg2pcie up_item is %0s.",up_item.sprint(),UVM_MEDIUM);
		//up_item.print();
		
		begin
			case ( up_item.cmd)
				S_RD_S,S_RD_B:begin
				  info_fifo.get(info_item);
				  //info_item.print();
				  //up_item.print();
    	    pcie_cpl.length     = info_item.length;
    	    //if ( info_item.is_3dw)
    	    pcie_cpl.cpl_lower_addr			 = info_item.lower_addr;      //maybe have
    		  //else	pcie_cpl.cpl_lower_addr = {info_item.addr64[5:2],2'b0};
    		  //pcie_cpl.first_dw_be= info_item.first_dw_be;
    		  //pcie_cpl.last_dw_be = info_item.last_dw_be;
    		  pcie_cpl.cpl_bcount = info_item.byte_cnt;
    		  pcie_cpl.cpl_id		 = `CPL_ID;
    		  pcie_cpl.cpl_st		 = `CPL_ST;
    		  pcie_cpl.bcm				 = `CPL_BCM;
    		  pcie_cpl.req_id		 = `REQ_ID;
    		  pcie_cpl.tag				 = info_item.tag;  
    		  uvm_report_info(get_type_name(), $sformatf(" up_item.addr = %0h ; info_item.tag  =%0h",up_item.addr,info_item.tag), UVM_HIGH); 
    		  //pcie_cpl.length			 = info_item.length;
    		  //pcie_cpl.is_cpl_op	
    		  pcie_cpl.is_with_data = 1'b1;
    		  pcie_cpl.is_cpl_op 	 = 1'b1;
    		  case (info_item.lower_addr[1:0])
    		  	2'b00 : diff = 0; // Zero length read or write
    	      2'b01 : diff = 1;
    	      2'b10 : diff = 2;
    	      2'b11 : diff = 3;
    	    endcase
    	    pcie_cpl.payload=new[(up_item.rdata.size+diff)];
    		  for (j = 0;j<diff;j=j+1) pcie_cpl.payload[j] = 0;										
				  foreach (up_item.rdata[i]) 
				  begin
    	      pcie_cpl.payload[i+diff] = up_item.rdata[i];
    	    end
    	    
    	    pcie_cpl.start(m_sequencer,this);
    	    //if (uvm_report_enabled(UVM_HIGH))
    		 // up_item.print();
				end
				M_WR_S,M_WR_B:begin
												case (up_item.addr[1:0])
												    2'b00 : first_dw_be = 4'hf;
												    2'b01 : first_dw_be = 4'he;
												    2'b10 : first_dw_be = 4'hc;
												    2'b11 : first_dw_be = 4'h8;
												endcase     
												//data.size()
												blength    =up_item.wdata.size();
												blength_minus1 = blength - 1;
												end_addr       = addr + blength_minus1;
												case (end_addr[1:0])
												    2'b00 : last_dw_be = 4'h1;
												    2'b01 : last_dw_be = 4'h3;
												    2'b10 : last_dw_be = 4'h7;
												    2'b11 : last_dw_be = 4'hf;
												endcase
												
												if ((addr[1:0] + blength_minus1) < 4) // single DWORD transfer
												begin
												    first_dw_be = first_dw_be & last_dw_be;
												    last_dw_be  = 4'h0;
												end
												
												// Compute length
												length = ((blength_minus1 + addr[1:0]) >> 2) + 1;
												my_tag1 = my_tag1 + 1'b1; 
												my_tag = my_tag + 1'b1;
												pcie_wr.length  		=  length      ;
												pcie_wr.tag					=  my_tag1     ;
												pcie_wr.first_dw_be =  first_dw_be ;
												pcie_wr.last_dw_be 	=  last_dw_be  ;
												pcie_wr.addr32			=  up_item.addr;
												pcie_wr.addr64			=  up_item.addr;
												pcie_wr.is_3dw			=  !is_3dw_or_4dw        ;
												pcie_wr.is_4dw			=  is_3dw_or_4dw         ; 
													if (pcie_wr.is_3dw)
													uvm_report_info(get_full_name(),"M WR head is 3dw ",UVM_MEDIUM);
													if (pcie_wr.is_4dw)
													uvm_report_info(get_full_name(),"M WR head is 4dw ",UVM_MEDIUM);
												pcie_wr.payload=new[up_item.wdata.size];
    										foreach (up_item.wdata[i]) begin
    										  pcie_wr.payload[i] = up_item.wdata[i];
    										end
												pcie_wr.start(m_sequencer,this);
												//reg_access_item_back.cmd = M_WR_B;
    										//reg_access_item_back.addr	= up_item.addr;
    										//reg_access_item_back.wdata = new[up_item.wdata.size()];
    										//wr_length = up_item.wdata.size();
    										//for  ( i = 0;i<wr_length;i=i+1'b1)
    										//reg_access_item_back.wdata[i] = up_item.wdata[i];
    										//write_reg_port.write(reg_access_item_back);
											end
				M_RD_S,M_RD_B:begin
			    // Compute first and last DWORD byte enables
			    case (up_item.addr[1:0])
			        2'b00 : first_dw_be = 4'hf;
			        2'b01 : first_dw_be = 4'he;
			        2'b10 : first_dw_be = 4'hc;
			        2'b11 : first_dw_be = 4'h8;
			    endcase     
			    blength        = up_item.rdata.size();
			    blength_minus1 = blength - 1;
			    end_addr       = addr + blength_minus1;
			    case (end_addr[1:0])
			      2'b00 : last_dw_be = 4'h1;
			      2'b01 : last_dw_be = 4'h3;
			      2'b10 : last_dw_be = 4'h7;
			      2'b11 : last_dw_be = 4'hf;
			    endcase
												
					if ((addr[1:0] + blength_minus1) < 4) // single DWORD transfer
					begin
					  first_dw_be = first_dw_be & last_dw_be;
					  last_dw_be  = 4'h0;
					end
												
					// Compute length
					length = ((blength_minus1 + addr[1:0]) >> 2) + 1;
					my_tag1 = my_tag1 + 1'b1;
					pcie_rd.length  		=  length      ;//?
					pcie_rd.tag					=  my_tag1     ;
					pcie_rd.first_dw_be =  first_dw_be ;
					pcie_rd.last_dw_be 	=  last_dw_be  ;
					pcie_rd.addr32			=  up_item.addr;
					pcie_rd.addr64			=  up_item.addr;
					pcie_rd.is_3dw			=  !is_3dw_or_4dw        ;
					pcie_rd.is_4dw			=  is_3dw_or_4dw        ;
					if (pcie_rd.is_3dw)
					uvm_report_info(get_full_name(),"M RD head is 3dw ",UVM_MEDIUM);
					if (pcie_rd.is_4dw)
					uvm_report_info(get_full_name(),"M RD head is 4dw ",UVM_MEDIUM);
					
					pcie_rd.start(m_sequencer,this);
			  end 
	  	endcase
	  	//$display("##############################item done#########################"); 
		//added bus2reg req
		//added by lixu
		`ifdef REG_MODLE
			if(up_item.cmd == M_RD_S) begin 
				reg_access_item_t rd_op;
				bit [7:0] rdata[];
				wait(REG_RD_FIFO.size() >= 1) begin 
					rd_op = REG_RD_FIFO.pop_front();
					rdata=new[`DATA_WIDTH];
					rdata = rd_op.rdata;
					`uvm_info(get_full_name(), $sformatf("[M_RD_S] addr=%0h rdata=%p",addr,rdata), UVM_MEDIUM);
					up_item.rdata = rdata;
				end
			end
		`endif
            //@2017.10.23 change for response que overflow response was dropped fro reg model
			//p_sequencer.reg_access_seq_item_port.item_done(up_item);
			p_sequencer.reg_access_seq_item_port.item_done();
		end 
		
        //forever begin
        //  #1ns;
        //  dav = m_config.lcbus_flow_m_tx_port.tx_dav;
        //end

		end
	endtask
	
endclass : reg2pcie_seq


    

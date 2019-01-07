

class reg_access_frame_seq extends uvm_sequence #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN));
  
  rand cmd_t                   cmd;
  rand bit [`ADDR_WIDTH-1:0]   addr  ;
  rand bit [7:0]               wdata [];
  rand bit [7:0]               rdata [];
  
  bit [31:0] trans_size = `DATA_WIDTH;

  function new(string name = "reg_access_frame_seq");
      super.new(name);
  endfunction : new
  
  `uvm_object_utils(reg_access_frame_seq)
    
  reg_access_item#(`ADDR_WIDTH,`BURSTLEN) item;
  
  virtual task body();
    // Step 1 - Creation
    item = reg_access_item#(`ADDR_WIDTH,`BURSTLEN)::type_id::create("item");
    
    // Step 2 - Ready - start_item()
    start_item(item);
    // Step 3 - Set
    
    item.cmd = cmd;
    //uvm_report_info(get_type_name(), $sformatf("req.cmd=%0s",cmd), UVM_LOW);
    // data 
    item.wdata.delete();
    item.wdata=new[trans_size];

    foreach (item.wdata[i]) begin
      item.wdata[i] = wdata[i];
    end

    item.rdata.delete();
    item.rdata=new[trans_size];

    foreach (item.rdata[i]) begin
      item.rdata[i] = rdata[i];
    end

    item.addr    = addr;
    
    
    // Step 4 - Go - finish_item()
    finish_item(item);
    //end  
  endtask : body
    
  virtual task s_m_write 
    ( 
      bit [`ADDR_WIDTH-1:0]   addr ,
      bit [`DATA_WIDTH*8-1:0] wdata,
      uvm_sequencer_base      seqr, 
      uvm_sequence_base       parent=null
    );
    
    this.cmd        = M_WR_S;   
    this.addr       = addr;
    this.wdata      = new[`DATA_WIDTH];
    this.trans_size = `DATA_WIDTH;
    
    for (int i=0;i<`DATA_WIDTH;i++) begin
      this.wdata[i] = wdata[`DATA_WIDTH*8-1-i*8-:8] ;
    end
    

    this.start(seqr,parent);
    
  endtask:s_m_write

  virtual task b_m_write 
    ( 
      bit [`ADDR_WIDTH-1:0]   addr   ,
      bit [15:0]              len_data,
      bit [7:0]               dt_data,
      GEN_MODE                data_gen_cmd,
      uvm_sequencer_base      seqr   , 
      uvm_sequence_base       parent=null
    );
    
    bit [7:0] data;
    
    this.cmd        = M_WR_B;   
    this.addr       = addr;
    this.wdata      = new[len_data];
    this.trans_size = len_data;
    
    if (data_gen_cmd == FIX) begin
      for (int i=0;i<len_data;i++) begin
        this.wdata[i] = dt_data;
      end
    end
    else if (data_gen_cmd == INC) begin
      data = dt_data;
      for (int i=0;i<len_data;i++) begin
        this.wdata[i] = data;
        data = data + 1;
      end
    end
    else if (data_gen_cmd == RDM) begin
      for (int i=0;i<len_data;i++) begin
        this.wdata[i] = $urandom_range(0,255);
      end
    end

    this.start(seqr,parent);
    
  endtask:b_m_write

  virtual task b_m_read
    ( 
      
      bit [`ADDR_WIDTH-1:0]   addr ,
      bit [31:0]              trans_size,
      uvm_sequencer_base      seqr, 
      uvm_sequence_base       parent=null
      
    );
    
    this.cmd        = M_RD_B;   
    this.addr       = addr;
    this.trans_size = trans_size;

    this.start(seqr,parent);
    
  endtask:b_m_read

  virtual task s_m_read
    ( 
      
      bit [`ADDR_WIDTH-1:0]   addr ,
      uvm_sequencer_base      seqr, 
      uvm_sequence_base       parent=null
      
    );
    
    this.cmd        = M_RD_S;   
    this.addr       = addr;

    this.start(seqr,parent);
    
  endtask:s_m_read

  //added by lixu
  virtual task s_m_read_with_data
    ( 
      
      bit [`ADDR_WIDTH-1:0]   addr ,
      ref bit [7:0]           rdata[],
      input uvm_sequencer_base      seqr, 
      input uvm_sequence_base       parent=null
      
    );
	reg_access_item#(`ADDR_WIDTH,`BURSTLEN) rd_op;
	fork
        this.s_m_read(addr,seqr,parent); 
	join 
	wait(REG_RD_FIFO.size() >= 1) begin 
        rd_op = REG_RD_FIFO.pop_front();
        rdata=new[`DATA_WIDTH];
        rdata = rd_op.rdata;
        
	    uvm_report_info(get_type_name(), $sformatf("[RD_S] addr=%0h rdata=%p",addr,rdata), UVM_HIGH);
	end
    
  endtask:s_m_read_with_data


  virtual task s_s_read
    ( 
      
      bit [`ADDR_WIDTH-1:0]   addr ,
      bit [7:0]               rdata[],
      uvm_sequencer_base      seqr, 
      uvm_sequence_base       parent=null
      
    );
    
    this.cmd        = S_RD_S;   
    this.addr       = addr;
    this.rdata      = new[`DATA_WIDTH];
    this.trans_size = `DATA_WIDTH;
    
    for (int i=0;i<`DATA_WIDTH;i++) begin
      this.rdata[i] = rdata[i] ;
    end

    this.start(seqr,parent);
    
  endtask:s_s_read

  virtual task b_s_read
    ( 
      
      bit [`ADDR_WIDTH-1:0]   addr ,
      bit [7:0]               rdata[],
      bit [31:0]              trans_size,
      uvm_sequencer_base      seqr, 
      uvm_sequence_base       parent=null
      
    );
    
    this.cmd        = S_RD_B;   
    this.addr       = addr;
    this.rdata      = new[trans_size];
    this.trans_size = trans_size;
    
    for (int i=0;i<trans_size;i++) begin
      this.rdata[i] = rdata[i] ;
    end

    this.start(seqr,parent);
    
  endtask:b_s_read

endclass : reg_access_frame_seq


class addr_slave_read_rsp_process_seq extends uvm_sequence #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN));
  // UVM automation macro for sequencers
  `uvm_object_utils(addr_slave_read_rsp_process_seq)
  
  reg_access_frame_seq reg_access_frame;


  uvm_tlm_analysis_fifo #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) slave_read_rsp_fifo;

  // Constructor - required UVM Syntax
  function new(string name = "addr_slave_read_rsp_process_seq");
    super.new(name);
  endfunction: new

  task body();
    
    bit [7:0] data [];

    reg_access_item#(`ADDR_WIDTH,`BURSTLEN) local_frm;
    
    forever begin                  
      slave_read_rsp_fifo.get(local_frm);
      //local_frm.print();
      //uvm_report_info(get_type_name(), $sformatf("debug go here!!!!!!!!!!!!!!!"), UVM_LOW);  
      if (local_frm.cmd == S_RD_S) begin
        data = new[`DATA_WIDTH];
        for (int i=0;i<data.size();i++) begin
          //data[i] = assoc_ram[local_frm.addr+i];
          data[i] = bd_base_seq::CPU_MEM[local_frm.addr+i];
        end
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");
        reg_access_frame.s_s_read(local_frm.addr,data,m_sequencer,null);
      end
      else if (local_frm.cmd == S_WR_S) begin
        for (int i=0;i<local_frm.wdata.size();i++) begin
          //assoc_ram[local_frm.addr+i] = local_frm.wdata[i];
          bd_base_seq::CPU_MEM[local_frm.addr+i] = local_frm.wdata[i];
        end
      end
      else if (local_frm.cmd == S_WR_B) begin
        //uvm_report_info(get_type_name(), $sformatf("local_frm.addr=%0h local_frm.wdata.size()=%0d",local_frm.addr,local_frm.wdata.size()), UVM_LOW);  
        for (int i=0;i<local_frm.wdata.size();i=i+`DATA_WIDTH) begin
          for (int j=0;j<`DATA_WIDTH;j++) begin
            if ((i+j)<local_frm.wdata.size()) begin
              bd_base_seq::CPU_MEM[local_frm.addr+i+j] = local_frm.wdata[i+j];
              //uvm_report_info(get_type_name(), $sformatf("==============>assoc_ram[%8h]=%2h i+j=%0d",local_frm.addr+i+j,assoc_ram[local_frm.addr+i+j],i+j), UVM_LOW);  
            end
          end
        end
      end      
      else if (local_frm.cmd == S_RD_B) begin
        //uvm_report_info(get_type_name(), $sformatf("local_frm.addr=%0h local_frm.blen=%0d",local_frm.addr,local_frm.rdata.size()), UVM_LOW);  
        data = new[local_frm.rdata.size()];
        for (int i=0;i<data.size();i++) begin
          data[i] = bd_base_seq::CPU_MEM[local_frm.addr+i];
        end
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");
        reg_access_frame.b_s_read(local_frm.addr,data,data.size(),m_sequencer,null);
      end                
    end                                                                                         
  endtask: body
  
endclass : addr_slave_read_rsp_process_seq


/*
class addr_slave_read_rsp_process_seq extends uvm_sequence #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN));
  // UVM automation macro for sequencers
  `uvm_object_utils(addr_slave_read_rsp_process_seq)
  
  reg_access_frame_seq reg_access_frame;


  uvm_tlm_analysis_fifo #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN)) slave_read_rsp_fifo;

  // Constructor - required UVM Syntax
  function new(string name = "addr_slave_read_rsp_process_seq");
    super.new(name);
  endfunction: new

  task body();
    
    bit [7:0] data [];

    reg_access_item#(`ADDR_WIDTH,`BURSTLEN) local_frm;
    
    forever begin                  
      slave_read_rsp_fifo.get(local_frm);
      //local_frm.print();
      //uvm_report_info(get_type_name(), $sformatf("debug go here!!!!!!!!!!!!!!!"), UVM_LOW);  
      if (local_frm.cmd == S_RD_S) begin
        data = new[`DATA_WIDTH];
        for (int i=0;i<data.size();i++) begin
          data[i] = assoc_ram[local_frm.addr+i];
        end
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");
        reg_access_frame.s_s_read(local_frm.addr,data,m_sequencer,null);
      end
      else if (local_frm.cmd == S_WR_S) begin
        for (int i=0;i<local_frm.wdata.size();i++) begin
          assoc_ram[local_frm.addr+i] = local_frm.wdata[i];
        end
      end
      else if (local_frm.cmd == S_WR_B) begin
        //uvm_report_info(get_type_name(), $sformatf("local_frm.addr=%0h local_frm.wdata.size()=%0d",local_frm.addr,local_frm.wdata.size()), UVM_LOW);  
        for (int i=0;i<local_frm.wdata.size();i=i+`DATA_WIDTH) begin
          for (int j=0;j<`DATA_WIDTH;j++) begin
            if ((i+j)<local_frm.wdata.size()) begin
              assoc_ram[local_frm.addr+i+j] = local_frm.wdata[i+j];
              //uvm_report_info(get_type_name(), $sformatf("==============>assoc_ram[%8h]=%2h i+j=%0d",local_frm.addr+i+j,assoc_ram[local_frm.addr+i+j],i+j), UVM_LOW);  
            end
          end
        end
      end      
      else if (local_frm.cmd == S_RD_B) begin
        //uvm_report_info(get_type_name(), $sformatf("local_frm.addr=%0h local_frm.blen=%0d",local_frm.addr,local_frm.rdata.size()), UVM_LOW);  
        data = new[local_frm.rdata.size()];
        for (int i=0;i<data.size();i++) begin
          data[i] = assoc_ram[local_frm.addr+i];
        end
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");
        reg_access_frame.b_s_read(local_frm.addr,data,data.size(),m_sequencer,null);
      end                
    end                                                                                         
  endtask: body
  
endclass : addr_slave_read_rsp_process_seq

*/

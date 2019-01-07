`ifdef CHUNK_WORK
class cpu_bd_ctl_process_seq extends uvm_sequence #(uvm_sequence_item);/*{{{*/
  //ctl
  bit [31:0]             send_num = 32'd100;
  
  //normal user set
  bit [`ADDR_WIDTH-1:0]  bd_addr_start = 64'h10000000_00000000;
  bit [31:0]             valid_pos     = 0; 
  bit [31:0]             owner_pos     = 1;
  bit [31:0]             bd_stream_num = 128;
  bit [31:0]             tx_addr_pos   = 191; //191 
  bit [31:0]             rx_addr_pos   = 127; //127 
  bit [31:0]             rx_len_pos    = 31; //31  
  bit [31:0]             tx_len_pos    = 47;
  bit [31:0]             rx_index_pos  = 15;
  bit [31:0]             block_len     = 65536; 
  
  //user need to set by differnt case
  //chn num
  bit [31:0]             chk_num        = 0;
  //task rx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start = 64'h6a5a5a5a_00000008;
  GEN_MODE               rx_aln_mode       = FIX;
  bit [31:0]             rx_offet_min      = 2;  
  bit [31:0]             rx_offet_max      = 2;
  //task rx_time_ctl
  //monitor for getting data form fpga gap set
  GEN_MODE               rx_gap_mode    = FIX;    
  bit [31:0]             rx_gap_min     = 2000000;
  bit [31:0]             rx_gap_max     = 2000000;
  bit [31:0]             rx_gap_step    = 2000000;
  ////task tx_data_ctl and tx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [31:0]             len_min           = 128;
  bit [31:0]             len_max           = 256;
  bit [31:0]             len_step          = 1;
  GEN_MODE               len_gen_cmd       = INC;  
  GEN_MODE               data_gen_cmd      = INC;  
  byte                   data_dt           = 8'h01;
  bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start = 64'h5a5a5a5a_00000008;
  GEN_MODE               tx_aln_mode       = FIX;
  bit [31:0]             tx_offet_min      = 2;  
  bit [31:0]             tx_offet_max      = 2;  
  //task tx_time_ctl
  //update bd_data for sending data to fpga gap set
  GEN_MODE               tx_gap_mode    = FIX;    
  bit [31:0]             tx_gap_min     = 2000000;
  bit [31:0]             tx_gap_max     = 2000000;
  bit [31:0]             tx_gap_step    = 2000000;
  //task bd_ctl
  //updata bd num
  GEN_MODE               bd_u_mode      = FIX;
  bit [31:0]             bd_u_min       = 127;
  bit [31:0]             bd_u_max       = 127;
  bit [31:0]             bd_u_step      = 1;  
  //for chunk pack type
  GEN_MODE               ctl_msg_mode   = FIX;   
  bit [31:0]             ctl_msg_min    = 1;     
  bit [31:0]             ctl_msg_max    = 1;     
  bit [31:0]             ctl_msg_step   = 1;     
  //tail
  bit [`ADDR_WIDTH-1:0]  head_h_addr = 64'h00000000_00001000;
  bit [`ADDR_WIDTH-1:0]  head_l_addr = 64'h00000000_00001004;
  bit [`ADDR_WIDTH-1:0]  tail_addr   = 64'h00000000_00001010;
  reg_access_sequencer   sqr;

  cpu_ini_addr_seq             cpu_ini_addr;
  cpu_bd_lookup_update_seq     cpu_bd_lookup ;
  cpu_get_data_seq             cpu_get_data  ;
  cpu_mon_data_seq             cpu_mon_data  ;
  
  reg_access_frame_seq         reg_access_frame;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  function new(string name = "cpu_bd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_bd_ctl_process_seq)

  virtual task body(); 
    
    fork

      begin
        //set bd
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
        reg_access_frame.s_m_write(head_h_addr,bd_addr_start[63:32],sqr);
        reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
        reg_access_frame.s_m_write(head_l_addr,bd_addr_start[31:0],sqr); 
      end 
      begin
        cpu_ini_addr = cpu_ini_addr_seq::type_id::create("cpu_ini_addr");
        cpu_ini_addr.chn_num           =  chk_num;           
        cpu_ini_addr.tx_aln_mode       =  tx_aln_mode ;
        cpu_ini_addr.tx_offet_min      =  tx_offet_min;
        cpu_ini_addr.tx_offet_max      =  tx_offet_max;           
        cpu_ini_addr.rx_aln_mode       =  rx_aln_mode ;    
        cpu_ini_addr.rx_offet_min      =  rx_offet_min;    
        cpu_ini_addr.rx_offet_max      =  rx_offet_max;         
        cpu_ini_addr.block_len         =  block_len        ;
        cpu_ini_addr.tx_buf_addr_start =  tx_buf_addr_start;
        cpu_ini_addr.rx_buf_addr_start =  rx_buf_addr_start;
        cpu_ini_addr.ctl_msg_mode      =  ctl_msg_mode;     
        cpu_ini_addr.ctl_msg_min       =  ctl_msg_min ; 
        cpu_ini_addr.ctl_msg_max       =  ctl_msg_max ; 
        cpu_ini_addr.ctl_msg_step      =  ctl_msg_step; 
        cpu_ini_addr.start(null);
      end
      begin
        cpu_mon_data = cpu_mon_data_seq::type_id::create("cpu_mon_data");
        cpu_mon_data.chn_num       = chk_num;
        cpu_mon_data.bd_addr_start = bd_addr_start;
        cpu_mon_data.valid_pos     = valid_pos;  
        cpu_mon_data.owner_pos     = owner_pos;  
        cpu_mon_data.tx_addr_pos   = tx_addr_pos;
        cpu_mon_data.rx_addr_pos   = rx_addr_pos;
        cpu_mon_data.rx_len_pos    = rx_len_pos; 
        cpu_mon_data.tx_len_pos    = tx_len_pos;
        cpu_mon_data.rx_index_pos  = rx_index_pos;
        cpu_mon_data.bd_stream_num = bd_stream_num;

        cpu_mon_data.gap_mode      = rx_gap_mode;
        cpu_mon_data.gap_min       = rx_gap_min ;
        cpu_mon_data.gap_max       = rx_gap_max ;
        cpu_mon_data.gap_step      = rx_gap_step;
        
        cpu_mon_data.start(null);

      end
      begin
        cpu_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_bd_lookup");
        
        cpu_bd_lookup.chn_num = chk_num;
        cpu_bd_lookup.trans_mode = "trx";
        
        cpu_bd_lookup.bd_addr_start = bd_addr_start;
        cpu_bd_lookup.valid_pos     = valid_pos;
        cpu_bd_lookup.owner_pos     = owner_pos;
        cpu_bd_lookup.bd_stream_num = bd_stream_num;

        cpu_bd_lookup.tail_addr      = tail_addr;
        cpu_bd_lookup.sqr            = sqr;

        cpu_bd_lookup.start(null);
      end
      begin
        cpu_get_data = cpu_get_data_seq::type_id::create("cpu_get_data");
        cpu_get_data.chn_num        = chk_num;
        cpu_get_data.trans_mode     = "trx";
        cpu_get_data.block_len      = block_len;
        cpu_get_data.send_num				= send_num;
        
        cpu_get_data.gap_mode       = tx_gap_mode;
        cpu_get_data.gap_min        = tx_gap_min ;
        cpu_get_data.gap_max        = tx_gap_max ;
        cpu_get_data.gap_step       = tx_gap_step;

        cpu_get_data.bd_u_mode      = bd_u_mode; 
        cpu_get_data.bd_u_min       = bd_u_min ; 
        cpu_get_data.bd_u_max       = bd_u_max ; 
        cpu_get_data.bd_u_step      = bd_u_step; 

        cpu_get_data.len_min        = len_min     ;
        cpu_get_data.len_max        = len_max     ;
        cpu_get_data.len_step       = len_step    ;
        cpu_get_data.len_gen_cmd    = len_gen_cmd ;
        cpu_get_data.data_gen_cmd   = data_gen_cmd;
        cpu_get_data.data_dt        = data_dt     ;
        cpu_get_data.start(null);
      end
      //chain add
      begin
        wait (cpu_mon_data.frm_cnt == send_num);
        bd_ctl_seq_done = 1'b1;
      end
    join
 
  endtask : body
  //task rx_addr_ctl
  virtual task rx_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start,
      GEN_MODE               rx_aln_mode      ,
      bit [31:0]             rx_offet_min     ,
      bit [31:0]             rx_offet_max     
    );
    
    this.rx_buf_addr_start = rx_buf_addr_start;
    this.rx_aln_mode       = rx_aln_mode      ;
    this.rx_offet_min      = rx_offet_min     ;
    this.rx_offet_max      = rx_offet_max     ;
    
  endtask:rx_addr_ctl
  //task rx_time_ctl
  virtual task rx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.rx_gap_mode = rx_gap_mode;
    this.rx_gap_min  = rx_gap_min ;
    this.rx_gap_max  = rx_gap_max ;
    this.rx_gap_step = rx_gap_step;
    
  endtask:rx_time_ctl
  //task tx_date_addr_ctl
  virtual task tx_date_addr_ctl 
    ( 
       bit [31:0]            len_min           ,
       bit [31:0]            len_max           ,
       bit [31:0]            len_step          ,
      GEN_MODE               len_gen_cmd       ,
      GEN_MODE               data_gen_cmd      ,
      byte                   data_dt           ,
      bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start ,
      GEN_MODE               tx_aln_mode       ,
      bit [31:0]             tx_offet_min      ,
      bit [31:0]             tx_offet_max      
    );
    
    this.len_min           = len_min           ;
    this.len_max           = len_max           ;
    this.len_step          = len_step          ;
    this.len_gen_cmd       = len_gen_cmd       ;
    this.data_gen_cmd      = data_gen_cmd      ;
    this.data_dt           = data_dt           ;
    
    this.tx_buf_addr_start = tx_buf_addr_start ;
    this.tx_aln_mode       = tx_aln_mode       ;
    this.tx_offet_min      = tx_offet_min      ;
    this.tx_offet_max      = tx_offet_max      ;
    
  endtask:tx_date_addr_ctl
  //task tx_time_ctl
  virtual task tx_time_ctl 
    ( 
      GEN_MODE               tx_gap_mode ,
      bit [31:0]             tx_gap_min  ,
      bit [31:0]             tx_gap_max  ,
      bit [31:0]             tx_gap_step 
    );
    
    this.tx_gap_mode = tx_gap_mode;
    this.tx_gap_min  = tx_gap_min ;
    this.tx_gap_max  = tx_gap_max ;
    this.tx_gap_step = tx_gap_step;
    
  endtask:tx_time_ctl

  //task bd_ctl
  virtual task bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.bd_u_mode = bd_u_mode;
    this.bd_u_min  = bd_u_min ;
    this.bd_u_max  = bd_u_max ;
    this.bd_u_step = bd_u_step;
    
  endtask:bd_ctl

  
endclass : cpu_bd_ctl_process_seq

  /*}}}*/
`endif

`ifdef CPM_16E1_WORK
class cpu_bd_ctl_process_seq extends uvm_sequence #(uvm_sequence_item);/*{{{*/
  //ctl
  bit [31:0]             CRC_MODE = 2;
  bit [31:0]             send_num = 32'd100;
  
  string                FILE_EXP_DIR = "./sim_out/bd_data_exp";
  string                FILE_MON_DIR = "./sim_out/bd_data_mon";
  
  //normal user set
  bit [`ADDR_WIDTH-1:0]  tx_bd_addr_start = 32'h10000000;
  bit [`ADDR_WIDTH-1:0]  rx_bd_addr_start = 32'h10001000;
  bit [31:0]             valid_pos     = 0; 
  bit [31:0]             owner_pos     = 0;
  bit [31:0]             bd_stream_num = 32;
  bit [31:0]             tx_addr_pos   = 63; //191 
  bit [31:0]             rx_addr_pos   = 63; //127 
  bit [31:0]             rx_len_pos    = 31; //31  
  bit [31:0]             tx_len_pos    = 31;
  bit [31:0]             rx_index_pos  = 31;
  bit [31:0]             block_len     = 2000;
  
  //user need to set by differnt case
  //chn num
  bit [31:0]             chn_num        = 0;
  //task rx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start = 32'h10000008;
  GEN_MODE               rx_aln_mode       = FIX;
  bit [31:0]             rx_offet_min      = 2;  
  bit [31:0]             rx_offet_max      = 2;
  //task rx_time_ctl
  //monitor for getting data form fpga gap set
  GEN_MODE               rx_mon_gap_mode    = FIX;    
  bit [31:0]             rx_mon_gap_min     = 2000000;
  bit [31:0]             rx_mon_gap_max     = 2000000;
  bit [31:0]             rx_mon_gap_step    = 2000000;
  
  GEN_MODE               tx_mon_gap_mode    = FIX;    
  bit [31:0]             tx_mon_gap_min     = 2000000;
  bit [31:0]             tx_mon_gap_max     = 2000000;
  bit [31:0]             tx_mon_gap_step    = 2000000;
  
  ////task tx_data_ctl and tx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [31:0]             len_min           = 128;
  bit [31:0]             len_max           = 256;
  bit [31:0]             len_step          = 1;
  GEN_MODE               len_gen_cmd       = INC;  
  GEN_MODE               data_gen_cmd      = INC;  
  byte                   data_dt           = 8'h01;
  bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start = 32'h10000008;
  GEN_MODE               tx_aln_mode       = FIX;
  bit [31:0]             tx_offet_min      = 2;  
  bit [31:0]             tx_offet_max      = 2;  
  //task tx_time_ctl
  //update bd_data for sending data to fpga gap set
  bit [31:0]             getdata_tx_start_time  = 2000000;
  GEN_MODE               getdata_tx_gap_mode    = FIX;    
  bit [31:0]             getdata_tx_gap_min     = 2000000;
  bit [31:0]             getdata_tx_gap_max     = 2000000;
  bit [31:0]             getdata_tx_gap_step    = 2000000;
  
  bit [31:0]             getdata_rx_start_time  = 2000000;
  GEN_MODE               getdata_rx_gap_mode    = FIX;    
  bit [31:0]             getdata_rx_gap_min     = 2000000;
  bit [31:0]             getdata_rx_gap_max     = 2000000;
  bit [31:0]             getdata_rx_gap_step    = 2000000;
  
  //task bd_ctl
  //updata bd num
  GEN_MODE               tx_bd_u_mode      = FIX;
  bit [31:0]             tx_bd_u_min       = 127;
  bit [31:0]             tx_bd_u_max       = 127;
  bit [31:0]             tx_bd_u_step      = 1;  

  GEN_MODE               rx_bd_u_mode      = FIX;
  bit [31:0]             rx_bd_u_min       = 127;
  bit [31:0]             rx_bd_u_max       = 127;
  bit [31:0]             rx_bd_u_step      = 1;  

  //tail
  //bit [`ADDR_WIDTH-1:0]  head_h_addr = 64'h00000000_00001000;
  //bit [`ADDR_WIDTH-1:0]  head_l_addr = 64'h00000000_00001004;
  bit [`ADDR_WIDTH-1:0]  tail_addr       = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr = 32'h2000101c; 
  
  reg_access_sequencer   reg_access_sqr;
  user_sequencer         rx_user_sqr;
  user_sequencer         tx_user_sqr;

  cpu_ini_addr_seq             cpu_ini_addr;
  cpu_bd_lookup_update_seq     cpu_tx_bd_lookup ;
  cpu_bd_lookup_update_seq     cpu_rx_bd_lookup ;
  cpu_get_data_seq             cpu_tx_get_data  ;
  cpu_get_data_seq             cpu_rx_get_data  ;
  cpu_mon_data_seq             cpu_tx_mon_data  ;
  cpu_mon_data_seq             cpu_rx_mon_data  ;
  
  reg_access_frame_seq         reg_access_frame;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  function new(string name = "cpu_bd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_bd_ctl_process_seq)

  virtual task body(); 

    fork

      begin
        cpu_ini_addr = cpu_ini_addr_seq::type_id::create("cpu_ini_addr");
        cpu_ini_addr.chn_num           =  chn_num;           
        cpu_ini_addr.tx_aln_mode       =  tx_aln_mode ;
        cpu_ini_addr.tx_offet_min      =  tx_offet_min;
        cpu_ini_addr.tx_offet_max      =  tx_offet_max;           
        cpu_ini_addr.rx_aln_mode       =  rx_aln_mode ;    
        cpu_ini_addr.rx_offet_min      =  rx_offet_min;    
        cpu_ini_addr.rx_offet_max      =  rx_offet_max;         
        cpu_ini_addr.block_len         =  block_len        ;
        cpu_ini_addr.tx_buf_addr_start =  tx_buf_addr_start;
        cpu_ini_addr.rx_buf_addr_start =  rx_buf_addr_start;
        cpu_ini_addr.ctl_msg_mode      =  FIX;     
        cpu_ini_addr.ctl_msg_min       =  0 ; 
        cpu_ini_addr.ctl_msg_max       =  0 ; 
        cpu_ini_addr.ctl_msg_step      =  0; 
        cpu_ini_addr.start(null);
      end
      begin
        cpu_tx_mon_data = cpu_mon_data_seq::type_id::create("cpu_tx_mon_data");
        cpu_tx_mon_data.CRC_MODE      = CRC_MODE;
        cpu_tx_mon_data.user_sqr      = rx_user_sqr;
        cpu_tx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_tx_mon_data.trans_mode    = "tx";
        cpu_tx_mon_data.chn_num       = chn_num;
        cpu_tx_mon_data.bd_addr_start = tx_bd_addr_start;
        cpu_tx_mon_data.valid_pos     = valid_pos;   
        cpu_tx_mon_data.tx_addr_pos   = tx_addr_pos;
        cpu_tx_mon_data.tx_len_pos    = tx_len_pos;
        cpu_tx_mon_data.bd_stream_num = bd_stream_num;

        cpu_tx_mon_data.gap_mode      = tx_mon_gap_mode;
        cpu_tx_mon_data.gap_min       = tx_mon_gap_min ;
        cpu_tx_mon_data.gap_max       = tx_mon_gap_max ;
        cpu_tx_mon_data.gap_step      = tx_mon_gap_step;
        
        cpu_tx_mon_data.start(null);

      end
      begin
        cpu_rx_mon_data = cpu_mon_data_seq::type_id::create("cpu_rx_mon_data");
        cpu_rx_mon_data.CRC_MODE      = CRC_MODE;
        cpu_rx_mon_data.user_sqr      = rx_user_sqr;
        cpu_rx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_rx_mon_data.trans_mode    = "rx";
        cpu_rx_mon_data.chn_num       = chn_num;
        cpu_rx_mon_data.bd_addr_start = rx_bd_addr_start;
        cpu_rx_mon_data.valid_pos     = valid_pos;   
        cpu_rx_mon_data.rx_addr_pos   = rx_addr_pos;
        cpu_rx_mon_data.rx_len_pos    = rx_len_pos; 
        cpu_rx_mon_data.rx_index_pos  = rx_index_pos;
        cpu_rx_mon_data.bd_stream_num = bd_stream_num;

        cpu_rx_mon_data.gap_mode      = rx_mon_gap_mode;
        cpu_rx_mon_data.gap_min       = rx_mon_gap_min ;
        cpu_rx_mon_data.gap_max       = rx_mon_gap_max ;
        cpu_rx_mon_data.gap_step      = rx_mon_gap_step;
        
        cpu_rx_mon_data.start(null);

      end
      begin
        cpu_tx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_tx_bd_lookup");
        
        cpu_tx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_tx_bd_lookup.chn_num = chn_num;
        cpu_tx_bd_lookup.trans_mode      = "tx";
        cpu_tx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_tx_bd_lookup.bd_addr_start   = tx_bd_addr_start;
        cpu_tx_bd_lookup.valid_pos       = valid_pos;
        cpu_tx_bd_lookup.owner_pos       = owner_pos;
        cpu_tx_bd_lookup.bd_stream_num   = bd_stream_num;
                                         
        cpu_tx_bd_lookup.tail_addr       = tail_addr;

        cpu_tx_bd_lookup.start(null);
      end
      begin
        cpu_rx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_rx_bd_lookup");
        
        cpu_rx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_rx_bd_lookup.chn_num = chn_num;
        cpu_rx_bd_lookup.trans_mode = "rx";
        cpu_rx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_rx_bd_lookup.bd_addr_start = rx_bd_addr_start;
        cpu_rx_bd_lookup.valid_pos     = valid_pos;
        cpu_rx_bd_lookup.owner_pos     = owner_pos;
        cpu_rx_bd_lookup.bd_stream_num = bd_stream_num;

        cpu_rx_bd_lookup.tail_addr      = tail_addr;

        cpu_rx_bd_lookup.start(null);
      end
      
      begin
        cpu_tx_get_data = cpu_get_data_seq::type_id::create("cpu_tx_get_data");
        
        cpu_tx_get_data.user_sqr        = tx_user_sqr;
        cpu_tx_get_data.FILE_EXP_DIR    = FILE_EXP_DIR;
        cpu_tx_get_data.chn_num         = chn_num;
        cpu_tx_get_data.trans_mode      = "tx";
        cpu_tx_get_data.block_len       = block_len;
        cpu_tx_get_data.send_num			  = send_num;
        
        cpu_tx_get_data.start_time      = getdata_tx_start_time;
        cpu_tx_get_data.gap_mode        = getdata_tx_gap_mode;
        cpu_tx_get_data.gap_min         = getdata_tx_gap_min ;
        cpu_tx_get_data.gap_max         = getdata_tx_gap_max ;
        cpu_tx_get_data.gap_step        = getdata_tx_gap_step;
                                            
        cpu_tx_get_data.bd_u_mode       = tx_bd_u_mode; 
        cpu_tx_get_data.bd_u_min        = tx_bd_u_min ; 
        cpu_tx_get_data.bd_u_max        = tx_bd_u_max ; 
        cpu_tx_get_data.bd_u_step       = tx_bd_u_step; 
                                        
        cpu_tx_get_data.len_min         = len_min     ;
        cpu_tx_get_data.len_max         = len_max     ;
        cpu_tx_get_data.len_step        = len_step    ;
        cpu_tx_get_data.len_gen_cmd     = len_gen_cmd ;
        cpu_tx_get_data.data_gen_cmd    = data_gen_cmd;
        cpu_tx_get_data.data_dt         = data_dt     ;
        cpu_tx_get_data.start(null);
      end
      begin
        cpu_rx_get_data = cpu_get_data_seq::type_id::create("cpu_rx_get_data");
        
        cpu_rx_get_data.user_sqr        = tx_user_sqr;
        cpu_rx_get_data.chn_num         = chn_num;
        cpu_rx_get_data.trans_mode      = "rx";
        cpu_rx_get_data.block_len       = block_len;
        cpu_rx_get_data.send_num			  = send_num;
        
        cpu_rx_get_data.start_time     = getdata_rx_start_time;     
        cpu_rx_get_data.gap_mode       = getdata_rx_gap_mode;
        cpu_rx_get_data.gap_min        = getdata_rx_gap_min ;
        cpu_rx_get_data.gap_max        = getdata_rx_gap_max ;
        cpu_rx_get_data.gap_step       = getdata_rx_gap_step;

        cpu_rx_get_data.bd_u_mode      = rx_bd_u_mode; 
        cpu_rx_get_data.bd_u_min       = rx_bd_u_min ; 
        cpu_rx_get_data.bd_u_max       = rx_bd_u_max ; 
        cpu_rx_get_data.bd_u_step      = rx_bd_u_step; 

        cpu_rx_get_data.start(null);
      end
      
      //chain add
      begin
        wait (cpu_tx_mon_data.frm_cnt == send_num);
        bd_ctl_seq_done = 1'b1;
      end
    join
 
  endtask : body
  //task rx_addr_ctl
  virtual task rx_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start,
      GEN_MODE               rx_aln_mode      ,
      bit [31:0]             rx_offet_min     ,
      bit [31:0]             rx_offet_max     
    );
    
    this.rx_buf_addr_start = rx_buf_addr_start;
    this.rx_aln_mode       = rx_aln_mode      ;
    this.rx_offet_min      = rx_offet_min     ;
    this.rx_offet_max      = rx_offet_max     ;
    
  endtask:rx_addr_ctl
  //task rx_time_ctl
  virtual task rx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.rx_mon_gap_mode = rx_gap_mode;
    this.rx_mon_gap_min  = rx_gap_min ;
    this.rx_mon_gap_max  = rx_gap_max ;
    this.rx_mon_gap_step = rx_gap_step;
    
  endtask:rx_time_ctl
  
  virtual task tx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.tx_mon_gap_mode = rx_gap_mode;
    this.tx_mon_gap_min  = rx_gap_min ;
    this.tx_mon_gap_max  = rx_gap_max ;
    this.tx_mon_gap_step = rx_gap_step;
    
  endtask:tx_time_ctl
  
  //task tx_date_addr_ctl
  virtual task tx_data_addr_ctl 
    ( 
       bit [31:0]            len_min           ,
       bit [31:0]            len_max           ,
       bit [31:0]            len_step          ,
      GEN_MODE               len_gen_cmd       ,
      GEN_MODE               data_gen_cmd      ,
      byte                   data_dt           ,
      bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start ,
      GEN_MODE               tx_aln_mode       ,
      bit [31:0]             tx_offet_min      ,
      bit [31:0]             tx_offet_max      
    );
    
    this.len_min           = len_min           ;
    this.len_max           = len_max           ;
    this.len_step          = len_step          ;
    this.len_gen_cmd       = len_gen_cmd       ;
    this.data_gen_cmd      = data_gen_cmd      ;
    this.data_dt           = data_dt           ;
    
    this.tx_buf_addr_start = tx_buf_addr_start ;
    this.tx_aln_mode       = tx_aln_mode       ;
    this.tx_offet_min      = tx_offet_min      ;
    this.tx_offet_max      = tx_offet_max      ;
    
  endtask:tx_data_addr_ctl
  //getdata tx_time_ctl
  virtual task getdata_tx_time_ctl 
    ( 
      bit [31:0]             tx_start_time,
      GEN_MODE               tx_gap_mode ,
      bit [31:0]             tx_gap_min  ,
      bit [31:0]             tx_gap_max  ,
      bit [31:0]             tx_gap_step 
    );
    
    this.getdata_tx_start_time = tx_start_time;
    this.getdata_tx_gap_mode   = tx_gap_mode;
    this.getdata_tx_gap_min    = tx_gap_min ;
    this.getdata_tx_gap_max    = tx_gap_max ;
    this.getdata_tx_gap_step   = tx_gap_step;
    
  endtask:getdata_tx_time_ctl
  
  //getdata rx_time_ctl
  virtual task getdata_rx_time_ctl 
    ( 
      bit [31:0]             rx_start_time,
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.getdata_rx_start_time = rx_start_time;
    this.getdata_rx_gap_mode = rx_gap_mode;
    this.getdata_rx_gap_min  = rx_gap_min ;
    this.getdata_rx_gap_max  = rx_gap_max ;
    this.getdata_rx_gap_step = rx_gap_step;
    
  endtask:getdata_rx_time_ctl
  
  //task bd_ctl
  virtual task tx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.tx_bd_u_mode = bd_u_mode;
    this.tx_bd_u_min  = bd_u_min ;
    this.tx_bd_u_max  = bd_u_max ;
    this.tx_bd_u_step = bd_u_step;
    
  endtask:tx_bd_ctl
  
  virtual task rx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.rx_bd_u_mode = bd_u_mode;
    this.rx_bd_u_min  = bd_u_min ;
    this.rx_bd_u_max  = bd_u_max ;
    this.rx_bd_u_step = bd_u_step;
    
  endtask:rx_bd_ctl
  
endclass : cpu_bd_ctl_process_seq


class m_cpu_bd_ctl_process_seq extends uvm_sequence #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN));
  
  //ctl
  bit [7:0]             chn_set;
  bit [7:0]             chn_start =0;
  bit [31:0]            bd_stream_num = 32;
  bit [31:0]            block_len     = 2000;
  bit [31:0]            send_num      = 32'd100;
  
  bit [31:0]            CRC_MODE      = 2;
  
  string                FILE_EXP_DIR = "./sim_out/bd_data_exp";
  string                FILE_MON_DIR = "./sim_out/bd_data_mon";

  bit [31:0]            len_min           ;
  bit [31:0]            len_max           ;
  bit [31:0]            len_step          ;
  GEN_MODE              len_gen_cmd       ;
  GEN_MODE              data_gen_cmd      ;
  byte                  data_dt           ;
 
  
  bit [31:0]             tx_start_time = 30000;
  bit [31:0]             rx_start_time = 20000;
  
  //tail
  bit [`ADDR_WIDTH-1:0]  ch_base               = 32'h20001000;
  bit [`ADDR_WIDTH-1:0]  tx_bd_addr_start_base = 32'h10000008; //
  bit [`ADDR_WIDTH-1:0]  rx_bd_addr_start_base = 32'h10000008+32*8*512;
  bit [`ADDR_WIDTH-1:0]  tx_buffer_start_base  = 32'h10100000+128*2000*512; //
  bit [`ADDR_WIDTH-1:0]  rx_buffer_start_base  = 32'h18000000; //
  
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr_base[`CHN_SUM]; 
  bit [`ADDR_WIDTH-1:0]  tx_bd_addr_start[`CHN_SUM]; 
  bit [`ADDR_WIDTH-1:0]  rx_bd_addr_start[`CHN_SUM]; 
  bit [`ADDR_WIDTH-1:0]  tx_buffer_start[`CHN_SUM]; 
  bit [`ADDR_WIDTH-1:0]  rx_buffer_start[`CHN_SUM];   
  
  reg_access_sequencer   reg_access_sqr;
  user_sequencer         tx_user_sqr;
  user_sequencer         rx_user_sqr;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  cpu_bd_ctl_process_seq cpu_bd_ctl_process[`CHN_SUM];
  
  function new(string name = "m_cpu_bd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(m_cpu_bd_ctl_process_seq)

  virtual task body(); 

    //if(!$cast(v_sqr, m_sequencer)) begin
    //  `uvm_error(get_full_name(), "Virtual sequencer pointer cast failed");
    //end
    
    //reg_access_sqr = v_sqr.reg_sqr; 
    //reg_access_sqr = v_sqr.reg_sqr; 
    //reg_access_sqr = v_sqr.reg_sqr; 
    
    for (int chn_i=chn_start;chn_i<chn_set;chn_i++) begin
      
      automatic int k=chn_i;
      
      fork
        begin
          
          //if (chn_i/128 == 0) begin
          //  ch_base = ch_base;
          //end
          //else if (chn_i/128 == 1) begin
          //  ch_base = ch_base+32'h0000_2000;
          //end
          //else if (chn_i/128 == 2) begin
          //  ch_base = ch_base+32'h0000_4000;
          //end
          //else if (chn_i/128 == 3) begin
          //  ch_base = ch_base+32'h0000_6000;
          //end     
          
          if (k>=0 && k<=3)  ch_base = 32'h20001000;
          if (k>=4 && k<=7)  ch_base = 32'h20001000 + 32'h0000_2000;
          
          ch_st_conf_addr_base[k] = ch_base+(k%4)*32'h0000_0020+32'h0000_001c; 
          tx_bd_addr_start[k]     = tx_bd_addr_start_base+bd_stream_num*`BD_LEN*k;
          rx_bd_addr_start[k]     = rx_bd_addr_start_base+bd_stream_num*`BD_LEN*k;
          tx_buffer_start[k]      = tx_buffer_start_base+bd_stream_num*block_len*k*16;
          rx_buffer_start[k]      = rx_buffer_start_base+bd_stream_num*block_len*k*16;
          
          cpu_bd_ctl_process[k] = cpu_bd_ctl_process_seq::type_id::create($sformatf("cpu_bd_ctl_process_%0d",k));
          cpu_bd_ctl_process[k].CRC_MODE         = CRC_MODE;
          cpu_bd_ctl_process[k].reg_access_sqr   = reg_access_sqr;
          cpu_bd_ctl_process[k].tx_user_sqr      = tx_user_sqr;
          cpu_bd_ctl_process[k].rx_user_sqr      = rx_user_sqr;
          cpu_bd_ctl_process[k].FILE_EXP_DIR     = FILE_EXP_DIR;
          cpu_bd_ctl_process[k].FILE_MON_DIR     = FILE_MON_DIR;
          cpu_bd_ctl_process[k].chn_num          = k;
          cpu_bd_ctl_process[k].send_num         = send_num;
          cpu_bd_ctl_process[k].ch_st_conf_addr  = ch_st_conf_addr_base[k];
          cpu_bd_ctl_process[k].tx_bd_addr_start = tx_bd_addr_start[k];
          cpu_bd_ctl_process[k].rx_bd_addr_start = rx_bd_addr_start[k];     
          cpu_bd_ctl_process[k].rx_addr_ctl(rx_buffer_start[k],FIX,4,4);
          cpu_bd_ctl_process[k].tx_data_addr_ctl(len_min,len_max,len_step,len_gen_cmd,data_gen_cmd,data_dt,tx_buffer_start[k],RDM,1,4);
          cpu_bd_ctl_process[k].getdata_tx_time_ctl(tx_start_time,FIX,200000,200000,0);
          cpu_bd_ctl_process[k].getdata_rx_time_ctl(rx_start_time,FIX,200000,200000,0);
          cpu_bd_ctl_process[k].tx_bd_ctl(FIX,31,31,0);
          cpu_bd_ctl_process[k].rx_bd_ctl(FIX,31,31,0);
          cpu_bd_ctl_process[k].tx_time_ctl(FIX,200000,200000,0);
          cpu_bd_ctl_process[k].rx_time_ctl(FIX,200000,200000,0);
          cpu_bd_ctl_process[k].start(null);
        end
      join_none
    end
  endtask : body
  
endclass : m_cpu_bd_ctl_process_seq

  /*}}}*/
`endif

`ifdef CLASS_HNM_4GE__SV

class cpu_txbd_ctl_process_seq extends uvm_sequence #(uvm_sequence_item);
  
  //ctl
  bit [31:0]             CRC_MODE = 2;
  bit [31:0]             send_num = 32'd100;
  
  string                 FILE_BD_LOG   = "./sim_out/bd_log"  ;
  string                 FILE_EXP_DIR  = "./sim_out/bd_data_exp";
  string                 FILE_MON_DIR  = "./sim_out/bd_data_mon";
  
  //normal user set
  bit [31:0]             tx_bd_addr_start = 32'h10000000;
  bit [31:0]             valid_pos     = 0; 
  bit [31:0]             owner_pos     = 1;
  bit [31:0]             bd_stream_num = 512;
  bit [31:0]             tx_addr_pos   = 63; //191 
  bit [31:0]             tx_len_pos    = 31;
  bit [31:0]             block_len     = 2000;
  
  //user need to set by differnt case
  //chn num
  bit [31:0]             chn_num        = 0;

  
  ////task tx_data_ctl and tx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [31:0]             len_min           = 128;
  bit [31:0]             len_max           = 256;
  bit [31:0]             len_step          = 1;
  GEN_MODE               len_gen_cmd       = INC;  
  GEN_MODE               data_gen_cmd      = INC;  
  byte                   data_dt           = 8'h01;
  bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start = 32'h10000008;
  GEN_MODE               tx_aln_mode       = FIX;
  bit [31:0]             tx_offet_min      = 2;  
  bit [31:0]             tx_offet_max      = 2;  
  //task tx_time_ctl
  //update bd_data for sending data to fpga gap set
  bit [31:0]             getdata_tx_start_time  = 2000000;
  GEN_MODE               getdata_tx_gap_mode    = FIX;    
  bit [31:0]             getdata_tx_gap_min     = 2000000;
  bit [31:0]             getdata_tx_gap_max     = 2000000;
  bit [31:0]             getdata_tx_gap_step    = 2000000;

  
  //task bd_ctl
  //updata bd num
  GEN_MODE               tx_bd_u_mode      = FIX;
  bit [31:0]             tx_bd_u_min       = 127;
  bit [31:0]             tx_bd_u_max       = 127;
  bit [31:0]             tx_bd_u_step      = 1;  


  GEN_MODE               tx_mon_gap_mode    = FIX;    
  bit [31:0]             tx_mon_gap_min     = 20000;
  bit [31:0]             tx_mon_gap_max     = 20000;
  bit [31:0]             tx_mon_gap_step    = 20000;

  //tail
  bit [`ADDR_WIDTH-1:0]  chn_addr        = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  tail_addr       = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  bd_base_addr    = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr = 32'h2000101c; 
  
  reg_access_sequencer   reg_access_sqr;
  //user_sequencer         rx_user_sqr;
  user_sequencer         tx_user_sqr;

  cpu_ini_addr_seq             cpu_ini_addr;
  cpu_bd_lookup_update_seq     cpu_tx_bd_lookup ;
  cpu_get_data_seq             cpu_tx_get_data  ;
  cpu_mon_data_seq             cpu_tx_mon_data  ;
  
  reg_access_frame_seq         reg_access_frame;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  function new(string name = "cpu_txbd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_txbd_ctl_process_seq)

  virtual task body(); 
    
    fork
      begin
      	reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame"); 
        reg_access_frame.s_m_write(bd_base_addr,tx_bd_addr_start,reg_access_sqr);
      	reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame"); 
        reg_access_frame.s_m_write(chn_addr,32'h00000001,reg_access_sqr);
      end
      begin
        cpu_ini_addr = cpu_ini_addr_seq::type_id::create("cpu_ini_addr");
        cpu_ini_addr.trans_mode        =  "tx"             ;
        cpu_ini_addr.chn_num           =  chn_num          ;           
        cpu_ini_addr.tx_aln_mode       =  tx_aln_mode      ;
        cpu_ini_addr.tx_offet_min      =  tx_offet_min     ;
        cpu_ini_addr.tx_offet_max      =  tx_offet_max     ;                
        cpu_ini_addr.block_len         =  block_len        ;
        cpu_ini_addr.tx_buf_addr_start =  tx_buf_addr_start;
        cpu_ini_addr.start(null);
      end
      begin
        cpu_tx_mon_data = cpu_mon_data_seq::type_id::create("cpu_tx_mon_data");
        cpu_tx_mon_data.CRC_MODE      = CRC_MODE;
        //cpu_tx_mon_data.user_sqr      = rx_user_sqr;
        cpu_tx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_tx_mon_data.trans_mode    = "tx";
        cpu_tx_mon_data.chn_num       = chn_num;
        cpu_tx_mon_data.bd_addr_start = tx_bd_addr_start;
        cpu_tx_mon_data.valid_pos     = valid_pos;   
        cpu_tx_mon_data.owner_pos     = owner_pos; 
        cpu_tx_mon_data.tx_addr_pos   = tx_addr_pos;
        cpu_tx_mon_data.tx_len_pos    = tx_len_pos;
        cpu_tx_mon_data.bd_stream_num = bd_stream_num;

        cpu_tx_mon_data.gap_mode      = tx_mon_gap_mode;
        cpu_tx_mon_data.gap_min       = tx_mon_gap_min ;
        cpu_tx_mon_data.gap_max       = tx_mon_gap_max ;
        cpu_tx_mon_data.gap_step      = tx_mon_gap_step;
        
        cpu_tx_mon_data.start(null);

      end

      begin
        cpu_tx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_tx_bd_lookup");
        cpu_tx_bd_lookup.FILE_BD_LOG     = FILE_BD_LOG;
        cpu_tx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_tx_bd_lookup.chn_num         = chn_num;
        cpu_tx_bd_lookup.trans_mode      = "tx";
        cpu_tx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_tx_bd_lookup.bd_addr_start   = tx_bd_addr_start;
        cpu_tx_bd_lookup.valid_pos       = valid_pos;
        cpu_tx_bd_lookup.owner_pos       = owner_pos;
        cpu_tx_bd_lookup.bd_stream_num   = bd_stream_num;                               
        cpu_tx_bd_lookup.tail_addr       = tail_addr;
        cpu_tx_bd_lookup.start(null);
      end
      
      begin
        cpu_tx_get_data = cpu_get_data_seq::type_id::create("cpu_tx_get_data");
        
        cpu_tx_get_data.user_sqr        = tx_user_sqr;
        cpu_tx_get_data.FILE_EXP_DIR    = FILE_EXP_DIR;
        cpu_tx_get_data.chn_num         = chn_num;
        cpu_tx_get_data.trans_mode      = "tx";
        cpu_tx_get_data.block_len       = block_len;
        cpu_tx_get_data.send_num			  = send_num;
        
        cpu_tx_get_data.start_time      = getdata_tx_start_time;
        cpu_tx_get_data.gap_mode        = getdata_tx_gap_mode;
        cpu_tx_get_data.gap_min         = getdata_tx_gap_min ;
        cpu_tx_get_data.gap_max         = getdata_tx_gap_max ;
        cpu_tx_get_data.gap_step        = getdata_tx_gap_step;
                                            
        cpu_tx_get_data.bd_u_mode       = tx_bd_u_mode; 
        cpu_tx_get_data.bd_u_min        = tx_bd_u_min ; 
        cpu_tx_get_data.bd_u_max        = tx_bd_u_max ; 
        cpu_tx_get_data.bd_u_step       = tx_bd_u_step; 
                                        
        cpu_tx_get_data.len_min         = len_min     ;
        cpu_tx_get_data.len_max         = len_max     ;
        cpu_tx_get_data.len_step        = len_step    ;
        cpu_tx_get_data.len_gen_cmd     = len_gen_cmd ;
        cpu_tx_get_data.data_gen_cmd    = data_gen_cmd;
        cpu_tx_get_data.data_dt         = data_dt     ;
        cpu_tx_get_data.start(null);
      end
      
      //chain add
      begin
        wait (cpu_tx_mon_data.frm_cnt == send_num);
        bd_ctl_seq_done = 1'b1;
      end
    join
 
  endtask : body

  virtual task tx_time_ctl 
    ( 
      GEN_MODE               tx_gap_mode ,
      bit [31:0]             tx_gap_min  ,
      bit [31:0]             tx_gap_max  ,
      bit [31:0]             tx_gap_step 
    );
    
    this.tx_mon_gap_mode = tx_gap_mode;
    this.tx_mon_gap_min  = tx_gap_min ;
    this.tx_mon_gap_max  = tx_gap_max ;
    this.tx_mon_gap_step = tx_gap_step;
    
  endtask:tx_time_ctl
  
  //task tx_date_addr_ctl
  virtual task tx_data_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start ,
      GEN_MODE               tx_aln_mode       ,
      bit [31:0]             tx_offet_min      ,
      bit [31:0]             tx_offet_max      ,
      bit [31:0]             len_min           ,
      bit [31:0]             len_max           ,
      bit [31:0]             len_step          ,
      GEN_MODE               len_gen_cmd       ,
      GEN_MODE               data_gen_cmd      ,
      byte                   data_dt           

    );
    
    this.len_min           = len_min           ;
    this.len_max           = len_max           ;
    this.len_step          = len_step          ;
    this.len_gen_cmd       = len_gen_cmd       ;
    this.data_gen_cmd      = data_gen_cmd      ;
    this.data_dt           = data_dt           ;
    
    this.tx_buf_addr_start = tx_buf_addr_start ;
    this.tx_aln_mode       = tx_aln_mode       ;
    this.tx_offet_min      = tx_offet_min      ;
    this.tx_offet_max      = tx_offet_max      ;
    
  endtask:tx_data_addr_ctl
  //getdata tx_time_ctl
  virtual task getdata_tx_time_ctl 
    ( 
      bit [31:0]             tx_start_time,
      GEN_MODE               tx_gap_mode ,
      bit [31:0]             tx_gap_min  ,
      bit [31:0]             tx_gap_max  ,
      bit [31:0]             tx_gap_step 
    );
    
    this.getdata_tx_start_time = tx_start_time;
    this.getdata_tx_gap_mode   = tx_gap_mode;
    this.getdata_tx_gap_min    = tx_gap_min ;
    this.getdata_tx_gap_max    = tx_gap_max ;
    this.getdata_tx_gap_step   = tx_gap_step;
    
  endtask:getdata_tx_time_ctl
  
  //task bd_ctl
  virtual task tx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.tx_bd_u_mode = bd_u_mode;
    this.tx_bd_u_min  = bd_u_min ;
    this.tx_bd_u_max  = bd_u_max ;
    this.tx_bd_u_step = bd_u_step;
    
  endtask:tx_bd_ctl
  
  
endclass : cpu_txbd_ctl_process_seq

class cpu_rxbd_ctl_process_seq extends uvm_sequence #(uvm_sequence_item);
  
  //ctl
  bit [31:0]             CRC_MODE = 0;
  
  string                 FILE_BD_LOG   = "./sim_out/bd_log"  ;
  string                 FILE_MON_DIR  = "./sim_out/bd_data_mon";
  
  //normal user set
  bit [31:0]             rx_bd_addr_start = 32'h10001000;
  bit [31:0]             valid_pos     = 0; 
  bit [31:0]             owner_pos     = 1;
  bit [31:0]             bd_stream_num = 512;
  bit [31:0]             rx_addr_pos   = 63; //127 
  bit [31:0]             rx_len_pos    = 31; //31  
  bit [31:0]             rx_port_pos   = 19;
  bit [31:0]             rx_index_pos  = 15;
  bit [31:0]             block_len     = 2000;
  
  //user need to set by differnt case
  //chn num
  bit [31:0]             chn_num        = 0;
  //task rx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start = 32'h10000008;
  GEN_MODE               rx_aln_mode       = FIX;
  bit [31:0]             rx_offet_min      = 2;  
  bit [31:0]             rx_offet_max      = 2;
  //task rx_time_ctl
  //monitor for getting data form fpga gap set
  GEN_MODE               rx_mon_gap_mode    = FIX;    
  bit [31:0]             rx_mon_gap_min     = 2000000;
  bit [31:0]             rx_mon_gap_max     = 2000000;
  bit [31:0]             rx_mon_gap_step    = 2000000;
  
  
  bit [31:0]             getdata_rx_start_time  = 2000000;
  GEN_MODE               getdata_rx_gap_mode    = FIX;    
  bit [31:0]             getdata_rx_gap_min     = 2000000;
  bit [31:0]             getdata_rx_gap_max     = 2000000;
  bit [31:0]             getdata_rx_gap_step    = 2000000;
  

  GEN_MODE               rx_bd_u_mode      = FIX;
  bit [31:0]             rx_bd_u_min       = 127;
  bit [31:0]             rx_bd_u_max       = 127;
  bit [31:0]             rx_bd_u_step      = 1;  

  //tail
  bit [`ADDR_WIDTH-1:0]  chn_addr        = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  tail_addr       = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  bd_base_addr    = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr = 32'h2000101c; 
  
  reg_access_sequencer   reg_access_sqr;
  user_sequencer         rx_user_sqr;
  //user_sequencer         tx_user_sqr;

  cpu_ini_addr_seq             cpu_ini_addr;
  cpu_bd_lookup_update_seq     cpu_rx_bd_lookup ;
  cpu_get_data_seq             cpu_rx_get_data  ;
  cpu_mon_data_seq             cpu_rx_mon_data  ;
  
  reg_access_frame_seq         reg_access_frame;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  function new(string name = "cpu_rxbd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_rxbd_ctl_process_seq)

  virtual task body(); 
    
    fork
      begin
      	reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame"); 
        reg_access_frame.s_m_write(bd_base_addr,rx_bd_addr_start,reg_access_sqr);
      	reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame"); 
        reg_access_frame.s_m_write(chn_addr,32'h00000001,reg_access_sqr);
      end
      begin
        cpu_ini_addr = cpu_ini_addr_seq::type_id::create("cpu_ini_addr");
        cpu_ini_addr.trans_mode        =  "rx";
        cpu_ini_addr.chn_num           =  chn_num;                  
        cpu_ini_addr.rx_aln_mode       =  rx_aln_mode ;    
        cpu_ini_addr.rx_offet_min      =  rx_offet_min;    
        cpu_ini_addr.rx_offet_max      =  rx_offet_max;         
        cpu_ini_addr.block_len         =  block_len        ;
        cpu_ini_addr.rx_buf_addr_start =  rx_buf_addr_start;
        cpu_ini_addr.start(null);
      end
      begin
        cpu_rx_mon_data = cpu_mon_data_seq::type_id::create("cpu_rx_mon_data");
        cpu_rx_mon_data.CRC_MODE      = CRC_MODE;
        cpu_rx_mon_data.user_sqr      = rx_user_sqr;
        cpu_rx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_rx_mon_data.trans_mode    = "rx";
        cpu_rx_mon_data.chn_num       = chn_num;
        cpu_rx_mon_data.bd_addr_start = rx_bd_addr_start;
        cpu_rx_mon_data.valid_pos     = valid_pos;  
        cpu_rx_mon_data.owner_pos     = owner_pos;  
        cpu_rx_mon_data.rx_addr_pos   = rx_addr_pos;
        cpu_rx_mon_data.rx_len_pos    = rx_len_pos; 
        cpu_rx_mon_data.rx_port_pos   = rx_port_pos;
        cpu_rx_mon_data.bd_stream_num = bd_stream_num;

        cpu_rx_mon_data.gap_mode      = rx_mon_gap_mode;
        cpu_rx_mon_data.gap_min       = rx_mon_gap_min ;
        cpu_rx_mon_data.gap_max       = rx_mon_gap_max ;
        cpu_rx_mon_data.gap_step      = rx_mon_gap_step;
        
        cpu_rx_mon_data.start(null);

      end
      begin
        cpu_rx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_rx_bd_lookup");
        cpu_rx_bd_lookup.FILE_BD_LOG     = FILE_BD_LOG;
        cpu_rx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_rx_bd_lookup.chn_num         = chn_num;
        cpu_rx_bd_lookup.trans_mode      = "rx";
        cpu_rx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_rx_bd_lookup.bd_addr_start   = rx_bd_addr_start;
        cpu_rx_bd_lookup.valid_pos       = valid_pos;
        cpu_rx_bd_lookup.owner_pos       = owner_pos;
        cpu_rx_bd_lookup.bd_stream_num   = bd_stream_num;

        cpu_rx_bd_lookup.tail_addr       = tail_addr;

        cpu_rx_bd_lookup.start(null);
      end
      begin
        cpu_rx_get_data = cpu_get_data_seq::type_id::create("cpu_rx_get_data");
        
        //cpu_rx_get_data.user_sqr        = tx_user_sqr;
        cpu_rx_get_data.chn_num         = chn_num;
        cpu_rx_get_data.trans_mode      = "rx";
        cpu_rx_get_data.block_len       = block_len;
        
        cpu_rx_get_data.start_time     = getdata_rx_start_time;     
        cpu_rx_get_data.gap_mode       = getdata_rx_gap_mode;
        cpu_rx_get_data.gap_min        = getdata_rx_gap_min ;
        cpu_rx_get_data.gap_max        = getdata_rx_gap_max ;
        cpu_rx_get_data.gap_step       = getdata_rx_gap_step;

        cpu_rx_get_data.bd_u_mode      = rx_bd_u_mode; 
        cpu_rx_get_data.bd_u_min       = rx_bd_u_min ; 
        cpu_rx_get_data.bd_u_max       = rx_bd_u_max ; 
        cpu_rx_get_data.bd_u_step      = rx_bd_u_step; 

        cpu_rx_get_data.start(null);
      end
      
    join
 
  endtask : body
  //task rx_addr_ctl
  virtual task rx_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start,
      GEN_MODE               rx_aln_mode      ,
      bit [31:0]             rx_offet_min     ,
      bit [31:0]             rx_offet_max     
    );
    
    this.rx_buf_addr_start = rx_buf_addr_start;
    this.rx_aln_mode       = rx_aln_mode      ;
    this.rx_offet_min      = rx_offet_min     ;
    this.rx_offet_max      = rx_offet_max     ;
    
  endtask:rx_addr_ctl
  //task rx_time_ctl
  virtual task rx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.rx_mon_gap_mode = rx_gap_mode;
    this.rx_mon_gap_min  = rx_gap_min ;
    this.rx_mon_gap_max  = rx_gap_max ;
    this.rx_mon_gap_step = rx_gap_step;
    
  endtask:rx_time_ctl
  
  
  //getdata rx_time_ctl
  virtual task getdata_rx_time_ctl 
    ( 
      bit [31:0]             rx_start_time,
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.getdata_rx_start_time = rx_start_time;
    this.getdata_rx_gap_mode = rx_gap_mode;
    this.getdata_rx_gap_min  = rx_gap_min ;
    this.getdata_rx_gap_max  = rx_gap_max ;
    this.getdata_rx_gap_step = rx_gap_step;
    
  endtask:getdata_rx_time_ctl
  
  virtual task rx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.rx_bd_u_mode = bd_u_mode;
    this.rx_bd_u_min  = bd_u_min ;
    this.rx_bd_u_max  = bd_u_max ;
    this.rx_bd_u_step = bd_u_step;
    
  endtask:rx_bd_ctl
  
endclass : cpu_rxbd_ctl_process_seq


class cpu_bd_ctl_process_seq extends uvm_sequence #(uvm_sequence_item);
  /*{{{*/
  //ctl
  bit [31:0]             CRC_MODE = 2;
  bit [31:0]             send_num = 32'd100;
  
  string                 FILE_BD_LOG   = "./sim_out/bd_log"  ;
  string                 FILE_EXP_DIR  = "./sim_out/bd_data_exp";
  string                 FILE_MON_DIR  = "./sim_out/bd_data_mon";
  
  //normal user set
  bit [31:0]             tx_bd_addr_start = 32'h10000000;
  bit [31:0]             rx_bd_addr_start = 32'h10001000;
  bit [31:0]             valid_pos     = 0; 
  bit [31:0]             owner_pos     = 1;
  bit [31:0]             bd_stream_num = 512;
  bit [31:0]             tx_addr_pos   = 63; //191 
  bit [31:0]             rx_addr_pos   = 63; //127 
  bit [31:0]             rx_len_pos    = 31; //31  
  bit [31:0]             tx_len_pos    = 31;
  bit [31:0]             rx_index_pos  = 15;
  bit [31:0]             block_len     = 2000;
  
  //user need to set by differnt case
  //chn num
  bit [31:0]             chn_num        = 0;
  //task rx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start = 32'h10000008;
  GEN_MODE               rx_aln_mode       = FIX;
  bit [31:0]             rx_offet_min      = 2;  
  bit [31:0]             rx_offet_max      = 2;
  //task rx_time_ctl
  //monitor for getting data form fpga gap set
  GEN_MODE               rx_mon_gap_mode    = FIX;    
  bit [31:0]             rx_mon_gap_min     = 2000000;
  bit [31:0]             rx_mon_gap_max     = 2000000;
  bit [31:0]             rx_mon_gap_step    = 2000000;
  
  GEN_MODE               tx_mon_gap_mode    = FIX;    
  bit [31:0]             tx_mon_gap_min     = 2000000;
  bit [31:0]             tx_mon_gap_max     = 2000000;
  bit [31:0]             tx_mon_gap_step    = 2000000;
  
  ////task tx_data_ctl and tx_addr_ctl
  //generate tx data and tx_buffer addr
  bit [31:0]             len_min           = 128;
  bit [31:0]             len_max           = 256;
  bit [31:0]             len_step          = 1;
  GEN_MODE               len_gen_cmd       = INC;  
  GEN_MODE               data_gen_cmd      = INC;  
  byte                   data_dt           = 8'h01;
  bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start = 32'h10000008;
  GEN_MODE               tx_aln_mode       = FIX;
  bit [31:0]             tx_offet_min      = 2;  
  bit [31:0]             tx_offet_max      = 2;  
  //task tx_time_ctl
  //update bd_data for sending data to fpga gap set
  bit [31:0]             getdata_tx_start_time  = 2000000;
  GEN_MODE               getdata_tx_gap_mode    = FIX;    
  bit [31:0]             getdata_tx_gap_min     = 2000000;
  bit [31:0]             getdata_tx_gap_max     = 2000000;
  bit [31:0]             getdata_tx_gap_step    = 2000000;
  
  bit [31:0]             getdata_rx_start_time  = 2000000;
  GEN_MODE               getdata_rx_gap_mode    = FIX;    
  bit [31:0]             getdata_rx_gap_min     = 2000000;
  bit [31:0]             getdata_rx_gap_max     = 2000000;
  bit [31:0]             getdata_rx_gap_step    = 2000000;
  
  //task bd_ctl
  //updata bd num
  GEN_MODE               tx_bd_u_mode      = FIX;
  bit [31:0]             tx_bd_u_min       = 127;
  bit [31:0]             tx_bd_u_max       = 127;
  bit [31:0]             tx_bd_u_step      = 1;  

  GEN_MODE               rx_bd_u_mode      = FIX;
  bit [31:0]             rx_bd_u_min       = 127;
  bit [31:0]             rx_bd_u_max       = 127;
  bit [31:0]             rx_bd_u_step      = 1;  

  //tail
  bit [`ADDR_WIDTH-1:0]  tail_addr       = 32'h20001010;
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr = 32'h2000101c; 
  
  reg_access_sequencer   reg_access_sqr;
  //user_sequencer         rx_user_sqr;
  //user_sequencer         tx_user_sqr;

  cpu_ini_addr_seq             cpu_ini_addr;
  cpu_bd_lookup_update_seq     cpu_tx_bd_lookup ;
  cpu_bd_lookup_update_seq     cpu_rx_bd_lookup ;
  cpu_get_data_seq             cpu_tx_get_data  ;
  cpu_get_data_seq             cpu_rx_get_data  ;
  cpu_mon_data_seq             cpu_tx_mon_data  ;
  cpu_mon_data_seq             cpu_rx_mon_data  ;
  
  reg_access_frame_seq         reg_access_frame;
  
  //chain add
  bit bd_ctl_seq_done = 1'b0;
  
  function new(string name = "cpu_bd_ctl_process_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_bd_ctl_process_seq)

  virtual task body(); 
    
    fork

      begin
        cpu_ini_addr = cpu_ini_addr_seq::type_id::create("cpu_ini_addr");
        cpu_ini_addr.chn_num           =  chn_num;           
        cpu_ini_addr.tx_aln_mode       =  tx_aln_mode ;
        cpu_ini_addr.tx_offet_min      =  tx_offet_min;
        cpu_ini_addr.tx_offet_max      =  tx_offet_max;           
        cpu_ini_addr.rx_aln_mode       =  rx_aln_mode ;    
        cpu_ini_addr.rx_offet_min      =  rx_offet_min;    
        cpu_ini_addr.rx_offet_max      =  rx_offet_max;         
        cpu_ini_addr.block_len         =  block_len        ;
        cpu_ini_addr.tx_buf_addr_start =  tx_buf_addr_start;
        cpu_ini_addr.rx_buf_addr_start =  rx_buf_addr_start;
        cpu_ini_addr.ctl_msg_mode      =  FIX;     
        cpu_ini_addr.ctl_msg_min       =  0 ; 
        cpu_ini_addr.ctl_msg_max       =  0 ; 
        cpu_ini_addr.ctl_msg_step      =  0; 
        cpu_ini_addr.start(null);
      end
      begin
        cpu_tx_mon_data = cpu_mon_data_seq::type_id::create("cpu_tx_mon_data");
        cpu_tx_mon_data.CRC_MODE      = CRC_MODE;
        //cpu_tx_mon_data.user_sqr      = rx_user_sqr;
        cpu_tx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_tx_mon_data.trans_mode    = "tx";
        cpu_tx_mon_data.chn_num       = chn_num;
        cpu_tx_mon_data.bd_addr_start = tx_bd_addr_start;
        cpu_tx_mon_data.valid_pos     = valid_pos;   
        cpu_tx_mon_data.tx_addr_pos   = tx_addr_pos;
        cpu_tx_mon_data.tx_len_pos    = tx_len_pos;
        cpu_tx_mon_data.bd_stream_num = bd_stream_num;

        cpu_tx_mon_data.gap_mode      = tx_mon_gap_mode;
        cpu_tx_mon_data.gap_min       = tx_mon_gap_min ;
        cpu_tx_mon_data.gap_max       = tx_mon_gap_max ;
        cpu_tx_mon_data.gap_step      = tx_mon_gap_step;
        
        cpu_tx_mon_data.start(null);

      end
      begin
        cpu_rx_mon_data = cpu_mon_data_seq::type_id::create("cpu_rx_mon_data");
        cpu_rx_mon_data.CRC_MODE      = CRC_MODE;
        //cpu_rx_mon_data.user_sqr      = rx_user_sqr;
        cpu_rx_mon_data.FILE_MON_DIR  = FILE_MON_DIR;
        cpu_rx_mon_data.trans_mode    = "rx";
        cpu_rx_mon_data.chn_num       = chn_num;
        cpu_rx_mon_data.bd_addr_start = rx_bd_addr_start;
        cpu_rx_mon_data.valid_pos     = valid_pos;   
        cpu_rx_mon_data.rx_addr_pos   = rx_addr_pos;
        cpu_rx_mon_data.rx_len_pos    = rx_len_pos; 
        cpu_rx_mon_data.rx_index_pos  = rx_index_pos;
        cpu_rx_mon_data.bd_stream_num = bd_stream_num;

        cpu_rx_mon_data.gap_mode      = rx_mon_gap_mode;
        cpu_rx_mon_data.gap_min       = rx_mon_gap_min ;
        cpu_rx_mon_data.gap_max       = rx_mon_gap_max ;
        cpu_rx_mon_data.gap_step      = rx_mon_gap_step;
        
        cpu_rx_mon_data.start(null);

      end
      begin
        cpu_tx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_tx_bd_lookup");
        cpu_tx_bd_lookup.FILE_BD_LOG     = FILE_BD_LOG;
        cpu_tx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_tx_bd_lookup.chn_num         = chn_num;
        cpu_tx_bd_lookup.trans_mode      = "tx";
        cpu_tx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_tx_bd_lookup.bd_addr_start   = tx_bd_addr_start;
        cpu_tx_bd_lookup.valid_pos       = valid_pos;
        cpu_tx_bd_lookup.owner_pos       = owner_pos;
        cpu_tx_bd_lookup.bd_stream_num   = bd_stream_num;
                                         
        cpu_tx_bd_lookup.tail_addr       = tail_addr;

        cpu_tx_bd_lookup.start(null);
      end
      begin
        cpu_rx_bd_lookup = cpu_bd_lookup_update_seq::type_id::create("cpu_rx_bd_lookup");
        cpu_rx_bd_lookup.FILE_BD_LOG     = FILE_BD_LOG;
        cpu_rx_bd_lookup.reg_access_sqr  = reg_access_sqr;
        cpu_rx_bd_lookup.chn_num         = chn_num;
        cpu_rx_bd_lookup.trans_mode      = "rx";
        cpu_rx_bd_lookup.ch_st_conf_addr = ch_st_conf_addr;
        cpu_rx_bd_lookup.bd_addr_start   = rx_bd_addr_start;
        cpu_rx_bd_lookup.valid_pos       = valid_pos;
        cpu_rx_bd_lookup.owner_pos       = owner_pos;
        cpu_rx_bd_lookup.bd_stream_num   = bd_stream_num;

        cpu_rx_bd_lookup.tail_addr       = tail_addr;

        cpu_rx_bd_lookup.start(null);
      end
      
      begin
        cpu_tx_get_data = cpu_get_data_seq::type_id::create("cpu_tx_get_data");
        
        //cpu_tx_get_data.user_sqr        = tx_user_sqr;
        cpu_tx_get_data.FILE_EXP_DIR    = FILE_EXP_DIR;
        cpu_tx_get_data.chn_num         = chn_num;
        cpu_tx_get_data.trans_mode      = "tx";
        cpu_tx_get_data.block_len       = block_len;
        cpu_tx_get_data.send_num			  = send_num;
        
        cpu_tx_get_data.start_time      = getdata_tx_start_time;
        cpu_tx_get_data.gap_mode        = getdata_tx_gap_mode;
        cpu_tx_get_data.gap_min         = getdata_tx_gap_min ;
        cpu_tx_get_data.gap_max         = getdata_tx_gap_max ;
        cpu_tx_get_data.gap_step        = getdata_tx_gap_step;
                                            
        cpu_tx_get_data.bd_u_mode       = tx_bd_u_mode; 
        cpu_tx_get_data.bd_u_min        = tx_bd_u_min ; 
        cpu_tx_get_data.bd_u_max        = tx_bd_u_max ; 
        cpu_tx_get_data.bd_u_step       = tx_bd_u_step; 
                                        
        cpu_tx_get_data.len_min         = len_min     ;
        cpu_tx_get_data.len_max         = len_max     ;
        cpu_tx_get_data.len_step        = len_step    ;
        cpu_tx_get_data.len_gen_cmd     = len_gen_cmd ;
        cpu_tx_get_data.data_gen_cmd    = data_gen_cmd;
        cpu_tx_get_data.data_dt         = data_dt     ;
        cpu_tx_get_data.start(null);
      end
      begin
        cpu_rx_get_data = cpu_get_data_seq::type_id::create("cpu_rx_get_data");
        
        //cpu_rx_get_data.user_sqr        = tx_user_sqr;
        cpu_rx_get_data.chn_num         = chn_num;
        cpu_rx_get_data.trans_mode      = "rx";
        cpu_rx_get_data.block_len       = block_len;
        cpu_rx_get_data.send_num			  = send_num;
        
        cpu_rx_get_data.start_time     = getdata_rx_start_time;     
        cpu_rx_get_data.gap_mode       = getdata_rx_gap_mode;
        cpu_rx_get_data.gap_min        = getdata_rx_gap_min ;
        cpu_rx_get_data.gap_max        = getdata_rx_gap_max ;
        cpu_rx_get_data.gap_step       = getdata_rx_gap_step;

        cpu_rx_get_data.bd_u_mode      = rx_bd_u_mode; 
        cpu_rx_get_data.bd_u_min       = rx_bd_u_min ; 
        cpu_rx_get_data.bd_u_max       = rx_bd_u_max ; 
        cpu_rx_get_data.bd_u_step      = rx_bd_u_step; 

        cpu_rx_get_data.start(null);
      end
      
      //chain add
      begin
        wait (cpu_tx_mon_data.frm_cnt == send_num);
        bd_ctl_seq_done = 1'b1;
      end
    join
 
  endtask : body
  //task rx_addr_ctl
  virtual task rx_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start,
      GEN_MODE               rx_aln_mode      ,
      bit [31:0]             rx_offet_min     ,
      bit [31:0]             rx_offet_max     
    );
    
    this.rx_buf_addr_start = rx_buf_addr_start;
    this.rx_aln_mode       = rx_aln_mode      ;
    this.rx_offet_min      = rx_offet_min     ;
    this.rx_offet_max      = rx_offet_max     ;
    
  endtask:rx_addr_ctl
  //task rx_time_ctl
  virtual task rx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.rx_mon_gap_mode = rx_gap_mode;
    this.rx_mon_gap_min  = rx_gap_min ;
    this.rx_mon_gap_max  = rx_gap_max ;
    this.rx_mon_gap_step = rx_gap_step;
    
  endtask:rx_time_ctl
  
  virtual task tx_time_ctl 
    ( 
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.tx_mon_gap_mode = rx_gap_mode;
    this.tx_mon_gap_min  = rx_gap_min ;
    this.tx_mon_gap_max  = rx_gap_max ;
    this.tx_mon_gap_step = rx_gap_step;
    
  endtask:tx_time_ctl
  
  //task tx_date_addr_ctl
  virtual task tx_data_addr_ctl 
    ( 
      bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start ,
      GEN_MODE               tx_aln_mode       ,
      bit [31:0]             tx_offet_min      ,
      bit [31:0]             tx_offet_max      ,
      bit [31:0]             len_min           ,
      bit [31:0]             len_max           ,
      bit [31:0]             len_step          ,
      GEN_MODE               len_gen_cmd       ,
      GEN_MODE               data_gen_cmd      ,
      byte                   data_dt           

    );
    
    this.len_min           = len_min           ;
    this.len_max           = len_max           ;
    this.len_step          = len_step          ;
    this.len_gen_cmd       = len_gen_cmd       ;
    this.data_gen_cmd      = data_gen_cmd      ;
    this.data_dt           = data_dt           ;
    
    this.tx_buf_addr_start = tx_buf_addr_start ;
    this.tx_aln_mode       = tx_aln_mode       ;
    this.tx_offet_min      = tx_offet_min      ;
    this.tx_offet_max      = tx_offet_max      ;
    
  endtask:tx_data_addr_ctl
  //getdata tx_time_ctl
  virtual task getdata_tx_time_ctl 
    ( 
      bit [31:0]             tx_start_time,
      GEN_MODE               tx_gap_mode ,
      bit [31:0]             tx_gap_min  ,
      bit [31:0]             tx_gap_max  ,
      bit [31:0]             tx_gap_step 
    );
    
    this.getdata_tx_start_time = tx_start_time;
    this.getdata_tx_gap_mode   = tx_gap_mode;
    this.getdata_tx_gap_min    = tx_gap_min ;
    this.getdata_tx_gap_max    = tx_gap_max ;
    this.getdata_tx_gap_step   = tx_gap_step;
    
  endtask:getdata_tx_time_ctl
  
  //getdata rx_time_ctl
  virtual task getdata_rx_time_ctl 
    ( 
      bit [31:0]             rx_start_time,
      GEN_MODE               rx_gap_mode ,
      bit [31:0]             rx_gap_min  ,
      bit [31:0]             rx_gap_max  ,
      bit [31:0]             rx_gap_step 
    );
    
    this.getdata_rx_start_time = rx_start_time;
    this.getdata_rx_gap_mode = rx_gap_mode;
    this.getdata_rx_gap_min  = rx_gap_min ;
    this.getdata_rx_gap_max  = rx_gap_max ;
    this.getdata_rx_gap_step = rx_gap_step;
    
  endtask:getdata_rx_time_ctl
  
  //task bd_ctl
  virtual task tx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.tx_bd_u_mode = bd_u_mode;
    this.tx_bd_u_min  = bd_u_min ;
    this.tx_bd_u_max  = bd_u_max ;
    this.tx_bd_u_step = bd_u_step;
    
  endtask:tx_bd_ctl
  
  virtual task rx_bd_ctl 
    ( 
      GEN_MODE         bd_u_mode ,
      bit [31:0]       bd_u_min  ,
      bit [31:0]       bd_u_max  ,
      bit [31:0]       bd_u_step 
    );
    
    this.rx_bd_u_mode = bd_u_mode;
    this.rx_bd_u_min  = bd_u_min ;
    this.rx_bd_u_max  = bd_u_max ;
    this.rx_bd_u_step = bd_u_step;
    
  endtask:rx_bd_ctl
 /*}}}*/ 
endclass : cpu_bd_ctl_process_seq

`endif

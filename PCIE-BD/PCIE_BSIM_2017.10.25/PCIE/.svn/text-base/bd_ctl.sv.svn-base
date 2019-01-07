

class cpu_ini_addr_seq extends uvm_sequence#(uvm_sequence_item);
  
  /////////////////////routine set//////////////
  bit [31:0]             chn_num           ;         //channel num
  bit [31:0]             addr_num          = 512;    //buffer_fifo max length
  bit [31:0]             block_len         ;         //each blocl max length
  
  /////////////tx addr generate////////////////
  bit [`ADDR_WIDTH-1:0]  tx_buf_addr_start ;         //tx buffer start address 
  GEN_MODE               tx_aln_mode       ;         //tx buffer address generate offset mode --FIX/INC/RDM
  bit [31:0]             tx_offet_min      ;         //tx buffer address generate offset min
  bit [31:0]             tx_offet_max      ;         //tx buffer address generate offset max
  
  /////////////rx addr generate////////////////
  bit [`ADDR_WIDTH-1:0]  rx_buf_addr_start ;         //rx buffer start address                       
  GEN_MODE               rx_aln_mode       ;         //rx buffer address generate offset mode --FIX/INC/RDM 
  bit [31:0]             rx_offet_min      ;         //rx buffer address generate offset min         
  bit [31:0]             rx_offet_max      ;         //rx buffer address generate offset max         
  ///////////////////for chunk/////////////////////////////
  GEN_MODE               ctl_msg_mode       =   FIX;
  bit [31:0]             ctl_msg_min        =   0  ;
  bit [31:0]             ctl_msg_max        =   0  ;
  bit [31:0]             ctl_msg_step       =   0  ;
  bit [31:0]             ctl_msg_calc; 
  
  ////////////////////////////////////////////////////
  string                 trans_mode ="trx";
  
  
  
  bit [31:0]             offet = 1;
  
  function new(string name = "cpu_ini_addr_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_ini_addr_seq)

  task addr_calc_t (bit [`ADDR_WIDTH-1:0]    tx_buf_addr_start,
                    bit [31:0]               pos              ,
                    bit [31:0]               block_len        ,
                    GEN_MODE                 aln_mode         ,
                    bit [31:0]               offet_min        ,
                    bit [31:0]               offet_max        ,
                    ref bit[`ADDR_WIDTH-1:0] addr_calc
                   );
  
    if (aln_mode == FIX) begin
      offet = offet_min;
    end
    else if (aln_mode == INC) begin
      if (offet > offet_max) begin
        offet = offet_min;
      end
      else begin
        offet = offet + 1;
      end
    end
    else begin
      offet = $urandom_range(offet_min,offet_max);
    end
    addr_calc = tx_buf_addr_start + pos*(block_len+`ADDR_WIDTH/8)-8+offet;
    
  endtask:addr_calc_t

  task calc_t (GEN_MODE mode,bit [31:0] min,bit [31:0] max,bit [31:0] step,ref bit[31:0] calc);
    
    if (mode == FIX) begin
      calc = min;
    end
    else if (mode == INC) begin
      if (calc > max) begin
        calc = min;
      end
      else begin
        calc = calc + step;
      end
    end
    else begin
      calc = $urandom_range(min,max);
    end

  endtask:calc_t

  virtual task body(); 
    
    bit [`ADDR_WIDTH-1:0]  tx_addr_calc;
    bit [`ADDR_WIDTH-1:0]  rx_addr_calc;
    
    ctl_msg_calc = ctl_msg_min;
    
    if (trans_mode == "trx") begin
    
      for (int i=0;i<addr_num;i++) begin
        addr_calc_t(tx_buf_addr_start,i,block_len,tx_aln_mode,tx_offet_min,tx_offet_max,tx_addr_calc);
        calc_t(ctl_msg_mode,ctl_msg_min,ctl_msg_max,ctl_msg_step,ctl_msg_calc); 
        tx_buffer_addr_fifo[chn_num].push_back({ctl_msg_calc,tx_addr_calc});
        //uvm_report_info(get_type_name(), $sformatf("tx_addr_calc = %0h",tx_addr_calc), UVM_LOW);
      end
      
      for (int i=0;i<addr_num;i++) begin
        addr_calc_t(rx_buf_addr_start,i,block_len,rx_aln_mode,rx_offet_min,rx_offet_max,rx_addr_calc);
        rx_buffer_addr_fifo[chn_num].push_back(rx_addr_calc);
        //uvm_report_info(get_type_name(), $sformatf("rx_addr_calc = %0h",rx_addr_calc), UVM_LOW);
      end   
    end
    else if (trans_mode == "tx") begin
      for (int i=0;i<addr_num;i++) begin
        addr_calc_t(tx_buf_addr_start,i,block_len,tx_aln_mode,tx_offet_min,tx_offet_max,tx_addr_calc);
        calc_t(ctl_msg_mode,ctl_msg_min,ctl_msg_max,ctl_msg_step,ctl_msg_calc); 
        tx_buffer_addr_fifo[chn_num].push_back({ctl_msg_calc,tx_addr_calc});
        //uvm_report_info(get_type_name(), $sformatf("tx_addr_calc = %0h",tx_addr_calc), UVM_LOW);
      end
    end
    else if (trans_mode == "rx") begin
      for (int i=0;i<addr_num;i++) begin
        addr_calc_t(rx_buf_addr_start,i,block_len,rx_aln_mode,rx_offet_min,rx_offet_max,rx_addr_calc);
        rx_buffer_addr_fifo[chn_num].push_back(rx_addr_calc);
        //uvm_report_info(get_type_name(), $sformatf("rx_addr_calc = %0h",rx_addr_calc), UVM_LOW);
      end  
    end
  endtask : body

endclass : cpu_ini_addr_seq



class cpu_get_data_seq extends uvm_sequence #(uvm_sequence_item);

  /////////////////////routine set//////////////
  bit [31:0]             chn_num;
  string                 trans_mode ="trx";
  bit [31:0]             block_len;
  bit [31:0]             bd_mesg_fifo_max = 128;
  ////////////update time ctl////////////////////////
  bit [31:0]             start_time   ;
  GEN_MODE               gap_mode     ;
  bit [31:0]             gap_min      ;
  bit [31:0]             gap_max      ;
  bit [31:0]             gap_step     ;
  bit [31:0]             gap_calc     ;
  ////////////get bd num ctl////////////////////////
  GEN_MODE               bd_u_mode     ;
  bit [31:0]             bd_u_min      ;
  bit [31:0]             bd_u_max      ;
  bit [31:0]             bd_u_step     ;
  bit [31:0]             bd_u_calc     ;
  ////////////get bd num ctl////////////////////////
  bit [31:0]             len_min        ;
  bit [31:0]             len_max        ;
  bit [31:0]             len_step       ;
  GEN_MODE               len_gen_cmd    ;
  bit [31:0]             len_dt         ;
  ////////////get bd num ctl////////////////////////
  GEN_MODE               data_gen_cmd   ;
  byte                   data_dt        ;
  bit [31:0]             seq_num = 32'd0;
  bit [31:0]			 send_num	=32'd100;
  
  //auto calc
  string                 FILE_EXP_DIR  = "./sim_out/bd_data_exp";

  `ifdef CLASS_HNM_4GE__SV
  int dsize;  
  user_sequencer         user_sqr;
  user_frame_seq         user_frame;
  `endif
  
  function new(string name = "cpu_get_data_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_get_data_seq)
    
  task calc_t (GEN_MODE       mode,
               bit     [31:0] min,
               bit     [31:0] max,
               bit     [31:0] step,
               ref bit [31:0] calc);
    
    if (mode == FIX) begin
      calc = min;
    end
    else if (mode == INC) begin
      if (calc > max) begin
        calc = min;
      end
      else begin
        calc = calc + step;
      end
    end
    else begin
      calc = $urandom_range(min,max);
    end

  endtask:calc_t

  task len_calc_t (bit      [31:0] len_min,
                   bit      [31:0] len_max,
                   bit      [31:0] len_step,
                   GEN_MODE        len_gen_cmd,
                   ref bit  [31:0] len_data);
    if (len_gen_cmd == FIX) begin
      len_data = len_min;
    end
    else if (len_gen_cmd == USER) begin
      if ((len_data <= (len_max+len_step)) && (len_data >= (len_max-len_step))) begin
        len_data = $urandom_range(len_min-len_step,len_min+len_step);
      end
      else if ((len_data <= (len_min+len_step)) && (len_data >= (len_min-len_step))) begin
        len_data = $urandom_range(len_max-len_step,len_max+len_step);
      end
    end
    else if (len_gen_cmd == INC) begin
      if (len_data > len_max) begin
        len_data = len_min;
      end
      else begin
        len_data = len_data+len_step;
      end
    end
    else begin
      len_data = $urandom_range(len_min,len_max);
    end
  endtask:len_calc_t

  task dt_calc_t (bit[31:0] len_data,
                  byte      dt_data,
                  GEN_MODE  data_gen_cmd,
                  ref byte  data[]);
    
    bit [15:0] dsize;
    
    if (data_gen_cmd == FIX) begin
      data=new[len_data];
      foreach(data[i]) data[i]=dt_data;
    end
    else if (data_gen_cmd == INC) begin
      data=new[len_data];
      foreach(data[i]) data[i]=dt_data+i;
    end
    else if (data_gen_cmd == RDM) begin
      data=new[len_data];
      foreach(data[i]) data[i]=$urandom_range(0,255);
    end
    
    `ifdef CLASS_HNM_4GE__SV
		dsize = data.size();
    	data[dsize-5] = 8'hff;
    	data[dsize-4] = chn_num[15:8];
    	data[dsize-3] = chn_num[7:0];
    	data[dsize-2] = seq_num[15:8];
    	data[dsize-1] = seq_num[7:0];
		seq_num=seq_num+1;
		wait(tbtop_pkg::BD_CFG_WR.triggered) begin 
			int fifo_sz;
			fifo_sz = tbtop_pkg::BD_CFG_FIFO.size();
			data = new[fifo_sz];
			foreach(data[i])
				data[i] = tbtop_pkg::BD_CFG_FIFO.pop_front();
		end
	`endif
    
  endtask:dt_calc_t

  virtual task body(); 
    
    bit [31:0]            len_data;
    byte                  data[];
    
    int file_out_0;

    bit [31:0]             tx_buffer_addr_fifo_size;
    bit [31:0]             tx_bd_mesg_fifo_size;

    bit [31:0]             rx_buffer_addr_fifo_size;
    bit [31:0]             rx_bd_mesg_fifo_size;

    bit [31:0]             bd_u_result;
    bit [`ADDR_WIDTH-1:0]  tx_addr_calc;
    
    bit [31:0]             frm_cnt =0;
    
    event bd_update;
    
    
    fork
      begin
        
        fork
          ////////////////////////update time ctl//////////////////////////
          begin
            repeat(start_time) #1ns;
            //gen update time
            gap_calc = gap_min;
            forever 
            begin
              -> bd_update;
              repeat(gap_calc) #1ns;
              calc_t(gap_mode,gap_min,gap_max,gap_step,gap_calc);
              //uvm_report_info(get_type_name(), $sformatf("gap_calc=%0d",gap_calc));
              //-> bd_update;
            end
          end
          begin
            bd_u_calc = bd_u_min;
            len_data  = len_min;
            forever begin
              @ bd_update;
              ////////////////////////update bd num calc////////////////////////// 
              if (trans_mode == "trx") begin
                tx_buffer_addr_fifo_size = tx_buffer_addr_fifo[chn_num].size();
                
                if (bd_u_calc <= tx_buffer_addr_fifo_size) begin
                  bd_u_result = bd_u_calc;
                end
                else begin
                  bd_u_result = tx_buffer_addr_fifo_size;
                end
                
                tx_bd_mesg_fifo_size = tx_bd_mesg_fifo[chn_num].size();
                
                if (bd_u_result >= (bd_mesg_fifo_max-tx_bd_mesg_fifo_size)) begin
                  bd_u_result = (bd_mesg_fifo_max-tx_bd_mesg_fifo_size);
                end
                else begin
                  bd_u_result = bd_u_result;
                end
              end
              else if (trans_mode == "tx") begin
                tx_buffer_addr_fifo_size = tx_buffer_addr_fifo[chn_num].size();
                
                if (bd_u_calc <= tx_buffer_addr_fifo_size) begin
                  bd_u_result = bd_u_calc;
                end
                else begin
                  bd_u_result = tx_buffer_addr_fifo_size;
                end
                
                tx_bd_mesg_fifo_size = tx_bd_mesg_fifo[chn_num].size();
                
                if (bd_u_result >= (bd_mesg_fifo_max-tx_bd_mesg_fifo_size)) begin
                  bd_u_result = (bd_mesg_fifo_max-tx_bd_mesg_fifo_size);
                end
                else begin
                  bd_u_result = bd_u_result;
                end
              end
              else if (trans_mode == "rx") begin
                rx_buffer_addr_fifo_size = rx_buffer_addr_fifo[chn_num].size();
                
                if (bd_u_calc <= rx_buffer_addr_fifo_size) begin
                  bd_u_result = bd_u_calc;
                end
                else begin
                  bd_u_result = rx_buffer_addr_fifo_size;
                end
                
                rx_bd_mesg_fifo_size = rx_bd_mesg_fifo[chn_num].size();
                
                if (bd_u_result >= (bd_mesg_fifo_max-rx_bd_mesg_fifo_size)) begin
                  bd_u_result = (bd_mesg_fifo_max-rx_bd_mesg_fifo_size);
                end
                else begin
                  bd_u_result = bd_u_result;
                end 
              end
              ////////////////////////get buffer addr from addr_src//////////////////////////
              if (trans_mode == "trx") begin
                for (int i=0;i<bd_u_result;i++) begin
                  
                  tx_bd_mesg_fifo[chn_num].push_back({tx_buffer_addr_fifo[chn_num][0],len_data});
                  rx_bd_mesg_fifo[chn_num].push_back(rx_buffer_addr_fifo[chn_num][0]);
                  
                  dt_calc_t(len_data,data_dt,data_gen_cmd,data);
                  
                  tx_addr_calc = tx_buffer_addr_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH];
                  
                  //uvm_report_info(get_type_name(), $sformatf("tx_addr_calc=%0h",tx_addr_calc));
                  //$stop;
                  
                  //put data into ram
                  //write data
                  file_out_0 = $fopen($sformatf("%0s_%0d",FILE_EXP_DIR,chn_num),"at");
                  //$fwrite(file_out,"len=%10d\n",(data.size()+8));
                  //$fwrite(file_out,"%16h",tx_addr_calc);
                  //for (int k=0;k<data.size();k++) begin
                  //  $fwrite(file_out,"%2h",data[k]);
                  //end
                  //$fwrite(file_out,"\n");
                  //$fclose(file_out);
                  
                  $fwrite(file_out_0,"#pack id   = %0d\n",frm_cnt);
                  $fwrite(file_out_0,"#pack type = %0d\n",tx_buffer_addr_fifo[chn_num][0][`ADDR_WIDTH+32-1-:32]);
                  $fwrite(file_out_0,"#pack len  = %0d\n",data.size());
                  $fwrite(file_out_0,"#pack addr = %0h\n",tx_buffer_addr_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH]);
                  for (int k=0;k<data.size();k++) begin
                    $fwrite(file_out_0,"%2h ",data[k]);
                    if (k%16 == 15) $fwrite(file_out_0,"\n");
                  end
                  $fwrite(file_out_0,"\n");
                  $fwrite(file_out_0,"#\n");
                  $fclose(file_out_0);
                  
                  frm_cnt = frm_cnt + 1;
                  
                  for(int j=0;j<len_data;j++)begin
                    assoc_ram[tx_addr_calc+j] = data[j];
                    //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%0h",tx_addr_calc+j,assoc_ram[tx_addr_calc+j]));
                  end
                  
                  len_calc_t(len_min,len_max,len_step,len_gen_cmd,len_data);
                  
                  tx_buffer_addr_fifo[chn_num].delete(0);
                  rx_buffer_addr_fifo[chn_num].delete(0);
                  
                  //chain add
                  if (frm_cnt == send_num) begin
                  	//$stop;
                    forever begin
                    	#1ns;
                    end
                  end
                end
                
                calc_t(bd_u_mode,bd_u_min,bd_u_max,bd_u_step,bd_u_calc);    
              end
              else if (trans_mode == "tx") begin
                for (int i=0;i<bd_u_result;i++) begin
                
                  tx_bd_mesg_fifo[chn_num].push_back({tx_buffer_addr_fifo[chn_num][0],len_data});
                  
                  dt_calc_t(len_data,data_dt,data_gen_cmd,data);
                  
                  tx_addr_calc = tx_buffer_addr_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH];
                  //file out 
                  //chaining del 20141201 file_out_0 = $fopen($sformatf("%0sdata_%0d",FILE_EXP_DIR,{data[data.size()-4],data[data.size()-3]}),"at");
                  //chaining del 20141201 $fwrite(file_out_0,"[rev data seq=%0d len=%0d]:\n",{data[data.size()-2],data[data.size()-1]},data.size());
                  //chaining del 20141201 
                  //chaining del 20141201 for (int k=0;k<data.size();k++) begin
                  //chaining del 20141201   $fwrite(file_out_0,"%2h",data[k]);
                  //chaining del 20141201   if (k%32 == 31) $fwrite(file_out_0,"\n");
                  //chaining del 20141201 end
                  //chaining del 20141201 $fwrite(file_out_0,"\n");
                  //chaining del 20141201 $fclose(file_out_0);   
                  
                  `ifdef CLASS_HNM_4GE__SV
                    dsize = data.size();
                    user_frame = user_frame_seq::type_id::create("user_frame");
                    user_frame.flag   = 8'hff;
                    user_frame.port   = chn_num%2;
                    user_frame.flowid = {data[dsize-4],data[dsize-3]};
                    user_frame.seqnum = {data[dsize-2],data[dsize-1]};
                    user_frame.data = new[dsize-5];
                    for (int k=0;k<data.size()-5;k++) begin
                      user_frame.data[k] = data[k];
                    end
                    user_frame.start(user_sqr);
                  `endif
                  
                  frm_cnt = frm_cnt + 1;
                  
                  for(int j=0;j<len_data;j++)begin
                    assoc_ram[tx_addr_calc+j] = data[j];
                    //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%0h",tx_addr_calc+j,assoc_ram[tx_addr_calc+j]));
                  end
                  
                  len_calc_t(len_min,len_max,len_step,len_gen_cmd,len_data);
                  
                  tx_buffer_addr_fifo[chn_num].delete(0);
                  
                  //chain add
                  if (frm_cnt == send_num) begin
                  	//$stop;
                    forever begin
                    	#1ns;
                    end
                  end

                end
              end
              else if (trans_mode == "rx") begin   
                for (int i=0;i<bd_u_result;i++) begin
                  //$display("#############bd_u_result=%0d",bd_u_result);
                  rx_bd_mesg_fifo[chn_num].push_back(rx_buffer_addr_fifo[chn_num][0]);
                  rx_buffer_addr_fifo[chn_num].delete(0);
                end
              end 
            end
          end
        join

      end 
      //begin 
      //	                                                                                  
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("20ms resv cnt =%0d",	frm_cnt), UVM_LOW); 
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("40ms resv cnt =%0d",	frm_cnt), UVM_LOW); 
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("60ms resv cnt =%0d",	frm_cnt), UVM_LOW); 
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("80ms resv cnt =%0d",	frm_cnt), UVM_LOW); 
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("100ms resv cnt =%0d",frm_cnt), UVM_LOW);
      //	#20ms; uvm_report_info(get_type_name(), $sformatf("120ms resv cnt =%0d",frm_cnt), UVM_LOW);
      //	                                                                               
      //end
    join
 
  endtask : body

endclass : cpu_get_data_seq



class cpu_bd_lookup_update_seq extends uvm_sequence#(uvm_sequence_item);
  
  /////////////////////routine set//////////////
  bit [31:0]             chn_num      ;
  string                 trans_mode   = "trx";
  bit [`ADDR_WIDTH-1:0]  bd_addr_start;
  bit [31:0]             valid_pos    ; 
  bit [31:0]             owner_pos    ;
  bit [31:0]             bd_stream_num;
  ///////////////////////tail////////////////////////
  bit [`ADDR_WIDTH-1:0]  tail_addr         = 64'h00000000_00001020;
  bit [`ADDR_WIDTH-1:0]  ch_st_conf_addr   = 32'h00001020;

  ///////////////////for chunk/////////////////////////////
  //GEN_MODE               pack_type_mode;
  //bit [31:0]             pack_type_min ;
  //bit [31:0]             pack_type_max ;
  //bit [31:0]             pack_type_step;
  //bit [31:0]             pack_type_calc; 
  
  
  reg_access_sequencer   reg_access_sqr;
  
  reg_access_frame_seq   reg_access_frame;

  bit [31:0]             chk_num      ;
  bit [31:0]             ctl_msg_calc;

  event bd_update;
  event tx_get_msg;
  event rx_get_msg;
  event trx_get_msg;
  
  bit [31:0] bd_u_result;
  bit [31:0] bd_index = 0;
  
  string                 FILE_BD_LOG = "./sim_out/bd_log";

  function new(string name = "cpu_bd_lookup_update_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_bd_lookup_update_seq)

  task calc_t (GEN_MODE mode,bit [31:0] min,bit [31:0] max,bit [31:0] step,ref bit[31:0] calc);
    
    if (mode == FIX) begin
      calc = min;
    end
    else if (mode == INC) begin
      if (calc > max) begin
        calc = min;
      end
      else begin
        calc = calc + step;
      end
    end
    else begin
      calc = $urandom_range(min,max);
    end

  endtask:calc_t

  task bd_assemble_for_chunk (bit [63:0] data_in_addr ,
                      bit [63:0] data_out_addr,
                      bit [15:0] data_in_len  ,
                      bit [6:0]  bd_index     ,
                      ref  byte  unsigned bd_data[]
                      );
    
    int pkt_len;
    chunk_bd_data_packet bd_item;  
    
    
    bd_item = chunk_bd_data_packet::type_id::create("bd_item");
    bd_item.data_in_addr  = data_in_addr ;
    bd_item.data_out_addr = data_out_addr;
    bd_item.data_in_len   = data_in_len  ;
    bd_item.bd_index      = bd_index     ;
    bd_item.pack_type     = ctl_msg_calc;
    bd_item.owner         = 1'b1;
    bd_item.valid         = 1'b1;
    
    //bd_item.print();
    
    pkt_len = bd_item.pack_bytes(bd_data);
    
    //calc_t(pack_type_mode,pack_type_min,pack_type_max,pack_type_step,pack_type_calc); 


  endtask:bd_assemble_for_chunk

  task bd_assemble_for_tx (bit [63:0] data_in_addr ,
                           bit [15:0] data_in_len  ,
                           bit [6:0]  bd_index     ,
                           bit        last_frame   ,
                           bit        first_frame  ,
                           ref  byte  unsigned bd_data[]
                           );
    
    int pkt_len;
    
    `ifdef CLASS_16E1_DATA_ITEM__SV    
       cpm_16e1_txbd_data_packet bd_item;  
       bd_item = cpm_16e1_txbd_data_packet::type_id::create("bd_item");
       bd_item.data_addr  = data_in_addr ;
       bd_item.data_len   = data_in_len  ;
       bd_item.valid      = 1'b1;
       if (bd_index == (bd_stream_num-1)) begin
         bd_item.wrap      = 1'b1;
       end
       pkt_len = bd_item.pack_bytes(bd_data);
    `endif
    `ifdef CLASS_HNM_4GE__SV 
       hnm_4ge_txbd_data_packet  bd_item; 
       bd_item = hnm_4ge_txbd_data_packet::type_id::create("bd_item");
       bd_item.data_addr   = data_in_addr ;
       bd_item.data_len    = data_in_len  ;
       bd_item.last_frame  = last_frame   ;
       bd_item.first_frame = first_frame  ;
       bd_item.owner       = 1'b1;
       bd_item.valid       = 1'b1;
       pkt_len = bd_item.pack_bytes(bd_data);
	   `uvm_info($sformatf("BD<%0d>_ASSEMBLE_FOR_TX",chn_num),$sformatf("Update TX BD:\n%s",bd_item.sprint()),UVM_HIGH)
    `endif
    //bd_item.print();
    //###########################################################
    
    
    //calc_t(pack_type_mode,pack_type_min,pack_type_max,pack_type_step,pack_type_calc); 


  endtask:bd_assemble_for_tx

  task bd_assemble_for_rx (bit [63:0] data_in_addr ,
                           bit [6:0]  bd_index     ,
                           ref  byte  unsigned bd_data[]
                           );
    
    int pkt_len;
    `ifdef CLASS_16E1_DATA_ITEM__SV  
       cpm_16e1_rxbd_data_packet bd_item;  
       
       
       bd_item = cpm_16e1_rxbd_data_packet::type_id::create("bd_item");
       bd_item.data_addr  = data_in_addr ;
       bd_item.empty      = 1'b1;
       
       if (bd_index == (bd_stream_num-1)) begin
         bd_item.wrap      = 1'b1;
       end
       pkt_len = bd_item.pack_bytes(bd_data);
    `endif
    `ifdef CLASS_HNM_4GE__SV 
       hnm_4ge_rxbd_data_packet  bd_item; 
       bd_item = hnm_4ge_rxbd_data_packet::type_id::create("bd_item");
       bd_item.data_addr   = data_in_addr ;
       bd_item.owner       = 1'b1;
       bd_item.valid       = 1'b1;
       pkt_len = bd_item.pack_bytes(bd_data);
	   `uvm_info($sformatf("BD<%0d>_ASSEMBLE_FOR_RX",chn_num),$sformatf("Update RX BD:\n%s",bd_item.sprint()),UVM_HIGH)
    `endif
    //bd_item.print();
    
    
    
    //calc_t(pack_type_mode,pack_type_min,pack_type_max,pack_type_step,pack_type_calc); 


  endtask:bd_assemble_for_rx

  task bd_lookup (bit[`ADDR_WIDTH-1:0] bd_addr_start,bit [31:0] valid_pos,bit [31:0] owner_pos,bit [31:0] bd_stream_num,ref bit[31:0] chk_num);
  
    bit [`ADDR_WIDTH-1:0] addr_for_valid;
    bit [`ADDR_WIDTH-1:0] addr_for_owner;
    bit                   valid;
    bit                   owner;
    
    bit [`BD_LEN*8-1:0]   bd_data;
    
    bit [31:0]            cnt = 0;
    
    bit flag = 0;
    
    for (int i=0;i<bd_stream_num;i++) begin
    	
    	for(int j=0;j<`BD_LEN;j++) begin
    		bd_data[(`BD_LEN-j)*8-1-:8] = assoc_ram[bd_addr_start+i*`BD_LEN+j];
    	end
    	//chaining modify 20141128 uvm_report_info(get_type_name(), $sformatf("bd_data=%0h",bd_data));
      //chaining modify 20141128 addr_for_valid = bd_addr_start+i*`BD_LEN+(`BD_LEN-1-valid_pos/8-4);
      //chaining modify 20141128 addr_for_owner = bd_addr_start+i*`BD_LEN+(`BD_LEN-1-owner_pos/8-4);
      
      
      //uvm_report_info(get_type_name(), $sformatf("addr_for_valid=%0h assoc_ram[addr_for_valid]=%h",addr_for_valid,assoc_ram[addr_for_valid]),UVM_LOW);
      //uvm_report_info(get_type_name(), $sformatf("addr_for_owner=%0h",addr_for_owner));
      
      //chaining modify 20141128 valid = assoc_ram[addr_for_valid][valid_pos];
      //chaining modify 20141128 owner = assoc_ram[addr_for_owner][owner_pos];

      valid = bd_data[valid_pos];
      owner = bd_data[owner_pos];

      //if (trans_mode == "tx") begin
      //  owner = tx_owner_table[chn_num][i];
      //  //uvm_report_info(get_type_name(), $sformatf("tx_owner_table[%0d][%0d]=%0b",chn_num,i,tx_owner_table[chn_num][i]),UVM_LOW);
      //end
      //
      //if (trans_mode == "rx") begin
      //  owner = rx_owner_table[chn_num][i];
      //  //uvm_report_info(get_type_name(), $sformatf("rx_owner_table[%0d][%0d]=%0b",chn_num,i,rx_owner_table[chn_num][i]),UVM_LOW);
      //end
      
      if ((owner == 1'b0) && (valid == 1'b0)) begin
        cnt = cnt + 1;
        flag = 1;
      end
      else begin
      	if (flag) begin
          i = 32'hfffffff0;
        end
      end
      chk_num = cnt;
      
    end
    //uvm_report_info(get_type_name(), $sformatf("cnt=%0d",cnt));
  endtask:bd_lookup

  virtual task body(); 
    
    bit [`ADDR_WIDTH-1:0] data_in_addr  ;
    bit [`ADDR_WIDTH-1:0] data_out_addr ;
    bit [31:0]            data_in_len   ;
    bit [31:0]            data_out_len  ;
    bit [31:0]            bd_index      ;
    
    bit [31:0]            bd_u_calc     ;
    
    byte unsigned bd_data_a[];
    
    int file_out;
    
    fork
      //lookup bd table and bd message buffer every 1us, and check bd update number
      begin
        forever begin
          #1us;
          bd_lookup(bd_addr_start,valid_pos,owner_pos,bd_stream_num,chk_num);
          if (trans_mode == "tx") begin 
            bd_u_calc = tx_bd_mesg_fifo[chn_num].size();  
          end
          else if (trans_mode == "rx") begin  
            bd_u_calc = rx_bd_mesg_fifo[chn_num].size();
          end
          else begin
            bd_u_calc = tx_bd_mesg_fifo[chn_num].size();  
          end
          //uvm_report_info(get_type_name(), $sformatf("=======================debug==========chk_num=%0d bd_u_calc=%0d",chk_num,bd_u_calc), UVM_LOW);
          if ((chk_num > 1) && (bd_u_calc >0)) begin
            ->bd_update;
          end
        end
      end
      begin
        forever begin
          @ bd_update;
          if (chk_num == bd_stream_num) begin //avoid update bd number == max bd number
            chk_num = bd_stream_num-1;
          end
          if (chk_num >= bd_u_calc) begin
            bd_u_result = bd_u_calc;
          end
          else begin
            bd_u_result = chk_num;
          end
          
          if (trans_mode == "tx") begin
            -> tx_get_msg;
          end
          else if (trans_mode == "rx") begin
            -> rx_get_msg;
          end
          else begin
            -> trx_get_msg;
          end
          //uvm_report_info(get_type_name(), $sformatf("bd_u_result=%0d",bd_u_result));
          //uvm_report_info(get_type_name(), $sformatf("bd_u_calc=%0d",bd_u_calc));
        end
      end
      begin
        forever begin
          @trx_get_msg;
          
          for (int i=0;i<bd_u_result;i++) begin
            //check for security
            if ((tx_bd_mesg_fifo[chn_num].size() == 0) || (rx_bd_mesg_fifo[chn_num].size() == 0)) begin
              uvm_report_error(get_type_name(), $sformatf("get bd from bd_mesg_fifo fail!!! %0d %0d",bd_u_calc,bd_u_result));
              wait ((tx_bd_mesg_fifo[chn_num].size() > 0) && (rx_bd_mesg_fifo[chn_num].size() > 0));
            end
            
            //get msg
            //uvm_report_info(get_type_name(), $sformatf("len_data=%0d",tx_bd_mesg_fifo[chn_num][0][31:0]));
            //uvm_report_info(get_type_name(), $sformatf("tx_addr_calc=%0h",tx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH+32-1-:`ADDR_WIDTH]));
            //uvm_report_info(get_type_name(), $sformatf("rx_addr_calc=%0h",rx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH]));
            ctl_msg_calc  = tx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH+32+32-1-:32];
            data_in_addr  = tx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH+32-1-:`ADDR_WIDTH];
            data_out_addr = rx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH];
            data_in_len   = tx_bd_mesg_fifo[chn_num][0][31:0];
            
            /////////////bd assemble/////////////////////
            bd_assemble_for_chunk ( 
                            data_in_addr , //bit [63:0] data_in_addr ,
                            data_out_addr, //bit [63:0] data_out_addr,
                            data_in_len  , //bit [15:0] data_in_len  ,
                            bd_index     , //bit [6:0]  bd_index     ,
                            bd_data_a      //ref byte bd_data[]
                          );
            
            //print
            uvm_report_info(get_type_name(), $sformatf("[BD UPDATE]chn_num=%0d bd_index=%0d tx_addr=%0h rx_addr=%0h rx_len=%0d",chn_num,bd_index,data_in_addr,data_out_addr,data_in_len), UVM_LOW);       
                    
            //write into ram
            for (int i=0;i<`BD_LEN;i=i+4) begin
              assoc_ram[bd_addr_start+bd_index*`BD_LEN+i]=bd_data_a[i];
              //for(int j=0;j<4;j++) begin
              //  assoc_ram[bd_addr_start+bd_index*`BD_LEN+i+3-j]=bd_data_a[`BD_LEN-i-1];
              //end
              //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%2h",bd_addr_start+bd_index*`BD_LEN+i,assoc_ram[bd_addr_start+bd_index*`BD_LEN+i]));
            end
            
            tx_bd_mesg_fifo[chn_num].delete(0);
            rx_bd_mesg_fifo[chn_num].delete(0);

            if (bd_index >= bd_stream_num-1) begin
              bd_index = 0;
            end
            else begin
              bd_index = bd_index + 1;
            end
          end
          //start reg_item
          if (bd_u_result !== 0) begin
            //reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
            //reg_access_frame.s_m_write(ch_bd_c,bd_index,sqr);
            //uvm_report_info(get_type_name(), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD UPDATE] time=%0d bd_update_num=%0d",$time,bd_u_result), UVM_LOW);
          end
        end
      end
      //tx
      begin
        forever begin
          @ tx_get_msg;
          //out log
          file_out = $fopen($sformatf("%0stx_%0d",FILE_BD_LOG,chn_num),"at");
          $fwrite(file_out,"[TXBD_UPDATE TIME=%0d ns SUM=%0d]\n",$time,bd_u_result);
          $fwrite(file_out,"---------------------------------------------------------------------\n");

          
          for (int i=0;i<bd_u_result;i++) begin
            //check for security
            if (tx_bd_mesg_fifo[chn_num].size() == 0) begin
              uvm_report_error(get_type_name(), $sformatf("get bd from tx bd_mesg_fifo fail!!! %0d %0d",bd_u_calc,bd_u_result));
              wait (tx_bd_mesg_fifo[chn_num].size() > 0);
            end
            
            ctl_msg_calc  = tx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH+32+32-1-:32];
            data_in_addr  = tx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH+32-1-:`ADDR_WIDTH];
            data_in_len   = tx_bd_mesg_fifo[chn_num][0][31:0];
            
            /////////////bd assemble/////////////////////
            bd_assemble_for_tx ( 
                            data_in_addr , //bit [63:0] data_in_addr ,
                            data_in_len  , //bit [15:0] data_in_len  ,
                            bd_index     , //bit [6:0]  bd_index     ,
                            1'b1         ,
                            1'b1         ,
                            bd_data_a      //ref byte bd_data[]
                          );
                          
            
            //print
            $fwrite(file_out,"chn_num=%0d bd_index=%0d tx_addr=%0h tx_len=%0d\n",chn_num,bd_index,data_in_addr,data_in_len);

            //uvm_report_info(get_type_name(), $sformatf("[BD UPDATE]chn_num=%0d bd_index=%0d tx_addr=%0h tx_len=%0d",chn_num,bd_index,data_in_addr,data_in_len), UVM_LOW);       
            
            //$display("`BD_LEN = %0d",`BD_LEN);
            
            //write into ram
            for (int i=0;i<`BD_LEN/4;i++) begin
              $fwrite(file_out,"addr=%8h:",bd_addr_start+bd_index*`BD_LEN+i*4);  
            //$stop;
              //assoc_ram[bd_addr_start+bd_index*`BD_LEN+i]=bd_data_a[i];
              for(int j=0;j<4;j++) begin
                
                //assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]=bd_data_a[`BD_LEN-(i+1)*4+j]; 
                //$fwrite(file_out,"%2h",bd_data_a[`BD_LEN-(i+1)*4+j]);   
                
                assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]=bd_data_a[i*4+j]; 
                $fwrite(file_out,"%2h",bd_data_a[i*4+j]);               
                //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%2h",bd_addr_start+bd_index*`BD_LEN+i*4+j,assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]), UVM_LOW);
              end
              $fwrite(file_out,"\n");
            end
            
            //tx_owner_table[chn_num][bd_index] = 1'b1;
            //uvm_report_info(get_type_name(), $sformatf("tx_owner_table[%0d][%0d]=%0b",chn_num,bd_index,tx_owner_table[chn_num][i]),UVM_LOW);
            
            tx_bd_mesg_fifo[chn_num].delete(0);

            if (bd_index >= bd_stream_num-1) begin
              bd_index = 0;
            end
            else begin
              bd_index = bd_index + 1;
            end
          end
          //start reg_item
          if (bd_u_result !== 0) begin
            //reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
            //if (chn_num%2==0) reg_access_frame.s_m_write(ch_st_conf_addr,32'h0000_0101,reg_access_sqr);
            //if (chn_num%2==1) reg_access_frame.s_m_write(ch_st_conf_addr,32'h0000_0103,reg_access_sqr);
            reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
            reg_access_frame.s_m_write(tail_addr,bd_addr_start+bd_index*`BD_LEN,reg_access_sqr);
            //uvm_report_info(get_type_name(), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD UPDATE] time=%0d bd_update_num=%0d",$time,bd_u_result), UVM_LOW);
          end
          
          $fclose(file_out);
          
        end
      end
      //rx
      begin
        forever begin
          @rx_get_msg;
          //out log
          file_out = $fopen($sformatf("%0srx_%0d",FILE_BD_LOG,chn_num),"at");
          $fwrite(file_out,"[RXBD_UPDATE TIME=%0d ns SUM=%0d]\n",$time,bd_u_result);
          $fwrite(file_out,"---------------------------------------------------------------------\n");

          for (int i=0;i<bd_u_result;i++) begin
            //check for security
            if (rx_bd_mesg_fifo[chn_num].size() == 0) begin
              uvm_report_error(get_type_name(), $sformatf("get bd from rx bd_mesg_fifo fail!!! %0d %0d",bd_u_calc,bd_u_result));
              wait (rx_bd_mesg_fifo[chn_num].size() > 0);
            end
            
            data_out_addr = rx_bd_mesg_fifo[chn_num][0][`ADDR_WIDTH-1-:`ADDR_WIDTH];
            
            /////////////bd assemble/////////////////////
            bd_assemble_for_rx ( 
                                    data_out_addr, //bit [63:0] data_out_addr,
                                    bd_index     , //bit [6:0]  bd_index     ,
                                    bd_data_a      //ref byte bd_data[]
                                    );
            
            //print
            $fwrite(file_out,"chn_num=%0d bd_index=%0d rx_addr=%0h\n",chn_num,bd_index,data_out_addr);

            //uvm_report_info(get_type_name(), $sformatf("[BD UPDATE]chn_num=%0d bd_index=%0d rx_addr=%0h",chn_num,bd_index,data_out_addr), UVM_LOW);       
                    
            //write into ram
            for (int i=0;i<`BD_LEN/4;i++) begin
              //assoc_ram[bd_addr_start+bd_index*`BD_LEN+i]=bd_data_a[i];
              $fwrite(file_out,"addr=%8h:",bd_addr_start+bd_index*`BD_LEN+i*4);  
              for(int j=0;j<4;j++) begin
                //assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]=bd_data_a[`BD_LEN-(i+1)*4+j]; 
                //$fwrite(file_out,"%2h",bd_data_a[`BD_LEN-(i+1)*4+j]);    
                
                assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]=bd_data_a[i*4+j]; 
                $fwrite(file_out,"%2h",bd_data_a[i*4+j]); 
                
                //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%2h",bd_addr_start+bd_index*`BD_LEN+i*4+j,assoc_ram[bd_addr_start+bd_index*`BD_LEN+i*4+j]), UVM_LOW);
              end
              $fwrite(file_out,"\n");
              //uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%2h",bd_addr_start+bd_index*`BD_LEN+i,assoc_ram[bd_addr_start+bd_index*`BD_LEN+i]));
            end
            
            //ownwe_table
            //rx_owner_table[chn_num][bd_index] = 1'b1;
            //uvm_report_info(get_type_name(), $sformatf("rx_owner_table[%0d][%0d]=%0b",chn_num,bd_index,rx_owner_table[chn_num][i]),UVM_LOW);
            
            rx_bd_mesg_fifo[chn_num].delete(0);

            if (bd_index >= bd_stream_num-1) begin
              bd_index = 0;
            end
            else begin
              bd_index = bd_index + 1;
            end
          end
          //start reg_item
          if (bd_u_result !== 0) begin
            reg_access_frame = reg_access_frame_seq::type_id::create("reg_access_frame");       
            reg_access_frame.s_m_write(tail_addr,bd_addr_start+bd_index*`BD_LEN,reg_access_sqr);
            //uvm_report_info(get_type_name(), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD UPDATE] time=%0d bd_update_num=%0d",$time,bd_u_result), UVM_LOW);
          end
          $fclose(file_out);
        end 
      end
    join
 
  endtask : body

endclass : cpu_bd_lookup_update_seq



class cpu_mon_data_seq extends uvm_sequence #(uvm_sequence_item);
  
  string                 trans_mode   = "trx";
  bit [31:0]             CRC_MODE = 2;
  /////////////////////routine set//////////////
  bit [31:0]             chn_num;
  bit [`ADDR_WIDTH-1:0]  bd_addr_start;
  bit [31:0]             valid_pos    ; 
  bit [31:0]             owner_pos    ;
  bit [31:0]             tx_addr_pos  ; //191
  bit [31:0]             rx_addr_pos  ; //127 
  bit [31:0]             rx_len_pos   ; //31  
  bit [31:0]             tx_len_pos   ;  
  bit [31:0]             rx_index_pos ; //15
  bit [31:0]             rx_mon_pos   ; //15
  bit [31:0]             rx_port_pos  ;
  bit [31:0]             bd_stream_num;
  string                 FILE_MON_DIR = "./sim_out/bd_data_mon";
  /////////////////////rx time clt//////////////
  GEN_MODE               gap_mode     ;
  bit [31:0]             gap_min      ;
  bit [31:0]             gap_max      ;
  bit [31:0]             gap_step     ;
  
  
  bit [31:0]             gap_calc     ;
  event bd_rx_mon;
  
  bit [31:0]             frm_cnt = 0;

  user_sequencer         user_sqr;
  user_frame_seq         user_frame;
  int                    dsize;

  function new(string name = "cpu_mon_data_seq");
    super.new(name);
  endfunction : new
  
  `uvm_object_utils(cpu_mon_data_seq)

  task calc_t (GEN_MODE mode,bit [31:0] min,bit [31:0] max,bit [31:0] step,ref bit[31:0] calc);
    
    if (mode == FIX) begin
      calc = min;
    end
    else if (mode == INC) begin
      if (calc > max) begin
        calc = min;
      end
      else begin
        calc = calc + step;
      end
    end
    else begin
      calc = $urandom_range(min,max);
    end

  endtask:calc_t

  virtual task body(); 

    bit [`ADDR_WIDTH-1:0] addr_for_valid;
    bit [`ADDR_WIDTH-1:0] addr_for_owner;
    bit [`ADDR_WIDTH-1:0] addr_for_tx_addr;
    bit [`ADDR_WIDTH-1:0] addr_for_rx_addr;
    bit [`ADDR_WIDTH-1:0] addr_for_rx_len ;
    bit [`ADDR_WIDTH-1:0] addr_for_tx_len ;
    bit [`ADDR_WIDTH-1:0] addr_for_rx_index ;
    bit [`ADDR_WIDTH-1:0] addr_for_rx_mon;
    bit                   valid;
    bit                   owner;
    bit [`ADDR_WIDTH-1:0] tx_addr;
    bit [`ADDR_WIDTH-1:0] rx_addr;
    bit [`LEN_WIDTH-1:0]  rx_len;
    bit [`LEN_WIDTH-1:0]  tx_len;
    bit [7:0]             rx_index;
    bit [7:0]             rx_mon;
    bit [3:0]             rx_port;
    bit [31:0]            bd_index      ;
    
    int file_out;
    
    bit [`BD_LEN*8-1:0]   bd_data;
    bit [7:0]             data_q[$];
    

    fork
      begin
        //gen update time
        gap_calc = gap_min;
        forever begin
          repeat(gap_calc) #1ns;
          calc_t(gap_mode,gap_min,gap_max,gap_step,gap_calc);
          -> bd_rx_mon;
        end
      end
      begin
        if (trans_mode == "trx") begin
          forever begin
            @ bd_rx_mon;
            for (int i=0;i<bd_stream_num;i++) begin
              
              //uvm_report_info(get_type_name(), $sformatf("bd_index=%0d bd_stream_num=%0d",bd_index,bd_stream_num));
              //
              //for(int j=0;j<32;j++) begin
              //  uvm_report_info(get_type_name(), $sformatf("assoc_ram[%0h]=%0h",bd_addr_start+bd_index*`BD_LEN+j,assoc_ram[bd_addr_start+bd_index*`BD_LEN+j]));
              //end
              
              addr_for_valid = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-valid_pos/8-4);
              addr_for_owner = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-owner_pos/8-4);
              valid = assoc_ram[addr_for_valid][valid_pos];
              owner = assoc_ram[addr_for_owner][owner_pos];
              
              addr_for_tx_addr = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-tx_addr_pos/8+4);
              addr_for_rx_addr = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_addr_pos/8+4);
              addr_for_rx_len  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_len_pos/8-4);   
              addr_for_tx_len  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-tx_len_pos/8-4);
              addr_for_rx_index= bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_index_pos/8-4);
              addr_for_rx_mon  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_mon_pos/8-4);
              
              
              //uvm_report_info(get_type_name(), $sformatf("addr_for_tx_addr=%0h",addr_for_tx_addr));
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_addr=%0h",addr_for_rx_addr));
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_len=%0h",addr_for_rx_len));
              //uvm_report_info(get_type_name(), $sformatf("valid=%0b",valid));
              //uvm_report_info(get_type_name(), $sformatf("owner=%0b",owner));
          
              for (int j=0;j<`ADDR_WIDTH/8;j++) begin
                tx_addr[`ADDR_WIDTH-1-j*8-:8] = assoc_ram[addr_for_tx_addr+j];
              end
          
              for (int j=0;j<`ADDR_WIDTH/8;j++) begin
                rx_addr[`ADDR_WIDTH-1-j*8-:8] = assoc_ram[addr_for_rx_addr+j];
              end
            
              for (int j=0;j<`LEN_WIDTH/8;j++) begin
                rx_len[`LEN_WIDTH-1-j*8-:8] = assoc_ram[addr_for_rx_len+j];
              end   
              
              for (int j=0;j<`LEN_WIDTH/8;j++) begin
                tx_len[`LEN_WIDTH-1-j*8-:8] = assoc_ram[addr_for_tx_len+j];
              end
              
              rx_index = assoc_ram[addr_for_rx_index];
              rx_mon   = assoc_ram[addr_for_rx_mon];
          
              if ((owner == 1'b0) && (valid == 1'b1)) begin
                if (rx_index == bd_index) begin
                  uvm_report_info(get_type_name(), $sformatf("[BD MONITOR]GOOD chn_num=%0d bd_index=%0d tx_addr=%0h rx_addr=%0h rx_len=%0d",chn_num,rx_index,tx_addr,rx_addr,rx_len), UVM_LOW);
                end
                else begin
                  uvm_report_info(get_type_name(), $sformatf("[BD MONITOR]BAD  chn_num=%0d bd_index=%0d tx_addr=%0h rx_addr=%0h rx_len=%0d",chn_num,rx_index,tx_addr,rx_addr,rx_len), UVM_LOW);
                end
                //write data
                file_out = $fopen($sformatf("%0s_%0d",FILE_MON_DIR,chn_num),"at");
                //$fwrite(file_out,"len=%10d\n",rx_len);
                //for (int k=0;k<rx_len;k++) begin
                //  $fwrite(file_out,"%2h",assoc_ram[rx_addr+k]);
                //end
                //$fwrite(file_out,"\n");
                //$fclose(file_out);
                
                $fwrite(file_out,"#pack id   = %0d\n",frm_cnt);
                $fwrite(file_out,"#pack type = 0\n");
                $fwrite(file_out,"#pack len  = %0d\n",rx_len);
                for (int k=0;k<rx_len;k++) begin
                  $fwrite(file_out,"%2h ",assoc_ram[rx_addr+k]);
                  if (k%36 == 35) $fwrite(file_out,"\n");
                end
                $fwrite(file_out,"\n");
                $fwrite(file_out,"#\n");
                $fclose(file_out);
                
                frm_cnt = frm_cnt + 1;
                
                
                assoc_ram[addr_for_owner][valid_pos]=1'b0;
                
                if (bd_index >= bd_stream_num-1) begin
                  bd_index = 0;
                end
                else begin
                  bd_index = bd_index + 1;
                end
                
                
                tx_buffer_addr_fifo[chn_num].push_back(tx_addr);
                rx_buffer_addr_fifo[chn_num].push_back(rx_addr);
                
                ///release tx_buffer 
                for (int k=0;k<tx_len;k++) begin
                	assoc_ram.delete(tx_addr+k);
                end
          
                ///release rx_buffer 
                for (int k=0;k<rx_len;k++) begin
                	assoc_ram.delete(rx_addr+k);
                end
          
              end
              else begin
                uvm_report_info(get_type_name(), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD MONITOR] time=%0d tx back_bd_num=%0d",$time,i), UVM_LOW);
                i = 32'hfffffff0;
              end
            end  
          end
        end
        else if (trans_mode == "rx") begin
          forever begin
            @ bd_rx_mon;
            for (int i=0;i<bd_stream_num;i++) begin

    	        for(int j=0;j<`BD_LEN;j++) begin
    	        	bd_data[(`BD_LEN-j)*8-1-:8] = assoc_ram[bd_addr_start+bd_index*`BD_LEN+j];
    	        end
              
              //uvm_report_info(get_type_name(), $sformatf("bd_index=%0d bd_data=%0h",bd_index,bd_data), UVM_LOW);
              
              //addr_for_valid = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-valid_pos/8-4);
              //valid = assoc_ram[addr_for_valid][valid_pos];
              
              //addr_for_rx_addr = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_addr_pos/8+4);
              //addr_for_rx_len  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_len_pos/8-4);   
              //addr_for_rx_mon  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_mon_pos/8-4);
              //addr_for_rx_index= bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-rx_index_pos/8);
              
              //uvm_report_info(get_type_name(), $sformatf("addr_for_tx_addr=%0h",addr_for_tx_addr), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_addr=%0h",addr_for_rx_addr), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_len=%0h",addr_for_rx_len), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("valid=%0b",valid), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("owner=%0b",owner), UVM_LOW);
          
              //for (int j=0;j<`ADDR_WIDTH/8;j++) begin
              //  rx_addr[`ADDR_WIDTH-1-j*8-:8] = assoc_ram[addr_for_rx_addr+j];
              //end
              //
              //for (int j=0;j<`LEN_WIDTH/8;j++) begin
              //  rx_len[`LEN_WIDTH-1-j*8-:8] = assoc_ram[addr_for_rx_len+j];
              //end   
              //
              //rx_index = assoc_ram[addr_for_rx_index];
              
              //rx_mon   = assoc_ram[addr_for_rx_mon];

              valid   = bd_data[valid_pos];
              owner   = bd_data[owner_pos];
              rx_addr = bd_data[rx_addr_pos-:32];
              rx_len  = bd_data[rx_len_pos-:12];
              rx_port = bd_data[rx_port_pos-:4];

              //uvm_report_info(get_type_name(), $sformatf("valid_pos  =%0h",valid_pos  ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("owner_pos  =%0h",owner_pos  ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_addr_pos=%0h",rx_addr_pos), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_len_pos =%0h",rx_len_pos ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_port_pos=%0h",rx_port_pos), UVM_LOW);
              //
              //uvm_report_info(get_type_name(), $sformatf("valid  =%0h",valid  ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("owner  =%0h",owner  ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_addr=%0h",rx_addr), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_len =%0h",rx_len ), UVM_LOW);
              //uvm_report_info(get_type_name(), $sformatf("rx_port=%0h",rx_port), UVM_LOW);

              ////for 16e1
              //rx_len   = {8'h00,rx_len[17:2]};
              //rx_index = rx_index[7:2];
              
              //uvm_report_info(get_type_name(), $sformatf("[BD MONITOR]GOOD chn_num=%0d bd_index=%0d rx_addr=%0h rx_len=%0d",chn_num,rx_index,rx_addr,rx_len), UVM_LOW);
              
              //if ((rx_len == 0) && (rx_addr == 0)) begin
              //  owner = 1'b0;
              //end
              //else if (rx_owner_table[chn_num][bd_index] == 1'b1) begin
              //  owner = 1'b1;
              //end
              //for 16e1
              
              if ((owner == 1'b0) && (valid == 1'b1)) begin
                //if (rx_index == bd_index) begin
                //  uvm_report_info(get_type_name(), $sformatf("[BD MONITOR]GOOD chn_num=%0d bd_index=%0d rx_addr=%0h rx_len=%0d",chn_num,rx_index,rx_addr,rx_len), UVM_LOW);
                //end
                //else begin
                //  uvm_report_info(get_type_name(), $sformatf("[BD MONITOR]BAD  chn_num=%0d bd_index=%0d rx_addr=%0h rx_len=%0d",chn_num,rx_index,rx_addr,rx_len), UVM_LOW);
                //end
                //write data
                //file_out = $fopen($sformatf("%0s_%0d",FILE_MON_DIR,chn_num),"at");
                //$fwrite(file_out,"len=%10d\n",rx_len-CRC_MODE);
                //for (int k=0;k<rx_len-CRC_MODE;k++) begin
                //  $fwrite(file_out,"%2h",assoc_ram[rx_addr+k]);
                //end
                //$fwrite(file_out,"\n");
                //$fclose(file_out);
                
                for (int k=0;k<rx_len-CRC_MODE;k++) begin
                  data_q.push_back(assoc_ram[rx_addr+k]);
                end

                `ifdef CLASS_HNM_4GE__SV
                  dsize = data_q.size();
                  user_frame = user_frame_seq::type_id::create("user_frame");
                  if (chn_num==28) user_frame.flag   = 8'hff;
                  else             user_frame.flag   = 8'h00;
                  user_frame.port   = rx_port;
				  user_frame.chn_num = chn_num;//added by lixu
				  user_frame.flag   = data_q[dsize-5];
                  user_frame.flowid = {data_q[dsize-4],data_q[dsize-3]};
                  user_frame.seqnum = {data_q[dsize-2],data_q[dsize-1]};
                  user_frame.data = new[dsize-5];
                  for (int k=0;k<data_q.size()-5;k++) begin
                    user_frame.data[k] = data_q[k];
                  end
                  user_frame.start(user_sqr);
                `endif        
                
                data_q={};
                
                //user_frame = user_frame_seq::type_id::create("user_frame");
                //user_frame.chn = chn_num;
                //user_frame.trans_size = rx_len-CRC_MODE;
                //user_frame.data = new[rx_len-CRC_MODE];
                //for (int k=0;k<rx_len-CRC_MODE;k++) begin
                //  user_frame.data[k] = assoc_ram[rx_addr+k];
                //end
                //user_frame.start(user_sqr);

                //rx_owner_table[chn_num][bd_index] = 1'b0;
                //uvm_report_info(get_type_name(), $sformatf("rx_owner_table[%0d][%0d]=%0b",chn_num,bd_index,rx_owner_table[chn_num][i]),UVM_LOW);
                //update bd
                bd_data[valid_pos] = 1'b0;
    	          for(int j=0;j<`BD_LEN;j++) begin
    	        	  assoc_ram[bd_addr_start+bd_index*`BD_LEN+j] = bd_data[(`BD_LEN-j)*8-1-:8];
    	          end

                frm_cnt = frm_cnt + 1;
                
                if (bd_index >= bd_stream_num-1) begin
                  bd_index = 0;
                end
                else begin
                  bd_index = bd_index + 1;
                end
                //uvm_report_info(get_type_name(), $sformatf("bd_index=%0d frm_cnt=%0g",bd_index,frm_cnt), UVM_LOW);
                rx_buffer_addr_fifo[chn_num].push_back(rx_addr);
                
          
                ///release rx_buffer 
                for (int k=0;k<rx_len;k++) begin
                	assoc_ram.delete(rx_addr+k);
                end
          
              end
              else begin
				`uvm_info($sformatf("RX_BD<%0d>_MONITOR",chn_num), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD MONITOR] time=%0d rx back_bd_num=%0d",$time,i), UVM_LOW);
                i = 32'hfffffff0;
              end
            end  
          end
        end
        else if (trans_mode == "tx") begin
          forever begin
            @ bd_rx_mon;
            for (int i=0;i<bd_stream_num;i++) begin

    	        for(int j=0;j<`BD_LEN;j++) begin
    	        	bd_data[(`BD_LEN-j)*8-1-:8] = assoc_ram[bd_addr_start+bd_index*`BD_LEN+j];
    	        end
              //chaining modify 20141128 uvm_report_info(get_type_name(), $sformatf("bd_data=%0h",bd_data), UVM_LOW);
              //chaining modify 20141128 addr_for_valid = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-valid_pos/8-4);
              //chaining modify 20141128 valid = assoc_ram[addr_for_valid][valid_pos];
              
              
              
              //chaining modify 20141128 addr_for_tx_addr = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-tx_addr_pos/8+4);   
              //chaining modify 20141128 addr_for_tx_len  = bd_addr_start+bd_index*`BD_LEN+(`BD_LEN-1-tx_len_pos/8-4);
              
              //uvm_report_info(get_type_name(), $sformatf("addr_for_tx_addr=%0h",addr_for_tx_addr));
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_addr=%0h",addr_for_rx_addr));
              //uvm_report_info(get_type_name(), $sformatf("addr_for_rx_len=%0h",addr_for_rx_len));
              //uvm_report_info(get_type_name(), $sformatf("valid=%0b",valid));
              //uvm_report_info(get_type_name(), $sformatf("owner=%0b",owner));
          
              //chaining modify 20141128 for (int j=0;j<`ADDR_WIDTH/8;j++) begin
              //chaining modify 20141128   tx_addr[`ADDR_WIDTH-1-j*8-:8] = assoc_ram[addr_for_tx_addr+j];
              //chaining modify 20141128 end
              
              //chaining modify 20141128 for (int j=0;j<`LEN_WIDTH/8;j++) begin
              //chaining modify 20141128   tx_len[`LEN_WIDTH-1-j*8-:8] = assoc_ram[addr_for_tx_len+j];
              //chaining modify 20141128 end
              
              
              valid   = bd_data[valid_pos];
              owner   = bd_data[owner_pos];
              tx_addr = bd_data[tx_addr_pos-:32];
              tx_len  = bd_data[tx_len_pos-:12];
              
              //tx_len = {8'h00,tx_len[15:0]};
              
              //if ((tx_len == 0) && (tx_addr == 0)) begin
              //  owner = 1'b0;
              //end
              //else if (tx_owner_table[chn_num][bd_index] == 1'b1) begin
              //  owner = 1'b1;
              //end
              
              if ((owner == 1'b0) && (valid == 1'b1)) begin
                
                frm_cnt = frm_cnt + 1;
                
                //tx_owner_table[chn_num][bd_index] = 1'b0;
                //uvm_report_info(get_type_name(), $sformatf("tx_owner_table[%0d][%0d]=%0b",chn_num,bd_index,tx_owner_table[chn_num][i]),UVM_LOW);

                //update bd
                bd_data[valid_pos] = 1'b0;
    	          for(int j=0;j<`BD_LEN;j++) begin
    	        	  assoc_ram[bd_addr_start+bd_index*`BD_LEN+j] = bd_data[(`BD_LEN-j)*8-1-:8];
    	          end


                if (bd_index >= bd_stream_num-1) begin
                  bd_index = 0;
                end
                else begin
                  bd_index = bd_index + 1;
                end
                
                

                tx_buffer_addr_fifo[chn_num].push_back(tx_addr);
                
                ///release tx_buffer 
                for (int k=0;k<tx_len;k++) begin
                	assoc_ram.delete(tx_addr+k);
                end
              end
              else begin
				`uvm_info($sformatf("TX_BD<%0d>_MONITOR",chn_num), $sformatf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[BD MONITOR] time=%0d tx back_bd_num=%0d",$time,i), UVM_LOW);
                i = 32'hfffffff0;
              end
            end  
          end
        end
      end
    join
  endtask : body

endclass : cpu_mon_data_seq


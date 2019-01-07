
`uvm_analysis_imp_decl(_reg_chk)

class reg_access_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(reg_access_scoreboard)
    string FILE_CFG_IN;
	string file_dir;//added by lixu
    int file,r,i;
    bit [`ADDR_WIDTH-1:0]   addr;
    bit [`DATA_WIDTH*8-1:0] data,rw;
   
    uvm_analysis_imp_reg_chk #(reg_access_item#(`ADDR_WIDTH,`BURSTLEN),reg_access_scoreboard) reg_sb_port;
   
    function new(string name, uvm_component parent);
      super.new(name, parent);
      reg_sb_port = new("reg_sb_port", this);
    endfunction : new

   function void start_of_simulation();
     //file =$fopen("./reg_cfg","r");
     file =$fopen($sformatf("./TC/%0s/sim_in/reg_cfg",file_dir),"w");
	 $fwrite(file,"20000000 00001000 10000000");
	 $fclose(file);
     file =$fopen($sformatf("./TC/%0s/sim_in/reg_cfg",file_dir),"r");
     while (!$feof(file)) begin
       r=$fscanf(file,"%h %h %h",addr,data,rw);
       assoc_ram_fpga_mirror[addr] = {data,rw};
       //uvm_report_info(get_type_name(), $sformatf("[INI] addr=%0h data=%0h",addr,assoc_ram_fpga_mirror[addr][`DATA_WIDTH*2*8-1:`DATA_WIDTH*8]), UVM_LOW);
     end
     $fclose(file);
   endfunction : start_of_simulation

   virtual function void write_reg_chk (input reg_access_item #(`ADDR_WIDTH,`BURSTLEN) op);

     
     bit [`DATA_WIDTH*8-1:0] wdata;
     bit [`DATA_WIDTH*8-1:0] rdata;
     
     //op.print();
     
     if (op.cmd == M_WR_S) begin
     
       //
       for(int j=0;j<`DATA_WIDTH;j++) wdata[`DATA_WIDTH*8-1-j*8-:8] = op.wdata[j];
     
       for (int i=`DATA_WIDTH-1;i>=0;i=i-1)begin
         if (assoc_ram_fpga_mirror[op.addr][i] == 1'b1) begin
           assoc_ram_fpga_mirror[op.addr][i+`DATA_WIDTH] = wdata[i];
         end
       end
       //uvm_report_info(get_type_name(), $sformatf("[WR_S] addr=%0h wdata=%0h",op.addr,assoc_ram_fpga_mirror[op.addr][`DATA_WIDTH*2-1:`DATA_WIDTH]), UVM_LOW);
       //uvm_report_info(get_type_name(), $sformatf("[WR_S] addr=%0h wdata=%0h",op.addr,wdata), UVM_LOW);
       
     end
     
     if (op.cmd == M_RD_S) begin
	   REG_RD_FIFO.push_back(op);
	   //$display("lixu:%s",op.sprint());
       for(int j=0;j<`DATA_WIDTH;j++) rdata[`DATA_WIDTH*8-1-j*8-:8] = op.rdata[j];
       
       if (assoc_ram_fpga_mirror[op.addr][`DATA_WIDTH*2*8-1:`DATA_WIDTH*8] == rdata) begin
         //uvm_report_info(get_type_name(), $sformatf("[RD_S] addr=%0h rdata=%0h expdata=%0h i2c data matched",op.addr,rdata,assoc_ram_fpga_mirror[op.addr][`DATA_WIDTH*2*8-1:`DATA_WIDTH*8]), UVM_HIGH);
         //uvm_report_info(get_type_name(), $psprintf("i2c data matched"), UVM_LOW);
       end
       else begin
         //uvm_report_error(get_type_name(), $sformatf("[RD_S] addr=%0h rdata=%0h expdata=%0h i2c data mismatched",op.addr,rdata,assoc_ram_fpga_mirror[op.addr][`DATA_WIDTH*2*8-1:`DATA_WIDTH*8]), UVM_HIGH);
         //uvm_report_error(get_type_name(), $psprintf("i2c data mismatched"), UVM_LOW);
       end
       
       for (int i=`DATA_WIDTH-1;i>=0;i=i-1)begin
         //if (assoc_ram_fpga_mirror[op.addr][i] == 1'b0) begin
         //  assoc_ram_fpga_mirror[op.addr][i+`DATA_WIDTH] = op.rdata[d][i];
         //end
           assoc_ram_fpga_mirror[op.addr][i+`DATA_WIDTH] = rdata[i];
       end

     end
        
   endfunction : write_reg_chk


   virtual function void report();
     uvm_report_info(get_type_name(),
     $psprintf("Scoreboard Report \n%s", this.sprint()), UVM_HIGH);
   endfunction : report

  
endclass : reg_access_scoreboard

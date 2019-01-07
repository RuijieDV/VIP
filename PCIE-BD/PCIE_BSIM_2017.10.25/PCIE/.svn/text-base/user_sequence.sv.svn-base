

class user_frame_seq extends uvm_sequence #(user_item);
  
  bit [7:0]  flag;
  bit [3:0]  port;
  bit [15:0] flowid;
  bit [15:0] seqnum;
  bit [31:0] chn_num;
  
  bit [7:0]  data[];
  
  function new(string name = "user_frame_seq");
      super.new(name);
  endfunction : new
  
  `uvm_object_utils(user_frame_seq)
    
  user_item item;
  
  virtual task body();
    m_sequencer.lock(this);
    // Step 1 - Creation
    item = user_item::type_id::create("item");
    
    // Step 2 - Ready - start_item()
    start_item(item);
    // Step 3 - Set
    //added by lixu
    item.chn_num = chn_num;
    item.flag   = flag;
    item.port   = port;
    item.flowid = flowid;
    item.seqnum = seqnum;
    //uvm_report_info(get_type_name(), $sformatf("req.cmd=%0s",cmd), UVM_LOW);
    // data 
    item.data.delete();
    item.data=new[data.size()];

    foreach (item.data[i]) begin
      item.data[i] = data[i];
    end
    
    // Step 4 - Go - finish_item()
    //item.print();
    finish_item(item);
    m_sequencer.unlock(this);
    //end  
  endtask : body

endclass : user_frame_seq


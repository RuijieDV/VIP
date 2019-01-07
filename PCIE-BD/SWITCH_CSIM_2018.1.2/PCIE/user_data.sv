
class user_item extends uvm_sequence_item;
  
  bit [3:0]  port;
  bit [31:0] chn_num;
  bit [7:0]  flag;
  bit [15:0] flowid;
  bit [15:0] seqnum;
  
  bit [7:0]  data[];
  
  `uvm_object_utils_begin(user_item)
     `uvm_field_array_int(data, UVM_ALL_ON)
     `uvm_field_int(flag, UVM_ALL_ON)
     `uvm_field_int(flowid, UVM_ALL_ON)
     `uvm_field_int(seqnum, UVM_ALL_ON)
	 `uvm_field_int(port,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
	 `uvm_field_int(chn_num,UVM_DEFAULT|UVM_NOCOMPARE|UVM_NOPACK)
  `uvm_object_utils_end

  
  function new(string name = "user_item");
    super.new(name);
  endfunction : new

endclass : user_item


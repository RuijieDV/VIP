
class reg_access_configuration extends uvm_object;
    
  string FILE_CFG_IN;
  string FILE_ISR_IN;
  
  function new (string name="");
    super.new (name);
  endfunction
  
  virtual function uvm_object create(string name="");
    reg_access_configuration t = new();
    t.FILE_CFG_IN = this.FILE_CFG_IN;
    t.FILE_ISR_IN = this.FILE_ISR_IN;
    return t;
  endfunction : create
  
endclass : reg_access_configuration

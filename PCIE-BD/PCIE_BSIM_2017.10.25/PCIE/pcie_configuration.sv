
class pcie_configuration extends uvm_object;
    
  // gmii virtual interface
  virtual pcie_intf.pcie_clk_intf pcie_clk_intf;
  virtual pcie_intf.pcie_tx_intf	pcie_tx_intf;
  virtual pcie_intf.pcie_rx_intf	pcie_rx_intf;
  
  
  function new (string name="");
    super.new (name);
  endfunction
  
  virtual function uvm_object create(string name="");
    pcie_configuration t = new();
    t.pcie_clk_intf = this.pcie_clk_intf;
    t.pcie_tx_intf = this.pcie_tx_intf;  
    t.pcie_rx_intf = this.pcie_rx_intf;
    return t;
  endfunction : create
  
endclass : pcie_configuration

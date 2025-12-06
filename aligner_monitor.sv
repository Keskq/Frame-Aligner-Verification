class aligner_monitor_dut extends uvm_monitor;
  `uvm_component_utils(aligner_monitor_dut)
  uvm_analysis_port#(aligner_transaction) mon_ap_dut;

  virtual aligner_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    void'(uvm_resource_db#(virtual aligner_if)::read_by_name(
      .scope("ifs"), .name("aligner_if"), .val(vif)
    ));
    mon_ap_dut = new(.name("mon_ap_dut"), .parent(this));
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    aligner_transaction al_tx;
    al_tx = aligner_transaction::type_id::create(.name("al_tx"), .contxt(get_full_name()));

    forever begin
      @(posedge vif.clk);
      al_tx.rx_data          = vif.rx_data;
      al_tx.fr_byte_position = vif.fr_byte_position;
      al_tx.frame_detect     = vif.frame_detect;
      mon_ap_dut.write(al_tx);

      `uvm_info("MON_DUT", $sformatf(
        "Captured transaction: rx_data=%0h, fr_byte_position=%0d, frame_detect=%0d",
        al_tx.rx_data, al_tx.fr_byte_position, al_tx.frame_detect
      ), UVM_MEDIUM)
    end
  endtask: run_phase
endclass: aligner_monitor_dut




class aligner_monitor_ref extends uvm_monitor;
	`uvm_component_utils(aligner_monitor_ref)
	uvm_analysis_port#(aligner_transaction) mon_ap_ref;

	virtual aligner_ref_if ref_vif;
	

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual aligner_ref_if)::read_by_name (.scope("ifs"), .name("aligner_ref_if"), .val(ref_vif)));
		mon_ap_ref = new(.name("mon_ap_ref"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);

		aligner_transaction al_tx;
		al_tx = aligner_transaction::type_id::create (.name("al_tx"), .contxt(get_full_name()));
      
		forever begin @(posedge ref_vif.clk) 
                   begin 
                     al_tx.rx_data = ref_vif.rx_data;
                     al_tx.fr_byte_position = ref_vif.fr_byte_position;
                     al_tx.frame_detect = ref_vif.frame_detect;
                     //Send the transaction to the analysis port
	                 mon_ap_ref.write(al_tx);
                   end 
        end 
    endtask: run_phase 
endclass:aligner_monitor_ref


class aligner_driver extends uvm_driver#(aligner_transaction);
	`uvm_component_utils(aligner_driver)

	virtual aligner_if vif;
    virtual aligner_ref_if ref_vif;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual aligner_if)::read_by_name (.scope("ifs"), .name("aligner_if"), .val(vif)));
        void'(uvm_resource_db#(virtual aligner_ref_if)::read_by_name (.scope("ifs"), .name("aligner_ref_if"), .val(ref_vif)));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		drive();
	endtask: run_phase

	virtual task drive();
		aligner_transaction al_tx;
		vif.rx_data = 8'b00000000;
        ref_vif.rx_data = 8'b00000000;


		forever begin
			begin
              seq_item_port.get_next_item(al_tx);
              `uvm_info("hm_sequence", al_tx.sprint(), UVM_LOW);
                vif.rx_data = al_tx.rx_data;
                ref_vif.rx_data = al_tx.rx_data;

			end

          @(posedge vif.clk)
			begin
			   seq_item_port.item_done();
			end
		end
	endtask: drive
endclass: aligner_driver

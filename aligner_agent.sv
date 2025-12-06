class aligner_agent extends uvm_agent;
	`uvm_component_utils(aligner_agent)
  
    uvm_analysis_port#(aligner_transaction) agent_ap_dut;
    uvm_analysis_port#(aligner_transaction) agent_ap_ref;

	aligner_sequencer	al_seqr;
	aligner_driver		al_drvr;
	aligner_monitor_dut	al_mon_dut;
  	aligner_monitor_ref	al_mon_ref;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      
        agent_ap_dut = new(.name("agent_ap_dut"), .parent(this));
        agent_ap_ref = new(.name("agent_ap_ref"), .parent(this));

		al_seqr		= aligner_sequencer::type_id::create(.name("al_seqr"), .parent(this));
		al_drvr		= aligner_driver::type_id::create(.name("al_drvr"), .parent(this));
		al_mon_dut	= aligner_monitor_dut::type_id::create(.name("al_mon_dut"), .parent(this));
        al_mon_ref	= aligner_monitor_ref::type_id::create(.name("al_mon_ref"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		al_drvr.seq_item_port.connect(al_seqr.seq_item_export);
        al_mon_dut.mon_ap_dut.connect(agent_ap_dut);
        al_mon_ref.mon_ap_ref.connect(agent_ap_ref) ;
	endfunction: connect_phase
endclass: aligner_agent

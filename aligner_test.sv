class aligner_test extends uvm_test;
		`uvm_component_utils(aligner_test)

		aligner_env al_env;

		function new(string name, uvm_component parent);
			super.new(name, parent);
            //`uvm_info("", "New of hamming_test", UVM_MEDIUM);
		endfunction: new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			al_env = aligner_env::type_id::create(.name("al_env"), .parent(this));
            //`uvm_info("", "Build Phase of hamming_test", UVM_MEDIUM);
		endfunction: build_phase

		task run_phase(uvm_phase phase);
			aligner_sequence al_seq;

			phase.raise_objection(.obj(this));
				al_seq = aligner_sequence::type_id::create(.name("al_seq"), .contxt(get_full_name()));
				assert(al_seq.randomize());
				al_seq.start(al_env.al_agent.al_seqr);
			phase.drop_objection(.obj(this));
            //`uvm_info("", "Run Phase of hamming_test", UVM_MEDIUM);
		endtask: run_phase
endclass: aligner_test

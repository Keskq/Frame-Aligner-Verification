import uvm_pkg::*;
`include "uvm_macros.svh"

// Include all UVM components
`include "frame_item.sv"
`include "aligner_sequencer.sv"
`include "aligner_driver.sv"
`include "aligner_monitor.sv"
`include "aligner_agent.sv"
`include "aligner_scoreboard.sv"
`include "aligner_env.sv"
`include "aligner_test.sv"

`include "aligner_ref.sv"
`include "aligner_ref_if.sv"
`include "aligner_coverage.sv" // הוספת קובץ כיסוי

module aligner_tb_top;
	import uvm_pkg::*;

	// Interface declaration
	aligner_if vif();
    aligner_ref_if ref_vif();
  

	// Connects the Interface to the DUT
    frame_aligner dut(.i_inf (vif));
    aligner_ref dut_ref(.i_ref_if(ref_vif));
 
  
     aligner_coverage coverage_inst (
        .clk(vif.clk),
        .reset(vif.reset),
        .fr_byte_position(vif.fr_byte_position),
        .frame_detect(vif.frame_detect),
        .rx_data(vif.rx_data)
      );


  
  
	initial begin
		// Registers the Interface in the configuration block
		uvm_resource_db#(virtual aligner_if)::set (.scope("ifs"), .name("aligner_if"), .val(vif));
        uvm_resource_db#(virtual aligner_ref_if)::set (.scope("ifs"), .name("aligner_ref_if"), .val(ref_vif));

		// Execute the test
        run_test("aligner_test");
	end

	// Variable initialization
	initial begin
		vif.clk <= 1'b1;
        ref_vif.clk <= 1'b1;
	end
  
    initial begin
        vif.reset = 1'b1;
        ref_vif.reset = 1'b1;
        #5;
        vif.reset = 1'b0;
        ref_vif.reset = 1'b0;

    end

	// Clock generation
	always #5 vif.clk = ~vif.clk;
  	always #5 ref_vif.clk = ~ref_vif.clk;


    // Enable waveform dumping
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
  

endmodule

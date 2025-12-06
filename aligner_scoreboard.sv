

class aligner_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(aligner_scoreboard)

    uvm_analysis_export #(aligner_transaction) sb_export_dut;
    uvm_analysis_export #(aligner_transaction) sb_export_ref;

    uvm_tlm_analysis_fifo #(aligner_transaction) dut_fifo;
    uvm_tlm_analysis_fifo #(aligner_transaction) ref_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export_dut       = new("sb_export_dut", this);
        sb_export_ref       = new("sb_export_ref", this);
        dut_fifo            = new("dut_fifo", this);
        ref_fifo            = new("ref_fifo", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_export_dut.connect(dut_fifo.analysis_export);
        sb_export_ref.connect(ref_fifo.analysis_export);
    endfunction: connect_phase

    task run();
        aligner_transaction transaction_dut;
        aligner_transaction transaction_reference;

        forever begin
            dut_fifo.get(transaction_dut);
            ref_fifo.get(transaction_reference);

            compare(transaction_dut, transaction_reference);
        end
    endtask: run
  
  

    virtual function void compare(aligner_transaction dut, aligner_transaction reference);
        `uvm_info("COMPARE", $sformatf(
            "DUT: rx_data=%0h fr_byte_position=%0d frame_detect=%0b | REF: rx_data=%0h fr_byte_position=%0d frame_detect=%0b",
            dut.rx_data, dut.fr_byte_position, dut.frame_detect,
            reference.rx_data, reference.fr_byte_position, reference.frame_detect
        ), UVM_LOW);

        if ((dut.rx_data == reference.rx_data) &&
            (dut.fr_byte_position == reference.fr_byte_position) &&
            (dut.frame_detect == reference.frame_detect)) begin
            `uvm_info("COMPARE", "Test: OK!", UVM_LOW)
        end else begin
            `uvm_error("COMPARE", "Test: FAIL! Values mismatch")
        end
    endfunction: compare
    
    

endclass: aligner_scoreboard



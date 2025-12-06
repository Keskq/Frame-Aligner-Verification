`include "uvm_macros.svh"
import uvm_pkg::*;


class aligner_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(aligner_transaction)  

  rand bit [7:0] rx_data;     
  bit [3:0] fr_byte_position;     
  bit frame_detect;
  
  function new (string name = "aligner_transaction");
    super.new(name);
  endfunction

  function void print_values();
    `uvm_info("TRANSACTION", $sformatf(
      "rx_data=%0h fr_byte_position=%0d frame_detect=%0b",
      rx_data, fr_byte_position, frame_detect), UVM_LOW)
  endfunction

endclass


class aligner_sequence extends uvm_sequence #(aligner_transaction);
  `uvm_object_utils(aligner_sequence)

  function new(string name="aligner_test_sequence");
    super.new(name);
  endfunction

  task body();

    frame_item frame;
    aligner_transaction tx;
    

    frame = frame_item::type_id::create("frame1");
    assert(frame.randomize() with { header inside {HEAD_1, HEAD_2}; });
    tx = aligner_transaction::type_id::create("hdr_lsb");
    start_item(tx);
    tx.rx_data = frame.header_value[7:0];
    finish_item(tx);

    tx = aligner_transaction::type_id::create("hdr_msb");
    start_item(tx);
    tx.rx_data = frame.header_value[15:8];
    finish_item(tx);

    foreach (frame.payload[i]) begin
        tx = aligner_transaction::type_id::create($sformatf("payload1_%0d", i));
        start_item(tx);
        tx.rx_data = frame.payload[i];
        finish_item(tx);
    end

    frame = frame_item::type_id::create("frame2");
    assert(frame.randomize() with { header inside {HEAD_1, HEAD_2}; });

    tx = aligner_transaction::type_id::create("hdr_lsb");
    start_item(tx);
    tx.rx_data = frame.header_value[7:0];
    finish_item(tx);

    tx = aligner_transaction::type_id::create("hdr_msb");
    start_item(tx);
    tx.rx_data = 8'hFF; 
    finish_item(tx);

    foreach (frame.payload[i]) begin
        tx = aligner_transaction::type_id::create($sformatf("payload2_%0d", i));
        start_item(tx);
        tx.rx_data = frame.payload[i];
        finish_item(tx);
    end

    repeat (2) begin
        frame = frame_item::type_id::create("legal_frame");
        assert(frame.randomize() with { header inside {HEAD_1, HEAD_2}; });

        tx = aligner_transaction::type_id::create("hdr_lsb");
        start_item(tx);
        tx.rx_data = frame.header_value[7:0];
        finish_item(tx);

        tx = aligner_transaction::type_id::create("hdr_msb");
        start_item(tx);
        tx.rx_data = frame.header_value[15:8];
        finish_item(tx);

        foreach (frame.payload[i]) begin
            tx = aligner_transaction::type_id::create($sformatf("payload_%0d", i));
            start_item(tx);
            tx.rx_data = frame.payload[i];
            finish_item(tx);
        end
    end

  endtask

endclass


// 3 proper frames and 51 illegal
/*
class aligner_sequence extends uvm_sequence #(aligner_transaction);
  `uvm_object_utils(aligner_sequence)

  function new(string name="aligner_test_sequence");
    super.new(name);
  endfunction

  task body();

    frame_item frame;
    aligner_transaction tx;

    // -----------------------
    // 3 LEGAL FRAMES
    // -----------------------
    repeat (3) begin

      frame = frame_item::type_id::create("legal_frame");
      assert(frame.randomize() with { header inside {HEAD_1, HEAD_2}; });
      //assert(frame.randomize() with { header inside {HEAD_1}; });


      tx = aligner_transaction::type_id::create("hdr_lsb");
      start_item(tx);
      tx.rx_data = frame.header_value[7:0];
      finish_item(tx);

      tx = aligner_transaction::type_id::create("hdr_msb");
      start_item(tx);
      tx.rx_data = frame.header_value[15:8];
      finish_item(tx);

      foreach (frame.payload[i]) begin
        tx = aligner_transaction::type_id::create($sformatf("payload_%0d", i));
        start_item(tx);
        tx.rx_data = frame.payload[i];
        finish_item(tx);
      end
    end

    // -----------------------
    // 51 ILLEGAL BYTES
    // -----------------------
    repeat (52) begin
      frame = frame_item::type_id::create("illegal_frame");

      assert(frame.randomize() with {
        header == ILLEGAL;
        payload.size() == 0;
      });

      tx = aligner_transaction::type_id::create("illegal_tx");
      start_item(tx);
      tx.rx_data = frame.header_value[7:0];
      finish_item(tx);
    end

  endtask

endclass

*/



class aligner_sequencer extends uvm_sequencer#(aligner_transaction);
  
  `uvm_component_utils(aligner_sequencer)
  
  function new ( string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
endclass

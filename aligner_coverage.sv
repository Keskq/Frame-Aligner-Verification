
module aligner_coverage ( 
  input logic clk,
  input logic reset,
  // Signal declarations
  logic [3:0] fr_byte_position, // Byte position in a legal frame
  logic frame_detect,          // Frame alignment indication
  logic [7:0] rx_data
);
 
    covergroup cg_byte @(posedge clk);
        option.per_instance = 1;
        fr_cp : coverpoint fr_byte_position {
            bins valid_byte[]   = {[0:11]};
            ignore_bins invalid = {[12:15]};
        }
    endgroup

    cg_byte byte_cg = new();

  
  
  // Sequence declarations for detecting headers
  sequence header_1;
    (rx_data == 8'hAA) ##1 (rx_data == 8'hAF);
  endsequence

  sequence header_2;
    (rx_data == 8'h55) ##1 (rx_data == 8'hBA);
  endsequence
  
  
/*
// Properties for detecting valid frames

property valid_frame1;
  @(posedge clk)
  disable iff(reset)
  header_1 ##11 header_1 ##11 header_1 |=> ##1 (frame_detect == 1);
endproperty
*/
 
  

sequence header_valid;
    header_1 or header_2;
endsequence

property valid_frame1;
    @(posedge clk) disable iff(reset)
        header_valid 
        ##11 header_valid
        ##11 header_valid
        |=> ##1 (frame_detect == 1);
endproperty  
  
  
property misalignment;
 @(posedge clk)
  disable iff(reset)
  ((frame_detect == 1) and ( fr_byte_position == 0 or fr_byte_position == 1))[*47] |=>  $fell(frame_detect);
endproperty 


property misalignment_resilience1;
  @(posedge clk)
  disable iff(reset)
  (frame_detect == 0) ##1 (header_valid) ##11 (rx_data == 8'hAA or rx_data == 8'h55) ##1 (header_1 or header_2) ##11 (header_1 or header_2) |=> (frame_detect == 0);
endproperty 

property misalignment_resilience2;
  @(posedge clk)
  disable iff(reset)
  (frame_detect == 0) ##1 (header_1 or header_2) ##11 (header_1 or header_2) ##11 (rx_data == 8'hAA or rx_data == 8'h55) ##1 (header_1 or header_2) |=> (frame_detect == 0);
endproperty

property alignment_resilience1;
  @(posedge clk)
  disable iff(reset)
  (frame_detect == 1) ##13 (header_1 or header_2) ##48 (frame_detect == 1); // ILLEGAL, LEGAL, ILLEGAL, ILLEGAL, ILLEGAL
endproperty

property alignment_resilience2;
  @(posedge clk)
  disable iff(reset)
  (frame_detect == 1) ##25 (header_1 or header_2) ##36 (frame_detect == 1); // ILLEGAL, ILLEGAL, LEGAL, ILLEGAL, ILLEGAL
endproperty

property alignment_resilience3;
  @(posedge clk)
  disable iff(reset)
  (frame_detect == 1) ##37 (header_1 or header_2) ##24 (frame_detect == 1); // ILLEGAL, ILLEGAL, ILLEGAL, LEGAL, ILLEGAL
endproperty


  // Assertion and Coverage for the valid_frame1 property
assert property (valid_frame1)
  else $error("Error: frame_detect did not rise after three valid headers valid_frame1 in a row at time: %0t", $time);
valid_frame_1_inst: cover property (valid_frame1);

assert property (misalignment)
  else $error("Error: frame_detect did not rise after three valid headers valid_frame1 in a row at time: %0t", $time);
misalignment_inst: cover property (misalignment);

misalignment_resilience1_inst: cover property(misalignment_resilience1);
misalignment_resilience2_inst: cover property(misalignment_resilience2);

alignment_resilience1_inst: cover property(alignment_resilience1);
alignment_resilience2_inst: cover property(alignment_resilience2);
alignment_resilience3_inst: cover property(alignment_resilience3);


endmodule

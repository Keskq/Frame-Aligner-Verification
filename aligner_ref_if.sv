interface aligner_ref_if ;
  logic clk;
  logic reset;
  logic [3:0] fr_byte_position;  
  logic frame_detect;           
  logic [7:0] rx_data;         
  
    
endinterface: aligner_ref_if
  

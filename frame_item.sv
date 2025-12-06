`include "uvm_macros.svh"
import uvm_pkg::*;

class frame_item extends uvm_sequence_item;
  
  `uvm_object_utils(frame_item)  

  typedef enum bit [1:0] {HEAD_1, HEAD_2, ILLEGAL} header_type;
  
  rand header_type header;        // סוג הפריים
  rand byte payload[];            // נתונים אחרי ההדר
  logic [15:0] header_value;      // הערך הבינארי של ההדר

  function new(string name="frame_item");
    super.new(name);
    payload = new[0];             // initialize dynamic array
  endfunction
  
  function void post_randomize();
    case (header)
      HEAD_1: header_value = 16'hAFAA;
      HEAD_2: header_value = 16'hBA55;
      ILLEGAL: header_value = $urandom_range(16'h0000, 16'hFFFF);
    endcase

    // Generate random payload values after randomizing size
    foreach (payload[i])
      payload[i] = $urandom_range(0, 255);
  endfunction
  
  /*
  
  // Distribution of headers
  constraint header_distribution {
    header dist {HEAD_1 := 50, HEAD_2 := 50, ILLEGAL := 0};
    //header dist {HEAD_1 := 40, HEAD_2 := 40, ILLEGAL := 20};

  }
  
  */
  
  // Constraint for payload size only
  constraint payload_c {
    if (header == ILLEGAL)
      payload.size() inside {[0:46]}; 
    else
      payload.size() == 10;
  }
  
  
  
endclass

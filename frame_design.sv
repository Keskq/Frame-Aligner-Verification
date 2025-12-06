//  Algorithm.
//  Author: Ilan Rachmanov   

//--------------------------------------------------------------
// Frame aligner block. Implementation of the frame aligner
// Algorithm.
// Author: Ilan Rachmanov   

interface aligner_if ;
  logic clk;
  logic reset;
  logic [3:0] fr_byte_position; 
  logic frame_detect;           
  logic [7:0] rx_data;    
  
  
endinterface  


module frame_aligner (aligner_if i_inf   // Using the interface for DUT connections
) ;
           
   // Counters
   reg [1:0] legal_frame_counter; // Counts number of consecutive legal frames detected
   reg [5:0] na_byte_counter;     // Counts number of "Not Aligned" bytes until header detection
   reg [7:0] header_lsb_samp;     // Stores sampled LSB of header for validation
   
   // FSM control triggers
   reg fr_byte_position_rst;      // Reset trigger for fr_byte_position
   reg na_byte_count_inc;         // Increment trigger for na_byte_counter
   reg na_byte_count_rst;         // Reset trigger for na_byte_counter
   reg legal_frame_counter_rst;   // Reset trigger for legal_frame_counter
   reg legal_frame_counter_inc;   // Increment trigger for legal_frame_counter

   // FSM states for frame alignment process
   typedef enum reg [1:0] {
       FR_IDLE = 2'b00,   // Idle state, waiting for header detection
       FR_HLSB = 2'b01,   // Detecting LSB of the header
       FR_HMSB = 2'b10,   // Detecting MSB of the header
       FR_DATA = 2'b11    // Receiving frame data after header alignment
   } frame_aligner_state_e;
   
   frame_aligner_state_e current_state, next_state; // FSM current and next state registers

   // Header validation signals
   wire header_msb_valid;   // Indicates that the MSB of the header is valid
   wire header_lsb_valid;   // Indicates that the LSB of the header is valid

   //--------------------------------------------------------------
   //--------------------------------------------------------------
   // Frame Aligner state machine
   
   always @ (posedge i_inf.clk or  posedge i_inf.reset)
     begin
	if (i_inf.reset)
	  current_state <= FR_IDLE;
	else
	  current_state <= next_state;
     end

       
   
   always @ (*)
     begin
    
       
	fr_byte_position_rst = 1'b0;
	na_byte_count_inc = 1'b0;
	na_byte_count_rst = 1'b0;
	legal_frame_counter_rst = 1'b0;
	legal_frame_counter_inc = 1'b0;

	case(current_state)
	  FR_IDLE:
	    begin
	       if(header_lsb_valid)
		 begin
		    fr_byte_position_rst = 1'b1;
		    na_byte_count_inc = 1'b1;
		    next_state = FR_HLSB;
		 end
	       else
		 begin
		    legal_frame_counter_rst = 1'b1;
		    fr_byte_position_rst = 1'b1;
		    na_byte_count_inc = 1'b1;
		    next_state = FR_IDLE;
		 end
	    end
	  FR_HLSB:
	    begin
	       if(header_msb_valid)
		 begin
		    legal_frame_counter_inc = 1'b1;
		    next_state = FR_HMSB;
		 end
	       else
		 begin
		    legal_frame_counter_rst = 1'b1;
		    na_byte_count_inc = 1'b1;
		    next_state = FR_IDLE;
		 end
	    end
	  FR_HMSB:
	    begin
	       next_state = FR_DATA;
	    end
	  FR_DATA:
	    begin
	       if(i_inf.fr_byte_position == 8'd10)
		 begin
		    na_byte_count_rst = 1'b1;
		    next_state = FR_IDLE;
		 end
	       else
		 next_state = FR_DATA;
	    end
	endcase
	  
     end
   
   //--------------------------------------------------------------
   //--------------------------------------------------------------
	
   // The code below searches the header pattern and send indications to the FSM to advance to FR_HLSB and FR_HMSB states
   // first the lsb pattern is sampled . in case the msb pattern matches , the FSM will advance to FR_HMSB
   assign header_lsb_valid = (i_inf.rx_data == 8'haa) || (i_inf.rx_data == 8'h55);
   
     always @ (posedge i_inf.clk or  posedge i_inf.reset)
       begin
	  if (i_inf.reset)
	    header_lsb_samp <= 8'h0; 
	  else if (header_lsb_valid)
	    header_lsb_samp <= i_inf.rx_data;
       end

   /// expected lsb header pattern:
   wire [7:0] expected_header_msb = (header_lsb_samp == 8'haa) ? 8'haf : ( (header_lsb_samp == 8'h55) ? 8'hba : 8'h00); // 00 is illegal since header_lsb_samp can be only 55 or aa
   
   assign header_msb_valid = (expected_header_msb == i_inf.rx_data);
   
   //--------------------------------------------------------------
   //--------------------------------------------------------------
   
   // The code below is implementation of the legal frame counter ,  byte position  . and not aligned byte counter which accepts triggeres from the FSM


   //     increments by default , rst is controlled by the fsm
   always @ (posedge i_inf.clk or  posedge i_inf.reset)
     begin
	if (i_inf.reset)
	  i_inf.fr_byte_position <= 4'h0;
	else if (fr_byte_position_rst)
	  i_inf.fr_byte_position <= 4'h0;
	else
	  i_inf.fr_byte_position <= i_inf.fr_byte_position + 1'b1;
     end

   // frame counter for legal frames
   always @ (posedge i_inf.clk or  posedge i_inf.reset)
     begin
	if (i_inf.reset)
	  legal_frame_counter <= 2'h0;
	else if (legal_frame_counter_rst)
	  legal_frame_counter <= 2'h0;
	else if (legal_frame_counter_inc)
	  legal_frame_counter <= legal_frame_counter + 1'b1 ;
	
     end
   
   // na_byte_counter is counting the illegal frames . in case there are 48 continues bytes witout header frame_detect will set low
     always @ (posedge i_inf.clk or  posedge i_inf.reset)
       begin
	  if (i_inf.reset) 
	    na_byte_counter <= 6'h0;
	  else if (na_byte_count_rst)
	    na_byte_counter <= 6'h0;
	  else if (na_byte_count_inc)
	    na_byte_counter <= na_byte_counter + 1'b1;
       end
   
   always @ (posedge i_inf.clk or  posedge i_inf.reset)
     begin
	if (i_inf.reset)
	  i_inf.frame_detect <= 1'b0;
	else if(legal_frame_counter == 2'h3)
	  i_inf.frame_detect <= 1'b1;
	else if(na_byte_counter == 6'd47)
	  i_inf.frame_detect <= 1'b0;
     end


  
  
  always @ (posedge i_inf.clk) begin
    $display("Time=%0t | state=%0s | rx_data=%0h | frame_detect=%0b | fr_byte_position=%0d | frame_counter=%0d | na_byte_counter=%0d",
             $time, current_state.name(), i_inf.rx_data, i_inf.frame_detect, i_inf.fr_byte_position, legal_frame_counter, na_byte_counter);
  end     
    
  
   //--------------------------------------------------------------
   //--------------------------------------------------------------
   
   
endmodule

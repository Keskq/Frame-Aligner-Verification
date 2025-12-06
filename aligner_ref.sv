

module aligner_ref (aligner_ref_if i_ref_if   // Using the interface for DUT connections
) ;

    typedef enum logic [1:0] {
        IDLE,
        H_LSB,
        H_MSB,
        DATA
    } state_t;

    state_t state;

    logic [7:0] previous_byte;
    logic [5:0] na_byte_counter;   // counts up to 47
    logic [3:0] frame_counter;

    // ---------------------------
    //        SEQ LOGIC
    // ---------------------------
    always_ff @(posedge i_ref_if.clk or posedge i_ref_if.reset) begin
        if (i_ref_if.reset) begin
            state            <= IDLE;
            frame_counter    <= 0;
            na_byte_counter  <= 0;
            i_ref_if.fr_byte_position <= 0;
            i_ref_if.frame_detect     <= 0;
            previous_byte    <= 0;
        end

        else begin
            case (state)

            // =====================================================
            //                      IDLE
            // =====================================================
            IDLE: begin

                // --- Reset byte position ---
                i_ref_if.fr_byte_position <= 0;

                // --- Reset frame counter ---
                //frame_counter <= 0;

                // --- Reset frame_detect exactly like old DUT ---
                if (na_byte_counter == 47)
                    i_ref_if.frame_detect <= 0;
              
                // --- Increase NA counter ---
                na_byte_counter <= na_byte_counter + 1;

                // --- Header LSB detected? ---
                if (i_ref_if.rx_data == 8'hAA || i_ref_if.rx_data == 8'h55) begin
                    state         <= H_LSB;
                    previous_byte <= i_ref_if.rx_data;
                end

                else begin
                    // No header → wrap NA counter
                    if (na_byte_counter == 47)
                        na_byte_counter <= 0;
                end
            end


            // =====================================================
            //                     HEADER LSB
            // =====================================================
            H_LSB: begin

                i_ref_if.fr_byte_position <= 1;

                if ( (previous_byte == 8'hAA && i_ref_if.rx_data == 8'hAF) ||
                     (previous_byte == 8'h55 && i_ref_if.rx_data == 8'hBA) )
                begin
                    // Valid header
                    state <= H_MSB;
                    frame_counter <= frame_counter + 1; 
                    
                end
                else begin
                    // Bad header → treat as NA byte
                    na_byte_counter <= na_byte_counter + 1;
                    frame_counter <= 0;
                    state <= IDLE;
                end
            end


            // =====================================================
            //                     HEADER MSB
            // =====================================================
            H_MSB: begin
                i_ref_if.fr_byte_position <= 2;
                state <= DATA;
                if (frame_counter==3)
                    i_ref_if.frame_detect  <= 1;   // <--- START OF FRAME
            end


              // =====================================================
            //                       DATA
            // =====================================================
            DATA: begin
                i_ref_if.fr_byte_position <= i_ref_if.fr_byte_position + 1;
                
                
                // Packet ends when byte position is 10
                if (i_ref_if.fr_byte_position == 10) begin
                    na_byte_counter <= 0;
                    state <= IDLE;
                end
            end

            endcase
            $display("Time=%0t | state=%0s | rx_data=%0h | frame_detect=%0b | fr_byte_position=%0d | frame_counter=%0d | na_byte_counter=%0d",
               $time, state.name(), i_ref_if.rx_data, i_ref_if.frame_detect, i_ref_if.fr_byte_position, frame_counter, na_byte_counter);
          
        end
    end

endmodule







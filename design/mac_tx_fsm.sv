// FILE : MAC TRANSMITTER
// Author : MEITAR SHIMONI
// DESCRIPTION : MAC Module that control transmittions of NxN Matrixes. 
module mac_tx_fsm(
    input system_clock,
    input clock_enable,
    input rst_n,

    input start,
    input [7:0] data_in,
    input [14:0] num_bytes,

    input busy_uart,
    output reg start_uart,
    output reg [7:0] urt_tx_data,

    output reg busy,
    output reg [16:0] data_counter, // change to 17 bits to be able to do 256x256 = 65,536
    output reg [7:0] line_counter
    
);

typedef enum logic [2:0] {IDLE,START, UART, SPECIAL_CHAR} state_e;
state_e current_state, next_state;
reg done;
reg [15:0] row_counter;


//-------------          ------------------------------
always @(posedge system_clock or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else if(clock_enable) current_state <= next_state;
end


//-------------          ------------------------------
always @(posedge system_clock or negedge rst_n) begin
    if(!rst_n) begin
        row_counter <= 0;
        line_counter <= 0;
        data_counter <= 0;
        urt_tx_data <= 0;
        start_uart <= 0;
        busy <= 0;
        done <= 0;
    end else if(clock_enable) begin
        case (next_state) 
            IDLE:
                begin
                    start_uart <= 0;
                    done <= 0;
                    busy <= 0;
                    data_counter <= 0;
                    row_counter <= 1;
                    line_counter <= 0;
                end
            START:
                begin
                    start_uart <= 1;
                    busy <= 1;
                    if(current_state == IDLE) urt_tx_data <= data_in;
                    
                   $display("UART  START WITH DATA: %h Actual DATA: %d",urt_tx_data,data_counter);
                end
            UART:
                begin
                    start_uart <= 0;
                end
            SPECIAL_CHAR:
                begin
                    
                    start_uart <= 0;
                    row_counter <= row_counter+1; 
                    if(row_counter == (num_bytes*2-1)) begin // NEW LINE
                        urt_tx_data <= 8'h0D;
                    end else if(row_counter == num_bytes*2) begin
                        urt_tx_data <= 8'h0A;
                        row_counter <= 0;
                        line_counter <= line_counter + 1;
                    end else if((row_counter[0] == 1) && (row_counter != num_bytes*2) && (row_counter != num_bytes*2-2) ) begin // SPACE
                        urt_tx_data <= 8'h20; // SPACE
                    end else begin 
                        urt_tx_data <= data_in;
                        data_counter <= data_counter + 1;
                    end
                    if((data_counter == num_bytes*num_bytes-1)) done <= 1;
                end
            default: start_uart <= 0;
        endcase
    end
end

//-------------          ------------------------------
always @(*) begin
    case (current_state) 
        IDLE: 
        begin 
        next_state = (start == 1) ? START : IDLE; 
        end
        START: next_state = UART; 
        UART: 
        begin
            if((num_bytes == 1) &&( busy_uart == 0 )) next_state = IDLE;
            else if(busy_uart == 0) next_state = SPECIAL_CHAR;
            else next_state = UART;
        end
        SPECIAL_CHAR: next_state = (data_counter == num_bytes*num_bytes) ? IDLE : START;
        default: next_state = IDLE;
    endcase
end
endmodule

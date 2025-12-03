// FILE : DEBOUNCER 
// Author : MEITAR SHIMONI
// DESCRIPTION : Latch in data after a press of CAPTURE_TIME
// also decodes different values for the system  
module button_counter #(parameter CAPTURE_TIME = 64)( // 1736
    input clk, 
    input CE,
    input reset_n,
    input center_button,

    input [7:0] data,
    input [1:0] delay,
    input [1:0] bytes2send,
    output reg start_latch,
    output reg [7:0] data_latch,
    output reg [14:0] bytes_to_send,
    output reg [1:0] delay_latch, 
    output reg [7:0] delay_disp
    );

reg [15:0] count; // 16 bits to count up to 57,603 which is 1 second from thr baud rate clock

always @(posedge clk or negedge reset_n) begin  // clk 3200Hz
    if(!reset_n) begin
        count <= 0;   
        data_latch <= 0;
        bytes_to_send <= 0;
        delay_latch <= 0;
        delay_disp <= 0;
        start_latch <= 0;
    end else if(CE) begin
        if (center_button) begin
            if (count == CAPTURE_TIME) begin
                count <= 0;
                data_latch <= data;
                delay_latch <= delay;
                start_latch <= center_button;
                case(delay) 
                    2'b00:  delay_disp = 8'h00;
                    2'b01:  delay_disp = 8'h05; // 50 (0.5)
                    2'b10:  delay_disp = 8'h10; // 100 (1.0)
                    2'b11:  delay_disp = 8'h20; // 200 (2.0)
                    default: delay_disp = 8'h00;
                endcase
                case (bytes2send)
                    2'b00:  bytes_to_send = 1;
                    2'b01:  bytes_to_send = 32; // change back to 32!
                    2'b10:  bytes_to_send = 128;  // 128
                    2'b11:  bytes_to_send = 256; // 256
                    default: bytes_to_send = 1;
                endcase

            end else begin
                count <= count+1;
                start_latch <= 0;
            end
        end else begin 
            start_latch <= 0;
            count <=0;
        end
    end end

endmodule

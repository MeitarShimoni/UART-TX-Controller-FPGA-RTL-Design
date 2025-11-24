module uart_fsm_1(
    input system_clock,
    input clock_enable,
    input rst_n,
    input center_push,
    input [7:0] data_in,
    input [1:0] delay,
    output reg tx_busy,
    output reg Tx
    );
    
    localparam int CNT_50MS = 2881/2;
    localparam int CNT_100MS = 5761/2;
    localparam int CNT_200MS = 11521/2;
    

//localparam IDLE = 3'b000;
//localparam START = 3'b001;
//localparam DATA = 3'b010;
//localparam STOP = 3'b100;

typedef enum logic [2:0] {IDLE,START,DATA,STOP,WAIT} state_e;

state_e current_state, next_state;
//reg [3:0] current_state, next_state;
reg [3:0] data_counter;
reg [7:0] data_reg; 

// delay:
// reg start_count;
reg [14:0] delay_val;
reg [14:0] count_delay;

// ----------------- Delay modes decoder ----------------------
always @(*) begin
    case(delay)
        2'b00: delay_val = 0; // no delay
        2'b01: delay_val = CNT_50MS; //change based BR to 50ms
        2'b10: delay_val = CNT_100MS; //change based BR to 100ms
        2'b11: delay_val = CNT_200MS; //change based BR to 200ms
        default: delay_val = 0; //change based BR
    endcase
end

// --------------------- State register --------------------- 
always @(posedge system_clock or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else if(clock_enable) current_state <= next_state;
end

// --------------------- next state logic --------------------- 
always @(posedge system_clock or negedge rst_n) begin
    if(!rst_n) begin
        Tx <= 1;
        data_counter <= 0;
        count_delay <= 0;
        tx_busy  <= 0;
        data_reg <= 0;
        end else if(clock_enable) begin
//    $display("State: %s", current_state);
    case (next_state) // ? MAYBE TO USE UNIQUE CASE SINCE IT'S ONE HOT ?
    IDLE: 
        begin
            Tx <= 1;
            tx_busy <= 0;
            // start_count <= 0;
        end
    START: 
        begin
            tx_busy <= 1;
            Tx <= 0;
            data_counter <= 0;
            data_reg <= data_in; 
        end
    DATA: 
        begin
            data_counter <= data_counter+1;
            Tx <= data_reg[0];
            data_reg <= { 1'b0 ,data_reg[7:1]}; // shift left
        end
    STOP: 
        begin
            Tx <= 1;
            count_delay <= 0;
        end
     WAIT: 
     begin
         count_delay <= count_delay + 1;
     end
        default: begin Tx <= 1'b0; data_counter <=0; tx_busy <= 0; end 
    endcase
    end
end
// -------------------------------------------------------------------
always @(*) begin
    case(current_state)     // ? MAYBE TO USE UNIQUE CASE SINCE IT'S ONE HOT ?    
        IDLE: next_state = (center_push == 1) ? START : IDLE;
        START: next_state = (current_state == START) ? DATA : START;
        DATA: next_state = (data_counter == 8) ? STOP : DATA;
        STOP: next_state = (delay_val == 0) ? IDLE : WAIT; // or to add if delay ==0 then go to IDLE
        WAIT: next_state = (count_delay == delay_val) ? IDLE : WAIT;
        default: next_state = IDLE;
    endcase
end

// always @(posedge system_clock or negedge rst_n) begin
//     if(!rst_n) begin
//         delay_counter <= 0;
//     end else if(clock_enable) begin
//         if(start_count) begin
//             if(delay_counter == delay) begin
//                 delay_counter <= 0;
//             end else delay_counter <= delay_counter + 1;
//         end else
//         delay_counter <= 0;
//     end

// end


endmodule
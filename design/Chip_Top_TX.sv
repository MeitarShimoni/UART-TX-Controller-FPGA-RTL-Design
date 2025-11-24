module Chip_Top_TX(
    input system_clock,
    input cpu_rst_n,
    
    input start_push,
    input [1:0] delay,
    input [7:0] data_to_send,
    input [1:0] num_bytes_to_send,

    output tx, // should i connect to UART_TXD_IN???
    output led_toggle,
    // output [14:0] data_counter, // temporaty
    output busy,
    output not_busy,
    output done,

    output [6:0] cathodes_out,
    output dot, // DP
    output [7:0] anode_out
//    ,output [7:0] delay_latch
    );

//reg clk_32;
reg [7:0] data_latch, delay_disp;
//wire not_busy;
assign not_busy = ~(busy);
wire [1:0] delay_latch;
reg [14:0] bytes_to_send;
reg [16:0] data_counter; // should be 15 to 0 but the in seven segment we have 2 digits (upto [F][F] = 255).
assign led_toggle = data_counter[0];
wire [7:0] line_counter;

// UPDATE: Button gets the Clock of Baudrate and not 3200Hz
clock_divider clk_div(.system_clock(system_clock), .rst_n(cpu_rst_n), .clock_enable(baud_rate_enable));

// -------------------------------------- latch input ----------------------------------------------------
button_counter btn_instance(.clk(system_clock), .CE(baud_rate_enable), .reset_n(cpu_rst_n), 
.center_button(start_push), .data(data_to_send), .delay(delay),
.bytes2send(num_bytes_to_send), .start_latch(start_latch), .data_latch(data_latch), .bytes_to_send(bytes_to_send), 
.delay_latch(delay_latch),.delay_disp(delay_disp));

// instnace the top module
top_transmitter UART_TX_CONTROLLER(.system_clock(system_clock), .clock_enable(baud_rate_enable), .rst_n(cpu_rst_n), .start(start_latch),
.data_to_send(data_latch), .num_bytes_to_send(bytes_to_send),  .data_counter(data_counter), .line_counter(line_counter),
.tx(tx) , .busy(busy), .delay(delay_latch), .done(done) );
// .delay(delay_latch),

// ---------------------------------------- display ----------------------------------------------------
clock_divider32 clk_div3200(.sys_clk(system_clock), .reset_n(cpu_rst_n), .clk_32(clk_32));

top_seven_segment_controller display(.system_clock(system_clock), .clock_enable(clk_32),
.cpu_rst_n(cpu_rst_n), .value2disp({line_counter[7:0],bytes_to_send[7:0], delay_disp[7:0], data_latch[7:0]}), .cathodes_out(cathodes_out),.dot(dot), .anode_out(anode_out)
);



endmodule
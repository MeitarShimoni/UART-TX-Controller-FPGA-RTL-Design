// ------------------------------------------------------------------------------------
            // num_bytes_to_send
            // 00 - > 1
            // 01 - > 10
            // 10 - > 128
            // 11 - > 256
            
            // delay :
            // 00 - > 0
            // 00 - > 50ms not working yet
            // 00 - > 100ms not working yet
            // 00 - > 200ms not working yet
// ------------------------------------------------------------------------------------

module tb_chip_top;


localparam NUM_TRANS_1 = 2'b00; // send 1 byte
localparam NUM_TRANS_32 = 2'b01; // send 32 bytes
localparam NUM_TRANS_128 = 2'b10; // send 128 bytes
localparam NUM_TRANS_256 = 2'b11; // send 256 bytes

localparam NO_DELAY = 2'b00; // no delay at all
localparam DELAY_50MS = 2'b01; // 10ms selay
localparam DELAY_100MS = 2'b10; // 100ms selay
localparam DELAY_200MS = 2'b11; // 200ms selay
localparam int START_WIDTH_CE = 100;


logic system_clock, cpu_rst_n, start;

logic [1:0] delay;
logic [1:0] num_bytes_to_send;
logic [7:0] data_to_send;
logic tx, led_toggle;
logic busy,not_busy, done;
logic [6:0] cathodes_out;
logic [7:0] anode_out;





task automatic send_data(
    input logic [7:0] data,
    input logic [1:0] num_bytes,
    input logic [1:0] del
    );
    if (busy) @(negedge busy);

    repeat (10) @(posedge CE);

    data_to_send      = data;
    num_bytes_to_send = num_bytes;
    delay             = del;

    @(posedge CE);
    start = 1;
    $display("TIME: %0t | DATA: %h | BYTES: %b | DELAY: %b",
             $time, data_to_send, num_bytes_to_send, delay);

    repeat (START_WIDTH_CE) @(posedge CE);
    start = 0;

    @(negedge busy);
endtask




Chip_Top_TX DUT(
    .system_clock(system_clock),
    .cpu_rst_n(cpu_rst_n),

    .start_push(start),
    .delay(delay),
    .data_to_send(data_to_send),
    .num_bytes_to_send(num_bytes_to_send),
    .tx(tx),
    .led_toggle(led_toggle),
    // .data_counter(data_counter),
    .busy(busy),
    .not_busy(not_busy),
    .done(done),

    .cathodes_out(cathodes_out),
    .anode_out(anode_out)
//    ,.delay_latch(delay_latch) // temporary

);

// instances clock divider for baud rate
//clock_divider clk_dut(.system_clock(system_clock), .rst_n(cpu_rst_n),.clock_enable(CE));
clock_divider baud_rate_dut(.system_clock(system_clock), .rst_n(cpu_rst_n), .clock_enable(CE));

always #5 system_clock = ~system_clock;

initial begin
    delay         = 0;
    system_clock  = 0;
    cpu_rst_n     = 1;
    data_to_send  = 0;
    start         = 0;

    @(negedge system_clock) cpu_rst_n = 0;
    @(negedge system_clock) cpu_rst_n = 1;

    repeat (30) @(posedge CE);

    // ---------------- TEST 1: Send 1 Byte without delay ------------------
    send_data(8'h51, NUM_TRANS_1, NO_DELAY);

    // ---------------- TEST 2: Send 32 Bytes with delay 50ms ----------------
    send_data(8'h51, NUM_TRANS_32, DELAY_100MS);

    // ---------------- TEST 3: Example 32 bytes with different data ------------------
    send_data(8'd123, NUM_TRANS_32, DELAY_200MS);

    repeat (100) @(posedge CE);
    $finish;
end

endmodule




module tb_top_transmitter;


logic system_clock;
logic rst_n;
logic start;

logic [7:0] data_to_send;
logic tx;

logic [15:0] data_counter;
logic [14:0] num_bytes_to_send;

top_transmitter dut(.system_clock(system_clock), .rst_n(rst_n),
.start(start), .data_to_send(data_to_send), .num_bytes_to_send(num_bytes_to_send),
.data_counter(data_counter), .tx(tx), .busy(busy), .done(done));
//  .busy(busy), .done(done)

// instances clock divider for baud rate
clock_divider clk_dut(.system_clock(system_clock), .rst_n(rst_n),
.clock_enable(CE));



always #5 system_clock = ~system_clock;

initial begin

system_clock = 0;
rst_n = 1;
data_to_send = 0;
start = 0;
@(negedge system_clock) rst_n = 0;
@(negedge system_clock) rst_n = 1;

repeat(30) @(posedge CE);
// ---------------- TEST 1: Send 10 Bytes ------------------
data_to_send = 8'h11;
num_bytes_to_send = 10;
@(posedge CE);
start = 1;
@(posedge CE) start = 0;

// ---------------- TEST 2: Send 32 Bytes ------------------
@(negedge done) repeat(100) @(posedge CE);
data_to_send = 8'h25;
num_bytes_to_send = 32;
@(posedge CE);
start = 1;
@(posedge CE) start = 0;


// ---------------- TEST 3: Send 128 Bytes ------------------
@(negedge done) repeat(100) @(posedge CE);
data_to_send = 8'h11;
num_bytes_to_send = 128;
@(posedge CE);
start = 1;
@(posedge CE) start = 0;


// ---------------- TEST 4: Send 256 Bytes ------------------
@(negedge done) repeat(100) @(posedge CE);
data_to_send = 8'h25;
num_bytes_to_send = 256;
start = 1;
@(posedge CE) start = 0;




end




endmodule
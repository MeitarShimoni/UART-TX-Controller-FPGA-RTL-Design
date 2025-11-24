module tb_uart_fsm_1;

logic clk;
logic rst_n;
logic center_push;
logic [7:0] data_in;
logic Tx;
logic busy;


// instance
uart_fsm_1 dut(.clk(clk), .rst_n(rst_n), .center_push(center_push), .data_in(data_in),
.busy(busy), .Tx(Tx) );

logic [7:0] data_out[8]; // queue!

always #5 clk = ~clk;

initial begin
    $monitor("Time: %t | center_push: %b | TX: %b | ", $time(), center_push, Tx);
    clk = 0;
    rst_n = 1;
    center_push = 0;
    data_in = 0;
    @(negedge clk);
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);
    data_in = 8'b1000_1101;
    #6;
    
    center_push = 1;
    @(posedge clk);
    // check_data();

    #200;
    $display("Simulation Finished!");

    $finish;
end


// task check_data();

//     for (int i = 0 ;i < 8 ;i++ ) begin
//         @(posedge clk);
//         data_out[i] = Tx;
//     end

//     assert(data_out == data_in) $display("DATA Match!"); 
//     else $error("DISMACH DATA!"); 


// endtask


endmodule
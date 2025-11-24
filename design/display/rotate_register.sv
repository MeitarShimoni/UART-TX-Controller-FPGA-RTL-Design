module rotate_register#(parameter DATA_WIDTH = 8)(
    input clk,
    input CE,
    input reset_n,
    output reg [DATA_WIDTH-1:0] parallel_out
);

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
//        parallel_out <= 8'b0111_1111;
        parallel_out <= 8'b1000_0000;
    end else if (CE) begin
        parallel_out <= {parallel_out[0], parallel_out[7:1]};
    end else parallel_out <= parallel_out; // is it necessery?
end

endmodule


//module rotate_register#(parameter DATA_WIDTH = 8)(
//    input clk,
//    input CE,
//    input reset_n,
//    output reg [DATA_WIDTH-1:0] parallel_out
//);

//always @(posedge clk or negedge reset_n) begin
//    if(!reset_n) begin
//        parallel_out <= 8'b0111_1111;
//    end else if (CE) begin
//        parallel_out <= {parallel_out[0], parallel_out[7:1]};
//    end else parallel_out <= parallel_out; // is it necessery?
//end

//endmodule
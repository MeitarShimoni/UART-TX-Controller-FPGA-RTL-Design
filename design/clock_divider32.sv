module clock_divider32#(parameter int div_by = 31250)(
    input sys_clk,
    input reset_n,
    //input CE,
    output reg clk_32
);

// 2^15 is enoght
reg [15:0] count;


always @(posedge sys_clk or negedge reset_n) begin
    if(!reset_n) begin
        // reset
        count <= 0;
        clk_32 <= 0;
    end else begin
        if(count == (div_by/1)-1) begin
            clk_32 <= 1;
            count <= 0;
        end else begin
            count++;
            clk_32 <= 0;
        end
    end

end

// add to input CE.
//always_ff @(posedge sys_clk or negedge reset_n) begin
//    if(!reset_n) begin
//      clk_32 <= 0;
//      count <= 0;
//    end else if(CE) begin
//        if(count == 12) begin
//            clk_32 <= 1;
//            count <= 0;
//        end else begin
//            count++;
//            clk_32 <= 0;
//        end 
//    end else clk_32 <= 0;
//end


endmodule
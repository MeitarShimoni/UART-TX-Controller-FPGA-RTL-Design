module clock_divider#(parameter int divider = 1736)(
    input system_clock,
    input rst_n,
    output reg clock_enable
);

reg [10:0] counter;

always @(posedge system_clock or negedge rst_n ) begin
    if(!rst_n) begin
        counter <= 0;
        clock_enable <= 0;
    end else if(counter == divider-1) begin
        clock_enable <= 1'b1;
        counter <=0;
    end else begin
        clock_enable <= 1'b0;
        counter <= counter + 1;
    end
end

endmodule
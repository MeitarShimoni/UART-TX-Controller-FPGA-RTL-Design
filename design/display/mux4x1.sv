module mux4x1(
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    input [3:0] in4,
    input [3:0] in5,
    input [3:0] in6,
    input [3:0] in7,
    input [2:0] sel,
    output reg [3:0] mux_out
);

always @(*) begin
    case (sel)
        3'b000: mux_out = in0;
        3'b001: mux_out = in1;
        3'b010: mux_out = in2;
        3'b011: mux_out = in3;
        3'b100: mux_out = in4;
        3'b101: mux_out = in5;
        3'b110: mux_out = in6;
        3'b111: mux_out = in7;
        default: mux_out = 0; // Default case
    endcase
end

endmodule
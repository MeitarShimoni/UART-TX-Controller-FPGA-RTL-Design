// FILE : MUX8x1
// Author : MEITAR SHIMONI
// DESCRIPTION : DECODING COMMON ANODE

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
        3'd0: mux_out = in0;
        3'd1: mux_out = in1;
        3'd2: mux_out = in2;
        3'd3: mux_out = in3;
        3'd4: mux_out = in4;
        3'd5: mux_out = in5;
        3'd6: mux_out = in6;
        3'd7: mux_out = in7;
        default: mux_out = 0; // Default case
    endcase
end

endmodule

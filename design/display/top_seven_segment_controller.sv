// FILE : SEVEN SEGMENT CONTROLLER 
// Author : MEITAR SHIMONI
// DESCRIPTION : DISPLAY ON 7 SEGMENT VALUE FOR HEXA ONLY 

module top_seven_segment_controller(
    input system_clock, 
    input clock_enable,
    input cpu_rst_n,

    input [7:0] seg87,
    input [7:0] seg65,
    input [7:0] seg43,
    input [7:0] seg21,
    output [6:0] cathodes_out, 
    output [7:0] anode_out

);

wire [2:0] anode_sel;
wire [3:0] hexa_digit;


wire [32:0] total_disp;
assign total_disp = {seg87,seg65,seg43,seg21};
// ---------------------------------
rotate_register rot_reg_inst(
    .clk(system_clock),
    .CE(clock_enable),
    .reset_n(cpu_rst_n),
    .parallel_out(anode_out)
);

// ---------------hexa 
anode_decoder anode_dec_inst(
    .anode_in(anode_out),
    .anode_sel(anode_sel)
);


mux4x1 mux_inst(
    .in0(seg87[7:4]), //f
    .in1(seg87[3:0]), // f
    .in2(seg65[7:4]), // f
    .in3(seg65[3:0]), // f
    .in4(seg43[7:4]),
    .in5(seg43[3:0]),
    .in6(seg21[7:4]),
    .in7(seg21[3:0]),
    .sel(anode_sel),
    .mux_out(hexa_digit)
);



decoder_bin2hex dec_inst(
    .bin_in_hex(hexa_digit),
    .decoded(cathodes_out)
);


endmodule

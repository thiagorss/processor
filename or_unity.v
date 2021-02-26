module or_unity(en, in1, in2, out);
	input en;
	input [15:0] in1, in2;
	output [15:0] out;
	
	assign out = in1 | in2;
endmodule

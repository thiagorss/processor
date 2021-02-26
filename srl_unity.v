module srl_unity(en, in1, in2, out);
	input en;
	input [15:0] in1, in2;
	output reg [15:0] out;
	
	always @(*) begin
		if (en)
			out <= (in1 >> in2);
	end
endmodule
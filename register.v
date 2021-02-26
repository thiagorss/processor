module register(clock, in, en, out);
	parameter n = 16;
	input clock, en;
	input [n-1:0] in;
	
	output reg [n-1:0] out;
	
	initial
		out = 0;
	
	always @(posedge clock) begin
		if (en)
			out <= in;
	end
endmodule
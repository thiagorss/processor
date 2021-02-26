module upcount(clock, clear, out);
	input clock, clear;
	output reg [2:0] out;

	always @(posedge clock) begin
		if (clear)
			out <= 3'b0;
//		else if (out > 3)
//			out <= 3'b0;
		else
			out <= out + 1'b1;
	end
endmodule

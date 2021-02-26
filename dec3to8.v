module dec3to8(w, en, out);
	input en;
	input [2:0] w;
	output reg [7:0] out;
	
	always @(w or en) begin
		if (en == 1)
			case (w)
				3'b000: out = 8'b10000000;					//reg_in 7
				3'b001: out = 8'b01000000;					//reg_in 6
				3'b010: out = 8'b00100000;					//reg_in 5
				3'b011: out = 8'b00010000;					//reg_in 4
				3'b100: out = 8'b00001000;					//reg_in 3
				3'b101: out = 8'b00000100;					//reg_in 2
				3'b110: out = 8'b00000010;					//reg_in 1
				3'b111: out = 8'b00000001;					//reg_in 0
			endcase
		else
			out = 8'b0;
	end
endmodule
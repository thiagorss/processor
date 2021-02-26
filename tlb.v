module tlb(in, data, clock, w, out);
	input clock, w;
	input [15:0] in, data;
	output [15:0] out;

	tlb_table t_tlb(in[5:0], clock, data, w, out);	
endmodule
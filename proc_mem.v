module proc_mem(clock, resetn, run);
	input clock, resetn, run;
	
	reg mem_en;
	wire w, done;
	wire [2:0] tstep;
	wire [15:0] din_q, out, addr, dout_data, r7;						//fios internos
	wire [15:0] bus_wires;
	
	initial
		mem_en = 0;
	
	always @(*) begin
		mem_en = w & ~(addr[15] | addr[14] | addr[13] | addr[12]);
	end
	
	ramlpm1 instruction_memory(addr[6:0], resetn, clock, dout_data, 1'b0, din_q);
	ramlpm data_memory(addr[6:0], clock, dout_data, w, out);
	proc processor(din_q, run, resetn, clock, addr, bus_wires, dout_data, w, tstep, done, r7);
endmodule

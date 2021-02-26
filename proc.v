module proc(din, run, resetn, clock, addr, bus_wires, dout, w, step_out, done, r7);
	input run, resetn, clock;
	input [15:0] din;
	
	output w;
	output [2:0] step_out; 									//saida do contador e entrada do controlador. Sinal do controlador
	output [15:0] addr, dout, r7;
	
	output reg done;
	output reg [15:0] bus_wires;
	
	//declarando as variaveis
	wire clear = done || ~resetn;
	wire w;
	wire [2:0] step_out;
	wire [3:0] instruction;	
	wire [7:0] reg_x, reg_y;
	wire [9:0] ir;
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
	wire [15:0] a, b, c, d, e, g, h, i, j, k;
	wire [15:0] addsub_out, or_out, slt_out, sll_out, srl_out;
	wire [15:0] addr_logical;
	
	reg write_16b, mvi_indice;
	reg ir_in, a_in, g_in, b_in, h_in, c_in, i_in, d_in, e_in, j_in, k_in;
	reg dout_in, addr_in, or_in, slt_in, sll_in, srl_in;
	reg incr_pc, w_d, add_sub;
	reg	g_out, h_out, i_out, j_out, k_out, din_out;
	reg [7:0] reg_in, reg_out;
	reg [13:0] mux;												//14 bits pois se liga a 10 registradores
	
	
	assign instruction = ir[9:6];
	
	upcount tstep(clock, clear, step_out);
	dec3to8 register_x(ir[5:3], 1'b1, reg_x);
	dec3to8 register_y(ir[2:0], 1'b1, reg_y);
	tlb tlb1(din, dout, clock, w, addr_logical);
	
	always @(step_out or instruction or reg_x or reg_y) begin
		//definindo as variaveis
		ir_in = 0;
		incr_pc = 0;
		mvi_indice = 0;
		
		//variaveis add
		add_sub = 0;
		a_in = 0;
		g_in = 0;
		
		//variaveis load, store
		dout_in = 0;
		addr_in = 0;
		w_d = 0;
		
		//variaveis or
		or_in = 0;
		b_in = 0;
		h_in = 0;
		
		//variaveis slt
		slt_in = 0;
		c_in = 0;
		i_in = 0;
		
		//variaveis sll
		sll_in = 0;
		d_in = 0;
		j_in = 0;
		
		//variaveis srl
		srl_in = 0;
		e_in = 0;
		k_in = 0;
		
		//fios de entrada e saida dos registradores r0...r7
		reg_in[7:0] = 0;
		reg_out[7:0] = 0;
		
		//fios controle - mux
		din_out = 0;
		g_out = 0;
		h_out = 0;
		i_out = 0;
		j_out = 0;
		k_out = 0;
		
		done = 0;
		write_16b = 0;
		
		case (step_out)
			//carrega a proxima instrucao  t0
			3'b000: begin
				addr_in = 1'b1;
				incr_pc = 1'b1;
				reg_out = 8'b10000000;
			end		
			//armazena a proxima instrucao t1
			3'b001: begin
				ir_in = 1'b1;
				addr_in = 1'b1;
			end		
			//define sinais de t2
			3'b010: begin
				case (instruction)
					//mv
					4'b0000: begin
						reg_in = reg_x;
						reg_out = reg_y;
						done = 1'b1;
					end
					//mvi
					4'b0001: begin
						reg_in = reg_x;
						mvi_indice = 1'b1;
						din_out = 1'b1;
						done = 1'b1;
					end
					//add 
					4'b0010: begin
						a_in = 1'b1;
						reg_out = reg_x;
					end
					//sub
					4'b0011: begin
						a_in = 1'b1;
						reg_out = reg_x;
					end
					//load
					4'b0100: begin
						addr_in = 1'b1;
						reg_out = reg_y;
					end
					//store
					4'b0101: begin
						dout_in = 1'b1;
						reg_out = reg_x;
					end
					//mvnz
					4'b0110: begin
						if (g!=0) begin
							reg_in = reg_x;
							reg_out = reg_y;
						end
						done = 1'b1;
					end
					//or
					4'b0111: begin
						b_in = 1'b1;
						reg_out = reg_x;
					end
					//slt
					4'b1000: begin
						c_in = 1'b1;
						reg_out = reg_x;
					end
					//sll
					4'b1001: begin
						d_in = 1'b1;
						reg_out = reg_x;
					end
					//srl
					4'b1010: begin
						e_in = 1'b1;
						reg_out = reg_x;
					end
				endcase
			end
			
			//define sinais de t3
			3'b011: begin
				case(instruction)
					//add
					4'b0010: begin
						//a_in = 1;
						g_in = 1'b1;
						reg_out = reg_y;
					end
					//sub
					4'b0011: begin
						//a_in = 1;
						g_in = 1'b1;
						add_sub = 1'b1;
						reg_out = reg_y;
					end
					//load
					4'b0100: begin
						reg_in = reg_x;
						din_out = 1'b1;
						write_16b = 1'b1;
						done = 1'b1;
					end 
					//store
					4'b0101: begin
						addr_in = 1'b1;
						w_d = 1'b1;
						reg_out = reg_y;
						done=1;
					end
					//or
					4'b0111: begin
						h_in = 1'b1;
						or_in = 1'b1;
						reg_out = reg_y;
					end
					//slt
					4'b1000: begin
						i_in = 1'b1;
						slt_in = 1'b1;
						reg_out = reg_y;
					end
					//sll
					4'b1001: begin
						j_in = 1'b1;
						sll_in = 1'b1;
						reg_out = reg_y;
					end              
					//srl            
					4'b1010: begin   
						k_in = 1'b1; 
						srl_in = 1'b1;
						reg_out = reg_y;
					end
				endcase
			end
			//define sinais de t4
			3'b100: begin
				case (instruction)
					//add
					4'b0010: begin
						reg_in = reg_x;
						g_out = 1'b1;
						done = 1'b1;
					end
					//sub
					4'b0011: begin
						reg_in = reg_x;
						g_out = 1'b1;
						done = 1'b1;
					end
					//or
					4'b0111: begin
						reg_in = reg_x;
						h_out = 1'b1;
						done = 1'b1;
					end
					//slt
					4'b1000: begin
						reg_in = reg_x;
						i_out = 1'b1;
						done = 1'b1;
					end
					//sll
					4'b1001: begin
						reg_in = reg_x;
						j_out = 1'b1;
						done = 1'b1;
					end
					//srl
					4'b1010: begin
						reg_in = reg_x;
						k_out = 1'b1;
						//k_in = 1;
						done = 1'b1;
					end
				endcase
			end
		endcase
	end	
	
	register reg_ir(clock, addr_logical[9:0] /*din[9:0]*/, ir_in, ir);
	defparam reg_ir.n = 10;
	
	lpmcounter reg7(1'b1, clock, incr_pc, bus_wires, ~resetn, reg_in[7], r7);
	register1 reg0(clock, bus_wires, addr_logical, reg_in[0], write_16b, mvi_indice, r0);
	register1 reg1(clock, bus_wires, addr_logical, reg_in[1], write_16b, mvi_indice, r1);
	register1 reg2(clock, bus_wires, addr_logical, reg_in[2], write_16b, mvi_indice, r2);
	register1 reg3(clock, bus_wires, addr_logical, reg_in[3], write_16b, mvi_indice, r3);
	register1 reg4(clock, bus_wires, addr_logical, reg_in[4], write_16b, mvi_indice, r4);
	register1 reg5(clock, bus_wires, addr_logical, reg_in[5], write_16b, mvi_indice, r5);
	register1 reg6(clock, bus_wires, addr_logical, reg_in[6], write_16b, mvi_indice, r6);
	//register reg7(clock, bus_wires, reg_in[7], r7);
	
	//addsub
	addsub unity_add_sub (~add_sub, a, bus_wires, addsub_out);
	register reg_a(clock, bus_wires, a_in, a);
	register reg_g(clock, addsub_out, g_in, g);
	
	//or
	or_unity or1(or_in, b, bus_wires, or_out);
	register reg_b(clock, bus_wires, b_in, b);
	register reg_h(clock, or_out, h_in, h);
	
	//load - store
	register reg_addr(clock, bus_wires, addr_in, addr);
	register reg_dout(clock, bus_wires, dout_in, dout);
	register reg_w(clock, w_d, 1'b1, w);
	defparam reg_w.n = 1;
	
	//slt
	slt_unity slt(slt_in, c, bus_wires, slt_out);
	register reg_c(clock, bus_wires, c_in, c);
	register reg_i(clock, slt_out, i_in, i);
	
	//sll
	sll_unity sll(sll_in, d, bus_wires, sll_out);
	register reg_d(clock, bus_wires, d_in, d);
	register reg_j(clock, sll_out, j_in, j);
	
	//srl
	srl_unity srl(srl_in, e, bus_wires, srl_out);
	register reg_e(clock, bus_wires, e_in, e);
	register reg_k(clock, srl_out, k_in, k);
	
	//definindo o fio interno bus
	always @(mux or g_out or reg_out or din_out or h_out or i_out or j_out or k_out) begin
		mux[0] = din_out;
		mux[1] = g_out;
		mux[9:2] = reg_out;
		mux[10] = h_out; 
		mux[11] = i_out;
		mux[12] = j_out;
		mux[13] = k_out;
		
		case(mux)
			14'b00000000000001: bus_wires = addr_logical;
			14'b00000000000010: bus_wires = g;
			14'b00000000000100: bus_wires = r0;
			14'b00000000001000: bus_wires = r1;
			14'b00000000010000: bus_wires = r2;
			14'b00000000100000: bus_wires = r3;
			14'b00000001000000: bus_wires = r4;
			14'b00000010000000: bus_wires = r5;
			14'b00000100000000: bus_wires = r6;
			14'b00001000000000: bus_wires = r7;
			14'b00010000000000: bus_wires = h;
			14'b00100000000000: bus_wires = i;
			14'b01000000000000: bus_wires = j;
			14'b10000000000000: bus_wires = k;
		endcase
	end
endmodule
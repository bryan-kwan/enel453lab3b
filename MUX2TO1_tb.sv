
`timescale 1ns/1ps

module MUX2TO1_tb();
	logic clk=0;
	logic s;
	logic [15:0] in1, in2, mux_out;
	parameter CLOCK_PERIOD = 20;
	// Instantiate UUTs
	MUX2TO1 DUT(.in1(in1),.in2(in2),.s(s),.mux_out(mux_out));
	  
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period 20 ns 
	initial begin 
		$display("---  Testbench started  ---");
		
		s = 1'b0; 
		in1=16'b1010_0101_1010_0101; in2=16'b1111_1111_1111_1111;  #(2*CLOCK_PERIOD);
		assert (mux_out===in1) else $error("s=0 failed");
		in1=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in1) else $error("s=0 failed");
		
		s = 1'b1; 
		in1=16'b1111_1111_1111_1111; in2=16'b1010_0101_1010_0101;  #(2*CLOCK_PERIOD);
		assert (mux_out===in2) else $error("s=1 failed");
		in2=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in2) else $error("s=1 failed");
		
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
 endmodule
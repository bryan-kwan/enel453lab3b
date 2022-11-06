
`timescale 1ns/1ps

module MUX4TO1_tb();
	logic clk=0;
	logic [1:0] s;
	logic [15:0] in1, in2, in3, in4, mux_out;
	parameter CLOCK_PERIOD = 20;
	// Instantiate UUTs
	MUX4TO1 DUT(.in1(in1),.in2(in2),.in3(in3),.in4(in4),.s(s),.mux_out(mux_out));
	  
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period 20 ns 
	initial begin 
		$display("---  Testbench started  ---");
		
		s = 2'b00; 
		in1=16'b1010_0101_1010_0101; in2=16'b1111_1111_1111_1111; 
		in3=16'b1111_1111_1111_1111; in4=16'b1111_1111_1111_1111; #(2*CLOCK_PERIOD);
		assert (mux_out===in1) else $error("s=00 failed");
				 in1=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in1) else $error("s=00 failed");
		
		s = 2'b01; 
		in1=16'b1111_1111_1111_1111; in2=16'b1010_0101_1010_0101; 
		in3=16'b1111_1111_1111_1111; in4=16'b1111_1111_1111_1111; #(2*CLOCK_PERIOD);
		assert (mux_out===in2) else $error("s=01 failed");
				 in2=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in2) else $error("s=01 failed");
		
		s = 2'b10; 
		in1=16'b1111_1111_1111_1111; in2=16'b1111_1111_1111_1111; 
		in3=16'b1010_0101_1010_0101; in4=16'b1111_1111_1111_1111; #(2*CLOCK_PERIOD);
		assert (mux_out===in3) else $error("s=10 failed");
				 in3=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in3) else $error("s=10 failed");
		
		s = 2'b11; 
		in1=16'b1111_1111_1111_1111; in2=16'b1111_1111_1111_1111; 
		in3=16'b1111_1111_1111_1111; in4=16'b1010_0101_1010_0101; #(2*CLOCK_PERIOD);
		assert (mux_out===in4) else $error("s=11 failed");
				 in4=16'b0101_1010_0101_1010; #(2*CLOCK_PERIOD);
		assert (mux_out===in4) else $error("s=11 failed");
		
		
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
 endmodule
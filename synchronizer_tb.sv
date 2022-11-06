

`timescale 1ns/1ps

module synchronizer_tb();
	logic clk=0;
	logic [9:0] SW, SW_out;
	parameter CLOCK_PERIOD = 20;
	parameter delay = 6 * CLOCK_PERIOD;
	
	// Instantiate UUTs
	synchronizer UUT(.clk(clk), .SW(SW), .SW_out(SW_out));
	
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period 20 ns 
	initial begin 
		$display("---  Testbench started  ---");
		#(10*delay);
		//Apply stimulus
		#(CLOCK_PERIOD/5); // Change input SW between clock edges
		SW = 10'b00_1010_0101; #(delay);
		SW = 10'b00_0101_1010; #(delay);
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
 endmodule


`timescale 1ns/1ps

module register_tb();
	logic clk=0;
	logic [11:0] data, q;
	logic write_enable, reset_n;
	parameter CLOCK_PERIOD = 20;
	parameter delay = 2 * CLOCK_PERIOD;
	// Instantiate UUTs
	register #(.width(12)) UUT(.data(data),.clk(clk),
	.write_enable(write_enable),.reset_n(reset_n),.q(q));
	
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period 20 ns 
	initial begin 
		$display("---  Testbench started  ---");
		#(100*delay);
		//Reset test
		reset_n = 1; #(delay);
		reset_n = 0; #(delay);
		assert(q===12'b0000_0000_0000) else $error("reset_n=0 failed");
		reset_n = 1; #(delay);
		
		//Writing data test
		write_enable=0; // Write enable off
		data = 12'b0101_1010_0101; //5A5 in hexadecimal
		q = 12'b0000_0000_0000; #(delay);
		assert(q!==data) else $error("write_enable_n=0 failed");
		
		write_enable=1; #(delay); // Write enable on
		assert(q===data) else $error("write_enable_n=1 failed");
		
		
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
 endmodule
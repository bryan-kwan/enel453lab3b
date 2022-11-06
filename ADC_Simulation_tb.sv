`timescale 1ns/1ps

// Dummy testbench for viewing what ADC_Simulation does

module ADC_Simulation_tb();

logic clk=0, response_valid_out;
logic [11:0] ADC_out;

parameter CLOCK_PERIOD = 20;

ADC_Simulation UUT(.MAX10_CLK1_50(clk),.*);

always #(CLOCK_PERIOD/2) clk=~clk;

initial begin 
		$display("---  Testbench started  ---");
        #(50000000*CLOCK_PERIOD);
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
endmodule
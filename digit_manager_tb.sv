
`timescale 1ns/1ps
module digit_manager_tb();
    logic clk=0;
	logic [15:0] data; // Binary coded decimal input
    logic [1:0] select;
	logic [5:0] DP, Blank, DP_expected, Blank_expected;
	parameter CLOCK_PERIOD = 20;
    parameter DEFAULT_DELAY = 2*CLOCK_PERIOD;
    parameter n_DP_2 = 0;
    parameter n_DP_3 = 2;
    parameter n_DP_4 = 3;

	// Instantiate UUTs
	digit_manager #(.n_DP_2(n_DP_2),.n_DP_3(n_DP_3),.n_DP_4(n_DP_4)) 
                  UUT(.data(data), .select(select), .DP(DP), .Blank(Blank));
	
	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period CLOCK_PERIOD
	initial begin 
		$display("---  Testbench started  ---");
		#(10.25*CLOCK_PERIOD); // Offset stimulus for ease of reading
        data='0;
        select=2'b00;
        // DP test
        $display("Starting decimal point (DP) test.");

        select=2'b00; // Mode 1 Hex
        DP_expected=6'b00_0000; #(DEFAULT_DELAY);
        assert(DP===DP_expected) else $error("Expected DP = %b (received %b).",DP_expected, DP);

        select=2'b01; // Mode 2 ADC avg
        DP_expected=6'b00_0000; #(DEFAULT_DELAY);
        assert(DP===DP_expected) else $error("Expected DP = %b (received %b).",DP_expected, DP);

        select=2'b10; // Mode 3 Distance
        DP_expected=6'b00_0000;
        DP_expected[n_DP_3] = 1; #(DEFAULT_DELAY);
        assert(DP===DP_expected) else $error("Expected DP = %b (received %b).",DP_expected, DP);

        select=2'b11; // Mode 4 Voltage
        DP_expected=6'b00_0000;
        DP_expected[n_DP_4] = 1; #(DEFAULT_DELAY);
        assert(DP===DP_expected) else $error("Expected DP = %b (received %b).",DP_expected, DP);
		
        // Blank test
        $display("Starting Blank test.");


        select=2'b00; // Mode 1 Hex
        Blank_expected = 6'b11_0000;
        data='0; #(DEFAULT_DELAY);
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0001_0101_0001_0101; #(DEFAULT_DELAY); // 1515
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0000_0001_0000_0001; #(DEFAULT_DELAY); // 0101
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);


        select=2'b01; // Mode 2 ADC avg
        data='0; // 0000 
        Blank_expected = 6'b11_1110; #(DEFAULT_DELAY); 
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data='h5A;
        Blank_expected = 6'b11_1100; #(DEFAULT_DELAY);
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data='h5A5A;
        Blank_expected = 6'b11_0000; #(DEFAULT_DELAY); 
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);


        select=2'b10; // Mode 3 Distance
        data='0; // 0.00 displayed so first three displays blanked
        Blank_expected = 6'b11_1000; #(DEFAULT_DELAY); 
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0000_0001_0110_0101; // 1.65 displayed so first three displays blanked
        Blank_expected = 6'b11_1000; #(DEFAULT_DELAY); 
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0001_0101_0001_0101; // 15.15 displayed so first two displays blanked
        Blank_expected = 6'b11_0000; #(DEFAULT_DELAY); 
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);

        select=2'b11; // Mode 4 Voltage
        Blank_expected = 6'b11_0000; // Only first two displays blanked no matter what data is
        data='0; #(DEFAULT_DELAY);
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0001_0101_0001_0101; #(DEFAULT_DELAY); // 1.515
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);
        data=16'b0101_0001_0101_0001; #(DEFAULT_DELAY); // 5.151
        assert(Blank==Blank_expected) else $error("Expected Blank = %b (received %b).",Blank_expected, Blank);

    

		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end



endmodule
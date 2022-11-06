`timescale 1ns/1ps
module averager_tb();
	logic clk=0;
	logic EN, reset_n;
    parameter INWIDTH=16,LOGSIZE=8, OUTWIDTH=16, SAMPLESIZE=2**LOGSIZE, SUMSIZE=SAMPLESIZE+INWIDTH;
    logic [INWIDTH-1:0] Din;
    logic [OUTWIDTH-1:0] Q;

	parameter CLOCK_PERIOD = 20;
	parameter delay = 2*CLOCK_PERIOD;
    parameter pipeline_delay = 3*CLOCK_PERIOD;
	parameter debouncer_stable_time = 5000000*CLOCK_PERIOD;

    int average_value;

	// Instantiate UUTs
	averager UUT(.clk(clk),.EN(EN),.reset_n(reset_n),.Din(Din),.Q(Q));

	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period CLOCK_PERIOD ns 
	
	
	initial begin 
		$display("---  Testbench started  ---");
		Din=0;
		#(1000.25*CLOCK_PERIOD); // Long initialization delay; offset the stimulus by 0.25 Period
		
        // Reset test
        reset_n=1; #(delay);
        reset_n=0; #(delay);
        assert(Q===0) else $error("Reset failed expected Q=%b (received %b).", 0, Q);
        reset_n=1; #(delay);
        $display("-End of reset test-");
		
        // Average value test
        EN=1;
        Din={(INWIDTH){1'b1}}; #(CLOCK_PERIOD); // Din = all 1's for 1 clock cycle
        Din={(INWIDTH){1'b0}}; #(pipeline_delay-CLOCK_PERIOD); // Din = all 0's for rest of pipeline_delay
        // Total of pipeline_delay clock cycles so average value for initial stimulus appears now
        assert(Q==={(INWIDTH){1'b1}}/SAMPLESIZE) else $error("Expected average value Q=%b (received %b). Input samples: %d",{(INWIDTH){1'b1}}/SAMPLESIZE,Q,2**INWIDTH-1);
		
        Din=1;
        #(SAMPLESIZE*CLOCK_PERIOD); // Flush pipeline with full samples of all 1's
        #(pipeline_delay); assert(Q==1) else $error("Expected average value Q=%b (received %b). Input samples: %d 1's",1,Q, SAMPLESIZE);

        
        Din=0; #(SAMPLESIZE*CLOCK_PERIOD); // Flush pipeline with 0's
        Din=30; #(CLOCK_PERIOD);
        Din=40; #(CLOCK_PERIOD);
        Din=0; #(pipeline_delay); // Q result appears now
        assert(Q==(30+40)/SAMPLESIZE) else $error("Expected average value Q=%b (received %b). Input samples: 30, 40",(30+40)/SAMPLESIZE,Q);
        
        $display("-End of average value test-");
        // EN test
        Din=8; #(SAMPLESIZE*CLOCK_PERIOD); // Flush pipeline with full samples of all 8's
        #(pipeline_delay); // Q result stabilized
        average_value = Q;
        EN=0;
        Din=0; #(10*CLOCK_PERIOD);
        assert(Q===average_value) else $error("EN=0 failed, expected average value Q=%b (received %b). Input samples: %d 8's", 8, Q, SAMPLESIZE);

        $display("-End of enable test-");
        
		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
endmodule
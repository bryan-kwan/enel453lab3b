
`timescale 1ns/1ps
module top_level_tb();
	logic clk=0;
	logic reset_n, button;
	logic [9:0] SW, LEDR;
	logic [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	int digit0, digit1, digit2, digit3;
	logic write_enable;
	logic [12:0] voltage, distance, avg_out;
	logic [15:0] reg_out;
	logic [5:0] DP, Blank;

	logic [7:0] switch_value;

	logic buzzer;
	logic pwm_out_LEDR, pwm_out_flash, pwm_out_buzzer;

	parameter WIDTH=13,MAX_COUNT=3000, // LEDR parameters
	// Display flashing / buzzer parameters
	BASE_PERIOD_flash = 2000, // Number of clock cycles for period of pwm_out by defeault (with enable=1)
	DUTY_CYCLE_flash = 1000, // duty cycle = BASE_PERIOD / DUTY_CYCLE, 50% by default
	MAX_FLASH_DISTANCE = 2000, // Distance (in 10^-2 cm) at which flashing starts
	MIN_FLASH_DISTANCE = 0, 
	CLOCK_DIVIDE_LOW_FREQ_flash = 25000, // Period = (1/50MHz) * BASE_PERIOD * CLOCK_DIVIDE
	CLOCK_DIVIDE_HIGH_FREQ_flash = 5000,
	BASE_PERIOD_buzzer = 100, 
	DUTY_CYCLE_buzzer = 50, 
	CLOCK_DIVIDE_LOW_FREQ_buzzer = 2040,
	CLOCK_DIVIDE_HIGH_FREQ_buzzer = 40,
	DISTANCE2CLOCK_DIVIDE_SCALING_flash = (CLOCK_DIVIDE_LOW_FREQ_flash-CLOCK_DIVIDE_HIGH_FREQ_flash)
                                            / (MAX_FLASH_DISTANCE-MIN_FLASH_DISTANCE),
	DISTANCE2CLOCK_DIVIDE_SCALING_buzzer = (CLOCK_DIVIDE_LOW_FREQ_buzzer-CLOCK_DIVIDE_HIGH_FREQ_buzzer)
                                            / (MAX_FLASH_DISTANCE-MIN_FLASH_DISTANCE);
	int n_cycles;

	parameter CLOCK_PERIOD = 20;
	parameter delay = 6*CLOCK_PERIOD;
	parameter bcd_delay = 250*CLOCK_PERIOD;
	parameter debouncer_stable_time = 5000000*CLOCK_PERIOD;


	static int use_force_button_tests = 1; // 1 = use force to change write_enable, 0 = use button
	static int distance_temp; // used as an intermediate variable for force statement
	// Instantiate UUTs
	//(input  logic       clk,
	//  input  logic       reset_n,
	//  input  logic [9:0] SW,
	//  output logic [9:0] LEDR,
	//  output logic [7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

	top_level UUT(.clk(clk),.reset_n(reset_n), 
	.SW(SW),.LEDR(LEDR), .button(button),
	.HEX0(HEX0),.HEX1(HEX1),
	.HEX2(HEX2),.HEX3(HEX3),
	.HEX4(HEX4),.HEX5(HEX5), 
	.buzzer(buzzer));

	// Apply stimulus
	always #(CLOCK_PERIOD/2) clk = ~clk; // run clock forever with period CLOCK_PERIOD ns 
	
	assign write_enable = UUT.register_ins.write_enable; // Probes for viewing signals
	assign voltage = UUT.MUX_binary_output_ins.in2;
	assign distance = UUT.distance;
	assign avg_out = UUT.MUX_hexadecimal_output_ins.in2;
	assign reg_out = UUT.reg_out;
	assign DP=UUT.DP_in;
	assign Blank=UUT.Blank;
	assign pwm_out_LEDR = ~UUT.pwm_led; // Outputs are the inversion of the signals we want to check
	assign pwm_out_flash = ~UUT.pwm_flash;
	assign pwm_out_buzzer = ~UUT.pwm_buzzer;
	
	initial begin 
		$display("---  Testbench started  ---");
		
		//#(0.25*CLOCK_PERIOD); // Offset the stimulus by 0.25 Period

		if(!use_force_button_tests) begin
			button=0; #(delay);
			button=1; #(debouncer_stable_time); // Enable on
		end else force UUT.write_enable=1;

		// Reset test ==================
		$display("Testing reset, time=%t ps",$time);
		SW[9:8]=2'b00; // Set to decimal mode
		reset_n = 1; #(delay);
		reset_n = 0;#(delay); // Reset is active low
		assert(UUT.reg_out==0) else $error("Expected reg_out=0 received %b", UUT.reg_out);
		reset_n = 1; #(delay);
		
		SW[9:8]=2'b01; // Set to voltage mode
		reset_n = 1; #(delay);
		reset_n = 0; #(delay); // Reset is active low
		assert(UUT.reg_out==0) else $error("Expected reg_out=0 received %b", UUT.reg_out);
		reset_n = 1; #(delay);
		
		SW[9:8]=2'b10; // Set to distance value mode
		reset_n = 1; #(delay);
		reset_n = 0; #(delay); // Reset is active low
		assert(UUT.reg_out==0) else $error("Expected reg_out=0 received %b", UUT.reg_out);
		reset_n = 1; #(delay);
		
		SW[9:8]=2'b11; // Set to average mode
		reset_n = 1; #(delay);
		reset_n = 0; #(delay); // Reset is active low
		assert(UUT.reg_out==0) else $error("Expected reg_out=0 received %b", UUT.reg_out);
		reset_n = 1; #(delay);
		$display("Finished testing reset, time=%t ps",$time);

		// PWM Signal tests
		SW[9:8]=2'b10; // Distance mode for convenience (pwm signals are on in all modes)
		distance_temp=1;
		force UUT.ADC_Data_ins.distance=distance_temp;
		// LEDR duty cycle test ==================
		$display("Testing LEDR duty cycle, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        reset_n = 1;
        // Distance greater than max distance MAX_COUNT: pwm_out_LEDR should always be 1
        // Distance less than max distance MAX_COUNT: pwm_out_LEDR=1 for distance clock cycles and 0 for rest
        for(int i = 0; i<2**(WIDTH-1)-1; i+=500) begin
			distance_temp = i;
            for(int j = 1; j<MAX_COUNT; j++) begin // Check every clock cycle until counter resets to 0
                #(CLOCK_PERIOD);
                if(distance>=MAX_COUNT)
                    assert(pwm_out_LEDR===1'b1) else $error("Expected pwm_out_LEDR=1 received pwm_out_LEDR=%b (Applied distance=%d, count=%d)",pwm_out_LEDR,distance,j);
                else if(j<distance)
                    assert(pwm_out_LEDR===1'b1) else $error("Expected pwm_out_LEDR=1 received pwm_out_LEDR=%b (Applied distance=%d, count=%d)",pwm_out_LEDR,distance,j);
                else
                    assert(pwm_out_LEDR===1'b0) else $error("Expected pwm_out_LEDR=0 received pwm_out_LEDR=%b (Applied distance=%d, count=%d)",pwm_out_LEDR,distance,j);
            end
            // Reset
            reset_n = 1; #(CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
            reset_n = 1;
        end
        $display("Finished testing LEDR duty cycle, time=%t ps",$time);
		// Flash period test ==================
		$display("Testing flash period, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        // Period = BASE_PERIOD * (1/50MHz) * (distance * DISTANCE2CLOCK_DIVIDE_SCALING)
        for(int i = 0; i<1.1*MAX_FLASH_DISTANCE; i+=1000) begin
            $display("Applying distance = %d", i);
			distance_temp = i; #(CLOCK_PERIOD);
            reset_n = 1;
            if(distance>MIN_FLASH_DISTANCE & distance<MAX_FLASH_DISTANCE) 
                n_cycles = BASE_PERIOD_flash * (distance * DISTANCE2CLOCK_DIVIDE_SCALING_flash);
            else
                n_cycles = BASE_PERIOD_flash;
            //pwm_out is 1 for 50%, then 0 for 50%
            assert(pwm_out_flash===1'b1) else $error("Expected pwm_out_flash=1 received pwm_out_flash=%b (Applied distance=%d)",pwm_out_flash,distance);
            #((n_cycles-1)*CLOCK_PERIOD);
            assert(pwm_out_flash===1'b0) else $error("Expected pwm_out_flash=0 received pwm_out_flash=%b (Applied distance=%d)",pwm_out_flash,distance);
            #(3*CLOCK_PERIOD);
            assert(pwm_out_flash===1'b1) else $error("Expected pwm_out_flash=1 received pwm_out_flash=%b (Applied distance=%d)",pwm_out_flash,distance);
            
            // Reset
            reset_n = 1; #(CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
        end
        $display("Finished testing flash period, time=%t ps",$time);
		// Buzzer period test ==================
		$display("Testing buzzer period, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        // Period = BASE_PERIOD * (1/50MHz) * (distance * DISTANCE2CLOCK_DIVIDE_SCALING)
        for(int i = 0; i<1.1*MAX_FLASH_DISTANCE; i+=500) begin
            $display("Applying distance = %d", i);
			distance_temp = i; #(CLOCK_PERIOD);
            reset_n = 1;
            if(distance>MIN_FLASH_DISTANCE & distance<MAX_FLASH_DISTANCE) 
                n_cycles = BASE_PERIOD_buzzer * (distance * DISTANCE2CLOCK_DIVIDE_SCALING_buzzer);
            else
                n_cycles = BASE_PERIOD_buzzer;
            //pwm_out is 1 for 50%, then 0 for 50%
            assert(pwm_out_buzzer===1'b1) else $error("Expected pwm_out_buzzer=1 received pwm_out_buzzer=%b (Applied distance=%d)",pwm_out_buzzer,distance);
            #((n_cycles-1)*CLOCK_PERIOD);
            assert(pwm_out_buzzer===1'b0) else $error("Expected pwm_out_buzzer=0 received pwm_out_buzzer=%b (Applied distance=%d)",pwm_out_buzzer,distance);
            #(3*CLOCK_PERIOD);
            assert(pwm_out_buzzer===1'b1) else $error("Expected pwm_out_buzzer=1 received pwm_out_buzzer=%b (Applied distance=%d)",pwm_out_buzzer,distance);
            
            // Reset
            reset_n = 1; #(CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
        end
        $display("Finished testing buzzer period, time=%t ps",$time);

		release UUT.ADC_Data_ins.distance;

		// Freeze button test ==================
		$display("Start of freeze button test (time=%t ps)", $time);
		reset_n = 1; #(CLOCK_PERIOD);
		SW[9:8]=2'b00; #(delay);
		SW[7:0]='1;
		switch_value=SW[7:0]; #(delay);
		if(!use_force_button_tests) begin
			button=0; #(debouncer_stable_time); // Enable off
		end
		else release UUT.write_enable;

		SW[7:0]='0; #(delay);
		assert(reg_out===switch_value) else $error("Freeze button failed: Expected reg_out=%b (received %b)",switch_value,reg_out);
		$display("End of freeze button test (time=%t ps)", $time);

		$display("\n===  Testbench ended  ===");
		$stop; // this stops simulation, needed because clk runs forever
	end
	
endmodule
`timescale 1ns/1ps
module distance2frequency_converter_tb();
    parameter WIDTH = 13,
                    BASE_PERIOD = 2000, // Number of clock cycles for period of pwm_out by defeault (with enable=1)
                    DUTY_CYCLE = 1000, // duty cycle = BASE_PERIOD / DUTY_CYCLE, 50% by default
                    MAX_FLASH_DISTANCE = 2000, // Distance (in 10^-2 cm) at which flashing starts
                    MIN_FLASH_DISTANCE = 0, 
                    CLOCK_DIVIDE_LOW_FREQ = 25000, // Period = (1/50MHz) * BASE_PERIOD * CLOCK_DIVIDE
                    CLOCK_DIVIDE_HIGH_FREQ = 5000,
                    DISTANCE2CLOCK_DIVIDE_SCALING = (CLOCK_DIVIDE_LOW_FREQ-CLOCK_DIVIDE_HIGH_FREQ)
                                            / (MAX_FLASH_DISTANCE-MIN_FLASH_DISTANCE),
                    PERIOD_WIDTH=16; // Bit width of the maximum clock division desired
    parameter CLOCK_PERIOD = 20;
    
    logic clk = 1, reset_n = 1, enable=1;
    logic [WIDTH-1:0] distance;
    logic pwm_led, pwm_out; // Output signal that controls LEDR (active high); pwm_out=~pwm_led
    logic pwm_enable, zero;
    logic [PERIOD_WIDTH-1:0] count;

    int n_cycles;
    // UUT
    distance2frequency_converter UUT(.distance(distance),.reset_n(reset_n),.clk(clk),.enable(enable),.pwm_led(pwm_led));

    assign pwm_out = UUT.pwm_out; // Inversion of pwm_led
    assign pwm_enable = UUT.pwm_enable;
    assign zero = UUT.zero;
    assign count = UUT.downcounter_ins.current_count;

    always #(CLOCK_PERIOD/2) clk=~clk;
    // Stimulus
    initial begin
        $display("Start of testbench");
        $display("Testing pwm_out period, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        // Period = BASE_PERIOD * (1/50MHz) * (distance * DISTANCE2CLOCK_DIVIDE_SCALING)
        for(int i = 0; i<1.1*MAX_FLASH_DISTANCE; i+=500) begin
            $display("Applying distance = %d", i);
            distance = i; #(CLOCK_PERIOD);
            reset_n = 1;
            if(distance>MIN_FLASH_DISTANCE & distance<MAX_FLASH_DISTANCE) 
                n_cycles = BASE_PERIOD * (distance * DISTANCE2CLOCK_DIVIDE_SCALING);
            else
                n_cycles = BASE_PERIOD;
            //pwm_out is 1 for 50%, then 0 for 50%
            assert(pwm_out===1'b1) else $error("Expected pwm_out=1 received pwm_out=%b (Applied distance=%d)",pwm_out,distance);
            #((n_cycles-1)*CLOCK_PERIOD);
            assert(pwm_out===1'b0) else $error("Expected pwm_out=0 received pwm_out=%b (Applied distance=%d)",pwm_out,distance);
            #(3*CLOCK_PERIOD);
            assert(pwm_out===1'b1) else $error("Expected pwm_out=1 received pwm_out=%b (Applied distance=%d)",pwm_out,distance);
            
            // Reset
            reset_n = 1; #(CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
        end
        #(n_cycles*CLOCK_PERIOD);
        $display("Finished testing pwm_out period, time=%t ps",$time);
        $display("End of testbench");
        $stop;
    end
    
endmodule
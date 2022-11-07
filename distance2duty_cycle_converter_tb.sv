`timescale 1ns/1ps
module distance2duty_cycle_converter_tb();
    parameter WIDTH = 13,
            MAX_COUNT = 3000, // Max distance (in 10^-2 cm) before duty cycle is 100%
            CLOCK_PERIOD = 20;

    logic clk = 0, reset_n = 1, enable=1;
    logic [WIDTH-1:0] distance;
    logic pwm_led, pwm_out; // Output signal that controls LEDR (active high); pwm_out=~pwm_led

    // UUT
    distance2duty_cycle_converter #(.WIDTH(WIDTH)) 
        UUT(.distance(distance),.reset_n(reset_n),.clk(clk),.enable(enable),.pwm_led(pwm_led));

    assign pwm_out = UUT.pwm_out; // Inversion of pwm_led

    always #(CLOCK_PERIOD/2) clk=~clk;
    // Stimulus
    initial begin
        $display("Start of testbench");
        $display("Testing pwm_out duty cycle, time=%t ps",$time);
        // Reset
        reset_n = 1; #(CLOCK_PERIOD);
        reset_n = 0; #(CLOCK_PERIOD);
        reset_n = 1;
        // Distance greater than max distance MAX_COUNT: pwm_out should always be 1
        // Distance less than max distance MAX_COUNT: pwm_out=1 for distance clock cycles and 0 for rest
        for(int i = 0; i<2**WIDTH-1; i+=100) begin
            distance = i;
            for(int j = 1; j<MAX_COUNT; j++) begin // Check every clock cycle until counter resets to 0
                #(CLOCK_PERIOD);
                if(distance>=MAX_COUNT)
                    assert(pwm_out===1'b1) else $error("Expected pwm_out=1 received pwm_out=%b (Applied distance=%d, count=%d)",pwm_out,distance,j);
                else if(j<distance)
                    assert(pwm_out===1'b1) else $error("Expected pwm_out=1 received pwm_out=%b (Applied distance=%d, count=%d)",pwm_out,distance,j);
                else
                    assert(pwm_out===1'b0) else $error("Expected pwm_out=0 received pwm_out=%b (Applied distance=%d, count=%d)",pwm_out,distance,j);
            end
            // Reset
            reset_n = 1; #(CLOCK_PERIOD);
            reset_n = 0; #(CLOCK_PERIOD);
            reset_n = 1;
        end
        $display("Finished testing pwm_out duty cycle, time=%t ps",$time);
        $display("End of testbench");
        $stop;
    end
    
endmodule
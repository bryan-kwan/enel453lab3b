module distance2duty_cycle_converter
        #(parameter WIDTH = 13,
                    MAX_COUNT = 3000 // Max distance (in 10^-2 cm) before duty cycle is 100%
                                     // ie. the distance "measured off scale"
        )
        (input logic [WIDTH-1:0] distance,
        input logic reset_n,
                    clk,
                    enable, // Use downcounter to divide the clk frequency to target output frequency
                            // Fix enable to 1 for no frequency change
        output logic pwm_led
        );

    logic pwm_out;
    assign pwm_led = ~pwm_out; // Invert LED signal to have low duty cycle for large distance

    PWM_DAC #(.width(WIDTH)) PWM_DAC_ins(
        .reset_n(reset_n),
        .clk(clk),
        .enable(enable),
        .duty_cycle(distance), // Large distance = large duty cycle
        .count_value(MAX_COUNT),
        .pwm_out(pwm_out)
    );
endmodule
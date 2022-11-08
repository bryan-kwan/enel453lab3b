
module distance2frequency_converter
        #(parameter WIDTH = 13,
                    BASE_PERIOD = 2000, // Number of clock cycles for period of pwm_out by defeault (with enable=1)
                    DUTY_CYCLE = 1000, // duty cycle = BASE_PERIOD / DUTY_CYCLE, 50% by default
                    MAX_FLASH_DISTANCE = 2000, // Distance (in 10^-2 cm) at which flashing starts
                    MIN_FLASH_DISTANCE = 0, 
                    CLOCK_DIVIDE_LOW_FREQ = 25000, // Period = (1/50MHz) * BASE_PERIOD * CLOCK_DIVIDE
                    CLOCK_DIVIDE_HIGH_FREQ = 5000,
                    DISTANCE2CLOCK_DIVIDE_SCALING = (CLOCK_DIVIDE_LOW_FREQ-CLOCK_DIVIDE_HIGH_FREQ)
                                            / (MAX_FLASH_DISTANCE-MIN_FLASH_DISTANCE), // Integer division
                                            // so make sure this divides into an integer

                    PERIOD_WIDTH=16 // Bit width of the maximum clock division desired
        )
        (input logic [WIDTH-1:0] distance,
         input logic reset_n,
                     clk,
                     enable,
         output logic pwm_led
        );
    logic [WIDTH-1:0] duty_cycle, count_value;
    logic pwm_out, pwm_enable, zero;
    logic [PERIOD_WIDTH-1:0] period;

    PWM_DAC #(.width(WIDTH)) PWM_DAC_ins(
        .reset_n(reset_n),
        .clk(clk),
        .enable(pwm_enable),
        .duty_cycle(duty_cycle), 
        .count_value(count_value), 
        .pwm_out(pwm_out)
    );
    downcounter #(.WIDTH(PERIOD_WIDTH)) downcounter_ins(.clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .period(period), 
        .zero(zero) 
        );

    always_comb begin
        pwm_led = ~pwm_out; // Have to invert signal for LED
        duty_cycle = DUTY_CYCLE;
        count_value = BASE_PERIOD;
        if(distance>MIN_FLASH_DISTANCE & distance<MAX_FLASH_DISTANCE) begin
            pwm_enable=zero; // Divides frequency of pwm signal by period
            period = distance * DISTANCE2CLOCK_DIVIDE_SCALING;
        end
        else begin
            pwm_enable=enable; // No frequency division outisde of min/max range
            period = BASE_PERIOD;
        end
    end
endmodule
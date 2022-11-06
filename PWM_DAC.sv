//

module PWM_DAC
 #(int                      width = 9)
  (input  logic             reset_n,
                            clk,
                            enable,
   input  logic [width-1:0] duty_cycle, // Number of clock cycles pwm_out is 1
                            count_value, // Maximum count value before resetting to 0
   output logic             pwm_out); // Actual duty cycle is duty_cycle / count_value * 100%
                                      // unless duty_cycle > count_value in which case duty cycle is 100%
  int counter;//,duty_cycle_int,count_value_int;
  
  always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n)
      counter <= 0;     
    else if (enable)
      if (counter < count_value)
        counter++;
      else
        counter <= 0;
  end
  
  always_comb begin
    if (counter < duty_cycle)
      pwm_out = 1;
    else 
      pwm_out = 0;      
  end
  
endmodule

// The downcounter produces a one-clk cycle positive pulse on output zero,
// once every every period of the counter, defined by the parameter period. 
// The zero pulse gets produced when the downcounter count reaches zero,
// hence the output name of zero. The zero signal can be used to implement
// a clock divider. The zero output can be used to generate pulse to enable 
// another downcounter (i.e. cascaded) to further divide a clock. Note,
// large periods (e.g. 64k (2^16)) will be slower downcounters, so a cascade 
// of two 256 (2^8) downcounters will be faster. (Note 256*256 = 64k)
// See clock_divider to see how downcounter can be used.

module downcounter
 #(parameter WIDTH = 16) // Width of period
  (input  logic clk,      // Clock to be divided (by period)                                        
                reset_n,  // Active-low reset                                           
                enable,   // Active-high enable (count enable)   
   input logic [WIDTH-1:0] period, // Number to count to (i.e. clock divide), must be postive                                    
   output logic zero);    // Creates a positive pulse every time current_count hits zero count, 
                          // zero is useful to enable another device, like to slow down a counter
   // output logic [X:0] value); // Outputs the current_count value, if needed,
                                 // value for X must be at least: X = (ceil(log2(period)) - 1)

  int current_count;
  
  always_ff @(posedge clk, negedge reset_n) begin
    if (!reset_n) begin
      current_count <= 0; 
      zero          <= 0;
    end
    else if (enable) 
      if (current_count == 0) begin // 
        current_count <= period - 1; //
        zero          <= 1; // recall zero is high for one clk period, once per counting period
      end
      else begin
        current_count--; //  decrement because this is a down counter
        zero <= 0;
      end 
    else
      zero <= 0; 
  end  

  // assign value = current_count; // this line outputs the counter value, if necessary

endmodule

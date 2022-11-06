// Moving average of 256 samples on Din
// Converted from RB' and DT's VHDL design from ENEL 453 F2019
// Note, use Q_high_res if you need it. Uncomment in 3 places.

module averager256
 #(parameter int // Note, these are the generic default values. The actual values are in the instantiation.
     N    = 8,   // log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
     X    = 4,   // X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
     bits = 11)  // number of bits in the input data to be averaged
  (input  logic          clk,
                         EN,      // takes a new sample when high for each clock cycle
                         reset_n,
   input  logic [bits:0] Din,     // input sample for moving average calculation
   output logic [bits:0] Q);      // 12-bit moving average of 256 samples
   // output logic [X+bits:0] Q_high_res); ) // (4+11 downto 0) -- first add (i.e. X) must match X constant in ADC_Data        
                                           // moving average of ADC with additional bits of resolution:                           
                                           // 256 average can give an additional 4 bits of ADC resolution, depending on conditions
                                           // so you get 12-bits plus 4-bits = 16-bits (is this real?) 
  logic [2*bits:0] REG_ARRAY [2**N:1];                                             
  logic [2*bits:0] tmp [2**N:1]; 
  
  logic [2**N-1:0] tmplast;
  
  always_ff @(posedge clk, negedge reset_n) begin // shift_reg
    if(!reset_n) begin
      for(int i = 1; i < 2**N+1; i++) // LoopA1
        REG_ARRAY[i] <= 0;
      Q <= 0;
      //Q_high_res = 0;
    end
    else if(EN) begin
      REG_ARRAY[1] <= Din;
      for(int j = 1; j < 2**N; j++) // LoopA2
        REG_ARRAY[j+1] <= REG_ARRAY[j];
      Q <= tmplast[N+bits:N];
      //Q_high_res = tmplast[N+bits:N-X];
    end
  end
  
  genvar k;
  generate
    for(k = 1; k < (2**N)/2+1; k++) begin : LoopB1
      assign tmp[k] = REG_ARRAY[2*k-1] + REG_ARRAY[2*k];
    end
  endgenerate
  
  genvar m;
  generate
    for(m = (2**N)/2+1; m < (2**N); m++) begin : LoopB2
      assign tmp[m] = tmp[2*(m-(2**N)/2)-1] + tmp[2*(m-(2**N)/2)];
    end
  endgenerate
  
  assign tmplast    = tmp[(2**N)-1];
 
endmodule           
                                                           
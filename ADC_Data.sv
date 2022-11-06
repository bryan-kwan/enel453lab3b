// Use this module to interface the ADC on the FPGA (i.e. for Quartus)

module ADC_Data(
  input  logic        clk,
                      reset_n, // active-low
  output logic [12:0] voltage, // Voltage in milli-volts                                                 
                      distance,// distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
  output logic [11:0] ADC_raw, // the latest 12-bit ADC value                                            
                      ADC_out);// moving average of ADC value, over 256 samples,                      
                               // number of samples defined by the averager module                    
                               
  parameter integer X = 4; // 4; // X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bits of resolution gained)
  logic          response_valid_out;
  logic [11:0]   ADC_raw_temp,ADC_out_ave,temp;
  logic [12:0]   voltage_temp;
  // below signal is not used in the design but is a sample signal if a high resolution signal is required
  logic [X+11:0] Q_high_res; // (4+11 DOWNTO 0); -- first add (i.e. X) is log4(2**N), e.g. log4(2**8) = log4(256) = 4, must match X constant

//==========================================================================
//== Uncomment one of the two ADC modules below, depending on the purpose ==
//==========================================================================
 // Instantiate RTL ADC (i.e. for Quartus)
  ADC_Conversion ADC_ins(
    .MAX10_CLK1_50      (clk),
    .response_valid_out (response_valid_out),
    .ADC_out            (ADC_raw_temp)); 

  
  // Instantiate Simulation ADC (i.e. for ModelSim)
  // ADC_Simulation ADC_ins(
  //   .MAX10_CLK1_50      (clk),
  //   .response_valid_out (response_valid_out),
  //   .ADC_out            (ADC_raw_temp)); 

//==========================================================================
  
  voltage2distance_array2 voltage2distance_ins(
    .clk(clk),
    .voltage  (voltage_temp),
    .distance (distance));

  // Provided averager module   
  // averager256 #( // change parameters here to modify the number of samples to average
  //   .N(8),     // 8, 10, -- log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
  //   .X(4),     // 4, 5, -- X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
  //   .bits(11)) // 11 -- number of bits in the input data to be averaged
    
  // averager_ins( // below are the connections for the instantiation
  //   .clk     (clk),
  //   .reset_n (reset_n),
  //   .EN      (response_valid_out),
  //   .Din     (ADC_raw_temp),
  //   .Q       (ADC_out_ave));

  // Averager module created for lab 3
  averager #(.INWIDTH(16), 
             .LOGSIZE(8), // Log base 2 of the size of SAMPLESIZE
             .OUTWIDTH(16)) // Same as INWIDTH if accurate rounding is not required (truncation is ok))
  averager_ins(.clk(clk),.reset_n(reset_n),.EN(response_valid_out),.Din(ADC_raw_temp),.Q(ADC_out_ave));

  assign ADC_out = ADC_out_ave;
  assign ADC_raw = ADC_raw_temp;
  assign voltage = voltage_temp;

  assign voltage_temp = ADC_out_ave*2500*2/(2**12); //voltage_temp = ADC_out_ave*2500*2/(2**12);
/*************************
Above voltage_temp equation (voltage_temp = ADC_out_ave*2500*2/(2**12)):  
2**12 represents 2^12 = 4096, and this is scaling factor to normalize the ADC 12-bit 
value to 1 (technically 4095/4096 = 0.9997559). Dividing by 4096 is trivial for digital 
hardware, it's just a shift of the binary point. Dividing by 4095 is difficult, 
resulting a complex divider that reduces the Fmax to 21.1 MHz. The difference in 
accuracy between /4096 and /4095 is neglible for this application. If you are curious, 
talk to Denis Onen about how to efficiently compute /4095, he has expertise in these 
kinds of calculations.

2500*2 represents the scaling factor to convert the normalized 12-bit ADC value to the 
ratiometric voltage value, in milli-volts (mV). The ADC accepts a 2.5 V input signal 
(2500 mV) and converts it to a 12-bit ratiometric number. However, there is a 2:1 voltage 
divider before the ADC input, so the actual input voltage range is 0V - 5V, which gets 
converted to a 12-bit ratiometric number. So, 2500*2 is 5000, but is written as 2500*2 
to give the user the hint that there is voltage division going on at the ADC input.  
***********************************************************/  
endmodule

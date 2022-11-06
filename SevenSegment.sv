//

module SevenSegment
 (input  logic [5:0] DP_in,Blank,
  input  logic [3:0] Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5,
  output logic [7:0] Hex0,Hex1,Hex2,Hex3,Hex4,Hex5);
  
  // instantiate decoders
                                   
 SevenSegment_decoder decoder0(.H      (Hex0),
                               .input7S(Num_Hex0),
							        				 .Blank  (Blank[0]),
                               .DP     (DP_in[0]));      
 SevenSegment_decoder decoder1(.H      (Hex1),
                               .input7S(Num_Hex1),
							        				 .Blank  (Blank[1]),
                               .DP     (DP_in[1]));      
 SevenSegment_decoder decoder2(.H      (Hex2),
                               .input7S(Num_Hex2),
							        				 .Blank  (Blank[2]),
                               .DP     (DP_in[2]));      
 SevenSegment_decoder decoder3(.H      (Hex3),
                               .input7S(Num_Hex3),
							        				 .Blank  (Blank[3]),
                               .DP     (DP_in[3]));      
 SevenSegment_decoder decoder4(.H      (Hex4),
                               .input7S(Num_Hex4),
							        				 .Blank  (Blank[4]),
                               .DP     (DP_in[4]));     
 SevenSegment_decoder decoder5(.H      (Hex5),
                               .input7S(Num_Hex5),
								      				 .Blank  (Blank[5]),
                               .DP     (DP_in[5]));  

endmodule

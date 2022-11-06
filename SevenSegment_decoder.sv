// 4.24 Seven Segment Display

module SevenSegment_decoder(             
  input  logic [3:0] input7S, // "input" is a reserved keyword, so can't use it directly  
  input  logic       DP,Blank,       
  output logic [7:0] H);
  
  logic [6:0] seven_seg;                               
                                 
  always_comb        // LED Position:
    if(Blank) seven_seg=7'b0_00_00_00; // All LEDs off if Blank
    else        
    case(input7S)    // 6_54_32_10  
      0: seven_seg  = 7'b0_11_11_11; // underscore is ignored but greatly helps readability
      1: seven_seg  = 7'b0_00_01_10; // 0=LED off, 1=LED on (active-high)
      2: seven_seg  = 7'b1_01_10_11; // 7-segment display segments' positions below:
      3: seven_seg  = 7'b1_00_11_11; //    0                             
      4: seven_seg  = 7'b1_10_01_10; //  5   1                           
      5: seven_seg  = 7'b1_10_11_01; //    6                             
      6: seven_seg  = 7'b1_11_11_01; //  4   2                           
      7: seven_seg  = 7'b0_00_01_11; //    3                             
      8: seven_seg  = 7'b1_11_11_11;
      9: seven_seg  = 7'b1_10_01_11;
      //-- students add this block -----
		10: seven_seg = 7'b1_11_01_11; // A
		11: seven_seg = 7'b1_11_11_00; // b
		12: seven_seg = 7'b0_11_10_01; // C
		13: seven_seg = 7'b1_01_11_10; // d
		14: seven_seg = 7'b1_11_10_01; // E
		15: seven_seg = 7'b1_11_00_01; // F

      //--------------------------------
      default: seven_seg = 7'b0_00_00_00; // all LEDs off
    endcase

// Logic inversions in the 2 lines below is to turn the LEDs on when a 1 is given as a 
// control signal, to make it easier for the designer to just think of positive logic.
  assign H[6:0] = ~seven_seg;
  assign H[7]   = ~DP;

endmodule

// Another representation of the 7-segment display, note the addition
// of DP, which is the Decimal Point of the 7-segment display. 
// "__" and "|" represent LEDs (consider DP a small, round LED)   
//
//       __    
//       0   
//   5 |    | 1
//       __    
//       6    
//   4 |    | 2
//       __     DP 
//       3    

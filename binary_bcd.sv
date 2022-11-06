// This module converts the binary input to a Binary-Encoded
// Decimal (BCD) value which is output on bcd. See the binary
// to BCD mappings in the table at the end of the file.
// 
// This module is given "as is" and students DO NOT have to study
// and understand this module for exams.
// 
// Note a couple of unusual features of this RTL code:
//   1. This is a one always block state machine, which is not a 
//      recommended style, please use a 2- or 3-always block style.
//   2. Blocking assignments (i.e. =) are used in the sequential
//      always block for next_state, where the standard rule is to  
//      use non-blocking assignments (i.e. <=). Note the this module
//      does not work if you convert the blocking to non-blocking.
//      Essentially, the current_state assignment is delayed by one
//      clock cycle, due to the one always block SM design, so the 
//      designer ended up using blocking assignments. Check out the
//      testbench binary_bcd_compare_tb to analyze the differences.

module binary_bcd
 (input  logic        clk,reset_n,
  input  logic [12:0] binary,
  output logic [15:0] bcd);
    
  typedef enum {S0,S1,S2,S3,S4,S5,S6} statetype; // abstract enumerated declaration
  statetype current_state = S0,next_state;
  int counter = 0;
  logic [28:0] bcd_signal  = 0;
  parameter logic [28:0] // applies to below 4 assignments, to save space for reading the constants
  add3_0digit = 29'b0_0000_0000_0000_0110_0000_0000_0000,
  add3_1digit = 29'b0_0000_0000_0110_0000_0000_0000_0000,
  add3_2digit = 29'b0_0000_0110_0000_0000_0000_0000_0000,
  add3_3digit = 29'b0_0110_0000_0000_0000_0000_0000_0000;
  
  always_ff@(posedge clk, negedge reset_n) begin
    if (!reset_n) begin // recall reset is active-low, hence !reset_n
      bcd           <= 0;
      bcd_signal    <= 0;
      counter       <= 0;
      current_state <= S0;
    end
    else begin
      case(current_state)
        S0: begin bcd_signal[12:0] <= binary; 
                  next_state = S1; end
        S1: begin if(bcd_signal[28:25] > 4) 
                    bcd_signal <= bcd_signal + add3_3digit; 
                  next_state = S2; 
            end
        S2: begin if(bcd_signal[24:21] > 4) 
                    bcd_signal <= bcd_signal + add3_2digit; 
                  next_state = S3; 
            end
        S3: begin if(bcd_signal[20:17] > 4) 
                    bcd_signal <= bcd_signal + add3_1digit; 
                  next_state = S4; 
            end
        S4: begin if(bcd_signal[16:13] > 4) 
                    bcd_signal <= bcd_signal + add3_0digit; 
                  next_state = S5; 
            end
        S5: begin bcd_signal <= bcd_signal<<1; 
                  next_state = S6; end
        S6: begin if(counter == 12) begin
                    bcd        <= bcd_signal[28:13];
                    bcd_signal <= 0; 
                    counter    <= 0;
                    next_state = S0;
                  end
                  else begin
                    counter    <= counter+1;
                    next_state = S1;
                  end 
            end
        default: begin 
          next_state = S0;
          counter    <= 0;
          bcd_signal <= 0;
        end 
      endcase
      current_state <= next_state;
    end
  end
endmodule

/****************************************************
Example of mapping of binary to BCD values (and Hexadecimal):

                 BCD                               Hexadecimal      
Binary  BCD   in binary values     Hexadecimal   in binary values
0000     00    0000_0000              00           0000_0000
0001     01    0000_0001              01           0000_0001
0010     02    0000_0010              02           0000_0010
0011     03    0000_0011              03           0000_0011
0100     04    0000_0100              04           0000_0100
0101     05    0000_0101              05           0000_0101
0110     06    0000_0110              06           0000_0110
0111     07    0000_0111              07           0000_0111
1000     08    0000_1000              08           0000_1000
1001     09    0000_1001              09           0000_1001
1010     10    0001_0000              0A           0000_1010
1011     11    0001_0001              0B           0000_1011
1100     12    0001_0010              0C           0000_1100
1101     13    0001_0011              0D           0000_1101
1110     14    0001_0100              0E           0000_1110
1111     15    0001_0101              0F           0000_1111

BCD in binary values would be what is presented on the
output bcd[7:0], based on what binary value is
presented on the input binary[3:0]
****************************************************/

// top level module
// Watch out for case sensitivity when translating from VHDL.
// Also note that the .QSF is case sensitive.

module top_level
 (input  logic       clk,
  input  logic       reset_n,
  input  logic [9:0] SW,
  input  logic button,
  output logic [9:0] LEDR,
  output logic [7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  
  logic [3:0]  Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5;   
  logic [5:0]  DP_in, Blank;
  logic [15:0] bcd, mux_out, reg_out, out1;
  logic [12:0] out2;
  logic [9:0] SW_out;
  logic write_enable; // Storage register write enable active high
  logic [12:0] voltage, distance, voltage_out, distance_out;
  logic [11:0] ADC_out, ADC_raw, avg_out;
  
  assign Num_Hex0 = reg_out[3:0]; 
  assign Num_Hex1 = reg_out[7:4];
  assign Num_Hex2 = reg_out[11:8];
  assign Num_Hex3 = reg_out[15:12];
  assign Num_Hex4 = 4'b0000;
  assign Num_Hex5 = 4'b0000;                                             
  assign LEDR[9:0]= SW_out[9:0]; // gives visual display of the switch inputs to the LEDs on board
  
  // instantiate lower level modules
  
  digit_manager digit_manager_ins(.data(reg_out), .select(SW_out[9:8]), .Blank(Blank), .DP(DP_in));

  ADC_Data ADC_Data_ins(.clk(clk),.reset_n(reset_n),.voltage(voltage),.distance(distance),.ADC_raw(ADC_raw),.ADC_out(ADC_out));

  debounce debouncer_ins(.clk(clk),.reset_n(reset_n),.button(button),.result(write_enable));
  
  register #(.width(16)) register_ins(.clk(clk),.reset_n(reset_n),.write_enable(write_enable),.data(mux_out),.q(reg_out));

  synchronizer synchronizer_ins(.clk(clk), .SW(SW),.SW_out(SW_out));

  MUX2TO1 #(.width(16)) MUX_hexadecimal_output_ins(.in1({8'b0000_0000,SW_out[7:0]}),.in2({4'b0000,ADC_out}),.s(SW[8]),.mux_out(out1));
  MUX2TO1 #(.width(13)) MUX_binary_output_ins(.in1(distance),.in2(voltage),.s(SW_out[8]),.mux_out(out2));
  MUX2TO1 #(.width(16)) MUX_final_output_ins(.in1(out1),.in2(bcd),.s(SW_out[9]),.mux_out(mux_out));
  
  //SevenSegment SevenSegment_ins(.*); // (.*) doesn't work for VHDL files, and instance name was too long
  SevenSegment SevenSeg_ins(.Num_Hex0(Num_Hex0),
                            .Num_Hex1(Num_Hex1),
                            .Num_Hex2(Num_Hex2),
                            .Num_Hex3(Num_Hex3),
                            .Num_Hex4(Num_Hex4),
                            .Num_Hex5(Num_Hex5),
                            .Hex0(HEX0),
                            .Hex1(HEX1),
                            .Hex2(HEX2),
                            .Hex3(HEX3),
                            .Hex4(HEX4),
                            .Hex5(HEX5),
                            .DP_in(DP_in),
							.Blank(Blank));
  
  binary_bcd binary_bcd_ins(.clk(clk),                          
                            .reset_n(reset_n),                                 
                            .binary(out2),    
                            .bcd(bcd));

endmodule

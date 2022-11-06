// 

module MUX4TO1
 #(parameter width=16, selectwidth=2)
  (input  logic [width-1:0] in1,in2,in3,in4,
   input  logic [selectwidth-1:0]       s,
   output logic [width-1:0] mux_out);
  
	always_comb
		case(s)
			2'b00: mux_out=in1;
			2'b01: mux_out=in2;
			2'b10: mux_out=in3;
			2'b11: mux_out=in4;
			default: mux_out=in1;
		endcase
endmodule
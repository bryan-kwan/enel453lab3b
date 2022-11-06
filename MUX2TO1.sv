module MUX2TO1
 #(parameter width=16)
  (input  logic [width-1:0] in1,in2,
   input  logic s,
   output logic [width-1:0] mux_out);
  
	always_comb
		case(s)
			1'b0: mux_out=in1;
			1'b1: mux_out=in2;
			default: mux_out=in1;
		endcase
endmodule
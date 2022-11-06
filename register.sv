
module register #(parameter width=16)
						 (input logic [width-1:0] data,
						  input logic write_enable, clk, reset_n,
						  output logic [width-1:0] q);
						  
						  
		always_ff @(posedge clk, negedge reset_n)
			if(~reset_n) //asynchronous active low reset
				q<='0;
			else if (write_enable)
				q<=data;
						  
						  
endmodule
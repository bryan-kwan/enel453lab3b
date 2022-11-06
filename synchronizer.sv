module synchronizer (input logic [9:0] SW, input logic clk,
							output logic [9:0] SW_out);

	logic [9:0] n1;
	always_ff @(posedge clk)
		begin
			n1 <= SW;
			SW_out <= n1;
		end
							
endmodule
	
module digit_manager #(parameter
						n_DP_1 = 0, // Number of decimals for mode 1; 0 means no decimal point
						n_DP_2 = 0, 
						n_DP_3 = 2,
						n_DP_4 = 3)
					(input logic [15:0] data,
					input logic [1:0] select,
					output logic [5:0] DP, // Decimal point flag for each display (gets inverted in SevenSeg)
					output logic [5:0] Blank // Blank display flag (1=blank, 0=display)
					);

	always_comb begin : DP_Logic // Sets DP according to each mode
		DP = 6'b00_0000;
		case(select)
			2'b00: DP = 6'b00_0000; // Mode 1 Hexadecimal
			2'b01: DP = 6'b00_0000; // Mode 2 ADC avg (hexadecimal)
			2'b10: DP[n_DP_3] = 1; // Mode 3 distance
			2'b11: DP[n_DP_4] = 1; // Mode 4 voltage
			default: DP=6'b00_0000;
		endcase
	end


	
	always_comb begin : Blank_Logic
		// Displays 4 and 5 are always blank (only using 4 displays)
		case(select)
			2'b00: Blank=6'b11_0000; // Mode 1 (hexadecimal): no blanking leading zeros
			2'b01: if(data[15:12]==4'b0000 & data[11:8]==4'b0000 & data[7:4]==4'b0000) // Mode 2 (ADC avg, hexadecimal)
						Blank=6'b11_1110; // If HEX3=HEX2=HEX1=0, Blank HEX3/HEX2/HEX1
				   else if(data[15:12]==4'b0000 & data[11:8]==4'b0000)
				   		Blank=6'b11_1100; // If HEX3=HEX2=0 (and HEX1!=0), Blank HEX3/HEX2
				   else if(data[15:12]==4'b0000)
				   		Blank=6'b11_1000; // If HEX3=0 (and HEX1!=0 and HEX2!=0), Blank HEX3
				   else Blank=6'b11_0000;
			2'b10: if(data[15:12]==4'b0000) Blank=6'b11_1000; // Mode 3 (distance, bcd): can only have 1 leading 0
				   else Blank=6'b11_0000; // If HEX3=0, Blank HEX3
			2'b11: Blank=6'b11_0000; // Mode 4 (voltage, bcd): 3 decimals so no leading zeros possible
			default: Blank = 6'b11_0000;
		endcase
	end

	

endmodule
							  
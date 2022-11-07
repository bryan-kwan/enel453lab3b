module digit_manager_wrapper
					(input logic [15:0] data,
					input logic [1:0] select,
                    input logic pwm,
					output logic [5:0] DP, // Decimal point flag for each display (gets inverted in SevenSeg)
					output logic [5:0] Blank // Blank display flag (1=blank, 0=display)
					);

    logic[5:0] blank_out;

    digit_manager digit_manager_ins(.data(data),
        .select(select),
        .DP(DP),
        .Blank(blank_out)
        );

    always_comb
        if(pwm)
            Blank = blank_out;
        else
            Blank = 6'b11_1111; // Blank display when pwm = 0
endmodule 
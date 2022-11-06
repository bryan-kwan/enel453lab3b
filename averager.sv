
module averager #(parameter 
                INWIDTH=16,
                LOGSIZE=8, // Log base 2 of the size of SAMPLESIZE
                OUTWIDTH=16, // Same as INWIDTH if accurate rounding is not required (truncation is ok)
                SAMPLESIZE=2**LOGSIZE, // Number of samples to average
                SUMSIZE=SAMPLESIZE+INWIDTH // Minimum bit width of the sum
                )
                (input  logic           clk,
                                        EN,      // takes a new sample when high for each clock cycle
                                        reset_n,
                input  logic [INWIDTH-1:0]   Din,     // input sample for moving average calculation
                output logic [OUTWIDTH-1:0]   Q);

// Adaptation of filter from https://zipcpu.com/dsp/2017/10/16/boxcar.html
// Algorithm:
//	y[n] = y[n-1] + x[n] - x[n-navg]
// Pipeline: 
//  0   oldval, newval, memory, address
//  1   sum
//  2   Q

// Overall delay of 3 samples: 
// 1. Read old value/new value and write Din to memory
// 2. Compute sum = sum + new value - old value
// 3. Compute Q = sum / sample_size (ie. Q = sum[SUMSIZE-1:INWIDTH])

    logic [INWIDTH-1:0] memory [SAMPLESIZE-1:0];
    logic [INWIDTH-1:0] oldval, newval; // Oldest value and newest value
    logic [SUMSIZE-1:0] sum; // Sum of all values
    logic [LOGSIZE-1:0] address;

    always_ff @(posedge clk, negedge reset_n)
        if(~reset_n) begin
            oldval<=0; // Initialize accumulator values to 0
            newval<=0;
            sum<=0;
            Q<=0; 
            address<=0;
            for(int i = 0; i<SAMPLESIZE; i++)
                memory[i]<=0;
        end
        else if (EN) begin
            oldval <= memory[address]; // oldval gets the previous memory value before overwriting with Din
            newval <= Din;
            memory[address] <= Din;
            address <= address + 1'b1;
            sum <= sum + {{(SUMSIZE-INWIDTH){1'b0}},newval} - {{(SUMSIZE-INWIDTH){1'b0}},oldval}; // Add the new value and subtract the old value
            Q <= sum[SUMSIZE-1:LOGSIZE]; // average = sum / SAMPLESIZE (same as a shift since SAMPLESIZE is a power of 2)
        end

endmodule
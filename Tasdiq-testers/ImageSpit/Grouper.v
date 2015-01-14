// This moduel will be called by Submatrix_creator
// The output values from here must not go directly to Submatrix.v
// rather the top level should relay it.

// The value for loaded should be used as a part with enable 
// at the top level. 


module Grouper(clk, enable, resetn, stream, loaded, dataOutput);
	parameter sizeOfCounter = 3; 

	// ACTIVE LOW RESET
	input clk, enable, resetn, stream;		// from the left side 
	// we have not yet decided where enable and resetn will come from
	// stream is the 1bit value that comes from RAM
	// stream MUST BE STOPPED when loaded = 1 
	
	// the next 3 is for Submatrix
//	input readyToBeLoaded;					// comes from Submatrix.v via the top level
	output reg loaded ;						// loaded = 1 when 16bit array is full 
	output reg [2:0] 	dataOutput;			// the 16bit array to output 
											// comes from the intermediary subGroup

	reg	[sizeOfCounter-1:0]	counter; 					// counts
	reg [2:0] 	subGroup;					// storage for shifting bits
											// gets relayed to output at 16th clock edge


//	Count restarts only when top level is ready for output AND the output is ready here
//  restarting would make loaded = 0
// PITFALL happens if: loaded = 1, submatrix takes in and still keeps readyToBeLoaded =1
// 						instead of turning it off and compute stuff
// RESOLVED
//
	wire restartCount;	 
	assign restartCount = ~enable & loaded; 

// magic begins 
	always @(posedge clk) begin
	
	if (restartCount | ~resetn) begin
		counter <= 3'd0;
		subGroup <= 3'b0;
		loaded <= 0;
	end 

	else if(enable) begin 
			if (counter < 3'd4)begin 
				subGroup[2:1] <= subGroup[1:0];
				subGroup[0] <= stream;
				counter <= counter + 1;
				loaded <= 0;
			end 
			else begin
				loaded <= 1; 
				dataOutput <= subGroup;
				counter <= 3'd0;
			end	
		end  
	end

endmodule 

/*
TEST  RESULTS:
	works with manuall driven input signals 

*/
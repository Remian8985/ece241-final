module Grouper(clk, enable, resetn, stream, readyToBeLoaded, loaded, dataOutput);
	parameter n = 4; 

	// ACTIVE LOW RESET
	input clk, enable, resetn, stream;		// from the left side 
	// the next 3 is for Submatrix
	input readyToBeLoaded;
	output reg loaded ;
	output reg [15:0] 	dataOutput;

	reg	[n:0]	counter; 
	reg [15:0] 	subGroup;

	wire restartCount;
	assign restartCount = readyToBeLoaded & loaded; 

	always @(posedge clk) begin
	if (restartCount | ~resetn) begin
		counter <= 5'd0;
		subGroup <= 16'b0;
	end 
	else if(enable) begin 
		
			if (counter < 5'd16)begin 
				subGroup[15:1] <= subGroup[14:0];
				subGroup[0] <= stream;
				counter <= counter + 1;
				loaded <= 0;
			end 
			else begin
				loaded <= 1; 
				dataOutput <= subGroup;
			end	
		end  
	end

endmodule 
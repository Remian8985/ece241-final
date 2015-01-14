module Master_counter(clk, enable, resetn, memAddress);
	parameter n = 15;

	input clk, enable, resetn;

	output reg	[n:0]	memAddress;			// counter for the whole memory array

	always @(posedge clk) begin
		if (!reset) 
			memAddress <= 16'd0
		else if(enable) begin 
			if (memAddress < 16'd57600)
				memAddress <= memAddress + 1;
			else 
				memAddress <= 16'd0
		end  
	end
endmodule 
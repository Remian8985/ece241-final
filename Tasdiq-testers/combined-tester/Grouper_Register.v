module Grouper_resiter(clk, enable);
	parameter n = 15;

	input clk, enable;

	reg	[n:0]	mem_address;			// counter for the whole memory array

	always @(posedge clk) begin
		if(enable) begin 
			mem_address <= mem_address + 1;
		end  
	end
	
endmodule 
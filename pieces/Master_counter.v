module Master_counter(clk, enable, reset);
	parameter n = 15;

	input clk, enable, reset;

	output reg	[n:0]	mem_address;			// counter for the whole memory array

	always @(posedge clk) begin
		if (reset) 
			mem_address <= 16'd0
		else if(enable) begin 
			if (mem_address < 16'd57600)
				mem_address <= mem_address + 1;
			else 
				mem_address <= 16'd0
		end  
	end
endmodule 
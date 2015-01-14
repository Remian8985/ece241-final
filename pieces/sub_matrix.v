

module sub_matrix (clk, data_in, clk, resetn, data_out);
	input [15:0] data_in;
	input clk, resetn; 
	output reg [15:0] data_out;

	always @(posedge clk ) begin
		if (!resetn) begin
			data_in <= 16'b0;			
		end
		else begin
			data_out <= data_in;
		end
	end
endmodule 



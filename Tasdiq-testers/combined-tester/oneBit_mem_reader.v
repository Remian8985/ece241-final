module oneBit_mem_rader(clk, reset, done, sub_group );
	parameter m = 6;
	parameter n = 16;		

	input clk, reset; 				// reset is given from top level when that is
									// ready to take in another 16-bit group. 

	output reg done ;				// signals the top level to take in 16-bit group
	output reg [15:0] send_group;	

	wire gnd, oneBit_outs; 
	reg [15:0] sub_group;	// the 16 bit group				
	reg [m:0] counter1; 			// counts up to 15/16
									// counter for the subgroup

	reg [n:0]	counter2;			// counter for the whole memory array


	assign gnd = 0;
	test1	test1_inst (
		.address ( address_sig ),	// need an address counter 
		.clock ( clk ),
		.data ( data_sig ),			// DON'T NEED , we're not writing 
		.wren ( gnd ),				// 		''
		.q ( oneBit_outs )			// output from the memory
		);


	always @(posedge clk) begin
		if (reset) begin
			counter1 <= 6'd0;				// resets count when top-level is ready
			done <= 0;
		end
		else if(counter2 > 16'd57600) begin 	// resets all the count when traversing is done
			counter1 <= 6'd0; 					
			counter2 <= 16'd0;		// 
			done <= 0;
		end 

		else if (counter1 < 6'd15) begin 
			sub_group[15:1] <= sub_group[14:1];
			sub_group[0] <= oneBit_outs;
			done <= 0;
			counter1 <= counter1 + 1; 
			counter2 <= counter2 + 1; 
		end 
		else begin 
			done <= 1;
			send_group <= sub_group;
		end 
	end
endmodule 
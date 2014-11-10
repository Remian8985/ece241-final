// Module to write an entire screen to buffer 
// Or we can pass colour value from here
// and put it in buffer in top level

// 	/!\
// NEED TO HEAVILY MODIFY MAGIC NUMBERS
// AND MEMORY
// FOR A CHANGE IN RESOLUTION :(


module change_display_to_image(wren, opcode, clk_in, clk_out, mem_address, date_in, data_out);
	parameter p = 2;	//	opcode size -1
	parameter m = 2;	// colour size -1
	parameter n = 15; // ?	// number of bits for memory -1
	parameter p = 4;	// number of image/options	


	input clk_in, clk_out, wren;	// 50MHz and 25MHz ??
	opcode [p:0] opcode;
	input [n:0] mem_address;
	input [m:0] data_in;		// 3 bit colour
	output  [m:0] data_out;		// 3 bit colour 

	//reg wren_sig, wren_sig1, wren_sig2, wren_sig3, wren_sig4;


	wire [m:0] data_out1, data_out2, data_out3, data_out4;	


// Assuming all the mif files are valid 
// when not writing, we're reading. 
image1	go_image1(
	.address ( mem_address ),
	.data ( data_in ),
	.inclock ( clk_in ),
	.outclock ( clk_out ),
	.wren ( wren_sig[1] ),
	.q ( data_out1 )
	);

image2	go_image2(
	.address ( mem_address ),
	.data ( data_in ),
	.inclock ( clk_in ),
	.outclock ( clk_out ),
	.wren ( wren_sig[2] ),
	.q ( data_out2 )
	);

// and so on

////////////
// mux to select what image (or not) to select
always @(posedge clk_in) begin
	if(wren)
		wren_sig <= opcode;

	case (opcode)
		3'b000: begin 
				// select no image 
				// read from buffer 
				data_out <= m'd0;
			end 
		3'b001: begin 
				data_out <= data_out1;

			end 			
		3'b010: begin 
				data_out <= data_out2;
			
			end 
		3'b011: begin 
				data_out <= data_out3;
			
			end 
//	..
//	..
		default: 
			data_out <= m'd0;
	endcase 
end


endmodule 


module copy_buffer( clk_in, clk_out, mem_address, date_in);
	

endmodule 
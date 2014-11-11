// Module to write an entire screen to buffer 
// Or we can pass colour value from here
// and put it in buffer in top level

// 	/!\
// NEED TO HEAVILY MODIFY MAGIC NUMBERS
// AND MEMORY
// FOR A CHANGE IN RESOLUTION :(


module change_display_to_image(wren, opcode, clk_in, clk_out, mem_address, data_in, data_out, wren_out);
	parameter p = 3;	//	opcode size 
					// number of images. 0th bit for copying the buffer to refresh the screen
	parameter m = 2;	// colour size -1
	parameter n = 15; // ?	// number of bits for memory -1	

	parameter vcc = 1;
	parameter gnd = 0;


	// 	  clock1, clock2 	in top level
	input clk_in, clk_out, wren;	// 50MHz and 25MHz ??
	input [p:0] opcode;
	input [n:0] mem_address;	// MUST COME FROM THE COUNTER
	input [m:0] data_in;		// 3 bit colour		... coming from the BUFFER
	output reg  [m:0] data_out;		// 3 bit colour 
	output reg wren_out;

	//reg wren_sig, wren_sig1, wren_sig2, wren_sig3, wren_sig4;

	reg [p:0] wren_sig;
	wire [m:0] data_out1, data_out2, data_out3, data_out4;	


// Assuming all the mif files are valid 
// when not writing, we're reading. 
// when passing values to write buffer, outclock MUST BE 50MHz
// other wise MUST BE 25MHz
// or whatever
	target0	go_target0(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_in ),
		.outclock ( clk_out ),
		.wren ( wren_sig[1] ),	// wren_sig is defined below at always blcok
		.q ( data_out1 )
		);

	target1	go_target1(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_in ),
		.outclock ( clk_out ),
		.wren ( wren_sig[2] ),
		.q ( data_out2 )
		);
/*
		target2	go_target2(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_in ),
		.outclock ( clk_out ),
		.wren ( wren_sig[2] ),
		.q ( data_out2 )
		);
*/
// and so on

// instantiate clipboard 

////////////
// mux to select what image (or not) to select
	always @(posedge clk_out) begin
		if(wren)
			wren_sig <= opcode;
		else 
			wren_sig <= 4'b0; // p =4 = opcode size

		case (opcode)
			4'b0000: begin 
					// select no image 
					// read from buffer 
					//data_out <= data_in;
					//wren_out <= 0;
				end 
			4'b0001: begin 
					wren_out <= 1;
					data_out <= data_out1;

				end 			
			4'b0010: begin 
					wren_out <= 1;
					data_out <= data_out2;
				
				end 
			4'b0100: begin 
					wren_out <= 1;
					data_out <= data_out3;
				
				end 
	//	..
	//	..
			default: 
				data_out <= 3'b111;	// m = 2
//				data_out <= data_in;	// m = 2
		endcase 
//		wren_sig <= 5'b0;
	end


endmodule 
 
 
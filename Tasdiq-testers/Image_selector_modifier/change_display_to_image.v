// Module to write an entire screen to buffer 
// Or we can pass colour value from here
// and put it in buffer in top level

// 	/!\
// NEED TO HEAVILY MODIFY MAGIC NUMBERS
// AND MEMORY
// FOR A CHANGE IN RESOLUTION :(


module change_display_to_image(wren, screen_refresh_done, opcode, clk_50, clk_25, mem_address, data_in, data_out, wren_out);
	parameter p = 3;	//	opcode size 
					// number of images. 0th bit for copying the buffer to refresh the screen
	parameter m = 2;	// colour size -1
	parameter n = 15; // ?	// number of bits for memory -1	

	parameter vcc = 1;
	parameter gnd = 0;

	// one-hot state parameters:
	parameter KEEP_SCREEN = 7'b0000001, LOAD_IMAGE1 = 7'b0000010, LOAD_IMAGE2 = 7'b0000100, 
			LOAD_IMAGE3 = 7'b0001000, WRITE_CLIPBOARD = 7'b0010000, READ_CLIPBOARD = 7'b0100000;


	// 	  clock1, clock2 	in top level
	input clk_50, clk_25, wren;	// 50MHz and 25MHz ??
	input screen_refresh_done;
	input [p:0] opcode;
	input [n:0] mem_address;	// MUST COME FROM THE COUNTER
	input [m:0] data_in;		// 3 bit colour		... coming from the BUFFER
	output reg  [m:0] data_out;		// 3 bit colour 
	output reg wren_out;
//	output [5:0] lights;

	//reg wren_sig, wren_sig1, wren_sig2, wren_sig3, wren_sig4;

	reg [p:0] wren_sig;
	wire [m:0] data_out1, data_out2, data_out3, data_out4;	
	reg [6:0] present_state, next_state;
	reg change_state; 
	//assign wren_out =(present_state != KEEP_SCREEN);	
					// also when writing to a memory or clipboard

//	assign wren_out = vcc;


// Assuming all the mif files are valid 
// when not writing, we're reading. 
// when passing values to write buffer, outclock MUST BE 50MHz
// other wise MUST BE 25MHz
// or whatever
	target0	go_target0(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_50 ),
		.outclock ( clk_25 ),
		.wren ( wren_sig[1] ),	// wren_sig is defined below at always blcok
		.q ( data_out1 )
		);

	target1	go_target1(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_50 ),
		.outclock ( clk_25 ),
		.wren ( wren_sig[2] ),
		.q ( data_out2 )
		);
/*
		target2	go_target2(
		.address ( mem_address ),
		.data ( data_in ),
		.inclock ( clk_50 ),
		.outclock ( clk_25 ),
		.wren ( wren_sig[2] ),
		.q ( data_out2 )
		);
*/
// and so on

// instantiate clipboard 



// super weird probably unnecessary FSM
// because i'm too lazy to think of any other
// way that would change output only when 
// screen sync is complete

// states depend on opcode, not previous state. 
always @(posedge clk_50) begin
	case(opcode)
		4'b0000: begin 
				next_state <= KEEP_SCREEN;
				end
		4'b0001: begin 
				next_state <= LOAD_IMAGE1;
				end
		4'b0010: begin 
				next_state <= LOAD_IMAGE2;
				end
		// 4'b0011: begin 
		// 		next_state <= LOAD_IMAGE3;
		// 		end
		default: begin 
				next_state <= KEEP_SCREEN;
				end
	endcase
	if (change_state)
		present_state <= next_state;
	else 
		present_state <= present_state;

	if (screen_refresh_done)
		change_state <= 1;
	else 
		change_state <= 0;

// NEED TO IMPLEMENT wren FOR WRITING TO MEMORY

	case (present_state)
		KEEP_SCREEN: begin 
					wren_sig <= 4'b0;
					data_out <= data_in;
					wren_out <= 0;
					end 
		LOAD_IMAGE1: begin 
					if(wren)
						wren_sig <= 4'b0; // DEFINE HERE
					else
						wren_sig <= 4'b0;
					data_out <= data_out1;
					wren_out <= 1;
					end 
		LOAD_IMAGE2: begin 
					if(wren)
						wren_sig <= 4'b0; // DEFINE HERE
					else
						wren_sig <= 4'b0;
					data_out <= data_out2;
					wren_out <= 1;
					end 
		LOAD_IMAGE3: begin 
					if(wren)
						wren_sig <= 4'b0; // DEFINE HERE
					else
						wren_sig <= 4'b0;
					data_out <= data_out3;
					wren_out <= 1;
					end 
		default: begin 
					wren_sig <= 4'b0;
					data_out <= data_in;
					wren_out <= 0;
					end 

	endcase  
end
endmodule 
 
 
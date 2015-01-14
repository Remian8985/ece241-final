module ImageSpit(	
		LEDR,
		LEDG,
		SW,
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
		);
		
		
	input	[17:0]	SW;
	input			CLOCK_50;				//	50 MHz
	input	[0:0]	KEY;					//	Button[3:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output	[17:0]	LEDR;
	output 	[7:0] 	LEDG;
	
	wire resetn;
	wire user_enable; 
	wire [15:0] mem_address;
	wire [15:0] vga_mem_address;
	wire loaded; 
	wire wren; 
	wire bitStream;
	wire gnd, vcc, high_impedence;
	wire [2:0] colour_group;
	wire loaded_delay;
	wire counter_enable;
	
	assign LEDR[2:0] = colour_group;
	
	
	assign vcc = 1;	assign gnd = 0;
	assign resetn = SW[17]; 
	assign user_enable = SW[16];
	assign wren = loaded;
	assign counter_enable = loaded_delay | user_enable;
	assign counter_enable2 = ~loaded_delay | user_enable;
	
	D_flipflop dff(loaded, CLOCK_50,  loaded_delay);
	
	
	OriginalImage	OriginalImage_inst (
	.address ( mem_address ),
	.clock ( VGA_CLK ),
	.q ( bitStream )
	);
	
	
	
	CounterFARHAD cf(
		.resetN(resetn), 
		.clock(VGA_CLK), 
		.enable(~loaded), 			// alternative ...~loaded
		.count(mem_address)
		);
//	defparam cf.countLimit = 3;
	
	GrouperFARHAD grpf(
		.resetN(resetn), 
		.clock(VGA_CLK), 
		.enable(~loaded), 			// alternative ...~loaded
		.element(bitStream), 
		.loaded(loaded), 					// output 
		.groupedElements(colour_group)		// output 
		);
	defparam grpf.groupSize = 3;
		
				
	CounterFARHAD finalCounter(				// ONLY COUNTS WHEN SHIFTER IS LOADED
		.resetN(resetn), 
		.clock(VGA_CLK), 
		.enable(loaded), 			// alternative ...~loaded
		.count(vga_mem_address)
		);
	defparam finalCounter.countLimit = 19200;
	
	
	
	
	
/*
	
	Master_counter MC (
	.clk(CLOCK_50), 
	.enable(counter_enable2), 
	.resetn(resetn), 
	.memAddress(mem_address)
	);

	Grouper grouper_inst(
	.clk(CLOCK_50), 
	.enable(counter_enable2), 
	.resetn(resetn), 
	.stream(bitStream), 
	.loaded(loaded), 
	.dataOutput(colour_group)
	);
	
	final_counter FC(
	.clk(CLOCK_50), 
	.enable(counter_enable), 
	.resetn(resetn), 
	.memAddress(vga_mem_address)
	);
*/	
	
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour_group),
		.x(gnd),
		.y(gnd),
		.memory_from_grouper(vga_mem_address),
		.plot(vcc),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK),
		.VGA_SYNC(VGA_SYNC),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "display.mif";

endmodule 

module D_flipflop_inverter(D, clk,  Q);
	input D;
	input clk;
	output reg Q;
	always@(posedge clk)
//always@(posedge clk or negedge resetn) // for async 
	begin
			Q <= ~D;
	end 
endmodule 

module D_flipflop(D, clk,  Q);
	input D;
	input clk;
	output reg Q;
	always@(posedge clk)
//always@(posedge clk or negedge resetn) // for async 
	begin
			Q <= D;
	end 
endmodule 
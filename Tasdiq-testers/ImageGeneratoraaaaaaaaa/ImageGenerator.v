module ImageGenerator(	
		
	resetN, 
  clock, 
  userEnable,
  readyToBeProcessed,
  encryptedSubmatrixElements,
  processed, 
 // address, 
  pixel,
  writeEnable,
  encryptedImageDisplayed,
  VGAmemAddress,
  enable,
  loaded,
  colour, 
  imageWriteEn,
		
		
		
		
		
		
		
		
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
	output [15:0] VGAmemAddress;
	output loaded; 				////////////////			//Indicates when grouper is loaded with 3 elements
	wire wren; 
	wire bitStream;
	wire gnd, vcc, high_impedence;
	wire [2:0] colour_group;
	wire loaded_delay;
	wire counter_enable;
	output imageWriteEn; 
	wire delayedLoaded;
assign imageWriteEn = loaded & enable & ~processed & delayedLoaded;
	

	
//	assign LEDR[2:0] = colour_group;
	
	
	assign vcc = 1;	assign gnd = 0;
//	assign resetn = SW[17]; 
//	assign user_enable = SW[16];
	assign wren = loaded;
	assign counter_enable = loaded_delay | user_enable;
	assign counter_enable2 = ~loaded_delay | user_enable;
	
	
		input [15:0] encryptedSubmatrixElements;				//
		
		
	
	input resetN, clock, readyToBeProcessed;
//	input [15:0] encryptedSubmatrixElements;
	input userEnable;
	output processed;
	output [2:0] pixel;
//	output [14:0] address;
	output writeEnable; 
	assign writeEnable = imageWriteEn;
	output reg encryptedImageDisplayed; //Indicates when the entire decrypted image has been outputted to the screen

//	wire loaded; //Indicates when grouper is loaded with 3 elements
	output enable = userEnable && readyToBeProcessed && !encryptedImageDisplayed && !processed; //Module is enabled when user enables the circuit



	wire serialEncryptedSubmatrixRegOutput;
	wire parallelEncryptedSubmatrixRegOutput;
	//wire [15:0] address;



	always@(posedge clock)
	begin
		if(!resetN || !readyToBeProcessed) //If reset or idle, reset the appropriate ports
		begin
			if(!resetN)
				encryptedImageDisplayed = 0;
	//		processed = 0;
		end
		
		else
			encryptedImageDisplayed = (loaded && ( VGAmemAddress==19199)); //Finished uploading last pixel
	end


	//Turns the 16 bit output from the Submatrix module into a stream of bits //Essentially the opposite of a Grouper
	ShiftRegister elementsToAddToImage
	(
		.resetN(resetN),
		.clock(CLOCK_50),
		.enable(enable),
		.resetValue (gnd),
		.shiftRight (1),
		.loadParallelly (dataLoadControllerCount==0), //Loads at the beginning of the count
		.serialLoad (0),
		.parallelLoad(encryptedSubmatrixElements),
		.serialOutput(serialRegOutput),
		.parallelOutput(parallelRegOutput)
	);

	wire [5:0] dataLoadControllerCount;

	Counter dataLoadController //Controls when elementsToAddToImage accepts new data from Submatrix
	(
		.resetN(resetN),
		.clock(CLOCK_50),
		.enable(enable),
		.count(dataLoadControllerCount)
//		.do_go_back(vcc)
	);
	defparam
	dataLoadController.counterSize = 5, //17 counts per cycle- 1 for data load and 16 to output data
	dataLoadController.countLimit = 16;

	
	 //Converts stream of data from elementsToAddToImage into 3 bit words, which represent pixels
	Grouper pixelGrouper 
	(
		.resetN(resetN),
		.clock(CLOCK_50),
		.enable(enable && dataLoadControllerCount!= 0), //Take new input when user has enabled circuit and elementsToAddToImage isn't loading new data parallely
		.element(serialRegOutput),
		.loaded(loaded),
		.groupedElements(pixel)
	);
	defparam pixelGrouper.groupSize = 3,
	pixelGrouper.sizeOfCounterInBits= 2;
	//defparam pixelGrouper.countLimit = 3;


	assign processed = dataLoadControllerCount == 16; //Entire cycle has been completed

	Counter addressTraverser //Increments once every three clock ticks; equivalently, increments every time Grouper finishes inserting a pixel into the RAM
	(
		.resetN(resetN),
		.clock(CLOCK_50),
		.enable(loaded),
		.count(VGAmemAddress)
//		.do_go_back(gnd)
	);
	
	output [2:0] colour;
	//threeDelay delayit(enable, clock, delayedLoaded); 
	
	vga_adapter VGA(
		.resetn(resetN),
		.clock(CLOCK_50),
		.colour(pixel),
		.x(gnd),
		.y(gnd),
		.memory_from_grouper(VGAmemAddress),
		.plot(imageWriteEn),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK),
		.VGA_SYNC(VGA_SYNC),
		.VGA_CLK(VGA_CLK)
		);
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "display.mif";

endmodule 


module threeDelay(resetn, clk,  vgaEnable);
	input clk, resetn;	// active low
//	input [2:0] raw;
//	output reg [2:0] outs;
	output reg vgaEnable;
	
	reg [1:0]counter; 
	
	
	always@(posedge clk)
	begin 
		if (!resetn) begin 
			counter <= 2'b0;
			vgaEnable <= 0;
		end 
		else begin 
			counter <= counter + 2'b01;
			vgaEnable <= 0;
		end 
		
		if (counter[0] & counter[1]) begin 
	//		outs <= raw;
			vgaEnable <=1;
		end 
	end 

endmodule 
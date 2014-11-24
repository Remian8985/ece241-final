
module ImageGenerator2
	(
		LEDR,
		LEDG,
		CLOCK_50,						//	On Board 50 MHz
		KEY,
		SW,							//	Push Button[0:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B	  						//	VGA Blue[9:0]
	);
//module ImageGenerator (resetN, clock, userEnable, readyToBeProcessed, encryptedSubmatrixElements, processed);

	input	CLOCK_50;				//	50 MHz
	input	[3:0] KEY;				//	Button[0:0]
	input	[17:0] SW;				//	Button[0:0]
	output	VGA_CLK;   				//	VGA Clock
	output	VGA_HS;					//	VGA H_SYNC
	output	VGA_VS;					//	VGA V_SYNC
	output	VGA_BLANK;				//	VGA BLANK
	output	VGA_SYNC;				//	VGA SYNC
	output	[9:0] VGA_R;   			//	VGA Red[9:0]
	output	[9:0] VGA_G;	 		//	VGA Green[9:0]
	output	[9:0] VGA_B;   			//	VGA Blue[9:0]

//input [17:0]	SW;
wire [15:0] encryptedSubmatrixElements;
output [17:0]	LEDR;
output [7:0]	LEDG;

wire serialEncryptedSubmatrixRegOutput;
wire parallelEncryptedSubmatrixRegOutput;
wire [15:0] address;

assign encryptedSubmatrixElements[15:0]	= SW [15:0];
wire resetN, clock, readyToBeProcessed, processed;

assign clock = CLOCK_50;
assign resetN = SW[17];
assign readyToBeProcessed = SW[16];
assign LEDG[0] = processed;
assign userEnable = SW[15];
assign LEDR[15:0] = address[15:0];

wire loaded; //Indicates when grouper is loaded with 3 elements
wire [2:0] pixel;
reg encryptedImageDisplayed; //Indicates when the entire decrypted image has been outputted to the screen
wire enable = userEnable && readyToBeProcessed && !encryptedImageDisplayed; //Module is enabled when user enables the circuit

wire imageWriteEn; 
assign imageWriteEn = loaded & enable;

wire vcc, gnd, highImpedence;
assign vcc = 1;
assign gnd = 0;

always@(posedge clock)
begin
	if(!resetN || !readyToBeProcessed) //If reset or idle, reset the appropriate ports
	begin
		if(!resetN)
			encryptedImageDisplayed = 0;
//		processed = 0;
	end
	
	else
		encryptedImageDisplayed = (loaded&&address==19199); //Finished uploading last pixel
end

//Turns the 16 bit output from the Submatrix module into a stream of bits //Essentially the opposite of a Grouper
ShiftRegister elementsToAddToImage
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.resetValue (gnd),
	.shiftRight (1),
	.loadParallelly (dataLoadControllerCount==0), //Loads at the beginning of the count
	.serialLoad (0),
	.parallelLoad(encryptedSubmatrixElements),
	.serialOutput(serialRegOutput),
	.parallelOutput(parallelRegOutput)
);

 //Converts stream of data from elementsToAddToImage into 3 bit words, which represent pixels
Grouper pixelGrouper 
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable && dataLoadControllerCount!= 0), //Take new input when user has enabled circuit and elementsToAddToImage isn't loading new data parallely
	.element(serialRegOutput),
	.loaded(loaded),
	.groupedElements(pixel)
);

wire [5:0] dataLoadControllerCount;

Counter dataLoadController //Controls when elementsToAddToImage accepts new data from Submatrix
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.count(dataLoadControllerCount),
);
defparam
dataLoadController.counterSize = 5, //17 counts per cycle- 1 for data load and 16 to output data
dataLoadController.countLimit = 16;

assign processed = dataLoadControllerCount == 16; //Entire cycle has been completed

Counter addressTraverser //Increments once every three clock ticks; equivalently, increments every time Grouper finishes inserting a pixel into the RAM
(
	.resetN(resetN),
	.clock(clock),
	.enable(loaded),
	.count(address)
);

//RAM Module
//writeEnable = loaded && enable
//Address = address
//Input=pixel
//clock = clock
//
// VGA adapter is modified:
// we are directly inputting the memory address 
// instead of x,y.
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(pixel),
		.x(gnd),			// obsolete
		.y(gnd),			// obsolete
		.memory_from_grouper(address),
		.plot(gnd),
//		.plot(imageWriteEn),
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
	// this display.mif should be the first image we want to display
	// when the program starts. 
	// it can be any image

endmodule


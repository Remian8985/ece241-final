//Uses the AES encryption algorithm to encrypt 160 by 120 pixel
//Displays the encrypted image via VGA

module ImageEncryptor
(
/*	
	readyToBeLoaded,
	submatrixGeneratorOutput1,
	encryptorOutput,
	loaded,
	pixel,
	VGAAddress,
	writeEnable,
	encryptedImageDisplayed,
	encrypted,
	processed,
*/	
	
	
	
	SW, 
	LEDR,
	LEDG,
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

	input [17:0] SW;
	input CLOCK_50;
	input	[3:0]	KEY;				//	Button[3:0]
	output VGA_CLK;   					//	VGA Clock
	output VGA_HS;						//	VGA H_SYNC
	output VGA_VS;						//	VGA V_SYNC
	output VGA_BLANK;					//	VGA BLANK
	output VGA_SYNC;					//	VGA SYNC
	output [9:0] VGA_R;   				//	VGA Red[9:0]
	output [9:0] VGA_G;	 				//	VGA Green[9:0]
	output [9:0] VGA_B;   				//	VGA Blue[9:0]
	output [17:0] LEDR;
	output [7:0] LEDG;

	wire resetN;
	wire enable;
	wire clock;

	
	wire 	readyToBeEncrypted;
	wire 	readyToBeProcessed;
	wire 	VGAresetn;

	wire	[15:0] imageGeneratorInput;
	wire	[15:0] encryptorInput;
	wire	debugCLK;

	
///////////////////////////////////////////////////////////////	
	wire	[15:0] submatrixGeneratorOutput;	//
	wire	[15:0] encryptorOutput;				//

	wire 	loaded;					//
	wire 	encrypted;				//
	wire 	processed;				//
	wire	readyToBeLoaded;		//
	wire	[2:0]	pixel;			//
	wire	[14:0]	VGAAddress;		//
	wire	writeEnable;			//
	wire	encryptedImageDisplayed; //
///////////////////////////////////////////////////////////////	

//##############################################################
//##############################################################
//##############################################################
//##############################################################

	
	/*
///////////////////////////////////////////////////////////////	
	wire	[15:0] submatrixGeneratorOutput;	//
	output	[15:0] encryptorOutput;				//
	output	[15:0] submatrixGeneratorOutput1;	//

	output loaded;					//
	output encrypted;				//
	output processed;				//
	output	readyToBeLoaded;		//
	output	[2:0]	pixel;			//
	output	[14:0]	VGAAddress;		//
	output	writeEnable;			//
	output	encryptedImageDisplayed; //
	

////////////////////////////////////////////////////////////////	
*/


///////////////////////////////////////////////////////////////	
	assign  LEDR[1] 		=	readyToBeEncrypted;
	assign  LEDR[2] 		=	readyToBeProcessed;

//	wire [15:0] imageGeneratorInput;
//	wire [15:0] encryptorInput;

	
//	wire	[15:0] submatrixGeneratorOutput;	//
//	wire	[15:0] encryptorOutput;				//

	assign  LEDR[10] 		=	loaded;					//
	assign  LEDR[11] 		=	encrypted;				//
	assign  LEDR[12] 		=	processed;				//
	assign  LEDR[0] 		=	readyToBeLoaded;		//
	assign  LEDG[2:0] 		=	pixel[2:0]	;			//
	assign  LEDR[4] 		=	writeEnable;			//
	assign  LEDR[3] 		=	encryptedImageDisplayed; //
///////////////////////////////////////////////////////////////		


	wire vcc, gnd, highImpedence;
	wire changedHz;
	assign vcc = 1;	assign gnd = 0;
	assign VGAresetn = SW[16];

	assign resetN = SW[16];
	assign enable = SW[0] & ~encryptedImageDisplayed;
	assign clock = CLOCK_50;
//	assign debugCLK = KEY[0];
//	assign debugCLK = CLOCK_50;
//	assign debugCLK = changedHz;
	assign debugCLK = CLOCK_50 & ~SW[2]  | changedHz & SW[2];
	// clock multiplexer
	
	

	
	frequency_divider divideHz(CLOCK_50,resetn,changedHz);
	
	
	SubmatrixGenerator submatrixGenerator 
	(	
//		.clock(clock),
		.clock(debugCLK),
//		.clock(VGA_CLK), 
		.resetN (resetN), 
		.userEnable (enable), 
		.readyToBeLoaded (vcc), 
		.loaded (loaded), 
		.submatrixElements(submatrixGeneratorOutput)
	);

	Submatrix submatrix 
	(
//		.clock(clock),
		.clock(debugCLK),
//		.clock(VGA_CLK), 
		.resetN(resetN), 
		.loaded(loaded), 
		.encrypted(encrypted),
		.processed(processed),  
		.readyToBeLoaded(readyToBeLoaded),				// output
		.readyToBeProcessed(readyToBeProcessed),		// output
		.readyToBeEncrypted(readyToBeEncrypted),		// output
		.submatrixGeneratorOutput(submatrixGeneratorOutput),
	   .encryptorOutput(encryptorOutput),				//Output of encryptor is input of submatrix
	   .encryptorInput(encryptorInput),					//See above comment		// output
	   .imageGeneratorInput(imageGeneratorInput)		//See above comment	//outpu
	);

	Encryptor encryptor
	(
//		.clock(clock),
		.clock(debugCLK),
//		.clock(VGA_CLK), 
		.resetN(resetN),
		.readyToBeEncrypted(readyToBeEncrypted),
		.dataToEncrypt(encryptorInput),
		.encrypted(encrypted),
		.encryptedData (encryptorOutput)
	);

	ImageGenerator imageGenerator 
	(
		.resetN(resetN), 
//		.clock(clock),
		.clock(debugCLK),
//		.clock(VGA_CLK), 
		.userEnable(enable), 
		.readyToBeProcessed(readyToBeProcessed), 
		.encryptedSubmatrixElements(imageGeneratorInput), 
		.processed (processed),				// output 
		.address(VGAAddress),				// output
		.pixel(pixel),						// output
		.writeEnable(writeEnable),			// output
		.encryptedImageDisplayed(encryptedImageDisplayed)	// output
	);

	vga_adapter VGA(
		.resetn(SW[15]),
		.clock(clock),
		.colour(pixel),
		.x(gnd),
		.y(gnd),
		.memory_from_grouper(VGAAddress),
		.plot(writeEnable),
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




module frequency_divider(clk,rst,clk_out); // debug code: , counter);
	input clk,rst;
	// clk is the original clk
	output reg clk_out;	// desired clk 

	// factor = original frequency / (2 x desired frequency) - 1
	parameter factor = 28'd6249999; 
//	parameter factor = 28'd24999999; 	
	// keep factor bitsize divisible by 4, just in case you want hex
	// bitsize = n + n mod 4   ....n + remainder of n/4
	
	parameter n = 25; // #of bits required to hold factor
						// be exact here, no less and no more

	reg [n-1:0]counter;
// output reg [n-1:0]counter;	// debug code 

	always @(posedge clk)
	begin
		if(rst)	begin 		// synchronous reset
			counter <= 28'd0;	// see comment at factor
//			counter <= 12'd24990;  // debug code
			clk_out <= 1'b0;
		end
		else if(counter==factor)begin
			counter <= 28'd0;	// see comment at factor
			clk_out <= ~clk_out;
		end
		//	//	//	//
		else
		counter <= counter+1;
	end
endmodule 

module ImageGenerator
(
  resetN, 
  clock, 
  userEnable,
  readyToBeProcessed,
  encryptedSubmatrixElements,
  processed, 
  address, 
  pixel,
  writeEnable,
  encryptedImageDisplayed
 );
	
	input resetN, clock, readyToBeProcessed;
	input [15:0] encryptedSubmatrixElements;
	input userEnable;
	output processed;
	output [2:0] pixel;
	output [14:0] address;
	output writeEnable; 
	output reg encryptedImageDisplayed; //Indicates when the entire decrypted image has been outputted to the screen

	wire loaded; 			// Indicates when grouper is loaded with 3 elements
	wire delayedLoaded;		// pragmatic fix to bug that early signals writeEnable
							// STILL DOES NOT WORK :(
	wire enable = userEnable && readyToBeProcessed && !encryptedImageDisplayed
					&& !processed ; //Module is enabled when user enables the circuit
	
	wire vcc, gnd, highImpedence; 
	assign vcc = 1;	assign gnd = 0;

	assign writeEnable = loaded & enable; // & ~processed & delayedLoaded; 

	always@(posedge clock)
	begin
		if(!resetN) //If reset or idle, reset the appropriate ports
		begin
			if(!resetN)
			begin
				encryptedImageDisplayed <= 0;
			end
		end
		
		else
			encryptedImageDisplayed <= (address == 15'd19199); //Finished uploading last pixel
//			encryptedImageDisplayed <= (loaded && (address == 15'd19199)); //Finished uploading last pixel
	end
	
	threeDelay delayit(enable, clock, delayedLoaded); 

	//Turns the 16 bit output from the Submatrix module into a stream of bits //Essentially the opposite of a Grouper
	ShiftRegister elementsToAddToImage
	(
		.resetN(resetN),
		.clock(clock),
		.enable(enable),
		.shiftRight (vcc),
		.loadParallelly (dataLoadControllerCount==0), //Loads at the beginning of the count
		.serialLoad (gnd),
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
	defparam pixelGrouper.groupSize = 3;

	wire [4:0] dataLoadControllerCount;

	Counter dataLoadController //Controls when elementsToAddToImage accepts new data from Submatrix
	(
		.resetN(resetN),
		.clock(clock),
		.enable(enable),
		.count(dataLoadControllerCount)
	);
	defparam
	dataLoadController.counterSize = 5, //17 counts per cycle- 1 for data load and 16 to output data
	dataLoadController.countLimit = 16;

	assign processed = userEnable & (dataLoadControllerCount == 16); //Entire cycle has been completed

	// This addressTraverser is bugged somehow.
	// check the enable
	Counter addressTraverser //Increments once every three clock ticks; equivalently, increments every time Grouper finishes inserting a pixel into the RAM
	(
		.resetN(resetN),
		.clock(clock),
		.enable(loaded),		
		.count(address)		
	);

endmodule 


module threeDelay(resetn, clk,  delaythree);
	input clk, resetn;	// active low reset
//	input [2:0] raw;
//	output reg [2:0] outs;
	output reg delaythree;
	
	reg [1:0]counter; 
	
	
	always@(posedge clk)
	begin 
		if (!resetn) begin 
			counter <= 2'b0;
			delaythree <= 0;
		end 
		else begin 
			counter <= counter + 2'b01;
			delaythree <= 0;
		end 
		
		if (counter[0] & counter[1]) begin 
	//		outs <= raw;
			delaythree <=1;
		end 
	end 

endmodule 

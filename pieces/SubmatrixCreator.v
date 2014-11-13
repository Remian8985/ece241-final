module SubmatrixCreator (clk, enable, resetn, readyToBeLoaded, dataOut, loaded);
	
	input clk, enable, resetn, readyToBeLoaded;

	output loaded;
	output	[15:0]	dataOut;

	wire [15:0]	memAddress;
	wire bitStream;				// Connects the output of ROM to Grouper


	wire enableActual; 
	assign enableActual = enable & readyToBeLoaded;

	Master_counter MC(
		.clk(clk), 
		.enable(enableActual), 
		.resetn(resetn), 
		.memAddress(memAddress)				// Counts memory addresses for the ROM
		);

	Grouper(
		.clk(clk), 
		.enable(enableActual), 				// yeah
		.resetn(resetn), 
		.stream(bitStream), 				// output from ROM
		.readyToBeLoaded(readyToBeLoaded), 	// comes from top level of THIS module
		.loaded(loaded), 					// output, it will go out of SubmatrixCreator as well
		.dataOutput(dataOut)				// 16 bit output, grouped together
		);

	OriginalImage	OriginalImage_inst (
	.address ( memAddress ),
	.clock ( clk ),
	.q ( bitStream )						// stream of 1bit values for the grouper
	);										// it should be stuck at a value when Master_counter is not counting



	// memory initialization needed 
	// output of ram is bitStream
	// input of ram is clk and address 



endmodule 
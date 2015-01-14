module SubmatrixCreator (clk, enable, resetn, readyToBeLoaded, dataOut, loaded);
	
	input clk, enable, resetn, readyToBeLoaded;

	output loaded;
	output	[15:0]	dataOut;

	wire [15:0]	memAddress;
	wire bitStream;


	wire enableActual; 
	assign enableActual = enable & readyToBeLoaded;

	Master_counter MC(
		.clk(clk), 
		.enable(enableActual), 
		.resetn(resetn), 
		.memAddress(memAddress)
		);

	Grouper(
		.clk(clk), 
		.enable(enableActual), 
		.resetn(resetn), 
		.stream(bitStream), 
		.readyToBeLoaded(readyToBeLoaded), 	// comes from top level of THIS module
		.loaded(loaded), 					// output, it will go out of SubmatrixCreator as well
		.dataOutput(dataOut)				// 16 bit output, grouped together
		);



	// memory initialization needed 
	// output of ram is bitStream
	// input of ram is clk and address 



endmodule 
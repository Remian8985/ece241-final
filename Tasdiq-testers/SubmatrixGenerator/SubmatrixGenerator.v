module SubmatrixGenerator 
(	
	enable,
	address,
	element,

	clock,
	resetN, 
	userEnable, 
	readyToBeLoaded, 
	loaded, 
	submatrixElements,
);

	input resetN;
	input userEnable;
	input clock;
	input readyToBeLoaded;
	output loaded;
	output	[15:0]	submatrixElements;

	output enable;
assign enable	= userEnable & readyToBeLoaded;
	output	[15:0]	address;
	output element;

	//Used to traverse through elements in ROM
	Counter addressTraverser 
	(
		.resetN(resetN),
		.clock(clock),
		.enable(enable),
		.count(address)
	);

	//ROM that contains original image/
	/*
	OneBitWordImage originalImage(
		.address (address),
		.clock (clock),
		.q (element)
		);
	*/	
	newROM	newROM_inst (
	.address ( address ),
	.clock ( clock ),
	.q ( element )
	);


	reg delayedEnable; //Used to delay submatrixGrouper's enable by one clock edge since the output of the ROM takes a clock edge to become defined

	always@(posedge clock)
	begin
		delayedEnable <= enable; 
	end

	//Groups elements from ROM and outputs the group
	Grouper submatrixGrouper 
	(
		.resetN(resetN),
		.clock(clock),
		.enable(delayedEnable),
		.element(element),
		.loaded(loaded),			//output
		.groupedElements(submatrixElements)
	);

endmodule 

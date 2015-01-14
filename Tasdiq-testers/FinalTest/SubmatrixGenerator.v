module SubmatrixGenerator 
(
	resetN, 
	userEnable, 
	clock, 
	readyToBeLoaded, 
	loaded, 
	submatrixElements
);

input resetN;
input userEnable;
input clock;
input readyToBeLoaded;
output loaded;
output reg [15:0] submatrixElements;

wire enable = userEnable && readyToBeLoaded;
wire address;
wire element;

//Used to traverse through elements in ROM
Counter addressTraverser 
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.count(address)
);

//ROM that contains original image
OneBitWordImage orignalImage(
	.address (address),
	.clock (clock),
	.q (element)
	);

//Groups elements from ROM and outputs the group
Grouper submatrixElementGrouper 
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.element(element),
	.loaded(loaded),
	.groupedElements(submatrixElements)
);

endmodule

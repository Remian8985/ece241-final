module SubmatrixGenerator 
(
	resetN, 
	userEnable, 
	clock, 
	readyToBeLoaded, 
	loaded, 
	submatrixElements,
	addressTest,
	elementTest,
	enableTest,
	enableDelayTest
);

parameter counterSize = 16;

input resetN;
input userEnable;
input clock;
input readyToBeLoaded;
output loaded;
output  [15:0] submatrixElements;
output	[15:0]	 addressTest;
output elementTest;
output enableTest;
output enableDelayTest;

wire enable = userEnable & readyToBeLoaded;
wire	[counterSize-1:0]	 address;
wire element;

assign addressTest[15:0] = address[15:0];
assign elementTest = element;
assign enableTest  = enable;
assign enableDelayTest = delayedEnable;

//Used to traverse through elements in ROM
Counter addressTraverser 
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.count(address)
);

// ROM that contains original image
OriginalImage	OriginalImage_inst (
	.address ( address ),
	.clock ( clock ),
	.q ( element )
	);

//ROM that contains original image
//OneBitWordImage orignalImage(
//	.address (address),
//	.clock (clock),
//	.q (element)
//	);


reg delayedEnable; //Used to delay submatrixGrouper's enable by one clock edge since the output of the ROM takes a clock edge to become defined

always@(posedge clock)
begin
	if (!resetN)
		delayedEnable = 0;
	else 
		delayedEnable = enable; 
end

//Groups elements from ROM and outputs the group
Grouper submatrixGrouper 
(
	.resetN(resetN),
	.clock(clock),
	.enable(delayedEnable),
	.element(element),
	.loaded(loaded),
	.groupedElements(submatrixElements)
);

endmodule


//module flipflop(D, Q, clk );
//	always@(posedge 
//endmodule 

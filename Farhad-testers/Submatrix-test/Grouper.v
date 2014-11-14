//Receives a stream of 1 bit values as input - groups them into groups of groupSize and outputs the entire group as once
module Grouper (resetN, clock, enable, element, loaded, groupedElements);

parameter groupSize = 16; //Default group size is 16
parameter sizeOfCounterInBits = 4; //Default uses 4 bit counter

input resetN;
input clock;
input enable; 
input element;
output reg loaded;
output reg [groupSize-1:0] groupedElements; 
//output  [groupSize-1:0] groupedElements; 
wire [sizeOfCounterInBits-1:0] elementsRead;
reg [groupSize-1:0] internalRegister; //Used to temporary hold inputted elements
//assign groupedElements = internalRegister;

//Internal counter used to keep track of the number of elements read
Counter elementsReadCounter
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.count(elementsRead),
); 
defparam
elementsReadCounter.counterSize = sizeOfCounterInBits,
elementsReadCounter.countLimit = 15;



always@(posedge clock)
begin
	if (!resetN)
	begin
//		groupedElements <= 0; //Reset everything to zero
		internalRegister <= 0;
		loaded <= 0;
	end
	else if (enable)
	begin
		if (elementsRead < (groupSize -1 )) //If entire internal register hasn't been filled, add the inputted element to the register
		begin
	//		internalRegister [groupSize - 1:1] <= groupedElements;
			internalRegister [groupSize - 1:1] <= internalRegister [groupSize -2:0];
			internalRegister [0] <= element;
			loaded <= 0;
		end
		else
		begin
			groupedElements <= internalRegister; //Update output when all elements of the internal register have been updated
			loaded <= 1;
		end
	end
end
		
endmodule
	
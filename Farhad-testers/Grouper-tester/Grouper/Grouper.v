//Receives a stream of 1 bit values as input - groups them into groups of groupSize and outputs the entire group as once
module Grouper (resetN, clock, enable, element, loaded, groupedElements);

parameter groupSize = 16; //Default group size is 16
parameter sizeOfCounterInBits = 5; //Default uses 4 bit counter

input resetN;
input clock;
input enable; 
input element;
output reg loaded;
output reg [groupSize-1:0] groupedElements; 
//output  [groupSize-1:0] groupedElements; 
wire [sizeOfCounterInBits-1:0] elementsRead;

//Serial and parallel output of internal reg
wire serialRegOutput;
assign serialRegOutput = 0;
wire [sizeOfCounterInBits-1:0] parallelRegOutput;
wire shifterEnable, gnd; 
assign shifterEnable = enable & (elementsRead < 5'd16); 
assign gnd = 0;

wire [sizeOfCounterInBits -1:0] parallelLoad;

ShiftRegister internalRegister
(
	.resetN(resetN),
	.clock(clock),
	.enable(shifterEnable),
	.resetValue (gnd),
	.shiftRight (gnd),
	.loadParallelly (gnd),
	.serialLoad (element),
	.parallelLoad(parallelLoad),
	.serialOutput(serialRegOutput),
	.parallelOutput(parallelRegOutput)
);
defparam
internalRegister.registerSize = (groupSize -1);

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
	if (~resetN)
	begin
		groupedElements <= 0; //Reset everything to zero
		loaded <= 0;
	end
	else if (enable)
	begin
		if (elementsRead < (groupSize - 1)) //If entire internal register hasn't been filled, set the "loaded" signal to 0
		begin
			loaded <= 0;
		end
		else
		begin
			groupedElements <= parallelRegOutput; //Update output when all elements of the internal register have been updated
			loaded <= 1;
		end
	end
end
		
endmodule
	
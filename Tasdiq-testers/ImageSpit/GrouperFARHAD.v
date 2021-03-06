//Receives a stream of 1 bit values as input - groups them into groups of groupSize and outputs the entire group as once
module GrouperFARHAD (resetN, clock, enable, element, loaded, groupedElements);

parameter groupSize = 16; //Default group size is 16
parameter sizeOfCounterInBits = 5; //Default uses 5 bit counter

input resetN;
input clock;
input enable; 
input element;
output reg loaded;
output reg [groupSize-1:0] groupedElements; 
reg [sizeOfCounterInBits-1:0] elementsRead;
wire [sizeOfCounterInBits-1:0] count;

//Serial and parallel output of internal reg
wire serialRegOutput;
assign serialRegOutput = 0;
wire [groupSize-1:0] parallelRegOutput;
wire shifterEnable, gnd; 
assign gnd = 0;

wire [groupSize- 1:0] parallelLoad;

ShiftRegisterFARHAD internalRegister
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.resetValue (gnd),
	.shiftRight (gnd),
	.loadParallelly (gnd),
	.serialLoad (element),
	.parallelLoad(parallelLoad),
	.serialOutput(serialRegOutput),
	.parallelOutput(parallelRegOutput)
);
defparam
internalRegister.registerSize = groupSize;

//Internal counter used to keep track of the number of elements read
CounterFARHAD elementsReadCounter
(
	.resetN(resetN),
	.clock(clock),
	.enable(enable),
	.count(count)
); 
defparam
elementsReadCounter.counterSize = sizeOfCounterInBits,
elementsReadCounter.countLimit = groupSize - 1;

always@(posedge clock)
begin
	if (!resetN)
	begin
		groupedElements <= 0; //Reset everything to zero
		loaded <= 0;
		elementsRead <= 0;
	end
	
	else if (!enable)
	begin
		elementsRead <= 0;
		loaded<=0;
	end
		
	else if (enable)
	begin
		elementsRead <= count+1;
		if (elementsRead < groupSize) //If entire internal register hasn't been filled, set the "loaded" signal to 0 //Need to read from 0 to 14 before setting output to internal register
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
	
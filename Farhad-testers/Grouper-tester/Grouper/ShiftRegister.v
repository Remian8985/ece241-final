//Shifts right

module ShiftRegister (resetN, clock, enable, resetValue, shiftRight, loadParallelly, serialLoad, parallelLoad, serialOutput, parallelOutput);
parameter registerSize = 16; //Default size stores 16 bits
input resetN;
input clock;
input enable;
input [registerSize-1:0] resetValue;
input loadParallelly;
input serialLoad;
input [registerSize -1:0] parallelLoad;
input shiftRight;
output reg serialOutput;
output reg [registerSize-1:0] parallelOutput;
integer serialShiftCounter; //Used for shifting

always@(posedge clock)
begin
	if (!resetN)
	begin
		parallelOutput <= resetValue;
	end
	else if (enable)
	begin
		if (loadParallelly) //Load registers parallelly
		begin
			parallelOutput <= parallelLoad;
		end
		else
		begin
			if (shiftRight) //Functioning as a shift left to right counter
			begin
				for (serialShiftCounter = 0; serialShiftCounter < registerSize-1; serialShiftCounter = serialShiftCounter+1)
					parallelOutput [serialShiftCounter] <= parallelOutput [serialShiftCounter+1];
				parallelOutput [registerSize -1] <= serialLoad;
			end
			else if (!shiftRight) //Functioning as a shift 
			begin
				parallelOutput [registerSize -1] <= serialLoad;

				for (serialShiftCounter = registerSize-2; serialShiftCounter >=0; serialShiftCounter = serialShiftCounter-1)
					parallelOutput [serialShiftCounter] <= parallelOutput [serialShiftCounter+1];
			end
		end
	end
	
	if (shiftRight) //Functioning as shift left to right counter
		serialOutput <= parallelOutput [0];

	else if (!shiftRight)
		serialOutput <= parallelOutput [registerSize-1];
end

endmodule
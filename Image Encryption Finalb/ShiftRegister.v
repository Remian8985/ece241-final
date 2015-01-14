module ShiftRegister (resetN, clock, enable, shiftRight, loadParallelly, serialLoad, parallelLoad, serialOutput, parallelOutput);
parameter registerSize = 16; //Default size stores 16 bits
input resetN;
input clock;
input enable;
input loadParallelly;
input serialLoad;
input [registerSize-1:0] parallelLoad;
input shiftRight;
output reg serialOutput;
output reg [registerSize-1:0] parallelOutput;
integer serialShiftCounter; //Used for shifting

always@(posedge clock)
begin
	if (!resetN)
	begin
		parallelOutput <= 0;
		serialOutput <= 0;
	end
	else if (enable)
	begin
		if (loadParallelly) //Load registers parallelly
		begin
			parallelOutput <= parallelLoad;
			
			if (shiftRight)
				serialOutput <= parallelLoad [0];
			else if (!shiftRight)
				serialOutput <= parallelLoad [registerSize-1];
		end
		else
		begin
			if (shiftRight) //Functioning as a shift-left-to-right shift register
			begin
				for (serialShiftCounter = 0; serialShiftCounter < registerSize-1; serialShiftCounter = serialShiftCounter+1)
					parallelOutput [serialShiftCounter] <= parallelOutput [serialShiftCounter+1];

				parallelOutput [registerSize -1] <= serialLoad;
				serialOutput <= parallelOutput [1]; //Set value to the last bit of the *next* parallel input

			end
			else if (!shiftRight) //Functioning as a shift-right-to-left shift register
			begin

				for (serialShiftCounter = registerSize-1; serialShiftCounter >0; serialShiftCounter = serialShiftCounter-1)
					parallelOutput [serialShiftCounter] <= parallelOutput [serialShiftCounter-1];
					
				parallelOutput [0] <= serialLoad;
				serialOutput <= parallelOutput [registerSize-2];
			end
		end
	end
end
endmodule
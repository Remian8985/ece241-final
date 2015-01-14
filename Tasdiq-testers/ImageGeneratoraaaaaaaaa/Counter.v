//16 bit counter with synchronous active low reset 
module Counter (resetN, clock, enable, count);//, do_go_back);

parameter counterSize = 16; //16 bit by default
parameter countLimit = 57599; //By default counts up to 57600
parameter [counterSize-1:0] resetValue = 0;
input resetN;
input clock; 
input enable;
//input do_go_back;
output reg[counterSize-1:0] count;

always@(posedge clock)
begin
	if (!resetN)
		count <= resetValue;

	else if (enable)
	begin
		if (count < countLimit) 
		count <= count+1;
	end
end

endmodule

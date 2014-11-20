//16 bit counter with synchronous active low reset 
module Counter (resetN, clock, enable, count);
parameter counterSize = 16; //16 bit by default
parameter countLimit = 57600; //By default counts up to 57600
parameter resetValue = 0;
input resetN;
input clock; 
input enable;
output reg[counterSize-1:0] count;
always@(posedge clock)
begin
 if (!resetN)
  count <= resetValue;
 else if (enable)
 begin
  if (count < countLimit) 
  count <= count+1;
  
  else
  count <= 0;
 end
end
endmodule


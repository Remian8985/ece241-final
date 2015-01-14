//Modified register used to store a submatrix
//Encryption is performed directly on this register
//"loaded" indicates a new submatrix is ready to be inserted into the register
//"processed" indicates the submatrix has been inserted into the encrypted image
//"encrypted" indicates the submatrix has been replaced with its encrypted version
//"submatrixInput" is used to input new submatrices into the register
//"submatrixOutput" is used to output the current submatrix 
//"readyToBeLoaded" indicates if the current submatrix is ready to be replaced by a new (unencrypted)submatrix
//"readyToBeProcessed" indicates if the submatrix is ready to be inserted into the encrypted image
//"readyToBeEncrypted" indicates the submatrix is ready to be replaced by its encrypted version
module Submatrix
(
	input clock, 
	input resetN, 
	input loaded, 
	input processed, 
	input encrypted, 
	input [15:0] submatrixInput,
	output reg readyToBeLoaded,
	output reg readyToBeProcessed,
	output reg readyToBeEncrypted,
	output reg [15:0] submatrixOutput
);
always@(posedge clock)
begin
	if (!resetN)
	begin
		submatrixOutput <= 0; //If reset, the submatrix empties itself and prepares to accept new input
		readyToBeLoaded <= 1;
		readyToBeProcessed <= 0;
		readyToBeEncrypted <= 0;
	end
	
	else
	begin
		if (loaded) //If new data is ready to be loaded, set the register and then let the submatrix creator know the submatrix isn't currently accepting new data
		begin
			submatrixOutput <= submatrixInput;
			readyToBeLoaded <= 0;
			readyToBeEncrypted <= 1; //The submatrix is ready to be encrypted
			// processed ???
		end
		else if (encrypted) //If the submatrix in the register has been replaced with its encrypted version
		begin
			readyToBeEncrypted <= 0;
			readyToBeProcessed <= 1; //The submatrix is ready to be inserted into the encrypted image
		end
		else if (processed) begin //If the submatrix has been succesfully inserted into the encrypted image
		   readyToBeProcessed <= 0;
		readyToBeLoaded <= 1;
		end 
	end
	
end
endmodule
//Modified register used to store a submatrix
//Encryption is performed directly on this register
//"loaded" indicates a new submatrix is ready to be inserted into the register
//"processed" indicates the submatrix has been inserted into the encrypted image
//"encrypted" indicates the submatrix has been replaced with its encrypted version
//"submatrixElements" is used to input new submatrices into the register
//"submatrixOutput" is used to output the current submatrix 
//"readyToBeLoaded" indicates if the current submatrix is ready to be replaced by a new (unencrypted)submatrix
//"readyToBeProcessed" indicates if the submatrix is ready to be inserted into the encrypted image
//"readyToBeEncrypted" indicates the submatrix is ready to be replaced by its encrypted version
//Rest are various inputs and outputs for other modules (indicated by the name)

module Submatrix
(
	clock, 
	resetN, 
	loaded,  
	encrypted,
	processed,	
	readyToBeLoaded,
	readyToBeProcessed,
	readyToBeEncrypted,
	submatrixGeneratorOutput,
   encryptorOutput,
   encryptorInput,
   imageGeneratorInput
);

	input clock;
	input resetN;
	input loaded;
	input processed;
	input encrypted;
	output reg readyToBeLoaded;
	output reg readyToBeProcessed;
	output reg readyToBeEncrypted;

	input		[15:0]	submatrixGeneratorOutput;
	input 		[15:0]	encryptorOutput;
	output reg	[15:0]	encryptorInput;
	output reg	[15:0]	imageGeneratorInput;

	always@(posedge clock)
	begin
		if (!resetN)
		begin
			encryptorInput <= 0; //If reset, the submatrix empties itself and prepares to accept new input
			imageGeneratorInput<=0;
			readyToBeLoaded <= 1;
			readyToBeProcessed <= 0;
			readyToBeEncrypted <= 0;
		end
		
		else
		begin
			if (loaded == 1) //If new data is ready to be loaded, set the register and then let the submatrix creator know the submatrix isn't currently accepting new data
			begin
				encryptorInput <= submatrixGeneratorOutput;
				readyToBeLoaded <= 0;
				readyToBeEncrypted <= 1; //The submatrix is ready to be encrypted
			end
			if (encrypted == 1) //If the submatrix in the register is ready to be replaced with its encrypted version
			begin
				imageGeneratorInput <= encryptorOutput;
				readyToBeEncrypted <= 0;
				readyToBeProcessed <= 1; //The submatrix is ready to be inserted into the encrypted image
			end
			if (processed == 1) //If the submatrix has been succesfully inserted into the encrypted image
			begin
			   readyToBeProcessed <= 0;
				readyToBeLoaded <= 1;
			end
		end
		
	end
endmodule 

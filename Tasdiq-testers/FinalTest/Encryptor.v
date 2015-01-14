//"readyToBeEncryped" indicates the encryptor needs to encrypt new data available at its input ports
//"encrypted" indicates the encryptor has completed encrypting the data available at its input ports

module Encryptor
(	
	clock,
	resetN,
	readyToBeEncrypted,
	dataToEncrypt,
	encrypted,
	encryptedData
);

input clock;
input resetN;
input readyToBeEncrypted;
input [15:0] dataToEncrypt;
output reg encrypted;
output reg [15:0] encryptedData;

always @(posedge clock)
begin
	if (!resetN || !readyToBeEncrypted)
	begin
		encrypted <= 0; //If reset or idle, set output ports to zero
		encryptedData <= 0;
	end
	
	else if (readyToBeEncrypted) //If the submatrix is ready to be encrypted
	begin
		encryptedData <= dataToEncrypt; //No encryption is currently done
		encrypted <= 1; //Indicates encryption is completed
	end
end
endmodule
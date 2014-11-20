
#include <cstdlib> 
#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
using namespace std;


int main()
{
	ifstream in_stream;
//	ofstream out_stream;

	in_stream.open("input.txt");
//	out_stream.open("outfile.txt");

	string check;


	int num = -1;
	int address = -1;
	cin >> address;
	cout << address << " :    " ; 
	while (!in_stream.eof() && address >= 0){
		in_stream >> check; 
		if (check == ";") {
			cin >> address;
			cout << "; \n" << address << " :    " ; 
		}
		else {
			cout << " " << check << " " ;
		}
	}


	return 0;
}
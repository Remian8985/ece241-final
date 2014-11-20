
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

	in_stream.open("output.txt");
//	out_stream.open("outfile.txt");

	int address;
	string line;
//	getline(cin, line);

	while(!cin.eof() && !in_stream.eof()){
		getline(cin, line);
		in_stream >> address;
		cout << address << "         ";
		cout << line << endl;
	}
	return 0;
}
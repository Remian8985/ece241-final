
#include <cstdlib> 

#include <iostream>
#include <string>
#include <sstream>
using namespace std;


int main()
{/*
	ifstream in_stream;
	ofstream out_stream;

	in_stream.open("sample.txt");
	out_stream.open("outfile.txt");

	string check;
	*/
	int num = -1;
	while (!cin.eof()){
		cin >> num; 
		num = num * 3;
		cout << num << endl;
	}


	return 0;
}
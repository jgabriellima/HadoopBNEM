/*
 * dai_mapreduce.h
 *
 *  Created on: Apr 24, 2012
 *      Author: erik reed
 */

#ifndef DAI_MAPREDUCE_H_
#define DAI_MAPREDUCE_H_

#include <dai/alldai.h>
#include <iostream>
#include <fstream>
#include <string>
#include <fstream>
#include <math.h>
#include <stdio.h>
#include <algorithm>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/string.hpp>
#include <boost/format.hpp>

using namespace std;
using namespace dai;

const string INF_TYPE = "JTREE";
const Real LIB_EM_TOLERANCE = 1e-9;
const size_t EM_MAX_ITER = 1000;

// ALEM (Saluja et al) parameters
const size_t pop_size = 10; // i.e. EMruns, denoted N
const size_t numLayers = 4;
const double agegap = 2; // denoted a
const bool verbose = false;
// end ALEM parameters

struct EMdata {
	string emFile;
	string fgFile;
	string tabFile;
	size_t iter;
	Real likelihood;
	Real lastLikelihood;
	vector<MaximizationStep> msteps;
	int bnID;


	// TODO: optimize serialization
	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & ar, const unsigned int version) {
		ar & emFile;
		ar & fgFile;
		ar & tabFile;
		ar & iter;
		ar & likelihood;
		ar & lastLikelihood;
		ar & msteps;
		ar & bnID;
	}

	bool isConverged() {
	    if( iter >= EM_MAX_ITER )
	        return true;
	    else if( iter < 3 )
	        // need at least 2 to calculate ratio
	        // Also, throw away first iteration, as the parameters may not
	        // have been normalized according to the estimation method
	        return false;
	    else {
	        if( lastLikelihood == 0 )
	            return false;
	        Real diff = likelihood - lastLikelihood;
	        if( diff < 0 ) {
	            cerr << "Error: in EM log-likehood decreased from " << lastLikelihood << " to " << likelihood << endl;
	            return true;
	        }
	        return (diff / fabs(lastLikelihood)) <= LIB_EM_TOLERANCE;
	    }
	}
};

string emToString(const EMdata &em) {
	ostringstream s;
	s << scientific;
	boost::archive::text_oarchive oa(s);
	oa << em;
	return s.str();
}

EMdata stringToEM(const string &s) {
	istringstream ss(s);
	boost::archive::text_iarchive ia(ss);
	EMdata em;
	ia >> em;
	return em;
}

string convertInt(int number) {
	stringstream ss;//create a stringstream
	ss << number;//add number to the stream
	return ss.str();//return a string with the contents of the stream
}

string readFile(const char* path) {

	int length;
	char * buffer;

	ifstream is;
	is.open(path, ios::binary);

	// get length of file:
	is.seekg(0, ios::end);
	length = is.tellg();
	is.seekg(0, ios::beg);
	// allocate memory:
	buffer = new char[length];

	// read data as a block:
	is.read(buffer, length);
	is.close();
	string out = buffer;
	delete[] buffer;
	return out;
}

void str_char_replace(string &s, char from, char to) {
	replace( s.begin(), s.end(), from, to);
}

bool str_replace(string& str, const string& from,
		const string& to) {
	size_t start_pos = str.find(from);
	if (start_pos == string::npos)
		return false;
	str.replace(start_pos, from.length(), to);
	return true;
}

void randomize_fg(FactorGraph* fg) {
	vector<Factor> factors = fg->factors();
	size_t size = factors.size();
	for (size_t i = 0; i < size; i++) {
		Factor f = fg->factor(i);
		f.randomize();
		fg->setFactor(i, f, false);
	}
}

vector<string> &str_split(const string &s, char delim,
		vector<string> &elems) {
	stringstream ss(s);
	string item;
	while (getline(ss, item, delim))
		elems.push_back(item);
	return elems;
}

vector<string> str_split(const string &s, char delim) {
	vector<string> elems;
	return str_split(s, delim, elems);
}

#endif /* DAI_MAPREDUCE_H_ */

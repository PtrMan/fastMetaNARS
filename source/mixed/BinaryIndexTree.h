#pragma once

// https://www.topcoder.com/community/data-science/data-science-tutorials/binary-indexed-trees/
// explaination http://stackoverflow.com/questions/15439233/bitusing-a-binary-indexed-tree

#include <cstddef>
#include <vector>
#include <cassert>
using namespace std;

#include "NumericHelper.h"

// for debugging
#include <iostream>
using namespace std;

template<typename Type>
struct BinaryIndexTree {
	typedef int IndexType; // needs to be a signed type

	void reset() {
		for(IndexType i = 0; i < tree.size(); i++ ) {
			tree[i] = 0;
		}
	}

	void setSize(IndexType size) {
		assert(isPowerOfTwo(size));
		tree.resize(size);
	}

	size_t getMaxVal() {
		return tree.size()-1;
	}

	vector<Type> tree;

	Type read(IndexType idx){
		// negative and 0 index are illegal
		assert(idx >= 1);

	    Type sum = 0;
	    while (idx > 0){
	        sum += tree[idx];
	        idx -= (idx & -idx);
	    }
	    return sum;
	}

	// reads actualy frequency at index
	Type readSingle(IndexType idx) {
		// negative and 0 index are illegal
		assert(idx >= 1);

		Type sum = tree[idx]; // sum will be decreased
		if (idx > 0) { // special case
			int z = idx - (idx & -idx); // make z first
			idx--; // idx is no important any more, so instead y, you can use idx
			while (idx != z) { // at some iteration idx (y) will become z
				sum -= tree[idx];
				// substruct tree frequency which is between y and "the same path"
				idx -= (idx & -idx);
			}
		}
		return sum;
	}

	void update(IndexType idx, Type val){
		// negative and 0 index are illegal
		assert(idx >= 1);

		cout << "BinaryIndexTree.h : update() index=" << idx << " value=" << val << endl;

	    while (idx <= getMaxVal()){
	        tree[idx] += val;
	        idx += (idx & -idx);
	    }
	}

	/*
	IndexType find(Type cumFre, bool &found) {
		found = false;

		int bitMask = 1 << integerLog(getMaxVal());

		Type currentValue = tree[bitMask];

		Type rightCandidate = currentValue + tree[bitMask | bitMask >> 1];


	}*/

	enum class EnumFindType {
		EXACT,
		ABOVE
	};
	
	// TODO< if mode is nonexact, go down the tree as long as the value stays equal, if it gets less return the previous result >

	// if in tree exists more than one index with a same
	// cumulative frequency, this procedure will return 
	// some of them (we do not know which one)
	IndexType find(Type cumFre, bool &found, EnumFindType findType = EnumFindType::EXACT){
		found = false;

		// bitMask - initialy, it is the greatest bit of MaxVal
		// bitMask store interval which should be searched
		int bitMask = 1 << integerLog(getMaxVal());
		
		IndexType index = 0; // this var is result of function
	    
	    while ((bitMask != 0) && (index < getMaxVal())){ // nobody likes overflow :)
			IndexType tIndex = index + bitMask; // we make midpoint of interval
			if (cumFre == tree[tIndex]) {
				// if it is equal, we just return index, only if we return exact values
				// because if we would not do the findType == EnumFindType::EXACT test it would point us to the half where it didn't match jet
				if (findType == EnumFindType::EXACT) {
					found = true;
					return tIndex;
				}
			}
	        else if (cumFre > tree[tIndex]){
	                // if tree frequency "can fit" into cumFre,
	                // then include it
				index = tIndex; // update index 
	            cumFre -= tree[tIndex]; // set frequency for next loop 
	        }
	        bitMask >>= 1; // half current interval
	    }
		if (cumFre != 0) {
			// if we are here then its not an exact result

			if (findType == EnumFindType::EXACT) {
				return -1;
			}
			else {
				found = true;
				return index;
			}
		}
	    else {
	    	found = true;
	        return index;
	    }
	}

};

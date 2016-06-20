#pragma once

// https://www.topcoder.com/community/data-science/data-science-tutorials/binary-indexed-trees/

#include <cstddef>
#include <vector>
#include <cassert>
using namespace std;

#include "NumericHelper.h"

template<typename Type>
struct BinaryIndexTree {
	void reset() {
		for( size_t i = 0; i < tree.size(); i++ ) {
			tree[i] = 0;
		}
	}

	void setSize(size_t size) {
		assert(isPowerOfTwo(size));
		tree.resize(size);
	}

	size_t getMaxVal() {
		return tree.size()-1;
	}

	vector<Type> tree;

	Type read(size_t idx){
	    Type sum = 0;
	    while (idx > 0){
	        sum += tree[idx];
	        idx -= (idx & -idx);
	    }
	    return sum;
	}

	// reads actualy frequency at index
	Type readSingle(size_t idx) {
		Type sum = tree[idx]; // sum will be decreased
		if (idx > 0) { // special case
			int z = static_cast<int>(idx) - (static_cast<int>(idx) & -static_cast<int>(idx)); // make z first
			idx--; // idx is no important any more, so instead y, you can use idx
			while (idx != z) { // at some iteration idx (y) will become z
				sum -= tree[idx];
				// substruct tree frequency which is between y and "the same path"
				idx -= (idx & -idx);
			}
		}
		return sum;
	}

	void update(size_t idx, Type val){
	    while (idx <= getMaxVal()){
	        tree[idx] += val;
	        idx += (idx & -idx);
	    }
	}

	// if in tree exists more than one index with a same
	// cumulative frequency, this procedure will return 
	// some of them (we do not know which one)
	size_t find(Type cumFre, bool &found){
		found = false;

		// bitMask - initialy, it is the greatest bit of MaxVal
		// bitMask store interval which should be searched
		int bitMask = 1 << integerLog(getMaxVal());
		
	    size_t idx = 0; // this var is result of function
	    
	    while ((bitMask != 0) && (idx < getMaxVal())){ // nobody likes overflow :)
	        size_t tIdx = idx + bitMask; // we make midpoint of interval
	        if (cumFre == tree[tIdx]) // if it is equal, we just return idx
	            return tIdx;
	        else if (cumFre > tree[tIdx]){ 
	                // if tree frequency "can fit" into cumFre,
	                // then include it
	            idx = tIdx; // update index 
	            cumFre -= tree[tIdx]; // set frequency for next loop 
	        }
	        bitMask >>= 1; // half current interval
	    }
	    if (cumFre != 0) // maybe given cumulative frequency doesn't exist
	        return -1;
	    else {
	    	found = true;
	        return idx;
	    }
	}

};

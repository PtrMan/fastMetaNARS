#pragma once


#include "StaticBitset.h"
#include "Hash.h"


template<size_t NumberOfBits, typename ValueType>
struct Bloomfilter {
	void set(ValueType value) {
		// for all hash functions
		setBit(bloomHash1(value));
	}

	bool test(ValueType value) {
		bool isSet = true;

		// for all hash functions
		isSet &= checkBit(bloomHash1(value));

		return isSet;
	}

	void reset() {
		filter.reset();
	}

	static bool overlap(Bloomfilter<NumberOfBits, ValueType> a, Bloomfilter<NumberOfBits, ValueType> b) {
		return StaticBitset<NumberOfBits>::existsOverlap(a.filter, b.filter);
	}

	static Bloomfilter<NumberOfBits, ValueType> union_(Bloomfilter<NumberOfBits, ValueType> a, Bloomfilter<NumberOfBits, ValueType> b) {
		Bloomfilter<NumberOfBits, ValueType> result;
		result.filter = StaticBitset<NumberOfBits>::or_(a.filter, b.filter);
		return result;
	}

protected:
	void setBit(size_t index) {
		filter.set(index % NumberOfBits, true);
	}

	bool checkBit(size_t index) {
		return filter.get(index % NumberOfBits);
	}

	static uint32_t bloomHash1(uint32_t x) {
		return hash_(x);
	}

	StaticBitset<NumberOfBits> filter;
};

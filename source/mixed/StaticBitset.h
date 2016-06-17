#pragma once

#include "TemplateHelper.h"

template<size_t NumberOfBits>
struct StaticBitset {
	StaticBitset() {
		reset();
	}

	void reset() {
		for (size_t i = 0; i < elmentsOfArray(array); i++) {
			array[i] = 0;
		}
	}

	static StaticBitset or_(StaticBitset a, StaticBitset b) {
		StaticBitset result;
		for (size_t i = 0; i < elmentsOfArray(result.array); i++) {
			result.array[i] = a.array[i] | b.array[i];
		}
		return result;
	}

	static bool existsOverlap(StaticBitset a, StaticBitset b) {
		StaticBitset result;
		for (size_t i = 0; i < elmentsOfArray(result.array); i++) {
			if (a.array[i] & b.array[i]) {
				return true;
			}
		}
		return false;
	}


	bool get(size_t bitIndexParameter) {
		size_t arrayIndex = bitIndexParameter / NUMBEROFBITSFORMACHINEWORD;
		size_t bitIndex = bitIndexParameter % NUMBEROFBITSFORMACHINEWORD;
		return array[arrayIndex] & (1 << bitIndex);
	}

	void set(size_t bitIndexParameter, bool value) {
		size_t arrayIndex = bitIndexParameter / NUMBEROFBITSFORMACHINEWORD;
		size_t bitIndexInWord = bitIndexParameter % NUMBEROFBITSFORMACHINEWORD;

		size_t negationMask = ~(1 << bitIndexInWord);

		if (value) {
			array[arrayIndex] |= (1 << bitIndexInWord);
		}
		else {
			array[arrayIndex] = array[arrayIndex] & negationMask;
		}
	}

	static const size_t NUMBEROFBITSFORMACHINEWORD = sizeof(size_t) * 8;

	size_t array[NumberOfBits / (NUMBEROFBITSFORMACHINEWORD)+1]; // TODO< remove +1 if modulo is zero >
};

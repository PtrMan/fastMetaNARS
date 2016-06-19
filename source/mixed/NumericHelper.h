#pragma once

#include <cstdint>
#include <cstddef>


// https://graphics.stanford.edu/~seander/bithacks.html#IntegerLog
unsigned integerLog(uint32_t v) {
	const uint32_t b[] = {0x2, 0xC, 0xF0, 0xFF00, 0xFFFF0000};
	const uint32_t S[] = {1, 2, 4, 8, 16};

	unsigned r = 0; // result of log2(v) will go here
	for (int i = 4; i >= 0; i--) {
	  if (v & b[i]) {
	    v >>= S[i];
	    r |= S[i];
	  }
	}
	return r;	
}

// https://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
bool isPowerOfTwo(uint32_t v) {
	return v && !(v & (v - 1));
}

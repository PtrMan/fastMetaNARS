#pragma once

#include <array>
#include <cstring>

#include "Bloomfilter.h"

/**
* A stamp like in the classic NARS which contains the stamp history (as TermIdType values) and a bloomfilter for the values
*/
template<size_t NumberOfElements, size_t BloofilterNumberOfBits>
struct DualStamp {
	DualStamp() {
		used = 0;
	}

	void insertAtFront(vector<TermIdType> termIds) {
		size_t newUsed = min(used + termIds.size(), termIdHistory.size());

		// push the old values to the back
		memmove(&termIdHistory[termIds.size()], &termIdHistory, (termIdHistory.size() - termIds.size()) * sizeof(TermIdType));

		for (size_t i = 0; i < termIds.size(); i++) {
			termIdHistory[i] = termIds[i];
		}

		bool sizeDidntChange = newUsed == used;
		if (sizeDidntChange) {
			recalcBloomfilter(newUsed);
		}
		else {
			addToBloomfilter(termIds);
		}
	}

	size_t used;
	array<TermIdType, NumberOfElements> termIdHistory;
	Bloomfilter<BloofilterNumberOfBits, TermIdType> bloomfilter;
protected:
	void recalcBloomfilter(size_t newSize) {
		bloomfilter.reset();

		for (size_t i = 0; i < newSize; i++) {
			bloomfilter.set(termIdHistory[i]);
		}
	}

	void addToBloomfilter(vector<TermIdType> termIds) {
		for (size_t i = 0; i < termIds.size(); i++) {
			bloomfilter.set(termIds[i]);
		}
	}
};

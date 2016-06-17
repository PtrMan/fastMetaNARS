#pragma once

#include <array>
#include <cstring>

#include "Bloomfilter.h"
#include "TermId.h"

/**
* A stamp like in the classic NARS which contains the stamp history (as TermIdType values) and a bloomfilter for the values
*/
template<size_t NumberOfElements, size_t BloofilterNumberOfBits>
struct DualStamp {
	typedef Bloomfilter<BloofilterNumberOfBits, TermId::TermIdType> BloomfilterType;

	DualStamp() {
		used = 0;
	}

	void insertAtFront(vector<TermId> termIds) {
		size_t newUsed = min(used + termIds.size(), termIdHistory.size());

		// push the old values to the back
		memmove(&termIdHistory[termIds.size()], &termIdHistory, (termIdHistory.size() - termIds.size()) * sizeof(TermId::TermIdType));

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

	static bool collide(DualStamp<NumberOfElements, BloofilterNumberOfBits> a, DualStamp<NumberOfElements, BloofilterNumberOfBits> b) {
		return
			collideByBloomfilter(a, b) && // fast rejection by checking if the bits overlap, if at least one bit does overlap it could overlap
			collideIterateHistoryAndCheckBloomfilter(a, b) &&
			collideIterateHistorySlow(a, b);
	}
protected:
	size_t used;
	array<TermId, NumberOfElements> termIdHistory;
	BloomfilterType bloomfilter;
	
	void recalcBloomfilter(size_t newSize) {
		bloomfilter.reset();

		for (size_t i = 0; i < newSize; i++) {
			bloomfilter.set(termIdHistory[i]);
		}
	}

	void addToBloomfilter(vector<TermId> termIds) {
		for (size_t i = 0; i < termIds.size(); i++) {
			bloomfilter.set(termIds[i]);
		}
	}

	// returns if the two bloomfilter (can) collide by checking if bits of the bloomfilters overlap
	static bool collideByBloomfilter(DualStamp a, DualStamp b) {
		return BloomfilterType::overlap(a.bloomfilter, b.bloomfilter);
	}

	// iterates over the termIdHistory of the stamp with the least number of entries and checks in the bloomfilter of the other if the bit is set
	static bool collideIterateHistoryAndCheckBloomfilter(DualStamp a, DualStamp b) {
		if (a.used < b.used) {
			return collideIterateHistoryAndCheckBloomfilterHelper(a, b);
		}
		else {
			return collideIterateHistoryAndCheckBloomfilterHelper(b, a);
		}
	}
	
	// iterates over the termIdHistory of a and checks if the coresponding entry in b in the bloomfilter is set
	static bool collideIterateHistoryAndCheckBloomfilterHelper(DualStamp a, DualStamp b) {
		assert(a.used <= NumberOfElements);

		for (size_t i = 0; i < a.used; i++) {
			TermId aTermId = a.termIdHistory[i];
			bool isSetInB = b.bloomfilter.test(aTermId.value);
			if (isSetInB) {
				return true;
			}
		}

		return false;
	}

	// ASK PATRICK< is this algorithm right to check all n to n or should we just check for common sequences? >
	static bool collideIterateHistorySlow(DualStamp a, DualStamp b) {
		assert(a.used <= NumberOfElements);
		assert(b.used <= NumberOfElements);

		for (size_t ia = 0; ia < a.used; ia++) {
			for (size_t ib = 0; ib < b.used; ib++) {
				TermId aTermId = a.termIdHistory[ia];
				TermId bTermId = b.termIdHistory[ib];
				if (aTermId.value == bTermId.value) {
					return true;
				}
			}
		}

		return false;
	}
};

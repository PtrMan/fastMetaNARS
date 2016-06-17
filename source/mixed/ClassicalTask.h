#pragma once

#include "DualStamp.h"
#include "UnifiedTermIndex.h"
#include "PathDescriptor.h"

const unsigned STAMP_NUMBEROFELEMENTS = 2 * 10;
const unsigned STAMP_BLOOMFILTERNUMBEROFBITS = 64 * 20;

struct ClassicalTask {
	UnifiedTermIndex unifiedTerm;

	// contains the path we have to go through the Terms from the term of the concept to get to the term "unifiedTerm"
	vector<PathDescriptor> pathFromConceptToThisTerm;

	// COMMENT PATRICK< every task has a stamp >
	DualStamp<STAMP_NUMBEROFELEMENTS, STAMP_BLOOMFILTERNUMBEROFBITS> stamp;
};

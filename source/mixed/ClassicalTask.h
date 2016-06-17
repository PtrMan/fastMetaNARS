#pragma once

#include "DualStamp.h"
#include "UnifiedTermIndex.h"
#include "Path.h"

const unsigned STAMP_NUMBEROFELEMENTS = 2 * 10;
const unsigned STAMP_BLOOMFILTERNUMBEROFBITS = 64 * 20;

struct ClassicalTask {
	UnifiedTermIndex unifiedTerm;

	// contains all paths we have to go through the Terms from the term of the concept to get to the term "unifiedTerm"
	vector<Path> pathsFromConceptToThisTerm;

	// COMMENT PATRICK< every task has a stamp >
	DualStamp<STAMP_NUMBEROFELEMENTS, STAMP_BLOOMFILTERNUMBEROFBITS> stamp;
};

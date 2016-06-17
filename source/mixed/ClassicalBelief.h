#pragma once

#include "UnifiedTermIndex.h"
#include "Path.h"

struct ClassicalBelief {
	UnifiedTermIndex unifiedTerm;

	// contains all paths we have to go through the Terms from the term of the concept to get to the term "unifiedTerm"
	vector<Path> pathsFromConceptToThisTerm;
};

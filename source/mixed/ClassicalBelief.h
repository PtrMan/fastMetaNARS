#pragma once

#include "UnifiedTermIndex.h"
#include "PathDescriptor.h"

struct ClassicalBelief {
	UnifiedTermIndex unifiedTerm;

	// contains the path we have to go through the Terms from the term of the concept to get to the term "unifiedTerm"
	vector<PathDescriptor> &pathFromConceptToThisTerm;
};

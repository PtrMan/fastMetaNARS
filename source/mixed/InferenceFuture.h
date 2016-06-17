#pragma once

#include <vector>
using namespace std;

#include "UnifiedTerm.h"

// holds the inference results and some other variables  for serialisation after the parallel stage of the inference
struct InferenceFuture {
	// task and beliefs from which the terms got derived
	ClassicalTask *task;
	ClassicalBelief *belief;

	vector<UnifiedTerm> derivedTerms;
};

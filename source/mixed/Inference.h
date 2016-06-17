#pragma once

#include <random>
#include <vector>

using namespace std;

#include "ClassicalConcept.h"
#include "ReasonerInstance.h"
#include "autogen\Deriver.h"
#include "InferenceFuture.h"

struct Inference {
	shared_ptr<vector<InferenceFuture>> sampleConceptsInParallel(vector<shared_ptr<ClassicalConcept>> &concepts, ReasonerInstance &reasonerInstance, mt19937 &gen);

protected:
	void sampleConcept(shared_ptr<ClassicalConcept> concept, float randomValues[2], ReasonerInstance &reasonerInstance, InferenceFuture &destinationInferenceFuture);

	void inference(shared_ptr<ClassicalTask> task, shared_ptr<ClassicalBelief> belief, ReasonerInstance &reasonerInstance, InferenceFuture &destinationInferenceFuture);

	// in own method for more abstraction
	void deriveForPaths(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, InferenceFuture &destinationInferenceFuture);
};

#pragma once

#include <random>
#include <vector>

using namespace std;

#include "ClassicalConcept.h"
#include "ReasonerInstance.h"
#include "autogen\Deriver.h"

struct Inference {
	void sampleConceptsInParallel(vector<shared_ptr<ClassicalConcept>> &concepts, ReasonerInstance &reasonerInstance, mt19937 &gen);

protected:
	void sampleConcept(shared_ptr<ClassicalConcept> concept, float randomValues[2], ReasonerInstance &reasonerInstance);

	void inference(shared_ptr<ClassicalTask> task, shared_ptr<ClassicalBelief> belief, ReasonerInstance &reasonerInstance);

	// in own method for more abstraction
	void deriveForPaths(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices);
};

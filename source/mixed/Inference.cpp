#include "Inference.h"
#include "PathWalker.h"


shared_ptr<vector<InferenceFuture>> Inference::sampleConceptsInParallel(vector<shared_ptr<ClassicalConcept>> &concepts, ReasonerInstance &reasonerInstance, mt19937 &gen) {
	size_t numberOfThreads = concepts.size();

	shared_ptr<vector<InferenceFuture>> inferenceFutures = make_shared<vector<InferenceFuture>>();
	inferenceFutures->reserve(numberOfThreads);
	
	// TODO< parallelize this >
	size_t inferenceFuturesIndex = 0;
	for (auto iterationConcept : concepts) {
		// random numbers need to be generated before entering this

		std::uniform_real_distribution<float> distribution(0, 1);
		float randomValues[2];
		randomValues[0] = distribution(gen);
		randomValues[1] = distribution(gen);

		sampleConcept(iterationConcept, randomValues, reasonerInstance, inferenceFutures->operator[](inferenceFuturesIndex));

		inferenceFuturesIndex++;
	}

	return inferenceFutures;
}

void Inference::sampleConcept(shared_ptr<ClassicalConcept> concept, float randomValues[2], ReasonerInstance &reasonerInstance, InferenceFuture &destinationInferenceFuture) {
	shared_ptr<ClassicalTask> task = concept->tasks.reference(randomValues[0]);
	shared_ptr<ClassicalBelief> belief = concept->beliefs.reference(randomValues[1]);

	// store the task and belief into the inference future for later decomposition
	// SAFE< it must be safe to pull the pointer out of the shared-ptr because at this stage its illegal to modify the bag(s) >
	destinationInferenceFuture.task = task.get();
	destinationInferenceFuture.belief = belief.get();

	inference(task, belief, reasonerInstance, destinationInferenceFuture);
}

void Inference::inference(shared_ptr<ClassicalTask> task, shared_ptr<ClassicalBelief> belief, ReasonerInstance &reasonerInstance, InferenceFuture &destinationInferenceFuture) {
	UnifiedTerm unifiedTermOfTask = reasonerInstance.accessTermByIndex(task->unifiedTerm);
	UnifiedTerm unifiedTermOfBelief = reasonerInstance.accessTermByIndex(belief->unifiedTerm);

	// walk and do inferences for all combinations of all paths of the task and belief
	for (Path& iterationTaskPath : task->pathsFromConceptToThisTerm) {
		vector<UnifiedTermIndex> walkedPathOfTask = PathWalker::walk(reasonerInstance, iterationTaskPath, task->unifiedTerm);

		for (Path& iterationBeliefPath : belief->pathsFromConceptToThisTerm) {
			vector<UnifiedTermIndex> walkedPathOfBelief = PathWalker::walk(reasonerInstance, iterationBeliefPath, belief->unifiedTerm);

			deriveForPaths(reasonerInstance, walkedPathOfTask, walkedPathOfBelief, destinationInferenceFuture);
		}
	}
}

void Inference::deriveForPaths(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, InferenceFuture &destinationInferenceFuture) {
	vector<UnifiedTerm> derivedTerms = derive(reasonerInstance, leftPathTermIndices, rightPathTermIndices, reasonerInstance.configuration.k);

	// add the derived terms to the result
	std::copy(derivedTerms.begin(), derivedTerms.end(), back_inserter(destinationInferenceFuture.derivedTerms));
}

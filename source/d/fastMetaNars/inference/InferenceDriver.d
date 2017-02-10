module inference.InferenceDriver;

import std.random : uniform;

import fastMetaNars.deriver.DeriverCaller;
import fastMetaNars.inference.ConceptTermInserter;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.deriver.DeriverUtils;
import fastMetaNars.entity.ClassicalConcept;
import fastMetaNars.entity.ClassicalTask;

/**
 * (1) select concept, task, belief(wich is a task)
 * 
 * (2) make derivations
 * (3) insert compounds/terms of the derivation results
 * 
 * (4) calculate truth values
 *
 * (5) put results into coresponding concepts/beliefs/tasks
 */
void inferenceStep(ReasonerInstance reasonerInstance) {
	// (1)
	if( reasonerInstance.memory.workingCyclish.concepts.size == 0 ) {
		return;
	}

	ClassicalConcept selectedConcept = reasonerInstance.memory.workingCyclish.concepts.reference();
	if( selectedConcept.tasks.size == 0 ) {
		return;
	}

	ClassicalTask task = selectedConcept.tasks.reference().targetTask;

	// select belief, we select a random belief
	size_t beliefIndex = uniform(0, selectedConcept.beliefs.length);
	ClassicalTask belief = selectedConcept.beliefs[beliefIndex];




	// (2) and (3)
	TemporaryDerivedCompoundWithDecorationAndTruth*[] derivedCompoundTermsWithDecorationAndTruth;
	deriverCaller(reasonerInstance, cast(uint)task.sentence.term.getMaskedOutId, cast(uint)belief.sentence.term.getMaskedOutId, /*out*/derivedCompoundTermsWithDecorationAndTruth, /*insert derived compounds */true);

	// (4)
	// TODO

	// (5)
	insertTermsIntoConcepts(reasonerInstance, derivedCompoundTermsWithDecorationAndTruth);

}

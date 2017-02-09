module inference.InferenceDriver;

import fastMetaNars.deriver.DeriverCaller;
import fastMetaNars.inference.ConceptTermInserter;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.deriver.DeriverUtils;

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
	// TODO< (1) >


	// (2) and (3)
	TemporaryDerivedCompoundWithDecorationAndTruth*[] derivedCompoundTermsWithDecorationAndTruth;
	deriverCaller(reasonerInstance, 0/*TODO*/, 0/*TODO*/, /*out*/derivedCompoundTermsWithDecorationAndTruth, /*insert derived compounds */true);

	// (4)
	// TODO

	// (5)
	insertTermsIntoConcepts(reasonerInstance, derivedCompoundTermsWithDecorationAndTruth);
}


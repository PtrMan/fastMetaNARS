module fastMetaNars.inference.ConceptTermInserter;

import fastMetaNars.deriver.DeriverUtils;
import fastMetaNars.control.WorkingCyclish;
import fastMetaNars.inference.walker.TermWalker;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.entity.ClassicalTask;
import fastMetaNars.entity.ClassicalConcept;
import fastMetaNars.entity.ClassicalSentence;
import fastMetaNars.Term;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;

// inserts the derived terms into the concepts

void insertTermsIntoConcepts(ReasonerInstance reasonerInstance, TemporaryDerivedCompoundWithDecorationAndTruth*[] temporaryDerivedTerms) {
	foreach( iTemporaryDerivedTerm; temporaryDerivedTerms ) {
		insertTermsIntoConceptsForOneTerm(reasonerInstance, iTemporaryDerivedTerm);
	}
}

private void insertTermsIntoConceptsForOneTerm(ReasonerInstance reasonerInstance, TemporaryDerivedCompoundWithDecorationAndTruth* temporaryDerivedTerm) {
	// we just build the task and add it
	// * get the compound term referer
	TermOrCompoundTermOrVariableReferer referedCompound = reasonerInstance.accessCompoundByIndex(temporaryDerivedTerm.derivedCompoundWithDecoration.decoration.compoundIndex).thisTermReferer;
	
	// * build task
	ClassicalSentence createdSentence = ClassicalSentence.makeJudgement(referedCompound, temporaryDerivedTerm.truth);
	reasonerInstance.memory.addNewTask(ClassicalTask.makeFromSentence(createdSentence), "insertTermsIntoConceptsForOneTerm");

	/+ 08.02.2017
	   uncommented because im not sure how to put the tasks back into nars

	TermWalker termWalker;
	termWalker.start(temporaryDerivedTerm);

	for(;;) {
		bool finished;
		RefererOrInterval iterationRefererOrInterval = termWalker.next(/*out*/finished);
		if( finished ) {
			break;
		}

		if( iterationRefererOrInterval.isInterval ) {
			continue; // we ignore intervals here
		}

		Compound insertedCompound = reasonerInstance.getCompoundByIndex(temporaryDerivedTerm.decoration.compoundIndex);
		TermOrCompoundTermOrVariableReferer insertedReferer = insertedCompound.thisTermReferer;



		bool isConceptExist = reasonerInstance.workingCyclish.concepts.contains(iterationRefererOrInterval.referer);
		if( isConceptExist ) {
			addBeliefToCorespondingConcept(reasonerInstance, iterationRefererOrInterval.referer, insertedReferer);
		}
		else {
			createConceptAndAddBelief(reasonerInstance, iterationRefererOrInterval.referer, insertedReferer);
		}
	}
	+/
}

/* uncommented because im not sure how to put the tasks back into nars
private void addBeliefToCorespondingConcept(ReasonerInstance reasonerInstance, TermOrCompoundTermOrVariableReferer referer, TermOrCompoundTermOrVariableReferer insertedReferer) {
	ClassicalConcept concept = reasonerInstance.workingCyclish.concepts.reference(referer);
	assert(concept.term == referer);

	//concept.beliefs.putIn(new ClassicalBelief(insertedReferer));
	assert(false, "TODO");
}

private void createConceptAndAddBelief(ReasonerInstance reasonerInstance, TermOrCompoundTermOrVariableReferer referer, TermOrCompoundTermOrVariableReferer insertedReferer) {
	ClassicalConcept concept = new ClassicalConcept(referer, reasonerInstance.bagBuilder);
	reasonerInstance.workingCyclish.concepts.putIn(concept);

	//.beliefs.putIn(new ClassicalBelief(insertedReferer));
	assert(false, "TODO");
}
*/

module fastMetaNars.TermComparision;

import fastMetaNars.Term;
import fastMetaNars.ReasonerInstance;

// checks if its the same based on structure
// doesn't look at the hashes, bause its used also for the cases when the hashes are the same or if hashes are not jet computed (for ecciciency reasons)
// doesn't look at id's except for atomics
bool isSameByIdsAndStructureRecursivly(ReasonerInstance reasonerInstance, Compound* a, Compound* b) {
	// if the term referer flags are not the same it can't be equal by definition
	if( !TermReferer.isSameWithoutId(a.thisTermReferer, b.thisTermReferer) ) {
		return false;
	}

	if( a.thisTermReferer.isAtomic ) {
		assert(b.thisTermReferer.isAtomic); // because of the above test

		return a.thisTermReferer.getAtomic == b.thisTermReferer.getAtomic;
	}
	else if( !a.thisTermReferer.isSpecial ) {
		assert(!b.thisTermReferer.isSpecial); // because of the above test

		// it is not an atomic so its a compound with a copula

		if( a.flagsOfCopula != b.flagsOfCopula ) {
			// it can't be the same if the copulas are different
			return false;
		}

		if( reasonerInstance.accessTermTupleByIndex(a.termTupleIndex).compoundIndices.length != reasonerInstance.accessTermTupleByIndex(b.termTupleIndex).compoundIndices.length ) {
			return false;
		}

		// check recursivly for all children
		foreach( termTupleIndex ; 0..reasonerInstance.accessTermTupleByIndex(a.termTupleIndex).compoundIndices.length ) {
			size_t iterationChildrenCompoundIndexA = reasonerInstance.accessTermTupleByIndex(a.termTupleIndex).compoundIndices[termTupleIndex];
			size_t iterationChildrenCompoundIndexB = reasonerInstance.accessTermTupleByIndex(b.termTupleIndex).compoundIndices[termTupleIndex];

			Compound* iterationChildrenCompoundA = reasonerInstance.accessCompoundByIndex(iterationChildrenCompoundIndexA);
			Compound* iterationChildrenCompoundB = reasonerInstance.accessCompoundByIndex(iterationChildrenCompoundIndexB);

			if( !isSameByIdsAndStructureRecursivly(reasonerInstance, iterationChildrenCompoundA, iterationChildrenCompoundB) ) {
				return false;
			}
		}

		return true;
	}
	else if( a.thisTermReferer.isDependentVariable ) {
		assert(b.thisTermReferer.isDependentVariable);

		return a.thisTermReferer.getDependentVariable == b.thisTermReferer.getDependentVariable;
	}
	else if( a.thisTermReferer.isIndependentVariable ) {
		assert(b.thisTermReferer.isIndependentVariable);

		return a.thisTermReferer.getIndependentVariable == b.thisTermReferer.getIndependentVariable;
	}
	else {
		throw new Exception("Internal error");
	}
	assert(false, "TODO TODO TODO TODO< comparision of variables >");
}

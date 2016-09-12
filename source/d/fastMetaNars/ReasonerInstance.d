module fastMetaNars.ReasonerInstance;

import fastMetaNars.Term;
import fastMetaNars.ClassicalConcept;
import fastMetaNars.TermReferer;
import fastMetaNars.FlagsOfCopula;

// TODO< pull in real bag! >
// this is just an dummy
class Bag(Type) {}


struct ReasonerInstanceConfiguration {
	float k;
	uint maximalTermComplexity;
}


// contains all information of a reasoner instance
class ReasonerInstance {
	alias size_t CompoundId;

	string[] humanReadableConcepts;

	// compounds describe concepts connected with copula and the references/id's of the children compounds are stored in termTuples
	Compound[] compounds;
	TermTuple[] termTuples;

	CompoundId compoundIdCounter;
	ReasonerInstanceConfiguration configuration;

	Bag!ClassicalConcept concepts;

	final TermTuple* accessTermTupleByIndex(size_t index) {
		assert(index < termTuples.length);
		return &(termTuples[index]);
	}
	
	final Compound* accessCompoundByIndex(size_t index) {
		assert(index < compounds.length);
		return &(compounds[index]);
	}

	static uint getTermComplexityOfCopula(FlagsOfCopula flagsOfCopula) {
		return 1;
	}

	final uint getTermComplexityOfAndByTermReferer(TermReferer termReferer) {
		if( termReferer.isVariable ) {
			return 1;
		}
		else if( !termReferer.isSpecial ) {
			return accessCompoundByIndex(cast(size_t)termReferer.getAtomicOrTerm).termComplexity;
		}
		else {
			throw new Exception("Term referer is not a variable or not special, not handled, is an internal error");
		}
	}

	final string getDebugStringByTermReferer(TermReferer termReferer) {
		return accessCompoundByIndex(cast(size_t)termReferer.getMaskedOutId).getDebugStringRecursive(this);
	}
}

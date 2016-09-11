module fastMetaNars.ReasonerInstance;

import fastMetaNars.Term;

// TODO< pull in real bag! >
// this is just an dummy
class Bag(Type) {}


struct ReasonerInstanceConfiguration {
	float k;
}


// contains all information of a reasoner instance
struct ReasonerInstance {
	// compounds describe concepts connected with copula and the references/id's of the children compounds are stored in termTuples
	Compound[] compounds;
	TermTuple[] termTuples;

	CompoundId compoundIdCounter;
	ReasonerInstanceConfiguration configuration;

	Bag!ClassicalConcept concepts;

	TermTuple* accessTermTupleByIndex(size_t index) {
		assert(index < termTuples.length);
		return &(termTuples[index]);
	}
	
	const Compound &accessCompoundByIndex(UnifiedTermIndex index) const;
}

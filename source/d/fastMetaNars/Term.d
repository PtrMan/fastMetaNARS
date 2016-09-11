module fastMetaNars.Term;

import fastMetaNars.FrequencyCertainty;
import fastMetaNars.ReasonerInstance;

struct Compound {
	enum EnumTermFlags {
		INHERITANCE_TOLEFT = 1, // <--
		INHERITANCE_TORIGHT = 2, // -->
	}

	size_t termTupleIndex;
	uint32_t termFlags; // EnumTermFlags
	TermId termId; // unique id of the term, is not GC'ed

	FrequencyCertainty frequencyCertainty;

	size_t termIndex; // term-gc'ed termIndex of this term
	uint32_t cachedHash;

	final void updateHash(ReasonerInstance reasonerInstance) {
		assert(false, "TODO");
	}

	final TermIndex left(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.termTuples[termTupleIndex];

		assert(dereferencedCompoundTuple.compoundIndices.length == 2, "only valid for binary term tuples");
		return dereferencedCompoundTuple.compoundIndices[0];
	}

	final TermIndex right(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.termTuples[termTupleIndex];

		assert(dereferencedCompoundTuple.compoundIndices.length == 2, "only valid for binary term tuples");
		return dereferencedCompoundTuple.compoundIndices[1];
	}

}

struct TermTuple {
	size_t[] compoundIndices; // term-gc'ed
}

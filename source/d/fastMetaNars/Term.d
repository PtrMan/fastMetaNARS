module fastMetaNars.Term;

import std.stdint;

import fastMetaNars.FrequencyCertainty;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.TermReferer;


struct Compound {
	alias uint64_t CompoundIdType;

	size_t termTupleIndex; // TODO< doesn't have to have a native size, 32 bit are enough >
	FlagsOfCopula flagsOfCopula;
	CompoundIdType compoundId; // unique id of the compound, is not GC'ed

	FrequencyCertainty frequencyCertainty;

	size_t compoundIndex; // compound-gc'ed index
	uint32_t cachedHash;

	final void updateHash(ReasonerInstance reasonerInstance) {
		assert(false, "TODO");
	}

	final TermReferer left(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.compoundIndices.length == 2, "only valid for binary compounds");
		return dereferencedCompoundTuple.compoundIndices[0];
	}

	final TermReferer right(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.compoundIndices.length == 2, "only valid for binary compounds");
		return dereferencedCompoundTuple.compoundIndices[1];
	}
}

struct TermTuple {
	TermReferer[] compoundIndices; // compound-gc'ed
}

module fastMetaNars.Term;

import fastMetaNars.FrequencyCertainty;
import fastMetaNars.ReasonerInstance;

// TODO< TermReferer >
// a term referer can be
// - index of  compound
// - id of variable, can be independent or dependent

struct Compound {
	// 11.09.2016 - this is outdated, we use the bitfield ike in the codegen for the deriver
	enum EnumTermFlags {
		INHERITANCE_TOLEFT = 1, // <--
		INHERITANCE_TORIGHT = 2, // -->
	}

	size_t termTupleIndex; // TODO< doesn't have to have a native size, 32 bit are enough >
	uint32_t termFlags; // EnumTermFlags
	CompoundId compoundId; // unique id of the compound, is not GC'ed

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

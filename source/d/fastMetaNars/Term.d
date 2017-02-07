module fastMetaNars.Term;

import std.stdint;
import std.format;
import std.typecons : Typedef;
import std.algorithm.iteration : map;
import std.array : array;

import fastMetaNars.FrequencyCertainty;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.FlagsOfCopulaConvertToString;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.Interval;



struct Compound {
	alias Typedef!(uint32_t, uint32_t.init, "HashWithCompoundIdType") HashWithCompoundIdType;
	alias Typedef!(uint32_t, uint32_t.init, "HashWithoutCompoundIdType") HashWithoutCompoundIdType;
	

	alias uint64_t CompoundIdType;

	static const uint COMPLEXITYINDEPENDENTVARIABLE = 1;
	static const uint COMPLEXITYDEPENDENTVARIABLE = 1;

	FlagsOfCopula flagsOfCopula;

	CompoundIdType compoundId; // unique id of the compound, is not GC'ed, used for hash calc

	
	TermOrCompoundTermOrVariableReferer thisTermReferer; // term referer describing this compound
	                             // contains the id which is compound-gc'ed

	// uncommented because outdated by thisTermReferer
	//size_t compoundIndex; // compound-gc'ed index


	uint32_t termTupleIndex;

	HashWithCompoundIdType cachedHashWithCompoundId;
	version(DEBUG) bool cachedHashWithCompoundIdValid;

	HashWithoutCompoundIdType cachedHashWithoutCompoundId;
	version(DEBUG) bool cachedHashWithoutCompoundIdValid;

	final void updateHashes() {
		updateHash(false);
		updateHash(true);
	}

	final void updateHash(bool withCompoundId) {
		static void rotate(ref uint32_t hash, uint bits) {
			uint32_t oldHash = hash;
			hash = (oldHash >> bits) | (oldHash << (32 - bits));
		}

		uint32_t hash;
		hash = 0;
		hash ^= termTupleIndex; rotate(hash, 13);
		if( withCompoundId ) {
			hash ^= compoundId; rotate(hash, 13);
		}
		hash ^= flagsOfCopula.asNumberEncoding; rotate(hash, 13);

		if( withCompoundId) {
			cachedHashWithCompoundId = cast(HashWithCompoundIdType)hash;
			version(DEBUG) {
				cachedHashWithCompoundIdValid = true;
			}
		}
		else {
			cachedHashWithoutCompoundId = cast(HashWithoutCompoundIdType)hash;
			version(DEBUG) {
				cachedHashWithoutCompoundIdValid = true;
			}
		}
	}

	// TODO< overhaul so it returns RefererOrInterval >
	final TermOrCompoundTermOrVariableReferer left(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.refererOrIntervals.length == 2, "only valid for binary compounds");
		assert(dereferencedCompoundTuple.refererOrIntervals[0].isReferer);
		return dereferencedCompoundTuple.refererOrIntervals[0].referer;
	}

	// TODO< overhaul so it returns RefererOrInterval >
	final TermOrCompoundTermOrVariableReferer right(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.refererOrIntervals.length == 2, "only valid for binary compounds");
		assert(dereferencedCompoundTuple.refererOrIntervals[1].isReferer);
		return dereferencedCompoundTuple.refererOrIntervals[1].referer;
	}

	final RefererOrInterval getComponentByIndex(ReasonerInstance reasonerInstance, size_t index) {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(index < dereferencedCompoundTuple.refererOrIntervals.length); // should maybe be "ensure"
		return dereferencedCompoundTuple.refererOrIntervals[index];
	}

	final size_t getComponentLength(ReasonerInstance reasonerInstance) {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);
		return dereferencedCompoundTuple.refererOrIntervals.length;
	}


	final string getDebugStringRecursive(ReasonerInstance reasonerInstance) {
		if( thisTermReferer.isIndependentVariable ) {
			return "$%s".format(thisTermReferer.getIndependentVariable);
		}
		else if( thisTermReferer.isDependentVariable ) {
			return "#%s".format(thisTermReferer.getDependentVariable);
		}
		else if( !thisTermReferer.isSpecial ) {
			if( thisTermReferer.isAtomic ) {
				return "c:%s:%s".format(thisTermReferer.getAtomic, reasonerInstance.humanReadableConcepts[cast(size_t)thisTermReferer.getAtomic]);
			}
			else {
				string
					debugStringForLeft = reasonerInstance.getDebugStringByTermReferer(left(reasonerInstance)),
					debugStringForRight = reasonerInstance.getDebugStringByTermReferer(right(reasonerInstance));

				// TODO< check if the term is prefix or nonprefix >
				// TODO< implement for nonbinary >
				return "<%s %s %s>".format(debugStringForLeft, flagsOfCopula.convToHumanString, debugStringForRight);
			}
		}
		else {
			throw new Exception("Term referer is not a variable or not special, not handled, is an internal error");
		}
	}

	final @property uint termComplexity() {
		return protectedTermComplexity;
	}

	protected uint protectedTermComplexity;

	static struct MakeParameters {
		uint termComplexity;
		FlagsOfCopula flagsOfCopula;
		CompoundIdType compoundId;
		TermOrCompoundTermOrVariableReferer thisTermReferer;
		uint32_t termTupleIndex;
	}

	static Compound make(MakeParameters parameters) {
		Compound result;
		result.protectedTermComplexity = parameters.termComplexity;
		result.flagsOfCopula = parameters.flagsOfCopula;
		result.compoundId = parameters.compoundId;
		result.thisTermReferer = parameters.thisTermReferer;
		result.termTupleIndex = parameters.termTupleIndex;
		result.updateHashes();
		return result;
	}

	static bool isEqualWithoutCompoundIdAndTermReferer(Compound a, Compound b) {
		return a.flagsOfCopula == b.flagsOfCopula && a.termTupleIndex == b.termTupleIndex && a.termComplexity == b.termComplexity;
	}

}

struct TermTuple {
	RefererOrInterval[] refererOrIntervals; // compound-gc'ed

	static TermTuple makeByReferers(TermOrCompoundTermOrVariableReferer[] referers) {
		TermTuple result;
		result.refererOrIntervals = referers.map!(v => RefererOrInterval.makeReferer(v)).array;
		return result;
	}
}

// we need this indirection because a sequence can contain referers(Term or compoundterm or variable) or a interval
struct RefererOrInterval {
	bool isInterval;

	final @property bool isReferer() {
		return !isInterval;
	}

	TermOrCompoundTermOrVariableReferer referer;
	Interval interval;

	static RefererOrInterval makeInterval(Interval interval) {
		RefererOrInterval result;
		result.isInterval = true;
		result.interval = interval;
		return result;
	}

	static RefererOrInterval makeReferer(TermOrCompoundTermOrVariableReferer referer) {
		RefererOrInterval result;
		result.isInterval = false;
		result.referer = referer;
		return result;
	}
}

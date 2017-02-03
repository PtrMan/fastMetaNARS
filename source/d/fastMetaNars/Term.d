module fastMetaNars.Term;

import std.stdint;
import std.format;

import fastMetaNars.FrequencyCertainty;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.FlagsOfCopulaConvertToString;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.Interval;

struct Compound {
	alias uint64_t CompoundIdType;

	static const uint COMPLEXITYINDEPENDENTVARIABLE = 1;
	static const uint COMPLEXITYDEPENDENTVARIABLE = 1;

	FlagsOfCopula flagsOfCopula;

	CompoundIdType compoundId; // unique id of the compound, is not GC'ed, used for hash calc

	
	TermOrCompoundTermOrVariableReferer thisTermReferer; // term referer describing this compound
	                             // contains the id which is compound-gc'ed

	// TODO 12.09.2016 < move this into term >
	FrequencyCertainty frequencyCertainty;

	// uncommented because outdated by thisTermReferer
	//size_t compoundIndex; // compound-gc'ed index


	uint32_t termTupleIndex;
	uint32_t cachedHash;

	version(DEBUG) bool cachedHashValid;

	final void updateHash(ReasonerInstance reasonerInstance) {
		static void rotate(ref uint32_t hash, uint bits) {
			uint32_t oldHash = hash;
			hash = (oldHash >> bits) | (oldHash << (32 - bits));
		}

		cachedHash = 0;
		cachedHash ^= termTupleIndex; rotate(cachedHash, 13);
		cachedHash ^= compoundId; rotate(cachedHash, 13);
		cachedHash ^= flagsOfCopula.asNumberEncoding; rotate(cachedHash, 13);

		version(DEBUG) {
			cachedHashValid = true;
		}
	}

	final TermOrCompoundTermOrVariableReferer left(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.refererOrIntervals.length == 2, "only valid for binary compounds");
		assert(dereferencedCompoundTuple.refererOrIntervals[0].isReferer);
		return dereferencedCompoundTuple.refererOrIntervals[0].referer;
	}

	final TermOrCompoundTermOrVariableReferer right(ReasonerInstance reasonerInstance) const {
		TermTuple* dereferencedCompoundTuple = reasonerInstance.accessTermTupleByIndex(termTupleIndex);

		assert(dereferencedCompoundTuple.refererOrIntervals.length == 2, "only valid for binary compounds");
		assert(dereferencedCompoundTuple.refererOrIntervals[1].isReferer);
		return dereferencedCompoundTuple.refererOrIntervals[1].referer;
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
}

struct TermTuple {
	RefererOrInterval[] refererOrIntervals; // compound-gc'ed
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
}

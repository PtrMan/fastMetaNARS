module fastMetaNars.TermOrCompoundTermOrVariableReferer;

import std.stdint;

// a term referer can be
// - index of  compound
// - id of variable, can be independent or dependent
struct TermOrCompoundTermOrVariableReferer {
	alias uint64_t EncodingType;

	private EncodingType encoding;

	private static const uint NUMBEROFBITSFORID = 28; // enough concepts for now
	private static const EncodingType BITMAKSFORID = bitmaskForBits!EncodingType(NUMBEROFBITSFORID);

	private enum EnumSpecialMaskBits {
		ATOMICTERM = NUMBEROFBITSFORID + 1, // for atomic terms
		INDEPENDENTVAR,
		DEPENDENTVAR,
	}

	static TermOrCompoundTermOrVariableReferer makeAtomic(EncodingType value) {
		assert((value & (!BITMAKSFORID)) == 0);
		TermOrCompoundTermOrVariableReferer result;
		result.encoding = value | (1 << EnumSpecialMaskBits.ATOMICTERM);
		return result;
	}

	static TermOrCompoundTermOrVariableReferer makeNonatomic(EncodingType value) {
		assert((value & (!BITMAKSFORID)) == 0);
		TermOrCompoundTermOrVariableReferer result;
		result.encoding = value;
		return result;
	}

	static TermOrCompoundTermOrVariableReferer makeIndependentVariable(EncodingType value) {
		assert((value & (!BITMAKSFORID)) == 0);
		TermOrCompoundTermOrVariableReferer result;
		result.encoding = value | (1 << EnumSpecialMaskBits.INDEPENDENTVAR);
		return result;
	}

	static TermOrCompoundTermOrVariableReferer makeDependentVariable(EncodingType value) {
		assert((value & (!BITMAKSFORID)) == 0);
		TermOrCompoundTermOrVariableReferer result;
		result.encoding = value | (1 << EnumSpecialMaskBits.DEPENDENTVAR);
		return result;
	}

	// flags must not overlap with the id
	static assert((BITMAKSFORID & (1 << EnumSpecialMaskBits.ATOMICTERM)) == 0);
	static assert((BITMAKSFORID & (1 << EnumSpecialMaskBits.INDEPENDENTVAR)) == 0);
	static assert((BITMAKSFORID & (1 << EnumSpecialMaskBits.DEPENDENTVAR)) == 0);

	// helper, TODO< move to other file >
	static private Type bitmaskForBits(Type)(uint bits) {
		return (cast(Type)1 << (bits + 1)) - 1;
	}

	final @property bool isAtomic() pure {
		return checkFlag(EnumSpecialMaskBits.ATOMICTERM);
	}

	final @property bool isIndependentVariable() pure {
		return checkFlag(EnumSpecialMaskBits.INDEPENDENTVAR);
	}

	final @property bool isDependentVariable() pure {
		return checkFlag(EnumSpecialMaskBits.DEPENDENTVAR);
	}

	final @property bool isVariable() pure {
		return isIndependentVariable || isDependentVariable;
	}

	final @property bool isSpecial() pure {
		return isVariable;
	}

	final @property EncodingType getAtomic() pure {
		assert(isAtomic && !isSpecial);
		return maskOutId();
	}

	final @property EncodingType getTerm() pure {
		assert(!isAtomic && !isSpecial);
		return maskOutId();
	}

	// provides more generalization than just getAtomic and getTerm
	// ASK< maybe we should just reference terms? >
	final @property EncodingType getAtomicOrTerm() pure {
		assert(!isSpecial);
		return maskOutId();
	}

	// provides more generalization than just getAtomic and getTerm
	// ASK< maybe we should just reference terms? >
	final @property EncodingType getMaskedOutId() pure {
		return maskOutId();
	}

	final @property EncodingType getDependentVariable() pure {
		assert(!isAtomic && isDependentVariable);
		return maskOutId();
	}

	final @property EncodingType getIndependentVariable() pure {
		assert(!isAtomic && isIndependentVariable);
		return maskOutId();
	}

	final protected bool checkFlag(EnumSpecialMaskBits maskIndex) pure {
		return (encoding & (1 << maskIndex)) != 0;
	}

	final protected EncodingType maskOutId() pure {
		return encoding & BITMAKSFORID;
	}

	final protected EncodingType maskedOutFlags() pure {
		return encoding & ~BITMAKSFORID;
	}

	final @property EncodingType rawEncoding() {
		return encoding;
	}

	static bool isSameWithoutId(TermOrCompoundTermOrVariableReferer a, TermOrCompoundTermOrVariableReferer b) {
		return a.maskedOutFlags == b.maskedOutFlags;
	}
}

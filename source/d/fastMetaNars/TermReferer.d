module fastMetaNars.TermReferer;

// a term referer can be
// - index of  compound
// - id of variable, can be independent or dependent
struct TermReferer {
	alias uint64_t EncodingType;

	private EncodingType encoding;

	private const uint NUMBEROFBITSFORID = 28; // enough concepts for now
	private const EncodingType BITMAKSFORID = bitmaskForBits!EncodingType(NUMBEROFBITSFORID);

	private enum EnumSpecialMaskBits {
		ATOMICTERM = NUMBEROFBITSFORID + 1, // for atomic terms
		INDEPENDENTVAR,
		DEPENDENTVAR,
	}

	static TermReferer makeAtomic(EncodingType value) {
		assert(value & (!BITMAKSFORID));
		TermReferer result;
		result.encoding = value | (1 << ATOMICTERM);
		return result;
	}

	static TermReferer makeNonatomic(EncodingType value) {
		assert(value & (!BITMAKSFORID));
		TermReferer result;
		result.encoding = value;
		return result;
	}

	static TermReferer makeIndependentVariable(EncodingType value) {
		assert(value & (!BITMAKSFORID));
		TermReferer result;
		result.encoding = value | (1 << INDEPENDENTVAR);
		return result;
	}

	static TermReferer makeDependentVariable(EncodingType value) {
		assert(value & (!BITMAKSFORID));
		TermReferer result;
		result.encoding = value | (1 << DEPENDENTVAR);
		return result;
	}

	// flags must not overlap with the id
	static assert(BITMAKSFORID & (1 << EnumSpecialMaskBits.ATOMICTERM)) == 0);

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

	final @property EncodingType getDependentVariable() pure {
		assert(!isAtomic && isDependentVariable);
		return maskOutId();
	}

	final @property EncodingType getIndependentVariable() pure {
		assert(!isAtomic && isIndependentVariable);
		return maskOutId();
	}

	final protected checkFlag(EnumSpecialMaskBits maskIndex) {
		return (encoding & (1 << maskIndex)) != 0;
	}

	final protected maskOutId() pure {
		return encoding & bitmaskForBits!EncodingType(NUMBEROFBITSFORID);
	}
}

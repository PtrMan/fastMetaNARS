module fastMetaNars.deriver.DeriverUtils;

import std.format : format;
import std.typecons : Nullable;

import fastMetaNars.ReasonerInstance;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.FlagsOfCopulaConvertToString;
import fastMetaNars.FlagsOfCopulaComplexity;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.RuleTable;
import fastMetaNars.Term;

alias TemporaryDerivedCompoundType!TemporaryDerivedCompoundDecoration TemporaryDerivedCompoundWithDecoration;

struct TemporaryDerivedCompoundDecoration {
	Nullable!size_t compoundIndex; // decoration, used for remembering where it was found/added in the central compound(term) table

	static TemporaryDerivedCompoundWithDecoration *makeRecursive(TemporaryDerivedCompound *temporaryDerivedCompound) {
		final switch( temporaryDerivedCompound.type ) with (TemporaryDerivedCompound.EnumType) {
			case COMPOUND: return TemporaryDerivedCompoundWithDecoration.makeBinaryCompound(temporaryDerivedCompound.flagsOfCopula, makeRecursive(temporaryDerivedCompound.leftChildren), makeRecursive(temporaryDerivedCompound.rightChildren));
			case LEAF: return TemporaryDerivedCompoundWithDecoration.makeLeaf(temporaryDerivedCompound.termReferer);
			case INDEPENDENTVARIABLE: return TemporaryDerivedCompoundWithDecoration.makeReferenceIndependentVariable(temporaryDerivedCompound.independentVariableId);
			case DEPENDENTVARIABLE: return TemporaryDerivedCompoundWithDecoration.makeReferenceDependentVariable(temporaryDerivedCompound.dependentVariableId);
		}
	}
}

// int is dummy
alias TemporaryDerivedCompoundType!int TemporaryDerivedCompound;

struct TemporaryDerivedCompoundType(Type) {
	enum EnumType {
		COMPOUND,
		LEAF,
		INDEPENDENTVARIABLE,
		DEPENDENTVARIABLE,
	}

	static TemporaryDerivedCompoundType!Type* makeBinaryCompound(FlagsOfCopula flagsOfCopula, TemporaryDerivedCompoundType!Type* leftChildren, TemporaryDerivedCompoundType!Type* rightChildren) {
		TemporaryDerivedCompoundType!Type* result = new TemporaryDerivedCompoundType!Type;
		result.flagsOfCopula = flagsOfCopula;
		result.leftChildren = leftChildren;
		result.rightChildren = rightChildren;
		result.type = EnumType.COMPOUND;
		return result;
	}

	static TemporaryDerivedCompoundType!Type* makeLeaf(TermOrCompoundTermOrVariableReferer termReferer) {
		TemporaryDerivedCompoundType!Type* result = new TemporaryDerivedCompoundType!Type;
		result.protectedTermReferer = termReferer;
		result.type = EnumType.LEAF;
		return result;
	}

	static TemporaryDerivedCompoundType!Type* makeReferenceIndependentVariable(uint id) {
		TemporaryDerivedCompoundType!Type* result = new TemporaryDerivedCompoundType!Type;
		with(result) {
			protectedVariableId = id;
			type = EnumType.INDEPENDENTVARIABLE;
		}
		return result;
	}

	static TemporaryDerivedCompoundType!Type* makeReferenceDependentVariable(uint id) {
		TemporaryDerivedCompoundType!Type* result = new TemporaryDerivedCompoundType!Type;
		with(result) {
			protectedVariableId = id;
			type = EnumType.DEPENDENTVARIABLE;
		}
		return result;
	}


	final @property bool isLeaf() pure {
		return type == EnumType.LEAF;
	}

	final string debugToStringRecursivly(ReasonerInstance reasonerInstance) {
		if( isLeaf ) {
			return "<LEAF=%s>".format(reasonerInstance.getDebugStringByTermReferer(termReferer));
		}
		else if( isIndependentVariable ) {
			return "<$VAR:%s>".format(independentVariableId);
		}
		else if( isDependentVariable ) {
			return "<#VAR:%s>".format(dependentVariableId);
		}
		else {
			// TODO< implement for nonbinary >
			return "<COMPOUND=%s %s %s>".format(leftChildren.debugToStringRecursivly(reasonerInstance), flagsOfCopula.convToHumanString(), rightChildren.debugToStringRecursivly(reasonerInstance));
		}
	}

	final uint calcComplexityRecursive(ReasonerInstance reasonerInstance) {
		if( isLeaf ) {
			return reasonerInstance.getTermComplexityOfAndByTermReferer(termReferer);
		}
		else if( isIndependentVariable ) {
			return Compound.COMPLEXITYINDEPENDENTVARIABLE;
		}
		else if( isDependentVariable ) {
			return Compound.COMPLEXITYDEPENDENTVARIABLE;
		}
		else {
			uint complexity = getComplexityOfFlagsOfCopula(flagsOfCopula);

			// TODO< implement for nonbinary >
			complexity += leftChildren.calcComplexityRecursive(reasonerInstance);
			complexity += rightChildren.calcComplexityRecursive(reasonerInstance);
			return complexity;
		}
	}

	EnumType type;
	FlagsOfCopula flagsOfCopula; // TODO< accessor >
	TemporaryDerivedCompoundType!Type* leftChildren; // TODO< accessor >
	TemporaryDerivedCompoundType!Type* rightChildren; // TODO< accessor >

	final @property TermOrCompoundTermOrVariableReferer termReferer() pure {
		assert(type == EnumType.LEAF);
		return protectedTermReferer;
	}

	final @property uint independentVariableId() pure {
		assert(type == EnumType.INDEPENDENTVARIABLE);
		return protectedVariableId;
	}

	final @property uint dependentVariableId() pure {
		assert(type == EnumType.DEPENDENTVARIABLE);
		return protectedVariableId;
	}

	final @property bool isIndependentVariable() pure {
		return type == EnumType.INDEPENDENTVARIABLE;
	}

	final @property bool isDependentVariable() pure {
		return type == EnumType.DEPENDENTVARIABLE;
	}

	final @property bool isVariable() pure {
		return isIndependentVariable || isDependentVariable;
	}


	uint termComplexity;

	protected TermOrCompoundTermOrVariableReferer protectedTermReferer;

	protected uint protectedVariableId;

	Type decoration;
}

// utilities used by the autogenerated deriver

TemporaryDerivedCompound* genBinary(FlagsOfCopula flagsOfCopula, TemporaryDerivedCompound* left, TemporaryDerivedCompound* right) {
	return TemporaryDerivedCompound.makeBinaryCompound(flagsOfCopula, left, right);
}

TemporaryDerivedCompound* genBinary(FlagsOfCopula flagsOfCopula, TemporaryDerivedCompound* left, TermOrCompoundTermOrVariableReferer termRefererRight) {
	return TemporaryDerivedCompound.makeBinaryCompound(flagsOfCopula, left, TemporaryDerivedCompound.makeLeaf(termRefererRight));
}

TemporaryDerivedCompound* genBinary(FlagsOfCopula flagsOfCopula, TermOrCompoundTermOrVariableReferer termRefererLeft, TemporaryDerivedCompound* right) {
	return TemporaryDerivedCompound.makeBinaryCompound(flagsOfCopula, TemporaryDerivedCompound.makeLeaf(termRefererLeft), right);
}

TemporaryDerivedCompound* genBinary(FlagsOfCopula flagsOfCopula, TermOrCompoundTermOrVariableReferer termRefererLeft, TermOrCompoundTermOrVariableReferer termRefererRight) {
	return TemporaryDerivedCompound.makeBinaryCompound(flagsOfCopula, TemporaryDerivedCompound.makeLeaf(termRefererLeft), TemporaryDerivedCompound.makeLeaf(termRefererRight));
}

TemporaryDerivedCompound* makeReferenceIndependentVariable(uint id) {
	return TemporaryDerivedCompound.makeReferenceIndependentVariable(id);
}

TemporaryDerivedCompound* makeReferenceDependentVariable(uint id) {
	return TemporaryDerivedCompound.makeReferenceDependentVariable(id);
}


struct TemporaryDerivedTerm {
	TemporaryDerivedCompound* derivedCompound;
	RuleTable.EnumTruthFunction truthfunction;
}

TemporaryDerivedTerm* genTerm(TemporaryDerivedCompound* derivedCompound, RuleTable.EnumTruthFunction truthfunction) {
	TemporaryDerivedTerm* result = new TemporaryDerivedTerm;
	result.derivedCompound = derivedCompound;
	result.truthfunction = truthfunction;
	return result;
}

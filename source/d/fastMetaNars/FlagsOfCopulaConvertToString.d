module fastMetaNars.FlagsOfCopulaConvertToString;

import fastMetaNars.FlagsOfCopula;

string convToHumanString(FlagsOfCopula flagsOfCopula) {
	if( flagsOfCopula.isImplication ) {
		return "-->";
	}
	else if( flagsOfCopula.isSimilarity ) {
		return "<->";
	}
	else if( flagsOfCopula.isImplication ) {
		return "==>";
	}
	else if( flagsOfCopula.isEquivalence ) {
		return "<=>";
	}
	else if( flagsOfCopula.isConjection ) {
		return "&&";
	}
	else {
		throw new Exception("Internal error - unimplemented");
	}
}

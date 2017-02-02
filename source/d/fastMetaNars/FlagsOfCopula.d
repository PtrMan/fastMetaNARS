module fastMetaNars.FlagsOfCopula;

import std.stdint;

struct FlagsOfCopula {
	bool nal1or2; // --> <->
	bool nal5; // ==> <=>

	bool arrowLeft, arrowRight;

	bool isConjection;


	final @property uint32_t asNumberEncoding() {
		return nal1or2 | (nal5 << 1) | (arrowLeft << 2) | (arrowRight << 3) | (isConjection << 4);
	}

	final public this(bool nal1or2, bool nal5, bool arrowLeft, bool arrowRight, bool isConjection) {
		this.nal1or2 = nal1or2;
		this.nal5 = nal5;
		this.arrowLeft = arrowLeft;
		this.arrowRight = arrowRight;
		this.isConjection = isConjection;
	}

	static FlagsOfCopula makeInheritance() {
		FlagsOfCopula result;
		with(result) {
			nal1or2 = true;
			arrowRight = true;
		}
		return result;
	}

	final @property bool isInheritance() pure {
		return nal1or2 && arrowRight && !arrowLeft;
	}

	static FlagsOfCopula makeSimilarity() {
		FlagsOfCopula result;
		with(result) {
			nal1or2 = true;
			arrowLeft = arrowRight = true;
		}

		return result;
	}

	final @property bool isSimilarity() pure {
		return nal1or2 && arrowRight && arrowLeft;
	}


	static FlagsOfCopula makeImplication() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowRight = true;
		}
		return result;
	}

	final @property bool isImplication() pure {
		return nal5 && arrowRight && !arrowLeft;
	}

	static FlagsOfCopula makeEquivalence() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowLeft = arrowRight = true;
		}
		return result;
	}

	final @property bool isEquivalence() pure {
		return nal5 && arrowRight && arrowLeft;
	}


	static FlagsOfCopula makeConjuction() {
		FlagsOfCopula result;
		result.isConjection = true;
		return result;
	}

}

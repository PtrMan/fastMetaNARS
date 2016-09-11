module fastMetaNars.FlagsOfCopula;

struct FlagsOfCopula {
	bool nal1or2; // --> <->
	bool nal5; // ==> <=>

	bool arrowLeft, arrowRight;

	bool isConjection;

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

	static FlagsOfCopula makeSimilarity() {
		FlagsOfCopula result;
		with(result) {
			nal1or2 = true;
			arrowLeft = arrowRight = true;
		}

		return result;
	}

	static FlagsOfCopula makeImplication() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowRight = true;
		}
		return result;
	}

	static FlagsOfCopula makeEquivalence() {
		FlagsOfCopula result;
		with(result) {
			nal5 = true;
			arrowLeft = arrowRight = true;
		}
		return result;
	}

	static FlagsOfCopula makeConjuction() {
		FlagsOfCopula result;
		result.isConjection = true;
		return result;
	}
}

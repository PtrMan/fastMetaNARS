module fastMetaNars.FlagsOfCopula;

struct FlagsOfCopula {
	bool nal1or2; // --> <->
	bool nal5; // ==> <=>

	bool arrowLeft, arrowRight;

	bool isConjection;

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

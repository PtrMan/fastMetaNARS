module fastMetaNars.FlagsOfCopula;

import std.stdint;

struct FlagsOfCopula {
	              //              product
	bool nal1or2; // --> <->
	bool nal5;    // ==> <=>
	bool nal7;    // =/> <|>      (&/, ...)

	bool arrowLeft, arrowRight;
	bool product; // can be a NAL5 product or a NAL7 product(which is an sequence)

	bool isConjection;

	// uncommented because TOINTEGRATE
	//bool list; 
	           // # 
	           // as introduced by pei
	           // https://groups.google.com/forum/#!topic/open-nars/S8c6P5ndy5o



	final @property uint32_t asNumberEncoding() {
		return nal1or2 | (nal5 << 1) | (arrowLeft << 2) | (arrowRight << 3) | (isConjection << 4);
	}

	final public this(bool nal1or2, bool nal5, bool arrowLeft, bool arrowRight, bool isConjection, bool nal7 = false) {
		this.nal1or2 = nal1or2;
		this.nal5 = nal5;
		this.arrowLeft = arrowLeft;
		this.arrowRight = arrowRight;
		this.isConjection = isConjection;
		this.nal7 = nal7;
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



	final @property bool isProduct() pure {
		assert(nal5 != nal7);

		return nal5 && product;
	}

	final @property bool isSequence() pure {
		assert(nal5 != nal7);

		return nal7 && product;
	}

}

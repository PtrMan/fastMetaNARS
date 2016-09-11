module fastMetaNars.FrequencyCertainty;

struct FrequencyCertainty {
	final this() {}

	final this(float frequency, float certainty) {
		this.frequency = frequency;
		this.certainty = certainty;
	}

	float frequency, certainty;


	static FrequencyCertainty fAnalogy(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		return FrequencyCertainty(f1*f2, c1*f2*f2*c2*c2);
	}

	// tick function
	// rigid flexibility, page 84

	static FrequencyCertainty fAnalogyTick(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		return fAnalogy(_2, _1, k);
	}

	static FrequencyCertainty fDedudction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		return FrequencyCertainty(_and(f1, f2), _and(f1, c1, f2, c2));
	}


	static FrequencyCertainty fDeduction2(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		return FrequencyCertainty(f1*f2, c1*c2*(f1 + f2 - f1*f2));
	}

	static FrequencyCertainty fAbduction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		return FrequencyCertainty(f2, f1*c1*c2 / (f1*c1*c2 + k));
	}

	static FrequencyCertainty fInduction(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		return FrequencyCertainty(f1, c1*f2*c2 / (c1*f2*c2 + k));
	}

	static FrequencyCertainty fRevision(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		float _1minusC1 = 1.0f - c1;
		float _1minusC2 = 1.0f - c2;

		float frequency = (f1*c1*_1minusC2 + f2*c2*_1minusC1) / (c1*_1minusC2 + c2*_1minusC1);
		float certainty = (c1*_1minusC2 + c2*_1minusC1) / (c1*_1minusC2 + c2*_1minusC1 + _1minusC1*_1minusC2);
		return FrequencyCertainty(frequency, certainty);
	}


	// rigid flexibility page 84
	static FrequencyCertainty fComparision(FrequencyCertainty _1, FrequencyCertainty _2, float k) {
		float c1 = _1.certainty;
		float c2 = _2.certainty;
		float f1 = _1.frequency;
		float f2 = _2.frequency;

		float frequency = (f1*f2) / (f1 + f2 - f1*f2);
		float certainty = (c1*c2*(f1 + f2 - f1*f2)) / (c1*c2*(f1 + f2 - f1*f2) + k);
		return FrequencyCertainty(frequency, certainty);
	}

	protected {
		// TODO< generalize to any # of arguments >
		static float _and(float a, float b) {
			return a*b;
		}

		static float _and(float a, float b, float c, float d) {
			return a*b*c*d;
		}
	}
}

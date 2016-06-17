#pragma once


struct FrequencyCertainty {
	FrequencyCertainty() {}

	FrequencyCertainty(float frequency, float certainty) {
		this->frequency = frequency;
		this->certainty = certainty;
	}

	float frequency, certainty;


	static FrequencyCertainty fAnalogy(FrequencyCertainty _1, FrequencyCertainty _2, float k);

	// tick function
	// rigid flexibility, page 84
	static FrequencyCertainty fAnalogyTick(FrequencyCertainty _1, FrequencyCertainty _2, float k);
	static FrequencyCertainty fDedudction(FrequencyCertainty _1, FrequencyCertainty _2, float k);
	static FrequencyCertainty fDeduction2(FrequencyCertainty _1, FrequencyCertainty _2, float k);
	static FrequencyCertainty fAbduction(FrequencyCertainty _1, FrequencyCertainty _2, float k);
	static FrequencyCertainty fInduction(FrequencyCertainty _1, FrequencyCertainty _2, float k);
	static FrequencyCertainty fRevision(FrequencyCertainty _1, FrequencyCertainty _2, float k);

	// rigid flexibility page 84
	static FrequencyCertainty fComparision(FrequencyCertainty _1, FrequencyCertainty _2, float k);

protected:

	static float _and(float a, float b);
	static float _and(float a, float b, float c, float d);
};


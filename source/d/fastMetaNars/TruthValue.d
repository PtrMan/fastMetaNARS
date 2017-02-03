module fastMetaNars.TruthValue;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/TruthValue.java
struct TruthValue {
	static TruthValue make(float frequency, float confidence) {
		TruthValue result;
		result.frequency = frequency;
		result.confidence = confidence;
		return result;
	}

	float frequency, confidence;
}

module fastMetaNars.TemporalMatcher;

import fastMetaNars.Interval;


bool perfectMatchByElements(CheckerType, Type)(CheckerType checker, Type[] template_, Type[] matched) {
	if( template_.length != matched.length ) {
		return false;
	}

	foreach( i; 0..template_.length) {
		if(!checker.matchesTypeButNotLength(template_[i], matched[i])) {
			return false;
		}
	}

	return true;
}

// the matched is only allowed to contain intervals of width zero!
void calcFrequencyForSameTemporalSequence(CheckerType, Type)(CheckerType checker, Type[] template_, Type[] matched, out bool perfectTemporalMatch, out float confidenceFactor) {
	perfectTemporalMatch = true;
	float confidenceProduct = 1.0f;
	Interval accumulatedTemplateInterval = Interval.makeInstantaneousRelative();
	double accumulatedMatchedTime = 0.0;

	assert(perfectMatchByElements!(CheckerType, Type)(checker, template_, matched)); // assertion-A1

	foreach( i; 0..template_.length ) {
		if( CheckerType.getRelativeInterval(template_[i]).isInstantaneous ) {
			continue; // equalivalence is already gurantueed by assertion-A1
		}

		perfectTemporalMatch &= checker.matchesTypeAndLength(template_[i], matched[i]);

		confidenceProduct *= checker.calcConfidenceOfTemporalMatch(CheckerType.getRelativeInterval(template_[i]), Interval.makeInstantaneousRelative(accumulatedMatchedTime), accumulatedTemplateInterval);
		accumulatedTemplateInterval = accumulatedTemplateInterval.add(CheckerType.getRelativeInterval(template_[i]));

		accumulatedMatchedTime += CheckerType.getRelativeInterval(matched[i]).endRelative;
	}

	confidenceFactor = confidenceProduct;
}

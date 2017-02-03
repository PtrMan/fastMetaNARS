import fastMetaNars.TemporalMatcher;
import fastMetaNars.TemporalMatcherCheckerImpl;
import fastMetaNars.Term : RefererOrInterval;
import fastMetaNars.Interval;

// unittest for calcFrequencyForSameTemporalSequence with TemporalMatcherCheckerImpl as Implementation for RefererOrInterval

// for direct matching of an range, where to instant is inside the range
unittest {
	TemporalMatcherCheckerImpl *checker = new TemporalMatcherCheckerImpl;
	checker.n = 1.0;

	RefererOrInterval[] template_ = [RefererOrInterval.makeInterval(Interval.makeRelative(1.0, 5.0))];
	RefererOrInterval[] matched = [RefererOrInterval.makeInterval(Interval.makeInstantaneousRelative(4.0))];

	float confidenceFactor;
	bool perfectTemporalMatch;
	calcFrequencyForSameTemporalSequence!(TemporalMatcherCheckerImpl*, RefererOrInterval)(checker, template_, matched, /*out*/ perfectTemporalMatch, /*out*/ confidenceFactor);

	assert(!perfectTemporalMatch); // can't be perfect because an event can't span a timespan
	assert(confidenceFactor == 1.0f);
}

// TODO< case before and case after >

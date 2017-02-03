module fastMetaNars.TemporalMatcherCheckerImpl;

// Implementation of the Structure used by the Temporal matcher for the NARS

import std.math : exp;

import fastMetaNars.ReasonerInstance;
import fastMetaNars.Term : RefererOrInterval;
import fastMetaNars.Interval;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;

struct TemporalMatcherCheckerImpl {
	// uncommented because not needed
	//ReasonerInstance reasonerInstance;
	
	double n; // time decay factor

	final bool matchesTypeButNotLength(RefererOrInterval templateRefererOrIntervals, RefererOrInterval matchedRefererOrIntervals) {
		return matchesTypeAndLengthByVariable(templateRefererOrIntervals, matchedRefererOrIntervals, true);
	}

	final bool matchesTypeAndLength(RefererOrInterval templateRefererOrIntervals, RefererOrInterval matchedRefererOrIntervals) {
		return matchesTypeAndLengthByVariable(templateRefererOrIntervals, matchedRefererOrIntervals, false);
	}

	final private bool matchesTypeAndLengthByVariable(RefererOrInterval templateRefererOrIntervals, RefererOrInterval matchedRefererOrIntervals, bool isIntervalMatched) {
		// must be equl because we just can matche intervals with intervals and compounds with compounds
		assert( templateRefererOrIntervals.isInterval == matchedRefererOrIntervals.isInterval );

		bool isInterval = templateRefererOrIntervals.isInterval;
		if( isInterval ) {
			return isIntervalMatched || templateRefererOrIntervals.interval.isEqual(matchedRefererOrIntervals.interval);
		}
		else {
			return TermOrCompoundTermOrVariableReferer.isSameWithId(templateRefererOrIntervals.referer, matchedRefererOrIntervals.referer);
		}
	}

	static Interval getRelativeInterval(RefererOrInterval refererOrInterval) {
		assert(refererOrInterval.isInterval);
		assert(!refererOrInterval.interval.isAnchored);
		return refererOrInterval.interval;
	}

	final float calcConfidenceOfTemporalMatch(Interval templateRefererOrIntervals, Interval matchedRefererOrIntervals, Interval accumulatedInterval) {
		assert(!accumulatedInterval.isAnchored); // accumulatedInterval must be an relative interval

		if( !matchedRefererOrIntervals.isInstantaneous ) {
			return 1.0f;
		}

		// if we are here, the matched is an event

		double matchedEventTime = matchedRefererOrIntervals.instantaneousRelative;

		if( accumulatedInterval.isInIntervalRelative(matchedEventTime) ) {
			return 1.0f;
		}
		else if( accumulatedInterval.isRelativeTimeBefore(matchedEventTime) ) {
			return cast(float)(1.0 - integrateTimeDecay(0.0, accumulatedInterval.beginRelative - matchedEventTime,  n));
		}
		else { // it is after the event
			return cast(float)(1.0 - integrateTimeDecay(0.0, matchedEventTime - accumulatedInterval.endRelative,  n));
		}
	}


	static private double integrateTimeDecay(double start, double end, double n) {
		assert(end >= start);
		return baseFunction(end, n) - baseFunction(start, n);
	}

	// https://www.wolframalpha.com/input/?i=integrate+(1%2F(e%5E(t*n)))
	// e^(-n*t) is a good base function for the decay of the freqency of the event depending on the time distance
	// base function is for integration
	static private double baseFunction(double t, double n) {
		return -(exp(-n*t)/n);
	}

}

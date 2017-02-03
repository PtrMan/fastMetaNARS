module fastMetaNars.Interval;

import std.math : pow, isNaN;

// intervals can be "anchored" in time with an absolute time -> isAnchored = false
// or they can be 



// [...)
struct Interval {
	private double privateBeginRelative, privateEndRelative;
	private double relativeTime; // only valid if 

	// is the interval "anchored" in time or is it relative to something
	final @property bool isAnchored() {
		return !relativeTime.isNaN;
	}

	final @property bool isInstantaneous() {
		return beginRelative==endRelative;
	}

	// returns instantanious time
	final @property double instantaneousRelative() {
		assert(!isAnchored);
		assert(isInstantaneous);
		return beginRelative;
	}

	// returns instantanious time
	final @property double instantaneousAbsolute() {
		assert(isAnchored);
		assert(isInstantaneous);
		return beginAbsolute;
	}

	// only valid if it is an relative time
	final @property double beginAbsolute() {
		assert(isAnchored);
		return relativeTime+privateBeginRelative;
	}

	// only valid if it is an relative time
	final @property double endAbsolute() {
		assert(isAnchored);
		return relativeTime+privateEndRelative;
	}

	// only valid if it is not an relative time
	final @property double beginRelative() {
		assert(!isAnchored);
		return privateBeginRelative;
	}

	// only valid if it is not an relative time
	final @property double endRelative() {
		assert(!isAnchored);
		return privateEndRelative;
	}

	final Interval add(Interval other) {
		assert(!other.isAnchored); // adding absolute time is illegal

		Interval result;
		result.relativeTime = relativeTime;
		result.privateBeginRelative = privateBeginRelative + other.privateBeginRelative;
		result.privateEndRelative = privateEndRelative + other.privateEndRelative;
		return result;
	}

	final bool isInIntervalAbsolute(double absoluteTime) {
		assert(isAnchored);
		return beginAbsolute <= absoluteTime && endAbsolute > absoluteTime;
	}

	final bool isInIntervalRelative(double relativeTime) {
		assert(!isAnchored);
		return beginRelative <= relativeTime && endRelative > relativeTime;
	}

	/* uncommented because not used
	final bool isAbsoluteTimeBefore(double absoluteTime) {
		assert(isAnchored);
		return absoluteTime < beginAbsolute;
	}
	*/

	final bool isRelativeTimeBefore(double relativeTime) {
		assert(!isAnchored);
		return relativeTime < beginRelative;
	}

	final bool isEqual(Interval other) {
		return beginRelative == other.beginRelative && endRelative == other.endRelative && relativeTime == other.relativeTime;
	}

	final bool isAbsoluteTimeInside(double absolute) {
		assert(isAnchored); // only defined for nonrelative intervals

		if(isInstantaneous) {
			return absolute == beginRelative;
		}
		return absolute >= beginAbsolute && absolute < endAbsolute;
	}

	static Interval makeAbsolute(double begin, double end) {
		Interval result;
		result.relativeTime = 0.0;
		result.privateBeginRelative = begin;
		result.privateEndRelative = end;
		return result;
	}

	static Interval makeRelative(double begin, double end) {
		Interval result;
		result.relativeTime = float.nan;
		result.privateBeginRelative = begin;
		result.privateEndRelative = end;
		return result;
	}

	static Interval makeInstantaneousRelative(double time) {
		Interval result;
		result.relativeTime = float.nan;
		result.privateBeginRelative = time;
		result.privateEndRelative = time;
		return result;
	}

	static Interval makeInstantaneousRelative() {
		return makeInstantaneousRelative(0.0);
	}
}



// example
// 1 -> [0.5;1.5)
// 1.0 -> [0.95;1.05)
// 1.00 -> [0.995;1.005]

// https://groups.google.com/forum/#!topic/open-nars/SLs8TyNwF7w
// >A single point with accuracy is equivalent to an interval. For example, 1 corresponds to [0.5, 1.5), 1.0 to [0.95, 1.05), 1.00 to [0.995, 1.005), ...
// 
// https://groups.google.com/forum/#!topic/open-nars/tC9NNwgmCjc
Interval createIntervalByBaseAndPrecision(double base, double precision) {
	if( precision.isNaN ) { // instantaneous
		return Interval.makeInstantaneousRelative(base);
	}

	assert(precision >= 0.0); // else it's ill defined

	// calculate the whole range [0;r)
	double rangeBase = pow(10.0, -precision);
	// calculate the difference to minus and plus
	double rangeDiff = rangeBase * 0.5;

	double rangeMin = base * (1.0 - rangeDiff);
	double rangeMax = base * (1.0 + rangeDiff);
	return Interval.makeRelative(rangeMin, rangeMax);
}

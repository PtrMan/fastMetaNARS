module fastMetaNars.CompoundHashtable;

import std.array : array;
import std.algorithm.iteration : map;
import std.stdint;

import misced.memory.Hashtable;

import fastMetaNars.ReasonerInstance;

// the indices need to be refreshed after compound-GC!
struct CompoundHashtable(HashType, bool WithCompoundId) {
	final this(ReasonerInstance reasonerInstance) {
		this.reasonerInstance = reasonerInstance;
		hashtable = new typeof(hashtable)(&calcHash);
	}

	final bool existHash(HashType hashValue) {
		return hashtable.existHash(cast(uint)hashValue);
	}

	final size_t[] getPotentialIndicesOfCompoundsByHash(HashType hashValue) {
		return hashtable.get(cast(uint)hashValue).map!(a => a.index).array;
	}

	final void insert(size_t index) {
		version(DEBUG) {
			static if( WithCompoundId ) {
				assert(reasonerInstance.accessCompoundByIndex(index).cachedHashWithCompoundIdValid);
			}
			else {
				assert(reasonerInstance.accessCompoundByIndex(index).cachedHashWithoutCompoundIdValid);
			}
		}

		HashWithIndex hashWithIndex;
		hashWithIndex.index = index;
		static if( WithCompoundId ) {
			hashWithIndex.hash = cast(uint)reasonerInstance.accessCompoundByIndex(index).cachedHashWithCompoundId;
		}
		else {
			hashWithIndex.hash = cast(uint)reasonerInstance.accessCompoundByIndex(index).cachedHashWithoutCompoundId;
		}
		hashtable.insert(hashWithIndex);
	}

	protected static uint calcHash(HashWithIndex hashWithIndex) {
		return hashWithIndex.hash;
	}

	private static struct HashWithIndex {
		size_t index;
		uint hash;

		final bool isEqual(HashWithIndex other) {
			return index == other.index && hash == other.hash;
		}
	}

	private static const NUMBEROFBUCKETS = 1 << 10; // 1024

	private ReasonerInstance reasonerInstance;
	private Hashtable!(HashWithIndex, NUMBEROFBUCKETS) hashtable;
}

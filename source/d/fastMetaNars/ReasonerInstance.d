module fastMetaNars.ReasonerInstance;

import std.stdint;
import std.algorithm.iteration : map;
import std.algorithm.searching : all;
import std.array : array;

import fastMetaNars.Term;
import fastMetaNars.ClassicalConcept;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.CompoundHashtable;
import fastMetaNars.control.WorkingCyclish;

struct ReasonerInstanceConfiguration {
	float k;
	uint maximalTermComplexity;
}


// contains all information of a reasoner instance
class ReasonerInstance {
	alias size_t CompoundId;

	string[] humanReadableConcepts;

	// compounds describe concepts connected with copula and the references/id's of the children compounds are stored in termTuples
	private Compound[] compounds;
	
	private TermTuple[] termTuples;
	private size_t[][uint64_t] termTupleIndicesByTermTupleHash;

	private CompoundHashtable!(Compound.HashWithCompoundIdType, true) compoundHashtableByWithId;
	private CompoundHashtable!(Compound.HashWithoutCompoundIdType, false) compoundHashtableByWithoutId;


	CompoundId compoundIdCounter;
	ReasonerInstanceConfiguration configuration;

	WorkingCyclish workingCyclish; // holds the concepts

	final this() {
		compoundHashtableByWithId = CompoundHashtable!(Compound.HashWithCompoundIdType, true)(this);
		compoundHashtableByWithoutId = CompoundHashtable!(Compound.HashWithoutCompoundIdType, false)(this);
	}

	// returns index
	final size_t addTermTupleByReferers(TermOrCompoundTermOrVariableReferer[] referers) {
		uint64_t hash = calcHashOfTermOrCompoundTermOrVariableReferers(referers);
		
		size_t insertionIndex = termTuples.length;
		termTuples ~= TermTuple.makeByReferers(referers);
		if( !(hash in termTupleIndicesByTermTupleHash) ) {
			termTupleIndicesByTermTupleHash[hash] = [insertionIndex];
			return insertionIndex;
		}

		termTupleIndicesByTermTupleHash[hash] ~= insertionIndex;

		return insertionIndex;
	}

	final TermTuple* accessTermTupleByIndex(size_t index) {
		assert(index < termTuples.length);
		return &(termTuples[index]);
	}
	
	final Compound* accessCompoundByIndex(size_t index) {
		assert(index < compounds.length);
		return &(compounds[index]);
	}

	static uint getTermComplexityOfCopula(FlagsOfCopula flagsOfCopula) {
		return 1;
	}

	final uint getTermComplexityOfAndByTermReferer(TermOrCompoundTermOrVariableReferer termReferer) {
		if( termReferer.isVariable ) {
			return 1;
		}
		else if( !termReferer.isSpecial ) {
			return accessCompoundByIndex(cast(size_t)termReferer.getAtomicOrTerm).termComplexity;
		}
		else {
			throw new Exception("Term referer is not a variable or not special, not handled, is an internal error");
		}
	}

	final string getDebugStringByTermReferer(TermOrCompoundTermOrVariableReferer termReferer) {
		return accessCompoundByIndex(cast(size_t)termReferer.getMaskedOutId).getDebugStringRecursive(this);
	}


	private size_t[Compound.CompoundIdType] compoundIdToCompoundIndex;
	final size_t translateCompoundIdToCompoundIndex(Compound.CompoundIdType compoundId) {
		assert(compoundId in compoundIdToCompoundIndex);
		return compoundIdToCompoundIndex[compoundId];
	}


	// all fields of parameters have to be initialized except compoundId
	final Compound createCompound(Compound.MakeParameters parameters) {
		parameters.compoundId = compoundIdCounter;
		Compound resultCompound = Compound.make(parameters);

		compoundIdCounter++;

		return resultCompound;
	}

	// geturns the index where the next compound will be created
	final size_t getCompoundCreateIndex() {
		return compounds.length;
	}

	final size_t addCompound(Compound compound) {
		size_t compoundIndex = compounds.length;
		compounds ~= compound;

		compoundIdToCompoundIndex[compound.compoundId] = compoundIndex;

		// add it to the hashtables
		compound.updateHashes();
		compoundHashtableByWithId.insert(compoundIndex);
		compoundHashtableByWithoutId.insert(compoundIndex);

		return compoundIndex;
	}

	final Compound getCompoundByIndex(size_t index) {
		return compounds[index];
	}

	final private size_t[] getPotentialIndicesOfCompoundsByHashWithoutCompoundId(Compound.HashWithoutCompoundIdType hash) {
		return compoundHashtableByWithoutId.getPotentialIndicesOfCompoundsByHash(hash);
	}

	// checks if the compound exists and returns the index of the compound if it is the case
	// the compoundId is not used for hash lookup/comparision
	final bool compoundExistsWithoutCompoundId(Compound compoundToCompareWithoutCompoundId, out size_t foundCompoundIndex) {
		if( !compoundHashtableByWithoutId.existHash(compoundToCompareWithoutCompoundId.cachedHashWithoutCompoundId) ) {
			return false;
		}

		size_t[] potentialCompoundIndices = getPotentialIndicesOfCompoundsByHashWithoutCompoundId(compoundToCompareWithoutCompoundId.cachedHashWithoutCompoundId);

		// compare and search the compound which matches the queried one
		foreach( iCompoundIndex; potentialCompoundIndices ) {
			Compound iCompound = compounds[iCompoundIndex];
			if( Compound.isEqualWithoutCompoundIdAndTermReferer(compoundToCompareWithoutCompoundId, iCompound) ) {
				foundCompoundIndex = iCompoundIndex;
				return true;
			}
		}

		return false;
	}

	final static uint64_t calcHashOfTermOrCompoundTermOrVariableReferers(TermOrCompoundTermOrVariableReferer[] compounds) {
		static void rotate(ref uint64_t hash, uint bits) {
			uint64_t oldHash = hash;
			hash = (oldHash >> bits) | (oldHash << (64 - bits));
		}

		uint64_t calcHash() {
			uint64_t hash = 0;

			foreach( iterationCompound; compounds ) {
				rotate(hash, 13);
				hash ^= iterationCompound.rawEncoding;
			} 

			return hash;
		}

		uint64_t hash = calcHash();
		return hash;
	}

	final bool existTermTuple(TermOrCompoundTermOrVariableReferer[] referers) {
		uint64_t hash = calcHashOfTermOrCompoundTermOrVariableReferers(referers);
		if( !(hash in termTupleIndicesByTermTupleHash) ) {
			return false;
		}

		// compare
		size_t[] termTupleIndices = termTupleIndicesByTermTupleHash[hash];
		foreach( iterationTermTupleIndex; termTupleIndices ) {
			assert(termTuples[iterationTermTupleIndex].refererOrIntervals.all!(a => a.isReferer));
			if( termTuples[iterationTermTupleIndex].refererOrIntervals.map!(a => a.referer ).array == referers ) { // TODO< maybe we need an helper which compares element by element >
				return true;
			}
		}

		return false;
	}

	final size_t getTermTupleIndexByReferers(TermOrCompoundTermOrVariableReferer[] referers) {
		uint64_t hash = calcHashOfTermOrCompoundTermOrVariableReferers(referers);
		if( !(hash in termTupleIndicesByTermTupleHash) ) {
			return false;
		}

		// compare
		size_t[] termTupleIndices = termTupleIndicesByTermTupleHash[hash];
		foreach( iterationTermTupleIndex; termTupleIndices ) {
			assert(termTuples[iterationTermTupleIndex].refererOrIntervals.all!(a => a.isReferer));
			if( termTuples[iterationTermTupleIndex].refererOrIntervals.map!(a => a.referer ).array == referers ) { // TODO< maybe we need an helper which compares element by element >
				return iterationTermTupleIndex;
			}
		}

		throw new Exception("compound wasn't indexed"); // indicates an internal error, existTermTuple() should return true before doing this query
	}
}

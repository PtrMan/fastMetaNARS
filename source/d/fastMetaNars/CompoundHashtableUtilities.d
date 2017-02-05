module fastMetaNars.CompoundHashtableUtilities;

import fastMetaNars.CompoundHashtable;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.Term;
import fastMetaNars.TermComparision;

// compoundIndex is the index in the compound table in reasonerInstance
void insertToHashtableIfDoesntExistNorecursive(HashType, bool WithCompoundId)(ReasonerInstance reasonerInstance, CompoundHashtable!(HashType, bool WithCompoundId)* compoundHashtable, size_t compoundIndex, out bool wasInsertedIntoHashtable) {
	wasInsertedIntoHashtable = false;

	Compound* compound = reasonerInstance.accessCompoundByIndex(compoundIndex);

	bool insertIntoHashtable;

	bool existHash;

	static if( WithCompoundId ) {
		version(DEBUG) {
			assert(compound.cachedHashWithCompoundIdValid, "We expect an valid hash of the compound for which we check if it eists in the hashtable");
		}
		existHash = compoundHashtable.existHash(compound.cachedHashWithCompoundId);
	}
	else {
		version(DEBUG) {
			assert(compound.cachedHashWithoutCompoundIdValid, "We expect an valid hash of the compound for which we check if it eists in the hashtable");
		}
		existHash = compoundHashtable.existHash(compound.cachedHashWithoutCompoundId);
	}

	assert(compound.cachedHashValid, "We expect an valid hash of the compound for which we check if it eists in the hashtable");
	if( existHash ) {
		// check for all candidates if its the same, if so we don't have to continue
		foreach( iterationCandidateCompoundIndex; compoundHashtable.getPotentialIndicesOfCompoundsByHash(compound.cachedHash) ) {
			Compound* candidateCompound = reasonerInstance.accessCompoundByIndex(iterationCandidateCompoundIndex);
			bool isSame = isSameByIdsAndStructureRecursivly(reasonerInstance, compound, candidateCompound);
			if( isSame ) {
				return;
			}
		}
	}
	else {
		insertIntoHashtable = true;
	}

	if( insertIntoHashtable ) {
		compoundHashtable.insert(compoundIndex);
		wasInsertedIntoHashtable = true;
	}
}
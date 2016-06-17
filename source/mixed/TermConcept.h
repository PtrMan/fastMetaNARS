#pragma once

#include "TypedefsAndDefines.h"

enum class EnumTermConcept {
	CONCEPT = 0, // must be 0 for fast check
	TERM
};

// unifies the adress of a term or a concept into one value
// OPTIMISATION< in header for inlining >
struct TermConcept {
	static TermConcept makeTerm(ConceptTermIndexType index) {
		size_t numberOfBits = sizeof(ConceptTermIndexType) * 8;

		TermConcept result;
		result.folded = (1 << (numberOfBits - 1)) | index;
		return result;
	}

	static TermConcept makeConcept(ConceptTermIndexType index) {
		TermConcept result;
		result.folded = index;
		return result;
	}

	bool operator==(const TermConcept &rhs) {
		return folded == rhs.folded;
	}

	bool operator!=(const TermConcept &rhs) {
		return !this->operator==(rhs);
	}

	EnumTermConcept getType() {
		size_t numberOfBits = sizeof(ConceptTermIndexType) * 8;
		return static_cast<EnumTermConcept>(folded >> (numberOfBits - 1));
	}

	ConceptTermIndexType maskOutIndex() {
		return static_cast<ConceptTermIndexType>(-1) & folded;
	}
protected:
	ConceptTermIndexType folded; // highest bit encodes if its a term
};
#pragma once

#include <vector>
#include <memory>

using namespace std;

#include "UnifiedTerm.h"
#include "ClassicalConcept.h"


struct Configuration {
	float k;
};

struct UnifiedTerm;

// contains all information of a reasoner instance
struct ReasonerInstance {
	ReasonerInstance();

	vector<UnifiedTerm> unifiedTerms;

	TermId termIdCounter;
	Configuration configuration;

	Bag<shared_ptr<ClassicalConcept>> concepts;
	
	// OPTIMISATION< for inlining in header >
	const UnifiedTerm &accessTermByIndex(UnifiedTermIndex &index) const {
		return unifiedTerms[index.value];
	}

	// OPTIMISATION< for inlining in header >
	UnifiedTerm &accessTermByIndex(UnifiedTermIndex &index) {
		return unifiedTerms[index.value];
	}
protected:
};

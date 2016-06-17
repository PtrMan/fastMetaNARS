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
	
	const UnifiedTerm &accessTermByIndex(UnifiedTermIndex &index) const;
	UnifiedTerm &accessTermByIndex(UnifiedTermIndex &index);
protected:
};

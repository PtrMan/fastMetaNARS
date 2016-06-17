#include "ReasonerInstance.h"

ReasonerInstance::ReasonerInstance() {
	termIdCounter.value = 0x31337E; // initialize to a value which which we can easily test for assignment problems
}

const UnifiedTerm &ReasonerInstance::accessTermByIndex(UnifiedTermIndex &index) const {
	return unifiedTerms[index.value];
}

UnifiedTerm &ReasonerInstance::accessTermByIndex(UnifiedTermIndex &index) {
	return unifiedTerms[index.value];
}

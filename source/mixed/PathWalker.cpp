#include "PathWalker.h"

vector<UnifiedTermIndex> PathWalker::walk(const ReasonerInstance &reasonerInstance, const Path &path, const UnifiedTermIndex &entry) {
	vector<UnifiedTermIndex> walkedPath(path.descriptors.size());

	UnifiedTermIndex currentTermIndex = entry;

	for (const PathDescriptor &currentDescriptor : path.descriptors) {
		// ASK< do we have to push this or the next? >
		walkedPath.push_back(currentTermIndex);
		
		const UnifiedTerm currentNodeTerm = reasonerInstance.accessTermByIndex(currentTermIndex);

		UnifiedTermIndex nextTermIndex;

		switch (currentDescriptor.type) {
			case PathDescriptor::EnumType::LEFT:
			nextTermIndex = currentNodeTerm.left;
			break;
			
			case PathDescriptor::EnumType::RIGHT:
			nextTermIndex = currentNodeTerm.right;
			break;
			
			default: // TODO< throw something >
		}

		currentTermIndex = nextTermIndex;
	}

	return walkedPath;
}

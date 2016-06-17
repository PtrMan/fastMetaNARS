#include "PathWalker.h"

vector<UnifiedTermIndex> PathWalker::walk(const ReasonerInstance &reasonerInstance, const Path &path, const UnifiedTermIndex &entry) {
	vector<UnifiedTermIndex> walkedPath(path.descriptors.size());

	UnifiedTermIndex currentTermIndex = entry;

	for (const PathDescriptor &currentDescriptor : path.descriptors) {
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

		// ASK< do we have to push this or the next? >
		walkedPath.push_back(nextTermIndex);

		currentTermIndex = nextTermIndex;
	}

	return walkedPath;
}

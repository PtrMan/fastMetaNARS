#pragma once

#include <vector>
using namespace std;

#include "Path.h"
#include "ReasonerInstance.h"

struct PathWalker {
	static vector<UnifiedTermIndex> walk(const ReasonerInstance &reasonerInstance, const Path &path, const UnifiedTermIndex &entry);
};

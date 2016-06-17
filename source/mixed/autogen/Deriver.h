#pragma once

#include <vector>

using namespace std;

#include "ReasonerInstance.h"
#include "UnifiedTermIndex.h"

vector<UnifiedTerm> derive(ReasonerInstance &reasonerInstance, vector<UnifiedTermIndex> &leftPathTermIndices, vector<UnifiedTermIndex> &rightPathTermIndices, float k);

#pragma once

#include "DualStamp.h"
#include "UnifiedTermIndex.h"

const unsigned STAMP_NUMBEROFELEMENTS = 2 * 10;
const unsigned STAMP_BLOOMFILTERNUMBEROFBITS = 64 * 20;

struct ClassicalTask {
	UnifiedTermIndex unifiedTerm;

	// COMMENT PATRICK< every task has a stamp >
	DualStamp<STAMP_NUMBEROFELEMENTS, STAMP_BLOOMFILTERNUMBEROFBITS> stamp;
};

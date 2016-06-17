#pragma once


#include <stddef.h>     /* offsetof */

#include "FrequencyCertainty.h"
#include "UnifiedTermIndex.h"
#include "TermId.h"
#include "ReasonerInstance.h"

enum class EnumTermFlags {
	INHERITANCE_TOLEFT = 1, // <--
	INHERITANCE_TORIGHT = 2, // -->
};

struct ReasonerInstance;

struct UnifiedTerm {
	UnifiedTermIndex left, right;
	uint32_t termFlags; // EnumTermFlags
	TermId termId; // unique id of the term, is not GC'ed

	FrequencyCertainty frequencyCertainty;

	size_t termIndex; // gc'ed termIndex
	uint32_t cachedHash;

	void updateHash(ReasonerInstance &reasonerInstance);
};

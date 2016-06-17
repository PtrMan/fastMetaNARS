#pragma once

#include <cstdint>

// typesafe TermId type for the unique identification of a term
struct TermId {
	typedef uint32_t TermIdType;

	TermIdType value;
};

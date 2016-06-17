#pragma once

#include <memory>

using namespace std;

#include "Bag.h"
#include "ClassicalTask.h"
#include "ClassicalBelief.h"

struct ClassicalConcept {
	Bag<shared_ptr<ClassicalTask>> tasks;
	Bag<shared_ptr<ClassicalBelief>> beliefs;

	UnifiedTermIndex term; // mainly for debugging purposes
	uint32_t termHash; // unique hash of the term
};

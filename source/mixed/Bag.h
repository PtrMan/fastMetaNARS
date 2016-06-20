#pragma once

#include <memory>
#include <vector>
#include <array>
#include <cassert>
#include <algorithm>

using namespace std;

#include "TypedefsAndDefines.h"
#include "BinaryIndexTree.h"
#include "NumericHelper.h"

template<typename Type, typename PriorityType>
struct BagEntity {
	BagEntity() {
		priority = static_cast<PriorityType>(0);
	}

	BagEntity(Type value, PriorityType priority) {
		this->value = value;
		this->priority = priority;
	}

	PriorityType priority;
	Type value;
};

struct BagQuantisizedPrioritySelectorStrategyBinaryIndexTree {

};


template<typename Type, typename PriorityType = float, typename PrioritySelectorStrategy>
struct Bag {
	Bag() {
		prioritySumQuantisized = 0;
		usedElementsWithoutEndSpare = 0;
		endSpare = 0;
		sparePrioritySumQuantisized = 0;
		priorityQuantisation = static_cast<PriorityType>(0);
	}

	void setPriorityQuantisation(PriorityType priorityQuantisation) {
		this->priorityQuantisation = priorityQuantisation;
	}

	void setSize(size_t size) {
		// set size next power of two and guarantee that enough spare space is available

		unsigned numberOfBitsForSize = integerLog(size);
		size_t nextPowerOfTwoSize = 1 << numberOfBitsForSize;

		// assert that there is at least one element sparespace
		// NOTE< for an efficient working the space should be much much larger than 1 >
		assert(size < nextPowerOfTwoSize - 1);

		binaryIndexTree.setSize(nextPowerOfTwoSize);
		elements.resize(nextPowerOfTwoSize);
	}


	void put(Type element, PriorityType priority) {
		uint64_t quantisizedPriority = quantisizePriority(priority);

		prioritySumQuantisized += quantisizedPriority;

		// insert sort
		// TODO


		// replace with index and adding one to #
		elements[usedElements] = element;
		usedElementsWithoutEndSpare++;
	}

	// value is [0, 1]
	Type reference(PriorityType value) {
		size_t indexWithSpare = sampleWithSpare(value);
		return elements[indexWithSpare].value;
	}

	// the caller implementation can decide the policy how and when to call his in which interval
	void rebuild() {

	}
protected:
	uint64_t quantisizePriority(PriorityType priority) {
		return static_cast<uint64_t>(static_cast<PriorityType>(priority) / priorityQuantisation);
	}

	// value is [0, 1]
	size_t sampleWithSpare(PriorityType value) {
		uint64_t absoluteQuantisizedPriority = static_cast<uint64_t>(static_cast<double>(value) * static_cast<double>(prioritySumQuantisized));
		uint64_t absoluteQuantisizedPriorityWithSpare = absoluteQuantisizedPriority + sparePrioritySumQuantisized;

		bool found;
		size_t index = binaryIndexTree.find(absoluteQuantisizedPriorityWithSpare, found);
		assert(found);
		
		return index;
	}


	// helper
	// inspired by
	// http://stackoverflow.com/questions/446296/where-can-i-get-a-useful-c-binary-search-algorithm
	template<class Iter, class T, class Compare>
	static Iter binary_find(Iter begin, Iter end, const T &value, Compare comp) {
		// Finds the lower bound in at most log(last - first) + 1 comparisons
		Iter i = lower_bound(begin, end, value, comp);

		if (i != end && comp(*i, value))
			return i; // found
		else
			return end; // not found
	}

	vector<BagEntity<Type, PriorityType>> elements;

	BinaryIndexTree<uint64_t> binaryIndexTree;


	size_t usedElementsWithoutEndSpare;
	size_t endSpare; // how many elements at the ending are spare
	                   // we do ignore the first elements to save some time for rearanging the array in case of a droped element
	uint64_t sparePrioritySumQuantisized;

	uint64_t prioritySumQuantisized;
	PriorityType priorityQuantisation;
};


#pragma once

#include <memory>
#include <vector>
#include <array>
#include <cassert>

using namespace std;

#include "TypedefsAndDefines.h"
//#include "BinaryIndexTree.h"

template<typename Type, typename PriorityType>
struct BagEntity {
	BagEntity(Type value, PriorityType priority) {
		this->value = value;
		this->priority = priority;
	}

	PriorityType priority;
	Type value;
};

template<typename Type, typename PriorityType = float>
struct Bag {
	Bag() {
		prioritySum = static_cast<PriorityType>(0);
		usedElements = 0;
	}

	void setSize(size_t size, size_t minElementIndexDiff) {
		elements.resize(size);
		this->minElementIndexDiff = minElementIndexDiff;
	}


	void put(Type element, PriorityType priority) {
		prioritySum += priority;

		// replace with index and adding one to #
		elements[usedElements] = element;
		usedElements++;
	}

	// value is [0, 1]
	Type reference(PriorityType value) {
		size_t index = sample(value);
		return elements[index].value;
	}

	// the caller implementation can decide the policy how and when to call his in which interval
	// if elements get added to the bag the performance decreases linearly if this is not called regularly
	void rebuild() {
		rebuildInternal();
	}

	// for unittests public
	vector<BagEntity<Type, PriorityType>> elements;


protected:
	// we store the priorities in a binary tree (with absolute priority sums)
	struct PriorityBinaryTreeElement {
		PriorityType splitPrioritySum;

		size_t index;

		typedef unique_ptr< array<shared_ptr<PriorityBinaryTreeElement>, 2> > ChildrenType;

		// [0] is < splitPrioritySum
		// [1] is >=
		ChildrenType childrens;
	};

	// value is [0, 1]
	size_t sample(PriorityType value) {
		PriorityType absolutePriority = value * prioritySum;

		PriorityType accumulator;
		MachineType entryIndex = sampleSearchEntry(priorityBinaryTree, absolutePriority, accumulator);
		// TODO< handle # of added elements after "binary priority tree" rebuild
		for (MachineType i = entryIndex; i < min(elements.size(), entryIndex + minElementIndexDiff); i++) {
			if (accumulator > absolutePriority) {
				return i;
			}

			accumulator += elements[i].priority;
		}

		return elements.size() - 1;
	}

	// searches the entryfrom which the linear search should start from
	size_t sampleSearchEntry(shared_ptr<PriorityBinaryTreeElement> entry, PriorityType absolutePriority, PriorityType &priorityAtEntry) {
		if (!entry->childrens) {
			priorityAtEntry = entry->splitPrioritySum;
			return entry->index;
		}

		if (absolutePriority < entry->splitPrioritySum) {
			return sampleSearchEntry(entry->childrens[0], absolutePriority, priorityAtEntry);
		}
		else {
			return sampleSearchEntry(entry->childrens[1], absolutePriority, priorityAtEntry);
		}
	}

	void rebuildInternal() {
		priorityBinaryTree.reset();

		// check because usedElements-1 would be bad
		if (usedElements == 0) {
			return;
		}

		vector<PriorityType> accumulatedPriorities = calcAccumulatedPriorities();

		priorityBinaryTree = shared_ptr<PriorityBinaryTreeElement>(new PriorityBinaryTreeElement());
		rebuildInternalHelper(accumulatedPriorities, priorityBinaryTree, 0, usedElements - 1);
	}

	vector<PriorityType> calcAccumulatedPriorities() {
		assert(usedElements <= elements.size());

		vector<PriorityType> accumulatedPriorities(usedElements);

		PriorityType prioritySum = 0;
		for (size_t i = 0; i < usedElements; i++) {
			accumulatedPriorities[i] = prioritySum;
			prioritySum += elements[i].priority;
		}

		return accumulatedPriorities;
	}

	// rebuild binary tree
	void rebuildInternalHelper(const vector<PriorityType> &accumulatedPriorities, shared_ptr<PriorityBinaryTreeElement> entry, size_t indexMin, size_t indexMax) {
		assert(indexMin <= indexMax);

		size_t indexDiff = indexMax - indexMin;

		if (indexDiff <= minElementIndexDiff) {
			return;
		}

		size_t indexMid = indexMin + indexDiff / 2;

		entry->splitPrioritySum = accumulatedPriorities[indexMid];
		entry->childrens = PriorityBinaryTreeElement::ChildrenType(new array<shared_ptr<PriorityBinaryTreeElement>, 2>());
		entry->childrens->operator[](0) = shared_ptr<PriorityBinaryTreeElement>(new PriorityBinaryTreeElement());
		entry->childrens->operator[](1) = shared_ptr<PriorityBinaryTreeElement>(new PriorityBinaryTreeElement());

		rebuildInternalHelper(accumulatedPriorities, entry->childrens->operator[](0), indexMin, indexMid);
		rebuildInternalHelper(accumulatedPriorities, entry->childrens->operator[](1), indexMid, indexMax);
	}

	size_t usedElements;

	size_t minElementIndexDiff; // minimal number of elements from which a split for the priorityBinaryTree is done

	PriorityType prioritySum;

	// is allowed to be not that strictly binary at the end, any number of elements can be added at the end
	// without the need to update the tree
	// this has some performance impact
	// this means that the binaryTree should be rebuild from time to time
	shared_ptr<PriorityBinaryTreeElement> priorityBinaryTree;
};

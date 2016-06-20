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

	PriorityType getPriority() {
		return priority;
	}
	
	Type value;

protected:
	PriorityType priority;
};

struct BagQuantisizedPrioritySelectorStrategyBinaryIndexTree {
protected:
	typedef int64_t BinaryIndexTreeType;
public:
	// we offset the index by 1 because index 0 is illegal for the BinaryIndexTree

	void setSize(size_t size) {
		binaryIndexTree.setSize(size);
		reset(); // initialize
	}

	void reset() {
		binaryIndexTree.reset(); // initialize
	}

	void updateDelta(size_t index, BinaryIndexTreeType delta) {
		binaryIndexTree.update(index+ getBeginningUnusable(), delta);
	}

	size_t find(BinaryIndexTreeType cumFre, bool &found) {
		return binaryIndexTree.find(cumFre, found, BinaryIndexTree<BinaryIndexTreeType>::EnumFindType::ABOVE);
	}

	BinaryIndexTreeType readSingle(size_t index) {
		return binaryIndexTree.readSingle(index+ getBeginningUnusable());
	}

	size_t getBeginningUnusable() {
		return 1;
	}
protected:
	BinaryIndexTree<BinaryIndexTreeType> binaryIndexTree;

};


template<typename Type, typename PriorityType = float, typename PrioritySelectorStrategy = BagQuantisizedPrioritySelectorStrategyBinaryIndexTree>
struct Bag {
protected:
	struct SortReverseForStl {
		SortReverseForStl(Bag<Type, PriorityType, PrioritySelectorStrategy> *parent) {
			this->parent = parent;
		}

		bool operator() (const size_t& indexA, const size_t& indexB) {
			return parent->elements[indexA].getPriority() > parent->elements[indexB].getPriority();
		}

		Bag<Type, PriorityType, PrioritySelectorStrategy> *parent;
	};

	struct FindIndirectionTableEntryWherePriorityIsLargerThanHelper {
		FindIndirectionTableEntryWherePriorityIsLargerThanHelper(Bag<Type, PriorityType, PrioritySelectorStrategy> *parent) {
			this->parent = parent;
		}

		bool operator()(size_t indirectionTableIndexToCompare, PriorityType compareValue) {
			size_t indexInElements = parent->indirectionTable[indirectionTableIndexToCompare];
			assert(parent->elements[indexInElements]);

			// TODO< check for direction of comparation >
			return parent->elements[indexInElements]->getPriority() < compareValue;
		}

		Bag<Type, PriorityType, PrioritySelectorStrategy> *parent;
	};
public:
	typedef BagEntity<Type, PriorityType> BagEntityType;

	void setPriorityQuantisation(PriorityType priorityQuantisation) {
		this->priorityQuantisation = priorityQuantisation;
	}

	void setMaxSize(size_t size) {
		// set size next power of two and guarantee that enough spare space is available

		size_t nextPowerOfTwoSize = calcNextPowerOfTwo(size);

		// assert that there is at least one element sparespace
		// NOTE< for an efficient working the space should be much much larger than 1 >
		assert(size < nextPowerOfTwoSize - 1 - prioritySelectionStrategy.getBeginningUnusable());

		prioritySelectionStrategy.setSize(nextPowerOfTwoSize);
		resizeElementsAndNull(nextPowerOfTwoSize);
	}


	void put(shared_ptr<BagEntityType> element) {
		uint64_t quantisizedPriority = quantisizePriority(element->getPriority());

		prioritySumQuantisized += quantisizedPriority;

		// check if we need to rebuild
		if (isRebuildRequired()) {
			rebuild();
		}


		// insert sort
		vector<size_t>::iterator insertionIterator = findIndirectionTableEntryWherePriorityIsLargerThan(element->getPriority());
		bool wasFound = insertionIterator != indirectionTable.end();
		if (wasFound) {
			indirectionTable.insert(insertionIterator, usedElements);
		}
		else {
			indirectionTable.push_back(usedElements);
		}

		size_t &index = usedElements;

		// replace with index 
		elements[index] = element;

		// (reset) PrioritySelectorStrategy value
		assert(prioritySelectionStrategy.readSingle(index) == 0);
		prioritySelectionStrategy.updateDelta(index, quantisizedPriority);

		usedElements++;
	}

	// value is [0, 1]
	shared_ptr<BagEntityType> reference(PriorityType value) {
		assert(usedElements != 0); // invalid for empty bag

		size_t index = sampleWithSpare(value);
		return elements[index];
	}

	// callee calls this if one or more referenced elements changed its priority
	void rebuildBecausePrioritiesChanged() {
		std::sort(indirectionTable.begin(), indirectionTable.end(), SortReverseForStl(this));

		rebuild();
	}

	// the caller implementation can decide the policy how and when to call his in which interval
	void rebuild() {
		// make indirection table linear and throw away not referenced elements
		{
			// OPTIMISATION< preallocate and store this array so we dont have to reallocate all the time >
			vector<shared_ptr<BagEntityType>> newElements(elements.size());

			for (size_t i = 0; i < indirectionTable.size(); i++) {
				newElements[i] = elements[indirectionTable[i]];
			}

			for (size_t i = 0; i < indirectionTable.size(); i++) {
				indirectionTable[i] = i;
			}

			elements = newElements;

			usedElements = indirectionTable.size();
		}
		


		// repopulate PrioritySelectionStrategy
		{
			prioritySelectionStrategy.reset();

			for (size_t i = 0; i < indirectionTable.size(); i++) {
				// ASSUMPTION< indirectionTable == elements >
				assert(indirectionTable[i] == i);

				prioritySelectionStrategy.updateDelta(i, quantisizePriority(elements[i]->getPriority()));
			}
		}
	}

	size_t getSize() {
		return indirectionTable.size();
	}
protected:
	bool isRebuildRequired() {
		assert(usedElements <= elements.size() - prioritySelectionStrategy.getBeginningUnusable());
		return usedElements == elements.size() - prioritySelectionStrategy.getBeginningUnusable();
	}

	void resizeElementsAndNull(size_t nextPowerOfTwoSize) {
		elements.resize(nextPowerOfTwoSize);
		for (size_t i = 0; i < elements.size(); i++) {
			elements[i].reset();
		}

		indirectionTable.resize(0);
	}


	uint64_t quantisizePriority(PriorityType priority) {
		assert(priorityQuantisation != static_cast<PriorityType>(0));
		return static_cast<uint64_t>(static_cast<PriorityType>(priority) / priorityQuantisation);
	}

	// value is [0, 1]
	size_t sampleWithSpare(PriorityType value) {
		unsigned quantisizedPriorityValue = quantisizePriority(value);


		// we can just sample because removed elements do have a quantisized priority of zero,
		// we just have to be careful to not return a null entry

		bool found;
		size_t index = prioritySelectionStrategy.find(quantisizedPriorityValue, found);
		if (!found) {
			return usedElements - 1;
		}

		// search the next element which is not null
		for (;;) {
			if (index >= elements.size()) {
				// TODO< throw something >

				// internal error, should never happen
				assert(false);
			}

			if (elements[index]) {
				return index;
			}

			index++;
		}

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


	vector<size_t>::iterator findIndirectionTableEntryWherePriorityIsLargerThan(PriorityType value) {
		vector<size_t>::iterator searchResultIterator = binary_find(indirectionTable.begin(), indirectionTable.end(), value, FindIndirectionTableEntryWherePriorityIsLargerThanHelper(this));
		return searchResultIterator;
	}




	// helper, TODO< move to IntegerTools >
	static unsigned calcNextPowerOfTwo(unsigned value) {
		unsigned numberOfBits = integerLog(value);
		return 1 << (numberOfBits + 1);
	}




	vector<shared_ptr<BagEntityType>> elements;
	size_t usedElements = 0;

	// this table stores the indices of the priority sorted elements
	// this is sorted in reverse (last elements have smallest priority)
	// this is for fast removal
	vector<size_t> indirectionTable;

	uint64_t prioritySumQuantisized = 0;
	PriorityType priorityQuantisation = static_cast<PriorityType>(0);

	PrioritySelectorStrategy prioritySelectionStrategy;
};


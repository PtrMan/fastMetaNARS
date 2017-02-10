module fastMetaNars.memory.ArrayBag;

import std.stdint;
import std.random : uniform;
import std.exception : enforce;

import std.algorithm.mutation : remove;
import std.algorithm.sorting : sort;

import fastMetaNars.memory.Bag;

// slow but (hopefully) correct implementation of a bag
class ArrayBag(E, K) : Bag!(E, K) {
	final void setPriorityQuantisation(float priorityQuantisation) {
		this.priorityQuantisation = priorityQuantisation;
	}


	final E take(K key) {
		foreach( i, iElement; elements ) {
			if( iElement.name == key ) {
				elements = elements.remove(i);
				return iElement;
			}
		}

		return null;
	}

	final E reference() {
		enforce(elements.length > 0, "reference() called on empty ArrayBag");

		size_t index = uniform(0, elements.length);
		return elements[index];
	}

	// value is [0, 1]
	//BagEntity reference(PriorityType value);

	// the number of items in the bag
	final @property size_t size() {
		return elements.length;
	}

	final void clear() {
		elements.length = 0;

		prioritySumQuantisized = 0;
	}

	/**
     * Insert an item into the bag, and return the overflow
     *
     * \param newItem The Item to put in
     * \return The overflow Item, or null if nothing displaced
     */
    final E addItem(E element) {
		uint64_t quantisizedPriorityInt = quantisizePriority(element.budget.priority);
		prioritySumQuantisized += quantisizedPriorityInt;

		elements ~= element;

		if (elements.length > maxSize) {
			elements.sort(); // TODO 09.02.2017< do we sort in the right order here? >
			E overflowElement = elements[maxSize];
			elements.length = maxSize;
			return overflowElement;
		}

		return null; // no overflow
	}

	// value is [0, 1]
	/* uncommented because abstract Bag lass has to be overhauled that it supports this fast method
	final BagEntity reference(float value) {
		size_t index = sample(value);
		return elements[index];
	}
	*/

	final void setMaxSize(size_t size) {
		maxSize = size;
	}
	
	protected final uint64_t quantisizePriority(float priority) {
		return cast(uint)(priority / priorityQuantisation);
	}

	protected float priorityQuantisation = cast(float)(0.001);
	
	// superslow algorithm
	// value is [0, 1]
	/* uncommented because it's not used, code should work fine
	protected final size_t sample(float value) {
		int64_t absolutePriority = cast(int64_t)(value * cast(float)(prioritySumQuantisized));

		int64_t accumulator = 0.0f;
		for( size_t i = 0; i < elements.length; i++ ) {
			// simulate what our bag does with the quantisation
			unsigned quantisizedPriorityInt = quantisizePriority(elements[i].getPriority());
			accumulator += quantisizedPriorityInt;
			
			if (accumulator >= absolutePriority) {
				return i;
			}

			
		}

		return elements.length - 1;
	}
	*/

	protected E[] elements;

	protected uint64_t prioritySumQuantisized = 0;

	protected size_t maxSize;
}

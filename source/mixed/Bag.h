#pragma once

#include <vector>

using namespace std;

template<typename Type>
struct BagEntity {
	BagEntity(Type value, float priority) {
		this->value = value;
		this->priority = priority;
	}

	float priority;
	Type value;
};

template<typename Type>
struct Bag {
	void put(Type element, float priority) {
		prioritySum += priority;
		elements.push_back(BagEntity<Type>(element, priority));
	}

	// value is [0, 1]
	Type reference(float value) {
		size_t index = sample(value);
		return elements[index].value;
	}

protected:


	// superslow algorithm
	// TODO< replace it with something faster >

	// value is [0, 1]
	size_t sample(float value) {
		float absolutePriority = value * prioritySum;

		float accumulator = 0.0f;
		for (MachineType i = 0; i < elements.size(); i++) {
			if (accumulator > absolutePriority) {
				return i;
			}

			accumulator += elements[i].priority;
		}

		return elements.size() - 1;
	}

	vector<BagEntity<Type>> elements;



	float prioritySum;
};

#include "gtest/gtest.h"

#include "Bag.h"

// simple bag implementation for comparision
template<typename Type>
struct CompareCorrectBag {
	CompareCorrectBag() {
		prioritySum = static_cast<float>(0);
	}

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






int main() {
	cout << "Hello World" << endl;

	Bag<unsigned> bagUnderTests;
	CompareCorrectBag<unsigned> bagCorrect;

	size_t bagSize = 100;
	size_t minElementIndexDiff = 5;
	bagUnderTests.setSize(bagSize, minElementIndexDiff);


	size_t numberOfElements = 0;

	for (size_t i = 0; i < 98; i++) {
		// TODO< use rng and do action >



		// check if bags are equal
		bool bagsAreEqual = areBagsEqual(0.001f, bagUnderTests, bagCorrect);
		if (!bagsAreEqual) {
			cout << "Failed(before rebuild) ", i << endl;
			return;
		}

		if (i % 20 == 0) {
			// rebuild tree structure
			bagUnderTests.rebuild();
		}

		// check if bags are equal
		bool bagsAreEqual = areBagsEqual(0.001f, bagUnderTests, bagCorrect);
		if (!bagsAreEqual) {
			cout << "Failed(after rebuild) ", i << endl;
			return;
		}

	}



	return 0;
}



// TODO< write unittests >

int main(int argc, char **argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}

#include "gtest/gtest.h"

#include "Bag.h"

//#include "tests/TestBinaryIndexTree.cpp"

void testBinaryIndexTree2() {
	BinaryIndexTree<int64_t> tree;
	tree.setSize(8);
	tree.reset();

	tree.update(1, 10);
	tree.update(1, 5);
	//tree.update(2, 4);
	//tree.update(3, 5);

	for (size_t i = 11; i < 11; i++) {
		bool found;
		cout << "binaryIndexTree test:  i " << i << "  index " << tree.find(i, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
		cout << "found " << found;
		cout << endl;
	}

	int debug = 1;
}


// simple bag implementation for comparision
template<typename Type>
struct CompareCorrectBag {
	void setPriorityQuantisation(float priorityQuantisation) {
		this->priorityQuantisation = priorityQuantisation;
	}

	void put(shared_ptr<BagEntity<Type, float>> element) {
		unsigned quantisizedPriorityInt = quantisizePriority(element->getPriority());
		prioritySumQuantisized += quantisizedPriorityInt;

		elements.push_back(element);
	}

	// value is [0, 1]
	shared_ptr<BagEntity<Type, float>> reference(float value) {
		size_t index = sample(value);
		return elements[index];
	}

	
protected:
	uint64_t quantisizePriority(float priority) {
		return static_cast<unsigned>(priority / priorityQuantisation);
	}


	float priorityQuantisation = static_cast<float>(0.001);
	
	// superslow algorithm
	// value is [0, 1]
	size_t sample(float value) {
		int64_t absolutePriority = static_cast<int64_t>(value * static_cast<float>(prioritySumQuantisized));

		int64_t accumulator = 0.0f;
		for (MachineType i = 0; i < elements.size(); i++) {
			if (accumulator > absolutePriority) {
				return i;
			}

			// simulate what our bag does with the quantisation
			unsigned quantisizedPriorityInt = quantisizePriority(elements[i]->getPriority());
			accumulator += quantisizedPriorityInt;
		}

		return elements.size() - 1;
	}

	vector<shared_ptr<BagEntity<Type, float>>> elements;

	uint64_t prioritySumQuantisized = 0;
};



bool areBagsEqual(float sampleGranularity, Bag<unsigned> &bagUnderTest, CompareCorrectBag<unsigned> &bagCorrect) {
	for (float i = 0.0f; i < 1.0f; i += sampleGranularity) {
		bool isEqual = bagUnderTest.reference(i)->value == bagCorrect.reference(i)->value;
		if (!isEqual) {
			cout << "expected " << bagCorrect.reference(i)->value << endl;
			cout << "actual   " << bagUnderTest.reference(i)->value << endl;

			return true;
		}
	}
	return true;
}

#include <iostream>
using namespace std;

/*
int main() {
	//testBinaryIndexTree2();



	Bag<unsigned> bagUnderTests;
	CompareCorrectBag<unsigned> bagCorrect;

	size_t bagSize = 100;
	bagUnderTests.setMaxSize(bagSize);

	float priorityQuantisation = 0.01f;
	bagUnderTests.setPriorityQuantisation(priorityQuantisation);
	bagCorrect.setPriorityQuantisation(priorityQuantisation);


	size_t numberOfElements = 0;

	for (size_t i = 0; i < 98; i++) {
		// TODO< use rng and do action >

		shared_ptr<BagEntity<unsigned, float>> elementToAdd1, elementToAdd2;
		elementToAdd1 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, 0.1f));
		elementToAdd2 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, 0.1f));

		bagUnderTests.put(elementToAdd1);
		bagCorrect.put(elementToAdd1);

		cout << "i " << i << endl;

		// check if bags are equal
		bool bagsAreEqual = areBagsEqual(0.05f, bagUnderTests, bagCorrect);
		if (!bagsAreEqual) {
			cout << "Failed(before rebuild) " << i << endl;
			return 1;
		}

		if (i % 20 == 0) {
			// rebuild tree structure
			bagUnderTests.rebuild();
		}

		// check if bags are equal
		bagsAreEqual = areBagsEqual(0.05f, bagUnderTests, bagCorrect);
		if (!bagsAreEqual) {
			cout << "Failed(after rebuild) " << i << endl;
			return 1;
		}

	}



	return 0;
}
*/



// TODO< write unittests >


int main(int argc, char **argv) {
	::testing::InitGoogleTest(&argc, argv);
	int unittestResult = RUN_ALL_TESTS();
	return unittestResult;
}

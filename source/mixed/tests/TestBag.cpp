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

		if (elements.size() > maxSize) {
			std::sort(elements.begin(), elements.end(), std::less);
			elements.resize(maxSize);
		}
	}

	// value is [0, 1]
	shared_ptr<BagEntity<Type, float>> reference(float value) {
		size_t index = sample(value);
		return elements[index];
	}

	void setMaxSize(size_t size) {
		maxSize = size;
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
			// simulate what our bag does with the quantisation
			unsigned quantisizedPriorityInt = quantisizePriority(elements[i]->getPriority());
			accumulator += quantisizedPriorityInt;
			
			if (accumulator >= absolutePriority) {
				return i;
			}

			
		}

		return elements.size() - 1;
	}

	vector<shared_ptr<BagEntity<Type, float>>> elements;

	uint64_t prioritySumQuantisized = 0;

	size_t maxSize;
};



void checkBagsEqual(float sampleGranularity, Bag<unsigned> &bagUnderTest, CompareCorrectBag<unsigned> &bagCorrect) {
	for (float i = 0.0f; i < 1.0f; i += sampleGranularity) {
		ASSERT_EQ(bagUnderTest.reference(i)->value, bagCorrect.reference(i)->value);
	}
}

void checkBagsEqualByMarkingElements(size_t checkSize, float sampleGranularity, Bag<unsigned> &bagUnderTest, CompareCorrectBag<unsigned> &bagCorrect) {
	vector<bool> checkForUnderTest(checkSize), checkForCorrect(checkSize);

	for (size_t i = 0; i < checkForUnderTest.size(); i++) {
		checkForUnderTest[i] = false;
		checkForCorrect[i] = false;
	}
	
	for (float i = 0.0f; i < 1.0f; i += sampleGranularity) {
		checkForUnderTest[bagUnderTest.reference(i)->value] = true;
	}

	for (float i = 0.0f; i < 1.0f; i += sampleGranularity) {
		checkForCorrect[bagCorrect.reference(i)->value] = true;
	}

	for (size_t i = 0; i < checkSize; i++) {
		ASSERT_EQ(checkForUnderTest[i], checkForCorrect[i]);
	}
}


#include <iostream>
using namespace std;



// TODO< test that it sorts it correctly (from big priority to low priority) >




TEST(BagTest, fillNotOversaturated) {

	Bag<unsigned> bagUnderTests;
	CompareCorrectBag<unsigned> bagCorrect;

	size_t bagSize = 20;
	bagUnderTests.setMaxSize(bagSize);
	bagCorrect.setMaxSize(bagSize);

	float priorityQuantisation = 0.01f;
	bagUnderTests.setPriorityQuantisation(priorityQuantisation);
	bagCorrect.setPriorityQuantisation(priorityQuantisation);


	for (size_t i = 0; i < bagSize-1; i++) {
		shared_ptr<BagEntity<unsigned, float>> elementToAdd1, elementToAdd2;
		elementToAdd1 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, 0.1f));
		elementToAdd2 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, 0.1f));

		bagUnderTests.put(elementToAdd1);
		bagCorrect.put(elementToAdd1);

		ASSERT_EQ(bagUnderTests.getSize(), bagCorrect.getSize());

		cout << "i " << i << endl;

		checkBagsEqual(0.05f, bagUnderTests, bagCorrect);

		if (i % 20 == 0) {
			// rebuild tree structure
			bagUnderTests.rebuild();
		}

		ASSERT_EQ(bagUnderTests.getSize(), bagCorrect.getSize());

		checkBagsEqual(0.05f, bagUnderTests, bagCorrect);

	}
}





TEST(BagTest, fillOversaturated) {

	Bag<unsigned> bagUnderTests;
	CompareCorrectBag<unsigned> bagCorrect;

	size_t bagSize = 20;
	bagUnderTests.setMaxSize(bagSize);
	bagCorrect.setMaxSize(bagSize);

	float priorityQuantisation = 0.01f;
	bagUnderTests.setPriorityQuantisation(priorityQuantisation);
	bagCorrect.setPriorityQuantisation(priorityQuantisation);


	for (size_t i = 0; i < bagSize*2; i++) {
		// TODO< use rng and do action >

		shared_ptr<BagEntity<unsigned, float>> elementToAdd1, elementToAdd2;
		elementToAdd1 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, static_cast<float>(i+1)*0.1f));
		elementToAdd2 = make_shared<BagEntity<unsigned, float>>(BagEntity<unsigned, float>(i, static_cast<float>(i+1)*0.1f));

		bagUnderTests.put(elementToAdd1);
		bagCorrect.put(elementToAdd1);

		ASSERT_EQ(bagUnderTests.getSize(), bagCorrect.getSize());

		cout << "i " << i << endl;

		checkBagsEqualByMarkingElements(bagSize*2, 0.05f, bagUnderTests, bagCorrect);

		if (i % 20 == 0) {
			// rebuild tree structure
			bagUnderTests.rebuild();
		}

		ASSERT_EQ(bagUnderTests.getSize(), bagCorrect.getSize());

		checkBagsEqualByMarkingElements(bagSize * 2, 0.05f, bagUnderTests, bagCorrect);

	}
}



int main(int argc, char **argv) {
	::testing::InitGoogleTest(&argc, argv);
	int unittestResult = RUN_ALL_TESTS();
	return unittestResult;
}

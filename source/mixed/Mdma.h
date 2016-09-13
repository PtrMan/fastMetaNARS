#include <array>

using namespace std;

// T-MDMA stands for "temporal multi interdependency macrosearch algorithm"

template<size_t Size>
struct MdmaTrace {
	MdmaTrace() {
		currentIndex = 0;

		for(size_t i = 0; i < Size; i++ ) {
			rating[i] = 0.0f;
		}
	}

	// the stored rating indicate the frequecy of the observation of the event in that timestep
	array<float, Size> rating;
	size_t currentIndex;

	void mulAddAndAdvance(float add, float scale) {
		rating[currentIndex] = rating[currentIndex] * scale + add;
		currentIndex++;
		if( currentIndex == Size ) {
			currentIndex = 0;
		}
	}
};



template <size_t Size>
struct MdmaVector {
	
	void mulAddAndAdvance(float add, float scale) {
		trace.mulAddAndAdvance(add, scale);
		children.mulAddAndAdvance(add, scale);
	}
protected:
	MdmaTrace<Size> trace;
	MdmaVector<Size-1> children;
};

// we don't want to trace size 1 because it doesn't make any sense
template <>
struct MdmaVector<1>  {
	void mulAddAndAdvance(float add, float scale) {
    }
};



/*
struct Mdma {
	
	// TODO< multiple vectors
	MdmaVector<10> vector;
};
*/

// for testing
void mulAddAndAdvanceTest(MdmaVector<50> &mdmaVector, float add, float scale) {
	mdmaVector.mulAddAndAdvance(add, scale);
}

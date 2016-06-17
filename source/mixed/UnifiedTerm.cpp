#include "UnifiedTerm.h"

#include <vector>
#include <cassert>

using namespace std;

#include "Murmur.h"

void UnifiedTerm::updateHash(ReasonerInstance &reasonerInstance) {
	size_t numberOfTerms = 2;


	uint32_t seed = 23;


	// assert that the sizes match up, because we cast it and put it into the vector
	assert(sizeof(termFlags) == sizeof(reasonerInstance.accessTermByIndex(left).cachedHash)); // sizeof(decltype(termFlags)));
																// vector with the values which we need to hash
	vector<decltype(termFlags)> hashVector(/* termId */1 + /* flags */1 + numberOfTerms);
	hashVector[0] = static_cast<decltype(termFlags)>(termId.value);
	hashVector[1] = static_cast<decltype(termFlags)>(termFlags);

	hashVector[2] = static_cast<decltype(termFlags)>(reasonerInstance.accessTermByIndex(left).cachedHash);
	hashVector[3] = static_cast<decltype(termFlags)>(reasonerInstance.accessTermByIndex(right).cachedHash);

	cachedHash = murmur3_32(reinterpret_cast<char*>(hashVector.data()), hashVector.size() * sizeof(decltype(termFlags)), seed);
}

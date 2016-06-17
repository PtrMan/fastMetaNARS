#pragma once

// used to describe a path through terms to go from one term to another
struct PathDescriptor {
	enum class EnumType {
		LEFT,
		RIGHT,
		// TODO LATER< CHILDRENVECTOR >
	};

	EnumType type;
	// TODO LATER< size_t childrenVectorIndex; > 
};

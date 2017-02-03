module fastMetaNars.ClassicalConcept;

import fastMetaNars.ClassicalTaskLink;
import fastMetaNars.ClassicalBelief;
import fastMetaNars.IBag;

struct ClassicalConcept {
	IBag!(ClassicalTaskLink*, float) tasks;
	IBag!(ClassicalBelief*, float) beliefs;

	// this must all be either an term or statement
	//UnifiedTermIndex term; // mainly for debugging purposes
	//uint32_t termHash; // unique hash of the term
}

module fastMetaNars.ClassicalTask;

import fastMetaNars.ClassicalSentence;

// see https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/Task.java
struct ClassicalTask {
	ClassicalSentence sentence;

	ClassicalTask *parentTask; // must behave like weakptr, else we violate AIKR

	ClassicalSentence bestSolution; // for question and goal: best solution found so far

	bool isInput; // is it an input task

	// holds all temporal related information like for example
	// * input chaining, ow long is the temporal difference to the input tasks before it
	static struct TemporalInformation {
		static struct Chaining {
			ClassicalTask *taskBefore;
			uint deltaTime; // in system steps
			bool withGap; // was there a gap between this and the previous task
			              // has the AI forgotten a task between taskBefore and this
			bool isImmediatePrecursor; // is taskBefore the task which was received directly before this task
		}

		Chaining[] chainingSkiplist; // NOTE< if an task is removed we have to maintain this list too >
		                             // NOTE< currntly we maintain only a single linked list >
	}

	TemporalInformation temporalInformation;
}

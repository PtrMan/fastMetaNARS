module fastMetaNars.entity.ClassicalBelief;

import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.entity.Item;

class ClassicalBelief : Item!TermOrCompoundTermOrVariableReferer  {
	// term with an path from the concept where it's occuring in that concept
	// https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/Concept.java#L91
	TermOrCompoundTermOrVariableReferer term;

	// holds all temporal related information like for example
	// * input chaining, how long is the temporal difference to the input tasks before it
	static struct TemporalInformation {
		static struct Chaining {
			ClassicalBelief *beliefBefore;
			uint deltaTime; // in system steps
			bool withGap; // was there a gap between this and the previous task
			              // has the AI forgotten a task between taskBefore and this
			bool isImmediatePrecursor; // is taskBefore the task which was received directly before this task
		}

		Chaining[] chainingSkiplist; // NOTE< if an task is removed we have to maintain this list too >
		                             // NOTE< currntly we maintain only a single linked list >
	}

	TemporalInformation temporalInformation;

	final override @property TermOrCompoundTermOrVariableReferer name() {
		return term;
	}
}

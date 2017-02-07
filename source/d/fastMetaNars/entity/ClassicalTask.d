module fastMetaNars.entity.ClassicalTask;

import fastMetaNars.entity.ClassicalSentence;
import fastMetaNars.entity.Item;

// see https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/Task.java
class ClassicalTask : Item!(ClassicalSentence) {
	ClassicalSentence sentence;

	ClassicalTask parentTask; // must behave like weakptr, else we violate AIKR

	ClassicalSentence bestSolution; // for question and goal: best solution found so far

	bool isInput; // is it an input task


	override @property ClassicalSentence name() {
		return sentence;
	}
}

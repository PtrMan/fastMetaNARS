module fastMetaNars.ClassicalConcept;

import fastMetaNars.ClassicalTask;
import fastMetaNars.ClassicalTaskLink;
import fastMetaNars.ClassicalBelief;
import fastMetaNars.entity.ClassicalTermLink;
import fastMetaNars.memory.Bag;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.entity.Item;

class ClassicalConcept : Item!TermOrCompoundTermOrVariableReferer {
	Bag!(ClassicalTaskLink, ClassicalTask) tasks;
	Bag!(ClassicalBelief, ClassicalTermLink) beliefs;

	// this must all be either an term or statement
	TermOrCompoundTermOrVariableReferer term;

	override @property TermOrCompoundTermOrVariableReferer name() {
		return term;
	}
}

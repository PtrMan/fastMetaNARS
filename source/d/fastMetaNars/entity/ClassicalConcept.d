module fastMetaNars.entity.ClassicalConcept;

import fastMetaNars.entity.ClassicalTask;
import fastMetaNars.entity.ClassicalTaskLink;
import fastMetaNars.entity.ClassicalBelief;
//import fastMetaNars.entity.ClassicalTermLink;
import fastMetaNars.memory.Bag;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.entity.Item;

class ClassicalConcept : Item!TermOrCompoundTermOrVariableReferer {
	Bag!(ClassicalTaskLink, ClassicalTask) tasks;
	Bag!(ClassicalBelief, TermOrCompoundTermOrVariableReferer) beliefs;

	// this must all be either an term or statement
	TermOrCompoundTermOrVariableReferer term;

	override @property TermOrCompoundTermOrVariableReferer name() {
		return term;
	}
}

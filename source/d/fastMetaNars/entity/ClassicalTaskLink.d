module fastMetaNars.entity.ClassicalTaskLink;

import fastMetaNars.entity.ClassicalTask;
import fastMetaNars.entity.Item;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/TaskLink.java
/**
 * Reference to a Task.
 * 
 * The reason to separate a Task and a TaskLink is that the same Task can be
 * linked from multiple Concepts, with different BudgetValue.
 * 
 * TaskLinks are unique according to the Task they reference
 */
class ClassicalTaskLink : Item!ClassicalTask {
	ClassicalTask targetTask;

    override @property ClassicalTask name() {
		return targetTask;
	}
}

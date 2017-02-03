module fastMetaNars.ClassicalTaskLink;

import fastMetaNars.ClassicalTask;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/entity/TaskLink.java
/**
 * Reference to a Task.
 * 
 * The reason to separate a Task and a TaskLink is that the same Task can be
 * linked from multiple Concepts, with different BudgetValue.
 * 
 * TaskLinks are unique according to the Task they reference
 */
struct ClassicalTaskLink {
	ClassicalTask* targetTask;
}

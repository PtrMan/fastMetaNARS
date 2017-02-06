module fastMetaNars.control.WorkingCyclish;

import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.memory.Bag;
import fastMetaNars.ClassicalConcept;

/**
 * stores the global concepts
 * is conceptually something between the details of the working cycle and the memory
 *
 * see https://github.com/opennars/opennars/blob/1.6.5_devel17_TonyAnticipationStrategy/nars_core/nars/control/WorkingCycle.java
 * for OpenNars 1.6.x inspiration
 */
class WorkingCyclish {
	// only the term or compound term is refered (for lookup)
	Bag!(ClassicalConcept,TermOrCompoundTermOrVariableReferer) concepts;
}

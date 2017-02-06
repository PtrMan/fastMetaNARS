module fastMetaNars.entity.ClassicalTermLink;

import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.entity.Item;

// inspired by https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/entity/TermLink.java
// provides the Item functionality and holds the information where the term was mentioned in the target
class ClassicalTermLink : Item!TermOrCompoundTermOrVariableReferer {
	TermOrCompoundTermOrVariableReferer target; /** The linked Term */

	// TODO< index where it was mentioned in the term >
}
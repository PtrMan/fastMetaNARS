module fastMetaNars.entity.builder.BagBuilder;

import fastMetaNars.memory.Bag;
import fastMetaNars.memory.ArrayBag;
import fastMetaNars.entity.ClassicalTaskLink;
import fastMetaNars.entity.ClassicalTask;

// used to create bags
class BagBuilder {
	final Bag!(ClassicalTaskLink, ClassicalTask) createForConcept_tasksBag() {
		// TODO< make this dependent on variables
		Bag!(ClassicalTaskLink, ClassicalTask) result = new ArrayBag!(ClassicalTaskLink, ClassicalTask);
		result.setMaxSize(10);
		return result;
	}
	
}

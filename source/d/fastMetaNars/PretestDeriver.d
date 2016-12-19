import fastMetaNars.deriver.DeriverCaller;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.ReasonerInstance;

void main() {
	ReasonerInstance reasonerInstance = new ReasonerInstance;

	// allocate room for tuples
	reasonerInstance.termTuples.length = 2;

	// add test compounds
	reasonerInstance.compounds.length = 6;

	reasonerInstance.humanReadableConcepts.length = 3;
	reasonerInstance.humanReadableConcepts[0] = "a";
	reasonerInstance.humanReadableConcepts[1] = "b";
	reasonerInstance.humanReadableConcepts[2] = "c";

	reasonerInstance.configuration.maximalTermComplexity = 50;	

	

	reasonerInstance.compounds[0].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(0);
	reasonerInstance.compounds[1].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(1);
	reasonerInstance.compounds[2].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(2);
	//reasonerInstance.compounds[3].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(3);

	reasonerInstance.termTuples[0].compoundIndices = [TermOrCompoundTermOrVariableReferer.makeAtomic(0), TermOrCompoundTermOrVariableReferer.makeAtomic(2)];
	reasonerInstance.termTuples[1].compoundIndices = [TermOrCompoundTermOrVariableReferer.makeAtomic(1), TermOrCompoundTermOrVariableReferer.makeAtomic(2)];

	reasonerInstance.compounds[4].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeNonatomic(4);
	reasonerInstance.compounds[4].flagsOfCopula = FlagsOfCopula.makeInheritance();
	reasonerInstance.compounds[4].termTupleIndex = 0;
	reasonerInstance.compounds[5].thisTermReferer = TermOrCompoundTermOrVariableReferer.makeNonatomic(5);
	reasonerInstance.compounds[5].flagsOfCopula = FlagsOfCopula.makeInheritance();
	reasonerInstance.compounds[5].termTupleIndex = 0;

	deriverCaller(reasonerInstance, 4, 5, false);
}

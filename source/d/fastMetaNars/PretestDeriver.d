import fastMetaNars.deriver.DeriverCaller;
import fastMetaNars.FlagsOfCopula;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.ReasonerInstance;
import fastMetaNars.Term;

void main() {
	ReasonerInstance reasonerInstance = new ReasonerInstance;

	// add test compounds

	reasonerInstance.humanReadableConcepts.length = 3;
	reasonerInstance.humanReadableConcepts[0] = "a";
	reasonerInstance.humanReadableConcepts[1] = "b";
	reasonerInstance.humanReadableConcepts[2] = "c";

	reasonerInstance.configuration.maximalTermComplexity = 50;	

	{
		Compound compound;
		compound.thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(0);
		compound.compoundId = 0;
		reasonerInstance.addCompound(compound);
	}

	{
		Compound compound;
		compound.thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(1);
		compound.compoundId = 1;
		reasonerInstance.addCompound(compound);
	}

	{
		Compound compound;
		compound.thisTermReferer = TermOrCompoundTermOrVariableReferer.makeAtomic(2);
		compound.compoundId = 2;
		reasonerInstance.addCompound(compound);
	}

	reasonerInstance.addTermTupleByReferers([TermOrCompoundTermOrVariableReferer.makeAtomic(0), TermOrCompoundTermOrVariableReferer.makeAtomic(2)]);
	reasonerInstance.addTermTupleByReferers([TermOrCompoundTermOrVariableReferer.makeAtomic(1), TermOrCompoundTermOrVariableReferer.makeAtomic(2)]);

	{
		Compound compound;
		compound.thisTermReferer = TermOrCompoundTermOrVariableReferer.makeNonatomic(3);
		compound.flagsOfCopula = FlagsOfCopula.makeInheritance();
		compound.termTupleIndex = 0;
		compound.compoundId = 3;
		
		reasonerInstance.addCompound(compound);
	}

	{
		Compound compound;
		compound.thisTermReferer = TermOrCompoundTermOrVariableReferer.makeNonatomic(4);
		compound.flagsOfCopula = FlagsOfCopula.makeInheritance();
		compound.termTupleIndex = 0;
		compound.compoundId = 4;
		
		reasonerInstance.addCompound(compound);
	}

	deriverCaller(reasonerInstance, 3, 4, false);
}

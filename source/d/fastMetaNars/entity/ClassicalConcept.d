module fastMetaNars.entity.ClassicalConcept;

import std.algorithm.mutation : remove;

import fastMetaNars.entity.ClassicalSentence;
import fastMetaNars.entity.ClassicalTask;
import fastMetaNars.entity.ClassicalTaskLink;
import fastMetaNars.entity.ClassicalBelief;
//import fastMetaNars.entity.ClassicalTermLink;
import fastMetaNars.memory.Bag;
import fastMetaNars.TermOrCompoundTermOrVariableReferer;
import fastMetaNars.entity.Item;
import fastMetaNars.entity.builder.BagBuilder;
import fastMetaNars.control.DerivationContext;

class ClassicalConcept : Item!TermOrCompoundTermOrVariableReferer {
	Bag!(ClassicalTaskLink, ClassicalTask) tasks;
	//uncommented because of some termLink/belief confusion  Bag!(ClassicalBelief, TermOrCompoundTermOrVariableReferer) termLinks;

	/**
     * Judgments directly made about the term 
     *
     * Uses Array because of access and insertion in the middle
     */
    ClassicalTask[] beliefs;


	// this must all be either an term or statement
	TermOrCompoundTermOrVariableReferer term;

	final this(TermOrCompoundTermOrVariableReferer term, BagBuilder bagBuilder) {
		tasks = bagBuilder.createForConcept_tasksBag();
		//termLinks = bagBuilder.createForConcept_termLinksBag();

		this.term = term;
	}

	override @property TermOrCompoundTermOrVariableReferer name() {
		return term;
	}


	// see https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/entity/Concept.java
	/**
     * Select a belief to interact with the given task in inference
     * 
     * get the first qualified one
     *
     * \param task The selected task
     * \return The selected isBelief
     */
    public final ClassicalSentence *getBelief(DerivationContext *nal, ClassicalTask task) {
        ClassicalSentence taskSentence = task.sentence;

        foreach( i, ClassicalTask iBelief; beliefs ) {
        	ClassicalSentence beliefSentence = iBelief.sentence;

        	// uncommented because event mechanism is not in place jet
        	//nal.emit(EnumXXX.BELIEF_SELECT, iBelief);

        	return &beliefs[i].sentence;
        }
        return null;
    }

    // TODO 09.02.2017 : use this to limit the # of beliefs
    // see https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/entity/Concept.java#L732
    /**
     * Add a new belief (or goal) into the table Sort the beliefs/desires by
     * rank, and remove redundant or low rank one
     *
     * \param newSentence The judgment to be processed
     * \param table The table to be revised
     * \param capacity The capacity of the table
     * \return whether table was modified
     */
    /+ uncommented because not completely translated to D and because some helper functions are missing
    public static ClassicalTask addToTable(ClassicalTask newTask, ref ClassicalTask[] table, final int capacity, boolean rankTruthExpectation) {
        Sentence newSentence = newTask.sentence;
        final float rank1 = rankBelief(newSentence, rankTruthExpectation);    // for the new isBelief
        float rank2;        
        int i;
        foreach(i ; 0..table.length) {
            Sentence judgment2 = table[i].sentence;
            rank2 = rankBelief(judgment2, rankTruthExpectation);
            if (rank1 >= rank2) {
                if (newSentence.equivalentTo(judgment2)) {
                    //System.out.println(" ---------- Equivalent Belief: " + newSentence + " == " + judgment2);
                    return null;
                }
                table.add(i, newTask);
                break;
            }            
        }
        
        if( table.length == capacity ) {
            // nothing
        }
        else if( table.length > capacity ) {
        	assert(table.length == capacity+1); // is allowed to overflow only by one, else we have an internal problem somewhere or the size limit was changed without throwing the less rated elements out
            ClassicalTask removed = table.remove(table.length - 1);
            return removed;
        }
        else if( i == table.length ) { // branch implies implicit table.size() < capacity
            table ~= newTask;
        }
        
        return null;
    }
    +/
}

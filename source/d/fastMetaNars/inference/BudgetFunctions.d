module fastMetaNars.inference.BudgetFunctions;

import std.algorithm.comparison : max;

import fastMetaNars.entity.BudgetValue;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/inference/BudgetFunctions.java
/**
 * Budget functions for resources allocation
 */
struct BudgetFunctions {
	/**
     * Merge an item into another one in a bag, when the two are identical
     * except in budget values
     *
     * \param b The budget baseValue to be modified
     * \param a The budget adjustValue doing the adjusting
     */
    static void merge(ref BudgetValue b, BudgetValue a) {        
        b.priority = max(b.priority, a.priority);
        b.durability = max(b.durability, a.durability);
        b.quality = max(b.quality, a.quality);
    }
}

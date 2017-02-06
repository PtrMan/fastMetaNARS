module fastMetaNars.entity.BudgetValue;

import std.string : format;

import fastMetaNars.config.Parameters;
import fastMetaNars.inference.BudgetFunctions;

// https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/entity/BudgetValue.java
/**
 * A triple of priority (current), durability (decay), and quality (long-term average).
 */
struct BudgetValue {
	/**
     * Get priority value
     * \return The current priority
     */
    final @property float priority() {
        return privatePriority;
    }

    /**
     * Change priority value
     * \param v The new priority
     */
    final @property void priority(float v) {
        if( v>1.0f ) {
            throw new Exception(format("Priority > 1.0: %s", v));
            //v=1.0f;
        }
        privatePriority = v;
    }

    /**
     * Get durability value
     * \return The current durability
     */
    final @property float durability() {
        return privateDurability;
    }

    /**
     * Change durability value
     * @param v The new durability
     */
    final @property void durability(float d) {
        if(d>=1.0f) {
            d=1.0f-Parameters.TRUTH_EPSILON;
        }
        privateDurability = d;
    }

    /**
     * Get quality value
     * @return The current quality
     */
    final @property float quality() {
        return privateQuality;
    }

    /**
     * Change quality value
     * @param v The new quality
     */
    final @property void quality(float v) {
        privateQuality = v;
    }


    /**
     * Merge one BudgetValue into another
     * @param that The other Budget
     */
    public void merge(BudgetValue that) {
        BudgetFunctions.merge(this, that);
    }
    
    
    

    /** The relative share of time resource to be allocated */
    private float privatePriority;
    
    /**
     * The percent of priority to be kept in a constant period; All priority
     * values "decay" over time, though at different rates. Each item is given a
     * "durability" factor in (0, 1) to specify the percentage of priority level
     * left after each reevaluation
     */
    private float privateDurability;
    
    /** The overall (context-independent) evaluation */
    private float privateQuality;
}

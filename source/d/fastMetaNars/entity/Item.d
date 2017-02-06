module fastMetaNars.entity.Item;

import fastMetaNars.entity.BudgetValue;

// see https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/entity/Item.java
/**
 * An item is an object that can be put into a Bag,
 * to participate in the resource competition of the system.
 *
 * It has a key and a budget. Cannot be cloned
 */
abstract class Item(K) {
	BudgetValue budget; /** The budget of the Item, consisting of 3 numbers */
    
    /**
     * Get the current key
     * \return Current key value
     */
    abstract @property K name();

    /**
     * Merge with another Item with identical key
     * \param that The Item to be merged
     * \return the resulting Item: this or that
     */
    /*nonfinal*/ Item!K merge(Item!K that) {
        budget.merge(that.budget);
        return this;
    }
}

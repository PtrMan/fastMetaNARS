module fastMetaNars.memory.Bag;

import fastMetaNars.entity.Item;

abstract class Bag(E, K) /*if(E : Item!K)*/ {
	abstract void setMaxSize(size_t size);

	/**
     * Add a new Item into the Bag
     * if the same item already exists it gets merged
     *
     * \param newItem The new Item
     * \return the item which was removed, which may be the input item if it could not be inserted; or null if nothing needed removed
     */
	final E putIn(E newItem) {
		K newKey = newItem.name;
        
        E existingItemWithSameKey = take(newKey);
        
        if( existingItemWithSameKey !is null ) {            
            newItem = cast(E)existingItemWithSameKey.merge(newItem);
        }
        
        // put the (new or merged) item into itemTable        
        E overflowItem = addItem(newItem);
        
        
        if( overflowItem !is null ) {
            return overflowItem;
        }
        else {
            return null;
        }
	}

    // returns null if item doesn't exit, is legal
	abstract E take(K key);

	// value is [0, 1]
	//BagEntity reference(PriorityType value);

	// the number of items in the bag
	abstract @property size_t size();

	abstract void clear();

	/**
     * Insert an item into the bag, and return the overflow
     *
     * \param newItem The Item to put in
     * \return The overflow Item, or null if nothing displaced
     */
    protected abstract E addItem(E newItem);
}

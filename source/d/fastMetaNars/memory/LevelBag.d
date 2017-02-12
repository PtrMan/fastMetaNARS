module fastMetaNars.memory.LevelBag;

import fastMetaNars.memory.Bag;

// translated from https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/storage/LevelBag.java
/**
 * Original Bag implementation which distributes items into
 * discrete levels (queues) according to priority
 */
class LevelBag(E, K) : Bag!(E, K) {
    uint levels; /** priority levels */
    int fireCompleteLevelThreshold; /** firing threshold */

    /**
     * shared DISTRIBUTOR that produce the probability distribution
     */
    short[] DISTRIBUTOR;

    /**
     * mapping from key to item
     */
    //public final Set<E> nameTable;
    E[K] nameTable;

    /**
     * array of lists of items, for items on different level
     */
    Level!E[] level;

    uint capacity; /** defined in different bags */
    private float mass; /** current sum of occupied level */
    int levelIndex; /** index to get next level, kept in individual objects */
    int currentLevel; /** current take out level */
    int currentCounter; /** maximum number of items to be taken out at current level */
    bool[] levelEmpty;
    
    
    final this(uint levels, uint capacity) {
        this(levels, capacity, cast(int) (Parameters.BAG_THRESHOLD * levels));
    }

    /** thresholdLevel = 0 disables "fire level completely" threshold effect */
    public LevelBag(uint levels, uint capacity, int thresholdLevel) {
        this.levels = levels;
        this.fireCompleteLevelThreshold = thresholdLevel;
        //THRESHOLD = levels + 1; //fair/flat takeOut policy
        this.capacity = capacity;
        nameTable = new HashMap<>(capacity);
        level.length = this.levels;
        levelEmpty.length = this.levels;
        Arrays.fill(levelEmpty, true);
        DISTRIBUTOR = Distributor.get(this.levels).order;
        distributorLength = DISTRIBUTOR.length;        
        clear();
    }

    static class Level!E  {
        private int thisLevel;
        
        //Deque<E> items;
        LinkedHashSet<E> items;
                
        final this(int level, int numElements) {
            super();
            items = new LinkedHashSet(numElements);
            this.thisLevel = level;
        }

        /* java iterator functionality
        @Override
        public Iterator<E> iterator() {
            return items.iterator();
        }
        */
        
        final @property uint size() {
            return items.size();
        }
        
        
        final void levelIsEmpty(final boolean e) {
            levelEmpty[thisLevel] = e;
        }
        
        final void clear() {
            items.clear();
            levelIsEmpty(true);
        }

       final boolean add(E e) {
           if (e is null)
               throw new Exception("Bag requires non-null items");
           
            if (items.add(e)) {
                levelIsEmpty(false);
                return true;
            }
            return false;
        }

        final bool remove(E o) {
            if (items.remove(o)) {
                levelIsEmpty(items.isEmpty());
                return true;
            }
            return false;
        }

        final E removeFirst() {
            E e = items.iterator().next();
            items.remove(e);
            if (e!=null) {
                levelIsEmpty(items.isEmpty());
            }
            return e;
        }

        final E peekFirst() {
            return items.iterator().next();
        }

        /* java iterator functionality 
        final Iterator<E> descendingIterator() {
            return items.iterator();
            //return items.descendingIterator();
        }
        */
    }
    
    private final Level!E newLevel(int l) {
        return new Level!E(l, 1 + capacity / levels);
    }
    
    final override void clear() {
        for (size_t i = 0; i < levels; i++) {
            if (level[i] !is null) {
                level[i].clear();
            }
        }
        nameTable.clear();
        currentLevel = levels - 1;
        levelIndex = capacity % levels; // so that different bags start at different point
        mass = 0;
        currentCounter = 0;
    }

    /**
     * The number of items in the bag
     *
     * \return The number of items
     */
    final override @property size_t size() {
        int in_ = nameTable.length;
        if (Parameters.DEBUG_BAG && (Parameters.DEBUG)) {
            int is_ = sizeItems();
            if (abs(is_-in_) > 1 ) {                
                throw new Exception(/*this.getClass() + */" inconsistent index: items="); // TODO< translate java code  + is_ + " names=" + in_ + ", capacity=" + getCapacity());
            }
        }
        return in_;
    }
        
    /** this should always equal size(), but it's here for testing purposes */
    protected final int sizeItems() {
        int t = 0;
        foreach( Level!E l; level ) {
            if (l !is null)
                t += l.size();
        }
        return t;
    }
    
    /* java functionality 
    @Override
    public Set<K> keySet() {
        return nameTable.keySet();
    }
    */

    /+ not jet implemented functionality
    /**
     * Get the average priority of Items
     *
     * @return The average priority of Items in the bag
     */
    @Override
    public float getAveragePriority() {
        if (size() == 0) {
            return 0.01f;
        }
        float f = (float) mass / (size());
        if (f > 1) {
            return 1.0f;
        }
        return f;
    }
    +/

    /+ not jet implemented functionality
    /**
     * Get an Item by key
     *
     * @param key The key of the Item
     * @return The Item with the given key
     */
    @Override
    public E get(final K key) {
        return nameTable.get(key);
    }
    +/

    int distributorLength;
    
    /** look for a non-empty level */
    protected final void nextNonEmptyLevel() {
        int cl = currentLevel;
        do {                        
        } while (levelEmpty[cl = DISTRIBUTOR[(levelIndex++) % distributorLength]]);
        currentLevel = cl;  
        if (currentLevel < fireCompleteLevelThreshold) { // for dormant levels, take one item
            currentCounter = 1;
        } else {                  // for active levels, take all current items
            currentCounter = getNonEmptyLevelSize(currentLevel);
        }
    }

    /+ not jet implemented functionality
    @Override
    public E peekNext() {
        if (size() == 0) 
            return null; // empty bag                  
        E e = takeNext();
        putIn(e);
        return e;        
    }
    +/
    
    final E peekNextWithoutAffectingBagOrder() {    
        if (size() == 0) return null; // empty bag                
        if (levelEmpty[currentLevel] || (currentCounter == 0)) { // done with the current level
            nextNonEmptyLevel();
        }
        return level[currentLevel].peekFirst();        
    }
    
    /+ not jet implemented functionality
    @Override
    public E takeNext() {
        if (size() == 0) {
            return null; // empty bag                
        }
        if (levelEmpty[currentLevel] || (currentCounter == 0)) { // done with the current level
            nextNonEmptyLevel();
        }
        if (levelEmpty[currentLevel]) {
            throw new RuntimeException("Empty level selected for takeNext");
        }
        final E selected = takeOutFirst(currentLevel); // take out the first item in the level
        currentCounter--;        
        return selected;
    }
    +/

    final int getNonEmptyLevelSize(final int level) {
        return this.level[level].size();
    }
    final int getLevelSize(final int level) {
        return (levelEmpty[level]) ? 0 : this.level[level].size();
    }

    final override E take(K name) {
        E oldItem = nameTable.remove(name);
        if (oldItem is null) {
            return null;
        }
        final int expectedLevel = getLevel(oldItem);
        // TODO scan up/down iteratively, it is likely to be near where it was
        if (!levelEmpty[expectedLevel]) {
            if (level[expectedLevel].remove(oldItem)) {                
                removeMass(oldItem);
                return oldItem;
            }            
        }
        for (int l = 0; l < levels; l++) {
            if ((!levelEmpty[l]) && (l!=expectedLevel)) {
                if (level[l].remove(oldItem)) {
                    removeMass(oldItem);
                    return oldItem;
                }
            }
        }
        // If it wasn't found, it probably was removed already.  So this check is probably not necessary
        // search other levels for this item because it's not where we thought it was according to getLevel()
        if (Parameters.DEBUG) {
            int ns = nameTable.size();
            int is = sizeItems();
            if (ns == is)
                return null;
            throw new RuntimeException("LevelBag inconsistency: " + nameTable.size() + "|" + sizeItems() + " Can not remove missing element: size inconsistency" + oldItem + " from " + this.getClass().getSimpleName());
        }
        return oldItem;
    }

    /**
     * Decide the put-in level according to priority
     *
     * @param item The Item to put in
     * @return The put-in level
     */
    private final int getLevel(E item) {
        float fl = item.getPriority() * levels;
        int level = (int) Math.ceil(fl) - 1;
        if (level < 0) return 0;
        if (level >= levels) return levels-1;
        return level;
    }
    
    /**
     * Insert an item into the itemTable, and return the overflow
     *
     * @param newItem The Item to put in
     * @return null if nothing overflowed, non-null if an overflow Item, which
     * may be the attempted input item (in which case it was not inserted)
     */
    @Override public E addItem(final E newItem) {
        E oldItem = null;
        int inLevel = getLevel(newItem);
        if (size() >= capacity) {      // the bag will be full after the next 
            int outLevel = 0;
            while (levelEmpty[outLevel]) {
                outLevel++;
            }
            if (outLevel > inLevel) {           // ignore the item and exit
                return newItem;
            } else {                            // remove an old item in the lowest non-empty level
                oldItem = takeOutFirst(outLevel);
            }
        }
        ensureLevelExists(inLevel);
        level[inLevel].add(newItem);        // FIFO
        nameTable.put(newItem.name(), newItem);        
        addMass(newItem);
        return oldItem;
    }

    protected final void ensureLevelExists(final int level) {
        if (this.level[level] == null) {
            this.level[level] = newLevel(level);
        }
    }

    /**
     * Take out the first or last E in a level from the itemTable
     *
     * @param level The current level
     * @return The first Item
     */
    private E takeOutFirst(final int level) {
        final E selected = this.level[level].removeFirst();
        if (selected!=null) {
            nameTable.remove(selected.name());
            removeMass(selected);
        }
        else {
            throw new RuntimeException("Attempt to remove item from empty level: " + level);
        }
        return selected;
    }

    protected final void removeMass(E item) {
        mass -= item.getPriority();
    }
    protected final void addMass(E item) {
        mass += item.getPriority();
    }

    /+ not implemented java code
    /**
     * TODO refactor : paste from preceding method
     */
    public string toStringLong(int minLevel) {
        StringBuilder buf = new StringBuilder(32)
                .append(" BAG ").append(getClass().getSimpleName())
                .append(" ").append(showSizes());

        for (int i = levels; i >= minLevel; i--) {
            if (!levelEmpty[i - 1]) {
                buf = buf.append("\n --- LEVEL ").append(i).append(":\n ");
                for (final E e : level[i - 1]) {
                    buf = buf.append(e.toStringLong()).append('\n');
                }

            }
        }
        buf.append(">>>> end of Bag").append(getClass().getSimpleName());
        return buf.toString();
    }

    /**
     * show item Table Sizes
     */
    public String showSizes() {
        StringBuilder buf = new StringBuilder(" ");
        int l = 0;
        for (Level<E> items : level) {
            int s = items.size();
            if ((items != null) && (s > 0)) {
                l++;
                buf.append(s).append(' ');
            }
        }
        return "Levels: " + Integer.toString(l) + ", sizes: " + buf;
    }


    @Override
    public float getMass() {
        return mass;
    }
    +/

    final float getAverageItemsPerLevel() {
        return capacity / levels;
    }

    final float getMaxItemsPerLevel() {
        int max = getLevelSize(0);
        for (int i = 1; i < levels; i++) {
            int s = getLevelSize(i);
            if (s > max) {
                max = s;
            }
        }
        return max;
    }

    final float getMinItemsPerLevel() {
        int min = getLevelSize(0);
        for (int i = 1; i < levels; i++) {
            int s = getLevelSize(i);
            if (s < min) {
                min = s;
            }
        }
        return min;
    }

    /+ not implemented java code
    @Override
    public int getCapacity() {
        return capacity;
    }
    +/

    /+ not implemented java code
    public Iterable<E> getLevel(final int i) {
        if (level[i] == null) {
            return Collections.EMPTY_LIST;
        }
        return level[i];
    }
    +/

    /+ not implemented java code
    @Override
    public Collection<E> values() {
        return nameTable.values();
    }
    +/

    /+ not implemented java code
    @Override
    public Iterator<E> iterator() {
        return new Iterator<E>() {
            int l = level.length - 1;
            private Iterator<E> levelIterator;
            private E next;
            final int size = size();
            int count = 0;

            @Override
            public boolean hasNext() {
                if (next != null) {
                    return true;
                }
                if (l >= 0 && levelIterator == null) {
                    while (levelEmpty[l]) {
                        if (--l == -1)
                            return false; //end of the levels
                    }
                    levelIterator = level[l].descendingIterator();
                }
                if (levelIterator == null) {
                    return false;
                }
                next = levelIterator.next();
                count++;
                if (levelIterator.hasNext()) {
                    return true;
                } else {
                    levelIterator = null;
                    l--;
                    return count <= size;
                }
            }

            @Override
            public E next() {
                E e = next;
                next = null;
                return e;
            }
        };
    }
    +/

    final uint numEmptyLevels() {
        uint empty = 0;
        for (int i = 0; i < level.length; i++) {
            if (levelEmpty[i]) {
                empty++;
            }
        }
        return empty;
    }
}
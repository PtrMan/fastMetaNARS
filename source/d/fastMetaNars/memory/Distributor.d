module fastMetaNars.memory.Distributor;

import std.algorithm.mutation : fill;

// translated from https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/storage/Distributor.java
/**
 * A pseudo-random number generator, used in Bag.
 */
class Distributor {
    public short order[]; /** Shuffled sequence of index numbers */
    public int capacity; /** Capacity of the array */

    private static Distributor[int] distributors;
    
    static Distributor get(int range) {
        Distributor d = distributors[range];
        if (d is null) {
            d = new Distributor(range);
            distributors[range] = d;
        }
        return d;
    }
    
    /**
     * For any number N < range, there is N+1 copies of it in the array, distributed as evenly as possible
     * \param range Range of valid numbers
     */
    protected final this(int range) {
        int index, rank, time;
        capacity = (range * (range + 1)) / 2;
        order.length = capacity;
        
        fill(order, cast(short)(-1));
        index = capacity;
        
        for (rank = range; rank > 0; rank--) {
            int capDivRank = capacity / rank;
            for (time = 0; time < rank; time++) {
                index = (capDivRank + index) % capacity;
                while (order[index] >= 0) {
                    index = (index + 1) % capacity;
                }
                order[index] = cast(short)(rank - 1);
            }
        }
    }

    /**
     * Get the next number according to the given index
     * \param index The current index
     * \return the random value
     */
    public final short pick(int index) {
        return order[index];
    }

    /**
     * Advance the index
     * \param index The current index
     * \return the next index
     */
    public final int next(int index) {
        return (index + 1) % capacity;
    }
}

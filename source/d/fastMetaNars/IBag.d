module fastMetaNars.IBag;

abstract class IBag(Type, PriorityType) {
	static struct BagEntity {
		final this(Type value, PriorityType priority) {
			this.value = value;
			this.protectedPriority = priority;
		}

		final @property PriorityType priority() {
			return protectedPriority;
		}

		Type value;

		protected PriorityType protectedPriority = PriorityType.init;
	}

	void setMaxSize(size_t size);

	void put(BagEntity element);

	// value is [0, 1]
	BagEntity reference(PriorityType value);

	size_t getSize();
}
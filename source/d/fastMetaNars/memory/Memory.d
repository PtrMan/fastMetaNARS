module fastMetaNars.memory.Memory;

import misced.memory.ArrayQueue;
import fastMetaNars.control.WorkingCyclish;
import fastMetaNars.entity.ClassicalTask;

// see https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/storage/Memory.java
class Memory {
	/* List of new tasks accumulated in one cycle, to be processed in the next cycle */
    public ClassicalTask[] newTasks; // used as dequeue

    public WorkingCyclish workingCyclish;
    /**
     * add new task that waits to be processed in the next cycleMemory
     */
    public void addNewTask(ClassicalTask t, string reason) {
        newTasks.enqueue(t);
        //  logic.TASK_ADD_NEW.commit(t.getPriority());
        //emit(Events.TaskAdd.class, t, reason);
        //output(t);
    }
}

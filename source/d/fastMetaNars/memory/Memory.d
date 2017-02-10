module fastMetaNars.memory.Memory;

import misced.memory.ArrayQueue;
import fastMetaNars.control.WorkingCyclish;
import fastMetaNars.entity.ClassicalTask;
import fastMetaNars.entity.ClassicalSentence;
import fastMetaNars.memory.Bag;

// TODO 10.02.2017 : transfer from newTasks to taskBuffer somehow and work on all tasks in taskBuffer like it's done in 1.6.5

// see https://github.com/opennars/opennars/blob/1.6.5_devel17_RetrospectiveAnticipation/nars_core/nars/storage/Memory.java
class Memory {
	/* List of new tasks accumulated in one cycle, to be processed in the next cycle */
    public ClassicalTask[] newTasks; // used as dequeue

    // see https://github.com/opennars/opennars/blob/4c428cd39c03a676da5247400bc962ad0f84a948/nars_core/nars/storage/Memory.java#L116
    public Bag!(ClassicalTask, ClassicalSentence) taskBuffer; /* taskBuffer from pei's docs, New tasks with novel composed terms, for delayed and selective processing*/

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

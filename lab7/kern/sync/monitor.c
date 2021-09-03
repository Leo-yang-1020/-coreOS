#include <stdio.h>
#include <monitor.h>
#include <kmalloc.h>
#include <assert.h>


// Initialize monitor.
void
monitor_init(monitor_t *mtp, size_t num_cv) {
    int i;
    assert(num_cv > 0);
    mtp->next_count = 0;
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
    sem_init(&(mtp->next), 0);
    mtp->cv = (condvar_t *) kmalloc(sizeof(condvar_t) * num_cv);
    assert(mtp->cv != NULL);
    for (i = 0; i < num_cv; i++) {
        mtp->cv[i].count = 0;
        sem_init(&(mtp->cv[i].sem), 0);
        mtp->cv[i].owner = mtp;
    }
}

// Unlock one of threads waiting on the condition variable.
// 当断言为真时，唤醒等待断言P被满足的进程继续执行
/**
 * 本次采取的signal措施是唤醒条件变量的等待队列的一个进程，并将自己挂载到入口的等待队列中以达到只有一个进程访问共享区的效果（有点像hoare，但是又没有新加一个单独的signal队列）
 * 注：这里的队列使用的是信号量来实现，down相当于入队，up相当于出队，利用信号量自带队列属性
 * @param cvp
 */
void
cond_signal(condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count,
            cvp->owner->next_count);
    if (cvp->count > 0) {
        cvp->owner->next_count++;//该进程在执行signal后会将执行signal的进程挂载到入口队列中，入口队列的等待进程数目++
        up(&(cvp->sem));//将该条件变量的某一个等待队列中的进程出队并唤醒
        down(&(cvp->owner->next));//将自己挂载到入口队列中
        cvp->owner->next_count--;//重新唤醒后入口队列等待的数目--
}
    cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count,
            cvp->owner->next_count);
}

// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
//发现断言为假时执行，执行后等待断言PC满足后恢复执行，执行后将不占用管道
/**
 * wait实现的思路为 先调度：从入口队列调度，如果没有则释放锁并等待;找到合适的进程后将自己挂载到条件变量的等待队列
 * @param cvp
 */
void
cond_wait(condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count,
            cvp->owner->next_count);
    cvp->count++;//由于不满足断言，因此该进程即将挂载到条件变量的队列中
    /**
     * 调度算法：优先调度正在入口队列中的进程，如果没有，则释放锁并等待
     */
    if (cvp->owner->next_count > 0)//当该管程的入口队列中已经存正在有等待的进程时
        up(&(cvp->owner->next));//选择某一入口队列的进程出队
    else
        up(&(cvp->owner->mutex));//如果当前管程的入口队列没有正在等待的进程，说明需要释放进入管程的锁，便于其他的进程进入管程
    down(&(cvp->sem));//因为不满足断言，将当前的进程加入到条件变量的等待队列中
    cvp->count--;//重新被激活后，条件变量的等待队列的进程数目减1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count,
            cvp->owner->next_count);
}

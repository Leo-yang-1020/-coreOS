#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    //调度时需要屏蔽中断，、
    {
        current->need_resched = 0;
        //当need_resched为1时，说明该进程需要退出并重新调度，而这里则将current设置为0,使得current进程退出执行
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                //这里调度算法是FIFO思想，找到第一个处于就绪态的进程切换
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
            //如果没有找到，进入空转
        }
        next->runs ++;
        //即将切换执行的进程的执行时间增加
        if (next != current) {
            proc_run(next);
            //正式执行该进程
        }
    }
    local_intr_restore(intr_flag);
}


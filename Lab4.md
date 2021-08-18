## Lab4 创建内核线程

为什么是创建内核线程？内核线程和进程的区别？

我们可以将内核线程看作是一种特殊的进程，区别如下：

- 内核线程只会在内核态运行
- 用户进程会在用户态和内核态交替运行
- 内核共用内核内存空间，不需要单独分配内存空间
- 用户进程需要维护各自的用户内存空间



### 内核级线程

创建整体流程如下：
kern_init()-> proc_init()->完成idleproc&&initproc两个内核线程的创建

如何理解内核线程的共享空间？

ucore OS内核中所有的线程都不需要再建立各自的页表，只需要共享内核虚拟空间就可以访问整个物理内存。

内核级线程成员变量中cr3可以设置为内核页目录基址，达到了共享虚拟空间。



idleproc与initproc？

ucore中，idleproc的pid为0,意味着他是第0个内核线程，既然是idle，空转，idleproc->need_resched一直被设置为1,即scheule函数会在其他进程需要时立刻切换到其它进程。



initproc：initproc可以说是我们的老朋友了，在僵尸进程处理与孤儿进程已经谈到过，init进程是所有用户进程的父进程。

剖析一下创建内核线程的函数：

kernel_thread:

```c
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.tf_cs = KERNEL_CS;
    tf.tf_ds = tf_struct.tf_es = tf_struct.tf_ss = KERNEL_DS;
    tf.tf_regs.reg_ebx = (uint32_t)fn;
    tf.tf_regs.reg_edx = (uint32_t)arg;
    tf.tf_eip = (uint32_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

```

这个函数会创建一个内核线程，该线程在后续将会创建特定的其他内核线程或用户进程。

这里注意 int(* fn)(void *)，含义为fn作为一个函数指针，指向一个返回值为int，参数为void*的函数

这个函数，可以类比于我们new_thread，是内核线程的主体函数，arg是其参数。

在该函数中，通过局部变量tf放置内核线程的临时中断帧。

保存好后，执行kernel_thread_entry:

```assembly
kernel_thread_entry: # void kernel_thread(void)
pushl %edx # push arg
call *%ebx # call fn
pushl %eax # save the return value of fn(arg)
call do_exit # call do_exit to terminate current thread
```

从上可以看出，kernel_thread_entry函数主要为内核线程的主体fn函数做了一个准备开始和结束运行的“壳”，并把函数fn的参数arg（保存在edx寄存器中）压栈，然后调用fn函数，把函数返回值eax寄存器内容压栈，调用do_exit函数退出线程执行。

do_fork是创建线程的主要函数。kernel_thread函数通过调用do_fork函数最终完成了内核线程的创建工作。下面我们来分析一下do_fork函数的实现（练习2）。do_fork函数主要做了以下6件事情：

1. 分配并初始化进程控制块（alloc_proc函数）；
2. 分配并初始化内核栈（setup_stack函数）；
3. 根据clone_flag标志复制或共享进程内存管理结构（copy_mm函数，选择是复制还是共享，对于内核线程来说无所谓，因为分享内核空间）；
4. 设置进程在内核（将来也包括用户态）正常运行和调度所需的中断帧和执行上下文（copy_thread函数）；
5. 把设置好的进程控制块放入hash_list和proc_list两个全局进程链表中；
6. 自此，进程已经准备好执行了，把进程状态设置为“就绪”态；
7. 设置返回码为子进程的id号。

## 练习2：

代码如下：

```c
if (proc = alloc_proc() == NULL) {
        goto fork_out;
    }
        //获得一块用户信息块
        proc->parent = current;
        if (setup_kstack(proc) != 0) {
            goto bad_fork_cleanup_proc;
        }
        //为进程分配一个内核栈，分配失败则需要清空。

        if (copy_mm(clone_flags, proc) != 0) {
            goto bad_fork_cleanup_kstack;
        }
        //复制或者共享内存，在本实验无须做任何事，因为内核线程共享虚拟内存

        copy_thread(proc, stack, tf);
        //初始化上下文及tf变量中寄存器信息


        proc->pid = get_pid();
        //为其分配一个合法的pid
        hash_proc(proc);
        //hash后插入
        list_add(&proc_list, &(proc->list_link));
        //将当前进程插入到双向链表
        nr_process++;

        wakeup_proc(proc);
        //唤醒进程：使其状态变为runnable

        ret = proc->pid;
        //返回值就是分配的pid
```

**思考：如何保证get_pid()能够分配一个独一无二的pid？**

第一，屏蔽中断，在进程创建后，每一个进程都可以通过do_forK()函数创建新的进程，因此，在调用get_pid()函数时必须屏蔽中断。

对于get_pid()函数本身：

我也没有看太明白这个get_pid()函数的写法为和能够保证不重复，只能简单地谈一谈思想。

如果是暴力的角度，我们需要遍历pid范围内的每一个数，检查其是否已经被分配，时间复杂度过高。

从优化的角度，我们可以创建一个pid表来表示是否已经分配了pid,但是，空间的开销较大，因为pid数目非常大！

从折中的角度来看，我们希望找到一个空间开销不大，并且时间复杂度也合适的算法，这里，使用到了静态变量：

代码如下：

```c
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
        inside:
        next_safe = MAX_PID;
        repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            } else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

last_pid作为静态变量，可以表示上一次分配的pid号。

这里的思想是定范围：

last_pid表示上一次分配的pid（静态变量特征），作为左边界  next_safe表示右边界。

当last_pid小于next_safe时（且没有超过最大pid值）可以直接+1后返回。

如果超过了，说明还需要重新遍历已分配的pid重新确定左右界限。

这样就可以最高效地分配唯一的pid！

**思考2：context上下文，trapframe中断帧，kstack内核栈，这几位分别是什么？有什么作用？**

 context最简单，也最直接，进程切换需要更新寄存器的值，而context则帮助保存寄存器的值，便于进程的上下文切换，其表示就是一个简单的结构体。

```c
struct context {
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};
```



trapframe，简写为tf，中断帧的指针，顾名思义，是中断相关的结构。

该指针指向**内核栈**的某个位置，当进程从user-mode跳转到kernel-mode时（我们知道只有中断才能使得发生用户态到内核态的转变）中断帧记录了进程在被中断前的状态（注意和上下文的区别，这里是中断）当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。



kstack: 我们知道线程有独立的内核栈。

对于内核线程，该栈就是运行时的程序使用的栈；而对于普通进程，该栈是发生特权级改变的时候使保存被打断的硬件信息用的栈。（与trapframe联系上了，trapframe指针就指向该内核栈的某个位置）

kstack指向该栈的地址，作用有：

1.当内核准备从一个进程切换到另一个的时候，需要根据kstack 的值正确的设置好 tss （可以回顾一下在实验一中讲述的 tss  在中断处理过程中的作用），以便在进程切换以后再发生中断时能够使用正确的栈。

2.内核栈位于内核地址空间，并且是不共享的（每个线程都拥有自己的内核栈），因此不受到 mm 的管理，当进程退出的时候，内核能够根据 kstack 的值快速定位栈的位置并进行回收。



## 练习3

创建运行了两个内核线程：idle_proc 和init_proc。

要分析proc_run,我们先分析会调用proc_run的函数：schedule():

本次实验仅仅涉及到了最简单的FIFO思想调度：

```c
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
```

执行完毕后，我们可以看到最后将调用proc_run(next)进行进程的正式切换：

```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        //设置下一个进程为要切换的进程，prev为当前即将被切换的进程
        local_intr_save(intr_flag);
        //屏蔽中断
        {
            current = proc;
            //修改全局变量为即将切换的process
            load_esp0(next->kstack + KSTACKSIZE);
            //设置tss,权限级别
            lcr3(next->cr3);
            switch_to(&(prev->context), &(next->context));
            //核心步骤：切换上下文，寄存器值更新为新进程的内容
        }
        local_intr_restore(intr_flag);
        //开中断
    }
}
```


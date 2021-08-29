## Lab6

核心：实现RR调度算法以及其他调度算法，完成进程调度规范。

### 进程切换的过程描述：

我们描述进程AB之间的切换，由此可以类比推进到多个进程间的切换过程。

进程A（用户态执行中）->出现trap->进程A切换到内核态度->内核需要进行进程切换->选择进程B->上下文切换到进程B的内核态，进程B继续上一次在内核态的操作->通过iret指令，将执行权交由进程B的用户空间，即此进程B转化为用户态。

进程B（用户态） 流程同上述。

我们可以注意到：

进程切换后，将会切入到另一个进程内核态继续执行，而非直接用户态。

### 工作概述

进程调度两大工作：选择在集合中的某个合适的进程进入，以及某个时机触发退出某个进程。

为了便于调度算法的扩展，我们需要使得调度相关函数与具体调度算法无关，即实现一个调度算法框架。

每一个调度算法都需要完成四个接口重写：

- sched_class_enqueue（入队）
- sched_class_dequeue（出队）
- sched_class_pick_next（选择下一个调度的进程）
- sched_class_proc_tick（当timer触发时将进行的事件）

#### 基础：RR算法

RR调度算法的调度思想  是让所有runnable态的进程分时轮流使用CPU时间。RR调度器维护当前runnable进程的有序运行队列。当前进程的时间片用完之后，调度器将当前进程放置到运行队列的尾部，再从其头部取出进程进行调度。RR调度算法的就绪队列在组织结构上也是一个双向链表，只是增加了一个成员变量，表明在此就绪进程队列中的最大执行时间片。而且在进程控制块proc_struct中增加了一个成员变量time_slice，用来记录进程当前的可运行时间片段。这是由于RR调度算法需要考虑执行进程的运行时间不能太长。在每个timer到时的时候，操作系统会递减当前执行进程的time_slice，当time_slice为0时，就意味着这个进程运行了一段时间（这个时间片段称为进程的时间片），需要把CPU让给其他进程执行，于是操作系统就需要让此进程重新回到rq的队列尾，且重置此进程的时间片为就绪队列的成员变量最大时间片max_time_slice值，然后再从rq的队列头取出一个新的进程执行。



### 练习1

分析sched_class:

```c
struct sched_class {
    // the name of sched_class
    const char *name;
    // Init the run queue
    void (*init)(struct run_queue *rq);
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
};
```

这里由于c不支持oop，因此，要写接口，接口中定义了调度算法的通用函数：

init,enqueue,dequeue等等，使用了void*类型，便于指向具体的实现函数。

每个函数的重要方法我们通过RR调度的实际例子来看：

- ```c
  static void
  RR_init(struct run_queue *rq) {
      list_init(&(rq->run_list));
      rq->proc_num = 0;
  }
  //就绪队列初始化并设置进程数目为0
  ```

- ```c
  static void
  RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
      assert(list_empty(&(proc->run_link)));
      list_add_before(&(rq->run_list), &(proc->run_link));
      //新就绪的进程插入到队列的尾部
      if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
          //如果时间片为0,或者大于RR算法中调度的最大值，需要设置其为调度的最大时间片大小，避免时间片为负数或过大
          proc->time_slice = rq->max_time_slice;
      }
      proc->rq = rq;
      rq->proc_num ++;
  }

- ```c
  static void
  RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
      assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
      list_del_init(&(proc->run_link));
      //删除队列中对应的进程
      rq->proc_num --;
  }
  ```

- ```c
  static struct proc_struct *
  RR_pick_next(struct run_queue *rq) {
      list_entry_t *le = list_next(&(rq->run_list));
      if (le != &(rq->run_list)) {
          //RR调度算法的特性：会直接选择队列中下一个进程执行
          return le2proc(le, run_link);
      }
      return NULL;
  }
  ```

- ```c
  static void
  RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
      if (proc->time_slice > 0) {
          proc->time_slice --;
      }
      if (proc->time_slice == 0) {
          proc->need_resched = 1;
      }
  }
  //每一次timer都减少时间片，当时间片耗尽时，设置调度位，需要重新调度
  ```

  有了RR调度算法的基础，我们继续完成stride scheduling调度算法也就更加方便。

**调度流程:**

触发调度->进程入队->pick 下一个进程->出队->进程切换

### 练习2

#### 什么是Stride调度算法？

> 可以理解为简单的，未优化的cfs调度算法，其每次分配的时间一致，stride为累积值，每次选择最小的stride值进程进行调度，优先级高的进程的stride增长值低，使得更容易被分配，但也不会出现优先级高的进程一直占据。

1. 为每个runnable的进程设置一个当前状态stride，表示该进程当前的调度权。另外定义其对应的pass值，表示对应进程在调度后，stride 需要进行的累加值。  
2. 每次需要调度时，从当前 runnable 态的进程中选择 stride最小的进程调度。
3. 对于获得调度的进程P，将对应的stride加上其对应的步长pass（只与进程的优先权有关系）。  
4. 在一段固定的时间之后，回到 2.步骤，重新调度当前stride最小的进程。
   可以证明，如果令 P.pass =BigStride / P.priority 其中 P.priority 表示进程的优先权（大于 1），而 BigStride  表示一个预先定义的大常数，则该调度方案为每个进程分配的时间将与其优先级成正比。



前置：修改grade.sh文件，否则无论怎么写都无法满分：

将220至241部分注释即可。



### Stride调度算法的实现

我们每次需要选出stride最小的进程执行，说到最小，我们自然想到了使用优先队列来完成！

优先队列的本质就是一个大根堆或者小根堆。


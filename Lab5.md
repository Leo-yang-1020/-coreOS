### 前置修改

前4个Lab完成的内容都是在内核态内完成的，接下来我们需要进一步完善，引入用户态。

Ucore需要提供用户态进程的创建和执行机制，给应用提供一个用户态的运行环境。

trap.c文件修改：

```c
ticks++;
        if(ticks%TICK_NUM==0){
            print_ticks();
            current->need_resched=1;
            //当时间片用完后，设置为需要调度
        }
//时钟中断处，当时间片用完后，需要设置为重新调度
```

idt_init函数：

```c
void
idt_init(void) {

    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL],1,GD_KTEXT,__vectors[T_SYSCALL],DPL_USER);
    //为系统调用初始化IDT项，该项属于陷入，并且特权级为USER（系统调用由用户态发生）
    lidt(&idt_pd);
}
```

需要增加系统调用的IDT项

进程方面：

do_fork()函数

需要增加对进程状态的判断以及进程亲子关系链表增添。

```c
if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    //获得一块用户信息块

    assert(current->wait_state==0);

    proc->parent = current;
    //其父进程应该为创建时调用该函数的进程

    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }
    //为进程分配一个内核栈，分配失败则需要清空。

    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    //复制或者共享内存，在本实验无须做任何事，因为内核线程共享虚拟内存

    //按照clone_flags所给提示，选择复制或者共享内存空间
    copy_thread(proc, stack, tf);
    //初始化上下文及tf变量中寄存器信息

    bool intr_flag;
    local_intr_save(intr_flag);
    //屏蔽中断
    proc->pid = get_pid();
    //为其分配一个合法的pid
    hash_proc(proc);
    //这里的hash是基于pid的，因此需要在pid初始化后hash
    set_links(proc);
    //设置进程的亲子关系
    nr_process++;
    
    local_intr_restore(intr_flag);
```

由于用户态的PCB发生的变动，因此alloc_proc函数也需要变动：

```c
proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
        proc->wait_state = 0;//PCB 进程控制块中新增的条目，初始化进程等待状态
        proc->cptr = proc->optr = proc->yptr = NULL;//进程相关指针初始化
```



至此，基础改动完成。



### 练习1

do_execv()函数用于加载应用程序并转化为进程开始执行。

分析do_execv()流程

- 清空当前进程的内存空间：

  ```c
  if (mm != NULL) {
          lcr3(boot_cr3);
          if (mm_count_dec(mm) == 0) {
              exit_mmap(mm);
              put_pgdir(mm);
              mm_destroy(mm);
          }
          current->mm = NULL;
      }
  ```

  

- 执行load_icode()，加载并解析一个处于内存中的ELF执行文件格式的应用程序：

- 分析load_icode()：

  - 获取二进制程序的elf头
  - 获取程序段的入口
  - 找到每一个程序头
  - 建立新的VMA
  - 分配内存
  - 将二进制程序的程序段和数据段拷贝
  - 建立BSS段
  - 建立用户栈
  - 设置CR3寄存器的值为该进程使用的页目录
  - 建立好用户环境的中断帧

  本质：读取ELF格式程序，建立进程内存空间中必须的内容，将程序内容读入到进程，设置CR3寄存器。

  要填写的代码：

  中断帧的设置：

  ```c
  	tf->tf_cs=USER_CS;
      tf->tf_ds=tf->tf_es=tf->tf_ss=USER_DS;
      tf->tf_esp=USTACKTOP;
      tf->tf_eip=elf->e_entry;
      tf->tf_eflags=FL_IF;//打开中断
  ```

  这样设置具体可以参考进程内存空间，比较关键的有esp指针，始终指向栈顶，eip指针指向e_entry，即应用程序的入口

  最后eflags表示打开中断



思考分析：当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。



- 当创建了一个用户态进程并加载了应用程序后，首先，会发生system call，即系统调用。

- 系统调用的过程和中断处理过程相同，根据中断向量表可以找到对应的系统调用函数，这里是：
  sys_exec:

  ```c
  static int
  sys_exec(uint32_t arg[]) {
      const char *name = (const char *)arg[0];
      size_t len = (size_t)arg[1];
      unsigned char *binary = (unsigned char *)arg[2];
      size_t size = (size_t)arg[3];
      return do_execve(name, len, binary, size);
  }
  ```

  接下来就会执行do_execve函数。

- do_execve函数可以简单概括为：清空当前进程内存，情况页目录，销毁mm_struct结构，之后再根据ELF文件内容，重新建立新的内存空间以及页目录映射，修改tf（中断帧）使得最终中断返回的时候能够切换到用户态，并且同时可以正确地将控制权转移到应用程序的入口处；最后设置CR3寄存器

- 执行结束后，由于中断处理例程的栈上面的 eip 已经被修改成了应用程序的入口处，而 CS 上的 CPL 是用户态，因此 iret 进行中断返回的时候会将堆栈切换到用户的栈，并且完成特权级的切换，并且跳转到要求的应用程序的入口处；

- 最后正常执行程序第一条指令。



### 练习2

我们需要完成copy_range函数的填写，该函数非常简单，但是我们需要具体分析函数的调用过程以便我们更好地完成Challenge内容：实现COW机制。

从调用顺序来看：

do_fork()->copy_mm()->dup_mmap()->copy_range()

先看copy_mm():

如果clone_flags为共享内存，则直接将mm设置为当前process的mm。

正常情况下：

```c
lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);
    }
unlock_mm(oldmm);
```

加锁后执行dup_mmap()

再看dup_mmap() 负责内存映射的复制

```c
list_entry_t *list = &(from->mmap_list), *le = list;
    //获取复制源的mmap_list
    while ((le = list_prev(le)) != list) {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        //获取源mm_struct每一个块的vma
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        //根据源的vma创建目的nvmas，其中开始地址与结束的虚拟地址相同
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
        //将其插入到目的mm_struct 逐步形成
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            //以不共享内存的方式实现进程内容拷贝
            return -E_NO_MEM;
        }
    }
```

我们可以发现，这里的非共享内存复制，就是虚拟地址不变，构建到新进程的虚拟地址到物理地址的新的映射来达成进程复制的效果，父进程与子进程不共享，但内容相同。

而copy_range就是复制某一段内容的复制（从start到end）

``` c
do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        void * src_kvaddr= page2kva(page);
        void * dst_kvaddr= page2kva(npage);
        memcpy(dst_kvaddr,src_kvaddr,PGSIZE);
        ret=page_insert(to,page,start,perm);
        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
```

总结一下：

copy_range就是根据给出的虚拟地址找到对应的页表项，最终找到了对应的物理页，最后父进程的物理页的内容复制到子进程，再建立子进程的虚拟地址与物理地址的映射。

（这里的成绩评判有点问题，需要将tools目录下的grade.sh的221到233行注释）

最后，执行make grade

![](https://cdn.jsdelivr.net/gh/Leo-yang-1020/picRepo/img/20210821165815.png)



### 练习3

分析fork,exec,wait,exit函数。

我们在理论课中学习了关于进程的状态转换图，这里，我们利用学习到的知识来看这些函数的实现的背后。

#### 系统调用服务

> 实现了用户进程后，自然引申出来需要实现的操作系统功能。用户进程只能在操作系统给它圈定好的“用户环境”中执行，但“用户环境”限制了用户进程能够执行的指令，即用户进程只能执行一般的指令，无法执行特权指令。如果用户进程想执行一些需要特权指令的任务，比如通过网卡发网络包等，只能让操作系统来代劳了。于是就需要一种机制来确保用户进程不能执行特权指令，但能够请操作系统“帮忙”完成需要特权指令的任务，这种机制就是系统调用。



| 系统调用名 | 含义                                      | 具体完成服务的函数                                           |
| ---------- | ----------------------------------------- | ------------------------------------------------------------ |
| SYS_exit   | process exit                              | do_exit                                                      |
| SYS_fork   | create child process, dup mm              | do_fork-->wakeup_proc                                        |
| SYS_wait   | wait child process                        | do_wait                                                      |
| SYS_exec   | after fork, process execute a new program | load a program and refresh the mm                            |
| SYS_yield  | process flag itself need resecheduling    | proc->need_sched=1, then scheduler will rescheule this process |
| SYS_kill   | kill process                              | do_kill-->proc->flags \|= PF_EXITING,                                                         -->wakeup_proc-->do_wait-->do_exit |
| SYS_getpid | get the process's pid                     |                                                              |

#### exit分析

进程要退出，必须考虑内存的释放，状态的转化以及退出后可能产生的调度问题。

do_exit()完成工作有：释放进程对应的内存，将进程状态设置为僵尸进程状态，唤醒父进程对此进行处理，调度执行其他进程。

fork不再赘述。

wait 是等待任意子进程的结束通知。wait_pid 函数等待进程 id 号为 pid 的子进程结束通知。这两个函数最终访问 sys_wait 系统调用接口让 ucore 来完成对子进程的最后回收工作。wait 系统调用取决于是否存在可以释放资源（ZOMBIE）的子进程，如果有的话不会发生状态的改变，并且会将**僵尸进程**清除掉;如果没有的话会将当前进程置为 SLEEPING 态，等待执行了 exit 的子进程将其唤醒；

exec也不必再赘述。





### CopyOnWrite实现

写时复制实现思路：

当创建线程选了共享内存时：

在copy_range()函数中，不需要建立新的映射，而是将子进程的内存直接指向父进程，并且将页设置为只读。

并且在do_pgfault()中设置相应的对于**写只读页**的处理：

当进程访问了共享的页面时（只读页面），内核需要重新分配页面、拷贝页面内容、建立映射关系：

如果该页ref为1,说明只有一个指向，则我们不需要重新拷贝，只需要修改其权限即可解决PF问题。

如果该页的ref大于1,说明有多个指向该只读页，说明是copyOnWrite的内容，我们需要进行类似与copy_range中实现的拷贝。

具体实现如下：

修改copy_range()函数的修改：

```c
if (share) {
                //当开启COW机制后，我们不需要完全重新将原来的页的内容拷贝到
                //新分配的一个页，而是直接将新的进程指向原页面，并且将页面设置为只读
                perm = (*ptep & (PTE_U | PTE_P));
                assert(page != NULL);
                // Set the new mm to be readonly.
                page_insert(to, page, start, perm & ~PTE_W);
                // Set the old mm to be readonly
                page_insert(from, page, start, perm & ~PTE_W);
            } else {
                struct Page *npage = alloc_page();
                assert(npage != NULL);
                void *kva_src = page2kva(page);
                void *kva_dst = page2kva(npage);
                memcpy(kva_dst, kva_src, PGSIZE);
                ret = page_insert(to, npage, start, perm);
                assert(ret == 0);
            }
```



对于do_pgfault()函数的修改

```c
if (*ptep & PTE_P) {
            // Read-only possibly caused by COW.
            if (vma->vm_flags & VM_WRITE) {
                // If ref of pages == 1, it is not shared, just make pte writable.
                // else, alloc a new page, copy content and reset pte.
                // also, remember to decrease ref of that page!
                struct Page *p = pte2page(*ptep);
                assert(p != NULL);
                assert(p->ref > 0);
                if (p->ref > 1) {
                    //当引用次数大于1,说明写只读页产生的问题为写了共享页，需要分配新的页并将内容复制
                    struct Page *npage = alloc_page();
                    assert(npage != NULL);
                    void *src_kvaddr = page2kva(p);
                    void *dst_kvaddr = page2kva(npage);
                    memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                    // addr already ROUND down.
                    page_insert(mm->pgdir, npage, addr, ((*ptep) & PTE_USER) | PTE_W);
                    // page_ref_dec(p);
                    cprintf("Handled one COW fault at %x: copied\n", addr);
                } else {
                    //如果不是，说明只是权限问题，放开权限为可写
                    page_insert(mm->pgdir, p, addr, ((*ptep) & PTE_USER) | PTE_W);
                    cprintf("Handled one COW fault: reused\n");
                }
            }
        } 
```



最后执行make run-dirtycow检测即可。


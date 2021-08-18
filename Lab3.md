Lab3:虚拟内存管理

前置知识：关于中断处理，参考Lab1笔记以及启动，中断，异常，系统调用笔记

Lab3依赖于Lab1中的中断处理框架，以及Lab2的物理内存管理框架



### 练习1

我们在LAB2中的练习完成了通过一个虚地址访问页表项（如果不存在就分配页并创建），但是我们不知道使用这个方法的时机。

完成do_pgfault函数，给未映射的地址映射上物理页（本质上就是缺页异常的中断服务例程,即重新建立虚拟页面和物理页面的映射）

函数的声明：do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) 

这个addr就是引起访问异常的线性地址,mm为虚拟地址使用的pdt的，error_code包含了错误的信息

明确的定义，函数流程：

该函数根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限，如果在此范围内并且权限也正确，这认为这是一次合法访问，但没有建立虚实对应关系。所以需要分配一个空闲的内存页，并修改页表完成虚地址到物理地址的映射，刷新TLB，然后调用iret中断，返回到产生页访问异常的指令处重新执行此指令。如果该虚地址不在某VMA范围内，则认为是一次非法访问！

参考资料：Page Fault异常处理！！这一章把这个函数解析得很透彻！

![image](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab3_figs/image002.png)

一些会使用到的函数:

get_pte(pde_t *pgdir, uintptr_t la, bool create) 这个就是Lab2自己实现的那个函数！根据线性地址和页目录获取得到pte的内核地址（如果不存在就分配一个页然后创建这个PTE，如果既不存在，又不愿意创建，就return null）

pgdir_alloc_page：调用 alloc_page 和 page_insert 函数来分配页大小的内存并设置具有逻辑地址 la 和 PDT pgdir 的地址映射 pa <—> la（物理地址和逻辑地址的映射）

首先剖析page_insert函数：

```c
//page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1); //根据逻辑地址找到对应的PTE
    if (ptep == NULL) {
        return -E_NO_MEM;  //创建失败，直接返回内存不足错误
    }
    page_ref_inc(page);//记录访问次数加一
    if (*ptep & PTE_P) {  //如果PTE的标记位是Present，即当前物理页是存在的
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page); //如果要插入的页就是当前的页，那没事了，不算是访问，ref--
        }
        else {
            page_remove_pte(pgdir, la, ptep);  //如果不是，把不对的页给移走
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;    //页表项内容更新，这样线性地址和物理的关系就建立好了
    tlb_invalidate(pgdir, la);   //把该页表项从快表中删掉
    return 0;
}
```

关于要使用的数据结构：

我们剖析一下这个mm结构体！

```c
struct mm_struct {
    // linear list link which sorted by start addr of vma
    list_entry_t mmap_list;
    // current accessed vma, used for speed purpose
    struct vma_struct *mmap_cache;
    pde_t *pgdir; // the PDT of these vma
    int map_count; // the count of these vma
    void *sm_priv; // the private data for swap manager,和swap机制相关
};
```

mmap_list是双向链表头，链接了所有属于同一**页目录表**的虚拟内存地址

mmap_cache就可以理解为是为了加快查询的结构。

pgdir 所指向的就是 mm_struct数据结构所维护的页表。通过访问pgdir可以查找某虚拟地址对应的页表项是否存在以及页表项的属性等。

mm_struct，说白了就是一个比vm_struct更高抽象层次的数据结构罢了，

```c
struct vma_struct {
    // the set of vma using the same PDT（virtual memory area）
    struct mm_struct *vm_mm;  
    uintptr_t vm_start; // start addr of vma
    uintptr_t vm_end; // end addr of vma
    uint32_t vm_flags; // flags of vma
    //linear list link which sorted by start addr of vma
    list_entry_t list_link;
};
```

这是vma_strcut结构

vm_start和vm_end描述了一个**连续地址**的虚拟内存空间的起始位置和结束位置，这两个值都应该是PGSIZE 对齐的（即大小就是一个page大小的倍数），而且描述的是一个合理的地址空间范围（即严格确保 vm_start < vm_end的关系）；list_link是一个双向链表，按照从小到大的顺序把一系列用vma_struct表示的虚拟内存空间链接起来，并且还要求这些链起来的vma_struct应该是不相交的，即vma之间的地址空间无交集；vm_flags表示了这个虚拟内存空间的属性，目前的属性包括：

```c
#define VM_READ 0x00000001 //只读
#define VM_WRITE 0x00000002 //可读写
#define VM_EXEC 0x00000004 //可执行
```

virtual memory area结构指向（表示）一个或多个合法的**虚拟页**,之后再通过我们的二级页表结构就可以指向我们的物理内存空间。



完整阅读 do_pgfault函数：

```c
int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;//地址无效
    }
    //check the error_code
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");//该页面不可写，但是页面不存在且需要写，page fault处理
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;// 当前页面物理页面是存在的，不需要缺页处理
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");//要读一个当前物理页面不在的页面，但虚拟地址不可读或执行
            goto failed;
        }
    }
```

页访问异常错误码有32位。位0为１表示对应物理页不存在，为0表示权限问题；位１为１表示写异常（比如写了只读页,位0表示读异常；位２为１表示访问权限异常（比如用户态程序访问内核空间的数据）

可能出现缺页异常的主要情况：

- 读取的页表项完全为空，目标页帧不存在

- “合法访问”，页表项非空，只是present标识位为0，即要访问的物理页帧现在还在磁盘，需要调回来，也是我们实验要完成的工作
- 不满足访问权限

我们回顾下x86页式管理：32位的线性地址，帮助理解

![img](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab2_figs/image006.png)

就是在PT中新建页表项。

实现的代码如下:

```c
ptep=get_pte(mm->pgdir,addr,1);
    if(*ptep==NULL){
        //在寻找页表项时失败
        goto failed;
    }
    else{
        if(*ptep==0){
            //如果页表项物理地址不存在，说明没有对应页表项，需要分配一个页并且映射物理地址和逻辑地址
            if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
                cprintf("pgdir_alloc_page in do_pgfault failed\n");
                goto failed;
            }
        }
        else{
            if(swap_init_ok){
                struct Page *page=NULL;
                if(ret=swap_in(mm,addr,&page)==0){
                    page_insert(mm->pgdir, page, addr, perm);
                    //将从磁盘转入内存的页插入，使得页目录项可以找到：即将物理地址和逻辑地址映射
                    swap_map_swappable(mm,addr,page,1);
                    //当映射一个可交换的页到mm_struct结构时执行，用于记录也访问情况的相关属性
                    page->pra_vaddr = addr;
                    //该pra_vaddr用来记录此物理页对应的虚拟页的起始地址
                }
                else{
                    //磁盘无法换出页
                    goto failed;
                }
            }
            else{
                //磁盘还未准备好且需要进行磁盘换出
                goto failed;
            }

        }
    }
```

重点思考：缺页异常中断服务例程总体设计（do_pgfault函数设计）

输入参数有：一段连续虚拟地址构成的控制结构体：mm，产生异常的代码：error_code，缺页发生的物理地址：addr。



该函数根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限，如果在此范围内并且权限也正确，这认为这是一次合法访问，但没有建立虚实对应关系。所以需要分配一个空闲的内存页，并修改页表完成虚地址到物理地址的映射，刷新TLB，然后调用iret中断，返回到产生页访问异常的指令处重新执行此指令。如果该虚地址不在某VMA范围内，则认为是一次非法访问！

流程：

- 首先判断error_code，只有当**页被换出到磁盘**或者**还未建立映射的页，即没有合法地址**需要进行接下来的缺页异常处理，其他如**权限存在越界限，写只读页**的情况不会进行下面的缺页异常执行。

- 根据页表项及缺页产生的物理地址找到对应的页目录

  - 如果页表项不存在（页表项此时还未满），说明还未建立映射，则分配一个页，并映射其物理地址和逻辑地址，这样缺页异常执行完毕后重新获取页就能获取到对应的页

  - 如果页表项存在：
    - 说明此时页表项已经建立，只是页在磁盘，我们需要将页从磁盘转入到内存，而转入内存的操作有：
      - 检查磁盘swap区是否已经就绪，如果未就绪说明不能转移
      - 将磁盘对应的物理页转到内存并建立物理映射和逻辑地址映射
      - 记录路页的访问时相关属性
      - 记录物理页对应的虚拟页的起始地址



执行完毕后，将会刷新TLB并调用iret中断，使得能够返回到产生页访问一场的指令处重新执行该指令。



后续思考：

- 页表项和页目录项的结构对于页面置换算法的帮助

  关于页表项：

  我们在换入换出时，我们期望快速由虚存中的页定位到对应的扇区。一个扇区512字节，一个页4KB，则需要8个连续的扇区来表示一个页。在**换出后**，页表项内容32位我们希望能够充分利用：

  首先，最后一位一定为0,表示present为01,即映射关系当前不存在。

  我们想要利用高24位表示一个放在硬盘上的页的起始扇区号：

  ```
  swap_entry_t
  -------------------------
  | offset | reserved | 0 |
  -------------------------
  24 bits    7 bits   1 bit
  ```

  中间7位留作保留位，这样，页表项能够帮助我们快速定位到对应的磁盘。

  

  

- 页访问异常处理参考之前的中断异常处理中硬件所做（保存现场，恢复中断现场等等）

### 练习2

首先考虑一件事，页面置换算法，置换出去的页在硬盘中，那我们又是如何快速定位到，这个页在硬盘的哪里呢？

ucore中的解决方法就是：对PTE的妙用。

我们通过之前的练习搞明白了：当PTE的present位置为0时，表示虚实地址映射关系不存在，那其他的位就这样空闲下来了么？

当然不是，剩下的，恰好可以用来表示**此页在硬盘上的起始扇区的位置**（其从第几个扇区开始）

一个页是确定大小4KB的，原来用于确定物理地址的20位页帧，再加上4位，即PTE的高24位，可以用来表示磁盘区的位置。一个扇区0.5KB，需要8个连续扇区才能放置一个页。

为了简化设计，在swap_check函数中建立了每个虚拟页唯一对应的swap page，其对应关系设定为：虚拟页对应的PTE的索引值 = swap page的扇区起始位置*8。

一个高24位不为0，而最低位为0的PTE表示了一个放在硬盘上的页的起始扇区号。

虽然之前Lab2中以及使用过了物理页Page结构，但是这里对物理页还做了更新：

```c
struct Page {  
……   
list_entry_t pra_page_link;   
uintptr_t pra_vaddr;   
};
```

pra_page_link可用来构造按页的第一次访问时间进行排序的一个链表，这个**链表的开始**表示第一次访问时间最近的页，**链表结尾**表示第一次访问时间最远的页。当然链表头可以就可设置为pra_list_head（定义在swap_fifo.c中），构造的时机是在page fault发生后，进行do_pgfault函数时。pra_vaddr可以用来记录此物理页对应的虚拟页起始地址。

现在我们就要来完成FIFO算法的实现了

要填充的两个函数

其分别的作用是:

map_swappable和swap_out_vistim

swappable：用于函数记录页访问情况的相关属性。每次页面操作置换进去后都会执行这个操作

vistim: 用于挑选需要换出的页。（不需要管换进来哪个）



FIFO算法非常简单，换入和换出操作，只需要注意对pra_page_link，始终保持该双向链表顺序为插入的时间，即越在前面的结点插入时间越晚。

```c
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    //插入到头节点下一处  
    return 0;
}
```



```c
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     /* Select the tail */
     list_entry_t *le = list_prev(head);
     //根据双向链表的特性，头链表的prev就是最早插入的页，也就是即将换出的页
     assert(head!=le);
     struct Page *p = le2page(le, pra_page_link);
     //找到要换出的页
     list_del(le);
     assert(p !=NULL);
     *ptr_page = p;
     //删除的页更新
     return 0;
}
```


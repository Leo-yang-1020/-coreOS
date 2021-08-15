### 前置知识

#### 关于ucore的页机制的描述

![img](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab2_figs/image006.png)

这是一个x86完成的一个基于二级页表的地址映射关系。

页表项存放的地址是线性地址。

线性地址中的高10位作为index决定directory可以确定在页目录表（大小4k）中的位置，内置一个PDE(起始地址由cr3寄存器给出，因为二级页表中的页目录只有一个)

而根据PDE左移12位后的内容可以确定page Table（大小4k）的起始地址，加上虚拟地址的Table项（中间10位）确定在page Table中的位置,里有一个PTE

PTE左移12位后，再加上Offset（页内偏移）确定物理地址。这样看来，物理地址的低十二位直接由线性地址的低十二位决定。这样，物理地址的完整32位就确定了。

我们在Lab2中需要完成对页目录和页表的建立。

页表项内容占32位，其中20位存放着物理页帧号，12位存放着属性位

属性位有

- r/w: 如果是1，说明页面可以修改
- U/S：如果是1，说明页面在用户态可以访问
- A：如果是1，说明这个页已经被访问过

#### 使能页机制

在使能页机制前，存在有映射：即虚地址0xc0000000对应着物理地址的0x00000000

为了在保护模式下使能页机制，OS需要设置cr0寄存器中的bit 31

建立页表的流程如下：

![image-20210328140436686](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210328140436686.png)

页目录大小4k

Lab2与Lab1相比，多了些物理内存探测的功能，在bootasm.S中，在使能A20后，还会通过bios中断获取内存布局

#### 关于Page的数据结构

```c
struct Page {
    int ref;        // page frame's reference counter
    uint32_t flags; // array of flags that describe the status of the page frame
    unsigned int property;// the num of free block, used in first fit pm manager
    list_entry_t page_link;// free list link
};
```

这表示flags目前用到了两个bit表示页目前具有的两种属性，bit 0表示此页是否被保留（reserved），如果是被保留的页，则bit 0会设置为1，且不能放到空闲页链表中，即这样的页不是空闲页，不能动态分配与释放。比如目前内核代码占用的空间就属于这样“被保留”的页。在本实验中，bit 1表示此页是否是free的，如果设置为1，表示这页是free的，可以被分配；如果设置为0，表示这页已经被分配出去了，不能被再二次分配。



### 练习1

注意：练习1也是以页为单位的物理内存分配管理

实现First fit，完成default_init,default_init_memmap,default_alloc_pages, default_free_pages函数的重写

```c
/* In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
   on receiving a request for memory, scans along the list for the first block that is large enough to
   satisfy the request. If the chosen block is significantly larger than that requested, then it is 
   usually split, and the remainder added to the list as another free block.
   Please see Page 196~198, Section 8.2 of Yan Wei Ming's chinese book "Data Structure -- C programming language"
*/
// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: default_init,default_init_memmap,default_alloc_pages, default_free_pages.
/*
 * Details of FFMA
 * (1) Prepare: In order to implement the First-Fit Mem Alloc (FFMA), we should manage the free mem block use some list.
 *              The struct free_area_t is used for the management of free mem blocks. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list implementation.
 *              You should know howto USE: list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *              Another tricky method is to transform a general list struct to a special struct (such as struct page):
 *              you can find some MACRO: le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.)
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *              This fun is used to init a free block (with parameter: addr_base, page_number).
 *              First you should init
(in memlayout.h) in this free block, include:
 *                  p->flags should be set bit PG_property (means this page is valid. In pmm_init fun (in pmm.c),
 *                  the bit PG_reserved is setted in p->flags)
 *                  if this page  is free and is not the first page of free block, p->property should be set to 0.
 *                  if this page  is free and is the first page of free block, p->property should be set to total num of block.
 *                  p->ref should be 0, because now p is free and no reference.
 *                  We can use p->page_link to link this page to free_list, (such as: list_add_before(&free_list, &(p->page_link)); )
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * (4) default_alloc_pages: search find a first free block (block size >=n) in free list and reszie the free block, return the addr
 *              of malloced block.
 *              (4.1) So you should search freelist like this:
 *                       list_entry_t le = &free_list;
 *                       while((le=list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) In while loop, get the struct page and check the p->property (record the num of free block) >=n?
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) If we find this p, then it' means we find a free block(block size >=n), and the first n pages can be malloced.
 *                     Some flag bits of this page should be setted: PG_reserved =1, PG_property =0
 *                     unlink the pages from free_list
 *                     (4.1.2.1) If (p->property >n), we should re-caluclate number of the the rest of this free block,
 *                           (such as: le2page(le,page_link))->property = p->property - n;)
 *                 (4.1.3)  re-caluclate nr_free (number of the the rest of all free block)
 *                 (4.1.4)  return p
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * (5) default_free_pages: relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 */
```

一些关键，不可忽略的数据结构：

First Fit 分配的是以**页为最小单位**的连续地址空间

两个最核心的数据：

```c
 list_entry_t free_list;         // the list header   空闲块双向链表的头
 unsigned int nr_free;           // # of free pages in this free list  空闲块的总数（以页为单位）
struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};
```

我们可以重点关注这个Page结构：property代表这个块有多少个空闲的页。。。这里感觉描述有点问题，page代表的是一个块，一个块由多个页组成（因为这里没有一个明显的单位叫做块，块只是一个虚拟的，便于分辨的，真正的链表链接的还是页，在块的第一个页中给出页的数目）

还需要注意一些链表的操作：

list_del ,list_add_before,list_add_after

list_add_before(le,elem)：将elem插到le的前面（双向循环链表）；

list_add_after(le,elem)：将elem插到le的后面（双向循环链表）；

其中的page_link参考之前给出的双向循环链表结构，相当于是一个接口

default_init_memmap函数负责将根据每个物理页帧的情况来建立空闲页**链表**

即调用一次该函数，就将一个块初始化好放在链表中

注意这里的分配策略：

以页为最基本的分配单位

| 方法or变量             | 含义                                     | 备注                                                       |
| ---------------------- | ---------------------------------------- | ---------------------------------------------------------- |
| Page                   | 代表页帧的结构体                         | 具体代码下面有                                             |
| p->flags               | 页帧的状态                               | 注意，这里的flags有两位！一个表示reserved 一个表示property |
| p->property            | 空闲数量                                 | 表示从该Page开始，该块有多少个空闲页面,是一种表示块的方法  |
| p->page_link           | 页帧里的链表元素                         | 通过这个元素就把页帧用双向链表连接起来了                   |
| p->ref                 | 代表页帧被引用的次数                     | 开始的时候是0次，代表是空的没被引用                        |
| nr_free                | 空闲的空间                               |                                                            |
| free_list              | 串了空闲页帧的双链表                     |                                                            |
| list_init()            | 初始化链表的方法                         |                                                            |
| default_init_memmap()  | 初始化n个空闲块的方法                    | 给出开始的页帧位置和大小，就分配了                         |
| PageReserved           | 检查页帧是否被保留                       |                                                            |
| list_add()             |                                          |                                                            |
| default_alloc_pages(n) | 分配一段空间                             | 他默认用的是First-Fit算法，如果失败返回null                |
| le2page(le, page_link) | 通过链表节点获取页帧指针                 | le是链表指针，page_link是当前节点                          |
| list_del()             |                                          |                                                            |
| ClearPageProperty()    | 设置该页帧的Property参数为无效           |                                                            |
| SetPageProperty()      | 设置该页帧的Property参数为有效           |                                                            |
| default_free_pages()   | 释放页帧                                 |                                                            |
| PageProperty()         | 检查该页的Property是否有效               |                                                            |
| set_page_ref(p,n)      | 用来设置p->ref的值的方法                 | 第一个参数代表page指针，第二个代表要设的值                 |
| SetPageReserved(p)     | 页面被分配后，用来设置表示页面已经被占用 |                                                            |
| ClearPageReserved      | 设置该页帧的被占用为没有被占用           |                                                            |

**理解P->flags**

这里的flag代表了**两位**：一位表示reserved 一位表示property。

原代码中的注释如下:

```c
#define PG_reserved                 0       
// if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       
// if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages),
// and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block,
//then this Page and the memory block is alloced. Or this Page isn't the head page.
```

翻译一下：reserved表示该页是否为内核保留。

property表示该页是否是头页面：如果是1，说明是没有被分配的头页面。

如果是0，说明要么不是头，要么已经被分配，over。







default_alloc_pages函数：负责分配第一个大小的块，分配的策略为:

找到第一个符合的块后，将其从free_list中删除，但是页本身是紧邻在一起的，只是free_list发生了变化而已。

default_free_pages函数：负责释放并紧凑(compaction)

先说说释放的方法：

首先，应该找到要插入的正确的位置，不断的遍历free_list，知道找到某一个块的page的地址**大于**要释放的块的base地址（说明该块的之前应该就是要释放的块！）

之后要修改首地址的property值的大小，然后将这一个块放入链表，不断地使用list_add_before方法，即插入

关于紧凑的方法：对于base+n之后的地址，即free_list下一个，直接修改其长度为0，然后把其加到base上。

对于base之前的地址，需要去探查free_list，直到找到property不为0的那一页（说明是上一块），然后把base的值加在该页，而base的property清0。

### 练习2

```java
 /* LAB2 EXERCISE 2: YOUR CODE
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
```

get_pte(Page table entry)，即获取页表项

功能为：此函数找到一个**虚地址**对应的二级页表项的内核虚地址，如果此二级页表项不存在，则分配一个包含此项的二级页表。传入的参数有：pde表，虚地址

注意PDE和PTE是不同滴！！二级页表结构：先通过虚拟地址访问PDE,取出内容再访问PTE

![img](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab2_figs/image002.png)

这个实验会使用到ucore提供的函数和标志位有：

- PDX (la)：虚拟地址 la 的页面目录条目的索引
- KADDR (pa) : 接受物理地址并返回相应的内核虚拟地址
- set_page_ref (page,1) : 设置页的引用次数，在释放页的时候有用
- page2pa (page): 获取（struct Page *）页面管理的内存的物理地址
- struct Page * alloc_page () : 分配页
- memset (void *s, char c, size_t n) : 将 s 指向的存储区域的前 n 个字节设置为指w定值 c
- PTE_U：位 3，表示用户态的软件可以读取对应地址的物理内存页内容
- PTE_W：位 2，表示物理内存页内容可写
- PTE_P：位 1，表示物理内存页存在

实现的流程步骤与代码：

- 通过给定的虚拟地址以及pgdir（页表起始项地址）找到PDE项

- 检测对应的页是否存在（有一个PTE_P标志位帮助判断，pte_t和其做与运算得到结果）

- 如果不存在，检查create参数，如果为0，则直接返回null（说明该页不存在且不会新创建页面），如果为1，则创建并分配一个新的页面。

- 设置新创建的页的引用次数为1，最后更新页表的标志位的信息

- 如果存在，则需要通过PDE找到PTE，最后返回该二级页表项的内核虚地址

- 寻找的方法为：PTX(la)，找到虚拟地址中表示Table项的值，即找到PTE中的索引

  代码：

  ```c
  pde_t *pdep=&pgdir[PDX(la)];
      if(!(pdep&PTE_P)){
      	if(create==1){
      		struct Page *page=alloc_page();
      		if(page==NULL){
      			return NULL;
      		}
      		set_page_ref(page,1);//设置为已访问
      		uintptr_t pa=page2pa(page);//获当前页面的内存管理地址，便于后续memset操作
      		memset(KADDR(pa),0,PGSIZE);//memset对刚分配的页初始化
      		*pdep = pa | PTE_U | PTE_W | PTE_P; //添加页表项内容
      	}else{
      		return NULL;//create为0，直接返回null
      	}
      }
      //根据pde访问pte
      return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  ```

  

  最核心的一行代码分析：

  ```c
  &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  ```

  首先要确定PTE的起始地址: 通过在PDE的页表项，先取得页表项的起始地址-> PDE_ADDR转化再通过KADDR转化，得到PTE的起始地址，再加上之前得到的偏移（PTX(la)），就是二级页表项（PTE）的内核虚地址。

  关于最后的两个思考题：

  PTE和PDE的结构以及其属性含义：

  参考博客：OS内存空间的管理

  出现页访问异常后，硬件要干的事情：其实这个流程和一般的中断异常处理非常地类似

  - 发现缺页中断，属于内中断，能够在中断向量表(IDT)中找到响应的中断门
  - 根据中断门中的选择子，可以找到其在段描述符表的段描述符
  - 段描述符的base+idt中的offset得到中断服务例程的线性地址
  - 将当前寄存器信息压栈保存，转向执行中断服务例程（缺页处理）
  - 在外存中查找页面，将找到的内存换入到物理内存中并修改页表
  - 最后重新执行导致异常的指令

### 练习3

完善page_remove_pte函数！

释放一个包含某虚地址的物理内存时，对Page结构，对其进行清除处理。并且还需要将虚地址与二级页表对应的表项给清除。

需要使用到的函数：

- struct Page *page pte2page (*ptep): 从 ptep 的值获取相应的页面
- free_page : 释放一个页
- page_ref_dec (page) : page->ref 减一，然后当 ref=0 的时候就意味着这个页应该被释放了
- tlb_invalidate (pde_t *pgdir, uintptr_t la) : 使 TLB 条目无效，但是仅在要编辑的页表是处理器当前正在使用的页表中(TLB是快表)

```c
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
```

过程如下：十分easy

- 检查页面是否存在，如果不存在就无需释放
- 如果存在，先通过ptep找到相应的页面
- 判断该页是否需要释放
- 需要，则释放该页。
- 使用tlb_invalidate函数，将快表中的有关内容清空

```c
if(*ptep & PTE_P){
    	struct Page *page=pte2page (*ptep);
    	if(page_ref_dec()==0){
    		free_page(ptep);
    	}
    	*ptep=0;
    	tlb_invalidate(pgdir,la);
    }
```


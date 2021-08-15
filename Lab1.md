Lab1

> lab1中包含一个bootloader和一个OS。这个bootloader可以从实模式切换到X86保护模式，能够读磁盘并加载ELF执行文件格式，并显示字符。而这lab1中的OS只是一个可以处理时钟中断和显示字符的幼儿园级别OS。

#### 实模式与保护模式

**实模式** ：CPU复位（reset）或加电（power on）的时候以实模式启动，处理器以实模式工作。在实模式下，内存寻址方式和8086相同，由16位段寄存器的内容乘以16（10H）当做段基地址，加上16位偏移地址形成20位的物理地址，最大寻址空间1MB。在实模式下，所有的段都是可以读、写和可执行的。实模式下没有分段或是分页机制，逻辑地址和物理地址相等。

由此得知：

1. 在实模式下最大寻址空间时1M，1M以上的内存空间在实模式下不会被使用。
2. 在实模式所有的内存数据都可以被访问。不存在用户态、内核态之分。
3. 在BIOS加载、MBR、ntdlr启动阶段都处在实模式下。

**保护模式** ：对于保护模式大家并不陌生；是目前操作系统的运行模式，利用内存管理机制来实现线性地址到物理地址的转换，具有完善的任务保护机制。我们的段机制和页机制都是在保护模式才有的。

保护模式常识：

1. 现在应用程序运行的模式均处于保护模式。
2. 横向保护，又叫任务间保护，多任务操作系统中，一个任务不能破坏另一个任务的代码，这是通过内存分页以及不同任务的内存页映射到不同物理内存上来实现的。
3. 纵向保护，又叫任务内保护，系统代码与应用程序代码虽处于同一地址空间，但系统代码具有高优先级，应用程序代码处于低优先级，规定只能高优先级代码访问低优先级代码，这样杜绝用户代码破坏系统代码。

μcore的保护模式，80386的全部32根地址线全部有效，可寻址高达4GB的线性地址空间和物理地址空间，可访问64TB的逻辑地址空间，可采用分段存储管理机制和分页存储管理机制，提供4个特权级和完善的特权检查机制，既能实现资源共享又能保证代码数据的安全及任务的隔离。

#### 第一条指令

![image-20210304213512484](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210304213512484.png)

EIP就是偏移量，计算所得的地址FFFFFFF0H(实模式下的寻址)，也就是加电后要读的第一条指令的地址。

内存的地址正好对应了一块只读的地址。

第一条指令通常是一条长跳转指令

会跳转到一个可以被访问的1M的内存空间运行（实模式）

#### X86的启动顺序，从bios到bootloader

- bios会进行加电自检

- bios加载存储设备的第一个扇区，即主引导扇区的512字节(bootloader)到内存的0x7c00（后续可以设置断点查看）
- 然后再跳转到@0x7c00的第一条指令

#### Bootloarder能做的事

- 将实模式切换为保护模式，并开启段机制(segment level protection)
- 从硬盘上读取kernel ELF格式的ucore kernel并放在内存中的固定位置
- 跳转到ucore OS的入口点执行，并将控制权转给ucore os

#### μcore中的段机制

![image-20210304191035863](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210304191035863.png)

这里的段机制稍微有一点不同

EIP（指令指针寄存器）相当于Offset，即偏移量

在段寄存器中有一个段选择子(seg selector)，拥有一个index，**（一共16位，高13位就是其index）**通过index可以查找描述符表(descriptor table)中的段描述符（segment descriptor)，其中的Base Address加上EIP就是线性地址，在页机制还没启动时，线性地址就等同于物理地址。

**段描述符（segment descriptor)**内容

- 段基地址
- 段界限：规定段大小
- 段属性

μcore中对段机制进行了弱化，即基址都是0，limit大小都是4G，并且没有使用LDT。

最后将cr0寄存器的第0位设为1，即进入保护模式

#### 加载elf格式的ucore OS kernel

> elf格式时linux的主要可执行文件格式

ELF文件由4部分组成，分别是ELF头（ELF header）、程序头表（Program header table）、节（Section）和节头表（Section header table）。实际上，一个文件中不一定包含全部内容，而且它们的位置也未必如同所示这样安排，只有ELF头的位置是固定的，其余各部分的位置、大小等信息由ELF头中的各项值来决定。

#### GCC内联汇编

> GCC对c语言的扩张，可在c语句中直接插入汇编指令

```c
asm ( assembler template
        : output operands                /* optional */
        : input operands                   /* optional */
        : list of clobbered registers   /* optional */
);
```

asm与\_asm\_等价

为什么需要用到内联汇编呢？

因为有时候c语言无法直接对寄存器进行操作，需要使用到汇编级别的代码。

用实际的栗子来帮助读懂gcc的内联汇编

```c
asm("movl $0xffff,%%eax\n")
    //将 ffff存入eax寄存器中
```

![image-20210304203155226](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210304203155226.png)

这段gcc内联汇编对应的含义为：
将cro寄存器的内容放到ebx寄存器中，并且将值传递给c语言中的变量cr0,之后对cr0进行或,将某一位置为1，再重新将cr0（C语言）的值给edx寄存器，最后将edx寄存器的值赋给cr0寄存器，达成修改cr0寄存器内容的效果。

%0代表第一个用到的寄存器，volatile关键字代表不需要做进一步的优化，r代表任意寄存器

#### 练习1：

**前置：阅读makefile并且了解makefile执行的指令**

首先补充了一些关于linux命令行的知识：
dd命令，与cp命令相似，其中的参数：

if=FILE 从FILE中读取数据，而不是默认的标准输入。

of=FILE 往FILE中写入数据，而不是默认的标准输出。

count=N 总共读取N*ibs字节数的数据，当然写入的数据也是这个大小。

seek=N 跳过N*obs字节数再开始写入数据。

conv=notrunc :不截断生成文件

/dev/zero: 该设备无穷尽地提供0，用于向设备或文件写入0

并且与cp命令的不同之处在于：cp是以字节的方式读取，dd是以扇区的方式读取。

我们在lab1中的lab1_result中执行 make clean 后再执行

make V= 显示编译时的细节

关键参数
-fno-bultin 除非用_builtin_前缀，否则不进行builtin函数的优化
-ggdb 此选项将尽可能的生成gdb的可以使用的调试信息
-m32 生成适用于32位环境的代码
-gstabs 此选项以stabs格式声称调试信息，但是不包括gdb调试信息
-nostdinc 使编译器不在系统缺省的头文件目录里面找头文件
-fno-stack-protector不生成用于检测缓冲区溢出的代码
-I<dir> 添加搜索头文件的路径

```makefile
dd if=/dev/zero of=bin/ucore.img count=10000
10000+0 records in
10000+0 records out
5120000 bytes (5.1 MB) copied, 0.0566984 s, 90.3 MB/s
dd if=bin/bootblock of=bin/ucore.img conv=notrunc
1+0 records in
1+0 records out
512 bytes (512 B) copied, 9.9469e-05 s, 5.1 MB/s
dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
146+1 records in
146+1 records out
74923 bytes (75 kB) copied, 0.000296201 s, 253 MB/s
```

这里时生成ucore.img的核心代码，我们可以看到，生成ucore.img依赖于bootblock和kernel。/dev/zero只是填充0。

我们可以寻找bootblock和kernel生成的过程

```makefile
# create bootblock
    146 bootfiles = $(call listf_cc,boot)
    147 $(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))
    148 
    149 bootblock = $(call totarget,bootblock)
    150 
    151 $(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
    152         @echo + ld $@
    153         $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
    154         @$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
    155         @$(OBJDUMP) -t $(call objfile,bootblock) | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call s    155 ymfile,bootblock)
    156         @$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
    157         @$(call totarget,sign) $(call outfile,bootblock) $(bootblock)
    158 
    159 $(call create_target,bootblock)

```

```makefile
# create kernel target
    131 kernel = $(call totarget,kernel)
    132 
    133 $(kernel): tools/kernel.ld
    134 
    135 $(kernel): $(KOBJS)
    136         @echo + ld $@
    137         $(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
    138         @$(OBJDUMP) -S $@ > $(call asmfile,kernel)
    139         @$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)
    140 
    141 $(call create_target,kernel)
```

```makefile
+ cc kern/init/init.c
+ cc kern/libs/readline.c
+ cc kern/libs/stdio.c
+ cc kern/debug/kdebug.c
+ cc kern/debug/kmonitor.c
+ cc kern/debug/panic.c
+ cc kern/driver/clock.c
+ cc kern/driver/console.c
+ cc kern/driver/intr.c
+ cc kern/driver/picirq.c
+ cc kern/trap/trap.c
+ cc kern/trap/trapentry.S
+ cc kern/trap/vectors.S
+ cc kern/mm/pmm.c
+ cc libs/printfmt.c
+ cc libs/string.c
+ ld bin/kernel
```

生成kernel过程就是编译一堆.c和.s文件最后连接生成

```makefile
+ cc boot/bootasm.S
+ cc boot/bootmain.c
+ cc tools/sign.c
    gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o
    gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign
+ ld bin/bootblock
```

而生成我们的bootblock则是依赖了bootasm.s和bootmain.c，sign.c文件（sign.c是检查硬盘规范的文件），并且我们惊奇地发现bootblock的大小为**512字节**

Q2:一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

这里需要找一个sign.c文件，其中有关于评判主引导扇区的特征

```c
buf[510] = 0x55;
    buf[511] = 0xAA;
    FILE *ofp = fopen(argv[2], "wb+");
    size = fwrite(buf, 1, 512, ofp);
    if (size != 512) {
        fprintf(stderr, "write '%s' error, size is %d.\n", argv[2], size);
        return -1;
    }
    fclose(ofp);
    printf("build 512 bytes boot sector: '%s' success!\n", argv[2]);

```

阅读代码，发现，其特征为 510 511作为特征写死，即，结尾为55AA,并且，size必须为512字节，符合规范

55AA被规定为结束标志

 #### 练习2：

练习2.1：

我们从之前的课程所学的知识可以知道，加电后执行的指令放在FFFFFFF0H：

因此我们将断点设置在该处。

之后，我们发现terminal窗口停在0x000fff0处，但是，在看了附录之后，发现，好像bios的第一条指令在0xffff；因此我们直接不设置断点，完全从头开始。

修改gdbinit初始文件，这次不设置断点，让其从头启动：

```makefile
set architecture i8086
#8086架构启动
target remote: 1234
#这里是与qemu交互，因为qemu的端口就是1234
```

![image-20210308211433553](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210308211433553.png)

这里停在了 0xffff0处，我们可以发现第一条指令就是一条长跳转指令，也符合了我们的理论。done

练习2.2及2.3

在初始化位置0x7c00设置实地址断点,测试断点正常

从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较

对于tools目录下的labinit文件，我们是这样设置的

```makefile
file bin/kernel
#代表的是可执行文件,bin目录下只有kernel和sign文件是可执行的，而且sign是用于检查的，这个kernel的生成具体参考前面的makefile
target remote: 1234
set architecture i8086
b *0x7c00
continue
x /2i $pc
#这里是为了打印两条反汇编的指令
```

即断点设置在了0x7c00

```assembly
Breakpoint 1, 0x00007c00 in ?? ()
=> 0x7c00:	cli    
   0x7c01:	cld    
```

这里的cli是开中断指令

![image-20210308161311341](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210308161311341.png)

通过在0x7c00设置断点发现，对比可得，反汇编得到的代码和bootasm.S是相同的，也证实了bootloader在0x7c00处。

> 这里我找了半天没找到这个传说中的block.asm文件。。。无语子

练习2.4：

他说要选一个bootloader或者内核中的代码设置断点并测试,我选择了内核中的某个函数。

在内核中，因为段式存储十分重要，因此我们选择了gdt_init函数，即全局描述符表初始化函数

![image-20210308220433586](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210308220433586.png)

设置断点后，我们看到了停在了0x102935处

![image-20210308220151952](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210308220151952.png)

由反汇编 查看pc的指令信息

再与代码对比

![image-20210308220803663](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210308220803663.png)

现在汇编基础太烂了。。。但是应该式对应得上的....

##### 练习2的总结反思

阅读Makefile中的源码，可以发现：
![image-20210310140044439](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210310140044439.png)

执行 debug lab1-mon后发生的事，首先是qemu的执行指令记录在q.log,然后再使用gdb调节：使用初始化文件labinit

但是练习2.4如果在bootloader设置断点，并不能成功识别函数的位置。。待完成后续工作

#### 练习3：

>  BIOS将通过读取硬盘主引导扇区到内存，并转跳到对应内存中的位置执行bootloader。请分析bootloader是如何完成从实模式进入保护模式的。

关键：阅读bootasm.s的源码理解：

```c
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment
```

cli指令用于关中断，即接下来进行原语(primitive)操作

**补充知识：**

```
	CS：代码段(Code Segment)
    DS：数据段(Data Segment)
    ES：附加数据段(Extra Segment)
    SS：堆栈段(Stack Segment)
    FS：附加段
    GS 附加段
```

General Register(通用寄存器)：EAX/EBX/ECX/EDX/ESI/EDI/ESP/EBP这些寄存器的低16位就是8086的 AX/BX/CX/DX/SI/DI/SP/BP，对于AX,BX,CX,DX这四个寄存器来讲,可以单独存取它们的高8位和低8位 (AH,AL,BH,BL,CH,CL,DH,DL)。它们的含义如下:

```
    EAX：累加器
    EBX：基址寄存器
    ECX：计数器
    EDX：数据寄存器
    ESI：源地址指针寄存器
    EDI：目的地址指针寄存器
    EBP：基址指针寄存器
    ESP：堆栈指针寄存器
```

这样我们就理解了：这里的操作是为了初始化段寄存器，即将ax寄存器的内容放到几个段寄存器中。

xorw %ax,%ax 通过异或操作，设置ax寄存器的值为0

movw %ax,%ds等操作就能将ds,es,ss寄存器通通置为0

打开A20Gate的代码如下：

```assembly
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042  input buffer empty).这条指令含义是从0x64端口读到数据放到ax的低八位
    testb $0x2, %al #这条指令的含义类似于and指令，用于判断
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port
seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
```

补充：

```
inb 从I/O端口读取一个字节(BYTE, HALF-WORD) ;
outb 向I/O端口写入一个字节（BYTE, HALF-WORD） ;
inw 从I/O端口读取一个字（WORD，即两个字节） ;
outw 向I/O端口写入一个字（WORD，即两个字节） ;
JNZ【jump no Zero】与JNE【jump no Equals】
都依据ZF标志位（ 零标志位，判断是不是0） 不为0/不等于时跳转执行
```

从宏观来看，开启A20的步骤为

- 等待8042 input buffer为空，即等待空闲
- 发送Write 8042 Output port(P2)命令到8042 buffer
- 等待8042 input buffer为空
- 设置P2的A20 bit（即1位）为1

而具体到每一条指令：

```assembly
inb $0x64,%al # Get status 
testb $0x2,%al # Busy? 
jnz seta20.1 # Yes
```

这貌似是一个古老的遗传下来的问题**A20地址线“A20” 用来指代第21位地址线（因为地址线是从零开始编号的）。这一位地址很特殊，在CPU启动之后默认总是0**

A20的历史原因我自己查了下，大概是这样的：

大名鼎鼎的cpu 8086有16位寄存器，但是却有20位地址线，intel就发明了段寄存器访问更多内存的方法：

abcd:1234 这个地址（16进制），冒号前面的是段寄存器的值，后面的是程序中访问的地址，那么真正的物理地址计算方法是0xabcd * 0x10 + 0x1234 = 0xacf04 . 这是个20位的地址，刚好可以用在8086的地址总线上。

但是！这可能会产生一个致命的问题：溢出！

 ffff:ffff 这个最大的地址映射到物理地址 0x10ffef ，很明显，这是个超过20位的地址。

Intel 的解决方法是无视第21位，将这个地址当作 0xffef 去访问，即**A20总线置为0**

而对0x64这一port的一顿操作就是为了使A20地址线生效，done！

**初始化GDT表**

GDT本质可以李姐为一个保存多个段描述符的“数组”。

**选择子**（摘自μcore的gitbook）

线性地址部分的选择子是用来选择哪个描述符表和在该表中索引一个描述符的。选择子可以做为指针变量的一部分，从而对应用程序员是可见的，但是一般是由连接加载器来设置的。选择子的格式如下图所示：

![段选择子结构](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image004.png)

那么有了索引，又如何找到gdt呢？

答案是： gdtr 全局描述符表寄存器.GDTR长48位，其中高32位为基地址，低16位为段界限。

来看初始化GDT表的源码，与之前描述的ucore的信息对照：

```assembly
gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
    
define SEG_ASM(type,base,lim)                                  
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)
```

我们可以看到，gdt的大小在 .word后给出： 0x17->也就是24子节点内存，而gdt表有三条信息，即，每条信息有8个字节大小。

第一条为空，符合所讲的：全局描述符的第一个段描述符设定为空段描述符。

第二条描述符为存放bootloader和kernel的代码段：其基础为0，界限为4G，符合前面描述的ucore的特征

第三条描述符同样base address为0，limit为4G，用于存放数据段

这就是初始化gdt的过程

**如何使能及进入保护模式**

```assembly
lgdt gdtdesc  #lgdt gdtdesc，是把gdtdesc这个标识符的值送入全局映射描述符表寄存器GDTR中。
movl %cr0, %eax
orl $CR0_PE_ON, %eax
movl %eax, %cr0
```

前面说到，进入保护模式，需要将cr0寄存器（控制寄存器）的bit0（PE）置为1

而段机制是在保护模式下自动使能的

我们来逐行分析代码：

movl操作将cr0寄存器的内容放到eax寄存器中

orl操作通过或运算，将PE位置为1

最后将eax寄存器运算所得内容反给cr0寄存器，

最后，调用bootmain这样，就进入的保护模式了。

#### 练习4

>  分析bootloader加载ELF格式的OS的过程，阅读bootmain.c

- bootloader如何读取硬盘扇区的？
- bootloader是如何加载ELF格式的OS？

实验给出了如下提示：

- 等待磁盘准备好
- 发出读取扇区的命令
- 等待磁盘准备好
- 把磁盘扇区数据读到指定内存

我们先补充下ucore中IO操作的：

在bootloader中，所有访问硬盘都是PIO方式，即所有IO操作都是通过cpu访问硬盘的IO地址寄存器完成。

而访问第一个硬盘的扇区是同构设置8个IO地址寄存器完成的。

| IO地址 | 功能                                                         |
| ------ | ------------------------------------------------------------ |
| 0x1f0  | 读数据，当0x1f7不为忙状态时，可以读。                        |
| 0x1f2  | 要读写的扇区数，每次读写前，你需要表明你要读写几个扇区。最小是1个扇区 |
| 0x1f3  | 如果是LBA模式，就是LBA参数的0-7位                            |
| 0x1f4  | 如果是LBA模式，就是LBA参数的8-15位                           |
| 0x1f5  | 如果是LBA模式，就是LBA参数的16-23位                          |
| 0x1f6  | 第0~3位：如果是LBA模式就是24-27位 第4位：为0主盘；为1从盘    |
| 0x1f7  | 状态和命令寄存器。操作时先给命令，再读取，如果不是忙状态就从0x1f0端口读数据 |

（摘自gitbook）

0号负责读数据，2号存储要读的扇区数 7号存储状态，

我们来看readsect函数的实现就明白了

```assembly
	waitdisk();

    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
```

```c
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}
```

waitdisk函数很简单，就像空转一样，我们通过与运算，即

将从0x1f7读取到的数据  和1100做与运算不为 0100时等待

即除非当从0x1f7读取的数据的第4位为0，第3位1，否则就一直等待

与之前的0x1f7时状态命令寄存器对应

硬盘空闲后，发出读取扇区的命令。对应的命令字(command)为0x20，放在0x1F7寄存器中；读取的扇区数为1，放在0x1F2寄存器中；读取的扇区起始编号共28位，分成4部分依次放在0x1F3~0x1F6寄存器中。

发出命令后，再次等待硬盘空闲。

最后：insl(0x1F0, dst, SECTSIZE / 4); 对应着空闲完后通过0x1f0读取数据

**小疑惑：为啥这个sectsize要除4？**

查了下unix系统调用，感觉讲得不是很清楚，贴一下：

This family of functions is used to do low level port input and output. The out* functions do port output, the in* functions do port input; the b-suffix functions are byte-width and the w-suffix functions word-width; the _p-suffix functions pause until the I/O completes.

​	They are primarily designed for internal kernel use, but can be used from user space.

​	You compile with **-O** or **-O2** or similar. The functions are defined as inline macros, and will not be substituted in without optimization enabled, causing unresolved references at link time.

​	You use **ioperm**(2) or alternatively **iopl**(2) to tell the kernel to allow the user space application to access the I/O ports in question. Failure to do this will cause the application to receive a segmentation fault

理解了readsect函数，我们就弄明白了bootloader如何读取磁盘的啦！

补充：ELF文件格式：ELF(Executable and linking format)文件格式是Linux系统下的一种常用目标文件(object file)格式，有三种主要类型:

- 用于执行的可执行文件(executable file)，用于提供程序的**进程映像**，加载的内存执行。 这也是本实验的OS文件类型。
- 用于连接的可重定位文件(relocatable file)，可与其它目标文件一起创建可执行文件和共享目标文件。
- 共享目标文件(shared object file),连接器可将它与其它可重定位文件和共享目标文件连接成其它的目标文件，动态连接器又可将它与可执行文件和其它共享目标文件结合起来创建一个进程映像。

接下来要理解bootloader加载ucore的过程，我们就需要聚焦到bootmain函数！

```c
// read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}
```

我们已经弄明白了bootloader是如何从硬盘区读取的，readseg函数就是读取第一个页内容（elfheader）

ELF可执行文件还需要一个文件头，包含整个执行文件的控制结构。（具体参考gitbook，elf.h文件）

之后

```c
#define ELF_MAGIC    0x464C457FU
```

这是判断是否是合格的elf的信息，存储在elfheader的e_magic中，如果相等，说明是合法的elf格式文件

还需要补充的是program header的描述，简单地说,program header包含了程序创建进程映像的必须信息。

```c
struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }
```

创建proheader指针，找到所在地址的方法就是elfheader中的ELFHDR和加上e_phoff偏移量。

末尾地址eph就是ph地址加上e_phnum(程序段数目)。

遍历program header的每个元素时，可以得到每个Segment在文件中的偏移量：p_offset，要加载到内存的地址p_memsz，segment的长虚拟地址：p_va，这样就可以将每个segment加载到对应的内存.

```c
// call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
```

​         最后根据elfheader提供的entry的虚拟地址，得到内核的入口，并且跳转到该地址..

另外，需要注意差错情况，当elf格式不合法时，不能读取，而是要跳转到错误情况

```c
bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
```

**尝试调试**

#### 练习5：

前置知识：

ESP与EBP与EIP

ESP指针：stack栈顶指针，无论何时，始终指向栈顶(ucore中栈顶为低地址)

EBP指针：指向当前函数的栈底指针，作用为作为栈底，便于与偏移量一同，访问函数成员变量等，并且ebp栈的内容为上一个函数的栈底（类比于编译过程中的静态链接）

在调用函数时，首先修改ebp指针，之后将函数的参数压栈，esp指针也会指向栈顶

EIP存储着下一条指令的地址，每执行一条指令，该寄存器变化一次，比如函数地址

![函数栈&EIP、EBP、ESP寄存器的作用](https://www.k2zone.cn/wp-content/uploads/2018/09/stack2.jpg)

入栈过程中，需要注意EBP的变化！

返回地址：指原函数的下一条指令

核心：**在每一层函数调用中，都能通过当时的ebp值“向上（栈底方向）”能获取返回地址、参数值，“向下（栈顶方向）”能获取函数局部变量值（因为参数在调用前就能压栈，而函数的局部变量需要调用后才能压栈）**

在执行一个函数前，就会有其他的数据按照这样的顺序入栈：参数、返回地址、ebp寄存器。

在所有函数被执行前，都会执行两条汇编： pushl  %ebp :对应着将当前ebp寄存器的内容入栈 。

**movl %esp %ebp： 由于esp指针始终指向栈顶，而现在的栈顶是之前入栈的ebp寄存器的内容，即现在的ebp寄存器指向的栈的内容为原函数的ebp寄存器指向的栈指针([ebp])，这样就形成了一条调用链的关系**

如图所示：

![image-20210316111041926](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210316111041926.png)

esp指针**始终**指向栈顶，这个实现方式与pop和push函数相关，我们不用过度追究。

之后才会将函数内的局部变量等信息入栈....

并且ebp寄存器指向的栈的内容为上一级函数的ebp地址。

**补充**：inline修饰,可以理解为，为了减少函数调用的开销，会对编译器产生影响，不会单独开辟函数栈空间

1）内联含函数比一般函数在前面多一个inline修饰符。

2）内联函数是直接复制“镶嵌”到主函数中去的，就是将内联函数的代码直接放在内联函数的位置上，这与一般函数不同，主函数在调用一般函数的时候，是指令跳转到被调用函数的入口地址，执行完被调用函数后，指令再跳转回主函数上继续执行后面的代码；而由于内联函数是将函数的代码直接放在了函数的位置上，所以没有指令跳转，指令按顺序执行。

3）一般函数的代码段只有一份，放在内存中的某个位置上，当程序调用它是，指令就跳转过来；当下一次程序调用它是，指令又跳转过来；而内联函数是程序中调用几次内联函数，内联函数的代码就会复制几份放在对应的位置上

4）内联函数一般在头文件中定义，而一般函数在头文件中声明，在cpp中定义。

##### 实现代码

我们根据他给我们的注释提示一步步地完成我们代码填充

```c
uint32_t ebp=read_ebp();//读取当前ebp寄存器内的内容
	//这里需要知道，read_ebp()的实现是内联函数，即调用read_ebp函数时，读取到的ebp仍然时print_stackframe的ebp，而不是read_ebp函数本身的ebp
	uint32_t eip=read_eip();//读取当前eip寄存器内的内容
	//read_eip就不是内联函数了，原因在于，在调用read_eip函数前，会将下一条指令放入eip，这样read_eip()就能获取到调用函数的eip
	int i,j;
	//循环结束条件有两个，第一个是不能超过函数调用深度，第二个是ebp不能为0
	for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
		cprintf("ebp:0x%08x ",ebp);
		cprintf("eip:%08x ",eip);
		cprintf("args: ");
		for(j=0;j<4;j++){
				 //这里需要注意，参数的所在的位置和指针的问题
	     cprintf("0x%08x ",*((uint32_t *)ebp+2+j));
	}
		print_debuginfo(eip-1);
	    eip=*((uint32_t *)ebp+1);
	  //下一条指令，即eip寄存器所在的位置为当前ebp指针向上再找一格，也有一种等价写法：(uint32_t *)ebp[1]
	    ebp=*((uint32_t *)ebp);
	    //ebp的更新就从当前ebp寄存器内指针中指向的栈的内容中取
	    cprintf("\n");
	}
    	
}
```

最后打印成功的截图：

![image-20210316223335585](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210316223335585.png)

done!!!!

#### 练习6：

第一个小问题：

1. 中断描述符表（也可简称为保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码的入口？

   直接找代码：在mm文件下有一个mmu.h文件，里有一个gatedesc结构，即门结构的构成

```c
struct gatedesc {
    unsigned gd_off_15_0 : 16;        // low 16 bits of offset in segment
    unsigned gd_ss : 16;            // segment selector
    unsigned gd_args : 5;            // # args, 0 for interrupt/trap gates
    unsigned gd_rsv1 : 3;            // reserved(should be zero I guess)
    unsigned gd_type : 4;            // type(STS_{TG,IG32,TG32})
    unsigned gd_s : 1;                // must be 0 (system)
    unsigned gd_dpl : 2;            // descriptor(meaning new) privilege level
    unsigned gd_p : 1;                // Present
    unsigned gd_off_31_16 : 16;        // high bits of offset in segment
};
```

说明一个门的大小为64位 8字节

​		0～15位：偏移地址的0～15位;

　　16～31位：段选择子;

　　32～47位：属性信息（包括DPL等）;

　　48～63位：偏移地址的16～31位。

故我们第一题的答案是：其中第16至32位是段选择子，而前16位和最后16位是段偏移量，二者结合就可以找到中断处理例程的线性地址

问题2：请编程完善kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中，依次对所有中断入口进行初始化。使用mmu.h中的SETGATE宏，填充idt数组内容。每个ISR的入口地址由tools/vectors.c生成，使用trap.c中声明的vectors数组即可在idt_init中使用。

所谓SETGATE宏，就是一个帮助初始化gate的函数，对门结构的信息进行填充，需要你输入的参数有：

- gate(门的信息会被该函数补充)

- isTrap: 1代表是陷阱门（异常）,0代表中断

- sel：代码段选择子(**这里我有一个疑惑，为什么GD_KTEXT（值为8）就是中断处理例程的段选择子？**)

  之后查阅了下，终于找到了答案，在vector.S文件中：声明了中断处理函数属于.text内容

  ![image-20210320215654159](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210320215654159.png)

  因此，故我们段选择子设位GD_KTEXT 

- off:  代码段偏移量（由相应的vectors给出，我们又有疑惑的地方，为什么注释说的vectors给出的是入口地址，但是这里的off偏移量直接使用地址，为什么？）

  在pmm.c文件中，我们又找到了答案

  ![image-20210320220104982](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210320220104982.png)

  SEG_KTEXT的基址为0，故中断处理函数的偏移量就等于地址本身，done!

- dpl：权限级(3代表用户态，0代表核心态)、



对trap.h中的内容进行分析：

```c
#define T_SWITCH_TOU                120    // user/kernel switch
#define T_SWITCH_TOK                121    // user/kernel switch
```

结合gitbook所给提示：

【注意】除了系统调用中断(T_SYSCALL)使用陷阱门描述符且权限为用户态权限以外，其它中断均使用特权级(DPL)为０的中断门描述符，权限为内核态权限；而ucore的应用程序处于特权级３，需要采用｀int 0x80`指令操作（这种方式称为软中断，软件中断，Tra中断，在lab5会碰到）来发出系统调用请求，并要能实现从特权级３到特权级０的转换，所以系统调用中断(T_SYSCALL)所对应的中断门描述符中的特权级（DPL）需要设置为３。

故这里的vecotors[121]是讲特权级切换为内核态的Trap门的地址，并且该陷阱门的dpl为3（应用程序处于特权级3）

故1的代码：

```c
extern uintptr_t __vectors[];
	int i;
	for(i=0;i<256;i++){
		if(i!=121)
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
	}
	SETGATE(idt[121],0,GD_KTEXT,__vectors[121],3);
	//这里是一个重要的细节，121代表转化为内核态的trap gate
	lidt(&idt_pd);//使用lidt指令将idt的起始地址加载到IDTR寄存器
```

3. 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”。

   这个练习比较简单

   ```c
   /* trap_dispatch - dispatch based on what type of trap occurred */
   static void
   trap_dispatch(struct trapframe *tf) {
       char c;
       switch (tf->tf_trapno)
   ```

   这就是根据trap的类型执行不同的操作。

   我们知道init.c中发生的操作有：

   ![image-20210321120812316](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210321120812316.png)

只有在时钟中断初始化进行后才能打印这个100ticks。

而我们clock_init()干了这些事：

```c
void
clock_init(void) {
    // set 8253 timer-chip
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
    pic_enable(IRQ_TIMER);
}
```

这里初始化了一个变量ticks，并且1s会执行100次时钟中断。我们就可以利用这个ticks记录时钟中断的次数

答案代码如下：1s会执行100次下述操作，因此当ticks为100的整数时打印即可

```c
ticks++;
    	if(ticks%100==0){
    		print_ticks();
    	}
```

3的执行截图：

![image-20210321120200198](C:\Users\Leo\AppData\Roaming\Typora\typora-user-images\image-20210321120200198.png)

#### 扩展练习

用户态和核心态之间的相互切换（待做）

##### 练习6的总结反思（重新梳理时看这里即可,在脑海中重新梳理一遍流程）：

梳理一下中断处理的整个流程：

首先，要处理中断，就必须要有维护一个中断向量表（IDT），因此首先需要初始化IDT。

系统将所有的中断事件统一进行了编号（0～255），这个编号称为中断向量。以ucore为例，操作系统内核启动以后，会通过 idt_init 函数初始化 idt 表。

IDT的内容中每一条都对应着一个中断门（或者陷阱门），其中最重要的有段选择子以及高低位偏移量。

IDT初始化后，cpu是如何知道IDT的基址以及其Limit的呢？

有一条指令：LIDT就可以讲IDT的基址和Limit加载到IDTR寄存器。

而有一部分中断服务例程是由我们的**硬件**来完成的：

- 在CPU执行完毕一个指令后（必须要执行完毕后才能响应中断）,会检查中断控制器是否有中断发生，如果有，则cpu会在响应的时钟脉冲读取相应的中断向量。
- 读取到了中断向量，在ucore中每个门的大小为8字节，因此中断向量*8就是IDT的索引。
- 找到了对应的中断门或陷阱门，就可以根据其中的段选择子和偏移量，确定中断服务例程的地址，并且跳转。
- 中断服务处理还会因特权级的不同而不同。即CPL和DPL的比较。假如当前程序处于内核态，中断程序一定是内核态，此时就不存在堆栈的转移，特权级也不需要改变。但如果当前程序处于用户态，则会发生特权级的转化。**CPU在执行中断时，一定不会降低特权级，要么不变（内核自己被冲断），要么提升（用户态程序被中断）**CPU会从当前程序的TSS信息（TR寄存器）里取得该程序的内核栈地址（内核态的SS和ESP），有了该地址，就会将当前的栈切换为内核态栈，并且会将原来的SS和ESP压入现在的栈（便于中断执行完后返回到原来的栈）
- 无论特权级是否会改变，都需要保存中断执行前现场（一些寄存器），便于恢复原来被打断的程序：依次将原来的Eflags,cs,eip,errorCode信息压入
- 最后，CPU会根据中断服务例程的段描述符将要执行的第一条指令加载到CS EIP,这样就进入到了中断服务程序。

中断返回的过程：

- 中断服务例程结束后，会执行IRET（详细看启动，中断，系统调用那篇笔记）指令恢复被打断程序的执行
- 首先会弹出被打断的程序的现场信息，有eflags,cs,eip，会重新开始执行
- 如果有特权级转化，还会弹出SS和ESP，切换到原来的用户态栈

除此之外，还需要关注**软中断**，也就是我们常见的系统调用。所谓软件中断，就是通过软件的指令来触发，而非外设引发的中断。

在Linux下，这个异常具体就是调用int $0x80的汇编指令，这条汇编指令将产生向量为0x80的编程异常。

在ucore中，该指令对应的中断门在121号。该中断门的描述符中的特权级（DPL）为3

但是存在一个问题：系统调用有这么多类型，仅仅靠一个中断门一定不够，因此这么多个系统调用进入内核中后，还需要有一个机制将他们派发到它们各自的服务程序中去。这里就需要引入**系统调用程序**和**系统调用表**

![在这里插入图片描述](https://img-blog.csdn.net/20181018183154271?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NoYW5naHhfMTIz/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

如图所示，这样的机制就可以使用系统调用的多种不同的处理。

具体阐述流程：

对于x86，在执行int $0x80前，会将系统调用号传递给eax寄存器，之后正常执行中断程序，最后在系统调用的处理程序，就会读取eax寄存器里的内容，对应到系统调用表中相应的服务例程。



bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
  100000:	0f 01 15 18 70 11 40 	lgdtl  0x40117018
    movl $KERNEL_DS, %eax
  100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
  100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
  100012:	ea 19 00 10 00 08 00 	ljmp   $0x8,$0x100019

00100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
  100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10001e:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  100023:	e8 02 00 00 00       	call   10002a <kern_init>

00100028 <spin>:

# should never get here
spin:
    jmp spin
  100028:	eb fe                	jmp    100028 <spin>

0010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  10002a:	55                   	push   %ebp
  10002b:	89 e5                	mov    %esp,%ebp
  10002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100030:	ba 68 89 11 00       	mov    $0x118968,%edx
  100035:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  10003a:	29 c2                	sub    %eax,%edx
  10003c:	89 d0                	mov    %edx,%eax
  10003e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100049:	00 
  10004a:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  100051:	e8 ee 56 00 00       	call   105744 <memset>

    cons_init();                // init the console
  100056:	e8 7d 15 00 00       	call   1015d8 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10005b:	c7 45 f4 60 5f 10 00 	movl   $0x105f60,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100065:	89 44 24 04          	mov    %eax,0x4(%esp)
  100069:	c7 04 24 7c 5f 10 00 	movl   $0x105f7c,(%esp)
  100070:	e8 11 02 00 00       	call   100286 <cprintf>

    print_kerninfo();
  100075:	e8 b2 08 00 00       	call   10092c <print_kerninfo>

    grade_backtrace();
  10007a:	e8 86 00 00 00       	call   100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10007f:	e8 4c 31 00 00       	call   1031d0 <pmm_init>

    pic_init();                 // init interrupt controller
  100084:	e8 ac 16 00 00       	call   101735 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100089:	e8 0a 18 00 00       	call   101898 <idt_init>

    clock_init();               // init clock interrupt
  10008e:	e8 fb 0c 00 00       	call   100d8e <clock_init>
    intr_enable();              // enable irq interrupt
  100093:	e8 d8 17 00 00       	call   101870 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  100098:	eb fe                	jmp    100098 <kern_init+0x6e>

0010009a <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  10009a:	55                   	push   %ebp
  10009b:	89 e5                	mov    %esp,%ebp
  10009d:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000a7:	00 
  1000a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000af:	00 
  1000b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000b7:	e8 c0 0c 00 00       	call   100d7c <mon_backtrace>
}
  1000bc:	c9                   	leave  
  1000bd:	c3                   	ret    

001000be <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000be:	55                   	push   %ebp
  1000bf:	89 e5                	mov    %esp,%ebp
  1000c1:	53                   	push   %ebx
  1000c2:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000c5:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000cb:	8d 55 08             	lea    0x8(%ebp),%edx
  1000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000dd:	89 04 24             	mov    %eax,(%esp)
  1000e0:	e8 b5 ff ff ff       	call   10009a <grade_backtrace2>
}
  1000e5:	83 c4 14             	add    $0x14,%esp
  1000e8:	5b                   	pop    %ebx
  1000e9:	5d                   	pop    %ebp
  1000ea:	c3                   	ret    

001000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000eb:	55                   	push   %ebp
  1000ec:	89 e5                	mov    %esp,%ebp
  1000ee:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000f1:	8b 45 10             	mov    0x10(%ebp),%eax
  1000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1000fb:	89 04 24             	mov    %eax,(%esp)
  1000fe:	e8 bb ff ff ff       	call   1000be <grade_backtrace1>
}
  100103:	c9                   	leave  
  100104:	c3                   	ret    

00100105 <grade_backtrace>:

void
grade_backtrace(void) {
  100105:	55                   	push   %ebp
  100106:	89 e5                	mov    %esp,%ebp
  100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10010b:	b8 2a 00 10 00       	mov    $0x10002a,%eax
  100110:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100117:	ff 
  100118:	89 44 24 04          	mov    %eax,0x4(%esp)
  10011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100123:	e8 c3 ff ff ff       	call   1000eb <grade_backtrace0>
}
  100128:	c9                   	leave  
  100129:	c3                   	ret    

0010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10012a:	55                   	push   %ebp
  10012b:	89 e5                	mov    %esp,%ebp
  10012d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100140:	0f b7 c0             	movzwl %ax,%eax
  100143:	83 e0 03             	and    $0x3,%eax
  100146:	89 c2                	mov    %eax,%edx
  100148:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10014d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100151:	89 44 24 04          	mov    %eax,0x4(%esp)
  100155:	c7 04 24 81 5f 10 00 	movl   $0x105f81,(%esp)
  10015c:	e8 25 01 00 00       	call   100286 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100165:	0f b7 d0             	movzwl %ax,%edx
  100168:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10016d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100171:	89 44 24 04          	mov    %eax,0x4(%esp)
  100175:	c7 04 24 8f 5f 10 00 	movl   $0x105f8f,(%esp)
  10017c:	e8 05 01 00 00       	call   100286 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100185:	0f b7 d0             	movzwl %ax,%edx
  100188:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10018d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100191:	89 44 24 04          	mov    %eax,0x4(%esp)
  100195:	c7 04 24 9d 5f 10 00 	movl   $0x105f9d,(%esp)
  10019c:	e8 e5 00 00 00       	call   100286 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001a5:	0f b7 d0             	movzwl %ax,%edx
  1001a8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b5:	c7 04 24 ab 5f 10 00 	movl   $0x105fab,(%esp)
  1001bc:	e8 c5 00 00 00       	call   100286 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001c5:	0f b7 d0             	movzwl %ax,%edx
  1001c8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001d5:	c7 04 24 b9 5f 10 00 	movl   $0x105fb9,(%esp)
  1001dc:	e8 a5 00 00 00       	call   100286 <cprintf>
    round ++;
  1001e1:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001e6:	83 c0 01             	add    $0x1,%eax
  1001e9:	a3 40 7a 11 00       	mov    %eax,0x117a40
}
  1001ee:	c9                   	leave  
  1001ef:	c3                   	ret    

001001f0 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f0:	55                   	push   %ebp
  1001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001f3:	5d                   	pop    %ebp
  1001f4:	c3                   	ret    

001001f5 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001f5:	55                   	push   %ebp
  1001f6:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  1001f8:	5d                   	pop    %ebp
  1001f9:	c3                   	ret    

001001fa <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001fa:	55                   	push   %ebp
  1001fb:	89 e5                	mov    %esp,%ebp
  1001fd:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100200:	e8 25 ff ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100205:	c7 04 24 c8 5f 10 00 	movl   $0x105fc8,(%esp)
  10020c:	e8 75 00 00 00       	call   100286 <cprintf>
    lab1_switch_to_user();
  100211:	e8 da ff ff ff       	call   1001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
  100216:	e8 0f ff ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10021b:	c7 04 24 e8 5f 10 00 	movl   $0x105fe8,(%esp)
  100222:	e8 5f 00 00 00       	call   100286 <cprintf>
    lab1_switch_to_kernel();
  100227:	e8 c9 ff ff ff       	call   1001f5 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10022c:	e8 f9 fe ff ff       	call   10012a <lab1_print_cur_status>
}
  100231:	c9                   	leave  
  100232:	c3                   	ret    

00100233 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100233:	55                   	push   %ebp
  100234:	89 e5                	mov    %esp,%ebp
  100236:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100239:	8b 45 08             	mov    0x8(%ebp),%eax
  10023c:	89 04 24             	mov    %eax,(%esp)
  10023f:	e8 c0 13 00 00       	call   101604 <cons_putc>
    (*cnt) ++;
  100244:	8b 45 0c             	mov    0xc(%ebp),%eax
  100247:	8b 00                	mov    (%eax),%eax
  100249:	8d 50 01             	lea    0x1(%eax),%edx
  10024c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10024f:	89 10                	mov    %edx,(%eax)
}
  100251:	c9                   	leave  
  100252:	c3                   	ret    

00100253 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100253:	55                   	push   %ebp
  100254:	89 e5                	mov    %esp,%ebp
  100256:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100259:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100260:	8b 45 0c             	mov    0xc(%ebp),%eax
  100263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100267:	8b 45 08             	mov    0x8(%ebp),%eax
  10026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100271:	89 44 24 04          	mov    %eax,0x4(%esp)
  100275:	c7 04 24 33 02 10 00 	movl   $0x100233,(%esp)
  10027c:	e8 15 58 00 00       	call   105a96 <vprintfmt>
    return cnt;
  100281:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100284:	c9                   	leave  
  100285:	c3                   	ret    

00100286 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100286:	55                   	push   %ebp
  100287:	89 e5                	mov    %esp,%ebp
  100289:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10028c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10028f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100295:	89 44 24 04          	mov    %eax,0x4(%esp)
  100299:	8b 45 08             	mov    0x8(%ebp),%eax
  10029c:	89 04 24             	mov    %eax,(%esp)
  10029f:	e8 af ff ff ff       	call   100253 <vcprintf>
  1002a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002aa:	c9                   	leave  
  1002ab:	c3                   	ret    

001002ac <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002ac:	55                   	push   %ebp
  1002ad:	89 e5                	mov    %esp,%ebp
  1002af:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b5:	89 04 24             	mov    %eax,(%esp)
  1002b8:	e8 47 13 00 00       	call   101604 <cons_putc>
}
  1002bd:	c9                   	leave  
  1002be:	c3                   	ret    

001002bf <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002bf:	55                   	push   %ebp
  1002c0:	89 e5                	mov    %esp,%ebp
  1002c2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002cc:	eb 13                	jmp    1002e1 <cputs+0x22>
        cputch(c, &cnt);
  1002ce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002d2:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002d9:	89 04 24             	mov    %eax,(%esp)
  1002dc:	e8 52 ff ff ff       	call   100233 <cputch>
    while ((c = *str ++) != '\0') {
  1002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1002e4:	8d 50 01             	lea    0x1(%eax),%edx
  1002e7:	89 55 08             	mov    %edx,0x8(%ebp)
  1002ea:	0f b6 00             	movzbl (%eax),%eax
  1002ed:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002f0:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002f4:	75 d8                	jne    1002ce <cputs+0xf>
    }
    cputch('\n', &cnt);
  1002f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002fd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100304:	e8 2a ff ff ff       	call   100233 <cputch>
    return cnt;
  100309:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10030c:	c9                   	leave  
  10030d:	c3                   	ret    

0010030e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10030e:	55                   	push   %ebp
  10030f:	89 e5                	mov    %esp,%ebp
  100311:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100314:	e8 27 13 00 00       	call   101640 <cons_getc>
  100319:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10031c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100320:	74 f2                	je     100314 <getchar+0x6>
        /* do nothing */;
    return c;
  100322:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100325:	c9                   	leave  
  100326:	c3                   	ret    

00100327 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100327:	55                   	push   %ebp
  100328:	89 e5                	mov    %esp,%ebp
  10032a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10032d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100331:	74 13                	je     100346 <readline+0x1f>
        cprintf("%s", prompt);
  100333:	8b 45 08             	mov    0x8(%ebp),%eax
  100336:	89 44 24 04          	mov    %eax,0x4(%esp)
  10033a:	c7 04 24 07 60 10 00 	movl   $0x106007,(%esp)
  100341:	e8 40 ff ff ff       	call   100286 <cprintf>
    }
    int i = 0, c;
  100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10034d:	e8 bc ff ff ff       	call   10030e <getchar>
  100352:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100355:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100359:	79 07                	jns    100362 <readline+0x3b>
            return NULL;
  10035b:	b8 00 00 00 00       	mov    $0x0,%eax
  100360:	eb 79                	jmp    1003db <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100362:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100366:	7e 28                	jle    100390 <readline+0x69>
  100368:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10036f:	7f 1f                	jg     100390 <readline+0x69>
            cputchar(c);
  100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100374:	89 04 24             	mov    %eax,(%esp)
  100377:	e8 30 ff ff ff       	call   1002ac <cputchar>
            buf[i ++] = c;
  10037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10037f:	8d 50 01             	lea    0x1(%eax),%edx
  100382:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100385:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100388:	88 90 60 7a 11 00    	mov    %dl,0x117a60(%eax)
  10038e:	eb 46                	jmp    1003d6 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100390:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100394:	75 17                	jne    1003ad <readline+0x86>
  100396:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10039a:	7e 11                	jle    1003ad <readline+0x86>
            cputchar(c);
  10039c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10039f:	89 04 24             	mov    %eax,(%esp)
  1003a2:	e8 05 ff ff ff       	call   1002ac <cputchar>
            i --;
  1003a7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1003ab:	eb 29                	jmp    1003d6 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1003ad:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003b1:	74 06                	je     1003b9 <readline+0x92>
  1003b3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003b7:	75 1d                	jne    1003d6 <readline+0xaf>
            cputchar(c);
  1003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003bc:	89 04 24             	mov    %eax,(%esp)
  1003bf:	e8 e8 fe ff ff       	call   1002ac <cputchar>
            buf[i] = '\0';
  1003c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003c7:	05 60 7a 11 00       	add    $0x117a60,%eax
  1003cc:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003cf:	b8 60 7a 11 00       	mov    $0x117a60,%eax
  1003d4:	eb 05                	jmp    1003db <readline+0xb4>
        }
    }
  1003d6:	e9 72 ff ff ff       	jmp    10034d <readline+0x26>
}
  1003db:	c9                   	leave  
  1003dc:	c3                   	ret    

001003dd <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003dd:	55                   	push   %ebp
  1003de:	89 e5                	mov    %esp,%ebp
  1003e0:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003e3:	a1 60 7e 11 00       	mov    0x117e60,%eax
  1003e8:	85 c0                	test   %eax,%eax
  1003ea:	74 02                	je     1003ee <__panic+0x11>
        goto panic_dead;
  1003ec:	eb 48                	jmp    100436 <__panic+0x59>
    }
    is_panic = 1;
  1003ee:	c7 05 60 7e 11 00 01 	movl   $0x1,0x117e60
  1003f5:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003f8:	8d 45 14             	lea    0x14(%ebp),%eax
  1003fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100401:	89 44 24 08          	mov    %eax,0x8(%esp)
  100405:	8b 45 08             	mov    0x8(%ebp),%eax
  100408:	89 44 24 04          	mov    %eax,0x4(%esp)
  10040c:	c7 04 24 0a 60 10 00 	movl   $0x10600a,(%esp)
  100413:	e8 6e fe ff ff       	call   100286 <cprintf>
    vcprintf(fmt, ap);
  100418:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10041b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10041f:	8b 45 10             	mov    0x10(%ebp),%eax
  100422:	89 04 24             	mov    %eax,(%esp)
  100425:	e8 29 fe ff ff       	call   100253 <vcprintf>
    cprintf("\n");
  10042a:	c7 04 24 26 60 10 00 	movl   $0x106026,(%esp)
  100431:	e8 50 fe ff ff       	call   100286 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
  100436:	e8 3b 14 00 00       	call   101876 <intr_disable>
    while (1) {
        kmonitor(NULL);
  10043b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100442:	e8 66 08 00 00       	call   100cad <kmonitor>
    }
  100447:	eb f2                	jmp    10043b <__panic+0x5e>

00100449 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100449:	55                   	push   %ebp
  10044a:	89 e5                	mov    %esp,%ebp
  10044c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10044f:	8d 45 14             	lea    0x14(%ebp),%eax
  100452:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100455:	8b 45 0c             	mov    0xc(%ebp),%eax
  100458:	89 44 24 08          	mov    %eax,0x8(%esp)
  10045c:	8b 45 08             	mov    0x8(%ebp),%eax
  10045f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100463:	c7 04 24 28 60 10 00 	movl   $0x106028,(%esp)
  10046a:	e8 17 fe ff ff       	call   100286 <cprintf>
    vcprintf(fmt, ap);
  10046f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100472:	89 44 24 04          	mov    %eax,0x4(%esp)
  100476:	8b 45 10             	mov    0x10(%ebp),%eax
  100479:	89 04 24             	mov    %eax,(%esp)
  10047c:	e8 d2 fd ff ff       	call   100253 <vcprintf>
    cprintf("\n");
  100481:	c7 04 24 26 60 10 00 	movl   $0x106026,(%esp)
  100488:	e8 f9 fd ff ff       	call   100286 <cprintf>
    va_end(ap);
}
  10048d:	c9                   	leave  
  10048e:	c3                   	ret    

0010048f <is_kernel_panic>:

bool
is_kernel_panic(void) {
  10048f:	55                   	push   %ebp
  100490:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100492:	a1 60 7e 11 00       	mov    0x117e60,%eax
}
  100497:	5d                   	pop    %ebp
  100498:	c3                   	ret    

00100499 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100499:	55                   	push   %ebp
  10049a:	89 e5                	mov    %esp,%ebp
  10049c:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10049f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004a2:	8b 00                	mov    (%eax),%eax
  1004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a7:	8b 45 10             	mov    0x10(%ebp),%eax
  1004aa:	8b 00                	mov    (%eax),%eax
  1004ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004b6:	e9 d2 00 00 00       	jmp    10058d <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004be:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004c1:	01 d0                	add    %edx,%eax
  1004c3:	89 c2                	mov    %eax,%edx
  1004c5:	c1 ea 1f             	shr    $0x1f,%edx
  1004c8:	01 d0                	add    %edx,%eax
  1004ca:	d1 f8                	sar    %eax
  1004cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004d2:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004d5:	eb 04                	jmp    1004db <stab_binsearch+0x42>
            m --;
  1004d7:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004e1:	7c 1f                	jl     100502 <stab_binsearch+0x69>
  1004e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e6:	89 d0                	mov    %edx,%eax
  1004e8:	01 c0                	add    %eax,%eax
  1004ea:	01 d0                	add    %edx,%eax
  1004ec:	c1 e0 02             	shl    $0x2,%eax
  1004ef:	89 c2                	mov    %eax,%edx
  1004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1004f4:	01 d0                	add    %edx,%eax
  1004f6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004fa:	0f b6 c0             	movzbl %al,%eax
  1004fd:	3b 45 14             	cmp    0x14(%ebp),%eax
  100500:	75 d5                	jne    1004d7 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100505:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100508:	7d 0b                	jge    100515 <stab_binsearch+0x7c>
            l = true_m + 1;
  10050a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10050d:	83 c0 01             	add    $0x1,%eax
  100510:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100513:	eb 78                	jmp    10058d <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100515:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10051c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10051f:	89 d0                	mov    %edx,%eax
  100521:	01 c0                	add    %eax,%eax
  100523:	01 d0                	add    %edx,%eax
  100525:	c1 e0 02             	shl    $0x2,%eax
  100528:	89 c2                	mov    %eax,%edx
  10052a:	8b 45 08             	mov    0x8(%ebp),%eax
  10052d:	01 d0                	add    %edx,%eax
  10052f:	8b 40 08             	mov    0x8(%eax),%eax
  100532:	3b 45 18             	cmp    0x18(%ebp),%eax
  100535:	73 13                	jae    10054a <stab_binsearch+0xb1>
            *region_left = m;
  100537:	8b 45 0c             	mov    0xc(%ebp),%eax
  10053a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10053f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100542:	83 c0 01             	add    $0x1,%eax
  100545:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100548:	eb 43                	jmp    10058d <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10054a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10054d:	89 d0                	mov    %edx,%eax
  10054f:	01 c0                	add    %eax,%eax
  100551:	01 d0                	add    %edx,%eax
  100553:	c1 e0 02             	shl    $0x2,%eax
  100556:	89 c2                	mov    %eax,%edx
  100558:	8b 45 08             	mov    0x8(%ebp),%eax
  10055b:	01 d0                	add    %edx,%eax
  10055d:	8b 40 08             	mov    0x8(%eax),%eax
  100560:	3b 45 18             	cmp    0x18(%ebp),%eax
  100563:	76 16                	jbe    10057b <stab_binsearch+0xe2>
            *region_right = m - 1;
  100565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100568:	8d 50 ff             	lea    -0x1(%eax),%edx
  10056b:	8b 45 10             	mov    0x10(%ebp),%eax
  10056e:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100573:	83 e8 01             	sub    $0x1,%eax
  100576:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100579:	eb 12                	jmp    10058d <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10057b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100581:	89 10                	mov    %edx,(%eax)
            l = m;
  100583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100586:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100589:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  10058d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100590:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100593:	0f 8e 22 ff ff ff    	jle    1004bb <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  100599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10059d:	75 0f                	jne    1005ae <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  10059f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a2:	8b 00                	mov    (%eax),%eax
  1005a4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005a7:	8b 45 10             	mov    0x10(%ebp),%eax
  1005aa:	89 10                	mov    %edx,(%eax)
  1005ac:	eb 3f                	jmp    1005ed <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005ae:	8b 45 10             	mov    0x10(%ebp),%eax
  1005b1:	8b 00                	mov    (%eax),%eax
  1005b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005b6:	eb 04                	jmp    1005bc <stab_binsearch+0x123>
  1005b8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005bf:	8b 00                	mov    (%eax),%eax
  1005c1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005c4:	7d 1f                	jge    1005e5 <stab_binsearch+0x14c>
  1005c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005c9:	89 d0                	mov    %edx,%eax
  1005cb:	01 c0                	add    %eax,%eax
  1005cd:	01 d0                	add    %edx,%eax
  1005cf:	c1 e0 02             	shl    $0x2,%eax
  1005d2:	89 c2                	mov    %eax,%edx
  1005d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005d7:	01 d0                	add    %edx,%eax
  1005d9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005dd:	0f b6 c0             	movzbl %al,%eax
  1005e0:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005e3:	75 d3                	jne    1005b8 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005eb:	89 10                	mov    %edx,(%eax)
    }
}
  1005ed:	c9                   	leave  
  1005ee:	c3                   	ret    

001005ef <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005ef:	55                   	push   %ebp
  1005f0:	89 e5                	mov    %esp,%ebp
  1005f2:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f8:	c7 00 48 60 10 00    	movl   $0x106048,(%eax)
    info->eip_line = 0;
  1005fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100601:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100608:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060b:	c7 40 08 48 60 10 00 	movl   $0x106048,0x8(%eax)
    info->eip_fn_namelen = 9;
  100612:	8b 45 0c             	mov    0xc(%ebp),%eax
  100615:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10061c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061f:	8b 55 08             	mov    0x8(%ebp),%edx
  100622:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10062f:	c7 45 f4 50 72 10 00 	movl   $0x107250,-0xc(%ebp)
    stab_end = __STAB_END__;
  100636:	c7 45 f0 40 1e 11 00 	movl   $0x111e40,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10063d:	c7 45 ec 41 1e 11 00 	movl   $0x111e41,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100644:	c7 45 e8 95 48 11 00 	movl   $0x114895,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10064b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10064e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100651:	76 0d                	jbe    100660 <debuginfo_eip+0x71>
  100653:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100656:	83 e8 01             	sub    $0x1,%eax
  100659:	0f b6 00             	movzbl (%eax),%eax
  10065c:	84 c0                	test   %al,%al
  10065e:	74 0a                	je     10066a <debuginfo_eip+0x7b>
        return -1;
  100660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100665:	e9 c0 02 00 00       	jmp    10092a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10066a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100671:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100677:	29 c2                	sub    %eax,%edx
  100679:	89 d0                	mov    %edx,%eax
  10067b:	c1 f8 02             	sar    $0x2,%eax
  10067e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100684:	83 e8 01             	sub    $0x1,%eax
  100687:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  10068a:	8b 45 08             	mov    0x8(%ebp),%eax
  10068d:	89 44 24 10          	mov    %eax,0x10(%esp)
  100691:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100698:	00 
  100699:	8d 45 e0             	lea    -0x20(%ebp),%eax
  10069c:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006aa:	89 04 24             	mov    %eax,(%esp)
  1006ad:	e8 e7 fd ff ff       	call   100499 <stab_binsearch>
    if (lfile == 0)
  1006b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b5:	85 c0                	test   %eax,%eax
  1006b7:	75 0a                	jne    1006c3 <debuginfo_eip+0xd4>
        return -1;
  1006b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006be:	e9 67 02 00 00       	jmp    10092a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1006d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006d6:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006dd:	00 
  1006de:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ef:	89 04 24             	mov    %eax,(%esp)
  1006f2:	e8 a2 fd ff ff       	call   100499 <stab_binsearch>

    if (lfun <= rfun) {
  1006f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006fd:	39 c2                	cmp    %eax,%edx
  1006ff:	7f 7c                	jg     10077d <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100701:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100704:	89 c2                	mov    %eax,%edx
  100706:	89 d0                	mov    %edx,%eax
  100708:	01 c0                	add    %eax,%eax
  10070a:	01 d0                	add    %edx,%eax
  10070c:	c1 e0 02             	shl    $0x2,%eax
  10070f:	89 c2                	mov    %eax,%edx
  100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100714:	01 d0                	add    %edx,%eax
  100716:	8b 10                	mov    (%eax),%edx
  100718:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10071b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10071e:	29 c1                	sub    %eax,%ecx
  100720:	89 c8                	mov    %ecx,%eax
  100722:	39 c2                	cmp    %eax,%edx
  100724:	73 22                	jae    100748 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100726:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100729:	89 c2                	mov    %eax,%edx
  10072b:	89 d0                	mov    %edx,%eax
  10072d:	01 c0                	add    %eax,%eax
  10072f:	01 d0                	add    %edx,%eax
  100731:	c1 e0 02             	shl    $0x2,%eax
  100734:	89 c2                	mov    %eax,%edx
  100736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100739:	01 d0                	add    %edx,%eax
  10073b:	8b 10                	mov    (%eax),%edx
  10073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100740:	01 c2                	add    %eax,%edx
  100742:	8b 45 0c             	mov    0xc(%ebp),%eax
  100745:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100748:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10074b:	89 c2                	mov    %eax,%edx
  10074d:	89 d0                	mov    %edx,%eax
  10074f:	01 c0                	add    %eax,%eax
  100751:	01 d0                	add    %edx,%eax
  100753:	c1 e0 02             	shl    $0x2,%eax
  100756:	89 c2                	mov    %eax,%edx
  100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075b:	01 d0                	add    %edx,%eax
  10075d:	8b 50 08             	mov    0x8(%eax),%edx
  100760:	8b 45 0c             	mov    0xc(%ebp),%eax
  100763:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100766:	8b 45 0c             	mov    0xc(%ebp),%eax
  100769:	8b 40 10             	mov    0x10(%eax),%eax
  10076c:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10076f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100772:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100775:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100778:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10077b:	eb 15                	jmp    100792 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100780:	8b 55 08             	mov    0x8(%ebp),%edx
  100783:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100789:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10078c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10078f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100792:	8b 45 0c             	mov    0xc(%ebp),%eax
  100795:	8b 40 08             	mov    0x8(%eax),%eax
  100798:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10079f:	00 
  1007a0:	89 04 24             	mov    %eax,(%esp)
  1007a3:	e8 10 4e 00 00       	call   1055b8 <strfind>
  1007a8:	89 c2                	mov    %eax,%edx
  1007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ad:	8b 40 08             	mov    0x8(%eax),%eax
  1007b0:	29 c2                	sub    %eax,%edx
  1007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b5:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1007bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007bf:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007c6:	00 
  1007c7:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007ce:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007d8:	89 04 24             	mov    %eax,(%esp)
  1007db:	e8 b9 fc ff ff       	call   100499 <stab_binsearch>
    if (lline <= rline) {
  1007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007e6:	39 c2                	cmp    %eax,%edx
  1007e8:	7f 24                	jg     10080e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  1007ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007ed:	89 c2                	mov    %eax,%edx
  1007ef:	89 d0                	mov    %edx,%eax
  1007f1:	01 c0                	add    %eax,%eax
  1007f3:	01 d0                	add    %edx,%eax
  1007f5:	c1 e0 02             	shl    $0x2,%eax
  1007f8:	89 c2                	mov    %eax,%edx
  1007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fd:	01 d0                	add    %edx,%eax
  1007ff:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100803:	0f b7 d0             	movzwl %ax,%edx
  100806:	8b 45 0c             	mov    0xc(%ebp),%eax
  100809:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10080c:	eb 13                	jmp    100821 <debuginfo_eip+0x232>
        return -1;
  10080e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100813:	e9 12 01 00 00       	jmp    10092a <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100818:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10081b:	83 e8 01             	sub    $0x1,%eax
  10081e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100821:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100827:	39 c2                	cmp    %eax,%edx
  100829:	7c 56                	jl     100881 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10082b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10082e:	89 c2                	mov    %eax,%edx
  100830:	89 d0                	mov    %edx,%eax
  100832:	01 c0                	add    %eax,%eax
  100834:	01 d0                	add    %edx,%eax
  100836:	c1 e0 02             	shl    $0x2,%eax
  100839:	89 c2                	mov    %eax,%edx
  10083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10083e:	01 d0                	add    %edx,%eax
  100840:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100844:	3c 84                	cmp    $0x84,%al
  100846:	74 39                	je     100881 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100848:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084b:	89 c2                	mov    %eax,%edx
  10084d:	89 d0                	mov    %edx,%eax
  10084f:	01 c0                	add    %eax,%eax
  100851:	01 d0                	add    %edx,%eax
  100853:	c1 e0 02             	shl    $0x2,%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085b:	01 d0                	add    %edx,%eax
  10085d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100861:	3c 64                	cmp    $0x64,%al
  100863:	75 b3                	jne    100818 <debuginfo_eip+0x229>
  100865:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100868:	89 c2                	mov    %eax,%edx
  10086a:	89 d0                	mov    %edx,%eax
  10086c:	01 c0                	add    %eax,%eax
  10086e:	01 d0                	add    %edx,%eax
  100870:	c1 e0 02             	shl    $0x2,%eax
  100873:	89 c2                	mov    %eax,%edx
  100875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100878:	01 d0                	add    %edx,%eax
  10087a:	8b 40 08             	mov    0x8(%eax),%eax
  10087d:	85 c0                	test   %eax,%eax
  10087f:	74 97                	je     100818 <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100881:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100887:	39 c2                	cmp    %eax,%edx
  100889:	7c 46                	jl     1008d1 <debuginfo_eip+0x2e2>
  10088b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10088e:	89 c2                	mov    %eax,%edx
  100890:	89 d0                	mov    %edx,%eax
  100892:	01 c0                	add    %eax,%eax
  100894:	01 d0                	add    %edx,%eax
  100896:	c1 e0 02             	shl    $0x2,%eax
  100899:	89 c2                	mov    %eax,%edx
  10089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10089e:	01 d0                	add    %edx,%eax
  1008a0:	8b 10                	mov    (%eax),%edx
  1008a2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008a8:	29 c1                	sub    %eax,%ecx
  1008aa:	89 c8                	mov    %ecx,%eax
  1008ac:	39 c2                	cmp    %eax,%edx
  1008ae:	73 21                	jae    1008d1 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b3:	89 c2                	mov    %eax,%edx
  1008b5:	89 d0                	mov    %edx,%eax
  1008b7:	01 c0                	add    %eax,%eax
  1008b9:	01 d0                	add    %edx,%eax
  1008bb:	c1 e0 02             	shl    $0x2,%eax
  1008be:	89 c2                	mov    %eax,%edx
  1008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008c3:	01 d0                	add    %edx,%eax
  1008c5:	8b 10                	mov    (%eax),%edx
  1008c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008ca:	01 c2                	add    %eax,%edx
  1008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008cf:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008d7:	39 c2                	cmp    %eax,%edx
  1008d9:	7d 4a                	jge    100925 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  1008db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008de:	83 c0 01             	add    $0x1,%eax
  1008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008e4:	eb 18                	jmp    1008fe <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008e9:	8b 40 14             	mov    0x14(%eax),%eax
  1008ec:	8d 50 01             	lea    0x1(%eax),%edx
  1008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f2:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1008f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f8:	83 c0 01             	add    $0x1,%eax
  1008fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100901:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100904:	39 c2                	cmp    %eax,%edx
  100906:	7d 1d                	jge    100925 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10090b:	89 c2                	mov    %eax,%edx
  10090d:	89 d0                	mov    %edx,%eax
  10090f:	01 c0                	add    %eax,%eax
  100911:	01 d0                	add    %edx,%eax
  100913:	c1 e0 02             	shl    $0x2,%eax
  100916:	89 c2                	mov    %eax,%edx
  100918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10091b:	01 d0                	add    %edx,%eax
  10091d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100921:	3c a0                	cmp    $0xa0,%al
  100923:	74 c1                	je     1008e6 <debuginfo_eip+0x2f7>
        }
    }
    return 0;
  100925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10092a:	c9                   	leave  
  10092b:	c3                   	ret    

0010092c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10092c:	55                   	push   %ebp
  10092d:	89 e5                	mov    %esp,%ebp
  10092f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100932:	c7 04 24 52 60 10 00 	movl   $0x106052,(%esp)
  100939:	e8 48 f9 ff ff       	call   100286 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10093e:	c7 44 24 04 2a 00 10 	movl   $0x10002a,0x4(%esp)
  100945:	00 
  100946:	c7 04 24 6b 60 10 00 	movl   $0x10606b,(%esp)
  10094d:	e8 34 f9 ff ff       	call   100286 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100952:	c7 44 24 04 4e 5f 10 	movl   $0x105f4e,0x4(%esp)
  100959:	00 
  10095a:	c7 04 24 83 60 10 00 	movl   $0x106083,(%esp)
  100961:	e8 20 f9 ff ff       	call   100286 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100966:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  10096d:	00 
  10096e:	c7 04 24 9b 60 10 00 	movl   $0x10609b,(%esp)
  100975:	e8 0c f9 ff ff       	call   100286 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  10097a:	c7 44 24 04 68 89 11 	movl   $0x118968,0x4(%esp)
  100981:	00 
  100982:	c7 04 24 b3 60 10 00 	movl   $0x1060b3,(%esp)
  100989:	e8 f8 f8 ff ff       	call   100286 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10098e:	b8 68 89 11 00       	mov    $0x118968,%eax
  100993:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100999:	b8 2a 00 10 00       	mov    $0x10002a,%eax
  10099e:	29 c2                	sub    %eax,%edx
  1009a0:	89 d0                	mov    %edx,%eax
  1009a2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009a8:	85 c0                	test   %eax,%eax
  1009aa:	0f 48 c2             	cmovs  %edx,%eax
  1009ad:	c1 f8 0a             	sar    $0xa,%eax
  1009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b4:	c7 04 24 cc 60 10 00 	movl   $0x1060cc,(%esp)
  1009bb:	e8 c6 f8 ff ff       	call   100286 <cprintf>
}
  1009c0:	c9                   	leave  
  1009c1:	c3                   	ret    

001009c2 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009c2:	55                   	push   %ebp
  1009c3:	89 e5                	mov    %esp,%ebp
  1009c5:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009cb:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1009d5:	89 04 24             	mov    %eax,(%esp)
  1009d8:	e8 12 fc ff ff       	call   1005ef <debuginfo_eip>
  1009dd:	85 c0                	test   %eax,%eax
  1009df:	74 15                	je     1009f6 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009e8:	c7 04 24 f6 60 10 00 	movl   $0x1060f6,(%esp)
  1009ef:	e8 92 f8 ff ff       	call   100286 <cprintf>
  1009f4:	eb 6d                	jmp    100a63 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009fd:	eb 1c                	jmp    100a1b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a05:	01 d0                	add    %edx,%eax
  100a07:	0f b6 00             	movzbl (%eax),%eax
  100a0a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a13:	01 ca                	add    %ecx,%edx
  100a15:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a21:	7f dc                	jg     1009ff <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
  100a23:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a2c:	01 d0                	add    %edx,%eax
  100a2e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a34:	8b 55 08             	mov    0x8(%ebp),%edx
  100a37:	89 d1                	mov    %edx,%ecx
  100a39:	29 c1                	sub    %eax,%ecx
  100a3b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a41:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a45:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a4b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a4f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a57:	c7 04 24 12 61 10 00 	movl   $0x106112,(%esp)
  100a5e:	e8 23 f8 ff ff       	call   100286 <cprintf>
    }
}
  100a63:	c9                   	leave  
  100a64:	c3                   	ret    

00100a65 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a65:	55                   	push   %ebp
  100a66:	89 e5                	mov    %esp,%ebp
  100a68:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a6b:	8b 45 04             	mov    0x4(%ebp),%eax
  100a6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a74:	c9                   	leave  
  100a75:	c3                   	ret    

00100a76 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a76:	55                   	push   %ebp
  100a77:	89 e5                	mov    %esp,%ebp
  100a79:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a7c:	89 e8                	mov    %ebp,%eax
  100a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
  100a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
  100a87:	e8 d9 ff ff ff       	call   100a65 <read_eip>
  100a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i, j;
	for(i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++) {
  100a8f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a96:	e9 94 00 00 00       	jmp    100b2f <print_stackframe+0xb9>
		cprintf("ebp:0x%08x eip:0x%08x", ebp, eip);
  100a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aa9:	c7 04 24 24 61 10 00 	movl   $0x106124,(%esp)
  100ab0:	e8 d1 f7 ff ff       	call   100286 <cprintf>
		uint32_t *arg = (uint32_t *)ebp + 2;
  100ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab8:	83 c0 08             	add    $0x8,%eax
  100abb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" arg:");
  100abe:	c7 04 24 3a 61 10 00 	movl   $0x10613a,(%esp)
  100ac5:	e8 bc f7 ff ff       	call   100286 <cprintf>
		for(j = 0; j < 4; j++) {
  100aca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ad1:	eb 25                	jmp    100af8 <print_stackframe+0x82>
			cprintf("0x%08x ", arg[j]);
  100ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ad6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ae0:	01 d0                	add    %edx,%eax
  100ae2:	8b 00                	mov    (%eax),%eax
  100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae8:	c7 04 24 40 61 10 00 	movl   $0x106140,(%esp)
  100aef:	e8 92 f7 ff ff       	call   100286 <cprintf>
		for(j = 0; j < 4; j++) {
  100af4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d5                	jle    100ad3 <print_stackframe+0x5d>
		}
		cprintf("\n");
  100afe:	c7 04 24 48 61 10 00 	movl   $0x106148,(%esp)
  100b05:	e8 7c f7 ff ff       	call   100286 <cprintf>
		print_debuginfo(eip - 1);
  100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0d:	83 e8 01             	sub    $0x1,%eax
  100b10:	89 04 24             	mov    %eax,(%esp)
  100b13:	e8 aa fe ff ff       	call   1009c2 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
  100b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b1b:	83 c0 04             	add    $0x4,%eax
  100b1e:	8b 00                	mov    (%eax),%eax
  100b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t*)ebp)[0];
  100b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b26:	8b 00                	mov    (%eax),%eax
  100b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++) {
  100b2b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100b2f:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b33:	7f 0a                	jg     100b3f <print_stackframe+0xc9>
  100b35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b39:	0f 85 5c ff ff ff    	jne    100a9b <print_stackframe+0x25>
	}
}
  100b3f:	c9                   	leave  
  100b40:	c3                   	ret    

00100b41 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b41:	55                   	push   %ebp
  100b42:	89 e5                	mov    %esp,%ebp
  100b44:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4e:	eb 0c                	jmp    100b5c <parse+0x1b>
            *buf ++ = '\0';
  100b50:	8b 45 08             	mov    0x8(%ebp),%eax
  100b53:	8d 50 01             	lea    0x1(%eax),%edx
  100b56:	89 55 08             	mov    %edx,0x8(%ebp)
  100b59:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5f:	0f b6 00             	movzbl (%eax),%eax
  100b62:	84 c0                	test   %al,%al
  100b64:	74 1d                	je     100b83 <parse+0x42>
  100b66:	8b 45 08             	mov    0x8(%ebp),%eax
  100b69:	0f b6 00             	movzbl (%eax),%eax
  100b6c:	0f be c0             	movsbl %al,%eax
  100b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b73:	c7 04 24 cc 61 10 00 	movl   $0x1061cc,(%esp)
  100b7a:	e8 06 4a 00 00       	call   105585 <strchr>
  100b7f:	85 c0                	test   %eax,%eax
  100b81:	75 cd                	jne    100b50 <parse+0xf>
        }
        if (*buf == '\0') {
  100b83:	8b 45 08             	mov    0x8(%ebp),%eax
  100b86:	0f b6 00             	movzbl (%eax),%eax
  100b89:	84 c0                	test   %al,%al
  100b8b:	75 02                	jne    100b8f <parse+0x4e>
            break;
  100b8d:	eb 67                	jmp    100bf6 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b8f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b93:	75 14                	jne    100ba9 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b95:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b9c:	00 
  100b9d:	c7 04 24 d1 61 10 00 	movl   $0x1061d1,(%esp)
  100ba4:	e8 dd f6 ff ff       	call   100286 <cprintf>
        }
        argv[argc ++] = buf;
  100ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bac:	8d 50 01             	lea    0x1(%eax),%edx
  100baf:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bbc:	01 c2                	add    %eax,%edx
  100bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc1:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc3:	eb 04                	jmp    100bc9 <parse+0x88>
            buf ++;
  100bc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bcc:	0f b6 00             	movzbl (%eax),%eax
  100bcf:	84 c0                	test   %al,%al
  100bd1:	74 1d                	je     100bf0 <parse+0xaf>
  100bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd6:	0f b6 00             	movzbl (%eax),%eax
  100bd9:	0f be c0             	movsbl %al,%eax
  100bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be0:	c7 04 24 cc 61 10 00 	movl   $0x1061cc,(%esp)
  100be7:	e8 99 49 00 00       	call   105585 <strchr>
  100bec:	85 c0                	test   %eax,%eax
  100bee:	74 d5                	je     100bc5 <parse+0x84>
        }
    }
  100bf0:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bf1:	e9 66 ff ff ff       	jmp    100b5c <parse+0x1b>
    return argc;
  100bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bf9:	c9                   	leave  
  100bfa:	c3                   	ret    

00100bfb <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bfb:	55                   	push   %ebp
  100bfc:	89 e5                	mov    %esp,%ebp
  100bfe:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c01:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c08:	8b 45 08             	mov    0x8(%ebp),%eax
  100c0b:	89 04 24             	mov    %eax,(%esp)
  100c0e:	e8 2e ff ff ff       	call   100b41 <parse>
  100c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c1a:	75 0a                	jne    100c26 <runcmd+0x2b>
        return 0;
  100c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  100c21:	e9 85 00 00 00       	jmp    100cab <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c2d:	eb 5c                	jmp    100c8b <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c2f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c35:	89 d0                	mov    %edx,%eax
  100c37:	01 c0                	add    %eax,%eax
  100c39:	01 d0                	add    %edx,%eax
  100c3b:	c1 e0 02             	shl    $0x2,%eax
  100c3e:	05 20 70 11 00       	add    $0x117020,%eax
  100c43:	8b 00                	mov    (%eax),%eax
  100c45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c49:	89 04 24             	mov    %eax,(%esp)
  100c4c:	e8 95 48 00 00       	call   1054e6 <strcmp>
  100c51:	85 c0                	test   %eax,%eax
  100c53:	75 32                	jne    100c87 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c58:	89 d0                	mov    %edx,%eax
  100c5a:	01 c0                	add    %eax,%eax
  100c5c:	01 d0                	add    %edx,%eax
  100c5e:	c1 e0 02             	shl    $0x2,%eax
  100c61:	05 20 70 11 00       	add    $0x117020,%eax
  100c66:	8b 40 08             	mov    0x8(%eax),%eax
  100c69:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100c6c:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  100c72:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c76:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100c79:	83 c2 04             	add    $0x4,%edx
  100c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  100c80:	89 0c 24             	mov    %ecx,(%esp)
  100c83:	ff d0                	call   *%eax
  100c85:	eb 24                	jmp    100cab <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c8e:	83 f8 02             	cmp    $0x2,%eax
  100c91:	76 9c                	jbe    100c2f <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c93:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9a:	c7 04 24 ef 61 10 00 	movl   $0x1061ef,(%esp)
  100ca1:	e8 e0 f5 ff ff       	call   100286 <cprintf>
    return 0;
  100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cab:	c9                   	leave  
  100cac:	c3                   	ret    

00100cad <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cad:	55                   	push   %ebp
  100cae:	89 e5                	mov    %esp,%ebp
  100cb0:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cb3:	c7 04 24 08 62 10 00 	movl   $0x106208,(%esp)
  100cba:	e8 c7 f5 ff ff       	call   100286 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbf:	c7 04 24 30 62 10 00 	movl   $0x106230,(%esp)
  100cc6:	e8 bb f5 ff ff       	call   100286 <cprintf>

    if (tf != NULL) {
  100ccb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ccf:	74 0b                	je     100cdc <kmonitor+0x2f>
        print_trapframe(tf);
  100cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd4:	89 04 24             	mov    %eax,(%esp)
  100cd7:	e8 74 0d 00 00       	call   101a50 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cdc:	c7 04 24 55 62 10 00 	movl   $0x106255,(%esp)
  100ce3:	e8 3f f6 ff ff       	call   100327 <readline>
  100ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100ceb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cef:	74 18                	je     100d09 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cfb:	89 04 24             	mov    %eax,(%esp)
  100cfe:	e8 f8 fe ff ff       	call   100bfb <runcmd>
  100d03:	85 c0                	test   %eax,%eax
  100d05:	79 02                	jns    100d09 <kmonitor+0x5c>
                break;
  100d07:	eb 02                	jmp    100d0b <kmonitor+0x5e>
            }
        }
    }
  100d09:	eb d1                	jmp    100cdc <kmonitor+0x2f>
}
  100d0b:	c9                   	leave  
  100d0c:	c3                   	ret    

00100d0d <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d0d:	55                   	push   %ebp
  100d0e:	89 e5                	mov    %esp,%ebp
  100d10:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d1a:	eb 3f                	jmp    100d5b <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d1f:	89 d0                	mov    %edx,%eax
  100d21:	01 c0                	add    %eax,%eax
  100d23:	01 d0                	add    %edx,%eax
  100d25:	c1 e0 02             	shl    $0x2,%eax
  100d28:	05 20 70 11 00       	add    $0x117020,%eax
  100d2d:	8b 48 04             	mov    0x4(%eax),%ecx
  100d30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d33:	89 d0                	mov    %edx,%eax
  100d35:	01 c0                	add    %eax,%eax
  100d37:	01 d0                	add    %edx,%eax
  100d39:	c1 e0 02             	shl    $0x2,%eax
  100d3c:	05 20 70 11 00       	add    $0x117020,%eax
  100d41:	8b 00                	mov    (%eax),%eax
  100d43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d4b:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  100d52:	e8 2f f5 ff ff       	call   100286 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d5e:	83 f8 02             	cmp    $0x2,%eax
  100d61:	76 b9                	jbe    100d1c <mon_help+0xf>
    }
    return 0;
  100d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d68:	c9                   	leave  
  100d69:	c3                   	ret    

00100d6a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d6a:	55                   	push   %ebp
  100d6b:	89 e5                	mov    %esp,%ebp
  100d6d:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d70:	e8 b7 fb ff ff       	call   10092c <print_kerninfo>
    return 0;
  100d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d7a:	c9                   	leave  
  100d7b:	c3                   	ret    

00100d7c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d7c:	55                   	push   %ebp
  100d7d:	89 e5                	mov    %esp,%ebp
  100d7f:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d82:	e8 ef fc ff ff       	call   100a76 <print_stackframe>
    return 0;
  100d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d8c:	c9                   	leave  
  100d8d:	c3                   	ret    

00100d8e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d8e:	55                   	push   %ebp
  100d8f:	89 e5                	mov    %esp,%ebp
  100d91:	83 ec 28             	sub    $0x28,%esp
  100d94:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d9a:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100d9e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100da2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100da6:	ee                   	out    %al,(%dx)
  100da7:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dad:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100db1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100db9:	ee                   	out    %al,(%dx)
  100dba:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dc0:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dc4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dc8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dcc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dcd:	c7 05 4c 89 11 00 00 	movl   $0x0,0x11894c
  100dd4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dd7:	c7 04 24 62 62 10 00 	movl   $0x106262,(%esp)
  100dde:	e8 a3 f4 ff ff       	call   100286 <cprintf>
    pic_enable(IRQ_TIMER);
  100de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dea:	e8 18 09 00 00       	call   101707 <pic_enable>
}
  100def:	c9                   	leave  
  100df0:	c3                   	ret    

00100df1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100df1:	55                   	push   %ebp
  100df2:	89 e5                	mov    %esp,%ebp
  100df4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100df7:	9c                   	pushf  
  100df8:	58                   	pop    %eax
  100df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100dff:	25 00 02 00 00       	and    $0x200,%eax
  100e04:	85 c0                	test   %eax,%eax
  100e06:	74 0c                	je     100e14 <__intr_save+0x23>
        intr_disable();
  100e08:	e8 69 0a 00 00       	call   101876 <intr_disable>
        return 1;
  100e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  100e12:	eb 05                	jmp    100e19 <__intr_save+0x28>
    }
    return 0;
  100e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e19:	c9                   	leave  
  100e1a:	c3                   	ret    

00100e1b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e1b:	55                   	push   %ebp
  100e1c:	89 e5                	mov    %esp,%ebp
  100e1e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e25:	74 05                	je     100e2c <__intr_restore+0x11>
        intr_enable();
  100e27:	e8 44 0a 00 00       	call   101870 <intr_enable>
    }
}
  100e2c:	c9                   	leave  
  100e2d:	c3                   	ret    

00100e2e <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e2e:	55                   	push   %ebp
  100e2f:	89 e5                	mov    %esp,%ebp
  100e31:	83 ec 10             	sub    $0x10,%esp
  100e34:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e3a:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e3e:	89 c2                	mov    %eax,%edx
  100e40:	ec                   	in     (%dx),%al
  100e41:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e44:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e4a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e4e:	89 c2                	mov    %eax,%edx
  100e50:	ec                   	in     (%dx),%al
  100e51:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e54:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e5a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e5e:	89 c2                	mov    %eax,%edx
  100e60:	ec                   	in     (%dx),%al
  100e61:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e64:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e6a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e6e:	89 c2                	mov    %eax,%edx
  100e70:	ec                   	in     (%dx),%al
  100e71:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e74:	c9                   	leave  
  100e75:	c3                   	ret    

00100e76 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e76:	55                   	push   %ebp
  100e77:	89 e5                	mov    %esp,%ebp
  100e79:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e7c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e86:	0f b7 00             	movzwl (%eax),%eax
  100e89:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e90:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e98:	0f b7 00             	movzwl (%eax),%eax
  100e9b:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e9f:	74 12                	je     100eb3 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ea1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ea8:	66 c7 05 86 7e 11 00 	movw   $0x3b4,0x117e86
  100eaf:	b4 03 
  100eb1:	eb 13                	jmp    100ec6 <cga_init+0x50>
    } else {
        *cp = was;
  100eb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eba:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ebd:	66 c7 05 86 7e 11 00 	movw   $0x3d4,0x117e86
  100ec4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ec6:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100ecd:	0f b7 c0             	movzwl %ax,%eax
  100ed0:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ed4:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ed8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100edc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee1:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100ee8:	83 c0 01             	add    $0x1,%eax
  100eeb:	0f b7 c0             	movzwl %ax,%eax
  100eee:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef2:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ef6:	89 c2                	mov    %eax,%edx
  100ef8:	ec                   	in     (%dx),%al
  100ef9:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100efc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f00:	0f b6 c0             	movzbl %al,%eax
  100f03:	c1 e0 08             	shl    $0x8,%eax
  100f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f09:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100f10:	0f b7 c0             	movzwl %ax,%eax
  100f13:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f17:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f1b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f1f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f23:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f24:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  100f2b:	83 c0 01             	add    $0x1,%eax
  100f2e:	0f b7 c0             	movzwl %ax,%eax
  100f31:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f35:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f39:	89 c2                	mov    %eax,%edx
  100f3b:	ec                   	in     (%dx),%al
  100f3c:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f3f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f43:	0f b6 c0             	movzbl %al,%eax
  100f46:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f49:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f4c:	a3 80 7e 11 00       	mov    %eax,0x117e80
    crt_pos = pos;
  100f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f54:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
}
  100f5a:	c9                   	leave  
  100f5b:	c3                   	ret    

00100f5c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f5c:	55                   	push   %ebp
  100f5d:	89 e5                	mov    %esp,%ebp
  100f5f:	83 ec 48             	sub    $0x48,%esp
  100f62:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f68:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f6c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f70:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f74:	ee                   	out    %al,(%dx)
  100f75:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f7b:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f7f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f83:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f87:	ee                   	out    %al,(%dx)
  100f88:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f8e:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f92:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f96:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f9a:	ee                   	out    %al,(%dx)
  100f9b:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fa1:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fa5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fa9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fad:	ee                   	out    %al,(%dx)
  100fae:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fb4:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fb8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fbc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fc0:	ee                   	out    %al,(%dx)
  100fc1:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fc7:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fcb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fcf:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fd3:	ee                   	out    %al,(%dx)
  100fd4:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fda:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fde:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fe2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fe6:	ee                   	out    %al,(%dx)
  100fe7:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fed:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100ff1:	89 c2                	mov    %eax,%edx
  100ff3:	ec                   	in     (%dx),%al
  100ff4:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100ff7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ffb:	3c ff                	cmp    $0xff,%al
  100ffd:	0f 95 c0             	setne  %al
  101000:	0f b6 c0             	movzbl %al,%eax
  101003:	a3 88 7e 11 00       	mov    %eax,0x117e88
  101008:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100e:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101012:	89 c2                	mov    %eax,%edx
  101014:	ec                   	in     (%dx),%al
  101015:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101018:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10101e:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101022:	89 c2                	mov    %eax,%edx
  101024:	ec                   	in     (%dx),%al
  101025:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101028:	a1 88 7e 11 00       	mov    0x117e88,%eax
  10102d:	85 c0                	test   %eax,%eax
  10102f:	74 0c                	je     10103d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101031:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101038:	e8 ca 06 00 00       	call   101707 <pic_enable>
    }
}
  10103d:	c9                   	leave  
  10103e:	c3                   	ret    

0010103f <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10103f:	55                   	push   %ebp
  101040:	89 e5                	mov    %esp,%ebp
  101042:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101045:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10104c:	eb 09                	jmp    101057 <lpt_putc_sub+0x18>
        delay();
  10104e:	e8 db fd ff ff       	call   100e2e <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101053:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101057:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10105d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101061:	89 c2                	mov    %eax,%edx
  101063:	ec                   	in     (%dx),%al
  101064:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101067:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10106b:	84 c0                	test   %al,%al
  10106d:	78 09                	js     101078 <lpt_putc_sub+0x39>
  10106f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101076:	7e d6                	jle    10104e <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101078:	8b 45 08             	mov    0x8(%ebp),%eax
  10107b:	0f b6 c0             	movzbl %al,%eax
  10107e:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101084:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101087:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10108b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10108f:	ee                   	out    %al,(%dx)
  101090:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101096:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  10109a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10109e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010a2:	ee                   	out    %al,(%dx)
  1010a3:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010a9:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010ad:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010b1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010b5:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010b6:	c9                   	leave  
  1010b7:	c3                   	ret    

001010b8 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010b8:	55                   	push   %ebp
  1010b9:	89 e5                	mov    %esp,%ebp
  1010bb:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010be:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010c2:	74 0d                	je     1010d1 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c7:	89 04 24             	mov    %eax,(%esp)
  1010ca:	e8 70 ff ff ff       	call   10103f <lpt_putc_sub>
  1010cf:	eb 24                	jmp    1010f5 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010d1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d8:	e8 62 ff ff ff       	call   10103f <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010e4:	e8 56 ff ff ff       	call   10103f <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f0:	e8 4a ff ff ff       	call   10103f <lpt_putc_sub>
    }
}
  1010f5:	c9                   	leave  
  1010f6:	c3                   	ret    

001010f7 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010f7:	55                   	push   %ebp
  1010f8:	89 e5                	mov    %esp,%ebp
  1010fa:	53                   	push   %ebx
  1010fb:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  101101:	b0 00                	mov    $0x0,%al
  101103:	85 c0                	test   %eax,%eax
  101105:	75 07                	jne    10110e <cga_putc+0x17>
        c |= 0x0700;
  101107:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10110e:	8b 45 08             	mov    0x8(%ebp),%eax
  101111:	0f b6 c0             	movzbl %al,%eax
  101114:	83 f8 0a             	cmp    $0xa,%eax
  101117:	74 4c                	je     101165 <cga_putc+0x6e>
  101119:	83 f8 0d             	cmp    $0xd,%eax
  10111c:	74 57                	je     101175 <cga_putc+0x7e>
  10111e:	83 f8 08             	cmp    $0x8,%eax
  101121:	0f 85 88 00 00 00    	jne    1011af <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101127:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10112e:	66 85 c0             	test   %ax,%ax
  101131:	74 30                	je     101163 <cga_putc+0x6c>
            crt_pos --;
  101133:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10113a:	83 e8 01             	sub    $0x1,%eax
  10113d:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101143:	a1 80 7e 11 00       	mov    0x117e80,%eax
  101148:	0f b7 15 84 7e 11 00 	movzwl 0x117e84,%edx
  10114f:	0f b7 d2             	movzwl %dx,%edx
  101152:	01 d2                	add    %edx,%edx
  101154:	01 c2                	add    %eax,%edx
  101156:	8b 45 08             	mov    0x8(%ebp),%eax
  101159:	b0 00                	mov    $0x0,%al
  10115b:	83 c8 20             	or     $0x20,%eax
  10115e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101161:	eb 72                	jmp    1011d5 <cga_putc+0xde>
  101163:	eb 70                	jmp    1011d5 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101165:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10116c:	83 c0 50             	add    $0x50,%eax
  10116f:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101175:	0f b7 1d 84 7e 11 00 	movzwl 0x117e84,%ebx
  10117c:	0f b7 0d 84 7e 11 00 	movzwl 0x117e84,%ecx
  101183:	0f b7 c1             	movzwl %cx,%eax
  101186:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10118c:	c1 e8 10             	shr    $0x10,%eax
  10118f:	89 c2                	mov    %eax,%edx
  101191:	66 c1 ea 06          	shr    $0x6,%dx
  101195:	89 d0                	mov    %edx,%eax
  101197:	c1 e0 02             	shl    $0x2,%eax
  10119a:	01 d0                	add    %edx,%eax
  10119c:	c1 e0 04             	shl    $0x4,%eax
  10119f:	29 c1                	sub    %eax,%ecx
  1011a1:	89 ca                	mov    %ecx,%edx
  1011a3:	89 d8                	mov    %ebx,%eax
  1011a5:	29 d0                	sub    %edx,%eax
  1011a7:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
        break;
  1011ad:	eb 26                	jmp    1011d5 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011af:	8b 0d 80 7e 11 00    	mov    0x117e80,%ecx
  1011b5:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1011bc:	8d 50 01             	lea    0x1(%eax),%edx
  1011bf:	66 89 15 84 7e 11 00 	mov    %dx,0x117e84
  1011c6:	0f b7 c0             	movzwl %ax,%eax
  1011c9:	01 c0                	add    %eax,%eax
  1011cb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1011d1:	66 89 02             	mov    %ax,(%edx)
        break;
  1011d4:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011d5:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1011dc:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011e0:	76 5b                	jbe    10123d <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011e2:	a1 80 7e 11 00       	mov    0x117e80,%eax
  1011e7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011ed:	a1 80 7e 11 00       	mov    0x117e80,%eax
  1011f2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011f9:	00 
  1011fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011fe:	89 04 24             	mov    %eax,(%esp)
  101201:	e8 7d 45 00 00       	call   105783 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101206:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10120d:	eb 15                	jmp    101224 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10120f:	a1 80 7e 11 00       	mov    0x117e80,%eax
  101214:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101217:	01 d2                	add    %edx,%edx
  101219:	01 d0                	add    %edx,%eax
  10121b:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101220:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101224:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10122b:	7e e2                	jle    10120f <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
  10122d:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  101234:	83 e8 50             	sub    $0x50,%eax
  101237:	66 a3 84 7e 11 00    	mov    %ax,0x117e84
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10123d:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  101244:	0f b7 c0             	movzwl %ax,%eax
  101247:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10124b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10124f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101253:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101257:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101258:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  10125f:	66 c1 e8 08          	shr    $0x8,%ax
  101263:	0f b6 c0             	movzbl %al,%eax
  101266:	0f b7 15 86 7e 11 00 	movzwl 0x117e86,%edx
  10126d:	83 c2 01             	add    $0x1,%edx
  101270:	0f b7 d2             	movzwl %dx,%edx
  101273:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101277:	88 45 ed             	mov    %al,-0x13(%ebp)
  10127a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10127e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101282:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101283:	0f b7 05 86 7e 11 00 	movzwl 0x117e86,%eax
  10128a:	0f b7 c0             	movzwl %ax,%eax
  10128d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101291:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101295:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101299:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10129d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10129e:	0f b7 05 84 7e 11 00 	movzwl 0x117e84,%eax
  1012a5:	0f b6 c0             	movzbl %al,%eax
  1012a8:	0f b7 15 86 7e 11 00 	movzwl 0x117e86,%edx
  1012af:	83 c2 01             	add    $0x1,%edx
  1012b2:	0f b7 d2             	movzwl %dx,%edx
  1012b5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012b9:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012bc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012c0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012c4:	ee                   	out    %al,(%dx)
}
  1012c5:	83 c4 34             	add    $0x34,%esp
  1012c8:	5b                   	pop    %ebx
  1012c9:	5d                   	pop    %ebp
  1012ca:	c3                   	ret    

001012cb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012cb:	55                   	push   %ebp
  1012cc:	89 e5                	mov    %esp,%ebp
  1012ce:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012d8:	eb 09                	jmp    1012e3 <serial_putc_sub+0x18>
        delay();
  1012da:	e8 4f fb ff ff       	call   100e2e <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012df:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012e3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012ed:	89 c2                	mov    %eax,%edx
  1012ef:	ec                   	in     (%dx),%al
  1012f0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012f3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012f7:	0f b6 c0             	movzbl %al,%eax
  1012fa:	83 e0 20             	and    $0x20,%eax
  1012fd:	85 c0                	test   %eax,%eax
  1012ff:	75 09                	jne    10130a <serial_putc_sub+0x3f>
  101301:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101308:	7e d0                	jle    1012da <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10130a:	8b 45 08             	mov    0x8(%ebp),%eax
  10130d:	0f b6 c0             	movzbl %al,%eax
  101310:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101316:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101319:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10131d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101321:	ee                   	out    %al,(%dx)
}
  101322:	c9                   	leave  
  101323:	c3                   	ret    

00101324 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101324:	55                   	push   %ebp
  101325:	89 e5                	mov    %esp,%ebp
  101327:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10132a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10132e:	74 0d                	je     10133d <serial_putc+0x19>
        serial_putc_sub(c);
  101330:	8b 45 08             	mov    0x8(%ebp),%eax
  101333:	89 04 24             	mov    %eax,(%esp)
  101336:	e8 90 ff ff ff       	call   1012cb <serial_putc_sub>
  10133b:	eb 24                	jmp    101361 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10133d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101344:	e8 82 ff ff ff       	call   1012cb <serial_putc_sub>
        serial_putc_sub(' ');
  101349:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101350:	e8 76 ff ff ff       	call   1012cb <serial_putc_sub>
        serial_putc_sub('\b');
  101355:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10135c:	e8 6a ff ff ff       	call   1012cb <serial_putc_sub>
    }
}
  101361:	c9                   	leave  
  101362:	c3                   	ret    

00101363 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101363:	55                   	push   %ebp
  101364:	89 e5                	mov    %esp,%ebp
  101366:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101369:	eb 33                	jmp    10139e <cons_intr+0x3b>
        if (c != 0) {
  10136b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10136f:	74 2d                	je     10139e <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101371:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  101376:	8d 50 01             	lea    0x1(%eax),%edx
  101379:	89 15 a4 80 11 00    	mov    %edx,0x1180a4
  10137f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101382:	88 90 a0 7e 11 00    	mov    %dl,0x117ea0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101388:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  10138d:	3d 00 02 00 00       	cmp    $0x200,%eax
  101392:	75 0a                	jne    10139e <cons_intr+0x3b>
                cons.wpos = 0;
  101394:	c7 05 a4 80 11 00 00 	movl   $0x0,0x1180a4
  10139b:	00 00 00 
    while ((c = (*proc)()) != -1) {
  10139e:	8b 45 08             	mov    0x8(%ebp),%eax
  1013a1:	ff d0                	call   *%eax
  1013a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013a6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013aa:	75 bf                	jne    10136b <cons_intr+0x8>
            }
        }
    }
}
  1013ac:	c9                   	leave  
  1013ad:	c3                   	ret    

001013ae <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013ae:	55                   	push   %ebp
  1013af:	89 e5                	mov    %esp,%ebp
  1013b1:	83 ec 10             	sub    $0x10,%esp
  1013b4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ba:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013be:	89 c2                	mov    %eax,%edx
  1013c0:	ec                   	in     (%dx),%al
  1013c1:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013c4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013c8:	0f b6 c0             	movzbl %al,%eax
  1013cb:	83 e0 01             	and    $0x1,%eax
  1013ce:	85 c0                	test   %eax,%eax
  1013d0:	75 07                	jne    1013d9 <serial_proc_data+0x2b>
        return -1;
  1013d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013d7:	eb 2a                	jmp    101403 <serial_proc_data+0x55>
  1013d9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013df:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013e3:	89 c2                	mov    %eax,%edx
  1013e5:	ec                   	in     (%dx),%al
  1013e6:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013e9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013ed:	0f b6 c0             	movzbl %al,%eax
  1013f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013f3:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013f7:	75 07                	jne    101400 <serial_proc_data+0x52>
        c = '\b';
  1013f9:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101400:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101403:	c9                   	leave  
  101404:	c3                   	ret    

00101405 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101405:	55                   	push   %ebp
  101406:	89 e5                	mov    %esp,%ebp
  101408:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10140b:	a1 88 7e 11 00       	mov    0x117e88,%eax
  101410:	85 c0                	test   %eax,%eax
  101412:	74 0c                	je     101420 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101414:	c7 04 24 ae 13 10 00 	movl   $0x1013ae,(%esp)
  10141b:	e8 43 ff ff ff       	call   101363 <cons_intr>
    }
}
  101420:	c9                   	leave  
  101421:	c3                   	ret    

00101422 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101422:	55                   	push   %ebp
  101423:	89 e5                	mov    %esp,%ebp
  101425:	83 ec 38             	sub    $0x38,%esp
  101428:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10142e:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101432:	89 c2                	mov    %eax,%edx
  101434:	ec                   	in     (%dx),%al
  101435:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101438:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10143c:	0f b6 c0             	movzbl %al,%eax
  10143f:	83 e0 01             	and    $0x1,%eax
  101442:	85 c0                	test   %eax,%eax
  101444:	75 0a                	jne    101450 <kbd_proc_data+0x2e>
        return -1;
  101446:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10144b:	e9 59 01 00 00       	jmp    1015a9 <kbd_proc_data+0x187>
  101450:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101456:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10145a:	89 c2                	mov    %eax,%edx
  10145c:	ec                   	in     (%dx),%al
  10145d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101460:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101464:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101467:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10146b:	75 17                	jne    101484 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10146d:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101472:	83 c8 40             	or     $0x40,%eax
  101475:	a3 a8 80 11 00       	mov    %eax,0x1180a8
        return 0;
  10147a:	b8 00 00 00 00       	mov    $0x0,%eax
  10147f:	e9 25 01 00 00       	jmp    1015a9 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101484:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101488:	84 c0                	test   %al,%al
  10148a:	79 47                	jns    1014d3 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10148c:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101491:	83 e0 40             	and    $0x40,%eax
  101494:	85 c0                	test   %eax,%eax
  101496:	75 09                	jne    1014a1 <kbd_proc_data+0x7f>
  101498:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10149c:	83 e0 7f             	and    $0x7f,%eax
  10149f:	eb 04                	jmp    1014a5 <kbd_proc_data+0x83>
  1014a1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a5:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ac:	0f b6 80 60 70 11 00 	movzbl 0x117060(%eax),%eax
  1014b3:	83 c8 40             	or     $0x40,%eax
  1014b6:	0f b6 c0             	movzbl %al,%eax
  1014b9:	f7 d0                	not    %eax
  1014bb:	89 c2                	mov    %eax,%edx
  1014bd:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014c2:	21 d0                	and    %edx,%eax
  1014c4:	a3 a8 80 11 00       	mov    %eax,0x1180a8
        return 0;
  1014c9:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ce:	e9 d6 00 00 00       	jmp    1015a9 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014d3:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014d8:	83 e0 40             	and    $0x40,%eax
  1014db:	85 c0                	test   %eax,%eax
  1014dd:	74 11                	je     1014f0 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014df:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014e3:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  1014e8:	83 e0 bf             	and    $0xffffffbf,%eax
  1014eb:	a3 a8 80 11 00       	mov    %eax,0x1180a8
    }

    shift |= shiftcode[data];
  1014f0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f4:	0f b6 80 60 70 11 00 	movzbl 0x117060(%eax),%eax
  1014fb:	0f b6 d0             	movzbl %al,%edx
  1014fe:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101503:	09 d0                	or     %edx,%eax
  101505:	a3 a8 80 11 00       	mov    %eax,0x1180a8
    shift ^= togglecode[data];
  10150a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150e:	0f b6 80 60 71 11 00 	movzbl 0x117160(%eax),%eax
  101515:	0f b6 d0             	movzbl %al,%edx
  101518:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  10151d:	31 d0                	xor    %edx,%eax
  10151f:	a3 a8 80 11 00       	mov    %eax,0x1180a8

    c = charcode[shift & (CTL | SHIFT)][data];
  101524:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101529:	83 e0 03             	and    $0x3,%eax
  10152c:	8b 14 85 60 75 11 00 	mov    0x117560(,%eax,4),%edx
  101533:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101537:	01 d0                	add    %edx,%eax
  101539:	0f b6 00             	movzbl (%eax),%eax
  10153c:	0f b6 c0             	movzbl %al,%eax
  10153f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101542:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101547:	83 e0 08             	and    $0x8,%eax
  10154a:	85 c0                	test   %eax,%eax
  10154c:	74 22                	je     101570 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10154e:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101552:	7e 0c                	jle    101560 <kbd_proc_data+0x13e>
  101554:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101558:	7f 06                	jg     101560 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10155a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10155e:	eb 10                	jmp    101570 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101560:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101564:	7e 0a                	jle    101570 <kbd_proc_data+0x14e>
  101566:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10156a:	7f 04                	jg     101570 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10156c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101570:	a1 a8 80 11 00       	mov    0x1180a8,%eax
  101575:	f7 d0                	not    %eax
  101577:	83 e0 06             	and    $0x6,%eax
  10157a:	85 c0                	test   %eax,%eax
  10157c:	75 28                	jne    1015a6 <kbd_proc_data+0x184>
  10157e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101585:	75 1f                	jne    1015a6 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101587:	c7 04 24 7d 62 10 00 	movl   $0x10627d,(%esp)
  10158e:	e8 f3 ec ff ff       	call   100286 <cprintf>
  101593:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101599:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10159d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015a1:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015a5:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015a9:	c9                   	leave  
  1015aa:	c3                   	ret    

001015ab <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015ab:	55                   	push   %ebp
  1015ac:	89 e5                	mov    %esp,%ebp
  1015ae:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015b1:	c7 04 24 22 14 10 00 	movl   $0x101422,(%esp)
  1015b8:	e8 a6 fd ff ff       	call   101363 <cons_intr>
}
  1015bd:	c9                   	leave  
  1015be:	c3                   	ret    

001015bf <kbd_init>:

static void
kbd_init(void) {
  1015bf:	55                   	push   %ebp
  1015c0:	89 e5                	mov    %esp,%ebp
  1015c2:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015c5:	e8 e1 ff ff ff       	call   1015ab <kbd_intr>
    pic_enable(IRQ_KBD);
  1015ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015d1:	e8 31 01 00 00       	call   101707 <pic_enable>
}
  1015d6:	c9                   	leave  
  1015d7:	c3                   	ret    

001015d8 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015d8:	55                   	push   %ebp
  1015d9:	89 e5                	mov    %esp,%ebp
  1015db:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015de:	e8 93 f8 ff ff       	call   100e76 <cga_init>
    serial_init();
  1015e3:	e8 74 f9 ff ff       	call   100f5c <serial_init>
    kbd_init();
  1015e8:	e8 d2 ff ff ff       	call   1015bf <kbd_init>
    if (!serial_exists) {
  1015ed:	a1 88 7e 11 00       	mov    0x117e88,%eax
  1015f2:	85 c0                	test   %eax,%eax
  1015f4:	75 0c                	jne    101602 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015f6:	c7 04 24 89 62 10 00 	movl   $0x106289,(%esp)
  1015fd:	e8 84 ec ff ff       	call   100286 <cprintf>
    }
}
  101602:	c9                   	leave  
  101603:	c3                   	ret    

00101604 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101604:	55                   	push   %ebp
  101605:	89 e5                	mov    %esp,%ebp
  101607:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10160a:	e8 e2 f7 ff ff       	call   100df1 <__intr_save>
  10160f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101612:	8b 45 08             	mov    0x8(%ebp),%eax
  101615:	89 04 24             	mov    %eax,(%esp)
  101618:	e8 9b fa ff ff       	call   1010b8 <lpt_putc>
        cga_putc(c);
  10161d:	8b 45 08             	mov    0x8(%ebp),%eax
  101620:	89 04 24             	mov    %eax,(%esp)
  101623:	e8 cf fa ff ff       	call   1010f7 <cga_putc>
        serial_putc(c);
  101628:	8b 45 08             	mov    0x8(%ebp),%eax
  10162b:	89 04 24             	mov    %eax,(%esp)
  10162e:	e8 f1 fc ff ff       	call   101324 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101633:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101636:	89 04 24             	mov    %eax,(%esp)
  101639:	e8 dd f7 ff ff       	call   100e1b <__intr_restore>
}
  10163e:	c9                   	leave  
  10163f:	c3                   	ret    

00101640 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101640:	55                   	push   %ebp
  101641:	89 e5                	mov    %esp,%ebp
  101643:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10164d:	e8 9f f7 ff ff       	call   100df1 <__intr_save>
  101652:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101655:	e8 ab fd ff ff       	call   101405 <serial_intr>
        kbd_intr();
  10165a:	e8 4c ff ff ff       	call   1015ab <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10165f:	8b 15 a0 80 11 00    	mov    0x1180a0,%edx
  101665:	a1 a4 80 11 00       	mov    0x1180a4,%eax
  10166a:	39 c2                	cmp    %eax,%edx
  10166c:	74 31                	je     10169f <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10166e:	a1 a0 80 11 00       	mov    0x1180a0,%eax
  101673:	8d 50 01             	lea    0x1(%eax),%edx
  101676:	89 15 a0 80 11 00    	mov    %edx,0x1180a0
  10167c:	0f b6 80 a0 7e 11 00 	movzbl 0x117ea0(%eax),%eax
  101683:	0f b6 c0             	movzbl %al,%eax
  101686:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101689:	a1 a0 80 11 00       	mov    0x1180a0,%eax
  10168e:	3d 00 02 00 00       	cmp    $0x200,%eax
  101693:	75 0a                	jne    10169f <cons_getc+0x5f>
                cons.rpos = 0;
  101695:	c7 05 a0 80 11 00 00 	movl   $0x0,0x1180a0
  10169c:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016a2:	89 04 24             	mov    %eax,(%esp)
  1016a5:	e8 71 f7 ff ff       	call   100e1b <__intr_restore>
    return c;
  1016aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016ad:	c9                   	leave  
  1016ae:	c3                   	ret    

001016af <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016af:	55                   	push   %ebp
  1016b0:	89 e5                	mov    %esp,%ebp
  1016b2:	83 ec 14             	sub    $0x14,%esp
  1016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1016b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016c0:	66 a3 70 75 11 00    	mov    %ax,0x117570
    if (did_init) {
  1016c6:	a1 ac 80 11 00       	mov    0x1180ac,%eax
  1016cb:	85 c0                	test   %eax,%eax
  1016cd:	74 36                	je     101705 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016cf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016d3:	0f b6 c0             	movzbl %al,%eax
  1016d6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016dc:	88 45 fd             	mov    %al,-0x3(%ebp)
  1016df:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016e3:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016e7:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016e8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016ec:	66 c1 e8 08          	shr    $0x8,%ax
  1016f0:	0f b6 c0             	movzbl %al,%eax
  1016f3:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016f9:	88 45 f9             	mov    %al,-0x7(%ebp)
  1016fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101700:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101704:	ee                   	out    %al,(%dx)
    }
}
  101705:	c9                   	leave  
  101706:	c3                   	ret    

00101707 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101707:	55                   	push   %ebp
  101708:	89 e5                	mov    %esp,%ebp
  10170a:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10170d:	8b 45 08             	mov    0x8(%ebp),%eax
  101710:	ba 01 00 00 00       	mov    $0x1,%edx
  101715:	89 c1                	mov    %eax,%ecx
  101717:	d3 e2                	shl    %cl,%edx
  101719:	89 d0                	mov    %edx,%eax
  10171b:	f7 d0                	not    %eax
  10171d:	89 c2                	mov    %eax,%edx
  10171f:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  101726:	21 d0                	and    %edx,%eax
  101728:	0f b7 c0             	movzwl %ax,%eax
  10172b:	89 04 24             	mov    %eax,(%esp)
  10172e:	e8 7c ff ff ff       	call   1016af <pic_setmask>
}
  101733:	c9                   	leave  
  101734:	c3                   	ret    

00101735 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101735:	55                   	push   %ebp
  101736:	89 e5                	mov    %esp,%ebp
  101738:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10173b:	c7 05 ac 80 11 00 01 	movl   $0x1,0x1180ac
  101742:	00 00 00 
  101745:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10174b:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10174f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101753:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101757:	ee                   	out    %al,(%dx)
  101758:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10175e:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  101762:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101766:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10176a:	ee                   	out    %al,(%dx)
  10176b:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101771:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101775:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101779:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10177d:	ee                   	out    %al,(%dx)
  10177e:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101784:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  101788:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10178c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101790:	ee                   	out    %al,(%dx)
  101791:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101797:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  10179b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10179f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017a3:	ee                   	out    %al,(%dx)
  1017a4:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017aa:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017ae:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017b2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017b6:	ee                   	out    %al,(%dx)
  1017b7:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017bd:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017c1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017c5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017c9:	ee                   	out    %al,(%dx)
  1017ca:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017d0:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017d4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017d8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017dc:	ee                   	out    %al,(%dx)
  1017dd:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  1017e3:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  1017e7:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017eb:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017ef:	ee                   	out    %al,(%dx)
  1017f0:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  1017f6:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  1017fa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017fe:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101802:	ee                   	out    %al,(%dx)
  101803:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101809:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10180d:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101811:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101815:	ee                   	out    %al,(%dx)
  101816:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10181c:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101820:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101824:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101828:	ee                   	out    %al,(%dx)
  101829:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10182f:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101833:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101837:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10183b:	ee                   	out    %al,(%dx)
  10183c:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  101842:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101846:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10184a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10184e:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10184f:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  101856:	66 83 f8 ff          	cmp    $0xffff,%ax
  10185a:	74 12                	je     10186e <pic_init+0x139>
        pic_setmask(irq_mask);
  10185c:	0f b7 05 70 75 11 00 	movzwl 0x117570,%eax
  101863:	0f b7 c0             	movzwl %ax,%eax
  101866:	89 04 24             	mov    %eax,(%esp)
  101869:	e8 41 fe ff ff       	call   1016af <pic_setmask>
    }
}
  10186e:	c9                   	leave  
  10186f:	c3                   	ret    

00101870 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101870:	55                   	push   %ebp
  101871:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101873:	fb                   	sti    
    sti();
}
  101874:	5d                   	pop    %ebp
  101875:	c3                   	ret    

00101876 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101876:	55                   	push   %ebp
  101877:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101879:	fa                   	cli    
    cli();
}
  10187a:	5d                   	pop    %ebp
  10187b:	c3                   	ret    

0010187c <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10187c:	55                   	push   %ebp
  10187d:	89 e5                	mov    %esp,%ebp
  10187f:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101882:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101889:	00 
  10188a:	c7 04 24 c0 62 10 00 	movl   $0x1062c0,(%esp)
  101891:	e8 f0 e9 ff ff       	call   100286 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101896:	c9                   	leave  
  101897:	c3                   	ret    

00101898 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101898:	55                   	push   %ebp
  101899:	89 e5                	mov    %esp,%ebp
  10189b:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
	int i;
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10189e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018a5:	e9 c3 00 00 00       	jmp    10196d <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ad:	8b 04 85 00 76 11 00 	mov    0x117600(,%eax,4),%eax
  1018b4:	89 c2                	mov    %eax,%edx
  1018b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b9:	66 89 14 c5 c0 80 11 	mov    %dx,0x1180c0(,%eax,8)
  1018c0:	00 
  1018c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c4:	66 c7 04 c5 c2 80 11 	movw   $0x8,0x1180c2(,%eax,8)
  1018cb:	00 08 00 
  1018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d1:	0f b6 14 c5 c4 80 11 	movzbl 0x1180c4(,%eax,8),%edx
  1018d8:	00 
  1018d9:	83 e2 e0             	and    $0xffffffe0,%edx
  1018dc:	88 14 c5 c4 80 11 00 	mov    %dl,0x1180c4(,%eax,8)
  1018e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e6:	0f b6 14 c5 c4 80 11 	movzbl 0x1180c4(,%eax,8),%edx
  1018ed:	00 
  1018ee:	83 e2 1f             	and    $0x1f,%edx
  1018f1:	88 14 c5 c4 80 11 00 	mov    %dl,0x1180c4(,%eax,8)
  1018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fb:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  101902:	00 
  101903:	83 e2 f0             	and    $0xfffffff0,%edx
  101906:	83 ca 0e             	or     $0xe,%edx
  101909:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101913:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  10191a:	00 
  10191b:	83 e2 ef             	and    $0xffffffef,%edx
  10191e:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  101925:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101928:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  10192f:	00 
  101930:	83 e2 9f             	and    $0xffffff9f,%edx
  101933:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  10193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193d:	0f b6 14 c5 c5 80 11 	movzbl 0x1180c5(,%eax,8),%edx
  101944:	00 
  101945:	83 ca 80             	or     $0xffffff80,%edx
  101948:	88 14 c5 c5 80 11 00 	mov    %dl,0x1180c5(,%eax,8)
  10194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101952:	8b 04 85 00 76 11 00 	mov    0x117600(,%eax,4),%eax
  101959:	c1 e8 10             	shr    $0x10,%eax
  10195c:	89 c2                	mov    %eax,%edx
  10195e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101961:	66 89 14 c5 c6 80 11 	mov    %dx,0x1180c6(,%eax,8)
  101968:	00 
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101969:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101970:	3d ff 00 00 00       	cmp    $0xff,%eax
  101975:	0f 86 2f ff ff ff    	jbe    1018aa <idt_init+0x12>
    }
	SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  10197b:	a1 e4 77 11 00       	mov    0x1177e4,%eax
  101980:	66 a3 88 84 11 00    	mov    %ax,0x118488
  101986:	66 c7 05 8a 84 11 00 	movw   $0x8,0x11848a
  10198d:	08 00 
  10198f:	0f b6 05 8c 84 11 00 	movzbl 0x11848c,%eax
  101996:	83 e0 e0             	and    $0xffffffe0,%eax
  101999:	a2 8c 84 11 00       	mov    %al,0x11848c
  10199e:	0f b6 05 8c 84 11 00 	movzbl 0x11848c,%eax
  1019a5:	83 e0 1f             	and    $0x1f,%eax
  1019a8:	a2 8c 84 11 00       	mov    %al,0x11848c
  1019ad:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019b4:	83 e0 f0             	and    $0xfffffff0,%eax
  1019b7:	83 c8 0e             	or     $0xe,%eax
  1019ba:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019bf:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019c6:	83 e0 ef             	and    $0xffffffef,%eax
  1019c9:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019ce:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019d5:	83 c8 60             	or     $0x60,%eax
  1019d8:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019dd:	0f b6 05 8d 84 11 00 	movzbl 0x11848d,%eax
  1019e4:	83 c8 80             	or     $0xffffff80,%eax
  1019e7:	a2 8d 84 11 00       	mov    %al,0x11848d
  1019ec:	a1 e4 77 11 00       	mov    0x1177e4,%eax
  1019f1:	c1 e8 10             	shr    $0x10,%eax
  1019f4:	66 a3 8e 84 11 00    	mov    %ax,0x11848e
  1019fa:	c7 45 f8 80 75 11 00 	movl   $0x117580,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a04:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
  101a07:	c9                   	leave  
  101a08:	c3                   	ret    

00101a09 <trapname>:

static const char *
trapname(int trapno) {
  101a09:	55                   	push   %ebp
  101a0a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0f:	83 f8 13             	cmp    $0x13,%eax
  101a12:	77 0c                	ja     101a20 <trapname+0x17>
        return excnames[trapno];
  101a14:	8b 45 08             	mov    0x8(%ebp),%eax
  101a17:	8b 04 85 20 66 10 00 	mov    0x106620(,%eax,4),%eax
  101a1e:	eb 18                	jmp    101a38 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a20:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a24:	7e 0d                	jle    101a33 <trapname+0x2a>
  101a26:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a2a:	7f 07                	jg     101a33 <trapname+0x2a>
        return "Hardware Interrupt";
  101a2c:	b8 ca 62 10 00       	mov    $0x1062ca,%eax
  101a31:	eb 05                	jmp    101a38 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a33:	b8 dd 62 10 00       	mov    $0x1062dd,%eax
}
  101a38:	5d                   	pop    %ebp
  101a39:	c3                   	ret    

00101a3a <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a3a:	55                   	push   %ebp
  101a3b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a40:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a44:	66 83 f8 08          	cmp    $0x8,%ax
  101a48:	0f 94 c0             	sete   %al
  101a4b:	0f b6 c0             	movzbl %al,%eax
}
  101a4e:	5d                   	pop    %ebp
  101a4f:	c3                   	ret    

00101a50 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a50:	55                   	push   %ebp
  101a51:	89 e5                	mov    %esp,%ebp
  101a53:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a56:	8b 45 08             	mov    0x8(%ebp),%eax
  101a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5d:	c7 04 24 1e 63 10 00 	movl   $0x10631e,(%esp)
  101a64:	e8 1d e8 ff ff       	call   100286 <cprintf>
    print_regs(&tf->tf_regs);
  101a69:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6c:	89 04 24             	mov    %eax,(%esp)
  101a6f:	e8 a1 01 00 00       	call   101c15 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a74:	8b 45 08             	mov    0x8(%ebp),%eax
  101a77:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a7b:	0f b7 c0             	movzwl %ax,%eax
  101a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a82:	c7 04 24 2f 63 10 00 	movl   $0x10632f,(%esp)
  101a89:	e8 f8 e7 ff ff       	call   100286 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a91:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a95:	0f b7 c0             	movzwl %ax,%eax
  101a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9c:	c7 04 24 42 63 10 00 	movl   $0x106342,(%esp)
  101aa3:	e8 de e7 ff ff       	call   100286 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aab:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101aaf:	0f b7 c0             	movzwl %ax,%eax
  101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab6:	c7 04 24 55 63 10 00 	movl   $0x106355,(%esp)
  101abd:	e8 c4 e7 ff ff       	call   100286 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ac9:	0f b7 c0             	movzwl %ax,%eax
  101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad0:	c7 04 24 68 63 10 00 	movl   $0x106368,(%esp)
  101ad7:	e8 aa e7 ff ff       	call   100286 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101adc:	8b 45 08             	mov    0x8(%ebp),%eax
  101adf:	8b 40 30             	mov    0x30(%eax),%eax
  101ae2:	89 04 24             	mov    %eax,(%esp)
  101ae5:	e8 1f ff ff ff       	call   101a09 <trapname>
  101aea:	8b 55 08             	mov    0x8(%ebp),%edx
  101aed:	8b 52 30             	mov    0x30(%edx),%edx
  101af0:	89 44 24 08          	mov    %eax,0x8(%esp)
  101af4:	89 54 24 04          	mov    %edx,0x4(%esp)
  101af8:	c7 04 24 7b 63 10 00 	movl   $0x10637b,(%esp)
  101aff:	e8 82 e7 ff ff       	call   100286 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b04:	8b 45 08             	mov    0x8(%ebp),%eax
  101b07:	8b 40 34             	mov    0x34(%eax),%eax
  101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0e:	c7 04 24 8d 63 10 00 	movl   $0x10638d,(%esp)
  101b15:	e8 6c e7 ff ff       	call   100286 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1d:	8b 40 38             	mov    0x38(%eax),%eax
  101b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b24:	c7 04 24 9c 63 10 00 	movl   $0x10639c,(%esp)
  101b2b:	e8 56 e7 ff ff       	call   100286 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b30:	8b 45 08             	mov    0x8(%ebp),%eax
  101b33:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b37:	0f b7 c0             	movzwl %ax,%eax
  101b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3e:	c7 04 24 ab 63 10 00 	movl   $0x1063ab,(%esp)
  101b45:	e8 3c e7 ff ff       	call   100286 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4d:	8b 40 40             	mov    0x40(%eax),%eax
  101b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b54:	c7 04 24 be 63 10 00 	movl   $0x1063be,(%esp)
  101b5b:	e8 26 e7 ff ff       	call   100286 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b6e:	eb 3e                	jmp    101bae <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b70:	8b 45 08             	mov    0x8(%ebp),%eax
  101b73:	8b 50 40             	mov    0x40(%eax),%edx
  101b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b79:	21 d0                	and    %edx,%eax
  101b7b:	85 c0                	test   %eax,%eax
  101b7d:	74 28                	je     101ba7 <print_trapframe+0x157>
  101b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b82:	8b 04 85 a0 75 11 00 	mov    0x1175a0(,%eax,4),%eax
  101b89:	85 c0                	test   %eax,%eax
  101b8b:	74 1a                	je     101ba7 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b90:	8b 04 85 a0 75 11 00 	mov    0x1175a0(,%eax,4),%eax
  101b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b9b:	c7 04 24 cd 63 10 00 	movl   $0x1063cd,(%esp)
  101ba2:	e8 df e6 ff ff       	call   100286 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ba7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bab:	d1 65 f0             	shll   -0x10(%ebp)
  101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bb1:	83 f8 17             	cmp    $0x17,%eax
  101bb4:	76 ba                	jbe    101b70 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb9:	8b 40 40             	mov    0x40(%eax),%eax
  101bbc:	25 00 30 00 00       	and    $0x3000,%eax
  101bc1:	c1 e8 0c             	shr    $0xc,%eax
  101bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc8:	c7 04 24 d1 63 10 00 	movl   $0x1063d1,(%esp)
  101bcf:	e8 b2 e6 ff ff       	call   100286 <cprintf>

    if (!trap_in_kernel(tf)) {
  101bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd7:	89 04 24             	mov    %eax,(%esp)
  101bda:	e8 5b fe ff ff       	call   101a3a <trap_in_kernel>
  101bdf:	85 c0                	test   %eax,%eax
  101be1:	75 30                	jne    101c13 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101be3:	8b 45 08             	mov    0x8(%ebp),%eax
  101be6:	8b 40 44             	mov    0x44(%eax),%eax
  101be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bed:	c7 04 24 da 63 10 00 	movl   $0x1063da,(%esp)
  101bf4:	e8 8d e6 ff ff       	call   100286 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfc:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c00:	0f b7 c0             	movzwl %ax,%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 e9 63 10 00 	movl   $0x1063e9,(%esp)
  101c0e:	e8 73 e6 ff ff       	call   100286 <cprintf>
    }
}
  101c13:	c9                   	leave  
  101c14:	c3                   	ret    

00101c15 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c15:	55                   	push   %ebp
  101c16:	89 e5                	mov    %esp,%ebp
  101c18:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1e:	8b 00                	mov    (%eax),%eax
  101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c24:	c7 04 24 fc 63 10 00 	movl   $0x1063fc,(%esp)
  101c2b:	e8 56 e6 ff ff       	call   100286 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c30:	8b 45 08             	mov    0x8(%ebp),%eax
  101c33:	8b 40 04             	mov    0x4(%eax),%eax
  101c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3a:	c7 04 24 0b 64 10 00 	movl   $0x10640b,(%esp)
  101c41:	e8 40 e6 ff ff       	call   100286 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c46:	8b 45 08             	mov    0x8(%ebp),%eax
  101c49:	8b 40 08             	mov    0x8(%eax),%eax
  101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c50:	c7 04 24 1a 64 10 00 	movl   $0x10641a,(%esp)
  101c57:	e8 2a e6 ff ff       	call   100286 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5f:	8b 40 0c             	mov    0xc(%eax),%eax
  101c62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c66:	c7 04 24 29 64 10 00 	movl   $0x106429,(%esp)
  101c6d:	e8 14 e6 ff ff       	call   100286 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c72:	8b 45 08             	mov    0x8(%ebp),%eax
  101c75:	8b 40 10             	mov    0x10(%eax),%eax
  101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7c:	c7 04 24 38 64 10 00 	movl   $0x106438,(%esp)
  101c83:	e8 fe e5 ff ff       	call   100286 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c88:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8b:	8b 40 14             	mov    0x14(%eax),%eax
  101c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c92:	c7 04 24 47 64 10 00 	movl   $0x106447,(%esp)
  101c99:	e8 e8 e5 ff ff       	call   100286 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca1:	8b 40 18             	mov    0x18(%eax),%eax
  101ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca8:	c7 04 24 56 64 10 00 	movl   $0x106456,(%esp)
  101caf:	e8 d2 e5 ff ff       	call   100286 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb7:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbe:	c7 04 24 65 64 10 00 	movl   $0x106465,(%esp)
  101cc5:	e8 bc e5 ff ff       	call   100286 <cprintf>
}
  101cca:	c9                   	leave  
  101ccb:	c3                   	ret    

00101ccc <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101ccc:	55                   	push   %ebp
  101ccd:	89 e5                	mov    %esp,%ebp
  101ccf:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd5:	8b 40 30             	mov    0x30(%eax),%eax
  101cd8:	83 f8 2f             	cmp    $0x2f,%eax
  101cdb:	77 21                	ja     101cfe <trap_dispatch+0x32>
  101cdd:	83 f8 2e             	cmp    $0x2e,%eax
  101ce0:	0f 83 04 01 00 00    	jae    101dea <trap_dispatch+0x11e>
  101ce6:	83 f8 21             	cmp    $0x21,%eax
  101ce9:	0f 84 81 00 00 00    	je     101d70 <trap_dispatch+0xa4>
  101cef:	83 f8 24             	cmp    $0x24,%eax
  101cf2:	74 56                	je     101d4a <trap_dispatch+0x7e>
  101cf4:	83 f8 20             	cmp    $0x20,%eax
  101cf7:	74 16                	je     101d0f <trap_dispatch+0x43>
  101cf9:	e9 b4 00 00 00       	jmp    101db2 <trap_dispatch+0xe6>
  101cfe:	83 e8 78             	sub    $0x78,%eax
  101d01:	83 f8 01             	cmp    $0x1,%eax
  101d04:	0f 87 a8 00 00 00    	ja     101db2 <trap_dispatch+0xe6>
  101d0a:	e9 87 00 00 00       	jmp    101d96 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101d0f:	a1 4c 89 11 00       	mov    0x11894c,%eax
  101d14:	83 c0 01             	add    $0x1,%eax
  101d17:	a3 4c 89 11 00       	mov    %eax,0x11894c
    	if (ticks % TICK_NUM == 0) {
  101d1c:	8b 0d 4c 89 11 00    	mov    0x11894c,%ecx
  101d22:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d27:	89 c8                	mov    %ecx,%eax
  101d29:	f7 e2                	mul    %edx
  101d2b:	89 d0                	mov    %edx,%eax
  101d2d:	c1 e8 05             	shr    $0x5,%eax
  101d30:	6b c0 64             	imul   $0x64,%eax,%eax
  101d33:	29 c1                	sub    %eax,%ecx
  101d35:	89 c8                	mov    %ecx,%eax
  101d37:	85 c0                	test   %eax,%eax
  101d39:	75 0a                	jne    101d45 <trap_dispatch+0x79>
    		print_ticks();
  101d3b:	e8 3c fb ff ff       	call   10187c <print_ticks>
    	}
        break;
  101d40:	e9 a6 00 00 00       	jmp    101deb <trap_dispatch+0x11f>
  101d45:	e9 a1 00 00 00       	jmp    101deb <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d4a:	e8 f1 f8 ff ff       	call   101640 <cons_getc>
  101d4f:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d52:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d56:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d5a:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d62:	c7 04 24 74 64 10 00 	movl   $0x106474,(%esp)
  101d69:	e8 18 e5 ff ff       	call   100286 <cprintf>
        break;
  101d6e:	eb 7b                	jmp    101deb <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d70:	e8 cb f8 ff ff       	call   101640 <cons_getc>
  101d75:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d78:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d7c:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d80:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d88:	c7 04 24 86 64 10 00 	movl   $0x106486,(%esp)
  101d8f:	e8 f2 e4 ff ff       	call   100286 <cprintf>
        break;
  101d94:	eb 55                	jmp    101deb <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d96:	c7 44 24 08 95 64 10 	movl   $0x106495,0x8(%esp)
  101d9d:	00 
  101d9e:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  101da5:	00 
  101da6:	c7 04 24 a5 64 10 00 	movl   $0x1064a5,(%esp)
  101dad:	e8 2b e6 ff ff       	call   1003dd <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101db2:	8b 45 08             	mov    0x8(%ebp),%eax
  101db5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101db9:	0f b7 c0             	movzwl %ax,%eax
  101dbc:	83 e0 03             	and    $0x3,%eax
  101dbf:	85 c0                	test   %eax,%eax
  101dc1:	75 28                	jne    101deb <trap_dispatch+0x11f>
            print_trapframe(tf);
  101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc6:	89 04 24             	mov    %eax,(%esp)
  101dc9:	e8 82 fc ff ff       	call   101a50 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101dce:	c7 44 24 08 b6 64 10 	movl   $0x1064b6,0x8(%esp)
  101dd5:	00 
  101dd6:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101ddd:	00 
  101dde:	c7 04 24 a5 64 10 00 	movl   $0x1064a5,(%esp)
  101de5:	e8 f3 e5 ff ff       	call   1003dd <__panic>
        break;
  101dea:	90                   	nop
        }
    }
}
  101deb:	c9                   	leave  
  101dec:	c3                   	ret    

00101ded <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101ded:	55                   	push   %ebp
  101dee:	89 e5                	mov    %esp,%ebp
  101df0:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101df3:	8b 45 08             	mov    0x8(%ebp),%eax
  101df6:	89 04 24             	mov    %eax,(%esp)
  101df9:	e8 ce fe ff ff       	call   101ccc <trap_dispatch>
}
  101dfe:	c9                   	leave  
  101dff:	c3                   	ret    

00101e00 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e00:	6a 00                	push   $0x0
  pushl $0
  101e02:	6a 00                	push   $0x0
  jmp __alltraps
  101e04:	e9 67 0a 00 00       	jmp    102870 <__alltraps>

00101e09 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e09:	6a 00                	push   $0x0
  pushl $1
  101e0b:	6a 01                	push   $0x1
  jmp __alltraps
  101e0d:	e9 5e 0a 00 00       	jmp    102870 <__alltraps>

00101e12 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $2
  101e14:	6a 02                	push   $0x2
  jmp __alltraps
  101e16:	e9 55 0a 00 00       	jmp    102870 <__alltraps>

00101e1b <vector3>:
.globl vector3
vector3:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $3
  101e1d:	6a 03                	push   $0x3
  jmp __alltraps
  101e1f:	e9 4c 0a 00 00       	jmp    102870 <__alltraps>

00101e24 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e24:	6a 00                	push   $0x0
  pushl $4
  101e26:	6a 04                	push   $0x4
  jmp __alltraps
  101e28:	e9 43 0a 00 00       	jmp    102870 <__alltraps>

00101e2d <vector5>:
.globl vector5
vector5:
  pushl $0
  101e2d:	6a 00                	push   $0x0
  pushl $5
  101e2f:	6a 05                	push   $0x5
  jmp __alltraps
  101e31:	e9 3a 0a 00 00       	jmp    102870 <__alltraps>

00101e36 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e36:	6a 00                	push   $0x0
  pushl $6
  101e38:	6a 06                	push   $0x6
  jmp __alltraps
  101e3a:	e9 31 0a 00 00       	jmp    102870 <__alltraps>

00101e3f <vector7>:
.globl vector7
vector7:
  pushl $0
  101e3f:	6a 00                	push   $0x0
  pushl $7
  101e41:	6a 07                	push   $0x7
  jmp __alltraps
  101e43:	e9 28 0a 00 00       	jmp    102870 <__alltraps>

00101e48 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e48:	6a 08                	push   $0x8
  jmp __alltraps
  101e4a:	e9 21 0a 00 00       	jmp    102870 <__alltraps>

00101e4f <vector9>:
.globl vector9
vector9:
  pushl $9
  101e4f:	6a 09                	push   $0x9
  jmp __alltraps
  101e51:	e9 1a 0a 00 00       	jmp    102870 <__alltraps>

00101e56 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e56:	6a 0a                	push   $0xa
  jmp __alltraps
  101e58:	e9 13 0a 00 00       	jmp    102870 <__alltraps>

00101e5d <vector11>:
.globl vector11
vector11:
  pushl $11
  101e5d:	6a 0b                	push   $0xb
  jmp __alltraps
  101e5f:	e9 0c 0a 00 00       	jmp    102870 <__alltraps>

00101e64 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e64:	6a 0c                	push   $0xc
  jmp __alltraps
  101e66:	e9 05 0a 00 00       	jmp    102870 <__alltraps>

00101e6b <vector13>:
.globl vector13
vector13:
  pushl $13
  101e6b:	6a 0d                	push   $0xd
  jmp __alltraps
  101e6d:	e9 fe 09 00 00       	jmp    102870 <__alltraps>

00101e72 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e72:	6a 0e                	push   $0xe
  jmp __alltraps
  101e74:	e9 f7 09 00 00       	jmp    102870 <__alltraps>

00101e79 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e79:	6a 00                	push   $0x0
  pushl $15
  101e7b:	6a 0f                	push   $0xf
  jmp __alltraps
  101e7d:	e9 ee 09 00 00       	jmp    102870 <__alltraps>

00101e82 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e82:	6a 00                	push   $0x0
  pushl $16
  101e84:	6a 10                	push   $0x10
  jmp __alltraps
  101e86:	e9 e5 09 00 00       	jmp    102870 <__alltraps>

00101e8b <vector17>:
.globl vector17
vector17:
  pushl $17
  101e8b:	6a 11                	push   $0x11
  jmp __alltraps
  101e8d:	e9 de 09 00 00       	jmp    102870 <__alltraps>

00101e92 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e92:	6a 00                	push   $0x0
  pushl $18
  101e94:	6a 12                	push   $0x12
  jmp __alltraps
  101e96:	e9 d5 09 00 00       	jmp    102870 <__alltraps>

00101e9b <vector19>:
.globl vector19
vector19:
  pushl $0
  101e9b:	6a 00                	push   $0x0
  pushl $19
  101e9d:	6a 13                	push   $0x13
  jmp __alltraps
  101e9f:	e9 cc 09 00 00       	jmp    102870 <__alltraps>

00101ea4 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ea4:	6a 00                	push   $0x0
  pushl $20
  101ea6:	6a 14                	push   $0x14
  jmp __alltraps
  101ea8:	e9 c3 09 00 00       	jmp    102870 <__alltraps>

00101ead <vector21>:
.globl vector21
vector21:
  pushl $0
  101ead:	6a 00                	push   $0x0
  pushl $21
  101eaf:	6a 15                	push   $0x15
  jmp __alltraps
  101eb1:	e9 ba 09 00 00       	jmp    102870 <__alltraps>

00101eb6 <vector22>:
.globl vector22
vector22:
  pushl $0
  101eb6:	6a 00                	push   $0x0
  pushl $22
  101eb8:	6a 16                	push   $0x16
  jmp __alltraps
  101eba:	e9 b1 09 00 00       	jmp    102870 <__alltraps>

00101ebf <vector23>:
.globl vector23
vector23:
  pushl $0
  101ebf:	6a 00                	push   $0x0
  pushl $23
  101ec1:	6a 17                	push   $0x17
  jmp __alltraps
  101ec3:	e9 a8 09 00 00       	jmp    102870 <__alltraps>

00101ec8 <vector24>:
.globl vector24
vector24:
  pushl $0
  101ec8:	6a 00                	push   $0x0
  pushl $24
  101eca:	6a 18                	push   $0x18
  jmp __alltraps
  101ecc:	e9 9f 09 00 00       	jmp    102870 <__alltraps>

00101ed1 <vector25>:
.globl vector25
vector25:
  pushl $0
  101ed1:	6a 00                	push   $0x0
  pushl $25
  101ed3:	6a 19                	push   $0x19
  jmp __alltraps
  101ed5:	e9 96 09 00 00       	jmp    102870 <__alltraps>

00101eda <vector26>:
.globl vector26
vector26:
  pushl $0
  101eda:	6a 00                	push   $0x0
  pushl $26
  101edc:	6a 1a                	push   $0x1a
  jmp __alltraps
  101ede:	e9 8d 09 00 00       	jmp    102870 <__alltraps>

00101ee3 <vector27>:
.globl vector27
vector27:
  pushl $0
  101ee3:	6a 00                	push   $0x0
  pushl $27
  101ee5:	6a 1b                	push   $0x1b
  jmp __alltraps
  101ee7:	e9 84 09 00 00       	jmp    102870 <__alltraps>

00101eec <vector28>:
.globl vector28
vector28:
  pushl $0
  101eec:	6a 00                	push   $0x0
  pushl $28
  101eee:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ef0:	e9 7b 09 00 00       	jmp    102870 <__alltraps>

00101ef5 <vector29>:
.globl vector29
vector29:
  pushl $0
  101ef5:	6a 00                	push   $0x0
  pushl $29
  101ef7:	6a 1d                	push   $0x1d
  jmp __alltraps
  101ef9:	e9 72 09 00 00       	jmp    102870 <__alltraps>

00101efe <vector30>:
.globl vector30
vector30:
  pushl $0
  101efe:	6a 00                	push   $0x0
  pushl $30
  101f00:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f02:	e9 69 09 00 00       	jmp    102870 <__alltraps>

00101f07 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f07:	6a 00                	push   $0x0
  pushl $31
  101f09:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f0b:	e9 60 09 00 00       	jmp    102870 <__alltraps>

00101f10 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f10:	6a 00                	push   $0x0
  pushl $32
  101f12:	6a 20                	push   $0x20
  jmp __alltraps
  101f14:	e9 57 09 00 00       	jmp    102870 <__alltraps>

00101f19 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f19:	6a 00                	push   $0x0
  pushl $33
  101f1b:	6a 21                	push   $0x21
  jmp __alltraps
  101f1d:	e9 4e 09 00 00       	jmp    102870 <__alltraps>

00101f22 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f22:	6a 00                	push   $0x0
  pushl $34
  101f24:	6a 22                	push   $0x22
  jmp __alltraps
  101f26:	e9 45 09 00 00       	jmp    102870 <__alltraps>

00101f2b <vector35>:
.globl vector35
vector35:
  pushl $0
  101f2b:	6a 00                	push   $0x0
  pushl $35
  101f2d:	6a 23                	push   $0x23
  jmp __alltraps
  101f2f:	e9 3c 09 00 00       	jmp    102870 <__alltraps>

00101f34 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f34:	6a 00                	push   $0x0
  pushl $36
  101f36:	6a 24                	push   $0x24
  jmp __alltraps
  101f38:	e9 33 09 00 00       	jmp    102870 <__alltraps>

00101f3d <vector37>:
.globl vector37
vector37:
  pushl $0
  101f3d:	6a 00                	push   $0x0
  pushl $37
  101f3f:	6a 25                	push   $0x25
  jmp __alltraps
  101f41:	e9 2a 09 00 00       	jmp    102870 <__alltraps>

00101f46 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f46:	6a 00                	push   $0x0
  pushl $38
  101f48:	6a 26                	push   $0x26
  jmp __alltraps
  101f4a:	e9 21 09 00 00       	jmp    102870 <__alltraps>

00101f4f <vector39>:
.globl vector39
vector39:
  pushl $0
  101f4f:	6a 00                	push   $0x0
  pushl $39
  101f51:	6a 27                	push   $0x27
  jmp __alltraps
  101f53:	e9 18 09 00 00       	jmp    102870 <__alltraps>

00101f58 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f58:	6a 00                	push   $0x0
  pushl $40
  101f5a:	6a 28                	push   $0x28
  jmp __alltraps
  101f5c:	e9 0f 09 00 00       	jmp    102870 <__alltraps>

00101f61 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f61:	6a 00                	push   $0x0
  pushl $41
  101f63:	6a 29                	push   $0x29
  jmp __alltraps
  101f65:	e9 06 09 00 00       	jmp    102870 <__alltraps>

00101f6a <vector42>:
.globl vector42
vector42:
  pushl $0
  101f6a:	6a 00                	push   $0x0
  pushl $42
  101f6c:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f6e:	e9 fd 08 00 00       	jmp    102870 <__alltraps>

00101f73 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f73:	6a 00                	push   $0x0
  pushl $43
  101f75:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f77:	e9 f4 08 00 00       	jmp    102870 <__alltraps>

00101f7c <vector44>:
.globl vector44
vector44:
  pushl $0
  101f7c:	6a 00                	push   $0x0
  pushl $44
  101f7e:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f80:	e9 eb 08 00 00       	jmp    102870 <__alltraps>

00101f85 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f85:	6a 00                	push   $0x0
  pushl $45
  101f87:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f89:	e9 e2 08 00 00       	jmp    102870 <__alltraps>

00101f8e <vector46>:
.globl vector46
vector46:
  pushl $0
  101f8e:	6a 00                	push   $0x0
  pushl $46
  101f90:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f92:	e9 d9 08 00 00       	jmp    102870 <__alltraps>

00101f97 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f97:	6a 00                	push   $0x0
  pushl $47
  101f99:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f9b:	e9 d0 08 00 00       	jmp    102870 <__alltraps>

00101fa0 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fa0:	6a 00                	push   $0x0
  pushl $48
  101fa2:	6a 30                	push   $0x30
  jmp __alltraps
  101fa4:	e9 c7 08 00 00       	jmp    102870 <__alltraps>

00101fa9 <vector49>:
.globl vector49
vector49:
  pushl $0
  101fa9:	6a 00                	push   $0x0
  pushl $49
  101fab:	6a 31                	push   $0x31
  jmp __alltraps
  101fad:	e9 be 08 00 00       	jmp    102870 <__alltraps>

00101fb2 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fb2:	6a 00                	push   $0x0
  pushl $50
  101fb4:	6a 32                	push   $0x32
  jmp __alltraps
  101fb6:	e9 b5 08 00 00       	jmp    102870 <__alltraps>

00101fbb <vector51>:
.globl vector51
vector51:
  pushl $0
  101fbb:	6a 00                	push   $0x0
  pushl $51
  101fbd:	6a 33                	push   $0x33
  jmp __alltraps
  101fbf:	e9 ac 08 00 00       	jmp    102870 <__alltraps>

00101fc4 <vector52>:
.globl vector52
vector52:
  pushl $0
  101fc4:	6a 00                	push   $0x0
  pushl $52
  101fc6:	6a 34                	push   $0x34
  jmp __alltraps
  101fc8:	e9 a3 08 00 00       	jmp    102870 <__alltraps>

00101fcd <vector53>:
.globl vector53
vector53:
  pushl $0
  101fcd:	6a 00                	push   $0x0
  pushl $53
  101fcf:	6a 35                	push   $0x35
  jmp __alltraps
  101fd1:	e9 9a 08 00 00       	jmp    102870 <__alltraps>

00101fd6 <vector54>:
.globl vector54
vector54:
  pushl $0
  101fd6:	6a 00                	push   $0x0
  pushl $54
  101fd8:	6a 36                	push   $0x36
  jmp __alltraps
  101fda:	e9 91 08 00 00       	jmp    102870 <__alltraps>

00101fdf <vector55>:
.globl vector55
vector55:
  pushl $0
  101fdf:	6a 00                	push   $0x0
  pushl $55
  101fe1:	6a 37                	push   $0x37
  jmp __alltraps
  101fe3:	e9 88 08 00 00       	jmp    102870 <__alltraps>

00101fe8 <vector56>:
.globl vector56
vector56:
  pushl $0
  101fe8:	6a 00                	push   $0x0
  pushl $56
  101fea:	6a 38                	push   $0x38
  jmp __alltraps
  101fec:	e9 7f 08 00 00       	jmp    102870 <__alltraps>

00101ff1 <vector57>:
.globl vector57
vector57:
  pushl $0
  101ff1:	6a 00                	push   $0x0
  pushl $57
  101ff3:	6a 39                	push   $0x39
  jmp __alltraps
  101ff5:	e9 76 08 00 00       	jmp    102870 <__alltraps>

00101ffa <vector58>:
.globl vector58
vector58:
  pushl $0
  101ffa:	6a 00                	push   $0x0
  pushl $58
  101ffc:	6a 3a                	push   $0x3a
  jmp __alltraps
  101ffe:	e9 6d 08 00 00       	jmp    102870 <__alltraps>

00102003 <vector59>:
.globl vector59
vector59:
  pushl $0
  102003:	6a 00                	push   $0x0
  pushl $59
  102005:	6a 3b                	push   $0x3b
  jmp __alltraps
  102007:	e9 64 08 00 00       	jmp    102870 <__alltraps>

0010200c <vector60>:
.globl vector60
vector60:
  pushl $0
  10200c:	6a 00                	push   $0x0
  pushl $60
  10200e:	6a 3c                	push   $0x3c
  jmp __alltraps
  102010:	e9 5b 08 00 00       	jmp    102870 <__alltraps>

00102015 <vector61>:
.globl vector61
vector61:
  pushl $0
  102015:	6a 00                	push   $0x0
  pushl $61
  102017:	6a 3d                	push   $0x3d
  jmp __alltraps
  102019:	e9 52 08 00 00       	jmp    102870 <__alltraps>

0010201e <vector62>:
.globl vector62
vector62:
  pushl $0
  10201e:	6a 00                	push   $0x0
  pushl $62
  102020:	6a 3e                	push   $0x3e
  jmp __alltraps
  102022:	e9 49 08 00 00       	jmp    102870 <__alltraps>

00102027 <vector63>:
.globl vector63
vector63:
  pushl $0
  102027:	6a 00                	push   $0x0
  pushl $63
  102029:	6a 3f                	push   $0x3f
  jmp __alltraps
  10202b:	e9 40 08 00 00       	jmp    102870 <__alltraps>

00102030 <vector64>:
.globl vector64
vector64:
  pushl $0
  102030:	6a 00                	push   $0x0
  pushl $64
  102032:	6a 40                	push   $0x40
  jmp __alltraps
  102034:	e9 37 08 00 00       	jmp    102870 <__alltraps>

00102039 <vector65>:
.globl vector65
vector65:
  pushl $0
  102039:	6a 00                	push   $0x0
  pushl $65
  10203b:	6a 41                	push   $0x41
  jmp __alltraps
  10203d:	e9 2e 08 00 00       	jmp    102870 <__alltraps>

00102042 <vector66>:
.globl vector66
vector66:
  pushl $0
  102042:	6a 00                	push   $0x0
  pushl $66
  102044:	6a 42                	push   $0x42
  jmp __alltraps
  102046:	e9 25 08 00 00       	jmp    102870 <__alltraps>

0010204b <vector67>:
.globl vector67
vector67:
  pushl $0
  10204b:	6a 00                	push   $0x0
  pushl $67
  10204d:	6a 43                	push   $0x43
  jmp __alltraps
  10204f:	e9 1c 08 00 00       	jmp    102870 <__alltraps>

00102054 <vector68>:
.globl vector68
vector68:
  pushl $0
  102054:	6a 00                	push   $0x0
  pushl $68
  102056:	6a 44                	push   $0x44
  jmp __alltraps
  102058:	e9 13 08 00 00       	jmp    102870 <__alltraps>

0010205d <vector69>:
.globl vector69
vector69:
  pushl $0
  10205d:	6a 00                	push   $0x0
  pushl $69
  10205f:	6a 45                	push   $0x45
  jmp __alltraps
  102061:	e9 0a 08 00 00       	jmp    102870 <__alltraps>

00102066 <vector70>:
.globl vector70
vector70:
  pushl $0
  102066:	6a 00                	push   $0x0
  pushl $70
  102068:	6a 46                	push   $0x46
  jmp __alltraps
  10206a:	e9 01 08 00 00       	jmp    102870 <__alltraps>

0010206f <vector71>:
.globl vector71
vector71:
  pushl $0
  10206f:	6a 00                	push   $0x0
  pushl $71
  102071:	6a 47                	push   $0x47
  jmp __alltraps
  102073:	e9 f8 07 00 00       	jmp    102870 <__alltraps>

00102078 <vector72>:
.globl vector72
vector72:
  pushl $0
  102078:	6a 00                	push   $0x0
  pushl $72
  10207a:	6a 48                	push   $0x48
  jmp __alltraps
  10207c:	e9 ef 07 00 00       	jmp    102870 <__alltraps>

00102081 <vector73>:
.globl vector73
vector73:
  pushl $0
  102081:	6a 00                	push   $0x0
  pushl $73
  102083:	6a 49                	push   $0x49
  jmp __alltraps
  102085:	e9 e6 07 00 00       	jmp    102870 <__alltraps>

0010208a <vector74>:
.globl vector74
vector74:
  pushl $0
  10208a:	6a 00                	push   $0x0
  pushl $74
  10208c:	6a 4a                	push   $0x4a
  jmp __alltraps
  10208e:	e9 dd 07 00 00       	jmp    102870 <__alltraps>

00102093 <vector75>:
.globl vector75
vector75:
  pushl $0
  102093:	6a 00                	push   $0x0
  pushl $75
  102095:	6a 4b                	push   $0x4b
  jmp __alltraps
  102097:	e9 d4 07 00 00       	jmp    102870 <__alltraps>

0010209c <vector76>:
.globl vector76
vector76:
  pushl $0
  10209c:	6a 00                	push   $0x0
  pushl $76
  10209e:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020a0:	e9 cb 07 00 00       	jmp    102870 <__alltraps>

001020a5 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020a5:	6a 00                	push   $0x0
  pushl $77
  1020a7:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020a9:	e9 c2 07 00 00       	jmp    102870 <__alltraps>

001020ae <vector78>:
.globl vector78
vector78:
  pushl $0
  1020ae:	6a 00                	push   $0x0
  pushl $78
  1020b0:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020b2:	e9 b9 07 00 00       	jmp    102870 <__alltraps>

001020b7 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020b7:	6a 00                	push   $0x0
  pushl $79
  1020b9:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020bb:	e9 b0 07 00 00       	jmp    102870 <__alltraps>

001020c0 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020c0:	6a 00                	push   $0x0
  pushl $80
  1020c2:	6a 50                	push   $0x50
  jmp __alltraps
  1020c4:	e9 a7 07 00 00       	jmp    102870 <__alltraps>

001020c9 <vector81>:
.globl vector81
vector81:
  pushl $0
  1020c9:	6a 00                	push   $0x0
  pushl $81
  1020cb:	6a 51                	push   $0x51
  jmp __alltraps
  1020cd:	e9 9e 07 00 00       	jmp    102870 <__alltraps>

001020d2 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020d2:	6a 00                	push   $0x0
  pushl $82
  1020d4:	6a 52                	push   $0x52
  jmp __alltraps
  1020d6:	e9 95 07 00 00       	jmp    102870 <__alltraps>

001020db <vector83>:
.globl vector83
vector83:
  pushl $0
  1020db:	6a 00                	push   $0x0
  pushl $83
  1020dd:	6a 53                	push   $0x53
  jmp __alltraps
  1020df:	e9 8c 07 00 00       	jmp    102870 <__alltraps>

001020e4 <vector84>:
.globl vector84
vector84:
  pushl $0
  1020e4:	6a 00                	push   $0x0
  pushl $84
  1020e6:	6a 54                	push   $0x54
  jmp __alltraps
  1020e8:	e9 83 07 00 00       	jmp    102870 <__alltraps>

001020ed <vector85>:
.globl vector85
vector85:
  pushl $0
  1020ed:	6a 00                	push   $0x0
  pushl $85
  1020ef:	6a 55                	push   $0x55
  jmp __alltraps
  1020f1:	e9 7a 07 00 00       	jmp    102870 <__alltraps>

001020f6 <vector86>:
.globl vector86
vector86:
  pushl $0
  1020f6:	6a 00                	push   $0x0
  pushl $86
  1020f8:	6a 56                	push   $0x56
  jmp __alltraps
  1020fa:	e9 71 07 00 00       	jmp    102870 <__alltraps>

001020ff <vector87>:
.globl vector87
vector87:
  pushl $0
  1020ff:	6a 00                	push   $0x0
  pushl $87
  102101:	6a 57                	push   $0x57
  jmp __alltraps
  102103:	e9 68 07 00 00       	jmp    102870 <__alltraps>

00102108 <vector88>:
.globl vector88
vector88:
  pushl $0
  102108:	6a 00                	push   $0x0
  pushl $88
  10210a:	6a 58                	push   $0x58
  jmp __alltraps
  10210c:	e9 5f 07 00 00       	jmp    102870 <__alltraps>

00102111 <vector89>:
.globl vector89
vector89:
  pushl $0
  102111:	6a 00                	push   $0x0
  pushl $89
  102113:	6a 59                	push   $0x59
  jmp __alltraps
  102115:	e9 56 07 00 00       	jmp    102870 <__alltraps>

0010211a <vector90>:
.globl vector90
vector90:
  pushl $0
  10211a:	6a 00                	push   $0x0
  pushl $90
  10211c:	6a 5a                	push   $0x5a
  jmp __alltraps
  10211e:	e9 4d 07 00 00       	jmp    102870 <__alltraps>

00102123 <vector91>:
.globl vector91
vector91:
  pushl $0
  102123:	6a 00                	push   $0x0
  pushl $91
  102125:	6a 5b                	push   $0x5b
  jmp __alltraps
  102127:	e9 44 07 00 00       	jmp    102870 <__alltraps>

0010212c <vector92>:
.globl vector92
vector92:
  pushl $0
  10212c:	6a 00                	push   $0x0
  pushl $92
  10212e:	6a 5c                	push   $0x5c
  jmp __alltraps
  102130:	e9 3b 07 00 00       	jmp    102870 <__alltraps>

00102135 <vector93>:
.globl vector93
vector93:
  pushl $0
  102135:	6a 00                	push   $0x0
  pushl $93
  102137:	6a 5d                	push   $0x5d
  jmp __alltraps
  102139:	e9 32 07 00 00       	jmp    102870 <__alltraps>

0010213e <vector94>:
.globl vector94
vector94:
  pushl $0
  10213e:	6a 00                	push   $0x0
  pushl $94
  102140:	6a 5e                	push   $0x5e
  jmp __alltraps
  102142:	e9 29 07 00 00       	jmp    102870 <__alltraps>

00102147 <vector95>:
.globl vector95
vector95:
  pushl $0
  102147:	6a 00                	push   $0x0
  pushl $95
  102149:	6a 5f                	push   $0x5f
  jmp __alltraps
  10214b:	e9 20 07 00 00       	jmp    102870 <__alltraps>

00102150 <vector96>:
.globl vector96
vector96:
  pushl $0
  102150:	6a 00                	push   $0x0
  pushl $96
  102152:	6a 60                	push   $0x60
  jmp __alltraps
  102154:	e9 17 07 00 00       	jmp    102870 <__alltraps>

00102159 <vector97>:
.globl vector97
vector97:
  pushl $0
  102159:	6a 00                	push   $0x0
  pushl $97
  10215b:	6a 61                	push   $0x61
  jmp __alltraps
  10215d:	e9 0e 07 00 00       	jmp    102870 <__alltraps>

00102162 <vector98>:
.globl vector98
vector98:
  pushl $0
  102162:	6a 00                	push   $0x0
  pushl $98
  102164:	6a 62                	push   $0x62
  jmp __alltraps
  102166:	e9 05 07 00 00       	jmp    102870 <__alltraps>

0010216b <vector99>:
.globl vector99
vector99:
  pushl $0
  10216b:	6a 00                	push   $0x0
  pushl $99
  10216d:	6a 63                	push   $0x63
  jmp __alltraps
  10216f:	e9 fc 06 00 00       	jmp    102870 <__alltraps>

00102174 <vector100>:
.globl vector100
vector100:
  pushl $0
  102174:	6a 00                	push   $0x0
  pushl $100
  102176:	6a 64                	push   $0x64
  jmp __alltraps
  102178:	e9 f3 06 00 00       	jmp    102870 <__alltraps>

0010217d <vector101>:
.globl vector101
vector101:
  pushl $0
  10217d:	6a 00                	push   $0x0
  pushl $101
  10217f:	6a 65                	push   $0x65
  jmp __alltraps
  102181:	e9 ea 06 00 00       	jmp    102870 <__alltraps>

00102186 <vector102>:
.globl vector102
vector102:
  pushl $0
  102186:	6a 00                	push   $0x0
  pushl $102
  102188:	6a 66                	push   $0x66
  jmp __alltraps
  10218a:	e9 e1 06 00 00       	jmp    102870 <__alltraps>

0010218f <vector103>:
.globl vector103
vector103:
  pushl $0
  10218f:	6a 00                	push   $0x0
  pushl $103
  102191:	6a 67                	push   $0x67
  jmp __alltraps
  102193:	e9 d8 06 00 00       	jmp    102870 <__alltraps>

00102198 <vector104>:
.globl vector104
vector104:
  pushl $0
  102198:	6a 00                	push   $0x0
  pushl $104
  10219a:	6a 68                	push   $0x68
  jmp __alltraps
  10219c:	e9 cf 06 00 00       	jmp    102870 <__alltraps>

001021a1 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021a1:	6a 00                	push   $0x0
  pushl $105
  1021a3:	6a 69                	push   $0x69
  jmp __alltraps
  1021a5:	e9 c6 06 00 00       	jmp    102870 <__alltraps>

001021aa <vector106>:
.globl vector106
vector106:
  pushl $0
  1021aa:	6a 00                	push   $0x0
  pushl $106
  1021ac:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021ae:	e9 bd 06 00 00       	jmp    102870 <__alltraps>

001021b3 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021b3:	6a 00                	push   $0x0
  pushl $107
  1021b5:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021b7:	e9 b4 06 00 00       	jmp    102870 <__alltraps>

001021bc <vector108>:
.globl vector108
vector108:
  pushl $0
  1021bc:	6a 00                	push   $0x0
  pushl $108
  1021be:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021c0:	e9 ab 06 00 00       	jmp    102870 <__alltraps>

001021c5 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021c5:	6a 00                	push   $0x0
  pushl $109
  1021c7:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021c9:	e9 a2 06 00 00       	jmp    102870 <__alltraps>

001021ce <vector110>:
.globl vector110
vector110:
  pushl $0
  1021ce:	6a 00                	push   $0x0
  pushl $110
  1021d0:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021d2:	e9 99 06 00 00       	jmp    102870 <__alltraps>

001021d7 <vector111>:
.globl vector111
vector111:
  pushl $0
  1021d7:	6a 00                	push   $0x0
  pushl $111
  1021d9:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021db:	e9 90 06 00 00       	jmp    102870 <__alltraps>

001021e0 <vector112>:
.globl vector112
vector112:
  pushl $0
  1021e0:	6a 00                	push   $0x0
  pushl $112
  1021e2:	6a 70                	push   $0x70
  jmp __alltraps
  1021e4:	e9 87 06 00 00       	jmp    102870 <__alltraps>

001021e9 <vector113>:
.globl vector113
vector113:
  pushl $0
  1021e9:	6a 00                	push   $0x0
  pushl $113
  1021eb:	6a 71                	push   $0x71
  jmp __alltraps
  1021ed:	e9 7e 06 00 00       	jmp    102870 <__alltraps>

001021f2 <vector114>:
.globl vector114
vector114:
  pushl $0
  1021f2:	6a 00                	push   $0x0
  pushl $114
  1021f4:	6a 72                	push   $0x72
  jmp __alltraps
  1021f6:	e9 75 06 00 00       	jmp    102870 <__alltraps>

001021fb <vector115>:
.globl vector115
vector115:
  pushl $0
  1021fb:	6a 00                	push   $0x0
  pushl $115
  1021fd:	6a 73                	push   $0x73
  jmp __alltraps
  1021ff:	e9 6c 06 00 00       	jmp    102870 <__alltraps>

00102204 <vector116>:
.globl vector116
vector116:
  pushl $0
  102204:	6a 00                	push   $0x0
  pushl $116
  102206:	6a 74                	push   $0x74
  jmp __alltraps
  102208:	e9 63 06 00 00       	jmp    102870 <__alltraps>

0010220d <vector117>:
.globl vector117
vector117:
  pushl $0
  10220d:	6a 00                	push   $0x0
  pushl $117
  10220f:	6a 75                	push   $0x75
  jmp __alltraps
  102211:	e9 5a 06 00 00       	jmp    102870 <__alltraps>

00102216 <vector118>:
.globl vector118
vector118:
  pushl $0
  102216:	6a 00                	push   $0x0
  pushl $118
  102218:	6a 76                	push   $0x76
  jmp __alltraps
  10221a:	e9 51 06 00 00       	jmp    102870 <__alltraps>

0010221f <vector119>:
.globl vector119
vector119:
  pushl $0
  10221f:	6a 00                	push   $0x0
  pushl $119
  102221:	6a 77                	push   $0x77
  jmp __alltraps
  102223:	e9 48 06 00 00       	jmp    102870 <__alltraps>

00102228 <vector120>:
.globl vector120
vector120:
  pushl $0
  102228:	6a 00                	push   $0x0
  pushl $120
  10222a:	6a 78                	push   $0x78
  jmp __alltraps
  10222c:	e9 3f 06 00 00       	jmp    102870 <__alltraps>

00102231 <vector121>:
.globl vector121
vector121:
  pushl $0
  102231:	6a 00                	push   $0x0
  pushl $121
  102233:	6a 79                	push   $0x79
  jmp __alltraps
  102235:	e9 36 06 00 00       	jmp    102870 <__alltraps>

0010223a <vector122>:
.globl vector122
vector122:
  pushl $0
  10223a:	6a 00                	push   $0x0
  pushl $122
  10223c:	6a 7a                	push   $0x7a
  jmp __alltraps
  10223e:	e9 2d 06 00 00       	jmp    102870 <__alltraps>

00102243 <vector123>:
.globl vector123
vector123:
  pushl $0
  102243:	6a 00                	push   $0x0
  pushl $123
  102245:	6a 7b                	push   $0x7b
  jmp __alltraps
  102247:	e9 24 06 00 00       	jmp    102870 <__alltraps>

0010224c <vector124>:
.globl vector124
vector124:
  pushl $0
  10224c:	6a 00                	push   $0x0
  pushl $124
  10224e:	6a 7c                	push   $0x7c
  jmp __alltraps
  102250:	e9 1b 06 00 00       	jmp    102870 <__alltraps>

00102255 <vector125>:
.globl vector125
vector125:
  pushl $0
  102255:	6a 00                	push   $0x0
  pushl $125
  102257:	6a 7d                	push   $0x7d
  jmp __alltraps
  102259:	e9 12 06 00 00       	jmp    102870 <__alltraps>

0010225e <vector126>:
.globl vector126
vector126:
  pushl $0
  10225e:	6a 00                	push   $0x0
  pushl $126
  102260:	6a 7e                	push   $0x7e
  jmp __alltraps
  102262:	e9 09 06 00 00       	jmp    102870 <__alltraps>

00102267 <vector127>:
.globl vector127
vector127:
  pushl $0
  102267:	6a 00                	push   $0x0
  pushl $127
  102269:	6a 7f                	push   $0x7f
  jmp __alltraps
  10226b:	e9 00 06 00 00       	jmp    102870 <__alltraps>

00102270 <vector128>:
.globl vector128
vector128:
  pushl $0
  102270:	6a 00                	push   $0x0
  pushl $128
  102272:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102277:	e9 f4 05 00 00       	jmp    102870 <__alltraps>

0010227c <vector129>:
.globl vector129
vector129:
  pushl $0
  10227c:	6a 00                	push   $0x0
  pushl $129
  10227e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102283:	e9 e8 05 00 00       	jmp    102870 <__alltraps>

00102288 <vector130>:
.globl vector130
vector130:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $130
  10228a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10228f:	e9 dc 05 00 00       	jmp    102870 <__alltraps>

00102294 <vector131>:
.globl vector131
vector131:
  pushl $0
  102294:	6a 00                	push   $0x0
  pushl $131
  102296:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10229b:	e9 d0 05 00 00       	jmp    102870 <__alltraps>

001022a0 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022a0:	6a 00                	push   $0x0
  pushl $132
  1022a2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022a7:	e9 c4 05 00 00       	jmp    102870 <__alltraps>

001022ac <vector133>:
.globl vector133
vector133:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $133
  1022ae:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022b3:	e9 b8 05 00 00       	jmp    102870 <__alltraps>

001022b8 <vector134>:
.globl vector134
vector134:
  pushl $0
  1022b8:	6a 00                	push   $0x0
  pushl $134
  1022ba:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022bf:	e9 ac 05 00 00       	jmp    102870 <__alltraps>

001022c4 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022c4:	6a 00                	push   $0x0
  pushl $135
  1022c6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022cb:	e9 a0 05 00 00       	jmp    102870 <__alltraps>

001022d0 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $136
  1022d2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022d7:	e9 94 05 00 00       	jmp    102870 <__alltraps>

001022dc <vector137>:
.globl vector137
vector137:
  pushl $0
  1022dc:	6a 00                	push   $0x0
  pushl $137
  1022de:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1022e3:	e9 88 05 00 00       	jmp    102870 <__alltraps>

001022e8 <vector138>:
.globl vector138
vector138:
  pushl $0
  1022e8:	6a 00                	push   $0x0
  pushl $138
  1022ea:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022ef:	e9 7c 05 00 00       	jmp    102870 <__alltraps>

001022f4 <vector139>:
.globl vector139
vector139:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $139
  1022f6:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022fb:	e9 70 05 00 00       	jmp    102870 <__alltraps>

00102300 <vector140>:
.globl vector140
vector140:
  pushl $0
  102300:	6a 00                	push   $0x0
  pushl $140
  102302:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102307:	e9 64 05 00 00       	jmp    102870 <__alltraps>

0010230c <vector141>:
.globl vector141
vector141:
  pushl $0
  10230c:	6a 00                	push   $0x0
  pushl $141
  10230e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102313:	e9 58 05 00 00       	jmp    102870 <__alltraps>

00102318 <vector142>:
.globl vector142
vector142:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $142
  10231a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10231f:	e9 4c 05 00 00       	jmp    102870 <__alltraps>

00102324 <vector143>:
.globl vector143
vector143:
  pushl $0
  102324:	6a 00                	push   $0x0
  pushl $143
  102326:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10232b:	e9 40 05 00 00       	jmp    102870 <__alltraps>

00102330 <vector144>:
.globl vector144
vector144:
  pushl $0
  102330:	6a 00                	push   $0x0
  pushl $144
  102332:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102337:	e9 34 05 00 00       	jmp    102870 <__alltraps>

0010233c <vector145>:
.globl vector145
vector145:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $145
  10233e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102343:	e9 28 05 00 00       	jmp    102870 <__alltraps>

00102348 <vector146>:
.globl vector146
vector146:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $146
  10234a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10234f:	e9 1c 05 00 00       	jmp    102870 <__alltraps>

00102354 <vector147>:
.globl vector147
vector147:
  pushl $0
  102354:	6a 00                	push   $0x0
  pushl $147
  102356:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10235b:	e9 10 05 00 00       	jmp    102870 <__alltraps>

00102360 <vector148>:
.globl vector148
vector148:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $148
  102362:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102367:	e9 04 05 00 00       	jmp    102870 <__alltraps>

0010236c <vector149>:
.globl vector149
vector149:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $149
  10236e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102373:	e9 f8 04 00 00       	jmp    102870 <__alltraps>

00102378 <vector150>:
.globl vector150
vector150:
  pushl $0
  102378:	6a 00                	push   $0x0
  pushl $150
  10237a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10237f:	e9 ec 04 00 00       	jmp    102870 <__alltraps>

00102384 <vector151>:
.globl vector151
vector151:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $151
  102386:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10238b:	e9 e0 04 00 00       	jmp    102870 <__alltraps>

00102390 <vector152>:
.globl vector152
vector152:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $152
  102392:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102397:	e9 d4 04 00 00       	jmp    102870 <__alltraps>

0010239c <vector153>:
.globl vector153
vector153:
  pushl $0
  10239c:	6a 00                	push   $0x0
  pushl $153
  10239e:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023a3:	e9 c8 04 00 00       	jmp    102870 <__alltraps>

001023a8 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $154
  1023aa:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023af:	e9 bc 04 00 00       	jmp    102870 <__alltraps>

001023b4 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $155
  1023b6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023bb:	e9 b0 04 00 00       	jmp    102870 <__alltraps>

001023c0 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023c0:	6a 00                	push   $0x0
  pushl $156
  1023c2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023c7:	e9 a4 04 00 00       	jmp    102870 <__alltraps>

001023cc <vector157>:
.globl vector157
vector157:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $157
  1023ce:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023d3:	e9 98 04 00 00       	jmp    102870 <__alltraps>

001023d8 <vector158>:
.globl vector158
vector158:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $158
  1023da:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1023df:	e9 8c 04 00 00       	jmp    102870 <__alltraps>

001023e4 <vector159>:
.globl vector159
vector159:
  pushl $0
  1023e4:	6a 00                	push   $0x0
  pushl $159
  1023e6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023eb:	e9 80 04 00 00       	jmp    102870 <__alltraps>

001023f0 <vector160>:
.globl vector160
vector160:
  pushl $0
  1023f0:	6a 00                	push   $0x0
  pushl $160
  1023f2:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023f7:	e9 74 04 00 00       	jmp    102870 <__alltraps>

001023fc <vector161>:
.globl vector161
vector161:
  pushl $0
  1023fc:	6a 00                	push   $0x0
  pushl $161
  1023fe:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102403:	e9 68 04 00 00       	jmp    102870 <__alltraps>

00102408 <vector162>:
.globl vector162
vector162:
  pushl $0
  102408:	6a 00                	push   $0x0
  pushl $162
  10240a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10240f:	e9 5c 04 00 00       	jmp    102870 <__alltraps>

00102414 <vector163>:
.globl vector163
vector163:
  pushl $0
  102414:	6a 00                	push   $0x0
  pushl $163
  102416:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10241b:	e9 50 04 00 00       	jmp    102870 <__alltraps>

00102420 <vector164>:
.globl vector164
vector164:
  pushl $0
  102420:	6a 00                	push   $0x0
  pushl $164
  102422:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102427:	e9 44 04 00 00       	jmp    102870 <__alltraps>

0010242c <vector165>:
.globl vector165
vector165:
  pushl $0
  10242c:	6a 00                	push   $0x0
  pushl $165
  10242e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102433:	e9 38 04 00 00       	jmp    102870 <__alltraps>

00102438 <vector166>:
.globl vector166
vector166:
  pushl $0
  102438:	6a 00                	push   $0x0
  pushl $166
  10243a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10243f:	e9 2c 04 00 00       	jmp    102870 <__alltraps>

00102444 <vector167>:
.globl vector167
vector167:
  pushl $0
  102444:	6a 00                	push   $0x0
  pushl $167
  102446:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10244b:	e9 20 04 00 00       	jmp    102870 <__alltraps>

00102450 <vector168>:
.globl vector168
vector168:
  pushl $0
  102450:	6a 00                	push   $0x0
  pushl $168
  102452:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102457:	e9 14 04 00 00       	jmp    102870 <__alltraps>

0010245c <vector169>:
.globl vector169
vector169:
  pushl $0
  10245c:	6a 00                	push   $0x0
  pushl $169
  10245e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102463:	e9 08 04 00 00       	jmp    102870 <__alltraps>

00102468 <vector170>:
.globl vector170
vector170:
  pushl $0
  102468:	6a 00                	push   $0x0
  pushl $170
  10246a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10246f:	e9 fc 03 00 00       	jmp    102870 <__alltraps>

00102474 <vector171>:
.globl vector171
vector171:
  pushl $0
  102474:	6a 00                	push   $0x0
  pushl $171
  102476:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10247b:	e9 f0 03 00 00       	jmp    102870 <__alltraps>

00102480 <vector172>:
.globl vector172
vector172:
  pushl $0
  102480:	6a 00                	push   $0x0
  pushl $172
  102482:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102487:	e9 e4 03 00 00       	jmp    102870 <__alltraps>

0010248c <vector173>:
.globl vector173
vector173:
  pushl $0
  10248c:	6a 00                	push   $0x0
  pushl $173
  10248e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102493:	e9 d8 03 00 00       	jmp    102870 <__alltraps>

00102498 <vector174>:
.globl vector174
vector174:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $174
  10249a:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10249f:	e9 cc 03 00 00       	jmp    102870 <__alltraps>

001024a4 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024a4:	6a 00                	push   $0x0
  pushl $175
  1024a6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024ab:	e9 c0 03 00 00       	jmp    102870 <__alltraps>

001024b0 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024b0:	6a 00                	push   $0x0
  pushl $176
  1024b2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024b7:	e9 b4 03 00 00       	jmp    102870 <__alltraps>

001024bc <vector177>:
.globl vector177
vector177:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $177
  1024be:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024c3:	e9 a8 03 00 00       	jmp    102870 <__alltraps>

001024c8 <vector178>:
.globl vector178
vector178:
  pushl $0
  1024c8:	6a 00                	push   $0x0
  pushl $178
  1024ca:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024cf:	e9 9c 03 00 00       	jmp    102870 <__alltraps>

001024d4 <vector179>:
.globl vector179
vector179:
  pushl $0
  1024d4:	6a 00                	push   $0x0
  pushl $179
  1024d6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024db:	e9 90 03 00 00       	jmp    102870 <__alltraps>

001024e0 <vector180>:
.globl vector180
vector180:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $180
  1024e2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1024e7:	e9 84 03 00 00       	jmp    102870 <__alltraps>

001024ec <vector181>:
.globl vector181
vector181:
  pushl $0
  1024ec:	6a 00                	push   $0x0
  pushl $181
  1024ee:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024f3:	e9 78 03 00 00       	jmp    102870 <__alltraps>

001024f8 <vector182>:
.globl vector182
vector182:
  pushl $0
  1024f8:	6a 00                	push   $0x0
  pushl $182
  1024fa:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024ff:	e9 6c 03 00 00       	jmp    102870 <__alltraps>

00102504 <vector183>:
.globl vector183
vector183:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $183
  102506:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10250b:	e9 60 03 00 00       	jmp    102870 <__alltraps>

00102510 <vector184>:
.globl vector184
vector184:
  pushl $0
  102510:	6a 00                	push   $0x0
  pushl $184
  102512:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102517:	e9 54 03 00 00       	jmp    102870 <__alltraps>

0010251c <vector185>:
.globl vector185
vector185:
  pushl $0
  10251c:	6a 00                	push   $0x0
  pushl $185
  10251e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102523:	e9 48 03 00 00       	jmp    102870 <__alltraps>

00102528 <vector186>:
.globl vector186
vector186:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $186
  10252a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10252f:	e9 3c 03 00 00       	jmp    102870 <__alltraps>

00102534 <vector187>:
.globl vector187
vector187:
  pushl $0
  102534:	6a 00                	push   $0x0
  pushl $187
  102536:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10253b:	e9 30 03 00 00       	jmp    102870 <__alltraps>

00102540 <vector188>:
.globl vector188
vector188:
  pushl $0
  102540:	6a 00                	push   $0x0
  pushl $188
  102542:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102547:	e9 24 03 00 00       	jmp    102870 <__alltraps>

0010254c <vector189>:
.globl vector189
vector189:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $189
  10254e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102553:	e9 18 03 00 00       	jmp    102870 <__alltraps>

00102558 <vector190>:
.globl vector190
vector190:
  pushl $0
  102558:	6a 00                	push   $0x0
  pushl $190
  10255a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10255f:	e9 0c 03 00 00       	jmp    102870 <__alltraps>

00102564 <vector191>:
.globl vector191
vector191:
  pushl $0
  102564:	6a 00                	push   $0x0
  pushl $191
  102566:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10256b:	e9 00 03 00 00       	jmp    102870 <__alltraps>

00102570 <vector192>:
.globl vector192
vector192:
  pushl $0
  102570:	6a 00                	push   $0x0
  pushl $192
  102572:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102577:	e9 f4 02 00 00       	jmp    102870 <__alltraps>

0010257c <vector193>:
.globl vector193
vector193:
  pushl $0
  10257c:	6a 00                	push   $0x0
  pushl $193
  10257e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102583:	e9 e8 02 00 00       	jmp    102870 <__alltraps>

00102588 <vector194>:
.globl vector194
vector194:
  pushl $0
  102588:	6a 00                	push   $0x0
  pushl $194
  10258a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10258f:	e9 dc 02 00 00       	jmp    102870 <__alltraps>

00102594 <vector195>:
.globl vector195
vector195:
  pushl $0
  102594:	6a 00                	push   $0x0
  pushl $195
  102596:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10259b:	e9 d0 02 00 00       	jmp    102870 <__alltraps>

001025a0 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025a0:	6a 00                	push   $0x0
  pushl $196
  1025a2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025a7:	e9 c4 02 00 00       	jmp    102870 <__alltraps>

001025ac <vector197>:
.globl vector197
vector197:
  pushl $0
  1025ac:	6a 00                	push   $0x0
  pushl $197
  1025ae:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025b3:	e9 b8 02 00 00       	jmp    102870 <__alltraps>

001025b8 <vector198>:
.globl vector198
vector198:
  pushl $0
  1025b8:	6a 00                	push   $0x0
  pushl $198
  1025ba:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025bf:	e9 ac 02 00 00       	jmp    102870 <__alltraps>

001025c4 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025c4:	6a 00                	push   $0x0
  pushl $199
  1025c6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025cb:	e9 a0 02 00 00       	jmp    102870 <__alltraps>

001025d0 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025d0:	6a 00                	push   $0x0
  pushl $200
  1025d2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025d7:	e9 94 02 00 00       	jmp    102870 <__alltraps>

001025dc <vector201>:
.globl vector201
vector201:
  pushl $0
  1025dc:	6a 00                	push   $0x0
  pushl $201
  1025de:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1025e3:	e9 88 02 00 00       	jmp    102870 <__alltraps>

001025e8 <vector202>:
.globl vector202
vector202:
  pushl $0
  1025e8:	6a 00                	push   $0x0
  pushl $202
  1025ea:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025ef:	e9 7c 02 00 00       	jmp    102870 <__alltraps>

001025f4 <vector203>:
.globl vector203
vector203:
  pushl $0
  1025f4:	6a 00                	push   $0x0
  pushl $203
  1025f6:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025fb:	e9 70 02 00 00       	jmp    102870 <__alltraps>

00102600 <vector204>:
.globl vector204
vector204:
  pushl $0
  102600:	6a 00                	push   $0x0
  pushl $204
  102602:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102607:	e9 64 02 00 00       	jmp    102870 <__alltraps>

0010260c <vector205>:
.globl vector205
vector205:
  pushl $0
  10260c:	6a 00                	push   $0x0
  pushl $205
  10260e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102613:	e9 58 02 00 00       	jmp    102870 <__alltraps>

00102618 <vector206>:
.globl vector206
vector206:
  pushl $0
  102618:	6a 00                	push   $0x0
  pushl $206
  10261a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10261f:	e9 4c 02 00 00       	jmp    102870 <__alltraps>

00102624 <vector207>:
.globl vector207
vector207:
  pushl $0
  102624:	6a 00                	push   $0x0
  pushl $207
  102626:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10262b:	e9 40 02 00 00       	jmp    102870 <__alltraps>

00102630 <vector208>:
.globl vector208
vector208:
  pushl $0
  102630:	6a 00                	push   $0x0
  pushl $208
  102632:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102637:	e9 34 02 00 00       	jmp    102870 <__alltraps>

0010263c <vector209>:
.globl vector209
vector209:
  pushl $0
  10263c:	6a 00                	push   $0x0
  pushl $209
  10263e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102643:	e9 28 02 00 00       	jmp    102870 <__alltraps>

00102648 <vector210>:
.globl vector210
vector210:
  pushl $0
  102648:	6a 00                	push   $0x0
  pushl $210
  10264a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10264f:	e9 1c 02 00 00       	jmp    102870 <__alltraps>

00102654 <vector211>:
.globl vector211
vector211:
  pushl $0
  102654:	6a 00                	push   $0x0
  pushl $211
  102656:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10265b:	e9 10 02 00 00       	jmp    102870 <__alltraps>

00102660 <vector212>:
.globl vector212
vector212:
  pushl $0
  102660:	6a 00                	push   $0x0
  pushl $212
  102662:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102667:	e9 04 02 00 00       	jmp    102870 <__alltraps>

0010266c <vector213>:
.globl vector213
vector213:
  pushl $0
  10266c:	6a 00                	push   $0x0
  pushl $213
  10266e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102673:	e9 f8 01 00 00       	jmp    102870 <__alltraps>

00102678 <vector214>:
.globl vector214
vector214:
  pushl $0
  102678:	6a 00                	push   $0x0
  pushl $214
  10267a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10267f:	e9 ec 01 00 00       	jmp    102870 <__alltraps>

00102684 <vector215>:
.globl vector215
vector215:
  pushl $0
  102684:	6a 00                	push   $0x0
  pushl $215
  102686:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10268b:	e9 e0 01 00 00       	jmp    102870 <__alltraps>

00102690 <vector216>:
.globl vector216
vector216:
  pushl $0
  102690:	6a 00                	push   $0x0
  pushl $216
  102692:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102697:	e9 d4 01 00 00       	jmp    102870 <__alltraps>

0010269c <vector217>:
.globl vector217
vector217:
  pushl $0
  10269c:	6a 00                	push   $0x0
  pushl $217
  10269e:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026a3:	e9 c8 01 00 00       	jmp    102870 <__alltraps>

001026a8 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026a8:	6a 00                	push   $0x0
  pushl $218
  1026aa:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026af:	e9 bc 01 00 00       	jmp    102870 <__alltraps>

001026b4 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026b4:	6a 00                	push   $0x0
  pushl $219
  1026b6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026bb:	e9 b0 01 00 00       	jmp    102870 <__alltraps>

001026c0 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026c0:	6a 00                	push   $0x0
  pushl $220
  1026c2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026c7:	e9 a4 01 00 00       	jmp    102870 <__alltraps>

001026cc <vector221>:
.globl vector221
vector221:
  pushl $0
  1026cc:	6a 00                	push   $0x0
  pushl $221
  1026ce:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026d3:	e9 98 01 00 00       	jmp    102870 <__alltraps>

001026d8 <vector222>:
.globl vector222
vector222:
  pushl $0
  1026d8:	6a 00                	push   $0x0
  pushl $222
  1026da:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1026df:	e9 8c 01 00 00       	jmp    102870 <__alltraps>

001026e4 <vector223>:
.globl vector223
vector223:
  pushl $0
  1026e4:	6a 00                	push   $0x0
  pushl $223
  1026e6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026eb:	e9 80 01 00 00       	jmp    102870 <__alltraps>

001026f0 <vector224>:
.globl vector224
vector224:
  pushl $0
  1026f0:	6a 00                	push   $0x0
  pushl $224
  1026f2:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026f7:	e9 74 01 00 00       	jmp    102870 <__alltraps>

001026fc <vector225>:
.globl vector225
vector225:
  pushl $0
  1026fc:	6a 00                	push   $0x0
  pushl $225
  1026fe:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102703:	e9 68 01 00 00       	jmp    102870 <__alltraps>

00102708 <vector226>:
.globl vector226
vector226:
  pushl $0
  102708:	6a 00                	push   $0x0
  pushl $226
  10270a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10270f:	e9 5c 01 00 00       	jmp    102870 <__alltraps>

00102714 <vector227>:
.globl vector227
vector227:
  pushl $0
  102714:	6a 00                	push   $0x0
  pushl $227
  102716:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10271b:	e9 50 01 00 00       	jmp    102870 <__alltraps>

00102720 <vector228>:
.globl vector228
vector228:
  pushl $0
  102720:	6a 00                	push   $0x0
  pushl $228
  102722:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102727:	e9 44 01 00 00       	jmp    102870 <__alltraps>

0010272c <vector229>:
.globl vector229
vector229:
  pushl $0
  10272c:	6a 00                	push   $0x0
  pushl $229
  10272e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102733:	e9 38 01 00 00       	jmp    102870 <__alltraps>

00102738 <vector230>:
.globl vector230
vector230:
  pushl $0
  102738:	6a 00                	push   $0x0
  pushl $230
  10273a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10273f:	e9 2c 01 00 00       	jmp    102870 <__alltraps>

00102744 <vector231>:
.globl vector231
vector231:
  pushl $0
  102744:	6a 00                	push   $0x0
  pushl $231
  102746:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10274b:	e9 20 01 00 00       	jmp    102870 <__alltraps>

00102750 <vector232>:
.globl vector232
vector232:
  pushl $0
  102750:	6a 00                	push   $0x0
  pushl $232
  102752:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102757:	e9 14 01 00 00       	jmp    102870 <__alltraps>

0010275c <vector233>:
.globl vector233
vector233:
  pushl $0
  10275c:	6a 00                	push   $0x0
  pushl $233
  10275e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102763:	e9 08 01 00 00       	jmp    102870 <__alltraps>

00102768 <vector234>:
.globl vector234
vector234:
  pushl $0
  102768:	6a 00                	push   $0x0
  pushl $234
  10276a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10276f:	e9 fc 00 00 00       	jmp    102870 <__alltraps>

00102774 <vector235>:
.globl vector235
vector235:
  pushl $0
  102774:	6a 00                	push   $0x0
  pushl $235
  102776:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10277b:	e9 f0 00 00 00       	jmp    102870 <__alltraps>

00102780 <vector236>:
.globl vector236
vector236:
  pushl $0
  102780:	6a 00                	push   $0x0
  pushl $236
  102782:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102787:	e9 e4 00 00 00       	jmp    102870 <__alltraps>

0010278c <vector237>:
.globl vector237
vector237:
  pushl $0
  10278c:	6a 00                	push   $0x0
  pushl $237
  10278e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102793:	e9 d8 00 00 00       	jmp    102870 <__alltraps>

00102798 <vector238>:
.globl vector238
vector238:
  pushl $0
  102798:	6a 00                	push   $0x0
  pushl $238
  10279a:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10279f:	e9 cc 00 00 00       	jmp    102870 <__alltraps>

001027a4 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027a4:	6a 00                	push   $0x0
  pushl $239
  1027a6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027ab:	e9 c0 00 00 00       	jmp    102870 <__alltraps>

001027b0 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027b0:	6a 00                	push   $0x0
  pushl $240
  1027b2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027b7:	e9 b4 00 00 00       	jmp    102870 <__alltraps>

001027bc <vector241>:
.globl vector241
vector241:
  pushl $0
  1027bc:	6a 00                	push   $0x0
  pushl $241
  1027be:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027c3:	e9 a8 00 00 00       	jmp    102870 <__alltraps>

001027c8 <vector242>:
.globl vector242
vector242:
  pushl $0
  1027c8:	6a 00                	push   $0x0
  pushl $242
  1027ca:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027cf:	e9 9c 00 00 00       	jmp    102870 <__alltraps>

001027d4 <vector243>:
.globl vector243
vector243:
  pushl $0
  1027d4:	6a 00                	push   $0x0
  pushl $243
  1027d6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027db:	e9 90 00 00 00       	jmp    102870 <__alltraps>

001027e0 <vector244>:
.globl vector244
vector244:
  pushl $0
  1027e0:	6a 00                	push   $0x0
  pushl $244
  1027e2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1027e7:	e9 84 00 00 00       	jmp    102870 <__alltraps>

001027ec <vector245>:
.globl vector245
vector245:
  pushl $0
  1027ec:	6a 00                	push   $0x0
  pushl $245
  1027ee:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027f3:	e9 78 00 00 00       	jmp    102870 <__alltraps>

001027f8 <vector246>:
.globl vector246
vector246:
  pushl $0
  1027f8:	6a 00                	push   $0x0
  pushl $246
  1027fa:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027ff:	e9 6c 00 00 00       	jmp    102870 <__alltraps>

00102804 <vector247>:
.globl vector247
vector247:
  pushl $0
  102804:	6a 00                	push   $0x0
  pushl $247
  102806:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10280b:	e9 60 00 00 00       	jmp    102870 <__alltraps>

00102810 <vector248>:
.globl vector248
vector248:
  pushl $0
  102810:	6a 00                	push   $0x0
  pushl $248
  102812:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102817:	e9 54 00 00 00       	jmp    102870 <__alltraps>

0010281c <vector249>:
.globl vector249
vector249:
  pushl $0
  10281c:	6a 00                	push   $0x0
  pushl $249
  10281e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102823:	e9 48 00 00 00       	jmp    102870 <__alltraps>

00102828 <vector250>:
.globl vector250
vector250:
  pushl $0
  102828:	6a 00                	push   $0x0
  pushl $250
  10282a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10282f:	e9 3c 00 00 00       	jmp    102870 <__alltraps>

00102834 <vector251>:
.globl vector251
vector251:
  pushl $0
  102834:	6a 00                	push   $0x0
  pushl $251
  102836:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10283b:	e9 30 00 00 00       	jmp    102870 <__alltraps>

00102840 <vector252>:
.globl vector252
vector252:
  pushl $0
  102840:	6a 00                	push   $0x0
  pushl $252
  102842:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102847:	e9 24 00 00 00       	jmp    102870 <__alltraps>

0010284c <vector253>:
.globl vector253
vector253:
  pushl $0
  10284c:	6a 00                	push   $0x0
  pushl $253
  10284e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102853:	e9 18 00 00 00       	jmp    102870 <__alltraps>

00102858 <vector254>:
.globl vector254
vector254:
  pushl $0
  102858:	6a 00                	push   $0x0
  pushl $254
  10285a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10285f:	e9 0c 00 00 00       	jmp    102870 <__alltraps>

00102864 <vector255>:
.globl vector255
vector255:
  pushl $0
  102864:	6a 00                	push   $0x0
  pushl $255
  102866:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10286b:	e9 00 00 00 00       	jmp    102870 <__alltraps>

00102870 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102870:	1e                   	push   %ds
    pushl %es
  102871:	06                   	push   %es
    pushl %fs
  102872:	0f a0                	push   %fs
    pushl %gs
  102874:	0f a8                	push   %gs
    pushal
  102876:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102877:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10287c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10287e:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102880:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102881:	e8 67 f5 ff ff       	call   101ded <trap>

    # pop the pushed stack pointer
    popl %esp
  102886:	5c                   	pop    %esp

00102887 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102887:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102888:	0f a9                	pop    %gs
    popl %fs
  10288a:	0f a1                	pop    %fs
    popl %es
  10288c:	07                   	pop    %es
    popl %ds
  10288d:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10288e:	83 c4 08             	add    $0x8,%esp
    iret
  102891:	cf                   	iret   

00102892 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102892:	55                   	push   %ebp
  102893:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102895:	8b 55 08             	mov    0x8(%ebp),%edx
  102898:	a1 58 89 11 00       	mov    0x118958,%eax
  10289d:	29 c2                	sub    %eax,%edx
  10289f:	89 d0                	mov    %edx,%eax
  1028a1:	c1 f8 02             	sar    $0x2,%eax
  1028a4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028aa:	5d                   	pop    %ebp
  1028ab:	c3                   	ret    

001028ac <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028ac:	55                   	push   %ebp
  1028ad:	89 e5                	mov    %esp,%ebp
  1028af:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028b5:	89 04 24             	mov    %eax,(%esp)
  1028b8:	e8 d5 ff ff ff       	call   102892 <page2ppn>
  1028bd:	c1 e0 0c             	shl    $0xc,%eax
}
  1028c0:	c9                   	leave  
  1028c1:	c3                   	ret    

001028c2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1028c2:	55                   	push   %ebp
  1028c3:	89 e5                	mov    %esp,%ebp
  1028c5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1028c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028cb:	c1 e8 0c             	shr    $0xc,%eax
  1028ce:	89 c2                	mov    %eax,%edx
  1028d0:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  1028d5:	39 c2                	cmp    %eax,%edx
  1028d7:	72 1c                	jb     1028f5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1028d9:	c7 44 24 08 70 66 10 	movl   $0x106670,0x8(%esp)
  1028e0:	00 
  1028e1:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1028e8:	00 
  1028e9:	c7 04 24 8f 66 10 00 	movl   $0x10668f,(%esp)
  1028f0:	e8 e8 da ff ff       	call   1003dd <__panic>
    }
    return &pages[PPN(pa)];
  1028f5:	8b 0d 58 89 11 00    	mov    0x118958,%ecx
  1028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1028fe:	c1 e8 0c             	shr    $0xc,%eax
  102901:	89 c2                	mov    %eax,%edx
  102903:	89 d0                	mov    %edx,%eax
  102905:	c1 e0 02             	shl    $0x2,%eax
  102908:	01 d0                	add    %edx,%eax
  10290a:	c1 e0 02             	shl    $0x2,%eax
  10290d:	01 c8                	add    %ecx,%eax
}
  10290f:	c9                   	leave  
  102910:	c3                   	ret    

00102911 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102911:	55                   	push   %ebp
  102912:	89 e5                	mov    %esp,%ebp
  102914:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102917:	8b 45 08             	mov    0x8(%ebp),%eax
  10291a:	89 04 24             	mov    %eax,(%esp)
  10291d:	e8 8a ff ff ff       	call   1028ac <page2pa>
  102922:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102928:	c1 e8 0c             	shr    $0xc,%eax
  10292b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10292e:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  102933:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102936:	72 23                	jb     10295b <page2kva+0x4a>
  102938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10293b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10293f:	c7 44 24 08 a0 66 10 	movl   $0x1066a0,0x8(%esp)
  102946:	00 
  102947:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10294e:	00 
  10294f:	c7 04 24 8f 66 10 00 	movl   $0x10668f,(%esp)
  102956:	e8 82 da ff ff       	call   1003dd <__panic>
  10295b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10295e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102963:	c9                   	leave  
  102964:	c3                   	ret    

00102965 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102965:	55                   	push   %ebp
  102966:	89 e5                	mov    %esp,%ebp
  102968:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  10296b:	8b 45 08             	mov    0x8(%ebp),%eax
  10296e:	83 e0 01             	and    $0x1,%eax
  102971:	85 c0                	test   %eax,%eax
  102973:	75 1c                	jne    102991 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102975:	c7 44 24 08 c4 66 10 	movl   $0x1066c4,0x8(%esp)
  10297c:	00 
  10297d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102984:	00 
  102985:	c7 04 24 8f 66 10 00 	movl   $0x10668f,(%esp)
  10298c:	e8 4c da ff ff       	call   1003dd <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102991:	8b 45 08             	mov    0x8(%ebp),%eax
  102994:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102999:	89 04 24             	mov    %eax,(%esp)
  10299c:	e8 21 ff ff ff       	call   1028c2 <pa2page>
}
  1029a1:	c9                   	leave  
  1029a2:	c3                   	ret    

001029a3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  1029a3:	55                   	push   %ebp
  1029a4:	89 e5                	mov    %esp,%ebp
  1029a6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  1029a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1029b1:	89 04 24             	mov    %eax,(%esp)
  1029b4:	e8 09 ff ff ff       	call   1028c2 <pa2page>
}
  1029b9:	c9                   	leave  
  1029ba:	c3                   	ret    

001029bb <page_ref>:

static inline int
page_ref(struct Page *page) {
  1029bb:	55                   	push   %ebp
  1029bc:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1029be:	8b 45 08             	mov    0x8(%ebp),%eax
  1029c1:	8b 00                	mov    (%eax),%eax
}
  1029c3:	5d                   	pop    %ebp
  1029c4:	c3                   	ret    

001029c5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1029c5:	55                   	push   %ebp
  1029c6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1029c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029ce:	89 10                	mov    %edx,(%eax)
}
  1029d0:	5d                   	pop    %ebp
  1029d1:	c3                   	ret    

001029d2 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  1029d2:	55                   	push   %ebp
  1029d3:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d8:	8b 00                	mov    (%eax),%eax
  1029da:	8d 50 01             	lea    0x1(%eax),%edx
  1029dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e0:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e5:	8b 00                	mov    (%eax),%eax
}
  1029e7:	5d                   	pop    %ebp
  1029e8:	c3                   	ret    

001029e9 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029e9:	55                   	push   %ebp
  1029ea:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ef:	8b 00                	mov    (%eax),%eax
  1029f1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f7:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1029fc:	8b 00                	mov    (%eax),%eax
}
  1029fe:	5d                   	pop    %ebp
  1029ff:	c3                   	ret    

00102a00 <__intr_save>:
__intr_save(void) {
  102a00:	55                   	push   %ebp
  102a01:	89 e5                	mov    %esp,%ebp
  102a03:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102a06:	9c                   	pushf  
  102a07:	58                   	pop    %eax
  102a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a0e:	25 00 02 00 00       	and    $0x200,%eax
  102a13:	85 c0                	test   %eax,%eax
  102a15:	74 0c                	je     102a23 <__intr_save+0x23>
        intr_disable();
  102a17:	e8 5a ee ff ff       	call   101876 <intr_disable>
        return 1;
  102a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  102a21:	eb 05                	jmp    102a28 <__intr_save+0x28>
    return 0;
  102a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a28:	c9                   	leave  
  102a29:	c3                   	ret    

00102a2a <__intr_restore>:
__intr_restore(bool flag) {
  102a2a:	55                   	push   %ebp
  102a2b:	89 e5                	mov    %esp,%ebp
  102a2d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a34:	74 05                	je     102a3b <__intr_restore+0x11>
        intr_enable();
  102a36:	e8 35 ee ff ff       	call   101870 <intr_enable>
}
  102a3b:	c9                   	leave  
  102a3c:	c3                   	ret    

00102a3d <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a3d:	55                   	push   %ebp
  102a3e:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a40:	8b 45 08             	mov    0x8(%ebp),%eax
  102a43:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a46:	b8 23 00 00 00       	mov    $0x23,%eax
  102a4b:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a4d:	b8 23 00 00 00       	mov    $0x23,%eax
  102a52:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a54:	b8 10 00 00 00       	mov    $0x10,%eax
  102a59:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a5b:	b8 10 00 00 00       	mov    $0x10,%eax
  102a60:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a62:	b8 10 00 00 00       	mov    $0x10,%eax
  102a67:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a69:	ea 70 2a 10 00 08 00 	ljmp   $0x8,$0x102a70
}
  102a70:	5d                   	pop    %ebp
  102a71:	c3                   	ret    

00102a72 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a72:	55                   	push   %ebp
  102a73:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a75:	8b 45 08             	mov    0x8(%ebp),%eax
  102a78:	a3 e4 88 11 00       	mov    %eax,0x1188e4
}
  102a7d:	5d                   	pop    %ebp
  102a7e:	c3                   	ret    

00102a7f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a7f:	55                   	push   %ebp
  102a80:	89 e5                	mov    %esp,%ebp
  102a82:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a85:	b8 00 70 11 00       	mov    $0x117000,%eax
  102a8a:	89 04 24             	mov    %eax,(%esp)
  102a8d:	e8 e0 ff ff ff       	call   102a72 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a92:	66 c7 05 e8 88 11 00 	movw   $0x10,0x1188e8
  102a99:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a9b:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102aa2:	68 00 
  102aa4:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102aa9:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102aaf:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102ab4:	c1 e8 10             	shr    $0x10,%eax
  102ab7:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102abc:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ac3:	83 e0 f0             	and    $0xfffffff0,%eax
  102ac6:	83 c8 09             	or     $0x9,%eax
  102ac9:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ace:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ad5:	83 e0 ef             	and    $0xffffffef,%eax
  102ad8:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102add:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ae4:	83 e0 9f             	and    $0xffffff9f,%eax
  102ae7:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102aec:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102af3:	83 c8 80             	or     $0xffffff80,%eax
  102af6:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102afb:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b02:	83 e0 f0             	and    $0xfffffff0,%eax
  102b05:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b0a:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b11:	83 e0 ef             	and    $0xffffffef,%eax
  102b14:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b19:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b20:	83 e0 df             	and    $0xffffffdf,%eax
  102b23:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b28:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b2f:	83 c8 40             	or     $0x40,%eax
  102b32:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b37:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b3e:	83 e0 7f             	and    $0x7f,%eax
  102b41:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b46:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102b4b:	c1 e8 18             	shr    $0x18,%eax
  102b4e:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b53:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b5a:	e8 de fe ff ff       	call   102a3d <lgdt>
  102b5f:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b65:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b69:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b6c:	c9                   	leave  
  102b6d:	c3                   	ret    

00102b6e <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b6e:	55                   	push   %ebp
  102b6f:	89 e5                	mov    %esp,%ebp
  102b71:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b74:	c7 05 50 89 11 00 38 	movl   $0x107038,0x118950
  102b7b:	70 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b7e:	a1 50 89 11 00       	mov    0x118950,%eax
  102b83:	8b 00                	mov    (%eax),%eax
  102b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b89:	c7 04 24 f0 66 10 00 	movl   $0x1066f0,(%esp)
  102b90:	e8 f1 d6 ff ff       	call   100286 <cprintf>
    pmm_manager->init();
  102b95:	a1 50 89 11 00       	mov    0x118950,%eax
  102b9a:	8b 40 04             	mov    0x4(%eax),%eax
  102b9d:	ff d0                	call   *%eax
}
  102b9f:	c9                   	leave  
  102ba0:	c3                   	ret    

00102ba1 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102ba1:	55                   	push   %ebp
  102ba2:	89 e5                	mov    %esp,%ebp
  102ba4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102ba7:	a1 50 89 11 00       	mov    0x118950,%eax
  102bac:	8b 40 08             	mov    0x8(%eax),%eax
  102baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  102bb9:	89 14 24             	mov    %edx,(%esp)
  102bbc:	ff d0                	call   *%eax
}
  102bbe:	c9                   	leave  
  102bbf:	c3                   	ret    

00102bc0 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bc0:	55                   	push   %ebp
  102bc1:	89 e5                	mov    %esp,%ebp
  102bc3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102bc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bcd:	e8 2e fe ff ff       	call   102a00 <__intr_save>
  102bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102bd5:	a1 50 89 11 00       	mov    0x118950,%eax
  102bda:	8b 40 0c             	mov    0xc(%eax),%eax
  102bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  102be0:	89 14 24             	mov    %edx,(%esp)
  102be3:	ff d0                	call   *%eax
  102be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102beb:	89 04 24             	mov    %eax,(%esp)
  102bee:	e8 37 fe ff ff       	call   102a2a <__intr_restore>
    return page;
  102bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102bf6:	c9                   	leave  
  102bf7:	c3                   	ret    

00102bf8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102bf8:	55                   	push   %ebp
  102bf9:	89 e5                	mov    %esp,%ebp
  102bfb:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102bfe:	e8 fd fd ff ff       	call   102a00 <__intr_save>
  102c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102c06:	a1 50 89 11 00       	mov    0x118950,%eax
  102c0b:	8b 40 10             	mov    0x10(%eax),%eax
  102c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c11:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c15:	8b 55 08             	mov    0x8(%ebp),%edx
  102c18:	89 14 24             	mov    %edx,(%esp)
  102c1b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c20:	89 04 24             	mov    %eax,(%esp)
  102c23:	e8 02 fe ff ff       	call   102a2a <__intr_restore>
}
  102c28:	c9                   	leave  
  102c29:	c3                   	ret    

00102c2a <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c2a:	55                   	push   %ebp
  102c2b:	89 e5                	mov    %esp,%ebp
  102c2d:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c30:	e8 cb fd ff ff       	call   102a00 <__intr_save>
  102c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c38:	a1 50 89 11 00       	mov    0x118950,%eax
  102c3d:	8b 40 14             	mov    0x14(%eax),%eax
  102c40:	ff d0                	call   *%eax
  102c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c48:	89 04 24             	mov    %eax,(%esp)
  102c4b:	e8 da fd ff ff       	call   102a2a <__intr_restore>
    return ret;
  102c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c53:	c9                   	leave  
  102c54:	c3                   	ret    

00102c55 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c55:	55                   	push   %ebp
  102c56:	89 e5                	mov    %esp,%ebp
  102c58:	57                   	push   %edi
  102c59:	56                   	push   %esi
  102c5a:	53                   	push   %ebx
  102c5b:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c61:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c68:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c6f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c76:	c7 04 24 07 67 10 00 	movl   $0x106707,(%esp)
  102c7d:	e8 04 d6 ff ff       	call   100286 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c82:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c89:	e9 15 01 00 00       	jmp    102da3 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c8e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c91:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c94:	89 d0                	mov    %edx,%eax
  102c96:	c1 e0 02             	shl    $0x2,%eax
  102c99:	01 d0                	add    %edx,%eax
  102c9b:	c1 e0 02             	shl    $0x2,%eax
  102c9e:	01 c8                	add    %ecx,%eax
  102ca0:	8b 50 08             	mov    0x8(%eax),%edx
  102ca3:	8b 40 04             	mov    0x4(%eax),%eax
  102ca6:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102ca9:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102cac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102caf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cb2:	89 d0                	mov    %edx,%eax
  102cb4:	c1 e0 02             	shl    $0x2,%eax
  102cb7:	01 d0                	add    %edx,%eax
  102cb9:	c1 e0 02             	shl    $0x2,%eax
  102cbc:	01 c8                	add    %ecx,%eax
  102cbe:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cc1:	8b 58 10             	mov    0x10(%eax),%ebx
  102cc4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102cc7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102cca:	01 c8                	add    %ecx,%eax
  102ccc:	11 da                	adc    %ebx,%edx
  102cce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102cd1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cd4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cd7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cda:	89 d0                	mov    %edx,%eax
  102cdc:	c1 e0 02             	shl    $0x2,%eax
  102cdf:	01 d0                	add    %edx,%eax
  102ce1:	c1 e0 02             	shl    $0x2,%eax
  102ce4:	01 c8                	add    %ecx,%eax
  102ce6:	83 c0 14             	add    $0x14,%eax
  102ce9:	8b 00                	mov    (%eax),%eax
  102ceb:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  102cf1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102cf4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102cf7:	83 c0 ff             	add    $0xffffffff,%eax
  102cfa:	83 d2 ff             	adc    $0xffffffff,%edx
  102cfd:	89 c6                	mov    %eax,%esi
  102cff:	89 d7                	mov    %edx,%edi
  102d01:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d04:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d07:	89 d0                	mov    %edx,%eax
  102d09:	c1 e0 02             	shl    $0x2,%eax
  102d0c:	01 d0                	add    %edx,%eax
  102d0e:	c1 e0 02             	shl    $0x2,%eax
  102d11:	01 c8                	add    %ecx,%eax
  102d13:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d16:	8b 58 10             	mov    0x10(%eax),%ebx
  102d19:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102d1f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  102d23:	89 74 24 14          	mov    %esi,0x14(%esp)
  102d27:	89 7c 24 18          	mov    %edi,0x18(%esp)
  102d2b:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d2e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d35:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d39:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d41:	c7 04 24 14 67 10 00 	movl   $0x106714,(%esp)
  102d48:	e8 39 d5 ff ff       	call   100286 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d4d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d50:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d53:	89 d0                	mov    %edx,%eax
  102d55:	c1 e0 02             	shl    $0x2,%eax
  102d58:	01 d0                	add    %edx,%eax
  102d5a:	c1 e0 02             	shl    $0x2,%eax
  102d5d:	01 c8                	add    %ecx,%eax
  102d5f:	83 c0 14             	add    $0x14,%eax
  102d62:	8b 00                	mov    (%eax),%eax
  102d64:	83 f8 01             	cmp    $0x1,%eax
  102d67:	75 36                	jne    102d9f <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  102d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d6f:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d72:	77 2b                	ja     102d9f <page_init+0x14a>
  102d74:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d77:	72 05                	jb     102d7e <page_init+0x129>
  102d79:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d7c:	73 21                	jae    102d9f <page_init+0x14a>
  102d7e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d82:	77 1b                	ja     102d9f <page_init+0x14a>
  102d84:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d88:	72 09                	jb     102d93 <page_init+0x13e>
  102d8a:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102d91:	77 0c                	ja     102d9f <page_init+0x14a>
                maxpa = end;
  102d93:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d96:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d9c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102d9f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102da3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102da6:	8b 00                	mov    (%eax),%eax
  102da8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102dab:	0f 8f dd fe ff ff    	jg     102c8e <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102db1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102db5:	72 1d                	jb     102dd4 <page_init+0x17f>
  102db7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dbb:	77 09                	ja     102dc6 <page_init+0x171>
  102dbd:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102dc4:	76 0e                	jbe    102dd4 <page_init+0x17f>
        maxpa = KMEMSIZE;
  102dc6:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102dcd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102dd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102dd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102dda:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102dde:	c1 ea 0c             	shr    $0xc,%edx
  102de1:	a3 c0 88 11 00       	mov    %eax,0x1188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102de6:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102ded:	b8 68 89 11 00       	mov    $0x118968,%eax
  102df2:	8d 50 ff             	lea    -0x1(%eax),%edx
  102df5:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102df8:	01 d0                	add    %edx,%eax
  102dfa:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102dfd:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e00:	ba 00 00 00 00       	mov    $0x0,%edx
  102e05:	f7 75 ac             	divl   -0x54(%ebp)
  102e08:	89 d0                	mov    %edx,%eax
  102e0a:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e0d:	29 c2                	sub    %eax,%edx
  102e0f:	89 d0                	mov    %edx,%eax
  102e11:	a3 58 89 11 00       	mov    %eax,0x118958

    for (i = 0; i < npage; i ++) {
  102e16:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e1d:	eb 2f                	jmp    102e4e <page_init+0x1f9>
        SetPageReserved(pages + i);
  102e1f:	8b 0d 58 89 11 00    	mov    0x118958,%ecx
  102e25:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e28:	89 d0                	mov    %edx,%eax
  102e2a:	c1 e0 02             	shl    $0x2,%eax
  102e2d:	01 d0                	add    %edx,%eax
  102e2f:	c1 e0 02             	shl    $0x2,%eax
  102e32:	01 c8                	add    %ecx,%eax
  102e34:	83 c0 04             	add    $0x4,%eax
  102e37:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e3e:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e41:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e44:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e47:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e4a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102e4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e51:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  102e56:	39 c2                	cmp    %eax,%edx
  102e58:	72 c5                	jb     102e1f <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e5a:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  102e60:	89 d0                	mov    %edx,%eax
  102e62:	c1 e0 02             	shl    $0x2,%eax
  102e65:	01 d0                	add    %edx,%eax
  102e67:	c1 e0 02             	shl    $0x2,%eax
  102e6a:	89 c2                	mov    %eax,%edx
  102e6c:	a1 58 89 11 00       	mov    0x118958,%eax
  102e71:	01 d0                	add    %edx,%eax
  102e73:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e76:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102e7d:	77 23                	ja     102ea2 <page_init+0x24d>
  102e7f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e86:	c7 44 24 08 44 67 10 	movl   $0x106744,0x8(%esp)
  102e8d:	00 
  102e8e:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  102e95:	00 
  102e96:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  102e9d:	e8 3b d5 ff ff       	call   1003dd <__panic>
  102ea2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102ea5:	05 00 00 00 40       	add    $0x40000000,%eax
  102eaa:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ead:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102eb4:	e9 74 01 00 00       	jmp    10302d <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102eb9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ebc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ebf:	89 d0                	mov    %edx,%eax
  102ec1:	c1 e0 02             	shl    $0x2,%eax
  102ec4:	01 d0                	add    %edx,%eax
  102ec6:	c1 e0 02             	shl    $0x2,%eax
  102ec9:	01 c8                	add    %ecx,%eax
  102ecb:	8b 50 08             	mov    0x8(%eax),%edx
  102ece:	8b 40 04             	mov    0x4(%eax),%eax
  102ed1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ed4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ed7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102edd:	89 d0                	mov    %edx,%eax
  102edf:	c1 e0 02             	shl    $0x2,%eax
  102ee2:	01 d0                	add    %edx,%eax
  102ee4:	c1 e0 02             	shl    $0x2,%eax
  102ee7:	01 c8                	add    %ecx,%eax
  102ee9:	8b 48 0c             	mov    0xc(%eax),%ecx
  102eec:	8b 58 10             	mov    0x10(%eax),%ebx
  102eef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ef2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ef5:	01 c8                	add    %ecx,%eax
  102ef7:	11 da                	adc    %ebx,%edx
  102ef9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102efc:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102eff:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f02:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f05:	89 d0                	mov    %edx,%eax
  102f07:	c1 e0 02             	shl    $0x2,%eax
  102f0a:	01 d0                	add    %edx,%eax
  102f0c:	c1 e0 02             	shl    $0x2,%eax
  102f0f:	01 c8                	add    %ecx,%eax
  102f11:	83 c0 14             	add    $0x14,%eax
  102f14:	8b 00                	mov    (%eax),%eax
  102f16:	83 f8 01             	cmp    $0x1,%eax
  102f19:	0f 85 0a 01 00 00    	jne    103029 <page_init+0x3d4>
            if (begin < freemem) {
  102f1f:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f22:	ba 00 00 00 00       	mov    $0x0,%edx
  102f27:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f2a:	72 17                	jb     102f43 <page_init+0x2ee>
  102f2c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f2f:	77 05                	ja     102f36 <page_init+0x2e1>
  102f31:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f34:	76 0d                	jbe    102f43 <page_init+0x2ee>
                begin = freemem;
  102f36:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f39:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f3c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f43:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f47:	72 1d                	jb     102f66 <page_init+0x311>
  102f49:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f4d:	77 09                	ja     102f58 <page_init+0x303>
  102f4f:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f56:	76 0e                	jbe    102f66 <page_init+0x311>
                end = KMEMSIZE;
  102f58:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f5f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f66:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f6c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f6f:	0f 87 b4 00 00 00    	ja     103029 <page_init+0x3d4>
  102f75:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f78:	72 09                	jb     102f83 <page_init+0x32e>
  102f7a:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f7d:	0f 83 a6 00 00 00    	jae    103029 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  102f83:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f8a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f8d:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f90:	01 d0                	add    %edx,%eax
  102f92:	83 e8 01             	sub    $0x1,%eax
  102f95:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f98:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  102fa0:	f7 75 9c             	divl   -0x64(%ebp)
  102fa3:	89 d0                	mov    %edx,%eax
  102fa5:	8b 55 98             	mov    -0x68(%ebp),%edx
  102fa8:	29 c2                	sub    %eax,%edx
  102faa:	89 d0                	mov    %edx,%eax
  102fac:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fb4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102fb7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fba:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102fbd:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  102fc5:	89 c7                	mov    %eax,%edi
  102fc7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  102fcd:	89 7d 80             	mov    %edi,-0x80(%ebp)
  102fd0:	89 d0                	mov    %edx,%eax
  102fd2:	83 e0 00             	and    $0x0,%eax
  102fd5:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102fd8:	8b 45 80             	mov    -0x80(%ebp),%eax
  102fdb:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102fde:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102fe1:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  102fe4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fe7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fea:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fed:	77 3a                	ja     103029 <page_init+0x3d4>
  102fef:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102ff2:	72 05                	jb     102ff9 <page_init+0x3a4>
  102ff4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102ff7:	73 30                	jae    103029 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102ff9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  102ffc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  102fff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103002:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103005:	29 c8                	sub    %ecx,%eax
  103007:	19 da                	sbb    %ebx,%edx
  103009:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10300d:	c1 ea 0c             	shr    $0xc,%edx
  103010:	89 c3                	mov    %eax,%ebx
  103012:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103015:	89 04 24             	mov    %eax,(%esp)
  103018:	e8 a5 f8 ff ff       	call   1028c2 <pa2page>
  10301d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103021:	89 04 24             	mov    %eax,(%esp)
  103024:	e8 78 fb ff ff       	call   102ba1 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103029:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  10302d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103030:	8b 00                	mov    (%eax),%eax
  103032:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103035:	0f 8f 7e fe ff ff    	jg     102eb9 <page_init+0x264>
                }
            }
        }
    }
}
  10303b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103041:	5b                   	pop    %ebx
  103042:	5e                   	pop    %esi
  103043:	5f                   	pop    %edi
  103044:	5d                   	pop    %ebp
  103045:	c3                   	ret    

00103046 <enable_paging>:

static void
enable_paging(void) {
  103046:	55                   	push   %ebp
  103047:	89 e5                	mov    %esp,%ebp
  103049:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
  10304c:	a1 54 89 11 00       	mov    0x118954,%eax
  103051:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
  103054:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103057:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
  10305a:	0f 20 c0             	mov    %cr0,%eax
  10305d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
  103060:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
  103063:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
  103066:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
  10306d:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
  103071:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103074:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
  103077:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10307a:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
  10307d:	c9                   	leave  
  10307e:	c3                   	ret    

0010307f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10307f:	55                   	push   %ebp
  103080:	89 e5                	mov    %esp,%ebp
  103082:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103085:	8b 45 14             	mov    0x14(%ebp),%eax
  103088:	8b 55 0c             	mov    0xc(%ebp),%edx
  10308b:	31 d0                	xor    %edx,%eax
  10308d:	25 ff 0f 00 00       	and    $0xfff,%eax
  103092:	85 c0                	test   %eax,%eax
  103094:	74 24                	je     1030ba <boot_map_segment+0x3b>
  103096:	c7 44 24 0c 76 67 10 	movl   $0x106776,0xc(%esp)
  10309d:	00 
  10309e:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1030a5:	00 
  1030a6:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  1030ad:	00 
  1030ae:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1030b5:	e8 23 d3 ff ff       	call   1003dd <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1030ba:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1030c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030c4:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030c9:	89 c2                	mov    %eax,%edx
  1030cb:	8b 45 10             	mov    0x10(%ebp),%eax
  1030ce:	01 c2                	add    %eax,%edx
  1030d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030d3:	01 d0                	add    %edx,%eax
  1030d5:	83 e8 01             	sub    $0x1,%eax
  1030d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030de:	ba 00 00 00 00       	mov    $0x0,%edx
  1030e3:	f7 75 f0             	divl   -0x10(%ebp)
  1030e6:	89 d0                	mov    %edx,%eax
  1030e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030eb:	29 c2                	sub    %eax,%edx
  1030ed:	89 d0                	mov    %edx,%eax
  1030ef:	c1 e8 0c             	shr    $0xc,%eax
  1030f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103103:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103106:	8b 45 14             	mov    0x14(%ebp),%eax
  103109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10310c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10310f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103114:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103117:	eb 6b                	jmp    103184 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103119:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103120:	00 
  103121:	8b 45 0c             	mov    0xc(%ebp),%eax
  103124:	89 44 24 04          	mov    %eax,0x4(%esp)
  103128:	8b 45 08             	mov    0x8(%ebp),%eax
  10312b:	89 04 24             	mov    %eax,(%esp)
  10312e:	e8 cc 01 00 00       	call   1032ff <get_pte>
  103133:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103136:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10313a:	75 24                	jne    103160 <boot_map_segment+0xe1>
  10313c:	c7 44 24 0c a2 67 10 	movl   $0x1067a2,0xc(%esp)
  103143:	00 
  103144:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10314b:	00 
  10314c:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  103153:	00 
  103154:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10315b:	e8 7d d2 ff ff       	call   1003dd <__panic>
        *ptep = pa | PTE_P | perm;
  103160:	8b 45 18             	mov    0x18(%ebp),%eax
  103163:	8b 55 14             	mov    0x14(%ebp),%edx
  103166:	09 d0                	or     %edx,%eax
  103168:	83 c8 01             	or     $0x1,%eax
  10316b:	89 c2                	mov    %eax,%edx
  10316d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103170:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103172:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103176:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10317d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103184:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103188:	75 8f                	jne    103119 <boot_map_segment+0x9a>
    }
}
  10318a:	c9                   	leave  
  10318b:	c3                   	ret    

0010318c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10318c:	55                   	push   %ebp
  10318d:	89 e5                	mov    %esp,%ebp
  10318f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103199:	e8 22 fa ff ff       	call   102bc0 <alloc_pages>
  10319e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1031a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1031a5:	75 1c                	jne    1031c3 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1031a7:	c7 44 24 08 af 67 10 	movl   $0x1067af,0x8(%esp)
  1031ae:	00 
  1031af:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  1031b6:	00 
  1031b7:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1031be:	e8 1a d2 ff ff       	call   1003dd <__panic>
    }
    return page2kva(p);
  1031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031c6:	89 04 24             	mov    %eax,(%esp)
  1031c9:	e8 43 f7 ff ff       	call   102911 <page2kva>
}
  1031ce:	c9                   	leave  
  1031cf:	c3                   	ret    

001031d0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1031d0:	55                   	push   %ebp
  1031d1:	89 e5                	mov    %esp,%ebp
  1031d3:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1031d6:	e8 93 f9 ff ff       	call   102b6e <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1031db:	e8 75 fa ff ff       	call   102c55 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1031e0:	e8 7b 04 00 00       	call   103660 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
  1031e5:	e8 a2 ff ff ff       	call   10318c <boot_alloc_page>
  1031ea:	a3 c4 88 11 00       	mov    %eax,0x1188c4
    memset(boot_pgdir, 0, PGSIZE);
  1031ef:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1031f4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1031fb:	00 
  1031fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103203:	00 
  103204:	89 04 24             	mov    %eax,(%esp)
  103207:	e8 38 25 00 00       	call   105744 <memset>
    boot_cr3 = PADDR(boot_pgdir);
  10320c:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103211:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103214:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10321b:	77 23                	ja     103240 <pmm_init+0x70>
  10321d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103220:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103224:	c7 44 24 08 44 67 10 	movl   $0x106744,0x8(%esp)
  10322b:	00 
  10322c:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  103233:	00 
  103234:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10323b:	e8 9d d1 ff ff       	call   1003dd <__panic>
  103240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103243:	05 00 00 00 40       	add    $0x40000000,%eax
  103248:	a3 54 89 11 00       	mov    %eax,0x118954

    check_pgdir();
  10324d:	e8 2c 04 00 00       	call   10367e <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103252:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103257:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  10325d:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103262:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103265:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10326c:	77 23                	ja     103291 <pmm_init+0xc1>
  10326e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103271:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103275:	c7 44 24 08 44 67 10 	movl   $0x106744,0x8(%esp)
  10327c:	00 
  10327d:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  103284:	00 
  103285:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10328c:	e8 4c d1 ff ff       	call   1003dd <__panic>
  103291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103294:	05 00 00 00 40       	add    $0x40000000,%eax
  103299:	83 c8 03             	or     $0x3,%eax
  10329c:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10329e:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1032a3:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1032aa:	00 
  1032ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1032b2:	00 
  1032b3:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1032ba:	38 
  1032bb:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1032c2:	c0 
  1032c3:	89 04 24             	mov    %eax,(%esp)
  1032c6:	e8 b4 fd ff ff       	call   10307f <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
  1032cb:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1032d0:	8b 15 c4 88 11 00    	mov    0x1188c4,%edx
  1032d6:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
  1032dc:	89 10                	mov    %edx,(%eax)

    enable_paging();
  1032de:	e8 63 fd ff ff       	call   103046 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1032e3:	e8 97 f7 ff ff       	call   102a7f <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
  1032e8:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1032ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1032f3:	e8 21 0a 00 00       	call   103d19 <check_boot_pgdir>

    print_pgdir();
  1032f8:	e8 a9 0e 00 00       	call   1041a6 <print_pgdir>

}
  1032fd:	c9                   	leave  
  1032fe:	c3                   	ret    

001032ff <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1032ff:	55                   	push   %ebp
  103300:	89 e5                	mov    %esp,%ebp
  103302:	83 ec 38             	sub    $0x38,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pde=&pgdir[PDX(la)];
  103305:	8b 45 0c             	mov    0xc(%ebp),%eax
  103308:	c1 e8 16             	shr    $0x16,%eax
  10330b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103312:	8b 45 08             	mov    0x8(%ebp),%eax
  103315:	01 d0                	add    %edx,%eax
  103317:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!( * pde & PTE_P)) {
  10331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10331d:	8b 00                	mov    (%eax),%eax
  10331f:	83 e0 01             	and    $0x1,%eax
  103322:	85 c0                	test   %eax,%eax
  103324:	0f 85 bc 00 00 00    	jne    1033e6 <get_pte+0xe7>
        //如果页目录项不存在
        if (create) {
  10332a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10332e:	0f 84 ab 00 00 00    	je     1033df <get_pte+0xe0>
            //分配一个页给页表

            struct Page *page=alloc_page();//分配一个页
  103334:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10333b:	e8 80 f8 ff ff       	call   102bc0 <alloc_pages>
  103340:	89 45 f0             	mov    %eax,-0x10(%ebp)
            if(page==NULL){
  103343:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103347:	75 0a                	jne    103353 <get_pte+0x54>
                return 0;
  103349:	b8 00 00 00 00       	mov    $0x0,%eax
  10334e:	e9 ef 00 00 00       	jmp    103442 <get_pte+0x143>
            }
            set_page_ref(page,1);//表示该页已经被访问
  103353:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10335a:	00 
  10335b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10335e:	89 04 24             	mov    %eax,(%esp)
  103361:	e8 5f f6 ff ff       	call   1029c5 <set_page_ref>

            uintptr_t pa=page2pa(page);//获取页的物理地址
  103366:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103369:	89 04 24             	mov    %eax,(%esp)
  10336c:	e8 3b f5 ff ff       	call   1028ac <page2pa>
  103371:	89 45 ec             	mov    %eax,-0x14(%ebp)

            memset(KADDR(pa),0,PGSIZE);//分配的页的虚拟地址的初始化
  103374:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103377:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10337a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10337d:	c1 e8 0c             	shr    $0xc,%eax
  103380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103383:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103388:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10338b:	72 23                	jb     1033b0 <get_pte+0xb1>
  10338d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103394:	c7 44 24 08 a0 66 10 	movl   $0x1066a0,0x8(%esp)
  10339b:	00 
  10339c:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
  1033a3:	00 
  1033a4:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1033ab:	e8 2d d0 ff ff       	call   1003dd <__panic>
  1033b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033b3:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1033b8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1033bf:	00 
  1033c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1033c7:	00 
  1033c8:	89 04 24             	mov    %eax,(%esp)
  1033cb:	e8 74 23 00 00       	call   105744 <memset>

            *pde = pa |PTE_U|PTE_W|PTE_P;
  1033d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033d3:	83 c8 07             	or     $0x7,%eax
  1033d6:	89 c2                	mov    %eax,%edx
  1033d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033db:	89 10                	mov    %edx,(%eax)
  1033dd:	eb 07                	jmp    1033e6 <get_pte+0xe7>
            //要理解这步，就需要明白，刚刚分配的页还没有和页表项建立映射关系，这里将对应的页地址映射
            //并且完善了页表项的标志位，到这里，新分配的页就正式映射到了对应的页表项

        }
        else{
            return 0;//如果页目录项不存在且不能开辟，则返回0
  1033df:	b8 00 00 00 00       	mov    $0x0,%eax
  1033e4:	eb 5c                	jmp    103442 <get_pte+0x143>
     * 首先要确定PTE的起始地址: 通过在PDE的页目录项，先取得页表项的起始地址：
     * PDE_ADDR（输入一个页目录项，输出对应的物理地址） 转化
     * 再通过KADDR转化，得到PTE的起始地址，
     * 再根据之前得到的偏移（PTX(la)），就是二级页表项（PTE）的内核虚地址。
     */
    return &((pte_t *)KADDR(PDE_ADDR(*pde)))[PTX(la)];
  1033e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e9:	8b 00                	mov    (%eax),%eax
  1033eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1033f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1033f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033f6:	c1 e8 0c             	shr    $0xc,%eax
  1033f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1033fc:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103401:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103404:	72 23                	jb     103429 <get_pte+0x12a>
  103406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10340d:	c7 44 24 08 a0 66 10 	movl   $0x1066a0,0x8(%esp)
  103414:	00 
  103415:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
  10341c:	00 
  10341d:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103424:	e8 b4 cf ff ff       	call   1003dd <__panic>
  103429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10342c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103431:	8b 55 0c             	mov    0xc(%ebp),%edx
  103434:	c1 ea 0c             	shr    $0xc,%edx
  103437:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  10343d:	c1 e2 02             	shl    $0x2,%edx
  103440:	01 d0                	add    %edx,%eax
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  103442:	c9                   	leave  
  103443:	c3                   	ret    

00103444 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103444:	55                   	push   %ebp
  103445:	89 e5                	mov    %esp,%ebp
  103447:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10344a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103451:	00 
  103452:	8b 45 0c             	mov    0xc(%ebp),%eax
  103455:	89 44 24 04          	mov    %eax,0x4(%esp)
  103459:	8b 45 08             	mov    0x8(%ebp),%eax
  10345c:	89 04 24             	mov    %eax,(%esp)
  10345f:	e8 9b fe ff ff       	call   1032ff <get_pte>
  103464:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103467:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10346b:	74 08                	je     103475 <get_page+0x31>
        *ptep_store = ptep;
  10346d:	8b 45 10             	mov    0x10(%ebp),%eax
  103470:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103473:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103475:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103479:	74 1b                	je     103496 <get_page+0x52>
  10347b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10347e:	8b 00                	mov    (%eax),%eax
  103480:	83 e0 01             	and    $0x1,%eax
  103483:	85 c0                	test   %eax,%eax
  103485:	74 0f                	je     103496 <get_page+0x52>
        return pte2page(*ptep);
  103487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10348a:	8b 00                	mov    (%eax),%eax
  10348c:	89 04 24             	mov    %eax,(%esp)
  10348f:	e8 d1 f4 ff ff       	call   102965 <pte2page>
  103494:	eb 05                	jmp    10349b <get_page+0x57>
    }
    return NULL;
  103496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10349b:	c9                   	leave  
  10349c:	c3                   	ret    

0010349d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10349d:	55                   	push   %ebp
  10349e:	89 e5                	mov    %esp,%ebp
  1034a0:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if(*ptep & PTE_P){
  1034a3:	8b 45 10             	mov    0x10(%ebp),%eax
  1034a6:	8b 00                	mov    (%eax),%eax
  1034a8:	83 e0 01             	and    $0x1,%eax
  1034ab:	85 c0                	test   %eax,%eax
  1034ad:	74 54                	je     103503 <page_remove_pte+0x66>
        struct Page *page=pte2page(*ptep);//ptep代表页表项的物理地址,找到其对应的页
  1034af:	8b 45 10             	mov    0x10(%ebp),%eax
  1034b2:	8b 00                	mov    (%eax),%eax
  1034b4:	89 04 24             	mov    %eax,(%esp)
  1034b7:	e8 a9 f4 ff ff       	call   102965 <pte2page>
  1034bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        page_ref_dec(page);//引用次数减1
  1034bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034c2:	89 04 24             	mov    %eax,(%esp)
  1034c5:	e8 1f f5 ff ff       	call   1029e9 <page_ref_dec>
        if(page->ref==0){//如果引用次数为0了，说明页不存在于任何页表项，可以释放
  1034ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034cd:	8b 00                	mov    (%eax),%eax
  1034cf:	85 c0                	test   %eax,%eax
  1034d1:	75 13                	jne    1034e6 <page_remove_pte+0x49>
            free_page(page);//释放页面
  1034d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1034da:	00 
  1034db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034de:	89 04 24             	mov    %eax,(%esp)
  1034e1:	e8 12 f7 ff ff       	call   102bf8 <free_pages>
        }
        *ptep=0;//清除对应关系
  1034e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1034e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,la);
  1034ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1034f9:	89 04 24             	mov    %eax,(%esp)
  1034fc:	e8 02 01 00 00       	call   103603 <tlb_invalidate>
  103501:	eb 01                	jmp    103504 <page_remove_pte+0x67>
        //tlb表在页释放后，如果该页存在于tlb表，需要被更新释放
    }
    else{
        return ;
  103503:	90                   	nop
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }

#endif
}
  103504:	c9                   	leave  
  103505:	c3                   	ret    

00103506 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103506:	55                   	push   %ebp
  103507:	89 e5                	mov    %esp,%ebp
  103509:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10350c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103513:	00 
  103514:	8b 45 0c             	mov    0xc(%ebp),%eax
  103517:	89 44 24 04          	mov    %eax,0x4(%esp)
  10351b:	8b 45 08             	mov    0x8(%ebp),%eax
  10351e:	89 04 24             	mov    %eax,(%esp)
  103521:	e8 d9 fd ff ff       	call   1032ff <get_pte>
  103526:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103529:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10352d:	74 19                	je     103548 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10352f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103532:	89 44 24 08          	mov    %eax,0x8(%esp)
  103536:	8b 45 0c             	mov    0xc(%ebp),%eax
  103539:	89 44 24 04          	mov    %eax,0x4(%esp)
  10353d:	8b 45 08             	mov    0x8(%ebp),%eax
  103540:	89 04 24             	mov    %eax,(%esp)
  103543:	e8 55 ff ff ff       	call   10349d <page_remove_pte>
    }
}
  103548:	c9                   	leave  
  103549:	c3                   	ret    

0010354a <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  10354a:	55                   	push   %ebp
  10354b:	89 e5                	mov    %esp,%ebp
  10354d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  103550:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103557:	00 
  103558:	8b 45 10             	mov    0x10(%ebp),%eax
  10355b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10355f:	8b 45 08             	mov    0x8(%ebp),%eax
  103562:	89 04 24             	mov    %eax,(%esp)
  103565:	e8 95 fd ff ff       	call   1032ff <get_pte>
  10356a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10356d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103571:	75 0a                	jne    10357d <page_insert+0x33>
        return -E_NO_MEM;
  103573:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103578:	e9 84 00 00 00       	jmp    103601 <page_insert+0xb7>
    }
    page_ref_inc(page);
  10357d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103580:	89 04 24             	mov    %eax,(%esp)
  103583:	e8 4a f4 ff ff       	call   1029d2 <page_ref_inc>
    if (*ptep & PTE_P) {
  103588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10358b:	8b 00                	mov    (%eax),%eax
  10358d:	83 e0 01             	and    $0x1,%eax
  103590:	85 c0                	test   %eax,%eax
  103592:	74 3e                	je     1035d2 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  103594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103597:	8b 00                	mov    (%eax),%eax
  103599:	89 04 24             	mov    %eax,(%esp)
  10359c:	e8 c4 f3 ff ff       	call   102965 <pte2page>
  1035a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1035a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035a7:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1035aa:	75 0d                	jne    1035b9 <page_insert+0x6f>
            page_ref_dec(page);
  1035ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035af:	89 04 24             	mov    %eax,(%esp)
  1035b2:	e8 32 f4 ff ff       	call   1029e9 <page_ref_dec>
  1035b7:	eb 19                	jmp    1035d2 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1035b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1035c0:	8b 45 10             	mov    0x10(%ebp),%eax
  1035c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ca:	89 04 24             	mov    %eax,(%esp)
  1035cd:	e8 cb fe ff ff       	call   10349d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1035d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035d5:	89 04 24             	mov    %eax,(%esp)
  1035d8:	e8 cf f2 ff ff       	call   1028ac <page2pa>
  1035dd:	0b 45 14             	or     0x14(%ebp),%eax
  1035e0:	83 c8 01             	or     $0x1,%eax
  1035e3:	89 c2                	mov    %eax,%edx
  1035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035e8:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1035ea:	8b 45 10             	mov    0x10(%ebp),%eax
  1035ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1035f4:	89 04 24             	mov    %eax,(%esp)
  1035f7:	e8 07 00 00 00       	call   103603 <tlb_invalidate>
    return 0;
  1035fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103601:	c9                   	leave  
  103602:	c3                   	ret    

00103603 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103603:	55                   	push   %ebp
  103604:	89 e5                	mov    %esp,%ebp
  103606:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103609:	0f 20 d8             	mov    %cr3,%eax
  10360c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10360f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  103612:	89 c2                	mov    %eax,%edx
  103614:	8b 45 08             	mov    0x8(%ebp),%eax
  103617:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10361a:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103621:	77 23                	ja     103646 <tlb_invalidate+0x43>
  103623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103626:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10362a:	c7 44 24 08 44 67 10 	movl   $0x106744,0x8(%esp)
  103631:	00 
  103632:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103639:	00 
  10363a:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103641:	e8 97 cd ff ff       	call   1003dd <__panic>
  103646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103649:	05 00 00 00 40       	add    $0x40000000,%eax
  10364e:	39 c2                	cmp    %eax,%edx
  103650:	75 0c                	jne    10365e <tlb_invalidate+0x5b>
        invlpg((void *)la);
  103652:	8b 45 0c             	mov    0xc(%ebp),%eax
  103655:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10365b:	0f 01 38             	invlpg (%eax)
    }
}
  10365e:	c9                   	leave  
  10365f:	c3                   	ret    

00103660 <check_alloc_page>:

static void
check_alloc_page(void) {
  103660:	55                   	push   %ebp
  103661:	89 e5                	mov    %esp,%ebp
  103663:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103666:	a1 50 89 11 00       	mov    0x118950,%eax
  10366b:	8b 40 18             	mov    0x18(%eax),%eax
  10366e:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103670:	c7 04 24 c8 67 10 00 	movl   $0x1067c8,(%esp)
  103677:	e8 0a cc ff ff       	call   100286 <cprintf>
}
  10367c:	c9                   	leave  
  10367d:	c3                   	ret    

0010367e <check_pgdir>:

static void
check_pgdir(void) {
  10367e:	55                   	push   %ebp
  10367f:	89 e5                	mov    %esp,%ebp
  103681:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  103684:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103689:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10368e:	76 24                	jbe    1036b4 <check_pgdir+0x36>
  103690:	c7 44 24 0c e7 67 10 	movl   $0x1067e7,0xc(%esp)
  103697:	00 
  103698:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10369f:	00 
  1036a0:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  1036a7:	00 
  1036a8:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1036af:	e8 29 cd ff ff       	call   1003dd <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1036b4:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1036b9:	85 c0                	test   %eax,%eax
  1036bb:	74 0e                	je     1036cb <check_pgdir+0x4d>
  1036bd:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1036c2:	25 ff 0f 00 00       	and    $0xfff,%eax
  1036c7:	85 c0                	test   %eax,%eax
  1036c9:	74 24                	je     1036ef <check_pgdir+0x71>
  1036cb:	c7 44 24 0c 04 68 10 	movl   $0x106804,0xc(%esp)
  1036d2:	00 
  1036d3:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1036da:	00 
  1036db:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  1036e2:	00 
  1036e3:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1036ea:	e8 ee cc ff ff       	call   1003dd <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1036ef:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1036f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036fb:	00 
  1036fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103703:	00 
  103704:	89 04 24             	mov    %eax,(%esp)
  103707:	e8 38 fd ff ff       	call   103444 <get_page>
  10370c:	85 c0                	test   %eax,%eax
  10370e:	74 24                	je     103734 <check_pgdir+0xb6>
  103710:	c7 44 24 0c 3c 68 10 	movl   $0x10683c,0xc(%esp)
  103717:	00 
  103718:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10371f:	00 
  103720:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  103727:	00 
  103728:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10372f:	e8 a9 cc ff ff       	call   1003dd <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103734:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10373b:	e8 80 f4 ff ff       	call   102bc0 <alloc_pages>
  103740:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103743:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103748:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10374f:	00 
  103750:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103757:	00 
  103758:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10375b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10375f:	89 04 24             	mov    %eax,(%esp)
  103762:	e8 e3 fd ff ff       	call   10354a <page_insert>
  103767:	85 c0                	test   %eax,%eax
  103769:	74 24                	je     10378f <check_pgdir+0x111>
  10376b:	c7 44 24 0c 64 68 10 	movl   $0x106864,0xc(%esp)
  103772:	00 
  103773:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10377a:	00 
  10377b:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103782:	00 
  103783:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10378a:	e8 4e cc ff ff       	call   1003dd <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  10378f:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103794:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10379b:	00 
  10379c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1037a3:	00 
  1037a4:	89 04 24             	mov    %eax,(%esp)
  1037a7:	e8 53 fb ff ff       	call   1032ff <get_pte>
  1037ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1037b3:	75 24                	jne    1037d9 <check_pgdir+0x15b>
  1037b5:	c7 44 24 0c 90 68 10 	movl   $0x106890,0xc(%esp)
  1037bc:	00 
  1037bd:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1037c4:	00 
  1037c5:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  1037cc:	00 
  1037cd:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1037d4:	e8 04 cc ff ff       	call   1003dd <__panic>
    assert(pte2page(*ptep) == p1);
  1037d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037dc:	8b 00                	mov    (%eax),%eax
  1037de:	89 04 24             	mov    %eax,(%esp)
  1037e1:	e8 7f f1 ff ff       	call   102965 <pte2page>
  1037e6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1037e9:	74 24                	je     10380f <check_pgdir+0x191>
  1037eb:	c7 44 24 0c bd 68 10 	movl   $0x1068bd,0xc(%esp)
  1037f2:	00 
  1037f3:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1037fa:	00 
  1037fb:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103802:	00 
  103803:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10380a:	e8 ce cb ff ff       	call   1003dd <__panic>
    assert(page_ref(p1) == 1);
  10380f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103812:	89 04 24             	mov    %eax,(%esp)
  103815:	e8 a1 f1 ff ff       	call   1029bb <page_ref>
  10381a:	83 f8 01             	cmp    $0x1,%eax
  10381d:	74 24                	je     103843 <check_pgdir+0x1c5>
  10381f:	c7 44 24 0c d3 68 10 	movl   $0x1068d3,0xc(%esp)
  103826:	00 
  103827:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10382e:	00 
  10382f:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  103836:	00 
  103837:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10383e:	e8 9a cb ff ff       	call   1003dd <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103843:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103848:	8b 00                	mov    (%eax),%eax
  10384a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10384f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103852:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103855:	c1 e8 0c             	shr    $0xc,%eax
  103858:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10385b:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103860:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103863:	72 23                	jb     103888 <check_pgdir+0x20a>
  103865:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103868:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10386c:	c7 44 24 08 a0 66 10 	movl   $0x1066a0,0x8(%esp)
  103873:	00 
  103874:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  10387b:	00 
  10387c:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103883:	e8 55 cb ff ff       	call   1003dd <__panic>
  103888:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10388b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103890:	83 c0 04             	add    $0x4,%eax
  103893:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103896:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10389b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038a2:	00 
  1038a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1038aa:	00 
  1038ab:	89 04 24             	mov    %eax,(%esp)
  1038ae:	e8 4c fa ff ff       	call   1032ff <get_pte>
  1038b3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1038b6:	74 24                	je     1038dc <check_pgdir+0x25e>
  1038b8:	c7 44 24 0c e8 68 10 	movl   $0x1068e8,0xc(%esp)
  1038bf:	00 
  1038c0:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1038c7:	00 
  1038c8:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  1038cf:	00 
  1038d0:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1038d7:	e8 01 cb ff ff       	call   1003dd <__panic>

    p2 = alloc_page();
  1038dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038e3:	e8 d8 f2 ff ff       	call   102bc0 <alloc_pages>
  1038e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1038eb:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1038f0:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1038f7:	00 
  1038f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1038ff:	00 
  103900:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103903:	89 54 24 04          	mov    %edx,0x4(%esp)
  103907:	89 04 24             	mov    %eax,(%esp)
  10390a:	e8 3b fc ff ff       	call   10354a <page_insert>
  10390f:	85 c0                	test   %eax,%eax
  103911:	74 24                	je     103937 <check_pgdir+0x2b9>
  103913:	c7 44 24 0c 10 69 10 	movl   $0x106910,0xc(%esp)
  10391a:	00 
  10391b:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103922:	00 
  103923:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  10392a:	00 
  10392b:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103932:	e8 a6 ca ff ff       	call   1003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103937:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10393c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103943:	00 
  103944:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10394b:	00 
  10394c:	89 04 24             	mov    %eax,(%esp)
  10394f:	e8 ab f9 ff ff       	call   1032ff <get_pte>
  103954:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103957:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10395b:	75 24                	jne    103981 <check_pgdir+0x303>
  10395d:	c7 44 24 0c 48 69 10 	movl   $0x106948,0xc(%esp)
  103964:	00 
  103965:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10396c:	00 
  10396d:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  103974:	00 
  103975:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10397c:	e8 5c ca ff ff       	call   1003dd <__panic>
    assert(*ptep & PTE_U);
  103981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103984:	8b 00                	mov    (%eax),%eax
  103986:	83 e0 04             	and    $0x4,%eax
  103989:	85 c0                	test   %eax,%eax
  10398b:	75 24                	jne    1039b1 <check_pgdir+0x333>
  10398d:	c7 44 24 0c 78 69 10 	movl   $0x106978,0xc(%esp)
  103994:	00 
  103995:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  10399c:	00 
  10399d:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  1039a4:	00 
  1039a5:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1039ac:	e8 2c ca ff ff       	call   1003dd <__panic>
    assert(*ptep & PTE_W);
  1039b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1039b4:	8b 00                	mov    (%eax),%eax
  1039b6:	83 e0 02             	and    $0x2,%eax
  1039b9:	85 c0                	test   %eax,%eax
  1039bb:	75 24                	jne    1039e1 <check_pgdir+0x363>
  1039bd:	c7 44 24 0c 86 69 10 	movl   $0x106986,0xc(%esp)
  1039c4:	00 
  1039c5:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1039cc:	00 
  1039cd:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  1039d4:	00 
  1039d5:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1039dc:	e8 fc c9 ff ff       	call   1003dd <__panic>
    assert(boot_pgdir[0] & PTE_U);
  1039e1:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1039e6:	8b 00                	mov    (%eax),%eax
  1039e8:	83 e0 04             	and    $0x4,%eax
  1039eb:	85 c0                	test   %eax,%eax
  1039ed:	75 24                	jne    103a13 <check_pgdir+0x395>
  1039ef:	c7 44 24 0c 94 69 10 	movl   $0x106994,0xc(%esp)
  1039f6:	00 
  1039f7:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  1039fe:	00 
  1039ff:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  103a06:	00 
  103a07:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103a0e:	e8 ca c9 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 1);
  103a13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a16:	89 04 24             	mov    %eax,(%esp)
  103a19:	e8 9d ef ff ff       	call   1029bb <page_ref>
  103a1e:	83 f8 01             	cmp    $0x1,%eax
  103a21:	74 24                	je     103a47 <check_pgdir+0x3c9>
  103a23:	c7 44 24 0c aa 69 10 	movl   $0x1069aa,0xc(%esp)
  103a2a:	00 
  103a2b:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103a32:	00 
  103a33:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  103a3a:	00 
  103a3b:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103a42:	e8 96 c9 ff ff       	call   1003dd <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103a47:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103a4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103a53:	00 
  103a54:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103a5b:	00 
  103a5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103a5f:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a63:	89 04 24             	mov    %eax,(%esp)
  103a66:	e8 df fa ff ff       	call   10354a <page_insert>
  103a6b:	85 c0                	test   %eax,%eax
  103a6d:	74 24                	je     103a93 <check_pgdir+0x415>
  103a6f:	c7 44 24 0c bc 69 10 	movl   $0x1069bc,0xc(%esp)
  103a76:	00 
  103a77:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103a7e:	00 
  103a7f:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  103a86:	00 
  103a87:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103a8e:	e8 4a c9 ff ff       	call   1003dd <__panic>
    assert(page_ref(p1) == 2);
  103a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a96:	89 04 24             	mov    %eax,(%esp)
  103a99:	e8 1d ef ff ff       	call   1029bb <page_ref>
  103a9e:	83 f8 02             	cmp    $0x2,%eax
  103aa1:	74 24                	je     103ac7 <check_pgdir+0x449>
  103aa3:	c7 44 24 0c e8 69 10 	movl   $0x1069e8,0xc(%esp)
  103aaa:	00 
  103aab:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103ab2:	00 
  103ab3:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  103aba:	00 
  103abb:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103ac2:	e8 16 c9 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103aca:	89 04 24             	mov    %eax,(%esp)
  103acd:	e8 e9 ee ff ff       	call   1029bb <page_ref>
  103ad2:	85 c0                	test   %eax,%eax
  103ad4:	74 24                	je     103afa <check_pgdir+0x47c>
  103ad6:	c7 44 24 0c fa 69 10 	movl   $0x1069fa,0xc(%esp)
  103add:	00 
  103ade:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103ae5:	00 
  103ae6:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  103aed:	00 
  103aee:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103af5:	e8 e3 c8 ff ff       	call   1003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103afa:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103b06:	00 
  103b07:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b0e:	00 
  103b0f:	89 04 24             	mov    %eax,(%esp)
  103b12:	e8 e8 f7 ff ff       	call   1032ff <get_pte>
  103b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103b1e:	75 24                	jne    103b44 <check_pgdir+0x4c6>
  103b20:	c7 44 24 0c 48 69 10 	movl   $0x106948,0xc(%esp)
  103b27:	00 
  103b28:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103b2f:	00 
  103b30:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  103b37:	00 
  103b38:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103b3f:	e8 99 c8 ff ff       	call   1003dd <__panic>
    assert(pte2page(*ptep) == p1);
  103b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b47:	8b 00                	mov    (%eax),%eax
  103b49:	89 04 24             	mov    %eax,(%esp)
  103b4c:	e8 14 ee ff ff       	call   102965 <pte2page>
  103b51:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103b54:	74 24                	je     103b7a <check_pgdir+0x4fc>
  103b56:	c7 44 24 0c bd 68 10 	movl   $0x1068bd,0xc(%esp)
  103b5d:	00 
  103b5e:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103b65:	00 
  103b66:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
  103b6d:	00 
  103b6e:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103b75:	e8 63 c8 ff ff       	call   1003dd <__panic>
    assert((*ptep & PTE_U) == 0);
  103b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b7d:	8b 00                	mov    (%eax),%eax
  103b7f:	83 e0 04             	and    $0x4,%eax
  103b82:	85 c0                	test   %eax,%eax
  103b84:	74 24                	je     103baa <check_pgdir+0x52c>
  103b86:	c7 44 24 0c 0c 6a 10 	movl   $0x106a0c,0xc(%esp)
  103b8d:	00 
  103b8e:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103b95:	00 
  103b96:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  103b9d:	00 
  103b9e:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103ba5:	e8 33 c8 ff ff       	call   1003dd <__panic>

    page_remove(boot_pgdir, 0x0);
  103baa:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103baf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103bb6:	00 
  103bb7:	89 04 24             	mov    %eax,(%esp)
  103bba:	e8 47 f9 ff ff       	call   103506 <page_remove>
    assert(page_ref(p1) == 1);
  103bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bc2:	89 04 24             	mov    %eax,(%esp)
  103bc5:	e8 f1 ed ff ff       	call   1029bb <page_ref>
  103bca:	83 f8 01             	cmp    $0x1,%eax
  103bcd:	74 24                	je     103bf3 <check_pgdir+0x575>
  103bcf:	c7 44 24 0c d3 68 10 	movl   $0x1068d3,0xc(%esp)
  103bd6:	00 
  103bd7:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103bde:	00 
  103bdf:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  103be6:	00 
  103be7:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103bee:	e8 ea c7 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bf6:	89 04 24             	mov    %eax,(%esp)
  103bf9:	e8 bd ed ff ff       	call   1029bb <page_ref>
  103bfe:	85 c0                	test   %eax,%eax
  103c00:	74 24                	je     103c26 <check_pgdir+0x5a8>
  103c02:	c7 44 24 0c fa 69 10 	movl   $0x1069fa,0xc(%esp)
  103c09:	00 
  103c0a:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103c11:	00 
  103c12:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
  103c19:	00 
  103c1a:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103c21:	e8 b7 c7 ff ff       	call   1003dd <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103c26:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103c2b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103c32:	00 
  103c33:	89 04 24             	mov    %eax,(%esp)
  103c36:	e8 cb f8 ff ff       	call   103506 <page_remove>
    assert(page_ref(p1) == 0);
  103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c3e:	89 04 24             	mov    %eax,(%esp)
  103c41:	e8 75 ed ff ff       	call   1029bb <page_ref>
  103c46:	85 c0                	test   %eax,%eax
  103c48:	74 24                	je     103c6e <check_pgdir+0x5f0>
  103c4a:	c7 44 24 0c 21 6a 10 	movl   $0x106a21,0xc(%esp)
  103c51:	00 
  103c52:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103c59:	00 
  103c5a:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
  103c61:	00 
  103c62:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103c69:	e8 6f c7 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c71:	89 04 24             	mov    %eax,(%esp)
  103c74:	e8 42 ed ff ff       	call   1029bb <page_ref>
  103c79:	85 c0                	test   %eax,%eax
  103c7b:	74 24                	je     103ca1 <check_pgdir+0x623>
  103c7d:	c7 44 24 0c fa 69 10 	movl   $0x1069fa,0xc(%esp)
  103c84:	00 
  103c85:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103c8c:	00 
  103c8d:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
  103c94:	00 
  103c95:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103c9c:	e8 3c c7 ff ff       	call   1003dd <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103ca1:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103ca6:	8b 00                	mov    (%eax),%eax
  103ca8:	89 04 24             	mov    %eax,(%esp)
  103cab:	e8 f3 ec ff ff       	call   1029a3 <pde2page>
  103cb0:	89 04 24             	mov    %eax,(%esp)
  103cb3:	e8 03 ed ff ff       	call   1029bb <page_ref>
  103cb8:	83 f8 01             	cmp    $0x1,%eax
  103cbb:	74 24                	je     103ce1 <check_pgdir+0x663>
  103cbd:	c7 44 24 0c 34 6a 10 	movl   $0x106a34,0xc(%esp)
  103cc4:	00 
  103cc5:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103ccc:	00 
  103ccd:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
  103cd4:	00 
  103cd5:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103cdc:	e8 fc c6 ff ff       	call   1003dd <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103ce1:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103ce6:	8b 00                	mov    (%eax),%eax
  103ce8:	89 04 24             	mov    %eax,(%esp)
  103ceb:	e8 b3 ec ff ff       	call   1029a3 <pde2page>
  103cf0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103cf7:	00 
  103cf8:	89 04 24             	mov    %eax,(%esp)
  103cfb:	e8 f8 ee ff ff       	call   102bf8 <free_pages>
    boot_pgdir[0] = 0;
  103d00:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103d05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103d0b:	c7 04 24 5b 6a 10 00 	movl   $0x106a5b,(%esp)
  103d12:	e8 6f c5 ff ff       	call   100286 <cprintf>
}
  103d17:	c9                   	leave  
  103d18:	c3                   	ret    

00103d19 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103d19:	55                   	push   %ebp
  103d1a:	89 e5                	mov    %esp,%ebp
  103d1c:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103d1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103d26:	e9 ca 00 00 00       	jmp    103df5 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d34:	c1 e8 0c             	shr    $0xc,%eax
  103d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103d3a:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103d3f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103d42:	72 23                	jb     103d67 <check_boot_pgdir+0x4e>
  103d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d4b:	c7 44 24 08 a0 66 10 	movl   $0x1066a0,0x8(%esp)
  103d52:	00 
  103d53:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
  103d5a:	00 
  103d5b:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103d62:	e8 76 c6 ff ff       	call   1003dd <__panic>
  103d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d6a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103d6f:	89 c2                	mov    %eax,%edx
  103d71:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103d76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103d7d:	00 
  103d7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d82:	89 04 24             	mov    %eax,(%esp)
  103d85:	e8 75 f5 ff ff       	call   1032ff <get_pte>
  103d8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103d8d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103d91:	75 24                	jne    103db7 <check_boot_pgdir+0x9e>
  103d93:	c7 44 24 0c 78 6a 10 	movl   $0x106a78,0xc(%esp)
  103d9a:	00 
  103d9b:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103da2:	00 
  103da3:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
  103daa:	00 
  103dab:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103db2:	e8 26 c6 ff ff       	call   1003dd <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103db7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103dba:	8b 00                	mov    (%eax),%eax
  103dbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103dc1:	89 c2                	mov    %eax,%edx
  103dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dc6:	39 c2                	cmp    %eax,%edx
  103dc8:	74 24                	je     103dee <check_boot_pgdir+0xd5>
  103dca:	c7 44 24 0c b5 6a 10 	movl   $0x106ab5,0xc(%esp)
  103dd1:	00 
  103dd2:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103dd9:	00 
  103dda:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
  103de1:	00 
  103de2:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103de9:	e8 ef c5 ff ff       	call   1003dd <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103dee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103df5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103df8:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103dfd:	39 c2                	cmp    %eax,%edx
  103dff:	0f 82 26 ff ff ff    	jb     103d2b <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103e05:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103e0a:	05 ac 0f 00 00       	add    $0xfac,%eax
  103e0f:	8b 00                	mov    (%eax),%eax
  103e11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103e16:	89 c2                	mov    %eax,%edx
  103e18:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103e1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103e20:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103e27:	77 23                	ja     103e4c <check_boot_pgdir+0x133>
  103e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103e30:	c7 44 24 08 44 67 10 	movl   $0x106744,0x8(%esp)
  103e37:	00 
  103e38:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
  103e3f:	00 
  103e40:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103e47:	e8 91 c5 ff ff       	call   1003dd <__panic>
  103e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e4f:	05 00 00 00 40       	add    $0x40000000,%eax
  103e54:	39 c2                	cmp    %eax,%edx
  103e56:	74 24                	je     103e7c <check_boot_pgdir+0x163>
  103e58:	c7 44 24 0c cc 6a 10 	movl   $0x106acc,0xc(%esp)
  103e5f:	00 
  103e60:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103e67:	00 
  103e68:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
  103e6f:	00 
  103e70:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103e77:	e8 61 c5 ff ff       	call   1003dd <__panic>

    assert(boot_pgdir[0] == 0);
  103e7c:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103e81:	8b 00                	mov    (%eax),%eax
  103e83:	85 c0                	test   %eax,%eax
  103e85:	74 24                	je     103eab <check_boot_pgdir+0x192>
  103e87:	c7 44 24 0c 00 6b 10 	movl   $0x106b00,0xc(%esp)
  103e8e:	00 
  103e8f:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103e96:	00 
  103e97:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
  103e9e:	00 
  103e9f:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103ea6:	e8 32 c5 ff ff       	call   1003dd <__panic>

    struct Page *p;
    p = alloc_page();
  103eab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103eb2:	e8 09 ed ff ff       	call   102bc0 <alloc_pages>
  103eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103eba:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103ebf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103ec6:	00 
  103ec7:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103ece:	00 
  103ecf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103ed2:	89 54 24 04          	mov    %edx,0x4(%esp)
  103ed6:	89 04 24             	mov    %eax,(%esp)
  103ed9:	e8 6c f6 ff ff       	call   10354a <page_insert>
  103ede:	85 c0                	test   %eax,%eax
  103ee0:	74 24                	je     103f06 <check_boot_pgdir+0x1ed>
  103ee2:	c7 44 24 0c 14 6b 10 	movl   $0x106b14,0xc(%esp)
  103ee9:	00 
  103eea:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103ef1:	00 
  103ef2:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
  103ef9:	00 
  103efa:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103f01:	e8 d7 c4 ff ff       	call   1003dd <__panic>
    assert(page_ref(p) == 1);
  103f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f09:	89 04 24             	mov    %eax,(%esp)
  103f0c:	e8 aa ea ff ff       	call   1029bb <page_ref>
  103f11:	83 f8 01             	cmp    $0x1,%eax
  103f14:	74 24                	je     103f3a <check_boot_pgdir+0x221>
  103f16:	c7 44 24 0c 42 6b 10 	movl   $0x106b42,0xc(%esp)
  103f1d:	00 
  103f1e:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103f25:	00 
  103f26:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
  103f2d:	00 
  103f2e:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103f35:	e8 a3 c4 ff ff       	call   1003dd <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103f3a:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103f3f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103f46:	00 
  103f47:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103f4e:	00 
  103f4f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103f52:	89 54 24 04          	mov    %edx,0x4(%esp)
  103f56:	89 04 24             	mov    %eax,(%esp)
  103f59:	e8 ec f5 ff ff       	call   10354a <page_insert>
  103f5e:	85 c0                	test   %eax,%eax
  103f60:	74 24                	je     103f86 <check_boot_pgdir+0x26d>
  103f62:	c7 44 24 0c 54 6b 10 	movl   $0x106b54,0xc(%esp)
  103f69:	00 
  103f6a:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103f71:	00 
  103f72:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
  103f79:	00 
  103f7a:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103f81:	e8 57 c4 ff ff       	call   1003dd <__panic>
    assert(page_ref(p) == 2);
  103f86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f89:	89 04 24             	mov    %eax,(%esp)
  103f8c:	e8 2a ea ff ff       	call   1029bb <page_ref>
  103f91:	83 f8 02             	cmp    $0x2,%eax
  103f94:	74 24                	je     103fba <check_boot_pgdir+0x2a1>
  103f96:	c7 44 24 0c 8b 6b 10 	movl   $0x106b8b,0xc(%esp)
  103f9d:	00 
  103f9e:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103fa5:	00 
  103fa6:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
  103fad:	00 
  103fae:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  103fb5:	e8 23 c4 ff ff       	call   1003dd <__panic>

    const char *str = "ucore: Hello world!!";
  103fba:	c7 45 dc 9c 6b 10 00 	movl   $0x106b9c,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103fc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  103fc8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103fcf:	e8 99 14 00 00       	call   10546d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103fd4:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103fdb:	00 
  103fdc:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103fe3:	e8 fe 14 00 00       	call   1054e6 <strcmp>
  103fe8:	85 c0                	test   %eax,%eax
  103fea:	74 24                	je     104010 <check_boot_pgdir+0x2f7>
  103fec:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  103ff3:	00 
  103ff4:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  103ffb:	00 
  103ffc:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
  104003:	00 
  104004:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  10400b:	e8 cd c3 ff ff       	call   1003dd <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  104010:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104013:	89 04 24             	mov    %eax,(%esp)
  104016:	e8 f6 e8 ff ff       	call   102911 <page2kva>
  10401b:	05 00 01 00 00       	add    $0x100,%eax
  104020:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  104023:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10402a:	e8 e6 13 00 00       	call   105415 <strlen>
  10402f:	85 c0                	test   %eax,%eax
  104031:	74 24                	je     104057 <check_boot_pgdir+0x33e>
  104033:	c7 44 24 0c ec 6b 10 	movl   $0x106bec,0xc(%esp)
  10403a:	00 
  10403b:	c7 44 24 08 8d 67 10 	movl   $0x10678d,0x8(%esp)
  104042:	00 
  104043:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
  10404a:	00 
  10404b:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  104052:	e8 86 c3 ff ff       	call   1003dd <__panic>

    free_page(p);
  104057:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10405e:	00 
  10405f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104062:	89 04 24             	mov    %eax,(%esp)
  104065:	e8 8e eb ff ff       	call   102bf8 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10406a:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10406f:	8b 00                	mov    (%eax),%eax
  104071:	89 04 24             	mov    %eax,(%esp)
  104074:	e8 2a e9 ff ff       	call   1029a3 <pde2page>
  104079:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104080:	00 
  104081:	89 04 24             	mov    %eax,(%esp)
  104084:	e8 6f eb ff ff       	call   102bf8 <free_pages>
    boot_pgdir[0] = 0;
  104089:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10408e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104094:	c7 04 24 10 6c 10 00 	movl   $0x106c10,(%esp)
  10409b:	e8 e6 c1 ff ff       	call   100286 <cprintf>
}
  1040a0:	c9                   	leave  
  1040a1:	c3                   	ret    

001040a2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1040a2:	55                   	push   %ebp
  1040a3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1040a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1040a8:	83 e0 04             	and    $0x4,%eax
  1040ab:	85 c0                	test   %eax,%eax
  1040ad:	74 07                	je     1040b6 <perm2str+0x14>
  1040af:	b8 75 00 00 00       	mov    $0x75,%eax
  1040b4:	eb 05                	jmp    1040bb <perm2str+0x19>
  1040b6:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1040bb:	a2 48 89 11 00       	mov    %al,0x118948
    str[1] = 'r';
  1040c0:	c6 05 49 89 11 00 72 	movb   $0x72,0x118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1040c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1040ca:	83 e0 02             	and    $0x2,%eax
  1040cd:	85 c0                	test   %eax,%eax
  1040cf:	74 07                	je     1040d8 <perm2str+0x36>
  1040d1:	b8 77 00 00 00       	mov    $0x77,%eax
  1040d6:	eb 05                	jmp    1040dd <perm2str+0x3b>
  1040d8:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1040dd:	a2 4a 89 11 00       	mov    %al,0x11894a
    str[3] = '\0';
  1040e2:	c6 05 4b 89 11 00 00 	movb   $0x0,0x11894b
    return str;
  1040e9:	b8 48 89 11 00       	mov    $0x118948,%eax
}
  1040ee:	5d                   	pop    %ebp
  1040ef:	c3                   	ret    

001040f0 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1040f0:	55                   	push   %ebp
  1040f1:	89 e5                	mov    %esp,%ebp
  1040f3:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1040f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1040f9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1040fc:	72 0a                	jb     104108 <get_pgtable_items+0x18>
        return 0;
  1040fe:	b8 00 00 00 00       	mov    $0x0,%eax
  104103:	e9 9c 00 00 00       	jmp    1041a4 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  104108:	eb 04                	jmp    10410e <get_pgtable_items+0x1e>
        start ++;
  10410a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10410e:	8b 45 10             	mov    0x10(%ebp),%eax
  104111:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104114:	73 18                	jae    10412e <get_pgtable_items+0x3e>
  104116:	8b 45 10             	mov    0x10(%ebp),%eax
  104119:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104120:	8b 45 14             	mov    0x14(%ebp),%eax
  104123:	01 d0                	add    %edx,%eax
  104125:	8b 00                	mov    (%eax),%eax
  104127:	83 e0 01             	and    $0x1,%eax
  10412a:	85 c0                	test   %eax,%eax
  10412c:	74 dc                	je     10410a <get_pgtable_items+0x1a>
    }
    if (start < right) {
  10412e:	8b 45 10             	mov    0x10(%ebp),%eax
  104131:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104134:	73 69                	jae    10419f <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  104136:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10413a:	74 08                	je     104144 <get_pgtable_items+0x54>
            *left_store = start;
  10413c:	8b 45 18             	mov    0x18(%ebp),%eax
  10413f:	8b 55 10             	mov    0x10(%ebp),%edx
  104142:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104144:	8b 45 10             	mov    0x10(%ebp),%eax
  104147:	8d 50 01             	lea    0x1(%eax),%edx
  10414a:	89 55 10             	mov    %edx,0x10(%ebp)
  10414d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104154:	8b 45 14             	mov    0x14(%ebp),%eax
  104157:	01 d0                	add    %edx,%eax
  104159:	8b 00                	mov    (%eax),%eax
  10415b:	83 e0 07             	and    $0x7,%eax
  10415e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104161:	eb 04                	jmp    104167 <get_pgtable_items+0x77>
            start ++;
  104163:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104167:	8b 45 10             	mov    0x10(%ebp),%eax
  10416a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10416d:	73 1d                	jae    10418c <get_pgtable_items+0x9c>
  10416f:	8b 45 10             	mov    0x10(%ebp),%eax
  104172:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104179:	8b 45 14             	mov    0x14(%ebp),%eax
  10417c:	01 d0                	add    %edx,%eax
  10417e:	8b 00                	mov    (%eax),%eax
  104180:	83 e0 07             	and    $0x7,%eax
  104183:	89 c2                	mov    %eax,%edx
  104185:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104188:	39 c2                	cmp    %eax,%edx
  10418a:	74 d7                	je     104163 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
  10418c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104190:	74 08                	je     10419a <get_pgtable_items+0xaa>
            *right_store = start;
  104192:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104195:	8b 55 10             	mov    0x10(%ebp),%edx
  104198:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10419a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10419d:	eb 05                	jmp    1041a4 <get_pgtable_items+0xb4>
    }
    return 0;
  10419f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1041a4:	c9                   	leave  
  1041a5:	c3                   	ret    

001041a6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1041a6:	55                   	push   %ebp
  1041a7:	89 e5                	mov    %esp,%ebp
  1041a9:	57                   	push   %edi
  1041aa:	56                   	push   %esi
  1041ab:	53                   	push   %ebx
  1041ac:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1041af:	c7 04 24 30 6c 10 00 	movl   $0x106c30,(%esp)
  1041b6:	e8 cb c0 ff ff       	call   100286 <cprintf>
    size_t left, right = 0, perm;
  1041bb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1041c2:	e9 fa 00 00 00       	jmp    1042c1 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1041c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041ca:	89 04 24             	mov    %eax,(%esp)
  1041cd:	e8 d0 fe ff ff       	call   1040a2 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1041d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1041d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041d8:	29 d1                	sub    %edx,%ecx
  1041da:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1041dc:	89 d6                	mov    %edx,%esi
  1041de:	c1 e6 16             	shl    $0x16,%esi
  1041e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041e4:	89 d3                	mov    %edx,%ebx
  1041e6:	c1 e3 16             	shl    $0x16,%ebx
  1041e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041ec:	89 d1                	mov    %edx,%ecx
  1041ee:	c1 e1 16             	shl    $0x16,%ecx
  1041f1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1041f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041f7:	29 d7                	sub    %edx,%edi
  1041f9:	89 fa                	mov    %edi,%edx
  1041fb:	89 44 24 14          	mov    %eax,0x14(%esp)
  1041ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  104203:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104207:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10420b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10420f:	c7 04 24 61 6c 10 00 	movl   $0x106c61,(%esp)
  104216:	e8 6b c0 ff ff       	call   100286 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10421b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10421e:	c1 e0 0a             	shl    $0xa,%eax
  104221:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104224:	eb 54                	jmp    10427a <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104229:	89 04 24             	mov    %eax,(%esp)
  10422c:	e8 71 fe ff ff       	call   1040a2 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104231:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104237:	29 d1                	sub    %edx,%ecx
  104239:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10423b:	89 d6                	mov    %edx,%esi
  10423d:	c1 e6 0c             	shl    $0xc,%esi
  104240:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104243:	89 d3                	mov    %edx,%ebx
  104245:	c1 e3 0c             	shl    $0xc,%ebx
  104248:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10424b:	c1 e2 0c             	shl    $0xc,%edx
  10424e:	89 d1                	mov    %edx,%ecx
  104250:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104253:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104256:	29 d7                	sub    %edx,%edi
  104258:	89 fa                	mov    %edi,%edx
  10425a:	89 44 24 14          	mov    %eax,0x14(%esp)
  10425e:	89 74 24 10          	mov    %esi,0x10(%esp)
  104262:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104266:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10426a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10426e:	c7 04 24 80 6c 10 00 	movl   $0x106c80,(%esp)
  104275:	e8 0c c0 ff ff       	call   100286 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10427a:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  10427f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104282:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104285:	89 ce                	mov    %ecx,%esi
  104287:	c1 e6 0a             	shl    $0xa,%esi
  10428a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10428d:	89 cb                	mov    %ecx,%ebx
  10428f:	c1 e3 0a             	shl    $0xa,%ebx
  104292:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  104295:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  104299:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  10429c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1042a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1042a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1042a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  1042ac:	89 1c 24             	mov    %ebx,(%esp)
  1042af:	e8 3c fe ff ff       	call   1040f0 <get_pgtable_items>
  1042b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1042bb:	0f 85 65 ff ff ff    	jne    104226 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1042c1:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1042c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042c9:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1042cc:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1042d0:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  1042d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1042d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1042db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1042df:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1042e6:	00 
  1042e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1042ee:	e8 fd fd ff ff       	call   1040f0 <get_pgtable_items>
  1042f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1042fa:	0f 85 c7 fe ff ff    	jne    1041c7 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104300:	c7 04 24 a4 6c 10 00 	movl   $0x106ca4,(%esp)
  104307:	e8 7a bf ff ff       	call   100286 <cprintf>
}
  10430c:	83 c4 4c             	add    $0x4c,%esp
  10430f:	5b                   	pop    %ebx
  104310:	5e                   	pop    %esi
  104311:	5f                   	pop    %edi
  104312:	5d                   	pop    %ebp
  104313:	c3                   	ret    

00104314 <page2ppn>:
page2ppn(struct Page *page) {
  104314:	55                   	push   %ebp
  104315:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104317:	8b 55 08             	mov    0x8(%ebp),%edx
  10431a:	a1 58 89 11 00       	mov    0x118958,%eax
  10431f:	29 c2                	sub    %eax,%edx
  104321:	89 d0                	mov    %edx,%eax
  104323:	c1 f8 02             	sar    $0x2,%eax
  104326:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10432c:	5d                   	pop    %ebp
  10432d:	c3                   	ret    

0010432e <page2pa>:
page2pa(struct Page *page) {
  10432e:	55                   	push   %ebp
  10432f:	89 e5                	mov    %esp,%ebp
  104331:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104334:	8b 45 08             	mov    0x8(%ebp),%eax
  104337:	89 04 24             	mov    %eax,(%esp)
  10433a:	e8 d5 ff ff ff       	call   104314 <page2ppn>
  10433f:	c1 e0 0c             	shl    $0xc,%eax
}
  104342:	c9                   	leave  
  104343:	c3                   	ret    

00104344 <page_ref>:
page_ref(struct Page *page) {
  104344:	55                   	push   %ebp
  104345:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104347:	8b 45 08             	mov    0x8(%ebp),%eax
  10434a:	8b 00                	mov    (%eax),%eax
}
  10434c:	5d                   	pop    %ebp
  10434d:	c3                   	ret    

0010434e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10434e:	55                   	push   %ebp
  10434f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104351:	8b 45 08             	mov    0x8(%ebp),%eax
  104354:	8b 55 0c             	mov    0xc(%ebp),%edx
  104357:	89 10                	mov    %edx,(%eax)
}
  104359:	5d                   	pop    %ebp
  10435a:	c3                   	ret    

0010435b <default_init>:
/**
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 */
static void
default_init(void) {
  10435b:	55                   	push   %ebp
  10435c:	89 e5                	mov    %esp,%ebp
  10435e:	83 ec 10             	sub    $0x10,%esp
  104361:	c7 45 fc 5c 89 11 00 	movl   $0x11895c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104368:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10436b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10436e:	89 50 04             	mov    %edx,0x4(%eax)
  104371:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104374:	8b 50 04             	mov    0x4(%eax),%edx
  104377:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10437a:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10437c:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  104383:	00 00 00 
}
  104386:	c9                   	leave  
  104387:	c3                   	ret    

00104388 <default_init_memmap>:
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * @param base
 * @param n
 */
static void
default_init_memmap(struct Page *base, size_t n) {
  104388:	55                   	push   %ebp
  104389:	89 e5                	mov    %esp,%ebp
  10438b:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  10438e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104392:	75 24                	jne    1043b8 <default_init_memmap+0x30>
  104394:	c7 44 24 0c d8 6c 10 	movl   $0x106cd8,0xc(%esp)
  10439b:	00 
  10439c:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1043a3:	00 
  1043a4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  1043ab:	00 
  1043ac:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1043b3:	e8 25 c0 ff ff       	call   1003dd <__panic>
    struct Page *p = base;
  1043b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1043bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1043be:	e9 d2 00 00 00       	jmp    104495 <default_init_memmap+0x10d>
        assert(PageReserved(p));
  1043c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043c6:	83 c0 04             	add    $0x4,%eax
  1043c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1043d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1043d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1043d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1043d9:	0f a3 10             	bt     %edx,(%eax)
  1043dc:	19 c0                	sbb    %eax,%eax
  1043de:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1043e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1043e5:	0f 95 c0             	setne  %al
  1043e8:	0f b6 c0             	movzbl %al,%eax
  1043eb:	85 c0                	test   %eax,%eax
  1043ed:	75 24                	jne    104413 <default_init_memmap+0x8b>
  1043ef:	c7 44 24 0c 09 6d 10 	movl   $0x106d09,0xc(%esp)
  1043f6:	00 
  1043f7:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1043fe:	00 
  1043ff:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  104406:	00 
  104407:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10440e:	e8 ca bf ff ff       	call   1003dd <__panic>
        set_page_ref(p, 0);
  104413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10441a:	00 
  10441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10441e:	89 04 24             	mov    %eax,(%esp)
  104421:	e8 28 ff ff ff       	call   10434e <set_page_ref>
        //p的ref指针设置为0,因为该页未被使用
        SetPageProperty(p);
  104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104429:	83 c0 04             	add    $0x4,%eax
  10442c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  104433:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104436:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10443c:	0f ab 10             	bts    %edx,(%eax)
        //页面刚刚初始化，未被保留
        p->property=0;
  10443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104442:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(&free_list, &(p->page_link));
  104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10444c:	83 c0 0c             	add    $0xc,%eax
  10444f:	c7 45 dc 5c 89 11 00 	movl   $0x11895c,-0x24(%ebp)
  104456:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  104459:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10445c:	8b 00                	mov    (%eax),%eax
  10445e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104461:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104464:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104467:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10446a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10446d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104470:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104473:	89 10                	mov    %edx,(%eax)
  104475:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104478:	8b 10                	mov    (%eax),%edx
  10447a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10447d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104480:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104483:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104486:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104489:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10448c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10448f:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
  104491:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104495:	8b 55 0c             	mov    0xc(%ebp),%edx
  104498:	89 d0                	mov    %edx,%eax
  10449a:	c1 e0 02             	shl    $0x2,%eax
  10449d:	01 d0                	add    %edx,%eax
  10449f:	c1 e0 02             	shl    $0x2,%eax
  1044a2:	89 c2                	mov    %eax,%edx
  1044a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1044a7:	01 d0                	add    %edx,%eax
  1044a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1044ac:	0f 85 11 ff ff ff    	jne    1043c3 <default_init_memmap+0x3b>
    }
    base->property=n;
  1044b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1044b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044b8:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;//总可分配数量增加
  1044bb:	8b 15 64 89 11 00    	mov    0x118964,%edx
  1044c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044c4:	01 d0                	add    %edx,%eax
  1044c6:	a3 64 89 11 00       	mov    %eax,0x118964
}
  1044cb:	c9                   	leave  
  1044cc:	c3                   	ret    

001044cd <default_alloc_pages>:
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * @param n
 * @return
 */
static struct Page *
default_alloc_pages(size_t n) {
  1044cd:	55                   	push   %ebp
  1044ce:	89 e5                	mov    %esp,%ebp
  1044d0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1044d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1044d7:	75 24                	jne    1044fd <default_alloc_pages+0x30>
  1044d9:	c7 44 24 0c d8 6c 10 	movl   $0x106cd8,0xc(%esp)
  1044e0:	00 
  1044e1:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1044e8:	00 
  1044e9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  1044f0:	00 
  1044f1:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1044f8:	e8 e0 be ff ff       	call   1003dd <__panic>
    if (n > nr_free) {
  1044fd:	a1 64 89 11 00       	mov    0x118964,%eax
  104502:	3b 45 08             	cmp    0x8(%ebp),%eax
  104505:	73 0a                	jae    104511 <default_alloc_pages+0x44>
        return NULL;
  104507:	b8 00 00 00 00       	mov    $0x0,%eax
  10450c:	e9 fc 00 00 00       	jmp    10460d <default_alloc_pages+0x140>
    }
    struct Page *page = NULL;
  104511:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    list_entry_t *le = &free_list;
  104518:	c7 45 f4 5c 89 11 00 	movl   $0x11895c,-0xc(%ebp)

    while ((le = list_next(le)) != &free_list) {
  10451f:	e9 c8 00 00 00       	jmp    1045ec <default_alloc_pages+0x11f>
        struct Page *p = le2page(le, page_link);
  104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104527:	83 e8 0c             	sub    $0xc,%eax
  10452a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
  10452d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104530:	8b 40 08             	mov    0x8(%eax),%eax
  104533:	3b 45 08             	cmp    0x8(%ebp),%eax
  104536:	0f 82 b0 00 00 00    	jb     1045ec <default_alloc_pages+0x11f>
            //找到了合适大小的块，可以进行分配
            struct Page *curPage=p;
  10453c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10453f:	89 45 f0             	mov    %eax,-0x10(%ebp)
            for(;curPage<p+n;curPage++){
  104542:	eb 61                	jmp    1045a5 <default_alloc_pages+0xd8>
                //遍历所有需要分配的PAGE 修改其相应属性为已经分配 并将其移除freelist
                ClearPageProperty(curPage);
  104544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104547:	83 c0 04             	add    $0x4,%eax
  10454a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  104551:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104554:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104557:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10455a:	0f b3 10             	btr    %edx,(%eax)
                SetPageReserved(curPage);
  10455d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104560:	83 c0 04             	add    $0x4,%eax
  104563:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10456a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10456d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104570:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104573:	0f ab 10             	bts    %edx,(%eax)
                list_del(&(curPage->page_link));
  104576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104579:	83 c0 0c             	add    $0xc,%eax
  10457c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10457f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104582:	8b 40 04             	mov    0x4(%eax),%eax
  104585:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104588:	8b 12                	mov    (%edx),%edx
  10458a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  10458d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104590:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104593:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104596:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104599:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10459c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10459f:	89 10                	mov    %edx,(%eax)
            for(;curPage<p+n;curPage++){
  1045a1:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  1045a5:	8b 55 08             	mov    0x8(%ebp),%edx
  1045a8:	89 d0                	mov    %edx,%eax
  1045aa:	c1 e0 02             	shl    $0x2,%eax
  1045ad:	01 d0                	add    %edx,%eax
  1045af:	c1 e0 02             	shl    $0x2,%eax
  1045b2:	89 c2                	mov    %eax,%edx
  1045b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045b7:	01 d0                	add    %edx,%eax
  1045b9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1045bc:	77 86                	ja     104544 <default_alloc_pages+0x77>
            }
            if(p->property>n){
  1045be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045c1:	8b 40 08             	mov    0x8(%eax),%eax
  1045c4:	3b 45 08             	cmp    0x8(%ebp),%eax
  1045c7:	76 11                	jbe    1045da <default_alloc_pages+0x10d>
                //如果分配后还存在外碎片，需要将外碎片数量更新为原大小减去分配量
                curPage->property=p->property-n;
  1045c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045cc:	8b 40 08             	mov    0x8(%eax),%eax
  1045cf:	2b 45 08             	sub    0x8(%ebp),%eax
  1045d2:	89 c2                	mov    %eax,%edx
  1045d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045d7:	89 50 08             	mov    %edx,0x8(%eax)
            }
            nr_free-=n;//记得更新剩余页数量
  1045da:	a1 64 89 11 00       	mov    0x118964,%eax
  1045df:	2b 45 08             	sub    0x8(%ebp),%eax
  1045e2:	a3 64 89 11 00       	mov    %eax,0x118964
            return p;
  1045e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045ea:	eb 21                	jmp    10460d <default_alloc_pages+0x140>
  1045ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045ef:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return listelm->next;
  1045f2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1045f5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1045f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1045fb:	81 7d f4 5c 89 11 00 	cmpl   $0x11895c,-0xc(%ebp)
  104602:	0f 85 1c ff ff ff    	jne    104524 <default_alloc_pages+0x57>
        }
    }

    return NULL;
  104608:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10460d:	c9                   	leave  
  10460e:	c3                   	ret    

0010460f <default_free_pages>:
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 * @param base
 * @param n
 */
static void
default_free_pages(struct Page *base, size_t n) {
  10460f:	55                   	push   %ebp
  104610:	89 e5                	mov    %esp,%ebp
  104612:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
  104615:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104619:	75 24                	jne    10463f <default_free_pages+0x30>
  10461b:	c7 44 24 0c d8 6c 10 	movl   $0x106cd8,0xc(%esp)
  104622:	00 
  104623:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  10462a:	00 
  10462b:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
  104632:	00 
  104633:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10463a:	e8 9e bd ff ff       	call   1003dd <__panic>
    assert(PageReserved(base));
  10463f:	8b 45 08             	mov    0x8(%ebp),%eax
  104642:	83 c0 04             	add    $0x4,%eax
  104645:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10464c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10464f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104652:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104655:	0f a3 10             	bt     %edx,(%eax)
  104658:	19 c0                	sbb    %eax,%eax
  10465a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10465d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104661:	0f 95 c0             	setne  %al
  104664:	0f b6 c0             	movzbl %al,%eax
  104667:	85 c0                	test   %eax,%eax
  104669:	75 24                	jne    10468f <default_free_pages+0x80>
  10466b:	c7 44 24 0c 19 6d 10 	movl   $0x106d19,0xc(%esp)
  104672:	00 
  104673:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  10467a:	00 
  10467b:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  104682:	00 
  104683:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10468a:	e8 4e bd ff ff       	call   1003dd <__panic>
    struct Page *p ;
    list_entry_t *le = &free_list;
  10468f:	c7 45 f0 5c 89 11 00 	movl   $0x11895c,-0x10(%ebp)
     while((le=list_next(le))!=&free_list){
  104696:	eb 13                	jmp    1046ab <default_free_pages+0x9c>
         //理解这段代码：由于块已经分配出去，因此块没有被串在链表中，我们需要找到正确插入链表的位置，而page结构数组是不会改变的
         //要找到正确的插入位置，就需要找到链表中第一个在base前的page，然后就可以对要释放的块使用头插法：list_add_before()以此插入即可
         p=le2page(le,page_link);
  104698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10469b:	83 e8 0c             	sub    $0xc,%eax
  10469e:	89 45 f4             	mov    %eax,-0xc(%ebp)
         if(p>base){
  1046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046a4:	3b 45 08             	cmp    0x8(%ebp),%eax
  1046a7:	76 02                	jbe    1046ab <default_free_pages+0x9c>
             break;
  1046a9:	eb 18                	jmp    1046c3 <default_free_pages+0xb4>
  1046ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1046b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1046b4:	8b 40 04             	mov    0x4(%eax),%eax
     while((le=list_next(le))!=&free_list){
  1046b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046ba:	81 7d f0 5c 89 11 00 	cmpl   $0x11895c,-0x10(%ebp)
  1046c1:	75 d5                	jne    104698 <default_free_pages+0x89>
         }
     }
     for(p=base;p<base+n;p++){
  1046c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1046c9:	eb 77                	jmp    104742 <default_free_pages+0x133>
         ClearPageReserved(p);//移除保留状态
  1046cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ce:	83 c0 04             	add    $0x4,%eax
  1046d1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1046d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1046db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1046e1:	0f b3 10             	btr    %edx,(%eax)
         set_page_ref(p,0);//设置引用数为0
  1046e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1046eb:	00 
  1046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ef:	89 04 24             	mov    %eax,(%esp)
  1046f2:	e8 57 fc ff ff       	call   10434e <set_page_ref>
         list_add_before(le,&p->page_link);//加入链表
  1046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046fa:	8d 50 0c             	lea    0xc(%eax),%edx
  1046fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  104703:	89 55 d0             	mov    %edx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104709:	8b 00                	mov    (%eax),%eax
  10470b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10470e:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104711:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104714:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104717:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  10471a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10471d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104720:	89 10                	mov    %edx,(%eax)
  104722:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104725:	8b 10                	mov    (%eax),%edx
  104727:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10472a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10472d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104730:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104733:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104736:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104739:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10473c:	89 10                	mov    %edx,(%eax)
     for(p=base;p<base+n;p++){
  10473e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104742:	8b 55 0c             	mov    0xc(%ebp),%edx
  104745:	89 d0                	mov    %edx,%eax
  104747:	c1 e0 02             	shl    $0x2,%eax
  10474a:	01 d0                	add    %edx,%eax
  10474c:	c1 e0 02             	shl    $0x2,%eax
  10474f:	89 c2                	mov    %eax,%edx
  104751:	8b 45 08             	mov    0x8(%ebp),%eax
  104754:	01 d0                	add    %edx,%eax
  104756:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104759:	0f 87 6c ff ff ff    	ja     1046cb <default_free_pages+0xbc>
     }
    SetPageProperty(base);//一个块的头页面需要设置property
  10475f:	8b 45 08             	mov    0x8(%ebp),%eax
  104762:	83 c0 04             	add    $0x4,%eax
  104765:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10476c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10476f:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104772:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104775:	0f ab 10             	bts    %edx,(%eax)
    base->property=n;
  104778:	8b 45 08             	mov    0x8(%ebp),%eax
  10477b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10477e:	89 50 08             	mov    %edx,0x8(%eax)
    p=le2page(le,page_link);
  104781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104784:	83 e8 0c             	sub    $0xc,%eax
  104787:	89 45 f4             	mov    %eax,-0xc(%ebp)

    //除了加入空闲链表之外，还需要合并上方和下方的块
    if(p==base+n){
  10478a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10478d:	89 d0                	mov    %edx,%eax
  10478f:	c1 e0 02             	shl    $0x2,%eax
  104792:	01 d0                	add    %edx,%eax
  104794:	c1 e0 02             	shl    $0x2,%eax
  104797:	89 c2                	mov    %eax,%edx
  104799:	8b 45 08             	mov    0x8(%ebp),%eax
  10479c:	01 d0                	add    %edx,%eax
  10479e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047a1:	75 37                	jne    1047da <default_free_pages+0x1cb>
        //下方的块合并较为简单，判断链表的下一个页是否正好是相邻的页，如果是，则直接将property加入到base页，然后清空该页的property
        base->property+=p->property;
  1047a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1047a6:	8b 50 08             	mov    0x8(%eax),%edx
  1047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ac:	8b 40 08             	mov    0x8(%eax),%eax
  1047af:	01 c2                	add    %eax,%edx
  1047b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1047b4:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
  1047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        ClearPageProperty(p);
  1047c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047c4:	83 c0 04             	add    $0x4,%eax
  1047c7:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1047ce:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1047d1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1047d4:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1047d7:	0f b3 10             	btr    %edx,(%eax)
    }

    //合并上方也不复杂，需要找到上方第一个空闲块并将base 的property赋给该块
    le=list_prev(&base->page_link);
  1047da:	8b 45 08             	mov    0x8(%ebp),%eax
  1047dd:	83 c0 0c             	add    $0xc,%eax
  1047e0:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->prev;
  1047e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1047e6:	8b 00                	mov    (%eax),%eax
  1047e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    p=le2page(le,page_link);
  1047eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047ee:	83 e8 0c             	sub    $0xc,%eax
  1047f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p==base-1){
  1047f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1047f7:	83 e8 14             	sub    $0x14,%eax
  1047fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047fd:	75 65                	jne    104864 <default_free_pages+0x255>
        //链表的上一个块必须要和当前页连续才能合并
        while(le!=&free_list){
  1047ff:	eb 5a                	jmp    10485b <default_free_pages+0x24c>
            p=le2page(le,page_link);
  104801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104804:	83 e8 0c             	sub    $0xc,%eax
  104807:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if(p->property!=0){
  10480a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10480d:	8b 40 08             	mov    0x8(%eax),%eax
  104810:	85 c0                	test   %eax,%eax
  104812:	74 39                	je     10484d <default_free_pages+0x23e>
                p->property+=base->property;
  104814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104817:	8b 50 08             	mov    0x8(%eax),%edx
  10481a:	8b 45 08             	mov    0x8(%ebp),%eax
  10481d:	8b 40 08             	mov    0x8(%eax),%eax
  104820:	01 c2                	add    %eax,%edx
  104822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104825:	89 50 08             	mov    %edx,0x8(%eax)
                base->property=0;
  104828:	8b 45 08             	mov    0x8(%ebp),%eax
  10482b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
                ClearPageProperty(base);
  104832:	8b 45 08             	mov    0x8(%ebp),%eax
  104835:	83 c0 04             	add    $0x4,%eax
  104838:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10483f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104842:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104845:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104848:	0f b3 10             	btr    %edx,(%eax)
                break;
  10484b:	eb 17                	jmp    104864 <default_free_pages+0x255>
  10484d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104850:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  104853:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104856:	8b 00                	mov    (%eax),%eax
            }
            le=list_prev(le);
  104858:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while(le!=&free_list){
  10485b:	81 7d f0 5c 89 11 00 	cmpl   $0x11895c,-0x10(%ebp)
  104862:	75 9d                	jne    104801 <default_free_pages+0x1f2>
        }
    }
    nr_free+=n;
  104864:	8b 15 64 89 11 00    	mov    0x118964,%edx
  10486a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10486d:	01 d0                	add    %edx,%eax
  10486f:	a3 64 89 11 00       	mov    %eax,0x118964
    return;
  104874:	90                   	nop

}
  104875:	c9                   	leave  
  104876:	c3                   	ret    

00104877 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104877:	55                   	push   %ebp
  104878:	89 e5                	mov    %esp,%ebp
    return nr_free;
  10487a:	a1 64 89 11 00       	mov    0x118964,%eax
}
  10487f:	5d                   	pop    %ebp
  104880:	c3                   	ret    

00104881 <basic_check>:

static void
basic_check(void) {
  104881:	55                   	push   %ebp
  104882:	89 e5                	mov    %esp,%ebp
  104884:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10488e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104891:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104897:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  10489a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048a1:	e8 1a e3 ff ff       	call   102bc0 <alloc_pages>
  1048a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1048a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1048ad:	75 24                	jne    1048d3 <basic_check+0x52>
  1048af:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  1048b6:	00 
  1048b7:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1048be:	00 
  1048bf:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  1048c6:	00 
  1048c7:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1048ce:	e8 0a bb ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
  1048d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048da:	e8 e1 e2 ff ff       	call   102bc0 <alloc_pages>
  1048df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048e6:	75 24                	jne    10490c <basic_check+0x8b>
  1048e8:	c7 44 24 0c 48 6d 10 	movl   $0x106d48,0xc(%esp)
  1048ef:	00 
  1048f0:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1048f7:	00 
  1048f8:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  1048ff:	00 
  104900:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104907:	e8 d1 ba ff ff       	call   1003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
  10490c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104913:	e8 a8 e2 ff ff       	call   102bc0 <alloc_pages>
  104918:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10491b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10491f:	75 24                	jne    104945 <basic_check+0xc4>
  104921:	c7 44 24 0c 64 6d 10 	movl   $0x106d64,0xc(%esp)
  104928:	00 
  104929:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104930:	00 
  104931:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104938:	00 
  104939:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104940:	e8 98 ba ff ff       	call   1003dd <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104945:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104948:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10494b:	74 10                	je     10495d <basic_check+0xdc>
  10494d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104950:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104953:	74 08                	je     10495d <basic_check+0xdc>
  104955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104958:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10495b:	75 24                	jne    104981 <basic_check+0x100>
  10495d:	c7 44 24 0c 80 6d 10 	movl   $0x106d80,0xc(%esp)
  104964:	00 
  104965:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  10496c:	00 
  10496d:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  104974:	00 
  104975:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10497c:	e8 5c ba ff ff       	call   1003dd <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104981:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104984:	89 04 24             	mov    %eax,(%esp)
  104987:	e8 b8 f9 ff ff       	call   104344 <page_ref>
  10498c:	85 c0                	test   %eax,%eax
  10498e:	75 1e                	jne    1049ae <basic_check+0x12d>
  104990:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104993:	89 04 24             	mov    %eax,(%esp)
  104996:	e8 a9 f9 ff ff       	call   104344 <page_ref>
  10499b:	85 c0                	test   %eax,%eax
  10499d:	75 0f                	jne    1049ae <basic_check+0x12d>
  10499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049a2:	89 04 24             	mov    %eax,(%esp)
  1049a5:	e8 9a f9 ff ff       	call   104344 <page_ref>
  1049aa:	85 c0                	test   %eax,%eax
  1049ac:	74 24                	je     1049d2 <basic_check+0x151>
  1049ae:	c7 44 24 0c a4 6d 10 	movl   $0x106da4,0xc(%esp)
  1049b5:	00 
  1049b6:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1049bd:	00 
  1049be:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  1049c5:	00 
  1049c6:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1049cd:	e8 0b ba ff ff       	call   1003dd <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1049d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049d5:	89 04 24             	mov    %eax,(%esp)
  1049d8:	e8 51 f9 ff ff       	call   10432e <page2pa>
  1049dd:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  1049e3:	c1 e2 0c             	shl    $0xc,%edx
  1049e6:	39 d0                	cmp    %edx,%eax
  1049e8:	72 24                	jb     104a0e <basic_check+0x18d>
  1049ea:	c7 44 24 0c e0 6d 10 	movl   $0x106de0,0xc(%esp)
  1049f1:	00 
  1049f2:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1049f9:	00 
  1049fa:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104a01:	00 
  104a02:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104a09:	e8 cf b9 ff ff       	call   1003dd <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a11:	89 04 24             	mov    %eax,(%esp)
  104a14:	e8 15 f9 ff ff       	call   10432e <page2pa>
  104a19:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  104a1f:	c1 e2 0c             	shl    $0xc,%edx
  104a22:	39 d0                	cmp    %edx,%eax
  104a24:	72 24                	jb     104a4a <basic_check+0x1c9>
  104a26:	c7 44 24 0c fd 6d 10 	movl   $0x106dfd,0xc(%esp)
  104a2d:	00 
  104a2e:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104a35:	00 
  104a36:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  104a3d:	00 
  104a3e:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104a45:	e8 93 b9 ff ff       	call   1003dd <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a4d:	89 04 24             	mov    %eax,(%esp)
  104a50:	e8 d9 f8 ff ff       	call   10432e <page2pa>
  104a55:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  104a5b:	c1 e2 0c             	shl    $0xc,%edx
  104a5e:	39 d0                	cmp    %edx,%eax
  104a60:	72 24                	jb     104a86 <basic_check+0x205>
  104a62:	c7 44 24 0c 1a 6e 10 	movl   $0x106e1a,0xc(%esp)
  104a69:	00 
  104a6a:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104a71:	00 
  104a72:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  104a79:	00 
  104a7a:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104a81:	e8 57 b9 ff ff       	call   1003dd <__panic>

    list_entry_t free_list_store = free_list;
  104a86:	a1 5c 89 11 00       	mov    0x11895c,%eax
  104a8b:	8b 15 60 89 11 00    	mov    0x118960,%edx
  104a91:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104a94:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104a97:	c7 45 e0 5c 89 11 00 	movl   $0x11895c,-0x20(%ebp)
    elm->prev = elm->next = elm;
  104a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104aa1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104aa4:	89 50 04             	mov    %edx,0x4(%eax)
  104aa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104aaa:	8b 50 04             	mov    0x4(%eax),%edx
  104aad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ab0:	89 10                	mov    %edx,(%eax)
  104ab2:	c7 45 dc 5c 89 11 00 	movl   $0x11895c,-0x24(%ebp)
    return list->next == list;
  104ab9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104abc:	8b 40 04             	mov    0x4(%eax),%eax
  104abf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104ac2:	0f 94 c0             	sete   %al
  104ac5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104ac8:	85 c0                	test   %eax,%eax
  104aca:	75 24                	jne    104af0 <basic_check+0x26f>
  104acc:	c7 44 24 0c 37 6e 10 	movl   $0x106e37,0xc(%esp)
  104ad3:	00 
  104ad4:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104adb:	00 
  104adc:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  104ae3:	00 
  104ae4:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104aeb:	e8 ed b8 ff ff       	call   1003dd <__panic>

    unsigned int nr_free_store = nr_free;
  104af0:	a1 64 89 11 00       	mov    0x118964,%eax
  104af5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104af8:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  104aff:	00 00 00 

    assert(alloc_page() == NULL);
  104b02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b09:	e8 b2 e0 ff ff       	call   102bc0 <alloc_pages>
  104b0e:	85 c0                	test   %eax,%eax
  104b10:	74 24                	je     104b36 <basic_check+0x2b5>
  104b12:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  104b19:	00 
  104b1a:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104b21:	00 
  104b22:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  104b29:	00 
  104b2a:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104b31:	e8 a7 b8 ff ff       	call   1003dd <__panic>

    free_page(p0);
  104b36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b3d:	00 
  104b3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b41:	89 04 24             	mov    %eax,(%esp)
  104b44:	e8 af e0 ff ff       	call   102bf8 <free_pages>
    free_page(p1);
  104b49:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b50:	00 
  104b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b54:	89 04 24             	mov    %eax,(%esp)
  104b57:	e8 9c e0 ff ff       	call   102bf8 <free_pages>
    free_page(p2);
  104b5c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b63:	00 
  104b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b67:	89 04 24             	mov    %eax,(%esp)
  104b6a:	e8 89 e0 ff ff       	call   102bf8 <free_pages>
    assert(nr_free == 3);
  104b6f:	a1 64 89 11 00       	mov    0x118964,%eax
  104b74:	83 f8 03             	cmp    $0x3,%eax
  104b77:	74 24                	je     104b9d <basic_check+0x31c>
  104b79:	c7 44 24 0c 63 6e 10 	movl   $0x106e63,0xc(%esp)
  104b80:	00 
  104b81:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104b88:	00 
  104b89:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104b90:	00 
  104b91:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104b98:	e8 40 b8 ff ff       	call   1003dd <__panic>

    assert((p0 = alloc_page()) != NULL);
  104b9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ba4:	e8 17 e0 ff ff       	call   102bc0 <alloc_pages>
  104ba9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104bac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104bb0:	75 24                	jne    104bd6 <basic_check+0x355>
  104bb2:	c7 44 24 0c 2c 6d 10 	movl   $0x106d2c,0xc(%esp)
  104bb9:	00 
  104bba:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104bc1:	00 
  104bc2:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104bc9:	00 
  104bca:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104bd1:	e8 07 b8 ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
  104bd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bdd:	e8 de df ff ff       	call   102bc0 <alloc_pages>
  104be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104be5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104be9:	75 24                	jne    104c0f <basic_check+0x38e>
  104beb:	c7 44 24 0c 48 6d 10 	movl   $0x106d48,0xc(%esp)
  104bf2:	00 
  104bf3:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104bfa:	00 
  104bfb:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104c02:	00 
  104c03:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104c0a:	e8 ce b7 ff ff       	call   1003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
  104c0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c16:	e8 a5 df ff ff       	call   102bc0 <alloc_pages>
  104c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104c1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104c22:	75 24                	jne    104c48 <basic_check+0x3c7>
  104c24:	c7 44 24 0c 64 6d 10 	movl   $0x106d64,0xc(%esp)
  104c2b:	00 
  104c2c:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104c33:	00 
  104c34:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  104c3b:	00 
  104c3c:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104c43:	e8 95 b7 ff ff       	call   1003dd <__panic>

    assert(alloc_page() == NULL);
  104c48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c4f:	e8 6c df ff ff       	call   102bc0 <alloc_pages>
  104c54:	85 c0                	test   %eax,%eax
  104c56:	74 24                	je     104c7c <basic_check+0x3fb>
  104c58:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  104c5f:	00 
  104c60:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104c67:	00 
  104c68:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  104c6f:	00 
  104c70:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104c77:	e8 61 b7 ff ff       	call   1003dd <__panic>

    free_page(p0);
  104c7c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c83:	00 
  104c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c87:	89 04 24             	mov    %eax,(%esp)
  104c8a:	e8 69 df ff ff       	call   102bf8 <free_pages>
  104c8f:	c7 45 d8 5c 89 11 00 	movl   $0x11895c,-0x28(%ebp)
  104c96:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c99:	8b 40 04             	mov    0x4(%eax),%eax
  104c9c:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c9f:	0f 94 c0             	sete   %al
  104ca2:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104ca5:	85 c0                	test   %eax,%eax
  104ca7:	74 24                	je     104ccd <basic_check+0x44c>
  104ca9:	c7 44 24 0c 70 6e 10 	movl   $0x106e70,0xc(%esp)
  104cb0:	00 
  104cb1:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104cb8:	00 
  104cb9:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104cc0:	00 
  104cc1:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104cc8:	e8 10 b7 ff ff       	call   1003dd <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104ccd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cd4:	e8 e7 de ff ff       	call   102bc0 <alloc_pages>
  104cd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104cdf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104ce2:	74 24                	je     104d08 <basic_check+0x487>
  104ce4:	c7 44 24 0c 88 6e 10 	movl   $0x106e88,0xc(%esp)
  104ceb:	00 
  104cec:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104cf3:	00 
  104cf4:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  104cfb:	00 
  104cfc:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104d03:	e8 d5 b6 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  104d08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d0f:	e8 ac de ff ff       	call   102bc0 <alloc_pages>
  104d14:	85 c0                	test   %eax,%eax
  104d16:	74 24                	je     104d3c <basic_check+0x4bb>
  104d18:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  104d1f:	00 
  104d20:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104d27:	00 
  104d28:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104d2f:	00 
  104d30:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104d37:	e8 a1 b6 ff ff       	call   1003dd <__panic>

    assert(nr_free == 0);
  104d3c:	a1 64 89 11 00       	mov    0x118964,%eax
  104d41:	85 c0                	test   %eax,%eax
  104d43:	74 24                	je     104d69 <basic_check+0x4e8>
  104d45:	c7 44 24 0c a1 6e 10 	movl   $0x106ea1,0xc(%esp)
  104d4c:	00 
  104d4d:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104d54:	00 
  104d55:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  104d5c:	00 
  104d5d:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104d64:	e8 74 b6 ff ff       	call   1003dd <__panic>
    free_list = free_list_store;
  104d69:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d6c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d6f:	a3 5c 89 11 00       	mov    %eax,0x11895c
  104d74:	89 15 60 89 11 00    	mov    %edx,0x118960
    nr_free = nr_free_store;
  104d7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d7d:	a3 64 89 11 00       	mov    %eax,0x118964

    free_page(p);
  104d82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d89:	00 
  104d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d8d:	89 04 24             	mov    %eax,(%esp)
  104d90:	e8 63 de ff ff       	call   102bf8 <free_pages>
    free_page(p1);
  104d95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d9c:	00 
  104d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104da0:	89 04 24             	mov    %eax,(%esp)
  104da3:	e8 50 de ff ff       	call   102bf8 <free_pages>
    free_page(p2);
  104da8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104daf:	00 
  104db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104db3:	89 04 24             	mov    %eax,(%esp)
  104db6:	e8 3d de ff ff       	call   102bf8 <free_pages>
}
  104dbb:	c9                   	leave  
  104dbc:	c3                   	ret    

00104dbd <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104dbd:	55                   	push   %ebp
  104dbe:	89 e5                	mov    %esp,%ebp
  104dc0:	53                   	push   %ebx
  104dc1:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  104dc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104dce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104dd5:	c7 45 ec 5c 89 11 00 	movl   $0x11895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104ddc:	eb 6b                	jmp    104e49 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  104dde:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104de1:	83 e8 0c             	sub    $0xc,%eax
  104de4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  104de7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104dea:	83 c0 04             	add    $0x4,%eax
  104ded:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104df4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104df7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104dfa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104dfd:	0f a3 10             	bt     %edx,(%eax)
  104e00:	19 c0                	sbb    %eax,%eax
  104e02:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104e05:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104e09:	0f 95 c0             	setne  %al
  104e0c:	0f b6 c0             	movzbl %al,%eax
  104e0f:	85 c0                	test   %eax,%eax
  104e11:	75 24                	jne    104e37 <default_check+0x7a>
  104e13:	c7 44 24 0c ae 6e 10 	movl   $0x106eae,0xc(%esp)
  104e1a:	00 
  104e1b:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104e22:	00 
  104e23:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  104e2a:	00 
  104e2b:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104e32:	e8 a6 b5 ff ff       	call   1003dd <__panic>
        count ++, total += p->property;
  104e37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104e3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e3e:	8b 50 08             	mov    0x8(%eax),%edx
  104e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e44:	01 d0                	add    %edx,%eax
  104e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e4c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e4f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e52:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e58:	81 7d ec 5c 89 11 00 	cmpl   $0x11895c,-0x14(%ebp)
  104e5f:	0f 85 79 ff ff ff    	jne    104dde <default_check+0x21>
    }
    assert(total == nr_free_pages());
  104e65:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  104e68:	e8 bd dd ff ff       	call   102c2a <nr_free_pages>
  104e6d:	39 c3                	cmp    %eax,%ebx
  104e6f:	74 24                	je     104e95 <default_check+0xd8>
  104e71:	c7 44 24 0c be 6e 10 	movl   $0x106ebe,0xc(%esp)
  104e78:	00 
  104e79:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104e80:	00 
  104e81:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  104e88:	00 
  104e89:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104e90:	e8 48 b5 ff ff       	call   1003dd <__panic>

    basic_check();
  104e95:	e8 e7 f9 ff ff       	call   104881 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104e9a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104ea1:	e8 1a dd ff ff       	call   102bc0 <alloc_pages>
  104ea6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  104ea9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104ead:	75 24                	jne    104ed3 <default_check+0x116>
  104eaf:	c7 44 24 0c d7 6e 10 	movl   $0x106ed7,0xc(%esp)
  104eb6:	00 
  104eb7:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104ebe:	00 
  104ebf:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  104ec6:	00 
  104ec7:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104ece:	e8 0a b5 ff ff       	call   1003dd <__panic>
    assert(!PageProperty(p0));
  104ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ed6:	83 c0 04             	add    $0x4,%eax
  104ed9:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104ee0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ee3:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104ee6:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104ee9:	0f a3 10             	bt     %edx,(%eax)
  104eec:	19 c0                	sbb    %eax,%eax
  104eee:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104ef1:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104ef5:	0f 95 c0             	setne  %al
  104ef8:	0f b6 c0             	movzbl %al,%eax
  104efb:	85 c0                	test   %eax,%eax
  104efd:	74 24                	je     104f23 <default_check+0x166>
  104eff:	c7 44 24 0c e2 6e 10 	movl   $0x106ee2,0xc(%esp)
  104f06:	00 
  104f07:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104f0e:	00 
  104f0f:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  104f16:	00 
  104f17:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104f1e:	e8 ba b4 ff ff       	call   1003dd <__panic>

    list_entry_t free_list_store = free_list;
  104f23:	a1 5c 89 11 00       	mov    0x11895c,%eax
  104f28:	8b 15 60 89 11 00    	mov    0x118960,%edx
  104f2e:	89 45 80             	mov    %eax,-0x80(%ebp)
  104f31:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104f34:	c7 45 b4 5c 89 11 00 	movl   $0x11895c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  104f3b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f3e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104f41:	89 50 04             	mov    %edx,0x4(%eax)
  104f44:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f47:	8b 50 04             	mov    0x4(%eax),%edx
  104f4a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f4d:	89 10                	mov    %edx,(%eax)
  104f4f:	c7 45 b0 5c 89 11 00 	movl   $0x11895c,-0x50(%ebp)
    return list->next == list;
  104f56:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f59:	8b 40 04             	mov    0x4(%eax),%eax
  104f5c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  104f5f:	0f 94 c0             	sete   %al
  104f62:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104f65:	85 c0                	test   %eax,%eax
  104f67:	75 24                	jne    104f8d <default_check+0x1d0>
  104f69:	c7 44 24 0c 37 6e 10 	movl   $0x106e37,0xc(%esp)
  104f70:	00 
  104f71:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104f78:	00 
  104f79:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  104f80:	00 
  104f81:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104f88:	e8 50 b4 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  104f8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f94:	e8 27 dc ff ff       	call   102bc0 <alloc_pages>
  104f99:	85 c0                	test   %eax,%eax
  104f9b:	74 24                	je     104fc1 <default_check+0x204>
  104f9d:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  104fa4:	00 
  104fa5:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  104fac:	00 
  104fad:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104fb4:	00 
  104fb5:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  104fbc:	e8 1c b4 ff ff       	call   1003dd <__panic>

    unsigned int nr_free_store = nr_free;
  104fc1:	a1 64 89 11 00       	mov    0x118964,%eax
  104fc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104fc9:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  104fd0:	00 00 00 

    free_pages(p0 + 2, 3);
  104fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fd6:	83 c0 28             	add    $0x28,%eax
  104fd9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104fe0:	00 
  104fe1:	89 04 24             	mov    %eax,(%esp)
  104fe4:	e8 0f dc ff ff       	call   102bf8 <free_pages>
    assert(alloc_pages(4) == NULL);
  104fe9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104ff0:	e8 cb db ff ff       	call   102bc0 <alloc_pages>
  104ff5:	85 c0                	test   %eax,%eax
  104ff7:	74 24                	je     10501d <default_check+0x260>
  104ff9:	c7 44 24 0c f4 6e 10 	movl   $0x106ef4,0xc(%esp)
  105000:	00 
  105001:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105008:	00 
  105009:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  105010:	00 
  105011:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105018:	e8 c0 b3 ff ff       	call   1003dd <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10501d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105020:	83 c0 28             	add    $0x28,%eax
  105023:	83 c0 04             	add    $0x4,%eax
  105026:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10502d:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105030:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105033:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105036:	0f a3 10             	bt     %edx,(%eax)
  105039:	19 c0                	sbb    %eax,%eax
  10503b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10503e:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105042:	0f 95 c0             	setne  %al
  105045:	0f b6 c0             	movzbl %al,%eax
  105048:	85 c0                	test   %eax,%eax
  10504a:	74 0e                	je     10505a <default_check+0x29d>
  10504c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10504f:	83 c0 28             	add    $0x28,%eax
  105052:	8b 40 08             	mov    0x8(%eax),%eax
  105055:	83 f8 03             	cmp    $0x3,%eax
  105058:	74 24                	je     10507e <default_check+0x2c1>
  10505a:	c7 44 24 0c 0c 6f 10 	movl   $0x106f0c,0xc(%esp)
  105061:	00 
  105062:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105069:	00 
  10506a:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  105071:	00 
  105072:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105079:	e8 5f b3 ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10507e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105085:	e8 36 db ff ff       	call   102bc0 <alloc_pages>
  10508a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10508d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105091:	75 24                	jne    1050b7 <default_check+0x2fa>
  105093:	c7 44 24 0c 38 6f 10 	movl   $0x106f38,0xc(%esp)
  10509a:	00 
  10509b:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1050a2:	00 
  1050a3:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  1050aa:	00 
  1050ab:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1050b2:	e8 26 b3 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  1050b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050be:	e8 fd da ff ff       	call   102bc0 <alloc_pages>
  1050c3:	85 c0                	test   %eax,%eax
  1050c5:	74 24                	je     1050eb <default_check+0x32e>
  1050c7:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  1050ce:	00 
  1050cf:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1050d6:	00 
  1050d7:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  1050de:	00 
  1050df:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1050e6:	e8 f2 b2 ff ff       	call   1003dd <__panic>
    assert(p0 + 2 == p1);
  1050eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050ee:	83 c0 28             	add    $0x28,%eax
  1050f1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1050f4:	74 24                	je     10511a <default_check+0x35d>
  1050f6:	c7 44 24 0c 56 6f 10 	movl   $0x106f56,0xc(%esp)
  1050fd:	00 
  1050fe:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105105:	00 
  105106:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  10510d:	00 
  10510e:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105115:	e8 c3 b2 ff ff       	call   1003dd <__panic>

    p2 = p0 + 1;
  10511a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10511d:	83 c0 14             	add    $0x14,%eax
  105120:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  105123:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10512a:	00 
  10512b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10512e:	89 04 24             	mov    %eax,(%esp)
  105131:	e8 c2 da ff ff       	call   102bf8 <free_pages>
    free_pages(p1, 3);
  105136:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10513d:	00 
  10513e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105141:	89 04 24             	mov    %eax,(%esp)
  105144:	e8 af da ff ff       	call   102bf8 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10514c:	83 c0 04             	add    $0x4,%eax
  10514f:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105156:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105159:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10515c:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10515f:	0f a3 10             	bt     %edx,(%eax)
  105162:	19 c0                	sbb    %eax,%eax
  105164:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105167:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10516b:	0f 95 c0             	setne  %al
  10516e:	0f b6 c0             	movzbl %al,%eax
  105171:	85 c0                	test   %eax,%eax
  105173:	74 0b                	je     105180 <default_check+0x3c3>
  105175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105178:	8b 40 08             	mov    0x8(%eax),%eax
  10517b:	83 f8 01             	cmp    $0x1,%eax
  10517e:	74 24                	je     1051a4 <default_check+0x3e7>
  105180:	c7 44 24 0c 64 6f 10 	movl   $0x106f64,0xc(%esp)
  105187:	00 
  105188:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  10518f:	00 
  105190:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
  105197:	00 
  105198:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10519f:	e8 39 b2 ff ff       	call   1003dd <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1051a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051a7:	83 c0 04             	add    $0x4,%eax
  1051aa:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  1051b1:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051b4:	8b 45 90             	mov    -0x70(%ebp),%eax
  1051b7:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1051ba:	0f a3 10             	bt     %edx,(%eax)
  1051bd:	19 c0                	sbb    %eax,%eax
  1051bf:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1051c2:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1051c6:	0f 95 c0             	setne  %al
  1051c9:	0f b6 c0             	movzbl %al,%eax
  1051cc:	85 c0                	test   %eax,%eax
  1051ce:	74 0b                	je     1051db <default_check+0x41e>
  1051d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051d3:	8b 40 08             	mov    0x8(%eax),%eax
  1051d6:	83 f8 03             	cmp    $0x3,%eax
  1051d9:	74 24                	je     1051ff <default_check+0x442>
  1051db:	c7 44 24 0c 8c 6f 10 	movl   $0x106f8c,0xc(%esp)
  1051e2:	00 
  1051e3:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1051ea:	00 
  1051eb:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  1051f2:	00 
  1051f3:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1051fa:	e8 de b1 ff ff       	call   1003dd <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1051ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105206:	e8 b5 d9 ff ff       	call   102bc0 <alloc_pages>
  10520b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10520e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105211:	83 e8 14             	sub    $0x14,%eax
  105214:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  105217:	74 24                	je     10523d <default_check+0x480>
  105219:	c7 44 24 0c b2 6f 10 	movl   $0x106fb2,0xc(%esp)
  105220:	00 
  105221:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105228:	00 
  105229:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  105230:	00 
  105231:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105238:	e8 a0 b1 ff ff       	call   1003dd <__panic>
    free_page(p0);
  10523d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105244:	00 
  105245:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105248:	89 04 24             	mov    %eax,(%esp)
  10524b:	e8 a8 d9 ff ff       	call   102bf8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105250:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105257:	e8 64 d9 ff ff       	call   102bc0 <alloc_pages>
  10525c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10525f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105262:	83 c0 14             	add    $0x14,%eax
  105265:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  105268:	74 24                	je     10528e <default_check+0x4d1>
  10526a:	c7 44 24 0c d0 6f 10 	movl   $0x106fd0,0xc(%esp)
  105271:	00 
  105272:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105279:	00 
  10527a:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  105281:	00 
  105282:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105289:	e8 4f b1 ff ff       	call   1003dd <__panic>

    free_pages(p0, 2);
  10528e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105295:	00 
  105296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105299:	89 04 24             	mov    %eax,(%esp)
  10529c:	e8 57 d9 ff ff       	call   102bf8 <free_pages>
    free_page(p2);
  1052a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052a8:	00 
  1052a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1052ac:	89 04 24             	mov    %eax,(%esp)
  1052af:	e8 44 d9 ff ff       	call   102bf8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1052b4:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1052bb:	e8 00 d9 ff ff       	call   102bc0 <alloc_pages>
  1052c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1052c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1052c7:	75 24                	jne    1052ed <default_check+0x530>
  1052c9:	c7 44 24 0c f0 6f 10 	movl   $0x106ff0,0xc(%esp)
  1052d0:	00 
  1052d1:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1052d8:	00 
  1052d9:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  1052e0:	00 
  1052e1:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1052e8:	e8 f0 b0 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  1052ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052f4:	e8 c7 d8 ff ff       	call   102bc0 <alloc_pages>
  1052f9:	85 c0                	test   %eax,%eax
  1052fb:	74 24                	je     105321 <default_check+0x564>
  1052fd:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  105304:	00 
  105305:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  10530c:	00 
  10530d:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
  105314:	00 
  105315:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  10531c:	e8 bc b0 ff ff       	call   1003dd <__panic>

    assert(nr_free == 0);
  105321:	a1 64 89 11 00       	mov    0x118964,%eax
  105326:	85 c0                	test   %eax,%eax
  105328:	74 24                	je     10534e <default_check+0x591>
  10532a:	c7 44 24 0c a1 6e 10 	movl   $0x106ea1,0xc(%esp)
  105331:	00 
  105332:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  105339:	00 
  10533a:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  105341:	00 
  105342:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105349:	e8 8f b0 ff ff       	call   1003dd <__panic>
    nr_free = nr_free_store;
  10534e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105351:	a3 64 89 11 00       	mov    %eax,0x118964

    free_list = free_list_store;
  105356:	8b 45 80             	mov    -0x80(%ebp),%eax
  105359:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10535c:	a3 5c 89 11 00       	mov    %eax,0x11895c
  105361:	89 15 60 89 11 00    	mov    %edx,0x118960
    free_pages(p0, 5);
  105367:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10536e:	00 
  10536f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105372:	89 04 24             	mov    %eax,(%esp)
  105375:	e8 7e d8 ff ff       	call   102bf8 <free_pages>

    le = &free_list;
  10537a:	c7 45 ec 5c 89 11 00 	movl   $0x11895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105381:	eb 1d                	jmp    1053a0 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  105383:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105386:	83 e8 0c             	sub    $0xc,%eax
  105389:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  10538c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  105390:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105393:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105396:	8b 40 08             	mov    0x8(%eax),%eax
  105399:	29 c2                	sub    %eax,%edx
  10539b:	89 d0                	mov    %edx,%eax
  10539d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053a3:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  1053a6:	8b 45 88             	mov    -0x78(%ebp),%eax
  1053a9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1053ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1053af:	81 7d ec 5c 89 11 00 	cmpl   $0x11895c,-0x14(%ebp)
  1053b6:	75 cb                	jne    105383 <default_check+0x5c6>
    }
    assert(count == 0);
  1053b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1053bc:	74 24                	je     1053e2 <default_check+0x625>
  1053be:	c7 44 24 0c 0e 70 10 	movl   $0x10700e,0xc(%esp)
  1053c5:	00 
  1053c6:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1053cd:	00 
  1053ce:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  1053d5:	00 
  1053d6:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  1053dd:	e8 fb af ff ff       	call   1003dd <__panic>
    assert(total == 0);
  1053e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1053e6:	74 24                	je     10540c <default_check+0x64f>
  1053e8:	c7 44 24 0c 19 70 10 	movl   $0x107019,0xc(%esp)
  1053ef:	00 
  1053f0:	c7 44 24 08 de 6c 10 	movl   $0x106cde,0x8(%esp)
  1053f7:	00 
  1053f8:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  1053ff:	00 
  105400:	c7 04 24 f3 6c 10 00 	movl   $0x106cf3,(%esp)
  105407:	e8 d1 af ff ff       	call   1003dd <__panic>
}
  10540c:	81 c4 94 00 00 00    	add    $0x94,%esp
  105412:	5b                   	pop    %ebx
  105413:	5d                   	pop    %ebp
  105414:	c3                   	ret    

00105415 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105415:	55                   	push   %ebp
  105416:	89 e5                	mov    %esp,%ebp
  105418:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10541b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105422:	eb 04                	jmp    105428 <strlen+0x13>
        cnt ++;
  105424:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  105428:	8b 45 08             	mov    0x8(%ebp),%eax
  10542b:	8d 50 01             	lea    0x1(%eax),%edx
  10542e:	89 55 08             	mov    %edx,0x8(%ebp)
  105431:	0f b6 00             	movzbl (%eax),%eax
  105434:	84 c0                	test   %al,%al
  105436:	75 ec                	jne    105424 <strlen+0xf>
    }
    return cnt;
  105438:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10543b:	c9                   	leave  
  10543c:	c3                   	ret    

0010543d <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10543d:	55                   	push   %ebp
  10543e:	89 e5                	mov    %esp,%ebp
  105440:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105443:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10544a:	eb 04                	jmp    105450 <strnlen+0x13>
        cnt ++;
  10544c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105450:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105453:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105456:	73 10                	jae    105468 <strnlen+0x2b>
  105458:	8b 45 08             	mov    0x8(%ebp),%eax
  10545b:	8d 50 01             	lea    0x1(%eax),%edx
  10545e:	89 55 08             	mov    %edx,0x8(%ebp)
  105461:	0f b6 00             	movzbl (%eax),%eax
  105464:	84 c0                	test   %al,%al
  105466:	75 e4                	jne    10544c <strnlen+0xf>
    }
    return cnt;
  105468:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10546b:	c9                   	leave  
  10546c:	c3                   	ret    

0010546d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10546d:	55                   	push   %ebp
  10546e:	89 e5                	mov    %esp,%ebp
  105470:	57                   	push   %edi
  105471:	56                   	push   %esi
  105472:	83 ec 20             	sub    $0x20,%esp
  105475:	8b 45 08             	mov    0x8(%ebp),%eax
  105478:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10547b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10547e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105484:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105487:	89 d1                	mov    %edx,%ecx
  105489:	89 c2                	mov    %eax,%edx
  10548b:	89 ce                	mov    %ecx,%esi
  10548d:	89 d7                	mov    %edx,%edi
  10548f:	ac                   	lods   %ds:(%esi),%al
  105490:	aa                   	stos   %al,%es:(%edi)
  105491:	84 c0                	test   %al,%al
  105493:	75 fa                	jne    10548f <strcpy+0x22>
  105495:	89 fa                	mov    %edi,%edx
  105497:	89 f1                	mov    %esi,%ecx
  105499:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10549c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  10549f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1054a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1054a5:	83 c4 20             	add    $0x20,%esp
  1054a8:	5e                   	pop    %esi
  1054a9:	5f                   	pop    %edi
  1054aa:	5d                   	pop    %ebp
  1054ab:	c3                   	ret    

001054ac <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1054ac:	55                   	push   %ebp
  1054ad:	89 e5                	mov    %esp,%ebp
  1054af:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1054b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1054b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1054b8:	eb 21                	jmp    1054db <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  1054ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054bd:	0f b6 10             	movzbl (%eax),%edx
  1054c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1054c3:	88 10                	mov    %dl,(%eax)
  1054c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1054c8:	0f b6 00             	movzbl (%eax),%eax
  1054cb:	84 c0                	test   %al,%al
  1054cd:	74 04                	je     1054d3 <strncpy+0x27>
            src ++;
  1054cf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1054d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1054d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  1054db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054df:	75 d9                	jne    1054ba <strncpy+0xe>
    }
    return dst;
  1054e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1054e4:	c9                   	leave  
  1054e5:	c3                   	ret    

001054e6 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1054e6:	55                   	push   %ebp
  1054e7:	89 e5                	mov    %esp,%ebp
  1054e9:	57                   	push   %edi
  1054ea:	56                   	push   %esi
  1054eb:	83 ec 20             	sub    $0x20,%esp
  1054ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1054fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105500:	89 d1                	mov    %edx,%ecx
  105502:	89 c2                	mov    %eax,%edx
  105504:	89 ce                	mov    %ecx,%esi
  105506:	89 d7                	mov    %edx,%edi
  105508:	ac                   	lods   %ds:(%esi),%al
  105509:	ae                   	scas   %es:(%edi),%al
  10550a:	75 08                	jne    105514 <strcmp+0x2e>
  10550c:	84 c0                	test   %al,%al
  10550e:	75 f8                	jne    105508 <strcmp+0x22>
  105510:	31 c0                	xor    %eax,%eax
  105512:	eb 04                	jmp    105518 <strcmp+0x32>
  105514:	19 c0                	sbb    %eax,%eax
  105516:	0c 01                	or     $0x1,%al
  105518:	89 fa                	mov    %edi,%edx
  10551a:	89 f1                	mov    %esi,%ecx
  10551c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10551f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105522:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105525:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105528:	83 c4 20             	add    $0x20,%esp
  10552b:	5e                   	pop    %esi
  10552c:	5f                   	pop    %edi
  10552d:	5d                   	pop    %ebp
  10552e:	c3                   	ret    

0010552f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10552f:	55                   	push   %ebp
  105530:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105532:	eb 0c                	jmp    105540 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105534:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105538:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10553c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105540:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105544:	74 1a                	je     105560 <strncmp+0x31>
  105546:	8b 45 08             	mov    0x8(%ebp),%eax
  105549:	0f b6 00             	movzbl (%eax),%eax
  10554c:	84 c0                	test   %al,%al
  10554e:	74 10                	je     105560 <strncmp+0x31>
  105550:	8b 45 08             	mov    0x8(%ebp),%eax
  105553:	0f b6 10             	movzbl (%eax),%edx
  105556:	8b 45 0c             	mov    0xc(%ebp),%eax
  105559:	0f b6 00             	movzbl (%eax),%eax
  10555c:	38 c2                	cmp    %al,%dl
  10555e:	74 d4                	je     105534 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105560:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105564:	74 18                	je     10557e <strncmp+0x4f>
  105566:	8b 45 08             	mov    0x8(%ebp),%eax
  105569:	0f b6 00             	movzbl (%eax),%eax
  10556c:	0f b6 d0             	movzbl %al,%edx
  10556f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105572:	0f b6 00             	movzbl (%eax),%eax
  105575:	0f b6 c0             	movzbl %al,%eax
  105578:	29 c2                	sub    %eax,%edx
  10557a:	89 d0                	mov    %edx,%eax
  10557c:	eb 05                	jmp    105583 <strncmp+0x54>
  10557e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105583:	5d                   	pop    %ebp
  105584:	c3                   	ret    

00105585 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105585:	55                   	push   %ebp
  105586:	89 e5                	mov    %esp,%ebp
  105588:	83 ec 04             	sub    $0x4,%esp
  10558b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10558e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105591:	eb 14                	jmp    1055a7 <strchr+0x22>
        if (*s == c) {
  105593:	8b 45 08             	mov    0x8(%ebp),%eax
  105596:	0f b6 00             	movzbl (%eax),%eax
  105599:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10559c:	75 05                	jne    1055a3 <strchr+0x1e>
            return (char *)s;
  10559e:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a1:	eb 13                	jmp    1055b6 <strchr+0x31>
        }
        s ++;
  1055a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  1055a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055aa:	0f b6 00             	movzbl (%eax),%eax
  1055ad:	84 c0                	test   %al,%al
  1055af:	75 e2                	jne    105593 <strchr+0xe>
    }
    return NULL;
  1055b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1055b6:	c9                   	leave  
  1055b7:	c3                   	ret    

001055b8 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1055b8:	55                   	push   %ebp
  1055b9:	89 e5                	mov    %esp,%ebp
  1055bb:	83 ec 04             	sub    $0x4,%esp
  1055be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055c1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1055c4:	eb 11                	jmp    1055d7 <strfind+0x1f>
        if (*s == c) {
  1055c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c9:	0f b6 00             	movzbl (%eax),%eax
  1055cc:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1055cf:	75 02                	jne    1055d3 <strfind+0x1b>
            break;
  1055d1:	eb 0e                	jmp    1055e1 <strfind+0x29>
        }
        s ++;
  1055d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  1055d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055da:	0f b6 00             	movzbl (%eax),%eax
  1055dd:	84 c0                	test   %al,%al
  1055df:	75 e5                	jne    1055c6 <strfind+0xe>
    }
    return (char *)s;
  1055e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1055e4:	c9                   	leave  
  1055e5:	c3                   	ret    

001055e6 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1055e6:	55                   	push   %ebp
  1055e7:	89 e5                	mov    %esp,%ebp
  1055e9:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1055ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1055f3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1055fa:	eb 04                	jmp    105600 <strtol+0x1a>
        s ++;
  1055fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105600:	8b 45 08             	mov    0x8(%ebp),%eax
  105603:	0f b6 00             	movzbl (%eax),%eax
  105606:	3c 20                	cmp    $0x20,%al
  105608:	74 f2                	je     1055fc <strtol+0x16>
  10560a:	8b 45 08             	mov    0x8(%ebp),%eax
  10560d:	0f b6 00             	movzbl (%eax),%eax
  105610:	3c 09                	cmp    $0x9,%al
  105612:	74 e8                	je     1055fc <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105614:	8b 45 08             	mov    0x8(%ebp),%eax
  105617:	0f b6 00             	movzbl (%eax),%eax
  10561a:	3c 2b                	cmp    $0x2b,%al
  10561c:	75 06                	jne    105624 <strtol+0x3e>
        s ++;
  10561e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105622:	eb 15                	jmp    105639 <strtol+0x53>
    }
    else if (*s == '-') {
  105624:	8b 45 08             	mov    0x8(%ebp),%eax
  105627:	0f b6 00             	movzbl (%eax),%eax
  10562a:	3c 2d                	cmp    $0x2d,%al
  10562c:	75 0b                	jne    105639 <strtol+0x53>
        s ++, neg = 1;
  10562e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105632:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105639:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10563d:	74 06                	je     105645 <strtol+0x5f>
  10563f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105643:	75 24                	jne    105669 <strtol+0x83>
  105645:	8b 45 08             	mov    0x8(%ebp),%eax
  105648:	0f b6 00             	movzbl (%eax),%eax
  10564b:	3c 30                	cmp    $0x30,%al
  10564d:	75 1a                	jne    105669 <strtol+0x83>
  10564f:	8b 45 08             	mov    0x8(%ebp),%eax
  105652:	83 c0 01             	add    $0x1,%eax
  105655:	0f b6 00             	movzbl (%eax),%eax
  105658:	3c 78                	cmp    $0x78,%al
  10565a:	75 0d                	jne    105669 <strtol+0x83>
        s += 2, base = 16;
  10565c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105660:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105667:	eb 2a                	jmp    105693 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105669:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10566d:	75 17                	jne    105686 <strtol+0xa0>
  10566f:	8b 45 08             	mov    0x8(%ebp),%eax
  105672:	0f b6 00             	movzbl (%eax),%eax
  105675:	3c 30                	cmp    $0x30,%al
  105677:	75 0d                	jne    105686 <strtol+0xa0>
        s ++, base = 8;
  105679:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10567d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105684:	eb 0d                	jmp    105693 <strtol+0xad>
    }
    else if (base == 0) {
  105686:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10568a:	75 07                	jne    105693 <strtol+0xad>
        base = 10;
  10568c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105693:	8b 45 08             	mov    0x8(%ebp),%eax
  105696:	0f b6 00             	movzbl (%eax),%eax
  105699:	3c 2f                	cmp    $0x2f,%al
  10569b:	7e 1b                	jle    1056b8 <strtol+0xd2>
  10569d:	8b 45 08             	mov    0x8(%ebp),%eax
  1056a0:	0f b6 00             	movzbl (%eax),%eax
  1056a3:	3c 39                	cmp    $0x39,%al
  1056a5:	7f 11                	jg     1056b8 <strtol+0xd2>
            dig = *s - '0';
  1056a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1056aa:	0f b6 00             	movzbl (%eax),%eax
  1056ad:	0f be c0             	movsbl %al,%eax
  1056b0:	83 e8 30             	sub    $0x30,%eax
  1056b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056b6:	eb 48                	jmp    105700 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1056b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1056bb:	0f b6 00             	movzbl (%eax),%eax
  1056be:	3c 60                	cmp    $0x60,%al
  1056c0:	7e 1b                	jle    1056dd <strtol+0xf7>
  1056c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1056c5:	0f b6 00             	movzbl (%eax),%eax
  1056c8:	3c 7a                	cmp    $0x7a,%al
  1056ca:	7f 11                	jg     1056dd <strtol+0xf7>
            dig = *s - 'a' + 10;
  1056cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cf:	0f b6 00             	movzbl (%eax),%eax
  1056d2:	0f be c0             	movsbl %al,%eax
  1056d5:	83 e8 57             	sub    $0x57,%eax
  1056d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056db:	eb 23                	jmp    105700 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1056dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1056e0:	0f b6 00             	movzbl (%eax),%eax
  1056e3:	3c 40                	cmp    $0x40,%al
  1056e5:	7e 3d                	jle    105724 <strtol+0x13e>
  1056e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1056ea:	0f b6 00             	movzbl (%eax),%eax
  1056ed:	3c 5a                	cmp    $0x5a,%al
  1056ef:	7f 33                	jg     105724 <strtol+0x13e>
            dig = *s - 'A' + 10;
  1056f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f4:	0f b6 00             	movzbl (%eax),%eax
  1056f7:	0f be c0             	movsbl %al,%eax
  1056fa:	83 e8 37             	sub    $0x37,%eax
  1056fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105703:	3b 45 10             	cmp    0x10(%ebp),%eax
  105706:	7c 02                	jl     10570a <strtol+0x124>
            break;
  105708:	eb 1a                	jmp    105724 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  10570a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10570e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105711:	0f af 45 10          	imul   0x10(%ebp),%eax
  105715:	89 c2                	mov    %eax,%edx
  105717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10571a:	01 d0                	add    %edx,%eax
  10571c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  10571f:	e9 6f ff ff ff       	jmp    105693 <strtol+0xad>

    if (endptr) {
  105724:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105728:	74 08                	je     105732 <strtol+0x14c>
        *endptr = (char *) s;
  10572a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10572d:	8b 55 08             	mov    0x8(%ebp),%edx
  105730:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105732:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105736:	74 07                	je     10573f <strtol+0x159>
  105738:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10573b:	f7 d8                	neg    %eax
  10573d:	eb 03                	jmp    105742 <strtol+0x15c>
  10573f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105742:	c9                   	leave  
  105743:	c3                   	ret    

00105744 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105744:	55                   	push   %ebp
  105745:	89 e5                	mov    %esp,%ebp
  105747:	57                   	push   %edi
  105748:	83 ec 24             	sub    $0x24,%esp
  10574b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10574e:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105751:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105755:	8b 55 08             	mov    0x8(%ebp),%edx
  105758:	89 55 f8             	mov    %edx,-0x8(%ebp)
  10575b:	88 45 f7             	mov    %al,-0x9(%ebp)
  10575e:	8b 45 10             	mov    0x10(%ebp),%eax
  105761:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105764:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105767:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10576b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10576e:	89 d7                	mov    %edx,%edi
  105770:	f3 aa                	rep stos %al,%es:(%edi)
  105772:	89 fa                	mov    %edi,%edx
  105774:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105777:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  10577a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  10577d:	83 c4 24             	add    $0x24,%esp
  105780:	5f                   	pop    %edi
  105781:	5d                   	pop    %ebp
  105782:	c3                   	ret    

00105783 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105783:	55                   	push   %ebp
  105784:	89 e5                	mov    %esp,%ebp
  105786:	57                   	push   %edi
  105787:	56                   	push   %esi
  105788:	53                   	push   %ebx
  105789:	83 ec 30             	sub    $0x30,%esp
  10578c:	8b 45 08             	mov    0x8(%ebp),%eax
  10578f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105792:	8b 45 0c             	mov    0xc(%ebp),%eax
  105795:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105798:	8b 45 10             	mov    0x10(%ebp),%eax
  10579b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  10579e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1057a4:	73 42                	jae    1057e8 <memmove+0x65>
  1057a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1057ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1057b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1057b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1057bb:	c1 e8 02             	shr    $0x2,%eax
  1057be:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1057c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1057c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057c6:	89 d7                	mov    %edx,%edi
  1057c8:	89 c6                	mov    %eax,%esi
  1057ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1057cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1057cf:	83 e1 03             	and    $0x3,%ecx
  1057d2:	74 02                	je     1057d6 <memmove+0x53>
  1057d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1057d6:	89 f0                	mov    %esi,%eax
  1057d8:	89 fa                	mov    %edi,%edx
  1057da:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1057dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1057e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1057e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057e6:	eb 36                	jmp    10581e <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1057e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057eb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1057ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057f1:	01 c2                	add    %eax,%edx
  1057f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057f6:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1057f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057fc:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1057ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105802:	89 c1                	mov    %eax,%ecx
  105804:	89 d8                	mov    %ebx,%eax
  105806:	89 d6                	mov    %edx,%esi
  105808:	89 c7                	mov    %eax,%edi
  10580a:	fd                   	std    
  10580b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10580d:	fc                   	cld    
  10580e:	89 f8                	mov    %edi,%eax
  105810:	89 f2                	mov    %esi,%edx
  105812:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105815:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105818:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10581b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10581e:	83 c4 30             	add    $0x30,%esp
  105821:	5b                   	pop    %ebx
  105822:	5e                   	pop    %esi
  105823:	5f                   	pop    %edi
  105824:	5d                   	pop    %ebp
  105825:	c3                   	ret    

00105826 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105826:	55                   	push   %ebp
  105827:	89 e5                	mov    %esp,%ebp
  105829:	57                   	push   %edi
  10582a:	56                   	push   %esi
  10582b:	83 ec 20             	sub    $0x20,%esp
  10582e:	8b 45 08             	mov    0x8(%ebp),%eax
  105831:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105834:	8b 45 0c             	mov    0xc(%ebp),%eax
  105837:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10583a:	8b 45 10             	mov    0x10(%ebp),%eax
  10583d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105840:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105843:	c1 e8 02             	shr    $0x2,%eax
  105846:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105848:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10584b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10584e:	89 d7                	mov    %edx,%edi
  105850:	89 c6                	mov    %eax,%esi
  105852:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105854:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105857:	83 e1 03             	and    $0x3,%ecx
  10585a:	74 02                	je     10585e <memcpy+0x38>
  10585c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10585e:	89 f0                	mov    %esi,%eax
  105860:	89 fa                	mov    %edi,%edx
  105862:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105865:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105868:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10586b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  10586e:	83 c4 20             	add    $0x20,%esp
  105871:	5e                   	pop    %esi
  105872:	5f                   	pop    %edi
  105873:	5d                   	pop    %ebp
  105874:	c3                   	ret    

00105875 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105875:	55                   	push   %ebp
  105876:	89 e5                	mov    %esp,%ebp
  105878:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  10587b:	8b 45 08             	mov    0x8(%ebp),%eax
  10587e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105881:	8b 45 0c             	mov    0xc(%ebp),%eax
  105884:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105887:	eb 30                	jmp    1058b9 <memcmp+0x44>
        if (*s1 != *s2) {
  105889:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10588c:	0f b6 10             	movzbl (%eax),%edx
  10588f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105892:	0f b6 00             	movzbl (%eax),%eax
  105895:	38 c2                	cmp    %al,%dl
  105897:	74 18                	je     1058b1 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105899:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10589c:	0f b6 00             	movzbl (%eax),%eax
  10589f:	0f b6 d0             	movzbl %al,%edx
  1058a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058a5:	0f b6 00             	movzbl (%eax),%eax
  1058a8:	0f b6 c0             	movzbl %al,%eax
  1058ab:	29 c2                	sub    %eax,%edx
  1058ad:	89 d0                	mov    %edx,%eax
  1058af:	eb 1a                	jmp    1058cb <memcmp+0x56>
        }
        s1 ++, s2 ++;
  1058b1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1058b5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  1058b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1058bc:	8d 50 ff             	lea    -0x1(%eax),%edx
  1058bf:	89 55 10             	mov    %edx,0x10(%ebp)
  1058c2:	85 c0                	test   %eax,%eax
  1058c4:	75 c3                	jne    105889 <memcmp+0x14>
    }
    return 0;
  1058c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1058cb:	c9                   	leave  
  1058cc:	c3                   	ret    

001058cd <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1058cd:	55                   	push   %ebp
  1058ce:	89 e5                	mov    %esp,%ebp
  1058d0:	83 ec 58             	sub    $0x58,%esp
  1058d3:	8b 45 10             	mov    0x10(%ebp),%eax
  1058d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1058d9:	8b 45 14             	mov    0x14(%ebp),%eax
  1058dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1058df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1058e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1058e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1058e8:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1058eb:	8b 45 18             	mov    0x18(%ebp),%eax
  1058ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1058f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1058f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1058f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1058fa:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1058fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105900:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105903:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105907:	74 1c                	je     105925 <printnum+0x58>
  105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10590c:	ba 00 00 00 00       	mov    $0x0,%edx
  105911:	f7 75 e4             	divl   -0x1c(%ebp)
  105914:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10591a:	ba 00 00 00 00       	mov    $0x0,%edx
  10591f:	f7 75 e4             	divl   -0x1c(%ebp)
  105922:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105925:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105928:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10592b:	f7 75 e4             	divl   -0x1c(%ebp)
  10592e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105931:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105934:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105937:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10593a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10593d:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105940:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105943:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105946:	8b 45 18             	mov    0x18(%ebp),%eax
  105949:	ba 00 00 00 00       	mov    $0x0,%edx
  10594e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105951:	77 56                	ja     1059a9 <printnum+0xdc>
  105953:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105956:	72 05                	jb     10595d <printnum+0x90>
  105958:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  10595b:	77 4c                	ja     1059a9 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  10595d:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105960:	8d 50 ff             	lea    -0x1(%eax),%edx
  105963:	8b 45 20             	mov    0x20(%ebp),%eax
  105966:	89 44 24 18          	mov    %eax,0x18(%esp)
  10596a:	89 54 24 14          	mov    %edx,0x14(%esp)
  10596e:	8b 45 18             	mov    0x18(%ebp),%eax
  105971:	89 44 24 10          	mov    %eax,0x10(%esp)
  105975:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105978:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10597b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10597f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105983:	8b 45 0c             	mov    0xc(%ebp),%eax
  105986:	89 44 24 04          	mov    %eax,0x4(%esp)
  10598a:	8b 45 08             	mov    0x8(%ebp),%eax
  10598d:	89 04 24             	mov    %eax,(%esp)
  105990:	e8 38 ff ff ff       	call   1058cd <printnum>
  105995:	eb 1c                	jmp    1059b3 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105997:	8b 45 0c             	mov    0xc(%ebp),%eax
  10599a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10599e:	8b 45 20             	mov    0x20(%ebp),%eax
  1059a1:	89 04 24             	mov    %eax,(%esp)
  1059a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a7:	ff d0                	call   *%eax
        while (-- width > 0)
  1059a9:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1059ad:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1059b1:	7f e4                	jg     105997 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1059b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1059b6:	05 d4 70 10 00       	add    $0x1070d4,%eax
  1059bb:	0f b6 00             	movzbl (%eax),%eax
  1059be:	0f be c0             	movsbl %al,%eax
  1059c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  1059c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1059c8:	89 04 24             	mov    %eax,(%esp)
  1059cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ce:	ff d0                	call   *%eax
}
  1059d0:	c9                   	leave  
  1059d1:	c3                   	ret    

001059d2 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1059d2:	55                   	push   %ebp
  1059d3:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1059d5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1059d9:	7e 14                	jle    1059ef <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1059db:	8b 45 08             	mov    0x8(%ebp),%eax
  1059de:	8b 00                	mov    (%eax),%eax
  1059e0:	8d 48 08             	lea    0x8(%eax),%ecx
  1059e3:	8b 55 08             	mov    0x8(%ebp),%edx
  1059e6:	89 0a                	mov    %ecx,(%edx)
  1059e8:	8b 50 04             	mov    0x4(%eax),%edx
  1059eb:	8b 00                	mov    (%eax),%eax
  1059ed:	eb 30                	jmp    105a1f <getuint+0x4d>
    }
    else if (lflag) {
  1059ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1059f3:	74 16                	je     105a0b <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1059f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1059f8:	8b 00                	mov    (%eax),%eax
  1059fa:	8d 48 04             	lea    0x4(%eax),%ecx
  1059fd:	8b 55 08             	mov    0x8(%ebp),%edx
  105a00:	89 0a                	mov    %ecx,(%edx)
  105a02:	8b 00                	mov    (%eax),%eax
  105a04:	ba 00 00 00 00       	mov    $0x0,%edx
  105a09:	eb 14                	jmp    105a1f <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a0e:	8b 00                	mov    (%eax),%eax
  105a10:	8d 48 04             	lea    0x4(%eax),%ecx
  105a13:	8b 55 08             	mov    0x8(%ebp),%edx
  105a16:	89 0a                	mov    %ecx,(%edx)
  105a18:	8b 00                	mov    (%eax),%eax
  105a1a:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105a1f:	5d                   	pop    %ebp
  105a20:	c3                   	ret    

00105a21 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105a21:	55                   	push   %ebp
  105a22:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105a24:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105a28:	7e 14                	jle    105a3e <getint+0x1d>
        return va_arg(*ap, long long);
  105a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  105a2d:	8b 00                	mov    (%eax),%eax
  105a2f:	8d 48 08             	lea    0x8(%eax),%ecx
  105a32:	8b 55 08             	mov    0x8(%ebp),%edx
  105a35:	89 0a                	mov    %ecx,(%edx)
  105a37:	8b 50 04             	mov    0x4(%eax),%edx
  105a3a:	8b 00                	mov    (%eax),%eax
  105a3c:	eb 28                	jmp    105a66 <getint+0x45>
    }
    else if (lflag) {
  105a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105a42:	74 12                	je     105a56 <getint+0x35>
        return va_arg(*ap, long);
  105a44:	8b 45 08             	mov    0x8(%ebp),%eax
  105a47:	8b 00                	mov    (%eax),%eax
  105a49:	8d 48 04             	lea    0x4(%eax),%ecx
  105a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  105a4f:	89 0a                	mov    %ecx,(%edx)
  105a51:	8b 00                	mov    (%eax),%eax
  105a53:	99                   	cltd   
  105a54:	eb 10                	jmp    105a66 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105a56:	8b 45 08             	mov    0x8(%ebp),%eax
  105a59:	8b 00                	mov    (%eax),%eax
  105a5b:	8d 48 04             	lea    0x4(%eax),%ecx
  105a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  105a61:	89 0a                	mov    %ecx,(%edx)
  105a63:	8b 00                	mov    (%eax),%eax
  105a65:	99                   	cltd   
    }
}
  105a66:	5d                   	pop    %ebp
  105a67:	c3                   	ret    

00105a68 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105a68:	55                   	push   %ebp
  105a69:	89 e5                	mov    %esp,%ebp
  105a6b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105a6e:	8d 45 14             	lea    0x14(%ebp),%eax
  105a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  105a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a89:	8b 45 08             	mov    0x8(%ebp),%eax
  105a8c:	89 04 24             	mov    %eax,(%esp)
  105a8f:	e8 02 00 00 00       	call   105a96 <vprintfmt>
    va_end(ap);
}
  105a94:	c9                   	leave  
  105a95:	c3                   	ret    

00105a96 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105a96:	55                   	push   %ebp
  105a97:	89 e5                	mov    %esp,%ebp
  105a99:	56                   	push   %esi
  105a9a:	53                   	push   %ebx
  105a9b:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a9e:	eb 18                	jmp    105ab8 <vprintfmt+0x22>
            if (ch == '\0') {
  105aa0:	85 db                	test   %ebx,%ebx
  105aa2:	75 05                	jne    105aa9 <vprintfmt+0x13>
                return;
  105aa4:	e9 d1 03 00 00       	jmp    105e7a <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ab0:	89 1c 24             	mov    %ebx,(%esp)
  105ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ab6:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  105abb:	8d 50 01             	lea    0x1(%eax),%edx
  105abe:	89 55 10             	mov    %edx,0x10(%ebp)
  105ac1:	0f b6 00             	movzbl (%eax),%eax
  105ac4:	0f b6 d8             	movzbl %al,%ebx
  105ac7:	83 fb 25             	cmp    $0x25,%ebx
  105aca:	75 d4                	jne    105aa0 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105acc:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105ad0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ada:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105add:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105ae4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ae7:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105aea:	8b 45 10             	mov    0x10(%ebp),%eax
  105aed:	8d 50 01             	lea    0x1(%eax),%edx
  105af0:	89 55 10             	mov    %edx,0x10(%ebp)
  105af3:	0f b6 00             	movzbl (%eax),%eax
  105af6:	0f b6 d8             	movzbl %al,%ebx
  105af9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105afc:	83 f8 55             	cmp    $0x55,%eax
  105aff:	0f 87 44 03 00 00    	ja     105e49 <vprintfmt+0x3b3>
  105b05:	8b 04 85 f8 70 10 00 	mov    0x1070f8(,%eax,4),%eax
  105b0c:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105b0e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105b12:	eb d6                	jmp    105aea <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105b14:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105b18:	eb d0                	jmp    105aea <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105b1a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105b21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105b24:	89 d0                	mov    %edx,%eax
  105b26:	c1 e0 02             	shl    $0x2,%eax
  105b29:	01 d0                	add    %edx,%eax
  105b2b:	01 c0                	add    %eax,%eax
  105b2d:	01 d8                	add    %ebx,%eax
  105b2f:	83 e8 30             	sub    $0x30,%eax
  105b32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105b35:	8b 45 10             	mov    0x10(%ebp),%eax
  105b38:	0f b6 00             	movzbl (%eax),%eax
  105b3b:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105b3e:	83 fb 2f             	cmp    $0x2f,%ebx
  105b41:	7e 0b                	jle    105b4e <vprintfmt+0xb8>
  105b43:	83 fb 39             	cmp    $0x39,%ebx
  105b46:	7f 06                	jg     105b4e <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  105b48:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  105b4c:	eb d3                	jmp    105b21 <vprintfmt+0x8b>
            goto process_precision;
  105b4e:	eb 33                	jmp    105b83 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  105b50:	8b 45 14             	mov    0x14(%ebp),%eax
  105b53:	8d 50 04             	lea    0x4(%eax),%edx
  105b56:	89 55 14             	mov    %edx,0x14(%ebp)
  105b59:	8b 00                	mov    (%eax),%eax
  105b5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105b5e:	eb 23                	jmp    105b83 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  105b60:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b64:	79 0c                	jns    105b72 <vprintfmt+0xdc>
                width = 0;
  105b66:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105b6d:	e9 78 ff ff ff       	jmp    105aea <vprintfmt+0x54>
  105b72:	e9 73 ff ff ff       	jmp    105aea <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105b77:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105b7e:	e9 67 ff ff ff       	jmp    105aea <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105b83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b87:	79 12                	jns    105b9b <vprintfmt+0x105>
                width = precision, precision = -1;
  105b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b8f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105b96:	e9 4f ff ff ff       	jmp    105aea <vprintfmt+0x54>
  105b9b:	e9 4a ff ff ff       	jmp    105aea <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105ba0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105ba4:	e9 41 ff ff ff       	jmp    105aea <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105ba9:	8b 45 14             	mov    0x14(%ebp),%eax
  105bac:	8d 50 04             	lea    0x4(%eax),%edx
  105baf:	89 55 14             	mov    %edx,0x14(%ebp)
  105bb2:	8b 00                	mov    (%eax),%eax
  105bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  105bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  105bbb:	89 04 24             	mov    %eax,(%esp)
  105bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc1:	ff d0                	call   *%eax
            break;
  105bc3:	e9 ac 02 00 00       	jmp    105e74 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  105bcb:	8d 50 04             	lea    0x4(%eax),%edx
  105bce:	89 55 14             	mov    %edx,0x14(%ebp)
  105bd1:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105bd3:	85 db                	test   %ebx,%ebx
  105bd5:	79 02                	jns    105bd9 <vprintfmt+0x143>
                err = -err;
  105bd7:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105bd9:	83 fb 06             	cmp    $0x6,%ebx
  105bdc:	7f 0b                	jg     105be9 <vprintfmt+0x153>
  105bde:	8b 34 9d b8 70 10 00 	mov    0x1070b8(,%ebx,4),%esi
  105be5:	85 f6                	test   %esi,%esi
  105be7:	75 23                	jne    105c0c <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105be9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105bed:	c7 44 24 08 e5 70 10 	movl   $0x1070e5,0x8(%esp)
  105bf4:	00 
  105bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  105bff:	89 04 24             	mov    %eax,(%esp)
  105c02:	e8 61 fe ff ff       	call   105a68 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105c07:	e9 68 02 00 00       	jmp    105e74 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  105c0c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105c10:	c7 44 24 08 ee 70 10 	movl   $0x1070ee,0x8(%esp)
  105c17:	00 
  105c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c22:	89 04 24             	mov    %eax,(%esp)
  105c25:	e8 3e fe ff ff       	call   105a68 <printfmt>
            break;
  105c2a:	e9 45 02 00 00       	jmp    105e74 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105c2f:	8b 45 14             	mov    0x14(%ebp),%eax
  105c32:	8d 50 04             	lea    0x4(%eax),%edx
  105c35:	89 55 14             	mov    %edx,0x14(%ebp)
  105c38:	8b 30                	mov    (%eax),%esi
  105c3a:	85 f6                	test   %esi,%esi
  105c3c:	75 05                	jne    105c43 <vprintfmt+0x1ad>
                p = "(null)";
  105c3e:	be f1 70 10 00       	mov    $0x1070f1,%esi
            }
            if (width > 0 && padc != '-') {
  105c43:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c47:	7e 3e                	jle    105c87 <vprintfmt+0x1f1>
  105c49:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105c4d:	74 38                	je     105c87 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c4f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c59:	89 34 24             	mov    %esi,(%esp)
  105c5c:	e8 dc f7 ff ff       	call   10543d <strnlen>
  105c61:	29 c3                	sub    %eax,%ebx
  105c63:	89 d8                	mov    %ebx,%eax
  105c65:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105c68:	eb 17                	jmp    105c81 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105c6a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c71:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c75:	89 04 24             	mov    %eax,(%esp)
  105c78:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7b:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c7d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105c81:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c85:	7f e3                	jg     105c6a <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c87:	eb 38                	jmp    105cc1 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105c89:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105c8d:	74 1f                	je     105cae <vprintfmt+0x218>
  105c8f:	83 fb 1f             	cmp    $0x1f,%ebx
  105c92:	7e 05                	jle    105c99 <vprintfmt+0x203>
  105c94:	83 fb 7e             	cmp    $0x7e,%ebx
  105c97:	7e 15                	jle    105cae <vprintfmt+0x218>
                    putch('?', putdat);
  105c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ca0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  105caa:	ff d0                	call   *%eax
  105cac:	eb 0f                	jmp    105cbd <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cb5:	89 1c 24             	mov    %ebx,(%esp)
  105cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  105cbb:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105cbd:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105cc1:	89 f0                	mov    %esi,%eax
  105cc3:	8d 70 01             	lea    0x1(%eax),%esi
  105cc6:	0f b6 00             	movzbl (%eax),%eax
  105cc9:	0f be d8             	movsbl %al,%ebx
  105ccc:	85 db                	test   %ebx,%ebx
  105cce:	74 10                	je     105ce0 <vprintfmt+0x24a>
  105cd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105cd4:	78 b3                	js     105c89 <vprintfmt+0x1f3>
  105cd6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105cda:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105cde:	79 a9                	jns    105c89 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  105ce0:	eb 17                	jmp    105cf9 <vprintfmt+0x263>
                putch(' ', putdat);
  105ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ce9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  105cf3:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105cf5:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105cf9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105cfd:	7f e3                	jg     105ce2 <vprintfmt+0x24c>
            }
            break;
  105cff:	e9 70 01 00 00       	jmp    105e74 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105d04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d0b:	8d 45 14             	lea    0x14(%ebp),%eax
  105d0e:	89 04 24             	mov    %eax,(%esp)
  105d11:	e8 0b fd ff ff       	call   105a21 <getint>
  105d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d19:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d22:	85 d2                	test   %edx,%edx
  105d24:	79 26                	jns    105d4c <vprintfmt+0x2b6>
                putch('-', putdat);
  105d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d29:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d2d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105d34:	8b 45 08             	mov    0x8(%ebp),%eax
  105d37:	ff d0                	call   *%eax
                num = -(long long)num;
  105d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d3f:	f7 d8                	neg    %eax
  105d41:	83 d2 00             	adc    $0x0,%edx
  105d44:	f7 da                	neg    %edx
  105d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d49:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105d4c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d53:	e9 a8 00 00 00       	jmp    105e00 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d5f:	8d 45 14             	lea    0x14(%ebp),%eax
  105d62:	89 04 24             	mov    %eax,(%esp)
  105d65:	e8 68 fc ff ff       	call   1059d2 <getuint>
  105d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d6d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105d70:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d77:	e9 84 00 00 00       	jmp    105e00 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105d7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d83:	8d 45 14             	lea    0x14(%ebp),%eax
  105d86:	89 04 24             	mov    %eax,(%esp)
  105d89:	e8 44 fc ff ff       	call   1059d2 <getuint>
  105d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d91:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105d94:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105d9b:	eb 63                	jmp    105e00 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105da4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105dab:	8b 45 08             	mov    0x8(%ebp),%eax
  105dae:	ff d0                	call   *%eax
            putch('x', putdat);
  105db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105db7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc1:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105dc3:	8b 45 14             	mov    0x14(%ebp),%eax
  105dc6:	8d 50 04             	lea    0x4(%eax),%edx
  105dc9:	89 55 14             	mov    %edx,0x14(%ebp)
  105dcc:	8b 00                	mov    (%eax),%eax
  105dce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105dd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105dd8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105ddf:	eb 1f                	jmp    105e00 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105de1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105de8:	8d 45 14             	lea    0x14(%ebp),%eax
  105deb:	89 04 24             	mov    %eax,(%esp)
  105dee:	e8 df fb ff ff       	call   1059d2 <getuint>
  105df3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105df6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105df9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105e00:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e07:	89 54 24 18          	mov    %edx,0x18(%esp)
  105e0b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105e0e:	89 54 24 14          	mov    %edx,0x14(%esp)
  105e12:	89 44 24 10          	mov    %eax,0x10(%esp)
  105e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e20:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e2e:	89 04 24             	mov    %eax,(%esp)
  105e31:	e8 97 fa ff ff       	call   1058cd <printnum>
            break;
  105e36:	eb 3c                	jmp    105e74 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e3f:	89 1c 24             	mov    %ebx,(%esp)
  105e42:	8b 45 08             	mov    0x8(%ebp),%eax
  105e45:	ff d0                	call   *%eax
            break;
  105e47:	eb 2b                	jmp    105e74 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e50:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105e57:	8b 45 08             	mov    0x8(%ebp),%eax
  105e5a:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105e5c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105e60:	eb 04                	jmp    105e66 <vprintfmt+0x3d0>
  105e62:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105e66:	8b 45 10             	mov    0x10(%ebp),%eax
  105e69:	83 e8 01             	sub    $0x1,%eax
  105e6c:	0f b6 00             	movzbl (%eax),%eax
  105e6f:	3c 25                	cmp    $0x25,%al
  105e71:	75 ef                	jne    105e62 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105e73:	90                   	nop
        }
    }
  105e74:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105e75:	e9 3e fc ff ff       	jmp    105ab8 <vprintfmt+0x22>
}
  105e7a:	83 c4 40             	add    $0x40,%esp
  105e7d:	5b                   	pop    %ebx
  105e7e:	5e                   	pop    %esi
  105e7f:	5d                   	pop    %ebp
  105e80:	c3                   	ret    

00105e81 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105e81:	55                   	push   %ebp
  105e82:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e87:	8b 40 08             	mov    0x8(%eax),%eax
  105e8a:	8d 50 01             	lea    0x1(%eax),%edx
  105e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e90:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e96:	8b 10                	mov    (%eax),%edx
  105e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e9b:	8b 40 04             	mov    0x4(%eax),%eax
  105e9e:	39 c2                	cmp    %eax,%edx
  105ea0:	73 12                	jae    105eb4 <sprintputch+0x33>
        *b->buf ++ = ch;
  105ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ea5:	8b 00                	mov    (%eax),%eax
  105ea7:	8d 48 01             	lea    0x1(%eax),%ecx
  105eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ead:	89 0a                	mov    %ecx,(%edx)
  105eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  105eb2:	88 10                	mov    %dl,(%eax)
    }
}
  105eb4:	5d                   	pop    %ebp
  105eb5:	c3                   	ret    

00105eb6 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105eb6:	55                   	push   %ebp
  105eb7:	89 e5                	mov    %esp,%ebp
  105eb9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105ebc:	8d 45 14             	lea    0x14(%ebp),%eax
  105ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ec5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  105ecc:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  105eda:	89 04 24             	mov    %eax,(%esp)
  105edd:	e8 08 00 00 00       	call   105eea <vsnprintf>
  105ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ee8:	c9                   	leave  
  105ee9:	c3                   	ret    

00105eea <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105eea:	55                   	push   %ebp
  105eeb:	89 e5                	mov    %esp,%ebp
  105eed:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ef3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef9:	8d 50 ff             	lea    -0x1(%eax),%edx
  105efc:	8b 45 08             	mov    0x8(%ebp),%eax
  105eff:	01 d0                	add    %edx,%eax
  105f01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105f0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105f0f:	74 0a                	je     105f1b <vsnprintf+0x31>
  105f11:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f17:	39 c2                	cmp    %eax,%edx
  105f19:	76 07                	jbe    105f22 <vsnprintf+0x38>
        return -E_INVAL;
  105f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105f20:	eb 2a                	jmp    105f4c <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105f22:	8b 45 14             	mov    0x14(%ebp),%eax
  105f25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f29:	8b 45 10             	mov    0x10(%ebp),%eax
  105f2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f30:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f37:	c7 04 24 81 5e 10 00 	movl   $0x105e81,(%esp)
  105f3e:	e8 53 fb ff ff       	call   105a96 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f46:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105f4c:	c9                   	leave  
  105f4d:	c3                   	ret    

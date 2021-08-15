
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
  100051:	e8 3d 55 00 00       	call   105593 <memset>

    cons_init();                // init the console
  100056:	e8 7d 15 00 00       	call   1015d8 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10005b:	c7 45 f4 a0 5d 10 00 	movl   $0x105da0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100065:	89 44 24 04          	mov    %eax,0x4(%esp)
  100069:	c7 04 24 bc 5d 10 00 	movl   $0x105dbc,(%esp)
  100070:	e8 11 02 00 00       	call   100286 <cprintf>

    print_kerninfo();
  100075:	e8 b2 08 00 00       	call   10092c <print_kerninfo>

    grade_backtrace();
  10007a:	e8 86 00 00 00       	call   100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10007f:	e8 3f 31 00 00       	call   1031c3 <pmm_init>

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
  100155:	c7 04 24 c1 5d 10 00 	movl   $0x105dc1,(%esp)
  10015c:	e8 25 01 00 00       	call   100286 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100165:	0f b7 d0             	movzwl %ax,%edx
  100168:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10016d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100171:	89 44 24 04          	mov    %eax,0x4(%esp)
  100175:	c7 04 24 cf 5d 10 00 	movl   $0x105dcf,(%esp)
  10017c:	e8 05 01 00 00       	call   100286 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100185:	0f b7 d0             	movzwl %ax,%edx
  100188:	a1 40 7a 11 00       	mov    0x117a40,%eax
  10018d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100191:	89 44 24 04          	mov    %eax,0x4(%esp)
  100195:	c7 04 24 dd 5d 10 00 	movl   $0x105ddd,(%esp)
  10019c:	e8 e5 00 00 00       	call   100286 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001a5:	0f b7 d0             	movzwl %ax,%edx
  1001a8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b5:	c7 04 24 eb 5d 10 00 	movl   $0x105deb,(%esp)
  1001bc:	e8 c5 00 00 00       	call   100286 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001c5:	0f b7 d0             	movzwl %ax,%edx
  1001c8:	a1 40 7a 11 00       	mov    0x117a40,%eax
  1001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001d5:	c7 04 24 f9 5d 10 00 	movl   $0x105df9,(%esp)
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
  100205:	c7 04 24 08 5e 10 00 	movl   $0x105e08,(%esp)
  10020c:	e8 75 00 00 00       	call   100286 <cprintf>
    lab1_switch_to_user();
  100211:	e8 da ff ff ff       	call   1001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
  100216:	e8 0f ff ff ff       	call   10012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10021b:	c7 04 24 28 5e 10 00 	movl   $0x105e28,(%esp)
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
  10027c:	e8 64 56 00 00       	call   1058e5 <vprintfmt>
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
  10033a:	c7 04 24 47 5e 10 00 	movl   $0x105e47,(%esp)
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
  10040c:	c7 04 24 4a 5e 10 00 	movl   $0x105e4a,(%esp)
  100413:	e8 6e fe ff ff       	call   100286 <cprintf>
    vcprintf(fmt, ap);
  100418:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10041b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10041f:	8b 45 10             	mov    0x10(%ebp),%eax
  100422:	89 04 24             	mov    %eax,(%esp)
  100425:	e8 29 fe ff ff       	call   100253 <vcprintf>
    cprintf("\n");
  10042a:	c7 04 24 66 5e 10 00 	movl   $0x105e66,(%esp)
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
  100463:	c7 04 24 68 5e 10 00 	movl   $0x105e68,(%esp)
  10046a:	e8 17 fe ff ff       	call   100286 <cprintf>
    vcprintf(fmt, ap);
  10046f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100472:	89 44 24 04          	mov    %eax,0x4(%esp)
  100476:	8b 45 10             	mov    0x10(%ebp),%eax
  100479:	89 04 24             	mov    %eax,(%esp)
  10047c:	e8 d2 fd ff ff       	call   100253 <vcprintf>
    cprintf("\n");
  100481:	c7 04 24 66 5e 10 00 	movl   $0x105e66,(%esp)
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
  1005f8:	c7 00 88 5e 10 00    	movl   $0x105e88,(%eax)
    info->eip_line = 0;
  1005fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100601:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100608:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060b:	c7 40 08 88 5e 10 00 	movl   $0x105e88,0x8(%eax)
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
  10062f:	c7 45 f4 90 70 10 00 	movl   $0x107090,-0xc(%ebp)
    stab_end = __STAB_END__;
  100636:	c7 45 f0 40 1a 11 00 	movl   $0x111a40,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10063d:	c7 45 ec 41 1a 11 00 	movl   $0x111a41,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100644:	c7 45 e8 80 44 11 00 	movl   $0x114480,-0x18(%ebp)

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
  1007a3:	e8 5f 4c 00 00       	call   105407 <strfind>
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
  100932:	c7 04 24 92 5e 10 00 	movl   $0x105e92,(%esp)
  100939:	e8 48 f9 ff ff       	call   100286 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10093e:	c7 44 24 04 2a 00 10 	movl   $0x10002a,0x4(%esp)
  100945:	00 
  100946:	c7 04 24 ab 5e 10 00 	movl   $0x105eab,(%esp)
  10094d:	e8 34 f9 ff ff       	call   100286 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100952:	c7 44 24 04 9d 5d 10 	movl   $0x105d9d,0x4(%esp)
  100959:	00 
  10095a:	c7 04 24 c3 5e 10 00 	movl   $0x105ec3,(%esp)
  100961:	e8 20 f9 ff ff       	call   100286 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100966:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  10096d:	00 
  10096e:	c7 04 24 db 5e 10 00 	movl   $0x105edb,(%esp)
  100975:	e8 0c f9 ff ff       	call   100286 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  10097a:	c7 44 24 04 68 89 11 	movl   $0x118968,0x4(%esp)
  100981:	00 
  100982:	c7 04 24 f3 5e 10 00 	movl   $0x105ef3,(%esp)
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
  1009b4:	c7 04 24 0c 5f 10 00 	movl   $0x105f0c,(%esp)
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
  1009e8:	c7 04 24 36 5f 10 00 	movl   $0x105f36,(%esp)
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
  100a57:	c7 04 24 52 5f 10 00 	movl   $0x105f52,(%esp)
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
  100aa9:	c7 04 24 64 5f 10 00 	movl   $0x105f64,(%esp)
  100ab0:	e8 d1 f7 ff ff       	call   100286 <cprintf>
		uint32_t *arg = (uint32_t *)ebp + 2;
  100ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab8:	83 c0 08             	add    $0x8,%eax
  100abb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" arg:");
  100abe:	c7 04 24 7a 5f 10 00 	movl   $0x105f7a,(%esp)
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
  100ae8:	c7 04 24 80 5f 10 00 	movl   $0x105f80,(%esp)
  100aef:	e8 92 f7 ff ff       	call   100286 <cprintf>
		for(j = 0; j < 4; j++) {
  100af4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100afc:	7e d5                	jle    100ad3 <print_stackframe+0x5d>
		}
		cprintf("\n");
  100afe:	c7 04 24 88 5f 10 00 	movl   $0x105f88,(%esp)
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
  100b73:	c7 04 24 0c 60 10 00 	movl   $0x10600c,(%esp)
  100b7a:	e8 55 48 00 00       	call   1053d4 <strchr>
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
  100b9d:	c7 04 24 11 60 10 00 	movl   $0x106011,(%esp)
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
  100be0:	c7 04 24 0c 60 10 00 	movl   $0x10600c,(%esp)
  100be7:	e8 e8 47 00 00       	call   1053d4 <strchr>
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
  100c4c:	e8 e4 46 00 00       	call   105335 <strcmp>
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
  100c9a:	c7 04 24 2f 60 10 00 	movl   $0x10602f,(%esp)
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
  100cb3:	c7 04 24 48 60 10 00 	movl   $0x106048,(%esp)
  100cba:	e8 c7 f5 ff ff       	call   100286 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cbf:	c7 04 24 70 60 10 00 	movl   $0x106070,(%esp)
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
  100cdc:	c7 04 24 95 60 10 00 	movl   $0x106095,(%esp)
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
  100d4b:	c7 04 24 99 60 10 00 	movl   $0x106099,(%esp)
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
  100dd7:	c7 04 24 a2 60 10 00 	movl   $0x1060a2,(%esp)
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
  101201:	e8 cc 43 00 00       	call   1055d2 <memmove>
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
  101587:	c7 04 24 bd 60 10 00 	movl   $0x1060bd,(%esp)
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
  1015f6:	c7 04 24 c9 60 10 00 	movl   $0x1060c9,(%esp)
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
  10188a:	c7 04 24 00 61 10 00 	movl   $0x106100,(%esp)
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
  101a17:	8b 04 85 60 64 10 00 	mov    0x106460(,%eax,4),%eax
  101a1e:	eb 18                	jmp    101a38 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a20:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a24:	7e 0d                	jle    101a33 <trapname+0x2a>
  101a26:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a2a:	7f 07                	jg     101a33 <trapname+0x2a>
        return "Hardware Interrupt";
  101a2c:	b8 0a 61 10 00       	mov    $0x10610a,%eax
  101a31:	eb 05                	jmp    101a38 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a33:	b8 1d 61 10 00       	mov    $0x10611d,%eax
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
  101a5d:	c7 04 24 5e 61 10 00 	movl   $0x10615e,(%esp)
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
  101a82:	c7 04 24 6f 61 10 00 	movl   $0x10616f,(%esp)
  101a89:	e8 f8 e7 ff ff       	call   100286 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a91:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a95:	0f b7 c0             	movzwl %ax,%eax
  101a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9c:	c7 04 24 82 61 10 00 	movl   $0x106182,(%esp)
  101aa3:	e8 de e7 ff ff       	call   100286 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aab:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101aaf:	0f b7 c0             	movzwl %ax,%eax
  101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab6:	c7 04 24 95 61 10 00 	movl   $0x106195,(%esp)
  101abd:	e8 c4 e7 ff ff       	call   100286 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ac9:	0f b7 c0             	movzwl %ax,%eax
  101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad0:	c7 04 24 a8 61 10 00 	movl   $0x1061a8,(%esp)
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
  101af8:	c7 04 24 bb 61 10 00 	movl   $0x1061bb,(%esp)
  101aff:	e8 82 e7 ff ff       	call   100286 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b04:	8b 45 08             	mov    0x8(%ebp),%eax
  101b07:	8b 40 34             	mov    0x34(%eax),%eax
  101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0e:	c7 04 24 cd 61 10 00 	movl   $0x1061cd,(%esp)
  101b15:	e8 6c e7 ff ff       	call   100286 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1d:	8b 40 38             	mov    0x38(%eax),%eax
  101b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b24:	c7 04 24 dc 61 10 00 	movl   $0x1061dc,(%esp)
  101b2b:	e8 56 e7 ff ff       	call   100286 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b30:	8b 45 08             	mov    0x8(%ebp),%eax
  101b33:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b37:	0f b7 c0             	movzwl %ax,%eax
  101b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3e:	c7 04 24 eb 61 10 00 	movl   $0x1061eb,(%esp)
  101b45:	e8 3c e7 ff ff       	call   100286 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4d:	8b 40 40             	mov    0x40(%eax),%eax
  101b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b54:	c7 04 24 fe 61 10 00 	movl   $0x1061fe,(%esp)
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
  101b9b:	c7 04 24 0d 62 10 00 	movl   $0x10620d,(%esp)
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
  101bc8:	c7 04 24 11 62 10 00 	movl   $0x106211,(%esp)
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
  101bed:	c7 04 24 1a 62 10 00 	movl   $0x10621a,(%esp)
  101bf4:	e8 8d e6 ff ff       	call   100286 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfc:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c00:	0f b7 c0             	movzwl %ax,%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 29 62 10 00 	movl   $0x106229,(%esp)
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
  101c24:	c7 04 24 3c 62 10 00 	movl   $0x10623c,(%esp)
  101c2b:	e8 56 e6 ff ff       	call   100286 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c30:	8b 45 08             	mov    0x8(%ebp),%eax
  101c33:	8b 40 04             	mov    0x4(%eax),%eax
  101c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3a:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  101c41:	e8 40 e6 ff ff       	call   100286 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c46:	8b 45 08             	mov    0x8(%ebp),%eax
  101c49:	8b 40 08             	mov    0x8(%eax),%eax
  101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c50:	c7 04 24 5a 62 10 00 	movl   $0x10625a,(%esp)
  101c57:	e8 2a e6 ff ff       	call   100286 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5f:	8b 40 0c             	mov    0xc(%eax),%eax
  101c62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c66:	c7 04 24 69 62 10 00 	movl   $0x106269,(%esp)
  101c6d:	e8 14 e6 ff ff       	call   100286 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c72:	8b 45 08             	mov    0x8(%ebp),%eax
  101c75:	8b 40 10             	mov    0x10(%eax),%eax
  101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7c:	c7 04 24 78 62 10 00 	movl   $0x106278,(%esp)
  101c83:	e8 fe e5 ff ff       	call   100286 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c88:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8b:	8b 40 14             	mov    0x14(%eax),%eax
  101c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c92:	c7 04 24 87 62 10 00 	movl   $0x106287,(%esp)
  101c99:	e8 e8 e5 ff ff       	call   100286 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca1:	8b 40 18             	mov    0x18(%eax),%eax
  101ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca8:	c7 04 24 96 62 10 00 	movl   $0x106296,(%esp)
  101caf:	e8 d2 e5 ff ff       	call   100286 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb7:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbe:	c7 04 24 a5 62 10 00 	movl   $0x1062a5,(%esp)
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
  101d62:	c7 04 24 b4 62 10 00 	movl   $0x1062b4,(%esp)
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
  101d88:	c7 04 24 c6 62 10 00 	movl   $0x1062c6,(%esp)
  101d8f:	e8 f2 e4 ff ff       	call   100286 <cprintf>
        break;
  101d94:	eb 55                	jmp    101deb <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d96:	c7 44 24 08 d5 62 10 	movl   $0x1062d5,0x8(%esp)
  101d9d:	00 
  101d9e:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  101da5:	00 
  101da6:	c7 04 24 e5 62 10 00 	movl   $0x1062e5,(%esp)
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
  101dce:	c7 44 24 08 f6 62 10 	movl   $0x1062f6,0x8(%esp)
  101dd5:	00 
  101dd6:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  101ddd:	00 
  101dde:	c7 04 24 e5 62 10 00 	movl   $0x1062e5,(%esp)
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
  1028d9:	c7 44 24 08 b0 64 10 	movl   $0x1064b0,0x8(%esp)
  1028e0:	00 
  1028e1:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  1028e8:	00 
  1028e9:	c7 04 24 cf 64 10 00 	movl   $0x1064cf,(%esp)
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
  10293f:	c7 44 24 08 e0 64 10 	movl   $0x1064e0,0x8(%esp)
  102946:	00 
  102947:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  10294e:	00 
  10294f:	c7 04 24 cf 64 10 00 	movl   $0x1064cf,(%esp)
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
  102975:	c7 44 24 08 04 65 10 	movl   $0x106504,0x8(%esp)
  10297c:	00 
  10297d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102984:	00 
  102985:	c7 04 24 cf 64 10 00 	movl   $0x1064cf,(%esp)
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

001029c5 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
  1029c5:	55                   	push   %ebp
  1029c6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  1029c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1029cb:	8b 00                	mov    (%eax),%eax
  1029cd:	8d 50 01             	lea    0x1(%eax),%edx
  1029d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d3:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d8:	8b 00                	mov    (%eax),%eax
}
  1029da:	5d                   	pop    %ebp
  1029db:	c3                   	ret    

001029dc <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  1029dc:	55                   	push   %ebp
  1029dd:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  1029df:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e2:	8b 00                	mov    (%eax),%eax
  1029e4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ea:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ef:	8b 00                	mov    (%eax),%eax
}
  1029f1:	5d                   	pop    %ebp
  1029f2:	c3                   	ret    

001029f3 <__intr_save>:
__intr_save(void) {
  1029f3:	55                   	push   %ebp
  1029f4:	89 e5                	mov    %esp,%ebp
  1029f6:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  1029f9:	9c                   	pushf  
  1029fa:	58                   	pop    %eax
  1029fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  1029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102a01:	25 00 02 00 00       	and    $0x200,%eax
  102a06:	85 c0                	test   %eax,%eax
  102a08:	74 0c                	je     102a16 <__intr_save+0x23>
        intr_disable();
  102a0a:	e8 67 ee ff ff       	call   101876 <intr_disable>
        return 1;
  102a0f:	b8 01 00 00 00       	mov    $0x1,%eax
  102a14:	eb 05                	jmp    102a1b <__intr_save+0x28>
    return 0;
  102a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102a1b:	c9                   	leave  
  102a1c:	c3                   	ret    

00102a1d <__intr_restore>:
__intr_restore(bool flag) {
  102a1d:	55                   	push   %ebp
  102a1e:	89 e5                	mov    %esp,%ebp
  102a20:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102a23:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a27:	74 05                	je     102a2e <__intr_restore+0x11>
        intr_enable();
  102a29:	e8 42 ee ff ff       	call   101870 <intr_enable>
}
  102a2e:	c9                   	leave  
  102a2f:	c3                   	ret    

00102a30 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a30:	55                   	push   %ebp
  102a31:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a33:	8b 45 08             	mov    0x8(%ebp),%eax
  102a36:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a39:	b8 23 00 00 00       	mov    $0x23,%eax
  102a3e:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a40:	b8 23 00 00 00       	mov    $0x23,%eax
  102a45:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a47:	b8 10 00 00 00       	mov    $0x10,%eax
  102a4c:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a4e:	b8 10 00 00 00       	mov    $0x10,%eax
  102a53:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a55:	b8 10 00 00 00       	mov    $0x10,%eax
  102a5a:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a5c:	ea 63 2a 10 00 08 00 	ljmp   $0x8,$0x102a63
}
  102a63:	5d                   	pop    %ebp
  102a64:	c3                   	ret    

00102a65 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a65:	55                   	push   %ebp
  102a66:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a68:	8b 45 08             	mov    0x8(%ebp),%eax
  102a6b:	a3 e4 88 11 00       	mov    %eax,0x1188e4
}
  102a70:	5d                   	pop    %ebp
  102a71:	c3                   	ret    

00102a72 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a72:	55                   	push   %ebp
  102a73:	89 e5                	mov    %esp,%ebp
  102a75:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a78:	b8 00 70 11 00       	mov    $0x117000,%eax
  102a7d:	89 04 24             	mov    %eax,(%esp)
  102a80:	e8 e0 ff ff ff       	call   102a65 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a85:	66 c7 05 e8 88 11 00 	movw   $0x10,0x1188e8
  102a8c:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a8e:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102a95:	68 00 
  102a97:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102a9c:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102aa2:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102aa7:	c1 e8 10             	shr    $0x10,%eax
  102aaa:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102aaf:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ab6:	83 e0 f0             	and    $0xfffffff0,%eax
  102ab9:	83 c8 09             	or     $0x9,%eax
  102abc:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ac1:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ac8:	83 e0 ef             	and    $0xffffffef,%eax
  102acb:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102ad0:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ad7:	83 e0 9f             	and    $0xffffff9f,%eax
  102ada:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102adf:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102ae6:	83 c8 80             	or     $0xffffff80,%eax
  102ae9:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102aee:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102af5:	83 e0 f0             	and    $0xfffffff0,%eax
  102af8:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102afd:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b04:	83 e0 ef             	and    $0xffffffef,%eax
  102b07:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b0c:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b13:	83 e0 df             	and    $0xffffffdf,%eax
  102b16:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b1b:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b22:	83 c8 40             	or     $0x40,%eax
  102b25:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b2a:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102b31:	83 e0 7f             	and    $0x7f,%eax
  102b34:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102b39:	b8 e0 88 11 00       	mov    $0x1188e0,%eax
  102b3e:	c1 e8 18             	shr    $0x18,%eax
  102b41:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b46:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102b4d:	e8 de fe ff ff       	call   102a30 <lgdt>
  102b52:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b58:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b5c:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b5f:	c9                   	leave  
  102b60:	c3                   	ret    

00102b61 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b61:	55                   	push   %ebp
  102b62:	89 e5                	mov    %esp,%ebp
  102b64:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102b67:	c7 05 50 89 11 00 78 	movl   $0x106e78,0x118950
  102b6e:	6e 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b71:	a1 50 89 11 00       	mov    0x118950,%eax
  102b76:	8b 00                	mov    (%eax),%eax
  102b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b7c:	c7 04 24 30 65 10 00 	movl   $0x106530,(%esp)
  102b83:	e8 fe d6 ff ff       	call   100286 <cprintf>
    pmm_manager->init();
  102b88:	a1 50 89 11 00       	mov    0x118950,%eax
  102b8d:	8b 40 04             	mov    0x4(%eax),%eax
  102b90:	ff d0                	call   *%eax
}
  102b92:	c9                   	leave  
  102b93:	c3                   	ret    

00102b94 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102b94:	55                   	push   %ebp
  102b95:	89 e5                	mov    %esp,%ebp
  102b97:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102b9a:	a1 50 89 11 00       	mov    0x118950,%eax
  102b9f:	8b 40 08             	mov    0x8(%eax),%eax
  102ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ba5:	89 54 24 04          	mov    %edx,0x4(%esp)
  102ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  102bac:	89 14 24             	mov    %edx,(%esp)
  102baf:	ff d0                	call   *%eax
}
  102bb1:	c9                   	leave  
  102bb2:	c3                   	ret    

00102bb3 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102bb3:	55                   	push   %ebp
  102bb4:	89 e5                	mov    %esp,%ebp
  102bb6:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102bc0:	e8 2e fe ff ff       	call   1029f3 <__intr_save>
  102bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102bc8:	a1 50 89 11 00       	mov    0x118950,%eax
  102bcd:	8b 40 0c             	mov    0xc(%eax),%eax
  102bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  102bd3:	89 14 24             	mov    %edx,(%esp)
  102bd6:	ff d0                	call   *%eax
  102bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102bde:	89 04 24             	mov    %eax,(%esp)
  102be1:	e8 37 fe ff ff       	call   102a1d <__intr_restore>
    return page;
  102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102be9:	c9                   	leave  
  102bea:	c3                   	ret    

00102beb <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102beb:	55                   	push   %ebp
  102bec:	89 e5                	mov    %esp,%ebp
  102bee:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102bf1:	e8 fd fd ff ff       	call   1029f3 <__intr_save>
  102bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102bf9:	a1 50 89 11 00       	mov    0x118950,%eax
  102bfe:	8b 40 10             	mov    0x10(%eax),%eax
  102c01:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c04:	89 54 24 04          	mov    %edx,0x4(%esp)
  102c08:	8b 55 08             	mov    0x8(%ebp),%edx
  102c0b:	89 14 24             	mov    %edx,(%esp)
  102c0e:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c13:	89 04 24             	mov    %eax,(%esp)
  102c16:	e8 02 fe ff ff       	call   102a1d <__intr_restore>
}
  102c1b:	c9                   	leave  
  102c1c:	c3                   	ret    

00102c1d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102c1d:	55                   	push   %ebp
  102c1e:	89 e5                	mov    %esp,%ebp
  102c20:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102c23:	e8 cb fd ff ff       	call   1029f3 <__intr_save>
  102c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102c2b:	a1 50 89 11 00       	mov    0x118950,%eax
  102c30:	8b 40 14             	mov    0x14(%eax),%eax
  102c33:	ff d0                	call   *%eax
  102c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c3b:	89 04 24             	mov    %eax,(%esp)
  102c3e:	e8 da fd ff ff       	call   102a1d <__intr_restore>
    return ret;
  102c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c46:	c9                   	leave  
  102c47:	c3                   	ret    

00102c48 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c48:	55                   	push   %ebp
  102c49:	89 e5                	mov    %esp,%ebp
  102c4b:	57                   	push   %edi
  102c4c:	56                   	push   %esi
  102c4d:	53                   	push   %ebx
  102c4e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c54:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c5b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c62:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c69:	c7 04 24 47 65 10 00 	movl   $0x106547,(%esp)
  102c70:	e8 11 d6 ff ff       	call   100286 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c75:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c7c:	e9 15 01 00 00       	jmp    102d96 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c81:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c84:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c87:	89 d0                	mov    %edx,%eax
  102c89:	c1 e0 02             	shl    $0x2,%eax
  102c8c:	01 d0                	add    %edx,%eax
  102c8e:	c1 e0 02             	shl    $0x2,%eax
  102c91:	01 c8                	add    %ecx,%eax
  102c93:	8b 50 08             	mov    0x8(%eax),%edx
  102c96:	8b 40 04             	mov    0x4(%eax),%eax
  102c99:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102c9c:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102c9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ca2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ca5:	89 d0                	mov    %edx,%eax
  102ca7:	c1 e0 02             	shl    $0x2,%eax
  102caa:	01 d0                	add    %edx,%eax
  102cac:	c1 e0 02             	shl    $0x2,%eax
  102caf:	01 c8                	add    %ecx,%eax
  102cb1:	8b 48 0c             	mov    0xc(%eax),%ecx
  102cb4:	8b 58 10             	mov    0x10(%eax),%ebx
  102cb7:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102cba:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102cbd:	01 c8                	add    %ecx,%eax
  102cbf:	11 da                	adc    %ebx,%edx
  102cc1:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102cc4:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102cc7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cca:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ccd:	89 d0                	mov    %edx,%eax
  102ccf:	c1 e0 02             	shl    $0x2,%eax
  102cd2:	01 d0                	add    %edx,%eax
  102cd4:	c1 e0 02             	shl    $0x2,%eax
  102cd7:	01 c8                	add    %ecx,%eax
  102cd9:	83 c0 14             	add    $0x14,%eax
  102cdc:	8b 00                	mov    (%eax),%eax
  102cde:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  102ce4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102ce7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102cea:	83 c0 ff             	add    $0xffffffff,%eax
  102ced:	83 d2 ff             	adc    $0xffffffff,%edx
  102cf0:	89 c6                	mov    %eax,%esi
  102cf2:	89 d7                	mov    %edx,%edi
  102cf4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cfa:	89 d0                	mov    %edx,%eax
  102cfc:	c1 e0 02             	shl    $0x2,%eax
  102cff:	01 d0                	add    %edx,%eax
  102d01:	c1 e0 02             	shl    $0x2,%eax
  102d04:	01 c8                	add    %ecx,%eax
  102d06:	8b 48 0c             	mov    0xc(%eax),%ecx
  102d09:	8b 58 10             	mov    0x10(%eax),%ebx
  102d0c:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102d12:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  102d16:	89 74 24 14          	mov    %esi,0x14(%esp)
  102d1a:	89 7c 24 18          	mov    %edi,0x18(%esp)
  102d1e:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d21:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d28:	89 54 24 10          	mov    %edx,0x10(%esp)
  102d2c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102d30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d34:	c7 04 24 54 65 10 00 	movl   $0x106554,(%esp)
  102d3b:	e8 46 d5 ff ff       	call   100286 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d40:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d43:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d46:	89 d0                	mov    %edx,%eax
  102d48:	c1 e0 02             	shl    $0x2,%eax
  102d4b:	01 d0                	add    %edx,%eax
  102d4d:	c1 e0 02             	shl    $0x2,%eax
  102d50:	01 c8                	add    %ecx,%eax
  102d52:	83 c0 14             	add    $0x14,%eax
  102d55:	8b 00                	mov    (%eax),%eax
  102d57:	83 f8 01             	cmp    $0x1,%eax
  102d5a:	75 36                	jne    102d92 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  102d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d62:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d65:	77 2b                	ja     102d92 <page_init+0x14a>
  102d67:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d6a:	72 05                	jb     102d71 <page_init+0x129>
  102d6c:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d6f:	73 21                	jae    102d92 <page_init+0x14a>
  102d71:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d75:	77 1b                	ja     102d92 <page_init+0x14a>
  102d77:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d7b:	72 09                	jb     102d86 <page_init+0x13e>
  102d7d:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102d84:	77 0c                	ja     102d92 <page_init+0x14a>
                maxpa = end;
  102d86:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d89:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102d92:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102d96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102d99:	8b 00                	mov    (%eax),%eax
  102d9b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102d9e:	0f 8f dd fe ff ff    	jg     102c81 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102da4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102da8:	72 1d                	jb     102dc7 <page_init+0x17f>
  102daa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102dae:	77 09                	ja     102db9 <page_init+0x171>
  102db0:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102db7:	76 0e                	jbe    102dc7 <page_init+0x17f>
        maxpa = KMEMSIZE;
  102db9:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102dc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102dca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102dcd:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102dd1:	c1 ea 0c             	shr    $0xc,%edx
  102dd4:	a3 c0 88 11 00       	mov    %eax,0x1188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102dd9:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102de0:	b8 68 89 11 00       	mov    $0x118968,%eax
  102de5:	8d 50 ff             	lea    -0x1(%eax),%edx
  102de8:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102deb:	01 d0                	add    %edx,%eax
  102ded:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102df0:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102df3:	ba 00 00 00 00       	mov    $0x0,%edx
  102df8:	f7 75 ac             	divl   -0x54(%ebp)
  102dfb:	89 d0                	mov    %edx,%eax
  102dfd:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e00:	29 c2                	sub    %eax,%edx
  102e02:	89 d0                	mov    %edx,%eax
  102e04:	a3 58 89 11 00       	mov    %eax,0x118958

    for (i = 0; i < npage; i ++) {
  102e09:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e10:	eb 2f                	jmp    102e41 <page_init+0x1f9>
        SetPageReserved(pages + i);
  102e12:	8b 0d 58 89 11 00    	mov    0x118958,%ecx
  102e18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e1b:	89 d0                	mov    %edx,%eax
  102e1d:	c1 e0 02             	shl    $0x2,%eax
  102e20:	01 d0                	add    %edx,%eax
  102e22:	c1 e0 02             	shl    $0x2,%eax
  102e25:	01 c8                	add    %ecx,%eax
  102e27:	83 c0 04             	add    $0x4,%eax
  102e2a:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102e31:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e34:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102e37:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e3a:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102e3d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  102e41:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e44:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  102e49:	39 c2                	cmp    %eax,%edx
  102e4b:	72 c5                	jb     102e12 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e4d:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  102e53:	89 d0                	mov    %edx,%eax
  102e55:	c1 e0 02             	shl    $0x2,%eax
  102e58:	01 d0                	add    %edx,%eax
  102e5a:	c1 e0 02             	shl    $0x2,%eax
  102e5d:	89 c2                	mov    %eax,%edx
  102e5f:	a1 58 89 11 00       	mov    0x118958,%eax
  102e64:	01 d0                	add    %edx,%eax
  102e66:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e69:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102e70:	77 23                	ja     102e95 <page_init+0x24d>
  102e72:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e79:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  102e80:	00 
  102e81:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  102e88:	00 
  102e89:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  102e90:	e8 48 d5 ff ff       	call   1003dd <__panic>
  102e95:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e98:	05 00 00 00 40       	add    $0x40000000,%eax
  102e9d:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102ea0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ea7:	e9 74 01 00 00       	jmp    103020 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102eac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eaf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eb2:	89 d0                	mov    %edx,%eax
  102eb4:	c1 e0 02             	shl    $0x2,%eax
  102eb7:	01 d0                	add    %edx,%eax
  102eb9:	c1 e0 02             	shl    $0x2,%eax
  102ebc:	01 c8                	add    %ecx,%eax
  102ebe:	8b 50 08             	mov    0x8(%eax),%edx
  102ec1:	8b 40 04             	mov    0x4(%eax),%eax
  102ec4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ec7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102eca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ecd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ed0:	89 d0                	mov    %edx,%eax
  102ed2:	c1 e0 02             	shl    $0x2,%eax
  102ed5:	01 d0                	add    %edx,%eax
  102ed7:	c1 e0 02             	shl    $0x2,%eax
  102eda:	01 c8                	add    %ecx,%eax
  102edc:	8b 48 0c             	mov    0xc(%eax),%ecx
  102edf:	8b 58 10             	mov    0x10(%eax),%ebx
  102ee2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ee5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102ee8:	01 c8                	add    %ecx,%eax
  102eea:	11 da                	adc    %ebx,%edx
  102eec:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102eef:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102ef2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ef8:	89 d0                	mov    %edx,%eax
  102efa:	c1 e0 02             	shl    $0x2,%eax
  102efd:	01 d0                	add    %edx,%eax
  102eff:	c1 e0 02             	shl    $0x2,%eax
  102f02:	01 c8                	add    %ecx,%eax
  102f04:	83 c0 14             	add    $0x14,%eax
  102f07:	8b 00                	mov    (%eax),%eax
  102f09:	83 f8 01             	cmp    $0x1,%eax
  102f0c:	0f 85 0a 01 00 00    	jne    10301c <page_init+0x3d4>
            if (begin < freemem) {
  102f12:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f15:	ba 00 00 00 00       	mov    $0x0,%edx
  102f1a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f1d:	72 17                	jb     102f36 <page_init+0x2ee>
  102f1f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102f22:	77 05                	ja     102f29 <page_init+0x2e1>
  102f24:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102f27:	76 0d                	jbe    102f36 <page_init+0x2ee>
                begin = freemem;
  102f29:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f2f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102f36:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f3a:	72 1d                	jb     102f59 <page_init+0x311>
  102f3c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f40:	77 09                	ja     102f4b <page_init+0x303>
  102f42:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f49:	76 0e                	jbe    102f59 <page_init+0x311>
                end = KMEMSIZE;
  102f4b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f52:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f5f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f62:	0f 87 b4 00 00 00    	ja     10301c <page_init+0x3d4>
  102f68:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f6b:	72 09                	jb     102f76 <page_init+0x32e>
  102f6d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f70:	0f 83 a6 00 00 00    	jae    10301c <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  102f76:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f7d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f80:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f83:	01 d0                	add    %edx,%eax
  102f85:	83 e8 01             	sub    $0x1,%eax
  102f88:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f8b:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  102f93:	f7 75 9c             	divl   -0x64(%ebp)
  102f96:	89 d0                	mov    %edx,%eax
  102f98:	8b 55 98             	mov    -0x68(%ebp),%edx
  102f9b:	29 c2                	sub    %eax,%edx
  102f9d:	89 d0                	mov    %edx,%eax
  102f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  102fa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102fa7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102faa:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fad:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102fb0:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb8:	89 c7                	mov    %eax,%edi
  102fba:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  102fc0:	89 7d 80             	mov    %edi,-0x80(%ebp)
  102fc3:	89 d0                	mov    %edx,%eax
  102fc5:	83 e0 00             	and    $0x0,%eax
  102fc8:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102fcb:	8b 45 80             	mov    -0x80(%ebp),%eax
  102fce:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102fd1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102fd4:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  102fd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fda:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102fdd:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fe0:	77 3a                	ja     10301c <page_init+0x3d4>
  102fe2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102fe5:	72 05                	jb     102fec <page_init+0x3a4>
  102fe7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fea:	73 30                	jae    10301c <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102fec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  102fef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  102ff2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102ff5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102ff8:	29 c8                	sub    %ecx,%eax
  102ffa:	19 da                	sbb    %ebx,%edx
  102ffc:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103000:	c1 ea 0c             	shr    $0xc,%edx
  103003:	89 c3                	mov    %eax,%ebx
  103005:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103008:	89 04 24             	mov    %eax,(%esp)
  10300b:	e8 b2 f8 ff ff       	call   1028c2 <pa2page>
  103010:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  103014:	89 04 24             	mov    %eax,(%esp)
  103017:	e8 78 fb ff ff       	call   102b94 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10301c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103020:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103023:	8b 00                	mov    (%eax),%eax
  103025:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103028:	0f 8f 7e fe ff ff    	jg     102eac <page_init+0x264>
                }
            }
        }
    }
}
  10302e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103034:	5b                   	pop    %ebx
  103035:	5e                   	pop    %esi
  103036:	5f                   	pop    %edi
  103037:	5d                   	pop    %ebp
  103038:	c3                   	ret    

00103039 <enable_paging>:

static void
enable_paging(void) {
  103039:	55                   	push   %ebp
  10303a:	89 e5                	mov    %esp,%ebp
  10303c:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
  10303f:	a1 54 89 11 00       	mov    0x118954,%eax
  103044:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
  103047:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10304a:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
  10304d:	0f 20 c0             	mov    %cr0,%eax
  103050:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
  103053:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
  103056:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
  103059:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
  103060:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
  103064:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103067:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
  10306a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10306d:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
  103070:	c9                   	leave  
  103071:	c3                   	ret    

00103072 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  103072:	55                   	push   %ebp
  103073:	89 e5                	mov    %esp,%ebp
  103075:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  103078:	8b 45 14             	mov    0x14(%ebp),%eax
  10307b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10307e:	31 d0                	xor    %edx,%eax
  103080:	25 ff 0f 00 00       	and    $0xfff,%eax
  103085:	85 c0                	test   %eax,%eax
  103087:	74 24                	je     1030ad <boot_map_segment+0x3b>
  103089:	c7 44 24 0c b6 65 10 	movl   $0x1065b6,0xc(%esp)
  103090:	00 
  103091:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103098:	00 
  103099:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  1030a0:	00 
  1030a1:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1030a8:	e8 30 d3 ff ff       	call   1003dd <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1030ad:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1030b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030b7:	25 ff 0f 00 00       	and    $0xfff,%eax
  1030bc:	89 c2                	mov    %eax,%edx
  1030be:	8b 45 10             	mov    0x10(%ebp),%eax
  1030c1:	01 c2                	add    %eax,%edx
  1030c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030c6:	01 d0                	add    %edx,%eax
  1030c8:	83 e8 01             	sub    $0x1,%eax
  1030cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030d1:	ba 00 00 00 00       	mov    $0x0,%edx
  1030d6:	f7 75 f0             	divl   -0x10(%ebp)
  1030d9:	89 d0                	mov    %edx,%eax
  1030db:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030de:	29 c2                	sub    %eax,%edx
  1030e0:	89 d0                	mov    %edx,%eax
  1030e2:	c1 e8 0c             	shr    $0xc,%eax
  1030e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1030e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1030f6:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1030f9:	8b 45 14             	mov    0x14(%ebp),%eax
  1030fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103102:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103107:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10310a:	eb 6b                	jmp    103177 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10310c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103113:	00 
  103114:	8b 45 0c             	mov    0xc(%ebp),%eax
  103117:	89 44 24 04          	mov    %eax,0x4(%esp)
  10311b:	8b 45 08             	mov    0x8(%ebp),%eax
  10311e:	89 04 24             	mov    %eax,(%esp)
  103121:	e8 cc 01 00 00       	call   1032f2 <get_pte>
  103126:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103129:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10312d:	75 24                	jne    103153 <boot_map_segment+0xe1>
  10312f:	c7 44 24 0c e2 65 10 	movl   $0x1065e2,0xc(%esp)
  103136:	00 
  103137:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10313e:	00 
  10313f:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103146:	00 
  103147:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10314e:	e8 8a d2 ff ff       	call   1003dd <__panic>
        *ptep = pa | PTE_P | perm;
  103153:	8b 45 18             	mov    0x18(%ebp),%eax
  103156:	8b 55 14             	mov    0x14(%ebp),%edx
  103159:	09 d0                	or     %edx,%eax
  10315b:	83 c8 01             	or     $0x1,%eax
  10315e:	89 c2                	mov    %eax,%edx
  103160:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103163:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103165:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103169:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  103170:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10317b:	75 8f                	jne    10310c <boot_map_segment+0x9a>
    }
}
  10317d:	c9                   	leave  
  10317e:	c3                   	ret    

0010317f <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10317f:	55                   	push   %ebp
  103180:	89 e5                	mov    %esp,%ebp
  103182:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10318c:	e8 22 fa ff ff       	call   102bb3 <alloc_pages>
  103191:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103198:	75 1c                	jne    1031b6 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10319a:	c7 44 24 08 ef 65 10 	movl   $0x1065ef,0x8(%esp)
  1031a1:	00 
  1031a2:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1031a9:	00 
  1031aa:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1031b1:	e8 27 d2 ff ff       	call   1003dd <__panic>
    }
    return page2kva(p);
  1031b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031b9:	89 04 24             	mov    %eax,(%esp)
  1031bc:	e8 50 f7 ff ff       	call   102911 <page2kva>
}
  1031c1:	c9                   	leave  
  1031c2:	c3                   	ret    

001031c3 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1031c3:	55                   	push   %ebp
  1031c4:	89 e5                	mov    %esp,%ebp
  1031c6:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1031c9:	e8 93 f9 ff ff       	call   102b61 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1031ce:	e8 75 fa ff ff       	call   102c48 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1031d3:	e8 d7 02 00 00       	call   1034af <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
  1031d8:	e8 a2 ff ff ff       	call   10317f <boot_alloc_page>
  1031dd:	a3 c4 88 11 00       	mov    %eax,0x1188c4
    memset(boot_pgdir, 0, PGSIZE);
  1031e2:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1031e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1031ee:	00 
  1031ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1031f6:	00 
  1031f7:	89 04 24             	mov    %eax,(%esp)
  1031fa:	e8 94 23 00 00       	call   105593 <memset>
    boot_cr3 = PADDR(boot_pgdir);
  1031ff:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103207:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10320e:	77 23                	ja     103233 <pmm_init+0x70>
  103210:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103213:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103217:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  10321e:	00 
  10321f:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103226:	00 
  103227:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10322e:	e8 aa d1 ff ff       	call   1003dd <__panic>
  103233:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103236:	05 00 00 00 40       	add    $0x40000000,%eax
  10323b:	a3 54 89 11 00       	mov    %eax,0x118954

    check_pgdir();
  103240:	e8 88 02 00 00       	call   1034cd <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103245:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10324a:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  103250:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103255:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103258:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10325f:	77 23                	ja     103284 <pmm_init+0xc1>
  103261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103264:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103268:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  10326f:	00 
  103270:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  103277:	00 
  103278:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10327f:	e8 59 d1 ff ff       	call   1003dd <__panic>
  103284:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103287:	05 00 00 00 40       	add    $0x40000000,%eax
  10328c:	83 c8 03             	or     $0x3,%eax
  10328f:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103291:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103296:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10329d:	00 
  10329e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1032a5:	00 
  1032a6:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1032ad:	38 
  1032ae:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1032b5:	c0 
  1032b6:	89 04 24             	mov    %eax,(%esp)
  1032b9:	e8 b4 fd ff ff       	call   103072 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
  1032be:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1032c3:	8b 15 c4 88 11 00    	mov    0x1188c4,%edx
  1032c9:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
  1032cf:	89 10                	mov    %edx,(%eax)

    enable_paging();
  1032d1:	e8 63 fd ff ff       	call   103039 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1032d6:	e8 97 f7 ff ff       	call   102a72 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
  1032db:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1032e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1032e6:	e8 7d 08 00 00       	call   103b68 <check_boot_pgdir>

    print_pgdir();
  1032eb:	e8 05 0d 00 00       	call   103ff5 <print_pgdir>

}
  1032f0:	c9                   	leave  
  1032f1:	c3                   	ret    

001032f2 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1032f2:	55                   	push   %ebp
  1032f3:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  1032f5:	5d                   	pop    %ebp
  1032f6:	c3                   	ret    

001032f7 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1032f7:	55                   	push   %ebp
  1032f8:	89 e5                	mov    %esp,%ebp
  1032fa:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1032fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103304:	00 
  103305:	8b 45 0c             	mov    0xc(%ebp),%eax
  103308:	89 44 24 04          	mov    %eax,0x4(%esp)
  10330c:	8b 45 08             	mov    0x8(%ebp),%eax
  10330f:	89 04 24             	mov    %eax,(%esp)
  103312:	e8 db ff ff ff       	call   1032f2 <get_pte>
  103317:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10331a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10331e:	74 08                	je     103328 <get_page+0x31>
        *ptep_store = ptep;
  103320:	8b 45 10             	mov    0x10(%ebp),%eax
  103323:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103326:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10332c:	74 1b                	je     103349 <get_page+0x52>
  10332e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103331:	8b 00                	mov    (%eax),%eax
  103333:	83 e0 01             	and    $0x1,%eax
  103336:	85 c0                	test   %eax,%eax
  103338:	74 0f                	je     103349 <get_page+0x52>
        return pte2page(*ptep);
  10333a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10333d:	8b 00                	mov    (%eax),%eax
  10333f:	89 04 24             	mov    %eax,(%esp)
  103342:	e8 1e f6 ff ff       	call   102965 <pte2page>
  103347:	eb 05                	jmp    10334e <get_page+0x57>
    }
    return NULL;
  103349:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10334e:	c9                   	leave  
  10334f:	c3                   	ret    

00103350 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103350:	55                   	push   %ebp
  103351:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  103353:	5d                   	pop    %ebp
  103354:	c3                   	ret    

00103355 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103355:	55                   	push   %ebp
  103356:	89 e5                	mov    %esp,%ebp
  103358:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10335b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103362:	00 
  103363:	8b 45 0c             	mov    0xc(%ebp),%eax
  103366:	89 44 24 04          	mov    %eax,0x4(%esp)
  10336a:	8b 45 08             	mov    0x8(%ebp),%eax
  10336d:	89 04 24             	mov    %eax,(%esp)
  103370:	e8 7d ff ff ff       	call   1032f2 <get_pte>
  103375:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  103378:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10337c:	74 19                	je     103397 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10337e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103381:	89 44 24 08          	mov    %eax,0x8(%esp)
  103385:	8b 45 0c             	mov    0xc(%ebp),%eax
  103388:	89 44 24 04          	mov    %eax,0x4(%esp)
  10338c:	8b 45 08             	mov    0x8(%ebp),%eax
  10338f:	89 04 24             	mov    %eax,(%esp)
  103392:	e8 b9 ff ff ff       	call   103350 <page_remove_pte>
    }
}
  103397:	c9                   	leave  
  103398:	c3                   	ret    

00103399 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103399:	55                   	push   %ebp
  10339a:	89 e5                	mov    %esp,%ebp
  10339c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10339f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1033a6:	00 
  1033a7:	8b 45 10             	mov    0x10(%ebp),%eax
  1033aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b1:	89 04 24             	mov    %eax,(%esp)
  1033b4:	e8 39 ff ff ff       	call   1032f2 <get_pte>
  1033b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1033bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033c0:	75 0a                	jne    1033cc <page_insert+0x33>
        return -E_NO_MEM;
  1033c2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1033c7:	e9 84 00 00 00       	jmp    103450 <page_insert+0xb7>
    }
    page_ref_inc(page);
  1033cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033cf:	89 04 24             	mov    %eax,(%esp)
  1033d2:	e8 ee f5 ff ff       	call   1029c5 <page_ref_inc>
    if (*ptep & PTE_P) {
  1033d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033da:	8b 00                	mov    (%eax),%eax
  1033dc:	83 e0 01             	and    $0x1,%eax
  1033df:	85 c0                	test   %eax,%eax
  1033e1:	74 3e                	je     103421 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1033e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e6:	8b 00                	mov    (%eax),%eax
  1033e8:	89 04 24             	mov    %eax,(%esp)
  1033eb:	e8 75 f5 ff ff       	call   102965 <pte2page>
  1033f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1033f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1033f9:	75 0d                	jne    103408 <page_insert+0x6f>
            page_ref_dec(page);
  1033fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033fe:	89 04 24             	mov    %eax,(%esp)
  103401:	e8 d6 f5 ff ff       	call   1029dc <page_ref_dec>
  103406:	eb 19                	jmp    103421 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10340b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10340f:	8b 45 10             	mov    0x10(%ebp),%eax
  103412:	89 44 24 04          	mov    %eax,0x4(%esp)
  103416:	8b 45 08             	mov    0x8(%ebp),%eax
  103419:	89 04 24             	mov    %eax,(%esp)
  10341c:	e8 2f ff ff ff       	call   103350 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103421:	8b 45 0c             	mov    0xc(%ebp),%eax
  103424:	89 04 24             	mov    %eax,(%esp)
  103427:	e8 80 f4 ff ff       	call   1028ac <page2pa>
  10342c:	0b 45 14             	or     0x14(%ebp),%eax
  10342f:	83 c8 01             	or     $0x1,%eax
  103432:	89 c2                	mov    %eax,%edx
  103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103437:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103439:	8b 45 10             	mov    0x10(%ebp),%eax
  10343c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103440:	8b 45 08             	mov    0x8(%ebp),%eax
  103443:	89 04 24             	mov    %eax,(%esp)
  103446:	e8 07 00 00 00       	call   103452 <tlb_invalidate>
    return 0;
  10344b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103450:	c9                   	leave  
  103451:	c3                   	ret    

00103452 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103452:	55                   	push   %ebp
  103453:	89 e5                	mov    %esp,%ebp
  103455:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103458:	0f 20 d8             	mov    %cr3,%eax
  10345b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10345e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  103461:	89 c2                	mov    %eax,%edx
  103463:	8b 45 08             	mov    0x8(%ebp),%eax
  103466:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103469:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103470:	77 23                	ja     103495 <tlb_invalidate+0x43>
  103472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103475:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103479:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  103480:	00 
  103481:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
  103488:	00 
  103489:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103490:	e8 48 cf ff ff       	call   1003dd <__panic>
  103495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103498:	05 00 00 00 40       	add    $0x40000000,%eax
  10349d:	39 c2                	cmp    %eax,%edx
  10349f:	75 0c                	jne    1034ad <tlb_invalidate+0x5b>
        invlpg((void *)la);
  1034a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1034a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034aa:	0f 01 38             	invlpg (%eax)
    }
}
  1034ad:	c9                   	leave  
  1034ae:	c3                   	ret    

001034af <check_alloc_page>:

static void
check_alloc_page(void) {
  1034af:	55                   	push   %ebp
  1034b0:	89 e5                	mov    %esp,%ebp
  1034b2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1034b5:	a1 50 89 11 00       	mov    0x118950,%eax
  1034ba:	8b 40 18             	mov    0x18(%eax),%eax
  1034bd:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1034bf:	c7 04 24 08 66 10 00 	movl   $0x106608,(%esp)
  1034c6:	e8 bb cd ff ff       	call   100286 <cprintf>
}
  1034cb:	c9                   	leave  
  1034cc:	c3                   	ret    

001034cd <check_pgdir>:

static void
check_pgdir(void) {
  1034cd:	55                   	push   %ebp
  1034ce:	89 e5                	mov    %esp,%ebp
  1034d0:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1034d3:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  1034d8:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1034dd:	76 24                	jbe    103503 <check_pgdir+0x36>
  1034df:	c7 44 24 0c 27 66 10 	movl   $0x106627,0xc(%esp)
  1034e6:	00 
  1034e7:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1034ee:	00 
  1034ef:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  1034f6:	00 
  1034f7:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1034fe:	e8 da ce ff ff       	call   1003dd <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103503:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103508:	85 c0                	test   %eax,%eax
  10350a:	74 0e                	je     10351a <check_pgdir+0x4d>
  10350c:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103511:	25 ff 0f 00 00       	and    $0xfff,%eax
  103516:	85 c0                	test   %eax,%eax
  103518:	74 24                	je     10353e <check_pgdir+0x71>
  10351a:	c7 44 24 0c 44 66 10 	movl   $0x106644,0xc(%esp)
  103521:	00 
  103522:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103529:	00 
  10352a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103531:	00 
  103532:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103539:	e8 9f ce ff ff       	call   1003dd <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10353e:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103543:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10354a:	00 
  10354b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103552:	00 
  103553:	89 04 24             	mov    %eax,(%esp)
  103556:	e8 9c fd ff ff       	call   1032f7 <get_page>
  10355b:	85 c0                	test   %eax,%eax
  10355d:	74 24                	je     103583 <check_pgdir+0xb6>
  10355f:	c7 44 24 0c 7c 66 10 	movl   $0x10667c,0xc(%esp)
  103566:	00 
  103567:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10356e:	00 
  10356f:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  103576:	00 
  103577:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10357e:	e8 5a ce ff ff       	call   1003dd <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103583:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10358a:	e8 24 f6 ff ff       	call   102bb3 <alloc_pages>
  10358f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103592:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103597:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10359e:	00 
  10359f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035a6:	00 
  1035a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1035aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1035ae:	89 04 24             	mov    %eax,(%esp)
  1035b1:	e8 e3 fd ff ff       	call   103399 <page_insert>
  1035b6:	85 c0                	test   %eax,%eax
  1035b8:	74 24                	je     1035de <check_pgdir+0x111>
  1035ba:	c7 44 24 0c a4 66 10 	movl   $0x1066a4,0xc(%esp)
  1035c1:	00 
  1035c2:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1035c9:	00 
  1035ca:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  1035d1:	00 
  1035d2:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1035d9:	e8 ff cd ff ff       	call   1003dd <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1035de:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1035e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035ea:	00 
  1035eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1035f2:	00 
  1035f3:	89 04 24             	mov    %eax,(%esp)
  1035f6:	e8 f7 fc ff ff       	call   1032f2 <get_pte>
  1035fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1035fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103602:	75 24                	jne    103628 <check_pgdir+0x15b>
  103604:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  10360b:	00 
  10360c:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103613:	00 
  103614:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  10361b:	00 
  10361c:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103623:	e8 b5 cd ff ff       	call   1003dd <__panic>
    assert(pte2page(*ptep) == p1);
  103628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10362b:	8b 00                	mov    (%eax),%eax
  10362d:	89 04 24             	mov    %eax,(%esp)
  103630:	e8 30 f3 ff ff       	call   102965 <pte2page>
  103635:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103638:	74 24                	je     10365e <check_pgdir+0x191>
  10363a:	c7 44 24 0c fd 66 10 	movl   $0x1066fd,0xc(%esp)
  103641:	00 
  103642:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103649:	00 
  10364a:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103651:	00 
  103652:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103659:	e8 7f cd ff ff       	call   1003dd <__panic>
    assert(page_ref(p1) == 1);
  10365e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103661:	89 04 24             	mov    %eax,(%esp)
  103664:	e8 52 f3 ff ff       	call   1029bb <page_ref>
  103669:	83 f8 01             	cmp    $0x1,%eax
  10366c:	74 24                	je     103692 <check_pgdir+0x1c5>
  10366e:	c7 44 24 0c 13 67 10 	movl   $0x106713,0xc(%esp)
  103675:	00 
  103676:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10367d:	00 
  10367e:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103685:	00 
  103686:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10368d:	e8 4b cd ff ff       	call   1003dd <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103692:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103697:	8b 00                	mov    (%eax),%eax
  103699:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10369e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1036a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036a4:	c1 e8 0c             	shr    $0xc,%eax
  1036a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1036aa:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  1036af:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1036b2:	72 23                	jb     1036d7 <check_pgdir+0x20a>
  1036b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1036bb:	c7 44 24 08 e0 64 10 	movl   $0x1064e0,0x8(%esp)
  1036c2:	00 
  1036c3:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  1036ca:	00 
  1036cb:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1036d2:	e8 06 cd ff ff       	call   1003dd <__panic>
  1036d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036da:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1036df:	83 c0 04             	add    $0x4,%eax
  1036e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1036e5:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1036ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036f1:	00 
  1036f2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1036f9:	00 
  1036fa:	89 04 24             	mov    %eax,(%esp)
  1036fd:	e8 f0 fb ff ff       	call   1032f2 <get_pte>
  103702:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103705:	74 24                	je     10372b <check_pgdir+0x25e>
  103707:	c7 44 24 0c 28 67 10 	movl   $0x106728,0xc(%esp)
  10370e:	00 
  10370f:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103716:	00 
  103717:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  10371e:	00 
  10371f:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103726:	e8 b2 cc ff ff       	call   1003dd <__panic>

    p2 = alloc_page();
  10372b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103732:	e8 7c f4 ff ff       	call   102bb3 <alloc_pages>
  103737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  10373a:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10373f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103746:	00 
  103747:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10374e:	00 
  10374f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103752:	89 54 24 04          	mov    %edx,0x4(%esp)
  103756:	89 04 24             	mov    %eax,(%esp)
  103759:	e8 3b fc ff ff       	call   103399 <page_insert>
  10375e:	85 c0                	test   %eax,%eax
  103760:	74 24                	je     103786 <check_pgdir+0x2b9>
  103762:	c7 44 24 0c 50 67 10 	movl   $0x106750,0xc(%esp)
  103769:	00 
  10376a:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103771:	00 
  103772:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103779:	00 
  10377a:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103781:	e8 57 cc ff ff       	call   1003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103786:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10378b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103792:	00 
  103793:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10379a:	00 
  10379b:	89 04 24             	mov    %eax,(%esp)
  10379e:	e8 4f fb ff ff       	call   1032f2 <get_pte>
  1037a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1037aa:	75 24                	jne    1037d0 <check_pgdir+0x303>
  1037ac:	c7 44 24 0c 88 67 10 	movl   $0x106788,0xc(%esp)
  1037b3:	00 
  1037b4:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1037bb:	00 
  1037bc:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1037c3:	00 
  1037c4:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1037cb:	e8 0d cc ff ff       	call   1003dd <__panic>
    assert(*ptep & PTE_U);
  1037d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037d3:	8b 00                	mov    (%eax),%eax
  1037d5:	83 e0 04             	and    $0x4,%eax
  1037d8:	85 c0                	test   %eax,%eax
  1037da:	75 24                	jne    103800 <check_pgdir+0x333>
  1037dc:	c7 44 24 0c b8 67 10 	movl   $0x1067b8,0xc(%esp)
  1037e3:	00 
  1037e4:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1037eb:	00 
  1037ec:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  1037f3:	00 
  1037f4:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1037fb:	e8 dd cb ff ff       	call   1003dd <__panic>
    assert(*ptep & PTE_W);
  103800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103803:	8b 00                	mov    (%eax),%eax
  103805:	83 e0 02             	and    $0x2,%eax
  103808:	85 c0                	test   %eax,%eax
  10380a:	75 24                	jne    103830 <check_pgdir+0x363>
  10380c:	c7 44 24 0c c6 67 10 	movl   $0x1067c6,0xc(%esp)
  103813:	00 
  103814:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10381b:	00 
  10381c:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103823:	00 
  103824:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10382b:	e8 ad cb ff ff       	call   1003dd <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103830:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103835:	8b 00                	mov    (%eax),%eax
  103837:	83 e0 04             	and    $0x4,%eax
  10383a:	85 c0                	test   %eax,%eax
  10383c:	75 24                	jne    103862 <check_pgdir+0x395>
  10383e:	c7 44 24 0c d4 67 10 	movl   $0x1067d4,0xc(%esp)
  103845:	00 
  103846:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10384d:	00 
  10384e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  103855:	00 
  103856:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10385d:	e8 7b cb ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 1);
  103862:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103865:	89 04 24             	mov    %eax,(%esp)
  103868:	e8 4e f1 ff ff       	call   1029bb <page_ref>
  10386d:	83 f8 01             	cmp    $0x1,%eax
  103870:	74 24                	je     103896 <check_pgdir+0x3c9>
  103872:	c7 44 24 0c ea 67 10 	movl   $0x1067ea,0xc(%esp)
  103879:	00 
  10387a:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103881:	00 
  103882:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  103889:	00 
  10388a:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103891:	e8 47 cb ff ff       	call   1003dd <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103896:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10389b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1038a2:	00 
  1038a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1038aa:	00 
  1038ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1038ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  1038b2:	89 04 24             	mov    %eax,(%esp)
  1038b5:	e8 df fa ff ff       	call   103399 <page_insert>
  1038ba:	85 c0                	test   %eax,%eax
  1038bc:	74 24                	je     1038e2 <check_pgdir+0x415>
  1038be:	c7 44 24 0c fc 67 10 	movl   $0x1067fc,0xc(%esp)
  1038c5:	00 
  1038c6:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1038cd:	00 
  1038ce:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  1038d5:	00 
  1038d6:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1038dd:	e8 fb ca ff ff       	call   1003dd <__panic>
    assert(page_ref(p1) == 2);
  1038e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038e5:	89 04 24             	mov    %eax,(%esp)
  1038e8:	e8 ce f0 ff ff       	call   1029bb <page_ref>
  1038ed:	83 f8 02             	cmp    $0x2,%eax
  1038f0:	74 24                	je     103916 <check_pgdir+0x449>
  1038f2:	c7 44 24 0c 28 68 10 	movl   $0x106828,0xc(%esp)
  1038f9:	00 
  1038fa:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103901:	00 
  103902:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103909:	00 
  10390a:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103911:	e8 c7 ca ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103919:	89 04 24             	mov    %eax,(%esp)
  10391c:	e8 9a f0 ff ff       	call   1029bb <page_ref>
  103921:	85 c0                	test   %eax,%eax
  103923:	74 24                	je     103949 <check_pgdir+0x47c>
  103925:	c7 44 24 0c 3a 68 10 	movl   $0x10683a,0xc(%esp)
  10392c:	00 
  10392d:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103934:	00 
  103935:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  10393c:	00 
  10393d:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103944:	e8 94 ca ff ff       	call   1003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103949:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  10394e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103955:	00 
  103956:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10395d:	00 
  10395e:	89 04 24             	mov    %eax,(%esp)
  103961:	e8 8c f9 ff ff       	call   1032f2 <get_pte>
  103966:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103969:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10396d:	75 24                	jne    103993 <check_pgdir+0x4c6>
  10396f:	c7 44 24 0c 88 67 10 	movl   $0x106788,0xc(%esp)
  103976:	00 
  103977:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  10397e:	00 
  10397f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103986:	00 
  103987:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  10398e:	e8 4a ca ff ff       	call   1003dd <__panic>
    assert(pte2page(*ptep) == p1);
  103993:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103996:	8b 00                	mov    (%eax),%eax
  103998:	89 04 24             	mov    %eax,(%esp)
  10399b:	e8 c5 ef ff ff       	call   102965 <pte2page>
  1039a0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1039a3:	74 24                	je     1039c9 <check_pgdir+0x4fc>
  1039a5:	c7 44 24 0c fd 66 10 	movl   $0x1066fd,0xc(%esp)
  1039ac:	00 
  1039ad:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1039b4:	00 
  1039b5:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  1039bc:	00 
  1039bd:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1039c4:	e8 14 ca ff ff       	call   1003dd <__panic>
    assert((*ptep & PTE_U) == 0);
  1039c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1039cc:	8b 00                	mov    (%eax),%eax
  1039ce:	83 e0 04             	and    $0x4,%eax
  1039d1:	85 c0                	test   %eax,%eax
  1039d3:	74 24                	je     1039f9 <check_pgdir+0x52c>
  1039d5:	c7 44 24 0c 4c 68 10 	movl   $0x10684c,0xc(%esp)
  1039dc:	00 
  1039dd:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  1039e4:	00 
  1039e5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  1039ec:	00 
  1039ed:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  1039f4:	e8 e4 c9 ff ff       	call   1003dd <__panic>

    page_remove(boot_pgdir, 0x0);
  1039f9:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  1039fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103a05:	00 
  103a06:	89 04 24             	mov    %eax,(%esp)
  103a09:	e8 47 f9 ff ff       	call   103355 <page_remove>
    assert(page_ref(p1) == 1);
  103a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a11:	89 04 24             	mov    %eax,(%esp)
  103a14:	e8 a2 ef ff ff       	call   1029bb <page_ref>
  103a19:	83 f8 01             	cmp    $0x1,%eax
  103a1c:	74 24                	je     103a42 <check_pgdir+0x575>
  103a1e:	c7 44 24 0c 13 67 10 	movl   $0x106713,0xc(%esp)
  103a25:	00 
  103a26:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103a2d:	00 
  103a2e:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103a35:	00 
  103a36:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103a3d:	e8 9b c9 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a45:	89 04 24             	mov    %eax,(%esp)
  103a48:	e8 6e ef ff ff       	call   1029bb <page_ref>
  103a4d:	85 c0                	test   %eax,%eax
  103a4f:	74 24                	je     103a75 <check_pgdir+0x5a8>
  103a51:	c7 44 24 0c 3a 68 10 	movl   $0x10683a,0xc(%esp)
  103a58:	00 
  103a59:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103a60:	00 
  103a61:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103a68:	00 
  103a69:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103a70:	e8 68 c9 ff ff       	call   1003dd <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103a75:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103a7a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a81:	00 
  103a82:	89 04 24             	mov    %eax,(%esp)
  103a85:	e8 cb f8 ff ff       	call   103355 <page_remove>
    assert(page_ref(p1) == 0);
  103a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a8d:	89 04 24             	mov    %eax,(%esp)
  103a90:	e8 26 ef ff ff       	call   1029bb <page_ref>
  103a95:	85 c0                	test   %eax,%eax
  103a97:	74 24                	je     103abd <check_pgdir+0x5f0>
  103a99:	c7 44 24 0c 61 68 10 	movl   $0x106861,0xc(%esp)
  103aa0:	00 
  103aa1:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103aa8:	00 
  103aa9:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103ab0:	00 
  103ab1:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103ab8:	e8 20 c9 ff ff       	call   1003dd <__panic>
    assert(page_ref(p2) == 0);
  103abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ac0:	89 04 24             	mov    %eax,(%esp)
  103ac3:	e8 f3 ee ff ff       	call   1029bb <page_ref>
  103ac8:	85 c0                	test   %eax,%eax
  103aca:	74 24                	je     103af0 <check_pgdir+0x623>
  103acc:	c7 44 24 0c 3a 68 10 	movl   $0x10683a,0xc(%esp)
  103ad3:	00 
  103ad4:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103adb:	00 
  103adc:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  103ae3:	00 
  103ae4:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103aeb:	e8 ed c8 ff ff       	call   1003dd <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103af0:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103af5:	8b 00                	mov    (%eax),%eax
  103af7:	89 04 24             	mov    %eax,(%esp)
  103afa:	e8 a4 ee ff ff       	call   1029a3 <pde2page>
  103aff:	89 04 24             	mov    %eax,(%esp)
  103b02:	e8 b4 ee ff ff       	call   1029bb <page_ref>
  103b07:	83 f8 01             	cmp    $0x1,%eax
  103b0a:	74 24                	je     103b30 <check_pgdir+0x663>
  103b0c:	c7 44 24 0c 74 68 10 	movl   $0x106874,0xc(%esp)
  103b13:	00 
  103b14:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103b1b:	00 
  103b1c:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103b23:	00 
  103b24:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103b2b:	e8 ad c8 ff ff       	call   1003dd <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103b30:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103b35:	8b 00                	mov    (%eax),%eax
  103b37:	89 04 24             	mov    %eax,(%esp)
  103b3a:	e8 64 ee ff ff       	call   1029a3 <pde2page>
  103b3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103b46:	00 
  103b47:	89 04 24             	mov    %eax,(%esp)
  103b4a:	e8 9c f0 ff ff       	call   102beb <free_pages>
    boot_pgdir[0] = 0;
  103b4f:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103b5a:	c7 04 24 9b 68 10 00 	movl   $0x10689b,(%esp)
  103b61:	e8 20 c7 ff ff       	call   100286 <cprintf>
}
  103b66:	c9                   	leave  
  103b67:	c3                   	ret    

00103b68 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103b68:	55                   	push   %ebp
  103b69:	89 e5                	mov    %esp,%ebp
  103b6b:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103b75:	e9 ca 00 00 00       	jmp    103c44 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b83:	c1 e8 0c             	shr    $0xc,%eax
  103b86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103b89:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103b8e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103b91:	72 23                	jb     103bb6 <check_boot_pgdir+0x4e>
  103b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b9a:	c7 44 24 08 e0 64 10 	movl   $0x1064e0,0x8(%esp)
  103ba1:	00 
  103ba2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  103ba9:	00 
  103baa:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103bb1:	e8 27 c8 ff ff       	call   1003dd <__panic>
  103bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bb9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103bbe:	89 c2                	mov    %eax,%edx
  103bc0:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103bc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103bcc:	00 
  103bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103bd1:	89 04 24             	mov    %eax,(%esp)
  103bd4:	e8 19 f7 ff ff       	call   1032f2 <get_pte>
  103bd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103bdc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103be0:	75 24                	jne    103c06 <check_boot_pgdir+0x9e>
  103be2:	c7 44 24 0c b8 68 10 	movl   $0x1068b8,0xc(%esp)
  103be9:	00 
  103bea:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103bf1:	00 
  103bf2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  103bf9:	00 
  103bfa:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103c01:	e8 d7 c7 ff ff       	call   1003dd <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103c09:	8b 00                	mov    (%eax),%eax
  103c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c10:	89 c2                	mov    %eax,%edx
  103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c15:	39 c2                	cmp    %eax,%edx
  103c17:	74 24                	je     103c3d <check_boot_pgdir+0xd5>
  103c19:	c7 44 24 0c f5 68 10 	movl   $0x1068f5,0xc(%esp)
  103c20:	00 
  103c21:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103c28:	00 
  103c29:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  103c30:	00 
  103c31:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103c38:	e8 a0 c7 ff ff       	call   1003dd <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103c3d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103c44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103c47:	a1 c0 88 11 00       	mov    0x1188c0,%eax
  103c4c:	39 c2                	cmp    %eax,%edx
  103c4e:	0f 82 26 ff ff ff    	jb     103b7a <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103c54:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103c59:	05 ac 0f 00 00       	add    $0xfac,%eax
  103c5e:	8b 00                	mov    (%eax),%eax
  103c60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c65:	89 c2                	mov    %eax,%edx
  103c67:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103c6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103c6f:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103c76:	77 23                	ja     103c9b <check_boot_pgdir+0x133>
  103c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c7f:	c7 44 24 08 84 65 10 	movl   $0x106584,0x8(%esp)
  103c86:	00 
  103c87:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103c8e:	00 
  103c8f:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103c96:	e8 42 c7 ff ff       	call   1003dd <__panic>
  103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c9e:	05 00 00 00 40       	add    $0x40000000,%eax
  103ca3:	39 c2                	cmp    %eax,%edx
  103ca5:	74 24                	je     103ccb <check_boot_pgdir+0x163>
  103ca7:	c7 44 24 0c 0c 69 10 	movl   $0x10690c,0xc(%esp)
  103cae:	00 
  103caf:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103cb6:	00 
  103cb7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103cbe:	00 
  103cbf:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103cc6:	e8 12 c7 ff ff       	call   1003dd <__panic>

    assert(boot_pgdir[0] == 0);
  103ccb:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103cd0:	8b 00                	mov    (%eax),%eax
  103cd2:	85 c0                	test   %eax,%eax
  103cd4:	74 24                	je     103cfa <check_boot_pgdir+0x192>
  103cd6:	c7 44 24 0c 40 69 10 	movl   $0x106940,0xc(%esp)
  103cdd:	00 
  103cde:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103ce5:	00 
  103ce6:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103ced:	00 
  103cee:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103cf5:	e8 e3 c6 ff ff       	call   1003dd <__panic>

    struct Page *p;
    p = alloc_page();
  103cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103d01:	e8 ad ee ff ff       	call   102bb3 <alloc_pages>
  103d06:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103d09:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103d0e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103d15:	00 
  103d16:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103d1d:	00 
  103d1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103d21:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d25:	89 04 24             	mov    %eax,(%esp)
  103d28:	e8 6c f6 ff ff       	call   103399 <page_insert>
  103d2d:	85 c0                	test   %eax,%eax
  103d2f:	74 24                	je     103d55 <check_boot_pgdir+0x1ed>
  103d31:	c7 44 24 0c 54 69 10 	movl   $0x106954,0xc(%esp)
  103d38:	00 
  103d39:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103d40:	00 
  103d41:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103d48:	00 
  103d49:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103d50:	e8 88 c6 ff ff       	call   1003dd <__panic>
    assert(page_ref(p) == 1);
  103d55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103d58:	89 04 24             	mov    %eax,(%esp)
  103d5b:	e8 5b ec ff ff       	call   1029bb <page_ref>
  103d60:	83 f8 01             	cmp    $0x1,%eax
  103d63:	74 24                	je     103d89 <check_boot_pgdir+0x221>
  103d65:	c7 44 24 0c 82 69 10 	movl   $0x106982,0xc(%esp)
  103d6c:	00 
  103d6d:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103d74:	00 
  103d75:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  103d7c:	00 
  103d7d:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103d84:	e8 54 c6 ff ff       	call   1003dd <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103d89:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103d8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103d95:	00 
  103d96:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103d9d:	00 
  103d9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103da1:	89 54 24 04          	mov    %edx,0x4(%esp)
  103da5:	89 04 24             	mov    %eax,(%esp)
  103da8:	e8 ec f5 ff ff       	call   103399 <page_insert>
  103dad:	85 c0                	test   %eax,%eax
  103daf:	74 24                	je     103dd5 <check_boot_pgdir+0x26d>
  103db1:	c7 44 24 0c 94 69 10 	movl   $0x106994,0xc(%esp)
  103db8:	00 
  103db9:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103dc0:	00 
  103dc1:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  103dc8:	00 
  103dc9:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103dd0:	e8 08 c6 ff ff       	call   1003dd <__panic>
    assert(page_ref(p) == 2);
  103dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103dd8:	89 04 24             	mov    %eax,(%esp)
  103ddb:	e8 db eb ff ff       	call   1029bb <page_ref>
  103de0:	83 f8 02             	cmp    $0x2,%eax
  103de3:	74 24                	je     103e09 <check_boot_pgdir+0x2a1>
  103de5:	c7 44 24 0c cb 69 10 	movl   $0x1069cb,0xc(%esp)
  103dec:	00 
  103ded:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103df4:	00 
  103df5:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103dfc:	00 
  103dfd:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103e04:	e8 d4 c5 ff ff       	call   1003dd <__panic>

    const char *str = "ucore: Hello world!!";
  103e09:	c7 45 dc dc 69 10 00 	movl   $0x1069dc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103e10:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  103e17:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e1e:	e8 99 14 00 00       	call   1052bc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103e23:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103e2a:	00 
  103e2b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e32:	e8 fe 14 00 00       	call   105335 <strcmp>
  103e37:	85 c0                	test   %eax,%eax
  103e39:	74 24                	je     103e5f <check_boot_pgdir+0x2f7>
  103e3b:	c7 44 24 0c f4 69 10 	movl   $0x1069f4,0xc(%esp)
  103e42:	00 
  103e43:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103e4a:	00 
  103e4b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  103e52:	00 
  103e53:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103e5a:	e8 7e c5 ff ff       	call   1003dd <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e62:	89 04 24             	mov    %eax,(%esp)
  103e65:	e8 a7 ea ff ff       	call   102911 <page2kva>
  103e6a:	05 00 01 00 00       	add    $0x100,%eax
  103e6f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103e72:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103e79:	e8 e6 13 00 00       	call   105264 <strlen>
  103e7e:	85 c0                	test   %eax,%eax
  103e80:	74 24                	je     103ea6 <check_boot_pgdir+0x33e>
  103e82:	c7 44 24 0c 2c 6a 10 	movl   $0x106a2c,0xc(%esp)
  103e89:	00 
  103e8a:	c7 44 24 08 cd 65 10 	movl   $0x1065cd,0x8(%esp)
  103e91:	00 
  103e92:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  103e99:	00 
  103e9a:	c7 04 24 a8 65 10 00 	movl   $0x1065a8,(%esp)
  103ea1:	e8 37 c5 ff ff       	call   1003dd <__panic>

    free_page(p);
  103ea6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ead:	00 
  103eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103eb1:	89 04 24             	mov    %eax,(%esp)
  103eb4:	e8 32 ed ff ff       	call   102beb <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103eb9:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103ebe:	8b 00                	mov    (%eax),%eax
  103ec0:	89 04 24             	mov    %eax,(%esp)
  103ec3:	e8 db ea ff ff       	call   1029a3 <pde2page>
  103ec8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ecf:	00 
  103ed0:	89 04 24             	mov    %eax,(%esp)
  103ed3:	e8 13 ed ff ff       	call   102beb <free_pages>
    boot_pgdir[0] = 0;
  103ed8:	a1 c4 88 11 00       	mov    0x1188c4,%eax
  103edd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103ee3:	c7 04 24 50 6a 10 00 	movl   $0x106a50,(%esp)
  103eea:	e8 97 c3 ff ff       	call   100286 <cprintf>
}
  103eef:	c9                   	leave  
  103ef0:	c3                   	ret    

00103ef1 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103ef1:	55                   	push   %ebp
  103ef2:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  103ef7:	83 e0 04             	and    $0x4,%eax
  103efa:	85 c0                	test   %eax,%eax
  103efc:	74 07                	je     103f05 <perm2str+0x14>
  103efe:	b8 75 00 00 00       	mov    $0x75,%eax
  103f03:	eb 05                	jmp    103f0a <perm2str+0x19>
  103f05:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103f0a:	a2 48 89 11 00       	mov    %al,0x118948
    str[1] = 'r';
  103f0f:	c6 05 49 89 11 00 72 	movb   $0x72,0x118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103f16:	8b 45 08             	mov    0x8(%ebp),%eax
  103f19:	83 e0 02             	and    $0x2,%eax
  103f1c:	85 c0                	test   %eax,%eax
  103f1e:	74 07                	je     103f27 <perm2str+0x36>
  103f20:	b8 77 00 00 00       	mov    $0x77,%eax
  103f25:	eb 05                	jmp    103f2c <perm2str+0x3b>
  103f27:	b8 2d 00 00 00       	mov    $0x2d,%eax
  103f2c:	a2 4a 89 11 00       	mov    %al,0x11894a
    str[3] = '\0';
  103f31:	c6 05 4b 89 11 00 00 	movb   $0x0,0x11894b
    return str;
  103f38:	b8 48 89 11 00       	mov    $0x118948,%eax
}
  103f3d:	5d                   	pop    %ebp
  103f3e:	c3                   	ret    

00103f3f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103f3f:	55                   	push   %ebp
  103f40:	89 e5                	mov    %esp,%ebp
  103f42:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103f45:	8b 45 10             	mov    0x10(%ebp),%eax
  103f48:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f4b:	72 0a                	jb     103f57 <get_pgtable_items+0x18>
        return 0;
  103f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  103f52:	e9 9c 00 00 00       	jmp    103ff3 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  103f57:	eb 04                	jmp    103f5d <get_pgtable_items+0x1e>
        start ++;
  103f59:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  103f5d:	8b 45 10             	mov    0x10(%ebp),%eax
  103f60:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f63:	73 18                	jae    103f7d <get_pgtable_items+0x3e>
  103f65:	8b 45 10             	mov    0x10(%ebp),%eax
  103f68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  103f72:	01 d0                	add    %edx,%eax
  103f74:	8b 00                	mov    (%eax),%eax
  103f76:	83 e0 01             	and    $0x1,%eax
  103f79:	85 c0                	test   %eax,%eax
  103f7b:	74 dc                	je     103f59 <get_pgtable_items+0x1a>
    }
    if (start < right) {
  103f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  103f80:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103f83:	73 69                	jae    103fee <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  103f85:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  103f89:	74 08                	je     103f93 <get_pgtable_items+0x54>
            *left_store = start;
  103f8b:	8b 45 18             	mov    0x18(%ebp),%eax
  103f8e:	8b 55 10             	mov    0x10(%ebp),%edx
  103f91:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  103f93:	8b 45 10             	mov    0x10(%ebp),%eax
  103f96:	8d 50 01             	lea    0x1(%eax),%edx
  103f99:	89 55 10             	mov    %edx,0x10(%ebp)
  103f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103fa3:	8b 45 14             	mov    0x14(%ebp),%eax
  103fa6:	01 d0                	add    %edx,%eax
  103fa8:	8b 00                	mov    (%eax),%eax
  103faa:	83 e0 07             	and    $0x7,%eax
  103fad:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103fb0:	eb 04                	jmp    103fb6 <get_pgtable_items+0x77>
            start ++;
  103fb2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  103fb6:	8b 45 10             	mov    0x10(%ebp),%eax
  103fb9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103fbc:	73 1d                	jae    103fdb <get_pgtable_items+0x9c>
  103fbe:	8b 45 10             	mov    0x10(%ebp),%eax
  103fc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  103fcb:	01 d0                	add    %edx,%eax
  103fcd:	8b 00                	mov    (%eax),%eax
  103fcf:	83 e0 07             	and    $0x7,%eax
  103fd2:	89 c2                	mov    %eax,%edx
  103fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103fd7:	39 c2                	cmp    %eax,%edx
  103fd9:	74 d7                	je     103fb2 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
  103fdb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103fdf:	74 08                	je     103fe9 <get_pgtable_items+0xaa>
            *right_store = start;
  103fe1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  103fe4:	8b 55 10             	mov    0x10(%ebp),%edx
  103fe7:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  103fe9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103fec:	eb 05                	jmp    103ff3 <get_pgtable_items+0xb4>
    }
    return 0;
  103fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103ff3:	c9                   	leave  
  103ff4:	c3                   	ret    

00103ff5 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  103ff5:	55                   	push   %ebp
  103ff6:	89 e5                	mov    %esp,%ebp
  103ff8:	57                   	push   %edi
  103ff9:	56                   	push   %esi
  103ffa:	53                   	push   %ebx
  103ffb:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  103ffe:	c7 04 24 70 6a 10 00 	movl   $0x106a70,(%esp)
  104005:	e8 7c c2 ff ff       	call   100286 <cprintf>
    size_t left, right = 0, perm;
  10400a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104011:	e9 fa 00 00 00       	jmp    104110 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104019:	89 04 24             	mov    %eax,(%esp)
  10401c:	e8 d0 fe ff ff       	call   103ef1 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104021:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104024:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104027:	29 d1                	sub    %edx,%ecx
  104029:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10402b:	89 d6                	mov    %edx,%esi
  10402d:	c1 e6 16             	shl    $0x16,%esi
  104030:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104033:	89 d3                	mov    %edx,%ebx
  104035:	c1 e3 16             	shl    $0x16,%ebx
  104038:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10403b:	89 d1                	mov    %edx,%ecx
  10403d:	c1 e1 16             	shl    $0x16,%ecx
  104040:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104043:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104046:	29 d7                	sub    %edx,%edi
  104048:	89 fa                	mov    %edi,%edx
  10404a:	89 44 24 14          	mov    %eax,0x14(%esp)
  10404e:	89 74 24 10          	mov    %esi,0x10(%esp)
  104052:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104056:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10405a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10405e:	c7 04 24 a1 6a 10 00 	movl   $0x106aa1,(%esp)
  104065:	e8 1c c2 ff ff       	call   100286 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10406a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10406d:	c1 e0 0a             	shl    $0xa,%eax
  104070:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104073:	eb 54                	jmp    1040c9 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104078:	89 04 24             	mov    %eax,(%esp)
  10407b:	e8 71 fe ff ff       	call   103ef1 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104080:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104083:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104086:	29 d1                	sub    %edx,%ecx
  104088:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10408a:	89 d6                	mov    %edx,%esi
  10408c:	c1 e6 0c             	shl    $0xc,%esi
  10408f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104092:	89 d3                	mov    %edx,%ebx
  104094:	c1 e3 0c             	shl    $0xc,%ebx
  104097:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10409a:	c1 e2 0c             	shl    $0xc,%edx
  10409d:	89 d1                	mov    %edx,%ecx
  10409f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1040a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1040a5:	29 d7                	sub    %edx,%edi
  1040a7:	89 fa                	mov    %edi,%edx
  1040a9:	89 44 24 14          	mov    %eax,0x14(%esp)
  1040ad:	89 74 24 10          	mov    %esi,0x10(%esp)
  1040b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1040b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1040b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  1040bd:	c7 04 24 c0 6a 10 00 	movl   $0x106ac0,(%esp)
  1040c4:	e8 bd c1 ff ff       	call   100286 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1040c9:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1040ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1040d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1040d4:	89 ce                	mov    %ecx,%esi
  1040d6:	c1 e6 0a             	shl    $0xa,%esi
  1040d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1040dc:	89 cb                	mov    %ecx,%ebx
  1040de:	c1 e3 0a             	shl    $0xa,%ebx
  1040e1:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1040e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1040e8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1040eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1040ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1040f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1040f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  1040fb:	89 1c 24             	mov    %ebx,(%esp)
  1040fe:	e8 3c fe ff ff       	call   103f3f <get_pgtable_items>
  104103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10410a:	0f 85 65 ff ff ff    	jne    104075 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104110:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  104115:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104118:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10411b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  10411f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  104122:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  104126:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10412a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10412e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104135:	00 
  104136:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10413d:	e8 fd fd ff ff       	call   103f3f <get_pgtable_items>
  104142:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104145:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104149:	0f 85 c7 fe ff ff    	jne    104016 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10414f:	c7 04 24 e4 6a 10 00 	movl   $0x106ae4,(%esp)
  104156:	e8 2b c1 ff ff       	call   100286 <cprintf>
}
  10415b:	83 c4 4c             	add    $0x4c,%esp
  10415e:	5b                   	pop    %ebx
  10415f:	5e                   	pop    %esi
  104160:	5f                   	pop    %edi
  104161:	5d                   	pop    %ebp
  104162:	c3                   	ret    

00104163 <page2ppn>:
page2ppn(struct Page *page) {
  104163:	55                   	push   %ebp
  104164:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104166:	8b 55 08             	mov    0x8(%ebp),%edx
  104169:	a1 58 89 11 00       	mov    0x118958,%eax
  10416e:	29 c2                	sub    %eax,%edx
  104170:	89 d0                	mov    %edx,%eax
  104172:	c1 f8 02             	sar    $0x2,%eax
  104175:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10417b:	5d                   	pop    %ebp
  10417c:	c3                   	ret    

0010417d <page2pa>:
page2pa(struct Page *page) {
  10417d:	55                   	push   %ebp
  10417e:	89 e5                	mov    %esp,%ebp
  104180:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104183:	8b 45 08             	mov    0x8(%ebp),%eax
  104186:	89 04 24             	mov    %eax,(%esp)
  104189:	e8 d5 ff ff ff       	call   104163 <page2ppn>
  10418e:	c1 e0 0c             	shl    $0xc,%eax
}
  104191:	c9                   	leave  
  104192:	c3                   	ret    

00104193 <page_ref>:
page_ref(struct Page *page) {
  104193:	55                   	push   %ebp
  104194:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104196:	8b 45 08             	mov    0x8(%ebp),%eax
  104199:	8b 00                	mov    (%eax),%eax
}
  10419b:	5d                   	pop    %ebp
  10419c:	c3                   	ret    

0010419d <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10419d:	55                   	push   %ebp
  10419e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1041a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1041a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1041a6:	89 10                	mov    %edx,(%eax)
}
  1041a8:	5d                   	pop    %ebp
  1041a9:	c3                   	ret    

001041aa <default_init>:
/**
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 */
static void
default_init(void) {
  1041aa:	55                   	push   %ebp
  1041ab:	89 e5                	mov    %esp,%ebp
  1041ad:	83 ec 10             	sub    $0x10,%esp
  1041b0:	c7 45 fc 5c 89 11 00 	movl   $0x11895c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1041b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1041bd:	89 50 04             	mov    %edx,0x4(%eax)
  1041c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041c3:	8b 50 04             	mov    0x4(%eax),%edx
  1041c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1041c9:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1041cb:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  1041d2:	00 00 00 
}
  1041d5:	c9                   	leave  
  1041d6:	c3                   	ret    

001041d7 <default_init_memmap>:
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * @param base
 * @param n
 */
static void
default_init_memmap(struct Page *base, size_t n) {
  1041d7:	55                   	push   %ebp
  1041d8:	89 e5                	mov    %esp,%ebp
  1041da:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1041dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1041e1:	75 24                	jne    104207 <default_init_memmap+0x30>
  1041e3:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  1041ea:	00 
  1041eb:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1041f2:	00 
  1041f3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  1041fa:	00 
  1041fb:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104202:	e8 d6 c1 ff ff       	call   1003dd <__panic>
    struct Page *p = base;
  104207:	8b 45 08             	mov    0x8(%ebp),%eax
  10420a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10420d:	e9 d2 00 00 00       	jmp    1042e4 <default_init_memmap+0x10d>
        assert(PageReserved(p));
  104212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104215:	83 c0 04             	add    $0x4,%eax
  104218:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10421f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104222:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104225:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104228:	0f a3 10             	bt     %edx,(%eax)
  10422b:	19 c0                	sbb    %eax,%eax
  10422d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104230:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104234:	0f 95 c0             	setne  %al
  104237:	0f b6 c0             	movzbl %al,%eax
  10423a:	85 c0                	test   %eax,%eax
  10423c:	75 24                	jne    104262 <default_init_memmap+0x8b>
  10423e:	c7 44 24 0c 49 6b 10 	movl   $0x106b49,0xc(%esp)
  104245:	00 
  104246:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10424d:	00 
  10424e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  104255:	00 
  104256:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10425d:	e8 7b c1 ff ff       	call   1003dd <__panic>
        set_page_ref(p, 0);
  104262:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104269:	00 
  10426a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10426d:	89 04 24             	mov    %eax,(%esp)
  104270:	e8 28 ff ff ff       	call   10419d <set_page_ref>
        //p的ref指针设置为0,因为该页未被使用
        SetPageProperty(p);
  104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104278:	83 c0 04             	add    $0x4,%eax
  10427b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  104282:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104285:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10428b:	0f ab 10             	bts    %edx,(%eax)
        //页面刚刚初始化，未被保留
        p->property=0;
  10428e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104291:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(&free_list, &(p->page_link));
  104298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10429b:	83 c0 0c             	add    $0xc,%eax
  10429e:	c7 45 dc 5c 89 11 00 	movl   $0x11895c,-0x24(%ebp)
  1042a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1042a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042ab:	8b 00                	mov    (%eax),%eax
  1042ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1042b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1042b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1042b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1042b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1042bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1042bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1042c2:	89 10                	mov    %edx,(%eax)
  1042c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1042c7:	8b 10                	mov    (%eax),%edx
  1042c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1042cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1042cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1042d2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1042d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1042d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1042db:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1042de:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
  1042e0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1042e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1042e7:	89 d0                	mov    %edx,%eax
  1042e9:	c1 e0 02             	shl    $0x2,%eax
  1042ec:	01 d0                	add    %edx,%eax
  1042ee:	c1 e0 02             	shl    $0x2,%eax
  1042f1:	89 c2                	mov    %eax,%edx
  1042f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1042f6:	01 d0                	add    %edx,%eax
  1042f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1042fb:	0f 85 11 ff ff ff    	jne    104212 <default_init_memmap+0x3b>
    }
    base->property=n;
  104301:	8b 45 08             	mov    0x8(%ebp),%eax
  104304:	8b 55 0c             	mov    0xc(%ebp),%edx
  104307:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;//总可分配数量增加
  10430a:	8b 15 64 89 11 00    	mov    0x118964,%edx
  104310:	8b 45 0c             	mov    0xc(%ebp),%eax
  104313:	01 d0                	add    %edx,%eax
  104315:	a3 64 89 11 00       	mov    %eax,0x118964
}
  10431a:	c9                   	leave  
  10431b:	c3                   	ret    

0010431c <default_alloc_pages>:
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * @param n
 * @return
 */
static struct Page *
default_alloc_pages(size_t n) {
  10431c:	55                   	push   %ebp
  10431d:	89 e5                	mov    %esp,%ebp
  10431f:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  104322:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104326:	75 24                	jne    10434c <default_alloc_pages+0x30>
  104328:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  10432f:	00 
  104330:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104337:	00 
  104338:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  10433f:	00 
  104340:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104347:	e8 91 c0 ff ff       	call   1003dd <__panic>
    if (n > nr_free) {
  10434c:	a1 64 89 11 00       	mov    0x118964,%eax
  104351:	3b 45 08             	cmp    0x8(%ebp),%eax
  104354:	73 0a                	jae    104360 <default_alloc_pages+0x44>
        return NULL;
  104356:	b8 00 00 00 00       	mov    $0x0,%eax
  10435b:	e9 fc 00 00 00       	jmp    10445c <default_alloc_pages+0x140>
    }
    struct Page *page = NULL;
  104360:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    list_entry_t *le = &free_list;
  104367:	c7 45 f4 5c 89 11 00 	movl   $0x11895c,-0xc(%ebp)

    while ((le = list_next(le)) != &free_list) {
  10436e:	e9 c8 00 00 00       	jmp    10443b <default_alloc_pages+0x11f>
        struct Page *p = le2page(le, page_link);
  104373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104376:	83 e8 0c             	sub    $0xc,%eax
  104379:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
  10437c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10437f:	8b 40 08             	mov    0x8(%eax),%eax
  104382:	3b 45 08             	cmp    0x8(%ebp),%eax
  104385:	0f 82 b0 00 00 00    	jb     10443b <default_alloc_pages+0x11f>
            //找到了合适大小的块，可以进行分配
            struct Page *curPage=p;
  10438b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10438e:	89 45 f0             	mov    %eax,-0x10(%ebp)
            for(;curPage<p+n;curPage++){
  104391:	eb 61                	jmp    1043f4 <default_alloc_pages+0xd8>
                //遍历所有需要分配的PAGE 修改其相应属性为已经分配 并将其移除freelist
                ClearPageProperty(curPage);
  104393:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104396:	83 c0 04             	add    $0x4,%eax
  104399:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1043a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1043a9:	0f b3 10             	btr    %edx,(%eax)
                SetPageReserved(curPage);
  1043ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043af:	83 c0 04             	add    $0x4,%eax
  1043b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1043b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1043bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043c2:	0f ab 10             	bts    %edx,(%eax)
                list_del(&(curPage->page_link));
  1043c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043c8:	83 c0 0c             	add    $0xc,%eax
  1043cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1043ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043d1:	8b 40 04             	mov    0x4(%eax),%eax
  1043d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043d7:	8b 12                	mov    (%edx),%edx
  1043d9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  1043dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1043df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043e2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1043e5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1043e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1043ee:	89 10                	mov    %edx,(%eax)
            for(;curPage<p+n;curPage++){
  1043f0:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
  1043f4:	8b 55 08             	mov    0x8(%ebp),%edx
  1043f7:	89 d0                	mov    %edx,%eax
  1043f9:	c1 e0 02             	shl    $0x2,%eax
  1043fc:	01 d0                	add    %edx,%eax
  1043fe:	c1 e0 02             	shl    $0x2,%eax
  104401:	89 c2                	mov    %eax,%edx
  104403:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104406:	01 d0                	add    %edx,%eax
  104408:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10440b:	77 86                	ja     104393 <default_alloc_pages+0x77>
            }
            if(p->property>n){
  10440d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104410:	8b 40 08             	mov    0x8(%eax),%eax
  104413:	3b 45 08             	cmp    0x8(%ebp),%eax
  104416:	76 11                	jbe    104429 <default_alloc_pages+0x10d>
                //如果分配后还存在外碎片，需要将外碎片数量更新为原大小减去分配量
                curPage->property=p->property-n;
  104418:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10441b:	8b 40 08             	mov    0x8(%eax),%eax
  10441e:	2b 45 08             	sub    0x8(%ebp),%eax
  104421:	89 c2                	mov    %eax,%edx
  104423:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104426:	89 50 08             	mov    %edx,0x8(%eax)
            }
            nr_free-=n;//记得更新剩余页数量
  104429:	a1 64 89 11 00       	mov    0x118964,%eax
  10442e:	2b 45 08             	sub    0x8(%ebp),%eax
  104431:	a3 64 89 11 00       	mov    %eax,0x118964
            return p;
  104436:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104439:	eb 21                	jmp    10445c <default_alloc_pages+0x140>
  10443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10443e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return listelm->next;
  104441:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104444:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10444a:	81 7d f4 5c 89 11 00 	cmpl   $0x11895c,-0xc(%ebp)
  104451:	0f 85 1c ff ff ff    	jne    104373 <default_alloc_pages+0x57>
        }
    }

    return NULL;
  104457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10445c:	c9                   	leave  
  10445d:	c3                   	ret    

0010445e <default_free_pages>:
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 * @param base
 * @param n
 */
static void
default_free_pages(struct Page *base, size_t n) {
  10445e:	55                   	push   %ebp
  10445f:	89 e5                	mov    %esp,%ebp
  104461:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
  104464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104468:	75 24                	jne    10448e <default_free_pages+0x30>
  10446a:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  104471:	00 
  104472:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104479:	00 
  10447a:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
  104481:	00 
  104482:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104489:	e8 4f bf ff ff       	call   1003dd <__panic>
    assert(PageReserved(base));
  10448e:	8b 45 08             	mov    0x8(%ebp),%eax
  104491:	83 c0 04             	add    $0x4,%eax
  104494:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10449b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10449e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1044a4:	0f a3 10             	bt     %edx,(%eax)
  1044a7:	19 c0                	sbb    %eax,%eax
  1044a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1044ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1044b0:	0f 95 c0             	setne  %al
  1044b3:	0f b6 c0             	movzbl %al,%eax
  1044b6:	85 c0                	test   %eax,%eax
  1044b8:	75 24                	jne    1044de <default_free_pages+0x80>
  1044ba:	c7 44 24 0c 59 6b 10 	movl   $0x106b59,0xc(%esp)
  1044c1:	00 
  1044c2:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1044c9:	00 
  1044ca:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  1044d1:	00 
  1044d2:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  1044d9:	e8 ff be ff ff       	call   1003dd <__panic>
    struct Page *p ;
    list_entry_t *le = &free_list;
  1044de:	c7 45 f0 5c 89 11 00 	movl   $0x11895c,-0x10(%ebp)
     while((le=list_next(le))!=&free_list){
  1044e5:	eb 13                	jmp    1044fa <default_free_pages+0x9c>
         //理解这段代码：由于块已经分配出去，因此块没有被串在链表中，我们需要找到正确插入链表的位置，而page结构数组是不会改变的
         //要找到正确的插入位置，就需要找到链表中第一个在base前的page，然后就可以对要释放的块使用头插法：list_add_before()以此插入即可
         p=le2page(le,page_link);
  1044e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044ea:	83 e8 0c             	sub    $0xc,%eax
  1044ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
         if(p>base){
  1044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f3:	3b 45 08             	cmp    0x8(%ebp),%eax
  1044f6:	76 02                	jbe    1044fa <default_free_pages+0x9c>
             break;
  1044f8:	eb 18                	jmp    104512 <default_free_pages+0xb4>
  1044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104500:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104503:	8b 40 04             	mov    0x4(%eax),%eax
     while((le=list_next(le))!=&free_list){
  104506:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104509:	81 7d f0 5c 89 11 00 	cmpl   $0x11895c,-0x10(%ebp)
  104510:	75 d5                	jne    1044e7 <default_free_pages+0x89>
         }
     }
     for(p=base;p<base+n;p++){
  104512:	8b 45 08             	mov    0x8(%ebp),%eax
  104515:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104518:	eb 77                	jmp    104591 <default_free_pages+0x133>
         ClearPageReserved(p);//移除保留状态
  10451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10451d:	83 c0 04             	add    $0x4,%eax
  104520:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104527:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10452a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10452d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104530:	0f b3 10             	btr    %edx,(%eax)
         set_page_ref(p,0);//设置引用数为0
  104533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10453a:	00 
  10453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10453e:	89 04 24             	mov    %eax,(%esp)
  104541:	e8 57 fc ff ff       	call   10419d <set_page_ref>
         list_add_before(le,&p->page_link);//加入链表
  104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104549:	8d 50 0c             	lea    0xc(%eax),%edx
  10454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10454f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  104552:	89 55 d0             	mov    %edx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104555:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104558:	8b 00                	mov    (%eax),%eax
  10455a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10455d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  104560:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104563:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104566:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
  104569:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10456c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10456f:	89 10                	mov    %edx,(%eax)
  104571:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104574:	8b 10                	mov    (%eax),%edx
  104576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104579:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10457c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10457f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104582:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104585:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104588:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10458b:	89 10                	mov    %edx,(%eax)
     for(p=base;p<base+n;p++){
  10458d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104591:	8b 55 0c             	mov    0xc(%ebp),%edx
  104594:	89 d0                	mov    %edx,%eax
  104596:	c1 e0 02             	shl    $0x2,%eax
  104599:	01 d0                	add    %edx,%eax
  10459b:	c1 e0 02             	shl    $0x2,%eax
  10459e:	89 c2                	mov    %eax,%edx
  1045a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1045a3:	01 d0                	add    %edx,%eax
  1045a5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1045a8:	0f 87 6c ff ff ff    	ja     10451a <default_free_pages+0xbc>
     }
    SetPageProperty(base);//一个块的头页面需要设置property
  1045ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1045b1:	83 c0 04             	add    $0x4,%eax
  1045b4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1045bb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1045be:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1045c1:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1045c4:	0f ab 10             	bts    %edx,(%eax)
    base->property=n;
  1045c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1045ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045cd:	89 50 08             	mov    %edx,0x8(%eax)
    p=le2page(le,page_link);
  1045d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045d3:	83 e8 0c             	sub    $0xc,%eax
  1045d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

    //除了加入空闲链表之外，还需要合并上方和下方的块
    if(p==base+n){
  1045d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045dc:	89 d0                	mov    %edx,%eax
  1045de:	c1 e0 02             	shl    $0x2,%eax
  1045e1:	01 d0                	add    %edx,%eax
  1045e3:	c1 e0 02             	shl    $0x2,%eax
  1045e6:	89 c2                	mov    %eax,%edx
  1045e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1045eb:	01 d0                	add    %edx,%eax
  1045ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1045f0:	75 37                	jne    104629 <default_free_pages+0x1cb>
        //下方的块合并较为简单，判断链表的下一个页是否正好是相邻的页，如果是，则直接将property加入到base页，然后清空该页的property
        base->property+=p->property;
  1045f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1045f5:	8b 50 08             	mov    0x8(%eax),%edx
  1045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045fb:	8b 40 08             	mov    0x8(%eax),%eax
  1045fe:	01 c2                	add    %eax,%edx
  104600:	8b 45 08             	mov    0x8(%ebp),%eax
  104603:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
  104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104609:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        ClearPageProperty(p);
  104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104613:	83 c0 04             	add    $0x4,%eax
  104616:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  10461d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104620:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104623:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104626:	0f b3 10             	btr    %edx,(%eax)
    }

    //合并上方也不复杂，需要找到上方第一个空闲块并将base 的property赋给该块
    le=list_prev(&base->page_link);
  104629:	8b 45 08             	mov    0x8(%ebp),%eax
  10462c:	83 c0 0c             	add    $0xc,%eax
  10462f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->prev;
  104632:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104635:	8b 00                	mov    (%eax),%eax
  104637:	89 45 f0             	mov    %eax,-0x10(%ebp)
    p=le2page(le,page_link);
  10463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10463d:	83 e8 0c             	sub    $0xc,%eax
  104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p==base-1){
  104643:	8b 45 08             	mov    0x8(%ebp),%eax
  104646:	83 e8 14             	sub    $0x14,%eax
  104649:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10464c:	75 65                	jne    1046b3 <default_free_pages+0x255>
        //链表的上一个块必须要和当前页连续才能合并
        while(le!=&free_list){
  10464e:	eb 5a                	jmp    1046aa <default_free_pages+0x24c>
            p=le2page(le,page_link);
  104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104653:	83 e8 0c             	sub    $0xc,%eax
  104656:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if(p->property!=0){
  104659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10465c:	8b 40 08             	mov    0x8(%eax),%eax
  10465f:	85 c0                	test   %eax,%eax
  104661:	74 39                	je     10469c <default_free_pages+0x23e>
                p->property+=base->property;
  104663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104666:	8b 50 08             	mov    0x8(%eax),%edx
  104669:	8b 45 08             	mov    0x8(%ebp),%eax
  10466c:	8b 40 08             	mov    0x8(%eax),%eax
  10466f:	01 c2                	add    %eax,%edx
  104671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104674:	89 50 08             	mov    %edx,0x8(%eax)
                base->property=0;
  104677:	8b 45 08             	mov    0x8(%ebp),%eax
  10467a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
                ClearPageProperty(base);
  104681:	8b 45 08             	mov    0x8(%ebp),%eax
  104684:	83 c0 04             	add    $0x4,%eax
  104687:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10468e:	89 45 a8             	mov    %eax,-0x58(%ebp)
  104691:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104694:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104697:	0f b3 10             	btr    %edx,(%eax)
                break;
  10469a:	eb 17                	jmp    1046b3 <default_free_pages+0x255>
  10469c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10469f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  1046a2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1046a5:	8b 00                	mov    (%eax),%eax
            }
            le=list_prev(le);
  1046a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while(le!=&free_list){
  1046aa:	81 7d f0 5c 89 11 00 	cmpl   $0x11895c,-0x10(%ebp)
  1046b1:	75 9d                	jne    104650 <default_free_pages+0x1f2>
        }
    }
    nr_free+=n;
  1046b3:	8b 15 64 89 11 00    	mov    0x118964,%edx
  1046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046bc:	01 d0                	add    %edx,%eax
  1046be:	a3 64 89 11 00       	mov    %eax,0x118964
    return;
  1046c3:	90                   	nop

}
  1046c4:	c9                   	leave  
  1046c5:	c3                   	ret    

001046c6 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  1046c6:	55                   	push   %ebp
  1046c7:	89 e5                	mov    %esp,%ebp
    return nr_free;
  1046c9:	a1 64 89 11 00       	mov    0x118964,%eax
}
  1046ce:	5d                   	pop    %ebp
  1046cf:	c3                   	ret    

001046d0 <basic_check>:

static void
basic_check(void) {
  1046d0:	55                   	push   %ebp
  1046d1:	89 e5                	mov    %esp,%ebp
  1046d3:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  1046d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  1046e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1046f0:	e8 be e4 ff ff       	call   102bb3 <alloc_pages>
  1046f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1046f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1046fc:	75 24                	jne    104722 <basic_check+0x52>
  1046fe:	c7 44 24 0c 6c 6b 10 	movl   $0x106b6c,0xc(%esp)
  104705:	00 
  104706:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10470d:	00 
  10470e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104715:	00 
  104716:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10471d:	e8 bb bc ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
  104722:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104729:	e8 85 e4 ff ff       	call   102bb3 <alloc_pages>
  10472e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104731:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104735:	75 24                	jne    10475b <basic_check+0x8b>
  104737:	c7 44 24 0c 88 6b 10 	movl   $0x106b88,0xc(%esp)
  10473e:	00 
  10473f:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104746:	00 
  104747:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  10474e:	00 
  10474f:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104756:	e8 82 bc ff ff       	call   1003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
  10475b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104762:	e8 4c e4 ff ff       	call   102bb3 <alloc_pages>
  104767:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10476a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10476e:	75 24                	jne    104794 <basic_check+0xc4>
  104770:	c7 44 24 0c a4 6b 10 	movl   $0x106ba4,0xc(%esp)
  104777:	00 
  104778:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10477f:	00 
  104780:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  104787:	00 
  104788:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10478f:	e8 49 bc ff ff       	call   1003dd <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104797:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10479a:	74 10                	je     1047ac <basic_check+0xdc>
  10479c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10479f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047a2:	74 08                	je     1047ac <basic_check+0xdc>
  1047a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1047aa:	75 24                	jne    1047d0 <basic_check+0x100>
  1047ac:	c7 44 24 0c c0 6b 10 	movl   $0x106bc0,0xc(%esp)
  1047b3:	00 
  1047b4:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1047bb:	00 
  1047bc:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  1047c3:	00 
  1047c4:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  1047cb:	e8 0d bc ff ff       	call   1003dd <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  1047d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047d3:	89 04 24             	mov    %eax,(%esp)
  1047d6:	e8 b8 f9 ff ff       	call   104193 <page_ref>
  1047db:	85 c0                	test   %eax,%eax
  1047dd:	75 1e                	jne    1047fd <basic_check+0x12d>
  1047df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1047e2:	89 04 24             	mov    %eax,(%esp)
  1047e5:	e8 a9 f9 ff ff       	call   104193 <page_ref>
  1047ea:	85 c0                	test   %eax,%eax
  1047ec:	75 0f                	jne    1047fd <basic_check+0x12d>
  1047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047f1:	89 04 24             	mov    %eax,(%esp)
  1047f4:	e8 9a f9 ff ff       	call   104193 <page_ref>
  1047f9:	85 c0                	test   %eax,%eax
  1047fb:	74 24                	je     104821 <basic_check+0x151>
  1047fd:	c7 44 24 0c e4 6b 10 	movl   $0x106be4,0xc(%esp)
  104804:	00 
  104805:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10480c:	00 
  10480d:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104814:	00 
  104815:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10481c:	e8 bc bb ff ff       	call   1003dd <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104821:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104824:	89 04 24             	mov    %eax,(%esp)
  104827:	e8 51 f9 ff ff       	call   10417d <page2pa>
  10482c:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  104832:	c1 e2 0c             	shl    $0xc,%edx
  104835:	39 d0                	cmp    %edx,%eax
  104837:	72 24                	jb     10485d <basic_check+0x18d>
  104839:	c7 44 24 0c 20 6c 10 	movl   $0x106c20,0xc(%esp)
  104840:	00 
  104841:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104848:	00 
  104849:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104850:	00 
  104851:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104858:	e8 80 bb ff ff       	call   1003dd <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10485d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104860:	89 04 24             	mov    %eax,(%esp)
  104863:	e8 15 f9 ff ff       	call   10417d <page2pa>
  104868:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  10486e:	c1 e2 0c             	shl    $0xc,%edx
  104871:	39 d0                	cmp    %edx,%eax
  104873:	72 24                	jb     104899 <basic_check+0x1c9>
  104875:	c7 44 24 0c 3d 6c 10 	movl   $0x106c3d,0xc(%esp)
  10487c:	00 
  10487d:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104884:	00 
  104885:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  10488c:	00 
  10488d:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104894:	e8 44 bb ff ff       	call   1003dd <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10489c:	89 04 24             	mov    %eax,(%esp)
  10489f:	e8 d9 f8 ff ff       	call   10417d <page2pa>
  1048a4:	8b 15 c0 88 11 00    	mov    0x1188c0,%edx
  1048aa:	c1 e2 0c             	shl    $0xc,%edx
  1048ad:	39 d0                	cmp    %edx,%eax
  1048af:	72 24                	jb     1048d5 <basic_check+0x205>
  1048b1:	c7 44 24 0c 5a 6c 10 	movl   $0x106c5a,0xc(%esp)
  1048b8:	00 
  1048b9:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1048c0:	00 
  1048c1:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  1048c8:	00 
  1048c9:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  1048d0:	e8 08 bb ff ff       	call   1003dd <__panic>

    list_entry_t free_list_store = free_list;
  1048d5:	a1 5c 89 11 00       	mov    0x11895c,%eax
  1048da:	8b 15 60 89 11 00    	mov    0x118960,%edx
  1048e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1048e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1048e6:	c7 45 e0 5c 89 11 00 	movl   $0x11895c,-0x20(%ebp)
    elm->prev = elm->next = elm;
  1048ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1048f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1048f3:	89 50 04             	mov    %edx,0x4(%eax)
  1048f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1048f9:	8b 50 04             	mov    0x4(%eax),%edx
  1048fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1048ff:	89 10                	mov    %edx,(%eax)
  104901:	c7 45 dc 5c 89 11 00 	movl   $0x11895c,-0x24(%ebp)
    return list->next == list;
  104908:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10490b:	8b 40 04             	mov    0x4(%eax),%eax
  10490e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104911:	0f 94 c0             	sete   %al
  104914:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104917:	85 c0                	test   %eax,%eax
  104919:	75 24                	jne    10493f <basic_check+0x26f>
  10491b:	c7 44 24 0c 77 6c 10 	movl   $0x106c77,0xc(%esp)
  104922:	00 
  104923:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10492a:	00 
  10492b:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  104932:	00 
  104933:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10493a:	e8 9e ba ff ff       	call   1003dd <__panic>

    unsigned int nr_free_store = nr_free;
  10493f:	a1 64 89 11 00       	mov    0x118964,%eax
  104944:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104947:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  10494e:	00 00 00 

    assert(alloc_page() == NULL);
  104951:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104958:	e8 56 e2 ff ff       	call   102bb3 <alloc_pages>
  10495d:	85 c0                	test   %eax,%eax
  10495f:	74 24                	je     104985 <basic_check+0x2b5>
  104961:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  104968:	00 
  104969:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104970:	00 
  104971:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  104978:	00 
  104979:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104980:	e8 58 ba ff ff       	call   1003dd <__panic>

    free_page(p0);
  104985:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10498c:	00 
  10498d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104990:	89 04 24             	mov    %eax,(%esp)
  104993:	e8 53 e2 ff ff       	call   102beb <free_pages>
    free_page(p1);
  104998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10499f:	00 
  1049a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049a3:	89 04 24             	mov    %eax,(%esp)
  1049a6:	e8 40 e2 ff ff       	call   102beb <free_pages>
    free_page(p2);
  1049ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1049b2:	00 
  1049b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049b6:	89 04 24             	mov    %eax,(%esp)
  1049b9:	e8 2d e2 ff ff       	call   102beb <free_pages>
    assert(nr_free == 3);
  1049be:	a1 64 89 11 00       	mov    0x118964,%eax
  1049c3:	83 f8 03             	cmp    $0x3,%eax
  1049c6:	74 24                	je     1049ec <basic_check+0x31c>
  1049c8:	c7 44 24 0c a3 6c 10 	movl   $0x106ca3,0xc(%esp)
  1049cf:	00 
  1049d0:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1049d7:	00 
  1049d8:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  1049df:	00 
  1049e0:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  1049e7:	e8 f1 b9 ff ff       	call   1003dd <__panic>

    assert((p0 = alloc_page()) != NULL);
  1049ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1049f3:	e8 bb e1 ff ff       	call   102bb3 <alloc_pages>
  1049f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1049fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1049ff:	75 24                	jne    104a25 <basic_check+0x355>
  104a01:	c7 44 24 0c 6c 6b 10 	movl   $0x106b6c,0xc(%esp)
  104a08:	00 
  104a09:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104a10:	00 
  104a11:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104a18:	00 
  104a19:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104a20:	e8 b8 b9 ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
  104a25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a2c:	e8 82 e1 ff ff       	call   102bb3 <alloc_pages>
  104a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a38:	75 24                	jne    104a5e <basic_check+0x38e>
  104a3a:	c7 44 24 0c 88 6b 10 	movl   $0x106b88,0xc(%esp)
  104a41:	00 
  104a42:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104a49:	00 
  104a4a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104a51:	00 
  104a52:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104a59:	e8 7f b9 ff ff       	call   1003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
  104a5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a65:	e8 49 e1 ff ff       	call   102bb3 <alloc_pages>
  104a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104a71:	75 24                	jne    104a97 <basic_check+0x3c7>
  104a73:	c7 44 24 0c a4 6b 10 	movl   $0x106ba4,0xc(%esp)
  104a7a:	00 
  104a7b:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104a82:	00 
  104a83:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  104a8a:	00 
  104a8b:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104a92:	e8 46 b9 ff ff       	call   1003dd <__panic>

    assert(alloc_page() == NULL);
  104a97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a9e:	e8 10 e1 ff ff       	call   102bb3 <alloc_pages>
  104aa3:	85 c0                	test   %eax,%eax
  104aa5:	74 24                	je     104acb <basic_check+0x3fb>
  104aa7:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  104aae:	00 
  104aaf:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104ab6:	00 
  104ab7:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  104abe:	00 
  104abf:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104ac6:	e8 12 b9 ff ff       	call   1003dd <__panic>

    free_page(p0);
  104acb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ad2:	00 
  104ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ad6:	89 04 24             	mov    %eax,(%esp)
  104ad9:	e8 0d e1 ff ff       	call   102beb <free_pages>
  104ade:	c7 45 d8 5c 89 11 00 	movl   $0x11895c,-0x28(%ebp)
  104ae5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104ae8:	8b 40 04             	mov    0x4(%eax),%eax
  104aeb:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104aee:	0f 94 c0             	sete   %al
  104af1:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104af4:	85 c0                	test   %eax,%eax
  104af6:	74 24                	je     104b1c <basic_check+0x44c>
  104af8:	c7 44 24 0c b0 6c 10 	movl   $0x106cb0,0xc(%esp)
  104aff:	00 
  104b00:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104b07:	00 
  104b08:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104b0f:	00 
  104b10:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104b17:	e8 c1 b8 ff ff       	call   1003dd <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104b1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b23:	e8 8b e0 ff ff       	call   102bb3 <alloc_pages>
  104b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104b31:	74 24                	je     104b57 <basic_check+0x487>
  104b33:	c7 44 24 0c c8 6c 10 	movl   $0x106cc8,0xc(%esp)
  104b3a:	00 
  104b3b:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104b42:	00 
  104b43:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  104b4a:	00 
  104b4b:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104b52:	e8 86 b8 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  104b57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b5e:	e8 50 e0 ff ff       	call   102bb3 <alloc_pages>
  104b63:	85 c0                	test   %eax,%eax
  104b65:	74 24                	je     104b8b <basic_check+0x4bb>
  104b67:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  104b6e:	00 
  104b6f:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104b76:	00 
  104b77:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  104b7e:	00 
  104b7f:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104b86:	e8 52 b8 ff ff       	call   1003dd <__panic>

    assert(nr_free == 0);
  104b8b:	a1 64 89 11 00       	mov    0x118964,%eax
  104b90:	85 c0                	test   %eax,%eax
  104b92:	74 24                	je     104bb8 <basic_check+0x4e8>
  104b94:	c7 44 24 0c e1 6c 10 	movl   $0x106ce1,0xc(%esp)
  104b9b:	00 
  104b9c:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104ba3:	00 
  104ba4:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  104bab:	00 
  104bac:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104bb3:	e8 25 b8 ff ff       	call   1003dd <__panic>
    free_list = free_list_store;
  104bb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104bbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104bbe:	a3 5c 89 11 00       	mov    %eax,0x11895c
  104bc3:	89 15 60 89 11 00    	mov    %edx,0x118960
    nr_free = nr_free_store;
  104bc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104bcc:	a3 64 89 11 00       	mov    %eax,0x118964

    free_page(p);
  104bd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bd8:	00 
  104bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bdc:	89 04 24             	mov    %eax,(%esp)
  104bdf:	e8 07 e0 ff ff       	call   102beb <free_pages>
    free_page(p1);
  104be4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104beb:	00 
  104bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bef:	89 04 24             	mov    %eax,(%esp)
  104bf2:	e8 f4 df ff ff       	call   102beb <free_pages>
    free_page(p2);
  104bf7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104bfe:	00 
  104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c02:	89 04 24             	mov    %eax,(%esp)
  104c05:	e8 e1 df ff ff       	call   102beb <free_pages>
}
  104c0a:	c9                   	leave  
  104c0b:	c3                   	ret    

00104c0c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104c0c:	55                   	push   %ebp
  104c0d:	89 e5                	mov    %esp,%ebp
  104c0f:	53                   	push   %ebx
  104c10:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  104c16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104c1d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104c24:	c7 45 ec 5c 89 11 00 	movl   $0x11895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104c2b:	eb 6b                	jmp    104c98 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  104c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c30:	83 e8 0c             	sub    $0xc,%eax
  104c33:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  104c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c39:	83 c0 04             	add    $0x4,%eax
  104c3c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104c43:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104c46:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104c49:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104c4c:	0f a3 10             	bt     %edx,(%eax)
  104c4f:	19 c0                	sbb    %eax,%eax
  104c51:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104c54:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104c58:	0f 95 c0             	setne  %al
  104c5b:	0f b6 c0             	movzbl %al,%eax
  104c5e:	85 c0                	test   %eax,%eax
  104c60:	75 24                	jne    104c86 <default_check+0x7a>
  104c62:	c7 44 24 0c ee 6c 10 	movl   $0x106cee,0xc(%esp)
  104c69:	00 
  104c6a:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104c71:	00 
  104c72:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  104c79:	00 
  104c7a:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104c81:	e8 57 b7 ff ff       	call   1003dd <__panic>
        count ++, total += p->property;
  104c86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  104c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c8d:	8b 50 08             	mov    0x8(%eax),%edx
  104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c93:	01 d0                	add    %edx,%eax
  104c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c9b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104c9e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104ca1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ca7:	81 7d ec 5c 89 11 00 	cmpl   $0x11895c,-0x14(%ebp)
  104cae:	0f 85 79 ff ff ff    	jne    104c2d <default_check+0x21>
    }
    assert(total == nr_free_pages());
  104cb4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  104cb7:	e8 61 df ff ff       	call   102c1d <nr_free_pages>
  104cbc:	39 c3                	cmp    %eax,%ebx
  104cbe:	74 24                	je     104ce4 <default_check+0xd8>
  104cc0:	c7 44 24 0c fe 6c 10 	movl   $0x106cfe,0xc(%esp)
  104cc7:	00 
  104cc8:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104ccf:	00 
  104cd0:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  104cd7:	00 
  104cd8:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104cdf:	e8 f9 b6 ff ff       	call   1003dd <__panic>

    basic_check();
  104ce4:	e8 e7 f9 ff ff       	call   1046d0 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104ce9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104cf0:	e8 be de ff ff       	call   102bb3 <alloc_pages>
  104cf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  104cf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104cfc:	75 24                	jne    104d22 <default_check+0x116>
  104cfe:	c7 44 24 0c 17 6d 10 	movl   $0x106d17,0xc(%esp)
  104d05:	00 
  104d06:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104d0d:	00 
  104d0e:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  104d15:	00 
  104d16:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104d1d:	e8 bb b6 ff ff       	call   1003dd <__panic>
    assert(!PageProperty(p0));
  104d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d25:	83 c0 04             	add    $0x4,%eax
  104d28:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104d2f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104d32:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104d35:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104d38:	0f a3 10             	bt     %edx,(%eax)
  104d3b:	19 c0                	sbb    %eax,%eax
  104d3d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104d40:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104d44:	0f 95 c0             	setne  %al
  104d47:	0f b6 c0             	movzbl %al,%eax
  104d4a:	85 c0                	test   %eax,%eax
  104d4c:	74 24                	je     104d72 <default_check+0x166>
  104d4e:	c7 44 24 0c 22 6d 10 	movl   $0x106d22,0xc(%esp)
  104d55:	00 
  104d56:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104d5d:	00 
  104d5e:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  104d65:	00 
  104d66:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104d6d:	e8 6b b6 ff ff       	call   1003dd <__panic>

    list_entry_t free_list_store = free_list;
  104d72:	a1 5c 89 11 00       	mov    0x11895c,%eax
  104d77:	8b 15 60 89 11 00    	mov    0x118960,%edx
  104d7d:	89 45 80             	mov    %eax,-0x80(%ebp)
  104d80:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104d83:	c7 45 b4 5c 89 11 00 	movl   $0x11895c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
  104d8a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104d8d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104d90:	89 50 04             	mov    %edx,0x4(%eax)
  104d93:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104d96:	8b 50 04             	mov    0x4(%eax),%edx
  104d99:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104d9c:	89 10                	mov    %edx,(%eax)
  104d9e:	c7 45 b0 5c 89 11 00 	movl   $0x11895c,-0x50(%ebp)
    return list->next == list;
  104da5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104da8:	8b 40 04             	mov    0x4(%eax),%eax
  104dab:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  104dae:	0f 94 c0             	sete   %al
  104db1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104db4:	85 c0                	test   %eax,%eax
  104db6:	75 24                	jne    104ddc <default_check+0x1d0>
  104db8:	c7 44 24 0c 77 6c 10 	movl   $0x106c77,0xc(%esp)
  104dbf:	00 
  104dc0:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104dc7:	00 
  104dc8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  104dcf:	00 
  104dd0:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104dd7:	e8 01 b6 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  104ddc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104de3:	e8 cb dd ff ff       	call   102bb3 <alloc_pages>
  104de8:	85 c0                	test   %eax,%eax
  104dea:	74 24                	je     104e10 <default_check+0x204>
  104dec:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  104df3:	00 
  104df4:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104dfb:	00 
  104dfc:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  104e03:	00 
  104e04:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104e0b:	e8 cd b5 ff ff       	call   1003dd <__panic>

    unsigned int nr_free_store = nr_free;
  104e10:	a1 64 89 11 00       	mov    0x118964,%eax
  104e15:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  104e18:	c7 05 64 89 11 00 00 	movl   $0x0,0x118964
  104e1f:	00 00 00 

    free_pages(p0 + 2, 3);
  104e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e25:	83 c0 28             	add    $0x28,%eax
  104e28:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104e2f:	00 
  104e30:	89 04 24             	mov    %eax,(%esp)
  104e33:	e8 b3 dd ff ff       	call   102beb <free_pages>
    assert(alloc_pages(4) == NULL);
  104e38:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104e3f:	e8 6f dd ff ff       	call   102bb3 <alloc_pages>
  104e44:	85 c0                	test   %eax,%eax
  104e46:	74 24                	je     104e6c <default_check+0x260>
  104e48:	c7 44 24 0c 34 6d 10 	movl   $0x106d34,0xc(%esp)
  104e4f:	00 
  104e50:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104e57:	00 
  104e58:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104e5f:	00 
  104e60:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104e67:	e8 71 b5 ff ff       	call   1003dd <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e6f:	83 c0 28             	add    $0x28,%eax
  104e72:	83 c0 04             	add    $0x4,%eax
  104e75:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104e7c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e7f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104e82:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104e85:	0f a3 10             	bt     %edx,(%eax)
  104e88:	19 c0                	sbb    %eax,%eax
  104e8a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104e8d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104e91:	0f 95 c0             	setne  %al
  104e94:	0f b6 c0             	movzbl %al,%eax
  104e97:	85 c0                	test   %eax,%eax
  104e99:	74 0e                	je     104ea9 <default_check+0x29d>
  104e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e9e:	83 c0 28             	add    $0x28,%eax
  104ea1:	8b 40 08             	mov    0x8(%eax),%eax
  104ea4:	83 f8 03             	cmp    $0x3,%eax
  104ea7:	74 24                	je     104ecd <default_check+0x2c1>
  104ea9:	c7 44 24 0c 4c 6d 10 	movl   $0x106d4c,0xc(%esp)
  104eb0:	00 
  104eb1:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104eb8:	00 
  104eb9:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  104ec0:	00 
  104ec1:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104ec8:	e8 10 b5 ff ff       	call   1003dd <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104ecd:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104ed4:	e8 da dc ff ff       	call   102bb3 <alloc_pages>
  104ed9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104edc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104ee0:	75 24                	jne    104f06 <default_check+0x2fa>
  104ee2:	c7 44 24 0c 78 6d 10 	movl   $0x106d78,0xc(%esp)
  104ee9:	00 
  104eea:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104ef1:	00 
  104ef2:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  104ef9:	00 
  104efa:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104f01:	e8 d7 b4 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  104f06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f0d:	e8 a1 dc ff ff       	call   102bb3 <alloc_pages>
  104f12:	85 c0                	test   %eax,%eax
  104f14:	74 24                	je     104f3a <default_check+0x32e>
  104f16:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  104f1d:	00 
  104f1e:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104f25:	00 
  104f26:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  104f2d:	00 
  104f2e:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104f35:	e8 a3 b4 ff ff       	call   1003dd <__panic>
    assert(p0 + 2 == p1);
  104f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f3d:	83 c0 28             	add    $0x28,%eax
  104f40:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104f43:	74 24                	je     104f69 <default_check+0x35d>
  104f45:	c7 44 24 0c 96 6d 10 	movl   $0x106d96,0xc(%esp)
  104f4c:	00 
  104f4d:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104f54:	00 
  104f55:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  104f5c:	00 
  104f5d:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104f64:	e8 74 b4 ff ff       	call   1003dd <__panic>

    p2 = p0 + 1;
  104f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f6c:	83 c0 14             	add    $0x14,%eax
  104f6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  104f72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f79:	00 
  104f7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f7d:	89 04 24             	mov    %eax,(%esp)
  104f80:	e8 66 dc ff ff       	call   102beb <free_pages>
    free_pages(p1, 3);
  104f85:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104f8c:	00 
  104f8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f90:	89 04 24             	mov    %eax,(%esp)
  104f93:	e8 53 dc ff ff       	call   102beb <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  104f98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f9b:	83 c0 04             	add    $0x4,%eax
  104f9e:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  104fa5:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104fa8:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104fab:	8b 55 a0             	mov    -0x60(%ebp),%edx
  104fae:	0f a3 10             	bt     %edx,(%eax)
  104fb1:	19 c0                	sbb    %eax,%eax
  104fb3:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  104fb6:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  104fba:	0f 95 c0             	setne  %al
  104fbd:	0f b6 c0             	movzbl %al,%eax
  104fc0:	85 c0                	test   %eax,%eax
  104fc2:	74 0b                	je     104fcf <default_check+0x3c3>
  104fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fc7:	8b 40 08             	mov    0x8(%eax),%eax
  104fca:	83 f8 01             	cmp    $0x1,%eax
  104fcd:	74 24                	je     104ff3 <default_check+0x3e7>
  104fcf:	c7 44 24 0c a4 6d 10 	movl   $0x106da4,0xc(%esp)
  104fd6:	00 
  104fd7:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  104fde:	00 
  104fdf:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
  104fe6:	00 
  104fe7:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  104fee:	e8 ea b3 ff ff       	call   1003dd <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  104ff3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104ff6:	83 c0 04             	add    $0x4,%eax
  104ff9:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105000:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105003:	8b 45 90             	mov    -0x70(%ebp),%eax
  105006:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105009:	0f a3 10             	bt     %edx,(%eax)
  10500c:	19 c0                	sbb    %eax,%eax
  10500e:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105011:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105015:	0f 95 c0             	setne  %al
  105018:	0f b6 c0             	movzbl %al,%eax
  10501b:	85 c0                	test   %eax,%eax
  10501d:	74 0b                	je     10502a <default_check+0x41e>
  10501f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105022:	8b 40 08             	mov    0x8(%eax),%eax
  105025:	83 f8 03             	cmp    $0x3,%eax
  105028:	74 24                	je     10504e <default_check+0x442>
  10502a:	c7 44 24 0c cc 6d 10 	movl   $0x106dcc,0xc(%esp)
  105031:	00 
  105032:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  105039:	00 
  10503a:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  105041:	00 
  105042:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  105049:	e8 8f b3 ff ff       	call   1003dd <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10504e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105055:	e8 59 db ff ff       	call   102bb3 <alloc_pages>
  10505a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10505d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105060:	83 e8 14             	sub    $0x14,%eax
  105063:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  105066:	74 24                	je     10508c <default_check+0x480>
  105068:	c7 44 24 0c f2 6d 10 	movl   $0x106df2,0xc(%esp)
  10506f:	00 
  105070:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  105077:	00 
  105078:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  10507f:	00 
  105080:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  105087:	e8 51 b3 ff ff       	call   1003dd <__panic>
    free_page(p0);
  10508c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105093:	00 
  105094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105097:	89 04 24             	mov    %eax,(%esp)
  10509a:	e8 4c db ff ff       	call   102beb <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10509f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1050a6:	e8 08 db ff ff       	call   102bb3 <alloc_pages>
  1050ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1050ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1050b1:	83 c0 14             	add    $0x14,%eax
  1050b4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1050b7:	74 24                	je     1050dd <default_check+0x4d1>
  1050b9:	c7 44 24 0c 10 6e 10 	movl   $0x106e10,0xc(%esp)
  1050c0:	00 
  1050c1:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  1050c8:	00 
  1050c9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  1050d0:	00 
  1050d1:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  1050d8:	e8 00 b3 ff ff       	call   1003dd <__panic>

    free_pages(p0, 2);
  1050dd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1050e4:	00 
  1050e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1050e8:	89 04 24             	mov    %eax,(%esp)
  1050eb:	e8 fb da ff ff       	call   102beb <free_pages>
    free_page(p2);
  1050f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050f7:	00 
  1050f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1050fb:	89 04 24             	mov    %eax,(%esp)
  1050fe:	e8 e8 da ff ff       	call   102beb <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105103:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10510a:	e8 a4 da ff ff       	call   102bb3 <alloc_pages>
  10510f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105112:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105116:	75 24                	jne    10513c <default_check+0x530>
  105118:	c7 44 24 0c 30 6e 10 	movl   $0x106e30,0xc(%esp)
  10511f:	00 
  105120:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  105127:	00 
  105128:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  10512f:	00 
  105130:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  105137:	e8 a1 b2 ff ff       	call   1003dd <__panic>
    assert(alloc_page() == NULL);
  10513c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105143:	e8 6b da ff ff       	call   102bb3 <alloc_pages>
  105148:	85 c0                	test   %eax,%eax
  10514a:	74 24                	je     105170 <default_check+0x564>
  10514c:	c7 44 24 0c 8e 6c 10 	movl   $0x106c8e,0xc(%esp)
  105153:	00 
  105154:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10515b:	00 
  10515c:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
  105163:	00 
  105164:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10516b:	e8 6d b2 ff ff       	call   1003dd <__panic>

    assert(nr_free == 0);
  105170:	a1 64 89 11 00       	mov    0x118964,%eax
  105175:	85 c0                	test   %eax,%eax
  105177:	74 24                	je     10519d <default_check+0x591>
  105179:	c7 44 24 0c e1 6c 10 	movl   $0x106ce1,0xc(%esp)
  105180:	00 
  105181:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  105188:	00 
  105189:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  105190:	00 
  105191:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  105198:	e8 40 b2 ff ff       	call   1003dd <__panic>
    nr_free = nr_free_store;
  10519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051a0:	a3 64 89 11 00       	mov    %eax,0x118964

    free_list = free_list_store;
  1051a5:	8b 45 80             	mov    -0x80(%ebp),%eax
  1051a8:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1051ab:	a3 5c 89 11 00       	mov    %eax,0x11895c
  1051b0:	89 15 60 89 11 00    	mov    %edx,0x118960
    free_pages(p0, 5);
  1051b6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1051bd:	00 
  1051be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1051c1:	89 04 24             	mov    %eax,(%esp)
  1051c4:	e8 22 da ff ff       	call   102beb <free_pages>

    le = &free_list;
  1051c9:	c7 45 ec 5c 89 11 00 	movl   $0x11895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1051d0:	eb 1d                	jmp    1051ef <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
  1051d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051d5:	83 e8 0c             	sub    $0xc,%eax
  1051d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1051db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1051df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1051e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1051e5:	8b 40 08             	mov    0x8(%eax),%eax
  1051e8:	29 c2                	sub    %eax,%edx
  1051ea:	89 d0                	mov    %edx,%eax
  1051ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1051ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1051f2:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  1051f5:	8b 45 88             	mov    -0x78(%ebp),%eax
  1051f8:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1051fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1051fe:	81 7d ec 5c 89 11 00 	cmpl   $0x11895c,-0x14(%ebp)
  105205:	75 cb                	jne    1051d2 <default_check+0x5c6>
    }
    assert(count == 0);
  105207:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10520b:	74 24                	je     105231 <default_check+0x625>
  10520d:	c7 44 24 0c 4e 6e 10 	movl   $0x106e4e,0xc(%esp)
  105214:	00 
  105215:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  10521c:	00 
  10521d:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  105224:	00 
  105225:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  10522c:	e8 ac b1 ff ff       	call   1003dd <__panic>
    assert(total == 0);
  105231:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105235:	74 24                	je     10525b <default_check+0x64f>
  105237:	c7 44 24 0c 59 6e 10 	movl   $0x106e59,0xc(%esp)
  10523e:	00 
  10523f:	c7 44 24 08 1e 6b 10 	movl   $0x106b1e,0x8(%esp)
  105246:	00 
  105247:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  10524e:	00 
  10524f:	c7 04 24 33 6b 10 00 	movl   $0x106b33,(%esp)
  105256:	e8 82 b1 ff ff       	call   1003dd <__panic>
}
  10525b:	81 c4 94 00 00 00    	add    $0x94,%esp
  105261:	5b                   	pop    %ebx
  105262:	5d                   	pop    %ebp
  105263:	c3                   	ret    

00105264 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105264:	55                   	push   %ebp
  105265:	89 e5                	mov    %esp,%ebp
  105267:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10526a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105271:	eb 04                	jmp    105277 <strlen+0x13>
        cnt ++;
  105273:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  105277:	8b 45 08             	mov    0x8(%ebp),%eax
  10527a:	8d 50 01             	lea    0x1(%eax),%edx
  10527d:	89 55 08             	mov    %edx,0x8(%ebp)
  105280:	0f b6 00             	movzbl (%eax),%eax
  105283:	84 c0                	test   %al,%al
  105285:	75 ec                	jne    105273 <strlen+0xf>
    }
    return cnt;
  105287:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10528a:	c9                   	leave  
  10528b:	c3                   	ret    

0010528c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10528c:	55                   	push   %ebp
  10528d:	89 e5                	mov    %esp,%ebp
  10528f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105292:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105299:	eb 04                	jmp    10529f <strnlen+0x13>
        cnt ++;
  10529b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10529f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052a5:	73 10                	jae    1052b7 <strnlen+0x2b>
  1052a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1052aa:	8d 50 01             	lea    0x1(%eax),%edx
  1052ad:	89 55 08             	mov    %edx,0x8(%ebp)
  1052b0:	0f b6 00             	movzbl (%eax),%eax
  1052b3:	84 c0                	test   %al,%al
  1052b5:	75 e4                	jne    10529b <strnlen+0xf>
    }
    return cnt;
  1052b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1052ba:	c9                   	leave  
  1052bb:	c3                   	ret    

001052bc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1052bc:	55                   	push   %ebp
  1052bd:	89 e5                	mov    %esp,%ebp
  1052bf:	57                   	push   %edi
  1052c0:	56                   	push   %esi
  1052c1:	83 ec 20             	sub    $0x20,%esp
  1052c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1052c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1052ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1052d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1052d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052d6:	89 d1                	mov    %edx,%ecx
  1052d8:	89 c2                	mov    %eax,%edx
  1052da:	89 ce                	mov    %ecx,%esi
  1052dc:	89 d7                	mov    %edx,%edi
  1052de:	ac                   	lods   %ds:(%esi),%al
  1052df:	aa                   	stos   %al,%es:(%edi)
  1052e0:	84 c0                	test   %al,%al
  1052e2:	75 fa                	jne    1052de <strcpy+0x22>
  1052e4:	89 fa                	mov    %edi,%edx
  1052e6:	89 f1                	mov    %esi,%ecx
  1052e8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1052eb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1052ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1052f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1052f4:	83 c4 20             	add    $0x20,%esp
  1052f7:	5e                   	pop    %esi
  1052f8:	5f                   	pop    %edi
  1052f9:	5d                   	pop    %ebp
  1052fa:	c3                   	ret    

001052fb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1052fb:	55                   	push   %ebp
  1052fc:	89 e5                	mov    %esp,%ebp
  1052fe:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105301:	8b 45 08             	mov    0x8(%ebp),%eax
  105304:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105307:	eb 21                	jmp    10532a <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105309:	8b 45 0c             	mov    0xc(%ebp),%eax
  10530c:	0f b6 10             	movzbl (%eax),%edx
  10530f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105312:	88 10                	mov    %dl,(%eax)
  105314:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105317:	0f b6 00             	movzbl (%eax),%eax
  10531a:	84 c0                	test   %al,%al
  10531c:	74 04                	je     105322 <strncpy+0x27>
            src ++;
  10531e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105322:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105326:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  10532a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10532e:	75 d9                	jne    105309 <strncpy+0xe>
    }
    return dst;
  105330:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105333:	c9                   	leave  
  105334:	c3                   	ret    

00105335 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105335:	55                   	push   %ebp
  105336:	89 e5                	mov    %esp,%ebp
  105338:	57                   	push   %edi
  105339:	56                   	push   %esi
  10533a:	83 ec 20             	sub    $0x20,%esp
  10533d:	8b 45 08             	mov    0x8(%ebp),%eax
  105340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105343:	8b 45 0c             	mov    0xc(%ebp),%eax
  105346:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105349:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10534c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10534f:	89 d1                	mov    %edx,%ecx
  105351:	89 c2                	mov    %eax,%edx
  105353:	89 ce                	mov    %ecx,%esi
  105355:	89 d7                	mov    %edx,%edi
  105357:	ac                   	lods   %ds:(%esi),%al
  105358:	ae                   	scas   %es:(%edi),%al
  105359:	75 08                	jne    105363 <strcmp+0x2e>
  10535b:	84 c0                	test   %al,%al
  10535d:	75 f8                	jne    105357 <strcmp+0x22>
  10535f:	31 c0                	xor    %eax,%eax
  105361:	eb 04                	jmp    105367 <strcmp+0x32>
  105363:	19 c0                	sbb    %eax,%eax
  105365:	0c 01                	or     $0x1,%al
  105367:	89 fa                	mov    %edi,%edx
  105369:	89 f1                	mov    %esi,%ecx
  10536b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10536e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105371:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105374:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105377:	83 c4 20             	add    $0x20,%esp
  10537a:	5e                   	pop    %esi
  10537b:	5f                   	pop    %edi
  10537c:	5d                   	pop    %ebp
  10537d:	c3                   	ret    

0010537e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10537e:	55                   	push   %ebp
  10537f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105381:	eb 0c                	jmp    10538f <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105383:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105387:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10538b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10538f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105393:	74 1a                	je     1053af <strncmp+0x31>
  105395:	8b 45 08             	mov    0x8(%ebp),%eax
  105398:	0f b6 00             	movzbl (%eax),%eax
  10539b:	84 c0                	test   %al,%al
  10539d:	74 10                	je     1053af <strncmp+0x31>
  10539f:	8b 45 08             	mov    0x8(%ebp),%eax
  1053a2:	0f b6 10             	movzbl (%eax),%edx
  1053a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053a8:	0f b6 00             	movzbl (%eax),%eax
  1053ab:	38 c2                	cmp    %al,%dl
  1053ad:	74 d4                	je     105383 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1053af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1053b3:	74 18                	je     1053cd <strncmp+0x4f>
  1053b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1053b8:	0f b6 00             	movzbl (%eax),%eax
  1053bb:	0f b6 d0             	movzbl %al,%edx
  1053be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053c1:	0f b6 00             	movzbl (%eax),%eax
  1053c4:	0f b6 c0             	movzbl %al,%eax
  1053c7:	29 c2                	sub    %eax,%edx
  1053c9:	89 d0                	mov    %edx,%eax
  1053cb:	eb 05                	jmp    1053d2 <strncmp+0x54>
  1053cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1053d2:	5d                   	pop    %ebp
  1053d3:	c3                   	ret    

001053d4 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1053d4:	55                   	push   %ebp
  1053d5:	89 e5                	mov    %esp,%ebp
  1053d7:	83 ec 04             	sub    $0x4,%esp
  1053da:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053dd:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1053e0:	eb 14                	jmp    1053f6 <strchr+0x22>
        if (*s == c) {
  1053e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1053e5:	0f b6 00             	movzbl (%eax),%eax
  1053e8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1053eb:	75 05                	jne    1053f2 <strchr+0x1e>
            return (char *)s;
  1053ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1053f0:	eb 13                	jmp    105405 <strchr+0x31>
        }
        s ++;
  1053f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  1053f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1053f9:	0f b6 00             	movzbl (%eax),%eax
  1053fc:	84 c0                	test   %al,%al
  1053fe:	75 e2                	jne    1053e2 <strchr+0xe>
    }
    return NULL;
  105400:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105405:	c9                   	leave  
  105406:	c3                   	ret    

00105407 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105407:	55                   	push   %ebp
  105408:	89 e5                	mov    %esp,%ebp
  10540a:	83 ec 04             	sub    $0x4,%esp
  10540d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105410:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105413:	eb 11                	jmp    105426 <strfind+0x1f>
        if (*s == c) {
  105415:	8b 45 08             	mov    0x8(%ebp),%eax
  105418:	0f b6 00             	movzbl (%eax),%eax
  10541b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10541e:	75 02                	jne    105422 <strfind+0x1b>
            break;
  105420:	eb 0e                	jmp    105430 <strfind+0x29>
        }
        s ++;
  105422:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  105426:	8b 45 08             	mov    0x8(%ebp),%eax
  105429:	0f b6 00             	movzbl (%eax),%eax
  10542c:	84 c0                	test   %al,%al
  10542e:	75 e5                	jne    105415 <strfind+0xe>
    }
    return (char *)s;
  105430:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105433:	c9                   	leave  
  105434:	c3                   	ret    

00105435 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105435:	55                   	push   %ebp
  105436:	89 e5                	mov    %esp,%ebp
  105438:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10543b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105442:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105449:	eb 04                	jmp    10544f <strtol+0x1a>
        s ++;
  10544b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10544f:	8b 45 08             	mov    0x8(%ebp),%eax
  105452:	0f b6 00             	movzbl (%eax),%eax
  105455:	3c 20                	cmp    $0x20,%al
  105457:	74 f2                	je     10544b <strtol+0x16>
  105459:	8b 45 08             	mov    0x8(%ebp),%eax
  10545c:	0f b6 00             	movzbl (%eax),%eax
  10545f:	3c 09                	cmp    $0x9,%al
  105461:	74 e8                	je     10544b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105463:	8b 45 08             	mov    0x8(%ebp),%eax
  105466:	0f b6 00             	movzbl (%eax),%eax
  105469:	3c 2b                	cmp    $0x2b,%al
  10546b:	75 06                	jne    105473 <strtol+0x3e>
        s ++;
  10546d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105471:	eb 15                	jmp    105488 <strtol+0x53>
    }
    else if (*s == '-') {
  105473:	8b 45 08             	mov    0x8(%ebp),%eax
  105476:	0f b6 00             	movzbl (%eax),%eax
  105479:	3c 2d                	cmp    $0x2d,%al
  10547b:	75 0b                	jne    105488 <strtol+0x53>
        s ++, neg = 1;
  10547d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105481:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105488:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10548c:	74 06                	je     105494 <strtol+0x5f>
  10548e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105492:	75 24                	jne    1054b8 <strtol+0x83>
  105494:	8b 45 08             	mov    0x8(%ebp),%eax
  105497:	0f b6 00             	movzbl (%eax),%eax
  10549a:	3c 30                	cmp    $0x30,%al
  10549c:	75 1a                	jne    1054b8 <strtol+0x83>
  10549e:	8b 45 08             	mov    0x8(%ebp),%eax
  1054a1:	83 c0 01             	add    $0x1,%eax
  1054a4:	0f b6 00             	movzbl (%eax),%eax
  1054a7:	3c 78                	cmp    $0x78,%al
  1054a9:	75 0d                	jne    1054b8 <strtol+0x83>
        s += 2, base = 16;
  1054ab:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1054af:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1054b6:	eb 2a                	jmp    1054e2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  1054b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054bc:	75 17                	jne    1054d5 <strtol+0xa0>
  1054be:	8b 45 08             	mov    0x8(%ebp),%eax
  1054c1:	0f b6 00             	movzbl (%eax),%eax
  1054c4:	3c 30                	cmp    $0x30,%al
  1054c6:	75 0d                	jne    1054d5 <strtol+0xa0>
        s ++, base = 8;
  1054c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1054cc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1054d3:	eb 0d                	jmp    1054e2 <strtol+0xad>
    }
    else if (base == 0) {
  1054d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054d9:	75 07                	jne    1054e2 <strtol+0xad>
        base = 10;
  1054db:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1054e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1054e5:	0f b6 00             	movzbl (%eax),%eax
  1054e8:	3c 2f                	cmp    $0x2f,%al
  1054ea:	7e 1b                	jle    105507 <strtol+0xd2>
  1054ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1054ef:	0f b6 00             	movzbl (%eax),%eax
  1054f2:	3c 39                	cmp    $0x39,%al
  1054f4:	7f 11                	jg     105507 <strtol+0xd2>
            dig = *s - '0';
  1054f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f9:	0f b6 00             	movzbl (%eax),%eax
  1054fc:	0f be c0             	movsbl %al,%eax
  1054ff:	83 e8 30             	sub    $0x30,%eax
  105502:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105505:	eb 48                	jmp    10554f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105507:	8b 45 08             	mov    0x8(%ebp),%eax
  10550a:	0f b6 00             	movzbl (%eax),%eax
  10550d:	3c 60                	cmp    $0x60,%al
  10550f:	7e 1b                	jle    10552c <strtol+0xf7>
  105511:	8b 45 08             	mov    0x8(%ebp),%eax
  105514:	0f b6 00             	movzbl (%eax),%eax
  105517:	3c 7a                	cmp    $0x7a,%al
  105519:	7f 11                	jg     10552c <strtol+0xf7>
            dig = *s - 'a' + 10;
  10551b:	8b 45 08             	mov    0x8(%ebp),%eax
  10551e:	0f b6 00             	movzbl (%eax),%eax
  105521:	0f be c0             	movsbl %al,%eax
  105524:	83 e8 57             	sub    $0x57,%eax
  105527:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10552a:	eb 23                	jmp    10554f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10552c:	8b 45 08             	mov    0x8(%ebp),%eax
  10552f:	0f b6 00             	movzbl (%eax),%eax
  105532:	3c 40                	cmp    $0x40,%al
  105534:	7e 3d                	jle    105573 <strtol+0x13e>
  105536:	8b 45 08             	mov    0x8(%ebp),%eax
  105539:	0f b6 00             	movzbl (%eax),%eax
  10553c:	3c 5a                	cmp    $0x5a,%al
  10553e:	7f 33                	jg     105573 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105540:	8b 45 08             	mov    0x8(%ebp),%eax
  105543:	0f b6 00             	movzbl (%eax),%eax
  105546:	0f be c0             	movsbl %al,%eax
  105549:	83 e8 37             	sub    $0x37,%eax
  10554c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10554f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105552:	3b 45 10             	cmp    0x10(%ebp),%eax
  105555:	7c 02                	jl     105559 <strtol+0x124>
            break;
  105557:	eb 1a                	jmp    105573 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105559:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10555d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105560:	0f af 45 10          	imul   0x10(%ebp),%eax
  105564:	89 c2                	mov    %eax,%edx
  105566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105569:	01 d0                	add    %edx,%eax
  10556b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  10556e:	e9 6f ff ff ff       	jmp    1054e2 <strtol+0xad>

    if (endptr) {
  105573:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105577:	74 08                	je     105581 <strtol+0x14c>
        *endptr = (char *) s;
  105579:	8b 45 0c             	mov    0xc(%ebp),%eax
  10557c:	8b 55 08             	mov    0x8(%ebp),%edx
  10557f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105581:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105585:	74 07                	je     10558e <strtol+0x159>
  105587:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10558a:	f7 d8                	neg    %eax
  10558c:	eb 03                	jmp    105591 <strtol+0x15c>
  10558e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105591:	c9                   	leave  
  105592:	c3                   	ret    

00105593 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105593:	55                   	push   %ebp
  105594:	89 e5                	mov    %esp,%ebp
  105596:	57                   	push   %edi
  105597:	83 ec 24             	sub    $0x24,%esp
  10559a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10559d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1055a0:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1055a4:	8b 55 08             	mov    0x8(%ebp),%edx
  1055a7:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1055aa:	88 45 f7             	mov    %al,-0x9(%ebp)
  1055ad:	8b 45 10             	mov    0x10(%ebp),%eax
  1055b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1055b3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1055b6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1055ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1055bd:	89 d7                	mov    %edx,%edi
  1055bf:	f3 aa                	rep stos %al,%es:(%edi)
  1055c1:	89 fa                	mov    %edi,%edx
  1055c3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1055c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1055c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1055cc:	83 c4 24             	add    $0x24,%esp
  1055cf:	5f                   	pop    %edi
  1055d0:	5d                   	pop    %ebp
  1055d1:	c3                   	ret    

001055d2 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1055d2:	55                   	push   %ebp
  1055d3:	89 e5                	mov    %esp,%ebp
  1055d5:	57                   	push   %edi
  1055d6:	56                   	push   %esi
  1055d7:	53                   	push   %ebx
  1055d8:	83 ec 30             	sub    $0x30,%esp
  1055db:	8b 45 08             	mov    0x8(%ebp),%eax
  1055de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1055e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1055e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1055ea:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1055ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055f0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1055f3:	73 42                	jae    105637 <memmove+0x65>
  1055f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1055f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1055fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105601:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105604:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10560a:	c1 e8 02             	shr    $0x2,%eax
  10560d:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10560f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105612:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105615:	89 d7                	mov    %edx,%edi
  105617:	89 c6                	mov    %eax,%esi
  105619:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10561b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10561e:	83 e1 03             	and    $0x3,%ecx
  105621:	74 02                	je     105625 <memmove+0x53>
  105623:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105625:	89 f0                	mov    %esi,%eax
  105627:	89 fa                	mov    %edi,%edx
  105629:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10562c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10562f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105635:	eb 36                	jmp    10566d <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105637:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10563a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10563d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105640:	01 c2                	add    %eax,%edx
  105642:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105645:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10564b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  10564e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105651:	89 c1                	mov    %eax,%ecx
  105653:	89 d8                	mov    %ebx,%eax
  105655:	89 d6                	mov    %edx,%esi
  105657:	89 c7                	mov    %eax,%edi
  105659:	fd                   	std    
  10565a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10565c:	fc                   	cld    
  10565d:	89 f8                	mov    %edi,%eax
  10565f:	89 f2                	mov    %esi,%edx
  105661:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105664:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105667:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10566a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10566d:	83 c4 30             	add    $0x30,%esp
  105670:	5b                   	pop    %ebx
  105671:	5e                   	pop    %esi
  105672:	5f                   	pop    %edi
  105673:	5d                   	pop    %ebp
  105674:	c3                   	ret    

00105675 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105675:	55                   	push   %ebp
  105676:	89 e5                	mov    %esp,%ebp
  105678:	57                   	push   %edi
  105679:	56                   	push   %esi
  10567a:	83 ec 20             	sub    $0x20,%esp
  10567d:	8b 45 08             	mov    0x8(%ebp),%eax
  105680:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105683:	8b 45 0c             	mov    0xc(%ebp),%eax
  105686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105689:	8b 45 10             	mov    0x10(%ebp),%eax
  10568c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10568f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105692:	c1 e8 02             	shr    $0x2,%eax
  105695:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105697:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10569a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10569d:	89 d7                	mov    %edx,%edi
  10569f:	89 c6                	mov    %eax,%esi
  1056a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1056a3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1056a6:	83 e1 03             	and    $0x3,%ecx
  1056a9:	74 02                	je     1056ad <memcpy+0x38>
  1056ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1056ad:	89 f0                	mov    %esi,%eax
  1056af:	89 fa                	mov    %edi,%edx
  1056b1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1056b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1056b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  1056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1056bd:	83 c4 20             	add    $0x20,%esp
  1056c0:	5e                   	pop    %esi
  1056c1:	5f                   	pop    %edi
  1056c2:	5d                   	pop    %ebp
  1056c3:	c3                   	ret    

001056c4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1056c4:	55                   	push   %ebp
  1056c5:	89 e5                	mov    %esp,%ebp
  1056c7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1056ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1056cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1056d6:	eb 30                	jmp    105708 <memcmp+0x44>
        if (*s1 != *s2) {
  1056d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1056db:	0f b6 10             	movzbl (%eax),%edx
  1056de:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056e1:	0f b6 00             	movzbl (%eax),%eax
  1056e4:	38 c2                	cmp    %al,%dl
  1056e6:	74 18                	je     105700 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1056e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1056eb:	0f b6 00             	movzbl (%eax),%eax
  1056ee:	0f b6 d0             	movzbl %al,%edx
  1056f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056f4:	0f b6 00             	movzbl (%eax),%eax
  1056f7:	0f b6 c0             	movzbl %al,%eax
  1056fa:	29 c2                	sub    %eax,%edx
  1056fc:	89 d0                	mov    %edx,%eax
  1056fe:	eb 1a                	jmp    10571a <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105700:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105704:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  105708:	8b 45 10             	mov    0x10(%ebp),%eax
  10570b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10570e:	89 55 10             	mov    %edx,0x10(%ebp)
  105711:	85 c0                	test   %eax,%eax
  105713:	75 c3                	jne    1056d8 <memcmp+0x14>
    }
    return 0;
  105715:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10571a:	c9                   	leave  
  10571b:	c3                   	ret    

0010571c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10571c:	55                   	push   %ebp
  10571d:	89 e5                	mov    %esp,%ebp
  10571f:	83 ec 58             	sub    $0x58,%esp
  105722:	8b 45 10             	mov    0x10(%ebp),%eax
  105725:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105728:	8b 45 14             	mov    0x14(%ebp),%eax
  10572b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10572e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105731:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105734:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105737:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10573a:	8b 45 18             	mov    0x18(%ebp),%eax
  10573d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105740:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105743:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105746:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105749:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10574c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10574f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105752:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105756:	74 1c                	je     105774 <printnum+0x58>
  105758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10575b:	ba 00 00 00 00       	mov    $0x0,%edx
  105760:	f7 75 e4             	divl   -0x1c(%ebp)
  105763:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105769:	ba 00 00 00 00       	mov    $0x0,%edx
  10576e:	f7 75 e4             	divl   -0x1c(%ebp)
  105771:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105774:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105777:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10577a:	f7 75 e4             	divl   -0x1c(%ebp)
  10577d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105780:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105783:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105786:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105789:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10578c:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10578f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105792:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105795:	8b 45 18             	mov    0x18(%ebp),%eax
  105798:	ba 00 00 00 00       	mov    $0x0,%edx
  10579d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1057a0:	77 56                	ja     1057f8 <printnum+0xdc>
  1057a2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1057a5:	72 05                	jb     1057ac <printnum+0x90>
  1057a7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1057aa:	77 4c                	ja     1057f8 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1057ac:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1057af:	8d 50 ff             	lea    -0x1(%eax),%edx
  1057b2:	8b 45 20             	mov    0x20(%ebp),%eax
  1057b5:	89 44 24 18          	mov    %eax,0x18(%esp)
  1057b9:	89 54 24 14          	mov    %edx,0x14(%esp)
  1057bd:	8b 45 18             	mov    0x18(%ebp),%eax
  1057c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1057c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1057ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  1057ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1057d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1057dc:	89 04 24             	mov    %eax,(%esp)
  1057df:	e8 38 ff ff ff       	call   10571c <printnum>
  1057e4:	eb 1c                	jmp    105802 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1057e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057ed:	8b 45 20             	mov    0x20(%ebp),%eax
  1057f0:	89 04 24             	mov    %eax,(%esp)
  1057f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057f6:	ff d0                	call   *%eax
        while (-- width > 0)
  1057f8:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1057fc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105800:	7f e4                	jg     1057e6 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105802:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105805:	05 14 6f 10 00       	add    $0x106f14,%eax
  10580a:	0f b6 00             	movzbl (%eax),%eax
  10580d:	0f be c0             	movsbl %al,%eax
  105810:	8b 55 0c             	mov    0xc(%ebp),%edx
  105813:	89 54 24 04          	mov    %edx,0x4(%esp)
  105817:	89 04 24             	mov    %eax,(%esp)
  10581a:	8b 45 08             	mov    0x8(%ebp),%eax
  10581d:	ff d0                	call   *%eax
}
  10581f:	c9                   	leave  
  105820:	c3                   	ret    

00105821 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105821:	55                   	push   %ebp
  105822:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105824:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105828:	7e 14                	jle    10583e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10582a:	8b 45 08             	mov    0x8(%ebp),%eax
  10582d:	8b 00                	mov    (%eax),%eax
  10582f:	8d 48 08             	lea    0x8(%eax),%ecx
  105832:	8b 55 08             	mov    0x8(%ebp),%edx
  105835:	89 0a                	mov    %ecx,(%edx)
  105837:	8b 50 04             	mov    0x4(%eax),%edx
  10583a:	8b 00                	mov    (%eax),%eax
  10583c:	eb 30                	jmp    10586e <getuint+0x4d>
    }
    else if (lflag) {
  10583e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105842:	74 16                	je     10585a <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105844:	8b 45 08             	mov    0x8(%ebp),%eax
  105847:	8b 00                	mov    (%eax),%eax
  105849:	8d 48 04             	lea    0x4(%eax),%ecx
  10584c:	8b 55 08             	mov    0x8(%ebp),%edx
  10584f:	89 0a                	mov    %ecx,(%edx)
  105851:	8b 00                	mov    (%eax),%eax
  105853:	ba 00 00 00 00       	mov    $0x0,%edx
  105858:	eb 14                	jmp    10586e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10585a:	8b 45 08             	mov    0x8(%ebp),%eax
  10585d:	8b 00                	mov    (%eax),%eax
  10585f:	8d 48 04             	lea    0x4(%eax),%ecx
  105862:	8b 55 08             	mov    0x8(%ebp),%edx
  105865:	89 0a                	mov    %ecx,(%edx)
  105867:	8b 00                	mov    (%eax),%eax
  105869:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10586e:	5d                   	pop    %ebp
  10586f:	c3                   	ret    

00105870 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105870:	55                   	push   %ebp
  105871:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105873:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105877:	7e 14                	jle    10588d <getint+0x1d>
        return va_arg(*ap, long long);
  105879:	8b 45 08             	mov    0x8(%ebp),%eax
  10587c:	8b 00                	mov    (%eax),%eax
  10587e:	8d 48 08             	lea    0x8(%eax),%ecx
  105881:	8b 55 08             	mov    0x8(%ebp),%edx
  105884:	89 0a                	mov    %ecx,(%edx)
  105886:	8b 50 04             	mov    0x4(%eax),%edx
  105889:	8b 00                	mov    (%eax),%eax
  10588b:	eb 28                	jmp    1058b5 <getint+0x45>
    }
    else if (lflag) {
  10588d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105891:	74 12                	je     1058a5 <getint+0x35>
        return va_arg(*ap, long);
  105893:	8b 45 08             	mov    0x8(%ebp),%eax
  105896:	8b 00                	mov    (%eax),%eax
  105898:	8d 48 04             	lea    0x4(%eax),%ecx
  10589b:	8b 55 08             	mov    0x8(%ebp),%edx
  10589e:	89 0a                	mov    %ecx,(%edx)
  1058a0:	8b 00                	mov    (%eax),%eax
  1058a2:	99                   	cltd   
  1058a3:	eb 10                	jmp    1058b5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1058a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a8:	8b 00                	mov    (%eax),%eax
  1058aa:	8d 48 04             	lea    0x4(%eax),%ecx
  1058ad:	8b 55 08             	mov    0x8(%ebp),%edx
  1058b0:	89 0a                	mov    %ecx,(%edx)
  1058b2:	8b 00                	mov    (%eax),%eax
  1058b4:	99                   	cltd   
    }
}
  1058b5:	5d                   	pop    %ebp
  1058b6:	c3                   	ret    

001058b7 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1058b7:	55                   	push   %ebp
  1058b8:	89 e5                	mov    %esp,%ebp
  1058ba:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1058bd:	8d 45 14             	lea    0x14(%ebp),%eax
  1058c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1058ca:	8b 45 10             	mov    0x10(%ebp),%eax
  1058cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1058d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1058db:	89 04 24             	mov    %eax,(%esp)
  1058de:	e8 02 00 00 00       	call   1058e5 <vprintfmt>
    va_end(ap);
}
  1058e3:	c9                   	leave  
  1058e4:	c3                   	ret    

001058e5 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1058e5:	55                   	push   %ebp
  1058e6:	89 e5                	mov    %esp,%ebp
  1058e8:	56                   	push   %esi
  1058e9:	53                   	push   %ebx
  1058ea:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1058ed:	eb 18                	jmp    105907 <vprintfmt+0x22>
            if (ch == '\0') {
  1058ef:	85 db                	test   %ebx,%ebx
  1058f1:	75 05                	jne    1058f8 <vprintfmt+0x13>
                return;
  1058f3:	e9 d1 03 00 00       	jmp    105cc9 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  1058f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058ff:	89 1c 24             	mov    %ebx,(%esp)
  105902:	8b 45 08             	mov    0x8(%ebp),%eax
  105905:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105907:	8b 45 10             	mov    0x10(%ebp),%eax
  10590a:	8d 50 01             	lea    0x1(%eax),%edx
  10590d:	89 55 10             	mov    %edx,0x10(%ebp)
  105910:	0f b6 00             	movzbl (%eax),%eax
  105913:	0f b6 d8             	movzbl %al,%ebx
  105916:	83 fb 25             	cmp    $0x25,%ebx
  105919:	75 d4                	jne    1058ef <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10591b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10591f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105929:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10592c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105933:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105936:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105939:	8b 45 10             	mov    0x10(%ebp),%eax
  10593c:	8d 50 01             	lea    0x1(%eax),%edx
  10593f:	89 55 10             	mov    %edx,0x10(%ebp)
  105942:	0f b6 00             	movzbl (%eax),%eax
  105945:	0f b6 d8             	movzbl %al,%ebx
  105948:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10594b:	83 f8 55             	cmp    $0x55,%eax
  10594e:	0f 87 44 03 00 00    	ja     105c98 <vprintfmt+0x3b3>
  105954:	8b 04 85 38 6f 10 00 	mov    0x106f38(,%eax,4),%eax
  10595b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10595d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105961:	eb d6                	jmp    105939 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105963:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105967:	eb d0                	jmp    105939 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105969:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105970:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105973:	89 d0                	mov    %edx,%eax
  105975:	c1 e0 02             	shl    $0x2,%eax
  105978:	01 d0                	add    %edx,%eax
  10597a:	01 c0                	add    %eax,%eax
  10597c:	01 d8                	add    %ebx,%eax
  10597e:	83 e8 30             	sub    $0x30,%eax
  105981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105984:	8b 45 10             	mov    0x10(%ebp),%eax
  105987:	0f b6 00             	movzbl (%eax),%eax
  10598a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10598d:	83 fb 2f             	cmp    $0x2f,%ebx
  105990:	7e 0b                	jle    10599d <vprintfmt+0xb8>
  105992:	83 fb 39             	cmp    $0x39,%ebx
  105995:	7f 06                	jg     10599d <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
  105997:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
  10599b:	eb d3                	jmp    105970 <vprintfmt+0x8b>
            goto process_precision;
  10599d:	eb 33                	jmp    1059d2 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  10599f:	8b 45 14             	mov    0x14(%ebp),%eax
  1059a2:	8d 50 04             	lea    0x4(%eax),%edx
  1059a5:	89 55 14             	mov    %edx,0x14(%ebp)
  1059a8:	8b 00                	mov    (%eax),%eax
  1059aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1059ad:	eb 23                	jmp    1059d2 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1059af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1059b3:	79 0c                	jns    1059c1 <vprintfmt+0xdc>
                width = 0;
  1059b5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1059bc:	e9 78 ff ff ff       	jmp    105939 <vprintfmt+0x54>
  1059c1:	e9 73 ff ff ff       	jmp    105939 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1059c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1059cd:	e9 67 ff ff ff       	jmp    105939 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1059d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1059d6:	79 12                	jns    1059ea <vprintfmt+0x105>
                width = precision, precision = -1;
  1059d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1059db:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1059de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1059e5:	e9 4f ff ff ff       	jmp    105939 <vprintfmt+0x54>
  1059ea:	e9 4a ff ff ff       	jmp    105939 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1059ef:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1059f3:	e9 41 ff ff ff       	jmp    105939 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1059f8:	8b 45 14             	mov    0x14(%ebp),%eax
  1059fb:	8d 50 04             	lea    0x4(%eax),%edx
  1059fe:	89 55 14             	mov    %edx,0x14(%ebp)
  105a01:	8b 00                	mov    (%eax),%eax
  105a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a06:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a0a:	89 04 24             	mov    %eax,(%esp)
  105a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105a10:	ff d0                	call   *%eax
            break;
  105a12:	e9 ac 02 00 00       	jmp    105cc3 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105a17:	8b 45 14             	mov    0x14(%ebp),%eax
  105a1a:	8d 50 04             	lea    0x4(%eax),%edx
  105a1d:	89 55 14             	mov    %edx,0x14(%ebp)
  105a20:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105a22:	85 db                	test   %ebx,%ebx
  105a24:	79 02                	jns    105a28 <vprintfmt+0x143>
                err = -err;
  105a26:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105a28:	83 fb 06             	cmp    $0x6,%ebx
  105a2b:	7f 0b                	jg     105a38 <vprintfmt+0x153>
  105a2d:	8b 34 9d f8 6e 10 00 	mov    0x106ef8(,%ebx,4),%esi
  105a34:	85 f6                	test   %esi,%esi
  105a36:	75 23                	jne    105a5b <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105a38:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105a3c:	c7 44 24 08 25 6f 10 	movl   $0x106f25,0x8(%esp)
  105a43:	00 
  105a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a4e:	89 04 24             	mov    %eax,(%esp)
  105a51:	e8 61 fe ff ff       	call   1058b7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105a56:	e9 68 02 00 00       	jmp    105cc3 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
  105a5b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105a5f:	c7 44 24 08 2e 6f 10 	movl   $0x106f2e,0x8(%esp)
  105a66:	00 
  105a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  105a71:	89 04 24             	mov    %eax,(%esp)
  105a74:	e8 3e fe ff ff       	call   1058b7 <printfmt>
            break;
  105a79:	e9 45 02 00 00       	jmp    105cc3 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  105a81:	8d 50 04             	lea    0x4(%eax),%edx
  105a84:	89 55 14             	mov    %edx,0x14(%ebp)
  105a87:	8b 30                	mov    (%eax),%esi
  105a89:	85 f6                	test   %esi,%esi
  105a8b:	75 05                	jne    105a92 <vprintfmt+0x1ad>
                p = "(null)";
  105a8d:	be 31 6f 10 00       	mov    $0x106f31,%esi
            }
            if (width > 0 && padc != '-') {
  105a92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a96:	7e 3e                	jle    105ad6 <vprintfmt+0x1f1>
  105a98:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105a9c:	74 38                	je     105ad6 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105a9e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aa8:	89 34 24             	mov    %esi,(%esp)
  105aab:	e8 dc f7 ff ff       	call   10528c <strnlen>
  105ab0:	29 c3                	sub    %eax,%ebx
  105ab2:	89 d8                	mov    %ebx,%eax
  105ab4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105ab7:	eb 17                	jmp    105ad0 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105ab9:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105abd:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ac0:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ac4:	89 04 24             	mov    %eax,(%esp)
  105ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  105aca:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105acc:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105ad0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ad4:	7f e3                	jg     105ab9 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105ad6:	eb 38                	jmp    105b10 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105ad8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105adc:	74 1f                	je     105afd <vprintfmt+0x218>
  105ade:	83 fb 1f             	cmp    $0x1f,%ebx
  105ae1:	7e 05                	jle    105ae8 <vprintfmt+0x203>
  105ae3:	83 fb 7e             	cmp    $0x7e,%ebx
  105ae6:	7e 15                	jle    105afd <vprintfmt+0x218>
                    putch('?', putdat);
  105ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  105aef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105af6:	8b 45 08             	mov    0x8(%ebp),%eax
  105af9:	ff d0                	call   *%eax
  105afb:	eb 0f                	jmp    105b0c <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b04:	89 1c 24             	mov    %ebx,(%esp)
  105b07:	8b 45 08             	mov    0x8(%ebp),%eax
  105b0a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105b0c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105b10:	89 f0                	mov    %esi,%eax
  105b12:	8d 70 01             	lea    0x1(%eax),%esi
  105b15:	0f b6 00             	movzbl (%eax),%eax
  105b18:	0f be d8             	movsbl %al,%ebx
  105b1b:	85 db                	test   %ebx,%ebx
  105b1d:	74 10                	je     105b2f <vprintfmt+0x24a>
  105b1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105b23:	78 b3                	js     105ad8 <vprintfmt+0x1f3>
  105b25:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  105b29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105b2d:	79 a9                	jns    105ad8 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
  105b2f:	eb 17                	jmp    105b48 <vprintfmt+0x263>
                putch(' ', putdat);
  105b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b38:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b42:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105b44:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105b48:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b4c:	7f e3                	jg     105b31 <vprintfmt+0x24c>
            }
            break;
  105b4e:	e9 70 01 00 00       	jmp    105cc3 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  105b5d:	89 04 24             	mov    %eax,(%esp)
  105b60:	e8 0b fd ff ff       	call   105870 <getint>
  105b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b68:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b71:	85 d2                	test   %edx,%edx
  105b73:	79 26                	jns    105b9b <vprintfmt+0x2b6>
                putch('-', putdat);
  105b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b7c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105b83:	8b 45 08             	mov    0x8(%ebp),%eax
  105b86:	ff d0                	call   *%eax
                num = -(long long)num;
  105b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b8e:	f7 d8                	neg    %eax
  105b90:	83 d2 00             	adc    $0x0,%edx
  105b93:	f7 da                	neg    %edx
  105b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b98:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105b9b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105ba2:	e9 a8 00 00 00       	jmp    105c4f <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105ba7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bae:	8d 45 14             	lea    0x14(%ebp),%eax
  105bb1:	89 04 24             	mov    %eax,(%esp)
  105bb4:	e8 68 fc ff ff       	call   105821 <getuint>
  105bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bbc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105bbf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105bc6:	e9 84 00 00 00       	jmp    105c4f <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105bcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bd2:	8d 45 14             	lea    0x14(%ebp),%eax
  105bd5:	89 04 24             	mov    %eax,(%esp)
  105bd8:	e8 44 fc ff ff       	call   105821 <getuint>
  105bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105be0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105be3:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105bea:	eb 63                	jmp    105c4f <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bf3:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfd:	ff d0                	call   *%eax
            putch('x', putdat);
  105bff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c06:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c10:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105c12:	8b 45 14             	mov    0x14(%ebp),%eax
  105c15:	8d 50 04             	lea    0x4(%eax),%edx
  105c18:	89 55 14             	mov    %edx,0x14(%ebp)
  105c1b:	8b 00                	mov    (%eax),%eax
  105c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105c27:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105c2e:	eb 1f                	jmp    105c4f <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c37:	8d 45 14             	lea    0x14(%ebp),%eax
  105c3a:	89 04 24             	mov    %eax,(%esp)
  105c3d:	e8 df fb ff ff       	call   105821 <getuint>
  105c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c45:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105c48:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105c4f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105c56:	89 54 24 18          	mov    %edx,0x18(%esp)
  105c5a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105c5d:	89 54 24 14          	mov    %edx,0x14(%esp)
  105c61:	89 44 24 10          	mov    %eax,0x10(%esp)
  105c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7d:	89 04 24             	mov    %eax,(%esp)
  105c80:	e8 97 fa ff ff       	call   10571c <printnum>
            break;
  105c85:	eb 3c                	jmp    105cc3 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c8e:	89 1c 24             	mov    %ebx,(%esp)
  105c91:	8b 45 08             	mov    0x8(%ebp),%eax
  105c94:	ff d0                	call   *%eax
            break;
  105c96:	eb 2b                	jmp    105cc3 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c9f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ca9:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105cab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105caf:	eb 04                	jmp    105cb5 <vprintfmt+0x3d0>
  105cb1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  105cb8:	83 e8 01             	sub    $0x1,%eax
  105cbb:	0f b6 00             	movzbl (%eax),%eax
  105cbe:	3c 25                	cmp    $0x25,%al
  105cc0:	75 ef                	jne    105cb1 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105cc2:	90                   	nop
        }
    }
  105cc3:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105cc4:	e9 3e fc ff ff       	jmp    105907 <vprintfmt+0x22>
}
  105cc9:	83 c4 40             	add    $0x40,%esp
  105ccc:	5b                   	pop    %ebx
  105ccd:	5e                   	pop    %esi
  105cce:	5d                   	pop    %ebp
  105ccf:	c3                   	ret    

00105cd0 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105cd0:	55                   	push   %ebp
  105cd1:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd6:	8b 40 08             	mov    0x8(%eax),%eax
  105cd9:	8d 50 01             	lea    0x1(%eax),%edx
  105cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cdf:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ce5:	8b 10                	mov    (%eax),%edx
  105ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cea:	8b 40 04             	mov    0x4(%eax),%eax
  105ced:	39 c2                	cmp    %eax,%edx
  105cef:	73 12                	jae    105d03 <sprintputch+0x33>
        *b->buf ++ = ch;
  105cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf4:	8b 00                	mov    (%eax),%eax
  105cf6:	8d 48 01             	lea    0x1(%eax),%ecx
  105cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  105cfc:	89 0a                	mov    %ecx,(%edx)
  105cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  105d01:	88 10                	mov    %dl,(%eax)
    }
}
  105d03:	5d                   	pop    %ebp
  105d04:	c3                   	ret    

00105d05 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105d05:	55                   	push   %ebp
  105d06:	89 e5                	mov    %esp,%ebp
  105d08:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105d0b:	8d 45 14             	lea    0x14(%ebp),%eax
  105d0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d18:	8b 45 10             	mov    0x10(%ebp),%eax
  105d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d22:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d26:	8b 45 08             	mov    0x8(%ebp),%eax
  105d29:	89 04 24             	mov    %eax,(%esp)
  105d2c:	e8 08 00 00 00       	call   105d39 <vsnprintf>
  105d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105d37:	c9                   	leave  
  105d38:	c3                   	ret    

00105d39 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105d39:	55                   	push   %ebp
  105d3a:	89 e5                	mov    %esp,%ebp
  105d3c:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  105d42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d48:	8d 50 ff             	lea    -0x1(%eax),%edx
  105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4e:	01 d0                	add    %edx,%eax
  105d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105d5a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105d5e:	74 0a                	je     105d6a <vsnprintf+0x31>
  105d60:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d66:	39 c2                	cmp    %eax,%edx
  105d68:	76 07                	jbe    105d71 <vsnprintf+0x38>
        return -E_INVAL;
  105d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105d6f:	eb 2a                	jmp    105d9b <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105d71:	8b 45 14             	mov    0x14(%ebp),%eax
  105d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d78:	8b 45 10             	mov    0x10(%ebp),%eax
  105d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d86:	c7 04 24 d0 5c 10 00 	movl   $0x105cd0,(%esp)
  105d8d:	e8 53 fb ff ff       	call   1058e5 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d95:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105d9b:	c9                   	leave  
  105d9c:	c3                   	ret    

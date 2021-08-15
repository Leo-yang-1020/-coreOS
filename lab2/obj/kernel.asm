
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 70 11 00 	lgdtl  0x117018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba 68 89 11 c0       	mov    $0xc0118968,%edx
c0100035:	b8 36 7a 11 c0       	mov    $0xc0117a36,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 36 7a 11 c0 	movl   $0xc0117a36,(%esp)
c0100051:	e8 3d 55 00 00       	call   c0105593 <memset>

    cons_init();                // init the console
c0100056:	e8 7d 15 00 00       	call   c01015d8 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 a0 5d 10 c0 	movl   $0xc0105da0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 bc 5d 10 c0 	movl   $0xc0105dbc,(%esp)
c0100070:	e8 11 02 00 00       	call   c0100286 <cprintf>

    print_kerninfo();
c0100075:	e8 b2 08 00 00       	call   c010092c <print_kerninfo>

    grade_backtrace();
c010007a:	e8 86 00 00 00       	call   c0100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 3f 31 00 00       	call   c01031c3 <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 ac 16 00 00       	call   c0101735 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 0a 18 00 00       	call   c0101898 <idt_init>

    clock_init();               // init clock interrupt
c010008e:	e8 fb 0c 00 00       	call   c0100d8e <clock_init>
    intr_enable();              // enable irq interrupt
c0100093:	e8 d8 17 00 00       	call   c0101870 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c0100098:	eb fe                	jmp    c0100098 <kern_init+0x6e>

c010009a <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c010009a:	55                   	push   %ebp
c010009b:	89 e5                	mov    %esp,%ebp
c010009d:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000a7:	00 
c01000a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000af:	00 
c01000b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000b7:	e8 c0 0c 00 00       	call   c0100d7c <mon_backtrace>
}
c01000bc:	c9                   	leave  
c01000bd:	c3                   	ret    

c01000be <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000be:	55                   	push   %ebp
c01000bf:	89 e5                	mov    %esp,%ebp
c01000c1:	53                   	push   %ebx
c01000c2:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000c5:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000cb:	8d 55 08             	lea    0x8(%ebp),%edx
c01000ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01000d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000dd:	89 04 24             	mov    %eax,(%esp)
c01000e0:	e8 b5 ff ff ff       	call   c010009a <grade_backtrace2>
}
c01000e5:	83 c4 14             	add    $0x14,%esp
c01000e8:	5b                   	pop    %ebx
c01000e9:	5d                   	pop    %ebp
c01000ea:	c3                   	ret    

c01000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000eb:	55                   	push   %ebp
c01000ec:	89 e5                	mov    %esp,%ebp
c01000ee:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01000f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fb:	89 04 24             	mov    %eax,(%esp)
c01000fe:	e8 bb ff ff ff       	call   c01000be <grade_backtrace1>
}
c0100103:	c9                   	leave  
c0100104:	c3                   	ret    

c0100105 <grade_backtrace>:

void
grade_backtrace(void) {
c0100105:	55                   	push   %ebp
c0100106:	89 e5                	mov    %esp,%ebp
c0100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010b:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100110:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100117:	ff 
c0100118:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100123:	e8 c3 ff ff ff       	call   c01000eb <grade_backtrace0>
}
c0100128:	c9                   	leave  
c0100129:	c3                   	ret    

c010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012a:	55                   	push   %ebp
c010012b:	89 e5                	mov    %esp,%ebp
c010012d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100140:	0f b7 c0             	movzwl %ax,%eax
c0100143:	83 e0 03             	and    $0x3,%eax
c0100146:	89 c2                	mov    %eax,%edx
c0100148:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010014d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100151:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100155:	c7 04 24 c1 5d 10 c0 	movl   $0xc0105dc1,(%esp)
c010015c:	e8 25 01 00 00       	call   c0100286 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100165:	0f b7 d0             	movzwl %ax,%edx
c0100168:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010016d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100171:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100175:	c7 04 24 cf 5d 10 c0 	movl   $0xc0105dcf,(%esp)
c010017c:	e8 05 01 00 00       	call   c0100286 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100185:	0f b7 d0             	movzwl %ax,%edx
c0100188:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 dd 5d 10 c0 	movl   $0xc0105ddd,(%esp)
c010019c:	e8 e5 00 00 00       	call   c0100286 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a5:	0f b7 d0             	movzwl %ax,%edx
c01001a8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b5:	c7 04 24 eb 5d 10 c0 	movl   $0xc0105deb,(%esp)
c01001bc:	e8 c5 00 00 00       	call   c0100286 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c5:	0f b7 d0             	movzwl %ax,%edx
c01001c8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d5:	c7 04 24 f9 5d 10 c0 	movl   $0xc0105df9,(%esp)
c01001dc:	e8 a5 00 00 00       	call   c0100286 <cprintf>
    round ++;
c01001e1:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001e6:	83 c0 01             	add    $0x1,%eax
c01001e9:	a3 40 7a 11 c0       	mov    %eax,0xc0117a40
}
c01001ee:	c9                   	leave  
c01001ef:	c3                   	ret    

c01001f0 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f0:	55                   	push   %ebp
c01001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001f3:	5d                   	pop    %ebp
c01001f4:	c3                   	ret    

c01001f5 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001f5:	55                   	push   %ebp
c01001f6:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f8:	5d                   	pop    %ebp
c01001f9:	c3                   	ret    

c01001fa <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001fa:	55                   	push   %ebp
c01001fb:	89 e5                	mov    %esp,%ebp
c01001fd:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100200:	e8 25 ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100205:	c7 04 24 08 5e 10 c0 	movl   $0xc0105e08,(%esp)
c010020c:	e8 75 00 00 00       	call   c0100286 <cprintf>
    lab1_switch_to_user();
c0100211:	e8 da ff ff ff       	call   c01001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100216:	e8 0f ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010021b:	c7 04 24 28 5e 10 c0 	movl   $0xc0105e28,(%esp)
c0100222:	e8 5f 00 00 00       	call   c0100286 <cprintf>
    lab1_switch_to_kernel();
c0100227:	e8 c9 ff ff ff       	call   c01001f5 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010022c:	e8 f9 fe ff ff       	call   c010012a <lab1_print_cur_status>
}
c0100231:	c9                   	leave  
c0100232:	c3                   	ret    

c0100233 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100233:	55                   	push   %ebp
c0100234:	89 e5                	mov    %esp,%ebp
c0100236:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100239:	8b 45 08             	mov    0x8(%ebp),%eax
c010023c:	89 04 24             	mov    %eax,(%esp)
c010023f:	e8 c0 13 00 00       	call   c0101604 <cons_putc>
    (*cnt) ++;
c0100244:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100247:	8b 00                	mov    (%eax),%eax
c0100249:	8d 50 01             	lea    0x1(%eax),%edx
c010024c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010024f:	89 10                	mov    %edx,(%eax)
}
c0100251:	c9                   	leave  
c0100252:	c3                   	ret    

c0100253 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100253:	55                   	push   %ebp
c0100254:	89 e5                	mov    %esp,%ebp
c0100256:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100259:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100260:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100263:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100267:	8b 45 08             	mov    0x8(%ebp),%eax
c010026a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100271:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100275:	c7 04 24 33 02 10 c0 	movl   $0xc0100233,(%esp)
c010027c:	e8 64 56 00 00       	call   c01058e5 <vprintfmt>
    return cnt;
c0100281:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100284:	c9                   	leave  
c0100285:	c3                   	ret    

c0100286 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100286:	55                   	push   %ebp
c0100287:	89 e5                	mov    %esp,%ebp
c0100289:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010028c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010028f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100292:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100295:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100299:	8b 45 08             	mov    0x8(%ebp),%eax
c010029c:	89 04 24             	mov    %eax,(%esp)
c010029f:	e8 af ff ff ff       	call   c0100253 <vcprintf>
c01002a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002aa:	c9                   	leave  
c01002ab:	c3                   	ret    

c01002ac <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002ac:	55                   	push   %ebp
c01002ad:	89 e5                	mov    %esp,%ebp
c01002af:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b5:	89 04 24             	mov    %eax,(%esp)
c01002b8:	e8 47 13 00 00       	call   c0101604 <cons_putc>
}
c01002bd:	c9                   	leave  
c01002be:	c3                   	ret    

c01002bf <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002bf:	55                   	push   %ebp
c01002c0:	89 e5                	mov    %esp,%ebp
c01002c2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002cc:	eb 13                	jmp    c01002e1 <cputs+0x22>
        cputch(c, &cnt);
c01002ce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002d2:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002d9:	89 04 24             	mov    %eax,(%esp)
c01002dc:	e8 52 ff ff ff       	call   c0100233 <cputch>
    while ((c = *str ++) != '\0') {
c01002e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e4:	8d 50 01             	lea    0x1(%eax),%edx
c01002e7:	89 55 08             	mov    %edx,0x8(%ebp)
c01002ea:	0f b6 00             	movzbl (%eax),%eax
c01002ed:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002f0:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002f4:	75 d8                	jne    c01002ce <cputs+0xf>
    }
    cputch('\n', &cnt);
c01002f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002fd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100304:	e8 2a ff ff ff       	call   c0100233 <cputch>
    return cnt;
c0100309:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010030c:	c9                   	leave  
c010030d:	c3                   	ret    

c010030e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010030e:	55                   	push   %ebp
c010030f:	89 e5                	mov    %esp,%ebp
c0100311:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100314:	e8 27 13 00 00       	call   c0101640 <cons_getc>
c0100319:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010031c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100320:	74 f2                	je     c0100314 <getchar+0x6>
        /* do nothing */;
    return c;
c0100322:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100325:	c9                   	leave  
c0100326:	c3                   	ret    

c0100327 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100327:	55                   	push   %ebp
c0100328:	89 e5                	mov    %esp,%ebp
c010032a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010032d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100331:	74 13                	je     c0100346 <readline+0x1f>
        cprintf("%s", prompt);
c0100333:	8b 45 08             	mov    0x8(%ebp),%eax
c0100336:	89 44 24 04          	mov    %eax,0x4(%esp)
c010033a:	c7 04 24 47 5e 10 c0 	movl   $0xc0105e47,(%esp)
c0100341:	e8 40 ff ff ff       	call   c0100286 <cprintf>
    }
    int i = 0, c;
c0100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010034d:	e8 bc ff ff ff       	call   c010030e <getchar>
c0100352:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100355:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100359:	79 07                	jns    c0100362 <readline+0x3b>
            return NULL;
c010035b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100360:	eb 79                	jmp    c01003db <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100362:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100366:	7e 28                	jle    c0100390 <readline+0x69>
c0100368:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010036f:	7f 1f                	jg     c0100390 <readline+0x69>
            cputchar(c);
c0100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100374:	89 04 24             	mov    %eax,(%esp)
c0100377:	e8 30 ff ff ff       	call   c01002ac <cputchar>
            buf[i ++] = c;
c010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010037f:	8d 50 01             	lea    0x1(%eax),%edx
c0100382:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100385:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100388:	88 90 60 7a 11 c0    	mov    %dl,-0x3fee85a0(%eax)
c010038e:	eb 46                	jmp    c01003d6 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c0100390:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0100394:	75 17                	jne    c01003ad <readline+0x86>
c0100396:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010039a:	7e 11                	jle    c01003ad <readline+0x86>
            cputchar(c);
c010039c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010039f:	89 04 24             	mov    %eax,(%esp)
c01003a2:	e8 05 ff ff ff       	call   c01002ac <cputchar>
            i --;
c01003a7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01003ab:	eb 29                	jmp    c01003d6 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01003ad:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003b1:	74 06                	je     c01003b9 <readline+0x92>
c01003b3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003b7:	75 1d                	jne    c01003d6 <readline+0xaf>
            cputchar(c);
c01003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bc:	89 04 24             	mov    %eax,(%esp)
c01003bf:	e8 e8 fe ff ff       	call   c01002ac <cputchar>
            buf[i] = '\0';
c01003c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003c7:	05 60 7a 11 c0       	add    $0xc0117a60,%eax
c01003cc:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003cf:	b8 60 7a 11 c0       	mov    $0xc0117a60,%eax
c01003d4:	eb 05                	jmp    c01003db <readline+0xb4>
        }
    }
c01003d6:	e9 72 ff ff ff       	jmp    c010034d <readline+0x26>
}
c01003db:	c9                   	leave  
c01003dc:	c3                   	ret    

c01003dd <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003dd:	55                   	push   %ebp
c01003de:	89 e5                	mov    %esp,%ebp
c01003e0:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003e3:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
c01003e8:	85 c0                	test   %eax,%eax
c01003ea:	74 02                	je     c01003ee <__panic+0x11>
        goto panic_dead;
c01003ec:	eb 48                	jmp    c0100436 <__panic+0x59>
    }
    is_panic = 1;
c01003ee:	c7 05 60 7e 11 c0 01 	movl   $0x1,0xc0117e60
c01003f5:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c01003f8:	8d 45 14             	lea    0x14(%ebp),%eax
c01003fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c01003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100401:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100405:	8b 45 08             	mov    0x8(%ebp),%eax
c0100408:	89 44 24 04          	mov    %eax,0x4(%esp)
c010040c:	c7 04 24 4a 5e 10 c0 	movl   $0xc0105e4a,(%esp)
c0100413:	e8 6e fe ff ff       	call   c0100286 <cprintf>
    vcprintf(fmt, ap);
c0100418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010041b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010041f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100422:	89 04 24             	mov    %eax,(%esp)
c0100425:	e8 29 fe ff ff       	call   c0100253 <vcprintf>
    cprintf("\n");
c010042a:	c7 04 24 66 5e 10 c0 	movl   $0xc0105e66,(%esp)
c0100431:	e8 50 fe ff ff       	call   c0100286 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100436:	e8 3b 14 00 00       	call   c0101876 <intr_disable>
    while (1) {
        kmonitor(NULL);
c010043b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100442:	e8 66 08 00 00       	call   c0100cad <kmonitor>
    }
c0100447:	eb f2                	jmp    c010043b <__panic+0x5e>

c0100449 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100449:	55                   	push   %ebp
c010044a:	89 e5                	mov    %esp,%ebp
c010044c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010044f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100452:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100455:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100458:	89 44 24 08          	mov    %eax,0x8(%esp)
c010045c:	8b 45 08             	mov    0x8(%ebp),%eax
c010045f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100463:	c7 04 24 68 5e 10 c0 	movl   $0xc0105e68,(%esp)
c010046a:	e8 17 fe ff ff       	call   c0100286 <cprintf>
    vcprintf(fmt, ap);
c010046f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100476:	8b 45 10             	mov    0x10(%ebp),%eax
c0100479:	89 04 24             	mov    %eax,(%esp)
c010047c:	e8 d2 fd ff ff       	call   c0100253 <vcprintf>
    cprintf("\n");
c0100481:	c7 04 24 66 5e 10 c0 	movl   $0xc0105e66,(%esp)
c0100488:	e8 f9 fd ff ff       	call   c0100286 <cprintf>
    va_end(ap);
}
c010048d:	c9                   	leave  
c010048e:	c3                   	ret    

c010048f <is_kernel_panic>:

bool
is_kernel_panic(void) {
c010048f:	55                   	push   %ebp
c0100490:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100492:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
}
c0100497:	5d                   	pop    %ebp
c0100498:	c3                   	ret    

c0100499 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100499:	55                   	push   %ebp
c010049a:	89 e5                	mov    %esp,%ebp
c010049c:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010049f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004a2:	8b 00                	mov    (%eax),%eax
c01004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004aa:	8b 00                	mov    (%eax),%eax
c01004ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004b6:	e9 d2 00 00 00       	jmp    c010058d <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01004bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004be:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004c1:	01 d0                	add    %edx,%eax
c01004c3:	89 c2                	mov    %eax,%edx
c01004c5:	c1 ea 1f             	shr    $0x1f,%edx
c01004c8:	01 d0                	add    %edx,%eax
c01004ca:	d1 f8                	sar    %eax
c01004cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004d2:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004d5:	eb 04                	jmp    c01004db <stab_binsearch+0x42>
            m --;
c01004d7:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c01004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004e1:	7c 1f                	jl     c0100502 <stab_binsearch+0x69>
c01004e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e6:	89 d0                	mov    %edx,%eax
c01004e8:	01 c0                	add    %eax,%eax
c01004ea:	01 d0                	add    %edx,%eax
c01004ec:	c1 e0 02             	shl    $0x2,%eax
c01004ef:	89 c2                	mov    %eax,%edx
c01004f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01004f4:	01 d0                	add    %edx,%eax
c01004f6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01004fa:	0f b6 c0             	movzbl %al,%eax
c01004fd:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100500:	75 d5                	jne    c01004d7 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100502:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100505:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100508:	7d 0b                	jge    c0100515 <stab_binsearch+0x7c>
            l = true_m + 1;
c010050a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010050d:	83 c0 01             	add    $0x1,%eax
c0100510:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100513:	eb 78                	jmp    c010058d <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100515:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010051c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051f:	89 d0                	mov    %edx,%eax
c0100521:	01 c0                	add    %eax,%eax
c0100523:	01 d0                	add    %edx,%eax
c0100525:	c1 e0 02             	shl    $0x2,%eax
c0100528:	89 c2                	mov    %eax,%edx
c010052a:	8b 45 08             	mov    0x8(%ebp),%eax
c010052d:	01 d0                	add    %edx,%eax
c010052f:	8b 40 08             	mov    0x8(%eax),%eax
c0100532:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100535:	73 13                	jae    c010054a <stab_binsearch+0xb1>
            *region_left = m;
c0100537:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010053f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100542:	83 c0 01             	add    $0x1,%eax
c0100545:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100548:	eb 43                	jmp    c010058d <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010054a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054d:	89 d0                	mov    %edx,%eax
c010054f:	01 c0                	add    %eax,%eax
c0100551:	01 d0                	add    %edx,%eax
c0100553:	c1 e0 02             	shl    $0x2,%eax
c0100556:	89 c2                	mov    %eax,%edx
c0100558:	8b 45 08             	mov    0x8(%ebp),%eax
c010055b:	01 d0                	add    %edx,%eax
c010055d:	8b 40 08             	mov    0x8(%eax),%eax
c0100560:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100563:	76 16                	jbe    c010057b <stab_binsearch+0xe2>
            *region_right = m - 1;
c0100565:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100568:	8d 50 ff             	lea    -0x1(%eax),%edx
c010056b:	8b 45 10             	mov    0x10(%ebp),%eax
c010056e:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100570:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100573:	83 e8 01             	sub    $0x1,%eax
c0100576:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100579:	eb 12                	jmp    c010058d <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010057b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100581:	89 10                	mov    %edx,(%eax)
            l = m;
c0100583:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100586:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100589:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c010058d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100590:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100593:	0f 8e 22 ff ff ff    	jle    c01004bb <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010059d:	75 0f                	jne    c01005ae <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c010059f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a2:	8b 00                	mov    (%eax),%eax
c01005a4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01005aa:	89 10                	mov    %edx,(%eax)
c01005ac:	eb 3f                	jmp    c01005ed <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01005b1:	8b 00                	mov    (%eax),%eax
c01005b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005b6:	eb 04                	jmp    c01005bc <stab_binsearch+0x123>
c01005b8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005bf:	8b 00                	mov    (%eax),%eax
c01005c1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005c4:	7d 1f                	jge    c01005e5 <stab_binsearch+0x14c>
c01005c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	01 c0                	add    %eax,%eax
c01005cd:	01 d0                	add    %edx,%eax
c01005cf:	c1 e0 02             	shl    $0x2,%eax
c01005d2:	89 c2                	mov    %eax,%edx
c01005d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d7:	01 d0                	add    %edx,%eax
c01005d9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005dd:	0f b6 c0             	movzbl %al,%eax
c01005e0:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005e3:	75 d3                	jne    c01005b8 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01005e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005eb:	89 10                	mov    %edx,(%eax)
    }
}
c01005ed:	c9                   	leave  
c01005ee:	c3                   	ret    

c01005ef <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01005ef:	55                   	push   %ebp
c01005f0:	89 e5                	mov    %esp,%ebp
c01005f2:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f8:	c7 00 88 5e 10 c0    	movl   $0xc0105e88,(%eax)
    info->eip_line = 0;
c01005fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100601:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060b:	c7 40 08 88 5e 10 c0 	movl   $0xc0105e88,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010061c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100622:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010062f:	c7 45 f4 90 70 10 c0 	movl   $0xc0107090,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100636:	c7 45 f0 40 1a 11 c0 	movl   $0xc0111a40,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010063d:	c7 45 ec 41 1a 11 c0 	movl   $0xc0111a41,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100644:	c7 45 e8 80 44 11 c0 	movl   $0xc0114480,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010064b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010064e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100651:	76 0d                	jbe    c0100660 <debuginfo_eip+0x71>
c0100653:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100656:	83 e8 01             	sub    $0x1,%eax
c0100659:	0f b6 00             	movzbl (%eax),%eax
c010065c:	84 c0                	test   %al,%al
c010065e:	74 0a                	je     c010066a <debuginfo_eip+0x7b>
        return -1;
c0100660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100665:	e9 c0 02 00 00       	jmp    c010092a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010066a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100671:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100674:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100677:	29 c2                	sub    %eax,%edx
c0100679:	89 d0                	mov    %edx,%eax
c010067b:	c1 f8 02             	sar    $0x2,%eax
c010067e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100684:	83 e8 01             	sub    $0x1,%eax
c0100687:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c010068a:	8b 45 08             	mov    0x8(%ebp),%eax
c010068d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100691:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100698:	00 
c0100699:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010069c:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006aa:	89 04 24             	mov    %eax,(%esp)
c01006ad:	e8 e7 fd ff ff       	call   c0100499 <stab_binsearch>
    if (lfile == 0)
c01006b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006b5:	85 c0                	test   %eax,%eax
c01006b7:	75 0a                	jne    c01006c3 <debuginfo_eip+0xd4>
        return -1;
c01006b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006be:	e9 67 02 00 00       	jmp    c010092a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01006d2:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006d6:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006dd:	00 
c01006de:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ef:	89 04 24             	mov    %eax,(%esp)
c01006f2:	e8 a2 fd ff ff       	call   c0100499 <stab_binsearch>

    if (lfun <= rfun) {
c01006f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01006fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006fd:	39 c2                	cmp    %eax,%edx
c01006ff:	7f 7c                	jg     c010077d <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100701:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100704:	89 c2                	mov    %eax,%edx
c0100706:	89 d0                	mov    %edx,%eax
c0100708:	01 c0                	add    %eax,%eax
c010070a:	01 d0                	add    %edx,%eax
c010070c:	c1 e0 02             	shl    $0x2,%eax
c010070f:	89 c2                	mov    %eax,%edx
c0100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100714:	01 d0                	add    %edx,%eax
c0100716:	8b 10                	mov    (%eax),%edx
c0100718:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010071b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010071e:	29 c1                	sub    %eax,%ecx
c0100720:	89 c8                	mov    %ecx,%eax
c0100722:	39 c2                	cmp    %eax,%edx
c0100724:	73 22                	jae    c0100748 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100726:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100729:	89 c2                	mov    %eax,%edx
c010072b:	89 d0                	mov    %edx,%eax
c010072d:	01 c0                	add    %eax,%eax
c010072f:	01 d0                	add    %edx,%eax
c0100731:	c1 e0 02             	shl    $0x2,%eax
c0100734:	89 c2                	mov    %eax,%edx
c0100736:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100739:	01 d0                	add    %edx,%eax
c010073b:	8b 10                	mov    (%eax),%edx
c010073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100740:	01 c2                	add    %eax,%edx
c0100742:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100745:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100748:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	89 d0                	mov    %edx,%eax
c010074f:	01 c0                	add    %eax,%eax
c0100751:	01 d0                	add    %edx,%eax
c0100753:	c1 e0 02             	shl    $0x2,%eax
c0100756:	89 c2                	mov    %eax,%edx
c0100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075b:	01 d0                	add    %edx,%eax
c010075d:	8b 50 08             	mov    0x8(%eax),%edx
c0100760:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100763:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100766:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100769:	8b 40 10             	mov    0x10(%eax),%eax
c010076c:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010076f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100772:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100775:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100778:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010077b:	eb 15                	jmp    c0100792 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010077d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100780:	8b 55 08             	mov    0x8(%ebp),%edx
c0100783:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100789:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c010078c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010078f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100792:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100795:	8b 40 08             	mov    0x8(%eax),%eax
c0100798:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010079f:	00 
c01007a0:	89 04 24             	mov    %eax,(%esp)
c01007a3:	e8 5f 4c 00 00       	call   c0105407 <strfind>
c01007a8:	89 c2                	mov    %eax,%edx
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	8b 40 08             	mov    0x8(%eax),%eax
c01007b0:	29 c2                	sub    %eax,%edx
c01007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b5:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01007bb:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007bf:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007c6:	00 
c01007c7:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007ce:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d8:	89 04 24             	mov    %eax,(%esp)
c01007db:	e8 b9 fc ff ff       	call   c0100499 <stab_binsearch>
    if (lline <= rline) {
c01007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007e6:	39 c2                	cmp    %eax,%edx
c01007e8:	7f 24                	jg     c010080e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c01007ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	89 d0                	mov    %edx,%eax
c01007f1:	01 c0                	add    %eax,%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	c1 e0 02             	shl    $0x2,%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100803:	0f b7 d0             	movzwl %ax,%edx
c0100806:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100809:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010080c:	eb 13                	jmp    c0100821 <debuginfo_eip+0x232>
        return -1;
c010080e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100813:	e9 12 01 00 00       	jmp    c010092a <debuginfo_eip+0x33b>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100818:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010081b:	83 e8 01             	sub    $0x1,%eax
c010081e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100821:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7c 56                	jl     c0100881 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010082b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082e:	89 c2                	mov    %eax,%edx
c0100830:	89 d0                	mov    %edx,%eax
c0100832:	01 c0                	add    %eax,%eax
c0100834:	01 d0                	add    %edx,%eax
c0100836:	c1 e0 02             	shl    $0x2,%eax
c0100839:	89 c2                	mov    %eax,%edx
c010083b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083e:	01 d0                	add    %edx,%eax
c0100840:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100844:	3c 84                	cmp    $0x84,%al
c0100846:	74 39                	je     c0100881 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100848:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	89 d0                	mov    %edx,%eax
c010084f:	01 c0                	add    %eax,%eax
c0100851:	01 d0                	add    %edx,%eax
c0100853:	c1 e0 02             	shl    $0x2,%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100861:	3c 64                	cmp    $0x64,%al
c0100863:	75 b3                	jne    c0100818 <debuginfo_eip+0x229>
c0100865:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100868:	89 c2                	mov    %eax,%edx
c010086a:	89 d0                	mov    %edx,%eax
c010086c:	01 c0                	add    %eax,%eax
c010086e:	01 d0                	add    %edx,%eax
c0100870:	c1 e0 02             	shl    $0x2,%eax
c0100873:	89 c2                	mov    %eax,%edx
c0100875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	8b 40 08             	mov    0x8(%eax),%eax
c010087d:	85 c0                	test   %eax,%eax
c010087f:	74 97                	je     c0100818 <debuginfo_eip+0x229>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100881:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100887:	39 c2                	cmp    %eax,%edx
c0100889:	7c 46                	jl     c01008d1 <debuginfo_eip+0x2e2>
c010088b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088e:	89 c2                	mov    %eax,%edx
c0100890:	89 d0                	mov    %edx,%eax
c0100892:	01 c0                	add    %eax,%eax
c0100894:	01 d0                	add    %edx,%eax
c0100896:	c1 e0 02             	shl    $0x2,%eax
c0100899:	89 c2                	mov    %eax,%edx
c010089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089e:	01 d0                	add    %edx,%eax
c01008a0:	8b 10                	mov    (%eax),%edx
c01008a2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008a8:	29 c1                	sub    %eax,%ecx
c01008aa:	89 c8                	mov    %ecx,%eax
c01008ac:	39 c2                	cmp    %eax,%edx
c01008ae:	73 21                	jae    c01008d1 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b3:	89 c2                	mov    %eax,%edx
c01008b5:	89 d0                	mov    %edx,%eax
c01008b7:	01 c0                	add    %eax,%eax
c01008b9:	01 d0                	add    %edx,%eax
c01008bb:	c1 e0 02             	shl    $0x2,%eax
c01008be:	89 c2                	mov    %eax,%edx
c01008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c3:	01 d0                	add    %edx,%eax
c01008c5:	8b 10                	mov    (%eax),%edx
c01008c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008ca:	01 c2                	add    %eax,%edx
c01008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008cf:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008d7:	39 c2                	cmp    %eax,%edx
c01008d9:	7d 4a                	jge    c0100925 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c01008db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008de:	83 c0 01             	add    $0x1,%eax
c01008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008e4:	eb 18                	jmp    c01008fe <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e9:	8b 40 14             	mov    0x14(%eax),%eax
c01008ec:	8d 50 01             	lea    0x1(%eax),%edx
c01008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f2:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c01008f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f8:	83 c0 01             	add    $0x1,%eax
c01008fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100901:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100904:	39 c2                	cmp    %eax,%edx
c0100906:	7d 1d                	jge    c0100925 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010090b:	89 c2                	mov    %eax,%edx
c010090d:	89 d0                	mov    %edx,%eax
c010090f:	01 c0                	add    %eax,%eax
c0100911:	01 d0                	add    %edx,%eax
c0100913:	c1 e0 02             	shl    $0x2,%eax
c0100916:	89 c2                	mov    %eax,%edx
c0100918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010091b:	01 d0                	add    %edx,%eax
c010091d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100921:	3c a0                	cmp    $0xa0,%al
c0100923:	74 c1                	je     c01008e6 <debuginfo_eip+0x2f7>
        }
    }
    return 0;
c0100925:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010092a:	c9                   	leave  
c010092b:	c3                   	ret    

c010092c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010092c:	55                   	push   %ebp
c010092d:	89 e5                	mov    %esp,%ebp
c010092f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100932:	c7 04 24 92 5e 10 c0 	movl   $0xc0105e92,(%esp)
c0100939:	e8 48 f9 ff ff       	call   c0100286 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010093e:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100945:	c0 
c0100946:	c7 04 24 ab 5e 10 c0 	movl   $0xc0105eab,(%esp)
c010094d:	e8 34 f9 ff ff       	call   c0100286 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100952:	c7 44 24 04 9d 5d 10 	movl   $0xc0105d9d,0x4(%esp)
c0100959:	c0 
c010095a:	c7 04 24 c3 5e 10 c0 	movl   $0xc0105ec3,(%esp)
c0100961:	e8 20 f9 ff ff       	call   c0100286 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100966:	c7 44 24 04 36 7a 11 	movl   $0xc0117a36,0x4(%esp)
c010096d:	c0 
c010096e:	c7 04 24 db 5e 10 c0 	movl   $0xc0105edb,(%esp)
c0100975:	e8 0c f9 ff ff       	call   c0100286 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c010097a:	c7 44 24 04 68 89 11 	movl   $0xc0118968,0x4(%esp)
c0100981:	c0 
c0100982:	c7 04 24 f3 5e 10 c0 	movl   $0xc0105ef3,(%esp)
c0100989:	e8 f8 f8 ff ff       	call   c0100286 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010098e:	b8 68 89 11 c0       	mov    $0xc0118968,%eax
c0100993:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100999:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c010099e:	29 c2                	sub    %eax,%edx
c01009a0:	89 d0                	mov    %edx,%eax
c01009a2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009a8:	85 c0                	test   %eax,%eax
c01009aa:	0f 48 c2             	cmovs  %edx,%eax
c01009ad:	c1 f8 0a             	sar    $0xa,%eax
c01009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b4:	c7 04 24 0c 5f 10 c0 	movl   $0xc0105f0c,(%esp)
c01009bb:	e8 c6 f8 ff ff       	call   c0100286 <cprintf>
}
c01009c0:	c9                   	leave  
c01009c1:	c3                   	ret    

c01009c2 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009c2:	55                   	push   %ebp
c01009c3:	89 e5                	mov    %esp,%ebp
c01009c5:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009cb:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01009d5:	89 04 24             	mov    %eax,(%esp)
c01009d8:	e8 12 fc ff ff       	call   c01005ef <debuginfo_eip>
c01009dd:	85 c0                	test   %eax,%eax
c01009df:	74 15                	je     c01009f6 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e8:	c7 04 24 36 5f 10 c0 	movl   $0xc0105f36,(%esp)
c01009ef:	e8 92 f8 ff ff       	call   c0100286 <cprintf>
c01009f4:	eb 6d                	jmp    c0100a63 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009fd:	eb 1c                	jmp    c0100a1b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a05:	01 d0                	add    %edx,%eax
c0100a07:	0f b6 00             	movzbl (%eax),%eax
c0100a0a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a10:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a13:	01 ca                	add    %ecx,%edx
c0100a15:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a21:	7f dc                	jg     c01009ff <print_debuginfo+0x3d>
        }
        fnname[j] = '\0';
c0100a23:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a2c:	01 d0                	add    %edx,%eax
c0100a2e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a34:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a37:	89 d1                	mov    %edx,%ecx
c0100a39:	29 c1                	sub    %eax,%ecx
c0100a3b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a41:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a45:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a4b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a4f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a57:	c7 04 24 52 5f 10 c0 	movl   $0xc0105f52,(%esp)
c0100a5e:	e8 23 f8 ff ff       	call   c0100286 <cprintf>
    }
}
c0100a63:	c9                   	leave  
c0100a64:	c3                   	ret    

c0100a65 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a65:	55                   	push   %ebp
c0100a66:	89 e5                	mov    %esp,%ebp
c0100a68:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a6b:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a74:	c9                   	leave  
c0100a75:	c3                   	ret    

c0100a76 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a76:	55                   	push   %ebp
c0100a77:	89 e5                	mov    %esp,%ebp
c0100a79:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a7c:	89 e8                	mov    %ebp,%eax
c0100a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
c0100a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c0100a87:	e8 d9 ff ff ff       	call   c0100a65 <read_eip>
c0100a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i, j;
	for(i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++) {
c0100a8f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a96:	e9 94 00 00 00       	jmp    c0100b2f <print_stackframe+0xb9>
		cprintf("ebp:0x%08x eip:0x%08x", ebp, eip);
c0100a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aa9:	c7 04 24 64 5f 10 c0 	movl   $0xc0105f64,(%esp)
c0100ab0:	e8 d1 f7 ff ff       	call   c0100286 <cprintf>
		uint32_t *arg = (uint32_t *)ebp + 2;
c0100ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab8:	83 c0 08             	add    $0x8,%eax
c0100abb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" arg:");
c0100abe:	c7 04 24 7a 5f 10 c0 	movl   $0xc0105f7a,(%esp)
c0100ac5:	e8 bc f7 ff ff       	call   c0100286 <cprintf>
		for(j = 0; j < 4; j++) {
c0100aca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ad1:	eb 25                	jmp    c0100af8 <print_stackframe+0x82>
			cprintf("0x%08x ", arg[j]);
c0100ad3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ad6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ae0:	01 d0                	add    %edx,%eax
c0100ae2:	8b 00                	mov    (%eax),%eax
c0100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae8:	c7 04 24 80 5f 10 c0 	movl   $0xc0105f80,(%esp)
c0100aef:	e8 92 f7 ff ff       	call   c0100286 <cprintf>
		for(j = 0; j < 4; j++) {
c0100af4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100af8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100afc:	7e d5                	jle    c0100ad3 <print_stackframe+0x5d>
		}
		cprintf("\n");
c0100afe:	c7 04 24 88 5f 10 c0 	movl   $0xc0105f88,(%esp)
c0100b05:	e8 7c f7 ff ff       	call   c0100286 <cprintf>
		print_debuginfo(eip - 1);
c0100b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0d:	83 e8 01             	sub    $0x1,%eax
c0100b10:	89 04 24             	mov    %eax,(%esp)
c0100b13:	e8 aa fe ff ff       	call   c01009c2 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1b:	83 c0 04             	add    $0x4,%eax
c0100b1e:	8b 00                	mov    (%eax),%eax
c0100b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t*)ebp)[0];
c0100b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b26:	8b 00                	mov    (%eax),%eax
c0100b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++) {
c0100b2b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b2f:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b33:	7f 0a                	jg     c0100b3f <print_stackframe+0xc9>
c0100b35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b39:	0f 85 5c ff ff ff    	jne    c0100a9b <print_stackframe+0x25>
	}
}
c0100b3f:	c9                   	leave  
c0100b40:	c3                   	ret    

c0100b41 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b41:	55                   	push   %ebp
c0100b42:	89 e5                	mov    %esp,%ebp
c0100b44:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4e:	eb 0c                	jmp    c0100b5c <parse+0x1b>
            *buf ++ = '\0';
c0100b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b53:	8d 50 01             	lea    0x1(%eax),%edx
c0100b56:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b59:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5f:	0f b6 00             	movzbl (%eax),%eax
c0100b62:	84 c0                	test   %al,%al
c0100b64:	74 1d                	je     c0100b83 <parse+0x42>
c0100b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b69:	0f b6 00             	movzbl (%eax),%eax
c0100b6c:	0f be c0             	movsbl %al,%eax
c0100b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b73:	c7 04 24 0c 60 10 c0 	movl   $0xc010600c,(%esp)
c0100b7a:	e8 55 48 00 00       	call   c01053d4 <strchr>
c0100b7f:	85 c0                	test   %eax,%eax
c0100b81:	75 cd                	jne    c0100b50 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b86:	0f b6 00             	movzbl (%eax),%eax
c0100b89:	84 c0                	test   %al,%al
c0100b8b:	75 02                	jne    c0100b8f <parse+0x4e>
            break;
c0100b8d:	eb 67                	jmp    c0100bf6 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b8f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b93:	75 14                	jne    c0100ba9 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b95:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b9c:	00 
c0100b9d:	c7 04 24 11 60 10 c0 	movl   $0xc0106011,(%esp)
c0100ba4:	e8 dd f6 ff ff       	call   c0100286 <cprintf>
        }
        argv[argc ++] = buf;
c0100ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bac:	8d 50 01             	lea    0x1(%eax),%edx
c0100baf:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bbc:	01 c2                	add    %eax,%edx
c0100bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc1:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc3:	eb 04                	jmp    c0100bc9 <parse+0x88>
            buf ++;
c0100bc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcc:	0f b6 00             	movzbl (%eax),%eax
c0100bcf:	84 c0                	test   %al,%al
c0100bd1:	74 1d                	je     c0100bf0 <parse+0xaf>
c0100bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd6:	0f b6 00             	movzbl (%eax),%eax
c0100bd9:	0f be c0             	movsbl %al,%eax
c0100bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be0:	c7 04 24 0c 60 10 c0 	movl   $0xc010600c,(%esp)
c0100be7:	e8 e8 47 00 00       	call   c01053d4 <strchr>
c0100bec:	85 c0                	test   %eax,%eax
c0100bee:	74 d5                	je     c0100bc5 <parse+0x84>
        }
    }
c0100bf0:	90                   	nop
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bf1:	e9 66 ff ff ff       	jmp    c0100b5c <parse+0x1b>
    return argc;
c0100bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bf9:	c9                   	leave  
c0100bfa:	c3                   	ret    

c0100bfb <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bfb:	55                   	push   %ebp
c0100bfc:	89 e5                	mov    %esp,%ebp
c0100bfe:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c01:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c08:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0b:	89 04 24             	mov    %eax,(%esp)
c0100c0e:	e8 2e ff ff ff       	call   c0100b41 <parse>
c0100c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c1a:	75 0a                	jne    c0100c26 <runcmd+0x2b>
        return 0;
c0100c1c:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c21:	e9 85 00 00 00       	jmp    c0100cab <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c2d:	eb 5c                	jmp    c0100c8b <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c2f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c35:	89 d0                	mov    %edx,%eax
c0100c37:	01 c0                	add    %eax,%eax
c0100c39:	01 d0                	add    %edx,%eax
c0100c3b:	c1 e0 02             	shl    $0x2,%eax
c0100c3e:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c43:	8b 00                	mov    (%eax),%eax
c0100c45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c49:	89 04 24             	mov    %eax,(%esp)
c0100c4c:	e8 e4 46 00 00       	call   c0105335 <strcmp>
c0100c51:	85 c0                	test   %eax,%eax
c0100c53:	75 32                	jne    c0100c87 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c58:	89 d0                	mov    %edx,%eax
c0100c5a:	01 c0                	add    %eax,%eax
c0100c5c:	01 d0                	add    %edx,%eax
c0100c5e:	c1 e0 02             	shl    $0x2,%eax
c0100c61:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c66:	8b 40 08             	mov    0x8(%eax),%eax
c0100c69:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100c6c:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100c72:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c76:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100c79:	83 c2 04             	add    $0x4,%edx
c0100c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100c80:	89 0c 24             	mov    %ecx,(%esp)
c0100c83:	ff d0                	call   *%eax
c0100c85:	eb 24                	jmp    c0100cab <runcmd+0xb0>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8e:	83 f8 02             	cmp    $0x2,%eax
c0100c91:	76 9c                	jbe    c0100c2f <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c93:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9a:	c7 04 24 2f 60 10 c0 	movl   $0xc010602f,(%esp)
c0100ca1:	e8 e0 f5 ff ff       	call   c0100286 <cprintf>
    return 0;
c0100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cab:	c9                   	leave  
c0100cac:	c3                   	ret    

c0100cad <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cad:	55                   	push   %ebp
c0100cae:	89 e5                	mov    %esp,%ebp
c0100cb0:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cb3:	c7 04 24 48 60 10 c0 	movl   $0xc0106048,(%esp)
c0100cba:	e8 c7 f5 ff ff       	call   c0100286 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cbf:	c7 04 24 70 60 10 c0 	movl   $0xc0106070,(%esp)
c0100cc6:	e8 bb f5 ff ff       	call   c0100286 <cprintf>

    if (tf != NULL) {
c0100ccb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ccf:	74 0b                	je     c0100cdc <kmonitor+0x2f>
        print_trapframe(tf);
c0100cd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd4:	89 04 24             	mov    %eax,(%esp)
c0100cd7:	e8 74 0d 00 00       	call   c0101a50 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cdc:	c7 04 24 95 60 10 c0 	movl   $0xc0106095,(%esp)
c0100ce3:	e8 3f f6 ff ff       	call   c0100327 <readline>
c0100ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ceb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cef:	74 18                	je     c0100d09 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cfb:	89 04 24             	mov    %eax,(%esp)
c0100cfe:	e8 f8 fe ff ff       	call   c0100bfb <runcmd>
c0100d03:	85 c0                	test   %eax,%eax
c0100d05:	79 02                	jns    c0100d09 <kmonitor+0x5c>
                break;
c0100d07:	eb 02                	jmp    c0100d0b <kmonitor+0x5e>
            }
        }
    }
c0100d09:	eb d1                	jmp    c0100cdc <kmonitor+0x2f>
}
c0100d0b:	c9                   	leave  
c0100d0c:	c3                   	ret    

c0100d0d <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d0d:	55                   	push   %ebp
c0100d0e:	89 e5                	mov    %esp,%ebp
c0100d10:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d1a:	eb 3f                	jmp    c0100d5b <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d1f:	89 d0                	mov    %edx,%eax
c0100d21:	01 c0                	add    %eax,%eax
c0100d23:	01 d0                	add    %edx,%eax
c0100d25:	c1 e0 02             	shl    $0x2,%eax
c0100d28:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100d2d:	8b 48 04             	mov    0x4(%eax),%ecx
c0100d30:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d33:	89 d0                	mov    %edx,%eax
c0100d35:	01 c0                	add    %eax,%eax
c0100d37:	01 d0                	add    %edx,%eax
c0100d39:	c1 e0 02             	shl    $0x2,%eax
c0100d3c:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100d41:	8b 00                	mov    (%eax),%eax
c0100d43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4b:	c7 04 24 99 60 10 c0 	movl   $0xc0106099,(%esp)
c0100d52:	e8 2f f5 ff ff       	call   c0100286 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d57:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5e:	83 f8 02             	cmp    $0x2,%eax
c0100d61:	76 b9                	jbe    c0100d1c <mon_help+0xf>
    }
    return 0;
c0100d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d68:	c9                   	leave  
c0100d69:	c3                   	ret    

c0100d6a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d6a:	55                   	push   %ebp
c0100d6b:	89 e5                	mov    %esp,%ebp
c0100d6d:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d70:	e8 b7 fb ff ff       	call   c010092c <print_kerninfo>
    return 0;
c0100d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7a:	c9                   	leave  
c0100d7b:	c3                   	ret    

c0100d7c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d7c:	55                   	push   %ebp
c0100d7d:	89 e5                	mov    %esp,%ebp
c0100d7f:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d82:	e8 ef fc ff ff       	call   c0100a76 <print_stackframe>
    return 0;
c0100d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8c:	c9                   	leave  
c0100d8d:	c3                   	ret    

c0100d8e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d8e:	55                   	push   %ebp
c0100d8f:	89 e5                	mov    %esp,%ebp
c0100d91:	83 ec 28             	sub    $0x28,%esp
c0100d94:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d9a:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d9e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100da2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100da6:	ee                   	out    %al,(%dx)
c0100da7:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dad:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100db1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100db5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100db9:	ee                   	out    %al,(%dx)
c0100dba:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dc0:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dc4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dc8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dcc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dcd:	c7 05 4c 89 11 c0 00 	movl   $0x0,0xc011894c
c0100dd4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dd7:	c7 04 24 a2 60 10 c0 	movl   $0xc01060a2,(%esp)
c0100dde:	e8 a3 f4 ff ff       	call   c0100286 <cprintf>
    pic_enable(IRQ_TIMER);
c0100de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dea:	e8 18 09 00 00       	call   c0101707 <pic_enable>
}
c0100def:	c9                   	leave  
c0100df0:	c3                   	ret    

c0100df1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100df1:	55                   	push   %ebp
c0100df2:	89 e5                	mov    %esp,%ebp
c0100df4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100df7:	9c                   	pushf  
c0100df8:	58                   	pop    %eax
c0100df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100dff:	25 00 02 00 00       	and    $0x200,%eax
c0100e04:	85 c0                	test   %eax,%eax
c0100e06:	74 0c                	je     c0100e14 <__intr_save+0x23>
        intr_disable();
c0100e08:	e8 69 0a 00 00       	call   c0101876 <intr_disable>
        return 1;
c0100e0d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e12:	eb 05                	jmp    c0100e19 <__intr_save+0x28>
    }
    return 0;
c0100e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e19:	c9                   	leave  
c0100e1a:	c3                   	ret    

c0100e1b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e1b:	55                   	push   %ebp
c0100e1c:	89 e5                	mov    %esp,%ebp
c0100e1e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e21:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e25:	74 05                	je     c0100e2c <__intr_restore+0x11>
        intr_enable();
c0100e27:	e8 44 0a 00 00       	call   c0101870 <intr_enable>
    }
}
c0100e2c:	c9                   	leave  
c0100e2d:	c3                   	ret    

c0100e2e <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e2e:	55                   	push   %ebp
c0100e2f:	89 e5                	mov    %esp,%ebp
c0100e31:	83 ec 10             	sub    $0x10,%esp
c0100e34:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e3a:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e3e:	89 c2                	mov    %eax,%edx
c0100e40:	ec                   	in     (%dx),%al
c0100e41:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e44:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e4a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e4e:	89 c2                	mov    %eax,%edx
c0100e50:	ec                   	in     (%dx),%al
c0100e51:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e54:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e5a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e5e:	89 c2                	mov    %eax,%edx
c0100e60:	ec                   	in     (%dx),%al
c0100e61:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e64:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e6a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e6e:	89 c2                	mov    %eax,%edx
c0100e70:	ec                   	in     (%dx),%al
c0100e71:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e74:	c9                   	leave  
c0100e75:	c3                   	ret    

c0100e76 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e76:	55                   	push   %ebp
c0100e77:	89 e5                	mov    %esp,%ebp
c0100e79:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e7c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e86:	0f b7 00             	movzwl (%eax),%eax
c0100e89:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e90:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e98:	0f b7 00             	movzwl (%eax),%eax
c0100e9b:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e9f:	74 12                	je     c0100eb3 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ea1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ea8:	66 c7 05 86 7e 11 c0 	movw   $0x3b4,0xc0117e86
c0100eaf:	b4 03 
c0100eb1:	eb 13                	jmp    c0100ec6 <cga_init+0x50>
    } else {
        *cp = was;
c0100eb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eba:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ebd:	66 c7 05 86 7e 11 c0 	movw   $0x3d4,0xc0117e86
c0100ec4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ec6:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100ecd:	0f b7 c0             	movzwl %ax,%eax
c0100ed0:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ed4:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100edc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ee0:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee1:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100ee8:	83 c0 01             	add    $0x1,%eax
c0100eeb:	0f b7 c0             	movzwl %ax,%eax
c0100eee:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef2:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100ef6:	89 c2                	mov    %eax,%edx
c0100ef8:	ec                   	in     (%dx),%al
c0100ef9:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100efc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f00:	0f b6 c0             	movzbl %al,%eax
c0100f03:	c1 e0 08             	shl    $0x8,%eax
c0100f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f09:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f10:	0f b7 c0             	movzwl %ax,%eax
c0100f13:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f17:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f1b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f1f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f23:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f24:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f2b:	83 c0 01             	add    $0x1,%eax
c0100f2e:	0f b7 c0             	movzwl %ax,%eax
c0100f31:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f35:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f39:	89 c2                	mov    %eax,%edx
c0100f3b:	ec                   	in     (%dx),%al
c0100f3c:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f3f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f43:	0f b6 c0             	movzbl %al,%eax
c0100f46:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f4c:	a3 80 7e 11 c0       	mov    %eax,0xc0117e80
    crt_pos = pos;
c0100f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f54:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
}
c0100f5a:	c9                   	leave  
c0100f5b:	c3                   	ret    

c0100f5c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f5c:	55                   	push   %ebp
c0100f5d:	89 e5                	mov    %esp,%ebp
c0100f5f:	83 ec 48             	sub    $0x48,%esp
c0100f62:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f68:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f6c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f70:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f74:	ee                   	out    %al,(%dx)
c0100f75:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f7b:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f7f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f83:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f87:	ee                   	out    %al,(%dx)
c0100f88:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f8e:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100f92:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f96:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f9a:	ee                   	out    %al,(%dx)
c0100f9b:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fa1:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fa5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fa9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fad:	ee                   	out    %al,(%dx)
c0100fae:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fb4:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fb8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fbc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fc0:	ee                   	out    %al,(%dx)
c0100fc1:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fc7:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fcb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fcf:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fd3:	ee                   	out    %al,(%dx)
c0100fd4:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fda:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fde:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fe2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fe6:	ee                   	out    %al,(%dx)
c0100fe7:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fed:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100ff1:	89 c2                	mov    %eax,%edx
c0100ff3:	ec                   	in     (%dx),%al
c0100ff4:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100ff7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ffb:	3c ff                	cmp    $0xff,%al
c0100ffd:	0f 95 c0             	setne  %al
c0101000:	0f b6 c0             	movzbl %al,%eax
c0101003:	a3 88 7e 11 c0       	mov    %eax,0xc0117e88
c0101008:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100e:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101012:	89 c2                	mov    %eax,%edx
c0101014:	ec                   	in     (%dx),%al
c0101015:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101018:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010101e:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101022:	89 c2                	mov    %eax,%edx
c0101024:	ec                   	in     (%dx),%al
c0101025:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101028:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c010102d:	85 c0                	test   %eax,%eax
c010102f:	74 0c                	je     c010103d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101031:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101038:	e8 ca 06 00 00       	call   c0101707 <pic_enable>
    }
}
c010103d:	c9                   	leave  
c010103e:	c3                   	ret    

c010103f <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010103f:	55                   	push   %ebp
c0101040:	89 e5                	mov    %esp,%ebp
c0101042:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101045:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010104c:	eb 09                	jmp    c0101057 <lpt_putc_sub+0x18>
        delay();
c010104e:	e8 db fd ff ff       	call   c0100e2e <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101053:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101057:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010105d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101061:	89 c2                	mov    %eax,%edx
c0101063:	ec                   	in     (%dx),%al
c0101064:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101067:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010106b:	84 c0                	test   %al,%al
c010106d:	78 09                	js     c0101078 <lpt_putc_sub+0x39>
c010106f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101076:	7e d6                	jle    c010104e <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101078:	8b 45 08             	mov    0x8(%ebp),%eax
c010107b:	0f b6 c0             	movzbl %al,%eax
c010107e:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101084:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101087:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010108b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010108f:	ee                   	out    %al,(%dx)
c0101090:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101096:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010109a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010109e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010a2:	ee                   	out    %al,(%dx)
c01010a3:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010a9:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010ad:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010b1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010b5:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010b6:	c9                   	leave  
c01010b7:	c3                   	ret    

c01010b8 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010b8:	55                   	push   %ebp
c01010b9:	89 e5                	mov    %esp,%ebp
c01010bb:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010be:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010c2:	74 0d                	je     c01010d1 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c7:	89 04 24             	mov    %eax,(%esp)
c01010ca:	e8 70 ff ff ff       	call   c010103f <lpt_putc_sub>
c01010cf:	eb 24                	jmp    c01010f5 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010d1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010d8:	e8 62 ff ff ff       	call   c010103f <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010e4:	e8 56 ff ff ff       	call   c010103f <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f0:	e8 4a ff ff ff       	call   c010103f <lpt_putc_sub>
    }
}
c01010f5:	c9                   	leave  
c01010f6:	c3                   	ret    

c01010f7 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010f7:	55                   	push   %ebp
c01010f8:	89 e5                	mov    %esp,%ebp
c01010fa:	53                   	push   %ebx
c01010fb:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101101:	b0 00                	mov    $0x0,%al
c0101103:	85 c0                	test   %eax,%eax
c0101105:	75 07                	jne    c010110e <cga_putc+0x17>
        c |= 0x0700;
c0101107:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010110e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101111:	0f b6 c0             	movzbl %al,%eax
c0101114:	83 f8 0a             	cmp    $0xa,%eax
c0101117:	74 4c                	je     c0101165 <cga_putc+0x6e>
c0101119:	83 f8 0d             	cmp    $0xd,%eax
c010111c:	74 57                	je     c0101175 <cga_putc+0x7e>
c010111e:	83 f8 08             	cmp    $0x8,%eax
c0101121:	0f 85 88 00 00 00    	jne    c01011af <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101127:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010112e:	66 85 c0             	test   %ax,%ax
c0101131:	74 30                	je     c0101163 <cga_putc+0x6c>
            crt_pos --;
c0101133:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010113a:	83 e8 01             	sub    $0x1,%eax
c010113d:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101143:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c0101148:	0f b7 15 84 7e 11 c0 	movzwl 0xc0117e84,%edx
c010114f:	0f b7 d2             	movzwl %dx,%edx
c0101152:	01 d2                	add    %edx,%edx
c0101154:	01 c2                	add    %eax,%edx
c0101156:	8b 45 08             	mov    0x8(%ebp),%eax
c0101159:	b0 00                	mov    $0x0,%al
c010115b:	83 c8 20             	or     $0x20,%eax
c010115e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101161:	eb 72                	jmp    c01011d5 <cga_putc+0xde>
c0101163:	eb 70                	jmp    c01011d5 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101165:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010116c:	83 c0 50             	add    $0x50,%eax
c010116f:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101175:	0f b7 1d 84 7e 11 c0 	movzwl 0xc0117e84,%ebx
c010117c:	0f b7 0d 84 7e 11 c0 	movzwl 0xc0117e84,%ecx
c0101183:	0f b7 c1             	movzwl %cx,%eax
c0101186:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010118c:	c1 e8 10             	shr    $0x10,%eax
c010118f:	89 c2                	mov    %eax,%edx
c0101191:	66 c1 ea 06          	shr    $0x6,%dx
c0101195:	89 d0                	mov    %edx,%eax
c0101197:	c1 e0 02             	shl    $0x2,%eax
c010119a:	01 d0                	add    %edx,%eax
c010119c:	c1 e0 04             	shl    $0x4,%eax
c010119f:	29 c1                	sub    %eax,%ecx
c01011a1:	89 ca                	mov    %ecx,%edx
c01011a3:	89 d8                	mov    %ebx,%eax
c01011a5:	29 d0                	sub    %edx,%eax
c01011a7:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
        break;
c01011ad:	eb 26                	jmp    c01011d5 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011af:	8b 0d 80 7e 11 c0    	mov    0xc0117e80,%ecx
c01011b5:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011bc:	8d 50 01             	lea    0x1(%eax),%edx
c01011bf:	66 89 15 84 7e 11 c0 	mov    %dx,0xc0117e84
c01011c6:	0f b7 c0             	movzwl %ax,%eax
c01011c9:	01 c0                	add    %eax,%eax
c01011cb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01011d1:	66 89 02             	mov    %ax,(%edx)
        break;
c01011d4:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011d5:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011dc:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011e0:	76 5b                	jbe    c010123d <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011e2:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011e7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011ed:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011f2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01011f9:	00 
c01011fa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01011fe:	89 04 24             	mov    %eax,(%esp)
c0101201:	e8 cc 43 00 00       	call   c01055d2 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101206:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010120d:	eb 15                	jmp    c0101224 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010120f:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c0101214:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101217:	01 d2                	add    %edx,%edx
c0101219:	01 d0                	add    %edx,%eax
c010121b:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101220:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101224:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010122b:	7e e2                	jle    c010120f <cga_putc+0x118>
        }
        crt_pos -= CRT_COLS;
c010122d:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101234:	83 e8 50             	sub    $0x50,%eax
c0101237:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010123d:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0101244:	0f b7 c0             	movzwl %ax,%eax
c0101247:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010124b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010124f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101253:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101257:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101258:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010125f:	66 c1 e8 08          	shr    $0x8,%ax
c0101263:	0f b6 c0             	movzbl %al,%eax
c0101266:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c010126d:	83 c2 01             	add    $0x1,%edx
c0101270:	0f b7 d2             	movzwl %dx,%edx
c0101273:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101277:	88 45 ed             	mov    %al,-0x13(%ebp)
c010127a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010127e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101282:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101283:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c010128a:	0f b7 c0             	movzwl %ax,%eax
c010128d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101291:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101295:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101299:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010129d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c010129e:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01012a5:	0f b6 c0             	movzbl %al,%eax
c01012a8:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c01012af:	83 c2 01             	add    $0x1,%edx
c01012b2:	0f b7 d2             	movzwl %dx,%edx
c01012b5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012b9:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012bc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012c0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012c4:	ee                   	out    %al,(%dx)
}
c01012c5:	83 c4 34             	add    $0x34,%esp
c01012c8:	5b                   	pop    %ebx
c01012c9:	5d                   	pop    %ebp
c01012ca:	c3                   	ret    

c01012cb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012cb:	55                   	push   %ebp
c01012cc:	89 e5                	mov    %esp,%ebp
c01012ce:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012d8:	eb 09                	jmp    c01012e3 <serial_putc_sub+0x18>
        delay();
c01012da:	e8 4f fb ff ff       	call   c0100e2e <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012df:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012e3:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012e9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012ed:	89 c2                	mov    %eax,%edx
c01012ef:	ec                   	in     (%dx),%al
c01012f0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01012f3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01012f7:	0f b6 c0             	movzbl %al,%eax
c01012fa:	83 e0 20             	and    $0x20,%eax
c01012fd:	85 c0                	test   %eax,%eax
c01012ff:	75 09                	jne    c010130a <serial_putc_sub+0x3f>
c0101301:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101308:	7e d0                	jle    c01012da <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010130a:	8b 45 08             	mov    0x8(%ebp),%eax
c010130d:	0f b6 c0             	movzbl %al,%eax
c0101310:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101316:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101319:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010131d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101321:	ee                   	out    %al,(%dx)
}
c0101322:	c9                   	leave  
c0101323:	c3                   	ret    

c0101324 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101324:	55                   	push   %ebp
c0101325:	89 e5                	mov    %esp,%ebp
c0101327:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010132a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010132e:	74 0d                	je     c010133d <serial_putc+0x19>
        serial_putc_sub(c);
c0101330:	8b 45 08             	mov    0x8(%ebp),%eax
c0101333:	89 04 24             	mov    %eax,(%esp)
c0101336:	e8 90 ff ff ff       	call   c01012cb <serial_putc_sub>
c010133b:	eb 24                	jmp    c0101361 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010133d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101344:	e8 82 ff ff ff       	call   c01012cb <serial_putc_sub>
        serial_putc_sub(' ');
c0101349:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101350:	e8 76 ff ff ff       	call   c01012cb <serial_putc_sub>
        serial_putc_sub('\b');
c0101355:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010135c:	e8 6a ff ff ff       	call   c01012cb <serial_putc_sub>
    }
}
c0101361:	c9                   	leave  
c0101362:	c3                   	ret    

c0101363 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101363:	55                   	push   %ebp
c0101364:	89 e5                	mov    %esp,%ebp
c0101366:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101369:	eb 33                	jmp    c010139e <cons_intr+0x3b>
        if (c != 0) {
c010136b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010136f:	74 2d                	je     c010139e <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101371:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c0101376:	8d 50 01             	lea    0x1(%eax),%edx
c0101379:	89 15 a4 80 11 c0    	mov    %edx,0xc01180a4
c010137f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101382:	88 90 a0 7e 11 c0    	mov    %dl,-0x3fee8160(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101388:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c010138d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101392:	75 0a                	jne    c010139e <cons_intr+0x3b>
                cons.wpos = 0;
c0101394:	c7 05 a4 80 11 c0 00 	movl   $0x0,0xc01180a4
c010139b:	00 00 00 
    while ((c = (*proc)()) != -1) {
c010139e:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a1:	ff d0                	call   *%eax
c01013a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013a6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013aa:	75 bf                	jne    c010136b <cons_intr+0x8>
            }
        }
    }
}
c01013ac:	c9                   	leave  
c01013ad:	c3                   	ret    

c01013ae <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013ae:	55                   	push   %ebp
c01013af:	89 e5                	mov    %esp,%ebp
c01013b1:	83 ec 10             	sub    $0x10,%esp
c01013b4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ba:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013be:	89 c2                	mov    %eax,%edx
c01013c0:	ec                   	in     (%dx),%al
c01013c1:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013c4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013c8:	0f b6 c0             	movzbl %al,%eax
c01013cb:	83 e0 01             	and    $0x1,%eax
c01013ce:	85 c0                	test   %eax,%eax
c01013d0:	75 07                	jne    c01013d9 <serial_proc_data+0x2b>
        return -1;
c01013d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013d7:	eb 2a                	jmp    c0101403 <serial_proc_data+0x55>
c01013d9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013df:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013e3:	89 c2                	mov    %eax,%edx
c01013e5:	ec                   	in     (%dx),%al
c01013e6:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013e9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013ed:	0f b6 c0             	movzbl %al,%eax
c01013f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013f3:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013f7:	75 07                	jne    c0101400 <serial_proc_data+0x52>
        c = '\b';
c01013f9:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101400:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101403:	c9                   	leave  
c0101404:	c3                   	ret    

c0101405 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101405:	55                   	push   %ebp
c0101406:	89 e5                	mov    %esp,%ebp
c0101408:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010140b:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c0101410:	85 c0                	test   %eax,%eax
c0101412:	74 0c                	je     c0101420 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101414:	c7 04 24 ae 13 10 c0 	movl   $0xc01013ae,(%esp)
c010141b:	e8 43 ff ff ff       	call   c0101363 <cons_intr>
    }
}
c0101420:	c9                   	leave  
c0101421:	c3                   	ret    

c0101422 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101422:	55                   	push   %ebp
c0101423:	89 e5                	mov    %esp,%ebp
c0101425:	83 ec 38             	sub    $0x38,%esp
c0101428:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010142e:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101432:	89 c2                	mov    %eax,%edx
c0101434:	ec                   	in     (%dx),%al
c0101435:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101438:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010143c:	0f b6 c0             	movzbl %al,%eax
c010143f:	83 e0 01             	and    $0x1,%eax
c0101442:	85 c0                	test   %eax,%eax
c0101444:	75 0a                	jne    c0101450 <kbd_proc_data+0x2e>
        return -1;
c0101446:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010144b:	e9 59 01 00 00       	jmp    c01015a9 <kbd_proc_data+0x187>
c0101450:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101456:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010145a:	89 c2                	mov    %eax,%edx
c010145c:	ec                   	in     (%dx),%al
c010145d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101460:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101464:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101467:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010146b:	75 17                	jne    c0101484 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010146d:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101472:	83 c8 40             	or     $0x40,%eax
c0101475:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c010147a:	b8 00 00 00 00       	mov    $0x0,%eax
c010147f:	e9 25 01 00 00       	jmp    c01015a9 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101484:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101488:	84 c0                	test   %al,%al
c010148a:	79 47                	jns    c01014d3 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010148c:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101491:	83 e0 40             	and    $0x40,%eax
c0101494:	85 c0                	test   %eax,%eax
c0101496:	75 09                	jne    c01014a1 <kbd_proc_data+0x7f>
c0101498:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149c:	83 e0 7f             	and    $0x7f,%eax
c010149f:	eb 04                	jmp    c01014a5 <kbd_proc_data+0x83>
c01014a1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a5:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ac:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014b3:	83 c8 40             	or     $0x40,%eax
c01014b6:	0f b6 c0             	movzbl %al,%eax
c01014b9:	f7 d0                	not    %eax
c01014bb:	89 c2                	mov    %eax,%edx
c01014bd:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014c2:	21 d0                	and    %edx,%eax
c01014c4:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c01014c9:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ce:	e9 d6 00 00 00       	jmp    c01015a9 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014d3:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014d8:	83 e0 40             	and    $0x40,%eax
c01014db:	85 c0                	test   %eax,%eax
c01014dd:	74 11                	je     c01014f0 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014df:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014e3:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014e8:	83 e0 bf             	and    $0xffffffbf,%eax
c01014eb:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    }

    shift |= shiftcode[data];
c01014f0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014f4:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014fb:	0f b6 d0             	movzbl %al,%edx
c01014fe:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101503:	09 d0                	or     %edx,%eax
c0101505:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    shift ^= togglecode[data];
c010150a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150e:	0f b6 80 60 71 11 c0 	movzbl -0x3fee8ea0(%eax),%eax
c0101515:	0f b6 d0             	movzbl %al,%edx
c0101518:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c010151d:	31 d0                	xor    %edx,%eax
c010151f:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101524:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101529:	83 e0 03             	and    $0x3,%eax
c010152c:	8b 14 85 60 75 11 c0 	mov    -0x3fee8aa0(,%eax,4),%edx
c0101533:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101537:	01 d0                	add    %edx,%eax
c0101539:	0f b6 00             	movzbl (%eax),%eax
c010153c:	0f b6 c0             	movzbl %al,%eax
c010153f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101542:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101547:	83 e0 08             	and    $0x8,%eax
c010154a:	85 c0                	test   %eax,%eax
c010154c:	74 22                	je     c0101570 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010154e:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101552:	7e 0c                	jle    c0101560 <kbd_proc_data+0x13e>
c0101554:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101558:	7f 06                	jg     c0101560 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010155a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010155e:	eb 10                	jmp    c0101570 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101560:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101564:	7e 0a                	jle    c0101570 <kbd_proc_data+0x14e>
c0101566:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010156a:	7f 04                	jg     c0101570 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010156c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101570:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101575:	f7 d0                	not    %eax
c0101577:	83 e0 06             	and    $0x6,%eax
c010157a:	85 c0                	test   %eax,%eax
c010157c:	75 28                	jne    c01015a6 <kbd_proc_data+0x184>
c010157e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101585:	75 1f                	jne    c01015a6 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101587:	c7 04 24 bd 60 10 c0 	movl   $0xc01060bd,(%esp)
c010158e:	e8 f3 ec ff ff       	call   c0100286 <cprintf>
c0101593:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101599:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010159d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015a1:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015a5:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015a9:	c9                   	leave  
c01015aa:	c3                   	ret    

c01015ab <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015ab:	55                   	push   %ebp
c01015ac:	89 e5                	mov    %esp,%ebp
c01015ae:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015b1:	c7 04 24 22 14 10 c0 	movl   $0xc0101422,(%esp)
c01015b8:	e8 a6 fd ff ff       	call   c0101363 <cons_intr>
}
c01015bd:	c9                   	leave  
c01015be:	c3                   	ret    

c01015bf <kbd_init>:

static void
kbd_init(void) {
c01015bf:	55                   	push   %ebp
c01015c0:	89 e5                	mov    %esp,%ebp
c01015c2:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015c5:	e8 e1 ff ff ff       	call   c01015ab <kbd_intr>
    pic_enable(IRQ_KBD);
c01015ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015d1:	e8 31 01 00 00       	call   c0101707 <pic_enable>
}
c01015d6:	c9                   	leave  
c01015d7:	c3                   	ret    

c01015d8 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015d8:	55                   	push   %ebp
c01015d9:	89 e5                	mov    %esp,%ebp
c01015db:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015de:	e8 93 f8 ff ff       	call   c0100e76 <cga_init>
    serial_init();
c01015e3:	e8 74 f9 ff ff       	call   c0100f5c <serial_init>
    kbd_init();
c01015e8:	e8 d2 ff ff ff       	call   c01015bf <kbd_init>
    if (!serial_exists) {
c01015ed:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c01015f2:	85 c0                	test   %eax,%eax
c01015f4:	75 0c                	jne    c0101602 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015f6:	c7 04 24 c9 60 10 c0 	movl   $0xc01060c9,(%esp)
c01015fd:	e8 84 ec ff ff       	call   c0100286 <cprintf>
    }
}
c0101602:	c9                   	leave  
c0101603:	c3                   	ret    

c0101604 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101604:	55                   	push   %ebp
c0101605:	89 e5                	mov    %esp,%ebp
c0101607:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010160a:	e8 e2 f7 ff ff       	call   c0100df1 <__intr_save>
c010160f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101612:	8b 45 08             	mov    0x8(%ebp),%eax
c0101615:	89 04 24             	mov    %eax,(%esp)
c0101618:	e8 9b fa ff ff       	call   c01010b8 <lpt_putc>
        cga_putc(c);
c010161d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101620:	89 04 24             	mov    %eax,(%esp)
c0101623:	e8 cf fa ff ff       	call   c01010f7 <cga_putc>
        serial_putc(c);
c0101628:	8b 45 08             	mov    0x8(%ebp),%eax
c010162b:	89 04 24             	mov    %eax,(%esp)
c010162e:	e8 f1 fc ff ff       	call   c0101324 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101633:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101636:	89 04 24             	mov    %eax,(%esp)
c0101639:	e8 dd f7 ff ff       	call   c0100e1b <__intr_restore>
}
c010163e:	c9                   	leave  
c010163f:	c3                   	ret    

c0101640 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101640:	55                   	push   %ebp
c0101641:	89 e5                	mov    %esp,%ebp
c0101643:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010164d:	e8 9f f7 ff ff       	call   c0100df1 <__intr_save>
c0101652:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101655:	e8 ab fd ff ff       	call   c0101405 <serial_intr>
        kbd_intr();
c010165a:	e8 4c ff ff ff       	call   c01015ab <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010165f:	8b 15 a0 80 11 c0    	mov    0xc01180a0,%edx
c0101665:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c010166a:	39 c2                	cmp    %eax,%edx
c010166c:	74 31                	je     c010169f <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010166e:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c0101673:	8d 50 01             	lea    0x1(%eax),%edx
c0101676:	89 15 a0 80 11 c0    	mov    %edx,0xc01180a0
c010167c:	0f b6 80 a0 7e 11 c0 	movzbl -0x3fee8160(%eax),%eax
c0101683:	0f b6 c0             	movzbl %al,%eax
c0101686:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101689:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c010168e:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101693:	75 0a                	jne    c010169f <cons_getc+0x5f>
                cons.rpos = 0;
c0101695:	c7 05 a0 80 11 c0 00 	movl   $0x0,0xc01180a0
c010169c:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016a2:	89 04 24             	mov    %eax,(%esp)
c01016a5:	e8 71 f7 ff ff       	call   c0100e1b <__intr_restore>
    return c;
c01016aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016ad:	c9                   	leave  
c01016ae:	c3                   	ret    

c01016af <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016af:	55                   	push   %ebp
c01016b0:	89 e5                	mov    %esp,%ebp
c01016b2:	83 ec 14             	sub    $0x14,%esp
c01016b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016c0:	66 a3 70 75 11 c0    	mov    %ax,0xc0117570
    if (did_init) {
c01016c6:	a1 ac 80 11 c0       	mov    0xc01180ac,%eax
c01016cb:	85 c0                	test   %eax,%eax
c01016cd:	74 36                	je     c0101705 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016cf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016d3:	0f b6 c0             	movzbl %al,%eax
c01016d6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016dc:	88 45 fd             	mov    %al,-0x3(%ebp)
c01016df:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016e3:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016e7:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016e8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016ec:	66 c1 e8 08          	shr    $0x8,%ax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01016f9:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101700:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
    }
}
c0101705:	c9                   	leave  
c0101706:	c3                   	ret    

c0101707 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101707:	55                   	push   %ebp
c0101708:	89 e5                	mov    %esp,%ebp
c010170a:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010170d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101710:	ba 01 00 00 00       	mov    $0x1,%edx
c0101715:	89 c1                	mov    %eax,%ecx
c0101717:	d3 e2                	shl    %cl,%edx
c0101719:	89 d0                	mov    %edx,%eax
c010171b:	f7 d0                	not    %eax
c010171d:	89 c2                	mov    %eax,%edx
c010171f:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101726:	21 d0                	and    %edx,%eax
c0101728:	0f b7 c0             	movzwl %ax,%eax
c010172b:	89 04 24             	mov    %eax,(%esp)
c010172e:	e8 7c ff ff ff       	call   c01016af <pic_setmask>
}
c0101733:	c9                   	leave  
c0101734:	c3                   	ret    

c0101735 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101735:	55                   	push   %ebp
c0101736:	89 e5                	mov    %esp,%ebp
c0101738:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010173b:	c7 05 ac 80 11 c0 01 	movl   $0x1,0xc01180ac
c0101742:	00 00 00 
c0101745:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010174b:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010174f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101753:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101757:	ee                   	out    %al,(%dx)
c0101758:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010175e:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0101762:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101766:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010176a:	ee                   	out    %al,(%dx)
c010176b:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101771:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101775:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101779:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010177d:	ee                   	out    %al,(%dx)
c010177e:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0101784:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0101788:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010178c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101790:	ee                   	out    %al,(%dx)
c0101791:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0101797:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010179b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010179f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017a3:	ee                   	out    %al,(%dx)
c01017a4:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017aa:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017ae:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017b2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017b6:	ee                   	out    %al,(%dx)
c01017b7:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017bd:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017c1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017c5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017c9:	ee                   	out    %al,(%dx)
c01017ca:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017d0:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017d4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017d8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017dc:	ee                   	out    %al,(%dx)
c01017dd:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01017e3:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c01017e7:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017eb:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017ef:	ee                   	out    %al,(%dx)
c01017f0:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01017f6:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01017fa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017fe:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101802:	ee                   	out    %al,(%dx)
c0101803:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101809:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010180d:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101811:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101815:	ee                   	out    %al,(%dx)
c0101816:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010181c:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101820:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101824:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101828:	ee                   	out    %al,(%dx)
c0101829:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010182f:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101833:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101837:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010183b:	ee                   	out    %al,(%dx)
c010183c:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0101842:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101846:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010184a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010184e:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010184f:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101856:	66 83 f8 ff          	cmp    $0xffff,%ax
c010185a:	74 12                	je     c010186e <pic_init+0x139>
        pic_setmask(irq_mask);
c010185c:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101863:	0f b7 c0             	movzwl %ax,%eax
c0101866:	89 04 24             	mov    %eax,(%esp)
c0101869:	e8 41 fe ff ff       	call   c01016af <pic_setmask>
    }
}
c010186e:	c9                   	leave  
c010186f:	c3                   	ret    

c0101870 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101870:	55                   	push   %ebp
c0101871:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101873:	fb                   	sti    
    sti();
}
c0101874:	5d                   	pop    %ebp
c0101875:	c3                   	ret    

c0101876 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101876:	55                   	push   %ebp
c0101877:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101879:	fa                   	cli    
    cli();
}
c010187a:	5d                   	pop    %ebp
c010187b:	c3                   	ret    

c010187c <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010187c:	55                   	push   %ebp
c010187d:	89 e5                	mov    %esp,%ebp
c010187f:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101882:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101889:	00 
c010188a:	c7 04 24 00 61 10 c0 	movl   $0xc0106100,(%esp)
c0101891:	e8 f0 e9 ff ff       	call   c0100286 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0101896:	c9                   	leave  
c0101897:	c3                   	ret    

c0101898 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0101898:	55                   	push   %ebp
c0101899:	89 e5                	mov    %esp,%ebp
c010189b:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
	int i;
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010189e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018a5:	e9 c3 00 00 00       	jmp    c010196d <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ad:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c01018b4:	89 c2                	mov    %eax,%edx
c01018b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018b9:	66 89 14 c5 c0 80 11 	mov    %dx,-0x3fee7f40(,%eax,8)
c01018c0:	c0 
c01018c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c4:	66 c7 04 c5 c2 80 11 	movw   $0x8,-0x3fee7f3e(,%eax,8)
c01018cb:	c0 08 00 
c01018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d1:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018d8:	c0 
c01018d9:	83 e2 e0             	and    $0xffffffe0,%edx
c01018dc:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e6:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018ed:	c0 
c01018ee:	83 e2 1f             	and    $0x1f,%edx
c01018f1:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fb:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101902:	c0 
c0101903:	83 e2 f0             	and    $0xfffffff0,%edx
c0101906:	83 ca 0e             	or     $0xe,%edx
c0101909:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101913:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c010191a:	c0 
c010191b:	83 e2 ef             	and    $0xffffffef,%edx
c010191e:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101925:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101928:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c010192f:	c0 
c0101930:	83 e2 9f             	and    $0xffffff9f,%edx
c0101933:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c010193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193d:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101944:	c0 
c0101945:	83 ca 80             	or     $0xffffff80,%edx
c0101948:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c010194f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101952:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c0101959:	c1 e8 10             	shr    $0x10,%eax
c010195c:	89 c2                	mov    %eax,%edx
c010195e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101961:	66 89 14 c5 c6 80 11 	mov    %dx,-0x3fee7f3a(,%eax,8)
c0101968:	c0 
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101969:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101970:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101975:	0f 86 2f ff ff ff    	jbe    c01018aa <idt_init+0x12>
    }
	SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010197b:	a1 e4 77 11 c0       	mov    0xc01177e4,%eax
c0101980:	66 a3 88 84 11 c0    	mov    %ax,0xc0118488
c0101986:	66 c7 05 8a 84 11 c0 	movw   $0x8,0xc011848a
c010198d:	08 00 
c010198f:	0f b6 05 8c 84 11 c0 	movzbl 0xc011848c,%eax
c0101996:	83 e0 e0             	and    $0xffffffe0,%eax
c0101999:	a2 8c 84 11 c0       	mov    %al,0xc011848c
c010199e:	0f b6 05 8c 84 11 c0 	movzbl 0xc011848c,%eax
c01019a5:	83 e0 1f             	and    $0x1f,%eax
c01019a8:	a2 8c 84 11 c0       	mov    %al,0xc011848c
c01019ad:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019b4:	83 e0 f0             	and    $0xfffffff0,%eax
c01019b7:	83 c8 0e             	or     $0xe,%eax
c01019ba:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019bf:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019c6:	83 e0 ef             	and    $0xffffffef,%eax
c01019c9:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019ce:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019d5:	83 c8 60             	or     $0x60,%eax
c01019d8:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019dd:	0f b6 05 8d 84 11 c0 	movzbl 0xc011848d,%eax
c01019e4:	83 c8 80             	or     $0xffffff80,%eax
c01019e7:	a2 8d 84 11 c0       	mov    %al,0xc011848d
c01019ec:	a1 e4 77 11 c0       	mov    0xc01177e4,%eax
c01019f1:	c1 e8 10             	shr    $0x10,%eax
c01019f4:	66 a3 8e 84 11 c0    	mov    %ax,0xc011848e
c01019fa:	c7 45 f8 80 75 11 c0 	movl   $0xc0117580,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a01:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a04:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c0101a07:	c9                   	leave  
c0101a08:	c3                   	ret    

c0101a09 <trapname>:

static const char *
trapname(int trapno) {
c0101a09:	55                   	push   %ebp
c0101a0a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a0f:	83 f8 13             	cmp    $0x13,%eax
c0101a12:	77 0c                	ja     c0101a20 <trapname+0x17>
        return excnames[trapno];
c0101a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a17:	8b 04 85 60 64 10 c0 	mov    -0x3fef9ba0(,%eax,4),%eax
c0101a1e:	eb 18                	jmp    c0101a38 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a20:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a24:	7e 0d                	jle    c0101a33 <trapname+0x2a>
c0101a26:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a2a:	7f 07                	jg     c0101a33 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a2c:	b8 0a 61 10 c0       	mov    $0xc010610a,%eax
c0101a31:	eb 05                	jmp    c0101a38 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a33:	b8 1d 61 10 c0       	mov    $0xc010611d,%eax
}
c0101a38:	5d                   	pop    %ebp
c0101a39:	c3                   	ret    

c0101a3a <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a3a:	55                   	push   %ebp
c0101a3b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a40:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a44:	66 83 f8 08          	cmp    $0x8,%ax
c0101a48:	0f 94 c0             	sete   %al
c0101a4b:	0f b6 c0             	movzbl %al,%eax
}
c0101a4e:	5d                   	pop    %ebp
c0101a4f:	c3                   	ret    

c0101a50 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a50:	55                   	push   %ebp
c0101a51:	89 e5                	mov    %esp,%ebp
c0101a53:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5d:	c7 04 24 5e 61 10 c0 	movl   $0xc010615e,(%esp)
c0101a64:	e8 1d e8 ff ff       	call   c0100286 <cprintf>
    print_regs(&tf->tf_regs);
c0101a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6c:	89 04 24             	mov    %eax,(%esp)
c0101a6f:	e8 a1 01 00 00       	call   c0101c15 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a77:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a7b:	0f b7 c0             	movzwl %ax,%eax
c0101a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a82:	c7 04 24 6f 61 10 c0 	movl   $0xc010616f,(%esp)
c0101a89:	e8 f8 e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a91:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a95:	0f b7 c0             	movzwl %ax,%eax
c0101a98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9c:	c7 04 24 82 61 10 c0 	movl   $0xc0106182,(%esp)
c0101aa3:	e8 de e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aab:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101aaf:	0f b7 c0             	movzwl %ax,%eax
c0101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab6:	c7 04 24 95 61 10 c0 	movl   $0xc0106195,(%esp)
c0101abd:	e8 c4 e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac5:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ac9:	0f b7 c0             	movzwl %ax,%eax
c0101acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad0:	c7 04 24 a8 61 10 c0 	movl   $0xc01061a8,(%esp)
c0101ad7:	e8 aa e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101adc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101adf:	8b 40 30             	mov    0x30(%eax),%eax
c0101ae2:	89 04 24             	mov    %eax,(%esp)
c0101ae5:	e8 1f ff ff ff       	call   c0101a09 <trapname>
c0101aea:	8b 55 08             	mov    0x8(%ebp),%edx
c0101aed:	8b 52 30             	mov    0x30(%edx),%edx
c0101af0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101af4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101af8:	c7 04 24 bb 61 10 c0 	movl   $0xc01061bb,(%esp)
c0101aff:	e8 82 e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b07:	8b 40 34             	mov    0x34(%eax),%eax
c0101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0e:	c7 04 24 cd 61 10 c0 	movl   $0xc01061cd,(%esp)
c0101b15:	e8 6c e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1d:	8b 40 38             	mov    0x38(%eax),%eax
c0101b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b24:	c7 04 24 dc 61 10 c0 	movl   $0xc01061dc,(%esp)
c0101b2b:	e8 56 e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b33:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b37:	0f b7 c0             	movzwl %ax,%eax
c0101b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3e:	c7 04 24 eb 61 10 c0 	movl   $0xc01061eb,(%esp)
c0101b45:	e8 3c e7 ff ff       	call   c0100286 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4d:	8b 40 40             	mov    0x40(%eax),%eax
c0101b50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b54:	c7 04 24 fe 61 10 c0 	movl   $0xc01061fe,(%esp)
c0101b5b:	e8 26 e7 ff ff       	call   c0100286 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b6e:	eb 3e                	jmp    c0101bae <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b73:	8b 50 40             	mov    0x40(%eax),%edx
c0101b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b79:	21 d0                	and    %edx,%eax
c0101b7b:	85 c0                	test   %eax,%eax
c0101b7d:	74 28                	je     c0101ba7 <print_trapframe+0x157>
c0101b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b82:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101b89:	85 c0                	test   %eax,%eax
c0101b8b:	74 1a                	je     c0101ba7 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b90:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101b97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b9b:	c7 04 24 0d 62 10 c0 	movl   $0xc010620d,(%esp)
c0101ba2:	e8 df e6 ff ff       	call   c0100286 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ba7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bab:	d1 65 f0             	shll   -0x10(%ebp)
c0101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb1:	83 f8 17             	cmp    $0x17,%eax
c0101bb4:	76 ba                	jbe    c0101b70 <print_trapframe+0x120>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb9:	8b 40 40             	mov    0x40(%eax),%eax
c0101bbc:	25 00 30 00 00       	and    $0x3000,%eax
c0101bc1:	c1 e8 0c             	shr    $0xc,%eax
c0101bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc8:	c7 04 24 11 62 10 c0 	movl   $0xc0106211,(%esp)
c0101bcf:	e8 b2 e6 ff ff       	call   c0100286 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101bd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd7:	89 04 24             	mov    %eax,(%esp)
c0101bda:	e8 5b fe ff ff       	call   c0101a3a <trap_in_kernel>
c0101bdf:	85 c0                	test   %eax,%eax
c0101be1:	75 30                	jne    c0101c13 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101be3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be6:	8b 40 44             	mov    0x44(%eax),%eax
c0101be9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bed:	c7 04 24 1a 62 10 c0 	movl   $0xc010621a,(%esp)
c0101bf4:	e8 8d e6 ff ff       	call   c0100286 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bfc:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c00:	0f b7 c0             	movzwl %ax,%eax
c0101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c07:	c7 04 24 29 62 10 c0 	movl   $0xc0106229,(%esp)
c0101c0e:	e8 73 e6 ff ff       	call   c0100286 <cprintf>
    }
}
c0101c13:	c9                   	leave  
c0101c14:	c3                   	ret    

c0101c15 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c15:	55                   	push   %ebp
c0101c16:	89 e5                	mov    %esp,%ebp
c0101c18:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1e:	8b 00                	mov    (%eax),%eax
c0101c20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c24:	c7 04 24 3c 62 10 c0 	movl   $0xc010623c,(%esp)
c0101c2b:	e8 56 e6 ff ff       	call   c0100286 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c33:	8b 40 04             	mov    0x4(%eax),%eax
c0101c36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3a:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c0101c41:	e8 40 e6 ff ff       	call   c0100286 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c49:	8b 40 08             	mov    0x8(%eax),%eax
c0101c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c50:	c7 04 24 5a 62 10 c0 	movl   $0xc010625a,(%esp)
c0101c57:	e8 2a e6 ff ff       	call   c0100286 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5f:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c66:	c7 04 24 69 62 10 c0 	movl   $0xc0106269,(%esp)
c0101c6d:	e8 14 e6 ff ff       	call   c0100286 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c75:	8b 40 10             	mov    0x10(%eax),%eax
c0101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7c:	c7 04 24 78 62 10 c0 	movl   $0xc0106278,(%esp)
c0101c83:	e8 fe e5 ff ff       	call   c0100286 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8b:	8b 40 14             	mov    0x14(%eax),%eax
c0101c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c92:	c7 04 24 87 62 10 c0 	movl   $0xc0106287,(%esp)
c0101c99:	e8 e8 e5 ff ff       	call   c0100286 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca1:	8b 40 18             	mov    0x18(%eax),%eax
c0101ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca8:	c7 04 24 96 62 10 c0 	movl   $0xc0106296,(%esp)
c0101caf:	e8 d2 e5 ff ff       	call   c0100286 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb7:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101cba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cbe:	c7 04 24 a5 62 10 c0 	movl   $0xc01062a5,(%esp)
c0101cc5:	e8 bc e5 ff ff       	call   c0100286 <cprintf>
}
c0101cca:	c9                   	leave  
c0101ccb:	c3                   	ret    

c0101ccc <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101ccc:	55                   	push   %ebp
c0101ccd:	89 e5                	mov    %esp,%ebp
c0101ccf:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cd5:	8b 40 30             	mov    0x30(%eax),%eax
c0101cd8:	83 f8 2f             	cmp    $0x2f,%eax
c0101cdb:	77 21                	ja     c0101cfe <trap_dispatch+0x32>
c0101cdd:	83 f8 2e             	cmp    $0x2e,%eax
c0101ce0:	0f 83 04 01 00 00    	jae    c0101dea <trap_dispatch+0x11e>
c0101ce6:	83 f8 21             	cmp    $0x21,%eax
c0101ce9:	0f 84 81 00 00 00    	je     c0101d70 <trap_dispatch+0xa4>
c0101cef:	83 f8 24             	cmp    $0x24,%eax
c0101cf2:	74 56                	je     c0101d4a <trap_dispatch+0x7e>
c0101cf4:	83 f8 20             	cmp    $0x20,%eax
c0101cf7:	74 16                	je     c0101d0f <trap_dispatch+0x43>
c0101cf9:	e9 b4 00 00 00       	jmp    c0101db2 <trap_dispatch+0xe6>
c0101cfe:	83 e8 78             	sub    $0x78,%eax
c0101d01:	83 f8 01             	cmp    $0x1,%eax
c0101d04:	0f 87 a8 00 00 00    	ja     c0101db2 <trap_dispatch+0xe6>
c0101d0a:	e9 87 00 00 00       	jmp    c0101d96 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0101d0f:	a1 4c 89 11 c0       	mov    0xc011894c,%eax
c0101d14:	83 c0 01             	add    $0x1,%eax
c0101d17:	a3 4c 89 11 c0       	mov    %eax,0xc011894c
    	if (ticks % TICK_NUM == 0) {
c0101d1c:	8b 0d 4c 89 11 c0    	mov    0xc011894c,%ecx
c0101d22:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d27:	89 c8                	mov    %ecx,%eax
c0101d29:	f7 e2                	mul    %edx
c0101d2b:	89 d0                	mov    %edx,%eax
c0101d2d:	c1 e8 05             	shr    $0x5,%eax
c0101d30:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d33:	29 c1                	sub    %eax,%ecx
c0101d35:	89 c8                	mov    %ecx,%eax
c0101d37:	85 c0                	test   %eax,%eax
c0101d39:	75 0a                	jne    c0101d45 <trap_dispatch+0x79>
    		print_ticks();
c0101d3b:	e8 3c fb ff ff       	call   c010187c <print_ticks>
    	}
        break;
c0101d40:	e9 a6 00 00 00       	jmp    c0101deb <trap_dispatch+0x11f>
c0101d45:	e9 a1 00 00 00       	jmp    c0101deb <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d4a:	e8 f1 f8 ff ff       	call   c0101640 <cons_getc>
c0101d4f:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d52:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d56:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d5a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d62:	c7 04 24 b4 62 10 c0 	movl   $0xc01062b4,(%esp)
c0101d69:	e8 18 e5 ff ff       	call   c0100286 <cprintf>
        break;
c0101d6e:	eb 7b                	jmp    c0101deb <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d70:	e8 cb f8 ff ff       	call   c0101640 <cons_getc>
c0101d75:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d78:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d7c:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d80:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d88:	c7 04 24 c6 62 10 c0 	movl   $0xc01062c6,(%esp)
c0101d8f:	e8 f2 e4 ff ff       	call   c0100286 <cprintf>
        break;
c0101d94:	eb 55                	jmp    c0101deb <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d96:	c7 44 24 08 d5 62 10 	movl   $0xc01062d5,0x8(%esp)
c0101d9d:	c0 
c0101d9e:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0101da5:	00 
c0101da6:	c7 04 24 e5 62 10 c0 	movl   $0xc01062e5,(%esp)
c0101dad:	e8 2b e6 ff ff       	call   c01003dd <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101db2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101db9:	0f b7 c0             	movzwl %ax,%eax
c0101dbc:	83 e0 03             	and    $0x3,%eax
c0101dbf:	85 c0                	test   %eax,%eax
c0101dc1:	75 28                	jne    c0101deb <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc6:	89 04 24             	mov    %eax,(%esp)
c0101dc9:	e8 82 fc ff ff       	call   c0101a50 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101dce:	c7 44 24 08 f6 62 10 	movl   $0xc01062f6,0x8(%esp)
c0101dd5:	c0 
c0101dd6:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0101ddd:	00 
c0101dde:	c7 04 24 e5 62 10 c0 	movl   $0xc01062e5,(%esp)
c0101de5:	e8 f3 e5 ff ff       	call   c01003dd <__panic>
        break;
c0101dea:	90                   	nop
        }
    }
}
c0101deb:	c9                   	leave  
c0101dec:	c3                   	ret    

c0101ded <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101ded:	55                   	push   %ebp
c0101dee:	89 e5                	mov    %esp,%ebp
c0101df0:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101df3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df6:	89 04 24             	mov    %eax,(%esp)
c0101df9:	e8 ce fe ff ff       	call   c0101ccc <trap_dispatch>
}
c0101dfe:	c9                   	leave  
c0101dff:	c3                   	ret    

c0101e00 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e00:	6a 00                	push   $0x0
  pushl $0
c0101e02:	6a 00                	push   $0x0
  jmp __alltraps
c0101e04:	e9 67 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e09 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e09:	6a 00                	push   $0x0
  pushl $1
c0101e0b:	6a 01                	push   $0x1
  jmp __alltraps
c0101e0d:	e9 5e 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e12 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e12:	6a 00                	push   $0x0
  pushl $2
c0101e14:	6a 02                	push   $0x2
  jmp __alltraps
c0101e16:	e9 55 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e1b <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e1b:	6a 00                	push   $0x0
  pushl $3
c0101e1d:	6a 03                	push   $0x3
  jmp __alltraps
c0101e1f:	e9 4c 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e24 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e24:	6a 00                	push   $0x0
  pushl $4
c0101e26:	6a 04                	push   $0x4
  jmp __alltraps
c0101e28:	e9 43 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e2d <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e2d:	6a 00                	push   $0x0
  pushl $5
c0101e2f:	6a 05                	push   $0x5
  jmp __alltraps
c0101e31:	e9 3a 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e36 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e36:	6a 00                	push   $0x0
  pushl $6
c0101e38:	6a 06                	push   $0x6
  jmp __alltraps
c0101e3a:	e9 31 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e3f <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e3f:	6a 00                	push   $0x0
  pushl $7
c0101e41:	6a 07                	push   $0x7
  jmp __alltraps
c0101e43:	e9 28 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e48 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e48:	6a 08                	push   $0x8
  jmp __alltraps
c0101e4a:	e9 21 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e4f <vector9>:
.globl vector9
vector9:
  pushl $9
c0101e4f:	6a 09                	push   $0x9
  jmp __alltraps
c0101e51:	e9 1a 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e56 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e56:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e58:	e9 13 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e5d <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e5d:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e5f:	e9 0c 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e64 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e64:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e66:	e9 05 0a 00 00       	jmp    c0102870 <__alltraps>

c0101e6b <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e6b:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e6d:	e9 fe 09 00 00       	jmp    c0102870 <__alltraps>

c0101e72 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e72:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e74:	e9 f7 09 00 00       	jmp    c0102870 <__alltraps>

c0101e79 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e79:	6a 00                	push   $0x0
  pushl $15
c0101e7b:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e7d:	e9 ee 09 00 00       	jmp    c0102870 <__alltraps>

c0101e82 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e82:	6a 00                	push   $0x0
  pushl $16
c0101e84:	6a 10                	push   $0x10
  jmp __alltraps
c0101e86:	e9 e5 09 00 00       	jmp    c0102870 <__alltraps>

c0101e8b <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e8b:	6a 11                	push   $0x11
  jmp __alltraps
c0101e8d:	e9 de 09 00 00       	jmp    c0102870 <__alltraps>

c0101e92 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e92:	6a 00                	push   $0x0
  pushl $18
c0101e94:	6a 12                	push   $0x12
  jmp __alltraps
c0101e96:	e9 d5 09 00 00       	jmp    c0102870 <__alltraps>

c0101e9b <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e9b:	6a 00                	push   $0x0
  pushl $19
c0101e9d:	6a 13                	push   $0x13
  jmp __alltraps
c0101e9f:	e9 cc 09 00 00       	jmp    c0102870 <__alltraps>

c0101ea4 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101ea4:	6a 00                	push   $0x0
  pushl $20
c0101ea6:	6a 14                	push   $0x14
  jmp __alltraps
c0101ea8:	e9 c3 09 00 00       	jmp    c0102870 <__alltraps>

c0101ead <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ead:	6a 00                	push   $0x0
  pushl $21
c0101eaf:	6a 15                	push   $0x15
  jmp __alltraps
c0101eb1:	e9 ba 09 00 00       	jmp    c0102870 <__alltraps>

c0101eb6 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101eb6:	6a 00                	push   $0x0
  pushl $22
c0101eb8:	6a 16                	push   $0x16
  jmp __alltraps
c0101eba:	e9 b1 09 00 00       	jmp    c0102870 <__alltraps>

c0101ebf <vector23>:
.globl vector23
vector23:
  pushl $0
c0101ebf:	6a 00                	push   $0x0
  pushl $23
c0101ec1:	6a 17                	push   $0x17
  jmp __alltraps
c0101ec3:	e9 a8 09 00 00       	jmp    c0102870 <__alltraps>

c0101ec8 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101ec8:	6a 00                	push   $0x0
  pushl $24
c0101eca:	6a 18                	push   $0x18
  jmp __alltraps
c0101ecc:	e9 9f 09 00 00       	jmp    c0102870 <__alltraps>

c0101ed1 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101ed1:	6a 00                	push   $0x0
  pushl $25
c0101ed3:	6a 19                	push   $0x19
  jmp __alltraps
c0101ed5:	e9 96 09 00 00       	jmp    c0102870 <__alltraps>

c0101eda <vector26>:
.globl vector26
vector26:
  pushl $0
c0101eda:	6a 00                	push   $0x0
  pushl $26
c0101edc:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101ede:	e9 8d 09 00 00       	jmp    c0102870 <__alltraps>

c0101ee3 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101ee3:	6a 00                	push   $0x0
  pushl $27
c0101ee5:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ee7:	e9 84 09 00 00       	jmp    c0102870 <__alltraps>

c0101eec <vector28>:
.globl vector28
vector28:
  pushl $0
c0101eec:	6a 00                	push   $0x0
  pushl $28
c0101eee:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ef0:	e9 7b 09 00 00       	jmp    c0102870 <__alltraps>

c0101ef5 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101ef5:	6a 00                	push   $0x0
  pushl $29
c0101ef7:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101ef9:	e9 72 09 00 00       	jmp    c0102870 <__alltraps>

c0101efe <vector30>:
.globl vector30
vector30:
  pushl $0
c0101efe:	6a 00                	push   $0x0
  pushl $30
c0101f00:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f02:	e9 69 09 00 00       	jmp    c0102870 <__alltraps>

c0101f07 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f07:	6a 00                	push   $0x0
  pushl $31
c0101f09:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f0b:	e9 60 09 00 00       	jmp    c0102870 <__alltraps>

c0101f10 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f10:	6a 00                	push   $0x0
  pushl $32
c0101f12:	6a 20                	push   $0x20
  jmp __alltraps
c0101f14:	e9 57 09 00 00       	jmp    c0102870 <__alltraps>

c0101f19 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f19:	6a 00                	push   $0x0
  pushl $33
c0101f1b:	6a 21                	push   $0x21
  jmp __alltraps
c0101f1d:	e9 4e 09 00 00       	jmp    c0102870 <__alltraps>

c0101f22 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f22:	6a 00                	push   $0x0
  pushl $34
c0101f24:	6a 22                	push   $0x22
  jmp __alltraps
c0101f26:	e9 45 09 00 00       	jmp    c0102870 <__alltraps>

c0101f2b <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f2b:	6a 00                	push   $0x0
  pushl $35
c0101f2d:	6a 23                	push   $0x23
  jmp __alltraps
c0101f2f:	e9 3c 09 00 00       	jmp    c0102870 <__alltraps>

c0101f34 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f34:	6a 00                	push   $0x0
  pushl $36
c0101f36:	6a 24                	push   $0x24
  jmp __alltraps
c0101f38:	e9 33 09 00 00       	jmp    c0102870 <__alltraps>

c0101f3d <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f3d:	6a 00                	push   $0x0
  pushl $37
c0101f3f:	6a 25                	push   $0x25
  jmp __alltraps
c0101f41:	e9 2a 09 00 00       	jmp    c0102870 <__alltraps>

c0101f46 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f46:	6a 00                	push   $0x0
  pushl $38
c0101f48:	6a 26                	push   $0x26
  jmp __alltraps
c0101f4a:	e9 21 09 00 00       	jmp    c0102870 <__alltraps>

c0101f4f <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f4f:	6a 00                	push   $0x0
  pushl $39
c0101f51:	6a 27                	push   $0x27
  jmp __alltraps
c0101f53:	e9 18 09 00 00       	jmp    c0102870 <__alltraps>

c0101f58 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f58:	6a 00                	push   $0x0
  pushl $40
c0101f5a:	6a 28                	push   $0x28
  jmp __alltraps
c0101f5c:	e9 0f 09 00 00       	jmp    c0102870 <__alltraps>

c0101f61 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f61:	6a 00                	push   $0x0
  pushl $41
c0101f63:	6a 29                	push   $0x29
  jmp __alltraps
c0101f65:	e9 06 09 00 00       	jmp    c0102870 <__alltraps>

c0101f6a <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f6a:	6a 00                	push   $0x0
  pushl $42
c0101f6c:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f6e:	e9 fd 08 00 00       	jmp    c0102870 <__alltraps>

c0101f73 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f73:	6a 00                	push   $0x0
  pushl $43
c0101f75:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f77:	e9 f4 08 00 00       	jmp    c0102870 <__alltraps>

c0101f7c <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f7c:	6a 00                	push   $0x0
  pushl $44
c0101f7e:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f80:	e9 eb 08 00 00       	jmp    c0102870 <__alltraps>

c0101f85 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f85:	6a 00                	push   $0x0
  pushl $45
c0101f87:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f89:	e9 e2 08 00 00       	jmp    c0102870 <__alltraps>

c0101f8e <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f8e:	6a 00                	push   $0x0
  pushl $46
c0101f90:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f92:	e9 d9 08 00 00       	jmp    c0102870 <__alltraps>

c0101f97 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f97:	6a 00                	push   $0x0
  pushl $47
c0101f99:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f9b:	e9 d0 08 00 00       	jmp    c0102870 <__alltraps>

c0101fa0 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fa0:	6a 00                	push   $0x0
  pushl $48
c0101fa2:	6a 30                	push   $0x30
  jmp __alltraps
c0101fa4:	e9 c7 08 00 00       	jmp    c0102870 <__alltraps>

c0101fa9 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101fa9:	6a 00                	push   $0x0
  pushl $49
c0101fab:	6a 31                	push   $0x31
  jmp __alltraps
c0101fad:	e9 be 08 00 00       	jmp    c0102870 <__alltraps>

c0101fb2 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fb2:	6a 00                	push   $0x0
  pushl $50
c0101fb4:	6a 32                	push   $0x32
  jmp __alltraps
c0101fb6:	e9 b5 08 00 00       	jmp    c0102870 <__alltraps>

c0101fbb <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fbb:	6a 00                	push   $0x0
  pushl $51
c0101fbd:	6a 33                	push   $0x33
  jmp __alltraps
c0101fbf:	e9 ac 08 00 00       	jmp    c0102870 <__alltraps>

c0101fc4 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fc4:	6a 00                	push   $0x0
  pushl $52
c0101fc6:	6a 34                	push   $0x34
  jmp __alltraps
c0101fc8:	e9 a3 08 00 00       	jmp    c0102870 <__alltraps>

c0101fcd <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fcd:	6a 00                	push   $0x0
  pushl $53
c0101fcf:	6a 35                	push   $0x35
  jmp __alltraps
c0101fd1:	e9 9a 08 00 00       	jmp    c0102870 <__alltraps>

c0101fd6 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101fd6:	6a 00                	push   $0x0
  pushl $54
c0101fd8:	6a 36                	push   $0x36
  jmp __alltraps
c0101fda:	e9 91 08 00 00       	jmp    c0102870 <__alltraps>

c0101fdf <vector55>:
.globl vector55
vector55:
  pushl $0
c0101fdf:	6a 00                	push   $0x0
  pushl $55
c0101fe1:	6a 37                	push   $0x37
  jmp __alltraps
c0101fe3:	e9 88 08 00 00       	jmp    c0102870 <__alltraps>

c0101fe8 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101fe8:	6a 00                	push   $0x0
  pushl $56
c0101fea:	6a 38                	push   $0x38
  jmp __alltraps
c0101fec:	e9 7f 08 00 00       	jmp    c0102870 <__alltraps>

c0101ff1 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101ff1:	6a 00                	push   $0x0
  pushl $57
c0101ff3:	6a 39                	push   $0x39
  jmp __alltraps
c0101ff5:	e9 76 08 00 00       	jmp    c0102870 <__alltraps>

c0101ffa <vector58>:
.globl vector58
vector58:
  pushl $0
c0101ffa:	6a 00                	push   $0x0
  pushl $58
c0101ffc:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101ffe:	e9 6d 08 00 00       	jmp    c0102870 <__alltraps>

c0102003 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102003:	6a 00                	push   $0x0
  pushl $59
c0102005:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102007:	e9 64 08 00 00       	jmp    c0102870 <__alltraps>

c010200c <vector60>:
.globl vector60
vector60:
  pushl $0
c010200c:	6a 00                	push   $0x0
  pushl $60
c010200e:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102010:	e9 5b 08 00 00       	jmp    c0102870 <__alltraps>

c0102015 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102015:	6a 00                	push   $0x0
  pushl $61
c0102017:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102019:	e9 52 08 00 00       	jmp    c0102870 <__alltraps>

c010201e <vector62>:
.globl vector62
vector62:
  pushl $0
c010201e:	6a 00                	push   $0x0
  pushl $62
c0102020:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102022:	e9 49 08 00 00       	jmp    c0102870 <__alltraps>

c0102027 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102027:	6a 00                	push   $0x0
  pushl $63
c0102029:	6a 3f                	push   $0x3f
  jmp __alltraps
c010202b:	e9 40 08 00 00       	jmp    c0102870 <__alltraps>

c0102030 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102030:	6a 00                	push   $0x0
  pushl $64
c0102032:	6a 40                	push   $0x40
  jmp __alltraps
c0102034:	e9 37 08 00 00       	jmp    c0102870 <__alltraps>

c0102039 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102039:	6a 00                	push   $0x0
  pushl $65
c010203b:	6a 41                	push   $0x41
  jmp __alltraps
c010203d:	e9 2e 08 00 00       	jmp    c0102870 <__alltraps>

c0102042 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102042:	6a 00                	push   $0x0
  pushl $66
c0102044:	6a 42                	push   $0x42
  jmp __alltraps
c0102046:	e9 25 08 00 00       	jmp    c0102870 <__alltraps>

c010204b <vector67>:
.globl vector67
vector67:
  pushl $0
c010204b:	6a 00                	push   $0x0
  pushl $67
c010204d:	6a 43                	push   $0x43
  jmp __alltraps
c010204f:	e9 1c 08 00 00       	jmp    c0102870 <__alltraps>

c0102054 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102054:	6a 00                	push   $0x0
  pushl $68
c0102056:	6a 44                	push   $0x44
  jmp __alltraps
c0102058:	e9 13 08 00 00       	jmp    c0102870 <__alltraps>

c010205d <vector69>:
.globl vector69
vector69:
  pushl $0
c010205d:	6a 00                	push   $0x0
  pushl $69
c010205f:	6a 45                	push   $0x45
  jmp __alltraps
c0102061:	e9 0a 08 00 00       	jmp    c0102870 <__alltraps>

c0102066 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102066:	6a 00                	push   $0x0
  pushl $70
c0102068:	6a 46                	push   $0x46
  jmp __alltraps
c010206a:	e9 01 08 00 00       	jmp    c0102870 <__alltraps>

c010206f <vector71>:
.globl vector71
vector71:
  pushl $0
c010206f:	6a 00                	push   $0x0
  pushl $71
c0102071:	6a 47                	push   $0x47
  jmp __alltraps
c0102073:	e9 f8 07 00 00       	jmp    c0102870 <__alltraps>

c0102078 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102078:	6a 00                	push   $0x0
  pushl $72
c010207a:	6a 48                	push   $0x48
  jmp __alltraps
c010207c:	e9 ef 07 00 00       	jmp    c0102870 <__alltraps>

c0102081 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102081:	6a 00                	push   $0x0
  pushl $73
c0102083:	6a 49                	push   $0x49
  jmp __alltraps
c0102085:	e9 e6 07 00 00       	jmp    c0102870 <__alltraps>

c010208a <vector74>:
.globl vector74
vector74:
  pushl $0
c010208a:	6a 00                	push   $0x0
  pushl $74
c010208c:	6a 4a                	push   $0x4a
  jmp __alltraps
c010208e:	e9 dd 07 00 00       	jmp    c0102870 <__alltraps>

c0102093 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102093:	6a 00                	push   $0x0
  pushl $75
c0102095:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102097:	e9 d4 07 00 00       	jmp    c0102870 <__alltraps>

c010209c <vector76>:
.globl vector76
vector76:
  pushl $0
c010209c:	6a 00                	push   $0x0
  pushl $76
c010209e:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020a0:	e9 cb 07 00 00       	jmp    c0102870 <__alltraps>

c01020a5 <vector77>:
.globl vector77
vector77:
  pushl $0
c01020a5:	6a 00                	push   $0x0
  pushl $77
c01020a7:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020a9:	e9 c2 07 00 00       	jmp    c0102870 <__alltraps>

c01020ae <vector78>:
.globl vector78
vector78:
  pushl $0
c01020ae:	6a 00                	push   $0x0
  pushl $78
c01020b0:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020b2:	e9 b9 07 00 00       	jmp    c0102870 <__alltraps>

c01020b7 <vector79>:
.globl vector79
vector79:
  pushl $0
c01020b7:	6a 00                	push   $0x0
  pushl $79
c01020b9:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020bb:	e9 b0 07 00 00       	jmp    c0102870 <__alltraps>

c01020c0 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020c0:	6a 00                	push   $0x0
  pushl $80
c01020c2:	6a 50                	push   $0x50
  jmp __alltraps
c01020c4:	e9 a7 07 00 00       	jmp    c0102870 <__alltraps>

c01020c9 <vector81>:
.globl vector81
vector81:
  pushl $0
c01020c9:	6a 00                	push   $0x0
  pushl $81
c01020cb:	6a 51                	push   $0x51
  jmp __alltraps
c01020cd:	e9 9e 07 00 00       	jmp    c0102870 <__alltraps>

c01020d2 <vector82>:
.globl vector82
vector82:
  pushl $0
c01020d2:	6a 00                	push   $0x0
  pushl $82
c01020d4:	6a 52                	push   $0x52
  jmp __alltraps
c01020d6:	e9 95 07 00 00       	jmp    c0102870 <__alltraps>

c01020db <vector83>:
.globl vector83
vector83:
  pushl $0
c01020db:	6a 00                	push   $0x0
  pushl $83
c01020dd:	6a 53                	push   $0x53
  jmp __alltraps
c01020df:	e9 8c 07 00 00       	jmp    c0102870 <__alltraps>

c01020e4 <vector84>:
.globl vector84
vector84:
  pushl $0
c01020e4:	6a 00                	push   $0x0
  pushl $84
c01020e6:	6a 54                	push   $0x54
  jmp __alltraps
c01020e8:	e9 83 07 00 00       	jmp    c0102870 <__alltraps>

c01020ed <vector85>:
.globl vector85
vector85:
  pushl $0
c01020ed:	6a 00                	push   $0x0
  pushl $85
c01020ef:	6a 55                	push   $0x55
  jmp __alltraps
c01020f1:	e9 7a 07 00 00       	jmp    c0102870 <__alltraps>

c01020f6 <vector86>:
.globl vector86
vector86:
  pushl $0
c01020f6:	6a 00                	push   $0x0
  pushl $86
c01020f8:	6a 56                	push   $0x56
  jmp __alltraps
c01020fa:	e9 71 07 00 00       	jmp    c0102870 <__alltraps>

c01020ff <vector87>:
.globl vector87
vector87:
  pushl $0
c01020ff:	6a 00                	push   $0x0
  pushl $87
c0102101:	6a 57                	push   $0x57
  jmp __alltraps
c0102103:	e9 68 07 00 00       	jmp    c0102870 <__alltraps>

c0102108 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102108:	6a 00                	push   $0x0
  pushl $88
c010210a:	6a 58                	push   $0x58
  jmp __alltraps
c010210c:	e9 5f 07 00 00       	jmp    c0102870 <__alltraps>

c0102111 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102111:	6a 00                	push   $0x0
  pushl $89
c0102113:	6a 59                	push   $0x59
  jmp __alltraps
c0102115:	e9 56 07 00 00       	jmp    c0102870 <__alltraps>

c010211a <vector90>:
.globl vector90
vector90:
  pushl $0
c010211a:	6a 00                	push   $0x0
  pushl $90
c010211c:	6a 5a                	push   $0x5a
  jmp __alltraps
c010211e:	e9 4d 07 00 00       	jmp    c0102870 <__alltraps>

c0102123 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102123:	6a 00                	push   $0x0
  pushl $91
c0102125:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102127:	e9 44 07 00 00       	jmp    c0102870 <__alltraps>

c010212c <vector92>:
.globl vector92
vector92:
  pushl $0
c010212c:	6a 00                	push   $0x0
  pushl $92
c010212e:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102130:	e9 3b 07 00 00       	jmp    c0102870 <__alltraps>

c0102135 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102135:	6a 00                	push   $0x0
  pushl $93
c0102137:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102139:	e9 32 07 00 00       	jmp    c0102870 <__alltraps>

c010213e <vector94>:
.globl vector94
vector94:
  pushl $0
c010213e:	6a 00                	push   $0x0
  pushl $94
c0102140:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102142:	e9 29 07 00 00       	jmp    c0102870 <__alltraps>

c0102147 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102147:	6a 00                	push   $0x0
  pushl $95
c0102149:	6a 5f                	push   $0x5f
  jmp __alltraps
c010214b:	e9 20 07 00 00       	jmp    c0102870 <__alltraps>

c0102150 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102150:	6a 00                	push   $0x0
  pushl $96
c0102152:	6a 60                	push   $0x60
  jmp __alltraps
c0102154:	e9 17 07 00 00       	jmp    c0102870 <__alltraps>

c0102159 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102159:	6a 00                	push   $0x0
  pushl $97
c010215b:	6a 61                	push   $0x61
  jmp __alltraps
c010215d:	e9 0e 07 00 00       	jmp    c0102870 <__alltraps>

c0102162 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102162:	6a 00                	push   $0x0
  pushl $98
c0102164:	6a 62                	push   $0x62
  jmp __alltraps
c0102166:	e9 05 07 00 00       	jmp    c0102870 <__alltraps>

c010216b <vector99>:
.globl vector99
vector99:
  pushl $0
c010216b:	6a 00                	push   $0x0
  pushl $99
c010216d:	6a 63                	push   $0x63
  jmp __alltraps
c010216f:	e9 fc 06 00 00       	jmp    c0102870 <__alltraps>

c0102174 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102174:	6a 00                	push   $0x0
  pushl $100
c0102176:	6a 64                	push   $0x64
  jmp __alltraps
c0102178:	e9 f3 06 00 00       	jmp    c0102870 <__alltraps>

c010217d <vector101>:
.globl vector101
vector101:
  pushl $0
c010217d:	6a 00                	push   $0x0
  pushl $101
c010217f:	6a 65                	push   $0x65
  jmp __alltraps
c0102181:	e9 ea 06 00 00       	jmp    c0102870 <__alltraps>

c0102186 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102186:	6a 00                	push   $0x0
  pushl $102
c0102188:	6a 66                	push   $0x66
  jmp __alltraps
c010218a:	e9 e1 06 00 00       	jmp    c0102870 <__alltraps>

c010218f <vector103>:
.globl vector103
vector103:
  pushl $0
c010218f:	6a 00                	push   $0x0
  pushl $103
c0102191:	6a 67                	push   $0x67
  jmp __alltraps
c0102193:	e9 d8 06 00 00       	jmp    c0102870 <__alltraps>

c0102198 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102198:	6a 00                	push   $0x0
  pushl $104
c010219a:	6a 68                	push   $0x68
  jmp __alltraps
c010219c:	e9 cf 06 00 00       	jmp    c0102870 <__alltraps>

c01021a1 <vector105>:
.globl vector105
vector105:
  pushl $0
c01021a1:	6a 00                	push   $0x0
  pushl $105
c01021a3:	6a 69                	push   $0x69
  jmp __alltraps
c01021a5:	e9 c6 06 00 00       	jmp    c0102870 <__alltraps>

c01021aa <vector106>:
.globl vector106
vector106:
  pushl $0
c01021aa:	6a 00                	push   $0x0
  pushl $106
c01021ac:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021ae:	e9 bd 06 00 00       	jmp    c0102870 <__alltraps>

c01021b3 <vector107>:
.globl vector107
vector107:
  pushl $0
c01021b3:	6a 00                	push   $0x0
  pushl $107
c01021b5:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021b7:	e9 b4 06 00 00       	jmp    c0102870 <__alltraps>

c01021bc <vector108>:
.globl vector108
vector108:
  pushl $0
c01021bc:	6a 00                	push   $0x0
  pushl $108
c01021be:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021c0:	e9 ab 06 00 00       	jmp    c0102870 <__alltraps>

c01021c5 <vector109>:
.globl vector109
vector109:
  pushl $0
c01021c5:	6a 00                	push   $0x0
  pushl $109
c01021c7:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021c9:	e9 a2 06 00 00       	jmp    c0102870 <__alltraps>

c01021ce <vector110>:
.globl vector110
vector110:
  pushl $0
c01021ce:	6a 00                	push   $0x0
  pushl $110
c01021d0:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021d2:	e9 99 06 00 00       	jmp    c0102870 <__alltraps>

c01021d7 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021d7:	6a 00                	push   $0x0
  pushl $111
c01021d9:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021db:	e9 90 06 00 00       	jmp    c0102870 <__alltraps>

c01021e0 <vector112>:
.globl vector112
vector112:
  pushl $0
c01021e0:	6a 00                	push   $0x0
  pushl $112
c01021e2:	6a 70                	push   $0x70
  jmp __alltraps
c01021e4:	e9 87 06 00 00       	jmp    c0102870 <__alltraps>

c01021e9 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021e9:	6a 00                	push   $0x0
  pushl $113
c01021eb:	6a 71                	push   $0x71
  jmp __alltraps
c01021ed:	e9 7e 06 00 00       	jmp    c0102870 <__alltraps>

c01021f2 <vector114>:
.globl vector114
vector114:
  pushl $0
c01021f2:	6a 00                	push   $0x0
  pushl $114
c01021f4:	6a 72                	push   $0x72
  jmp __alltraps
c01021f6:	e9 75 06 00 00       	jmp    c0102870 <__alltraps>

c01021fb <vector115>:
.globl vector115
vector115:
  pushl $0
c01021fb:	6a 00                	push   $0x0
  pushl $115
c01021fd:	6a 73                	push   $0x73
  jmp __alltraps
c01021ff:	e9 6c 06 00 00       	jmp    c0102870 <__alltraps>

c0102204 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102204:	6a 00                	push   $0x0
  pushl $116
c0102206:	6a 74                	push   $0x74
  jmp __alltraps
c0102208:	e9 63 06 00 00       	jmp    c0102870 <__alltraps>

c010220d <vector117>:
.globl vector117
vector117:
  pushl $0
c010220d:	6a 00                	push   $0x0
  pushl $117
c010220f:	6a 75                	push   $0x75
  jmp __alltraps
c0102211:	e9 5a 06 00 00       	jmp    c0102870 <__alltraps>

c0102216 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102216:	6a 00                	push   $0x0
  pushl $118
c0102218:	6a 76                	push   $0x76
  jmp __alltraps
c010221a:	e9 51 06 00 00       	jmp    c0102870 <__alltraps>

c010221f <vector119>:
.globl vector119
vector119:
  pushl $0
c010221f:	6a 00                	push   $0x0
  pushl $119
c0102221:	6a 77                	push   $0x77
  jmp __alltraps
c0102223:	e9 48 06 00 00       	jmp    c0102870 <__alltraps>

c0102228 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102228:	6a 00                	push   $0x0
  pushl $120
c010222a:	6a 78                	push   $0x78
  jmp __alltraps
c010222c:	e9 3f 06 00 00       	jmp    c0102870 <__alltraps>

c0102231 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102231:	6a 00                	push   $0x0
  pushl $121
c0102233:	6a 79                	push   $0x79
  jmp __alltraps
c0102235:	e9 36 06 00 00       	jmp    c0102870 <__alltraps>

c010223a <vector122>:
.globl vector122
vector122:
  pushl $0
c010223a:	6a 00                	push   $0x0
  pushl $122
c010223c:	6a 7a                	push   $0x7a
  jmp __alltraps
c010223e:	e9 2d 06 00 00       	jmp    c0102870 <__alltraps>

c0102243 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102243:	6a 00                	push   $0x0
  pushl $123
c0102245:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102247:	e9 24 06 00 00       	jmp    c0102870 <__alltraps>

c010224c <vector124>:
.globl vector124
vector124:
  pushl $0
c010224c:	6a 00                	push   $0x0
  pushl $124
c010224e:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102250:	e9 1b 06 00 00       	jmp    c0102870 <__alltraps>

c0102255 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102255:	6a 00                	push   $0x0
  pushl $125
c0102257:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102259:	e9 12 06 00 00       	jmp    c0102870 <__alltraps>

c010225e <vector126>:
.globl vector126
vector126:
  pushl $0
c010225e:	6a 00                	push   $0x0
  pushl $126
c0102260:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102262:	e9 09 06 00 00       	jmp    c0102870 <__alltraps>

c0102267 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102267:	6a 00                	push   $0x0
  pushl $127
c0102269:	6a 7f                	push   $0x7f
  jmp __alltraps
c010226b:	e9 00 06 00 00       	jmp    c0102870 <__alltraps>

c0102270 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102270:	6a 00                	push   $0x0
  pushl $128
c0102272:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102277:	e9 f4 05 00 00       	jmp    c0102870 <__alltraps>

c010227c <vector129>:
.globl vector129
vector129:
  pushl $0
c010227c:	6a 00                	push   $0x0
  pushl $129
c010227e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102283:	e9 e8 05 00 00       	jmp    c0102870 <__alltraps>

c0102288 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102288:	6a 00                	push   $0x0
  pushl $130
c010228a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010228f:	e9 dc 05 00 00       	jmp    c0102870 <__alltraps>

c0102294 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102294:	6a 00                	push   $0x0
  pushl $131
c0102296:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010229b:	e9 d0 05 00 00       	jmp    c0102870 <__alltraps>

c01022a0 <vector132>:
.globl vector132
vector132:
  pushl $0
c01022a0:	6a 00                	push   $0x0
  pushl $132
c01022a2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022a7:	e9 c4 05 00 00       	jmp    c0102870 <__alltraps>

c01022ac <vector133>:
.globl vector133
vector133:
  pushl $0
c01022ac:	6a 00                	push   $0x0
  pushl $133
c01022ae:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022b3:	e9 b8 05 00 00       	jmp    c0102870 <__alltraps>

c01022b8 <vector134>:
.globl vector134
vector134:
  pushl $0
c01022b8:	6a 00                	push   $0x0
  pushl $134
c01022ba:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022bf:	e9 ac 05 00 00       	jmp    c0102870 <__alltraps>

c01022c4 <vector135>:
.globl vector135
vector135:
  pushl $0
c01022c4:	6a 00                	push   $0x0
  pushl $135
c01022c6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022cb:	e9 a0 05 00 00       	jmp    c0102870 <__alltraps>

c01022d0 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022d0:	6a 00                	push   $0x0
  pushl $136
c01022d2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022d7:	e9 94 05 00 00       	jmp    c0102870 <__alltraps>

c01022dc <vector137>:
.globl vector137
vector137:
  pushl $0
c01022dc:	6a 00                	push   $0x0
  pushl $137
c01022de:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022e3:	e9 88 05 00 00       	jmp    c0102870 <__alltraps>

c01022e8 <vector138>:
.globl vector138
vector138:
  pushl $0
c01022e8:	6a 00                	push   $0x0
  pushl $138
c01022ea:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022ef:	e9 7c 05 00 00       	jmp    c0102870 <__alltraps>

c01022f4 <vector139>:
.globl vector139
vector139:
  pushl $0
c01022f4:	6a 00                	push   $0x0
  pushl $139
c01022f6:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022fb:	e9 70 05 00 00       	jmp    c0102870 <__alltraps>

c0102300 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102300:	6a 00                	push   $0x0
  pushl $140
c0102302:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102307:	e9 64 05 00 00       	jmp    c0102870 <__alltraps>

c010230c <vector141>:
.globl vector141
vector141:
  pushl $0
c010230c:	6a 00                	push   $0x0
  pushl $141
c010230e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102313:	e9 58 05 00 00       	jmp    c0102870 <__alltraps>

c0102318 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102318:	6a 00                	push   $0x0
  pushl $142
c010231a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010231f:	e9 4c 05 00 00       	jmp    c0102870 <__alltraps>

c0102324 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102324:	6a 00                	push   $0x0
  pushl $143
c0102326:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010232b:	e9 40 05 00 00       	jmp    c0102870 <__alltraps>

c0102330 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102330:	6a 00                	push   $0x0
  pushl $144
c0102332:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102337:	e9 34 05 00 00       	jmp    c0102870 <__alltraps>

c010233c <vector145>:
.globl vector145
vector145:
  pushl $0
c010233c:	6a 00                	push   $0x0
  pushl $145
c010233e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102343:	e9 28 05 00 00       	jmp    c0102870 <__alltraps>

c0102348 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102348:	6a 00                	push   $0x0
  pushl $146
c010234a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010234f:	e9 1c 05 00 00       	jmp    c0102870 <__alltraps>

c0102354 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102354:	6a 00                	push   $0x0
  pushl $147
c0102356:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010235b:	e9 10 05 00 00       	jmp    c0102870 <__alltraps>

c0102360 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102360:	6a 00                	push   $0x0
  pushl $148
c0102362:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102367:	e9 04 05 00 00       	jmp    c0102870 <__alltraps>

c010236c <vector149>:
.globl vector149
vector149:
  pushl $0
c010236c:	6a 00                	push   $0x0
  pushl $149
c010236e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102373:	e9 f8 04 00 00       	jmp    c0102870 <__alltraps>

c0102378 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102378:	6a 00                	push   $0x0
  pushl $150
c010237a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010237f:	e9 ec 04 00 00       	jmp    c0102870 <__alltraps>

c0102384 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102384:	6a 00                	push   $0x0
  pushl $151
c0102386:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010238b:	e9 e0 04 00 00       	jmp    c0102870 <__alltraps>

c0102390 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102390:	6a 00                	push   $0x0
  pushl $152
c0102392:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102397:	e9 d4 04 00 00       	jmp    c0102870 <__alltraps>

c010239c <vector153>:
.globl vector153
vector153:
  pushl $0
c010239c:	6a 00                	push   $0x0
  pushl $153
c010239e:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023a3:	e9 c8 04 00 00       	jmp    c0102870 <__alltraps>

c01023a8 <vector154>:
.globl vector154
vector154:
  pushl $0
c01023a8:	6a 00                	push   $0x0
  pushl $154
c01023aa:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023af:	e9 bc 04 00 00       	jmp    c0102870 <__alltraps>

c01023b4 <vector155>:
.globl vector155
vector155:
  pushl $0
c01023b4:	6a 00                	push   $0x0
  pushl $155
c01023b6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023bb:	e9 b0 04 00 00       	jmp    c0102870 <__alltraps>

c01023c0 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023c0:	6a 00                	push   $0x0
  pushl $156
c01023c2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023c7:	e9 a4 04 00 00       	jmp    c0102870 <__alltraps>

c01023cc <vector157>:
.globl vector157
vector157:
  pushl $0
c01023cc:	6a 00                	push   $0x0
  pushl $157
c01023ce:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023d3:	e9 98 04 00 00       	jmp    c0102870 <__alltraps>

c01023d8 <vector158>:
.globl vector158
vector158:
  pushl $0
c01023d8:	6a 00                	push   $0x0
  pushl $158
c01023da:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01023df:	e9 8c 04 00 00       	jmp    c0102870 <__alltraps>

c01023e4 <vector159>:
.globl vector159
vector159:
  pushl $0
c01023e4:	6a 00                	push   $0x0
  pushl $159
c01023e6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023eb:	e9 80 04 00 00       	jmp    c0102870 <__alltraps>

c01023f0 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023f0:	6a 00                	push   $0x0
  pushl $160
c01023f2:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023f7:	e9 74 04 00 00       	jmp    c0102870 <__alltraps>

c01023fc <vector161>:
.globl vector161
vector161:
  pushl $0
c01023fc:	6a 00                	push   $0x0
  pushl $161
c01023fe:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102403:	e9 68 04 00 00       	jmp    c0102870 <__alltraps>

c0102408 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102408:	6a 00                	push   $0x0
  pushl $162
c010240a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010240f:	e9 5c 04 00 00       	jmp    c0102870 <__alltraps>

c0102414 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102414:	6a 00                	push   $0x0
  pushl $163
c0102416:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010241b:	e9 50 04 00 00       	jmp    c0102870 <__alltraps>

c0102420 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102420:	6a 00                	push   $0x0
  pushl $164
c0102422:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102427:	e9 44 04 00 00       	jmp    c0102870 <__alltraps>

c010242c <vector165>:
.globl vector165
vector165:
  pushl $0
c010242c:	6a 00                	push   $0x0
  pushl $165
c010242e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102433:	e9 38 04 00 00       	jmp    c0102870 <__alltraps>

c0102438 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102438:	6a 00                	push   $0x0
  pushl $166
c010243a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010243f:	e9 2c 04 00 00       	jmp    c0102870 <__alltraps>

c0102444 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102444:	6a 00                	push   $0x0
  pushl $167
c0102446:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010244b:	e9 20 04 00 00       	jmp    c0102870 <__alltraps>

c0102450 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102450:	6a 00                	push   $0x0
  pushl $168
c0102452:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102457:	e9 14 04 00 00       	jmp    c0102870 <__alltraps>

c010245c <vector169>:
.globl vector169
vector169:
  pushl $0
c010245c:	6a 00                	push   $0x0
  pushl $169
c010245e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102463:	e9 08 04 00 00       	jmp    c0102870 <__alltraps>

c0102468 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102468:	6a 00                	push   $0x0
  pushl $170
c010246a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010246f:	e9 fc 03 00 00       	jmp    c0102870 <__alltraps>

c0102474 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102474:	6a 00                	push   $0x0
  pushl $171
c0102476:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010247b:	e9 f0 03 00 00       	jmp    c0102870 <__alltraps>

c0102480 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102480:	6a 00                	push   $0x0
  pushl $172
c0102482:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102487:	e9 e4 03 00 00       	jmp    c0102870 <__alltraps>

c010248c <vector173>:
.globl vector173
vector173:
  pushl $0
c010248c:	6a 00                	push   $0x0
  pushl $173
c010248e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102493:	e9 d8 03 00 00       	jmp    c0102870 <__alltraps>

c0102498 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102498:	6a 00                	push   $0x0
  pushl $174
c010249a:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010249f:	e9 cc 03 00 00       	jmp    c0102870 <__alltraps>

c01024a4 <vector175>:
.globl vector175
vector175:
  pushl $0
c01024a4:	6a 00                	push   $0x0
  pushl $175
c01024a6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024ab:	e9 c0 03 00 00       	jmp    c0102870 <__alltraps>

c01024b0 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024b0:	6a 00                	push   $0x0
  pushl $176
c01024b2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024b7:	e9 b4 03 00 00       	jmp    c0102870 <__alltraps>

c01024bc <vector177>:
.globl vector177
vector177:
  pushl $0
c01024bc:	6a 00                	push   $0x0
  pushl $177
c01024be:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024c3:	e9 a8 03 00 00       	jmp    c0102870 <__alltraps>

c01024c8 <vector178>:
.globl vector178
vector178:
  pushl $0
c01024c8:	6a 00                	push   $0x0
  pushl $178
c01024ca:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024cf:	e9 9c 03 00 00       	jmp    c0102870 <__alltraps>

c01024d4 <vector179>:
.globl vector179
vector179:
  pushl $0
c01024d4:	6a 00                	push   $0x0
  pushl $179
c01024d6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024db:	e9 90 03 00 00       	jmp    c0102870 <__alltraps>

c01024e0 <vector180>:
.globl vector180
vector180:
  pushl $0
c01024e0:	6a 00                	push   $0x0
  pushl $180
c01024e2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024e7:	e9 84 03 00 00       	jmp    c0102870 <__alltraps>

c01024ec <vector181>:
.globl vector181
vector181:
  pushl $0
c01024ec:	6a 00                	push   $0x0
  pushl $181
c01024ee:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024f3:	e9 78 03 00 00       	jmp    c0102870 <__alltraps>

c01024f8 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024f8:	6a 00                	push   $0x0
  pushl $182
c01024fa:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024ff:	e9 6c 03 00 00       	jmp    c0102870 <__alltraps>

c0102504 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102504:	6a 00                	push   $0x0
  pushl $183
c0102506:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010250b:	e9 60 03 00 00       	jmp    c0102870 <__alltraps>

c0102510 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102510:	6a 00                	push   $0x0
  pushl $184
c0102512:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102517:	e9 54 03 00 00       	jmp    c0102870 <__alltraps>

c010251c <vector185>:
.globl vector185
vector185:
  pushl $0
c010251c:	6a 00                	push   $0x0
  pushl $185
c010251e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102523:	e9 48 03 00 00       	jmp    c0102870 <__alltraps>

c0102528 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102528:	6a 00                	push   $0x0
  pushl $186
c010252a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010252f:	e9 3c 03 00 00       	jmp    c0102870 <__alltraps>

c0102534 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102534:	6a 00                	push   $0x0
  pushl $187
c0102536:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010253b:	e9 30 03 00 00       	jmp    c0102870 <__alltraps>

c0102540 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102540:	6a 00                	push   $0x0
  pushl $188
c0102542:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102547:	e9 24 03 00 00       	jmp    c0102870 <__alltraps>

c010254c <vector189>:
.globl vector189
vector189:
  pushl $0
c010254c:	6a 00                	push   $0x0
  pushl $189
c010254e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102553:	e9 18 03 00 00       	jmp    c0102870 <__alltraps>

c0102558 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102558:	6a 00                	push   $0x0
  pushl $190
c010255a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010255f:	e9 0c 03 00 00       	jmp    c0102870 <__alltraps>

c0102564 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102564:	6a 00                	push   $0x0
  pushl $191
c0102566:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010256b:	e9 00 03 00 00       	jmp    c0102870 <__alltraps>

c0102570 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102570:	6a 00                	push   $0x0
  pushl $192
c0102572:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102577:	e9 f4 02 00 00       	jmp    c0102870 <__alltraps>

c010257c <vector193>:
.globl vector193
vector193:
  pushl $0
c010257c:	6a 00                	push   $0x0
  pushl $193
c010257e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102583:	e9 e8 02 00 00       	jmp    c0102870 <__alltraps>

c0102588 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102588:	6a 00                	push   $0x0
  pushl $194
c010258a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010258f:	e9 dc 02 00 00       	jmp    c0102870 <__alltraps>

c0102594 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102594:	6a 00                	push   $0x0
  pushl $195
c0102596:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010259b:	e9 d0 02 00 00       	jmp    c0102870 <__alltraps>

c01025a0 <vector196>:
.globl vector196
vector196:
  pushl $0
c01025a0:	6a 00                	push   $0x0
  pushl $196
c01025a2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025a7:	e9 c4 02 00 00       	jmp    c0102870 <__alltraps>

c01025ac <vector197>:
.globl vector197
vector197:
  pushl $0
c01025ac:	6a 00                	push   $0x0
  pushl $197
c01025ae:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025b3:	e9 b8 02 00 00       	jmp    c0102870 <__alltraps>

c01025b8 <vector198>:
.globl vector198
vector198:
  pushl $0
c01025b8:	6a 00                	push   $0x0
  pushl $198
c01025ba:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025bf:	e9 ac 02 00 00       	jmp    c0102870 <__alltraps>

c01025c4 <vector199>:
.globl vector199
vector199:
  pushl $0
c01025c4:	6a 00                	push   $0x0
  pushl $199
c01025c6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025cb:	e9 a0 02 00 00       	jmp    c0102870 <__alltraps>

c01025d0 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025d0:	6a 00                	push   $0x0
  pushl $200
c01025d2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025d7:	e9 94 02 00 00       	jmp    c0102870 <__alltraps>

c01025dc <vector201>:
.globl vector201
vector201:
  pushl $0
c01025dc:	6a 00                	push   $0x0
  pushl $201
c01025de:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025e3:	e9 88 02 00 00       	jmp    c0102870 <__alltraps>

c01025e8 <vector202>:
.globl vector202
vector202:
  pushl $0
c01025e8:	6a 00                	push   $0x0
  pushl $202
c01025ea:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025ef:	e9 7c 02 00 00       	jmp    c0102870 <__alltraps>

c01025f4 <vector203>:
.globl vector203
vector203:
  pushl $0
c01025f4:	6a 00                	push   $0x0
  pushl $203
c01025f6:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025fb:	e9 70 02 00 00       	jmp    c0102870 <__alltraps>

c0102600 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102600:	6a 00                	push   $0x0
  pushl $204
c0102602:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102607:	e9 64 02 00 00       	jmp    c0102870 <__alltraps>

c010260c <vector205>:
.globl vector205
vector205:
  pushl $0
c010260c:	6a 00                	push   $0x0
  pushl $205
c010260e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102613:	e9 58 02 00 00       	jmp    c0102870 <__alltraps>

c0102618 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102618:	6a 00                	push   $0x0
  pushl $206
c010261a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010261f:	e9 4c 02 00 00       	jmp    c0102870 <__alltraps>

c0102624 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102624:	6a 00                	push   $0x0
  pushl $207
c0102626:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010262b:	e9 40 02 00 00       	jmp    c0102870 <__alltraps>

c0102630 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102630:	6a 00                	push   $0x0
  pushl $208
c0102632:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102637:	e9 34 02 00 00       	jmp    c0102870 <__alltraps>

c010263c <vector209>:
.globl vector209
vector209:
  pushl $0
c010263c:	6a 00                	push   $0x0
  pushl $209
c010263e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102643:	e9 28 02 00 00       	jmp    c0102870 <__alltraps>

c0102648 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102648:	6a 00                	push   $0x0
  pushl $210
c010264a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010264f:	e9 1c 02 00 00       	jmp    c0102870 <__alltraps>

c0102654 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102654:	6a 00                	push   $0x0
  pushl $211
c0102656:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010265b:	e9 10 02 00 00       	jmp    c0102870 <__alltraps>

c0102660 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102660:	6a 00                	push   $0x0
  pushl $212
c0102662:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102667:	e9 04 02 00 00       	jmp    c0102870 <__alltraps>

c010266c <vector213>:
.globl vector213
vector213:
  pushl $0
c010266c:	6a 00                	push   $0x0
  pushl $213
c010266e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102673:	e9 f8 01 00 00       	jmp    c0102870 <__alltraps>

c0102678 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102678:	6a 00                	push   $0x0
  pushl $214
c010267a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010267f:	e9 ec 01 00 00       	jmp    c0102870 <__alltraps>

c0102684 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102684:	6a 00                	push   $0x0
  pushl $215
c0102686:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010268b:	e9 e0 01 00 00       	jmp    c0102870 <__alltraps>

c0102690 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102690:	6a 00                	push   $0x0
  pushl $216
c0102692:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102697:	e9 d4 01 00 00       	jmp    c0102870 <__alltraps>

c010269c <vector217>:
.globl vector217
vector217:
  pushl $0
c010269c:	6a 00                	push   $0x0
  pushl $217
c010269e:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026a3:	e9 c8 01 00 00       	jmp    c0102870 <__alltraps>

c01026a8 <vector218>:
.globl vector218
vector218:
  pushl $0
c01026a8:	6a 00                	push   $0x0
  pushl $218
c01026aa:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026af:	e9 bc 01 00 00       	jmp    c0102870 <__alltraps>

c01026b4 <vector219>:
.globl vector219
vector219:
  pushl $0
c01026b4:	6a 00                	push   $0x0
  pushl $219
c01026b6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026bb:	e9 b0 01 00 00       	jmp    c0102870 <__alltraps>

c01026c0 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026c0:	6a 00                	push   $0x0
  pushl $220
c01026c2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026c7:	e9 a4 01 00 00       	jmp    c0102870 <__alltraps>

c01026cc <vector221>:
.globl vector221
vector221:
  pushl $0
c01026cc:	6a 00                	push   $0x0
  pushl $221
c01026ce:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026d3:	e9 98 01 00 00       	jmp    c0102870 <__alltraps>

c01026d8 <vector222>:
.globl vector222
vector222:
  pushl $0
c01026d8:	6a 00                	push   $0x0
  pushl $222
c01026da:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01026df:	e9 8c 01 00 00       	jmp    c0102870 <__alltraps>

c01026e4 <vector223>:
.globl vector223
vector223:
  pushl $0
c01026e4:	6a 00                	push   $0x0
  pushl $223
c01026e6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026eb:	e9 80 01 00 00       	jmp    c0102870 <__alltraps>

c01026f0 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026f0:	6a 00                	push   $0x0
  pushl $224
c01026f2:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026f7:	e9 74 01 00 00       	jmp    c0102870 <__alltraps>

c01026fc <vector225>:
.globl vector225
vector225:
  pushl $0
c01026fc:	6a 00                	push   $0x0
  pushl $225
c01026fe:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102703:	e9 68 01 00 00       	jmp    c0102870 <__alltraps>

c0102708 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102708:	6a 00                	push   $0x0
  pushl $226
c010270a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010270f:	e9 5c 01 00 00       	jmp    c0102870 <__alltraps>

c0102714 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102714:	6a 00                	push   $0x0
  pushl $227
c0102716:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010271b:	e9 50 01 00 00       	jmp    c0102870 <__alltraps>

c0102720 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102720:	6a 00                	push   $0x0
  pushl $228
c0102722:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102727:	e9 44 01 00 00       	jmp    c0102870 <__alltraps>

c010272c <vector229>:
.globl vector229
vector229:
  pushl $0
c010272c:	6a 00                	push   $0x0
  pushl $229
c010272e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102733:	e9 38 01 00 00       	jmp    c0102870 <__alltraps>

c0102738 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102738:	6a 00                	push   $0x0
  pushl $230
c010273a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010273f:	e9 2c 01 00 00       	jmp    c0102870 <__alltraps>

c0102744 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102744:	6a 00                	push   $0x0
  pushl $231
c0102746:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010274b:	e9 20 01 00 00       	jmp    c0102870 <__alltraps>

c0102750 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102750:	6a 00                	push   $0x0
  pushl $232
c0102752:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102757:	e9 14 01 00 00       	jmp    c0102870 <__alltraps>

c010275c <vector233>:
.globl vector233
vector233:
  pushl $0
c010275c:	6a 00                	push   $0x0
  pushl $233
c010275e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102763:	e9 08 01 00 00       	jmp    c0102870 <__alltraps>

c0102768 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102768:	6a 00                	push   $0x0
  pushl $234
c010276a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010276f:	e9 fc 00 00 00       	jmp    c0102870 <__alltraps>

c0102774 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102774:	6a 00                	push   $0x0
  pushl $235
c0102776:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010277b:	e9 f0 00 00 00       	jmp    c0102870 <__alltraps>

c0102780 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102780:	6a 00                	push   $0x0
  pushl $236
c0102782:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102787:	e9 e4 00 00 00       	jmp    c0102870 <__alltraps>

c010278c <vector237>:
.globl vector237
vector237:
  pushl $0
c010278c:	6a 00                	push   $0x0
  pushl $237
c010278e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102793:	e9 d8 00 00 00       	jmp    c0102870 <__alltraps>

c0102798 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102798:	6a 00                	push   $0x0
  pushl $238
c010279a:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010279f:	e9 cc 00 00 00       	jmp    c0102870 <__alltraps>

c01027a4 <vector239>:
.globl vector239
vector239:
  pushl $0
c01027a4:	6a 00                	push   $0x0
  pushl $239
c01027a6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027ab:	e9 c0 00 00 00       	jmp    c0102870 <__alltraps>

c01027b0 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027b0:	6a 00                	push   $0x0
  pushl $240
c01027b2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027b7:	e9 b4 00 00 00       	jmp    c0102870 <__alltraps>

c01027bc <vector241>:
.globl vector241
vector241:
  pushl $0
c01027bc:	6a 00                	push   $0x0
  pushl $241
c01027be:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027c3:	e9 a8 00 00 00       	jmp    c0102870 <__alltraps>

c01027c8 <vector242>:
.globl vector242
vector242:
  pushl $0
c01027c8:	6a 00                	push   $0x0
  pushl $242
c01027ca:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027cf:	e9 9c 00 00 00       	jmp    c0102870 <__alltraps>

c01027d4 <vector243>:
.globl vector243
vector243:
  pushl $0
c01027d4:	6a 00                	push   $0x0
  pushl $243
c01027d6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027db:	e9 90 00 00 00       	jmp    c0102870 <__alltraps>

c01027e0 <vector244>:
.globl vector244
vector244:
  pushl $0
c01027e0:	6a 00                	push   $0x0
  pushl $244
c01027e2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027e7:	e9 84 00 00 00       	jmp    c0102870 <__alltraps>

c01027ec <vector245>:
.globl vector245
vector245:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $245
c01027ee:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027f3:	e9 78 00 00 00       	jmp    c0102870 <__alltraps>

c01027f8 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027f8:	6a 00                	push   $0x0
  pushl $246
c01027fa:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027ff:	e9 6c 00 00 00       	jmp    c0102870 <__alltraps>

c0102804 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102804:	6a 00                	push   $0x0
  pushl $247
c0102806:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010280b:	e9 60 00 00 00       	jmp    c0102870 <__alltraps>

c0102810 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102810:	6a 00                	push   $0x0
  pushl $248
c0102812:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102817:	e9 54 00 00 00       	jmp    c0102870 <__alltraps>

c010281c <vector249>:
.globl vector249
vector249:
  pushl $0
c010281c:	6a 00                	push   $0x0
  pushl $249
c010281e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102823:	e9 48 00 00 00       	jmp    c0102870 <__alltraps>

c0102828 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102828:	6a 00                	push   $0x0
  pushl $250
c010282a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010282f:	e9 3c 00 00 00       	jmp    c0102870 <__alltraps>

c0102834 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102834:	6a 00                	push   $0x0
  pushl $251
c0102836:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010283b:	e9 30 00 00 00       	jmp    c0102870 <__alltraps>

c0102840 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102840:	6a 00                	push   $0x0
  pushl $252
c0102842:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102847:	e9 24 00 00 00       	jmp    c0102870 <__alltraps>

c010284c <vector253>:
.globl vector253
vector253:
  pushl $0
c010284c:	6a 00                	push   $0x0
  pushl $253
c010284e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102853:	e9 18 00 00 00       	jmp    c0102870 <__alltraps>

c0102858 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $254
c010285a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010285f:	e9 0c 00 00 00       	jmp    c0102870 <__alltraps>

c0102864 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102864:	6a 00                	push   $0x0
  pushl $255
c0102866:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010286b:	e9 00 00 00 00       	jmp    c0102870 <__alltraps>

c0102870 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102870:	1e                   	push   %ds
    pushl %es
c0102871:	06                   	push   %es
    pushl %fs
c0102872:	0f a0                	push   %fs
    pushl %gs
c0102874:	0f a8                	push   %gs
    pushal
c0102876:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102877:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010287c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010287e:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102880:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102881:	e8 67 f5 ff ff       	call   c0101ded <trap>

    # pop the pushed stack pointer
    popl %esp
c0102886:	5c                   	pop    %esp

c0102887 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102887:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102888:	0f a9                	pop    %gs
    popl %fs
c010288a:	0f a1                	pop    %fs
    popl %es
c010288c:	07                   	pop    %es
    popl %ds
c010288d:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010288e:	83 c4 08             	add    $0x8,%esp
    iret
c0102891:	cf                   	iret   

c0102892 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102892:	55                   	push   %ebp
c0102893:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102895:	8b 55 08             	mov    0x8(%ebp),%edx
c0102898:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c010289d:	29 c2                	sub    %eax,%edx
c010289f:	89 d0                	mov    %edx,%eax
c01028a1:	c1 f8 02             	sar    $0x2,%eax
c01028a4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028aa:	5d                   	pop    %ebp
c01028ab:	c3                   	ret    

c01028ac <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028ac:	55                   	push   %ebp
c01028ad:	89 e5                	mov    %esp,%ebp
c01028af:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b5:	89 04 24             	mov    %eax,(%esp)
c01028b8:	e8 d5 ff ff ff       	call   c0102892 <page2ppn>
c01028bd:	c1 e0 0c             	shl    $0xc,%eax
}
c01028c0:	c9                   	leave  
c01028c1:	c3                   	ret    

c01028c2 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01028c2:	55                   	push   %ebp
c01028c3:	89 e5                	mov    %esp,%ebp
c01028c5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01028c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028cb:	c1 e8 0c             	shr    $0xc,%eax
c01028ce:	89 c2                	mov    %eax,%edx
c01028d0:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01028d5:	39 c2                	cmp    %eax,%edx
c01028d7:	72 1c                	jb     c01028f5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01028d9:	c7 44 24 08 b0 64 10 	movl   $0xc01064b0,0x8(%esp)
c01028e0:	c0 
c01028e1:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c01028e8:	00 
c01028e9:	c7 04 24 cf 64 10 c0 	movl   $0xc01064cf,(%esp)
c01028f0:	e8 e8 da ff ff       	call   c01003dd <__panic>
    }
    return &pages[PPN(pa)];
c01028f5:	8b 0d 58 89 11 c0    	mov    0xc0118958,%ecx
c01028fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01028fe:	c1 e8 0c             	shr    $0xc,%eax
c0102901:	89 c2                	mov    %eax,%edx
c0102903:	89 d0                	mov    %edx,%eax
c0102905:	c1 e0 02             	shl    $0x2,%eax
c0102908:	01 d0                	add    %edx,%eax
c010290a:	c1 e0 02             	shl    $0x2,%eax
c010290d:	01 c8                	add    %ecx,%eax
}
c010290f:	c9                   	leave  
c0102910:	c3                   	ret    

c0102911 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102911:	55                   	push   %ebp
c0102912:	89 e5                	mov    %esp,%ebp
c0102914:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102917:	8b 45 08             	mov    0x8(%ebp),%eax
c010291a:	89 04 24             	mov    %eax,(%esp)
c010291d:	e8 8a ff ff ff       	call   c01028ac <page2pa>
c0102922:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102925:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102928:	c1 e8 0c             	shr    $0xc,%eax
c010292b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010292e:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0102933:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102936:	72 23                	jb     c010295b <page2kva+0x4a>
c0102938:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010293b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010293f:	c7 44 24 08 e0 64 10 	movl   $0xc01064e0,0x8(%esp)
c0102946:	c0 
c0102947:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c010294e:	00 
c010294f:	c7 04 24 cf 64 10 c0 	movl   $0xc01064cf,(%esp)
c0102956:	e8 82 da ff ff       	call   c01003dd <__panic>
c010295b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102963:	c9                   	leave  
c0102964:	c3                   	ret    

c0102965 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102965:	55                   	push   %ebp
c0102966:	89 e5                	mov    %esp,%ebp
c0102968:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010296b:	8b 45 08             	mov    0x8(%ebp),%eax
c010296e:	83 e0 01             	and    $0x1,%eax
c0102971:	85 c0                	test   %eax,%eax
c0102973:	75 1c                	jne    c0102991 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102975:	c7 44 24 08 04 65 10 	movl   $0xc0106504,0x8(%esp)
c010297c:	c0 
c010297d:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102984:	00 
c0102985:	c7 04 24 cf 64 10 c0 	movl   $0xc01064cf,(%esp)
c010298c:	e8 4c da ff ff       	call   c01003dd <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102991:	8b 45 08             	mov    0x8(%ebp),%eax
c0102994:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102999:	89 04 24             	mov    %eax,(%esp)
c010299c:	e8 21 ff ff ff       	call   c01028c2 <pa2page>
}
c01029a1:	c9                   	leave  
c01029a2:	c3                   	ret    

c01029a3 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01029a3:	55                   	push   %ebp
c01029a4:	89 e5                	mov    %esp,%ebp
c01029a6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01029a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01029b1:	89 04 24             	mov    %eax,(%esp)
c01029b4:	e8 09 ff ff ff       	call   c01028c2 <pa2page>
}
c01029b9:	c9                   	leave  
c01029ba:	c3                   	ret    

c01029bb <page_ref>:

static inline int
page_ref(struct Page *page) {
c01029bb:	55                   	push   %ebp
c01029bc:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01029be:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c1:	8b 00                	mov    (%eax),%eax
}
c01029c3:	5d                   	pop    %ebp
c01029c4:	c3                   	ret    

c01029c5 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c01029c5:	55                   	push   %ebp
c01029c6:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01029c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01029cb:	8b 00                	mov    (%eax),%eax
c01029cd:	8d 50 01             	lea    0x1(%eax),%edx
c01029d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d3:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d8:	8b 00                	mov    (%eax),%eax
}
c01029da:	5d                   	pop    %ebp
c01029db:	c3                   	ret    

c01029dc <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01029dc:	55                   	push   %ebp
c01029dd:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01029df:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e2:	8b 00                	mov    (%eax),%eax
c01029e4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ea:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ef:	8b 00                	mov    (%eax),%eax
}
c01029f1:	5d                   	pop    %ebp
c01029f2:	c3                   	ret    

c01029f3 <__intr_save>:
__intr_save(void) {
c01029f3:	55                   	push   %ebp
c01029f4:	89 e5                	mov    %esp,%ebp
c01029f6:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01029f9:	9c                   	pushf  
c01029fa:	58                   	pop    %eax
c01029fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a01:	25 00 02 00 00       	and    $0x200,%eax
c0102a06:	85 c0                	test   %eax,%eax
c0102a08:	74 0c                	je     c0102a16 <__intr_save+0x23>
        intr_disable();
c0102a0a:	e8 67 ee ff ff       	call   c0101876 <intr_disable>
        return 1;
c0102a0f:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a14:	eb 05                	jmp    c0102a1b <__intr_save+0x28>
    return 0;
c0102a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a1b:	c9                   	leave  
c0102a1c:	c3                   	ret    

c0102a1d <__intr_restore>:
__intr_restore(bool flag) {
c0102a1d:	55                   	push   %ebp
c0102a1e:	89 e5                	mov    %esp,%ebp
c0102a20:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a23:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a27:	74 05                	je     c0102a2e <__intr_restore+0x11>
        intr_enable();
c0102a29:	e8 42 ee ff ff       	call   c0101870 <intr_enable>
}
c0102a2e:	c9                   	leave  
c0102a2f:	c3                   	ret    

c0102a30 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102a30:	55                   	push   %ebp
c0102a31:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102a33:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a36:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102a39:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a3e:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102a40:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a45:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a47:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a4c:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a4e:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a53:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a55:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a5a:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a5c:	ea 63 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a63
}
c0102a63:	5d                   	pop    %ebp
c0102a64:	c3                   	ret    

c0102a65 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a65:	55                   	push   %ebp
c0102a66:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a68:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a6b:	a3 e4 88 11 c0       	mov    %eax,0xc01188e4
}
c0102a70:	5d                   	pop    %ebp
c0102a71:	c3                   	ret    

c0102a72 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a72:	55                   	push   %ebp
c0102a73:	89 e5                	mov    %esp,%ebp
c0102a75:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a78:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102a7d:	89 04 24             	mov    %eax,(%esp)
c0102a80:	e8 e0 ff ff ff       	call   c0102a65 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102a85:	66 c7 05 e8 88 11 c0 	movw   $0x10,0xc01188e8
c0102a8c:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a8e:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102a95:	68 00 
c0102a97:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0102a9c:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102aa2:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0102aa7:	c1 e8 10             	shr    $0x10,%eax
c0102aaa:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102aaf:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ab6:	83 e0 f0             	and    $0xfffffff0,%eax
c0102ab9:	83 c8 09             	or     $0x9,%eax
c0102abc:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102ac1:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ac8:	83 e0 ef             	and    $0xffffffef,%eax
c0102acb:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102ad0:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ad7:	83 e0 9f             	and    $0xffffff9f,%eax
c0102ada:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102adf:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102ae6:	83 c8 80             	or     $0xffffff80,%eax
c0102ae9:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102aee:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102af5:	83 e0 f0             	and    $0xfffffff0,%eax
c0102af8:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102afd:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b04:	83 e0 ef             	and    $0xffffffef,%eax
c0102b07:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b0c:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b13:	83 e0 df             	and    $0xffffffdf,%eax
c0102b16:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b1b:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b22:	83 c8 40             	or     $0x40,%eax
c0102b25:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b2a:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102b31:	83 e0 7f             	and    $0x7f,%eax
c0102b34:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102b39:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0102b3e:	c1 e8 18             	shr    $0x18,%eax
c0102b41:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b46:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102b4d:	e8 de fe ff ff       	call   c0102a30 <lgdt>
c0102b52:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b58:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b5c:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b5f:	c9                   	leave  
c0102b60:	c3                   	ret    

c0102b61 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b61:	55                   	push   %ebp
c0102b62:	89 e5                	mov    %esp,%ebp
c0102b64:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102b67:	c7 05 50 89 11 c0 78 	movl   $0xc0106e78,0xc0118950
c0102b6e:	6e 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b71:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102b76:	8b 00                	mov    (%eax),%eax
c0102b78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b7c:	c7 04 24 30 65 10 c0 	movl   $0xc0106530,(%esp)
c0102b83:	e8 fe d6 ff ff       	call   c0100286 <cprintf>
    pmm_manager->init();
c0102b88:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102b8d:	8b 40 04             	mov    0x4(%eax),%eax
c0102b90:	ff d0                	call   *%eax
}
c0102b92:	c9                   	leave  
c0102b93:	c3                   	ret    

c0102b94 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b94:	55                   	push   %ebp
c0102b95:	89 e5                	mov    %esp,%ebp
c0102b97:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102b9a:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102b9f:	8b 40 08             	mov    0x8(%eax),%eax
c0102ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ba5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102ba9:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bac:	89 14 24             	mov    %edx,(%esp)
c0102baf:	ff d0                	call   *%eax
}
c0102bb1:	c9                   	leave  
c0102bb2:	c3                   	ret    

c0102bb3 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102bb3:	55                   	push   %ebp
c0102bb4:	89 e5                	mov    %esp,%ebp
c0102bb6:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bc0:	e8 2e fe ff ff       	call   c01029f3 <__intr_save>
c0102bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102bc8:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102bcd:	8b 40 0c             	mov    0xc(%eax),%eax
c0102bd0:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bd3:	89 14 24             	mov    %edx,(%esp)
c0102bd6:	ff d0                	call   *%eax
c0102bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bde:	89 04 24             	mov    %eax,(%esp)
c0102be1:	e8 37 fe ff ff       	call   c0102a1d <__intr_restore>
    return page;
c0102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102be9:	c9                   	leave  
c0102bea:	c3                   	ret    

c0102beb <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102beb:	55                   	push   %ebp
c0102bec:	89 e5                	mov    %esp,%ebp
c0102bee:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bf1:	e8 fd fd ff ff       	call   c01029f3 <__intr_save>
c0102bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102bf9:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102bfe:	8b 40 10             	mov    0x10(%eax),%eax
c0102c01:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c04:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102c08:	8b 55 08             	mov    0x8(%ebp),%edx
c0102c0b:	89 14 24             	mov    %edx,(%esp)
c0102c0e:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c13:	89 04 24             	mov    %eax,(%esp)
c0102c16:	e8 02 fe ff ff       	call   c0102a1d <__intr_restore>
}
c0102c1b:	c9                   	leave  
c0102c1c:	c3                   	ret    

c0102c1d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102c1d:	55                   	push   %ebp
c0102c1e:	89 e5                	mov    %esp,%ebp
c0102c20:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102c23:	e8 cb fd ff ff       	call   c01029f3 <__intr_save>
c0102c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102c2b:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102c30:	8b 40 14             	mov    0x14(%eax),%eax
c0102c33:	ff d0                	call   *%eax
c0102c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c3b:	89 04 24             	mov    %eax,(%esp)
c0102c3e:	e8 da fd ff ff       	call   c0102a1d <__intr_restore>
    return ret;
c0102c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c46:	c9                   	leave  
c0102c47:	c3                   	ret    

c0102c48 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c48:	55                   	push   %ebp
c0102c49:	89 e5                	mov    %esp,%ebp
c0102c4b:	57                   	push   %edi
c0102c4c:	56                   	push   %esi
c0102c4d:	53                   	push   %ebx
c0102c4e:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c54:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c5b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c62:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c69:	c7 04 24 47 65 10 c0 	movl   $0xc0106547,(%esp)
c0102c70:	e8 11 d6 ff ff       	call   c0100286 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c75:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c7c:	e9 15 01 00 00       	jmp    c0102d96 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c81:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c84:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c87:	89 d0                	mov    %edx,%eax
c0102c89:	c1 e0 02             	shl    $0x2,%eax
c0102c8c:	01 d0                	add    %edx,%eax
c0102c8e:	c1 e0 02             	shl    $0x2,%eax
c0102c91:	01 c8                	add    %ecx,%eax
c0102c93:	8b 50 08             	mov    0x8(%eax),%edx
c0102c96:	8b 40 04             	mov    0x4(%eax),%eax
c0102c99:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102c9c:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102c9f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ca2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ca5:	89 d0                	mov    %edx,%eax
c0102ca7:	c1 e0 02             	shl    $0x2,%eax
c0102caa:	01 d0                	add    %edx,%eax
c0102cac:	c1 e0 02             	shl    $0x2,%eax
c0102caf:	01 c8                	add    %ecx,%eax
c0102cb1:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102cb4:	8b 58 10             	mov    0x10(%eax),%ebx
c0102cb7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102cba:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102cbd:	01 c8                	add    %ecx,%eax
c0102cbf:	11 da                	adc    %ebx,%edx
c0102cc1:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102cc4:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102cc7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cca:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ccd:	89 d0                	mov    %edx,%eax
c0102ccf:	c1 e0 02             	shl    $0x2,%eax
c0102cd2:	01 d0                	add    %edx,%eax
c0102cd4:	c1 e0 02             	shl    $0x2,%eax
c0102cd7:	01 c8                	add    %ecx,%eax
c0102cd9:	83 c0 14             	add    $0x14,%eax
c0102cdc:	8b 00                	mov    (%eax),%eax
c0102cde:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0102ce4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102ce7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102cea:	83 c0 ff             	add    $0xffffffff,%eax
c0102ced:	83 d2 ff             	adc    $0xffffffff,%edx
c0102cf0:	89 c6                	mov    %eax,%esi
c0102cf2:	89 d7                	mov    %edx,%edi
c0102cf4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cfa:	89 d0                	mov    %edx,%eax
c0102cfc:	c1 e0 02             	shl    $0x2,%eax
c0102cff:	01 d0                	add    %edx,%eax
c0102d01:	c1 e0 02             	shl    $0x2,%eax
c0102d04:	01 c8                	add    %ecx,%eax
c0102d06:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102d09:	8b 58 10             	mov    0x10(%eax),%ebx
c0102d0c:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102d12:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0102d16:	89 74 24 14          	mov    %esi,0x14(%esp)
c0102d1a:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0102d1e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d21:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d24:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d28:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102d2c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102d30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d34:	c7 04 24 54 65 10 c0 	movl   $0xc0106554,(%esp)
c0102d3b:	e8 46 d5 ff ff       	call   c0100286 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d40:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d43:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d46:	89 d0                	mov    %edx,%eax
c0102d48:	c1 e0 02             	shl    $0x2,%eax
c0102d4b:	01 d0                	add    %edx,%eax
c0102d4d:	c1 e0 02             	shl    $0x2,%eax
c0102d50:	01 c8                	add    %ecx,%eax
c0102d52:	83 c0 14             	add    $0x14,%eax
c0102d55:	8b 00                	mov    (%eax),%eax
c0102d57:	83 f8 01             	cmp    $0x1,%eax
c0102d5a:	75 36                	jne    c0102d92 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d62:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d65:	77 2b                	ja     c0102d92 <page_init+0x14a>
c0102d67:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d6a:	72 05                	jb     c0102d71 <page_init+0x129>
c0102d6c:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102d6f:	73 21                	jae    c0102d92 <page_init+0x14a>
c0102d71:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d75:	77 1b                	ja     c0102d92 <page_init+0x14a>
c0102d77:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d7b:	72 09                	jb     c0102d86 <page_init+0x13e>
c0102d7d:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102d84:	77 0c                	ja     c0102d92 <page_init+0x14a>
                maxpa = end;
c0102d86:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d89:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d92:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102d96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d99:	8b 00                	mov    (%eax),%eax
c0102d9b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102d9e:	0f 8f dd fe ff ff    	jg     c0102c81 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102da4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102da8:	72 1d                	jb     c0102dc7 <page_init+0x17f>
c0102daa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102dae:	77 09                	ja     c0102db9 <page_init+0x171>
c0102db0:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102db7:	76 0e                	jbe    c0102dc7 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0102db9:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102dc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102dca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102dcd:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102dd1:	c1 ea 0c             	shr    $0xc,%edx
c0102dd4:	a3 c0 88 11 c0       	mov    %eax,0xc01188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102dd9:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102de0:	b8 68 89 11 c0       	mov    $0xc0118968,%eax
c0102de5:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102de8:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102deb:	01 d0                	add    %edx,%eax
c0102ded:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102df0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102df3:	ba 00 00 00 00       	mov    $0x0,%edx
c0102df8:	f7 75 ac             	divl   -0x54(%ebp)
c0102dfb:	89 d0                	mov    %edx,%eax
c0102dfd:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102e00:	29 c2                	sub    %eax,%edx
c0102e02:	89 d0                	mov    %edx,%eax
c0102e04:	a3 58 89 11 c0       	mov    %eax,0xc0118958

    for (i = 0; i < npage; i ++) {
c0102e09:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e10:	eb 2f                	jmp    c0102e41 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0102e12:	8b 0d 58 89 11 c0    	mov    0xc0118958,%ecx
c0102e18:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e1b:	89 d0                	mov    %edx,%eax
c0102e1d:	c1 e0 02             	shl    $0x2,%eax
c0102e20:	01 d0                	add    %edx,%eax
c0102e22:	c1 e0 02             	shl    $0x2,%eax
c0102e25:	01 c8                	add    %ecx,%eax
c0102e27:	83 c0 04             	add    $0x4,%eax
c0102e2a:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102e31:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e34:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102e37:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e3a:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102e3d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0102e41:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e44:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0102e49:	39 c2                	cmp    %eax,%edx
c0102e4b:	72 c5                	jb     c0102e12 <page_init+0x1ca>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e4d:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0102e53:	89 d0                	mov    %edx,%eax
c0102e55:	c1 e0 02             	shl    $0x2,%eax
c0102e58:	01 d0                	add    %edx,%eax
c0102e5a:	c1 e0 02             	shl    $0x2,%eax
c0102e5d:	89 c2                	mov    %eax,%edx
c0102e5f:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c0102e64:	01 d0                	add    %edx,%eax
c0102e66:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102e69:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102e70:	77 23                	ja     c0102e95 <page_init+0x24d>
c0102e72:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e75:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e79:	c7 44 24 08 84 65 10 	movl   $0xc0106584,0x8(%esp)
c0102e80:	c0 
c0102e81:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0102e88:	00 
c0102e89:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0102e90:	e8 48 d5 ff ff       	call   c01003dd <__panic>
c0102e95:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e98:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e9d:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102ea0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102ea7:	e9 74 01 00 00       	jmp    c0103020 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102eac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102eaf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eb2:	89 d0                	mov    %edx,%eax
c0102eb4:	c1 e0 02             	shl    $0x2,%eax
c0102eb7:	01 d0                	add    %edx,%eax
c0102eb9:	c1 e0 02             	shl    $0x2,%eax
c0102ebc:	01 c8                	add    %ecx,%eax
c0102ebe:	8b 50 08             	mov    0x8(%eax),%edx
c0102ec1:	8b 40 04             	mov    0x4(%eax),%eax
c0102ec4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ec7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102eca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ecd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ed0:	89 d0                	mov    %edx,%eax
c0102ed2:	c1 e0 02             	shl    $0x2,%eax
c0102ed5:	01 d0                	add    %edx,%eax
c0102ed7:	c1 e0 02             	shl    $0x2,%eax
c0102eda:	01 c8                	add    %ecx,%eax
c0102edc:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102edf:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ee2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ee5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ee8:	01 c8                	add    %ecx,%eax
c0102eea:	11 da                	adc    %ebx,%edx
c0102eec:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102eef:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102ef2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ef8:	89 d0                	mov    %edx,%eax
c0102efa:	c1 e0 02             	shl    $0x2,%eax
c0102efd:	01 d0                	add    %edx,%eax
c0102eff:	c1 e0 02             	shl    $0x2,%eax
c0102f02:	01 c8                	add    %ecx,%eax
c0102f04:	83 c0 14             	add    $0x14,%eax
c0102f07:	8b 00                	mov    (%eax),%eax
c0102f09:	83 f8 01             	cmp    $0x1,%eax
c0102f0c:	0f 85 0a 01 00 00    	jne    c010301c <page_init+0x3d4>
            if (begin < freemem) {
c0102f12:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f15:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f1a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f1d:	72 17                	jb     c0102f36 <page_init+0x2ee>
c0102f1f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102f22:	77 05                	ja     c0102f29 <page_init+0x2e1>
c0102f24:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102f27:	76 0d                	jbe    c0102f36 <page_init+0x2ee>
                begin = freemem;
c0102f29:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f2f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102f36:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f3a:	72 1d                	jb     c0102f59 <page_init+0x311>
c0102f3c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f40:	77 09                	ja     c0102f4b <page_init+0x303>
c0102f42:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f49:	76 0e                	jbe    c0102f59 <page_init+0x311>
                end = KMEMSIZE;
c0102f4b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f52:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f5f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f62:	0f 87 b4 00 00 00    	ja     c010301c <page_init+0x3d4>
c0102f68:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f6b:	72 09                	jb     c0102f76 <page_init+0x32e>
c0102f6d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f70:	0f 83 a6 00 00 00    	jae    c010301c <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0102f76:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102f7d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f80:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f83:	01 d0                	add    %edx,%eax
c0102f85:	83 e8 01             	sub    $0x1,%eax
c0102f88:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102f8b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f8e:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f93:	f7 75 9c             	divl   -0x64(%ebp)
c0102f96:	89 d0                	mov    %edx,%eax
c0102f98:	8b 55 98             	mov    -0x68(%ebp),%edx
c0102f9b:	29 c2                	sub    %eax,%edx
c0102f9d:	89 d0                	mov    %edx,%eax
c0102f9f:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fa7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102faa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fad:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102fb0:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102fb3:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fb8:	89 c7                	mov    %eax,%edi
c0102fba:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0102fc0:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0102fc3:	89 d0                	mov    %edx,%eax
c0102fc5:	83 e0 00             	and    $0x0,%eax
c0102fc8:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102fcb:	8b 45 80             	mov    -0x80(%ebp),%eax
c0102fce:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102fd1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102fd4:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0102fd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fda:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102fdd:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fe0:	77 3a                	ja     c010301c <page_init+0x3d4>
c0102fe2:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102fe5:	72 05                	jb     c0102fec <page_init+0x3a4>
c0102fe7:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fea:	73 30                	jae    c010301c <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102fec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0102fef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0102ff2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102ff5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102ff8:	29 c8                	sub    %ecx,%eax
c0102ffa:	19 da                	sbb    %ebx,%edx
c0102ffc:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103000:	c1 ea 0c             	shr    $0xc,%edx
c0103003:	89 c3                	mov    %eax,%ebx
c0103005:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103008:	89 04 24             	mov    %eax,(%esp)
c010300b:	e8 b2 f8 ff ff       	call   c01028c2 <pa2page>
c0103010:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103014:	89 04 24             	mov    %eax,(%esp)
c0103017:	e8 78 fb ff ff       	call   c0102b94 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010301c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103020:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103023:	8b 00                	mov    (%eax),%eax
c0103025:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103028:	0f 8f 7e fe ff ff    	jg     c0102eac <page_init+0x264>
                }
            }
        }
    }
}
c010302e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103034:	5b                   	pop    %ebx
c0103035:	5e                   	pop    %esi
c0103036:	5f                   	pop    %edi
c0103037:	5d                   	pop    %ebp
c0103038:	c3                   	ret    

c0103039 <enable_paging>:

static void
enable_paging(void) {
c0103039:	55                   	push   %ebp
c010303a:	89 e5                	mov    %esp,%ebp
c010303c:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c010303f:	a1 54 89 11 c0       	mov    0xc0118954,%eax
c0103044:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0103047:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010304a:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c010304d:	0f 20 c0             	mov    %cr0,%eax
c0103050:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c0103053:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c0103056:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0103059:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0103060:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0103064:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103067:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c010306a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010306d:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0103070:	c9                   	leave  
c0103071:	c3                   	ret    

c0103072 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103072:	55                   	push   %ebp
c0103073:	89 e5                	mov    %esp,%ebp
c0103075:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103078:	8b 45 14             	mov    0x14(%ebp),%eax
c010307b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010307e:	31 d0                	xor    %edx,%eax
c0103080:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103085:	85 c0                	test   %eax,%eax
c0103087:	74 24                	je     c01030ad <boot_map_segment+0x3b>
c0103089:	c7 44 24 0c b6 65 10 	movl   $0xc01065b6,0xc(%esp)
c0103090:	c0 
c0103091:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103098:	c0 
c0103099:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c01030a0:	00 
c01030a1:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01030a8:	e8 30 d3 ff ff       	call   c01003dd <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01030ad:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01030b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030b7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01030bc:	89 c2                	mov    %eax,%edx
c01030be:	8b 45 10             	mov    0x10(%ebp),%eax
c01030c1:	01 c2                	add    %eax,%edx
c01030c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030c6:	01 d0                	add    %edx,%eax
c01030c8:	83 e8 01             	sub    $0x1,%eax
c01030cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030d1:	ba 00 00 00 00       	mov    $0x0,%edx
c01030d6:	f7 75 f0             	divl   -0x10(%ebp)
c01030d9:	89 d0                	mov    %edx,%eax
c01030db:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01030de:	29 c2                	sub    %eax,%edx
c01030e0:	89 d0                	mov    %edx,%eax
c01030e2:	c1 e8 0c             	shr    $0xc,%eax
c01030e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01030e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01030ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01030f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01030f6:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01030f9:	8b 45 14             	mov    0x14(%ebp),%eax
c01030fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01030ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103102:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103107:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010310a:	eb 6b                	jmp    c0103177 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010310c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103113:	00 
c0103114:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010311b:	8b 45 08             	mov    0x8(%ebp),%eax
c010311e:	89 04 24             	mov    %eax,(%esp)
c0103121:	e8 cc 01 00 00       	call   c01032f2 <get_pte>
c0103126:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103129:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010312d:	75 24                	jne    c0103153 <boot_map_segment+0xe1>
c010312f:	c7 44 24 0c e2 65 10 	movl   $0xc01065e2,0xc(%esp)
c0103136:	c0 
c0103137:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010313e:	c0 
c010313f:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103146:	00 
c0103147:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010314e:	e8 8a d2 ff ff       	call   c01003dd <__panic>
        *ptep = pa | PTE_P | perm;
c0103153:	8b 45 18             	mov    0x18(%ebp),%eax
c0103156:	8b 55 14             	mov    0x14(%ebp),%edx
c0103159:	09 d0                	or     %edx,%eax
c010315b:	83 c8 01             	or     $0x1,%eax
c010315e:	89 c2                	mov    %eax,%edx
c0103160:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103163:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103165:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103169:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103170:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010317b:	75 8f                	jne    c010310c <boot_map_segment+0x9a>
    }
}
c010317d:	c9                   	leave  
c010317e:	c3                   	ret    

c010317f <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010317f:	55                   	push   %ebp
c0103180:	89 e5                	mov    %esp,%ebp
c0103182:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010318c:	e8 22 fa ff ff       	call   c0102bb3 <alloc_pages>
c0103191:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103198:	75 1c                	jne    c01031b6 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010319a:	c7 44 24 08 ef 65 10 	movl   $0xc01065ef,0x8(%esp)
c01031a1:	c0 
c01031a2:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01031a9:	00 
c01031aa:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01031b1:	e8 27 d2 ff ff       	call   c01003dd <__panic>
    }
    return page2kva(p);
c01031b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031b9:	89 04 24             	mov    %eax,(%esp)
c01031bc:	e8 50 f7 ff ff       	call   c0102911 <page2kva>
}
c01031c1:	c9                   	leave  
c01031c2:	c3                   	ret    

c01031c3 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01031c3:	55                   	push   %ebp
c01031c4:	89 e5                	mov    %esp,%ebp
c01031c6:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01031c9:	e8 93 f9 ff ff       	call   c0102b61 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01031ce:	e8 75 fa ff ff       	call   c0102c48 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01031d3:	e8 d7 02 00 00       	call   c01034af <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c01031d8:	e8 a2 ff ff ff       	call   c010317f <boot_alloc_page>
c01031dd:	a3 c4 88 11 c0       	mov    %eax,0xc01188c4
    memset(boot_pgdir, 0, PGSIZE);
c01031e2:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01031e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01031ee:	00 
c01031ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01031f6:	00 
c01031f7:	89 04 24             	mov    %eax,(%esp)
c01031fa:	e8 94 23 00 00       	call   c0105593 <memset>
    boot_cr3 = PADDR(boot_pgdir);
c01031ff:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103204:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103207:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010320e:	77 23                	ja     c0103233 <pmm_init+0x70>
c0103210:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103213:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103217:	c7 44 24 08 84 65 10 	movl   $0xc0106584,0x8(%esp)
c010321e:	c0 
c010321f:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103226:	00 
c0103227:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010322e:	e8 aa d1 ff ff       	call   c01003dd <__panic>
c0103233:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103236:	05 00 00 00 40       	add    $0x40000000,%eax
c010323b:	a3 54 89 11 c0       	mov    %eax,0xc0118954

    check_pgdir();
c0103240:	e8 88 02 00 00       	call   c01034cd <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103245:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010324a:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0103250:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103255:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103258:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010325f:	77 23                	ja     c0103284 <pmm_init+0xc1>
c0103261:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103264:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103268:	c7 44 24 08 84 65 10 	movl   $0xc0106584,0x8(%esp)
c010326f:	c0 
c0103270:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c0103277:	00 
c0103278:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010327f:	e8 59 d1 ff ff       	call   c01003dd <__panic>
c0103284:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103287:	05 00 00 00 40       	add    $0x40000000,%eax
c010328c:	83 c8 03             	or     $0x3,%eax
c010328f:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103291:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103296:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010329d:	00 
c010329e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01032a5:	00 
c01032a6:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01032ad:	38 
c01032ae:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01032b5:	c0 
c01032b6:	89 04 24             	mov    %eax,(%esp)
c01032b9:	e8 b4 fd ff ff       	call   c0103072 <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c01032be:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01032c3:	8b 15 c4 88 11 c0    	mov    0xc01188c4,%edx
c01032c9:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c01032cf:	89 10                	mov    %edx,(%eax)

    enable_paging();
c01032d1:	e8 63 fd ff ff       	call   c0103039 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01032d6:	e8 97 f7 ff ff       	call   c0102a72 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c01032db:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01032e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01032e6:	e8 7d 08 00 00       	call   c0103b68 <check_boot_pgdir>

    print_pgdir();
c01032eb:	e8 05 0d 00 00       	call   c0103ff5 <print_pgdir>

}
c01032f0:	c9                   	leave  
c01032f1:	c3                   	ret    

c01032f2 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01032f2:	55                   	push   %ebp
c01032f3:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c01032f5:	5d                   	pop    %ebp
c01032f6:	c3                   	ret    

c01032f7 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01032f7:	55                   	push   %ebp
c01032f8:	89 e5                	mov    %esp,%ebp
c01032fa:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01032fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103304:	00 
c0103305:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103308:	89 44 24 04          	mov    %eax,0x4(%esp)
c010330c:	8b 45 08             	mov    0x8(%ebp),%eax
c010330f:	89 04 24             	mov    %eax,(%esp)
c0103312:	e8 db ff ff ff       	call   c01032f2 <get_pte>
c0103317:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010331a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010331e:	74 08                	je     c0103328 <get_page+0x31>
        *ptep_store = ptep;
c0103320:	8b 45 10             	mov    0x10(%ebp),%eax
c0103323:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103326:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010332c:	74 1b                	je     c0103349 <get_page+0x52>
c010332e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103331:	8b 00                	mov    (%eax),%eax
c0103333:	83 e0 01             	and    $0x1,%eax
c0103336:	85 c0                	test   %eax,%eax
c0103338:	74 0f                	je     c0103349 <get_page+0x52>
        return pte2page(*ptep);
c010333a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010333d:	8b 00                	mov    (%eax),%eax
c010333f:	89 04 24             	mov    %eax,(%esp)
c0103342:	e8 1e f6 ff ff       	call   c0102965 <pte2page>
c0103347:	eb 05                	jmp    c010334e <get_page+0x57>
    }
    return NULL;
c0103349:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010334e:	c9                   	leave  
c010334f:	c3                   	ret    

c0103350 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103350:	55                   	push   %ebp
c0103351:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c0103353:	5d                   	pop    %ebp
c0103354:	c3                   	ret    

c0103355 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103355:	55                   	push   %ebp
c0103356:	89 e5                	mov    %esp,%ebp
c0103358:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010335b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103362:	00 
c0103363:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103366:	89 44 24 04          	mov    %eax,0x4(%esp)
c010336a:	8b 45 08             	mov    0x8(%ebp),%eax
c010336d:	89 04 24             	mov    %eax,(%esp)
c0103370:	e8 7d ff ff ff       	call   c01032f2 <get_pte>
c0103375:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c0103378:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010337c:	74 19                	je     c0103397 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010337e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103381:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103385:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103388:	89 44 24 04          	mov    %eax,0x4(%esp)
c010338c:	8b 45 08             	mov    0x8(%ebp),%eax
c010338f:	89 04 24             	mov    %eax,(%esp)
c0103392:	e8 b9 ff ff ff       	call   c0103350 <page_remove_pte>
    }
}
c0103397:	c9                   	leave  
c0103398:	c3                   	ret    

c0103399 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103399:	55                   	push   %ebp
c010339a:	89 e5                	mov    %esp,%ebp
c010339c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010339f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01033a6:	00 
c01033a7:	8b 45 10             	mov    0x10(%ebp),%eax
c01033aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b1:	89 04 24             	mov    %eax,(%esp)
c01033b4:	e8 39 ff ff ff       	call   c01032f2 <get_pte>
c01033b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01033bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033c0:	75 0a                	jne    c01033cc <page_insert+0x33>
        return -E_NO_MEM;
c01033c2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01033c7:	e9 84 00 00 00       	jmp    c0103450 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01033cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033cf:	89 04 24             	mov    %eax,(%esp)
c01033d2:	e8 ee f5 ff ff       	call   c01029c5 <page_ref_inc>
    if (*ptep & PTE_P) {
c01033d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033da:	8b 00                	mov    (%eax),%eax
c01033dc:	83 e0 01             	and    $0x1,%eax
c01033df:	85 c0                	test   %eax,%eax
c01033e1:	74 3e                	je     c0103421 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01033e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e6:	8b 00                	mov    (%eax),%eax
c01033e8:	89 04 24             	mov    %eax,(%esp)
c01033eb:	e8 75 f5 ff ff       	call   c0102965 <pte2page>
c01033f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01033f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033f9:	75 0d                	jne    c0103408 <page_insert+0x6f>
            page_ref_dec(page);
c01033fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033fe:	89 04 24             	mov    %eax,(%esp)
c0103401:	e8 d6 f5 ff ff       	call   c01029dc <page_ref_dec>
c0103406:	eb 19                	jmp    c0103421 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103408:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010340b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010340f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103412:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103416:	8b 45 08             	mov    0x8(%ebp),%eax
c0103419:	89 04 24             	mov    %eax,(%esp)
c010341c:	e8 2f ff ff ff       	call   c0103350 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103421:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103424:	89 04 24             	mov    %eax,(%esp)
c0103427:	e8 80 f4 ff ff       	call   c01028ac <page2pa>
c010342c:	0b 45 14             	or     0x14(%ebp),%eax
c010342f:	83 c8 01             	or     $0x1,%eax
c0103432:	89 c2                	mov    %eax,%edx
c0103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103437:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103439:	8b 45 10             	mov    0x10(%ebp),%eax
c010343c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103440:	8b 45 08             	mov    0x8(%ebp),%eax
c0103443:	89 04 24             	mov    %eax,(%esp)
c0103446:	e8 07 00 00 00       	call   c0103452 <tlb_invalidate>
    return 0;
c010344b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103450:	c9                   	leave  
c0103451:	c3                   	ret    

c0103452 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103452:	55                   	push   %ebp
c0103453:	89 e5                	mov    %esp,%ebp
c0103455:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103458:	0f 20 d8             	mov    %cr3,%eax
c010345b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010345e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0103461:	89 c2                	mov    %eax,%edx
c0103463:	8b 45 08             	mov    0x8(%ebp),%eax
c0103466:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103469:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103470:	77 23                	ja     c0103495 <tlb_invalidate+0x43>
c0103472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103475:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103479:	c7 44 24 08 84 65 10 	movl   $0xc0106584,0x8(%esp)
c0103480:	c0 
c0103481:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c0103488:	00 
c0103489:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103490:	e8 48 cf ff ff       	call   c01003dd <__panic>
c0103495:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103498:	05 00 00 00 40       	add    $0x40000000,%eax
c010349d:	39 c2                	cmp    %eax,%edx
c010349f:	75 0c                	jne    c01034ad <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01034a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01034a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034aa:	0f 01 38             	invlpg (%eax)
    }
}
c01034ad:	c9                   	leave  
c01034ae:	c3                   	ret    

c01034af <check_alloc_page>:

static void
check_alloc_page(void) {
c01034af:	55                   	push   %ebp
c01034b0:	89 e5                	mov    %esp,%ebp
c01034b2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01034b5:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c01034ba:	8b 40 18             	mov    0x18(%eax),%eax
c01034bd:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01034bf:	c7 04 24 08 66 10 c0 	movl   $0xc0106608,(%esp)
c01034c6:	e8 bb cd ff ff       	call   c0100286 <cprintf>
}
c01034cb:	c9                   	leave  
c01034cc:	c3                   	ret    

c01034cd <check_pgdir>:

static void
check_pgdir(void) {
c01034cd:	55                   	push   %ebp
c01034ce:	89 e5                	mov    %esp,%ebp
c01034d0:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01034d3:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01034d8:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01034dd:	76 24                	jbe    c0103503 <check_pgdir+0x36>
c01034df:	c7 44 24 0c 27 66 10 	movl   $0xc0106627,0xc(%esp)
c01034e6:	c0 
c01034e7:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01034ee:	c0 
c01034ef:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c01034f6:	00 
c01034f7:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01034fe:	e8 da ce ff ff       	call   c01003dd <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103503:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103508:	85 c0                	test   %eax,%eax
c010350a:	74 0e                	je     c010351a <check_pgdir+0x4d>
c010350c:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103511:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103516:	85 c0                	test   %eax,%eax
c0103518:	74 24                	je     c010353e <check_pgdir+0x71>
c010351a:	c7 44 24 0c 44 66 10 	movl   $0xc0106644,0xc(%esp)
c0103521:	c0 
c0103522:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103529:	c0 
c010352a:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103531:	00 
c0103532:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103539:	e8 9f ce ff ff       	call   c01003dd <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010353e:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103543:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010354a:	00 
c010354b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103552:	00 
c0103553:	89 04 24             	mov    %eax,(%esp)
c0103556:	e8 9c fd ff ff       	call   c01032f7 <get_page>
c010355b:	85 c0                	test   %eax,%eax
c010355d:	74 24                	je     c0103583 <check_pgdir+0xb6>
c010355f:	c7 44 24 0c 7c 66 10 	movl   $0xc010667c,0xc(%esp)
c0103566:	c0 
c0103567:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010356e:	c0 
c010356f:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0103576:	00 
c0103577:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010357e:	e8 5a ce ff ff       	call   c01003dd <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103583:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010358a:	e8 24 f6 ff ff       	call   c0102bb3 <alloc_pages>
c010358f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103592:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103597:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010359e:	00 
c010359f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035a6:	00 
c01035a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01035ae:	89 04 24             	mov    %eax,(%esp)
c01035b1:	e8 e3 fd ff ff       	call   c0103399 <page_insert>
c01035b6:	85 c0                	test   %eax,%eax
c01035b8:	74 24                	je     c01035de <check_pgdir+0x111>
c01035ba:	c7 44 24 0c a4 66 10 	movl   $0xc01066a4,0xc(%esp)
c01035c1:	c0 
c01035c2:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01035c9:	c0 
c01035ca:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c01035d1:	00 
c01035d2:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01035d9:	e8 ff cd ff ff       	call   c01003dd <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01035de:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01035e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035ea:	00 
c01035eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01035f2:	00 
c01035f3:	89 04 24             	mov    %eax,(%esp)
c01035f6:	e8 f7 fc ff ff       	call   c01032f2 <get_pte>
c01035fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01035fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103602:	75 24                	jne    c0103628 <check_pgdir+0x15b>
c0103604:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c010360b:	c0 
c010360c:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103613:	c0 
c0103614:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010361b:	00 
c010361c:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103623:	e8 b5 cd ff ff       	call   c01003dd <__panic>
    assert(pte2page(*ptep) == p1);
c0103628:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010362b:	8b 00                	mov    (%eax),%eax
c010362d:	89 04 24             	mov    %eax,(%esp)
c0103630:	e8 30 f3 ff ff       	call   c0102965 <pte2page>
c0103635:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103638:	74 24                	je     c010365e <check_pgdir+0x191>
c010363a:	c7 44 24 0c fd 66 10 	movl   $0xc01066fd,0xc(%esp)
c0103641:	c0 
c0103642:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103649:	c0 
c010364a:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103651:	00 
c0103652:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103659:	e8 7f cd ff ff       	call   c01003dd <__panic>
    assert(page_ref(p1) == 1);
c010365e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103661:	89 04 24             	mov    %eax,(%esp)
c0103664:	e8 52 f3 ff ff       	call   c01029bb <page_ref>
c0103669:	83 f8 01             	cmp    $0x1,%eax
c010366c:	74 24                	je     c0103692 <check_pgdir+0x1c5>
c010366e:	c7 44 24 0c 13 67 10 	movl   $0xc0106713,0xc(%esp)
c0103675:	c0 
c0103676:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010367d:	c0 
c010367e:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103685:	00 
c0103686:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010368d:	e8 4b cd ff ff       	call   c01003dd <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103692:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103697:	8b 00                	mov    (%eax),%eax
c0103699:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010369e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01036a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036a4:	c1 e8 0c             	shr    $0xc,%eax
c01036a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01036aa:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01036af:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01036b2:	72 23                	jb     c01036d7 <check_pgdir+0x20a>
c01036b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036bb:	c7 44 24 08 e0 64 10 	movl   $0xc01064e0,0x8(%esp)
c01036c2:	c0 
c01036c3:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c01036ca:	00 
c01036cb:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01036d2:	e8 06 cd ff ff       	call   c01003dd <__panic>
c01036d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036da:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01036df:	83 c0 04             	add    $0x4,%eax
c01036e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01036e5:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01036ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036f1:	00 
c01036f2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01036f9:	00 
c01036fa:	89 04 24             	mov    %eax,(%esp)
c01036fd:	e8 f0 fb ff ff       	call   c01032f2 <get_pte>
c0103702:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103705:	74 24                	je     c010372b <check_pgdir+0x25e>
c0103707:	c7 44 24 0c 28 67 10 	movl   $0xc0106728,0xc(%esp)
c010370e:	c0 
c010370f:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103716:	c0 
c0103717:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c010371e:	00 
c010371f:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103726:	e8 b2 cc ff ff       	call   c01003dd <__panic>

    p2 = alloc_page();
c010372b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103732:	e8 7c f4 ff ff       	call   c0102bb3 <alloc_pages>
c0103737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010373a:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010373f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103746:	00 
c0103747:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010374e:	00 
c010374f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103752:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103756:	89 04 24             	mov    %eax,(%esp)
c0103759:	e8 3b fc ff ff       	call   c0103399 <page_insert>
c010375e:	85 c0                	test   %eax,%eax
c0103760:	74 24                	je     c0103786 <check_pgdir+0x2b9>
c0103762:	c7 44 24 0c 50 67 10 	movl   $0xc0106750,0xc(%esp)
c0103769:	c0 
c010376a:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103771:	c0 
c0103772:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0103779:	00 
c010377a:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103781:	e8 57 cc ff ff       	call   c01003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103786:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010378b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103792:	00 
c0103793:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010379a:	00 
c010379b:	89 04 24             	mov    %eax,(%esp)
c010379e:	e8 4f fb ff ff       	call   c01032f2 <get_pte>
c01037a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01037a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01037aa:	75 24                	jne    c01037d0 <check_pgdir+0x303>
c01037ac:	c7 44 24 0c 88 67 10 	movl   $0xc0106788,0xc(%esp)
c01037b3:	c0 
c01037b4:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01037bb:	c0 
c01037bc:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01037c3:	00 
c01037c4:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01037cb:	e8 0d cc ff ff       	call   c01003dd <__panic>
    assert(*ptep & PTE_U);
c01037d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037d3:	8b 00                	mov    (%eax),%eax
c01037d5:	83 e0 04             	and    $0x4,%eax
c01037d8:	85 c0                	test   %eax,%eax
c01037da:	75 24                	jne    c0103800 <check_pgdir+0x333>
c01037dc:	c7 44 24 0c b8 67 10 	movl   $0xc01067b8,0xc(%esp)
c01037e3:	c0 
c01037e4:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01037eb:	c0 
c01037ec:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c01037f3:	00 
c01037f4:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01037fb:	e8 dd cb ff ff       	call   c01003dd <__panic>
    assert(*ptep & PTE_W);
c0103800:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103803:	8b 00                	mov    (%eax),%eax
c0103805:	83 e0 02             	and    $0x2,%eax
c0103808:	85 c0                	test   %eax,%eax
c010380a:	75 24                	jne    c0103830 <check_pgdir+0x363>
c010380c:	c7 44 24 0c c6 67 10 	movl   $0xc01067c6,0xc(%esp)
c0103813:	c0 
c0103814:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010381b:	c0 
c010381c:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103823:	00 
c0103824:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010382b:	e8 ad cb ff ff       	call   c01003dd <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103830:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103835:	8b 00                	mov    (%eax),%eax
c0103837:	83 e0 04             	and    $0x4,%eax
c010383a:	85 c0                	test   %eax,%eax
c010383c:	75 24                	jne    c0103862 <check_pgdir+0x395>
c010383e:	c7 44 24 0c d4 67 10 	movl   $0xc01067d4,0xc(%esp)
c0103845:	c0 
c0103846:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010384d:	c0 
c010384e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103855:	00 
c0103856:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010385d:	e8 7b cb ff ff       	call   c01003dd <__panic>
    assert(page_ref(p2) == 1);
c0103862:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103865:	89 04 24             	mov    %eax,(%esp)
c0103868:	e8 4e f1 ff ff       	call   c01029bb <page_ref>
c010386d:	83 f8 01             	cmp    $0x1,%eax
c0103870:	74 24                	je     c0103896 <check_pgdir+0x3c9>
c0103872:	c7 44 24 0c ea 67 10 	movl   $0xc01067ea,0xc(%esp)
c0103879:	c0 
c010387a:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103881:	c0 
c0103882:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0103889:	00 
c010388a:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103891:	e8 47 cb ff ff       	call   c01003dd <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103896:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010389b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01038a2:	00 
c01038a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01038aa:	00 
c01038ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038ae:	89 54 24 04          	mov    %edx,0x4(%esp)
c01038b2:	89 04 24             	mov    %eax,(%esp)
c01038b5:	e8 df fa ff ff       	call   c0103399 <page_insert>
c01038ba:	85 c0                	test   %eax,%eax
c01038bc:	74 24                	je     c01038e2 <check_pgdir+0x415>
c01038be:	c7 44 24 0c fc 67 10 	movl   $0xc01067fc,0xc(%esp)
c01038c5:	c0 
c01038c6:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01038cd:	c0 
c01038ce:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c01038d5:	00 
c01038d6:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01038dd:	e8 fb ca ff ff       	call   c01003dd <__panic>
    assert(page_ref(p1) == 2);
c01038e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e5:	89 04 24             	mov    %eax,(%esp)
c01038e8:	e8 ce f0 ff ff       	call   c01029bb <page_ref>
c01038ed:	83 f8 02             	cmp    $0x2,%eax
c01038f0:	74 24                	je     c0103916 <check_pgdir+0x449>
c01038f2:	c7 44 24 0c 28 68 10 	movl   $0xc0106828,0xc(%esp)
c01038f9:	c0 
c01038fa:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103901:	c0 
c0103902:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103909:	00 
c010390a:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103911:	e8 c7 ca ff ff       	call   c01003dd <__panic>
    assert(page_ref(p2) == 0);
c0103916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103919:	89 04 24             	mov    %eax,(%esp)
c010391c:	e8 9a f0 ff ff       	call   c01029bb <page_ref>
c0103921:	85 c0                	test   %eax,%eax
c0103923:	74 24                	je     c0103949 <check_pgdir+0x47c>
c0103925:	c7 44 24 0c 3a 68 10 	movl   $0xc010683a,0xc(%esp)
c010392c:	c0 
c010392d:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103934:	c0 
c0103935:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c010393c:	00 
c010393d:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103944:	e8 94 ca ff ff       	call   c01003dd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103949:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010394e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103955:	00 
c0103956:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010395d:	00 
c010395e:	89 04 24             	mov    %eax,(%esp)
c0103961:	e8 8c f9 ff ff       	call   c01032f2 <get_pte>
c0103966:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103969:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010396d:	75 24                	jne    c0103993 <check_pgdir+0x4c6>
c010396f:	c7 44 24 0c 88 67 10 	movl   $0xc0106788,0xc(%esp)
c0103976:	c0 
c0103977:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c010397e:	c0 
c010397f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103986:	00 
c0103987:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c010398e:	e8 4a ca ff ff       	call   c01003dd <__panic>
    assert(pte2page(*ptep) == p1);
c0103993:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103996:	8b 00                	mov    (%eax),%eax
c0103998:	89 04 24             	mov    %eax,(%esp)
c010399b:	e8 c5 ef ff ff       	call   c0102965 <pte2page>
c01039a0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01039a3:	74 24                	je     c01039c9 <check_pgdir+0x4fc>
c01039a5:	c7 44 24 0c fd 66 10 	movl   $0xc01066fd,0xc(%esp)
c01039ac:	c0 
c01039ad:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01039b4:	c0 
c01039b5:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c01039bc:	00 
c01039bd:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01039c4:	e8 14 ca ff ff       	call   c01003dd <__panic>
    assert((*ptep & PTE_U) == 0);
c01039c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039cc:	8b 00                	mov    (%eax),%eax
c01039ce:	83 e0 04             	and    $0x4,%eax
c01039d1:	85 c0                	test   %eax,%eax
c01039d3:	74 24                	je     c01039f9 <check_pgdir+0x52c>
c01039d5:	c7 44 24 0c 4c 68 10 	movl   $0xc010684c,0xc(%esp)
c01039dc:	c0 
c01039dd:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c01039e4:	c0 
c01039e5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c01039ec:	00 
c01039ed:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c01039f4:	e8 e4 c9 ff ff       	call   c01003dd <__panic>

    page_remove(boot_pgdir, 0x0);
c01039f9:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01039fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103a05:	00 
c0103a06:	89 04 24             	mov    %eax,(%esp)
c0103a09:	e8 47 f9 ff ff       	call   c0103355 <page_remove>
    assert(page_ref(p1) == 1);
c0103a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a11:	89 04 24             	mov    %eax,(%esp)
c0103a14:	e8 a2 ef ff ff       	call   c01029bb <page_ref>
c0103a19:	83 f8 01             	cmp    $0x1,%eax
c0103a1c:	74 24                	je     c0103a42 <check_pgdir+0x575>
c0103a1e:	c7 44 24 0c 13 67 10 	movl   $0xc0106713,0xc(%esp)
c0103a25:	c0 
c0103a26:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103a35:	00 
c0103a36:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103a3d:	e8 9b c9 ff ff       	call   c01003dd <__panic>
    assert(page_ref(p2) == 0);
c0103a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a45:	89 04 24             	mov    %eax,(%esp)
c0103a48:	e8 6e ef ff ff       	call   c01029bb <page_ref>
c0103a4d:	85 c0                	test   %eax,%eax
c0103a4f:	74 24                	je     c0103a75 <check_pgdir+0x5a8>
c0103a51:	c7 44 24 0c 3a 68 10 	movl   $0xc010683a,0xc(%esp)
c0103a58:	c0 
c0103a59:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103a60:	c0 
c0103a61:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103a68:	00 
c0103a69:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103a70:	e8 68 c9 ff ff       	call   c01003dd <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103a75:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103a7a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a81:	00 
c0103a82:	89 04 24             	mov    %eax,(%esp)
c0103a85:	e8 cb f8 ff ff       	call   c0103355 <page_remove>
    assert(page_ref(p1) == 0);
c0103a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8d:	89 04 24             	mov    %eax,(%esp)
c0103a90:	e8 26 ef ff ff       	call   c01029bb <page_ref>
c0103a95:	85 c0                	test   %eax,%eax
c0103a97:	74 24                	je     c0103abd <check_pgdir+0x5f0>
c0103a99:	c7 44 24 0c 61 68 10 	movl   $0xc0106861,0xc(%esp)
c0103aa0:	c0 
c0103aa1:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103aa8:	c0 
c0103aa9:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103ab0:	00 
c0103ab1:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103ab8:	e8 20 c9 ff ff       	call   c01003dd <__panic>
    assert(page_ref(p2) == 0);
c0103abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ac0:	89 04 24             	mov    %eax,(%esp)
c0103ac3:	e8 f3 ee ff ff       	call   c01029bb <page_ref>
c0103ac8:	85 c0                	test   %eax,%eax
c0103aca:	74 24                	je     c0103af0 <check_pgdir+0x623>
c0103acc:	c7 44 24 0c 3a 68 10 	movl   $0xc010683a,0xc(%esp)
c0103ad3:	c0 
c0103ad4:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103adb:	c0 
c0103adc:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103ae3:	00 
c0103ae4:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103aeb:	e8 ed c8 ff ff       	call   c01003dd <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103af0:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103af5:	8b 00                	mov    (%eax),%eax
c0103af7:	89 04 24             	mov    %eax,(%esp)
c0103afa:	e8 a4 ee ff ff       	call   c01029a3 <pde2page>
c0103aff:	89 04 24             	mov    %eax,(%esp)
c0103b02:	e8 b4 ee ff ff       	call   c01029bb <page_ref>
c0103b07:	83 f8 01             	cmp    $0x1,%eax
c0103b0a:	74 24                	je     c0103b30 <check_pgdir+0x663>
c0103b0c:	c7 44 24 0c 74 68 10 	movl   $0xc0106874,0xc(%esp)
c0103b13:	c0 
c0103b14:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103b1b:	c0 
c0103b1c:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103b23:	00 
c0103b24:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103b2b:	e8 ad c8 ff ff       	call   c01003dd <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103b30:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103b35:	8b 00                	mov    (%eax),%eax
c0103b37:	89 04 24             	mov    %eax,(%esp)
c0103b3a:	e8 64 ee ff ff       	call   c01029a3 <pde2page>
c0103b3f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b46:	00 
c0103b47:	89 04 24             	mov    %eax,(%esp)
c0103b4a:	e8 9c f0 ff ff       	call   c0102beb <free_pages>
    boot_pgdir[0] = 0;
c0103b4f:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103b5a:	c7 04 24 9b 68 10 c0 	movl   $0xc010689b,(%esp)
c0103b61:	e8 20 c7 ff ff       	call   c0100286 <cprintf>
}
c0103b66:	c9                   	leave  
c0103b67:	c3                   	ret    

c0103b68 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103b68:	55                   	push   %ebp
c0103b69:	89 e5                	mov    %esp,%ebp
c0103b6b:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b75:	e9 ca 00 00 00       	jmp    c0103c44 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b83:	c1 e8 0c             	shr    $0xc,%eax
c0103b86:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b89:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103b8e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103b91:	72 23                	jb     c0103bb6 <check_boot_pgdir+0x4e>
c0103b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b96:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b9a:	c7 44 24 08 e0 64 10 	movl   $0xc01064e0,0x8(%esp)
c0103ba1:	c0 
c0103ba2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0103ba9:	00 
c0103baa:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103bb1:	e8 27 c8 ff ff       	call   c01003dd <__panic>
c0103bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bb9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103bbe:	89 c2                	mov    %eax,%edx
c0103bc0:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103bc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103bcc:	00 
c0103bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103bd1:	89 04 24             	mov    %eax,(%esp)
c0103bd4:	e8 19 f7 ff ff       	call   c01032f2 <get_pte>
c0103bd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103bdc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103be0:	75 24                	jne    c0103c06 <check_boot_pgdir+0x9e>
c0103be2:	c7 44 24 0c b8 68 10 	movl   $0xc01068b8,0xc(%esp)
c0103be9:	c0 
c0103bea:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103bf1:	c0 
c0103bf2:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0103bf9:	00 
c0103bfa:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103c01:	e8 d7 c7 ff ff       	call   c01003dd <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c09:	8b 00                	mov    (%eax),%eax
c0103c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c10:	89 c2                	mov    %eax,%edx
c0103c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c15:	39 c2                	cmp    %eax,%edx
c0103c17:	74 24                	je     c0103c3d <check_boot_pgdir+0xd5>
c0103c19:	c7 44 24 0c f5 68 10 	movl   $0xc01068f5,0xc(%esp)
c0103c20:	c0 
c0103c21:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103c28:	c0 
c0103c29:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0103c30:	00 
c0103c31:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103c38:	e8 a0 c7 ff ff       	call   c01003dd <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103c3d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103c44:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103c47:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103c4c:	39 c2                	cmp    %eax,%edx
c0103c4e:	0f 82 26 ff ff ff    	jb     c0103b7a <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103c54:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103c59:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103c5e:	8b 00                	mov    (%eax),%eax
c0103c60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c65:	89 c2                	mov    %eax,%edx
c0103c67:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103c6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c6f:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103c76:	77 23                	ja     c0103c9b <check_boot_pgdir+0x133>
c0103c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c7f:	c7 44 24 08 84 65 10 	movl   $0xc0106584,0x8(%esp)
c0103c86:	c0 
c0103c87:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103c8e:	00 
c0103c8f:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103c96:	e8 42 c7 ff ff       	call   c01003dd <__panic>
c0103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c9e:	05 00 00 00 40       	add    $0x40000000,%eax
c0103ca3:	39 c2                	cmp    %eax,%edx
c0103ca5:	74 24                	je     c0103ccb <check_boot_pgdir+0x163>
c0103ca7:	c7 44 24 0c 0c 69 10 	movl   $0xc010690c,0xc(%esp)
c0103cae:	c0 
c0103caf:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103cb6:	c0 
c0103cb7:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103cbe:	00 
c0103cbf:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103cc6:	e8 12 c7 ff ff       	call   c01003dd <__panic>

    assert(boot_pgdir[0] == 0);
c0103ccb:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103cd0:	8b 00                	mov    (%eax),%eax
c0103cd2:	85 c0                	test   %eax,%eax
c0103cd4:	74 24                	je     c0103cfa <check_boot_pgdir+0x192>
c0103cd6:	c7 44 24 0c 40 69 10 	movl   $0xc0106940,0xc(%esp)
c0103cdd:	c0 
c0103cde:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103ce5:	c0 
c0103ce6:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0103ced:	00 
c0103cee:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103cf5:	e8 e3 c6 ff ff       	call   c01003dd <__panic>

    struct Page *p;
    p = alloc_page();
c0103cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d01:	e8 ad ee ff ff       	call   c0102bb3 <alloc_pages>
c0103d06:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103d09:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103d0e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103d15:	00 
c0103d16:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103d1d:	00 
c0103d1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103d21:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d25:	89 04 24             	mov    %eax,(%esp)
c0103d28:	e8 6c f6 ff ff       	call   c0103399 <page_insert>
c0103d2d:	85 c0                	test   %eax,%eax
c0103d2f:	74 24                	je     c0103d55 <check_boot_pgdir+0x1ed>
c0103d31:	c7 44 24 0c 54 69 10 	movl   $0xc0106954,0xc(%esp)
c0103d38:	c0 
c0103d39:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103d40:	c0 
c0103d41:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103d48:	00 
c0103d49:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103d50:	e8 88 c6 ff ff       	call   c01003dd <__panic>
    assert(page_ref(p) == 1);
c0103d55:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d58:	89 04 24             	mov    %eax,(%esp)
c0103d5b:	e8 5b ec ff ff       	call   c01029bb <page_ref>
c0103d60:	83 f8 01             	cmp    $0x1,%eax
c0103d63:	74 24                	je     c0103d89 <check_boot_pgdir+0x221>
c0103d65:	c7 44 24 0c 82 69 10 	movl   $0xc0106982,0xc(%esp)
c0103d6c:	c0 
c0103d6d:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103d74:	c0 
c0103d75:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0103d7c:	00 
c0103d7d:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103d84:	e8 54 c6 ff ff       	call   c01003dd <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103d89:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103d8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103d95:	00 
c0103d96:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103d9d:	00 
c0103d9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103da1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103da5:	89 04 24             	mov    %eax,(%esp)
c0103da8:	e8 ec f5 ff ff       	call   c0103399 <page_insert>
c0103dad:	85 c0                	test   %eax,%eax
c0103daf:	74 24                	je     c0103dd5 <check_boot_pgdir+0x26d>
c0103db1:	c7 44 24 0c 94 69 10 	movl   $0xc0106994,0xc(%esp)
c0103db8:	c0 
c0103db9:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103dc0:	c0 
c0103dc1:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0103dc8:	00 
c0103dc9:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103dd0:	e8 08 c6 ff ff       	call   c01003dd <__panic>
    assert(page_ref(p) == 2);
c0103dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103dd8:	89 04 24             	mov    %eax,(%esp)
c0103ddb:	e8 db eb ff ff       	call   c01029bb <page_ref>
c0103de0:	83 f8 02             	cmp    $0x2,%eax
c0103de3:	74 24                	je     c0103e09 <check_boot_pgdir+0x2a1>
c0103de5:	c7 44 24 0c cb 69 10 	movl   $0xc01069cb,0xc(%esp)
c0103dec:	c0 
c0103ded:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103df4:	c0 
c0103df5:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103dfc:	00 
c0103dfd:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103e04:	e8 d4 c5 ff ff       	call   c01003dd <__panic>

    const char *str = "ucore: Hello world!!";
c0103e09:	c7 45 dc dc 69 10 c0 	movl   $0xc01069dc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103e10:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e17:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103e1e:	e8 99 14 00 00       	call   c01052bc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103e23:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103e2a:	00 
c0103e2b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103e32:	e8 fe 14 00 00       	call   c0105335 <strcmp>
c0103e37:	85 c0                	test   %eax,%eax
c0103e39:	74 24                	je     c0103e5f <check_boot_pgdir+0x2f7>
c0103e3b:	c7 44 24 0c f4 69 10 	movl   $0xc01069f4,0xc(%esp)
c0103e42:	c0 
c0103e43:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103e4a:	c0 
c0103e4b:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0103e52:	00 
c0103e53:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103e5a:	e8 7e c5 ff ff       	call   c01003dd <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e62:	89 04 24             	mov    %eax,(%esp)
c0103e65:	e8 a7 ea ff ff       	call   c0102911 <page2kva>
c0103e6a:	05 00 01 00 00       	add    $0x100,%eax
c0103e6f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103e72:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103e79:	e8 e6 13 00 00       	call   c0105264 <strlen>
c0103e7e:	85 c0                	test   %eax,%eax
c0103e80:	74 24                	je     c0103ea6 <check_boot_pgdir+0x33e>
c0103e82:	c7 44 24 0c 2c 6a 10 	movl   $0xc0106a2c,0xc(%esp)
c0103e89:	c0 
c0103e8a:	c7 44 24 08 cd 65 10 	movl   $0xc01065cd,0x8(%esp)
c0103e91:	c0 
c0103e92:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0103e99:	00 
c0103e9a:	c7 04 24 a8 65 10 c0 	movl   $0xc01065a8,(%esp)
c0103ea1:	e8 37 c5 ff ff       	call   c01003dd <__panic>

    free_page(p);
c0103ea6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ead:	00 
c0103eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eb1:	89 04 24             	mov    %eax,(%esp)
c0103eb4:	e8 32 ed ff ff       	call   c0102beb <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103eb9:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103ebe:	8b 00                	mov    (%eax),%eax
c0103ec0:	89 04 24             	mov    %eax,(%esp)
c0103ec3:	e8 db ea ff ff       	call   c01029a3 <pde2page>
c0103ec8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ecf:	00 
c0103ed0:	89 04 24             	mov    %eax,(%esp)
c0103ed3:	e8 13 ed ff ff       	call   c0102beb <free_pages>
    boot_pgdir[0] = 0;
c0103ed8:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0103edd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103ee3:	c7 04 24 50 6a 10 c0 	movl   $0xc0106a50,(%esp)
c0103eea:	e8 97 c3 ff ff       	call   c0100286 <cprintf>
}
c0103eef:	c9                   	leave  
c0103ef0:	c3                   	ret    

c0103ef1 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103ef1:	55                   	push   %ebp
c0103ef2:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ef7:	83 e0 04             	and    $0x4,%eax
c0103efa:	85 c0                	test   %eax,%eax
c0103efc:	74 07                	je     c0103f05 <perm2str+0x14>
c0103efe:	b8 75 00 00 00       	mov    $0x75,%eax
c0103f03:	eb 05                	jmp    c0103f0a <perm2str+0x19>
c0103f05:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103f0a:	a2 48 89 11 c0       	mov    %al,0xc0118948
    str[1] = 'r';
c0103f0f:	c6 05 49 89 11 c0 72 	movb   $0x72,0xc0118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103f16:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f19:	83 e0 02             	and    $0x2,%eax
c0103f1c:	85 c0                	test   %eax,%eax
c0103f1e:	74 07                	je     c0103f27 <perm2str+0x36>
c0103f20:	b8 77 00 00 00       	mov    $0x77,%eax
c0103f25:	eb 05                	jmp    c0103f2c <perm2str+0x3b>
c0103f27:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0103f2c:	a2 4a 89 11 c0       	mov    %al,0xc011894a
    str[3] = '\0';
c0103f31:	c6 05 4b 89 11 c0 00 	movb   $0x0,0xc011894b
    return str;
c0103f38:	b8 48 89 11 c0       	mov    $0xc0118948,%eax
}
c0103f3d:	5d                   	pop    %ebp
c0103f3e:	c3                   	ret    

c0103f3f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103f3f:	55                   	push   %ebp
c0103f40:	89 e5                	mov    %esp,%ebp
c0103f42:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103f45:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f48:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f4b:	72 0a                	jb     c0103f57 <get_pgtable_items+0x18>
        return 0;
c0103f4d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103f52:	e9 9c 00 00 00       	jmp    c0103ff3 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0103f57:	eb 04                	jmp    c0103f5d <get_pgtable_items+0x1e>
        start ++;
c0103f59:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0103f5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f60:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f63:	73 18                	jae    c0103f7d <get_pgtable_items+0x3e>
c0103f65:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103f6f:	8b 45 14             	mov    0x14(%ebp),%eax
c0103f72:	01 d0                	add    %edx,%eax
c0103f74:	8b 00                	mov    (%eax),%eax
c0103f76:	83 e0 01             	and    $0x1,%eax
c0103f79:	85 c0                	test   %eax,%eax
c0103f7b:	74 dc                	je     c0103f59 <get_pgtable_items+0x1a>
    }
    if (start < right) {
c0103f7d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f80:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103f83:	73 69                	jae    c0103fee <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0103f85:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103f89:	74 08                	je     c0103f93 <get_pgtable_items+0x54>
            *left_store = start;
c0103f8b:	8b 45 18             	mov    0x18(%ebp),%eax
c0103f8e:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f91:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0103f93:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f96:	8d 50 01             	lea    0x1(%eax),%edx
c0103f99:	89 55 10             	mov    %edx,0x10(%ebp)
c0103f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103fa3:	8b 45 14             	mov    0x14(%ebp),%eax
c0103fa6:	01 d0                	add    %edx,%eax
c0103fa8:	8b 00                	mov    (%eax),%eax
c0103faa:	83 e0 07             	and    $0x7,%eax
c0103fad:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103fb0:	eb 04                	jmp    c0103fb6 <get_pgtable_items+0x77>
            start ++;
c0103fb2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0103fb6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103fb9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103fbc:	73 1d                	jae    c0103fdb <get_pgtable_items+0x9c>
c0103fbe:	8b 45 10             	mov    0x10(%ebp),%eax
c0103fc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103fc8:	8b 45 14             	mov    0x14(%ebp),%eax
c0103fcb:	01 d0                	add    %edx,%eax
c0103fcd:	8b 00                	mov    (%eax),%eax
c0103fcf:	83 e0 07             	and    $0x7,%eax
c0103fd2:	89 c2                	mov    %eax,%edx
c0103fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fd7:	39 c2                	cmp    %eax,%edx
c0103fd9:	74 d7                	je     c0103fb2 <get_pgtable_items+0x73>
        }
        if (right_store != NULL) {
c0103fdb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103fdf:	74 08                	je     c0103fe9 <get_pgtable_items+0xaa>
            *right_store = start;
c0103fe1:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103fe4:	8b 55 10             	mov    0x10(%ebp),%edx
c0103fe7:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0103fe9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103fec:	eb 05                	jmp    c0103ff3 <get_pgtable_items+0xb4>
    }
    return 0;
c0103fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103ff3:	c9                   	leave  
c0103ff4:	c3                   	ret    

c0103ff5 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0103ff5:	55                   	push   %ebp
c0103ff6:	89 e5                	mov    %esp,%ebp
c0103ff8:	57                   	push   %edi
c0103ff9:	56                   	push   %esi
c0103ffa:	53                   	push   %ebx
c0103ffb:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0103ffe:	c7 04 24 70 6a 10 c0 	movl   $0xc0106a70,(%esp)
c0104005:	e8 7c c2 ff ff       	call   c0100286 <cprintf>
    size_t left, right = 0, perm;
c010400a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104011:	e9 fa 00 00 00       	jmp    c0104110 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104019:	89 04 24             	mov    %eax,(%esp)
c010401c:	e8 d0 fe ff ff       	call   c0103ef1 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104021:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104024:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104027:	29 d1                	sub    %edx,%ecx
c0104029:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010402b:	89 d6                	mov    %edx,%esi
c010402d:	c1 e6 16             	shl    $0x16,%esi
c0104030:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104033:	89 d3                	mov    %edx,%ebx
c0104035:	c1 e3 16             	shl    $0x16,%ebx
c0104038:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010403b:	89 d1                	mov    %edx,%ecx
c010403d:	c1 e1 16             	shl    $0x16,%ecx
c0104040:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104043:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104046:	29 d7                	sub    %edx,%edi
c0104048:	89 fa                	mov    %edi,%edx
c010404a:	89 44 24 14          	mov    %eax,0x14(%esp)
c010404e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104052:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104056:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010405a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010405e:	c7 04 24 a1 6a 10 c0 	movl   $0xc0106aa1,(%esp)
c0104065:	e8 1c c2 ff ff       	call   c0100286 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010406a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010406d:	c1 e0 0a             	shl    $0xa,%eax
c0104070:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104073:	eb 54                	jmp    c01040c9 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104078:	89 04 24             	mov    %eax,(%esp)
c010407b:	e8 71 fe ff ff       	call   c0103ef1 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104080:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104083:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104086:	29 d1                	sub    %edx,%ecx
c0104088:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010408a:	89 d6                	mov    %edx,%esi
c010408c:	c1 e6 0c             	shl    $0xc,%esi
c010408f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104092:	89 d3                	mov    %edx,%ebx
c0104094:	c1 e3 0c             	shl    $0xc,%ebx
c0104097:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010409a:	c1 e2 0c             	shl    $0xc,%edx
c010409d:	89 d1                	mov    %edx,%ecx
c010409f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01040a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01040a5:	29 d7                	sub    %edx,%edi
c01040a7:	89 fa                	mov    %edi,%edx
c01040a9:	89 44 24 14          	mov    %eax,0x14(%esp)
c01040ad:	89 74 24 10          	mov    %esi,0x10(%esp)
c01040b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01040b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01040b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01040bd:	c7 04 24 c0 6a 10 c0 	movl   $0xc0106ac0,(%esp)
c01040c4:	e8 bd c1 ff ff       	call   c0100286 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01040c9:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01040ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01040d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01040d4:	89 ce                	mov    %ecx,%esi
c01040d6:	c1 e6 0a             	shl    $0xa,%esi
c01040d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01040dc:	89 cb                	mov    %ecx,%ebx
c01040de:	c1 e3 0a             	shl    $0xa,%ebx
c01040e1:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01040e4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01040e8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01040eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01040ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01040f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01040f7:	89 74 24 04          	mov    %esi,0x4(%esp)
c01040fb:	89 1c 24             	mov    %ebx,(%esp)
c01040fe:	e8 3c fe ff ff       	call   c0103f3f <get_pgtable_items>
c0104103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010410a:	0f 85 65 ff ff ff    	jne    c0104075 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104110:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0104115:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104118:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010411b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010411f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0104122:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0104126:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010412a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010412e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104135:	00 
c0104136:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010413d:	e8 fd fd ff ff       	call   c0103f3f <get_pgtable_items>
c0104142:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104145:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104149:	0f 85 c7 fe ff ff    	jne    c0104016 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010414f:	c7 04 24 e4 6a 10 c0 	movl   $0xc0106ae4,(%esp)
c0104156:	e8 2b c1 ff ff       	call   c0100286 <cprintf>
}
c010415b:	83 c4 4c             	add    $0x4c,%esp
c010415e:	5b                   	pop    %ebx
c010415f:	5e                   	pop    %esi
c0104160:	5f                   	pop    %edi
c0104161:	5d                   	pop    %ebp
c0104162:	c3                   	ret    

c0104163 <page2ppn>:
page2ppn(struct Page *page) {
c0104163:	55                   	push   %ebp
c0104164:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104166:	8b 55 08             	mov    0x8(%ebp),%edx
c0104169:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c010416e:	29 c2                	sub    %eax,%edx
c0104170:	89 d0                	mov    %edx,%eax
c0104172:	c1 f8 02             	sar    $0x2,%eax
c0104175:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010417b:	5d                   	pop    %ebp
c010417c:	c3                   	ret    

c010417d <page2pa>:
page2pa(struct Page *page) {
c010417d:	55                   	push   %ebp
c010417e:	89 e5                	mov    %esp,%ebp
c0104180:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104183:	8b 45 08             	mov    0x8(%ebp),%eax
c0104186:	89 04 24             	mov    %eax,(%esp)
c0104189:	e8 d5 ff ff ff       	call   c0104163 <page2ppn>
c010418e:	c1 e0 0c             	shl    $0xc,%eax
}
c0104191:	c9                   	leave  
c0104192:	c3                   	ret    

c0104193 <page_ref>:
page_ref(struct Page *page) {
c0104193:	55                   	push   %ebp
c0104194:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104196:	8b 45 08             	mov    0x8(%ebp),%eax
c0104199:	8b 00                	mov    (%eax),%eax
}
c010419b:	5d                   	pop    %ebp
c010419c:	c3                   	ret    

c010419d <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010419d:	55                   	push   %ebp
c010419e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01041a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01041a3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01041a6:	89 10                	mov    %edx,(%eax)
}
c01041a8:	5d                   	pop    %ebp
c01041a9:	c3                   	ret    

c01041aa <default_init>:
/**
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 */
static void
default_init(void) {
c01041aa:	55                   	push   %ebp
c01041ab:	89 e5                	mov    %esp,%ebp
c01041ad:	83 ec 10             	sub    $0x10,%esp
c01041b0:	c7 45 fc 5c 89 11 c0 	movl   $0xc011895c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01041b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01041ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01041bd:	89 50 04             	mov    %edx,0x4(%eax)
c01041c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01041c3:	8b 50 04             	mov    0x4(%eax),%edx
c01041c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01041c9:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01041cb:	c7 05 64 89 11 c0 00 	movl   $0x0,0xc0118964
c01041d2:	00 00 00 
}
c01041d5:	c9                   	leave  
c01041d6:	c3                   	ret    

c01041d7 <default_init_memmap>:
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * @param base
 * @param n
 */
static void
default_init_memmap(struct Page *base, size_t n) {
c01041d7:	55                   	push   %ebp
c01041d8:	89 e5                	mov    %esp,%ebp
c01041da:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01041dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01041e1:	75 24                	jne    c0104207 <default_init_memmap+0x30>
c01041e3:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c01041ea:	c0 
c01041eb:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01041f2:	c0 
c01041f3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01041fa:	00 
c01041fb:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104202:	e8 d6 c1 ff ff       	call   c01003dd <__panic>
    struct Page *p = base;
c0104207:	8b 45 08             	mov    0x8(%ebp),%eax
c010420a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010420d:	e9 d2 00 00 00       	jmp    c01042e4 <default_init_memmap+0x10d>
        assert(PageReserved(p));
c0104212:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104215:	83 c0 04             	add    $0x4,%eax
c0104218:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010421f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104222:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104225:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104228:	0f a3 10             	bt     %edx,(%eax)
c010422b:	19 c0                	sbb    %eax,%eax
c010422d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104230:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104234:	0f 95 c0             	setne  %al
c0104237:	0f b6 c0             	movzbl %al,%eax
c010423a:	85 c0                	test   %eax,%eax
c010423c:	75 24                	jne    c0104262 <default_init_memmap+0x8b>
c010423e:	c7 44 24 0c 49 6b 10 	movl   $0xc0106b49,0xc(%esp)
c0104245:	c0 
c0104246:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010424d:	c0 
c010424e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104255:	00 
c0104256:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010425d:	e8 7b c1 ff ff       	call   c01003dd <__panic>
        set_page_ref(p, 0);
c0104262:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104269:	00 
c010426a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010426d:	89 04 24             	mov    %eax,(%esp)
c0104270:	e8 28 ff ff ff       	call   c010419d <set_page_ref>
        //p的ref指针设置为0,因为该页未被使用
        SetPageProperty(p);
c0104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104278:	83 c0 04             	add    $0x4,%eax
c010427b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0104282:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104285:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010428b:	0f ab 10             	bts    %edx,(%eax)
        //页面刚刚初始化，未被保留
        p->property=0;
c010428e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104291:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(&free_list, &(p->page_link));
c0104298:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010429b:	83 c0 0c             	add    $0xc,%eax
c010429e:	c7 45 dc 5c 89 11 c0 	movl   $0xc011895c,-0x24(%ebp)
c01042a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01042a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042ab:	8b 00                	mov    (%eax),%eax
c01042ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01042b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01042b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01042b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01042bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01042bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01042c2:	89 10                	mov    %edx,(%eax)
c01042c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01042c7:	8b 10                	mov    (%eax),%edx
c01042c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01042cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01042cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01042d2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01042d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01042d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01042db:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01042de:	89 10                	mov    %edx,(%eax)
    for (; p != base + n; p ++) {
c01042e0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01042e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042e7:	89 d0                	mov    %edx,%eax
c01042e9:	c1 e0 02             	shl    $0x2,%eax
c01042ec:	01 d0                	add    %edx,%eax
c01042ee:	c1 e0 02             	shl    $0x2,%eax
c01042f1:	89 c2                	mov    %eax,%edx
c01042f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01042f6:	01 d0                	add    %edx,%eax
c01042f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01042fb:	0f 85 11 ff ff ff    	jne    c0104212 <default_init_memmap+0x3b>
    }
    base->property=n;
c0104301:	8b 45 08             	mov    0x8(%ebp),%eax
c0104304:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104307:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;//总可分配数量增加
c010430a:	8b 15 64 89 11 c0    	mov    0xc0118964,%edx
c0104310:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104313:	01 d0                	add    %edx,%eax
c0104315:	a3 64 89 11 c0       	mov    %eax,0xc0118964
}
c010431a:	c9                   	leave  
c010431b:	c3                   	ret    

c010431c <default_alloc_pages>:
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * @param n
 * @return
 */
static struct Page *
default_alloc_pages(size_t n) {
c010431c:	55                   	push   %ebp
c010431d:	89 e5                	mov    %esp,%ebp
c010431f:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104322:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104326:	75 24                	jne    c010434c <default_alloc_pages+0x30>
c0104328:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c010432f:	c0 
c0104330:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104337:	c0 
c0104338:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c010433f:	00 
c0104340:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104347:	e8 91 c0 ff ff       	call   c01003dd <__panic>
    if (n > nr_free) {
c010434c:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0104351:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104354:	73 0a                	jae    c0104360 <default_alloc_pages+0x44>
        return NULL;
c0104356:	b8 00 00 00 00       	mov    $0x0,%eax
c010435b:	e9 fc 00 00 00       	jmp    c010445c <default_alloc_pages+0x140>
    }
    struct Page *page = NULL;
c0104360:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    list_entry_t *le = &free_list;
c0104367:	c7 45 f4 5c 89 11 c0 	movl   $0xc011895c,-0xc(%ebp)

    while ((le = list_next(le)) != &free_list) {
c010436e:	e9 c8 00 00 00       	jmp    c010443b <default_alloc_pages+0x11f>
        struct Page *p = le2page(le, page_link);
c0104373:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104376:	83 e8 0c             	sub    $0xc,%eax
c0104379:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c010437c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010437f:	8b 40 08             	mov    0x8(%eax),%eax
c0104382:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104385:	0f 82 b0 00 00 00    	jb     c010443b <default_alloc_pages+0x11f>
            //找到了合适大小的块，可以进行分配
            struct Page *curPage=p;
c010438b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010438e:	89 45 f0             	mov    %eax,-0x10(%ebp)
            for(;curPage<p+n;curPage++){
c0104391:	eb 61                	jmp    c01043f4 <default_alloc_pages+0xd8>
                //遍历所有需要分配的PAGE 修改其相应属性为已经分配 并将其移除freelist
                ClearPageProperty(curPage);
c0104393:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104396:	83 c0 04             	add    $0x4,%eax
c0104399:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01043a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01043a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01043a9:	0f b3 10             	btr    %edx,(%eax)
                SetPageReserved(curPage);
c01043ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043af:	83 c0 04             	add    $0x4,%eax
c01043b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01043b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01043bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043c2:	0f ab 10             	bts    %edx,(%eax)
                list_del(&(curPage->page_link));
c01043c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043c8:	83 c0 0c             	add    $0xc,%eax
c01043cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01043ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043d1:	8b 40 04             	mov    0x4(%eax),%eax
c01043d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043d7:	8b 12                	mov    (%edx),%edx
c01043d9:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01043dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01043df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043e2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01043e5:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01043e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043ee:	89 10                	mov    %edx,(%eax)
            for(;curPage<p+n;curPage++){
c01043f0:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c01043f4:	8b 55 08             	mov    0x8(%ebp),%edx
c01043f7:	89 d0                	mov    %edx,%eax
c01043f9:	c1 e0 02             	shl    $0x2,%eax
c01043fc:	01 d0                	add    %edx,%eax
c01043fe:	c1 e0 02             	shl    $0x2,%eax
c0104401:	89 c2                	mov    %eax,%edx
c0104403:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104406:	01 d0                	add    %edx,%eax
c0104408:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010440b:	77 86                	ja     c0104393 <default_alloc_pages+0x77>
            }
            if(p->property>n){
c010440d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104410:	8b 40 08             	mov    0x8(%eax),%eax
c0104413:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104416:	76 11                	jbe    c0104429 <default_alloc_pages+0x10d>
                //如果分配后还存在外碎片，需要将外碎片数量更新为原大小减去分配量
                curPage->property=p->property-n;
c0104418:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010441b:	8b 40 08             	mov    0x8(%eax),%eax
c010441e:	2b 45 08             	sub    0x8(%ebp),%eax
c0104421:	89 c2                	mov    %eax,%edx
c0104423:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104426:	89 50 08             	mov    %edx,0x8(%eax)
            }
            nr_free-=n;//记得更新剩余页数量
c0104429:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c010442e:	2b 45 08             	sub    0x8(%ebp),%eax
c0104431:	a3 64 89 11 c0       	mov    %eax,0xc0118964
            return p;
c0104436:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104439:	eb 21                	jmp    c010445c <default_alloc_pages+0x140>
c010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010443e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return listelm->next;
c0104441:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104444:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104447:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010444a:	81 7d f4 5c 89 11 c0 	cmpl   $0xc011895c,-0xc(%ebp)
c0104451:	0f 85 1c ff ff ff    	jne    c0104373 <default_alloc_pages+0x57>
        }
    }

    return NULL;
c0104457:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010445c:	c9                   	leave  
c010445d:	c3                   	ret    

c010445e <default_free_pages>:
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 * @param base
 * @param n
 */
static void
default_free_pages(struct Page *base, size_t n) {
c010445e:	55                   	push   %ebp
c010445f:	89 e5                	mov    %esp,%ebp
c0104461:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
c0104464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104468:	75 24                	jne    c010448e <default_free_pages+0x30>
c010446a:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c0104471:	c0 
c0104472:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104479:	c0 
c010447a:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0104481:	00 
c0104482:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104489:	e8 4f bf ff ff       	call   c01003dd <__panic>
    assert(PageReserved(base));
c010448e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104491:	83 c0 04             	add    $0x4,%eax
c0104494:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010449b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010449e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01044a4:	0f a3 10             	bt     %edx,(%eax)
c01044a7:	19 c0                	sbb    %eax,%eax
c01044a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01044ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01044b0:	0f 95 c0             	setne  %al
c01044b3:	0f b6 c0             	movzbl %al,%eax
c01044b6:	85 c0                	test   %eax,%eax
c01044b8:	75 24                	jne    c01044de <default_free_pages+0x80>
c01044ba:	c7 44 24 0c 59 6b 10 	movl   $0xc0106b59,0xc(%esp)
c01044c1:	c0 
c01044c2:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01044c9:	c0 
c01044ca:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c01044d1:	00 
c01044d2:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c01044d9:	e8 ff be ff ff       	call   c01003dd <__panic>
    struct Page *p ;
    list_entry_t *le = &free_list;
c01044de:	c7 45 f0 5c 89 11 c0 	movl   $0xc011895c,-0x10(%ebp)
     while((le=list_next(le))!=&free_list){
c01044e5:	eb 13                	jmp    c01044fa <default_free_pages+0x9c>
         //理解这段代码：由于块已经分配出去，因此块没有被串在链表中，我们需要找到正确插入链表的位置，而page结构数组是不会改变的
         //要找到正确的插入位置，就需要找到链表中第一个在base前的page，然后就可以对要释放的块使用头插法：list_add_before()以此插入即可
         p=le2page(le,page_link);
c01044e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044ea:	83 e8 0c             	sub    $0xc,%eax
c01044ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
         if(p>base){
c01044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f3:	3b 45 08             	cmp    0x8(%ebp),%eax
c01044f6:	76 02                	jbe    c01044fa <default_free_pages+0x9c>
             break;
c01044f8:	eb 18                	jmp    c0104512 <default_free_pages+0xb4>
c01044fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104500:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104503:	8b 40 04             	mov    0x4(%eax),%eax
     while((le=list_next(le))!=&free_list){
c0104506:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104509:	81 7d f0 5c 89 11 c0 	cmpl   $0xc011895c,-0x10(%ebp)
c0104510:	75 d5                	jne    c01044e7 <default_free_pages+0x89>
         }
     }
     for(p=base;p<base+n;p++){
c0104512:	8b 45 08             	mov    0x8(%ebp),%eax
c0104515:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104518:	eb 77                	jmp    c0104591 <default_free_pages+0x133>
         ClearPageReserved(p);//移除保留状态
c010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010451d:	83 c0 04             	add    $0x4,%eax
c0104520:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104527:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010452a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010452d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104530:	0f b3 10             	btr    %edx,(%eax)
         set_page_ref(p,0);//设置引用数为0
c0104533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010453a:	00 
c010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010453e:	89 04 24             	mov    %eax,(%esp)
c0104541:	e8 57 fc ff ff       	call   c010419d <set_page_ref>
         list_add_before(le,&p->page_link);//加入链表
c0104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104549:	8d 50 0c             	lea    0xc(%eax),%edx
c010454c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010454f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0104552:	89 55 d0             	mov    %edx,-0x30(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104555:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104558:	8b 00                	mov    (%eax),%eax
c010455a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010455d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104560:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104563:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104566:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c0104569:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010456c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010456f:	89 10                	mov    %edx,(%eax)
c0104571:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104574:	8b 10                	mov    (%eax),%edx
c0104576:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104579:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010457c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010457f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104582:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104585:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104588:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010458b:	89 10                	mov    %edx,(%eax)
     for(p=base;p<base+n;p++){
c010458d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104591:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104594:	89 d0                	mov    %edx,%eax
c0104596:	c1 e0 02             	shl    $0x2,%eax
c0104599:	01 d0                	add    %edx,%eax
c010459b:	c1 e0 02             	shl    $0x2,%eax
c010459e:	89 c2                	mov    %eax,%edx
c01045a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a3:	01 d0                	add    %edx,%eax
c01045a5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01045a8:	0f 87 6c ff ff ff    	ja     c010451a <default_free_pages+0xbc>
     }
    SetPageProperty(base);//一个块的头页面需要设置property
c01045ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b1:	83 c0 04             	add    $0x4,%eax
c01045b4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01045bb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01045be:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01045c1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01045c4:	0f ab 10             	bts    %edx,(%eax)
    base->property=n;
c01045c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ca:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045cd:	89 50 08             	mov    %edx,0x8(%eax)
    p=le2page(le,page_link);
c01045d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045d3:	83 e8 0c             	sub    $0xc,%eax
c01045d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

    //除了加入空闲链表之外，还需要合并上方和下方的块
    if(p==base+n){
c01045d9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045dc:	89 d0                	mov    %edx,%eax
c01045de:	c1 e0 02             	shl    $0x2,%eax
c01045e1:	01 d0                	add    %edx,%eax
c01045e3:	c1 e0 02             	shl    $0x2,%eax
c01045e6:	89 c2                	mov    %eax,%edx
c01045e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045eb:	01 d0                	add    %edx,%eax
c01045ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01045f0:	75 37                	jne    c0104629 <default_free_pages+0x1cb>
        //下方的块合并较为简单，判断链表的下一个页是否正好是相邻的页，如果是，则直接将property加入到base页，然后清空该页的property
        base->property+=p->property;
c01045f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f5:	8b 50 08             	mov    0x8(%eax),%edx
c01045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045fb:	8b 40 08             	mov    0x8(%eax),%eax
c01045fe:	01 c2                	add    %eax,%edx
c0104600:	8b 45 08             	mov    0x8(%ebp),%eax
c0104603:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
c0104606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104609:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        ClearPageProperty(p);
c0104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104613:	83 c0 04             	add    $0x4,%eax
c0104616:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010461d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104620:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104623:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104626:	0f b3 10             	btr    %edx,(%eax)
    }

    //合并上方也不复杂，需要找到上方第一个空闲块并将base 的property赋给该块
    le=list_prev(&base->page_link);
c0104629:	8b 45 08             	mov    0x8(%ebp),%eax
c010462c:	83 c0 0c             	add    $0xc,%eax
c010462f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return listelm->prev;
c0104632:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104635:	8b 00                	mov    (%eax),%eax
c0104637:	89 45 f0             	mov    %eax,-0x10(%ebp)
    p=le2page(le,page_link);
c010463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010463d:	83 e8 0c             	sub    $0xc,%eax
c0104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p==base-1){
c0104643:	8b 45 08             	mov    0x8(%ebp),%eax
c0104646:	83 e8 14             	sub    $0x14,%eax
c0104649:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010464c:	75 65                	jne    c01046b3 <default_free_pages+0x255>
        //链表的上一个块必须要和当前页连续才能合并
        while(le!=&free_list){
c010464e:	eb 5a                	jmp    c01046aa <default_free_pages+0x24c>
            p=le2page(le,page_link);
c0104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104653:	83 e8 0c             	sub    $0xc,%eax
c0104656:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if(p->property!=0){
c0104659:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010465c:	8b 40 08             	mov    0x8(%eax),%eax
c010465f:	85 c0                	test   %eax,%eax
c0104661:	74 39                	je     c010469c <default_free_pages+0x23e>
                p->property+=base->property;
c0104663:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104666:	8b 50 08             	mov    0x8(%eax),%edx
c0104669:	8b 45 08             	mov    0x8(%ebp),%eax
c010466c:	8b 40 08             	mov    0x8(%eax),%eax
c010466f:	01 c2                	add    %eax,%edx
c0104671:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104674:	89 50 08             	mov    %edx,0x8(%eax)
                base->property=0;
c0104677:	8b 45 08             	mov    0x8(%ebp),%eax
c010467a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
                ClearPageProperty(base);
c0104681:	8b 45 08             	mov    0x8(%ebp),%eax
c0104684:	83 c0 04             	add    $0x4,%eax
c0104687:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010468e:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104691:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104694:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104697:	0f b3 10             	btr    %edx,(%eax)
                break;
c010469a:	eb 17                	jmp    c01046b3 <default_free_pages+0x255>
c010469c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010469f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01046a2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01046a5:	8b 00                	mov    (%eax),%eax
            }
            le=list_prev(le);
c01046a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while(le!=&free_list){
c01046aa:	81 7d f0 5c 89 11 c0 	cmpl   $0xc011895c,-0x10(%ebp)
c01046b1:	75 9d                	jne    c0104650 <default_free_pages+0x1f2>
        }
    }
    nr_free+=n;
c01046b3:	8b 15 64 89 11 c0    	mov    0xc0118964,%edx
c01046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046bc:	01 d0                	add    %edx,%eax
c01046be:	a3 64 89 11 c0       	mov    %eax,0xc0118964
    return;
c01046c3:	90                   	nop

}
c01046c4:	c9                   	leave  
c01046c5:	c3                   	ret    

c01046c6 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01046c6:	55                   	push   %ebp
c01046c7:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01046c9:	a1 64 89 11 c0       	mov    0xc0118964,%eax
}
c01046ce:	5d                   	pop    %ebp
c01046cf:	c3                   	ret    

c01046d0 <basic_check>:

static void
basic_check(void) {
c01046d0:	55                   	push   %ebp
c01046d1:	89 e5                	mov    %esp,%ebp
c01046d3:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01046d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01046e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046f0:	e8 be e4 ff ff       	call   c0102bb3 <alloc_pages>
c01046f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01046f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01046fc:	75 24                	jne    c0104722 <basic_check+0x52>
c01046fe:	c7 44 24 0c 6c 6b 10 	movl   $0xc0106b6c,0xc(%esp)
c0104705:	c0 
c0104706:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010470d:	c0 
c010470e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104715:	00 
c0104716:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010471d:	e8 bb bc ff ff       	call   c01003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104722:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104729:	e8 85 e4 ff ff       	call   c0102bb3 <alloc_pages>
c010472e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104731:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104735:	75 24                	jne    c010475b <basic_check+0x8b>
c0104737:	c7 44 24 0c 88 6b 10 	movl   $0xc0106b88,0xc(%esp)
c010473e:	c0 
c010473f:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104746:	c0 
c0104747:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c010474e:	00 
c010474f:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104756:	e8 82 bc ff ff       	call   c01003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
c010475b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104762:	e8 4c e4 ff ff       	call   c0102bb3 <alloc_pages>
c0104767:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010476a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010476e:	75 24                	jne    c0104794 <basic_check+0xc4>
c0104770:	c7 44 24 0c a4 6b 10 	movl   $0xc0106ba4,0xc(%esp)
c0104777:	c0 
c0104778:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010477f:	c0 
c0104780:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0104787:	00 
c0104788:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010478f:	e8 49 bc ff ff       	call   c01003dd <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104794:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104797:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010479a:	74 10                	je     c01047ac <basic_check+0xdc>
c010479c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010479f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047a2:	74 08                	je     c01047ac <basic_check+0xdc>
c01047a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047aa:	75 24                	jne    c01047d0 <basic_check+0x100>
c01047ac:	c7 44 24 0c c0 6b 10 	movl   $0xc0106bc0,0xc(%esp)
c01047b3:	c0 
c01047b4:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01047bb:	c0 
c01047bc:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c01047c3:	00 
c01047c4:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c01047cb:	e8 0d bc ff ff       	call   c01003dd <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01047d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047d3:	89 04 24             	mov    %eax,(%esp)
c01047d6:	e8 b8 f9 ff ff       	call   c0104193 <page_ref>
c01047db:	85 c0                	test   %eax,%eax
c01047dd:	75 1e                	jne    c01047fd <basic_check+0x12d>
c01047df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047e2:	89 04 24             	mov    %eax,(%esp)
c01047e5:	e8 a9 f9 ff ff       	call   c0104193 <page_ref>
c01047ea:	85 c0                	test   %eax,%eax
c01047ec:	75 0f                	jne    c01047fd <basic_check+0x12d>
c01047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f1:	89 04 24             	mov    %eax,(%esp)
c01047f4:	e8 9a f9 ff ff       	call   c0104193 <page_ref>
c01047f9:	85 c0                	test   %eax,%eax
c01047fb:	74 24                	je     c0104821 <basic_check+0x151>
c01047fd:	c7 44 24 0c e4 6b 10 	movl   $0xc0106be4,0xc(%esp)
c0104804:	c0 
c0104805:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010480c:	c0 
c010480d:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104814:	00 
c0104815:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010481c:	e8 bc bb ff ff       	call   c01003dd <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104821:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104824:	89 04 24             	mov    %eax,(%esp)
c0104827:	e8 51 f9 ff ff       	call   c010417d <page2pa>
c010482c:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0104832:	c1 e2 0c             	shl    $0xc,%edx
c0104835:	39 d0                	cmp    %edx,%eax
c0104837:	72 24                	jb     c010485d <basic_check+0x18d>
c0104839:	c7 44 24 0c 20 6c 10 	movl   $0xc0106c20,0xc(%esp)
c0104840:	c0 
c0104841:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104848:	c0 
c0104849:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104850:	00 
c0104851:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104858:	e8 80 bb ff ff       	call   c01003dd <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010485d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104860:	89 04 24             	mov    %eax,(%esp)
c0104863:	e8 15 f9 ff ff       	call   c010417d <page2pa>
c0104868:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c010486e:	c1 e2 0c             	shl    $0xc,%edx
c0104871:	39 d0                	cmp    %edx,%eax
c0104873:	72 24                	jb     c0104899 <basic_check+0x1c9>
c0104875:	c7 44 24 0c 3d 6c 10 	movl   $0xc0106c3d,0xc(%esp)
c010487c:	c0 
c010487d:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104884:	c0 
c0104885:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010488c:	00 
c010488d:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104894:	e8 44 bb ff ff       	call   c01003dd <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104899:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010489c:	89 04 24             	mov    %eax,(%esp)
c010489f:	e8 d9 f8 ff ff       	call   c010417d <page2pa>
c01048a4:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c01048aa:	c1 e2 0c             	shl    $0xc,%edx
c01048ad:	39 d0                	cmp    %edx,%eax
c01048af:	72 24                	jb     c01048d5 <basic_check+0x205>
c01048b1:	c7 44 24 0c 5a 6c 10 	movl   $0xc0106c5a,0xc(%esp)
c01048b8:	c0 
c01048b9:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01048c0:	c0 
c01048c1:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01048c8:	00 
c01048c9:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c01048d0:	e8 08 bb ff ff       	call   c01003dd <__panic>

    list_entry_t free_list_store = free_list;
c01048d5:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c01048da:	8b 15 60 89 11 c0    	mov    0xc0118960,%edx
c01048e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01048e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01048e6:	c7 45 e0 5c 89 11 c0 	movl   $0xc011895c,-0x20(%ebp)
    elm->prev = elm->next = elm;
c01048ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048f3:	89 50 04             	mov    %edx,0x4(%eax)
c01048f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048f9:	8b 50 04             	mov    0x4(%eax),%edx
c01048fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048ff:	89 10                	mov    %edx,(%eax)
c0104901:	c7 45 dc 5c 89 11 c0 	movl   $0xc011895c,-0x24(%ebp)
    return list->next == list;
c0104908:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010490b:	8b 40 04             	mov    0x4(%eax),%eax
c010490e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104911:	0f 94 c0             	sete   %al
c0104914:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104917:	85 c0                	test   %eax,%eax
c0104919:	75 24                	jne    c010493f <basic_check+0x26f>
c010491b:	c7 44 24 0c 77 6c 10 	movl   $0xc0106c77,0xc(%esp)
c0104922:	c0 
c0104923:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010492a:	c0 
c010492b:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0104932:	00 
c0104933:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010493a:	e8 9e ba ff ff       	call   c01003dd <__panic>

    unsigned int nr_free_store = nr_free;
c010493f:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0104944:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104947:	c7 05 64 89 11 c0 00 	movl   $0x0,0xc0118964
c010494e:	00 00 00 

    assert(alloc_page() == NULL);
c0104951:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104958:	e8 56 e2 ff ff       	call   c0102bb3 <alloc_pages>
c010495d:	85 c0                	test   %eax,%eax
c010495f:	74 24                	je     c0104985 <basic_check+0x2b5>
c0104961:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0104968:	c0 
c0104969:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104970:	c0 
c0104971:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0104978:	00 
c0104979:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104980:	e8 58 ba ff ff       	call   c01003dd <__panic>

    free_page(p0);
c0104985:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010498c:	00 
c010498d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104990:	89 04 24             	mov    %eax,(%esp)
c0104993:	e8 53 e2 ff ff       	call   c0102beb <free_pages>
    free_page(p1);
c0104998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010499f:	00 
c01049a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049a3:	89 04 24             	mov    %eax,(%esp)
c01049a6:	e8 40 e2 ff ff       	call   c0102beb <free_pages>
    free_page(p2);
c01049ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01049b2:	00 
c01049b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b6:	89 04 24             	mov    %eax,(%esp)
c01049b9:	e8 2d e2 ff ff       	call   c0102beb <free_pages>
    assert(nr_free == 3);
c01049be:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c01049c3:	83 f8 03             	cmp    $0x3,%eax
c01049c6:	74 24                	je     c01049ec <basic_check+0x31c>
c01049c8:	c7 44 24 0c a3 6c 10 	movl   $0xc0106ca3,0xc(%esp)
c01049cf:	c0 
c01049d0:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01049d7:	c0 
c01049d8:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01049df:	00 
c01049e0:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c01049e7:	e8 f1 b9 ff ff       	call   c01003dd <__panic>

    assert((p0 = alloc_page()) != NULL);
c01049ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01049f3:	e8 bb e1 ff ff       	call   c0102bb3 <alloc_pages>
c01049f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01049fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01049ff:	75 24                	jne    c0104a25 <basic_check+0x355>
c0104a01:	c7 44 24 0c 6c 6b 10 	movl   $0xc0106b6c,0xc(%esp)
c0104a08:	c0 
c0104a09:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104a10:	c0 
c0104a11:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104a18:	00 
c0104a19:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104a20:	e8 b8 b9 ff ff       	call   c01003dd <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104a25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a2c:	e8 82 e1 ff ff       	call   c0102bb3 <alloc_pages>
c0104a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a38:	75 24                	jne    c0104a5e <basic_check+0x38e>
c0104a3a:	c7 44 24 0c 88 6b 10 	movl   $0xc0106b88,0xc(%esp)
c0104a41:	c0 
c0104a42:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104a49:	c0 
c0104a4a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0104a51:	00 
c0104a52:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104a59:	e8 7f b9 ff ff       	call   c01003dd <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104a5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a65:	e8 49 e1 ff ff       	call   c0102bb3 <alloc_pages>
c0104a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a71:	75 24                	jne    c0104a97 <basic_check+0x3c7>
c0104a73:	c7 44 24 0c a4 6b 10 	movl   $0xc0106ba4,0xc(%esp)
c0104a7a:	c0 
c0104a7b:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104a82:	c0 
c0104a83:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0104a8a:	00 
c0104a8b:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104a92:	e8 46 b9 ff ff       	call   c01003dd <__panic>

    assert(alloc_page() == NULL);
c0104a97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a9e:	e8 10 e1 ff ff       	call   c0102bb3 <alloc_pages>
c0104aa3:	85 c0                	test   %eax,%eax
c0104aa5:	74 24                	je     c0104acb <basic_check+0x3fb>
c0104aa7:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0104aae:	c0 
c0104aaf:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104ab6:	c0 
c0104ab7:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0104abe:	00 
c0104abf:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104ac6:	e8 12 b9 ff ff       	call   c01003dd <__panic>

    free_page(p0);
c0104acb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ad2:	00 
c0104ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ad6:	89 04 24             	mov    %eax,(%esp)
c0104ad9:	e8 0d e1 ff ff       	call   c0102beb <free_pages>
c0104ade:	c7 45 d8 5c 89 11 c0 	movl   $0xc011895c,-0x28(%ebp)
c0104ae5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ae8:	8b 40 04             	mov    0x4(%eax),%eax
c0104aeb:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104aee:	0f 94 c0             	sete   %al
c0104af1:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104af4:	85 c0                	test   %eax,%eax
c0104af6:	74 24                	je     c0104b1c <basic_check+0x44c>
c0104af8:	c7 44 24 0c b0 6c 10 	movl   $0xc0106cb0,0xc(%esp)
c0104aff:	c0 
c0104b00:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104b07:	c0 
c0104b08:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104b0f:	00 
c0104b10:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104b17:	e8 c1 b8 ff ff       	call   c01003dd <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104b1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b23:	e8 8b e0 ff ff       	call   c0102bb3 <alloc_pages>
c0104b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104b31:	74 24                	je     c0104b57 <basic_check+0x487>
c0104b33:	c7 44 24 0c c8 6c 10 	movl   $0xc0106cc8,0xc(%esp)
c0104b3a:	c0 
c0104b3b:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104b42:	c0 
c0104b43:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104b4a:	00 
c0104b4b:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104b52:	e8 86 b8 ff ff       	call   c01003dd <__panic>
    assert(alloc_page() == NULL);
c0104b57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b5e:	e8 50 e0 ff ff       	call   c0102bb3 <alloc_pages>
c0104b63:	85 c0                	test   %eax,%eax
c0104b65:	74 24                	je     c0104b8b <basic_check+0x4bb>
c0104b67:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0104b6e:	c0 
c0104b6f:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104b76:	c0 
c0104b77:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0104b7e:	00 
c0104b7f:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104b86:	e8 52 b8 ff ff       	call   c01003dd <__panic>

    assert(nr_free == 0);
c0104b8b:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0104b90:	85 c0                	test   %eax,%eax
c0104b92:	74 24                	je     c0104bb8 <basic_check+0x4e8>
c0104b94:	c7 44 24 0c e1 6c 10 	movl   $0xc0106ce1,0xc(%esp)
c0104b9b:	c0 
c0104b9c:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104ba3:	c0 
c0104ba4:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104bab:	00 
c0104bac:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104bb3:	e8 25 b8 ff ff       	call   c01003dd <__panic>
    free_list = free_list_store;
c0104bb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104bbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104bbe:	a3 5c 89 11 c0       	mov    %eax,0xc011895c
c0104bc3:	89 15 60 89 11 c0    	mov    %edx,0xc0118960
    nr_free = nr_free_store;
c0104bc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bcc:	a3 64 89 11 c0       	mov    %eax,0xc0118964

    free_page(p);
c0104bd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bd8:	00 
c0104bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bdc:	89 04 24             	mov    %eax,(%esp)
c0104bdf:	e8 07 e0 ff ff       	call   c0102beb <free_pages>
    free_page(p1);
c0104be4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104beb:	00 
c0104bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bef:	89 04 24             	mov    %eax,(%esp)
c0104bf2:	e8 f4 df ff ff       	call   c0102beb <free_pages>
    free_page(p2);
c0104bf7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104bfe:	00 
c0104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c02:	89 04 24             	mov    %eax,(%esp)
c0104c05:	e8 e1 df ff ff       	call   c0102beb <free_pages>
}
c0104c0a:	c9                   	leave  
c0104c0b:	c3                   	ret    

c0104c0c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104c0c:	55                   	push   %ebp
c0104c0d:	89 e5                	mov    %esp,%ebp
c0104c0f:	53                   	push   %ebx
c0104c10:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0104c16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104c1d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104c24:	c7 45 ec 5c 89 11 c0 	movl   $0xc011895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104c2b:	eb 6b                	jmp    c0104c98 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0104c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c30:	83 e8 0c             	sub    $0xc,%eax
c0104c33:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0104c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c39:	83 c0 04             	add    $0x4,%eax
c0104c3c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104c43:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104c46:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c49:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104c4c:	0f a3 10             	bt     %edx,(%eax)
c0104c4f:	19 c0                	sbb    %eax,%eax
c0104c51:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104c54:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104c58:	0f 95 c0             	setne  %al
c0104c5b:	0f b6 c0             	movzbl %al,%eax
c0104c5e:	85 c0                	test   %eax,%eax
c0104c60:	75 24                	jne    c0104c86 <default_check+0x7a>
c0104c62:	c7 44 24 0c ee 6c 10 	movl   $0xc0106cee,0xc(%esp)
c0104c69:	c0 
c0104c6a:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104c71:	c0 
c0104c72:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0104c79:	00 
c0104c7a:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104c81:	e8 57 b7 ff ff       	call   c01003dd <__panic>
        count ++, total += p->property;
c0104c86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c8d:	8b 50 08             	mov    0x8(%eax),%edx
c0104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c93:	01 d0                	add    %edx,%eax
c0104c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c9b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104c9e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ca1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ca7:	81 7d ec 5c 89 11 c0 	cmpl   $0xc011895c,-0x14(%ebp)
c0104cae:	0f 85 79 ff ff ff    	jne    c0104c2d <default_check+0x21>
    }
    assert(total == nr_free_pages());
c0104cb4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0104cb7:	e8 61 df ff ff       	call   c0102c1d <nr_free_pages>
c0104cbc:	39 c3                	cmp    %eax,%ebx
c0104cbe:	74 24                	je     c0104ce4 <default_check+0xd8>
c0104cc0:	c7 44 24 0c fe 6c 10 	movl   $0xc0106cfe,0xc(%esp)
c0104cc7:	c0 
c0104cc8:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104ccf:	c0 
c0104cd0:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0104cd7:	00 
c0104cd8:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104cdf:	e8 f9 b6 ff ff       	call   c01003dd <__panic>

    basic_check();
c0104ce4:	e8 e7 f9 ff ff       	call   c01046d0 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104ce9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104cf0:	e8 be de ff ff       	call   c0102bb3 <alloc_pages>
c0104cf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0104cf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104cfc:	75 24                	jne    c0104d22 <default_check+0x116>
c0104cfe:	c7 44 24 0c 17 6d 10 	movl   $0xc0106d17,0xc(%esp)
c0104d05:	c0 
c0104d06:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104d0d:	c0 
c0104d0e:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104d15:	00 
c0104d16:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104d1d:	e8 bb b6 ff ff       	call   c01003dd <__panic>
    assert(!PageProperty(p0));
c0104d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d25:	83 c0 04             	add    $0x4,%eax
c0104d28:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104d2f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d32:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104d35:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104d38:	0f a3 10             	bt     %edx,(%eax)
c0104d3b:	19 c0                	sbb    %eax,%eax
c0104d3d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104d40:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104d44:	0f 95 c0             	setne  %al
c0104d47:	0f b6 c0             	movzbl %al,%eax
c0104d4a:	85 c0                	test   %eax,%eax
c0104d4c:	74 24                	je     c0104d72 <default_check+0x166>
c0104d4e:	c7 44 24 0c 22 6d 10 	movl   $0xc0106d22,0xc(%esp)
c0104d55:	c0 
c0104d56:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104d5d:	c0 
c0104d5e:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0104d65:	00 
c0104d66:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104d6d:	e8 6b b6 ff ff       	call   c01003dd <__panic>

    list_entry_t free_list_store = free_list;
c0104d72:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0104d77:	8b 15 60 89 11 c0    	mov    0xc0118960,%edx
c0104d7d:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104d80:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104d83:	c7 45 b4 5c 89 11 c0 	movl   $0xc011895c,-0x4c(%ebp)
    elm->prev = elm->next = elm;
c0104d8a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104d8d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104d90:	89 50 04             	mov    %edx,0x4(%eax)
c0104d93:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104d96:	8b 50 04             	mov    0x4(%eax),%edx
c0104d99:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104d9c:	89 10                	mov    %edx,(%eax)
c0104d9e:	c7 45 b0 5c 89 11 c0 	movl   $0xc011895c,-0x50(%ebp)
    return list->next == list;
c0104da5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104da8:	8b 40 04             	mov    0x4(%eax),%eax
c0104dab:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0104dae:	0f 94 c0             	sete   %al
c0104db1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104db4:	85 c0                	test   %eax,%eax
c0104db6:	75 24                	jne    c0104ddc <default_check+0x1d0>
c0104db8:	c7 44 24 0c 77 6c 10 	movl   $0xc0106c77,0xc(%esp)
c0104dbf:	c0 
c0104dc0:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104dc7:	c0 
c0104dc8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0104dcf:	00 
c0104dd0:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104dd7:	e8 01 b6 ff ff       	call   c01003dd <__panic>
    assert(alloc_page() == NULL);
c0104ddc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104de3:	e8 cb dd ff ff       	call   c0102bb3 <alloc_pages>
c0104de8:	85 c0                	test   %eax,%eax
c0104dea:	74 24                	je     c0104e10 <default_check+0x204>
c0104dec:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0104df3:	c0 
c0104df4:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104dfb:	c0 
c0104dfc:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104e03:	00 
c0104e04:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104e0b:	e8 cd b5 ff ff       	call   c01003dd <__panic>

    unsigned int nr_free_store = nr_free;
c0104e10:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0104e15:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0104e18:	c7 05 64 89 11 c0 00 	movl   $0x0,0xc0118964
c0104e1f:	00 00 00 

    free_pages(p0 + 2, 3);
c0104e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e25:	83 c0 28             	add    $0x28,%eax
c0104e28:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104e2f:	00 
c0104e30:	89 04 24             	mov    %eax,(%esp)
c0104e33:	e8 b3 dd ff ff       	call   c0102beb <free_pages>
    assert(alloc_pages(4) == NULL);
c0104e38:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104e3f:	e8 6f dd ff ff       	call   c0102bb3 <alloc_pages>
c0104e44:	85 c0                	test   %eax,%eax
c0104e46:	74 24                	je     c0104e6c <default_check+0x260>
c0104e48:	c7 44 24 0c 34 6d 10 	movl   $0xc0106d34,0xc(%esp)
c0104e4f:	c0 
c0104e50:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104e57:	c0 
c0104e58:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104e5f:	00 
c0104e60:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104e67:	e8 71 b5 ff ff       	call   c01003dd <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e6f:	83 c0 28             	add    $0x28,%eax
c0104e72:	83 c0 04             	add    $0x4,%eax
c0104e75:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104e7c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e7f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104e82:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104e85:	0f a3 10             	bt     %edx,(%eax)
c0104e88:	19 c0                	sbb    %eax,%eax
c0104e8a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104e8d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104e91:	0f 95 c0             	setne  %al
c0104e94:	0f b6 c0             	movzbl %al,%eax
c0104e97:	85 c0                	test   %eax,%eax
c0104e99:	74 0e                	je     c0104ea9 <default_check+0x29d>
c0104e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e9e:	83 c0 28             	add    $0x28,%eax
c0104ea1:	8b 40 08             	mov    0x8(%eax),%eax
c0104ea4:	83 f8 03             	cmp    $0x3,%eax
c0104ea7:	74 24                	je     c0104ecd <default_check+0x2c1>
c0104ea9:	c7 44 24 0c 4c 6d 10 	movl   $0xc0106d4c,0xc(%esp)
c0104eb0:	c0 
c0104eb1:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104eb8:	c0 
c0104eb9:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0104ec0:	00 
c0104ec1:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104ec8:	e8 10 b5 ff ff       	call   c01003dd <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104ecd:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104ed4:	e8 da dc ff ff       	call   c0102bb3 <alloc_pages>
c0104ed9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104edc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104ee0:	75 24                	jne    c0104f06 <default_check+0x2fa>
c0104ee2:	c7 44 24 0c 78 6d 10 	movl   $0xc0106d78,0xc(%esp)
c0104ee9:	c0 
c0104eea:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104ef1:	c0 
c0104ef2:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0104ef9:	00 
c0104efa:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104f01:	e8 d7 b4 ff ff       	call   c01003dd <__panic>
    assert(alloc_page() == NULL);
c0104f06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f0d:	e8 a1 dc ff ff       	call   c0102bb3 <alloc_pages>
c0104f12:	85 c0                	test   %eax,%eax
c0104f14:	74 24                	je     c0104f3a <default_check+0x32e>
c0104f16:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0104f1d:	c0 
c0104f1e:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104f25:	c0 
c0104f26:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0104f2d:	00 
c0104f2e:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104f35:	e8 a3 b4 ff ff       	call   c01003dd <__panic>
    assert(p0 + 2 == p1);
c0104f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f3d:	83 c0 28             	add    $0x28,%eax
c0104f40:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104f43:	74 24                	je     c0104f69 <default_check+0x35d>
c0104f45:	c7 44 24 0c 96 6d 10 	movl   $0xc0106d96,0xc(%esp)
c0104f4c:	c0 
c0104f4d:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104f54:	c0 
c0104f55:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0104f5c:	00 
c0104f5d:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104f64:	e8 74 b4 ff ff       	call   c01003dd <__panic>

    p2 = p0 + 1;
c0104f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f6c:	83 c0 14             	add    $0x14,%eax
c0104f6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104f72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f79:	00 
c0104f7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f7d:	89 04 24             	mov    %eax,(%esp)
c0104f80:	e8 66 dc ff ff       	call   c0102beb <free_pages>
    free_pages(p1, 3);
c0104f85:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104f8c:	00 
c0104f8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f90:	89 04 24             	mov    %eax,(%esp)
c0104f93:	e8 53 dc ff ff       	call   c0102beb <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104f98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f9b:	83 c0 04             	add    $0x4,%eax
c0104f9e:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104fa5:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fa8:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104fab:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104fae:	0f a3 10             	bt     %edx,(%eax)
c0104fb1:	19 c0                	sbb    %eax,%eax
c0104fb3:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104fb6:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104fba:	0f 95 c0             	setne  %al
c0104fbd:	0f b6 c0             	movzbl %al,%eax
c0104fc0:	85 c0                	test   %eax,%eax
c0104fc2:	74 0b                	je     c0104fcf <default_check+0x3c3>
c0104fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fc7:	8b 40 08             	mov    0x8(%eax),%eax
c0104fca:	83 f8 01             	cmp    $0x1,%eax
c0104fcd:	74 24                	je     c0104ff3 <default_check+0x3e7>
c0104fcf:	c7 44 24 0c a4 6d 10 	movl   $0xc0106da4,0xc(%esp)
c0104fd6:	c0 
c0104fd7:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0104fde:	c0 
c0104fdf:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0104fe6:	00 
c0104fe7:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0104fee:	e8 ea b3 ff ff       	call   c01003dd <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104ff3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104ff6:	83 c0 04             	add    $0x4,%eax
c0104ff9:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105000:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105003:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105006:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105009:	0f a3 10             	bt     %edx,(%eax)
c010500c:	19 c0                	sbb    %eax,%eax
c010500e:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105011:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105015:	0f 95 c0             	setne  %al
c0105018:	0f b6 c0             	movzbl %al,%eax
c010501b:	85 c0                	test   %eax,%eax
c010501d:	74 0b                	je     c010502a <default_check+0x41e>
c010501f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105022:	8b 40 08             	mov    0x8(%eax),%eax
c0105025:	83 f8 03             	cmp    $0x3,%eax
c0105028:	74 24                	je     c010504e <default_check+0x442>
c010502a:	c7 44 24 0c cc 6d 10 	movl   $0xc0106dcc,0xc(%esp)
c0105031:	c0 
c0105032:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0105039:	c0 
c010503a:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0105041:	00 
c0105042:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0105049:	e8 8f b3 ff ff       	call   c01003dd <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010504e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105055:	e8 59 db ff ff       	call   c0102bb3 <alloc_pages>
c010505a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010505d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105060:	83 e8 14             	sub    $0x14,%eax
c0105063:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105066:	74 24                	je     c010508c <default_check+0x480>
c0105068:	c7 44 24 0c f2 6d 10 	movl   $0xc0106df2,0xc(%esp)
c010506f:	c0 
c0105070:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0105077:	c0 
c0105078:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c010507f:	00 
c0105080:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0105087:	e8 51 b3 ff ff       	call   c01003dd <__panic>
    free_page(p0);
c010508c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105093:	00 
c0105094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105097:	89 04 24             	mov    %eax,(%esp)
c010509a:	e8 4c db ff ff       	call   c0102beb <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010509f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01050a6:	e8 08 db ff ff       	call   c0102bb3 <alloc_pages>
c01050ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01050ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01050b1:	83 c0 14             	add    $0x14,%eax
c01050b4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01050b7:	74 24                	je     c01050dd <default_check+0x4d1>
c01050b9:	c7 44 24 0c 10 6e 10 	movl   $0xc0106e10,0xc(%esp)
c01050c0:	c0 
c01050c1:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c01050c8:	c0 
c01050c9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01050d0:	00 
c01050d1:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c01050d8:	e8 00 b3 ff ff       	call   c01003dd <__panic>

    free_pages(p0, 2);
c01050dd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01050e4:	00 
c01050e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050e8:	89 04 24             	mov    %eax,(%esp)
c01050eb:	e8 fb da ff ff       	call   c0102beb <free_pages>
    free_page(p2);
c01050f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050f7:	00 
c01050f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01050fb:	89 04 24             	mov    %eax,(%esp)
c01050fe:	e8 e8 da ff ff       	call   c0102beb <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105103:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010510a:	e8 a4 da ff ff       	call   c0102bb3 <alloc_pages>
c010510f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105112:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105116:	75 24                	jne    c010513c <default_check+0x530>
c0105118:	c7 44 24 0c 30 6e 10 	movl   $0xc0106e30,0xc(%esp)
c010511f:	c0 
c0105120:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0105127:	c0 
c0105128:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c010512f:	00 
c0105130:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0105137:	e8 a1 b2 ff ff       	call   c01003dd <__panic>
    assert(alloc_page() == NULL);
c010513c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105143:	e8 6b da ff ff       	call   c0102bb3 <alloc_pages>
c0105148:	85 c0                	test   %eax,%eax
c010514a:	74 24                	je     c0105170 <default_check+0x564>
c010514c:	c7 44 24 0c 8e 6c 10 	movl   $0xc0106c8e,0xc(%esp)
c0105153:	c0 
c0105154:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010515b:	c0 
c010515c:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0105163:	00 
c0105164:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010516b:	e8 6d b2 ff ff       	call   c01003dd <__panic>

    assert(nr_free == 0);
c0105170:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0105175:	85 c0                	test   %eax,%eax
c0105177:	74 24                	je     c010519d <default_check+0x591>
c0105179:	c7 44 24 0c e1 6c 10 	movl   $0xc0106ce1,0xc(%esp)
c0105180:	c0 
c0105181:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0105188:	c0 
c0105189:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0105190:	00 
c0105191:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0105198:	e8 40 b2 ff ff       	call   c01003dd <__panic>
    nr_free = nr_free_store;
c010519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051a0:	a3 64 89 11 c0       	mov    %eax,0xc0118964

    free_list = free_list_store;
c01051a5:	8b 45 80             	mov    -0x80(%ebp),%eax
c01051a8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01051ab:	a3 5c 89 11 c0       	mov    %eax,0xc011895c
c01051b0:	89 15 60 89 11 c0    	mov    %edx,0xc0118960
    free_pages(p0, 5);
c01051b6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01051bd:	00 
c01051be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051c1:	89 04 24             	mov    %eax,(%esp)
c01051c4:	e8 22 da ff ff       	call   c0102beb <free_pages>

    le = &free_list;
c01051c9:	c7 45 ec 5c 89 11 c0 	movl   $0xc011895c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01051d0:	eb 1d                	jmp    c01051ef <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01051d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051d5:	83 e8 0c             	sub    $0xc,%eax
c01051d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01051db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01051df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01051e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01051e5:	8b 40 08             	mov    0x8(%eax),%eax
c01051e8:	29 c2                	sub    %eax,%edx
c01051ea:	89 d0                	mov    %edx,%eax
c01051ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01051ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051f2:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01051f5:	8b 45 88             	mov    -0x78(%ebp),%eax
c01051f8:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01051fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01051fe:	81 7d ec 5c 89 11 c0 	cmpl   $0xc011895c,-0x14(%ebp)
c0105205:	75 cb                	jne    c01051d2 <default_check+0x5c6>
    }
    assert(count == 0);
c0105207:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010520b:	74 24                	je     c0105231 <default_check+0x625>
c010520d:	c7 44 24 0c 4e 6e 10 	movl   $0xc0106e4e,0xc(%esp)
c0105214:	c0 
c0105215:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c010521c:	c0 
c010521d:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0105224:	00 
c0105225:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c010522c:	e8 ac b1 ff ff       	call   c01003dd <__panic>
    assert(total == 0);
c0105231:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105235:	74 24                	je     c010525b <default_check+0x64f>
c0105237:	c7 44 24 0c 59 6e 10 	movl   $0xc0106e59,0xc(%esp)
c010523e:	c0 
c010523f:	c7 44 24 08 1e 6b 10 	movl   $0xc0106b1e,0x8(%esp)
c0105246:	c0 
c0105247:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c010524e:	00 
c010524f:	c7 04 24 33 6b 10 c0 	movl   $0xc0106b33,(%esp)
c0105256:	e8 82 b1 ff ff       	call   c01003dd <__panic>
}
c010525b:	81 c4 94 00 00 00    	add    $0x94,%esp
c0105261:	5b                   	pop    %ebx
c0105262:	5d                   	pop    %ebp
c0105263:	c3                   	ret    

c0105264 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105264:	55                   	push   %ebp
c0105265:	89 e5                	mov    %esp,%ebp
c0105267:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010526a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105271:	eb 04                	jmp    c0105277 <strlen+0x13>
        cnt ++;
c0105273:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105277:	8b 45 08             	mov    0x8(%ebp),%eax
c010527a:	8d 50 01             	lea    0x1(%eax),%edx
c010527d:	89 55 08             	mov    %edx,0x8(%ebp)
c0105280:	0f b6 00             	movzbl (%eax),%eax
c0105283:	84 c0                	test   %al,%al
c0105285:	75 ec                	jne    c0105273 <strlen+0xf>
    }
    return cnt;
c0105287:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010528a:	c9                   	leave  
c010528b:	c3                   	ret    

c010528c <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010528c:	55                   	push   %ebp
c010528d:	89 e5                	mov    %esp,%ebp
c010528f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105292:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105299:	eb 04                	jmp    c010529f <strnlen+0x13>
        cnt ++;
c010529b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010529f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052a5:	73 10                	jae    c01052b7 <strnlen+0x2b>
c01052a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01052aa:	8d 50 01             	lea    0x1(%eax),%edx
c01052ad:	89 55 08             	mov    %edx,0x8(%ebp)
c01052b0:	0f b6 00             	movzbl (%eax),%eax
c01052b3:	84 c0                	test   %al,%al
c01052b5:	75 e4                	jne    c010529b <strnlen+0xf>
    }
    return cnt;
c01052b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01052ba:	c9                   	leave  
c01052bb:	c3                   	ret    

c01052bc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01052bc:	55                   	push   %ebp
c01052bd:	89 e5                	mov    %esp,%ebp
c01052bf:	57                   	push   %edi
c01052c0:	56                   	push   %esi
c01052c1:	83 ec 20             	sub    $0x20,%esp
c01052c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01052c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01052d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01052d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052d6:	89 d1                	mov    %edx,%ecx
c01052d8:	89 c2                	mov    %eax,%edx
c01052da:	89 ce                	mov    %ecx,%esi
c01052dc:	89 d7                	mov    %edx,%edi
c01052de:	ac                   	lods   %ds:(%esi),%al
c01052df:	aa                   	stos   %al,%es:(%edi)
c01052e0:	84 c0                	test   %al,%al
c01052e2:	75 fa                	jne    c01052de <strcpy+0x22>
c01052e4:	89 fa                	mov    %edi,%edx
c01052e6:	89 f1                	mov    %esi,%ecx
c01052e8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01052eb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01052ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01052f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01052f4:	83 c4 20             	add    $0x20,%esp
c01052f7:	5e                   	pop    %esi
c01052f8:	5f                   	pop    %edi
c01052f9:	5d                   	pop    %ebp
c01052fa:	c3                   	ret    

c01052fb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01052fb:	55                   	push   %ebp
c01052fc:	89 e5                	mov    %esp,%ebp
c01052fe:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105301:	8b 45 08             	mov    0x8(%ebp),%eax
c0105304:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105307:	eb 21                	jmp    c010532a <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105309:	8b 45 0c             	mov    0xc(%ebp),%eax
c010530c:	0f b6 10             	movzbl (%eax),%edx
c010530f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105312:	88 10                	mov    %dl,(%eax)
c0105314:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105317:	0f b6 00             	movzbl (%eax),%eax
c010531a:	84 c0                	test   %al,%al
c010531c:	74 04                	je     c0105322 <strncpy+0x27>
            src ++;
c010531e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105322:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105326:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010532a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010532e:	75 d9                	jne    c0105309 <strncpy+0xe>
    }
    return dst;
c0105330:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105333:	c9                   	leave  
c0105334:	c3                   	ret    

c0105335 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105335:	55                   	push   %ebp
c0105336:	89 e5                	mov    %esp,%ebp
c0105338:	57                   	push   %edi
c0105339:	56                   	push   %esi
c010533a:	83 ec 20             	sub    $0x20,%esp
c010533d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105340:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105343:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105346:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105349:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010534c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010534f:	89 d1                	mov    %edx,%ecx
c0105351:	89 c2                	mov    %eax,%edx
c0105353:	89 ce                	mov    %ecx,%esi
c0105355:	89 d7                	mov    %edx,%edi
c0105357:	ac                   	lods   %ds:(%esi),%al
c0105358:	ae                   	scas   %es:(%edi),%al
c0105359:	75 08                	jne    c0105363 <strcmp+0x2e>
c010535b:	84 c0                	test   %al,%al
c010535d:	75 f8                	jne    c0105357 <strcmp+0x22>
c010535f:	31 c0                	xor    %eax,%eax
c0105361:	eb 04                	jmp    c0105367 <strcmp+0x32>
c0105363:	19 c0                	sbb    %eax,%eax
c0105365:	0c 01                	or     $0x1,%al
c0105367:	89 fa                	mov    %edi,%edx
c0105369:	89 f1                	mov    %esi,%ecx
c010536b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010536e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105371:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105374:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105377:	83 c4 20             	add    $0x20,%esp
c010537a:	5e                   	pop    %esi
c010537b:	5f                   	pop    %edi
c010537c:	5d                   	pop    %ebp
c010537d:	c3                   	ret    

c010537e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010537e:	55                   	push   %ebp
c010537f:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105381:	eb 0c                	jmp    c010538f <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105383:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105387:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010538b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010538f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105393:	74 1a                	je     c01053af <strncmp+0x31>
c0105395:	8b 45 08             	mov    0x8(%ebp),%eax
c0105398:	0f b6 00             	movzbl (%eax),%eax
c010539b:	84 c0                	test   %al,%al
c010539d:	74 10                	je     c01053af <strncmp+0x31>
c010539f:	8b 45 08             	mov    0x8(%ebp),%eax
c01053a2:	0f b6 10             	movzbl (%eax),%edx
c01053a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053a8:	0f b6 00             	movzbl (%eax),%eax
c01053ab:	38 c2                	cmp    %al,%dl
c01053ad:	74 d4                	je     c0105383 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01053af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01053b3:	74 18                	je     c01053cd <strncmp+0x4f>
c01053b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01053b8:	0f b6 00             	movzbl (%eax),%eax
c01053bb:	0f b6 d0             	movzbl %al,%edx
c01053be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053c1:	0f b6 00             	movzbl (%eax),%eax
c01053c4:	0f b6 c0             	movzbl %al,%eax
c01053c7:	29 c2                	sub    %eax,%edx
c01053c9:	89 d0                	mov    %edx,%eax
c01053cb:	eb 05                	jmp    c01053d2 <strncmp+0x54>
c01053cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01053d2:	5d                   	pop    %ebp
c01053d3:	c3                   	ret    

c01053d4 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01053d4:	55                   	push   %ebp
c01053d5:	89 e5                	mov    %esp,%ebp
c01053d7:	83 ec 04             	sub    $0x4,%esp
c01053da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053dd:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01053e0:	eb 14                	jmp    c01053f6 <strchr+0x22>
        if (*s == c) {
c01053e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01053e5:	0f b6 00             	movzbl (%eax),%eax
c01053e8:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01053eb:	75 05                	jne    c01053f2 <strchr+0x1e>
            return (char *)s;
c01053ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f0:	eb 13                	jmp    c0105405 <strchr+0x31>
        }
        s ++;
c01053f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c01053f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f9:	0f b6 00             	movzbl (%eax),%eax
c01053fc:	84 c0                	test   %al,%al
c01053fe:	75 e2                	jne    c01053e2 <strchr+0xe>
    }
    return NULL;
c0105400:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105405:	c9                   	leave  
c0105406:	c3                   	ret    

c0105407 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105407:	55                   	push   %ebp
c0105408:	89 e5                	mov    %esp,%ebp
c010540a:	83 ec 04             	sub    $0x4,%esp
c010540d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105410:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105413:	eb 11                	jmp    c0105426 <strfind+0x1f>
        if (*s == c) {
c0105415:	8b 45 08             	mov    0x8(%ebp),%eax
c0105418:	0f b6 00             	movzbl (%eax),%eax
c010541b:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010541e:	75 02                	jne    c0105422 <strfind+0x1b>
            break;
c0105420:	eb 0e                	jmp    c0105430 <strfind+0x29>
        }
        s ++;
c0105422:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c0105426:	8b 45 08             	mov    0x8(%ebp),%eax
c0105429:	0f b6 00             	movzbl (%eax),%eax
c010542c:	84 c0                	test   %al,%al
c010542e:	75 e5                	jne    c0105415 <strfind+0xe>
    }
    return (char *)s;
c0105430:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105433:	c9                   	leave  
c0105434:	c3                   	ret    

c0105435 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105435:	55                   	push   %ebp
c0105436:	89 e5                	mov    %esp,%ebp
c0105438:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010543b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105442:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105449:	eb 04                	jmp    c010544f <strtol+0x1a>
        s ++;
c010544b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010544f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105452:	0f b6 00             	movzbl (%eax),%eax
c0105455:	3c 20                	cmp    $0x20,%al
c0105457:	74 f2                	je     c010544b <strtol+0x16>
c0105459:	8b 45 08             	mov    0x8(%ebp),%eax
c010545c:	0f b6 00             	movzbl (%eax),%eax
c010545f:	3c 09                	cmp    $0x9,%al
c0105461:	74 e8                	je     c010544b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105463:	8b 45 08             	mov    0x8(%ebp),%eax
c0105466:	0f b6 00             	movzbl (%eax),%eax
c0105469:	3c 2b                	cmp    $0x2b,%al
c010546b:	75 06                	jne    c0105473 <strtol+0x3e>
        s ++;
c010546d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105471:	eb 15                	jmp    c0105488 <strtol+0x53>
    }
    else if (*s == '-') {
c0105473:	8b 45 08             	mov    0x8(%ebp),%eax
c0105476:	0f b6 00             	movzbl (%eax),%eax
c0105479:	3c 2d                	cmp    $0x2d,%al
c010547b:	75 0b                	jne    c0105488 <strtol+0x53>
        s ++, neg = 1;
c010547d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105481:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105488:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010548c:	74 06                	je     c0105494 <strtol+0x5f>
c010548e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105492:	75 24                	jne    c01054b8 <strtol+0x83>
c0105494:	8b 45 08             	mov    0x8(%ebp),%eax
c0105497:	0f b6 00             	movzbl (%eax),%eax
c010549a:	3c 30                	cmp    $0x30,%al
c010549c:	75 1a                	jne    c01054b8 <strtol+0x83>
c010549e:	8b 45 08             	mov    0x8(%ebp),%eax
c01054a1:	83 c0 01             	add    $0x1,%eax
c01054a4:	0f b6 00             	movzbl (%eax),%eax
c01054a7:	3c 78                	cmp    $0x78,%al
c01054a9:	75 0d                	jne    c01054b8 <strtol+0x83>
        s += 2, base = 16;
c01054ab:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01054af:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01054b6:	eb 2a                	jmp    c01054e2 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c01054b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01054bc:	75 17                	jne    c01054d5 <strtol+0xa0>
c01054be:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c1:	0f b6 00             	movzbl (%eax),%eax
c01054c4:	3c 30                	cmp    $0x30,%al
c01054c6:	75 0d                	jne    c01054d5 <strtol+0xa0>
        s ++, base = 8;
c01054c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01054cc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01054d3:	eb 0d                	jmp    c01054e2 <strtol+0xad>
    }
    else if (base == 0) {
c01054d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01054d9:	75 07                	jne    c01054e2 <strtol+0xad>
        base = 10;
c01054db:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01054e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e5:	0f b6 00             	movzbl (%eax),%eax
c01054e8:	3c 2f                	cmp    $0x2f,%al
c01054ea:	7e 1b                	jle    c0105507 <strtol+0xd2>
c01054ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ef:	0f b6 00             	movzbl (%eax),%eax
c01054f2:	3c 39                	cmp    $0x39,%al
c01054f4:	7f 11                	jg     c0105507 <strtol+0xd2>
            dig = *s - '0';
c01054f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f9:	0f b6 00             	movzbl (%eax),%eax
c01054fc:	0f be c0             	movsbl %al,%eax
c01054ff:	83 e8 30             	sub    $0x30,%eax
c0105502:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105505:	eb 48                	jmp    c010554f <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105507:	8b 45 08             	mov    0x8(%ebp),%eax
c010550a:	0f b6 00             	movzbl (%eax),%eax
c010550d:	3c 60                	cmp    $0x60,%al
c010550f:	7e 1b                	jle    c010552c <strtol+0xf7>
c0105511:	8b 45 08             	mov    0x8(%ebp),%eax
c0105514:	0f b6 00             	movzbl (%eax),%eax
c0105517:	3c 7a                	cmp    $0x7a,%al
c0105519:	7f 11                	jg     c010552c <strtol+0xf7>
            dig = *s - 'a' + 10;
c010551b:	8b 45 08             	mov    0x8(%ebp),%eax
c010551e:	0f b6 00             	movzbl (%eax),%eax
c0105521:	0f be c0             	movsbl %al,%eax
c0105524:	83 e8 57             	sub    $0x57,%eax
c0105527:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010552a:	eb 23                	jmp    c010554f <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010552c:	8b 45 08             	mov    0x8(%ebp),%eax
c010552f:	0f b6 00             	movzbl (%eax),%eax
c0105532:	3c 40                	cmp    $0x40,%al
c0105534:	7e 3d                	jle    c0105573 <strtol+0x13e>
c0105536:	8b 45 08             	mov    0x8(%ebp),%eax
c0105539:	0f b6 00             	movzbl (%eax),%eax
c010553c:	3c 5a                	cmp    $0x5a,%al
c010553e:	7f 33                	jg     c0105573 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105540:	8b 45 08             	mov    0x8(%ebp),%eax
c0105543:	0f b6 00             	movzbl (%eax),%eax
c0105546:	0f be c0             	movsbl %al,%eax
c0105549:	83 e8 37             	sub    $0x37,%eax
c010554c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010554f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105552:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105555:	7c 02                	jl     c0105559 <strtol+0x124>
            break;
c0105557:	eb 1a                	jmp    c0105573 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105559:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010555d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105560:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105564:	89 c2                	mov    %eax,%edx
c0105566:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105569:	01 d0                	add    %edx,%eax
c010556b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010556e:	e9 6f ff ff ff       	jmp    c01054e2 <strtol+0xad>

    if (endptr) {
c0105573:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105577:	74 08                	je     c0105581 <strtol+0x14c>
        *endptr = (char *) s;
c0105579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010557c:	8b 55 08             	mov    0x8(%ebp),%edx
c010557f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105581:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105585:	74 07                	je     c010558e <strtol+0x159>
c0105587:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010558a:	f7 d8                	neg    %eax
c010558c:	eb 03                	jmp    c0105591 <strtol+0x15c>
c010558e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105591:	c9                   	leave  
c0105592:	c3                   	ret    

c0105593 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105593:	55                   	push   %ebp
c0105594:	89 e5                	mov    %esp,%ebp
c0105596:	57                   	push   %edi
c0105597:	83 ec 24             	sub    $0x24,%esp
c010559a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010559d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01055a0:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01055a4:	8b 55 08             	mov    0x8(%ebp),%edx
c01055a7:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01055aa:	88 45 f7             	mov    %al,-0x9(%ebp)
c01055ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01055b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01055b3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01055b6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01055ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01055bd:	89 d7                	mov    %edx,%edi
c01055bf:	f3 aa                	rep stos %al,%es:(%edi)
c01055c1:	89 fa                	mov    %edi,%edx
c01055c3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01055c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01055c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01055cc:	83 c4 24             	add    $0x24,%esp
c01055cf:	5f                   	pop    %edi
c01055d0:	5d                   	pop    %ebp
c01055d1:	c3                   	ret    

c01055d2 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01055d2:	55                   	push   %ebp
c01055d3:	89 e5                	mov    %esp,%ebp
c01055d5:	57                   	push   %edi
c01055d6:	56                   	push   %esi
c01055d7:	53                   	push   %ebx
c01055d8:	83 ec 30             	sub    $0x30,%esp
c01055db:	8b 45 08             	mov    0x8(%ebp),%eax
c01055de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01055e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01055ea:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01055ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055f0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01055f3:	73 42                	jae    c0105637 <memmove+0x65>
c01055f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105601:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105604:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105607:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010560a:	c1 e8 02             	shr    $0x2,%eax
c010560d:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010560f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105612:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105615:	89 d7                	mov    %edx,%edi
c0105617:	89 c6                	mov    %eax,%esi
c0105619:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010561b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010561e:	83 e1 03             	and    $0x3,%ecx
c0105621:	74 02                	je     c0105625 <memmove+0x53>
c0105623:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105625:	89 f0                	mov    %esi,%eax
c0105627:	89 fa                	mov    %edi,%edx
c0105629:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010562c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010562f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105635:	eb 36                	jmp    c010566d <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105637:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010563a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010563d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105640:	01 c2                	add    %eax,%edx
c0105642:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105645:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105648:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010564b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010564e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105651:	89 c1                	mov    %eax,%ecx
c0105653:	89 d8                	mov    %ebx,%eax
c0105655:	89 d6                	mov    %edx,%esi
c0105657:	89 c7                	mov    %eax,%edi
c0105659:	fd                   	std    
c010565a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010565c:	fc                   	cld    
c010565d:	89 f8                	mov    %edi,%eax
c010565f:	89 f2                	mov    %esi,%edx
c0105661:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105664:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105667:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010566a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010566d:	83 c4 30             	add    $0x30,%esp
c0105670:	5b                   	pop    %ebx
c0105671:	5e                   	pop    %esi
c0105672:	5f                   	pop    %edi
c0105673:	5d                   	pop    %ebp
c0105674:	c3                   	ret    

c0105675 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105675:	55                   	push   %ebp
c0105676:	89 e5                	mov    %esp,%ebp
c0105678:	57                   	push   %edi
c0105679:	56                   	push   %esi
c010567a:	83 ec 20             	sub    $0x20,%esp
c010567d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105680:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105683:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105686:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105689:	8b 45 10             	mov    0x10(%ebp),%eax
c010568c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010568f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105692:	c1 e8 02             	shr    $0x2,%eax
c0105695:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105697:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010569a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010569d:	89 d7                	mov    %edx,%edi
c010569f:	89 c6                	mov    %eax,%esi
c01056a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01056a3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01056a6:	83 e1 03             	and    $0x3,%ecx
c01056a9:	74 02                	je     c01056ad <memcpy+0x38>
c01056ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01056ad:	89 f0                	mov    %esi,%eax
c01056af:	89 fa                	mov    %edi,%edx
c01056b1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01056b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01056b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01056bd:	83 c4 20             	add    $0x20,%esp
c01056c0:	5e                   	pop    %esi
c01056c1:	5f                   	pop    %edi
c01056c2:	5d                   	pop    %ebp
c01056c3:	c3                   	ret    

c01056c4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01056c4:	55                   	push   %ebp
c01056c5:	89 e5                	mov    %esp,%ebp
c01056c7:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01056ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01056cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01056d6:	eb 30                	jmp    c0105708 <memcmp+0x44>
        if (*s1 != *s2) {
c01056d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01056db:	0f b6 10             	movzbl (%eax),%edx
c01056de:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056e1:	0f b6 00             	movzbl (%eax),%eax
c01056e4:	38 c2                	cmp    %al,%dl
c01056e6:	74 18                	je     c0105700 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01056e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01056eb:	0f b6 00             	movzbl (%eax),%eax
c01056ee:	0f b6 d0             	movzbl %al,%edx
c01056f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056f4:	0f b6 00             	movzbl (%eax),%eax
c01056f7:	0f b6 c0             	movzbl %al,%eax
c01056fa:	29 c2                	sub    %eax,%edx
c01056fc:	89 d0                	mov    %edx,%eax
c01056fe:	eb 1a                	jmp    c010571a <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105700:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105704:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c0105708:	8b 45 10             	mov    0x10(%ebp),%eax
c010570b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010570e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105711:	85 c0                	test   %eax,%eax
c0105713:	75 c3                	jne    c01056d8 <memcmp+0x14>
    }
    return 0;
c0105715:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010571a:	c9                   	leave  
c010571b:	c3                   	ret    

c010571c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010571c:	55                   	push   %ebp
c010571d:	89 e5                	mov    %esp,%ebp
c010571f:	83 ec 58             	sub    $0x58,%esp
c0105722:	8b 45 10             	mov    0x10(%ebp),%eax
c0105725:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105728:	8b 45 14             	mov    0x14(%ebp),%eax
c010572b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010572e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105731:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105734:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105737:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010573a:	8b 45 18             	mov    0x18(%ebp),%eax
c010573d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105740:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105743:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105746:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105749:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010574c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010574f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105752:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105756:	74 1c                	je     c0105774 <printnum+0x58>
c0105758:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010575b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105760:	f7 75 e4             	divl   -0x1c(%ebp)
c0105763:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105766:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105769:	ba 00 00 00 00       	mov    $0x0,%edx
c010576e:	f7 75 e4             	divl   -0x1c(%ebp)
c0105771:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105774:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105777:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010577a:	f7 75 e4             	divl   -0x1c(%ebp)
c010577d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105780:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105783:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105786:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105789:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010578c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010578f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105792:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105795:	8b 45 18             	mov    0x18(%ebp),%eax
c0105798:	ba 00 00 00 00       	mov    $0x0,%edx
c010579d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01057a0:	77 56                	ja     c01057f8 <printnum+0xdc>
c01057a2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01057a5:	72 05                	jb     c01057ac <printnum+0x90>
c01057a7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01057aa:	77 4c                	ja     c01057f8 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01057ac:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01057af:	8d 50 ff             	lea    -0x1(%eax),%edx
c01057b2:	8b 45 20             	mov    0x20(%ebp),%eax
c01057b5:	89 44 24 18          	mov    %eax,0x18(%esp)
c01057b9:	89 54 24 14          	mov    %edx,0x14(%esp)
c01057bd:	8b 45 18             	mov    0x18(%ebp),%eax
c01057c0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01057c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01057ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01057ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01057d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01057dc:	89 04 24             	mov    %eax,(%esp)
c01057df:	e8 38 ff ff ff       	call   c010571c <printnum>
c01057e4:	eb 1c                	jmp    c0105802 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01057e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057ed:	8b 45 20             	mov    0x20(%ebp),%eax
c01057f0:	89 04 24             	mov    %eax,(%esp)
c01057f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01057f6:	ff d0                	call   *%eax
        while (-- width > 0)
c01057f8:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01057fc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105800:	7f e4                	jg     c01057e6 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105802:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105805:	05 14 6f 10 c0       	add    $0xc0106f14,%eax
c010580a:	0f b6 00             	movzbl (%eax),%eax
c010580d:	0f be c0             	movsbl %al,%eax
c0105810:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105813:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105817:	89 04 24             	mov    %eax,(%esp)
c010581a:	8b 45 08             	mov    0x8(%ebp),%eax
c010581d:	ff d0                	call   *%eax
}
c010581f:	c9                   	leave  
c0105820:	c3                   	ret    

c0105821 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105821:	55                   	push   %ebp
c0105822:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105824:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105828:	7e 14                	jle    c010583e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010582a:	8b 45 08             	mov    0x8(%ebp),%eax
c010582d:	8b 00                	mov    (%eax),%eax
c010582f:	8d 48 08             	lea    0x8(%eax),%ecx
c0105832:	8b 55 08             	mov    0x8(%ebp),%edx
c0105835:	89 0a                	mov    %ecx,(%edx)
c0105837:	8b 50 04             	mov    0x4(%eax),%edx
c010583a:	8b 00                	mov    (%eax),%eax
c010583c:	eb 30                	jmp    c010586e <getuint+0x4d>
    }
    else if (lflag) {
c010583e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105842:	74 16                	je     c010585a <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105844:	8b 45 08             	mov    0x8(%ebp),%eax
c0105847:	8b 00                	mov    (%eax),%eax
c0105849:	8d 48 04             	lea    0x4(%eax),%ecx
c010584c:	8b 55 08             	mov    0x8(%ebp),%edx
c010584f:	89 0a                	mov    %ecx,(%edx)
c0105851:	8b 00                	mov    (%eax),%eax
c0105853:	ba 00 00 00 00       	mov    $0x0,%edx
c0105858:	eb 14                	jmp    c010586e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010585a:	8b 45 08             	mov    0x8(%ebp),%eax
c010585d:	8b 00                	mov    (%eax),%eax
c010585f:	8d 48 04             	lea    0x4(%eax),%ecx
c0105862:	8b 55 08             	mov    0x8(%ebp),%edx
c0105865:	89 0a                	mov    %ecx,(%edx)
c0105867:	8b 00                	mov    (%eax),%eax
c0105869:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010586e:	5d                   	pop    %ebp
c010586f:	c3                   	ret    

c0105870 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105870:	55                   	push   %ebp
c0105871:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105873:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105877:	7e 14                	jle    c010588d <getint+0x1d>
        return va_arg(*ap, long long);
c0105879:	8b 45 08             	mov    0x8(%ebp),%eax
c010587c:	8b 00                	mov    (%eax),%eax
c010587e:	8d 48 08             	lea    0x8(%eax),%ecx
c0105881:	8b 55 08             	mov    0x8(%ebp),%edx
c0105884:	89 0a                	mov    %ecx,(%edx)
c0105886:	8b 50 04             	mov    0x4(%eax),%edx
c0105889:	8b 00                	mov    (%eax),%eax
c010588b:	eb 28                	jmp    c01058b5 <getint+0x45>
    }
    else if (lflag) {
c010588d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105891:	74 12                	je     c01058a5 <getint+0x35>
        return va_arg(*ap, long);
c0105893:	8b 45 08             	mov    0x8(%ebp),%eax
c0105896:	8b 00                	mov    (%eax),%eax
c0105898:	8d 48 04             	lea    0x4(%eax),%ecx
c010589b:	8b 55 08             	mov    0x8(%ebp),%edx
c010589e:	89 0a                	mov    %ecx,(%edx)
c01058a0:	8b 00                	mov    (%eax),%eax
c01058a2:	99                   	cltd   
c01058a3:	eb 10                	jmp    c01058b5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01058a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a8:	8b 00                	mov    (%eax),%eax
c01058aa:	8d 48 04             	lea    0x4(%eax),%ecx
c01058ad:	8b 55 08             	mov    0x8(%ebp),%edx
c01058b0:	89 0a                	mov    %ecx,(%edx)
c01058b2:	8b 00                	mov    (%eax),%eax
c01058b4:	99                   	cltd   
    }
}
c01058b5:	5d                   	pop    %ebp
c01058b6:	c3                   	ret    

c01058b7 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01058b7:	55                   	push   %ebp
c01058b8:	89 e5                	mov    %esp,%ebp
c01058ba:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01058bd:	8d 45 14             	lea    0x14(%ebp),%eax
c01058c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01058cd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01058db:	89 04 24             	mov    %eax,(%esp)
c01058de:	e8 02 00 00 00       	call   c01058e5 <vprintfmt>
    va_end(ap);
}
c01058e3:	c9                   	leave  
c01058e4:	c3                   	ret    

c01058e5 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01058e5:	55                   	push   %ebp
c01058e6:	89 e5                	mov    %esp,%ebp
c01058e8:	56                   	push   %esi
c01058e9:	53                   	push   %ebx
c01058ea:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01058ed:	eb 18                	jmp    c0105907 <vprintfmt+0x22>
            if (ch == '\0') {
c01058ef:	85 db                	test   %ebx,%ebx
c01058f1:	75 05                	jne    c01058f8 <vprintfmt+0x13>
                return;
c01058f3:	e9 d1 03 00 00       	jmp    c0105cc9 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01058f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058ff:	89 1c 24             	mov    %ebx,(%esp)
c0105902:	8b 45 08             	mov    0x8(%ebp),%eax
c0105905:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105907:	8b 45 10             	mov    0x10(%ebp),%eax
c010590a:	8d 50 01             	lea    0x1(%eax),%edx
c010590d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105910:	0f b6 00             	movzbl (%eax),%eax
c0105913:	0f b6 d8             	movzbl %al,%ebx
c0105916:	83 fb 25             	cmp    $0x25,%ebx
c0105919:	75 d4                	jne    c01058ef <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010591b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010591f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105929:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010592c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105933:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105936:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105939:	8b 45 10             	mov    0x10(%ebp),%eax
c010593c:	8d 50 01             	lea    0x1(%eax),%edx
c010593f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105942:	0f b6 00             	movzbl (%eax),%eax
c0105945:	0f b6 d8             	movzbl %al,%ebx
c0105948:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010594b:	83 f8 55             	cmp    $0x55,%eax
c010594e:	0f 87 44 03 00 00    	ja     c0105c98 <vprintfmt+0x3b3>
c0105954:	8b 04 85 38 6f 10 c0 	mov    -0x3fef90c8(,%eax,4),%eax
c010595b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010595d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105961:	eb d6                	jmp    c0105939 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105963:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105967:	eb d0                	jmp    c0105939 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105969:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105970:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105973:	89 d0                	mov    %edx,%eax
c0105975:	c1 e0 02             	shl    $0x2,%eax
c0105978:	01 d0                	add    %edx,%eax
c010597a:	01 c0                	add    %eax,%eax
c010597c:	01 d8                	add    %ebx,%eax
c010597e:	83 e8 30             	sub    $0x30,%eax
c0105981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105984:	8b 45 10             	mov    0x10(%ebp),%eax
c0105987:	0f b6 00             	movzbl (%eax),%eax
c010598a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010598d:	83 fb 2f             	cmp    $0x2f,%ebx
c0105990:	7e 0b                	jle    c010599d <vprintfmt+0xb8>
c0105992:	83 fb 39             	cmp    $0x39,%ebx
c0105995:	7f 06                	jg     c010599d <vprintfmt+0xb8>
            for (precision = 0; ; ++ fmt) {
c0105997:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                    break;
                }
            }
c010599b:	eb d3                	jmp    c0105970 <vprintfmt+0x8b>
            goto process_precision;
c010599d:	eb 33                	jmp    c01059d2 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010599f:	8b 45 14             	mov    0x14(%ebp),%eax
c01059a2:	8d 50 04             	lea    0x4(%eax),%edx
c01059a5:	89 55 14             	mov    %edx,0x14(%ebp)
c01059a8:	8b 00                	mov    (%eax),%eax
c01059aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01059ad:	eb 23                	jmp    c01059d2 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01059af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01059b3:	79 0c                	jns    c01059c1 <vprintfmt+0xdc>
                width = 0;
c01059b5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01059bc:	e9 78 ff ff ff       	jmp    c0105939 <vprintfmt+0x54>
c01059c1:	e9 73 ff ff ff       	jmp    c0105939 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01059c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01059cd:	e9 67 ff ff ff       	jmp    c0105939 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01059d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01059d6:	79 12                	jns    c01059ea <vprintfmt+0x105>
                width = precision, precision = -1;
c01059d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01059de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01059e5:	e9 4f ff ff ff       	jmp    c0105939 <vprintfmt+0x54>
c01059ea:	e9 4a ff ff ff       	jmp    c0105939 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01059ef:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01059f3:	e9 41 ff ff ff       	jmp    c0105939 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01059f8:	8b 45 14             	mov    0x14(%ebp),%eax
c01059fb:	8d 50 04             	lea    0x4(%eax),%edx
c01059fe:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a01:	8b 00                	mov    (%eax),%eax
c0105a03:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a06:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a0a:	89 04 24             	mov    %eax,(%esp)
c0105a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a10:	ff d0                	call   *%eax
            break;
c0105a12:	e9 ac 02 00 00       	jmp    c0105cc3 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105a17:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a1a:	8d 50 04             	lea    0x4(%eax),%edx
c0105a1d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a20:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105a22:	85 db                	test   %ebx,%ebx
c0105a24:	79 02                	jns    c0105a28 <vprintfmt+0x143>
                err = -err;
c0105a26:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105a28:	83 fb 06             	cmp    $0x6,%ebx
c0105a2b:	7f 0b                	jg     c0105a38 <vprintfmt+0x153>
c0105a2d:	8b 34 9d f8 6e 10 c0 	mov    -0x3fef9108(,%ebx,4),%esi
c0105a34:	85 f6                	test   %esi,%esi
c0105a36:	75 23                	jne    c0105a5b <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0105a38:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105a3c:	c7 44 24 08 25 6f 10 	movl   $0xc0106f25,0x8(%esp)
c0105a43:	c0 
c0105a44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a4e:	89 04 24             	mov    %eax,(%esp)
c0105a51:	e8 61 fe ff ff       	call   c01058b7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105a56:	e9 68 02 00 00       	jmp    c0105cc3 <vprintfmt+0x3de>
                printfmt(putch, putdat, "%s", p);
c0105a5b:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105a5f:	c7 44 24 08 2e 6f 10 	movl   $0xc0106f2e,0x8(%esp)
c0105a66:	c0 
c0105a67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a71:	89 04 24             	mov    %eax,(%esp)
c0105a74:	e8 3e fe ff ff       	call   c01058b7 <printfmt>
            break;
c0105a79:	e9 45 02 00 00       	jmp    c0105cc3 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105a7e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a81:	8d 50 04             	lea    0x4(%eax),%edx
c0105a84:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a87:	8b 30                	mov    (%eax),%esi
c0105a89:	85 f6                	test   %esi,%esi
c0105a8b:	75 05                	jne    c0105a92 <vprintfmt+0x1ad>
                p = "(null)";
c0105a8d:	be 31 6f 10 c0       	mov    $0xc0106f31,%esi
            }
            if (width > 0 && padc != '-') {
c0105a92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a96:	7e 3e                	jle    c0105ad6 <vprintfmt+0x1f1>
c0105a98:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105a9c:	74 38                	je     c0105ad6 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105a9e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aa8:	89 34 24             	mov    %esi,(%esp)
c0105aab:	e8 dc f7 ff ff       	call   c010528c <strnlen>
c0105ab0:	29 c3                	sub    %eax,%ebx
c0105ab2:	89 d8                	mov    %ebx,%eax
c0105ab4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ab7:	eb 17                	jmp    c0105ad0 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105ab9:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105abd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ac0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ac4:	89 04 24             	mov    %eax,(%esp)
c0105ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aca:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105acc:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105ad0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ad4:	7f e3                	jg     c0105ab9 <vprintfmt+0x1d4>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105ad6:	eb 38                	jmp    c0105b10 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105ad8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105adc:	74 1f                	je     c0105afd <vprintfmt+0x218>
c0105ade:	83 fb 1f             	cmp    $0x1f,%ebx
c0105ae1:	7e 05                	jle    c0105ae8 <vprintfmt+0x203>
c0105ae3:	83 fb 7e             	cmp    $0x7e,%ebx
c0105ae6:	7e 15                	jle    c0105afd <vprintfmt+0x218>
                    putch('?', putdat);
c0105ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105af6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105af9:	ff d0                	call   *%eax
c0105afb:	eb 0f                	jmp    c0105b0c <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0105afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b04:	89 1c 24             	mov    %ebx,(%esp)
c0105b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0a:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105b0c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105b10:	89 f0                	mov    %esi,%eax
c0105b12:	8d 70 01             	lea    0x1(%eax),%esi
c0105b15:	0f b6 00             	movzbl (%eax),%eax
c0105b18:	0f be d8             	movsbl %al,%ebx
c0105b1b:	85 db                	test   %ebx,%ebx
c0105b1d:	74 10                	je     c0105b2f <vprintfmt+0x24a>
c0105b1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105b23:	78 b3                	js     c0105ad8 <vprintfmt+0x1f3>
c0105b25:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105b29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105b2d:	79 a9                	jns    c0105ad8 <vprintfmt+0x1f3>
                }
            }
            for (; width > 0; width --) {
c0105b2f:	eb 17                	jmp    c0105b48 <vprintfmt+0x263>
                putch(' ', putdat);
c0105b31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b38:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b42:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105b44:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105b48:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b4c:	7f e3                	jg     c0105b31 <vprintfmt+0x24c>
            }
            break;
c0105b4e:	e9 70 01 00 00       	jmp    c0105cc3 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b5a:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b5d:	89 04 24             	mov    %eax,(%esp)
c0105b60:	e8 0b fd ff ff       	call   c0105870 <getint>
c0105b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b68:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b71:	85 d2                	test   %edx,%edx
c0105b73:	79 26                	jns    c0105b9b <vprintfmt+0x2b6>
                putch('-', putdat);
c0105b75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b7c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b86:	ff d0                	call   *%eax
                num = -(long long)num;
c0105b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b8e:	f7 d8                	neg    %eax
c0105b90:	83 d2 00             	adc    $0x0,%edx
c0105b93:	f7 da                	neg    %edx
c0105b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b98:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105b9b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105ba2:	e9 a8 00 00 00       	jmp    c0105c4f <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105ba7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105baa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bae:	8d 45 14             	lea    0x14(%ebp),%eax
c0105bb1:	89 04 24             	mov    %eax,(%esp)
c0105bb4:	e8 68 fc ff ff       	call   c0105821 <getuint>
c0105bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bbc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105bbf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105bc6:	e9 84 00 00 00       	jmp    c0105c4f <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105bcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bd2:	8d 45 14             	lea    0x14(%ebp),%eax
c0105bd5:	89 04 24             	mov    %eax,(%esp)
c0105bd8:	e8 44 fc ff ff       	call   c0105821 <getuint>
c0105bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105be0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105be3:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105bea:	eb 63                	jmp    c0105c4f <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105bec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bf3:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfd:	ff d0                	call   *%eax
            putch('x', putdat);
c0105bff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c06:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105c0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c10:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105c12:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c15:	8d 50 04             	lea    0x4(%eax),%edx
c0105c18:	89 55 14             	mov    %edx,0x14(%ebp)
c0105c1b:	8b 00                	mov    (%eax),%eax
c0105c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105c27:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105c2e:	eb 1f                	jmp    c0105c4f <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c37:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c3a:	89 04 24             	mov    %eax,(%esp)
c0105c3d:	e8 df fb ff ff       	call   c0105821 <getuint>
c0105c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c45:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105c48:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105c4f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c56:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105c5a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105c5d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105c61:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105c73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7d:	89 04 24             	mov    %eax,(%esp)
c0105c80:	e8 97 fa ff ff       	call   c010571c <printnum>
            break;
c0105c85:	eb 3c                	jmp    c0105cc3 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c8e:	89 1c 24             	mov    %ebx,(%esp)
c0105c91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c94:	ff d0                	call   *%eax
            break;
c0105c96:	eb 2b                	jmp    c0105cc3 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105c98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c9f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105ca6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca9:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105cab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105caf:	eb 04                	jmp    c0105cb5 <vprintfmt+0x3d0>
c0105cb1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105cb5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cb8:	83 e8 01             	sub    $0x1,%eax
c0105cbb:	0f b6 00             	movzbl (%eax),%eax
c0105cbe:	3c 25                	cmp    $0x25,%al
c0105cc0:	75 ef                	jne    c0105cb1 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105cc2:	90                   	nop
        }
    }
c0105cc3:	90                   	nop
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105cc4:	e9 3e fc ff ff       	jmp    c0105907 <vprintfmt+0x22>
}
c0105cc9:	83 c4 40             	add    $0x40,%esp
c0105ccc:	5b                   	pop    %ebx
c0105ccd:	5e                   	pop    %esi
c0105cce:	5d                   	pop    %ebp
c0105ccf:	c3                   	ret    

c0105cd0 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105cd0:	55                   	push   %ebp
c0105cd1:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd6:	8b 40 08             	mov    0x8(%eax),%eax
c0105cd9:	8d 50 01             	lea    0x1(%eax),%edx
c0105cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cdf:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce5:	8b 10                	mov    (%eax),%edx
c0105ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cea:	8b 40 04             	mov    0x4(%eax),%eax
c0105ced:	39 c2                	cmp    %eax,%edx
c0105cef:	73 12                	jae    c0105d03 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf4:	8b 00                	mov    (%eax),%eax
c0105cf6:	8d 48 01             	lea    0x1(%eax),%ecx
c0105cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105cfc:	89 0a                	mov    %ecx,(%edx)
c0105cfe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d01:	88 10                	mov    %dl,(%eax)
    }
}
c0105d03:	5d                   	pop    %ebp
c0105d04:	c3                   	ret    

c0105d05 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105d05:	55                   	push   %ebp
c0105d06:	89 e5                	mov    %esp,%ebp
c0105d08:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105d0b:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d14:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d18:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d26:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d29:	89 04 24             	mov    %eax,(%esp)
c0105d2c:	e8 08 00 00 00       	call   c0105d39 <vsnprintf>
c0105d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d37:	c9                   	leave  
c0105d38:	c3                   	ret    

c0105d39 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105d39:	55                   	push   %ebp
c0105d3a:	89 e5                	mov    %esp,%ebp
c0105d3c:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d42:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d48:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4e:	01 d0                	add    %edx,%eax
c0105d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105d5a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105d5e:	74 0a                	je     c0105d6a <vsnprintf+0x31>
c0105d60:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d66:	39 c2                	cmp    %eax,%edx
c0105d68:	76 07                	jbe    c0105d71 <vsnprintf+0x38>
        return -E_INVAL;
c0105d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105d6f:	eb 2a                	jmp    c0105d9b <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105d71:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d78:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d86:	c7 04 24 d0 5c 10 c0 	movl   $0xc0105cd0,(%esp)
c0105d8d:	e8 53 fb ff ff       	call   c01058e5 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d95:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d9b:	c9                   	leave  
c0105d9c:	c3                   	ret    

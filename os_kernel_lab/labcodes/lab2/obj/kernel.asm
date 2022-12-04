
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 c0 11 00       	mov    $0x11c000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 c0 11 c0       	mov    %eax,0xc011c000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 b0 11 c0       	mov    $0xc011b000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 8c ef 11 c0       	mov    $0xc011ef8c,%eax
c0100041:	2d 00 e0 11 c0       	sub    $0xc011e000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 e0 11 c0 	movl   $0xc011e000,(%esp)
c0100059:	e8 26 6e 00 00       	call   c0106e84 <memset>

    cons_init();                // init the console
c010005e:	e8 df 15 00 00       	call   c0101642 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 20 70 10 c0 	movl   $0xc0107020,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 3c 70 10 c0 	movl   $0xc010703c,(%esp)
c0100078:	e8 d9 02 00 00       	call   c0100356 <cprintf>

    print_kerninfo();
c010007d:	e8 f7 07 00 00       	call   c0100879 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 90 00 00 00       	call   c0100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 02 53 00 00       	call   c010538e <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 32 17 00 00       	call   c01017c3 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 b9 18 00 00       	call   c010194f <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 06 0d 00 00       	call   c0100da1 <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 81 16 00 00       	call   c0101721 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a0:	eb fe                	jmp    c01000a0 <kern_init+0x6a>

c01000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a2:	55                   	push   %ebp
c01000a3:	89 e5                	mov    %esp,%ebp
c01000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000af:	00 
c01000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000b7:	00 
c01000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000bf:	e8 f8 0b 00 00       	call   c0100cbc <mon_backtrace>
}
c01000c4:	90                   	nop
c01000c5:	89 ec                	mov    %ebp,%esp
c01000c7:	5d                   	pop    %ebp
c01000c8:	c3                   	ret    

c01000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c9:	55                   	push   %ebp
c01000ca:	89 e5                	mov    %esp,%ebp
c01000cc:	83 ec 18             	sub    $0x18,%esp
c01000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b0 ff ff ff       	call   c01000a2 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f6:	89 ec                	mov    %ebp,%esp
c01000f8:	5d                   	pop    %ebp
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100100:	8b 45 10             	mov    0x10(%ebp),%eax
c0100103:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100107:	8b 45 08             	mov    0x8(%ebp),%eax
c010010a:	89 04 24             	mov    %eax,(%esp)
c010010d:	e8 b7 ff ff ff       	call   c01000c9 <grade_backtrace1>
}
c0100112:	90                   	nop
c0100113:	89 ec                	mov    %ebp,%esp
c0100115:	5d                   	pop    %ebp
c0100116:	c3                   	ret    

c0100117 <grade_backtrace>:

void
grade_backtrace(void) {
c0100117:	55                   	push   %ebp
c0100118:	89 e5                	mov    %esp,%ebp
c010011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011d:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100129:	ff 
c010012a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100135:	e8 c0 ff ff ff       	call   c01000fa <grade_backtrace0>
}
c010013a:	90                   	nop
c010013b:	89 ec                	mov    %ebp,%esp
c010013d:	5d                   	pop    %ebp
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 41 70 10 c0 	movl   $0xc0107041,(%esp)
c010016e:	e8 e3 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 4f 70 10 c0 	movl   $0xc010704f,(%esp)
c010018d:	e8 c4 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 5d 70 10 c0 	movl   $0xc010705d,(%esp)
c01001ac:	e8 a5 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 6b 70 10 c0 	movl   $0xc010706b,(%esp)
c01001cb:	e8 86 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 79 70 10 c0 	movl   $0xc0107079,(%esp)
c01001ea:	e8 67 01 00 00       	call   c0100356 <cprintf>
    round ++;
c01001ef:	a1 00 e0 11 c0       	mov    0xc011e000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 e0 11 c0       	mov    %eax,0xc011e000
}
c01001fa:	90                   	nop
c01001fb:	89 ec                	mov    %ebp,%esp
c01001fd:	5d                   	pop    %ebp
c01001fe:	c3                   	ret    

c01001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ff:	55                   	push   %ebp
c0100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100208:	90                   	nop
c0100209:	5d                   	pop    %ebp
c010020a:	c3                   	ret    

c010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
c010020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100211:	e8 29 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100216:	c7 04 24 88 70 10 c0 	movl   $0xc0107088,(%esp)
c010021d:	e8 34 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_user();
c0100222:	e8 d8 ff ff ff       	call   c01001ff <lab1_switch_to_user>
    lab1_print_cur_status();
c0100227:	e8 13 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022c:	c7 04 24 a8 70 10 c0 	movl   $0xc01070a8,(%esp)
c0100233:	e8 1e 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_kernel();
c0100238:	e8 c8 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023d:	e8 fd fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100242:	90                   	nop
c0100243:	89 ec                	mov    %ebp,%esp
c0100245:	5d                   	pop    %ebp
c0100246:	c3                   	ret    

c0100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100247:	55                   	push   %ebp
c0100248:	89 e5                	mov    %esp,%ebp
c010024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100251:	74 13                	je     c0100266 <readline+0x1f>
        cprintf("%s", prompt);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025a:	c7 04 24 c7 70 10 c0 	movl   $0xc01070c7,(%esp)
c0100261:	e8 f0 00 00 00       	call   c0100356 <cprintf>
    }
    int i = 0, c;
c0100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010026d:	e8 73 01 00 00       	call   c01003e5 <getchar>
c0100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100279:	79 07                	jns    c0100282 <readline+0x3b>
            return NULL;
c010027b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100280:	eb 78                	jmp    c01002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100286:	7e 28                	jle    c01002b0 <readline+0x69>
c0100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010028f:	7f 1f                	jg     c01002b0 <readline+0x69>
            cputchar(c);
c0100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100294:	89 04 24             	mov    %eax,(%esp)
c0100297:	e8 e2 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010029f:	8d 50 01             	lea    0x1(%eax),%edx
c01002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a8:	88 90 20 e0 11 c0    	mov    %dl,-0x3fee1fe0(%eax)
c01002ae:	eb 45                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b4:	75 16                	jne    c01002cc <readline+0x85>
c01002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ba:	7e 10                	jle    c01002cc <readline+0x85>
            cputchar(c);
c01002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 b7 00 00 00       	call   c010037e <cputchar>
            i --;
c01002c7:	ff 4d f4             	decl   -0xc(%ebp)
c01002ca:	eb 29                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d0:	74 06                	je     c01002d8 <readline+0x91>
c01002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d6:	75 95                	jne    c010026d <readline+0x26>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 9b 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e6:	05 20 e0 11 c0       	add    $0xc011e020,%eax
c01002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ee:	b8 20 e0 11 c0       	mov    $0xc011e020,%eax
c01002f3:	eb 05                	jmp    c01002fa <readline+0xb3>
        c = getchar();
c01002f5:	e9 73 ff ff ff       	jmp    c010026d <readline+0x26>
        }
    }
}
c01002fa:	89 ec                	mov    %ebp,%esp
c01002fc:	5d                   	pop    %ebp
c01002fd:	c3                   	ret    

c01002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	89 04 24             	mov    %eax,(%esp)
c010030a:	e8 62 13 00 00       	call   c0101671 <cons_putc>
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	89 ec                	mov    %ebp,%esp
c010031f:	5d                   	pop    %ebp
c0100320:	c3                   	ret    

c0100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100321:	55                   	push   %ebp
c0100322:	89 e5                	mov    %esp,%ebp
c0100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100335:	8b 45 08             	mov    0x8(%ebp),%eax
c0100338:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100343:	c7 04 24 fe 02 10 c0 	movl   $0xc01002fe,(%esp)
c010034a:	e8 60 63 00 00       	call   c01066af <vprintfmt>
    return cnt;
c010034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100352:	89 ec                	mov    %ebp,%esp
c0100354:	5d                   	pop    %ebp
c0100355:	c3                   	ret    

c0100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100356:	55                   	push   %ebp
c0100357:	89 e5                	mov    %esp,%ebp
c0100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100369:	8b 45 08             	mov    0x8(%ebp),%eax
c010036c:	89 04 24             	mov    %eax,(%esp)
c010036f:	e8 ad ff ff ff       	call   c0100321 <vcprintf>
c0100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	89 ec                	mov    %ebp,%esp
c010037c:	5d                   	pop    %ebp
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 e2 12 00 00       	call   c0101671 <cons_putc>
}
c010038f:	90                   	nop
c0100390:	89 ec                	mov    %ebp,%esp
c0100392:	5d                   	pop    %ebp
c0100393:	c3                   	ret    

c0100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100394:	55                   	push   %ebp
c0100395:	89 e5                	mov    %esp,%ebp
c0100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a1:	eb 13                	jmp    c01003b6 <cputs+0x22>
        cputch(c, &cnt);
c01003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ae:	89 04 24             	mov    %eax,(%esp)
c01003b1:	e8 48 ff ff ff       	call   c01002fe <cputch>
    while ((c = *str ++) != '\0') {
c01003b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b9:	8d 50 01             	lea    0x1(%eax),%edx
c01003bc:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bf:	0f b6 00             	movzbl (%eax),%eax
c01003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c9:	75 d8                	jne    c01003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d9:	e8 20 ff ff ff       	call   c01002fe <cputch>
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	89 ec                	mov    %ebp,%esp
c01003e3:	5d                   	pop    %ebp
c01003e4:	c3                   	ret    

c01003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e5:	55                   	push   %ebp
c01003e6:	89 e5                	mov    %esp,%ebp
c01003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003eb:	90                   	nop
c01003ec:	e8 bf 12 00 00       	call   c01016b0 <cons_getc>
c01003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f8:	74 f2                	je     c01003ec <getchar+0x7>
        /* do nothing */;
    return c;
c01003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100412:	8b 00                	mov    (%eax),%eax
c0100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041e:	e9 ca 00 00 00       	jmp    c01004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100429:	01 d0                	add    %edx,%eax
c010042b:	89 c2                	mov    %eax,%edx
c010042d:	c1 ea 1f             	shr    $0x1f,%edx
c0100430:	01 d0                	add    %edx,%eax
c0100432:	d1 f8                	sar    %eax
c0100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043d:	eb 03                	jmp    c0100442 <stab_binsearch+0x41>
            m --;
c010043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x68>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100467:	75 d6                	jne    c010043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 09                	jge    c010047a <stab_binsearch+0x79>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	40                   	inc    %eax
c0100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100478:	eb 73                	jmp    c01004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100484:	89 d0                	mov    %edx,%eax
c0100486:	01 c0                	add    %eax,%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	c1 e0 02             	shl    $0x2,%eax
c010048d:	89 c2                	mov    %eax,%edx
c010048f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100492:	01 d0                	add    %edx,%eax
c0100494:	8b 40 08             	mov    0x8(%eax),%eax
c0100497:	39 45 18             	cmp    %eax,0x18(%ebp)
c010049a:	76 11                	jbe    c01004ad <stab_binsearch+0xac>
            *region_left = m;
c010049c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a7:	40                   	inc    %eax
c01004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ab:	eb 40                	jmp    c01004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b0:	89 d0                	mov    %edx,%eax
c01004b2:	01 c0                	add    %eax,%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	c1 e0 02             	shl    $0x2,%eax
c01004b9:	89 c2                	mov    %eax,%edx
c01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01004be:	01 d0                	add    %edx,%eax
c01004c0:	8b 40 08             	mov    0x8(%eax),%eax
c01004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004c6:	73 14                	jae    c01004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	48                   	dec    %eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	eb 11                	jmp    c01004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e2:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 2a ff ff ff    	jle    c0100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010050c:	eb 3e                	jmp    c010054c <stab_binsearch+0x14b>
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 03                	jmp    c010051b <stab_binsearch+0x11a>
c0100518:	ff 4d fc             	decl   -0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100523:	7e 1f                	jle    c0100544 <stab_binsearch+0x143>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100542:	75 d4                	jne    c0100518 <stab_binsearch+0x117>
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
}
c010054c:	90                   	nop
c010054d:	89 ec                	mov    %ebp,%esp
c010054f:	5d                   	pop    %ebp
c0100550:	c3                   	ret    

c0100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100551:	55                   	push   %ebp
c0100552:	89 e5                	mov    %esp,%ebp
c0100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 00 cc 70 10 c0    	movl   $0xc01070cc,(%eax)
    info->eip_line = 0;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 08 cc 70 10 c0 	movl   $0xc01070cc,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	8b 55 08             	mov    0x8(%ebp),%edx
c0100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100591:	c7 45 f4 c4 85 10 c0 	movl   $0xc01085c4,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100598:	c7 45 f0 48 55 11 c0 	movl   $0xc0115548,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059f:	c7 45 ec 49 55 11 c0 	movl   $0xc0115549,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a6:	c7 45 e8 81 8e 11 c0 	movl   $0xc0118e81,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b3:	76 0b                	jbe    c01005c0 <debuginfo_eip+0x6f>
c01005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b8:	48                   	dec    %eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x79>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 ab 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005d7:	c1 f8 02             	sar    $0x2,%eax
c01005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e0:	48                   	dec    %eax
c01005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f2:	00 
c01005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100604:	89 04 24             	mov    %eax,(%esp)
c0100607:	e8 f5 fd ff ff       	call   c0100401 <stab_binsearch>
    if (lfile == 0)
c010060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	75 0a                	jne    c010061d <debuginfo_eip+0xcc>
        return -1;
c0100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100618:	e9 58 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 b0 fd ff ff       	call   c0100401 <stab_binsearch>

    if (lfun <= rfun) {
c0100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100657:	39 c2                	cmp    %eax,%edx
c0100659:	7f 78                	jg     c01006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	89 d0                	mov    %edx,%eax
c0100662:	01 c0                	add    %eax,%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	c1 e0 02             	shl    $0x2,%eax
c0100669:	89 c2                	mov    %eax,%edx
c010066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066e:	01 d0                	add    %edx,%eax
c0100670:	8b 10                	mov    (%eax),%edx
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100678:	39 c2                	cmp    %eax,%edx
c010067a:	73 22                	jae    c010069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010067f:	89 c2                	mov    %eax,%edx
c0100681:	89 d0                	mov    %edx,%eax
c0100683:	01 c0                	add    %eax,%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	c1 e0 02             	shl    $0x2,%eax
c010068a:	89 c2                	mov    %eax,%edx
c010068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	8b 10                	mov    (%eax),%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	01 c2                	add    %eax,%edx
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 50 08             	mov    0x8(%eax),%edx
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bf:	8b 40 10             	mov    0x10(%eax),%eax
c01006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d1:	eb 15                	jmp    c01006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006eb:	8b 40 08             	mov    0x8(%eax),%eax
c01006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006f5:	00 
c01006f6:	89 04 24             	mov    %eax,(%esp)
c01006f9:	e8 fe 65 00 00       	call   c0106cfc <strfind>
c01006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100701:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100704:	29 c8                	sub    %ecx,%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010070e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100711:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010071c:	00 
c010071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100720:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 cb fc ff ff       	call   c0100401 <stab_binsearch>
    if (lline <= rline) {
c0100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	39 c2                	cmp    %eax,%edx
c010073e:	7f 23                	jg     c0100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	89 d0                	mov    %edx,%eax
c0100747:	01 c0                	add    %eax,%eax
c0100749:	01 d0                	add    %edx,%eax
c010074b:	c1 e0 02             	shl    $0x2,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100759:	89 c2                	mov    %eax,%edx
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100761:	eb 11                	jmp    c0100774 <debuginfo_eip+0x223>
        return -1;
c0100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100768:	e9 08 01 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	48                   	dec    %eax
c0100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	7c 56                	jl     c01007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100797:	3c 84                	cmp    $0x84,%al
c0100799:	74 39                	je     c01007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b4:	3c 64                	cmp    $0x64,%al
c01007b6:	75 b5                	jne    c010076d <debuginfo_eip+0x21c>
c01007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	89 d0                	mov    %edx,%eax
c01007bf:	01 c0                	add    %eax,%eax
c01007c1:	01 d0                	add    %edx,%eax
c01007c3:	c1 e0 02             	shl    $0x2,%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cb:	01 d0                	add    %edx,%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	85 c0                	test   %eax,%eax
c01007d2:	74 99                	je     c010076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007da:	39 c2                	cmp    %eax,%edx
c01007dc:	7c 42                	jl     c0100820 <debuginfo_eip+0x2cf>
c01007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e1:	89 c2                	mov    %eax,%edx
c01007e3:	89 d0                	mov    %edx,%eax
c01007e5:	01 c0                	add    %eax,%eax
c01007e7:	01 d0                	add    %edx,%eax
c01007e9:	c1 e0 02             	shl    $0x2,%eax
c01007ec:	89 c2                	mov    %eax,%edx
c01007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f1:	01 d0                	add    %edx,%eax
c01007f3:	8b 10                	mov    (%eax),%edx
c01007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 46                	jge    c0100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	40                   	inc    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100831:	eb 16                	jmp    c0100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	8b 40 14             	mov    0x14(%eax),%eax
c0100839:	8d 50 01             	lea    0x1(%eax),%edx
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100845:	40                   	inc    %eax
c0100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010084f:	39 c2                	cmp    %eax,%edx
c0100851:	7d 1d                	jge    c0100870 <debuginfo_eip+0x31f>
c0100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	89 d0                	mov    %edx,%eax
c010085a:	01 c0                	add    %eax,%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	c1 e0 02             	shl    $0x2,%eax
c0100861:	89 c2                	mov    %eax,%edx
c0100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086c:	3c a0                	cmp    $0xa0,%al
c010086e:	74 c3                	je     c0100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100875:	89 ec                	mov    %ebp,%esp
c0100877:	5d                   	pop    %ebp
c0100878:	c3                   	ret    

c0100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100879:	55                   	push   %ebp
c010087a:	89 e5                	mov    %esp,%ebp
c010087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010087f:	c7 04 24 d6 70 10 c0 	movl   $0xc01070d6,(%esp)
c0100886:	e8 cb fa ff ff       	call   c0100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100892:	c0 
c0100893:	c7 04 24 ef 70 10 c0 	movl   $0xc01070ef,(%esp)
c010089a:	e8 b7 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010089f:	c7 44 24 04 10 70 10 	movl   $0xc0107010,0x4(%esp)
c01008a6:	c0 
c01008a7:	c7 04 24 07 71 10 c0 	movl   $0xc0107107,(%esp)
c01008ae:	e8 a3 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b3:	c7 44 24 04 00 e0 11 	movl   $0xc011e000,0x4(%esp)
c01008ba:	c0 
c01008bb:	c7 04 24 1f 71 10 c0 	movl   $0xc010711f,(%esp)
c01008c2:	e8 8f fa ff ff       	call   c0100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c7:	c7 44 24 04 8c ef 11 	movl   $0xc011ef8c,0x4(%esp)
c01008ce:	c0 
c01008cf:	c7 04 24 37 71 10 c0 	movl   $0xc0107137,(%esp)
c01008d6:	e8 7b fa ff ff       	call   c0100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008db:	b8 8c ef 11 c0       	mov    $0xc011ef8c,%eax
c01008e0:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f0:	85 c0                	test   %eax,%eax
c01008f2:	0f 48 c2             	cmovs  %edx,%eax
c01008f5:	c1 f8 0a             	sar    $0xa,%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	c7 04 24 50 71 10 c0 	movl   $0xc0107150,(%esp)
c0100903:	e8 4e fa ff ff       	call   c0100356 <cprintf>
}
c0100908:	90                   	nop
c0100909:	89 ec                	mov    %ebp,%esp
c010090b:	5d                   	pop    %ebp
c010090c:	c3                   	ret    

c010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010090d:	55                   	push   %ebp
c010090e:	89 e5                	mov    %esp,%ebp
c0100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100920:	89 04 24             	mov    %eax,(%esp)
c0100923:	e8 29 fc ff ff       	call   c0100551 <debuginfo_eip>
c0100928:	85 c0                	test   %eax,%eax
c010092a:	74 15                	je     c0100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100933:	c7 04 24 7a 71 10 c0 	movl   $0xc010717a,(%esp)
c010093a:	e8 17 fa ff ff       	call   c0100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010093f:	eb 6c                	jmp    c01009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100948:	eb 1b                	jmp    c0100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	01 d0                	add    %edx,%eax
c0100952:	0f b6 10             	movzbl (%eax),%edx
c0100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095e:	01 c8                	add    %ecx,%eax
c0100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100962:	ff 45 f4             	incl   -0xc(%ebp)
c0100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096b:	7c dd                	jl     c010094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100976:	01 d0                	add    %edx,%eax
c0100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010097e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100981:	29 d0                	sub    %edx,%eax
c0100983:	89 c1                	mov    %eax,%ecx
c0100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100999:	89 54 24 08          	mov    %edx,0x8(%esp)
c010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a1:	c7 04 24 96 71 10 c0 	movl   $0xc0107196,(%esp)
c01009a8:	e8 a9 f9 ff ff       	call   c0100356 <cprintf>
}
c01009ad:	90                   	nop
c01009ae:	89 ec                	mov    %ebp,%esp
c01009b0:	5d                   	pop    %ebp
c01009b1:	c3                   	ret    

c01009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b2:	55                   	push   %ebp
c01009b3:	89 e5                	mov    %esp,%ebp
c01009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009b8:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c1:	89 ec                	mov    %ebp,%esp
c01009c3:	5d                   	pop    %ebp
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cb:	89 e8                	mov    %ebp,%eax
c01009cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t* ebp = (uint32_t *)read_ebp();
c01009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c01009d6:	e8 d7 ff ff ff       	call   c01009b2 <read_eip>
c01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
        for (int i = 0; i < STACKFRAME_DEPTH && (uint32_t)ebp != 0; ++ i) {
c01009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e5:	eb 7c                	jmp    c0100a63 <print_stackframe+0x9e>
        cprintf("ebp:0x%08x eip:0x%08x args:", (uint32_t)ebp, eip);
c01009e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01009ed:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f5:	c7 04 24 a8 71 10 c0 	movl   $0xc01071a8,(%esp)
c01009fc:	e8 55 f9 ff ff       	call   c0100356 <cprintf>
        for (int argi = 0; argi < 4; argi++) {
c0100a01:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a08:	eb 27                	jmp    c0100a31 <print_stackframe+0x6c>
            cprintf("0x%08x ", ebp[2 + argi]);
c0100a0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a0d:	83 c0 02             	add    $0x2,%eax
c0100a10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a1a:	01 d0                	add    %edx,%eax
c0100a1c:	8b 00                	mov    (%eax),%eax
c0100a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a22:	c7 04 24 c4 71 10 c0 	movl   $0xc01071c4,(%esp)
c0100a29:	e8 28 f9 ff ff       	call   c0100356 <cprintf>
        for (int argi = 0; argi < 4; argi++) {
c0100a2e:	ff 45 e8             	incl   -0x18(%ebp)
c0100a31:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a35:	7e d3                	jle    c0100a0a <print_stackframe+0x45>
        }
        cprintf("\n");
c0100a37:	c7 04 24 cc 71 10 c0 	movl   $0xc01071cc,(%esp)
c0100a3e:	e8 13 f9 ff ff       	call   c0100356 <cprintf>
        print_debuginfo(eip - 1);
c0100a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a46:	48                   	dec    %eax
c0100a47:	89 04 24             	mov    %eax,(%esp)
c0100a4a:	e8 be fe ff ff       	call   c010090d <print_debuginfo>
        eip = ebp[1];//更新为其指向的位置上前一个字的值，函数返回的pc跳转地址
c0100a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a52:	8b 40 04             	mov    0x4(%eax),%eax
c0100a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = (uint32_t *)*ebp;//更新为其指向的位置上的值，这里存储着上一个栈块的ebp
c0100a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5b:	8b 00                	mov    (%eax),%eax
c0100a5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (int i = 0; i < STACKFRAME_DEPTH && (uint32_t)ebp != 0; ++ i) {
c0100a60:	ff 45 ec             	incl   -0x14(%ebp)
c0100a63:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a67:	7f 0a                	jg     c0100a73 <print_stackframe+0xae>
c0100a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a6d:	0f 85 74 ff ff ff    	jne    c01009e7 <print_stackframe+0x22>
    }
}
c0100a73:	90                   	nop
c0100a74:	89 ec                	mov    %ebp,%esp
c0100a76:	5d                   	pop    %ebp
c0100a77:	c3                   	ret    

c0100a78 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a78:	55                   	push   %ebp
c0100a79:	89 e5                	mov    %esp,%ebp
c0100a7b:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a85:	eb 0c                	jmp    c0100a93 <parse+0x1b>
            *buf ++ = '\0';
c0100a87:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8a:	8d 50 01             	lea    0x1(%eax),%edx
c0100a8d:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a90:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a96:	0f b6 00             	movzbl (%eax),%eax
c0100a99:	84 c0                	test   %al,%al
c0100a9b:	74 1d                	je     c0100aba <parse+0x42>
c0100a9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa0:	0f b6 00             	movzbl (%eax),%eax
c0100aa3:	0f be c0             	movsbl %al,%eax
c0100aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aaa:	c7 04 24 50 72 10 c0 	movl   $0xc0107250,(%esp)
c0100ab1:	e8 12 62 00 00       	call   c0106cc8 <strchr>
c0100ab6:	85 c0                	test   %eax,%eax
c0100ab8:	75 cd                	jne    c0100a87 <parse+0xf>
        }
        if (*buf == '\0') {
c0100aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abd:	0f b6 00             	movzbl (%eax),%eax
c0100ac0:	84 c0                	test   %al,%al
c0100ac2:	74 65                	je     c0100b29 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ac4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ac8:	75 14                	jne    c0100ade <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100aca:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ad1:	00 
c0100ad2:	c7 04 24 55 72 10 c0 	movl   $0xc0107255,(%esp)
c0100ad9:	e8 78 f8 ff ff       	call   c0100356 <cprintf>
        }
        argv[argc ++] = buf;
c0100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae1:	8d 50 01             	lea    0x1(%eax),%edx
c0100ae4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100ae7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100aee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100af1:	01 c2                	add    %eax,%edx
c0100af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af6:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100af8:	eb 03                	jmp    c0100afd <parse+0x85>
            buf ++;
c0100afa:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b00:	0f b6 00             	movzbl (%eax),%eax
c0100b03:	84 c0                	test   %al,%al
c0100b05:	74 8c                	je     c0100a93 <parse+0x1b>
c0100b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0a:	0f b6 00             	movzbl (%eax),%eax
c0100b0d:	0f be c0             	movsbl %al,%eax
c0100b10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b14:	c7 04 24 50 72 10 c0 	movl   $0xc0107250,(%esp)
c0100b1b:	e8 a8 61 00 00       	call   c0106cc8 <strchr>
c0100b20:	85 c0                	test   %eax,%eax
c0100b22:	74 d6                	je     c0100afa <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b24:	e9 6a ff ff ff       	jmp    c0100a93 <parse+0x1b>
            break;
c0100b29:	90                   	nop
        }
    }
    return argc;
c0100b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b2d:	89 ec                	mov    %ebp,%esp
c0100b2f:	5d                   	pop    %ebp
c0100b30:	c3                   	ret    

c0100b31 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b31:	55                   	push   %ebp
c0100b32:	89 e5                	mov    %esp,%ebp
c0100b34:	83 ec 68             	sub    $0x68,%esp
c0100b37:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b3a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b44:	89 04 24             	mov    %eax,(%esp)
c0100b47:	e8 2c ff ff ff       	call   c0100a78 <parse>
c0100b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b53:	75 0a                	jne    c0100b5f <runcmd+0x2e>
        return 0;
c0100b55:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b5a:	e9 83 00 00 00       	jmp    c0100be2 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b66:	eb 5a                	jmp    c0100bc2 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b68:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b6b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b6e:	89 c8                	mov    %ecx,%eax
c0100b70:	01 c0                	add    %eax,%eax
c0100b72:	01 c8                	add    %ecx,%eax
c0100b74:	c1 e0 02             	shl    $0x2,%eax
c0100b77:	05 00 b0 11 c0       	add    $0xc011b000,%eax
c0100b7c:	8b 00                	mov    (%eax),%eax
c0100b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b82:	89 04 24             	mov    %eax,(%esp)
c0100b85:	e8 a2 60 00 00       	call   c0106c2c <strcmp>
c0100b8a:	85 c0                	test   %eax,%eax
c0100b8c:	75 31                	jne    c0100bbf <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b91:	89 d0                	mov    %edx,%eax
c0100b93:	01 c0                	add    %eax,%eax
c0100b95:	01 d0                	add    %edx,%eax
c0100b97:	c1 e0 02             	shl    $0x2,%eax
c0100b9a:	05 08 b0 11 c0       	add    $0xc011b008,%eax
c0100b9f:	8b 10                	mov    (%eax),%edx
c0100ba1:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100ba4:	83 c0 04             	add    $0x4,%eax
c0100ba7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100baa:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bb0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bb8:	89 1c 24             	mov    %ebx,(%esp)
c0100bbb:	ff d2                	call   *%edx
c0100bbd:	eb 23                	jmp    c0100be2 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bbf:	ff 45 f4             	incl   -0xc(%ebp)
c0100bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc5:	83 f8 02             	cmp    $0x2,%eax
c0100bc8:	76 9e                	jbe    c0100b68 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bca:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd1:	c7 04 24 73 72 10 c0 	movl   $0xc0107273,(%esp)
c0100bd8:	e8 79 f7 ff ff       	call   c0100356 <cprintf>
    return 0;
c0100bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100be5:	89 ec                	mov    %ebp,%esp
c0100be7:	5d                   	pop    %ebp
c0100be8:	c3                   	ret    

c0100be9 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100be9:	55                   	push   %ebp
c0100bea:	89 e5                	mov    %esp,%ebp
c0100bec:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bef:	c7 04 24 8c 72 10 c0 	movl   $0xc010728c,(%esp)
c0100bf6:	e8 5b f7 ff ff       	call   c0100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100bfb:	c7 04 24 b4 72 10 c0 	movl   $0xc01072b4,(%esp)
c0100c02:	e8 4f f7 ff ff       	call   c0100356 <cprintf>

    if (tf != NULL) {
c0100c07:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c0b:	74 0b                	je     c0100c18 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c10:	89 04 24             	mov    %eax,(%esp)
c0100c13:	e8 f2 0e 00 00       	call   c0101b0a <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c18:	c7 04 24 d9 72 10 c0 	movl   $0xc01072d9,(%esp)
c0100c1f:	e8 23 f6 ff ff       	call   c0100247 <readline>
c0100c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c2b:	74 eb                	je     c0100c18 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c37:	89 04 24             	mov    %eax,(%esp)
c0100c3a:	e8 f2 fe ff ff       	call   c0100b31 <runcmd>
c0100c3f:	85 c0                	test   %eax,%eax
c0100c41:	78 02                	js     c0100c45 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c43:	eb d3                	jmp    c0100c18 <kmonitor+0x2f>
                break;
c0100c45:	90                   	nop
            }
        }
    }
}
c0100c46:	90                   	nop
c0100c47:	89 ec                	mov    %ebp,%esp
c0100c49:	5d                   	pop    %ebp
c0100c4a:	c3                   	ret    

c0100c4b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c4b:	55                   	push   %ebp
c0100c4c:	89 e5                	mov    %esp,%ebp
c0100c4e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c58:	eb 3d                	jmp    c0100c97 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c5d:	89 d0                	mov    %edx,%eax
c0100c5f:	01 c0                	add    %eax,%eax
c0100c61:	01 d0                	add    %edx,%eax
c0100c63:	c1 e0 02             	shl    $0x2,%eax
c0100c66:	05 04 b0 11 c0       	add    $0xc011b004,%eax
c0100c6b:	8b 10                	mov    (%eax),%edx
c0100c6d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c70:	89 c8                	mov    %ecx,%eax
c0100c72:	01 c0                	add    %eax,%eax
c0100c74:	01 c8                	add    %ecx,%eax
c0100c76:	c1 e0 02             	shl    $0x2,%eax
c0100c79:	05 00 b0 11 c0       	add    $0xc011b000,%eax
c0100c7e:	8b 00                	mov    (%eax),%eax
c0100c80:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c88:	c7 04 24 dd 72 10 c0 	movl   $0xc01072dd,(%esp)
c0100c8f:	e8 c2 f6 ff ff       	call   c0100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c94:	ff 45 f4             	incl   -0xc(%ebp)
c0100c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c9a:	83 f8 02             	cmp    $0x2,%eax
c0100c9d:	76 bb                	jbe    c0100c5a <mon_help+0xf>
    }
    return 0;
c0100c9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca4:	89 ec                	mov    %ebp,%esp
c0100ca6:	5d                   	pop    %ebp
c0100ca7:	c3                   	ret    

c0100ca8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ca8:	55                   	push   %ebp
c0100ca9:	89 e5                	mov    %esp,%ebp
c0100cab:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cae:	e8 c6 fb ff ff       	call   c0100879 <print_kerninfo>
    return 0;
c0100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb8:	89 ec                	mov    %ebp,%esp
c0100cba:	5d                   	pop    %ebp
c0100cbb:	c3                   	ret    

c0100cbc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cbc:	55                   	push   %ebp
c0100cbd:	89 e5                	mov    %esp,%ebp
c0100cbf:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc2:	e8 fe fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccc:	89 ec                	mov    %ebp,%esp
c0100cce:	5d                   	pop    %ebp
c0100ccf:	c3                   	ret    

c0100cd0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd0:	55                   	push   %ebp
c0100cd1:	89 e5                	mov    %esp,%ebp
c0100cd3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd6:	a1 20 e4 11 c0       	mov    0xc011e420,%eax
c0100cdb:	85 c0                	test   %eax,%eax
c0100cdd:	75 5b                	jne    c0100d3a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100cdf:	c7 05 20 e4 11 c0 01 	movl   $0x1,0xc011e420
c0100ce6:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ce9:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cef:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cfd:	c7 04 24 e6 72 10 c0 	movl   $0xc01072e6,(%esp)
c0100d04:	e8 4d f6 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d10:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d13:	89 04 24             	mov    %eax,(%esp)
c0100d16:	e8 06 f6 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d1b:	c7 04 24 02 73 10 c0 	movl   $0xc0107302,(%esp)
c0100d22:	e8 2f f6 ff ff       	call   c0100356 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d27:	c7 04 24 04 73 10 c0 	movl   $0xc0107304,(%esp)
c0100d2e:	e8 23 f6 ff ff       	call   c0100356 <cprintf>
    print_stackframe();
c0100d33:	e8 8d fc ff ff       	call   c01009c5 <print_stackframe>
c0100d38:	eb 01                	jmp    c0100d3b <__panic+0x6b>
        goto panic_dead;
c0100d3a:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3b:	e8 e9 09 00 00       	call   c0101729 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d47:	e8 9d fe ff ff       	call   c0100be9 <kmonitor>
c0100d4c:	eb f2                	jmp    c0100d40 <__panic+0x70>

c0100d4e <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4e:	55                   	push   %ebp
c0100d4f:	89 e5                	mov    %esp,%ebp
c0100d51:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d54:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d61:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d68:	c7 04 24 16 73 10 c0 	movl   $0xc0107316,(%esp)
c0100d6f:	e8 e2 f5 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7e:	89 04 24             	mov    %eax,(%esp)
c0100d81:	e8 9b f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d86:	c7 04 24 02 73 10 c0 	movl   $0xc0107302,(%esp)
c0100d8d:	e8 c4 f5 ff ff       	call   c0100356 <cprintf>
    va_end(ap);
}
c0100d92:	90                   	nop
c0100d93:	89 ec                	mov    %ebp,%esp
c0100d95:	5d                   	pop    %ebp
c0100d96:	c3                   	ret    

c0100d97 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d97:	55                   	push   %ebp
c0100d98:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d9a:	a1 20 e4 11 c0       	mov    0xc011e420,%eax
}
c0100d9f:	5d                   	pop    %ebp
c0100da0:	c3                   	ret    

c0100da1 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100da1:	55                   	push   %ebp
c0100da2:	89 e5                	mov    %esp,%ebp
c0100da4:	83 ec 28             	sub    $0x28,%esp
c0100da7:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100dad:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100db1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100db5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100db9:	ee                   	out    %al,(%dx)
}
c0100dba:	90                   	nop
c0100dbb:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dc1:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dcd:	ee                   	out    %al,(%dx)
}
c0100dce:	90                   	nop
c0100dcf:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100dd5:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dd9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ddd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100de1:	ee                   	out    %al,(%dx)
}
c0100de2:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100de3:	c7 05 24 e4 11 c0 00 	movl   $0x0,0xc011e424
c0100dea:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100ded:	c7 04 24 34 73 10 c0 	movl   $0xc0107334,(%esp)
c0100df4:	e8 5d f5 ff ff       	call   c0100356 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e00:	e8 89 09 00 00       	call   c010178e <pic_enable>
}
c0100e05:	90                   	nop
c0100e06:	89 ec                	mov    %ebp,%esp
c0100e08:	5d                   	pop    %ebp
c0100e09:	c3                   	ret    

c0100e0a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e0a:	55                   	push   %ebp
c0100e0b:	89 e5                	mov    %esp,%ebp
c0100e0d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e10:	9c                   	pushf  
c0100e11:	58                   	pop    %eax
c0100e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e18:	25 00 02 00 00       	and    $0x200,%eax
c0100e1d:	85 c0                	test   %eax,%eax
c0100e1f:	74 0c                	je     c0100e2d <__intr_save+0x23>
        intr_disable();
c0100e21:	e8 03 09 00 00       	call   c0101729 <intr_disable>
        return 1;
c0100e26:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e2b:	eb 05                	jmp    c0100e32 <__intr_save+0x28>
    }
    return 0;
c0100e2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e32:	89 ec                	mov    %ebp,%esp
c0100e34:	5d                   	pop    %ebp
c0100e35:	c3                   	ret    

c0100e36 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e36:	55                   	push   %ebp
c0100e37:	89 e5                	mov    %esp,%ebp
c0100e39:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e40:	74 05                	je     c0100e47 <__intr_restore+0x11>
        intr_enable();
c0100e42:	e8 da 08 00 00       	call   c0101721 <intr_enable>
    }
}
c0100e47:	90                   	nop
c0100e48:	89 ec                	mov    %ebp,%esp
c0100e4a:	5d                   	pop    %ebp
c0100e4b:	c3                   	ret    

c0100e4c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e4c:	55                   	push   %ebp
c0100e4d:	89 e5                	mov    %esp,%ebp
c0100e4f:	83 ec 10             	sub    $0x10,%esp
c0100e52:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e58:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e5c:	89 c2                	mov    %eax,%edx
c0100e5e:	ec                   	in     (%dx),%al
c0100e5f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e62:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e68:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6c:	89 c2                	mov    %eax,%edx
c0100e6e:	ec                   	in     (%dx),%al
c0100e6f:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e72:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e78:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e7c:	89 c2                	mov    %eax,%edx
c0100e7e:	ec                   	in     (%dx),%al
c0100e7f:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e82:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e88:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e8c:	89 c2                	mov    %eax,%edx
c0100e8e:	ec                   	in     (%dx),%al
c0100e8f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e92:	90                   	nop
c0100e93:	89 ec                	mov    %ebp,%esp
c0100e95:	5d                   	pop    %ebp
c0100e96:	c3                   	ret    

c0100e97 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e97:	55                   	push   %ebp
c0100e98:	89 e5                	mov    %esp,%ebp
c0100e9a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e9d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea7:	0f b7 00             	movzwl (%eax),%eax
c0100eaa:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb9:	0f b7 00             	movzwl (%eax),%eax
c0100ebc:	0f b7 c0             	movzwl %ax,%eax
c0100ebf:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ec4:	74 12                	je     c0100ed8 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ec6:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ecd:	66 c7 05 46 e4 11 c0 	movw   $0x3b4,0xc011e446
c0100ed4:	b4 03 
c0100ed6:	eb 13                	jmp    c0100eeb <cga_init+0x54>
    } else {
        *cp = was;
c0100ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100edf:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee2:	66 c7 05 46 e4 11 c0 	movw   $0x3d4,0xc011e446
c0100ee9:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eeb:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c0100ef2:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ef6:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100efa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100efe:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f02:	ee                   	out    %al,(%dx)
}
c0100f03:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f04:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c0100f0b:	40                   	inc    %eax
c0100f0c:	0f b7 c0             	movzwl %ax,%eax
c0100f0f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f13:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f17:	89 c2                	mov    %eax,%edx
c0100f19:	ec                   	in     (%dx),%al
c0100f1a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f1d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f21:	0f b6 c0             	movzbl %al,%eax
c0100f24:	c1 e0 08             	shl    $0x8,%eax
c0100f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f2a:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c0100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f41:	ee                   	out    %al,(%dx)
}
c0100f42:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f43:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c0100f4a:	40                   	inc    %eax
c0100f4b:	0f b7 c0             	movzwl %ax,%eax
c0100f4e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f52:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f56:	89 c2                	mov    %eax,%edx
c0100f58:	ec                   	in     (%dx),%al
c0100f59:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f5c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f60:	0f b6 c0             	movzbl %al,%eax
c0100f63:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f66:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f69:	a3 40 e4 11 c0       	mov    %eax,0xc011e440
    crt_pos = pos;
c0100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f71:	0f b7 c0             	movzwl %ax,%eax
c0100f74:	66 a3 44 e4 11 c0    	mov    %ax,0xc011e444
}
c0100f7a:	90                   	nop
c0100f7b:	89 ec                	mov    %ebp,%esp
c0100f7d:	5d                   	pop    %ebp
c0100f7e:	c3                   	ret    

c0100f7f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f7f:	55                   	push   %ebp
c0100f80:	89 e5                	mov    %esp,%ebp
c0100f82:	83 ec 48             	sub    $0x48,%esp
c0100f85:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f8b:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8f:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f93:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f97:	ee                   	out    %al,(%dx)
}
c0100f98:	90                   	nop
c0100f99:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100f9f:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fa3:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fa7:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fab:	ee                   	out    %al,(%dx)
}
c0100fac:	90                   	nop
c0100fad:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fb3:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fb7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fbb:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fbf:	ee                   	out    %al,(%dx)
}
c0100fc0:	90                   	nop
c0100fc1:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fc7:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fcb:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fcf:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fd3:	ee                   	out    %al,(%dx)
}
c0100fd4:	90                   	nop
c0100fd5:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fdb:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fdf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fe3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe7:	ee                   	out    %al,(%dx)
}
c0100fe8:	90                   	nop
c0100fe9:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100fef:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100ff7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ffb:	ee                   	out    %al,(%dx)
}
c0100ffc:	90                   	nop
c0100ffd:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101003:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101007:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010100b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010100f:	ee                   	out    %al,(%dx)
}
c0101010:	90                   	nop
c0101011:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101017:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010101b:	89 c2                	mov    %eax,%edx
c010101d:	ec                   	in     (%dx),%al
c010101e:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101021:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101025:	3c ff                	cmp    $0xff,%al
c0101027:	0f 95 c0             	setne  %al
c010102a:	0f b6 c0             	movzbl %al,%eax
c010102d:	a3 48 e4 11 c0       	mov    %eax,0xc011e448
c0101032:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101038:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010103c:	89 c2                	mov    %eax,%edx
c010103e:	ec                   	in     (%dx),%al
c010103f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101042:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101048:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010104c:	89 c2                	mov    %eax,%edx
c010104e:	ec                   	in     (%dx),%al
c010104f:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101052:	a1 48 e4 11 c0       	mov    0xc011e448,%eax
c0101057:	85 c0                	test   %eax,%eax
c0101059:	74 0c                	je     c0101067 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c010105b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101062:	e8 27 07 00 00       	call   c010178e <pic_enable>
    }
}
c0101067:	90                   	nop
c0101068:	89 ec                	mov    %ebp,%esp
c010106a:	5d                   	pop    %ebp
c010106b:	c3                   	ret    

c010106c <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010106c:	55                   	push   %ebp
c010106d:	89 e5                	mov    %esp,%ebp
c010106f:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101072:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101079:	eb 08                	jmp    c0101083 <lpt_putc_sub+0x17>
        delay();
c010107b:	e8 cc fd ff ff       	call   c0100e4c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101080:	ff 45 fc             	incl   -0x4(%ebp)
c0101083:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101089:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010108d:	89 c2                	mov    %eax,%edx
c010108f:	ec                   	in     (%dx),%al
c0101090:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101093:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101097:	84 c0                	test   %al,%al
c0101099:	78 09                	js     c01010a4 <lpt_putc_sub+0x38>
c010109b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010a2:	7e d7                	jle    c010107b <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01010a7:	0f b6 c0             	movzbl %al,%eax
c01010aa:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010b0:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010b3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010b7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010bb:	ee                   	out    %al,(%dx)
}
c01010bc:	90                   	nop
c01010bd:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010c3:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010c7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010cf:	ee                   	out    %al,(%dx)
}
c01010d0:	90                   	nop
c01010d1:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010d7:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010db:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010df:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010e3:	ee                   	out    %al,(%dx)
}
c01010e4:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010e5:	90                   	nop
c01010e6:	89 ec                	mov    %ebp,%esp
c01010e8:	5d                   	pop    %ebp
c01010e9:	c3                   	ret    

c01010ea <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010ea:	55                   	push   %ebp
c01010eb:	89 e5                	mov    %esp,%ebp
c01010ed:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010f0:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010f4:	74 0d                	je     c0101103 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f9:	89 04 24             	mov    %eax,(%esp)
c01010fc:	e8 6b ff ff ff       	call   c010106c <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101101:	eb 24                	jmp    c0101127 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101103:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010110a:	e8 5d ff ff ff       	call   c010106c <lpt_putc_sub>
        lpt_putc_sub(' ');
c010110f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101116:	e8 51 ff ff ff       	call   c010106c <lpt_putc_sub>
        lpt_putc_sub('\b');
c010111b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101122:	e8 45 ff ff ff       	call   c010106c <lpt_putc_sub>
}
c0101127:	90                   	nop
c0101128:	89 ec                	mov    %ebp,%esp
c010112a:	5d                   	pop    %ebp
c010112b:	c3                   	ret    

c010112c <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010112c:	55                   	push   %ebp
c010112d:	89 e5                	mov    %esp,%ebp
c010112f:	83 ec 38             	sub    $0x38,%esp
c0101132:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101135:	8b 45 08             	mov    0x8(%ebp),%eax
c0101138:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010113d:	85 c0                	test   %eax,%eax
c010113f:	75 07                	jne    c0101148 <cga_putc+0x1c>
        c |= 0x0700;
c0101141:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101148:	8b 45 08             	mov    0x8(%ebp),%eax
c010114b:	0f b6 c0             	movzbl %al,%eax
c010114e:	83 f8 0d             	cmp    $0xd,%eax
c0101151:	74 72                	je     c01011c5 <cga_putc+0x99>
c0101153:	83 f8 0d             	cmp    $0xd,%eax
c0101156:	0f 8f a3 00 00 00    	jg     c01011ff <cga_putc+0xd3>
c010115c:	83 f8 08             	cmp    $0x8,%eax
c010115f:	74 0a                	je     c010116b <cga_putc+0x3f>
c0101161:	83 f8 0a             	cmp    $0xa,%eax
c0101164:	74 4c                	je     c01011b2 <cga_putc+0x86>
c0101166:	e9 94 00 00 00       	jmp    c01011ff <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c010116b:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c0101172:	85 c0                	test   %eax,%eax
c0101174:	0f 84 af 00 00 00    	je     c0101229 <cga_putc+0xfd>
            crt_pos --;
c010117a:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c0101181:	48                   	dec    %eax
c0101182:	0f b7 c0             	movzwl %ax,%eax
c0101185:	66 a3 44 e4 11 c0    	mov    %ax,0xc011e444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010118b:	8b 45 08             	mov    0x8(%ebp),%eax
c010118e:	98                   	cwtl   
c010118f:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101194:	98                   	cwtl   
c0101195:	83 c8 20             	or     $0x20,%eax
c0101198:	98                   	cwtl   
c0101199:	8b 0d 40 e4 11 c0    	mov    0xc011e440,%ecx
c010119f:	0f b7 15 44 e4 11 c0 	movzwl 0xc011e444,%edx
c01011a6:	01 d2                	add    %edx,%edx
c01011a8:	01 ca                	add    %ecx,%edx
c01011aa:	0f b7 c0             	movzwl %ax,%eax
c01011ad:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011b0:	eb 77                	jmp    c0101229 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011b2:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c01011b9:	83 c0 50             	add    $0x50,%eax
c01011bc:	0f b7 c0             	movzwl %ax,%eax
c01011bf:	66 a3 44 e4 11 c0    	mov    %ax,0xc011e444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011c5:	0f b7 1d 44 e4 11 c0 	movzwl 0xc011e444,%ebx
c01011cc:	0f b7 0d 44 e4 11 c0 	movzwl 0xc011e444,%ecx
c01011d3:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011d8:	89 c8                	mov    %ecx,%eax
c01011da:	f7 e2                	mul    %edx
c01011dc:	c1 ea 06             	shr    $0x6,%edx
c01011df:	89 d0                	mov    %edx,%eax
c01011e1:	c1 e0 02             	shl    $0x2,%eax
c01011e4:	01 d0                	add    %edx,%eax
c01011e6:	c1 e0 04             	shl    $0x4,%eax
c01011e9:	29 c1                	sub    %eax,%ecx
c01011eb:	89 ca                	mov    %ecx,%edx
c01011ed:	0f b7 d2             	movzwl %dx,%edx
c01011f0:	89 d8                	mov    %ebx,%eax
c01011f2:	29 d0                	sub    %edx,%eax
c01011f4:	0f b7 c0             	movzwl %ax,%eax
c01011f7:	66 a3 44 e4 11 c0    	mov    %ax,0xc011e444
        break;
c01011fd:	eb 2b                	jmp    c010122a <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011ff:	8b 0d 40 e4 11 c0    	mov    0xc011e440,%ecx
c0101205:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c010120c:	8d 50 01             	lea    0x1(%eax),%edx
c010120f:	0f b7 d2             	movzwl %dx,%edx
c0101212:	66 89 15 44 e4 11 c0 	mov    %dx,0xc011e444
c0101219:	01 c0                	add    %eax,%eax
c010121b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010121e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101221:	0f b7 c0             	movzwl %ax,%eax
c0101224:	66 89 02             	mov    %ax,(%edx)
        break;
c0101227:	eb 01                	jmp    c010122a <cga_putc+0xfe>
        break;
c0101229:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010122a:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c0101231:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101236:	76 5e                	jbe    c0101296 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101238:	a1 40 e4 11 c0       	mov    0xc011e440,%eax
c010123d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101243:	a1 40 e4 11 c0       	mov    0xc011e440,%eax
c0101248:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010124f:	00 
c0101250:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101254:	89 04 24             	mov    %eax,(%esp)
c0101257:	e8 6a 5c 00 00       	call   c0106ec6 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010125c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101263:	eb 15                	jmp    c010127a <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101265:	8b 15 40 e4 11 c0    	mov    0xc011e440,%edx
c010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010126e:	01 c0                	add    %eax,%eax
c0101270:	01 d0                	add    %edx,%eax
c0101272:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101277:	ff 45 f4             	incl   -0xc(%ebp)
c010127a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101281:	7e e2                	jle    c0101265 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c0101283:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c010128a:	83 e8 50             	sub    $0x50,%eax
c010128d:	0f b7 c0             	movzwl %ax,%eax
c0101290:	66 a3 44 e4 11 c0    	mov    %ax,0xc011e444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101296:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c010129d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012a1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012a5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012a9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
}
c01012ae:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012af:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c01012b6:	c1 e8 08             	shr    $0x8,%eax
c01012b9:	0f b7 c0             	movzwl %ax,%eax
c01012bc:	0f b6 c0             	movzbl %al,%eax
c01012bf:	0f b7 15 46 e4 11 c0 	movzwl 0xc011e446,%edx
c01012c6:	42                   	inc    %edx
c01012c7:	0f b7 d2             	movzwl %dx,%edx
c01012ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012ce:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012d1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012d5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012d9:	ee                   	out    %al,(%dx)
}
c01012da:	90                   	nop
    outb(addr_6845, 15);
c01012db:	0f b7 05 46 e4 11 c0 	movzwl 0xc011e446,%eax
c01012e2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012e6:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012ea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012ee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012f2:	ee                   	out    %al,(%dx)
}
c01012f3:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c01012f4:	0f b7 05 44 e4 11 c0 	movzwl 0xc011e444,%eax
c01012fb:	0f b6 c0             	movzbl %al,%eax
c01012fe:	0f b7 15 46 e4 11 c0 	movzwl 0xc011e446,%edx
c0101305:	42                   	inc    %edx
c0101306:	0f b7 d2             	movzwl %dx,%edx
c0101309:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010130d:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101310:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101314:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101318:	ee                   	out    %al,(%dx)
}
c0101319:	90                   	nop
}
c010131a:	90                   	nop
c010131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010131e:	89 ec                	mov    %ebp,%esp
c0101320:	5d                   	pop    %ebp
c0101321:	c3                   	ret    

c0101322 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101322:	55                   	push   %ebp
c0101323:	89 e5                	mov    %esp,%ebp
c0101325:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101328:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010132f:	eb 08                	jmp    c0101339 <serial_putc_sub+0x17>
        delay();
c0101331:	e8 16 fb ff ff       	call   c0100e4c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101336:	ff 45 fc             	incl   -0x4(%ebp)
c0101339:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010133f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101343:	89 c2                	mov    %eax,%edx
c0101345:	ec                   	in     (%dx),%al
c0101346:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101349:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010134d:	0f b6 c0             	movzbl %al,%eax
c0101350:	83 e0 20             	and    $0x20,%eax
c0101353:	85 c0                	test   %eax,%eax
c0101355:	75 09                	jne    c0101360 <serial_putc_sub+0x3e>
c0101357:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010135e:	7e d1                	jle    c0101331 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101360:	8b 45 08             	mov    0x8(%ebp),%eax
c0101363:	0f b6 c0             	movzbl %al,%eax
c0101366:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010136c:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010136f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101373:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101377:	ee                   	out    %al,(%dx)
}
c0101378:	90                   	nop
}
c0101379:	90                   	nop
c010137a:	89 ec                	mov    %ebp,%esp
c010137c:	5d                   	pop    %ebp
c010137d:	c3                   	ret    

c010137e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010137e:	55                   	push   %ebp
c010137f:	89 e5                	mov    %esp,%ebp
c0101381:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101384:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101388:	74 0d                	je     c0101397 <serial_putc+0x19>
        serial_putc_sub(c);
c010138a:	8b 45 08             	mov    0x8(%ebp),%eax
c010138d:	89 04 24             	mov    %eax,(%esp)
c0101390:	e8 8d ff ff ff       	call   c0101322 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101395:	eb 24                	jmp    c01013bb <serial_putc+0x3d>
        serial_putc_sub('\b');
c0101397:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010139e:	e8 7f ff ff ff       	call   c0101322 <serial_putc_sub>
        serial_putc_sub(' ');
c01013a3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013aa:	e8 73 ff ff ff       	call   c0101322 <serial_putc_sub>
        serial_putc_sub('\b');
c01013af:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013b6:	e8 67 ff ff ff       	call   c0101322 <serial_putc_sub>
}
c01013bb:	90                   	nop
c01013bc:	89 ec                	mov    %ebp,%esp
c01013be:	5d                   	pop    %ebp
c01013bf:	c3                   	ret    

c01013c0 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013c0:	55                   	push   %ebp
c01013c1:	89 e5                	mov    %esp,%ebp
c01013c3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013c6:	eb 33                	jmp    c01013fb <cons_intr+0x3b>
        if (c != 0) {
c01013c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013cc:	74 2d                	je     c01013fb <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013ce:	a1 64 e6 11 c0       	mov    0xc011e664,%eax
c01013d3:	8d 50 01             	lea    0x1(%eax),%edx
c01013d6:	89 15 64 e6 11 c0    	mov    %edx,0xc011e664
c01013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013df:	88 90 60 e4 11 c0    	mov    %dl,-0x3fee1ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013e5:	a1 64 e6 11 c0       	mov    0xc011e664,%eax
c01013ea:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013ef:	75 0a                	jne    c01013fb <cons_intr+0x3b>
                cons.wpos = 0;
c01013f1:	c7 05 64 e6 11 c0 00 	movl   $0x0,0xc011e664
c01013f8:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01013fe:	ff d0                	call   *%eax
c0101400:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101403:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101407:	75 bf                	jne    c01013c8 <cons_intr+0x8>
            }
        }
    }
}
c0101409:	90                   	nop
c010140a:	90                   	nop
c010140b:	89 ec                	mov    %ebp,%esp
c010140d:	5d                   	pop    %ebp
c010140e:	c3                   	ret    

c010140f <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010140f:	55                   	push   %ebp
c0101410:	89 e5                	mov    %esp,%ebp
c0101412:	83 ec 10             	sub    $0x10,%esp
c0101415:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010141b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010141f:	89 c2                	mov    %eax,%edx
c0101421:	ec                   	in     (%dx),%al
c0101422:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101425:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101429:	0f b6 c0             	movzbl %al,%eax
c010142c:	83 e0 01             	and    $0x1,%eax
c010142f:	85 c0                	test   %eax,%eax
c0101431:	75 07                	jne    c010143a <serial_proc_data+0x2b>
        return -1;
c0101433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101438:	eb 2a                	jmp    c0101464 <serial_proc_data+0x55>
c010143a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101440:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101444:	89 c2                	mov    %eax,%edx
c0101446:	ec                   	in     (%dx),%al
c0101447:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010144a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010144e:	0f b6 c0             	movzbl %al,%eax
c0101451:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101454:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101458:	75 07                	jne    c0101461 <serial_proc_data+0x52>
        c = '\b';
c010145a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101461:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101464:	89 ec                	mov    %ebp,%esp
c0101466:	5d                   	pop    %ebp
c0101467:	c3                   	ret    

c0101468 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101468:	55                   	push   %ebp
c0101469:	89 e5                	mov    %esp,%ebp
c010146b:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010146e:	a1 48 e4 11 c0       	mov    0xc011e448,%eax
c0101473:	85 c0                	test   %eax,%eax
c0101475:	74 0c                	je     c0101483 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101477:	c7 04 24 0f 14 10 c0 	movl   $0xc010140f,(%esp)
c010147e:	e8 3d ff ff ff       	call   c01013c0 <cons_intr>
    }
}
c0101483:	90                   	nop
c0101484:	89 ec                	mov    %ebp,%esp
c0101486:	5d                   	pop    %ebp
c0101487:	c3                   	ret    

c0101488 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101488:	55                   	push   %ebp
c0101489:	89 e5                	mov    %esp,%ebp
c010148b:	83 ec 38             	sub    $0x38,%esp
c010148e:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101494:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101497:	89 c2                	mov    %eax,%edx
c0101499:	ec                   	in     (%dx),%al
c010149a:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010149d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014a1:	0f b6 c0             	movzbl %al,%eax
c01014a4:	83 e0 01             	and    $0x1,%eax
c01014a7:	85 c0                	test   %eax,%eax
c01014a9:	75 0a                	jne    c01014b5 <kbd_proc_data+0x2d>
        return -1;
c01014ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014b0:	e9 56 01 00 00       	jmp    c010160b <kbd_proc_data+0x183>
c01014b5:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014be:	89 c2                	mov    %eax,%edx
c01014c0:	ec                   	in     (%dx),%al
c01014c1:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014c4:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014c8:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014cb:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014cf:	75 17                	jne    c01014e8 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014d1:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c01014d6:	83 c8 40             	or     $0x40,%eax
c01014d9:	a3 68 e6 11 c0       	mov    %eax,0xc011e668
        return 0;
c01014de:	b8 00 00 00 00       	mov    $0x0,%eax
c01014e3:	e9 23 01 00 00       	jmp    c010160b <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c01014e8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ec:	84 c0                	test   %al,%al
c01014ee:	79 45                	jns    c0101535 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014f0:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c01014f5:	83 e0 40             	and    $0x40,%eax
c01014f8:	85 c0                	test   %eax,%eax
c01014fa:	75 08                	jne    c0101504 <kbd_proc_data+0x7c>
c01014fc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101500:	24 7f                	and    $0x7f,%al
c0101502:	eb 04                	jmp    c0101508 <kbd_proc_data+0x80>
c0101504:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101508:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010150f:	0f b6 80 40 b0 11 c0 	movzbl -0x3fee4fc0(%eax),%eax
c0101516:	0c 40                	or     $0x40,%al
c0101518:	0f b6 c0             	movzbl %al,%eax
c010151b:	f7 d0                	not    %eax
c010151d:	89 c2                	mov    %eax,%edx
c010151f:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c0101524:	21 d0                	and    %edx,%eax
c0101526:	a3 68 e6 11 c0       	mov    %eax,0xc011e668
        return 0;
c010152b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101530:	e9 d6 00 00 00       	jmp    c010160b <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101535:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c010153a:	83 e0 40             	and    $0x40,%eax
c010153d:	85 c0                	test   %eax,%eax
c010153f:	74 11                	je     c0101552 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101541:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101545:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c010154a:	83 e0 bf             	and    $0xffffffbf,%eax
c010154d:	a3 68 e6 11 c0       	mov    %eax,0xc011e668
    }

    shift |= shiftcode[data];
c0101552:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101556:	0f b6 80 40 b0 11 c0 	movzbl -0x3fee4fc0(%eax),%eax
c010155d:	0f b6 d0             	movzbl %al,%edx
c0101560:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c0101565:	09 d0                	or     %edx,%eax
c0101567:	a3 68 e6 11 c0       	mov    %eax,0xc011e668
    shift ^= togglecode[data];
c010156c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101570:	0f b6 80 40 b1 11 c0 	movzbl -0x3fee4ec0(%eax),%eax
c0101577:	0f b6 d0             	movzbl %al,%edx
c010157a:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c010157f:	31 d0                	xor    %edx,%eax
c0101581:	a3 68 e6 11 c0       	mov    %eax,0xc011e668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101586:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c010158b:	83 e0 03             	and    $0x3,%eax
c010158e:	8b 14 85 40 b5 11 c0 	mov    -0x3fee4ac0(,%eax,4),%edx
c0101595:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101599:	01 d0                	add    %edx,%eax
c010159b:	0f b6 00             	movzbl (%eax),%eax
c010159e:	0f b6 c0             	movzbl %al,%eax
c01015a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015a4:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c01015a9:	83 e0 08             	and    $0x8,%eax
c01015ac:	85 c0                	test   %eax,%eax
c01015ae:	74 22                	je     c01015d2 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015b0:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015b4:	7e 0c                	jle    c01015c2 <kbd_proc_data+0x13a>
c01015b6:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015ba:	7f 06                	jg     c01015c2 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015bc:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015c0:	eb 10                	jmp    c01015d2 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015c2:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015c6:	7e 0a                	jle    c01015d2 <kbd_proc_data+0x14a>
c01015c8:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015cc:	7f 04                	jg     c01015d2 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015ce:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015d2:	a1 68 e6 11 c0       	mov    0xc011e668,%eax
c01015d7:	f7 d0                	not    %eax
c01015d9:	83 e0 06             	and    $0x6,%eax
c01015dc:	85 c0                	test   %eax,%eax
c01015de:	75 28                	jne    c0101608 <kbd_proc_data+0x180>
c01015e0:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015e7:	75 1f                	jne    c0101608 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c01015e9:	c7 04 24 4f 73 10 c0 	movl   $0xc010734f,(%esp)
c01015f0:	e8 61 ed ff ff       	call   c0100356 <cprintf>
c01015f5:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015fb:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ff:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101603:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101606:	ee                   	out    %al,(%dx)
}
c0101607:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101608:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010160b:	89 ec                	mov    %ebp,%esp
c010160d:	5d                   	pop    %ebp
c010160e:	c3                   	ret    

c010160f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010160f:	55                   	push   %ebp
c0101610:	89 e5                	mov    %esp,%ebp
c0101612:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101615:	c7 04 24 88 14 10 c0 	movl   $0xc0101488,(%esp)
c010161c:	e8 9f fd ff ff       	call   c01013c0 <cons_intr>
}
c0101621:	90                   	nop
c0101622:	89 ec                	mov    %ebp,%esp
c0101624:	5d                   	pop    %ebp
c0101625:	c3                   	ret    

c0101626 <kbd_init>:

static void
kbd_init(void) {
c0101626:	55                   	push   %ebp
c0101627:	89 e5                	mov    %esp,%ebp
c0101629:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010162c:	e8 de ff ff ff       	call   c010160f <kbd_intr>
    pic_enable(IRQ_KBD);
c0101631:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101638:	e8 51 01 00 00       	call   c010178e <pic_enable>
}
c010163d:	90                   	nop
c010163e:	89 ec                	mov    %ebp,%esp
c0101640:	5d                   	pop    %ebp
c0101641:	c3                   	ret    

c0101642 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101642:	55                   	push   %ebp
c0101643:	89 e5                	mov    %esp,%ebp
c0101645:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101648:	e8 4a f8 ff ff       	call   c0100e97 <cga_init>
    serial_init();
c010164d:	e8 2d f9 ff ff       	call   c0100f7f <serial_init>
    kbd_init();
c0101652:	e8 cf ff ff ff       	call   c0101626 <kbd_init>
    if (!serial_exists) {
c0101657:	a1 48 e4 11 c0       	mov    0xc011e448,%eax
c010165c:	85 c0                	test   %eax,%eax
c010165e:	75 0c                	jne    c010166c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101660:	c7 04 24 5b 73 10 c0 	movl   $0xc010735b,(%esp)
c0101667:	e8 ea ec ff ff       	call   c0100356 <cprintf>
    }
}
c010166c:	90                   	nop
c010166d:	89 ec                	mov    %ebp,%esp
c010166f:	5d                   	pop    %ebp
c0101670:	c3                   	ret    

c0101671 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101671:	55                   	push   %ebp
c0101672:	89 e5                	mov    %esp,%ebp
c0101674:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101677:	e8 8e f7 ff ff       	call   c0100e0a <__intr_save>
c010167c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010167f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101682:	89 04 24             	mov    %eax,(%esp)
c0101685:	e8 60 fa ff ff       	call   c01010ea <lpt_putc>
        cga_putc(c);
c010168a:	8b 45 08             	mov    0x8(%ebp),%eax
c010168d:	89 04 24             	mov    %eax,(%esp)
c0101690:	e8 97 fa ff ff       	call   c010112c <cga_putc>
        serial_putc(c);
c0101695:	8b 45 08             	mov    0x8(%ebp),%eax
c0101698:	89 04 24             	mov    %eax,(%esp)
c010169b:	e8 de fc ff ff       	call   c010137e <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016a3:	89 04 24             	mov    %eax,(%esp)
c01016a6:	e8 8b f7 ff ff       	call   c0100e36 <__intr_restore>
}
c01016ab:	90                   	nop
c01016ac:	89 ec                	mov    %ebp,%esp
c01016ae:	5d                   	pop    %ebp
c01016af:	c3                   	ret    

c01016b0 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016b0:	55                   	push   %ebp
c01016b1:	89 e5                	mov    %esp,%ebp
c01016b3:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016bd:	e8 48 f7 ff ff       	call   c0100e0a <__intr_save>
c01016c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016c5:	e8 9e fd ff ff       	call   c0101468 <serial_intr>
        kbd_intr();
c01016ca:	e8 40 ff ff ff       	call   c010160f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016cf:	8b 15 60 e6 11 c0    	mov    0xc011e660,%edx
c01016d5:	a1 64 e6 11 c0       	mov    0xc011e664,%eax
c01016da:	39 c2                	cmp    %eax,%edx
c01016dc:	74 31                	je     c010170f <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016de:	a1 60 e6 11 c0       	mov    0xc011e660,%eax
c01016e3:	8d 50 01             	lea    0x1(%eax),%edx
c01016e6:	89 15 60 e6 11 c0    	mov    %edx,0xc011e660
c01016ec:	0f b6 80 60 e4 11 c0 	movzbl -0x3fee1ba0(%eax),%eax
c01016f3:	0f b6 c0             	movzbl %al,%eax
c01016f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016f9:	a1 60 e6 11 c0       	mov    0xc011e660,%eax
c01016fe:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101703:	75 0a                	jne    c010170f <cons_getc+0x5f>
                cons.rpos = 0;
c0101705:	c7 05 60 e6 11 c0 00 	movl   $0x0,0xc011e660
c010170c:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010170f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101712:	89 04 24             	mov    %eax,(%esp)
c0101715:	e8 1c f7 ff ff       	call   c0100e36 <__intr_restore>
    return c;
c010171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010171d:	89 ec                	mov    %ebp,%esp
c010171f:	5d                   	pop    %ebp
c0101720:	c3                   	ret    

c0101721 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101721:	55                   	push   %ebp
c0101722:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101724:	fb                   	sti    
}
c0101725:	90                   	nop
    sti();
}
c0101726:	90                   	nop
c0101727:	5d                   	pop    %ebp
c0101728:	c3                   	ret    

c0101729 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101729:	55                   	push   %ebp
c010172a:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010172c:	fa                   	cli    
}
c010172d:	90                   	nop
    cli();
}
c010172e:	90                   	nop
c010172f:	5d                   	pop    %ebp
c0101730:	c3                   	ret    

c0101731 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101731:	55                   	push   %ebp
c0101732:	89 e5                	mov    %esp,%ebp
c0101734:	83 ec 14             	sub    $0x14,%esp
c0101737:	8b 45 08             	mov    0x8(%ebp),%eax
c010173a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010173e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101741:	66 a3 50 b5 11 c0    	mov    %ax,0xc011b550
    if (did_init) {
c0101747:	a1 6c e6 11 c0       	mov    0xc011e66c,%eax
c010174c:	85 c0                	test   %eax,%eax
c010174e:	74 39                	je     c0101789 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101750:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101753:	0f b6 c0             	movzbl %al,%eax
c0101756:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c010175c:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010175f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101763:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101767:	ee                   	out    %al,(%dx)
}
c0101768:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101769:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010176d:	c1 e8 08             	shr    $0x8,%eax
c0101770:	0f b7 c0             	movzwl %ax,%eax
c0101773:	0f b6 c0             	movzbl %al,%eax
c0101776:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010177c:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010177f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101783:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
}
c0101788:	90                   	nop
    }
}
c0101789:	90                   	nop
c010178a:	89 ec                	mov    %ebp,%esp
c010178c:	5d                   	pop    %ebp
c010178d:	c3                   	ret    

c010178e <pic_enable>:

void
pic_enable(unsigned int irq) {
c010178e:	55                   	push   %ebp
c010178f:	89 e5                	mov    %esp,%ebp
c0101791:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101794:	8b 45 08             	mov    0x8(%ebp),%eax
c0101797:	ba 01 00 00 00       	mov    $0x1,%edx
c010179c:	88 c1                	mov    %al,%cl
c010179e:	d3 e2                	shl    %cl,%edx
c01017a0:	89 d0                	mov    %edx,%eax
c01017a2:	98                   	cwtl   
c01017a3:	f7 d0                	not    %eax
c01017a5:	0f bf d0             	movswl %ax,%edx
c01017a8:	0f b7 05 50 b5 11 c0 	movzwl 0xc011b550,%eax
c01017af:	98                   	cwtl   
c01017b0:	21 d0                	and    %edx,%eax
c01017b2:	98                   	cwtl   
c01017b3:	0f b7 c0             	movzwl %ax,%eax
c01017b6:	89 04 24             	mov    %eax,(%esp)
c01017b9:	e8 73 ff ff ff       	call   c0101731 <pic_setmask>
}
c01017be:	90                   	nop
c01017bf:	89 ec                	mov    %ebp,%esp
c01017c1:	5d                   	pop    %ebp
c01017c2:	c3                   	ret    

c01017c3 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01017c3:	55                   	push   %ebp
c01017c4:	89 e5                	mov    %esp,%ebp
c01017c6:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01017c9:	c7 05 6c e6 11 c0 01 	movl   $0x1,0xc011e66c
c01017d0:	00 00 00 
c01017d3:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01017d9:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017dd:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017e1:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017e5:	ee                   	out    %al,(%dx)
}
c01017e6:	90                   	nop
c01017e7:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01017ed:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017f1:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01017f5:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
}
c01017fa:	90                   	nop
c01017fb:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101801:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101805:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101809:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010180d:	ee                   	out    %al,(%dx)
}
c010180e:	90                   	nop
c010180f:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101815:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101819:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010181d:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101821:	ee                   	out    %al,(%dx)
}
c0101822:	90                   	nop
c0101823:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101829:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010182d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101831:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101835:	ee                   	out    %al,(%dx)
}
c0101836:	90                   	nop
c0101837:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010183d:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101841:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101845:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101849:	ee                   	out    %al,(%dx)
}
c010184a:	90                   	nop
c010184b:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0101851:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101855:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101859:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010185d:	ee                   	out    %al,(%dx)
}
c010185e:	90                   	nop
c010185f:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0101865:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101869:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010186d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101871:	ee                   	out    %al,(%dx)
}
c0101872:	90                   	nop
c0101873:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0101879:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010187d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101881:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101885:	ee                   	out    %al,(%dx)
}
c0101886:	90                   	nop
c0101887:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010188d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101891:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101895:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101899:	ee                   	out    %al,(%dx)
}
c010189a:	90                   	nop
c010189b:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018a1:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018ad:	ee                   	out    %al,(%dx)
}
c01018ae:	90                   	nop
c01018af:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01018b5:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01018bd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018c1:	ee                   	out    %al,(%dx)
}
c01018c2:	90                   	nop
c01018c3:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01018c9:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018cd:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018d1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018d5:	ee                   	out    %al,(%dx)
}
c01018d6:	90                   	nop
c01018d7:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01018dd:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e1:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01018e5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01018e9:	ee                   	out    %al,(%dx)
}
c01018ea:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01018eb:	0f b7 05 50 b5 11 c0 	movzwl 0xc011b550,%eax
c01018f2:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01018f7:	74 0f                	je     c0101908 <pic_init+0x145>
        pic_setmask(irq_mask);
c01018f9:	0f b7 05 50 b5 11 c0 	movzwl 0xc011b550,%eax
c0101900:	89 04 24             	mov    %eax,(%esp)
c0101903:	e8 29 fe ff ff       	call   c0101731 <pic_setmask>
    }
}
c0101908:	90                   	nop
c0101909:	89 ec                	mov    %ebp,%esp
c010190b:	5d                   	pop    %ebp
c010190c:	c3                   	ret    

c010190d <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c010190d:	55                   	push   %ebp
c010190e:	89 e5                	mov    %esp,%ebp
c0101910:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101913:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010191a:	00 
c010191b:	c7 04 24 80 73 10 c0 	movl   $0xc0107380,(%esp)
c0101922:	e8 2f ea ff ff       	call   c0100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0101927:	c7 04 24 8a 73 10 c0 	movl   $0xc010738a,(%esp)
c010192e:	e8 23 ea ff ff       	call   c0100356 <cprintf>
    panic("EOT: kernel seems ok.");
c0101933:	c7 44 24 08 98 73 10 	movl   $0xc0107398,0x8(%esp)
c010193a:	c0 
c010193b:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c0101942:	00 
c0101943:	c7 04 24 ae 73 10 c0 	movl   $0xc01073ae,(%esp)
c010194a:	e8 81 f3 ff ff       	call   c0100cd0 <__panic>

c010194f <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010194f:	55                   	push   %ebp
c0101950:	89 e5                	mov    %esp,%ebp
c0101952:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101955:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010195c:	e9 c4 00 00 00       	jmp    c0101a25 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101964:	8b 04 85 e0 b5 11 c0 	mov    -0x3fee4a20(,%eax,4),%eax
c010196b:	0f b7 d0             	movzwl %ax,%edx
c010196e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101971:	66 89 14 c5 e0 e6 11 	mov    %dx,-0x3fee1920(,%eax,8)
c0101978:	c0 
c0101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197c:	66 c7 04 c5 e2 e6 11 	movw   $0x8,-0x3fee191e(,%eax,8)
c0101983:	c0 08 00 
c0101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101989:	0f b6 14 c5 e4 e6 11 	movzbl -0x3fee191c(,%eax,8),%edx
c0101990:	c0 
c0101991:	80 e2 e0             	and    $0xe0,%dl
c0101994:	88 14 c5 e4 e6 11 c0 	mov    %dl,-0x3fee191c(,%eax,8)
c010199b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010199e:	0f b6 14 c5 e4 e6 11 	movzbl -0x3fee191c(,%eax,8),%edx
c01019a5:	c0 
c01019a6:	80 e2 1f             	and    $0x1f,%dl
c01019a9:	88 14 c5 e4 e6 11 c0 	mov    %dl,-0x3fee191c(,%eax,8)
c01019b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b3:	0f b6 14 c5 e5 e6 11 	movzbl -0x3fee191b(,%eax,8),%edx
c01019ba:	c0 
c01019bb:	80 e2 f0             	and    $0xf0,%dl
c01019be:	80 ca 0e             	or     $0xe,%dl
c01019c1:	88 14 c5 e5 e6 11 c0 	mov    %dl,-0x3fee191b(,%eax,8)
c01019c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019cb:	0f b6 14 c5 e5 e6 11 	movzbl -0x3fee191b(,%eax,8),%edx
c01019d2:	c0 
c01019d3:	80 e2 ef             	and    $0xef,%dl
c01019d6:	88 14 c5 e5 e6 11 c0 	mov    %dl,-0x3fee191b(,%eax,8)
c01019dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019e0:	0f b6 14 c5 e5 e6 11 	movzbl -0x3fee191b(,%eax,8),%edx
c01019e7:	c0 
c01019e8:	80 e2 9f             	and    $0x9f,%dl
c01019eb:	88 14 c5 e5 e6 11 c0 	mov    %dl,-0x3fee191b(,%eax,8)
c01019f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019f5:	0f b6 14 c5 e5 e6 11 	movzbl -0x3fee191b(,%eax,8),%edx
c01019fc:	c0 
c01019fd:	80 ca 80             	or     $0x80,%dl
c0101a00:	88 14 c5 e5 e6 11 c0 	mov    %dl,-0x3fee191b(,%eax,8)
c0101a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a0a:	8b 04 85 e0 b5 11 c0 	mov    -0x3fee4a20(,%eax,4),%eax
c0101a11:	c1 e8 10             	shr    $0x10,%eax
c0101a14:	0f b7 d0             	movzwl %ax,%edx
c0101a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a1a:	66 89 14 c5 e6 e6 11 	mov    %dx,-0x3fee191a(,%eax,8)
c0101a21:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101a22:	ff 45 fc             	incl   -0x4(%ebp)
c0101a25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a28:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a2d:	0f 86 2e ff ff ff    	jbe    c0101961 <idt_init+0x12>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101a33:	a1 c4 b7 11 c0       	mov    0xc011b7c4,%eax
c0101a38:	0f b7 c0             	movzwl %ax,%eax
c0101a3b:	66 a3 a8 ea 11 c0    	mov    %ax,0xc011eaa8
c0101a41:	66 c7 05 aa ea 11 c0 	movw   $0x8,0xc011eaaa
c0101a48:	08 00 
c0101a4a:	0f b6 05 ac ea 11 c0 	movzbl 0xc011eaac,%eax
c0101a51:	24 e0                	and    $0xe0,%al
c0101a53:	a2 ac ea 11 c0       	mov    %al,0xc011eaac
c0101a58:	0f b6 05 ac ea 11 c0 	movzbl 0xc011eaac,%eax
c0101a5f:	24 1f                	and    $0x1f,%al
c0101a61:	a2 ac ea 11 c0       	mov    %al,0xc011eaac
c0101a66:	0f b6 05 ad ea 11 c0 	movzbl 0xc011eaad,%eax
c0101a6d:	24 f0                	and    $0xf0,%al
c0101a6f:	0c 0e                	or     $0xe,%al
c0101a71:	a2 ad ea 11 c0       	mov    %al,0xc011eaad
c0101a76:	0f b6 05 ad ea 11 c0 	movzbl 0xc011eaad,%eax
c0101a7d:	24 ef                	and    $0xef,%al
c0101a7f:	a2 ad ea 11 c0       	mov    %al,0xc011eaad
c0101a84:	0f b6 05 ad ea 11 c0 	movzbl 0xc011eaad,%eax
c0101a8b:	0c 60                	or     $0x60,%al
c0101a8d:	a2 ad ea 11 c0       	mov    %al,0xc011eaad
c0101a92:	0f b6 05 ad ea 11 c0 	movzbl 0xc011eaad,%eax
c0101a99:	0c 80                	or     $0x80,%al
c0101a9b:	a2 ad ea 11 c0       	mov    %al,0xc011eaad
c0101aa0:	a1 c4 b7 11 c0       	mov    0xc011b7c4,%eax
c0101aa5:	c1 e8 10             	shr    $0x10,%eax
c0101aa8:	0f b7 c0             	movzwl %ax,%eax
c0101aab:	66 a3 ae ea 11 c0    	mov    %ax,0xc011eaae
c0101ab1:	c7 45 f8 60 b5 11 c0 	movl   $0xc011b560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101ab8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101abb:	0f 01 18             	lidtl  (%eax)
}
c0101abe:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
c0101abf:	90                   	nop
c0101ac0:	89 ec                	mov    %ebp,%esp
c0101ac2:	5d                   	pop    %ebp
c0101ac3:	c3                   	ret    

c0101ac4 <trapname>:

static const char *
trapname(int trapno) {
c0101ac4:	55                   	push   %ebp
c0101ac5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aca:	83 f8 13             	cmp    $0x13,%eax
c0101acd:	77 0c                	ja     c0101adb <trapname+0x17>
        return excnames[trapno];
c0101acf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad2:	8b 04 85 40 77 10 c0 	mov    -0x3fef88c0(,%eax,4),%eax
c0101ad9:	eb 18                	jmp    c0101af3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101adb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101adf:	7e 0d                	jle    c0101aee <trapname+0x2a>
c0101ae1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101ae5:	7f 07                	jg     c0101aee <trapname+0x2a>
        return "Hardware Interrupt";
c0101ae7:	b8 bf 73 10 c0       	mov    $0xc01073bf,%eax
c0101aec:	eb 05                	jmp    c0101af3 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101aee:	b8 d2 73 10 c0       	mov    $0xc01073d2,%eax
}
c0101af3:	5d                   	pop    %ebp
c0101af4:	c3                   	ret    

c0101af5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101af5:	55                   	push   %ebp
c0101af6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101af8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101afb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101aff:	83 f8 08             	cmp    $0x8,%eax
c0101b02:	0f 94 c0             	sete   %al
c0101b05:	0f b6 c0             	movzbl %al,%eax
}
c0101b08:	5d                   	pop    %ebp
c0101b09:	c3                   	ret    

c0101b0a <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b0a:	55                   	push   %ebp
c0101b0b:	89 e5                	mov    %esp,%ebp
c0101b0d:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b10:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b17:	c7 04 24 13 74 10 c0 	movl   $0xc0107413,(%esp)
c0101b1e:	e8 33 e8 ff ff       	call   c0100356 <cprintf>
    print_regs(&tf->tf_regs);
c0101b23:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b26:	89 04 24             	mov    %eax,(%esp)
c0101b29:	e8 8f 01 00 00       	call   c0101cbd <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b31:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101b35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b39:	c7 04 24 24 74 10 c0 	movl   $0xc0107424,(%esp)
c0101b40:	e8 11 e8 ff ff       	call   c0100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101b45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b48:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b50:	c7 04 24 37 74 10 c0 	movl   $0xc0107437,(%esp)
c0101b57:	e8 fa e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b67:	c7 04 24 4a 74 10 c0 	movl   $0xc010744a,(%esp)
c0101b6e:	e8 e3 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b76:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7e:	c7 04 24 5d 74 10 c0 	movl   $0xc010745d,(%esp)
c0101b85:	e8 cc e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8d:	8b 40 30             	mov    0x30(%eax),%eax
c0101b90:	89 04 24             	mov    %eax,(%esp)
c0101b93:	e8 2c ff ff ff       	call   c0101ac4 <trapname>
c0101b98:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b9b:	8b 52 30             	mov    0x30(%edx),%edx
c0101b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101ba6:	c7 04 24 70 74 10 c0 	movl   $0xc0107470,(%esp)
c0101bad:	e8 a4 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb5:	8b 40 34             	mov    0x34(%eax),%eax
c0101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bbc:	c7 04 24 82 74 10 c0 	movl   $0xc0107482,(%esp)
c0101bc3:	e8 8e e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcb:	8b 40 38             	mov    0x38(%eax),%eax
c0101bce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd2:	c7 04 24 91 74 10 c0 	movl   $0xc0107491,(%esp)
c0101bd9:	e8 78 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be9:	c7 04 24 a0 74 10 c0 	movl   $0xc01074a0,(%esp)
c0101bf0:	e8 61 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf8:	8b 40 40             	mov    0x40(%eax),%eax
c0101bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bff:	c7 04 24 b3 74 10 c0 	movl   $0xc01074b3,(%esp)
c0101c06:	e8 4b e7 ff ff       	call   c0100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c12:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c19:	eb 3d                	jmp    c0101c58 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1e:	8b 50 40             	mov    0x40(%eax),%edx
c0101c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c24:	21 d0                	and    %edx,%eax
c0101c26:	85 c0                	test   %eax,%eax
c0101c28:	74 28                	je     c0101c52 <print_trapframe+0x148>
c0101c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c2d:	8b 04 85 80 b5 11 c0 	mov    -0x3fee4a80(,%eax,4),%eax
c0101c34:	85 c0                	test   %eax,%eax
c0101c36:	74 1a                	je     c0101c52 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c3b:	8b 04 85 80 b5 11 c0 	mov    -0x3fee4a80(,%eax,4),%eax
c0101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c46:	c7 04 24 c2 74 10 c0 	movl   $0xc01074c2,(%esp)
c0101c4d:	e8 04 e7 ff ff       	call   c0100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c52:	ff 45 f4             	incl   -0xc(%ebp)
c0101c55:	d1 65 f0             	shll   -0x10(%ebp)
c0101c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c5b:	83 f8 17             	cmp    $0x17,%eax
c0101c5e:	76 bb                	jbe    c0101c1b <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c63:	8b 40 40             	mov    0x40(%eax),%eax
c0101c66:	c1 e8 0c             	shr    $0xc,%eax
c0101c69:	83 e0 03             	and    $0x3,%eax
c0101c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c70:	c7 04 24 c6 74 10 c0 	movl   $0xc01074c6,(%esp)
c0101c77:	e8 da e6 ff ff       	call   c0100356 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7f:	89 04 24             	mov    %eax,(%esp)
c0101c82:	e8 6e fe ff ff       	call   c0101af5 <trap_in_kernel>
c0101c87:	85 c0                	test   %eax,%eax
c0101c89:	75 2d                	jne    c0101cb8 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8e:	8b 40 44             	mov    0x44(%eax),%eax
c0101c91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c95:	c7 04 24 cf 74 10 c0 	movl   $0xc01074cf,(%esp)
c0101c9c:	e8 b5 e6 ff ff       	call   c0100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca4:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cac:	c7 04 24 de 74 10 c0 	movl   $0xc01074de,(%esp)
c0101cb3:	e8 9e e6 ff ff       	call   c0100356 <cprintf>
    }
}
c0101cb8:	90                   	nop
c0101cb9:	89 ec                	mov    %ebp,%esp
c0101cbb:	5d                   	pop    %ebp
c0101cbc:	c3                   	ret    

c0101cbd <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101cbd:	55                   	push   %ebp
c0101cbe:	89 e5                	mov    %esp,%ebp
c0101cc0:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc6:	8b 00                	mov    (%eax),%eax
c0101cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccc:	c7 04 24 f1 74 10 c0 	movl   $0xc01074f1,(%esp)
c0101cd3:	e8 7e e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdb:	8b 40 04             	mov    0x4(%eax),%eax
c0101cde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce2:	c7 04 24 00 75 10 c0 	movl   $0xc0107500,(%esp)
c0101ce9:	e8 68 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf1:	8b 40 08             	mov    0x8(%eax),%eax
c0101cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf8:	c7 04 24 0f 75 10 c0 	movl   $0xc010750f,(%esp)
c0101cff:	e8 52 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d07:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0e:	c7 04 24 1e 75 10 c0 	movl   $0xc010751e,(%esp)
c0101d15:	e8 3c e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1d:	8b 40 10             	mov    0x10(%eax),%eax
c0101d20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d24:	c7 04 24 2d 75 10 c0 	movl   $0xc010752d,(%esp)
c0101d2b:	e8 26 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101d30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d33:	8b 40 14             	mov    0x14(%eax),%eax
c0101d36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d3a:	c7 04 24 3c 75 10 c0 	movl   $0xc010753c,(%esp)
c0101d41:	e8 10 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101d46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d49:	8b 40 18             	mov    0x18(%eax),%eax
c0101d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d50:	c7 04 24 4b 75 10 c0 	movl   $0xc010754b,(%esp)
c0101d57:	e8 fa e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d5f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d66:	c7 04 24 5a 75 10 c0 	movl   $0xc010755a,(%esp)
c0101d6d:	e8 e4 e5 ff ff       	call   c0100356 <cprintf>
}
c0101d72:	90                   	nop
c0101d73:	89 ec                	mov    %ebp,%esp
c0101d75:	5d                   	pop    %ebp
c0101d76:	c3                   	ret    

c0101d77 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d77:	55                   	push   %ebp
c0101d78:	89 e5                	mov    %esp,%ebp
c0101d7a:	83 ec 38             	sub    $0x38,%esp
c0101d7d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
c0101d80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d83:	8b 40 30             	mov    0x30(%eax),%eax
c0101d86:	83 f8 79             	cmp    $0x79,%eax
c0101d89:	0f 84 f8 02 00 00    	je     c0102087 <trap_dispatch+0x310>
c0101d8f:	83 f8 79             	cmp    $0x79,%eax
c0101d92:	0f 87 6c 03 00 00    	ja     c0102104 <trap_dispatch+0x38d>
c0101d98:	83 f8 78             	cmp    $0x78,%eax
c0101d9b:	0f 84 5c 02 00 00    	je     c0101ffd <trap_dispatch+0x286>
c0101da1:	83 f8 78             	cmp    $0x78,%eax
c0101da4:	0f 87 5a 03 00 00    	ja     c0102104 <trap_dispatch+0x38d>
c0101daa:	83 f8 2f             	cmp    $0x2f,%eax
c0101dad:	0f 87 51 03 00 00    	ja     c0102104 <trap_dispatch+0x38d>
c0101db3:	83 f8 2e             	cmp    $0x2e,%eax
c0101db6:	0f 83 7d 03 00 00    	jae    c0102139 <trap_dispatch+0x3c2>
c0101dbc:	83 f8 24             	cmp    $0x24,%eax
c0101dbf:	74 5e                	je     c0101e1f <trap_dispatch+0xa8>
c0101dc1:	83 f8 24             	cmp    $0x24,%eax
c0101dc4:	0f 87 3a 03 00 00    	ja     c0102104 <trap_dispatch+0x38d>
c0101dca:	83 f8 20             	cmp    $0x20,%eax
c0101dcd:	74 0a                	je     c0101dd9 <trap_dispatch+0x62>
c0101dcf:	83 f8 21             	cmp    $0x21,%eax
c0101dd2:	74 74                	je     c0101e48 <trap_dispatch+0xd1>
c0101dd4:	e9 2b 03 00 00       	jmp    c0102104 <trap_dispatch+0x38d>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101dd9:	a1 24 e4 11 c0       	mov    0xc011e424,%eax
c0101dde:	40                   	inc    %eax
c0101ddf:	a3 24 e4 11 c0       	mov    %eax,0xc011e424
        if (ticks % TICK_NUM == 0) {
c0101de4:	8b 0d 24 e4 11 c0    	mov    0xc011e424,%ecx
c0101dea:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101def:	89 c8                	mov    %ecx,%eax
c0101df1:	f7 e2                	mul    %edx
c0101df3:	c1 ea 05             	shr    $0x5,%edx
c0101df6:	89 d0                	mov    %edx,%eax
c0101df8:	c1 e0 02             	shl    $0x2,%eax
c0101dfb:	01 d0                	add    %edx,%eax
c0101dfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e04:	01 d0                	add    %edx,%eax
c0101e06:	c1 e0 02             	shl    $0x2,%eax
c0101e09:	29 c1                	sub    %eax,%ecx
c0101e0b:	89 ca                	mov    %ecx,%edx
c0101e0d:	85 d2                	test   %edx,%edx
c0101e0f:	0f 85 27 03 00 00    	jne    c010213c <trap_dispatch+0x3c5>
            print_ticks();
c0101e15:	e8 f3 fa ff ff       	call   c010190d <print_ticks>
        }
        break;
c0101e1a:	e9 1d 03 00 00       	jmp    c010213c <trap_dispatch+0x3c5>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e1f:	e8 8c f8 ff ff       	call   c01016b0 <cons_getc>
c0101e24:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101e27:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e2b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e2f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e37:	c7 04 24 69 75 10 c0 	movl   $0xc0107569,(%esp)
c0101e3e:	e8 13 e5 ff ff       	call   c0100356 <cprintf>
        break;
c0101e43:	e9 fe 02 00 00       	jmp    c0102146 <trap_dispatch+0x3cf>
    case IRQ_OFFSET + IRQ_KBD:
        static int round = 0;
        c = cons_getc();
c0101e48:	e8 63 f8 ff ff       	call   c01016b0 <cons_getc>
c0101e4d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101e50:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e54:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e58:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e60:	c7 04 24 7b 75 10 c0 	movl   $0xc010757b,(%esp)
c0101e67:	e8 ea e4 ff ff       	call   c0100356 <cprintf>
        if (c == '0') {
c0101e6c:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c0101e70:	0f 85 be 00 00 00    	jne    c0101f34 <trap_dispatch+0x1bd>
            asm volatile (
c0101e76:	cd 79                	int    $0x79
c0101e78:	89 ec                	mov    %ebp,%esp
                "movl %%ebp, %%esp \n"
                : 
                : "i"(T_SWITCH_TOK)
            );
            uint16_t reg1, reg2, reg3, reg4;
            asm volatile (
c0101e7a:	8c 4d f4             	mov    %cs,-0xc(%ebp)
c0101e7d:	8c 5d f2             	mov    %ds,-0xe(%ebp)
c0101e80:	8c 45 f0             	mov    %es,-0x10(%ebp)
c0101e83:	8c 55 ee             	mov    %ss,-0x12(%ebp)
                    "mov %%cs, %0;"
                    "mov %%ds, %1;"
                    "mov %%es, %2;"
                    "mov %%ss, %3;"
                    : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
            cprintf("%d: @ring %d\n", round, reg1 & 3);
c0101e86:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0101e8a:	83 e0 03             	and    $0x3,%eax
c0101e8d:	89 c2                	mov    %eax,%edx
c0101e8f:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101e94:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e9c:	c7 04 24 8a 75 10 c0 	movl   $0xc010758a,(%esp)
c0101ea3:	e8 ae e4 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  cs = %x\n", round, reg1);
c0101ea8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0101eac:	89 c2                	mov    %eax,%edx
c0101eae:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101eb3:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ebb:	c7 04 24 98 75 10 c0 	movl   $0xc0107598,(%esp)
c0101ec2:	e8 8f e4 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  ds = %x\n", round, reg2);
c0101ec7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ecb:	89 c2                	mov    %eax,%edx
c0101ecd:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101ed2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eda:	c7 04 24 a6 75 10 c0 	movl   $0xc01075a6,(%esp)
c0101ee1:	e8 70 e4 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  es = %x\n", round, reg3);
c0101ee6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101eea:	89 c2                	mov    %eax,%edx
c0101eec:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101ef1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ef9:	c7 04 24 b4 75 10 c0 	movl   $0xc01075b4,(%esp)
c0101f00:	e8 51 e4 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  ss = %x\n", round, reg4);
c0101f05:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101f09:	89 c2                	mov    %eax,%edx
c0101f0b:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101f10:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f18:	c7 04 24 c2 75 10 c0 	movl   $0xc01075c2,(%esp)
c0101f1f:	e8 32 e4 ff ff       	call   c0100356 <cprintf>
            round ++;
c0101f24:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101f29:	40                   	inc    %eax
c0101f2a:	a3 e0 ee 11 c0       	mov    %eax,0xc011eee0
            cprintf("%d:  ds = %x\n", round, reg2);
            cprintf("%d:  es = %x\n", round, reg3);
            cprintf("%d:  ss = %x\n", round, reg4);
            round ++;
        }
        break;
c0101f2f:	e9 0b 02 00 00       	jmp    c010213f <trap_dispatch+0x3c8>
        } else if (c == '3') {
c0101f34:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c0101f38:	0f 85 01 02 00 00    	jne    c010213f <trap_dispatch+0x3c8>
            asm volatile (
c0101f3e:	83 ec 08             	sub    $0x8,%esp
c0101f41:	89 ec                	mov    %ebp,%esp
            asm volatile (
c0101f43:	8c 4d ec             	mov    %cs,-0x14(%ebp)
c0101f46:	8c 5d ea             	mov    %ds,-0x16(%ebp)
c0101f49:	8c 45 e8             	mov    %es,-0x18(%ebp)
c0101f4c:	8c 55 e6             	mov    %ss,-0x1a(%ebp)
            cprintf("%d: @ring %d\n", round, reg1 & 3);
c0101f4f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f53:	83 e0 03             	and    $0x3,%eax
c0101f56:	89 c2                	mov    %eax,%edx
c0101f58:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101f5d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f65:	c7 04 24 8a 75 10 c0 	movl   $0xc010758a,(%esp)
c0101f6c:	e8 e5 e3 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  cs = %x\n", round, reg1);
c0101f71:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f75:	89 c2                	mov    %eax,%edx
c0101f77:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101f7c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f80:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f84:	c7 04 24 98 75 10 c0 	movl   $0xc0107598,(%esp)
c0101f8b:	e8 c6 e3 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  ds = %x\n", round, reg2);
c0101f90:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101f94:	89 c2                	mov    %eax,%edx
c0101f96:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fa3:	c7 04 24 a6 75 10 c0 	movl   $0xc01075a6,(%esp)
c0101faa:	e8 a7 e3 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  es = %x\n", round, reg3);
c0101faf:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0101fb3:	89 c2                	mov    %eax,%edx
c0101fb5:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101fba:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fc2:	c7 04 24 b4 75 10 c0 	movl   $0xc01075b4,(%esp)
c0101fc9:	e8 88 e3 ff ff       	call   c0100356 <cprintf>
            cprintf("%d:  ss = %x\n", round, reg4);
c0101fce:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101fd2:	89 c2                	mov    %eax,%edx
c0101fd4:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101fd9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fe1:	c7 04 24 c2 75 10 c0 	movl   $0xc01075c2,(%esp)
c0101fe8:	e8 69 e3 ff ff       	call   c0100356 <cprintf>
            round ++;
c0101fed:	a1 e0 ee 11 c0       	mov    0xc011eee0,%eax
c0101ff2:	40                   	inc    %eax
c0101ff3:	a3 e0 ee 11 c0       	mov    %eax,0xc011eee0
        break;
c0101ff8:	e9 42 01 00 00       	jmp    c010213f <trap_dispatch+0x3c8>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c0101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102000:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102004:	83 f8 1b             	cmp    $0x1b,%eax
c0102007:	0f 84 35 01 00 00    	je     c0102142 <trap_dispatch+0x3cb>
            switchk2u = *tf;
c010200d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102010:	b8 4c 00 00 00       	mov    $0x4c,%eax
c0102015:	83 e0 fc             	and    $0xfffffffc,%eax
c0102018:	89 c3                	mov    %eax,%ebx
c010201a:	b8 00 00 00 00       	mov    $0x0,%eax
c010201f:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c0102022:	89 90 80 e6 11 c0    	mov    %edx,-0x3fee1980(%eax)
c0102028:	83 c0 04             	add    $0x4,%eax
c010202b:	39 d8                	cmp    %ebx,%eax
c010202d:	72 f0                	jb     c010201f <trap_dispatch+0x2a8>
            switchk2u.tf_cs = USER_CS;
c010202f:	66 c7 05 bc e6 11 c0 	movw   $0x1b,0xc011e6bc
c0102036:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0102038:	66 c7 05 c8 e6 11 c0 	movw   $0x23,0xc011e6c8
c010203f:	23 00 
c0102041:	0f b7 05 c8 e6 11 c0 	movzwl 0xc011e6c8,%eax
c0102048:	66 a3 a8 e6 11 c0    	mov    %ax,0xc011e6a8
c010204e:	0f b7 05 a8 e6 11 c0 	movzwl 0xc011e6a8,%eax
c0102055:	66 a3 ac e6 11 c0    	mov    %ax,0xc011e6ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c010205b:	8b 45 08             	mov    0x8(%ebp),%eax
c010205e:	83 c0 44             	add    $0x44,%eax
c0102061:	a3 c4 e6 11 c0       	mov    %eax,0xc011e6c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0102066:	a1 c0 e6 11 c0       	mov    0xc011e6c0,%eax
c010206b:	0d 00 30 00 00       	or     $0x3000,%eax
c0102070:	a3 c0 e6 11 c0       	mov    %eax,0xc011e6c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0102075:	8b 45 08             	mov    0x8(%ebp),%eax
c0102078:	83 e8 04             	sub    $0x4,%eax
c010207b:	ba 80 e6 11 c0       	mov    $0xc011e680,%edx
c0102080:	89 10                	mov    %edx,(%eax)
        }
        break;
c0102082:	e9 bb 00 00 00       	jmp    c0102142 <trap_dispatch+0x3cb>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
c0102087:	8b 45 08             	mov    0x8(%ebp),%eax
c010208a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010208e:	83 f8 08             	cmp    $0x8,%eax
c0102091:	0f 84 ae 00 00 00    	je     c0102145 <trap_dispatch+0x3ce>
            tf->tf_cs = KERNEL_CS;
c0102097:	8b 45 08             	mov    0x8(%ebp),%eax
c010209a:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c01020a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01020a3:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c01020a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01020ac:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c01020b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b3:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c01020b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01020ba:	8b 40 40             	mov    0x40(%eax),%eax
c01020bd:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c01020c2:	89 c2                	mov    %eax,%edx
c01020c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01020c7:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c01020ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01020cd:	8b 40 44             	mov    0x44(%eax),%eax
c01020d0:	83 e8 44             	sub    $0x44,%eax
c01020d3:	a3 cc e6 11 c0       	mov    %eax,0xc011e6cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c01020d8:	a1 cc e6 11 c0       	mov    0xc011e6cc,%eax
c01020dd:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c01020e4:	00 
c01020e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01020e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01020ec:	89 04 24             	mov    %eax,(%esp)
c01020ef:	e8 d2 4d 00 00       	call   c0106ec6 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c01020f4:	8b 15 cc e6 11 c0    	mov    0xc011e6cc,%edx
c01020fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01020fd:	83 e8 04             	sub    $0x4,%eax
c0102100:	89 10                	mov    %edx,(%eax)
        }
        break;
c0102102:	eb 41                	jmp    c0102145 <trap_dispatch+0x3ce>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102104:	8b 45 08             	mov    0x8(%ebp),%eax
c0102107:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010210b:	83 e0 03             	and    $0x3,%eax
c010210e:	85 c0                	test   %eax,%eax
c0102110:	75 34                	jne    c0102146 <trap_dispatch+0x3cf>
            print_trapframe(tf);
c0102112:	8b 45 08             	mov    0x8(%ebp),%eax
c0102115:	89 04 24             	mov    %eax,(%esp)
c0102118:	e8 ed f9 ff ff       	call   c0101b0a <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010211d:	c7 44 24 08 d0 75 10 	movl   $0xc01075d0,0x8(%esp)
c0102124:	c0 
c0102125:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010212c:	00 
c010212d:	c7 04 24 ae 73 10 c0 	movl   $0xc01073ae,(%esp)
c0102134:	e8 97 eb ff ff       	call   c0100cd0 <__panic>
        break;
c0102139:	90                   	nop
c010213a:	eb 0a                	jmp    c0102146 <trap_dispatch+0x3cf>
        break;
c010213c:	90                   	nop
c010213d:	eb 07                	jmp    c0102146 <trap_dispatch+0x3cf>
        break;
c010213f:	90                   	nop
c0102140:	eb 04                	jmp    c0102146 <trap_dispatch+0x3cf>
        break;
c0102142:	90                   	nop
c0102143:	eb 01                	jmp    c0102146 <trap_dispatch+0x3cf>
        break;
c0102145:	90                   	nop
        }
    }
}
c0102146:	90                   	nop
c0102147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010214a:	89 ec                	mov    %ebp,%esp
c010214c:	5d                   	pop    %ebp
c010214d:	c3                   	ret    

c010214e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c010214e:	55                   	push   %ebp
c010214f:	89 e5                	mov    %esp,%ebp
c0102151:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102154:	8b 45 08             	mov    0x8(%ebp),%eax
c0102157:	89 04 24             	mov    %eax,(%esp)
c010215a:	e8 18 fc ff ff       	call   c0101d77 <trap_dispatch>
}
c010215f:	90                   	nop
c0102160:	89 ec                	mov    %ebp,%esp
c0102162:	5d                   	pop    %ebp
c0102163:	c3                   	ret    

c0102164 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102164:	1e                   	push   %ds
    pushl %es
c0102165:	06                   	push   %es
    pushl %fs
c0102166:	0f a0                	push   %fs
    pushl %gs
c0102168:	0f a8                	push   %gs
    pushal
c010216a:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010216b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102170:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102172:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102174:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102175:	e8 d4 ff ff ff       	call   c010214e <trap>

    # pop the pushed stack pointer
    popl %esp
c010217a:	5c                   	pop    %esp

c010217b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010217b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010217c:	0f a9                	pop    %gs
    popl %fs
c010217e:	0f a1                	pop    %fs
    popl %es
c0102180:	07                   	pop    %es
    popl %ds
c0102181:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102182:	83 c4 08             	add    $0x8,%esp
    iret
c0102185:	cf                   	iret   

c0102186 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102186:	6a 00                	push   $0x0
  pushl $0
c0102188:	6a 00                	push   $0x0
  jmp __alltraps
c010218a:	e9 d5 ff ff ff       	jmp    c0102164 <__alltraps>

c010218f <vector1>:
.globl vector1
vector1:
  pushl $0
c010218f:	6a 00                	push   $0x0
  pushl $1
c0102191:	6a 01                	push   $0x1
  jmp __alltraps
c0102193:	e9 cc ff ff ff       	jmp    c0102164 <__alltraps>

c0102198 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102198:	6a 00                	push   $0x0
  pushl $2
c010219a:	6a 02                	push   $0x2
  jmp __alltraps
c010219c:	e9 c3 ff ff ff       	jmp    c0102164 <__alltraps>

c01021a1 <vector3>:
.globl vector3
vector3:
  pushl $0
c01021a1:	6a 00                	push   $0x0
  pushl $3
c01021a3:	6a 03                	push   $0x3
  jmp __alltraps
c01021a5:	e9 ba ff ff ff       	jmp    c0102164 <__alltraps>

c01021aa <vector4>:
.globl vector4
vector4:
  pushl $0
c01021aa:	6a 00                	push   $0x0
  pushl $4
c01021ac:	6a 04                	push   $0x4
  jmp __alltraps
c01021ae:	e9 b1 ff ff ff       	jmp    c0102164 <__alltraps>

c01021b3 <vector5>:
.globl vector5
vector5:
  pushl $0
c01021b3:	6a 00                	push   $0x0
  pushl $5
c01021b5:	6a 05                	push   $0x5
  jmp __alltraps
c01021b7:	e9 a8 ff ff ff       	jmp    c0102164 <__alltraps>

c01021bc <vector6>:
.globl vector6
vector6:
  pushl $0
c01021bc:	6a 00                	push   $0x0
  pushl $6
c01021be:	6a 06                	push   $0x6
  jmp __alltraps
c01021c0:	e9 9f ff ff ff       	jmp    c0102164 <__alltraps>

c01021c5 <vector7>:
.globl vector7
vector7:
  pushl $0
c01021c5:	6a 00                	push   $0x0
  pushl $7
c01021c7:	6a 07                	push   $0x7
  jmp __alltraps
c01021c9:	e9 96 ff ff ff       	jmp    c0102164 <__alltraps>

c01021ce <vector8>:
.globl vector8
vector8:
  pushl $8
c01021ce:	6a 08                	push   $0x8
  jmp __alltraps
c01021d0:	e9 8f ff ff ff       	jmp    c0102164 <__alltraps>

c01021d5 <vector9>:
.globl vector9
vector9:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $9
c01021d7:	6a 09                	push   $0x9
  jmp __alltraps
c01021d9:	e9 86 ff ff ff       	jmp    c0102164 <__alltraps>

c01021de <vector10>:
.globl vector10
vector10:
  pushl $10
c01021de:	6a 0a                	push   $0xa
  jmp __alltraps
c01021e0:	e9 7f ff ff ff       	jmp    c0102164 <__alltraps>

c01021e5 <vector11>:
.globl vector11
vector11:
  pushl $11
c01021e5:	6a 0b                	push   $0xb
  jmp __alltraps
c01021e7:	e9 78 ff ff ff       	jmp    c0102164 <__alltraps>

c01021ec <vector12>:
.globl vector12
vector12:
  pushl $12
c01021ec:	6a 0c                	push   $0xc
  jmp __alltraps
c01021ee:	e9 71 ff ff ff       	jmp    c0102164 <__alltraps>

c01021f3 <vector13>:
.globl vector13
vector13:
  pushl $13
c01021f3:	6a 0d                	push   $0xd
  jmp __alltraps
c01021f5:	e9 6a ff ff ff       	jmp    c0102164 <__alltraps>

c01021fa <vector14>:
.globl vector14
vector14:
  pushl $14
c01021fa:	6a 0e                	push   $0xe
  jmp __alltraps
c01021fc:	e9 63 ff ff ff       	jmp    c0102164 <__alltraps>

c0102201 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102201:	6a 00                	push   $0x0
  pushl $15
c0102203:	6a 0f                	push   $0xf
  jmp __alltraps
c0102205:	e9 5a ff ff ff       	jmp    c0102164 <__alltraps>

c010220a <vector16>:
.globl vector16
vector16:
  pushl $0
c010220a:	6a 00                	push   $0x0
  pushl $16
c010220c:	6a 10                	push   $0x10
  jmp __alltraps
c010220e:	e9 51 ff ff ff       	jmp    c0102164 <__alltraps>

c0102213 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102213:	6a 11                	push   $0x11
  jmp __alltraps
c0102215:	e9 4a ff ff ff       	jmp    c0102164 <__alltraps>

c010221a <vector18>:
.globl vector18
vector18:
  pushl $0
c010221a:	6a 00                	push   $0x0
  pushl $18
c010221c:	6a 12                	push   $0x12
  jmp __alltraps
c010221e:	e9 41 ff ff ff       	jmp    c0102164 <__alltraps>

c0102223 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102223:	6a 00                	push   $0x0
  pushl $19
c0102225:	6a 13                	push   $0x13
  jmp __alltraps
c0102227:	e9 38 ff ff ff       	jmp    c0102164 <__alltraps>

c010222c <vector20>:
.globl vector20
vector20:
  pushl $0
c010222c:	6a 00                	push   $0x0
  pushl $20
c010222e:	6a 14                	push   $0x14
  jmp __alltraps
c0102230:	e9 2f ff ff ff       	jmp    c0102164 <__alltraps>

c0102235 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $21
c0102237:	6a 15                	push   $0x15
  jmp __alltraps
c0102239:	e9 26 ff ff ff       	jmp    c0102164 <__alltraps>

c010223e <vector22>:
.globl vector22
vector22:
  pushl $0
c010223e:	6a 00                	push   $0x0
  pushl $22
c0102240:	6a 16                	push   $0x16
  jmp __alltraps
c0102242:	e9 1d ff ff ff       	jmp    c0102164 <__alltraps>

c0102247 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102247:	6a 00                	push   $0x0
  pushl $23
c0102249:	6a 17                	push   $0x17
  jmp __alltraps
c010224b:	e9 14 ff ff ff       	jmp    c0102164 <__alltraps>

c0102250 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102250:	6a 00                	push   $0x0
  pushl $24
c0102252:	6a 18                	push   $0x18
  jmp __alltraps
c0102254:	e9 0b ff ff ff       	jmp    c0102164 <__alltraps>

c0102259 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $25
c010225b:	6a 19                	push   $0x19
  jmp __alltraps
c010225d:	e9 02 ff ff ff       	jmp    c0102164 <__alltraps>

c0102262 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102262:	6a 00                	push   $0x0
  pushl $26
c0102264:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102266:	e9 f9 fe ff ff       	jmp    c0102164 <__alltraps>

c010226b <vector27>:
.globl vector27
vector27:
  pushl $0
c010226b:	6a 00                	push   $0x0
  pushl $27
c010226d:	6a 1b                	push   $0x1b
  jmp __alltraps
c010226f:	e9 f0 fe ff ff       	jmp    c0102164 <__alltraps>

c0102274 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102274:	6a 00                	push   $0x0
  pushl $28
c0102276:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102278:	e9 e7 fe ff ff       	jmp    c0102164 <__alltraps>

c010227d <vector29>:
.globl vector29
vector29:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $29
c010227f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102281:	e9 de fe ff ff       	jmp    c0102164 <__alltraps>

c0102286 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102286:	6a 00                	push   $0x0
  pushl $30
c0102288:	6a 1e                	push   $0x1e
  jmp __alltraps
c010228a:	e9 d5 fe ff ff       	jmp    c0102164 <__alltraps>

c010228f <vector31>:
.globl vector31
vector31:
  pushl $0
c010228f:	6a 00                	push   $0x0
  pushl $31
c0102291:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102293:	e9 cc fe ff ff       	jmp    c0102164 <__alltraps>

c0102298 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102298:	6a 00                	push   $0x0
  pushl $32
c010229a:	6a 20                	push   $0x20
  jmp __alltraps
c010229c:	e9 c3 fe ff ff       	jmp    c0102164 <__alltraps>

c01022a1 <vector33>:
.globl vector33
vector33:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $33
c01022a3:	6a 21                	push   $0x21
  jmp __alltraps
c01022a5:	e9 ba fe ff ff       	jmp    c0102164 <__alltraps>

c01022aa <vector34>:
.globl vector34
vector34:
  pushl $0
c01022aa:	6a 00                	push   $0x0
  pushl $34
c01022ac:	6a 22                	push   $0x22
  jmp __alltraps
c01022ae:	e9 b1 fe ff ff       	jmp    c0102164 <__alltraps>

c01022b3 <vector35>:
.globl vector35
vector35:
  pushl $0
c01022b3:	6a 00                	push   $0x0
  pushl $35
c01022b5:	6a 23                	push   $0x23
  jmp __alltraps
c01022b7:	e9 a8 fe ff ff       	jmp    c0102164 <__alltraps>

c01022bc <vector36>:
.globl vector36
vector36:
  pushl $0
c01022bc:	6a 00                	push   $0x0
  pushl $36
c01022be:	6a 24                	push   $0x24
  jmp __alltraps
c01022c0:	e9 9f fe ff ff       	jmp    c0102164 <__alltraps>

c01022c5 <vector37>:
.globl vector37
vector37:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $37
c01022c7:	6a 25                	push   $0x25
  jmp __alltraps
c01022c9:	e9 96 fe ff ff       	jmp    c0102164 <__alltraps>

c01022ce <vector38>:
.globl vector38
vector38:
  pushl $0
c01022ce:	6a 00                	push   $0x0
  pushl $38
c01022d0:	6a 26                	push   $0x26
  jmp __alltraps
c01022d2:	e9 8d fe ff ff       	jmp    c0102164 <__alltraps>

c01022d7 <vector39>:
.globl vector39
vector39:
  pushl $0
c01022d7:	6a 00                	push   $0x0
  pushl $39
c01022d9:	6a 27                	push   $0x27
  jmp __alltraps
c01022db:	e9 84 fe ff ff       	jmp    c0102164 <__alltraps>

c01022e0 <vector40>:
.globl vector40
vector40:
  pushl $0
c01022e0:	6a 00                	push   $0x0
  pushl $40
c01022e2:	6a 28                	push   $0x28
  jmp __alltraps
c01022e4:	e9 7b fe ff ff       	jmp    c0102164 <__alltraps>

c01022e9 <vector41>:
.globl vector41
vector41:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $41
c01022eb:	6a 29                	push   $0x29
  jmp __alltraps
c01022ed:	e9 72 fe ff ff       	jmp    c0102164 <__alltraps>

c01022f2 <vector42>:
.globl vector42
vector42:
  pushl $0
c01022f2:	6a 00                	push   $0x0
  pushl $42
c01022f4:	6a 2a                	push   $0x2a
  jmp __alltraps
c01022f6:	e9 69 fe ff ff       	jmp    c0102164 <__alltraps>

c01022fb <vector43>:
.globl vector43
vector43:
  pushl $0
c01022fb:	6a 00                	push   $0x0
  pushl $43
c01022fd:	6a 2b                	push   $0x2b
  jmp __alltraps
c01022ff:	e9 60 fe ff ff       	jmp    c0102164 <__alltraps>

c0102304 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102304:	6a 00                	push   $0x0
  pushl $44
c0102306:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102308:	e9 57 fe ff ff       	jmp    c0102164 <__alltraps>

c010230d <vector45>:
.globl vector45
vector45:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $45
c010230f:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102311:	e9 4e fe ff ff       	jmp    c0102164 <__alltraps>

c0102316 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102316:	6a 00                	push   $0x0
  pushl $46
c0102318:	6a 2e                	push   $0x2e
  jmp __alltraps
c010231a:	e9 45 fe ff ff       	jmp    c0102164 <__alltraps>

c010231f <vector47>:
.globl vector47
vector47:
  pushl $0
c010231f:	6a 00                	push   $0x0
  pushl $47
c0102321:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102323:	e9 3c fe ff ff       	jmp    c0102164 <__alltraps>

c0102328 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102328:	6a 00                	push   $0x0
  pushl $48
c010232a:	6a 30                	push   $0x30
  jmp __alltraps
c010232c:	e9 33 fe ff ff       	jmp    c0102164 <__alltraps>

c0102331 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $49
c0102333:	6a 31                	push   $0x31
  jmp __alltraps
c0102335:	e9 2a fe ff ff       	jmp    c0102164 <__alltraps>

c010233a <vector50>:
.globl vector50
vector50:
  pushl $0
c010233a:	6a 00                	push   $0x0
  pushl $50
c010233c:	6a 32                	push   $0x32
  jmp __alltraps
c010233e:	e9 21 fe ff ff       	jmp    c0102164 <__alltraps>

c0102343 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102343:	6a 00                	push   $0x0
  pushl $51
c0102345:	6a 33                	push   $0x33
  jmp __alltraps
c0102347:	e9 18 fe ff ff       	jmp    c0102164 <__alltraps>

c010234c <vector52>:
.globl vector52
vector52:
  pushl $0
c010234c:	6a 00                	push   $0x0
  pushl $52
c010234e:	6a 34                	push   $0x34
  jmp __alltraps
c0102350:	e9 0f fe ff ff       	jmp    c0102164 <__alltraps>

c0102355 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $53
c0102357:	6a 35                	push   $0x35
  jmp __alltraps
c0102359:	e9 06 fe ff ff       	jmp    c0102164 <__alltraps>

c010235e <vector54>:
.globl vector54
vector54:
  pushl $0
c010235e:	6a 00                	push   $0x0
  pushl $54
c0102360:	6a 36                	push   $0x36
  jmp __alltraps
c0102362:	e9 fd fd ff ff       	jmp    c0102164 <__alltraps>

c0102367 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102367:	6a 00                	push   $0x0
  pushl $55
c0102369:	6a 37                	push   $0x37
  jmp __alltraps
c010236b:	e9 f4 fd ff ff       	jmp    c0102164 <__alltraps>

c0102370 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102370:	6a 00                	push   $0x0
  pushl $56
c0102372:	6a 38                	push   $0x38
  jmp __alltraps
c0102374:	e9 eb fd ff ff       	jmp    c0102164 <__alltraps>

c0102379 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $57
c010237b:	6a 39                	push   $0x39
  jmp __alltraps
c010237d:	e9 e2 fd ff ff       	jmp    c0102164 <__alltraps>

c0102382 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102382:	6a 00                	push   $0x0
  pushl $58
c0102384:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102386:	e9 d9 fd ff ff       	jmp    c0102164 <__alltraps>

c010238b <vector59>:
.globl vector59
vector59:
  pushl $0
c010238b:	6a 00                	push   $0x0
  pushl $59
c010238d:	6a 3b                	push   $0x3b
  jmp __alltraps
c010238f:	e9 d0 fd ff ff       	jmp    c0102164 <__alltraps>

c0102394 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102394:	6a 00                	push   $0x0
  pushl $60
c0102396:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102398:	e9 c7 fd ff ff       	jmp    c0102164 <__alltraps>

c010239d <vector61>:
.globl vector61
vector61:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $61
c010239f:	6a 3d                	push   $0x3d
  jmp __alltraps
c01023a1:	e9 be fd ff ff       	jmp    c0102164 <__alltraps>

c01023a6 <vector62>:
.globl vector62
vector62:
  pushl $0
c01023a6:	6a 00                	push   $0x0
  pushl $62
c01023a8:	6a 3e                	push   $0x3e
  jmp __alltraps
c01023aa:	e9 b5 fd ff ff       	jmp    c0102164 <__alltraps>

c01023af <vector63>:
.globl vector63
vector63:
  pushl $0
c01023af:	6a 00                	push   $0x0
  pushl $63
c01023b1:	6a 3f                	push   $0x3f
  jmp __alltraps
c01023b3:	e9 ac fd ff ff       	jmp    c0102164 <__alltraps>

c01023b8 <vector64>:
.globl vector64
vector64:
  pushl $0
c01023b8:	6a 00                	push   $0x0
  pushl $64
c01023ba:	6a 40                	push   $0x40
  jmp __alltraps
c01023bc:	e9 a3 fd ff ff       	jmp    c0102164 <__alltraps>

c01023c1 <vector65>:
.globl vector65
vector65:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $65
c01023c3:	6a 41                	push   $0x41
  jmp __alltraps
c01023c5:	e9 9a fd ff ff       	jmp    c0102164 <__alltraps>

c01023ca <vector66>:
.globl vector66
vector66:
  pushl $0
c01023ca:	6a 00                	push   $0x0
  pushl $66
c01023cc:	6a 42                	push   $0x42
  jmp __alltraps
c01023ce:	e9 91 fd ff ff       	jmp    c0102164 <__alltraps>

c01023d3 <vector67>:
.globl vector67
vector67:
  pushl $0
c01023d3:	6a 00                	push   $0x0
  pushl $67
c01023d5:	6a 43                	push   $0x43
  jmp __alltraps
c01023d7:	e9 88 fd ff ff       	jmp    c0102164 <__alltraps>

c01023dc <vector68>:
.globl vector68
vector68:
  pushl $0
c01023dc:	6a 00                	push   $0x0
  pushl $68
c01023de:	6a 44                	push   $0x44
  jmp __alltraps
c01023e0:	e9 7f fd ff ff       	jmp    c0102164 <__alltraps>

c01023e5 <vector69>:
.globl vector69
vector69:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $69
c01023e7:	6a 45                	push   $0x45
  jmp __alltraps
c01023e9:	e9 76 fd ff ff       	jmp    c0102164 <__alltraps>

c01023ee <vector70>:
.globl vector70
vector70:
  pushl $0
c01023ee:	6a 00                	push   $0x0
  pushl $70
c01023f0:	6a 46                	push   $0x46
  jmp __alltraps
c01023f2:	e9 6d fd ff ff       	jmp    c0102164 <__alltraps>

c01023f7 <vector71>:
.globl vector71
vector71:
  pushl $0
c01023f7:	6a 00                	push   $0x0
  pushl $71
c01023f9:	6a 47                	push   $0x47
  jmp __alltraps
c01023fb:	e9 64 fd ff ff       	jmp    c0102164 <__alltraps>

c0102400 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102400:	6a 00                	push   $0x0
  pushl $72
c0102402:	6a 48                	push   $0x48
  jmp __alltraps
c0102404:	e9 5b fd ff ff       	jmp    c0102164 <__alltraps>

c0102409 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $73
c010240b:	6a 49                	push   $0x49
  jmp __alltraps
c010240d:	e9 52 fd ff ff       	jmp    c0102164 <__alltraps>

c0102412 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102412:	6a 00                	push   $0x0
  pushl $74
c0102414:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102416:	e9 49 fd ff ff       	jmp    c0102164 <__alltraps>

c010241b <vector75>:
.globl vector75
vector75:
  pushl $0
c010241b:	6a 00                	push   $0x0
  pushl $75
c010241d:	6a 4b                	push   $0x4b
  jmp __alltraps
c010241f:	e9 40 fd ff ff       	jmp    c0102164 <__alltraps>

c0102424 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102424:	6a 00                	push   $0x0
  pushl $76
c0102426:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102428:	e9 37 fd ff ff       	jmp    c0102164 <__alltraps>

c010242d <vector77>:
.globl vector77
vector77:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $77
c010242f:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102431:	e9 2e fd ff ff       	jmp    c0102164 <__alltraps>

c0102436 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102436:	6a 00                	push   $0x0
  pushl $78
c0102438:	6a 4e                	push   $0x4e
  jmp __alltraps
c010243a:	e9 25 fd ff ff       	jmp    c0102164 <__alltraps>

c010243f <vector79>:
.globl vector79
vector79:
  pushl $0
c010243f:	6a 00                	push   $0x0
  pushl $79
c0102441:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102443:	e9 1c fd ff ff       	jmp    c0102164 <__alltraps>

c0102448 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102448:	6a 00                	push   $0x0
  pushl $80
c010244a:	6a 50                	push   $0x50
  jmp __alltraps
c010244c:	e9 13 fd ff ff       	jmp    c0102164 <__alltraps>

c0102451 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $81
c0102453:	6a 51                	push   $0x51
  jmp __alltraps
c0102455:	e9 0a fd ff ff       	jmp    c0102164 <__alltraps>

c010245a <vector82>:
.globl vector82
vector82:
  pushl $0
c010245a:	6a 00                	push   $0x0
  pushl $82
c010245c:	6a 52                	push   $0x52
  jmp __alltraps
c010245e:	e9 01 fd ff ff       	jmp    c0102164 <__alltraps>

c0102463 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102463:	6a 00                	push   $0x0
  pushl $83
c0102465:	6a 53                	push   $0x53
  jmp __alltraps
c0102467:	e9 f8 fc ff ff       	jmp    c0102164 <__alltraps>

c010246c <vector84>:
.globl vector84
vector84:
  pushl $0
c010246c:	6a 00                	push   $0x0
  pushl $84
c010246e:	6a 54                	push   $0x54
  jmp __alltraps
c0102470:	e9 ef fc ff ff       	jmp    c0102164 <__alltraps>

c0102475 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $85
c0102477:	6a 55                	push   $0x55
  jmp __alltraps
c0102479:	e9 e6 fc ff ff       	jmp    c0102164 <__alltraps>

c010247e <vector86>:
.globl vector86
vector86:
  pushl $0
c010247e:	6a 00                	push   $0x0
  pushl $86
c0102480:	6a 56                	push   $0x56
  jmp __alltraps
c0102482:	e9 dd fc ff ff       	jmp    c0102164 <__alltraps>

c0102487 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102487:	6a 00                	push   $0x0
  pushl $87
c0102489:	6a 57                	push   $0x57
  jmp __alltraps
c010248b:	e9 d4 fc ff ff       	jmp    c0102164 <__alltraps>

c0102490 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102490:	6a 00                	push   $0x0
  pushl $88
c0102492:	6a 58                	push   $0x58
  jmp __alltraps
c0102494:	e9 cb fc ff ff       	jmp    c0102164 <__alltraps>

c0102499 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $89
c010249b:	6a 59                	push   $0x59
  jmp __alltraps
c010249d:	e9 c2 fc ff ff       	jmp    c0102164 <__alltraps>

c01024a2 <vector90>:
.globl vector90
vector90:
  pushl $0
c01024a2:	6a 00                	push   $0x0
  pushl $90
c01024a4:	6a 5a                	push   $0x5a
  jmp __alltraps
c01024a6:	e9 b9 fc ff ff       	jmp    c0102164 <__alltraps>

c01024ab <vector91>:
.globl vector91
vector91:
  pushl $0
c01024ab:	6a 00                	push   $0x0
  pushl $91
c01024ad:	6a 5b                	push   $0x5b
  jmp __alltraps
c01024af:	e9 b0 fc ff ff       	jmp    c0102164 <__alltraps>

c01024b4 <vector92>:
.globl vector92
vector92:
  pushl $0
c01024b4:	6a 00                	push   $0x0
  pushl $92
c01024b6:	6a 5c                	push   $0x5c
  jmp __alltraps
c01024b8:	e9 a7 fc ff ff       	jmp    c0102164 <__alltraps>

c01024bd <vector93>:
.globl vector93
vector93:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $93
c01024bf:	6a 5d                	push   $0x5d
  jmp __alltraps
c01024c1:	e9 9e fc ff ff       	jmp    c0102164 <__alltraps>

c01024c6 <vector94>:
.globl vector94
vector94:
  pushl $0
c01024c6:	6a 00                	push   $0x0
  pushl $94
c01024c8:	6a 5e                	push   $0x5e
  jmp __alltraps
c01024ca:	e9 95 fc ff ff       	jmp    c0102164 <__alltraps>

c01024cf <vector95>:
.globl vector95
vector95:
  pushl $0
c01024cf:	6a 00                	push   $0x0
  pushl $95
c01024d1:	6a 5f                	push   $0x5f
  jmp __alltraps
c01024d3:	e9 8c fc ff ff       	jmp    c0102164 <__alltraps>

c01024d8 <vector96>:
.globl vector96
vector96:
  pushl $0
c01024d8:	6a 00                	push   $0x0
  pushl $96
c01024da:	6a 60                	push   $0x60
  jmp __alltraps
c01024dc:	e9 83 fc ff ff       	jmp    c0102164 <__alltraps>

c01024e1 <vector97>:
.globl vector97
vector97:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $97
c01024e3:	6a 61                	push   $0x61
  jmp __alltraps
c01024e5:	e9 7a fc ff ff       	jmp    c0102164 <__alltraps>

c01024ea <vector98>:
.globl vector98
vector98:
  pushl $0
c01024ea:	6a 00                	push   $0x0
  pushl $98
c01024ec:	6a 62                	push   $0x62
  jmp __alltraps
c01024ee:	e9 71 fc ff ff       	jmp    c0102164 <__alltraps>

c01024f3 <vector99>:
.globl vector99
vector99:
  pushl $0
c01024f3:	6a 00                	push   $0x0
  pushl $99
c01024f5:	6a 63                	push   $0x63
  jmp __alltraps
c01024f7:	e9 68 fc ff ff       	jmp    c0102164 <__alltraps>

c01024fc <vector100>:
.globl vector100
vector100:
  pushl $0
c01024fc:	6a 00                	push   $0x0
  pushl $100
c01024fe:	6a 64                	push   $0x64
  jmp __alltraps
c0102500:	e9 5f fc ff ff       	jmp    c0102164 <__alltraps>

c0102505 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $101
c0102507:	6a 65                	push   $0x65
  jmp __alltraps
c0102509:	e9 56 fc ff ff       	jmp    c0102164 <__alltraps>

c010250e <vector102>:
.globl vector102
vector102:
  pushl $0
c010250e:	6a 00                	push   $0x0
  pushl $102
c0102510:	6a 66                	push   $0x66
  jmp __alltraps
c0102512:	e9 4d fc ff ff       	jmp    c0102164 <__alltraps>

c0102517 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102517:	6a 00                	push   $0x0
  pushl $103
c0102519:	6a 67                	push   $0x67
  jmp __alltraps
c010251b:	e9 44 fc ff ff       	jmp    c0102164 <__alltraps>

c0102520 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102520:	6a 00                	push   $0x0
  pushl $104
c0102522:	6a 68                	push   $0x68
  jmp __alltraps
c0102524:	e9 3b fc ff ff       	jmp    c0102164 <__alltraps>

c0102529 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $105
c010252b:	6a 69                	push   $0x69
  jmp __alltraps
c010252d:	e9 32 fc ff ff       	jmp    c0102164 <__alltraps>

c0102532 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102532:	6a 00                	push   $0x0
  pushl $106
c0102534:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102536:	e9 29 fc ff ff       	jmp    c0102164 <__alltraps>

c010253b <vector107>:
.globl vector107
vector107:
  pushl $0
c010253b:	6a 00                	push   $0x0
  pushl $107
c010253d:	6a 6b                	push   $0x6b
  jmp __alltraps
c010253f:	e9 20 fc ff ff       	jmp    c0102164 <__alltraps>

c0102544 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102544:	6a 00                	push   $0x0
  pushl $108
c0102546:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102548:	e9 17 fc ff ff       	jmp    c0102164 <__alltraps>

c010254d <vector109>:
.globl vector109
vector109:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $109
c010254f:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102551:	e9 0e fc ff ff       	jmp    c0102164 <__alltraps>

c0102556 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102556:	6a 00                	push   $0x0
  pushl $110
c0102558:	6a 6e                	push   $0x6e
  jmp __alltraps
c010255a:	e9 05 fc ff ff       	jmp    c0102164 <__alltraps>

c010255f <vector111>:
.globl vector111
vector111:
  pushl $0
c010255f:	6a 00                	push   $0x0
  pushl $111
c0102561:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102563:	e9 fc fb ff ff       	jmp    c0102164 <__alltraps>

c0102568 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102568:	6a 00                	push   $0x0
  pushl $112
c010256a:	6a 70                	push   $0x70
  jmp __alltraps
c010256c:	e9 f3 fb ff ff       	jmp    c0102164 <__alltraps>

c0102571 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $113
c0102573:	6a 71                	push   $0x71
  jmp __alltraps
c0102575:	e9 ea fb ff ff       	jmp    c0102164 <__alltraps>

c010257a <vector114>:
.globl vector114
vector114:
  pushl $0
c010257a:	6a 00                	push   $0x0
  pushl $114
c010257c:	6a 72                	push   $0x72
  jmp __alltraps
c010257e:	e9 e1 fb ff ff       	jmp    c0102164 <__alltraps>

c0102583 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102583:	6a 00                	push   $0x0
  pushl $115
c0102585:	6a 73                	push   $0x73
  jmp __alltraps
c0102587:	e9 d8 fb ff ff       	jmp    c0102164 <__alltraps>

c010258c <vector116>:
.globl vector116
vector116:
  pushl $0
c010258c:	6a 00                	push   $0x0
  pushl $116
c010258e:	6a 74                	push   $0x74
  jmp __alltraps
c0102590:	e9 cf fb ff ff       	jmp    c0102164 <__alltraps>

c0102595 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $117
c0102597:	6a 75                	push   $0x75
  jmp __alltraps
c0102599:	e9 c6 fb ff ff       	jmp    c0102164 <__alltraps>

c010259e <vector118>:
.globl vector118
vector118:
  pushl $0
c010259e:	6a 00                	push   $0x0
  pushl $118
c01025a0:	6a 76                	push   $0x76
  jmp __alltraps
c01025a2:	e9 bd fb ff ff       	jmp    c0102164 <__alltraps>

c01025a7 <vector119>:
.globl vector119
vector119:
  pushl $0
c01025a7:	6a 00                	push   $0x0
  pushl $119
c01025a9:	6a 77                	push   $0x77
  jmp __alltraps
c01025ab:	e9 b4 fb ff ff       	jmp    c0102164 <__alltraps>

c01025b0 <vector120>:
.globl vector120
vector120:
  pushl $0
c01025b0:	6a 00                	push   $0x0
  pushl $120
c01025b2:	6a 78                	push   $0x78
  jmp __alltraps
c01025b4:	e9 ab fb ff ff       	jmp    c0102164 <__alltraps>

c01025b9 <vector121>:
.globl vector121
vector121:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $121
c01025bb:	6a 79                	push   $0x79
  jmp __alltraps
c01025bd:	e9 a2 fb ff ff       	jmp    c0102164 <__alltraps>

c01025c2 <vector122>:
.globl vector122
vector122:
  pushl $0
c01025c2:	6a 00                	push   $0x0
  pushl $122
c01025c4:	6a 7a                	push   $0x7a
  jmp __alltraps
c01025c6:	e9 99 fb ff ff       	jmp    c0102164 <__alltraps>

c01025cb <vector123>:
.globl vector123
vector123:
  pushl $0
c01025cb:	6a 00                	push   $0x0
  pushl $123
c01025cd:	6a 7b                	push   $0x7b
  jmp __alltraps
c01025cf:	e9 90 fb ff ff       	jmp    c0102164 <__alltraps>

c01025d4 <vector124>:
.globl vector124
vector124:
  pushl $0
c01025d4:	6a 00                	push   $0x0
  pushl $124
c01025d6:	6a 7c                	push   $0x7c
  jmp __alltraps
c01025d8:	e9 87 fb ff ff       	jmp    c0102164 <__alltraps>

c01025dd <vector125>:
.globl vector125
vector125:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $125
c01025df:	6a 7d                	push   $0x7d
  jmp __alltraps
c01025e1:	e9 7e fb ff ff       	jmp    c0102164 <__alltraps>

c01025e6 <vector126>:
.globl vector126
vector126:
  pushl $0
c01025e6:	6a 00                	push   $0x0
  pushl $126
c01025e8:	6a 7e                	push   $0x7e
  jmp __alltraps
c01025ea:	e9 75 fb ff ff       	jmp    c0102164 <__alltraps>

c01025ef <vector127>:
.globl vector127
vector127:
  pushl $0
c01025ef:	6a 00                	push   $0x0
  pushl $127
c01025f1:	6a 7f                	push   $0x7f
  jmp __alltraps
c01025f3:	e9 6c fb ff ff       	jmp    c0102164 <__alltraps>

c01025f8 <vector128>:
.globl vector128
vector128:
  pushl $0
c01025f8:	6a 00                	push   $0x0
  pushl $128
c01025fa:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01025ff:	e9 60 fb ff ff       	jmp    c0102164 <__alltraps>

c0102604 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102604:	6a 00                	push   $0x0
  pushl $129
c0102606:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010260b:	e9 54 fb ff ff       	jmp    c0102164 <__alltraps>

c0102610 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102610:	6a 00                	push   $0x0
  pushl $130
c0102612:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102617:	e9 48 fb ff ff       	jmp    c0102164 <__alltraps>

c010261c <vector131>:
.globl vector131
vector131:
  pushl $0
c010261c:	6a 00                	push   $0x0
  pushl $131
c010261e:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102623:	e9 3c fb ff ff       	jmp    c0102164 <__alltraps>

c0102628 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102628:	6a 00                	push   $0x0
  pushl $132
c010262a:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010262f:	e9 30 fb ff ff       	jmp    c0102164 <__alltraps>

c0102634 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102634:	6a 00                	push   $0x0
  pushl $133
c0102636:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010263b:	e9 24 fb ff ff       	jmp    c0102164 <__alltraps>

c0102640 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102640:	6a 00                	push   $0x0
  pushl $134
c0102642:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102647:	e9 18 fb ff ff       	jmp    c0102164 <__alltraps>

c010264c <vector135>:
.globl vector135
vector135:
  pushl $0
c010264c:	6a 00                	push   $0x0
  pushl $135
c010264e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102653:	e9 0c fb ff ff       	jmp    c0102164 <__alltraps>

c0102658 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102658:	6a 00                	push   $0x0
  pushl $136
c010265a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010265f:	e9 00 fb ff ff       	jmp    c0102164 <__alltraps>

c0102664 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102664:	6a 00                	push   $0x0
  pushl $137
c0102666:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010266b:	e9 f4 fa ff ff       	jmp    c0102164 <__alltraps>

c0102670 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102670:	6a 00                	push   $0x0
  pushl $138
c0102672:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102677:	e9 e8 fa ff ff       	jmp    c0102164 <__alltraps>

c010267c <vector139>:
.globl vector139
vector139:
  pushl $0
c010267c:	6a 00                	push   $0x0
  pushl $139
c010267e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102683:	e9 dc fa ff ff       	jmp    c0102164 <__alltraps>

c0102688 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102688:	6a 00                	push   $0x0
  pushl $140
c010268a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010268f:	e9 d0 fa ff ff       	jmp    c0102164 <__alltraps>

c0102694 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102694:	6a 00                	push   $0x0
  pushl $141
c0102696:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010269b:	e9 c4 fa ff ff       	jmp    c0102164 <__alltraps>

c01026a0 <vector142>:
.globl vector142
vector142:
  pushl $0
c01026a0:	6a 00                	push   $0x0
  pushl $142
c01026a2:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01026a7:	e9 b8 fa ff ff       	jmp    c0102164 <__alltraps>

c01026ac <vector143>:
.globl vector143
vector143:
  pushl $0
c01026ac:	6a 00                	push   $0x0
  pushl $143
c01026ae:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01026b3:	e9 ac fa ff ff       	jmp    c0102164 <__alltraps>

c01026b8 <vector144>:
.globl vector144
vector144:
  pushl $0
c01026b8:	6a 00                	push   $0x0
  pushl $144
c01026ba:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01026bf:	e9 a0 fa ff ff       	jmp    c0102164 <__alltraps>

c01026c4 <vector145>:
.globl vector145
vector145:
  pushl $0
c01026c4:	6a 00                	push   $0x0
  pushl $145
c01026c6:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01026cb:	e9 94 fa ff ff       	jmp    c0102164 <__alltraps>

c01026d0 <vector146>:
.globl vector146
vector146:
  pushl $0
c01026d0:	6a 00                	push   $0x0
  pushl $146
c01026d2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01026d7:	e9 88 fa ff ff       	jmp    c0102164 <__alltraps>

c01026dc <vector147>:
.globl vector147
vector147:
  pushl $0
c01026dc:	6a 00                	push   $0x0
  pushl $147
c01026de:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01026e3:	e9 7c fa ff ff       	jmp    c0102164 <__alltraps>

c01026e8 <vector148>:
.globl vector148
vector148:
  pushl $0
c01026e8:	6a 00                	push   $0x0
  pushl $148
c01026ea:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01026ef:	e9 70 fa ff ff       	jmp    c0102164 <__alltraps>

c01026f4 <vector149>:
.globl vector149
vector149:
  pushl $0
c01026f4:	6a 00                	push   $0x0
  pushl $149
c01026f6:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01026fb:	e9 64 fa ff ff       	jmp    c0102164 <__alltraps>

c0102700 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102700:	6a 00                	push   $0x0
  pushl $150
c0102702:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102707:	e9 58 fa ff ff       	jmp    c0102164 <__alltraps>

c010270c <vector151>:
.globl vector151
vector151:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $151
c010270e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102713:	e9 4c fa ff ff       	jmp    c0102164 <__alltraps>

c0102718 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102718:	6a 00                	push   $0x0
  pushl $152
c010271a:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010271f:	e9 40 fa ff ff       	jmp    c0102164 <__alltraps>

c0102724 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102724:	6a 00                	push   $0x0
  pushl $153
c0102726:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010272b:	e9 34 fa ff ff       	jmp    c0102164 <__alltraps>

c0102730 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102730:	6a 00                	push   $0x0
  pushl $154
c0102732:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102737:	e9 28 fa ff ff       	jmp    c0102164 <__alltraps>

c010273c <vector155>:
.globl vector155
vector155:
  pushl $0
c010273c:	6a 00                	push   $0x0
  pushl $155
c010273e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102743:	e9 1c fa ff ff       	jmp    c0102164 <__alltraps>

c0102748 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102748:	6a 00                	push   $0x0
  pushl $156
c010274a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010274f:	e9 10 fa ff ff       	jmp    c0102164 <__alltraps>

c0102754 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102754:	6a 00                	push   $0x0
  pushl $157
c0102756:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010275b:	e9 04 fa ff ff       	jmp    c0102164 <__alltraps>

c0102760 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102760:	6a 00                	push   $0x0
  pushl $158
c0102762:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102767:	e9 f8 f9 ff ff       	jmp    c0102164 <__alltraps>

c010276c <vector159>:
.globl vector159
vector159:
  pushl $0
c010276c:	6a 00                	push   $0x0
  pushl $159
c010276e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102773:	e9 ec f9 ff ff       	jmp    c0102164 <__alltraps>

c0102778 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102778:	6a 00                	push   $0x0
  pushl $160
c010277a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010277f:	e9 e0 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102784 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102784:	6a 00                	push   $0x0
  pushl $161
c0102786:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010278b:	e9 d4 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102790 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102790:	6a 00                	push   $0x0
  pushl $162
c0102792:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102797:	e9 c8 f9 ff ff       	jmp    c0102164 <__alltraps>

c010279c <vector163>:
.globl vector163
vector163:
  pushl $0
c010279c:	6a 00                	push   $0x0
  pushl $163
c010279e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01027a3:	e9 bc f9 ff ff       	jmp    c0102164 <__alltraps>

c01027a8 <vector164>:
.globl vector164
vector164:
  pushl $0
c01027a8:	6a 00                	push   $0x0
  pushl $164
c01027aa:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01027af:	e9 b0 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027b4 <vector165>:
.globl vector165
vector165:
  pushl $0
c01027b4:	6a 00                	push   $0x0
  pushl $165
c01027b6:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01027bb:	e9 a4 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027c0 <vector166>:
.globl vector166
vector166:
  pushl $0
c01027c0:	6a 00                	push   $0x0
  pushl $166
c01027c2:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01027c7:	e9 98 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027cc <vector167>:
.globl vector167
vector167:
  pushl $0
c01027cc:	6a 00                	push   $0x0
  pushl $167
c01027ce:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01027d3:	e9 8c f9 ff ff       	jmp    c0102164 <__alltraps>

c01027d8 <vector168>:
.globl vector168
vector168:
  pushl $0
c01027d8:	6a 00                	push   $0x0
  pushl $168
c01027da:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01027df:	e9 80 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027e4 <vector169>:
.globl vector169
vector169:
  pushl $0
c01027e4:	6a 00                	push   $0x0
  pushl $169
c01027e6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01027eb:	e9 74 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027f0 <vector170>:
.globl vector170
vector170:
  pushl $0
c01027f0:	6a 00                	push   $0x0
  pushl $170
c01027f2:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01027f7:	e9 68 f9 ff ff       	jmp    c0102164 <__alltraps>

c01027fc <vector171>:
.globl vector171
vector171:
  pushl $0
c01027fc:	6a 00                	push   $0x0
  pushl $171
c01027fe:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102803:	e9 5c f9 ff ff       	jmp    c0102164 <__alltraps>

c0102808 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102808:	6a 00                	push   $0x0
  pushl $172
c010280a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010280f:	e9 50 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102814 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102814:	6a 00                	push   $0x0
  pushl $173
c0102816:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010281b:	e9 44 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102820 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102820:	6a 00                	push   $0x0
  pushl $174
c0102822:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102827:	e9 38 f9 ff ff       	jmp    c0102164 <__alltraps>

c010282c <vector175>:
.globl vector175
vector175:
  pushl $0
c010282c:	6a 00                	push   $0x0
  pushl $175
c010282e:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102833:	e9 2c f9 ff ff       	jmp    c0102164 <__alltraps>

c0102838 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102838:	6a 00                	push   $0x0
  pushl $176
c010283a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010283f:	e9 20 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102844 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102844:	6a 00                	push   $0x0
  pushl $177
c0102846:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010284b:	e9 14 f9 ff ff       	jmp    c0102164 <__alltraps>

c0102850 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102850:	6a 00                	push   $0x0
  pushl $178
c0102852:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102857:	e9 08 f9 ff ff       	jmp    c0102164 <__alltraps>

c010285c <vector179>:
.globl vector179
vector179:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $179
c010285e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102863:	e9 fc f8 ff ff       	jmp    c0102164 <__alltraps>

c0102868 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102868:	6a 00                	push   $0x0
  pushl $180
c010286a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010286f:	e9 f0 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102874 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102874:	6a 00                	push   $0x0
  pushl $181
c0102876:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010287b:	e9 e4 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102880 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $182
c0102882:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102887:	e9 d8 f8 ff ff       	jmp    c0102164 <__alltraps>

c010288c <vector183>:
.globl vector183
vector183:
  pushl $0
c010288c:	6a 00                	push   $0x0
  pushl $183
c010288e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102893:	e9 cc f8 ff ff       	jmp    c0102164 <__alltraps>

c0102898 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102898:	6a 00                	push   $0x0
  pushl $184
c010289a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010289f:	e9 c0 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028a4 <vector185>:
.globl vector185
vector185:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $185
c01028a6:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01028ab:	e9 b4 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028b0 <vector186>:
.globl vector186
vector186:
  pushl $0
c01028b0:	6a 00                	push   $0x0
  pushl $186
c01028b2:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01028b7:	e9 a8 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028bc <vector187>:
.globl vector187
vector187:
  pushl $0
c01028bc:	6a 00                	push   $0x0
  pushl $187
c01028be:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01028c3:	e9 9c f8 ff ff       	jmp    c0102164 <__alltraps>

c01028c8 <vector188>:
.globl vector188
vector188:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $188
c01028ca:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01028cf:	e9 90 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028d4 <vector189>:
.globl vector189
vector189:
  pushl $0
c01028d4:	6a 00                	push   $0x0
  pushl $189
c01028d6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01028db:	e9 84 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028e0 <vector190>:
.globl vector190
vector190:
  pushl $0
c01028e0:	6a 00                	push   $0x0
  pushl $190
c01028e2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01028e7:	e9 78 f8 ff ff       	jmp    c0102164 <__alltraps>

c01028ec <vector191>:
.globl vector191
vector191:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $191
c01028ee:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01028f3:	e9 6c f8 ff ff       	jmp    c0102164 <__alltraps>

c01028f8 <vector192>:
.globl vector192
vector192:
  pushl $0
c01028f8:	6a 00                	push   $0x0
  pushl $192
c01028fa:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01028ff:	e9 60 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102904 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102904:	6a 00                	push   $0x0
  pushl $193
c0102906:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010290b:	e9 54 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102910 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $194
c0102912:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102917:	e9 48 f8 ff ff       	jmp    c0102164 <__alltraps>

c010291c <vector195>:
.globl vector195
vector195:
  pushl $0
c010291c:	6a 00                	push   $0x0
  pushl $195
c010291e:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102923:	e9 3c f8 ff ff       	jmp    c0102164 <__alltraps>

c0102928 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102928:	6a 00                	push   $0x0
  pushl $196
c010292a:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010292f:	e9 30 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102934 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $197
c0102936:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010293b:	e9 24 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102940 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102940:	6a 00                	push   $0x0
  pushl $198
c0102942:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102947:	e9 18 f8 ff ff       	jmp    c0102164 <__alltraps>

c010294c <vector199>:
.globl vector199
vector199:
  pushl $0
c010294c:	6a 00                	push   $0x0
  pushl $199
c010294e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102953:	e9 0c f8 ff ff       	jmp    c0102164 <__alltraps>

c0102958 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $200
c010295a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010295f:	e9 00 f8 ff ff       	jmp    c0102164 <__alltraps>

c0102964 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102964:	6a 00                	push   $0x0
  pushl $201
c0102966:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010296b:	e9 f4 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102970 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102970:	6a 00                	push   $0x0
  pushl $202
c0102972:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102977:	e9 e8 f7 ff ff       	jmp    c0102164 <__alltraps>

c010297c <vector203>:
.globl vector203
vector203:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $203
c010297e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102983:	e9 dc f7 ff ff       	jmp    c0102164 <__alltraps>

c0102988 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102988:	6a 00                	push   $0x0
  pushl $204
c010298a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010298f:	e9 d0 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102994 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102994:	6a 00                	push   $0x0
  pushl $205
c0102996:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010299b:	e9 c4 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029a0 <vector206>:
.globl vector206
vector206:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $206
c01029a2:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01029a7:	e9 b8 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029ac <vector207>:
.globl vector207
vector207:
  pushl $0
c01029ac:	6a 00                	push   $0x0
  pushl $207
c01029ae:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01029b3:	e9 ac f7 ff ff       	jmp    c0102164 <__alltraps>

c01029b8 <vector208>:
.globl vector208
vector208:
  pushl $0
c01029b8:	6a 00                	push   $0x0
  pushl $208
c01029ba:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01029bf:	e9 a0 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029c4 <vector209>:
.globl vector209
vector209:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $209
c01029c6:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01029cb:	e9 94 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029d0 <vector210>:
.globl vector210
vector210:
  pushl $0
c01029d0:	6a 00                	push   $0x0
  pushl $210
c01029d2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01029d7:	e9 88 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029dc <vector211>:
.globl vector211
vector211:
  pushl $0
c01029dc:	6a 00                	push   $0x0
  pushl $211
c01029de:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01029e3:	e9 7c f7 ff ff       	jmp    c0102164 <__alltraps>

c01029e8 <vector212>:
.globl vector212
vector212:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $212
c01029ea:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01029ef:	e9 70 f7 ff ff       	jmp    c0102164 <__alltraps>

c01029f4 <vector213>:
.globl vector213
vector213:
  pushl $0
c01029f4:	6a 00                	push   $0x0
  pushl $213
c01029f6:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01029fb:	e9 64 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a00 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102a00:	6a 00                	push   $0x0
  pushl $214
c0102a02:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102a07:	e9 58 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a0c <vector215>:
.globl vector215
vector215:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $215
c0102a0e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102a13:	e9 4c f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a18 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102a18:	6a 00                	push   $0x0
  pushl $216
c0102a1a:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102a1f:	e9 40 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a24 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102a24:	6a 00                	push   $0x0
  pushl $217
c0102a26:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102a2b:	e9 34 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a30 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $218
c0102a32:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102a37:	e9 28 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a3c <vector219>:
.globl vector219
vector219:
  pushl $0
c0102a3c:	6a 00                	push   $0x0
  pushl $219
c0102a3e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102a43:	e9 1c f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a48 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102a48:	6a 00                	push   $0x0
  pushl $220
c0102a4a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102a4f:	e9 10 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a54 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $221
c0102a56:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102a5b:	e9 04 f7 ff ff       	jmp    c0102164 <__alltraps>

c0102a60 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102a60:	6a 00                	push   $0x0
  pushl $222
c0102a62:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102a67:	e9 f8 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102a6c <vector223>:
.globl vector223
vector223:
  pushl $0
c0102a6c:	6a 00                	push   $0x0
  pushl $223
c0102a6e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102a73:	e9 ec f6 ff ff       	jmp    c0102164 <__alltraps>

c0102a78 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $224
c0102a7a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102a7f:	e9 e0 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102a84 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102a84:	6a 00                	push   $0x0
  pushl $225
c0102a86:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102a8b:	e9 d4 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102a90 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102a90:	6a 00                	push   $0x0
  pushl $226
c0102a92:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102a97:	e9 c8 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102a9c <vector227>:
.globl vector227
vector227:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $227
c0102a9e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102aa3:	e9 bc f6 ff ff       	jmp    c0102164 <__alltraps>

c0102aa8 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102aa8:	6a 00                	push   $0x0
  pushl $228
c0102aaa:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102aaf:	e9 b0 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102ab4 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102ab4:	6a 00                	push   $0x0
  pushl $229
c0102ab6:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102abb:	e9 a4 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102ac0 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $230
c0102ac2:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102ac7:	e9 98 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102acc <vector231>:
.globl vector231
vector231:
  pushl $0
c0102acc:	6a 00                	push   $0x0
  pushl $231
c0102ace:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102ad3:	e9 8c f6 ff ff       	jmp    c0102164 <__alltraps>

c0102ad8 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102ad8:	6a 00                	push   $0x0
  pushl $232
c0102ada:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102adf:	e9 80 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102ae4 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $233
c0102ae6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102aeb:	e9 74 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102af0 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102af0:	6a 00                	push   $0x0
  pushl $234
c0102af2:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102af7:	e9 68 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102afc <vector235>:
.globl vector235
vector235:
  pushl $0
c0102afc:	6a 00                	push   $0x0
  pushl $235
c0102afe:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102b03:	e9 5c f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b08 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102b08:	6a 00                	push   $0x0
  pushl $236
c0102b0a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102b0f:	e9 50 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b14 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102b14:	6a 00                	push   $0x0
  pushl $237
c0102b16:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102b1b:	e9 44 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b20 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102b20:	6a 00                	push   $0x0
  pushl $238
c0102b22:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102b27:	e9 38 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b2c <vector239>:
.globl vector239
vector239:
  pushl $0
c0102b2c:	6a 00                	push   $0x0
  pushl $239
c0102b2e:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102b33:	e9 2c f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b38 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102b38:	6a 00                	push   $0x0
  pushl $240
c0102b3a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102b3f:	e9 20 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b44 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102b44:	6a 00                	push   $0x0
  pushl $241
c0102b46:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102b4b:	e9 14 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b50 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102b50:	6a 00                	push   $0x0
  pushl $242
c0102b52:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102b57:	e9 08 f6 ff ff       	jmp    c0102164 <__alltraps>

c0102b5c <vector243>:
.globl vector243
vector243:
  pushl $0
c0102b5c:	6a 00                	push   $0x0
  pushl $243
c0102b5e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102b63:	e9 fc f5 ff ff       	jmp    c0102164 <__alltraps>

c0102b68 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102b68:	6a 00                	push   $0x0
  pushl $244
c0102b6a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102b6f:	e9 f0 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102b74 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $245
c0102b76:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102b7b:	e9 e4 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102b80 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102b80:	6a 00                	push   $0x0
  pushl $246
c0102b82:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102b87:	e9 d8 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102b8c <vector247>:
.globl vector247
vector247:
  pushl $0
c0102b8c:	6a 00                	push   $0x0
  pushl $247
c0102b8e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102b93:	e9 cc f5 ff ff       	jmp    c0102164 <__alltraps>

c0102b98 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $248
c0102b9a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102b9f:	e9 c0 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102ba4 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102ba4:	6a 00                	push   $0x0
  pushl $249
c0102ba6:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102bab:	e9 b4 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bb0 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102bb0:	6a 00                	push   $0x0
  pushl $250
c0102bb2:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102bb7:	e9 a8 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bbc <vector251>:
.globl vector251
vector251:
  pushl $0
c0102bbc:	6a 00                	push   $0x0
  pushl $251
c0102bbe:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102bc3:	e9 9c f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bc8 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102bc8:	6a 00                	push   $0x0
  pushl $252
c0102bca:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102bcf:	e9 90 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bd4 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102bd4:	6a 00                	push   $0x0
  pushl $253
c0102bd6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102bdb:	e9 84 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102be0 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102be0:	6a 00                	push   $0x0
  pushl $254
c0102be2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102be7:	e9 78 f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bec <vector255>:
.globl vector255
vector255:
  pushl $0
c0102bec:	6a 00                	push   $0x0
  pushl $255
c0102bee:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102bf3:	e9 6c f5 ff ff       	jmp    c0102164 <__alltraps>

c0102bf8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102bf8:	55                   	push   %ebp
c0102bf9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102bfb:	8b 15 00 ef 11 c0    	mov    0xc011ef00,%edx
c0102c01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c04:	29 d0                	sub    %edx,%eax
c0102c06:	c1 f8 02             	sar    $0x2,%eax
c0102c09:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102c0f:	5d                   	pop    %ebp
c0102c10:	c3                   	ret    

c0102c11 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102c11:	55                   	push   %ebp
c0102c12:	89 e5                	mov    %esp,%ebp
c0102c14:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c1a:	89 04 24             	mov    %eax,(%esp)
c0102c1d:	e8 d6 ff ff ff       	call   c0102bf8 <page2ppn>
c0102c22:	c1 e0 0c             	shl    $0xc,%eax
}
c0102c25:	89 ec                	mov    %ebp,%esp
c0102c27:	5d                   	pop    %ebp
c0102c28:	c3                   	ret    

c0102c29 <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
c0102c29:	55                   	push   %ebp
c0102c2a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c32:	89 10                	mov    %edx,(%eax)
}
c0102c34:	90                   	nop
c0102c35:	5d                   	pop    %ebp
c0102c36:	c3                   	ret    

c0102c37 <MAX>:
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) (((index) + 1) / 2 - 1)

static struct Page* buddy_base;

static inline uint32_t MAX(uint32_t a, uint32_t b) {return ((a) > (b) ? (a) : (b));}
c0102c37:	55                   	push   %ebp
c0102c38:	89 e5                	mov    %esp,%ebp
c0102c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c40:	39 c2                	cmp    %eax,%edx
c0102c42:	0f 43 c2             	cmovae %edx,%eax
c0102c45:	5d                   	pop    %ebp
c0102c46:	c3                   	ret    

c0102c47 <is_pow_of_2>:
static inline bool is_pow_of_2(uint32_t x) { return !(x & (x - 1)); }
c0102c47:	55                   	push   %ebp
c0102c48:	89 e5                	mov    %esp,%ebp
c0102c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c4d:	48                   	dec    %eax
c0102c4e:	23 45 08             	and    0x8(%ebp),%eax
c0102c51:	85 c0                	test   %eax,%eax
c0102c53:	0f 94 c0             	sete   %al
c0102c56:	0f b6 c0             	movzbl %al,%eax
c0102c59:	5d                   	pop    %ebp
c0102c5a:	c3                   	ret    

c0102c5b <next_pow_of_2>:
static inline uint32_t next_pow_of_2(uint32_t x)
{
c0102c5b:	55                   	push   %ebp
c0102c5c:	89 e5                	mov    %esp,%ebp
c0102c5e:	83 ec 04             	sub    $0x4,%esp
	if (is_pow_of_2(x)) return x;
c0102c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c64:	89 04 24             	mov    %eax,(%esp)
c0102c67:	e8 db ff ff ff       	call   c0102c47 <is_pow_of_2>
c0102c6c:	85 c0                	test   %eax,%eax
c0102c6e:	74 05                	je     c0102c75 <next_pow_of_2+0x1a>
c0102c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c73:	eb 30                	jmp    c0102ca5 <next_pow_of_2+0x4a>
	x |= x >> 1;
c0102c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c78:	d1 e8                	shr    %eax
c0102c7a:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 2;
c0102c7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c80:	c1 e8 02             	shr    $0x2,%eax
c0102c83:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 4;
c0102c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c89:	c1 e8 04             	shr    $0x4,%eax
c0102c8c:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 8;
c0102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c92:	c1 e8 08             	shr    $0x8,%eax
c0102c95:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 16;
c0102c98:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c9b:	c1 e8 10             	shr    $0x10,%eax
c0102c9e:	09 45 08             	or     %eax,0x8(%ebp)
	return x + 1;
c0102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca4:	40                   	inc    %eax
}
c0102ca5:	89 ec                	mov    %ebp,%esp
c0102ca7:	5d                   	pop    %ebp
c0102ca8:	c3                   	ret    

c0102ca9 <buddy_init>:

static void
buddy_init(void) {
c0102ca9:	55                   	push   %ebp
c0102caa:	89 e5                	mov    %esp,%ebp
}
c0102cac:	90                   	nop
c0102cad:	5d                   	pop    %ebp
c0102cae:	c3                   	ret    

c0102caf <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page *base, size_t n) {
c0102caf:	55                   	push   %ebp
c0102cb0:	89 e5                	mov    %esp,%ebp
c0102cb2:	83 ec 68             	sub    $0x68,%esp
	assert(n > 0);
c0102cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102cb9:	75 24                	jne    c0102cdf <buddy_init_memmap+0x30>
c0102cbb:	c7 44 24 0c 90 77 10 	movl   $0xc0107790,0xc(%esp)
c0102cc2:	c0 
c0102cc3:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0102cca:	c0 
c0102ccb:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c0102cd2:	00 
c0102cd3:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0102cda:	e8 f1 df ff ff       	call   c0100cd0 <__panic>
	// 最大管理页数：不超过n的最大的2的幂次
	size_t max_pages = 1;
c0102cdf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	for (size_t i = 1; i < 31; i++)
c0102ce6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102ced:	eb 1d                	jmp    c0102d0c <buddy_init_memmap+0x5d>
	{
		// 需要一个存储longest数组的页
		if (max_pages + max_pages / 512 >= n)
c0102cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cf2:	c1 e8 09             	shr    $0x9,%eax
c0102cf5:	89 c2                	mov    %eax,%edx
c0102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cfa:	01 d0                	add    %edx,%eax
c0102cfc:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0102cff:	77 05                	ja     c0102d06 <buddy_init_memmap+0x57>
		{
			max_pages >>= 1;
c0102d01:	d1 6d f4             	shrl   -0xc(%ebp)
			break;
c0102d04:	eb 0c                	jmp    c0102d12 <buddy_init_memmap+0x63>
		}
		max_pages <<= 1;
c0102d06:	d1 65 f4             	shll   -0xc(%ebp)
	for (size_t i = 1; i < 31; i++)
c0102d09:	ff 45 f0             	incl   -0x10(%ebp)
c0102d0c:	83 7d f0 1e          	cmpl   $0x1e,-0x10(%ebp)
c0102d10:	76 dd                	jbe    c0102cef <buddy_init_memmap+0x40>
	}
	// 存储longest需要的页数
	size_t longest_array_pages = max_pages / 512 + 1;
c0102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d15:	c1 e8 09             	shr    $0x9,%eax
c0102d18:	40                   	inc    %eax
c0102d19:	89 45 dc             	mov    %eax,-0x24(%ebp)

	buddy_longest = (uint32_t*)KADDR(page2pa(base));
c0102d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d1f:	89 04 24             	mov    %eax,(%esp)
c0102d22:	e8 ea fe ff ff       	call   c0102c11 <page2pa>
c0102d27:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102d2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102d2d:	c1 e8 0c             	shr    $0xc,%eax
c0102d30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102d33:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0102d38:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
c0102d3b:	72 23                	jb     c0102d60 <buddy_init_memmap+0xb1>
c0102d3d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d44:	c7 44 24 08 c0 77 10 	movl   $0xc01077c0,0x8(%esp)
c0102d4b:	c0 
c0102d4c:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
c0102d53:	00 
c0102d54:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0102d5b:	e8 70 df ff ff       	call   c0100cd0 <__panic>
c0102d60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102d63:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0102d68:	a3 e4 ee 11 c0       	mov    %eax,0xc011eee4
	buddy_max_pages = max_pages;
c0102d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d70:	a3 e8 ee 11 c0       	mov    %eax,0xc011eee8

	uint32_t node_size = max_pages * 2;
c0102d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d78:	01 c0                	add    %eax,%eax
c0102d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (uint32_t i = 0; i < 2*max_pages-1; i++)
c0102d7d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0102d84:	eb 29                	jmp    c0102daf <buddy_init_memmap+0x100>
	{
		if (is_pow_of_2(i+1)) node_size >>= 1;
c0102d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d89:	40                   	inc    %eax
c0102d8a:	89 04 24             	mov    %eax,(%esp)
c0102d8d:	e8 b5 fe ff ff       	call   c0102c47 <is_pow_of_2>
c0102d92:	85 c0                	test   %eax,%eax
c0102d94:	74 03                	je     c0102d99 <buddy_init_memmap+0xea>
c0102d96:	d1 6d ec             	shrl   -0x14(%ebp)
		buddy_longest[i] = node_size;
c0102d99:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0102d9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102da2:	c1 e0 02             	shl    $0x2,%eax
c0102da5:	01 c2                	add    %eax,%edx
c0102da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102daa:	89 02                	mov    %eax,(%edx)
	for (uint32_t i = 0; i < 2*max_pages-1; i++)
c0102dac:	ff 45 e8             	incl   -0x18(%ebp)
c0102daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102db2:	01 c0                	add    %eax,%eax
c0102db4:	48                   	dec    %eax
c0102db5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0102db8:	72 cc                	jb     c0102d86 <buddy_init_memmap+0xd7>
	}

	for (int i = 0; i < longest_array_pages; i++)
c0102dba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0102dc1:	eb 34                	jmp    c0102df7 <buddy_init_memmap+0x148>
	{
		struct Page *p = base + i;
c0102dc3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102dc6:	89 d0                	mov    %edx,%eax
c0102dc8:	c1 e0 02             	shl    $0x2,%eax
c0102dcb:	01 d0                	add    %edx,%eax
c0102dcd:	c1 e0 02             	shl    $0x2,%eax
c0102dd0:	89 c2                	mov    %eax,%edx
c0102dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dd5:	01 d0                	add    %edx,%eax
c0102dd7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		SetPageReserved(p);
c0102dda:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102ddd:	83 c0 04             	add    $0x4,%eax
c0102de0:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c0102de7:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dea:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102ded:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102df0:	0f ab 10             	bts    %edx,(%eax)
}
c0102df3:	90                   	nop
	for (int i = 0; i < longest_array_pages; i++)
c0102df4:	ff 45 e4             	incl   -0x1c(%ebp)
c0102df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102dfa:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102dfd:	77 c4                	ja     c0102dc3 <buddy_init_memmap+0x114>
	}

	struct Page *p = base + longest_array_pages;
c0102dff:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e02:	89 d0                	mov    %edx,%eax
c0102e04:	c1 e0 02             	shl    $0x2,%eax
c0102e07:	01 d0                	add    %edx,%eax
c0102e09:	c1 e0 02             	shl    $0x2,%eax
c0102e0c:	89 c2                	mov    %eax,%edx
c0102e0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e11:	01 d0                	add    %edx,%eax
c0102e13:	89 45 e0             	mov    %eax,-0x20(%ebp)
	buddy_base = p;
c0102e16:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e19:	a3 ec ee 11 c0       	mov    %eax,0xc011eeec
    for (; p != base + n; p ++) {
c0102e1e:	e9 9b 00 00 00       	jmp    c0102ebe <buddy_init_memmap+0x20f>
		assert(PageReserved(p));
c0102e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e26:	83 c0 04             	add    $0x4,%eax
c0102e29:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
c0102e30:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e33:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102e36:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102e39:	0f a3 10             	bt     %edx,(%eax)
c0102e3c:	19 c0                	sbb    %eax,%eax
c0102e3e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0102e41:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102e45:	0f 95 c0             	setne  %al
c0102e48:	0f b6 c0             	movzbl %al,%eax
c0102e4b:	85 c0                	test   %eax,%eax
c0102e4d:	75 24                	jne    c0102e73 <buddy_init_memmap+0x1c4>
c0102e4f:	c7 44 24 0c e3 77 10 	movl   $0xc01077e3,0xc(%esp)
c0102e56:	c0 
c0102e57:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0102e5e:	c0 
c0102e5f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0102e66:	00 
c0102e67:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0102e6e:	e8 5d de ff ff       	call   c0100cd0 <__panic>
		ClearPageReserved(p);
c0102e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e76:	83 c0 04             	add    $0x4,%eax
c0102e79:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
c0102e80:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e83:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102e86:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102e89:	0f b3 10             	btr    %edx,(%eax)
}
c0102e8c:	90                   	nop
		SetPageProperty(p);
c0102e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102e90:	83 c0 04             	add    $0x4,%eax
c0102e93:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102e9a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102e9d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102ea0:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102ea3:	0f ab 10             	bts    %edx,(%eax)
}
c0102ea6:	90                   	nop
		set_page_ref(p, 0);
c0102ea7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102eae:	00 
c0102eaf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102eb2:	89 04 24             	mov    %eax,(%esp)
c0102eb5:	e8 6f fd ff ff       	call   c0102c29 <set_page_ref>
    for (; p != base + n; p ++) {
c0102eba:	83 45 e0 14          	addl   $0x14,-0x20(%ebp)
c0102ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ec1:	89 d0                	mov    %edx,%eax
c0102ec3:	c1 e0 02             	shl    $0x2,%eax
c0102ec6:	01 d0                	add    %edx,%eax
c0102ec8:	c1 e0 02             	shl    $0x2,%eax
c0102ecb:	89 c2                	mov    %eax,%edx
c0102ecd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ed0:	01 d0                	add    %edx,%eax
c0102ed2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0102ed5:	0f 85 48 ff ff ff    	jne    c0102e23 <buddy_init_memmap+0x174>
    }
}
c0102edb:	90                   	nop
c0102edc:	90                   	nop
c0102edd:	89 ec                	mov    %ebp,%esp
c0102edf:	5d                   	pop    %ebp
c0102ee0:	c3                   	ret    

c0102ee1 <buddy_alloc_pages>:

static struct Page *
buddy_alloc_pages(size_t n) {
c0102ee1:	55                   	push   %ebp
c0102ee2:	89 e5                	mov    %esp,%ebp
c0102ee4:	83 ec 38             	sub    $0x38,%esp
c0102ee7:	89 5d fc             	mov    %ebx,-0x4(%ebp)
	assert(n > 0);
c0102eea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102eee:	75 24                	jne    c0102f14 <buddy_alloc_pages+0x33>
c0102ef0:	c7 44 24 0c 90 77 10 	movl   $0xc0107790,0xc(%esp)
c0102ef7:	c0 
c0102ef8:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0102eff:	c0 
c0102f00:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
c0102f07:	00 
c0102f08:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0102f0f:	e8 bc dd ff ff       	call   c0100cd0 <__panic>
	n = next_pow_of_2(n);
c0102f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f17:	89 04 24             	mov    %eax,(%esp)
c0102f1a:	e8 3c fd ff ff       	call   c0102c5b <next_pow_of_2>
c0102f1f:	89 45 08             	mov    %eax,0x8(%ebp)
	if (n > buddy_longest[0]) {
c0102f22:	a1 e4 ee 11 c0       	mov    0xc011eee4,%eax
c0102f27:	8b 00                	mov    (%eax),%eax
c0102f29:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102f2c:	76 0a                	jbe    c0102f38 <buddy_alloc_pages+0x57>
		return NULL;
c0102f2e:	b8 00 00 00 00       	mov    $0x0,%eax
c0102f33:	e9 2e 01 00 00       	jmp    c0103066 <buddy_alloc_pages+0x185>
	}

	// 从根节点遍历二叉树
	uint32_t index = 0;
c0102f38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// 当前节点大小 （p->property）
	uint32_t node_size;

	// 寻找合适内存块
	for (node_size = buddy_max_pages; node_size != n; node_size >>= 1) 
c0102f3f:	a1 e8 ee 11 c0       	mov    0xc011eee8,%eax
c0102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f47:	eb 2f                	jmp    c0102f78 <buddy_alloc_pages+0x97>
	{
		if (buddy_longest[LEFT_LEAF(index)] >= n)
c0102f49:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0102f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f52:	c1 e0 03             	shl    $0x3,%eax
c0102f55:	83 c0 04             	add    $0x4,%eax
c0102f58:	01 d0                	add    %edx,%eax
c0102f5a:	8b 00                	mov    (%eax),%eax
c0102f5c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102f5f:	77 0b                	ja     c0102f6c <buddy_alloc_pages+0x8b>
			index = LEFT_LEAF(index);
c0102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f64:	01 c0                	add    %eax,%eax
c0102f66:	40                   	inc    %eax
c0102f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f6a:	eb 09                	jmp    c0102f75 <buddy_alloc_pages+0x94>
		else
			index = RIGHT_LEAF(index);
c0102f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f6f:	40                   	inc    %eax
c0102f70:	01 c0                	add    %eax,%eax
c0102f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (node_size = buddy_max_pages; node_size != n; node_size >>= 1) 
c0102f75:	d1 6d f0             	shrl   -0x10(%ebp)
c0102f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f7b:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102f7e:	75 c9                	jne    c0102f49 <buddy_alloc_pages+0x68>
	}

	// 分配此节点下的所有页
	buddy_longest[index] = 0;
c0102f80:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0102f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f89:	c1 e0 02             	shl    $0x2,%eax
c0102f8c:	01 d0                	add    %edx,%eax
c0102f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	// 找到页位置
	uint32_t offset = (index + 1) * node_size - buddy_max_pages;
c0102f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f97:	40                   	inc    %eax
c0102f98:	0f af 45 f0          	imul   -0x10(%ebp),%eax
c0102f9c:	8b 15 e8 ee 11 c0    	mov    0xc011eee8,%edx
c0102fa2:	29 d0                	sub    %edx,%eax
c0102fa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	struct Page* new_page = buddy_base + offset, * p;
c0102fa7:	8b 0d ec ee 11 c0    	mov    0xc011eeec,%ecx
c0102fad:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0102fb0:	89 d0                	mov    %edx,%eax
c0102fb2:	c1 e0 02             	shl    $0x2,%eax
c0102fb5:	01 d0                	add    %edx,%eax
c0102fb7:	c1 e0 02             	shl    $0x2,%eax
c0102fba:	01 c8                	add    %ecx,%eax
c0102fbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (p = new_page; p != new_page+node_size; p++)
c0102fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102fc5:	eb 31                	jmp    c0102ff8 <buddy_alloc_pages+0x117>
	{
		set_page_ref(p, 0); // init时没有设置
c0102fc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102fce:	00 
c0102fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fd2:	89 04 24             	mov    %eax,(%esp)
c0102fd5:	e8 4f fc ff ff       	call   c0102c29 <set_page_ref>
		ClearPageProperty(p); // 每一页都Clear
c0102fda:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fdd:	83 c0 04             	add    $0x4,%eax
c0102fe0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102fe7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102fed:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102ff0:	0f b3 10             	btr    %edx,(%eax)
}
c0102ff3:	90                   	nop
	for (p = new_page; p != new_page+node_size; p++)
c0102ff4:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c0102ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102ffb:	89 d0                	mov    %edx,%eax
c0102ffd:	c1 e0 02             	shl    $0x2,%eax
c0103000:	01 d0                	add    %edx,%eax
c0103002:	c1 e0 02             	shl    $0x2,%eax
c0103005:	89 c2                	mov    %eax,%edx
c0103007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010300a:	01 d0                	add    %edx,%eax
c010300c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010300f:	75 b6                	jne    c0102fc7 <buddy_alloc_pages+0xe6>
	}

	// 更新所有父节点
	while (index) {
c0103011:	eb 4a                	jmp    c010305d <buddy_alloc_pages+0x17c>
		index = PARENT(index);
c0103013:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103016:	40                   	inc    %eax
c0103017:	d1 e8                	shr    %eax
c0103019:	48                   	dec    %eax
c010301a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		buddy_longest[index] = MAX(
			buddy_longest[LEFT_LEAF(index)], 
			buddy_longest[RIGHT_LEAF(index)]);
c010301d:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0103023:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103026:	40                   	inc    %eax
c0103027:	c1 e0 03             	shl    $0x3,%eax
c010302a:	01 d0                	add    %edx,%eax
		buddy_longest[index] = MAX(
c010302c:	8b 10                	mov    (%eax),%edx
			buddy_longest[LEFT_LEAF(index)], 
c010302e:	8b 0d e4 ee 11 c0    	mov    0xc011eee4,%ecx
c0103034:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103037:	c1 e0 03             	shl    $0x3,%eax
c010303a:	83 c0 04             	add    $0x4,%eax
c010303d:	01 c8                	add    %ecx,%eax
		buddy_longest[index] = MAX(
c010303f:	8b 00                	mov    (%eax),%eax
c0103041:	8b 1d e4 ee 11 c0    	mov    0xc011eee4,%ebx
c0103047:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c010304a:	c1 e1 02             	shl    $0x2,%ecx
c010304d:	01 cb                	add    %ecx,%ebx
c010304f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103053:	89 04 24             	mov    %eax,(%esp)
c0103056:	e8 dc fb ff ff       	call   c0102c37 <MAX>
c010305b:	89 03                	mov    %eax,(%ebx)
	while (index) {
c010305d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103061:	75 b0                	jne    c0103013 <buddy_alloc_pages+0x132>
	}
	return new_page;
c0103063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
c0103066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103069:	89 ec                	mov    %ebp,%esp
c010306b:	5d                   	pop    %ebp
c010306c:	c3                   	ret    

c010306d <buddy_free_pages>:

static void
buddy_free_pages(struct Page *base, size_t n) {
c010306d:	55                   	push   %ebp
c010306e:	89 e5                	mov    %esp,%ebp
c0103070:	83 ec 58             	sub    $0x58,%esp
c0103073:	89 5d fc             	mov    %ebx,-0x4(%ebp)
	assert(n > 0);
c0103076:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010307a:	75 24                	jne    c01030a0 <buddy_free_pages+0x33>
c010307c:	c7 44 24 0c 90 77 10 	movl   $0xc0107790,0xc(%esp)
c0103083:	c0 
c0103084:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c010308b:	c0 
c010308c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0103093:	00 
c0103094:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c010309b:	e8 30 dc ff ff       	call   c0100cd0 <__panic>
	n = next_pow_of_2(n);
c01030a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030a3:	89 04 24             	mov    %eax,(%esp)
c01030a6:	e8 b0 fb ff ff       	call   c0102c5b <next_pow_of_2>
c01030ab:	89 45 0c             	mov    %eax,0xc(%ebp)
	// base作为叶节点在longest中的位置
	uint32_t index = (uint32_t)(base - buddy_base) + buddy_max_pages - 1;
c01030ae:	8b 15 ec ee 11 c0    	mov    0xc011eeec,%edx
c01030b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01030b7:	29 d0                	sub    %edx,%eax
c01030b9:	c1 f8 02             	sar    $0x2,%eax
c01030bc:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
c01030c2:	89 c2                	mov    %eax,%edx
c01030c4:	a1 e8 ee 11 c0       	mov    0xc011eee8,%eax
c01030c9:	01 d0                	add    %edx,%eax
c01030cb:	48                   	dec    %eax
c01030cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t node_size = 1;
c01030cf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// 向上找到第一个为0的节点
	while (buddy_longest[index] != 0)
c01030d6:	eb 37                	jmp    c010310f <buddy_free_pages+0xa2>
	{
		node_size <<= 1;
c01030d8:	d1 65 f0             	shll   -0x10(%ebp)
		assert(index != 0); // 否则出现错误，不存在分配过的节点
c01030db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030df:	75 24                	jne    c0103105 <buddy_free_pages+0x98>
c01030e1:	c7 44 24 0c f3 77 10 	movl   $0xc01077f3,0xc(%esp)
c01030e8:	c0 
c01030e9:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01030f0:	c0 
c01030f1:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
c01030f8:	00 
c01030f9:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103100:	e8 cb db ff ff       	call   c0100cd0 <__panic>
		index = PARENT(index);
c0103105:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103108:	40                   	inc    %eax
c0103109:	d1 e8                	shr    %eax
c010310b:	48                   	dec    %eax
c010310c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while (buddy_longest[index] != 0)
c010310f:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0103115:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103118:	c1 e0 02             	shl    $0x2,%eax
c010311b:	01 d0                	add    %edx,%eax
c010311d:	8b 00                	mov    (%eax),%eax
c010311f:	85 c0                	test   %eax,%eax
c0103121:	75 b5                	jne    c01030d8 <buddy_free_pages+0x6b>
	}

	struct Page *p = base;
c0103123:	8b 45 08             	mov    0x8(%ebp),%eax
c0103126:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (; p != base + n; p ++) {
c0103129:	e9 ad 00 00 00       	jmp    c01031db <buddy_free_pages+0x16e>
	    assert(!PageReserved(p) && !PageProperty(p));
c010312e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103131:	83 c0 04             	add    $0x4,%eax
c0103134:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010313b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010313e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103141:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103144:	0f a3 10             	bt     %edx,(%eax)
c0103147:	19 c0                	sbb    %eax,%eax
c0103149:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010314c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103150:	0f 95 c0             	setne  %al
c0103153:	0f b6 c0             	movzbl %al,%eax
c0103156:	85 c0                	test   %eax,%eax
c0103158:	75 2c                	jne    c0103186 <buddy_free_pages+0x119>
c010315a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010315d:	83 c0 04             	add    $0x4,%eax
c0103160:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103167:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010316a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010316d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103170:	0f a3 10             	bt     %edx,(%eax)
c0103173:	19 c0                	sbb    %eax,%eax
c0103175:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
c0103178:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010317c:	0f 95 c0             	setne  %al
c010317f:	0f b6 c0             	movzbl %al,%eax
c0103182:	85 c0                	test   %eax,%eax
c0103184:	74 24                	je     c01031aa <buddy_free_pages+0x13d>
c0103186:	c7 44 24 0c 00 78 10 	movl   $0xc0107800,0xc(%esp)
c010318d:	c0 
c010318e:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103195:	c0 
c0103196:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
c010319d:	00 
c010319e:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01031a5:	e8 26 db ff ff       	call   c0100cd0 <__panic>
        // p->flags = 0;
	    SetPageProperty(p); // 分配时每页都Clear，此时每页都Set
c01031aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031ad:	83 c0 04             	add    $0x4,%eax
c01031b0:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01031b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01031ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01031bd:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01031c0:	0f ab 10             	bts    %edx,(%eax)
}
c01031c3:	90                   	nop
	    set_page_ref(p, 0);
c01031c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01031cb:	00 
c01031cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031cf:	89 04 24             	mov    %eax,(%esp)
c01031d2:	e8 52 fa ff ff       	call   c0102c29 <set_page_ref>
	for (; p != base + n; p ++) {
c01031d7:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
c01031db:	8b 55 0c             	mov    0xc(%ebp),%edx
c01031de:	89 d0                	mov    %edx,%eax
c01031e0:	c1 e0 02             	shl    $0x2,%eax
c01031e3:	01 d0                	add    %edx,%eax
c01031e5:	c1 e0 02             	shl    $0x2,%eax
c01031e8:	89 c2                	mov    %eax,%edx
c01031ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01031ed:	01 d0                	add    %edx,%eax
c01031ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01031f2:	0f 85 36 ff ff ff    	jne    c010312e <buddy_free_pages+0xc1>
	}

	// 更新longest数组
	buddy_longest[index] = node_size;
c01031f8:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c01031fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103201:	c1 e0 02             	shl    $0x2,%eax
c0103204:	01 c2                	add    %eax,%edx
c0103206:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103209:	89 02                	mov    %eax,(%edx)
	while (index != 0)
c010320b:	eb 7c                	jmp    c0103289 <buddy_free_pages+0x21c>
	{
		index = PARENT(index);
c010320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103210:	40                   	inc    %eax
c0103211:	d1 e8                	shr    %eax
c0103213:	48                   	dec    %eax
c0103214:	89 45 f4             	mov    %eax,-0xc(%ebp)
		node_size <<= 1;
c0103217:	d1 65 f0             	shll   -0x10(%ebp)
		uint32_t left_size = buddy_longest[LEFT_LEAF(index)];
c010321a:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0103220:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103223:	c1 e0 03             	shl    $0x3,%eax
c0103226:	83 c0 04             	add    $0x4,%eax
c0103229:	01 d0                	add    %edx,%eax
c010322b:	8b 00                	mov    (%eax),%eax
c010322d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		uint32_t right_size = buddy_longest[RIGHT_LEAF(index)];
c0103230:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0103236:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103239:	40                   	inc    %eax
c010323a:	c1 e0 03             	shl    $0x3,%eax
c010323d:	01 d0                	add    %edx,%eax
c010323f:	8b 00                	mov    (%eax),%eax
c0103241:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		if (left_size + right_size == node_size) // 相邻可以合并
c0103244:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010324a:	01 d0                	add    %edx,%eax
c010324c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010324f:	75 15                	jne    c0103266 <buddy_free_pages+0x1f9>
			buddy_longest[index] = node_size;
c0103251:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c0103257:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010325a:	c1 e0 02             	shl    $0x2,%eax
c010325d:	01 c2                	add    %eax,%edx
c010325f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103262:	89 02                	mov    %eax,(%edx)
c0103264:	eb 23                	jmp    c0103289 <buddy_free_pages+0x21c>
		else
			buddy_longest[index] = MAX(left_size, right_size);
c0103266:	8b 15 e4 ee 11 c0    	mov    0xc011eee4,%edx
c010326c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010326f:	c1 e0 02             	shl    $0x2,%eax
c0103272:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c0103275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103278:	89 44 24 04          	mov    %eax,0x4(%esp)
c010327c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010327f:	89 04 24             	mov    %eax,(%esp)
c0103282:	e8 b0 f9 ff ff       	call   c0102c37 <MAX>
c0103287:	89 03                	mov    %eax,(%ebx)
	while (index != 0)
c0103289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010328d:	0f 85 7a ff ff ff    	jne    c010320d <buddy_free_pages+0x1a0>
	}
}
c0103293:	90                   	nop
c0103294:	90                   	nop
c0103295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103298:	89 ec                	mov    %ebp,%esp
c010329a:	5d                   	pop    %ebp
c010329b:	c3                   	ret    

c010329c <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
c010329c:	55                   	push   %ebp
c010329d:	89 e5                	mov    %esp,%ebp
    return buddy_longest[0];
c010329f:	a1 e4 ee 11 c0       	mov    0xc011eee4,%eax
c01032a4:	8b 00                	mov    (%eax),%eax
}
c01032a6:	5d                   	pop    %ebp
c01032a7:	c3                   	ret    

c01032a8 <buddy_check>:

static void
buddy_check(void) {
c01032a8:	55                   	push   %ebp
c01032a9:	89 e5                	mov    %esp,%ebp
c01032ab:	81 ec a8 00 00 00    	sub    $0xa8,%esp
	int all_pages = nr_free_pages();
c01032b1:	e8 9d 1b 00 00       	call   c0104e53 <nr_free_pages>
c01032b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Page* p0, *p1, *p2, *p3, *p4;
	assert(alloc_pages(all_pages + 1) == NULL);
c01032b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032bc:	40                   	inc    %eax
c01032bd:	89 04 24             	mov    %eax,(%esp)
c01032c0:	e8 1f 1b 00 00       	call   c0104de4 <alloc_pages>
c01032c5:	85 c0                	test   %eax,%eax
c01032c7:	74 24                	je     c01032ed <buddy_check+0x45>
c01032c9:	c7 44 24 0c 28 78 10 	movl   $0xc0107828,0xc(%esp)
c01032d0:	c0 
c01032d1:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01032d8:	c0 
c01032d9:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c01032e0:	00 
c01032e1:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01032e8:	e8 e3 d9 ff ff       	call   c0100cd0 <__panic>

	p0 = alloc_pages(1);
c01032ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032f4:	e8 eb 1a 00 00       	call   c0104de4 <alloc_pages>
c01032f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(p0 != NULL);
c01032fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103300:	75 24                	jne    c0103326 <buddy_check+0x7e>
c0103302:	c7 44 24 0c 4b 78 10 	movl   $0xc010784b,0xc(%esp)
c0103309:	c0 
c010330a:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103311:	c0 
c0103312:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0103319:	00 
c010331a:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103321:	e8 aa d9 ff ff       	call   c0100cd0 <__panic>
	
	p1 = alloc_pages(2);
c0103326:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010332d:	e8 b2 1a 00 00       	call   c0104de4 <alloc_pages>
c0103332:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(p1 == p0 + 2);
c0103335:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103338:	83 c0 28             	add    $0x28,%eax
c010333b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010333e:	74 24                	je     c0103364 <buddy_check+0xbc>
c0103340:	c7 44 24 0c 56 78 10 	movl   $0xc0107856,0xc(%esp)
c0103347:	c0 
c0103348:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c010334f:	c0 
c0103350:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0103357:	00 
c0103358:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c010335f:	e8 6c d9 ff ff       	call   c0100cd0 <__panic>
	assert(!PageReserved(p0) && !PageReserved(p1));
c0103364:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103367:	83 c0 04             	add    $0x4,%eax
c010336a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103371:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103374:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103377:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010337a:	0f a3 10             	bt     %edx,(%eax)
c010337d:	19 c0                	sbb    %eax,%eax
c010337f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0103382:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0103386:	0f 95 c0             	setne  %al
c0103389:	0f b6 c0             	movzbl %al,%eax
c010338c:	85 c0                	test   %eax,%eax
c010338e:	75 2c                	jne    c01033bc <buddy_check+0x114>
c0103390:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103393:	83 c0 04             	add    $0x4,%eax
c0103396:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c010339d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01033a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01033a6:	0f a3 10             	bt     %edx,(%eax)
c01033a9:	19 c0                	sbb    %eax,%eax
c01033ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01033ae:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01033b2:	0f 95 c0             	setne  %al
c01033b5:	0f b6 c0             	movzbl %al,%eax
c01033b8:	85 c0                	test   %eax,%eax
c01033ba:	74 24                	je     c01033e0 <buddy_check+0x138>
c01033bc:	c7 44 24 0c 64 78 10 	movl   $0xc0107864,0xc(%esp)
c01033c3:	c0 
c01033c4:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01033cb:	c0 
c01033cc:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c01033d3:	00 
c01033d4:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01033db:	e8 f0 d8 ff ff       	call   c0100cd0 <__panic>
	assert(!PageProperty(p0) && !PageProperty(p1));
c01033e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033e3:	83 c0 04             	add    $0x4,%eax
c01033e6:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01033ed:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033f0:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01033f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01033f6:	0f a3 10             	bt     %edx,(%eax)
c01033f9:	19 c0                	sbb    %eax,%eax
c01033fb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01033fe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103402:	0f 95 c0             	setne  %al
c0103405:	0f b6 c0             	movzbl %al,%eax
c0103408:	85 c0                	test   %eax,%eax
c010340a:	75 2c                	jne    c0103438 <buddy_check+0x190>
c010340c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010340f:	83 c0 04             	add    $0x4,%eax
c0103412:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103419:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010341c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010341f:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103422:	0f a3 10             	bt     %edx,(%eax)
c0103425:	19 c0                	sbb    %eax,%eax
c0103427:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c010342a:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c010342e:	0f 95 c0             	setne  %al
c0103431:	0f b6 c0             	movzbl %al,%eax
c0103434:	85 c0                	test   %eax,%eax
c0103436:	74 24                	je     c010345c <buddy_check+0x1b4>
c0103438:	c7 44 24 0c 8c 78 10 	movl   $0xc010788c,0xc(%esp)
c010343f:	c0 
c0103440:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103447:	c0 
c0103448:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c010344f:	00 
c0103450:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103457:	e8 74 d8 ff ff       	call   c0100cd0 <__panic>

	p2 = alloc_pages(1);
c010345c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103463:	e8 7c 19 00 00       	call   c0104de4 <alloc_pages>
c0103468:	89 45 e8             	mov    %eax,-0x18(%ebp)
	assert(p2 == p0 + 1);
c010346b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010346e:	83 c0 14             	add    $0x14,%eax
c0103471:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103474:	74 24                	je     c010349a <buddy_check+0x1f2>
c0103476:	c7 44 24 0c b3 78 10 	movl   $0xc01078b3,0xc(%esp)
c010347d:	c0 
c010347e:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103485:	c0 
c0103486:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c010348d:	00 
c010348e:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103495:	e8 36 d8 ff ff       	call   c0100cd0 <__panic>

	p3 = alloc_pages(2);
c010349a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01034a1:	e8 3e 19 00 00       	call   c0104de4 <alloc_pages>
c01034a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(p3 == p0 + 4);
c01034a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034ac:	83 c0 50             	add    $0x50,%eax
c01034af:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01034b2:	74 24                	je     c01034d8 <buddy_check+0x230>
c01034b4:	c7 44 24 0c c0 78 10 	movl   $0xc01078c0,0xc(%esp)
c01034bb:	c0 
c01034bc:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01034c3:	c0 
c01034c4:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01034cb:	00 
c01034cc:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01034d3:	e8 f8 d7 ff ff       	call   c0100cd0 <__panic>
	assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));
c01034d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034db:	83 c0 04             	add    $0x4,%eax
c01034de:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01034e5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01034eb:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01034ee:	0f a3 10             	bt     %edx,(%eax)
c01034f1:	19 c0                	sbb    %eax,%eax
c01034f3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01034f6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01034fa:	0f 95 c0             	setne  %al
c01034fd:	0f b6 c0             	movzbl %al,%eax
c0103500:	85 c0                	test   %eax,%eax
c0103502:	75 5e                	jne    c0103562 <buddy_check+0x2ba>
c0103504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103507:	83 c0 14             	add    $0x14,%eax
c010350a:	83 c0 04             	add    $0x4,%eax
c010350d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103514:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103517:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010351a:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010351d:	0f a3 10             	bt     %edx,(%eax)
c0103520:	19 c0                	sbb    %eax,%eax
c0103522:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103525:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103529:	0f 95 c0             	setne  %al
c010352c:	0f b6 c0             	movzbl %al,%eax
c010352f:	85 c0                	test   %eax,%eax
c0103531:	75 2f                	jne    c0103562 <buddy_check+0x2ba>
c0103533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103536:	83 c0 28             	add    $0x28,%eax
c0103539:	83 c0 04             	add    $0x4,%eax
c010353c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103543:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103546:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103549:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010354c:	0f a3 10             	bt     %edx,(%eax)
c010354f:	19 c0                	sbb    %eax,%eax
c0103551:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103554:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103558:	0f 95 c0             	setne  %al
c010355b:	0f b6 c0             	movzbl %al,%eax
c010355e:	85 c0                	test   %eax,%eax
c0103560:	75 24                	jne    c0103586 <buddy_check+0x2de>
c0103562:	c7 44 24 0c d0 78 10 	movl   $0xc01078d0,0xc(%esp)
c0103569:	c0 
c010356a:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103571:	c0 
c0103572:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0103579:	00 
c010357a:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103581:	e8 4a d7 ff ff       	call   c0100cd0 <__panic>

	free_pages(p1, 2);
c0103586:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010358d:	00 
c010358e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103591:	89 04 24             	mov    %eax,(%esp)
c0103594:	e8 85 18 00 00       	call   c0104e1e <free_pages>
	assert(PageProperty(p1) && PageProperty(p1 + 1));
c0103599:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010359c:	83 c0 04             	add    $0x4,%eax
c010359f:	c7 45 88 01 00 00 00 	movl   $0x1,-0x78(%ebp)
c01035a6:	89 45 84             	mov    %eax,-0x7c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035a9:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01035ac:	8b 55 88             	mov    -0x78(%ebp),%edx
c01035af:	0f a3 10             	bt     %edx,(%eax)
c01035b2:	19 c0                	sbb    %eax,%eax
c01035b4:	89 45 80             	mov    %eax,-0x80(%ebp)
    return oldbit != 0;
c01035b7:	83 7d 80 00          	cmpl   $0x0,-0x80(%ebp)
c01035bb:	0f 95 c0             	setne  %al
c01035be:	0f b6 c0             	movzbl %al,%eax
c01035c1:	85 c0                	test   %eax,%eax
c01035c3:	74 41                	je     c0103606 <buddy_check+0x35e>
c01035c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035c8:	83 c0 14             	add    $0x14,%eax
c01035cb:	83 c0 04             	add    $0x4,%eax
c01035ce:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
c01035d5:	00 00 00 
c01035d8:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035de:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c01035e4:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c01035ea:	0f a3 10             	bt     %edx,(%eax)
c01035ed:	19 c0                	sbb    %eax,%eax
c01035ef:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
    return oldbit != 0;
c01035f5:	83 bd 74 ff ff ff 00 	cmpl   $0x0,-0x8c(%ebp)
c01035fc:	0f 95 c0             	setne  %al
c01035ff:	0f b6 c0             	movzbl %al,%eax
c0103602:	85 c0                	test   %eax,%eax
c0103604:	75 24                	jne    c010362a <buddy_check+0x382>
c0103606:	c7 44 24 0c 14 79 10 	movl   $0xc0107914,0xc(%esp)
c010360d:	c0 
c010360e:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103615:	c0 
c0103616:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c010361d:	00 
c010361e:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103625:	e8 a6 d6 ff ff       	call   c0100cd0 <__panic>
	assert(p1->ref == 0);
c010362a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010362d:	8b 00                	mov    (%eax),%eax
c010362f:	85 c0                	test   %eax,%eax
c0103631:	74 24                	je     c0103657 <buddy_check+0x3af>
c0103633:	c7 44 24 0c 3d 79 10 	movl   $0xc010793d,0xc(%esp)
c010363a:	c0 
c010363b:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103642:	c0 
c0103643:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c010364a:	00 
c010364b:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103652:	e8 79 d6 ff ff       	call   c0100cd0 <__panic>

	free_pages(p0, 1);
c0103657:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010365e:	00 
c010365f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103662:	89 04 24             	mov    %eax,(%esp)
c0103665:	e8 b4 17 00 00       	call   c0104e1e <free_pages>
	free_pages(p2, 1);
c010366a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103671:	00 
c0103672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103675:	89 04 24             	mov    %eax,(%esp)
c0103678:	e8 a1 17 00 00       	call   c0104e1e <free_pages>

	p4 = alloc_pages(2);
c010367d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103684:	e8 5b 17 00 00       	call   c0104de4 <alloc_pages>
c0103689:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(p4 == p0);
c010368c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010368f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103692:	74 24                	je     c01036b8 <buddy_check+0x410>
c0103694:	c7 44 24 0c 4a 79 10 	movl   $0xc010794a,0xc(%esp)
c010369b:	c0 
c010369c:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01036a3:	c0 
c01036a4:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01036ab:	00 
c01036ac:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01036b3:	e8 18 d6 ff ff       	call   c0100cd0 <__panic>
	free_pages(p4, 2);
c01036b8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01036bf:	00 
c01036c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01036c3:	89 04 24             	mov    %eax,(%esp)
c01036c6:	e8 53 17 00 00       	call   c0104e1e <free_pages>
	assert((*(p4 + 1)).ref == 0);
c01036cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01036ce:	83 c0 14             	add    $0x14,%eax
c01036d1:	8b 00                	mov    (%eax),%eax
c01036d3:	85 c0                	test   %eax,%eax
c01036d5:	74 24                	je     c01036fb <buddy_check+0x453>
c01036d7:	c7 44 24 0c 53 79 10 	movl   $0xc0107953,0xc(%esp)
c01036de:	c0 
c01036df:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01036e6:	c0 
c01036e7:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c01036ee:	00 
c01036ef:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01036f6:	e8 d5 d5 ff ff       	call   c0100cd0 <__panic>

	assert(nr_free_pages() == 16384 /2);
c01036fb:	e8 53 17 00 00       	call   c0104e53 <nr_free_pages>
c0103700:	3d 00 20 00 00       	cmp    $0x2000,%eax
c0103705:	74 24                	je     c010372b <buddy_check+0x483>
c0103707:	c7 44 24 0c 68 79 10 	movl   $0xc0107968,0xc(%esp)
c010370e:	c0 
c010370f:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103716:	c0 
c0103717:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c010371e:	00 
c010371f:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103726:	e8 a5 d5 ff ff       	call   c0100cd0 <__panic>

	free_pages(p3, 2);
c010372b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103732:	00 
c0103733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103736:	89 04 24             	mov    %eax,(%esp)
c0103739:	e8 e0 16 00 00       	call   c0104e1e <free_pages>

	assert(nr_free_pages() == 16384);
c010373e:	e8 10 17 00 00       	call   c0104e53 <nr_free_pages>
c0103743:	3d 00 40 00 00       	cmp    $0x4000,%eax
c0103748:	74 24                	je     c010376e <buddy_check+0x4c6>
c010374a:	c7 44 24 0c 84 79 10 	movl   $0xc0107984,0xc(%esp)
c0103751:	c0 
c0103752:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c0103759:	c0 
c010375a:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103761:	00 
c0103762:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c0103769:	e8 62 d5 ff ff       	call   c0100cd0 <__panic>

	p1 = alloc_pages(33);
c010376e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
c0103775:	e8 6a 16 00 00       	call   c0104de4 <alloc_pages>
c010377a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	free_pages(p1, 64);
c010377d:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
c0103784:	00 
c0103785:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103788:	89 04 24             	mov    %eax,(%esp)
c010378b:	e8 8e 16 00 00       	call   c0104e1e <free_pages>

	assert(nr_free_pages() == 16384);
c0103790:	e8 be 16 00 00       	call   c0104e53 <nr_free_pages>
c0103795:	3d 00 40 00 00       	cmp    $0x4000,%eax
c010379a:	74 24                	je     c01037c0 <buddy_check+0x518>
c010379c:	c7 44 24 0c 84 79 10 	movl   $0xc0107984,0xc(%esp)
c01037a3:	c0 
c01037a4:	c7 44 24 08 96 77 10 	movl   $0xc0107796,0x8(%esp)
c01037ab:	c0 
c01037ac:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01037b3:	00 
c01037b4:	c7 04 24 ab 77 10 c0 	movl   $0xc01077ab,(%esp)
c01037bb:	e8 10 d5 ff ff       	call   c0100cd0 <__panic>
}
c01037c0:	90                   	nop
c01037c1:	89 ec                	mov    %ebp,%esp
c01037c3:	5d                   	pop    %ebp
c01037c4:	c3                   	ret    

c01037c5 <page2ppn>:
page2ppn(struct Page *page) {
c01037c5:	55                   	push   %ebp
c01037c6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01037c8:	8b 15 00 ef 11 c0    	mov    0xc011ef00,%edx
c01037ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01037d1:	29 d0                	sub    %edx,%eax
c01037d3:	c1 f8 02             	sar    $0x2,%eax
c01037d6:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01037dc:	5d                   	pop    %ebp
c01037dd:	c3                   	ret    

c01037de <page2pa>:
page2pa(struct Page *page) {
c01037de:	55                   	push   %ebp
c01037df:	89 e5                	mov    %esp,%ebp
c01037e1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01037e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e7:	89 04 24             	mov    %eax,(%esp)
c01037ea:	e8 d6 ff ff ff       	call   c01037c5 <page2ppn>
c01037ef:	c1 e0 0c             	shl    $0xc,%eax
}
c01037f2:	89 ec                	mov    %ebp,%esp
c01037f4:	5d                   	pop    %ebp
c01037f5:	c3                   	ret    

c01037f6 <page_ref>:
page_ref(struct Page *page) {
c01037f6:	55                   	push   %ebp
c01037f7:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01037f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01037fc:	8b 00                	mov    (%eax),%eax
}
c01037fe:	5d                   	pop    %ebp
c01037ff:	c3                   	ret    

c0103800 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0103800:	55                   	push   %ebp
c0103801:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103803:	8b 45 08             	mov    0x8(%ebp),%eax
c0103806:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103809:	89 10                	mov    %edx,(%eax)
}
c010380b:	90                   	nop
c010380c:	5d                   	pop    %ebp
c010380d:	c3                   	ret    

c010380e <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010380e:	55                   	push   %ebp
c010380f:	89 e5                	mov    %esp,%ebp
c0103811:	83 ec 10             	sub    $0x10,%esp
c0103814:	c7 45 fc f0 ee 11 c0 	movl   $0xc011eef0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010381b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010381e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103821:	89 50 04             	mov    %edx,0x4(%eax)
c0103824:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103827:	8b 50 04             	mov    0x4(%eax),%edx
c010382a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010382d:	89 10                	mov    %edx,(%eax)
}
c010382f:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103830:	c7 05 f8 ee 11 c0 00 	movl   $0x0,0xc011eef8
c0103837:	00 00 00 
}
c010383a:	90                   	nop
c010383b:	89 ec                	mov    %ebp,%esp
c010383d:	5d                   	pop    %ebp
c010383e:	c3                   	ret    

c010383f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010383f:	55                   	push   %ebp
c0103840:	89 e5                	mov    %esp,%ebp
c0103842:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0103845:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103849:	75 24                	jne    c010386f <default_init_memmap+0x30>
c010384b:	c7 44 24 0c cc 79 10 	movl   $0xc01079cc,0xc(%esp)
c0103852:	c0 
c0103853:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010385a:	c0 
c010385b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103862:	00 
c0103863:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010386a:	e8 61 d4 ff ff       	call   c0100cd0 <__panic>
    struct Page *p = base;
c010386f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103872:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103875:	eb 7d                	jmp    c01038f4 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010387a:	83 c0 04             	add    $0x4,%eax
c010387d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103884:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103887:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010388a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010388d:	0f a3 10             	bt     %edx,(%eax)
c0103890:	19 c0                	sbb    %eax,%eax
c0103892:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103895:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103899:	0f 95 c0             	setne  %al
c010389c:	0f b6 c0             	movzbl %al,%eax
c010389f:	85 c0                	test   %eax,%eax
c01038a1:	75 24                	jne    c01038c7 <default_init_memmap+0x88>
c01038a3:	c7 44 24 0c fd 79 10 	movl   $0xc01079fd,0xc(%esp)
c01038aa:	c0 
c01038ab:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01038b2:	c0 
c01038b3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01038ba:	00 
c01038bb:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01038c2:	e8 09 d4 ff ff       	call   c0100cd0 <__panic>
        p->flags = p->property = 0;
c01038c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01038d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d4:	8b 50 08             	mov    0x8(%eax),%edx
c01038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038da:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01038dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01038e4:	00 
c01038e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e8:	89 04 24             	mov    %eax,(%esp)
c01038eb:	e8 10 ff ff ff       	call   c0103800 <set_page_ref>
    for (; p != base + n; p ++) {
c01038f0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01038f4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01038f7:	89 d0                	mov    %edx,%eax
c01038f9:	c1 e0 02             	shl    $0x2,%eax
c01038fc:	01 d0                	add    %edx,%eax
c01038fe:	c1 e0 02             	shl    $0x2,%eax
c0103901:	89 c2                	mov    %eax,%edx
c0103903:	8b 45 08             	mov    0x8(%ebp),%eax
c0103906:	01 d0                	add    %edx,%eax
c0103908:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010390b:	0f 85 66 ff ff ff    	jne    c0103877 <default_init_memmap+0x38>
    }
    base->property = n;
c0103911:	8b 45 08             	mov    0x8(%ebp),%eax
c0103914:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103917:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010391a:	8b 45 08             	mov    0x8(%ebp),%eax
c010391d:	83 c0 04             	add    $0x4,%eax
c0103920:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103927:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010392a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010392d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103930:	0f ab 10             	bts    %edx,(%eax)
}
c0103933:	90                   	nop
    nr_free += n;
c0103934:	8b 15 f8 ee 11 c0    	mov    0xc011eef8,%edx
c010393a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010393d:	01 d0                	add    %edx,%eax
c010393f:	a3 f8 ee 11 c0       	mov    %eax,0xc011eef8
    list_add(&free_list, &(base->page_link));
c0103944:	8b 45 08             	mov    0x8(%ebp),%eax
c0103947:	83 c0 0c             	add    $0xc,%eax
c010394a:	c7 45 e4 f0 ee 11 c0 	movl   $0xc011eef0,-0x1c(%ebp)
c0103951:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103957:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010395a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010395d:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103960:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103963:	8b 40 04             	mov    0x4(%eax),%eax
c0103966:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103969:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010396c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010396f:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103972:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103975:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103978:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010397b:	89 10                	mov    %edx,(%eax)
c010397d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103980:	8b 10                	mov    (%eax),%edx
c0103982:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103985:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103988:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010398b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010398e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103991:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103994:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103997:	89 10                	mov    %edx,(%eax)
}
c0103999:	90                   	nop
}
c010399a:	90                   	nop
}
c010399b:	90                   	nop
}
c010399c:	90                   	nop
c010399d:	89 ec                	mov    %ebp,%esp
c010399f:	5d                   	pop    %ebp
c01039a0:	c3                   	ret    

c01039a1 <default_alloc_pages>:

/* along: in FFMA algorithm, the pages should be sorted by address.
 * And the original code just insert the page after allocation 
 * at the beginning of the free_list, so we need to correct it. */
static struct Page *
default_alloc_pages(size_t n) {
c01039a1:	55                   	push   %ebp
c01039a2:	89 e5                	mov    %esp,%ebp
c01039a4:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01039a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01039ab:	75 24                	jne    c01039d1 <default_alloc_pages+0x30>
c01039ad:	c7 44 24 0c cc 79 10 	movl   $0xc01079cc,0xc(%esp)
c01039b4:	c0 
c01039b5:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01039bc:	c0 
c01039bd:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c01039c4:	00 
c01039c5:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01039cc:	e8 ff d2 ff ff       	call   c0100cd0 <__panic>
    if (n > nr_free) {
c01039d1:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c01039d6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01039d9:	76 0a                	jbe    c01039e5 <default_alloc_pages+0x44>
        return NULL;
c01039db:	b8 00 00 00 00       	mov    $0x0,%eax
c01039e0:	e9 50 01 00 00       	jmp    c0103b35 <default_alloc_pages+0x194>
    }
    struct Page *page = NULL;
c01039e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01039ec:	c7 45 f0 f0 ee 11 c0 	movl   $0xc011eef0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01039f3:	eb 1c                	jmp    c0103a11 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01039f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039f8:	83 e8 0c             	sub    $0xc,%eax
c01039fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01039fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a01:	8b 40 08             	mov    0x8(%eax),%eax
c0103a04:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103a07:	77 08                	ja     c0103a11 <default_alloc_pages+0x70>
            page = p;
c0103a09:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103a0f:	eb 18                	jmp    c0103a29 <default_alloc_pages+0x88>
c0103a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0103a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a1a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a20:	81 7d f0 f0 ee 11 c0 	cmpl   $0xc011eef0,-0x10(%ebp)
c0103a27:	75 cc                	jne    c01039f5 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0103a29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a2d:	0f 84 ff 00 00 00    	je     c0103b32 <default_alloc_pages+0x191>
    	/*
        list_del(&(page->page_link));
        */
        if (page->property > n) {
c0103a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a36:	8b 40 08             	mov    0x8(%eax),%eax
c0103a39:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103a3c:	0f 83 9c 00 00 00    	jae    c0103ade <default_alloc_pages+0x13d>
            struct Page *p = page + n;
c0103a42:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a45:	89 d0                	mov    %edx,%eax
c0103a47:	c1 e0 02             	shl    $0x2,%eax
c0103a4a:	01 d0                	add    %edx,%eax
c0103a4c:	c1 e0 02             	shl    $0x2,%eax
c0103a4f:	89 c2                	mov    %eax,%edx
c0103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a54:	01 d0                	add    %edx,%eax
c0103a56:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a5c:	8b 40 08             	mov    0x8(%eax),%eax
c0103a5f:	2b 45 08             	sub    0x8(%ebp),%eax
c0103a62:	89 c2                	mov    %eax,%edx
c0103a64:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a67:	89 50 08             	mov    %edx,0x8(%eax)
            // my code
            SetPageProperty(p);
c0103a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a6d:	83 c0 04             	add    $0x4,%eax
c0103a70:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103a77:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a7a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103a7d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103a80:	0f ab 10             	bts    %edx,(%eax)
}
c0103a83:	90                   	nop
            list_add(&(page->page_link), &(p->page_link));
c0103a84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a87:	83 c0 0c             	add    $0xc,%eax
c0103a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a8d:	83 c2 0c             	add    $0xc,%edx
c0103a90:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0103a93:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a96:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a99:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103aa2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103aa5:	8b 40 04             	mov    0x4(%eax),%eax
c0103aa8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103aab:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103aae:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103ab1:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103ab4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0103ab7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103aba:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103abd:	89 10                	mov    %edx,(%eax)
c0103abf:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103ac2:	8b 10                	mov    (%eax),%edx
c0103ac4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103ac7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103aca:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103acd:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103ad0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103ad3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103ad6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103ad9:	89 10                	mov    %edx,(%eax)
}
c0103adb:	90                   	nop
}
c0103adc:	90                   	nop
}
c0103add:	90                   	nop
            /*
            list_add(&free_list, &(p->page_link));
            */
        }
        // my code
        list_del(&(page->page_link));
c0103ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae1:	83 c0 0c             	add    $0xc,%eax
c0103ae4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103ae7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103aea:	8b 40 04             	mov    0x4(%eax),%eax
c0103aed:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103af0:	8b 12                	mov    (%edx),%edx
c0103af2:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0103af5:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103af8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103afb:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103afe:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b01:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b04:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103b07:	89 10                	mov    %edx,(%eax)
}
c0103b09:	90                   	nop
}
c0103b0a:	90                   	nop
        // -----
        nr_free -= n;
c0103b0b:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c0103b10:	2b 45 08             	sub    0x8(%ebp),%eax
c0103b13:	a3 f8 ee 11 c0       	mov    %eax,0xc011eef8
        ClearPageProperty(page);
c0103b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b1b:	83 c0 04             	add    $0x4,%eax
c0103b1e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0103b25:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103b28:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103b2b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103b2e:	0f b3 10             	btr    %edx,(%eax)
}
c0103b31:	90                   	nop
    }
    return page;
c0103b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103b35:	89 ec                	mov    %ebp,%esp
c0103b37:	5d                   	pop    %ebp
c0103b38:	c3                   	ret    

c0103b39 <default_free_pages>:

/* along: in FFMA algorithm, the pages should be sorted by address.
 * And the original code just insert the page to be freed 
 * at the beginning of the free_list, so we need to correct it. */
static void
default_free_pages(struct Page *base, size_t n) {
c0103b39:	55                   	push   %ebp
c0103b3a:	89 e5                	mov    %esp,%ebp
c0103b3c:	81 ec b8 00 00 00    	sub    $0xb8,%esp
    assert(n > 0);
c0103b42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103b46:	75 24                	jne    c0103b6c <default_free_pages+0x33>
c0103b48:	c7 44 24 0c cc 79 10 	movl   $0xc01079cc,0xc(%esp)
c0103b4f:	c0 
c0103b50:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103b57:	c0 
c0103b58:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0103b5f:	00 
c0103b60:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0103b67:	e8 64 d1 ff ff       	call   c0100cd0 <__panic>
    struct Page *p = base;
c0103b6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page *pp = base; // 前一页 my code
c0103b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (; p != base + n; p ++) {
c0103b78:	e9 9d 00 00 00       	jmp    c0103c1a <default_free_pages+0xe1>
        assert(!PageReserved(p) && !PageProperty(p));
c0103b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b80:	83 c0 04             	add    $0x4,%eax
c0103b83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0103b8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b90:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0103b93:	0f a3 10             	bt     %edx,(%eax)
c0103b96:	19 c0                	sbb    %eax,%eax
c0103b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0103b9b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103b9f:	0f 95 c0             	setne  %al
c0103ba2:	0f b6 c0             	movzbl %al,%eax
c0103ba5:	85 c0                	test   %eax,%eax
c0103ba7:	75 2c                	jne    c0103bd5 <default_free_pages+0x9c>
c0103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bac:	83 c0 04             	add    $0x4,%eax
c0103baf:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0103bb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103bb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103bbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103bbf:	0f a3 10             	bt     %edx,(%eax)
c0103bc2:	19 c0                	sbb    %eax,%eax
c0103bc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0103bc7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0103bcb:	0f 95 c0             	setne  %al
c0103bce:	0f b6 c0             	movzbl %al,%eax
c0103bd1:	85 c0                	test   %eax,%eax
c0103bd3:	74 24                	je     c0103bf9 <default_free_pages+0xc0>
c0103bd5:	c7 44 24 0c 10 7a 10 	movl   $0xc0107a10,0xc(%esp)
c0103bdc:	c0 
c0103bdd:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103be4:	c0 
c0103be5:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0103bec:	00 
c0103bed:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0103bf4:	e8 d7 d0 ff ff       	call   c0100cd0 <__panic>
        p->flags = 0;
c0103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bfc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103c03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103c0a:	00 
c0103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c0e:	89 04 24             	mov    %eax,(%esp)
c0103c11:	e8 ea fb ff ff       	call   c0103800 <set_page_ref>
    for (; p != base + n; p ++) {
c0103c16:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0103c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c1d:	89 d0                	mov    %edx,%eax
c0103c1f:	c1 e0 02             	shl    $0x2,%eax
c0103c22:	01 d0                	add    %edx,%eax
c0103c24:	c1 e0 02             	shl    $0x2,%eax
c0103c27:	89 c2                	mov    %eax,%edx
c0103c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c2c:	01 d0                	add    %edx,%eax
c0103c2e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103c31:	0f 85 46 ff ff ff    	jne    c0103b7d <default_free_pages+0x44>
    }
    p = base; // my code
c0103c37:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    base->property = n;
c0103c3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c40:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c43:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c49:	83 c0 04             	add    $0x4,%eax
c0103c4c:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0103c53:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103c56:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103c59:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103c5c:	0f ab 10             	bts    %edx,(%eax)
}
c0103c5f:	90                   	nop
c0103c60:	c7 45 d0 f0 ee 11 c0 	movl   $0xc011eef0,-0x30(%ebp)
    return listelm->next;
c0103c67:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103c6a:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0103c6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    // my code
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
c0103c70:	eb 15                	jmp    c0103c87 <default_free_pages+0x14e>
        pp = p;
c0103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c7b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0103c7e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103c81:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103c84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
c0103c87:	81 7d ec f0 ee 11 c0 	cmpl   $0xc011eef0,-0x14(%ebp)
c0103c8e:	74 11                	je     c0103ca1 <default_free_pages+0x168>
c0103c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c93:	83 e8 0c             	sub    $0xc,%eax
c0103c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c9c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103c9f:	72 d1                	jb     c0103c72 <default_free_pages+0x139>
    }

    if ((base + base->property == p) && (pp + pp->property == base)) {
c0103ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ca4:	8b 50 08             	mov    0x8(%eax),%edx
c0103ca7:	89 d0                	mov    %edx,%eax
c0103ca9:	c1 e0 02             	shl    $0x2,%eax
c0103cac:	01 d0                	add    %edx,%eax
c0103cae:	c1 e0 02             	shl    $0x2,%eax
c0103cb1:	89 c2                	mov    %eax,%edx
c0103cb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb6:	01 d0                	add    %edx,%eax
c0103cb8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103cbb:	0f 85 9b 00 00 00    	jne    c0103d5c <default_free_pages+0x223>
c0103cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cc4:	8b 50 08             	mov    0x8(%eax),%edx
c0103cc7:	89 d0                	mov    %edx,%eax
c0103cc9:	c1 e0 02             	shl    $0x2,%eax
c0103ccc:	01 d0                	add    %edx,%eax
c0103cce:	c1 e0 02             	shl    $0x2,%eax
c0103cd1:	89 c2                	mov    %eax,%edx
c0103cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cd6:	01 d0                	add    %edx,%eax
c0103cd8:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103cdb:	75 7f                	jne    c0103d5c <default_free_pages+0x223>
        pp->property += (base->property + p->property);
c0103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ce0:	8b 50 08             	mov    0x8(%eax),%edx
c0103ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ce6:	8b 48 08             	mov    0x8(%eax),%ecx
c0103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cec:	8b 40 08             	mov    0x8(%eax),%eax
c0103cef:	01 c8                	add    %ecx,%eax
c0103cf1:	01 c2                	add    %eax,%edx
c0103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cf6:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
c0103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cfc:	83 c0 04             	add    $0x4,%eax
c0103cff:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103d06:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103d09:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103d0c:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103d0f:	0f b3 10             	btr    %edx,(%eax)
}
c0103d12:	90                   	nop
        ClearPageProperty(p);
c0103d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d16:	83 c0 04             	add    $0x4,%eax
c0103d19:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0103d20:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103d23:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103d26:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103d29:	0f b3 10             	btr    %edx,(%eax)
}
c0103d2c:	90                   	nop
c0103d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d30:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103d33:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103d36:	8b 40 04             	mov    0x4(%eax),%eax
c0103d39:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103d3c:	8b 12                	mov    (%edx),%edx
c0103d3e:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103d41:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c0103d44:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103d47:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103d4a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103d4d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103d50:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103d53:	89 10                	mov    %edx,(%eax)
}
c0103d55:	90                   	nop
}
c0103d56:	90                   	nop
        list_del(le);
c0103d57:	e9 95 01 00 00       	jmp    c0103ef1 <default_free_pages+0x3b8>
    }
    else if (base + base->property == p) {
c0103d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d5f:	8b 50 08             	mov    0x8(%eax),%edx
c0103d62:	89 d0                	mov    %edx,%eax
c0103d64:	c1 e0 02             	shl    $0x2,%eax
c0103d67:	01 d0                	add    %edx,%eax
c0103d69:	c1 e0 02             	shl    $0x2,%eax
c0103d6c:	89 c2                	mov    %eax,%edx
c0103d6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d71:	01 d0                	add    %edx,%eax
c0103d73:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103d76:	0f 85 a5 00 00 00    	jne    c0103e21 <default_free_pages+0x2e8>
        base->property += p->property;
c0103d7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d7f:	8b 50 08             	mov    0x8(%eax),%edx
c0103d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d85:	8b 40 08             	mov    0x8(%eax),%eax
c0103d88:	01 c2                	add    %eax,%edx
c0103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d8d:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(p);
c0103d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d93:	83 c0 04             	add    $0x4,%eax
c0103d96:	c7 45 84 01 00 00 00 	movl   $0x1,-0x7c(%ebp)
c0103d9d:	89 45 80             	mov    %eax,-0x80(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103da0:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103da3:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103da6:	0f b3 10             	btr    %edx,(%eax)
}
c0103da9:	90                   	nop
        list_add_before(le, &(base->page_link));
c0103daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dad:	8d 50 0c             	lea    0xc(%eax),%edx
c0103db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103db3:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103db6:	89 55 94             	mov    %edx,-0x6c(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0103db9:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103dbc:	8b 00                	mov    (%eax),%eax
c0103dbe:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103dc1:	89 55 90             	mov    %edx,-0x70(%ebp)
c0103dc4:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0103dc7:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103dca:	89 45 88             	mov    %eax,-0x78(%ebp)
    prev->next = next->prev = elm;
c0103dcd:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103dd0:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103dd3:	89 10                	mov    %edx,(%eax)
c0103dd5:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103dd8:	8b 10                	mov    (%eax),%edx
c0103dda:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103ddd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103de0:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103de3:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103de6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103de9:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103dec:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103def:	89 10                	mov    %edx,(%eax)
}
c0103df1:	90                   	nop
}
c0103df2:	90                   	nop
c0103df3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103df6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103df9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103dfc:	8b 40 04             	mov    0x4(%eax),%eax
c0103dff:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103e02:	8b 12                	mov    (%edx),%edx
c0103e04:	89 55 a0             	mov    %edx,-0x60(%ebp)
c0103e07:	89 45 9c             	mov    %eax,-0x64(%ebp)
    prev->next = next;
c0103e0a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103e0d:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103e10:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103e13:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103e16:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103e19:	89 10                	mov    %edx,(%eax)
}
c0103e1b:	90                   	nop
}
c0103e1c:	e9 d0 00 00 00       	jmp    c0103ef1 <default_free_pages+0x3b8>
        list_del(le);
    }
    else if (pp + pp->property == base) {
c0103e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e24:	8b 50 08             	mov    0x8(%eax),%edx
c0103e27:	89 d0                	mov    %edx,%eax
c0103e29:	c1 e0 02             	shl    $0x2,%eax
c0103e2c:	01 d0                	add    %edx,%eax
c0103e2e:	c1 e0 02             	shl    $0x2,%eax
c0103e31:	89 c2                	mov    %eax,%edx
c0103e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e36:	01 d0                	add    %edx,%eax
c0103e38:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103e3b:	75 3b                	jne    c0103e78 <default_free_pages+0x33f>
        pp->property += base->property;
c0103e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e40:	8b 50 08             	mov    0x8(%eax),%edx
c0103e43:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e46:	8b 40 08             	mov    0x8(%eax),%eax
c0103e49:	01 c2                	add    %eax,%edx
c0103e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e4e:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
c0103e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e54:	83 c0 04             	add    $0x4,%eax
c0103e57:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
c0103e5e:	00 00 00 
c0103e61:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103e67:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103e6d:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103e73:	0f b3 10             	btr    %edx,(%eax)
}
c0103e76:	eb 79                	jmp    c0103ef1 <default_free_pages+0x3b8>
    }
    else {
        list_add_before(le, &(base->page_link));
c0103e78:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e7b:	8d 50 0c             	lea    0xc(%eax),%edx
c0103e7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e81:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
c0103e87:	89 95 70 ff ff ff    	mov    %edx,-0x90(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0103e8d:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
c0103e93:	8b 00                	mov    (%eax),%eax
c0103e95:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
c0103e9b:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
c0103ea1:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
c0103ea7:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
c0103ead:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
    prev->next = next->prev = elm;
c0103eb3:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0103eb9:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
c0103ebf:	89 10                	mov    %edx,(%eax)
c0103ec1:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0103ec7:	8b 10                	mov    (%eax),%edx
c0103ec9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
c0103ecf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103ed2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0103ed8:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
c0103ede:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103ee1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0103ee7:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
c0103eed:	89 10                	mov    %edx,(%eax)
}
c0103eef:	90                   	nop
}
c0103ef0:	90                   	nop
    }

    nr_free += n;
c0103ef1:	8b 15 f8 ee 11 c0    	mov    0xc011eef8,%edx
c0103ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103efa:	01 d0                	add    %edx,%eax
c0103efc:	a3 f8 ee 11 c0       	mov    %eax,0xc011eef8
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
c0103f01:	90                   	nop
c0103f02:	89 ec                	mov    %ebp,%esp
c0103f04:	5d                   	pop    %ebp
c0103f05:	c3                   	ret    

c0103f06 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103f06:	55                   	push   %ebp
c0103f07:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103f09:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
}
c0103f0e:	5d                   	pop    %ebp
c0103f0f:	c3                   	ret    

c0103f10 <basic_check>:

static void
basic_check(void) {
c0103f10:	55                   	push   %ebp
c0103f11:	89 e5                	mov    %esp,%ebp
c0103f13:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103f29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f30:	e8 af 0e 00 00       	call   c0104de4 <alloc_pages>
c0103f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f3c:	75 24                	jne    c0103f62 <basic_check+0x52>
c0103f3e:	c7 44 24 0c 35 7a 10 	movl   $0xc0107a35,0xc(%esp)
c0103f45:	c0 
c0103f46:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103f4d:	c0 
c0103f4e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103f55:	00 
c0103f56:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0103f5d:	e8 6e cd ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103f62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f69:	e8 76 0e 00 00       	call   c0104de4 <alloc_pages>
c0103f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103f75:	75 24                	jne    c0103f9b <basic_check+0x8b>
c0103f77:	c7 44 24 0c 51 7a 10 	movl   $0xc0107a51,0xc(%esp)
c0103f7e:	c0 
c0103f7f:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103f86:	c0 
c0103f87:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103f8e:	00 
c0103f8f:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0103f96:	e8 35 cd ff ff       	call   c0100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103f9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fa2:	e8 3d 0e 00 00       	call   c0104de4 <alloc_pages>
c0103fa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103faa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103fae:	75 24                	jne    c0103fd4 <basic_check+0xc4>
c0103fb0:	c7 44 24 0c 6d 7a 10 	movl   $0xc0107a6d,0xc(%esp)
c0103fb7:	c0 
c0103fb8:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103fbf:	c0 
c0103fc0:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103fc7:	00 
c0103fc8:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0103fcf:	e8 fc cc ff ff       	call   c0100cd0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fd7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103fda:	74 10                	je     c0103fec <basic_check+0xdc>
c0103fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fdf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103fe2:	74 08                	je     c0103fec <basic_check+0xdc>
c0103fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fe7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103fea:	75 24                	jne    c0104010 <basic_check+0x100>
c0103fec:	c7 44 24 0c 8c 7a 10 	movl   $0xc0107a8c,0xc(%esp)
c0103ff3:	c0 
c0103ff4:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0103ffb:	c0 
c0103ffc:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104003:	00 
c0104004:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010400b:	e8 c0 cc ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104010:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104013:	89 04 24             	mov    %eax,(%esp)
c0104016:	e8 db f7 ff ff       	call   c01037f6 <page_ref>
c010401b:	85 c0                	test   %eax,%eax
c010401d:	75 1e                	jne    c010403d <basic_check+0x12d>
c010401f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104022:	89 04 24             	mov    %eax,(%esp)
c0104025:	e8 cc f7 ff ff       	call   c01037f6 <page_ref>
c010402a:	85 c0                	test   %eax,%eax
c010402c:	75 0f                	jne    c010403d <basic_check+0x12d>
c010402e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104031:	89 04 24             	mov    %eax,(%esp)
c0104034:	e8 bd f7 ff ff       	call   c01037f6 <page_ref>
c0104039:	85 c0                	test   %eax,%eax
c010403b:	74 24                	je     c0104061 <basic_check+0x151>
c010403d:	c7 44 24 0c b0 7a 10 	movl   $0xc0107ab0,0xc(%esp)
c0104044:	c0 
c0104045:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010404c:	c0 
c010404d:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0104054:	00 
c0104055:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010405c:	e8 6f cc ff ff       	call   c0100cd0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104061:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104064:	89 04 24             	mov    %eax,(%esp)
c0104067:	e8 72 f7 ff ff       	call   c01037de <page2pa>
c010406c:	8b 15 04 ef 11 c0    	mov    0xc011ef04,%edx
c0104072:	c1 e2 0c             	shl    $0xc,%edx
c0104075:	39 d0                	cmp    %edx,%eax
c0104077:	72 24                	jb     c010409d <basic_check+0x18d>
c0104079:	c7 44 24 0c ec 7a 10 	movl   $0xc0107aec,0xc(%esp)
c0104080:	c0 
c0104081:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104088:	c0 
c0104089:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0104090:	00 
c0104091:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104098:	e8 33 cc ff ff       	call   c0100cd0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010409d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040a0:	89 04 24             	mov    %eax,(%esp)
c01040a3:	e8 36 f7 ff ff       	call   c01037de <page2pa>
c01040a8:	8b 15 04 ef 11 c0    	mov    0xc011ef04,%edx
c01040ae:	c1 e2 0c             	shl    $0xc,%edx
c01040b1:	39 d0                	cmp    %edx,%eax
c01040b3:	72 24                	jb     c01040d9 <basic_check+0x1c9>
c01040b5:	c7 44 24 0c 09 7b 10 	movl   $0xc0107b09,0xc(%esp)
c01040bc:	c0 
c01040bd:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01040c4:	c0 
c01040c5:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01040cc:	00 
c01040cd:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01040d4:	e8 f7 cb ff ff       	call   c0100cd0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040dc:	89 04 24             	mov    %eax,(%esp)
c01040df:	e8 fa f6 ff ff       	call   c01037de <page2pa>
c01040e4:	8b 15 04 ef 11 c0    	mov    0xc011ef04,%edx
c01040ea:	c1 e2 0c             	shl    $0xc,%edx
c01040ed:	39 d0                	cmp    %edx,%eax
c01040ef:	72 24                	jb     c0104115 <basic_check+0x205>
c01040f1:	c7 44 24 0c 26 7b 10 	movl   $0xc0107b26,0xc(%esp)
c01040f8:	c0 
c01040f9:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104100:	c0 
c0104101:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0104108:	00 
c0104109:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104110:	e8 bb cb ff ff       	call   c0100cd0 <__panic>

    list_entry_t free_list_store = free_list;
c0104115:	a1 f0 ee 11 c0       	mov    0xc011eef0,%eax
c010411a:	8b 15 f4 ee 11 c0    	mov    0xc011eef4,%edx
c0104120:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104123:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104126:	c7 45 dc f0 ee 11 c0 	movl   $0xc011eef0,-0x24(%ebp)
    elm->prev = elm->next = elm;
c010412d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104130:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104133:	89 50 04             	mov    %edx,0x4(%eax)
c0104136:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104139:	8b 50 04             	mov    0x4(%eax),%edx
c010413c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010413f:	89 10                	mov    %edx,(%eax)
}
c0104141:	90                   	nop
c0104142:	c7 45 e0 f0 ee 11 c0 	movl   $0xc011eef0,-0x20(%ebp)
    return list->next == list;
c0104149:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010414c:	8b 40 04             	mov    0x4(%eax),%eax
c010414f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104152:	0f 94 c0             	sete   %al
c0104155:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104158:	85 c0                	test   %eax,%eax
c010415a:	75 24                	jne    c0104180 <basic_check+0x270>
c010415c:	c7 44 24 0c 43 7b 10 	movl   $0xc0107b43,0xc(%esp)
c0104163:	c0 
c0104164:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010416b:	c0 
c010416c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104173:	00 
c0104174:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010417b:	e8 50 cb ff ff       	call   c0100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
c0104180:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c0104185:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104188:	c7 05 f8 ee 11 c0 00 	movl   $0x0,0xc011eef8
c010418f:	00 00 00 

    assert(alloc_page() == NULL);
c0104192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104199:	e8 46 0c 00 00       	call   c0104de4 <alloc_pages>
c010419e:	85 c0                	test   %eax,%eax
c01041a0:	74 24                	je     c01041c6 <basic_check+0x2b6>
c01041a2:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c01041a9:	c0 
c01041aa:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01041b1:	c0 
c01041b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01041b9:	00 
c01041ba:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01041c1:	e8 0a cb ff ff       	call   c0100cd0 <__panic>

    free_page(p0);
c01041c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041cd:	00 
c01041ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041d1:	89 04 24             	mov    %eax,(%esp)
c01041d4:	e8 45 0c 00 00       	call   c0104e1e <free_pages>
    free_page(p1);
c01041d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041e0:	00 
c01041e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041e4:	89 04 24             	mov    %eax,(%esp)
c01041e7:	e8 32 0c 00 00       	call   c0104e1e <free_pages>
    free_page(p2);
c01041ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041f3:	00 
c01041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041f7:	89 04 24             	mov    %eax,(%esp)
c01041fa:	e8 1f 0c 00 00       	call   c0104e1e <free_pages>
    assert(nr_free == 3);
c01041ff:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c0104204:	83 f8 03             	cmp    $0x3,%eax
c0104207:	74 24                	je     c010422d <basic_check+0x31d>
c0104209:	c7 44 24 0c 6f 7b 10 	movl   $0xc0107b6f,0xc(%esp)
c0104210:	c0 
c0104211:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104218:	c0 
c0104219:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104220:	00 
c0104221:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104228:	e8 a3 ca ff ff       	call   c0100cd0 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010422d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104234:	e8 ab 0b 00 00       	call   c0104de4 <alloc_pages>
c0104239:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010423c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104240:	75 24                	jne    c0104266 <basic_check+0x356>
c0104242:	c7 44 24 0c 35 7a 10 	movl   $0xc0107a35,0xc(%esp)
c0104249:	c0 
c010424a:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104251:	c0 
c0104252:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104259:	00 
c010425a:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104261:	e8 6a ca ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104266:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010426d:	e8 72 0b 00 00       	call   c0104de4 <alloc_pages>
c0104272:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104279:	75 24                	jne    c010429f <basic_check+0x38f>
c010427b:	c7 44 24 0c 51 7a 10 	movl   $0xc0107a51,0xc(%esp)
c0104282:	c0 
c0104283:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010428a:	c0 
c010428b:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104292:	00 
c0104293:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010429a:	e8 31 ca ff ff       	call   c0100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010429f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042a6:	e8 39 0b 00 00       	call   c0104de4 <alloc_pages>
c01042ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01042ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042b2:	75 24                	jne    c01042d8 <basic_check+0x3c8>
c01042b4:	c7 44 24 0c 6d 7a 10 	movl   $0xc0107a6d,0xc(%esp)
c01042bb:	c0 
c01042bc:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01042c3:	c0 
c01042c4:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01042cb:	00 
c01042cc:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01042d3:	e8 f8 c9 ff ff       	call   c0100cd0 <__panic>

    assert(alloc_page() == NULL);
c01042d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042df:	e8 00 0b 00 00       	call   c0104de4 <alloc_pages>
c01042e4:	85 c0                	test   %eax,%eax
c01042e6:	74 24                	je     c010430c <basic_check+0x3fc>
c01042e8:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c01042ef:	c0 
c01042f0:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01042f7:	c0 
c01042f8:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01042ff:	00 
c0104300:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104307:	e8 c4 c9 ff ff       	call   c0100cd0 <__panic>

    free_page(p0);
c010430c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104313:	00 
c0104314:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104317:	89 04 24             	mov    %eax,(%esp)
c010431a:	e8 ff 0a 00 00       	call   c0104e1e <free_pages>
c010431f:	c7 45 d8 f0 ee 11 c0 	movl   $0xc011eef0,-0x28(%ebp)
c0104326:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104329:	8b 40 04             	mov    0x4(%eax),%eax
c010432c:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010432f:	0f 94 c0             	sete   %al
c0104332:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104335:	85 c0                	test   %eax,%eax
c0104337:	74 24                	je     c010435d <basic_check+0x44d>
c0104339:	c7 44 24 0c 7c 7b 10 	movl   $0xc0107b7c,0xc(%esp)
c0104340:	c0 
c0104341:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104348:	c0 
c0104349:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104350:	00 
c0104351:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104358:	e8 73 c9 ff ff       	call   c0100cd0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010435d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104364:	e8 7b 0a 00 00       	call   c0104de4 <alloc_pages>
c0104369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010436c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010436f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104372:	74 24                	je     c0104398 <basic_check+0x488>
c0104374:	c7 44 24 0c 94 7b 10 	movl   $0xc0107b94,0xc(%esp)
c010437b:	c0 
c010437c:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104383:	c0 
c0104384:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c010438b:	00 
c010438c:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104393:	e8 38 c9 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c0104398:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010439f:	e8 40 0a 00 00       	call   c0104de4 <alloc_pages>
c01043a4:	85 c0                	test   %eax,%eax
c01043a6:	74 24                	je     c01043cc <basic_check+0x4bc>
c01043a8:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c01043af:	c0 
c01043b0:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01043b7:	c0 
c01043b8:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c01043bf:	00 
c01043c0:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01043c7:	e8 04 c9 ff ff       	call   c0100cd0 <__panic>

    assert(nr_free == 0);
c01043cc:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c01043d1:	85 c0                	test   %eax,%eax
c01043d3:	74 24                	je     c01043f9 <basic_check+0x4e9>
c01043d5:	c7 44 24 0c ad 7b 10 	movl   $0xc0107bad,0xc(%esp)
c01043dc:	c0 
c01043dd:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01043e4:	c0 
c01043e5:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01043ec:	00 
c01043ed:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01043f4:	e8 d7 c8 ff ff       	call   c0100cd0 <__panic>
    free_list = free_list_store;
c01043f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043ff:	a3 f0 ee 11 c0       	mov    %eax,0xc011eef0
c0104404:	89 15 f4 ee 11 c0    	mov    %edx,0xc011eef4
    nr_free = nr_free_store;
c010440a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010440d:	a3 f8 ee 11 c0       	mov    %eax,0xc011eef8

    free_page(p);
c0104412:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104419:	00 
c010441a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010441d:	89 04 24             	mov    %eax,(%esp)
c0104420:	e8 f9 09 00 00       	call   c0104e1e <free_pages>
    free_page(p1);
c0104425:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010442c:	00 
c010442d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104430:	89 04 24             	mov    %eax,(%esp)
c0104433:	e8 e6 09 00 00       	call   c0104e1e <free_pages>
    free_page(p2);
c0104438:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010443f:	00 
c0104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104443:	89 04 24             	mov    %eax,(%esp)
c0104446:	e8 d3 09 00 00       	call   c0104e1e <free_pages>
}
c010444b:	90                   	nop
c010444c:	89 ec                	mov    %ebp,%esp
c010444e:	5d                   	pop    %ebp
c010444f:	c3                   	ret    

c0104450 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104450:	55                   	push   %ebp
c0104451:	89 e5                	mov    %esp,%ebp
c0104453:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104459:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104460:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104467:	c7 45 ec f0 ee 11 c0 	movl   $0xc011eef0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010446e:	eb 6a                	jmp    c01044da <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104470:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104473:	83 e8 0c             	sub    $0xc,%eax
c0104476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010447c:	83 c0 04             	add    $0x4,%eax
c010447f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104486:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104489:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010448c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010448f:	0f a3 10             	bt     %edx,(%eax)
c0104492:	19 c0                	sbb    %eax,%eax
c0104494:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104497:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010449b:	0f 95 c0             	setne  %al
c010449e:	0f b6 c0             	movzbl %al,%eax
c01044a1:	85 c0                	test   %eax,%eax
c01044a3:	75 24                	jne    c01044c9 <default_check+0x79>
c01044a5:	c7 44 24 0c ba 7b 10 	movl   $0xc0107bba,0xc(%esp)
c01044ac:	c0 
c01044ad:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01044b4:	c0 
c01044b5:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c01044bc:	00 
c01044bd:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01044c4:	e8 07 c8 ff ff       	call   c0100cd0 <__panic>
        count ++, total += p->property;
c01044c9:	ff 45 f4             	incl   -0xc(%ebp)
c01044cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044cf:	8b 50 08             	mov    0x8(%eax),%edx
c01044d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044d5:	01 d0                	add    %edx,%eax
c01044d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044dd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01044e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01044e3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01044e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044e9:	81 7d ec f0 ee 11 c0 	cmpl   $0xc011eef0,-0x14(%ebp)
c01044f0:	0f 85 7a ff ff ff    	jne    c0104470 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c01044f6:	e8 58 09 00 00       	call   c0104e53 <nr_free_pages>
c01044fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01044fe:	39 d0                	cmp    %edx,%eax
c0104500:	74 24                	je     c0104526 <default_check+0xd6>
c0104502:	c7 44 24 0c ca 7b 10 	movl   $0xc0107bca,0xc(%esp)
c0104509:	c0 
c010450a:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104511:	c0 
c0104512:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0104519:	00 
c010451a:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104521:	e8 aa c7 ff ff       	call   c0100cd0 <__panic>

    basic_check();
c0104526:	e8 e5 f9 ff ff       	call   c0103f10 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010452b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104532:	e8 ad 08 00 00       	call   c0104de4 <alloc_pages>
c0104537:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010453a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010453e:	75 24                	jne    c0104564 <default_check+0x114>
c0104540:	c7 44 24 0c e3 7b 10 	movl   $0xc0107be3,0xc(%esp)
c0104547:	c0 
c0104548:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010454f:	c0 
c0104550:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104557:	00 
c0104558:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010455f:	e8 6c c7 ff ff       	call   c0100cd0 <__panic>
    assert(!PageProperty(p0));
c0104564:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104567:	83 c0 04             	add    $0x4,%eax
c010456a:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104571:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104574:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104577:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010457a:	0f a3 10             	bt     %edx,(%eax)
c010457d:	19 c0                	sbb    %eax,%eax
c010457f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104582:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104586:	0f 95 c0             	setne  %al
c0104589:	0f b6 c0             	movzbl %al,%eax
c010458c:	85 c0                	test   %eax,%eax
c010458e:	74 24                	je     c01045b4 <default_check+0x164>
c0104590:	c7 44 24 0c ee 7b 10 	movl   $0xc0107bee,0xc(%esp)
c0104597:	c0 
c0104598:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c01045a7:	00 
c01045a8:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01045af:	e8 1c c7 ff ff       	call   c0100cd0 <__panic>

    list_entry_t free_list_store = free_list;
c01045b4:	a1 f0 ee 11 c0       	mov    0xc011eef0,%eax
c01045b9:	8b 15 f4 ee 11 c0    	mov    0xc011eef4,%edx
c01045bf:	89 45 80             	mov    %eax,-0x80(%ebp)
c01045c2:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01045c5:	c7 45 b0 f0 ee 11 c0 	movl   $0xc011eef0,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01045cc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045cf:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01045d2:	89 50 04             	mov    %edx,0x4(%eax)
c01045d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045d8:	8b 50 04             	mov    0x4(%eax),%edx
c01045db:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01045de:	89 10                	mov    %edx,(%eax)
}
c01045e0:	90                   	nop
c01045e1:	c7 45 b4 f0 ee 11 c0 	movl   $0xc011eef0,-0x4c(%ebp)
    return list->next == list;
c01045e8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01045eb:	8b 40 04             	mov    0x4(%eax),%eax
c01045ee:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01045f1:	0f 94 c0             	sete   %al
c01045f4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01045f7:	85 c0                	test   %eax,%eax
c01045f9:	75 24                	jne    c010461f <default_check+0x1cf>
c01045fb:	c7 44 24 0c 43 7b 10 	movl   $0xc0107b43,0xc(%esp)
c0104602:	c0 
c0104603:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010460a:	c0 
c010460b:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c0104612:	00 
c0104613:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010461a:	e8 b1 c6 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c010461f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104626:	e8 b9 07 00 00       	call   c0104de4 <alloc_pages>
c010462b:	85 c0                	test   %eax,%eax
c010462d:	74 24                	je     c0104653 <default_check+0x203>
c010462f:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c0104636:	c0 
c0104637:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010463e:	c0 
c010463f:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0104646:	00 
c0104647:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010464e:	e8 7d c6 ff ff       	call   c0100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
c0104653:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c0104658:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010465b:	c7 05 f8 ee 11 c0 00 	movl   $0x0,0xc011eef8
c0104662:	00 00 00 

    free_pages(p0 + 2, 3);
c0104665:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104668:	83 c0 28             	add    $0x28,%eax
c010466b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104672:	00 
c0104673:	89 04 24             	mov    %eax,(%esp)
c0104676:	e8 a3 07 00 00       	call   c0104e1e <free_pages>
    assert(alloc_pages(4) == NULL);
c010467b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104682:	e8 5d 07 00 00       	call   c0104de4 <alloc_pages>
c0104687:	85 c0                	test   %eax,%eax
c0104689:	74 24                	je     c01046af <default_check+0x25f>
c010468b:	c7 44 24 0c 00 7c 10 	movl   $0xc0107c00,0xc(%esp)
c0104692:	c0 
c0104693:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010469a:	c0 
c010469b:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c01046a2:	00 
c01046a3:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01046aa:	e8 21 c6 ff ff       	call   c0100cd0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01046af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046b2:	83 c0 28             	add    $0x28,%eax
c01046b5:	83 c0 04             	add    $0x4,%eax
c01046b8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01046bf:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01046c2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01046c5:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01046c8:	0f a3 10             	bt     %edx,(%eax)
c01046cb:	19 c0                	sbb    %eax,%eax
c01046cd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01046d0:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01046d4:	0f 95 c0             	setne  %al
c01046d7:	0f b6 c0             	movzbl %al,%eax
c01046da:	85 c0                	test   %eax,%eax
c01046dc:	74 0e                	je     c01046ec <default_check+0x29c>
c01046de:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046e1:	83 c0 28             	add    $0x28,%eax
c01046e4:	8b 40 08             	mov    0x8(%eax),%eax
c01046e7:	83 f8 03             	cmp    $0x3,%eax
c01046ea:	74 24                	je     c0104710 <default_check+0x2c0>
c01046ec:	c7 44 24 0c 18 7c 10 	movl   $0xc0107c18,0xc(%esp)
c01046f3:	c0 
c01046f4:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01046fb:	c0 
c01046fc:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104703:	00 
c0104704:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010470b:	e8 c0 c5 ff ff       	call   c0100cd0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104710:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104717:	e8 c8 06 00 00       	call   c0104de4 <alloc_pages>
c010471c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010471f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104723:	75 24                	jne    c0104749 <default_check+0x2f9>
c0104725:	c7 44 24 0c 44 7c 10 	movl   $0xc0107c44,0xc(%esp)
c010472c:	c0 
c010472d:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104734:	c0 
c0104735:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010473c:	00 
c010473d:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104744:	e8 87 c5 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c0104749:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104750:	e8 8f 06 00 00       	call   c0104de4 <alloc_pages>
c0104755:	85 c0                	test   %eax,%eax
c0104757:	74 24                	je     c010477d <default_check+0x32d>
c0104759:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c0104760:	c0 
c0104761:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104768:	c0 
c0104769:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104770:	00 
c0104771:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104778:	e8 53 c5 ff ff       	call   c0100cd0 <__panic>
    assert(p0 + 2 == p1);
c010477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104780:	83 c0 28             	add    $0x28,%eax
c0104783:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104786:	74 24                	je     c01047ac <default_check+0x35c>
c0104788:	c7 44 24 0c 62 7c 10 	movl   $0xc0107c62,0xc(%esp)
c010478f:	c0 
c0104790:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104797:	c0 
c0104798:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c010479f:	00 
c01047a0:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01047a7:	e8 24 c5 ff ff       	call   c0100cd0 <__panic>

    p2 = p0 + 1;
c01047ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047af:	83 c0 14             	add    $0x14,%eax
c01047b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01047b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01047bc:	00 
c01047bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047c0:	89 04 24             	mov    %eax,(%esp)
c01047c3:	e8 56 06 00 00       	call   c0104e1e <free_pages>
    free_pages(p1, 3);
c01047c8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01047cf:	00 
c01047d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047d3:	89 04 24             	mov    %eax,(%esp)
c01047d6:	e8 43 06 00 00       	call   c0104e1e <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01047db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047de:	83 c0 04             	add    $0x4,%eax
c01047e1:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01047e8:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047eb:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01047ee:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01047f1:	0f a3 10             	bt     %edx,(%eax)
c01047f4:	19 c0                	sbb    %eax,%eax
c01047f6:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01047f9:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01047fd:	0f 95 c0             	setne  %al
c0104800:	0f b6 c0             	movzbl %al,%eax
c0104803:	85 c0                	test   %eax,%eax
c0104805:	74 0b                	je     c0104812 <default_check+0x3c2>
c0104807:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010480a:	8b 40 08             	mov    0x8(%eax),%eax
c010480d:	83 f8 01             	cmp    $0x1,%eax
c0104810:	74 24                	je     c0104836 <default_check+0x3e6>
c0104812:	c7 44 24 0c 70 7c 10 	movl   $0xc0107c70,0xc(%esp)
c0104819:	c0 
c010481a:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104821:	c0 
c0104822:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
c0104829:	00 
c010482a:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104831:	e8 9a c4 ff ff       	call   c0100cd0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104836:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104839:	83 c0 04             	add    $0x4,%eax
c010483c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104843:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104846:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104849:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010484c:	0f a3 10             	bt     %edx,(%eax)
c010484f:	19 c0                	sbb    %eax,%eax
c0104851:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104854:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104858:	0f 95 c0             	setne  %al
c010485b:	0f b6 c0             	movzbl %al,%eax
c010485e:	85 c0                	test   %eax,%eax
c0104860:	74 0b                	je     c010486d <default_check+0x41d>
c0104862:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104865:	8b 40 08             	mov    0x8(%eax),%eax
c0104868:	83 f8 03             	cmp    $0x3,%eax
c010486b:	74 24                	je     c0104891 <default_check+0x441>
c010486d:	c7 44 24 0c 98 7c 10 	movl   $0xc0107c98,0xc(%esp)
c0104874:	c0 
c0104875:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010487c:	c0 
c010487d:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0104884:	00 
c0104885:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010488c:	e8 3f c4 ff ff       	call   c0100cd0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104891:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104898:	e8 47 05 00 00       	call   c0104de4 <alloc_pages>
c010489d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01048a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048a3:	83 e8 14             	sub    $0x14,%eax
c01048a6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01048a9:	74 24                	je     c01048cf <default_check+0x47f>
c01048ab:	c7 44 24 0c be 7c 10 	movl   $0xc0107cbe,0xc(%esp)
c01048b2:	c0 
c01048b3:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01048ba:	c0 
c01048bb:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c01048c2:	00 
c01048c3:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01048ca:	e8 01 c4 ff ff       	call   c0100cd0 <__panic>
    free_page(p0);
c01048cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01048d6:	00 
c01048d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048da:	89 04 24             	mov    %eax,(%esp)
c01048dd:	e8 3c 05 00 00       	call   c0104e1e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01048e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01048e9:	e8 f6 04 00 00       	call   c0104de4 <alloc_pages>
c01048ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01048f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048f4:	83 c0 14             	add    $0x14,%eax
c01048f7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01048fa:	74 24                	je     c0104920 <default_check+0x4d0>
c01048fc:	c7 44 24 0c dc 7c 10 	movl   $0xc0107cdc,0xc(%esp)
c0104903:	c0 
c0104904:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010490b:	c0 
c010490c:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c0104913:	00 
c0104914:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010491b:	e8 b0 c3 ff ff       	call   c0100cd0 <__panic>

    free_pages(p0, 2);
c0104920:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104927:	00 
c0104928:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010492b:	89 04 24             	mov    %eax,(%esp)
c010492e:	e8 eb 04 00 00       	call   c0104e1e <free_pages>
    free_page(p2);
c0104933:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010493a:	00 
c010493b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010493e:	89 04 24             	mov    %eax,(%esp)
c0104941:	e8 d8 04 00 00       	call   c0104e1e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104946:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010494d:	e8 92 04 00 00       	call   c0104de4 <alloc_pages>
c0104952:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104955:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104959:	75 24                	jne    c010497f <default_check+0x52f>
c010495b:	c7 44 24 0c fc 7c 10 	movl   $0xc0107cfc,0xc(%esp)
c0104962:	c0 
c0104963:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010496a:	c0 
c010496b:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0104972:	00 
c0104973:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c010497a:	e8 51 c3 ff ff       	call   c0100cd0 <__panic>
    assert(alloc_page() == NULL);
c010497f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104986:	e8 59 04 00 00       	call   c0104de4 <alloc_pages>
c010498b:	85 c0                	test   %eax,%eax
c010498d:	74 24                	je     c01049b3 <default_check+0x563>
c010498f:	c7 44 24 0c 5a 7b 10 	movl   $0xc0107b5a,0xc(%esp)
c0104996:	c0 
c0104997:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c010499e:	c0 
c010499f:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
c01049a6:	00 
c01049a7:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01049ae:	e8 1d c3 ff ff       	call   c0100cd0 <__panic>

    assert(nr_free == 0);
c01049b3:	a1 f8 ee 11 c0       	mov    0xc011eef8,%eax
c01049b8:	85 c0                	test   %eax,%eax
c01049ba:	74 24                	je     c01049e0 <default_check+0x590>
c01049bc:	c7 44 24 0c ad 7b 10 	movl   $0xc0107bad,0xc(%esp)
c01049c3:	c0 
c01049c4:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c01049cb:	c0 
c01049cc:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c01049d3:	00 
c01049d4:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c01049db:	e8 f0 c2 ff ff       	call   c0100cd0 <__panic>
    nr_free = nr_free_store;
c01049e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049e3:	a3 f8 ee 11 c0       	mov    %eax,0xc011eef8

    free_list = free_list_store;
c01049e8:	8b 45 80             	mov    -0x80(%ebp),%eax
c01049eb:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01049ee:	a3 f0 ee 11 c0       	mov    %eax,0xc011eef0
c01049f3:	89 15 f4 ee 11 c0    	mov    %edx,0xc011eef4
    free_pages(p0, 5);
c01049f9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104a00:	00 
c0104a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a04:	89 04 24             	mov    %eax,(%esp)
c0104a07:	e8 12 04 00 00       	call   c0104e1e <free_pages>

    le = &free_list;
c0104a0c:	c7 45 ec f0 ee 11 c0 	movl   $0xc011eef0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104a13:	eb 1c                	jmp    c0104a31 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
c0104a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a18:	83 e8 0c             	sub    $0xc,%eax
c0104a1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0104a1e:	ff 4d f4             	decl   -0xc(%ebp)
c0104a21:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a24:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104a27:	8b 48 08             	mov    0x8(%eax),%ecx
c0104a2a:	89 d0                	mov    %edx,%eax
c0104a2c:	29 c8                	sub    %ecx,%eax
c0104a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a34:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104a37:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104a3a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104a3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a40:	81 7d ec f0 ee 11 c0 	cmpl   $0xc011eef0,-0x14(%ebp)
c0104a47:	75 cc                	jne    c0104a15 <default_check+0x5c5>
    }
    assert(count == 0);
c0104a49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a4d:	74 24                	je     c0104a73 <default_check+0x623>
c0104a4f:	c7 44 24 0c 1a 7d 10 	movl   $0xc0107d1a,0xc(%esp)
c0104a56:	c0 
c0104a57:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104a5e:	c0 
c0104a5f:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
c0104a66:	00 
c0104a67:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104a6e:	e8 5d c2 ff ff       	call   c0100cd0 <__panic>
    assert(total == 0);
c0104a73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a77:	74 24                	je     c0104a9d <default_check+0x64d>
c0104a79:	c7 44 24 0c 25 7d 10 	movl   $0xc0107d25,0xc(%esp)
c0104a80:	c0 
c0104a81:	c7 44 24 08 d2 79 10 	movl   $0xc01079d2,0x8(%esp)
c0104a88:	c0 
c0104a89:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
c0104a90:	00 
c0104a91:	c7 04 24 e7 79 10 c0 	movl   $0xc01079e7,(%esp)
c0104a98:	e8 33 c2 ff ff       	call   c0100cd0 <__panic>
}
c0104a9d:	90                   	nop
c0104a9e:	89 ec                	mov    %ebp,%esp
c0104aa0:	5d                   	pop    %ebp
c0104aa1:	c3                   	ret    

c0104aa2 <page2ppn>:
page2ppn(struct Page *page) {
c0104aa2:	55                   	push   %ebp
c0104aa3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104aa5:	8b 15 00 ef 11 c0    	mov    0xc011ef00,%edx
c0104aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aae:	29 d0                	sub    %edx,%eax
c0104ab0:	c1 f8 02             	sar    $0x2,%eax
c0104ab3:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104ab9:	5d                   	pop    %ebp
c0104aba:	c3                   	ret    

c0104abb <page2pa>:
page2pa(struct Page *page) {
c0104abb:	55                   	push   %ebp
c0104abc:	89 e5                	mov    %esp,%ebp
c0104abe:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104ac1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ac4:	89 04 24             	mov    %eax,(%esp)
c0104ac7:	e8 d6 ff ff ff       	call   c0104aa2 <page2ppn>
c0104acc:	c1 e0 0c             	shl    $0xc,%eax
}
c0104acf:	89 ec                	mov    %ebp,%esp
c0104ad1:	5d                   	pop    %ebp
c0104ad2:	c3                   	ret    

c0104ad3 <pa2page>:
pa2page(uintptr_t pa) {
c0104ad3:	55                   	push   %ebp
c0104ad4:	89 e5                	mov    %esp,%ebp
c0104ad6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104adc:	c1 e8 0c             	shr    $0xc,%eax
c0104adf:	89 c2                	mov    %eax,%edx
c0104ae1:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0104ae6:	39 c2                	cmp    %eax,%edx
c0104ae8:	72 1c                	jb     c0104b06 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104aea:	c7 44 24 08 60 7d 10 	movl   $0xc0107d60,0x8(%esp)
c0104af1:	c0 
c0104af2:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0104af9:	00 
c0104afa:	c7 04 24 7f 7d 10 c0 	movl   $0xc0107d7f,(%esp)
c0104b01:	e8 ca c1 ff ff       	call   c0100cd0 <__panic>
    return &pages[PPN(pa)];
c0104b06:	8b 0d 00 ef 11 c0    	mov    0xc011ef00,%ecx
c0104b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b0f:	c1 e8 0c             	shr    $0xc,%eax
c0104b12:	89 c2                	mov    %eax,%edx
c0104b14:	89 d0                	mov    %edx,%eax
c0104b16:	c1 e0 02             	shl    $0x2,%eax
c0104b19:	01 d0                	add    %edx,%eax
c0104b1b:	c1 e0 02             	shl    $0x2,%eax
c0104b1e:	01 c8                	add    %ecx,%eax
}
c0104b20:	89 ec                	mov    %ebp,%esp
c0104b22:	5d                   	pop    %ebp
c0104b23:	c3                   	ret    

c0104b24 <page2kva>:
page2kva(struct Page *page) {
c0104b24:	55                   	push   %ebp
c0104b25:	89 e5                	mov    %esp,%ebp
c0104b27:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b2d:	89 04 24             	mov    %eax,(%esp)
c0104b30:	e8 86 ff ff ff       	call   c0104abb <page2pa>
c0104b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b3b:	c1 e8 0c             	shr    $0xc,%eax
c0104b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b41:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0104b46:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104b49:	72 23                	jb     c0104b6e <page2kva+0x4a>
c0104b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b52:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c0104b59:	c0 
c0104b5a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0104b61:	00 
c0104b62:	c7 04 24 7f 7d 10 c0 	movl   $0xc0107d7f,(%esp)
c0104b69:	e8 62 c1 ff ff       	call   c0100cd0 <__panic>
c0104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b71:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104b76:	89 ec                	mov    %ebp,%esp
c0104b78:	5d                   	pop    %ebp
c0104b79:	c3                   	ret    

c0104b7a <pte2page>:
pte2page(pte_t pte) {
c0104b7a:	55                   	push   %ebp
c0104b7b:	89 e5                	mov    %esp,%ebp
c0104b7d:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104b80:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b83:	83 e0 01             	and    $0x1,%eax
c0104b86:	85 c0                	test   %eax,%eax
c0104b88:	75 1c                	jne    c0104ba6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104b8a:	c7 44 24 08 b4 7d 10 	movl   $0xc0107db4,0x8(%esp)
c0104b91:	c0 
c0104b92:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0104b99:	00 
c0104b9a:	c7 04 24 7f 7d 10 c0 	movl   $0xc0107d7f,(%esp)
c0104ba1:	e8 2a c1 ff ff       	call   c0100cd0 <__panic>
    return pa2page(PTE_ADDR(pte));
c0104ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ba9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104bae:	89 04 24             	mov    %eax,(%esp)
c0104bb1:	e8 1d ff ff ff       	call   c0104ad3 <pa2page>
}
c0104bb6:	89 ec                	mov    %ebp,%esp
c0104bb8:	5d                   	pop    %ebp
c0104bb9:	c3                   	ret    

c0104bba <pde2page>:
pde2page(pde_t pde) {
c0104bba:	55                   	push   %ebp
c0104bbb:	89 e5                	mov    %esp,%ebp
c0104bbd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104bc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104bc8:	89 04 24             	mov    %eax,(%esp)
c0104bcb:	e8 03 ff ff ff       	call   c0104ad3 <pa2page>
}
c0104bd0:	89 ec                	mov    %ebp,%esp
c0104bd2:	5d                   	pop    %ebp
c0104bd3:	c3                   	ret    

c0104bd4 <page_ref>:
page_ref(struct Page *page) {
c0104bd4:	55                   	push   %ebp
c0104bd5:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bda:	8b 00                	mov    (%eax),%eax
}
c0104bdc:	5d                   	pop    %ebp
c0104bdd:	c3                   	ret    

c0104bde <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104bde:	55                   	push   %ebp
c0104bdf:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104be1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104be4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104be7:	89 10                	mov    %edx,(%eax)
}
c0104be9:	90                   	nop
c0104bea:	5d                   	pop    %ebp
c0104beb:	c3                   	ret    

c0104bec <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104bec:	55                   	push   %ebp
c0104bed:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bf2:	8b 00                	mov    (%eax),%eax
c0104bf4:	8d 50 01             	lea    0x1(%eax),%edx
c0104bf7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bfa:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104bfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bff:	8b 00                	mov    (%eax),%eax
}
c0104c01:	5d                   	pop    %ebp
c0104c02:	c3                   	ret    

c0104c03 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104c03:	55                   	push   %ebp
c0104c04:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104c06:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c09:	8b 00                	mov    (%eax),%eax
c0104c0b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c11:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c16:	8b 00                	mov    (%eax),%eax
}
c0104c18:	5d                   	pop    %ebp
c0104c19:	c3                   	ret    

c0104c1a <__intr_save>:
__intr_save(void) {
c0104c1a:	55                   	push   %ebp
c0104c1b:	89 e5                	mov    %esp,%ebp
c0104c1d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104c20:	9c                   	pushf  
c0104c21:	58                   	pop    %eax
c0104c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104c28:	25 00 02 00 00       	and    $0x200,%eax
c0104c2d:	85 c0                	test   %eax,%eax
c0104c2f:	74 0c                	je     c0104c3d <__intr_save+0x23>
        intr_disable();
c0104c31:	e8 f3 ca ff ff       	call   c0101729 <intr_disable>
        return 1;
c0104c36:	b8 01 00 00 00       	mov    $0x1,%eax
c0104c3b:	eb 05                	jmp    c0104c42 <__intr_save+0x28>
    return 0;
c0104c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104c42:	89 ec                	mov    %ebp,%esp
c0104c44:	5d                   	pop    %ebp
c0104c45:	c3                   	ret    

c0104c46 <__intr_restore>:
__intr_restore(bool flag) {
c0104c46:	55                   	push   %ebp
c0104c47:	89 e5                	mov    %esp,%ebp
c0104c49:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104c4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c50:	74 05                	je     c0104c57 <__intr_restore+0x11>
        intr_enable();
c0104c52:	e8 ca ca ff ff       	call   c0101721 <intr_enable>
}
c0104c57:	90                   	nop
c0104c58:	89 ec                	mov    %ebp,%esp
c0104c5a:	5d                   	pop    %ebp
c0104c5b:	c3                   	ret    

c0104c5c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104c5c:	55                   	push   %ebp
c0104c5d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c62:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104c65:	b8 23 00 00 00       	mov    $0x23,%eax
c0104c6a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104c6c:	b8 23 00 00 00       	mov    $0x23,%eax
c0104c71:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104c73:	b8 10 00 00 00       	mov    $0x10,%eax
c0104c78:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104c7a:	b8 10 00 00 00       	mov    $0x10,%eax
c0104c7f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104c81:	b8 10 00 00 00       	mov    $0x10,%eax
c0104c86:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104c88:	ea 8f 4c 10 c0 08 00 	ljmp   $0x8,$0xc0104c8f
}
c0104c8f:	90                   	nop
c0104c90:	5d                   	pop    %ebp
c0104c91:	c3                   	ret    

c0104c92 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104c92:	55                   	push   %ebp
c0104c93:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c98:	a3 24 ef 11 c0       	mov    %eax,0xc011ef24
}
c0104c9d:	90                   	nop
c0104c9e:	5d                   	pop    %ebp
c0104c9f:	c3                   	ret    

c0104ca0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104ca0:	55                   	push   %ebp
c0104ca1:	89 e5                	mov    %esp,%ebp
c0104ca3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104ca6:	b8 00 b0 11 c0       	mov    $0xc011b000,%eax
c0104cab:	89 04 24             	mov    %eax,(%esp)
c0104cae:	e8 df ff ff ff       	call   c0104c92 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104cb3:	66 c7 05 28 ef 11 c0 	movw   $0x10,0xc011ef28
c0104cba:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104cbc:	66 c7 05 28 ba 11 c0 	movw   $0x68,0xc011ba28
c0104cc3:	68 00 
c0104cc5:	b8 20 ef 11 c0       	mov    $0xc011ef20,%eax
c0104cca:	0f b7 c0             	movzwl %ax,%eax
c0104ccd:	66 a3 2a ba 11 c0    	mov    %ax,0xc011ba2a
c0104cd3:	b8 20 ef 11 c0       	mov    $0xc011ef20,%eax
c0104cd8:	c1 e8 10             	shr    $0x10,%eax
c0104cdb:	a2 2c ba 11 c0       	mov    %al,0xc011ba2c
c0104ce0:	0f b6 05 2d ba 11 c0 	movzbl 0xc011ba2d,%eax
c0104ce7:	24 f0                	and    $0xf0,%al
c0104ce9:	0c 09                	or     $0x9,%al
c0104ceb:	a2 2d ba 11 c0       	mov    %al,0xc011ba2d
c0104cf0:	0f b6 05 2d ba 11 c0 	movzbl 0xc011ba2d,%eax
c0104cf7:	24 ef                	and    $0xef,%al
c0104cf9:	a2 2d ba 11 c0       	mov    %al,0xc011ba2d
c0104cfe:	0f b6 05 2d ba 11 c0 	movzbl 0xc011ba2d,%eax
c0104d05:	24 9f                	and    $0x9f,%al
c0104d07:	a2 2d ba 11 c0       	mov    %al,0xc011ba2d
c0104d0c:	0f b6 05 2d ba 11 c0 	movzbl 0xc011ba2d,%eax
c0104d13:	0c 80                	or     $0x80,%al
c0104d15:	a2 2d ba 11 c0       	mov    %al,0xc011ba2d
c0104d1a:	0f b6 05 2e ba 11 c0 	movzbl 0xc011ba2e,%eax
c0104d21:	24 f0                	and    $0xf0,%al
c0104d23:	a2 2e ba 11 c0       	mov    %al,0xc011ba2e
c0104d28:	0f b6 05 2e ba 11 c0 	movzbl 0xc011ba2e,%eax
c0104d2f:	24 ef                	and    $0xef,%al
c0104d31:	a2 2e ba 11 c0       	mov    %al,0xc011ba2e
c0104d36:	0f b6 05 2e ba 11 c0 	movzbl 0xc011ba2e,%eax
c0104d3d:	24 df                	and    $0xdf,%al
c0104d3f:	a2 2e ba 11 c0       	mov    %al,0xc011ba2e
c0104d44:	0f b6 05 2e ba 11 c0 	movzbl 0xc011ba2e,%eax
c0104d4b:	0c 40                	or     $0x40,%al
c0104d4d:	a2 2e ba 11 c0       	mov    %al,0xc011ba2e
c0104d52:	0f b6 05 2e ba 11 c0 	movzbl 0xc011ba2e,%eax
c0104d59:	24 7f                	and    $0x7f,%al
c0104d5b:	a2 2e ba 11 c0       	mov    %al,0xc011ba2e
c0104d60:	b8 20 ef 11 c0       	mov    $0xc011ef20,%eax
c0104d65:	c1 e8 18             	shr    $0x18,%eax
c0104d68:	a2 2f ba 11 c0       	mov    %al,0xc011ba2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104d6d:	c7 04 24 30 ba 11 c0 	movl   $0xc011ba30,(%esp)
c0104d74:	e8 e3 fe ff ff       	call   c0104c5c <lgdt>
c0104d79:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104d7f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104d83:	0f 00 d8             	ltr    %ax
}
c0104d86:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104d87:	90                   	nop
c0104d88:	89 ec                	mov    %ebp,%esp
c0104d8a:	5d                   	pop    %ebp
c0104d8b:	c3                   	ret    

c0104d8c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104d8c:	55                   	push   %ebp
c0104d8d:	89 e5                	mov    %esp,%ebp
c0104d8f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &buddy_pmm_manager;
c0104d92:	c7 05 0c ef 11 c0 b0 	movl   $0xc01079b0,0xc011ef0c
c0104d99:	79 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104d9c:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104da1:	8b 00                	mov    (%eax),%eax
c0104da3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104da7:	c7 04 24 e0 7d 10 c0 	movl   $0xc0107de0,(%esp)
c0104dae:	e8 a3 b5 ff ff       	call   c0100356 <cprintf>
    pmm_manager->init();
c0104db3:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104db8:	8b 40 04             	mov    0x4(%eax),%eax
c0104dbb:	ff d0                	call   *%eax
}
c0104dbd:	90                   	nop
c0104dbe:	89 ec                	mov    %ebp,%esp
c0104dc0:	5d                   	pop    %ebp
c0104dc1:	c3                   	ret    

c0104dc2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104dc2:	55                   	push   %ebp
c0104dc3:	89 e5                	mov    %esp,%ebp
c0104dc5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104dc8:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104dcd:	8b 40 08             	mov    0x8(%eax),%eax
c0104dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104dd7:	8b 55 08             	mov    0x8(%ebp),%edx
c0104dda:	89 14 24             	mov    %edx,(%esp)
c0104ddd:	ff d0                	call   *%eax
}
c0104ddf:	90                   	nop
c0104de0:	89 ec                	mov    %ebp,%esp
c0104de2:	5d                   	pop    %ebp
c0104de3:	c3                   	ret    

c0104de4 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104de4:	55                   	push   %ebp
c0104de5:	89 e5                	mov    %esp,%ebp
c0104de7:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104dea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0104df1:	e8 24 fe ff ff       	call   c0104c1a <__intr_save>
c0104df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0104df9:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104dfe:	8b 40 0c             	mov    0xc(%eax),%eax
c0104e01:	8b 55 08             	mov    0x8(%ebp),%edx
c0104e04:	89 14 24             	mov    %edx,(%esp)
c0104e07:	ff d0                	call   *%eax
c0104e09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0104e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e0f:	89 04 24             	mov    %eax,(%esp)
c0104e12:	e8 2f fe ff ff       	call   c0104c46 <__intr_restore>
    return page;
c0104e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104e1a:	89 ec                	mov    %ebp,%esp
c0104e1c:	5d                   	pop    %ebp
c0104e1d:	c3                   	ret    

c0104e1e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104e1e:	55                   	push   %ebp
c0104e1f:	89 e5                	mov    %esp,%ebp
c0104e21:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104e24:	e8 f1 fd ff ff       	call   c0104c1a <__intr_save>
c0104e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104e2c:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104e31:	8b 40 10             	mov    0x10(%eax),%eax
c0104e34:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e37:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e3b:	8b 55 08             	mov    0x8(%ebp),%edx
c0104e3e:	89 14 24             	mov    %edx,(%esp)
c0104e41:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0104e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e46:	89 04 24             	mov    %eax,(%esp)
c0104e49:	e8 f8 fd ff ff       	call   c0104c46 <__intr_restore>
}
c0104e4e:	90                   	nop
c0104e4f:	89 ec                	mov    %ebp,%esp
c0104e51:	5d                   	pop    %ebp
c0104e52:	c3                   	ret    

c0104e53 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104e53:	55                   	push   %ebp
c0104e54:	89 e5                	mov    %esp,%ebp
c0104e56:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104e59:	e8 bc fd ff ff       	call   c0104c1a <__intr_save>
c0104e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104e61:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0104e66:	8b 40 14             	mov    0x14(%eax),%eax
c0104e69:	ff d0                	call   *%eax
c0104e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e71:	89 04 24             	mov    %eax,(%esp)
c0104e74:	e8 cd fd ff ff       	call   c0104c46 <__intr_restore>
    return ret;
c0104e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104e7c:	89 ec                	mov    %ebp,%esp
c0104e7e:	5d                   	pop    %ebp
c0104e7f:	c3                   	ret    

c0104e80 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104e80:	55                   	push   %ebp
c0104e81:	89 e5                	mov    %esp,%ebp
c0104e83:	57                   	push   %edi
c0104e84:	56                   	push   %esi
c0104e85:	53                   	push   %ebx
c0104e86:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104e8c:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104e93:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104e9a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104ea1:	c7 04 24 f7 7d 10 c0 	movl   $0xc0107df7,(%esp)
c0104ea8:	e8 a9 b4 ff ff       	call   c0100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104ead:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104eb4:	e9 0c 01 00 00       	jmp    c0104fc5 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104eb9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ebc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ebf:	89 d0                	mov    %edx,%eax
c0104ec1:	c1 e0 02             	shl    $0x2,%eax
c0104ec4:	01 d0                	add    %edx,%eax
c0104ec6:	c1 e0 02             	shl    $0x2,%eax
c0104ec9:	01 c8                	add    %ecx,%eax
c0104ecb:	8b 50 08             	mov    0x8(%eax),%edx
c0104ece:	8b 40 04             	mov    0x4(%eax),%eax
c0104ed1:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104ed4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104ed7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104edd:	89 d0                	mov    %edx,%eax
c0104edf:	c1 e0 02             	shl    $0x2,%eax
c0104ee2:	01 d0                	add    %edx,%eax
c0104ee4:	c1 e0 02             	shl    $0x2,%eax
c0104ee7:	01 c8                	add    %ecx,%eax
c0104ee9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104eec:	8b 58 10             	mov    0x10(%eax),%ebx
c0104eef:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104ef2:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104ef5:	01 c8                	add    %ecx,%eax
c0104ef7:	11 da                	adc    %ebx,%edx
c0104ef9:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104efc:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104eff:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104f02:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f05:	89 d0                	mov    %edx,%eax
c0104f07:	c1 e0 02             	shl    $0x2,%eax
c0104f0a:	01 d0                	add    %edx,%eax
c0104f0c:	c1 e0 02             	shl    $0x2,%eax
c0104f0f:	01 c8                	add    %ecx,%eax
c0104f11:	83 c0 14             	add    $0x14,%eax
c0104f14:	8b 00                	mov    (%eax),%eax
c0104f16:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104f1c:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104f1f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104f22:	83 c0 ff             	add    $0xffffffff,%eax
c0104f25:	83 d2 ff             	adc    $0xffffffff,%edx
c0104f28:	89 c6                	mov    %eax,%esi
c0104f2a:	89 d7                	mov    %edx,%edi
c0104f2c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104f2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f32:	89 d0                	mov    %edx,%eax
c0104f34:	c1 e0 02             	shl    $0x2,%eax
c0104f37:	01 d0                	add    %edx,%eax
c0104f39:	c1 e0 02             	shl    $0x2,%eax
c0104f3c:	01 c8                	add    %ecx,%eax
c0104f3e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104f41:	8b 58 10             	mov    0x10(%eax),%ebx
c0104f44:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104f4a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104f4e:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104f52:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104f56:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104f59:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104f5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f60:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104f64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104f68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104f6c:	c7 04 24 04 7e 10 c0 	movl   $0xc0107e04,(%esp)
c0104f73:	e8 de b3 ff ff       	call   c0100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104f78:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104f7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f7e:	89 d0                	mov    %edx,%eax
c0104f80:	c1 e0 02             	shl    $0x2,%eax
c0104f83:	01 d0                	add    %edx,%eax
c0104f85:	c1 e0 02             	shl    $0x2,%eax
c0104f88:	01 c8                	add    %ecx,%eax
c0104f8a:	83 c0 14             	add    $0x14,%eax
c0104f8d:	8b 00                	mov    (%eax),%eax
c0104f8f:	83 f8 01             	cmp    $0x1,%eax
c0104f92:	75 2e                	jne    c0104fc2 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104f9a:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104f9d:	89 d0                	mov    %edx,%eax
c0104f9f:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104fa2:	73 1e                	jae    c0104fc2 <page_init+0x142>
c0104fa4:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104fa9:	b8 00 00 00 00       	mov    $0x0,%eax
c0104fae:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104fb1:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104fb4:	72 0c                	jb     c0104fc2 <page_init+0x142>
                maxpa = end;
c0104fb6:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104fb9:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104fbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104fbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104fc2:	ff 45 dc             	incl   -0x24(%ebp)
c0104fc5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104fc8:	8b 00                	mov    (%eax),%eax
c0104fca:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104fcd:	0f 8c e6 fe ff ff    	jl     c0104eb9 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104fd3:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104fd8:	b8 00 00 00 00       	mov    $0x0,%eax
c0104fdd:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104fe0:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104fe3:	73 0e                	jae    c0104ff3 <page_init+0x173>
        maxpa = KMEMSIZE;
c0104fe5:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104fec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104ff3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ff9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104ffd:	c1 ea 0c             	shr    $0xc,%edx
c0105000:	a3 04 ef 11 c0       	mov    %eax,0xc011ef04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0105005:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c010500c:	b8 8c ef 11 c0       	mov    $0xc011ef8c,%eax
c0105011:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105014:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105017:	01 d0                	add    %edx,%eax
c0105019:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010501c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010501f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105024:	f7 75 c0             	divl   -0x40(%ebp)
c0105027:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010502a:	29 d0                	sub    %edx,%eax
c010502c:	a3 00 ef 11 c0       	mov    %eax,0xc011ef00

    for (i = 0; i < npage; i ++) {
c0105031:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105038:	eb 2f                	jmp    c0105069 <page_init+0x1e9>
        SetPageReserved(pages + i);
c010503a:	8b 0d 00 ef 11 c0    	mov    0xc011ef00,%ecx
c0105040:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105043:	89 d0                	mov    %edx,%eax
c0105045:	c1 e0 02             	shl    $0x2,%eax
c0105048:	01 d0                	add    %edx,%eax
c010504a:	c1 e0 02             	shl    $0x2,%eax
c010504d:	01 c8                	add    %ecx,%eax
c010504f:	83 c0 04             	add    $0x4,%eax
c0105052:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0105059:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010505c:	8b 45 90             	mov    -0x70(%ebp),%eax
c010505f:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105062:	0f ab 10             	bts    %edx,(%eax)
}
c0105065:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0105066:	ff 45 dc             	incl   -0x24(%ebp)
c0105069:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010506c:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0105071:	39 c2                	cmp    %eax,%edx
c0105073:	72 c5                	jb     c010503a <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105075:	8b 15 04 ef 11 c0    	mov    0xc011ef04,%edx
c010507b:	89 d0                	mov    %edx,%eax
c010507d:	c1 e0 02             	shl    $0x2,%eax
c0105080:	01 d0                	add    %edx,%eax
c0105082:	c1 e0 02             	shl    $0x2,%eax
c0105085:	89 c2                	mov    %eax,%edx
c0105087:	a1 00 ef 11 c0       	mov    0xc011ef00,%eax
c010508c:	01 d0                	add    %edx,%eax
c010508e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105091:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0105098:	77 23                	ja     c01050bd <page_init+0x23d>
c010509a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010509d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050a1:	c7 44 24 08 34 7e 10 	movl   $0xc0107e34,0x8(%esp)
c01050a8:	c0 
c01050a9:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01050b0:	00 
c01050b1:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01050b8:	e8 13 bc ff ff       	call   c0100cd0 <__panic>
c01050bd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01050c0:	05 00 00 00 40       	add    $0x40000000,%eax
c01050c5:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01050c8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01050cf:	e9 53 01 00 00       	jmp    c0105227 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01050d4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050da:	89 d0                	mov    %edx,%eax
c01050dc:	c1 e0 02             	shl    $0x2,%eax
c01050df:	01 d0                	add    %edx,%eax
c01050e1:	c1 e0 02             	shl    $0x2,%eax
c01050e4:	01 c8                	add    %ecx,%eax
c01050e6:	8b 50 08             	mov    0x8(%eax),%edx
c01050e9:	8b 40 04             	mov    0x4(%eax),%eax
c01050ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01050ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01050f2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050f8:	89 d0                	mov    %edx,%eax
c01050fa:	c1 e0 02             	shl    $0x2,%eax
c01050fd:	01 d0                	add    %edx,%eax
c01050ff:	c1 e0 02             	shl    $0x2,%eax
c0105102:	01 c8                	add    %ecx,%eax
c0105104:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105107:	8b 58 10             	mov    0x10(%eax),%ebx
c010510a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010510d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105110:	01 c8                	add    %ecx,%eax
c0105112:	11 da                	adc    %ebx,%edx
c0105114:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105117:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010511a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010511d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105120:	89 d0                	mov    %edx,%eax
c0105122:	c1 e0 02             	shl    $0x2,%eax
c0105125:	01 d0                	add    %edx,%eax
c0105127:	c1 e0 02             	shl    $0x2,%eax
c010512a:	01 c8                	add    %ecx,%eax
c010512c:	83 c0 14             	add    $0x14,%eax
c010512f:	8b 00                	mov    (%eax),%eax
c0105131:	83 f8 01             	cmp    $0x1,%eax
c0105134:	0f 85 ea 00 00 00    	jne    c0105224 <page_init+0x3a4>
            if (begin < freemem) {
c010513a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010513d:	ba 00 00 00 00       	mov    $0x0,%edx
c0105142:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105145:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105148:	19 d1                	sbb    %edx,%ecx
c010514a:	73 0d                	jae    c0105159 <page_init+0x2d9>
                begin = freemem;
c010514c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010514f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105152:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0105159:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010515e:	b8 00 00 00 00       	mov    $0x0,%eax
c0105163:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0105166:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105169:	73 0e                	jae    c0105179 <page_init+0x2f9>
                end = KMEMSIZE;
c010516b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105172:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0105179:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010517c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010517f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105182:	89 d0                	mov    %edx,%eax
c0105184:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105187:	0f 83 97 00 00 00    	jae    c0105224 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c010518d:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0105194:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105197:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010519a:	01 d0                	add    %edx,%eax
c010519c:	48                   	dec    %eax
c010519d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01051a0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01051a3:	ba 00 00 00 00       	mov    $0x0,%edx
c01051a8:	f7 75 b0             	divl   -0x50(%ebp)
c01051ab:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01051ae:	29 d0                	sub    %edx,%eax
c01051b0:	ba 00 00 00 00       	mov    $0x0,%edx
c01051b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01051b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01051bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01051be:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01051c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01051c4:	ba 00 00 00 00       	mov    $0x0,%edx
c01051c9:	89 c7                	mov    %eax,%edi
c01051cb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01051d1:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01051d4:	89 d0                	mov    %edx,%eax
c01051d6:	83 e0 00             	and    $0x0,%eax
c01051d9:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01051dc:	8b 45 80             	mov    -0x80(%ebp),%eax
c01051df:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01051e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01051e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01051e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01051eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01051ee:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01051f1:	89 d0                	mov    %edx,%eax
c01051f3:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01051f6:	73 2c                	jae    c0105224 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01051f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01051fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01051fe:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0105201:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0105204:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105208:	c1 ea 0c             	shr    $0xc,%edx
c010520b:	89 c3                	mov    %eax,%ebx
c010520d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105210:	89 04 24             	mov    %eax,(%esp)
c0105213:	e8 bb f8 ff ff       	call   c0104ad3 <pa2page>
c0105218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010521c:	89 04 24             	mov    %eax,(%esp)
c010521f:	e8 9e fb ff ff       	call   c0104dc2 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0105224:	ff 45 dc             	incl   -0x24(%ebp)
c0105227:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010522a:	8b 00                	mov    (%eax),%eax
c010522c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010522f:	0f 8c 9f fe ff ff    	jl     c01050d4 <page_init+0x254>
                }
            }
        }
    }
}
c0105235:	90                   	nop
c0105236:	90                   	nop
c0105237:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010523d:	5b                   	pop    %ebx
c010523e:	5e                   	pop    %esi
c010523f:	5f                   	pop    %edi
c0105240:	5d                   	pop    %ebp
c0105241:	c3                   	ret    

c0105242 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0105242:	55                   	push   %ebp
c0105243:	89 e5                	mov    %esp,%ebp
c0105245:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105248:	8b 45 0c             	mov    0xc(%ebp),%eax
c010524b:	33 45 14             	xor    0x14(%ebp),%eax
c010524e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105253:	85 c0                	test   %eax,%eax
c0105255:	74 24                	je     c010527b <boot_map_segment+0x39>
c0105257:	c7 44 24 0c 66 7e 10 	movl   $0xc0107e66,0xc(%esp)
c010525e:	c0 
c010525f:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105266:	c0 
c0105267:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010526e:	00 
c010526f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105276:	e8 55 ba ff ff       	call   c0100cd0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010527b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0105282:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105285:	25 ff 0f 00 00       	and    $0xfff,%eax
c010528a:	89 c2                	mov    %eax,%edx
c010528c:	8b 45 10             	mov    0x10(%ebp),%eax
c010528f:	01 c2                	add    %eax,%edx
c0105291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105294:	01 d0                	add    %edx,%eax
c0105296:	48                   	dec    %eax
c0105297:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010529a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010529d:	ba 00 00 00 00       	mov    $0x0,%edx
c01052a2:	f7 75 f0             	divl   -0x10(%ebp)
c01052a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052a8:	29 d0                	sub    %edx,%eax
c01052aa:	c1 e8 0c             	shr    $0xc,%eax
c01052ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01052b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01052b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01052be:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01052c1:	8b 45 14             	mov    0x14(%ebp),%eax
c01052c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01052c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01052cf:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01052d2:	eb 68                	jmp    c010533c <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01052d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01052db:	00 
c01052dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01052e6:	89 04 24             	mov    %eax,(%esp)
c01052e9:	e8 88 01 00 00       	call   c0105476 <get_pte>
c01052ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01052f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01052f5:	75 24                	jne    c010531b <boot_map_segment+0xd9>
c01052f7:	c7 44 24 0c 92 7e 10 	movl   $0xc0107e92,0xc(%esp)
c01052fe:	c0 
c01052ff:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105306:	c0 
c0105307:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c010530e:	00 
c010530f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105316:	e8 b5 b9 ff ff       	call   c0100cd0 <__panic>
        *ptep = pa | PTE_P | perm;
c010531b:	8b 45 14             	mov    0x14(%ebp),%eax
c010531e:	0b 45 18             	or     0x18(%ebp),%eax
c0105321:	83 c8 01             	or     $0x1,%eax
c0105324:	89 c2                	mov    %eax,%edx
c0105326:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105329:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010532b:	ff 4d f4             	decl   -0xc(%ebp)
c010532e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0105335:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010533c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105340:	75 92                	jne    c01052d4 <boot_map_segment+0x92>
    }
}
c0105342:	90                   	nop
c0105343:	90                   	nop
c0105344:	89 ec                	mov    %ebp,%esp
c0105346:	5d                   	pop    %ebp
c0105347:	c3                   	ret    

c0105348 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105348:	55                   	push   %ebp
c0105349:	89 e5                	mov    %esp,%ebp
c010534b:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010534e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105355:	e8 8a fa ff ff       	call   c0104de4 <alloc_pages>
c010535a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010535d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105361:	75 1c                	jne    c010537f <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105363:	c7 44 24 08 9f 7e 10 	movl   $0xc0107e9f,0x8(%esp)
c010536a:	c0 
c010536b:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0105372:	00 
c0105373:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010537a:	e8 51 b9 ff ff       	call   c0100cd0 <__panic>
    }
    return page2kva(p);
c010537f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105382:	89 04 24             	mov    %eax,(%esp)
c0105385:	e8 9a f7 ff ff       	call   c0104b24 <page2kva>
}
c010538a:	89 ec                	mov    %ebp,%esp
c010538c:	5d                   	pop    %ebp
c010538d:	c3                   	ret    

c010538e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010538e:	55                   	push   %ebp
c010538f:	89 e5                	mov    %esp,%ebp
c0105391:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105394:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105399:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010539c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01053a3:	77 23                	ja     c01053c8 <pmm_init+0x3a>
c01053a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053ac:	c7 44 24 08 34 7e 10 	movl   $0xc0107e34,0x8(%esp)
c01053b3:	c0 
c01053b4:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01053bb:	00 
c01053bc:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01053c3:	e8 08 b9 ff ff       	call   c0100cd0 <__panic>
c01053c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053cb:	05 00 00 00 40       	add    $0x40000000,%eax
c01053d0:	a3 08 ef 11 c0       	mov    %eax,0xc011ef08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01053d5:	e8 b2 f9 ff ff       	call   c0104d8c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01053da:	e8 a1 fa ff ff       	call   c0104e80 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01053df:	e8 5a 04 00 00       	call   c010583e <check_alloc_page>

    check_pgdir();
c01053e4:	e8 76 04 00 00       	call   c010585f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01053e9:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c01053ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053f1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01053f8:	77 23                	ja     c010541d <pmm_init+0x8f>
c01053fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105401:	c7 44 24 08 34 7e 10 	movl   $0xc0107e34,0x8(%esp)
c0105408:	c0 
c0105409:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0105410:	00 
c0105411:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105418:	e8 b3 b8 ff ff       	call   c0100cd0 <__panic>
c010541d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105420:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0105426:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c010542b:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105430:	83 ca 03             	or     $0x3,%edx
c0105433:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105435:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c010543a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105441:	00 
c0105442:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105449:	00 
c010544a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105451:	38 
c0105452:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0105459:	c0 
c010545a:	89 04 24             	mov    %eax,(%esp)
c010545d:	e8 e0 fd ff ff       	call   c0105242 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105462:	e8 39 f8 ff ff       	call   c0104ca0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0105467:	e8 91 0a 00 00       	call   c0105efd <check_boot_pgdir>

    print_pgdir();
c010546c:	e8 0e 0f 00 00       	call   c010637f <print_pgdir>

}
c0105471:	90                   	nop
c0105472:	89 ec                	mov    %ebp,%esp
c0105474:	5d                   	pop    %ebp
c0105475:	c3                   	ret    

c0105476 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105476:	55                   	push   %ebp
c0105477:	89 e5                	mov    %esp,%ebp
c0105479:	83 ec 48             	sub    $0x48,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pdep = pgdir + PDX(la);
c010547c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010547f:	c1 e8 16             	shr    $0x16,%eax
c0105482:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105489:	8b 45 08             	mov    0x8(%ebp),%eax
c010548c:	01 d0                	add    %edx,%eax
c010548e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*pdep & PTE_P) {
c0105491:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105494:	8b 00                	mov    (%eax),%eax
c0105496:	83 e0 01             	and    $0x1,%eax
c0105499:	85 c0                	test   %eax,%eax
c010549b:	74 68                	je     c0105505 <get_pte+0x8f>
        pte_t *ptep = (pte_t *)KADDR(*pdep & ~0x0fff) + PTX(la);
c010549d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a0:	8b 00                	mov    (%eax),%eax
c01054a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01054a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01054aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054ad:	c1 e8 0c             	shr    $0xc,%eax
c01054b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054b3:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c01054b8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01054bb:	72 23                	jb     c01054e0 <get_pte+0x6a>
c01054bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01054c4:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c01054cb:	c0 
c01054cc:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c01054d3:	00 
c01054d4:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01054db:	e8 f0 b7 ff ff       	call   c0100cd0 <__panic>
c01054e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054e3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01054e8:	89 c2                	mov    %eax,%edx
c01054ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054ed:	c1 e8 0c             	shr    $0xc,%eax
c01054f0:	25 ff 03 00 00       	and    $0x3ff,%eax
c01054f5:	c1 e0 02             	shl    $0x2,%eax
c01054f8:	01 d0                	add    %edx,%eax
c01054fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
        return ptep;
c01054fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105500:	e9 10 01 00 00       	jmp    c0105615 <get_pte+0x19f>
    }

    struct Page *page;
    if (!create || ((page = alloc_page()) == NULL)) {
c0105505:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105509:	74 15                	je     c0105520 <get_pte+0xaa>
c010550b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105512:	e8 cd f8 ff ff       	call   c0104de4 <alloc_pages>
c0105517:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010551a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010551e:	75 0a                	jne    c010552a <get_pte+0xb4>
        return NULL;
c0105520:	b8 00 00 00 00       	mov    $0x0,%eax
c0105525:	e9 eb 00 00 00       	jmp    c0105615 <get_pte+0x19f>
    }

    set_page_ref(page, 1);
c010552a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105531:	00 
c0105532:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105535:	89 04 24             	mov    %eax,(%esp)
c0105538:	e8 a1 f6 ff ff       	call   c0104bde <set_page_ref>
    uintptr_t pa = page2pa(page) & ~0x0fff;
c010553d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105540:	89 04 24             	mov    %eax,(%esp)
c0105543:	e8 73 f5 ff ff       	call   c0104abb <page2pa>
c0105548:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010554d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memset((void *)KADDR(pa), 0, PGSIZE);
c0105550:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105553:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105556:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105559:	c1 e8 0c             	shr    $0xc,%eax
c010555c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010555f:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0105564:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105567:	72 23                	jb     c010558c <get_pte+0x116>
c0105569:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010556c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105570:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c0105577:	c0 
c0105578:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c010557f:	00 
c0105580:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105587:	e8 44 b7 ff ff       	call   c0100cd0 <__panic>
c010558c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010558f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105594:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010559b:	00 
c010559c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055a3:	00 
c01055a4:	89 04 24             	mov    %eax,(%esp)
c01055a7:	e8 d8 18 00 00       	call   c0106e84 <memset>
    *pdep = pa | PTE_P | PTE_W | PTE_U;
c01055ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055af:	83 c8 07             	or     $0x7,%eax
c01055b2:	89 c2                	mov    %eax,%edx
c01055b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055b7:	89 10                	mov    %edx,(%eax)
    pte_t *ptep = (pte_t *)KADDR(pa) + PTX(la);
c01055b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01055bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055c2:	c1 e8 0c             	shr    $0xc,%eax
c01055c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01055c8:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c01055cd:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01055d0:	72 23                	jb     c01055f5 <get_pte+0x17f>
c01055d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055d9:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c01055e0:	c0 
c01055e1:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
c01055e8:	00 
c01055e9:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01055f0:	e8 db b6 ff ff       	call   c0100cd0 <__panic>
c01055f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055f8:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01055fd:	89 c2                	mov    %eax,%edx
c01055ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105602:	c1 e8 0c             	shr    $0xc,%eax
c0105605:	25 ff 03 00 00       	and    $0x3ff,%eax
c010560a:	c1 e0 02             	shl    $0x2,%eax
c010560d:	01 d0                	add    %edx,%eax
c010560f:	89 45 d8             	mov    %eax,-0x28(%ebp)

    return ptep;
c0105612:	8b 45 d8             	mov    -0x28(%ebp),%eax
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c0105615:	89 ec                	mov    %ebp,%esp
c0105617:	5d                   	pop    %ebp
c0105618:	c3                   	ret    

c0105619 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105619:	55                   	push   %ebp
c010561a:	89 e5                	mov    %esp,%ebp
c010561c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010561f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105626:	00 
c0105627:	8b 45 0c             	mov    0xc(%ebp),%eax
c010562a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010562e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105631:	89 04 24             	mov    %eax,(%esp)
c0105634:	e8 3d fe ff ff       	call   c0105476 <get_pte>
c0105639:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010563c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105640:	74 08                	je     c010564a <get_page+0x31>
        *ptep_store = ptep;
c0105642:	8b 45 10             	mov    0x10(%ebp),%eax
c0105645:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105648:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010564a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010564e:	74 1b                	je     c010566b <get_page+0x52>
c0105650:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105653:	8b 00                	mov    (%eax),%eax
c0105655:	83 e0 01             	and    $0x1,%eax
c0105658:	85 c0                	test   %eax,%eax
c010565a:	74 0f                	je     c010566b <get_page+0x52>
        return pte2page(*ptep);
c010565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010565f:	8b 00                	mov    (%eax),%eax
c0105661:	89 04 24             	mov    %eax,(%esp)
c0105664:	e8 11 f5 ff ff       	call   c0104b7a <pte2page>
c0105669:	eb 05                	jmp    c0105670 <get_page+0x57>
    }
    return NULL;
c010566b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105670:	89 ec                	mov    %ebp,%esp
c0105672:	5d                   	pop    %ebp
c0105673:	c3                   	ret    

c0105674 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105674:	55                   	push   %ebp
c0105675:	89 e5                	mov    %esp,%ebp
c0105677:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if (*ptep & PTE_P) {
c010567a:	8b 45 10             	mov    0x10(%ebp),%eax
c010567d:	8b 00                	mov    (%eax),%eax
c010567f:	83 e0 01             	and    $0x1,%eax
c0105682:	85 c0                	test   %eax,%eax
c0105684:	74 52                	je     c01056d8 <page_remove_pte+0x64>
        struct Page *page = pa2page(*ptep & ~0x0fff);
c0105686:	8b 45 10             	mov    0x10(%ebp),%eax
c0105689:	8b 00                	mov    (%eax),%eax
c010568b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105690:	89 04 24             	mov    %eax,(%esp)
c0105693:	e8 3b f4 ff ff       	call   c0104ad3 <pa2page>
c0105698:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010569b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010569e:	89 04 24             	mov    %eax,(%esp)
c01056a1:	e8 5d f5 ff ff       	call   c0104c03 <page_ref_dec>
c01056a6:	85 c0                	test   %eax,%eax
c01056a8:	75 13                	jne    c01056bd <page_remove_pte+0x49>
            free_page(page);
c01056aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01056b1:	00 
c01056b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056b5:	89 04 24             	mov    %eax,(%esp)
c01056b8:	e8 61 f7 ff ff       	call   c0104e1e <free_pages>
        }
        *ptep = 0;
c01056bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01056c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01056c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 07 01 00 00       	call   c01057df <tlb_invalidate>
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c01056d8:	90                   	nop
c01056d9:	89 ec                	mov    %ebp,%esp
c01056db:	5d                   	pop    %ebp
c01056dc:	c3                   	ret    

c01056dd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01056dd:	55                   	push   %ebp
c01056de:	89 e5                	mov    %esp,%ebp
c01056e0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01056e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056ea:	00 
c01056eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01056f5:	89 04 24             	mov    %eax,(%esp)
c01056f8:	e8 79 fd ff ff       	call   c0105476 <get_pte>
c01056fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105700:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105704:	74 19                	je     c010571f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105709:	89 44 24 08          	mov    %eax,0x8(%esp)
c010570d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105710:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105714:	8b 45 08             	mov    0x8(%ebp),%eax
c0105717:	89 04 24             	mov    %eax,(%esp)
c010571a:	e8 55 ff ff ff       	call   c0105674 <page_remove_pte>
    }
}
c010571f:	90                   	nop
c0105720:	89 ec                	mov    %ebp,%esp
c0105722:	5d                   	pop    %ebp
c0105723:	c3                   	ret    

c0105724 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105724:	55                   	push   %ebp
c0105725:	89 e5                	mov    %esp,%ebp
c0105727:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010572a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105731:	00 
c0105732:	8b 45 10             	mov    0x10(%ebp),%eax
c0105735:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105739:	8b 45 08             	mov    0x8(%ebp),%eax
c010573c:	89 04 24             	mov    %eax,(%esp)
c010573f:	e8 32 fd ff ff       	call   c0105476 <get_pte>
c0105744:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010574b:	75 0a                	jne    c0105757 <page_insert+0x33>
        return -E_NO_MEM;
c010574d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105752:	e9 84 00 00 00       	jmp    c01057db <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105757:	8b 45 0c             	mov    0xc(%ebp),%eax
c010575a:	89 04 24             	mov    %eax,(%esp)
c010575d:	e8 8a f4 ff ff       	call   c0104bec <page_ref_inc>
    if (*ptep & PTE_P) {
c0105762:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105765:	8b 00                	mov    (%eax),%eax
c0105767:	83 e0 01             	and    $0x1,%eax
c010576a:	85 c0                	test   %eax,%eax
c010576c:	74 3e                	je     c01057ac <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010576e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105771:	8b 00                	mov    (%eax),%eax
c0105773:	89 04 24             	mov    %eax,(%esp)
c0105776:	e8 ff f3 ff ff       	call   c0104b7a <pte2page>
c010577b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010577e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105781:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105784:	75 0d                	jne    c0105793 <page_insert+0x6f>
            page_ref_dec(page);
c0105786:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105789:	89 04 24             	mov    %eax,(%esp)
c010578c:	e8 72 f4 ff ff       	call   c0104c03 <page_ref_dec>
c0105791:	eb 19                	jmp    c01057ac <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105796:	89 44 24 08          	mov    %eax,0x8(%esp)
c010579a:	8b 45 10             	mov    0x10(%ebp),%eax
c010579d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a4:	89 04 24             	mov    %eax,(%esp)
c01057a7:	e8 c8 fe ff ff       	call   c0105674 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01057ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057af:	89 04 24             	mov    %eax,(%esp)
c01057b2:	e8 04 f3 ff ff       	call   c0104abb <page2pa>
c01057b7:	0b 45 14             	or     0x14(%ebp),%eax
c01057ba:	83 c8 01             	or     $0x1,%eax
c01057bd:	89 c2                	mov    %eax,%edx
c01057bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057c2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01057c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01057c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ce:	89 04 24             	mov    %eax,(%esp)
c01057d1:	e8 09 00 00 00       	call   c01057df <tlb_invalidate>
    return 0;
c01057d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01057db:	89 ec                	mov    %ebp,%esp
c01057dd:	5d                   	pop    %ebp
c01057de:	c3                   	ret    

c01057df <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01057df:	55                   	push   %ebp
c01057e0:	89 e5                	mov    %esp,%ebp
c01057e2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01057e5:	0f 20 d8             	mov    %cr3,%eax
c01057e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01057eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01057ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01057f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01057f4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01057fb:	77 23                	ja     c0105820 <tlb_invalidate+0x41>
c01057fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105800:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105804:	c7 44 24 08 34 7e 10 	movl   $0xc0107e34,0x8(%esp)
c010580b:	c0 
c010580c:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0105813:	00 
c0105814:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010581b:	e8 b0 b4 ff ff       	call   c0100cd0 <__panic>
c0105820:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105823:	05 00 00 00 40       	add    $0x40000000,%eax
c0105828:	39 d0                	cmp    %edx,%eax
c010582a:	75 0d                	jne    c0105839 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c010582c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010582f:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105832:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105835:	0f 01 38             	invlpg (%eax)
}
c0105838:	90                   	nop
    }
}
c0105839:	90                   	nop
c010583a:	89 ec                	mov    %ebp,%esp
c010583c:	5d                   	pop    %ebp
c010583d:	c3                   	ret    

c010583e <check_alloc_page>:

static void
check_alloc_page(void) {
c010583e:	55                   	push   %ebp
c010583f:	89 e5                	mov    %esp,%ebp
c0105841:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105844:	a1 0c ef 11 c0       	mov    0xc011ef0c,%eax
c0105849:	8b 40 18             	mov    0x18(%eax),%eax
c010584c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010584e:	c7 04 24 b8 7e 10 c0 	movl   $0xc0107eb8,(%esp)
c0105855:	e8 fc aa ff ff       	call   c0100356 <cprintf>
}
c010585a:	90                   	nop
c010585b:	89 ec                	mov    %ebp,%esp
c010585d:	5d                   	pop    %ebp
c010585e:	c3                   	ret    

c010585f <check_pgdir>:

static void
check_pgdir(void) {
c010585f:	55                   	push   %ebp
c0105860:	89 e5                	mov    %esp,%ebp
c0105862:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105865:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c010586a:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010586f:	76 24                	jbe    c0105895 <check_pgdir+0x36>
c0105871:	c7 44 24 0c d7 7e 10 	movl   $0xc0107ed7,0xc(%esp)
c0105878:	c0 
c0105879:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105880:	c0 
c0105881:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0105888:	00 
c0105889:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105890:	e8 3b b4 ff ff       	call   c0100cd0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105895:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c010589a:	85 c0                	test   %eax,%eax
c010589c:	74 0e                	je     c01058ac <check_pgdir+0x4d>
c010589e:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c01058a3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01058a8:	85 c0                	test   %eax,%eax
c01058aa:	74 24                	je     c01058d0 <check_pgdir+0x71>
c01058ac:	c7 44 24 0c f4 7e 10 	movl   $0xc0107ef4,0xc(%esp)
c01058b3:	c0 
c01058b4:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c01058bb:	c0 
c01058bc:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01058c3:	00 
c01058c4:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01058cb:	e8 00 b4 ff ff       	call   c0100cd0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01058d0:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c01058d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01058dc:	00 
c01058dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01058e4:	00 
c01058e5:	89 04 24             	mov    %eax,(%esp)
c01058e8:	e8 2c fd ff ff       	call   c0105619 <get_page>
c01058ed:	85 c0                	test   %eax,%eax
c01058ef:	74 24                	je     c0105915 <check_pgdir+0xb6>
c01058f1:	c7 44 24 0c 2c 7f 10 	movl   $0xc0107f2c,0xc(%esp)
c01058f8:	c0 
c01058f9:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105900:	c0 
c0105901:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0105908:	00 
c0105909:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105910:	e8 bb b3 ff ff       	call   c0100cd0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105915:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010591c:	e8 c3 f4 ff ff       	call   c0104de4 <alloc_pages>
c0105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105924:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105929:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105930:	00 
c0105931:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105938:	00 
c0105939:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010593c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105940:	89 04 24             	mov    %eax,(%esp)
c0105943:	e8 dc fd ff ff       	call   c0105724 <page_insert>
c0105948:	85 c0                	test   %eax,%eax
c010594a:	74 24                	je     c0105970 <check_pgdir+0x111>
c010594c:	c7 44 24 0c 54 7f 10 	movl   $0xc0107f54,0xc(%esp)
c0105953:	c0 
c0105954:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c010595b:	c0 
c010595c:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0105963:	00 
c0105964:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010596b:	e8 60 b3 ff ff       	call   c0100cd0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105970:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105975:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010597c:	00 
c010597d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105984:	00 
c0105985:	89 04 24             	mov    %eax,(%esp)
c0105988:	e8 e9 fa ff ff       	call   c0105476 <get_pte>
c010598d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105990:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105994:	75 24                	jne    c01059ba <check_pgdir+0x15b>
c0105996:	c7 44 24 0c 80 7f 10 	movl   $0xc0107f80,0xc(%esp)
c010599d:	c0 
c010599e:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c01059a5:	c0 
c01059a6:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c01059ad:	00 
c01059ae:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01059b5:	e8 16 b3 ff ff       	call   c0100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
c01059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059bd:	8b 00                	mov    (%eax),%eax
c01059bf:	89 04 24             	mov    %eax,(%esp)
c01059c2:	e8 b3 f1 ff ff       	call   c0104b7a <pte2page>
c01059c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01059ca:	74 24                	je     c01059f0 <check_pgdir+0x191>
c01059cc:	c7 44 24 0c ad 7f 10 	movl   $0xc0107fad,0xc(%esp)
c01059d3:	c0 
c01059d4:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c01059db:	c0 
c01059dc:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c01059e3:	00 
c01059e4:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01059eb:	e8 e0 b2 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p1) == 1);
c01059f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f3:	89 04 24             	mov    %eax,(%esp)
c01059f6:	e8 d9 f1 ff ff       	call   c0104bd4 <page_ref>
c01059fb:	83 f8 01             	cmp    $0x1,%eax
c01059fe:	74 24                	je     c0105a24 <check_pgdir+0x1c5>
c0105a00:	c7 44 24 0c c3 7f 10 	movl   $0xc0107fc3,0xc(%esp)
c0105a07:	c0 
c0105a08:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105a0f:	c0 
c0105a10:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0105a17:	00 
c0105a18:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105a1f:	e8 ac b2 ff ff       	call   c0100cd0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105a24:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105a29:	8b 00                	mov    (%eax),%eax
c0105a2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a36:	c1 e8 0c             	shr    $0xc,%eax
c0105a39:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a3c:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0105a41:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105a44:	72 23                	jb     c0105a69 <check_pgdir+0x20a>
c0105a46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a49:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a4d:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c0105a54:	c0 
c0105a55:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0105a5c:	00 
c0105a5d:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105a64:	e8 67 b2 ff ff       	call   c0100cd0 <__panic>
c0105a69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a6c:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105a71:	83 c0 04             	add    $0x4,%eax
c0105a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105a77:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105a7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a83:	00 
c0105a84:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105a8b:	00 
c0105a8c:	89 04 24             	mov    %eax,(%esp)
c0105a8f:	e8 e2 f9 ff ff       	call   c0105476 <get_pte>
c0105a94:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105a97:	74 24                	je     c0105abd <check_pgdir+0x25e>
c0105a99:	c7 44 24 0c d8 7f 10 	movl   $0xc0107fd8,0xc(%esp)
c0105aa0:	c0 
c0105aa1:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105aa8:	c0 
c0105aa9:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0105ab0:	00 
c0105ab1:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105ab8:	e8 13 b2 ff ff       	call   c0100cd0 <__panic>

    p2 = alloc_page();
c0105abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ac4:	e8 1b f3 ff ff       	call   c0104de4 <alloc_pages>
c0105ac9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105acc:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105ad1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105ad8:	00 
c0105ad9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105ae0:	00 
c0105ae1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ae8:	89 04 24             	mov    %eax,(%esp)
c0105aeb:	e8 34 fc ff ff       	call   c0105724 <page_insert>
c0105af0:	85 c0                	test   %eax,%eax
c0105af2:	74 24                	je     c0105b18 <check_pgdir+0x2b9>
c0105af4:	c7 44 24 0c 00 80 10 	movl   $0xc0108000,0xc(%esp)
c0105afb:	c0 
c0105afc:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105b03:	c0 
c0105b04:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0105b0b:	00 
c0105b0c:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105b13:	e8 b8 b1 ff ff       	call   c0100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105b18:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105b1d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b24:	00 
c0105b25:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105b2c:	00 
c0105b2d:	89 04 24             	mov    %eax,(%esp)
c0105b30:	e8 41 f9 ff ff       	call   c0105476 <get_pte>
c0105b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105b3c:	75 24                	jne    c0105b62 <check_pgdir+0x303>
c0105b3e:	c7 44 24 0c 38 80 10 	movl   $0xc0108038,0xc(%esp)
c0105b45:	c0 
c0105b46:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105b4d:	c0 
c0105b4e:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0105b55:	00 
c0105b56:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105b5d:	e8 6e b1 ff ff       	call   c0100cd0 <__panic>
    assert(*ptep & PTE_U);
c0105b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b65:	8b 00                	mov    (%eax),%eax
c0105b67:	83 e0 04             	and    $0x4,%eax
c0105b6a:	85 c0                	test   %eax,%eax
c0105b6c:	75 24                	jne    c0105b92 <check_pgdir+0x333>
c0105b6e:	c7 44 24 0c 68 80 10 	movl   $0xc0108068,0xc(%esp)
c0105b75:	c0 
c0105b76:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105b7d:	c0 
c0105b7e:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0105b85:	00 
c0105b86:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105b8d:	e8 3e b1 ff ff       	call   c0100cd0 <__panic>
    assert(*ptep & PTE_W);
c0105b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b95:	8b 00                	mov    (%eax),%eax
c0105b97:	83 e0 02             	and    $0x2,%eax
c0105b9a:	85 c0                	test   %eax,%eax
c0105b9c:	75 24                	jne    c0105bc2 <check_pgdir+0x363>
c0105b9e:	c7 44 24 0c 76 80 10 	movl   $0xc0108076,0xc(%esp)
c0105ba5:	c0 
c0105ba6:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105bad:	c0 
c0105bae:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0105bb5:	00 
c0105bb6:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105bbd:	e8 0e b1 ff ff       	call   c0100cd0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105bc2:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105bc7:	8b 00                	mov    (%eax),%eax
c0105bc9:	83 e0 04             	and    $0x4,%eax
c0105bcc:	85 c0                	test   %eax,%eax
c0105bce:	75 24                	jne    c0105bf4 <check_pgdir+0x395>
c0105bd0:	c7 44 24 0c 84 80 10 	movl   $0xc0108084,0xc(%esp)
c0105bd7:	c0 
c0105bd8:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105bdf:	c0 
c0105be0:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0105be7:	00 
c0105be8:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105bef:	e8 dc b0 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 1);
c0105bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bf7:	89 04 24             	mov    %eax,(%esp)
c0105bfa:	e8 d5 ef ff ff       	call   c0104bd4 <page_ref>
c0105bff:	83 f8 01             	cmp    $0x1,%eax
c0105c02:	74 24                	je     c0105c28 <check_pgdir+0x3c9>
c0105c04:	c7 44 24 0c 9a 80 10 	movl   $0xc010809a,0xc(%esp)
c0105c0b:	c0 
c0105c0c:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105c13:	c0 
c0105c14:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0105c1b:	00 
c0105c1c:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105c23:	e8 a8 b0 ff ff       	call   c0100cd0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105c28:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105c2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105c34:	00 
c0105c35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105c3c:	00 
c0105c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c40:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c44:	89 04 24             	mov    %eax,(%esp)
c0105c47:	e8 d8 fa ff ff       	call   c0105724 <page_insert>
c0105c4c:	85 c0                	test   %eax,%eax
c0105c4e:	74 24                	je     c0105c74 <check_pgdir+0x415>
c0105c50:	c7 44 24 0c ac 80 10 	movl   $0xc01080ac,0xc(%esp)
c0105c57:	c0 
c0105c58:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105c5f:	c0 
c0105c60:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0105c67:	00 
c0105c68:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105c6f:	e8 5c b0 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p1) == 2);
c0105c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c77:	89 04 24             	mov    %eax,(%esp)
c0105c7a:	e8 55 ef ff ff       	call   c0104bd4 <page_ref>
c0105c7f:	83 f8 02             	cmp    $0x2,%eax
c0105c82:	74 24                	je     c0105ca8 <check_pgdir+0x449>
c0105c84:	c7 44 24 0c d8 80 10 	movl   $0xc01080d8,0xc(%esp)
c0105c8b:	c0 
c0105c8c:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105c93:	c0 
c0105c94:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0105c9b:	00 
c0105c9c:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105ca3:	e8 28 b0 ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0105ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cab:	89 04 24             	mov    %eax,(%esp)
c0105cae:	e8 21 ef ff ff       	call   c0104bd4 <page_ref>
c0105cb3:	85 c0                	test   %eax,%eax
c0105cb5:	74 24                	je     c0105cdb <check_pgdir+0x47c>
c0105cb7:	c7 44 24 0c ea 80 10 	movl   $0xc01080ea,0xc(%esp)
c0105cbe:	c0 
c0105cbf:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105cc6:	c0 
c0105cc7:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0105cce:	00 
c0105ccf:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105cd6:	e8 f5 af ff ff       	call   c0100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105cdb:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ce7:	00 
c0105ce8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105cef:	00 
c0105cf0:	89 04 24             	mov    %eax,(%esp)
c0105cf3:	e8 7e f7 ff ff       	call   c0105476 <get_pte>
c0105cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105cff:	75 24                	jne    c0105d25 <check_pgdir+0x4c6>
c0105d01:	c7 44 24 0c 38 80 10 	movl   $0xc0108038,0xc(%esp)
c0105d08:	c0 
c0105d09:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105d10:	c0 
c0105d11:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0105d18:	00 
c0105d19:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105d20:	e8 ab af ff ff       	call   c0100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
c0105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d28:	8b 00                	mov    (%eax),%eax
c0105d2a:	89 04 24             	mov    %eax,(%esp)
c0105d2d:	e8 48 ee ff ff       	call   c0104b7a <pte2page>
c0105d32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105d35:	74 24                	je     c0105d5b <check_pgdir+0x4fc>
c0105d37:	c7 44 24 0c ad 7f 10 	movl   $0xc0107fad,0xc(%esp)
c0105d3e:	c0 
c0105d3f:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105d46:	c0 
c0105d47:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0105d4e:	00 
c0105d4f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105d56:	e8 75 af ff ff       	call   c0100cd0 <__panic>
    assert((*ptep & PTE_U) == 0);
c0105d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d5e:	8b 00                	mov    (%eax),%eax
c0105d60:	83 e0 04             	and    $0x4,%eax
c0105d63:	85 c0                	test   %eax,%eax
c0105d65:	74 24                	je     c0105d8b <check_pgdir+0x52c>
c0105d67:	c7 44 24 0c fc 80 10 	movl   $0xc01080fc,0xc(%esp)
c0105d6e:	c0 
c0105d6f:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105d76:	c0 
c0105d77:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0105d7e:	00 
c0105d7f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105d86:	e8 45 af ff ff       	call   c0100cd0 <__panic>

    page_remove(boot_pgdir, 0x0);
c0105d8b:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105d90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105d97:	00 
c0105d98:	89 04 24             	mov    %eax,(%esp)
c0105d9b:	e8 3d f9 ff ff       	call   c01056dd <page_remove>
    assert(page_ref(p1) == 1);
c0105da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105da3:	89 04 24             	mov    %eax,(%esp)
c0105da6:	e8 29 ee ff ff       	call   c0104bd4 <page_ref>
c0105dab:	83 f8 01             	cmp    $0x1,%eax
c0105dae:	74 24                	je     c0105dd4 <check_pgdir+0x575>
c0105db0:	c7 44 24 0c c3 7f 10 	movl   $0xc0107fc3,0xc(%esp)
c0105db7:	c0 
c0105db8:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105dbf:	c0 
c0105dc0:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0105dc7:	00 
c0105dc8:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105dcf:	e8 fc ae ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0105dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dd7:	89 04 24             	mov    %eax,(%esp)
c0105dda:	e8 f5 ed ff ff       	call   c0104bd4 <page_ref>
c0105ddf:	85 c0                	test   %eax,%eax
c0105de1:	74 24                	je     c0105e07 <check_pgdir+0x5a8>
c0105de3:	c7 44 24 0c ea 80 10 	movl   $0xc01080ea,0xc(%esp)
c0105dea:	c0 
c0105deb:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105df2:	c0 
c0105df3:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105dfa:	00 
c0105dfb:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105e02:	e8 c9 ae ff ff       	call   c0100cd0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105e07:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105e0c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105e13:	00 
c0105e14:	89 04 24             	mov    %eax,(%esp)
c0105e17:	e8 c1 f8 ff ff       	call   c01056dd <page_remove>
    assert(page_ref(p1) == 0);
c0105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e1f:	89 04 24             	mov    %eax,(%esp)
c0105e22:	e8 ad ed ff ff       	call   c0104bd4 <page_ref>
c0105e27:	85 c0                	test   %eax,%eax
c0105e29:	74 24                	je     c0105e4f <check_pgdir+0x5f0>
c0105e2b:	c7 44 24 0c 11 81 10 	movl   $0xc0108111,0xc(%esp)
c0105e32:	c0 
c0105e33:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105e3a:	c0 
c0105e3b:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0105e42:	00 
c0105e43:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105e4a:	e8 81 ae ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p2) == 0);
c0105e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e52:	89 04 24             	mov    %eax,(%esp)
c0105e55:	e8 7a ed ff ff       	call   c0104bd4 <page_ref>
c0105e5a:	85 c0                	test   %eax,%eax
c0105e5c:	74 24                	je     c0105e82 <check_pgdir+0x623>
c0105e5e:	c7 44 24 0c ea 80 10 	movl   $0xc01080ea,0xc(%esp)
c0105e65:	c0 
c0105e66:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105e6d:	c0 
c0105e6e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0105e75:	00 
c0105e76:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105e7d:	e8 4e ae ff ff       	call   c0100cd0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105e82:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105e87:	8b 00                	mov    (%eax),%eax
c0105e89:	89 04 24             	mov    %eax,(%esp)
c0105e8c:	e8 29 ed ff ff       	call   c0104bba <pde2page>
c0105e91:	89 04 24             	mov    %eax,(%esp)
c0105e94:	e8 3b ed ff ff       	call   c0104bd4 <page_ref>
c0105e99:	83 f8 01             	cmp    $0x1,%eax
c0105e9c:	74 24                	je     c0105ec2 <check_pgdir+0x663>
c0105e9e:	c7 44 24 0c 24 81 10 	movl   $0xc0108124,0xc(%esp)
c0105ea5:	c0 
c0105ea6:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105ead:	c0 
c0105eae:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105eb5:	00 
c0105eb6:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105ebd:	e8 0e ae ff ff       	call   c0100cd0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105ec2:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105ec7:	8b 00                	mov    (%eax),%eax
c0105ec9:	89 04 24             	mov    %eax,(%esp)
c0105ecc:	e8 e9 ec ff ff       	call   c0104bba <pde2page>
c0105ed1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ed8:	00 
c0105ed9:	89 04 24             	mov    %eax,(%esp)
c0105edc:	e8 3d ef ff ff       	call   c0104e1e <free_pages>
    boot_pgdir[0] = 0;
c0105ee1:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105ee6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105eec:	c7 04 24 4b 81 10 c0 	movl   $0xc010814b,(%esp)
c0105ef3:	e8 5e a4 ff ff       	call   c0100356 <cprintf>
}
c0105ef8:	90                   	nop
c0105ef9:	89 ec                	mov    %ebp,%esp
c0105efb:	5d                   	pop    %ebp
c0105efc:	c3                   	ret    

c0105efd <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105efd:	55                   	push   %ebp
c0105efe:	89 e5                	mov    %esp,%ebp
c0105f00:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105f03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105f0a:	e9 ca 00 00 00       	jmp    c0105fd9 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f18:	c1 e8 0c             	shr    $0xc,%eax
c0105f1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105f1e:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0105f23:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105f26:	72 23                	jb     c0105f4b <check_boot_pgdir+0x4e>
c0105f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f2f:	c7 44 24 08 90 7d 10 	movl   $0xc0107d90,0x8(%esp)
c0105f36:	c0 
c0105f37:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105f3e:	00 
c0105f3f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105f46:	e8 85 ad ff ff       	call   c0100cd0 <__panic>
c0105f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f4e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105f53:	89 c2                	mov    %eax,%edx
c0105f55:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105f61:	00 
c0105f62:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f66:	89 04 24             	mov    %eax,(%esp)
c0105f69:	e8 08 f5 ff ff       	call   c0105476 <get_pte>
c0105f6e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105f71:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105f75:	75 24                	jne    c0105f9b <check_boot_pgdir+0x9e>
c0105f77:	c7 44 24 0c 68 81 10 	movl   $0xc0108168,0xc(%esp)
c0105f7e:	c0 
c0105f7f:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105f86:	c0 
c0105f87:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105f8e:	00 
c0105f8f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105f96:	e8 35 ad ff ff       	call   c0100cd0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f9e:	8b 00                	mov    (%eax),%eax
c0105fa0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105fa5:	89 c2                	mov    %eax,%edx
c0105fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105faa:	39 c2                	cmp    %eax,%edx
c0105fac:	74 24                	je     c0105fd2 <check_boot_pgdir+0xd5>
c0105fae:	c7 44 24 0c a5 81 10 	movl   $0xc01081a5,0xc(%esp)
c0105fb5:	c0 
c0105fb6:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0105fbd:	c0 
c0105fbe:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105fc5:	00 
c0105fc6:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0105fcd:	e8 fe ac ff ff       	call   c0100cd0 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0105fd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fdc:	a1 04 ef 11 c0       	mov    0xc011ef04,%eax
c0105fe1:	39 c2                	cmp    %eax,%edx
c0105fe3:	0f 82 26 ff ff ff    	jb     c0105f0f <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105fe9:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0105fee:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105ff3:	8b 00                	mov    (%eax),%eax
c0105ff5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105ffa:	89 c2                	mov    %eax,%edx
c0105ffc:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0106001:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106004:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010600b:	77 23                	ja     c0106030 <check_boot_pgdir+0x133>
c010600d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106010:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106014:	c7 44 24 08 34 7e 10 	movl   $0xc0107e34,0x8(%esp)
c010601b:	c0 
c010601c:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0106023:	00 
c0106024:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010602b:	e8 a0 ac ff ff       	call   c0100cd0 <__panic>
c0106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106033:	05 00 00 00 40       	add    $0x40000000,%eax
c0106038:	39 d0                	cmp    %edx,%eax
c010603a:	74 24                	je     c0106060 <check_boot_pgdir+0x163>
c010603c:	c7 44 24 0c bc 81 10 	movl   $0xc01081bc,0xc(%esp)
c0106043:	c0 
c0106044:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c010604b:	c0 
c010604c:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0106053:	00 
c0106054:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010605b:	e8 70 ac ff ff       	call   c0100cd0 <__panic>

    assert(boot_pgdir[0] == 0);
c0106060:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0106065:	8b 00                	mov    (%eax),%eax
c0106067:	85 c0                	test   %eax,%eax
c0106069:	74 24                	je     c010608f <check_boot_pgdir+0x192>
c010606b:	c7 44 24 0c f0 81 10 	movl   $0xc01081f0,0xc(%esp)
c0106072:	c0 
c0106073:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c010607a:	c0 
c010607b:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0106082:	00 
c0106083:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c010608a:	e8 41 ac ff ff       	call   c0100cd0 <__panic>

    struct Page *p;
    p = alloc_page();
c010608f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106096:	e8 49 ed ff ff       	call   c0104de4 <alloc_pages>
c010609b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010609e:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c01060a3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01060aa:	00 
c01060ab:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01060b2:	00 
c01060b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060ba:	89 04 24             	mov    %eax,(%esp)
c01060bd:	e8 62 f6 ff ff       	call   c0105724 <page_insert>
c01060c2:	85 c0                	test   %eax,%eax
c01060c4:	74 24                	je     c01060ea <check_boot_pgdir+0x1ed>
c01060c6:	c7 44 24 0c 04 82 10 	movl   $0xc0108204,0xc(%esp)
c01060cd:	c0 
c01060ce:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c01060d5:	c0 
c01060d6:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c01060dd:	00 
c01060de:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01060e5:	e8 e6 ab ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p) == 1);
c01060ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060ed:	89 04 24             	mov    %eax,(%esp)
c01060f0:	e8 df ea ff ff       	call   c0104bd4 <page_ref>
c01060f5:	83 f8 01             	cmp    $0x1,%eax
c01060f8:	74 24                	je     c010611e <check_boot_pgdir+0x221>
c01060fa:	c7 44 24 0c 32 82 10 	movl   $0xc0108232,0xc(%esp)
c0106101:	c0 
c0106102:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0106109:	c0 
c010610a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0106111:	00 
c0106112:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0106119:	e8 b2 ab ff ff       	call   c0100cd0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010611e:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0106123:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010612a:	00 
c010612b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106132:	00 
c0106133:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106136:	89 54 24 04          	mov    %edx,0x4(%esp)
c010613a:	89 04 24             	mov    %eax,(%esp)
c010613d:	e8 e2 f5 ff ff       	call   c0105724 <page_insert>
c0106142:	85 c0                	test   %eax,%eax
c0106144:	74 24                	je     c010616a <check_boot_pgdir+0x26d>
c0106146:	c7 44 24 0c 44 82 10 	movl   $0xc0108244,0xc(%esp)
c010614d:	c0 
c010614e:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0106155:	c0 
c0106156:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c010615d:	00 
c010615e:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0106165:	e8 66 ab ff ff       	call   c0100cd0 <__panic>
    assert(page_ref(p) == 2);
c010616a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010616d:	89 04 24             	mov    %eax,(%esp)
c0106170:	e8 5f ea ff ff       	call   c0104bd4 <page_ref>
c0106175:	83 f8 02             	cmp    $0x2,%eax
c0106178:	74 24                	je     c010619e <check_boot_pgdir+0x2a1>
c010617a:	c7 44 24 0c 7b 82 10 	movl   $0xc010827b,0xc(%esp)
c0106181:	c0 
c0106182:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0106189:	c0 
c010618a:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0106191:	00 
c0106192:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0106199:	e8 32 ab ff ff       	call   c0100cd0 <__panic>

    const char *str = "ucore: Hello world!!";
c010619e:	c7 45 e8 8c 82 10 c0 	movl   $0xc010828c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c01061a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061ac:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01061b3:	e8 fc 09 00 00       	call   c0106bb4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01061b8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01061bf:	00 
c01061c0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01061c7:	e8 60 0a 00 00       	call   c0106c2c <strcmp>
c01061cc:	85 c0                	test   %eax,%eax
c01061ce:	74 24                	je     c01061f4 <check_boot_pgdir+0x2f7>
c01061d0:	c7 44 24 0c a4 82 10 	movl   $0xc01082a4,0xc(%esp)
c01061d7:	c0 
c01061d8:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c01061df:	c0 
c01061e0:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c01061e7:	00 
c01061e8:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c01061ef:	e8 dc aa ff ff       	call   c0100cd0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01061f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061f7:	89 04 24             	mov    %eax,(%esp)
c01061fa:	e8 25 e9 ff ff       	call   c0104b24 <page2kva>
c01061ff:	05 00 01 00 00       	add    $0x100,%eax
c0106204:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106207:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010620e:	e8 47 09 00 00       	call   c0106b5a <strlen>
c0106213:	85 c0                	test   %eax,%eax
c0106215:	74 24                	je     c010623b <check_boot_pgdir+0x33e>
c0106217:	c7 44 24 0c dc 82 10 	movl   $0xc01082dc,0xc(%esp)
c010621e:	c0 
c010621f:	c7 44 24 08 7d 7e 10 	movl   $0xc0107e7d,0x8(%esp)
c0106226:	c0 
c0106227:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c010622e:	00 
c010622f:	c7 04 24 58 7e 10 c0 	movl   $0xc0107e58,(%esp)
c0106236:	e8 95 aa ff ff       	call   c0100cd0 <__panic>

    free_page(p);
c010623b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106242:	00 
c0106243:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106246:	89 04 24             	mov    %eax,(%esp)
c0106249:	e8 d0 eb ff ff       	call   c0104e1e <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010624e:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0106253:	8b 00                	mov    (%eax),%eax
c0106255:	89 04 24             	mov    %eax,(%esp)
c0106258:	e8 5d e9 ff ff       	call   c0104bba <pde2page>
c010625d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106264:	00 
c0106265:	89 04 24             	mov    %eax,(%esp)
c0106268:	e8 b1 eb ff ff       	call   c0104e1e <free_pages>
    boot_pgdir[0] = 0;
c010626d:	a1 e0 b9 11 c0       	mov    0xc011b9e0,%eax
c0106272:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106278:	c7 04 24 00 83 10 c0 	movl   $0xc0108300,(%esp)
c010627f:	e8 d2 a0 ff ff       	call   c0100356 <cprintf>
}
c0106284:	90                   	nop
c0106285:	89 ec                	mov    %ebp,%esp
c0106287:	5d                   	pop    %ebp
c0106288:	c3                   	ret    

c0106289 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106289:	55                   	push   %ebp
c010628a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010628c:	8b 45 08             	mov    0x8(%ebp),%eax
c010628f:	83 e0 04             	and    $0x4,%eax
c0106292:	85 c0                	test   %eax,%eax
c0106294:	74 04                	je     c010629a <perm2str+0x11>
c0106296:	b0 75                	mov    $0x75,%al
c0106298:	eb 02                	jmp    c010629c <perm2str+0x13>
c010629a:	b0 2d                	mov    $0x2d,%al
c010629c:	a2 88 ef 11 c0       	mov    %al,0xc011ef88
    str[1] = 'r';
c01062a1:	c6 05 89 ef 11 c0 72 	movb   $0x72,0xc011ef89
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01062a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01062ab:	83 e0 02             	and    $0x2,%eax
c01062ae:	85 c0                	test   %eax,%eax
c01062b0:	74 04                	je     c01062b6 <perm2str+0x2d>
c01062b2:	b0 77                	mov    $0x77,%al
c01062b4:	eb 02                	jmp    c01062b8 <perm2str+0x2f>
c01062b6:	b0 2d                	mov    $0x2d,%al
c01062b8:	a2 8a ef 11 c0       	mov    %al,0xc011ef8a
    str[3] = '\0';
c01062bd:	c6 05 8b ef 11 c0 00 	movb   $0x0,0xc011ef8b
    return str;
c01062c4:	b8 88 ef 11 c0       	mov    $0xc011ef88,%eax
}
c01062c9:	5d                   	pop    %ebp
c01062ca:	c3                   	ret    

c01062cb <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01062cb:	55                   	push   %ebp
c01062cc:	89 e5                	mov    %esp,%ebp
c01062ce:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01062d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01062d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01062d7:	72 0d                	jb     c01062e6 <get_pgtable_items+0x1b>
        return 0;
c01062d9:	b8 00 00 00 00       	mov    $0x0,%eax
c01062de:	e9 98 00 00 00       	jmp    c010637b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01062e3:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01062e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01062e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01062ec:	73 18                	jae    c0106306 <get_pgtable_items+0x3b>
c01062ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01062f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01062f8:	8b 45 14             	mov    0x14(%ebp),%eax
c01062fb:	01 d0                	add    %edx,%eax
c01062fd:	8b 00                	mov    (%eax),%eax
c01062ff:	83 e0 01             	and    $0x1,%eax
c0106302:	85 c0                	test   %eax,%eax
c0106304:	74 dd                	je     c01062e3 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106306:	8b 45 10             	mov    0x10(%ebp),%eax
c0106309:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010630c:	73 68                	jae    c0106376 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c010630e:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106312:	74 08                	je     c010631c <get_pgtable_items+0x51>
            *left_store = start;
c0106314:	8b 45 18             	mov    0x18(%ebp),%eax
c0106317:	8b 55 10             	mov    0x10(%ebp),%edx
c010631a:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010631c:	8b 45 10             	mov    0x10(%ebp),%eax
c010631f:	8d 50 01             	lea    0x1(%eax),%edx
c0106322:	89 55 10             	mov    %edx,0x10(%ebp)
c0106325:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010632c:	8b 45 14             	mov    0x14(%ebp),%eax
c010632f:	01 d0                	add    %edx,%eax
c0106331:	8b 00                	mov    (%eax),%eax
c0106333:	83 e0 07             	and    $0x7,%eax
c0106336:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106339:	eb 03                	jmp    c010633e <get_pgtable_items+0x73>
            start ++;
c010633b:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010633e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106341:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106344:	73 1d                	jae    c0106363 <get_pgtable_items+0x98>
c0106346:	8b 45 10             	mov    0x10(%ebp),%eax
c0106349:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106350:	8b 45 14             	mov    0x14(%ebp),%eax
c0106353:	01 d0                	add    %edx,%eax
c0106355:	8b 00                	mov    (%eax),%eax
c0106357:	83 e0 07             	and    $0x7,%eax
c010635a:	89 c2                	mov    %eax,%edx
c010635c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010635f:	39 c2                	cmp    %eax,%edx
c0106361:	74 d8                	je     c010633b <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0106363:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106367:	74 08                	je     c0106371 <get_pgtable_items+0xa6>
            *right_store = start;
c0106369:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010636c:	8b 55 10             	mov    0x10(%ebp),%edx
c010636f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106371:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106374:	eb 05                	jmp    c010637b <get_pgtable_items+0xb0>
    }
    return 0;
c0106376:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010637b:	89 ec                	mov    %ebp,%esp
c010637d:	5d                   	pop    %ebp
c010637e:	c3                   	ret    

c010637f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010637f:	55                   	push   %ebp
c0106380:	89 e5                	mov    %esp,%ebp
c0106382:	57                   	push   %edi
c0106383:	56                   	push   %esi
c0106384:	53                   	push   %ebx
c0106385:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106388:	c7 04 24 20 83 10 c0 	movl   $0xc0108320,(%esp)
c010638f:	e8 c2 9f ff ff       	call   c0100356 <cprintf>
    size_t left, right = 0, perm;
c0106394:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010639b:	e9 f2 00 00 00       	jmp    c0106492 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01063a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063a3:	89 04 24             	mov    %eax,(%esp)
c01063a6:	e8 de fe ff ff       	call   c0106289 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01063ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01063b1:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01063b3:	89 d6                	mov    %edx,%esi
c01063b5:	c1 e6 16             	shl    $0x16,%esi
c01063b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063bb:	89 d3                	mov    %edx,%ebx
c01063bd:	c1 e3 16             	shl    $0x16,%ebx
c01063c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01063c3:	89 d1                	mov    %edx,%ecx
c01063c5:	c1 e1 16             	shl    $0x16,%ecx
c01063c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
c01063ce:	29 fa                	sub    %edi,%edx
c01063d0:	89 44 24 14          	mov    %eax,0x14(%esp)
c01063d4:	89 74 24 10          	mov    %esi,0x10(%esp)
c01063d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01063dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01063e0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063e4:	c7 04 24 51 83 10 c0 	movl   $0xc0108351,(%esp)
c01063eb:	e8 66 9f ff ff       	call   c0100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01063f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01063f3:	c1 e0 0a             	shl    $0xa,%eax
c01063f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01063f9:	eb 50                	jmp    c010644b <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01063fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063fe:	89 04 24             	mov    %eax,(%esp)
c0106401:	e8 83 fe ff ff       	call   c0106289 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106406:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106409:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010640c:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010640e:	89 d6                	mov    %edx,%esi
c0106410:	c1 e6 0c             	shl    $0xc,%esi
c0106413:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106416:	89 d3                	mov    %edx,%ebx
c0106418:	c1 e3 0c             	shl    $0xc,%ebx
c010641b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010641e:	89 d1                	mov    %edx,%ecx
c0106420:	c1 e1 0c             	shl    $0xc,%ecx
c0106423:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106426:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106429:	29 fa                	sub    %edi,%edx
c010642b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010642f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106433:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106437:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010643b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010643f:	c7 04 24 70 83 10 c0 	movl   $0xc0108370,(%esp)
c0106446:	e8 0b 9f ff ff       	call   c0100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010644b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0106450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106453:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106456:	89 d3                	mov    %edx,%ebx
c0106458:	c1 e3 0a             	shl    $0xa,%ebx
c010645b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010645e:	89 d1                	mov    %edx,%ecx
c0106460:	c1 e1 0a             	shl    $0xa,%ecx
c0106463:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0106466:	89 54 24 14          	mov    %edx,0x14(%esp)
c010646a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010646d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106471:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106475:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106479:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010647d:	89 0c 24             	mov    %ecx,(%esp)
c0106480:	e8 46 fe ff ff       	call   c01062cb <get_pgtable_items>
c0106485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010648c:	0f 85 69 ff ff ff    	jne    c01063fb <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106492:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0106497:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010649a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010649d:	89 54 24 14          	mov    %edx,0x14(%esp)
c01064a1:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01064a4:	89 54 24 10          	mov    %edx,0x10(%esp)
c01064a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01064ac:	89 44 24 08          	mov    %eax,0x8(%esp)
c01064b0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01064b7:	00 
c01064b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01064bf:	e8 07 fe ff ff       	call   c01062cb <get_pgtable_items>
c01064c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01064c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01064cb:	0f 85 cf fe ff ff    	jne    c01063a0 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01064d1:	c7 04 24 94 83 10 c0 	movl   $0xc0108394,(%esp)
c01064d8:	e8 79 9e ff ff       	call   c0100356 <cprintf>
}
c01064dd:	90                   	nop
c01064de:	83 c4 4c             	add    $0x4c,%esp
c01064e1:	5b                   	pop    %ebx
c01064e2:	5e                   	pop    %esi
c01064e3:	5f                   	pop    %edi
c01064e4:	5d                   	pop    %ebp
c01064e5:	c3                   	ret    

c01064e6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01064e6:	55                   	push   %ebp
c01064e7:	89 e5                	mov    %esp,%ebp
c01064e9:	83 ec 58             	sub    $0x58,%esp
c01064ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01064ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01064f2:	8b 45 14             	mov    0x14(%ebp),%eax
c01064f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01064f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01064fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01064fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106501:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106504:	8b 45 18             	mov    0x18(%ebp),%eax
c0106507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010650a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010650d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106510:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106513:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106516:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106519:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010651c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106520:	74 1c                	je     c010653e <printnum+0x58>
c0106522:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106525:	ba 00 00 00 00       	mov    $0x0,%edx
c010652a:	f7 75 e4             	divl   -0x1c(%ebp)
c010652d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0106530:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106533:	ba 00 00 00 00       	mov    $0x0,%edx
c0106538:	f7 75 e4             	divl   -0x1c(%ebp)
c010653b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010653e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106541:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106544:	f7 75 e4             	divl   -0x1c(%ebp)
c0106547:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010654a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010654d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106550:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106553:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106556:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106559:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010655c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010655f:	8b 45 18             	mov    0x18(%ebp),%eax
c0106562:	ba 00 00 00 00       	mov    $0x0,%edx
c0106567:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010656a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010656d:	19 d1                	sbb    %edx,%ecx
c010656f:	72 4c                	jb     c01065bd <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106571:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106574:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106577:	8b 45 20             	mov    0x20(%ebp),%eax
c010657a:	89 44 24 18          	mov    %eax,0x18(%esp)
c010657e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106582:	8b 45 18             	mov    0x18(%ebp),%eax
c0106585:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106589:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010658c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010658f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106593:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106597:	8b 45 0c             	mov    0xc(%ebp),%eax
c010659a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010659e:	8b 45 08             	mov    0x8(%ebp),%eax
c01065a1:	89 04 24             	mov    %eax,(%esp)
c01065a4:	e8 3d ff ff ff       	call   c01064e6 <printnum>
c01065a9:	eb 1b                	jmp    c01065c6 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01065ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065b2:	8b 45 20             	mov    0x20(%ebp),%eax
c01065b5:	89 04 24             	mov    %eax,(%esp)
c01065b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01065bb:	ff d0                	call   *%eax
        while (-- width > 0)
c01065bd:	ff 4d 1c             	decl   0x1c(%ebp)
c01065c0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01065c4:	7f e5                	jg     c01065ab <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01065c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01065c9:	05 48 84 10 c0       	add    $0xc0108448,%eax
c01065ce:	0f b6 00             	movzbl (%eax),%eax
c01065d1:	0f be c0             	movsbl %al,%eax
c01065d4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01065d7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065db:	89 04 24             	mov    %eax,(%esp)
c01065de:	8b 45 08             	mov    0x8(%ebp),%eax
c01065e1:	ff d0                	call   *%eax
}
c01065e3:	90                   	nop
c01065e4:	89 ec                	mov    %ebp,%esp
c01065e6:	5d                   	pop    %ebp
c01065e7:	c3                   	ret    

c01065e8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01065e8:	55                   	push   %ebp
c01065e9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01065eb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01065ef:	7e 14                	jle    c0106605 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01065f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01065f4:	8b 00                	mov    (%eax),%eax
c01065f6:	8d 48 08             	lea    0x8(%eax),%ecx
c01065f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01065fc:	89 0a                	mov    %ecx,(%edx)
c01065fe:	8b 50 04             	mov    0x4(%eax),%edx
c0106601:	8b 00                	mov    (%eax),%eax
c0106603:	eb 30                	jmp    c0106635 <getuint+0x4d>
    }
    else if (lflag) {
c0106605:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106609:	74 16                	je     c0106621 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010660b:	8b 45 08             	mov    0x8(%ebp),%eax
c010660e:	8b 00                	mov    (%eax),%eax
c0106610:	8d 48 04             	lea    0x4(%eax),%ecx
c0106613:	8b 55 08             	mov    0x8(%ebp),%edx
c0106616:	89 0a                	mov    %ecx,(%edx)
c0106618:	8b 00                	mov    (%eax),%eax
c010661a:	ba 00 00 00 00       	mov    $0x0,%edx
c010661f:	eb 14                	jmp    c0106635 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106621:	8b 45 08             	mov    0x8(%ebp),%eax
c0106624:	8b 00                	mov    (%eax),%eax
c0106626:	8d 48 04             	lea    0x4(%eax),%ecx
c0106629:	8b 55 08             	mov    0x8(%ebp),%edx
c010662c:	89 0a                	mov    %ecx,(%edx)
c010662e:	8b 00                	mov    (%eax),%eax
c0106630:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106635:	5d                   	pop    %ebp
c0106636:	c3                   	ret    

c0106637 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0106637:	55                   	push   %ebp
c0106638:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010663a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010663e:	7e 14                	jle    c0106654 <getint+0x1d>
        return va_arg(*ap, long long);
c0106640:	8b 45 08             	mov    0x8(%ebp),%eax
c0106643:	8b 00                	mov    (%eax),%eax
c0106645:	8d 48 08             	lea    0x8(%eax),%ecx
c0106648:	8b 55 08             	mov    0x8(%ebp),%edx
c010664b:	89 0a                	mov    %ecx,(%edx)
c010664d:	8b 50 04             	mov    0x4(%eax),%edx
c0106650:	8b 00                	mov    (%eax),%eax
c0106652:	eb 28                	jmp    c010667c <getint+0x45>
    }
    else if (lflag) {
c0106654:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106658:	74 12                	je     c010666c <getint+0x35>
        return va_arg(*ap, long);
c010665a:	8b 45 08             	mov    0x8(%ebp),%eax
c010665d:	8b 00                	mov    (%eax),%eax
c010665f:	8d 48 04             	lea    0x4(%eax),%ecx
c0106662:	8b 55 08             	mov    0x8(%ebp),%edx
c0106665:	89 0a                	mov    %ecx,(%edx)
c0106667:	8b 00                	mov    (%eax),%eax
c0106669:	99                   	cltd   
c010666a:	eb 10                	jmp    c010667c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010666c:	8b 45 08             	mov    0x8(%ebp),%eax
c010666f:	8b 00                	mov    (%eax),%eax
c0106671:	8d 48 04             	lea    0x4(%eax),%ecx
c0106674:	8b 55 08             	mov    0x8(%ebp),%edx
c0106677:	89 0a                	mov    %ecx,(%edx)
c0106679:	8b 00                	mov    (%eax),%eax
c010667b:	99                   	cltd   
    }
}
c010667c:	5d                   	pop    %ebp
c010667d:	c3                   	ret    

c010667e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010667e:	55                   	push   %ebp
c010667f:	89 e5                	mov    %esp,%ebp
c0106681:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106684:	8d 45 14             	lea    0x14(%ebp),%eax
c0106687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010668d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106691:	8b 45 10             	mov    0x10(%ebp),%eax
c0106694:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010669b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010669f:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a2:	89 04 24             	mov    %eax,(%esp)
c01066a5:	e8 05 00 00 00       	call   c01066af <vprintfmt>
    va_end(ap);
}
c01066aa:	90                   	nop
c01066ab:	89 ec                	mov    %ebp,%esp
c01066ad:	5d                   	pop    %ebp
c01066ae:	c3                   	ret    

c01066af <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01066af:	55                   	push   %ebp
c01066b0:	89 e5                	mov    %esp,%ebp
c01066b2:	56                   	push   %esi
c01066b3:	53                   	push   %ebx
c01066b4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01066b7:	eb 17                	jmp    c01066d0 <vprintfmt+0x21>
            if (ch == '\0') {
c01066b9:	85 db                	test   %ebx,%ebx
c01066bb:	0f 84 bf 03 00 00    	je     c0106a80 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01066c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01066c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066c8:	89 1c 24             	mov    %ebx,(%esp)
c01066cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01066ce:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01066d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01066d3:	8d 50 01             	lea    0x1(%eax),%edx
c01066d6:	89 55 10             	mov    %edx,0x10(%ebp)
c01066d9:	0f b6 00             	movzbl (%eax),%eax
c01066dc:	0f b6 d8             	movzbl %al,%ebx
c01066df:	83 fb 25             	cmp    $0x25,%ebx
c01066e2:	75 d5                	jne    c01066b9 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01066e4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01066e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01066ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01066f5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01066fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01066ff:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106702:	8b 45 10             	mov    0x10(%ebp),%eax
c0106705:	8d 50 01             	lea    0x1(%eax),%edx
c0106708:	89 55 10             	mov    %edx,0x10(%ebp)
c010670b:	0f b6 00             	movzbl (%eax),%eax
c010670e:	0f b6 d8             	movzbl %al,%ebx
c0106711:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106714:	83 f8 55             	cmp    $0x55,%eax
c0106717:	0f 87 37 03 00 00    	ja     c0106a54 <vprintfmt+0x3a5>
c010671d:	8b 04 85 6c 84 10 c0 	mov    -0x3fef7b94(,%eax,4),%eax
c0106724:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106726:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010672a:	eb d6                	jmp    c0106702 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010672c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106730:	eb d0                	jmp    c0106702 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106732:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106739:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010673c:	89 d0                	mov    %edx,%eax
c010673e:	c1 e0 02             	shl    $0x2,%eax
c0106741:	01 d0                	add    %edx,%eax
c0106743:	01 c0                	add    %eax,%eax
c0106745:	01 d8                	add    %ebx,%eax
c0106747:	83 e8 30             	sub    $0x30,%eax
c010674a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010674d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106750:	0f b6 00             	movzbl (%eax),%eax
c0106753:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106756:	83 fb 2f             	cmp    $0x2f,%ebx
c0106759:	7e 38                	jle    c0106793 <vprintfmt+0xe4>
c010675b:	83 fb 39             	cmp    $0x39,%ebx
c010675e:	7f 33                	jg     c0106793 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0106760:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0106763:	eb d4                	jmp    c0106739 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106765:	8b 45 14             	mov    0x14(%ebp),%eax
c0106768:	8d 50 04             	lea    0x4(%eax),%edx
c010676b:	89 55 14             	mov    %edx,0x14(%ebp)
c010676e:	8b 00                	mov    (%eax),%eax
c0106770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106773:	eb 1f                	jmp    c0106794 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106775:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106779:	79 87                	jns    c0106702 <vprintfmt+0x53>
                width = 0;
c010677b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106782:	e9 7b ff ff ff       	jmp    c0106702 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106787:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010678e:	e9 6f ff ff ff       	jmp    c0106702 <vprintfmt+0x53>
            goto process_precision;
c0106793:	90                   	nop

        process_precision:
            if (width < 0)
c0106794:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106798:	0f 89 64 ff ff ff    	jns    c0106702 <vprintfmt+0x53>
                width = precision, precision = -1;
c010679e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01067a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01067ab:	e9 52 ff ff ff       	jmp    c0106702 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01067b0:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01067b3:	e9 4a ff ff ff       	jmp    c0106702 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01067b8:	8b 45 14             	mov    0x14(%ebp),%eax
c01067bb:	8d 50 04             	lea    0x4(%eax),%edx
c01067be:	89 55 14             	mov    %edx,0x14(%ebp)
c01067c1:	8b 00                	mov    (%eax),%eax
c01067c3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01067c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01067ca:	89 04 24             	mov    %eax,(%esp)
c01067cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d0:	ff d0                	call   *%eax
            break;
c01067d2:	e9 a4 02 00 00       	jmp    c0106a7b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01067d7:	8b 45 14             	mov    0x14(%ebp),%eax
c01067da:	8d 50 04             	lea    0x4(%eax),%edx
c01067dd:	89 55 14             	mov    %edx,0x14(%ebp)
c01067e0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01067e2:	85 db                	test   %ebx,%ebx
c01067e4:	79 02                	jns    c01067e8 <vprintfmt+0x139>
                err = -err;
c01067e6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01067e8:	83 fb 06             	cmp    $0x6,%ebx
c01067eb:	7f 0b                	jg     c01067f8 <vprintfmt+0x149>
c01067ed:	8b 34 9d 2c 84 10 c0 	mov    -0x3fef7bd4(,%ebx,4),%esi
c01067f4:	85 f6                	test   %esi,%esi
c01067f6:	75 23                	jne    c010681b <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01067f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01067fc:	c7 44 24 08 59 84 10 	movl   $0xc0108459,0x8(%esp)
c0106803:	c0 
c0106804:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106807:	89 44 24 04          	mov    %eax,0x4(%esp)
c010680b:	8b 45 08             	mov    0x8(%ebp),%eax
c010680e:	89 04 24             	mov    %eax,(%esp)
c0106811:	e8 68 fe ff ff       	call   c010667e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106816:	e9 60 02 00 00       	jmp    c0106a7b <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010681b:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010681f:	c7 44 24 08 62 84 10 	movl   $0xc0108462,0x8(%esp)
c0106826:	c0 
c0106827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010682a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010682e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106831:	89 04 24             	mov    %eax,(%esp)
c0106834:	e8 45 fe ff ff       	call   c010667e <printfmt>
            break;
c0106839:	e9 3d 02 00 00       	jmp    c0106a7b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010683e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106841:	8d 50 04             	lea    0x4(%eax),%edx
c0106844:	89 55 14             	mov    %edx,0x14(%ebp)
c0106847:	8b 30                	mov    (%eax),%esi
c0106849:	85 f6                	test   %esi,%esi
c010684b:	75 05                	jne    c0106852 <vprintfmt+0x1a3>
                p = "(null)";
c010684d:	be 65 84 10 c0       	mov    $0xc0108465,%esi
            }
            if (width > 0 && padc != '-') {
c0106852:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106856:	7e 76                	jle    c01068ce <vprintfmt+0x21f>
c0106858:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010685c:	74 70                	je     c01068ce <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010685e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106861:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106865:	89 34 24             	mov    %esi,(%esp)
c0106868:	e8 16 03 00 00       	call   c0106b83 <strnlen>
c010686d:	89 c2                	mov    %eax,%edx
c010686f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106872:	29 d0                	sub    %edx,%eax
c0106874:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106877:	eb 16                	jmp    c010688f <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106879:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010687d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106880:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106884:	89 04 24             	mov    %eax,(%esp)
c0106887:	8b 45 08             	mov    0x8(%ebp),%eax
c010688a:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010688c:	ff 4d e8             	decl   -0x18(%ebp)
c010688f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106893:	7f e4                	jg     c0106879 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106895:	eb 37                	jmp    c01068ce <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106897:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010689b:	74 1f                	je     c01068bc <vprintfmt+0x20d>
c010689d:	83 fb 1f             	cmp    $0x1f,%ebx
c01068a0:	7e 05                	jle    c01068a7 <vprintfmt+0x1f8>
c01068a2:	83 fb 7e             	cmp    $0x7e,%ebx
c01068a5:	7e 15                	jle    c01068bc <vprintfmt+0x20d>
                    putch('?', putdat);
c01068a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068ae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01068b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b8:	ff d0                	call   *%eax
c01068ba:	eb 0f                	jmp    c01068cb <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c01068bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068c3:	89 1c 24             	mov    %ebx,(%esp)
c01068c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01068c9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01068cb:	ff 4d e8             	decl   -0x18(%ebp)
c01068ce:	89 f0                	mov    %esi,%eax
c01068d0:	8d 70 01             	lea    0x1(%eax),%esi
c01068d3:	0f b6 00             	movzbl (%eax),%eax
c01068d6:	0f be d8             	movsbl %al,%ebx
c01068d9:	85 db                	test   %ebx,%ebx
c01068db:	74 27                	je     c0106904 <vprintfmt+0x255>
c01068dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01068e1:	78 b4                	js     c0106897 <vprintfmt+0x1e8>
c01068e3:	ff 4d e4             	decl   -0x1c(%ebp)
c01068e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01068ea:	79 ab                	jns    c0106897 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c01068ec:	eb 16                	jmp    c0106904 <vprintfmt+0x255>
                putch(' ', putdat);
c01068ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01068fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01068ff:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0106901:	ff 4d e8             	decl   -0x18(%ebp)
c0106904:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106908:	7f e4                	jg     c01068ee <vprintfmt+0x23f>
            }
            break;
c010690a:	e9 6c 01 00 00       	jmp    c0106a7b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010690f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106912:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106916:	8d 45 14             	lea    0x14(%ebp),%eax
c0106919:	89 04 24             	mov    %eax,(%esp)
c010691c:	e8 16 fd ff ff       	call   c0106637 <getint>
c0106921:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106924:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106927:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010692a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010692d:	85 d2                	test   %edx,%edx
c010692f:	79 26                	jns    c0106957 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106931:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106938:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010693f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106942:	ff d0                	call   *%eax
                num = -(long long)num;
c0106944:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106947:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010694a:	f7 d8                	neg    %eax
c010694c:	83 d2 00             	adc    $0x0,%edx
c010694f:	f7 da                	neg    %edx
c0106951:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106954:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106957:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010695e:	e9 a8 00 00 00       	jmp    c0106a0b <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106963:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106966:	89 44 24 04          	mov    %eax,0x4(%esp)
c010696a:	8d 45 14             	lea    0x14(%ebp),%eax
c010696d:	89 04 24             	mov    %eax,(%esp)
c0106970:	e8 73 fc ff ff       	call   c01065e8 <getuint>
c0106975:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106978:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010697b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106982:	e9 84 00 00 00       	jmp    c0106a0b <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106987:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010698a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010698e:	8d 45 14             	lea    0x14(%ebp),%eax
c0106991:	89 04 24             	mov    %eax,(%esp)
c0106994:	e8 4f fc ff ff       	call   c01065e8 <getuint>
c0106999:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010699c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010699f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01069a6:	eb 63                	jmp    c0106a0b <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c01069a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069af:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01069b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b9:	ff d0                	call   *%eax
            putch('x', putdat);
c01069bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069c2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01069c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01069cc:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01069ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01069d1:	8d 50 04             	lea    0x4(%eax),%edx
c01069d4:	89 55 14             	mov    %edx,0x14(%ebp)
c01069d7:	8b 00                	mov    (%eax),%eax
c01069d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01069e3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01069ea:	eb 1f                	jmp    c0106a0b <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01069ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01069f6:	89 04 24             	mov    %eax,(%esp)
c01069f9:	e8 ea fb ff ff       	call   c01065e8 <getuint>
c01069fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a01:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106a04:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106a0b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106a0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a12:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106a16:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106a19:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106a1d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a27:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106a2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a39:	89 04 24             	mov    %eax,(%esp)
c0106a3c:	e8 a5 fa ff ff       	call   c01064e6 <printnum>
            break;
c0106a41:	eb 38                	jmp    c0106a7b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106a43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a4a:	89 1c 24             	mov    %ebx,(%esp)
c0106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a50:	ff d0                	call   *%eax
            break;
c0106a52:	eb 27                	jmp    c0106a7b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106a54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a5b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a65:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106a67:	ff 4d 10             	decl   0x10(%ebp)
c0106a6a:	eb 03                	jmp    c0106a6f <vprintfmt+0x3c0>
c0106a6c:	ff 4d 10             	decl   0x10(%ebp)
c0106a6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106a72:	48                   	dec    %eax
c0106a73:	0f b6 00             	movzbl (%eax),%eax
c0106a76:	3c 25                	cmp    $0x25,%al
c0106a78:	75 f2                	jne    c0106a6c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106a7a:	90                   	nop
    while (1) {
c0106a7b:	e9 37 fc ff ff       	jmp    c01066b7 <vprintfmt+0x8>
                return;
c0106a80:	90                   	nop
        }
    }
}
c0106a81:	83 c4 40             	add    $0x40,%esp
c0106a84:	5b                   	pop    %ebx
c0106a85:	5e                   	pop    %esi
c0106a86:	5d                   	pop    %ebp
c0106a87:	c3                   	ret    

c0106a88 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106a88:	55                   	push   %ebp
c0106a89:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a8e:	8b 40 08             	mov    0x8(%eax),%eax
c0106a91:	8d 50 01             	lea    0x1(%eax),%edx
c0106a94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a97:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a9d:	8b 10                	mov    (%eax),%edx
c0106a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aa2:	8b 40 04             	mov    0x4(%eax),%eax
c0106aa5:	39 c2                	cmp    %eax,%edx
c0106aa7:	73 12                	jae    c0106abb <sprintputch+0x33>
        *b->buf ++ = ch;
c0106aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aac:	8b 00                	mov    (%eax),%eax
c0106aae:	8d 48 01             	lea    0x1(%eax),%ecx
c0106ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ab4:	89 0a                	mov    %ecx,(%edx)
c0106ab6:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ab9:	88 10                	mov    %dl,(%eax)
    }
}
c0106abb:	90                   	nop
c0106abc:	5d                   	pop    %ebp
c0106abd:	c3                   	ret    

c0106abe <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106abe:	55                   	push   %ebp
c0106abf:	89 e5                	mov    %esp,%ebp
c0106ac1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106ac4:	8d 45 14             	lea    0x14(%ebp),%eax
c0106ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106ad1:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ae2:	89 04 24             	mov    %eax,(%esp)
c0106ae5:	e8 0a 00 00 00       	call   c0106af4 <vsnprintf>
c0106aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106af0:	89 ec                	mov    %ebp,%esp
c0106af2:	5d                   	pop    %ebp
c0106af3:	c3                   	ret    

c0106af4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106af4:	55                   	push   %ebp
c0106af5:	89 e5                	mov    %esp,%ebp
c0106af7:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0106afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b03:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106b06:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b09:	01 d0                	add    %edx,%eax
c0106b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106b15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106b19:	74 0a                	je     c0106b25 <vsnprintf+0x31>
c0106b1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b21:	39 c2                	cmp    %eax,%edx
c0106b23:	76 07                	jbe    c0106b2c <vsnprintf+0x38>
        return -E_INVAL;
c0106b25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106b2a:	eb 2a                	jmp    c0106b56 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106b2c:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b33:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b36:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b41:	c7 04 24 88 6a 10 c0 	movl   $0xc0106a88,(%esp)
c0106b48:	e8 62 fb ff ff       	call   c01066af <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b50:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106b56:	89 ec                	mov    %ebp,%esp
c0106b58:	5d                   	pop    %ebp
c0106b59:	c3                   	ret    

c0106b5a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0106b5a:	55                   	push   %ebp
c0106b5b:	89 e5                	mov    %esp,%ebp
c0106b5d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106b60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106b67:	eb 03                	jmp    c0106b6c <strlen+0x12>
        cnt ++;
c0106b69:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0106b6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b6f:	8d 50 01             	lea    0x1(%eax),%edx
c0106b72:	89 55 08             	mov    %edx,0x8(%ebp)
c0106b75:	0f b6 00             	movzbl (%eax),%eax
c0106b78:	84 c0                	test   %al,%al
c0106b7a:	75 ed                	jne    c0106b69 <strlen+0xf>
    }
    return cnt;
c0106b7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106b7f:	89 ec                	mov    %ebp,%esp
c0106b81:	5d                   	pop    %ebp
c0106b82:	c3                   	ret    

c0106b83 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106b83:	55                   	push   %ebp
c0106b84:	89 e5                	mov    %esp,%ebp
c0106b86:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106b89:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106b90:	eb 03                	jmp    c0106b95 <strnlen+0x12>
        cnt ++;
c0106b92:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106b95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b98:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b9b:	73 10                	jae    c0106bad <strnlen+0x2a>
c0106b9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ba0:	8d 50 01             	lea    0x1(%eax),%edx
c0106ba3:	89 55 08             	mov    %edx,0x8(%ebp)
c0106ba6:	0f b6 00             	movzbl (%eax),%eax
c0106ba9:	84 c0                	test   %al,%al
c0106bab:	75 e5                	jne    c0106b92 <strnlen+0xf>
    }
    return cnt;
c0106bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106bb0:	89 ec                	mov    %ebp,%esp
c0106bb2:	5d                   	pop    %ebp
c0106bb3:	c3                   	ret    

c0106bb4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0106bb4:	55                   	push   %ebp
c0106bb5:	89 e5                	mov    %esp,%ebp
c0106bb7:	57                   	push   %edi
c0106bb8:	56                   	push   %esi
c0106bb9:	83 ec 20             	sub    $0x20,%esp
c0106bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0106bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bce:	89 d1                	mov    %edx,%ecx
c0106bd0:	89 c2                	mov    %eax,%edx
c0106bd2:	89 ce                	mov    %ecx,%esi
c0106bd4:	89 d7                	mov    %edx,%edi
c0106bd6:	ac                   	lods   %ds:(%esi),%al
c0106bd7:	aa                   	stos   %al,%es:(%edi)
c0106bd8:	84 c0                	test   %al,%al
c0106bda:	75 fa                	jne    c0106bd6 <strcpy+0x22>
c0106bdc:	89 fa                	mov    %edi,%edx
c0106bde:	89 f1                	mov    %esi,%ecx
c0106be0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106be3:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106be6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0106be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0106bec:	83 c4 20             	add    $0x20,%esp
c0106bef:	5e                   	pop    %esi
c0106bf0:	5f                   	pop    %edi
c0106bf1:	5d                   	pop    %ebp
c0106bf2:	c3                   	ret    

c0106bf3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0106bf3:	55                   	push   %ebp
c0106bf4:	89 e5                	mov    %esp,%ebp
c0106bf6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0106bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0106bff:	eb 1e                	jmp    c0106c1f <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0106c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c04:	0f b6 10             	movzbl (%eax),%edx
c0106c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c0a:	88 10                	mov    %dl,(%eax)
c0106c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c0f:	0f b6 00             	movzbl (%eax),%eax
c0106c12:	84 c0                	test   %al,%al
c0106c14:	74 03                	je     c0106c19 <strncpy+0x26>
            src ++;
c0106c16:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0106c19:	ff 45 fc             	incl   -0x4(%ebp)
c0106c1c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0106c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106c23:	75 dc                	jne    c0106c01 <strncpy+0xe>
    }
    return dst;
c0106c25:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106c28:	89 ec                	mov    %ebp,%esp
c0106c2a:	5d                   	pop    %ebp
c0106c2b:	c3                   	ret    

c0106c2c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106c2c:	55                   	push   %ebp
c0106c2d:	89 e5                	mov    %esp,%ebp
c0106c2f:	57                   	push   %edi
c0106c30:	56                   	push   %esi
c0106c31:	83 ec 20             	sub    $0x20,%esp
c0106c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0106c40:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c46:	89 d1                	mov    %edx,%ecx
c0106c48:	89 c2                	mov    %eax,%edx
c0106c4a:	89 ce                	mov    %ecx,%esi
c0106c4c:	89 d7                	mov    %edx,%edi
c0106c4e:	ac                   	lods   %ds:(%esi),%al
c0106c4f:	ae                   	scas   %es:(%edi),%al
c0106c50:	75 08                	jne    c0106c5a <strcmp+0x2e>
c0106c52:	84 c0                	test   %al,%al
c0106c54:	75 f8                	jne    c0106c4e <strcmp+0x22>
c0106c56:	31 c0                	xor    %eax,%eax
c0106c58:	eb 04                	jmp    c0106c5e <strcmp+0x32>
c0106c5a:	19 c0                	sbb    %eax,%eax
c0106c5c:	0c 01                	or     $0x1,%al
c0106c5e:	89 fa                	mov    %edi,%edx
c0106c60:	89 f1                	mov    %esi,%ecx
c0106c62:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106c65:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106c68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0106c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0106c6e:	83 c4 20             	add    $0x20,%esp
c0106c71:	5e                   	pop    %esi
c0106c72:	5f                   	pop    %edi
c0106c73:	5d                   	pop    %ebp
c0106c74:	c3                   	ret    

c0106c75 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106c75:	55                   	push   %ebp
c0106c76:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106c78:	eb 09                	jmp    c0106c83 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106c7a:	ff 4d 10             	decl   0x10(%ebp)
c0106c7d:	ff 45 08             	incl   0x8(%ebp)
c0106c80:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106c83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106c87:	74 1a                	je     c0106ca3 <strncmp+0x2e>
c0106c89:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c8c:	0f b6 00             	movzbl (%eax),%eax
c0106c8f:	84 c0                	test   %al,%al
c0106c91:	74 10                	je     c0106ca3 <strncmp+0x2e>
c0106c93:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c96:	0f b6 10             	movzbl (%eax),%edx
c0106c99:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c9c:	0f b6 00             	movzbl (%eax),%eax
c0106c9f:	38 c2                	cmp    %al,%dl
c0106ca1:	74 d7                	je     c0106c7a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106ca3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106ca7:	74 18                	je     c0106cc1 <strncmp+0x4c>
c0106ca9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cac:	0f b6 00             	movzbl (%eax),%eax
c0106caf:	0f b6 d0             	movzbl %al,%edx
c0106cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cb5:	0f b6 00             	movzbl (%eax),%eax
c0106cb8:	0f b6 c8             	movzbl %al,%ecx
c0106cbb:	89 d0                	mov    %edx,%eax
c0106cbd:	29 c8                	sub    %ecx,%eax
c0106cbf:	eb 05                	jmp    c0106cc6 <strncmp+0x51>
c0106cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106cc6:	5d                   	pop    %ebp
c0106cc7:	c3                   	ret    

c0106cc8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0106cc8:	55                   	push   %ebp
c0106cc9:	89 e5                	mov    %esp,%ebp
c0106ccb:	83 ec 04             	sub    $0x4,%esp
c0106cce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cd1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106cd4:	eb 13                	jmp    c0106ce9 <strchr+0x21>
        if (*s == c) {
c0106cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cd9:	0f b6 00             	movzbl (%eax),%eax
c0106cdc:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106cdf:	75 05                	jne    c0106ce6 <strchr+0x1e>
            return (char *)s;
c0106ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce4:	eb 12                	jmp    c0106cf8 <strchr+0x30>
        }
        s ++;
c0106ce6:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106ce9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cec:	0f b6 00             	movzbl (%eax),%eax
c0106cef:	84 c0                	test   %al,%al
c0106cf1:	75 e3                	jne    c0106cd6 <strchr+0xe>
    }
    return NULL;
c0106cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106cf8:	89 ec                	mov    %ebp,%esp
c0106cfa:	5d                   	pop    %ebp
c0106cfb:	c3                   	ret    

c0106cfc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0106cfc:	55                   	push   %ebp
c0106cfd:	89 e5                	mov    %esp,%ebp
c0106cff:	83 ec 04             	sub    $0x4,%esp
c0106d02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d05:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0106d08:	eb 0e                	jmp    c0106d18 <strfind+0x1c>
        if (*s == c) {
c0106d0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d0d:	0f b6 00             	movzbl (%eax),%eax
c0106d10:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0106d13:	74 0f                	je     c0106d24 <strfind+0x28>
            break;
        }
        s ++;
c0106d15:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0106d18:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d1b:	0f b6 00             	movzbl (%eax),%eax
c0106d1e:	84 c0                	test   %al,%al
c0106d20:	75 e8                	jne    c0106d0a <strfind+0xe>
c0106d22:	eb 01                	jmp    c0106d25 <strfind+0x29>
            break;
c0106d24:	90                   	nop
    }
    return (char *)s;
c0106d25:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106d28:	89 ec                	mov    %ebp,%esp
c0106d2a:	5d                   	pop    %ebp
c0106d2b:	c3                   	ret    

c0106d2c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106d2c:	55                   	push   %ebp
c0106d2d:	89 e5                	mov    %esp,%ebp
c0106d2f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0106d32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106d39:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0106d40:	eb 03                	jmp    c0106d45 <strtol+0x19>
        s ++;
c0106d42:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0106d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d48:	0f b6 00             	movzbl (%eax),%eax
c0106d4b:	3c 20                	cmp    $0x20,%al
c0106d4d:	74 f3                	je     c0106d42 <strtol+0x16>
c0106d4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d52:	0f b6 00             	movzbl (%eax),%eax
c0106d55:	3c 09                	cmp    $0x9,%al
c0106d57:	74 e9                	je     c0106d42 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0106d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d5c:	0f b6 00             	movzbl (%eax),%eax
c0106d5f:	3c 2b                	cmp    $0x2b,%al
c0106d61:	75 05                	jne    c0106d68 <strtol+0x3c>
        s ++;
c0106d63:	ff 45 08             	incl   0x8(%ebp)
c0106d66:	eb 14                	jmp    c0106d7c <strtol+0x50>
    }
    else if (*s == '-') {
c0106d68:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d6b:	0f b6 00             	movzbl (%eax),%eax
c0106d6e:	3c 2d                	cmp    $0x2d,%al
c0106d70:	75 0a                	jne    c0106d7c <strtol+0x50>
        s ++, neg = 1;
c0106d72:	ff 45 08             	incl   0x8(%ebp)
c0106d75:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106d7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106d80:	74 06                	je     c0106d88 <strtol+0x5c>
c0106d82:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0106d86:	75 22                	jne    c0106daa <strtol+0x7e>
c0106d88:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d8b:	0f b6 00             	movzbl (%eax),%eax
c0106d8e:	3c 30                	cmp    $0x30,%al
c0106d90:	75 18                	jne    c0106daa <strtol+0x7e>
c0106d92:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d95:	40                   	inc    %eax
c0106d96:	0f b6 00             	movzbl (%eax),%eax
c0106d99:	3c 78                	cmp    $0x78,%al
c0106d9b:	75 0d                	jne    c0106daa <strtol+0x7e>
        s += 2, base = 16;
c0106d9d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0106da1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0106da8:	eb 29                	jmp    c0106dd3 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0106daa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106dae:	75 16                	jne    c0106dc6 <strtol+0x9a>
c0106db0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106db3:	0f b6 00             	movzbl (%eax),%eax
c0106db6:	3c 30                	cmp    $0x30,%al
c0106db8:	75 0c                	jne    c0106dc6 <strtol+0x9a>
        s ++, base = 8;
c0106dba:	ff 45 08             	incl   0x8(%ebp)
c0106dbd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0106dc4:	eb 0d                	jmp    c0106dd3 <strtol+0xa7>
    }
    else if (base == 0) {
c0106dc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106dca:	75 07                	jne    c0106dd3 <strtol+0xa7>
        base = 10;
c0106dcc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0106dd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dd6:	0f b6 00             	movzbl (%eax),%eax
c0106dd9:	3c 2f                	cmp    $0x2f,%al
c0106ddb:	7e 1b                	jle    c0106df8 <strtol+0xcc>
c0106ddd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106de0:	0f b6 00             	movzbl (%eax),%eax
c0106de3:	3c 39                	cmp    $0x39,%al
c0106de5:	7f 11                	jg     c0106df8 <strtol+0xcc>
            dig = *s - '0';
c0106de7:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dea:	0f b6 00             	movzbl (%eax),%eax
c0106ded:	0f be c0             	movsbl %al,%eax
c0106df0:	83 e8 30             	sub    $0x30,%eax
c0106df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106df6:	eb 48                	jmp    c0106e40 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0106df8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dfb:	0f b6 00             	movzbl (%eax),%eax
c0106dfe:	3c 60                	cmp    $0x60,%al
c0106e00:	7e 1b                	jle    c0106e1d <strtol+0xf1>
c0106e02:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e05:	0f b6 00             	movzbl (%eax),%eax
c0106e08:	3c 7a                	cmp    $0x7a,%al
c0106e0a:	7f 11                	jg     c0106e1d <strtol+0xf1>
            dig = *s - 'a' + 10;
c0106e0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e0f:	0f b6 00             	movzbl (%eax),%eax
c0106e12:	0f be c0             	movsbl %al,%eax
c0106e15:	83 e8 57             	sub    $0x57,%eax
c0106e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106e1b:	eb 23                	jmp    c0106e40 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0106e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e20:	0f b6 00             	movzbl (%eax),%eax
c0106e23:	3c 40                	cmp    $0x40,%al
c0106e25:	7e 3b                	jle    c0106e62 <strtol+0x136>
c0106e27:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e2a:	0f b6 00             	movzbl (%eax),%eax
c0106e2d:	3c 5a                	cmp    $0x5a,%al
c0106e2f:	7f 31                	jg     c0106e62 <strtol+0x136>
            dig = *s - 'A' + 10;
c0106e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e34:	0f b6 00             	movzbl (%eax),%eax
c0106e37:	0f be c0             	movsbl %al,%eax
c0106e3a:	83 e8 37             	sub    $0x37,%eax
c0106e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0106e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e43:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106e46:	7d 19                	jge    c0106e61 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106e48:	ff 45 08             	incl   0x8(%ebp)
c0106e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106e4e:	0f af 45 10          	imul   0x10(%ebp),%eax
c0106e52:	89 c2                	mov    %eax,%edx
c0106e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e57:	01 d0                	add    %edx,%eax
c0106e59:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106e5c:	e9 72 ff ff ff       	jmp    c0106dd3 <strtol+0xa7>
            break;
c0106e61:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0106e62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106e66:	74 08                	je     c0106e70 <strtol+0x144>
        *endptr = (char *) s;
c0106e68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e6b:	8b 55 08             	mov    0x8(%ebp),%edx
c0106e6e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0106e70:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106e74:	74 07                	je     c0106e7d <strtol+0x151>
c0106e76:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106e79:	f7 d8                	neg    %eax
c0106e7b:	eb 03                	jmp    c0106e80 <strtol+0x154>
c0106e7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0106e80:	89 ec                	mov    %ebp,%esp
c0106e82:	5d                   	pop    %ebp
c0106e83:	c3                   	ret    

c0106e84 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106e84:	55                   	push   %ebp
c0106e85:	89 e5                	mov    %esp,%ebp
c0106e87:	83 ec 28             	sub    $0x28,%esp
c0106e8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0106e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e90:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106e93:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0106e97:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e9a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0106e9d:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0106ea0:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106ea6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106ea9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106ead:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106eb0:	89 d7                	mov    %edx,%edi
c0106eb2:	f3 aa                	rep stos %al,%es:(%edi)
c0106eb4:	89 fa                	mov    %edi,%edx
c0106eb6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0106eb9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106ebc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106ebf:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0106ec2:	89 ec                	mov    %ebp,%esp
c0106ec4:	5d                   	pop    %ebp
c0106ec5:	c3                   	ret    

c0106ec6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0106ec6:	55                   	push   %ebp
c0106ec7:	89 e5                	mov    %esp,%ebp
c0106ec9:	57                   	push   %edi
c0106eca:	56                   	push   %esi
c0106ecb:	53                   	push   %ebx
c0106ecc:	83 ec 30             	sub    $0x30,%esp
c0106ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ed8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106edb:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ede:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0106ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ee4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106ee7:	73 42                	jae    c0106f2b <memmove+0x65>
c0106ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ef8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106efe:	c1 e8 02             	shr    $0x2,%eax
c0106f01:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106f03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f09:	89 d7                	mov    %edx,%edi
c0106f0b:	89 c6                	mov    %eax,%esi
c0106f0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106f0f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106f12:	83 e1 03             	and    $0x3,%ecx
c0106f15:	74 02                	je     c0106f19 <memmove+0x53>
c0106f17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106f19:	89 f0                	mov    %esi,%eax
c0106f1b:	89 fa                	mov    %edi,%edx
c0106f1d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0106f20:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106f23:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0106f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0106f29:	eb 36                	jmp    c0106f61 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f2e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f34:	01 c2                	add    %eax,%edx
c0106f36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f39:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f3f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0106f42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f45:	89 c1                	mov    %eax,%ecx
c0106f47:	89 d8                	mov    %ebx,%eax
c0106f49:	89 d6                	mov    %edx,%esi
c0106f4b:	89 c7                	mov    %eax,%edi
c0106f4d:	fd                   	std    
c0106f4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106f50:	fc                   	cld    
c0106f51:	89 f8                	mov    %edi,%eax
c0106f53:	89 f2                	mov    %esi,%edx
c0106f55:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106f58:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106f5b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0106f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106f61:	83 c4 30             	add    $0x30,%esp
c0106f64:	5b                   	pop    %ebx
c0106f65:	5e                   	pop    %esi
c0106f66:	5f                   	pop    %edi
c0106f67:	5d                   	pop    %ebp
c0106f68:	c3                   	ret    

c0106f69 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106f69:	55                   	push   %ebp
c0106f6a:	89 e5                	mov    %esp,%ebp
c0106f6c:	57                   	push   %edi
c0106f6d:	56                   	push   %esi
c0106f6e:	83 ec 20             	sub    $0x20,%esp
c0106f71:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106f77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f7d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106f80:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f86:	c1 e8 02             	shr    $0x2,%eax
c0106f89:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f91:	89 d7                	mov    %edx,%edi
c0106f93:	89 c6                	mov    %eax,%esi
c0106f95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106f97:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106f9a:	83 e1 03             	and    $0x3,%ecx
c0106f9d:	74 02                	je     c0106fa1 <memcpy+0x38>
c0106f9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106fa1:	89 f0                	mov    %esi,%eax
c0106fa3:	89 fa                	mov    %edi,%edx
c0106fa5:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106fa8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106fab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0106fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106fb1:	83 c4 20             	add    $0x20,%esp
c0106fb4:	5e                   	pop    %esi
c0106fb5:	5f                   	pop    %edi
c0106fb6:	5d                   	pop    %ebp
c0106fb7:	c3                   	ret    

c0106fb8 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0106fb8:	55                   	push   %ebp
c0106fb9:	89 e5                	mov    %esp,%ebp
c0106fbb:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106fbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fc1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0106fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fc7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0106fca:	eb 2e                	jmp    c0106ffa <memcmp+0x42>
        if (*s1 != *s2) {
c0106fcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fcf:	0f b6 10             	movzbl (%eax),%edx
c0106fd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106fd5:	0f b6 00             	movzbl (%eax),%eax
c0106fd8:	38 c2                	cmp    %al,%dl
c0106fda:	74 18                	je     c0106ff4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106fdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fdf:	0f b6 00             	movzbl (%eax),%eax
c0106fe2:	0f b6 d0             	movzbl %al,%edx
c0106fe5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106fe8:	0f b6 00             	movzbl (%eax),%eax
c0106feb:	0f b6 c8             	movzbl %al,%ecx
c0106fee:	89 d0                	mov    %edx,%eax
c0106ff0:	29 c8                	sub    %ecx,%eax
c0106ff2:	eb 18                	jmp    c010700c <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0106ff4:	ff 45 fc             	incl   -0x4(%ebp)
c0106ff7:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0106ffa:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ffd:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107000:	89 55 10             	mov    %edx,0x10(%ebp)
c0107003:	85 c0                	test   %eax,%eax
c0107005:	75 c5                	jne    c0106fcc <memcmp+0x14>
    }
    return 0;
c0107007:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010700c:	89 ec                	mov    %ebp,%esp
c010700e:	5d                   	pop    %ebp
c010700f:	c3                   	ret    

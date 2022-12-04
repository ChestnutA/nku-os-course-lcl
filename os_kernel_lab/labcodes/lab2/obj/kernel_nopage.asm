
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 c0 11 40       	mov    $0x4011c000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 c0 11 00       	mov    %eax,0x11c000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 b0 11 00       	mov    $0x11b000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 8c ef 11 00       	mov    $0x11ef8c,%eax
  100041:	2d 36 ba 11 00       	sub    $0x11ba36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 ba 11 00 	movl   $0x11ba36,(%esp)
  100059:	e8 26 6e 00 00       	call   106e84 <memset>

    cons_init();                // init the console
  10005e:	e8 df 15 00 00       	call   101642 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 20 70 10 00 	movl   $0x107020,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 3c 70 10 00 	movl   $0x10703c,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100087:	e8 02 53 00 00       	call   10538e <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 32 17 00 00       	call   1017c3 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 b9 18 00 00       	call   10194f <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 06 0d 00 00       	call   100da1 <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 81 16 00 00       	call   101721 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a0:	eb fe                	jmp    1000a0 <kern_init+0x6a>

001000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000af:	00 
  1000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000b7:	00 
  1000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000bf:	e8 f8 0b 00 00       	call   100cbc <mon_backtrace>
}
  1000c4:	90                   	nop
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
  1000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b0 ff ff ff       	call   1000a2 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000f6:	89 ec                	mov    %ebp,%esp
  1000f8:	5d                   	pop    %ebp
  1000f9:	c3                   	ret    

001000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100100:	8b 45 10             	mov    0x10(%ebp),%eax
  100103:	89 44 24 04          	mov    %eax,0x4(%esp)
  100107:	8b 45 08             	mov    0x8(%ebp),%eax
  10010a:	89 04 24             	mov    %eax,(%esp)
  10010d:	e8 b7 ff ff ff       	call   1000c9 <grade_backtrace1>
}
  100112:	90                   	nop
  100113:	89 ec                	mov    %ebp,%esp
  100115:	5d                   	pop    %ebp
  100116:	c3                   	ret    

00100117 <grade_backtrace>:

void
grade_backtrace(void) {
  100117:	55                   	push   %ebp
  100118:	89 e5                	mov    %esp,%ebp
  10011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011d:	b8 36 00 10 00       	mov    $0x100036,%eax
  100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100129:	ff 
  10012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100135:	e8 c0 ff ff ff       	call   1000fa <grade_backtrace0>
}
  10013a:	90                   	nop
  10013b:	89 ec                	mov    %ebp,%esp
  10013d:	5d                   	pop    %ebp
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 e0 11 00       	mov    0x11e000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 41 70 10 00 	movl   $0x107041,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 e0 11 00       	mov    0x11e000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 4f 70 10 00 	movl   $0x10704f,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 e0 11 00       	mov    0x11e000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 5d 70 10 00 	movl   $0x10705d,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 e0 11 00       	mov    0x11e000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 6b 70 10 00 	movl   $0x10706b,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 e0 11 00       	mov    0x11e000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 79 70 10 00 	movl   $0x107079,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 e0 11 00       	mov    0x11e000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 e0 11 00       	mov    %eax,0x11e000
}
  1001fa:	90                   	nop
  1001fb:	89 ec                	mov    %ebp,%esp
  1001fd:	5d                   	pop    %ebp
  1001fe:	c3                   	ret    

001001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001ff:	55                   	push   %ebp
  100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100208:	90                   	nop
  100209:	5d                   	pop    %ebp
  10020a:	c3                   	ret    

0010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020b:	55                   	push   %ebp
  10020c:	89 e5                	mov    %esp,%ebp
  10020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100211:	e8 29 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100216:	c7 04 24 88 70 10 00 	movl   $0x107088,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 a8 70 10 00 	movl   $0x1070a8,(%esp)
  100233:	e8 1e 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_kernel();
  100238:	e8 c8 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023d:	e8 fd fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100242:	90                   	nop
  100243:	89 ec                	mov    %ebp,%esp
  100245:	5d                   	pop    %ebp
  100246:	c3                   	ret    

00100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100247:	55                   	push   %ebp
  100248:	89 e5                	mov    %esp,%ebp
  10024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100251:	74 13                	je     100266 <readline+0x1f>
        cprintf("%s", prompt);
  100253:	8b 45 08             	mov    0x8(%ebp),%eax
  100256:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025a:	c7 04 24 c7 70 10 00 	movl   $0x1070c7,(%esp)
  100261:	e8 f0 00 00 00       	call   100356 <cprintf>
    }
    int i = 0, c;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10026d:	e8 73 01 00 00       	call   1003e5 <getchar>
  100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100279:	79 07                	jns    100282 <readline+0x3b>
            return NULL;
  10027b:	b8 00 00 00 00       	mov    $0x0,%eax
  100280:	eb 78                	jmp    1002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100286:	7e 28                	jle    1002b0 <readline+0x69>
  100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028f:	7f 1f                	jg     1002b0 <readline+0x69>
            cputchar(c);
  100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100294:	89 04 24             	mov    %eax,(%esp)
  100297:	e8 e2 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  10029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029f:	8d 50 01             	lea    0x1(%eax),%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a8:	88 90 20 e0 11 00    	mov    %dl,0x11e020(%eax)
  1002ae:	eb 45                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b4:	75 16                	jne    1002cc <readline+0x85>
  1002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ba:	7e 10                	jle    1002cc <readline+0x85>
            cputchar(c);
  1002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bf:	89 04 24             	mov    %eax,(%esp)
  1002c2:	e8 b7 00 00 00       	call   10037e <cputchar>
            i --;
  1002c7:	ff 4d f4             	decl   -0xc(%ebp)
  1002ca:	eb 29                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d0:	74 06                	je     1002d8 <readline+0x91>
  1002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d6:	75 95                	jne    10026d <readline+0x26>
            cputchar(c);
  1002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002db:	89 04 24             	mov    %eax,(%esp)
  1002de:	e8 9b 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e6:	05 20 e0 11 00       	add    $0x11e020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 e0 11 00       	mov    $0x11e020,%eax
  1002f3:	eb 05                	jmp    1002fa <readline+0xb3>
        c = getchar();
  1002f5:	e9 73 ff ff ff       	jmp    10026d <readline+0x26>
        }
    }
}
  1002fa:	89 ec                	mov    %ebp,%esp
  1002fc:	5d                   	pop    %ebp
  1002fd:	c3                   	ret    

001002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100304:	8b 45 08             	mov    0x8(%ebp),%eax
  100307:	89 04 24             	mov    %eax,(%esp)
  10030a:	e8 62 13 00 00       	call   101671 <cons_putc>
    (*cnt) ++;
  10030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100312:	8b 00                	mov    (%eax),%eax
  100314:	8d 50 01             	lea    0x1(%eax),%edx
  100317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031a:	89 10                	mov    %edx,(%eax)
}
  10031c:	90                   	nop
  10031d:	89 ec                	mov    %ebp,%esp
  10031f:	5d                   	pop    %ebp
  100320:	c3                   	ret    

00100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100321:	55                   	push   %ebp
  100322:	89 e5                	mov    %esp,%ebp
  100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100343:	c7 04 24 fe 02 10 00 	movl   $0x1002fe,(%esp)
  10034a:	e8 60 63 00 00       	call   1066af <vprintfmt>
    return cnt;
  10034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100352:	89 ec                	mov    %ebp,%esp
  100354:	5d                   	pop    %ebp
  100355:	c3                   	ret    

00100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100356:	55                   	push   %ebp
  100357:	89 e5                	mov    %esp,%ebp
  100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100365:	89 44 24 04          	mov    %eax,0x4(%esp)
  100369:	8b 45 08             	mov    0x8(%ebp),%eax
  10036c:	89 04 24             	mov    %eax,(%esp)
  10036f:	e8 ad ff ff ff       	call   100321 <vcprintf>
  100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	89 ec                	mov    %ebp,%esp
  10037c:	5d                   	pop    %ebp
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 e2 12 00 00       	call   101671 <cons_putc>
}
  10038f:	90                   	nop
  100390:	89 ec                	mov    %ebp,%esp
  100392:	5d                   	pop    %ebp
  100393:	c3                   	ret    

00100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100394:	55                   	push   %ebp
  100395:	89 e5                	mov    %esp,%ebp
  100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003a1:	eb 13                	jmp    1003b6 <cputs+0x22>
        cputch(c, &cnt);
  1003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ae:	89 04 24             	mov    %eax,(%esp)
  1003b1:	e8 48 ff ff ff       	call   1002fe <cputch>
    while ((c = *str ++) != '\0') {
  1003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b9:	8d 50 01             	lea    0x1(%eax),%edx
  1003bc:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bf:	0f b6 00             	movzbl (%eax),%eax
  1003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c9:	75 d8                	jne    1003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d9:	e8 20 ff ff ff       	call   1002fe <cputch>
    return cnt;
  1003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003e1:	89 ec                	mov    %ebp,%esp
  1003e3:	5d                   	pop    %ebp
  1003e4:	c3                   	ret    

001003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e5:	55                   	push   %ebp
  1003e6:	89 e5                	mov    %esp,%ebp
  1003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003eb:	90                   	nop
  1003ec:	e8 bf 12 00 00       	call   1016b0 <cons_getc>
  1003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f8:	74 f2                	je     1003ec <getchar+0x7>
        /* do nothing */;
    return c;
  1003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003fd:	89 ec                	mov    %ebp,%esp
  1003ff:	5d                   	pop    %ebp
  100400:	c3                   	ret    

00100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100401:	55                   	push   %ebp
  100402:	89 e5                	mov    %esp,%ebp
  100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	8b 00                	mov    (%eax),%eax
  100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10041e:	e9 ca 00 00 00       	jmp    1004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100429:	01 d0                	add    %edx,%eax
  10042b:	89 c2                	mov    %eax,%edx
  10042d:	c1 ea 1f             	shr    $0x1f,%edx
  100430:	01 d0                	add    %edx,%eax
  100432:	d1 f8                	sar    %eax
  100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043d:	eb 03                	jmp    100442 <stab_binsearch+0x41>
            m --;
  10043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100448:	7c 1f                	jl     100469 <stab_binsearch+0x68>
  10044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044d:	89 d0                	mov    %edx,%eax
  10044f:	01 c0                	add    %eax,%eax
  100451:	01 d0                	add    %edx,%eax
  100453:	c1 e0 02             	shl    $0x2,%eax
  100456:	89 c2                	mov    %eax,%edx
  100458:	8b 45 08             	mov    0x8(%ebp),%eax
  10045b:	01 d0                	add    %edx,%eax
  10045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100461:	0f b6 c0             	movzbl %al,%eax
  100464:	39 45 14             	cmp    %eax,0x14(%ebp)
  100467:	75 d6                	jne    10043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046f:	7d 09                	jge    10047a <stab_binsearch+0x79>
            l = true_m + 1;
  100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100474:	40                   	inc    %eax
  100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100478:	eb 73                	jmp    1004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100484:	89 d0                	mov    %edx,%eax
  100486:	01 c0                	add    %eax,%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	89 c2                	mov    %eax,%edx
  10048f:	8b 45 08             	mov    0x8(%ebp),%eax
  100492:	01 d0                	add    %edx,%eax
  100494:	8b 40 08             	mov    0x8(%eax),%eax
  100497:	39 45 18             	cmp    %eax,0x18(%ebp)
  10049a:	76 11                	jbe    1004ad <stab_binsearch+0xac>
            *region_left = m;
  10049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a7:	40                   	inc    %eax
  1004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ab:	eb 40                	jmp    1004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b0:	89 d0                	mov    %edx,%eax
  1004b2:	01 c0                	add    %eax,%eax
  1004b4:	01 d0                	add    %edx,%eax
  1004b6:	c1 e0 02             	shl    $0x2,%eax
  1004b9:	89 c2                	mov    %eax,%edx
  1004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004be:	01 d0                	add    %edx,%eax
  1004c0:	8b 40 08             	mov    0x8(%eax),%eax
  1004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c6:	73 14                	jae    1004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	48                   	dec    %eax
  1004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004da:	eb 11                	jmp    1004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e2:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 2a ff ff ff    	jle    100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10050c:	eb 3e                	jmp    10054c <stab_binsearch+0x14b>
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 03                	jmp    10051b <stab_binsearch+0x11a>
  100518:	ff 4d fc             	decl   -0x4(%ebp)
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100523:	7e 1f                	jle    100544 <stab_binsearch+0x143>
  100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100528:	89 d0                	mov    %edx,%eax
  10052a:	01 c0                	add    %eax,%eax
  10052c:	01 d0                	add    %edx,%eax
  10052e:	c1 e0 02             	shl    $0x2,%eax
  100531:	89 c2                	mov    %eax,%edx
  100533:	8b 45 08             	mov    0x8(%ebp),%eax
  100536:	01 d0                	add    %edx,%eax
  100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053c:	0f b6 c0             	movzbl %al,%eax
  10053f:	39 45 14             	cmp    %eax,0x14(%ebp)
  100542:	75 d4                	jne    100518 <stab_binsearch+0x117>
        *region_left = l;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054a:	89 10                	mov    %edx,(%eax)
}
  10054c:	90                   	nop
  10054d:	89 ec                	mov    %ebp,%esp
  10054f:	5d                   	pop    %ebp
  100550:	c3                   	ret    

00100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100551:	55                   	push   %ebp
  100552:	89 e5                	mov    %esp,%ebp
  100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 00 cc 70 10 00    	movl   $0x1070cc,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 cc 70 10 00 	movl   $0x1070cc,0x8(%eax)
    info->eip_fn_namelen = 9;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100581:	8b 55 08             	mov    0x8(%ebp),%edx
  100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100587:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100591:	c7 45 f4 c4 85 10 00 	movl   $0x1085c4,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 48 55 11 00 	movl   $0x115548,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec 49 55 11 00 	movl   $0x115549,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 81 8e 11 00 	movl   $0x118e81,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b3:	76 0b                	jbe    1005c0 <debuginfo_eip+0x6f>
  1005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b8:	48                   	dec    %eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x79>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 ab 02 00 00       	jmp    100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d7:	c1 f8 02             	sar    $0x2,%eax
  1005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e0:	48                   	dec    %eax
  1005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f2:	00 
  1005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100604:	89 04 24             	mov    %eax,(%esp)
  100607:	e8 f5 fd ff ff       	call   100401 <stab_binsearch>
    if (lfile == 0)
  10060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	75 0a                	jne    10061d <debuginfo_eip+0xcc>
        return -1;
  100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100618:	e9 58 02 00 00       	jmp    100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100637:	00 
  100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 b0 fd ff ff       	call   100401 <stab_binsearch>

    if (lfun <= rfun) {
  100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100657:	39 c2                	cmp    %eax,%edx
  100659:	7f 78                	jg     1006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	01 c0                	add    %eax,%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	c1 e0 02             	shl    $0x2,%eax
  100669:	89 c2                	mov    %eax,%edx
  10066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066e:	01 d0                	add    %edx,%eax
  100670:	8b 10                	mov    (%eax),%edx
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100678:	39 c2                	cmp    %eax,%edx
  10067a:	73 22                	jae    10069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067f:	89 c2                	mov    %eax,%edx
  100681:	89 d0                	mov    %edx,%eax
  100683:	01 c0                	add    %eax,%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	c1 e0 02             	shl    $0x2,%eax
  10068a:	89 c2                	mov    %eax,%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	8b 10                	mov    (%eax),%edx
  100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100696:	01 c2                	add    %eax,%edx
  100698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a1:	89 c2                	mov    %eax,%edx
  1006a3:	89 d0                	mov    %edx,%eax
  1006a5:	01 c0                	add    %eax,%eax
  1006a7:	01 d0                	add    %edx,%eax
  1006a9:	c1 e0 02             	shl    $0x2,%eax
  1006ac:	89 c2                	mov    %eax,%edx
  1006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	8b 50 08             	mov    0x8(%eax),%edx
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 10             	mov    0x10(%eax),%eax
  1006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d1:	eb 15                	jmp    1006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006eb:	8b 40 08             	mov    0x8(%eax),%eax
  1006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f5:	00 
  1006f6:	89 04 24             	mov    %eax,(%esp)
  1006f9:	e8 fe 65 00 00       	call   106cfc <strfind>
  1006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100701:	8b 4a 08             	mov    0x8(%edx),%ecx
  100704:	29 c8                	sub    %ecx,%eax
  100706:	89 c2                	mov    %eax,%edx
  100708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070e:	8b 45 08             	mov    0x8(%ebp),%eax
  100711:	89 44 24 10          	mov    %eax,0x10(%esp)
  100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10071c:	00 
  10071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100720:	89 44 24 08          	mov    %eax,0x8(%esp)
  100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100727:	89 44 24 04          	mov    %eax,0x4(%esp)
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	89 04 24             	mov    %eax,(%esp)
  100731:	e8 cb fc ff ff       	call   100401 <stab_binsearch>
    if (lline <= rline) {
  100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	39 c2                	cmp    %eax,%edx
  10073e:	7f 23                	jg     100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	89 d0                	mov    %edx,%eax
  100747:	01 c0                	add    %eax,%eax
  100749:	01 d0                	add    %edx,%eax
  10074b:	c1 e0 02             	shl    $0x2,%eax
  10074e:	89 c2                	mov    %eax,%edx
  100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100759:	89 c2                	mov    %eax,%edx
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100761:	eb 11                	jmp    100774 <debuginfo_eip+0x223>
        return -1;
  100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100768:	e9 08 01 00 00       	jmp    100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100770:	48                   	dec    %eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10077a:	39 c2                	cmp    %eax,%edx
  10077c:	7c 56                	jl     1007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100781:	89 c2                	mov    %eax,%edx
  100783:	89 d0                	mov    %edx,%eax
  100785:	01 c0                	add    %eax,%eax
  100787:	01 d0                	add    %edx,%eax
  100789:	c1 e0 02             	shl    $0x2,%eax
  10078c:	89 c2                	mov    %eax,%edx
  10078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100791:	01 d0                	add    %edx,%eax
  100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100797:	3c 84                	cmp    $0x84,%al
  100799:	74 39                	je     1007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	89 d0                	mov    %edx,%eax
  1007a2:	01 c0                	add    %eax,%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	c1 e0 02             	shl    $0x2,%eax
  1007a9:	89 c2                	mov    %eax,%edx
  1007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b4:	3c 64                	cmp    $0x64,%al
  1007b6:	75 b5                	jne    10076d <debuginfo_eip+0x21c>
  1007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	89 d0                	mov    %edx,%eax
  1007bf:	01 c0                	add    %eax,%eax
  1007c1:	01 d0                	add    %edx,%eax
  1007c3:	c1 e0 02             	shl    $0x2,%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007cb:	01 d0                	add    %edx,%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	85 c0                	test   %eax,%eax
  1007d2:	74 99                	je     10076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007da:	39 c2                	cmp    %eax,%edx
  1007dc:	7c 42                	jl     100820 <debuginfo_eip+0x2cf>
  1007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e1:	89 c2                	mov    %eax,%edx
  1007e3:	89 d0                	mov    %edx,%eax
  1007e5:	01 c0                	add    %eax,%eax
  1007e7:	01 d0                	add    %edx,%eax
  1007e9:	c1 e0 02             	shl    $0x2,%eax
  1007ec:	89 c2                	mov    %eax,%edx
  1007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f1:	01 d0                	add    %edx,%eax
  1007f3:	8b 10                	mov    (%eax),%edx
  1007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 46                	jge    100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	40                   	inc    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100831:	eb 16                	jmp    100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100833:	8b 45 0c             	mov    0xc(%ebp),%eax
  100836:	8b 40 14             	mov    0x14(%eax),%eax
  100839:	8d 50 01             	lea    0x1(%eax),%edx
  10083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100845:	40                   	inc    %eax
  100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10084f:	39 c2                	cmp    %eax,%edx
  100851:	7d 1d                	jge    100870 <debuginfo_eip+0x31f>
  100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	89 d0                	mov    %edx,%eax
  10085a:	01 c0                	add    %eax,%eax
  10085c:	01 d0                	add    %edx,%eax
  10085e:	c1 e0 02             	shl    $0x2,%eax
  100861:	89 c2                	mov    %eax,%edx
  100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086c:	3c a0                	cmp    $0xa0,%al
  10086e:	74 c3                	je     100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100875:	89 ec                	mov    %ebp,%esp
  100877:	5d                   	pop    %ebp
  100878:	c3                   	ret    

00100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100879:	55                   	push   %ebp
  10087a:	89 e5                	mov    %esp,%ebp
  10087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087f:	c7 04 24 d6 70 10 00 	movl   $0x1070d6,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 ef 70 10 00 	movl   $0x1070ef,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 10 70 10 	movl   $0x107010,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 07 71 10 00 	movl   $0x107107,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 ba 11 	movl   $0x11ba36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 1f 71 10 00 	movl   $0x10711f,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 8c ef 11 	movl   $0x11ef8c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 37 71 10 00 	movl   $0x107137,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 8c ef 11 00       	mov    $0x11ef8c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 50 71 10 00 	movl   $0x107150,(%esp)
  100903:	e8 4e fa ff ff       	call   100356 <cprintf>
}
  100908:	90                   	nop
  100909:	89 ec                	mov    %ebp,%esp
  10090b:	5d                   	pop    %ebp
  10090c:	c3                   	ret    

0010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100919:	89 44 24 04          	mov    %eax,0x4(%esp)
  10091d:	8b 45 08             	mov    0x8(%ebp),%eax
  100920:	89 04 24             	mov    %eax,(%esp)
  100923:	e8 29 fc ff ff       	call   100551 <debuginfo_eip>
  100928:	85 c0                	test   %eax,%eax
  10092a:	74 15                	je     100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100933:	c7 04 24 7a 71 10 00 	movl   $0x10717a,(%esp)
  10093a:	e8 17 fa ff ff       	call   100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093f:	eb 6c                	jmp    1009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100948:	eb 1b                	jmp    100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100950:	01 d0                	add    %edx,%eax
  100952:	0f b6 10             	movzbl (%eax),%edx
  100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095e:	01 c8                	add    %ecx,%eax
  100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100962:	ff 45 f4             	incl   -0xc(%ebp)
  100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10096b:	7c dd                	jl     10094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100976:	01 d0                	add    %edx,%eax
  100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097e:	8b 45 08             	mov    0x8(%ebp),%eax
  100981:	29 d0                	sub    %edx,%eax
  100983:	89 c1                	mov    %eax,%ecx
  100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100999:	89 54 24 08          	mov    %edx,0x8(%esp)
  10099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a1:	c7 04 24 96 71 10 00 	movl   $0x107196,(%esp)
  1009a8:	e8 a9 f9 ff ff       	call   100356 <cprintf>
}
  1009ad:	90                   	nop
  1009ae:	89 ec                	mov    %ebp,%esp
  1009b0:	5d                   	pop    %ebp
  1009b1:	c3                   	ret    

001009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b2:	55                   	push   %ebp
  1009b3:	89 e5                	mov    %esp,%ebp
  1009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c1:	89 ec                	mov    %ebp,%esp
  1009c3:	5d                   	pop    %ebp
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cb:	89 e8                	mov    %ebp,%eax
  1009cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t* ebp = (uint32_t *)read_ebp();
  1009d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  1009d6:	e8 d7 ff ff ff       	call   1009b2 <read_eip>
  1009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
        for (int i = 0; i < STACKFRAME_DEPTH && (uint32_t)ebp != 0; ++ i) {
  1009de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e5:	eb 7c                	jmp    100a63 <print_stackframe+0x9e>
        cprintf("ebp:0x%08x eip:0x%08x args:", (uint32_t)ebp, eip);
  1009e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1009ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f5:	c7 04 24 a8 71 10 00 	movl   $0x1071a8,(%esp)
  1009fc:	e8 55 f9 ff ff       	call   100356 <cprintf>
        for (int argi = 0; argi < 4; argi++) {
  100a01:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a08:	eb 27                	jmp    100a31 <print_stackframe+0x6c>
            cprintf("0x%08x ", ebp[2 + argi]);
  100a0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a0d:	83 c0 02             	add    $0x2,%eax
  100a10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a1a:	01 d0                	add    %edx,%eax
  100a1c:	8b 00                	mov    (%eax),%eax
  100a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a22:	c7 04 24 c4 71 10 00 	movl   $0x1071c4,(%esp)
  100a29:	e8 28 f9 ff ff       	call   100356 <cprintf>
        for (int argi = 0; argi < 4; argi++) {
  100a2e:	ff 45 e8             	incl   -0x18(%ebp)
  100a31:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a35:	7e d3                	jle    100a0a <print_stackframe+0x45>
        }
        cprintf("\n");
  100a37:	c7 04 24 cc 71 10 00 	movl   $0x1071cc,(%esp)
  100a3e:	e8 13 f9 ff ff       	call   100356 <cprintf>
        print_debuginfo(eip - 1);
  100a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a46:	48                   	dec    %eax
  100a47:	89 04 24             	mov    %eax,(%esp)
  100a4a:	e8 be fe ff ff       	call   10090d <print_debuginfo>
        eip = ebp[1];//更新为其指向的位置上前一个字的值，函数返回的pc跳转地址
  100a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a52:	8b 40 04             	mov    0x4(%eax),%eax
  100a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = (uint32_t *)*ebp;//更新为其指向的位置上的值，这里存储着上一个栈块的ebp
  100a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5b:	8b 00                	mov    (%eax),%eax
  100a5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (int i = 0; i < STACKFRAME_DEPTH && (uint32_t)ebp != 0; ++ i) {
  100a60:	ff 45 ec             	incl   -0x14(%ebp)
  100a63:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a67:	7f 0a                	jg     100a73 <print_stackframe+0xae>
  100a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a6d:	0f 85 74 ff ff ff    	jne    1009e7 <print_stackframe+0x22>
    }
}
  100a73:	90                   	nop
  100a74:	89 ec                	mov    %ebp,%esp
  100a76:	5d                   	pop    %ebp
  100a77:	c3                   	ret    

00100a78 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a78:	55                   	push   %ebp
  100a79:	89 e5                	mov    %esp,%ebp
  100a7b:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a85:	eb 0c                	jmp    100a93 <parse+0x1b>
            *buf ++ = '\0';
  100a87:	8b 45 08             	mov    0x8(%ebp),%eax
  100a8a:	8d 50 01             	lea    0x1(%eax),%edx
  100a8d:	89 55 08             	mov    %edx,0x8(%ebp)
  100a90:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a93:	8b 45 08             	mov    0x8(%ebp),%eax
  100a96:	0f b6 00             	movzbl (%eax),%eax
  100a99:	84 c0                	test   %al,%al
  100a9b:	74 1d                	je     100aba <parse+0x42>
  100a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa0:	0f b6 00             	movzbl (%eax),%eax
  100aa3:	0f be c0             	movsbl %al,%eax
  100aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aaa:	c7 04 24 50 72 10 00 	movl   $0x107250,(%esp)
  100ab1:	e8 12 62 00 00       	call   106cc8 <strchr>
  100ab6:	85 c0                	test   %eax,%eax
  100ab8:	75 cd                	jne    100a87 <parse+0xf>
        }
        if (*buf == '\0') {
  100aba:	8b 45 08             	mov    0x8(%ebp),%eax
  100abd:	0f b6 00             	movzbl (%eax),%eax
  100ac0:	84 c0                	test   %al,%al
  100ac2:	74 65                	je     100b29 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ac4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ac8:	75 14                	jne    100ade <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100aca:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ad1:	00 
  100ad2:	c7 04 24 55 72 10 00 	movl   $0x107255,(%esp)
  100ad9:	e8 78 f8 ff ff       	call   100356 <cprintf>
        }
        argv[argc ++] = buf;
  100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ae1:	8d 50 01             	lea    0x1(%eax),%edx
  100ae4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ae7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  100af1:	01 c2                	add    %eax,%edx
  100af3:	8b 45 08             	mov    0x8(%ebp),%eax
  100af6:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100af8:	eb 03                	jmp    100afd <parse+0x85>
            buf ++;
  100afa:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100afd:	8b 45 08             	mov    0x8(%ebp),%eax
  100b00:	0f b6 00             	movzbl (%eax),%eax
  100b03:	84 c0                	test   %al,%al
  100b05:	74 8c                	je     100a93 <parse+0x1b>
  100b07:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0a:	0f b6 00             	movzbl (%eax),%eax
  100b0d:	0f be c0             	movsbl %al,%eax
  100b10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b14:	c7 04 24 50 72 10 00 	movl   $0x107250,(%esp)
  100b1b:	e8 a8 61 00 00       	call   106cc8 <strchr>
  100b20:	85 c0                	test   %eax,%eax
  100b22:	74 d6                	je     100afa <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b24:	e9 6a ff ff ff       	jmp    100a93 <parse+0x1b>
            break;
  100b29:	90                   	nop
        }
    }
    return argc;
  100b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b2d:	89 ec                	mov    %ebp,%esp
  100b2f:	5d                   	pop    %ebp
  100b30:	c3                   	ret    

00100b31 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b31:	55                   	push   %ebp
  100b32:	89 e5                	mov    %esp,%ebp
  100b34:	83 ec 68             	sub    $0x68,%esp
  100b37:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b3a:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b41:	8b 45 08             	mov    0x8(%ebp),%eax
  100b44:	89 04 24             	mov    %eax,(%esp)
  100b47:	e8 2c ff ff ff       	call   100a78 <parse>
  100b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b53:	75 0a                	jne    100b5f <runcmd+0x2e>
        return 0;
  100b55:	b8 00 00 00 00       	mov    $0x0,%eax
  100b5a:	e9 83 00 00 00       	jmp    100be2 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b66:	eb 5a                	jmp    100bc2 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b68:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b6b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b6e:	89 c8                	mov    %ecx,%eax
  100b70:	01 c0                	add    %eax,%eax
  100b72:	01 c8                	add    %ecx,%eax
  100b74:	c1 e0 02             	shl    $0x2,%eax
  100b77:	05 00 b0 11 00       	add    $0x11b000,%eax
  100b7c:	8b 00                	mov    (%eax),%eax
  100b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b82:	89 04 24             	mov    %eax,(%esp)
  100b85:	e8 a2 60 00 00       	call   106c2c <strcmp>
  100b8a:	85 c0                	test   %eax,%eax
  100b8c:	75 31                	jne    100bbf <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b91:	89 d0                	mov    %edx,%eax
  100b93:	01 c0                	add    %eax,%eax
  100b95:	01 d0                	add    %edx,%eax
  100b97:	c1 e0 02             	shl    $0x2,%eax
  100b9a:	05 08 b0 11 00       	add    $0x11b008,%eax
  100b9f:	8b 10                	mov    (%eax),%edx
  100ba1:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100ba4:	83 c0 04             	add    $0x4,%eax
  100ba7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100baa:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bb0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb8:	89 1c 24             	mov    %ebx,(%esp)
  100bbb:	ff d2                	call   *%edx
  100bbd:	eb 23                	jmp    100be2 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bbf:	ff 45 f4             	incl   -0xc(%ebp)
  100bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bc5:	83 f8 02             	cmp    $0x2,%eax
  100bc8:	76 9e                	jbe    100b68 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bca:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bd1:	c7 04 24 73 72 10 00 	movl   $0x107273,(%esp)
  100bd8:	e8 79 f7 ff ff       	call   100356 <cprintf>
    return 0;
  100bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100be5:	89 ec                	mov    %ebp,%esp
  100be7:	5d                   	pop    %ebp
  100be8:	c3                   	ret    

00100be9 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100be9:	55                   	push   %ebp
  100bea:	89 e5                	mov    %esp,%ebp
  100bec:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bef:	c7 04 24 8c 72 10 00 	movl   $0x10728c,(%esp)
  100bf6:	e8 5b f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100bfb:	c7 04 24 b4 72 10 00 	movl   $0x1072b4,(%esp)
  100c02:	e8 4f f7 ff ff       	call   100356 <cprintf>

    if (tf != NULL) {
  100c07:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c0b:	74 0b                	je     100c18 <kmonitor+0x2f>
        print_trapframe(tf);
  100c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100c10:	89 04 24             	mov    %eax,(%esp)
  100c13:	e8 f2 0e 00 00       	call   101b0a <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c18:	c7 04 24 d9 72 10 00 	movl   $0x1072d9,(%esp)
  100c1f:	e8 23 f6 ff ff       	call   100247 <readline>
  100c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c2b:	74 eb                	je     100c18 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  100c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c37:	89 04 24             	mov    %eax,(%esp)
  100c3a:	e8 f2 fe ff ff       	call   100b31 <runcmd>
  100c3f:	85 c0                	test   %eax,%eax
  100c41:	78 02                	js     100c45 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c43:	eb d3                	jmp    100c18 <kmonitor+0x2f>
                break;
  100c45:	90                   	nop
            }
        }
    }
}
  100c46:	90                   	nop
  100c47:	89 ec                	mov    %ebp,%esp
  100c49:	5d                   	pop    %ebp
  100c4a:	c3                   	ret    

00100c4b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c4b:	55                   	push   %ebp
  100c4c:	89 e5                	mov    %esp,%ebp
  100c4e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c58:	eb 3d                	jmp    100c97 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c5d:	89 d0                	mov    %edx,%eax
  100c5f:	01 c0                	add    %eax,%eax
  100c61:	01 d0                	add    %edx,%eax
  100c63:	c1 e0 02             	shl    $0x2,%eax
  100c66:	05 04 b0 11 00       	add    $0x11b004,%eax
  100c6b:	8b 10                	mov    (%eax),%edx
  100c6d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c70:	89 c8                	mov    %ecx,%eax
  100c72:	01 c0                	add    %eax,%eax
  100c74:	01 c8                	add    %ecx,%eax
  100c76:	c1 e0 02             	shl    $0x2,%eax
  100c79:	05 00 b0 11 00       	add    $0x11b000,%eax
  100c7e:	8b 00                	mov    (%eax),%eax
  100c80:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c88:	c7 04 24 dd 72 10 00 	movl   $0x1072dd,(%esp)
  100c8f:	e8 c2 f6 ff ff       	call   100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c94:	ff 45 f4             	incl   -0xc(%ebp)
  100c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c9a:	83 f8 02             	cmp    $0x2,%eax
  100c9d:	76 bb                	jbe    100c5a <mon_help+0xf>
    }
    return 0;
  100c9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca4:	89 ec                	mov    %ebp,%esp
  100ca6:	5d                   	pop    %ebp
  100ca7:	c3                   	ret    

00100ca8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100ca8:	55                   	push   %ebp
  100ca9:	89 e5                	mov    %esp,%ebp
  100cab:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cae:	e8 c6 fb ff ff       	call   100879 <print_kerninfo>
    return 0;
  100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb8:	89 ec                	mov    %ebp,%esp
  100cba:	5d                   	pop    %ebp
  100cbb:	c3                   	ret    

00100cbc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cbc:	55                   	push   %ebp
  100cbd:	89 e5                	mov    %esp,%ebp
  100cbf:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc2:	e8 fe fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ccc:	89 ec                	mov    %ebp,%esp
  100cce:	5d                   	pop    %ebp
  100ccf:	c3                   	ret    

00100cd0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd0:	55                   	push   %ebp
  100cd1:	89 e5                	mov    %esp,%ebp
  100cd3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd6:	a1 20 e4 11 00       	mov    0x11e420,%eax
  100cdb:	85 c0                	test   %eax,%eax
  100cdd:	75 5b                	jne    100d3a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cdf:	c7 05 20 e4 11 00 01 	movl   $0x1,0x11e420
  100ce6:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ce9:	8d 45 14             	lea    0x14(%ebp),%eax
  100cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cfd:	c7 04 24 e6 72 10 00 	movl   $0x1072e6,(%esp)
  100d04:	e8 4d f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d10:	8b 45 10             	mov    0x10(%ebp),%eax
  100d13:	89 04 24             	mov    %eax,(%esp)
  100d16:	e8 06 f6 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d1b:	c7 04 24 02 73 10 00 	movl   $0x107302,(%esp)
  100d22:	e8 2f f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d27:	c7 04 24 04 73 10 00 	movl   $0x107304,(%esp)
  100d2e:	e8 23 f6 ff ff       	call   100356 <cprintf>
    print_stackframe();
  100d33:	e8 8d fc ff ff       	call   1009c5 <print_stackframe>
  100d38:	eb 01                	jmp    100d3b <__panic+0x6b>
        goto panic_dead;
  100d3a:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d3b:	e8 e9 09 00 00       	call   101729 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d47:	e8 9d fe ff ff       	call   100be9 <kmonitor>
  100d4c:	eb f2                	jmp    100d40 <__panic+0x70>

00100d4e <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4e:	55                   	push   %ebp
  100d4f:	89 e5                	mov    %esp,%ebp
  100d51:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d54:	8d 45 14             	lea    0x14(%ebp),%eax
  100d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d61:	8b 45 08             	mov    0x8(%ebp),%eax
  100d64:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d68:	c7 04 24 16 73 10 00 	movl   $0x107316,(%esp)
  100d6f:	e8 e2 f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7b:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7e:	89 04 24             	mov    %eax,(%esp)
  100d81:	e8 9b f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d86:	c7 04 24 02 73 10 00 	movl   $0x107302,(%esp)
  100d8d:	e8 c4 f5 ff ff       	call   100356 <cprintf>
    va_end(ap);
}
  100d92:	90                   	nop
  100d93:	89 ec                	mov    %ebp,%esp
  100d95:	5d                   	pop    %ebp
  100d96:	c3                   	ret    

00100d97 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d97:	55                   	push   %ebp
  100d98:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d9a:	a1 20 e4 11 00       	mov    0x11e420,%eax
}
  100d9f:	5d                   	pop    %ebp
  100da0:	c3                   	ret    

00100da1 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100da1:	55                   	push   %ebp
  100da2:	89 e5                	mov    %esp,%ebp
  100da4:	83 ec 28             	sub    $0x28,%esp
  100da7:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dad:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100db1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100db5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db9:	ee                   	out    %al,(%dx)
}
  100dba:	90                   	nop
  100dbb:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dc1:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dc5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dcd:	ee                   	out    %al,(%dx)
}
  100dce:	90                   	nop
  100dcf:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dd5:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dd9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100ddd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100de1:	ee                   	out    %al,(%dx)
}
  100de2:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100de3:	c7 05 24 e4 11 00 00 	movl   $0x0,0x11e424
  100dea:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100ded:	c7 04 24 34 73 10 00 	movl   $0x107334,(%esp)
  100df4:	e8 5d f5 ff ff       	call   100356 <cprintf>
    pic_enable(IRQ_TIMER);
  100df9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e00:	e8 89 09 00 00       	call   10178e <pic_enable>
}
  100e05:	90                   	nop
  100e06:	89 ec                	mov    %ebp,%esp
  100e08:	5d                   	pop    %ebp
  100e09:	c3                   	ret    

00100e0a <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e0a:	55                   	push   %ebp
  100e0b:	89 e5                	mov    %esp,%ebp
  100e0d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e10:	9c                   	pushf  
  100e11:	58                   	pop    %eax
  100e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e18:	25 00 02 00 00       	and    $0x200,%eax
  100e1d:	85 c0                	test   %eax,%eax
  100e1f:	74 0c                	je     100e2d <__intr_save+0x23>
        intr_disable();
  100e21:	e8 03 09 00 00       	call   101729 <intr_disable>
        return 1;
  100e26:	b8 01 00 00 00       	mov    $0x1,%eax
  100e2b:	eb 05                	jmp    100e32 <__intr_save+0x28>
    }
    return 0;
  100e2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e32:	89 ec                	mov    %ebp,%esp
  100e34:	5d                   	pop    %ebp
  100e35:	c3                   	ret    

00100e36 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e36:	55                   	push   %ebp
  100e37:	89 e5                	mov    %esp,%ebp
  100e39:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e40:	74 05                	je     100e47 <__intr_restore+0x11>
        intr_enable();
  100e42:	e8 da 08 00 00       	call   101721 <intr_enable>
    }
}
  100e47:	90                   	nop
  100e48:	89 ec                	mov    %ebp,%esp
  100e4a:	5d                   	pop    %ebp
  100e4b:	c3                   	ret    

00100e4c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e4c:	55                   	push   %ebp
  100e4d:	89 e5                	mov    %esp,%ebp
  100e4f:	83 ec 10             	sub    $0x10,%esp
  100e52:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e58:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e5c:	89 c2                	mov    %eax,%edx
  100e5e:	ec                   	in     (%dx),%al
  100e5f:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e62:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e68:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6c:	89 c2                	mov    %eax,%edx
  100e6e:	ec                   	in     (%dx),%al
  100e6f:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e72:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e78:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e7c:	89 c2                	mov    %eax,%edx
  100e7e:	ec                   	in     (%dx),%al
  100e7f:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e82:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e88:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e8c:	89 c2                	mov    %eax,%edx
  100e8e:	ec                   	in     (%dx),%al
  100e8f:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e92:	90                   	nop
  100e93:	89 ec                	mov    %ebp,%esp
  100e95:	5d                   	pop    %ebp
  100e96:	c3                   	ret    

00100e97 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e97:	55                   	push   %ebp
  100e98:	89 e5                	mov    %esp,%ebp
  100e9a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e9d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea7:	0f b7 00             	movzwl (%eax),%eax
  100eaa:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb9:	0f b7 00             	movzwl (%eax),%eax
  100ebc:	0f b7 c0             	movzwl %ax,%eax
  100ebf:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ec4:	74 12                	je     100ed8 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ec6:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ecd:	66 c7 05 46 e4 11 00 	movw   $0x3b4,0x11e446
  100ed4:	b4 03 
  100ed6:	eb 13                	jmp    100eeb <cga_init+0x54>
    } else {
        *cp = was;
  100ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100edf:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee2:	66 c7 05 46 e4 11 00 	movw   $0x3d4,0x11e446
  100ee9:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eeb:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  100ef2:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ef6:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100efa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100efe:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f02:	ee                   	out    %al,(%dx)
}
  100f03:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f04:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  100f0b:	40                   	inc    %eax
  100f0c:	0f b7 c0             	movzwl %ax,%eax
  100f0f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f13:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f17:	89 c2                	mov    %eax,%edx
  100f19:	ec                   	in     (%dx),%al
  100f1a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f1d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f21:	0f b6 c0             	movzbl %al,%eax
  100f24:	c1 e0 08             	shl    $0x8,%eax
  100f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f2a:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f41:	ee                   	out    %al,(%dx)
}
  100f42:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f43:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  100f4a:	40                   	inc    %eax
  100f4b:	0f b7 c0             	movzwl %ax,%eax
  100f4e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f52:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f56:	89 c2                	mov    %eax,%edx
  100f58:	ec                   	in     (%dx),%al
  100f59:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f5c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f60:	0f b6 c0             	movzbl %al,%eax
  100f63:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f66:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f69:	a3 40 e4 11 00       	mov    %eax,0x11e440
    crt_pos = pos;
  100f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f71:	0f b7 c0             	movzwl %ax,%eax
  100f74:	66 a3 44 e4 11 00    	mov    %ax,0x11e444
}
  100f7a:	90                   	nop
  100f7b:	89 ec                	mov    %ebp,%esp
  100f7d:	5d                   	pop    %ebp
  100f7e:	c3                   	ret    

00100f7f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f7f:	55                   	push   %ebp
  100f80:	89 e5                	mov    %esp,%ebp
  100f82:	83 ec 48             	sub    $0x48,%esp
  100f85:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f8b:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f8f:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f93:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f97:	ee                   	out    %al,(%dx)
}
  100f98:	90                   	nop
  100f99:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f9f:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fa3:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fa7:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fab:	ee                   	out    %al,(%dx)
}
  100fac:	90                   	nop
  100fad:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fb3:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fb7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fbb:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fbf:	ee                   	out    %al,(%dx)
}
  100fc0:	90                   	nop
  100fc1:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fc7:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fcb:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fcf:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fd3:	ee                   	out    %al,(%dx)
}
  100fd4:	90                   	nop
  100fd5:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fdb:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fdf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fe3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe7:	ee                   	out    %al,(%dx)
}
  100fe8:	90                   	nop
  100fe9:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fef:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ff3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ff7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ffb:	ee                   	out    %al,(%dx)
}
  100ffc:	90                   	nop
  100ffd:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  101003:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101007:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10100b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10100f:	ee                   	out    %al,(%dx)
}
  101010:	90                   	nop
  101011:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101017:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  10101b:	89 c2                	mov    %eax,%edx
  10101d:	ec                   	in     (%dx),%al
  10101e:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101021:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101025:	3c ff                	cmp    $0xff,%al
  101027:	0f 95 c0             	setne  %al
  10102a:	0f b6 c0             	movzbl %al,%eax
  10102d:	a3 48 e4 11 00       	mov    %eax,0x11e448
  101032:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101038:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10103c:	89 c2                	mov    %eax,%edx
  10103e:	ec                   	in     (%dx),%al
  10103f:	88 45 f1             	mov    %al,-0xf(%ebp)
  101042:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101048:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10104c:	89 c2                	mov    %eax,%edx
  10104e:	ec                   	in     (%dx),%al
  10104f:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101052:	a1 48 e4 11 00       	mov    0x11e448,%eax
  101057:	85 c0                	test   %eax,%eax
  101059:	74 0c                	je     101067 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  10105b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101062:	e8 27 07 00 00       	call   10178e <pic_enable>
    }
}
  101067:	90                   	nop
  101068:	89 ec                	mov    %ebp,%esp
  10106a:	5d                   	pop    %ebp
  10106b:	c3                   	ret    

0010106c <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10106c:	55                   	push   %ebp
  10106d:	89 e5                	mov    %esp,%ebp
  10106f:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101072:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101079:	eb 08                	jmp    101083 <lpt_putc_sub+0x17>
        delay();
  10107b:	e8 cc fd ff ff       	call   100e4c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101080:	ff 45 fc             	incl   -0x4(%ebp)
  101083:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101089:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10108d:	89 c2                	mov    %eax,%edx
  10108f:	ec                   	in     (%dx),%al
  101090:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101093:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101097:	84 c0                	test   %al,%al
  101099:	78 09                	js     1010a4 <lpt_putc_sub+0x38>
  10109b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010a2:	7e d7                	jle    10107b <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a7:	0f b6 c0             	movzbl %al,%eax
  1010aa:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010b0:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010b3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010b7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010bb:	ee                   	out    %al,(%dx)
}
  1010bc:	90                   	nop
  1010bd:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010c3:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010c7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010cf:	ee                   	out    %al,(%dx)
}
  1010d0:	90                   	nop
  1010d1:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010d7:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010db:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010df:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010e3:	ee                   	out    %al,(%dx)
}
  1010e4:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010e5:	90                   	nop
  1010e6:	89 ec                	mov    %ebp,%esp
  1010e8:	5d                   	pop    %ebp
  1010e9:	c3                   	ret    

001010ea <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010ea:	55                   	push   %ebp
  1010eb:	89 e5                	mov    %esp,%ebp
  1010ed:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010f0:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010f4:	74 0d                	je     101103 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f9:	89 04 24             	mov    %eax,(%esp)
  1010fc:	e8 6b ff ff ff       	call   10106c <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101101:	eb 24                	jmp    101127 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  101103:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10110a:	e8 5d ff ff ff       	call   10106c <lpt_putc_sub>
        lpt_putc_sub(' ');
  10110f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101116:	e8 51 ff ff ff       	call   10106c <lpt_putc_sub>
        lpt_putc_sub('\b');
  10111b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101122:	e8 45 ff ff ff       	call   10106c <lpt_putc_sub>
}
  101127:	90                   	nop
  101128:	89 ec                	mov    %ebp,%esp
  10112a:	5d                   	pop    %ebp
  10112b:	c3                   	ret    

0010112c <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10112c:	55                   	push   %ebp
  10112d:	89 e5                	mov    %esp,%ebp
  10112f:	83 ec 38             	sub    $0x38,%esp
  101132:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  101135:	8b 45 08             	mov    0x8(%ebp),%eax
  101138:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10113d:	85 c0                	test   %eax,%eax
  10113f:	75 07                	jne    101148 <cga_putc+0x1c>
        c |= 0x0700;
  101141:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101148:	8b 45 08             	mov    0x8(%ebp),%eax
  10114b:	0f b6 c0             	movzbl %al,%eax
  10114e:	83 f8 0d             	cmp    $0xd,%eax
  101151:	74 72                	je     1011c5 <cga_putc+0x99>
  101153:	83 f8 0d             	cmp    $0xd,%eax
  101156:	0f 8f a3 00 00 00    	jg     1011ff <cga_putc+0xd3>
  10115c:	83 f8 08             	cmp    $0x8,%eax
  10115f:	74 0a                	je     10116b <cga_putc+0x3f>
  101161:	83 f8 0a             	cmp    $0xa,%eax
  101164:	74 4c                	je     1011b2 <cga_putc+0x86>
  101166:	e9 94 00 00 00       	jmp    1011ff <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  10116b:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  101172:	85 c0                	test   %eax,%eax
  101174:	0f 84 af 00 00 00    	je     101229 <cga_putc+0xfd>
            crt_pos --;
  10117a:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  101181:	48                   	dec    %eax
  101182:	0f b7 c0             	movzwl %ax,%eax
  101185:	66 a3 44 e4 11 00    	mov    %ax,0x11e444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10118b:	8b 45 08             	mov    0x8(%ebp),%eax
  10118e:	98                   	cwtl   
  10118f:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101194:	98                   	cwtl   
  101195:	83 c8 20             	or     $0x20,%eax
  101198:	98                   	cwtl   
  101199:	8b 0d 40 e4 11 00    	mov    0x11e440,%ecx
  10119f:	0f b7 15 44 e4 11 00 	movzwl 0x11e444,%edx
  1011a6:	01 d2                	add    %edx,%edx
  1011a8:	01 ca                	add    %ecx,%edx
  1011aa:	0f b7 c0             	movzwl %ax,%eax
  1011ad:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011b0:	eb 77                	jmp    101229 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011b2:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  1011b9:	83 c0 50             	add    $0x50,%eax
  1011bc:	0f b7 c0             	movzwl %ax,%eax
  1011bf:	66 a3 44 e4 11 00    	mov    %ax,0x11e444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011c5:	0f b7 1d 44 e4 11 00 	movzwl 0x11e444,%ebx
  1011cc:	0f b7 0d 44 e4 11 00 	movzwl 0x11e444,%ecx
  1011d3:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011d8:	89 c8                	mov    %ecx,%eax
  1011da:	f7 e2                	mul    %edx
  1011dc:	c1 ea 06             	shr    $0x6,%edx
  1011df:	89 d0                	mov    %edx,%eax
  1011e1:	c1 e0 02             	shl    $0x2,%eax
  1011e4:	01 d0                	add    %edx,%eax
  1011e6:	c1 e0 04             	shl    $0x4,%eax
  1011e9:	29 c1                	sub    %eax,%ecx
  1011eb:	89 ca                	mov    %ecx,%edx
  1011ed:	0f b7 d2             	movzwl %dx,%edx
  1011f0:	89 d8                	mov    %ebx,%eax
  1011f2:	29 d0                	sub    %edx,%eax
  1011f4:	0f b7 c0             	movzwl %ax,%eax
  1011f7:	66 a3 44 e4 11 00    	mov    %ax,0x11e444
        break;
  1011fd:	eb 2b                	jmp    10122a <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011ff:	8b 0d 40 e4 11 00    	mov    0x11e440,%ecx
  101205:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  10120c:	8d 50 01             	lea    0x1(%eax),%edx
  10120f:	0f b7 d2             	movzwl %dx,%edx
  101212:	66 89 15 44 e4 11 00 	mov    %dx,0x11e444
  101219:	01 c0                	add    %eax,%eax
  10121b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10121e:	8b 45 08             	mov    0x8(%ebp),%eax
  101221:	0f b7 c0             	movzwl %ax,%eax
  101224:	66 89 02             	mov    %ax,(%edx)
        break;
  101227:	eb 01                	jmp    10122a <cga_putc+0xfe>
        break;
  101229:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10122a:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  101231:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101236:	76 5e                	jbe    101296 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101238:	a1 40 e4 11 00       	mov    0x11e440,%eax
  10123d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101243:	a1 40 e4 11 00       	mov    0x11e440,%eax
  101248:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10124f:	00 
  101250:	89 54 24 04          	mov    %edx,0x4(%esp)
  101254:	89 04 24             	mov    %eax,(%esp)
  101257:	e8 6a 5c 00 00       	call   106ec6 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10125c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101263:	eb 15                	jmp    10127a <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101265:	8b 15 40 e4 11 00    	mov    0x11e440,%edx
  10126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10126e:	01 c0                	add    %eax,%eax
  101270:	01 d0                	add    %edx,%eax
  101272:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101277:	ff 45 f4             	incl   -0xc(%ebp)
  10127a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101281:	7e e2                	jle    101265 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  101283:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  10128a:	83 e8 50             	sub    $0x50,%eax
  10128d:	0f b7 c0             	movzwl %ax,%eax
  101290:	66 a3 44 e4 11 00    	mov    %ax,0x11e444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101296:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  10129d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012a1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012a5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012a9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
}
  1012ae:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012af:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  1012b6:	c1 e8 08             	shr    $0x8,%eax
  1012b9:	0f b7 c0             	movzwl %ax,%eax
  1012bc:	0f b6 c0             	movzbl %al,%eax
  1012bf:	0f b7 15 46 e4 11 00 	movzwl 0x11e446,%edx
  1012c6:	42                   	inc    %edx
  1012c7:	0f b7 d2             	movzwl %dx,%edx
  1012ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012ce:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012d1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012d5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012d9:	ee                   	out    %al,(%dx)
}
  1012da:	90                   	nop
    outb(addr_6845, 15);
  1012db:	0f b7 05 46 e4 11 00 	movzwl 0x11e446,%eax
  1012e2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012e6:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012ea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012ee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012f2:	ee                   	out    %al,(%dx)
}
  1012f3:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012f4:	0f b7 05 44 e4 11 00 	movzwl 0x11e444,%eax
  1012fb:	0f b6 c0             	movzbl %al,%eax
  1012fe:	0f b7 15 46 e4 11 00 	movzwl 0x11e446,%edx
  101305:	42                   	inc    %edx
  101306:	0f b7 d2             	movzwl %dx,%edx
  101309:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  10130d:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101310:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101314:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101318:	ee                   	out    %al,(%dx)
}
  101319:	90                   	nop
}
  10131a:	90                   	nop
  10131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10131e:	89 ec                	mov    %ebp,%esp
  101320:	5d                   	pop    %ebp
  101321:	c3                   	ret    

00101322 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101322:	55                   	push   %ebp
  101323:	89 e5                	mov    %esp,%ebp
  101325:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101328:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10132f:	eb 08                	jmp    101339 <serial_putc_sub+0x17>
        delay();
  101331:	e8 16 fb ff ff       	call   100e4c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101336:	ff 45 fc             	incl   -0x4(%ebp)
  101339:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10133f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101343:	89 c2                	mov    %eax,%edx
  101345:	ec                   	in     (%dx),%al
  101346:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101349:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10134d:	0f b6 c0             	movzbl %al,%eax
  101350:	83 e0 20             	and    $0x20,%eax
  101353:	85 c0                	test   %eax,%eax
  101355:	75 09                	jne    101360 <serial_putc_sub+0x3e>
  101357:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10135e:	7e d1                	jle    101331 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101360:	8b 45 08             	mov    0x8(%ebp),%eax
  101363:	0f b6 c0             	movzbl %al,%eax
  101366:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10136c:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10136f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101373:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101377:	ee                   	out    %al,(%dx)
}
  101378:	90                   	nop
}
  101379:	90                   	nop
  10137a:	89 ec                	mov    %ebp,%esp
  10137c:	5d                   	pop    %ebp
  10137d:	c3                   	ret    

0010137e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10137e:	55                   	push   %ebp
  10137f:	89 e5                	mov    %esp,%ebp
  101381:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101384:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101388:	74 0d                	je     101397 <serial_putc+0x19>
        serial_putc_sub(c);
  10138a:	8b 45 08             	mov    0x8(%ebp),%eax
  10138d:	89 04 24             	mov    %eax,(%esp)
  101390:	e8 8d ff ff ff       	call   101322 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101395:	eb 24                	jmp    1013bb <serial_putc+0x3d>
        serial_putc_sub('\b');
  101397:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10139e:	e8 7f ff ff ff       	call   101322 <serial_putc_sub>
        serial_putc_sub(' ');
  1013a3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013aa:	e8 73 ff ff ff       	call   101322 <serial_putc_sub>
        serial_putc_sub('\b');
  1013af:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013b6:	e8 67 ff ff ff       	call   101322 <serial_putc_sub>
}
  1013bb:	90                   	nop
  1013bc:	89 ec                	mov    %ebp,%esp
  1013be:	5d                   	pop    %ebp
  1013bf:	c3                   	ret    

001013c0 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013c0:	55                   	push   %ebp
  1013c1:	89 e5                	mov    %esp,%ebp
  1013c3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013c6:	eb 33                	jmp    1013fb <cons_intr+0x3b>
        if (c != 0) {
  1013c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013cc:	74 2d                	je     1013fb <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013ce:	a1 64 e6 11 00       	mov    0x11e664,%eax
  1013d3:	8d 50 01             	lea    0x1(%eax),%edx
  1013d6:	89 15 64 e6 11 00    	mov    %edx,0x11e664
  1013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013df:	88 90 60 e4 11 00    	mov    %dl,0x11e460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013e5:	a1 64 e6 11 00       	mov    0x11e664,%eax
  1013ea:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013ef:	75 0a                	jne    1013fb <cons_intr+0x3b>
                cons.wpos = 0;
  1013f1:	c7 05 64 e6 11 00 00 	movl   $0x0,0x11e664
  1013f8:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1013fe:	ff d0                	call   *%eax
  101400:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101403:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101407:	75 bf                	jne    1013c8 <cons_intr+0x8>
            }
        }
    }
}
  101409:	90                   	nop
  10140a:	90                   	nop
  10140b:	89 ec                	mov    %ebp,%esp
  10140d:	5d                   	pop    %ebp
  10140e:	c3                   	ret    

0010140f <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10140f:	55                   	push   %ebp
  101410:	89 e5                	mov    %esp,%ebp
  101412:	83 ec 10             	sub    $0x10,%esp
  101415:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10141b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10141f:	89 c2                	mov    %eax,%edx
  101421:	ec                   	in     (%dx),%al
  101422:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101425:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101429:	0f b6 c0             	movzbl %al,%eax
  10142c:	83 e0 01             	and    $0x1,%eax
  10142f:	85 c0                	test   %eax,%eax
  101431:	75 07                	jne    10143a <serial_proc_data+0x2b>
        return -1;
  101433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101438:	eb 2a                	jmp    101464 <serial_proc_data+0x55>
  10143a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101440:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101444:	89 c2                	mov    %eax,%edx
  101446:	ec                   	in     (%dx),%al
  101447:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10144a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10144e:	0f b6 c0             	movzbl %al,%eax
  101451:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101454:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101458:	75 07                	jne    101461 <serial_proc_data+0x52>
        c = '\b';
  10145a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101461:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101464:	89 ec                	mov    %ebp,%esp
  101466:	5d                   	pop    %ebp
  101467:	c3                   	ret    

00101468 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101468:	55                   	push   %ebp
  101469:	89 e5                	mov    %esp,%ebp
  10146b:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10146e:	a1 48 e4 11 00       	mov    0x11e448,%eax
  101473:	85 c0                	test   %eax,%eax
  101475:	74 0c                	je     101483 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101477:	c7 04 24 0f 14 10 00 	movl   $0x10140f,(%esp)
  10147e:	e8 3d ff ff ff       	call   1013c0 <cons_intr>
    }
}
  101483:	90                   	nop
  101484:	89 ec                	mov    %ebp,%esp
  101486:	5d                   	pop    %ebp
  101487:	c3                   	ret    

00101488 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101488:	55                   	push   %ebp
  101489:	89 e5                	mov    %esp,%ebp
  10148b:	83 ec 38             	sub    $0x38,%esp
  10148e:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101497:	89 c2                	mov    %eax,%edx
  101499:	ec                   	in     (%dx),%al
  10149a:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10149d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014a1:	0f b6 c0             	movzbl %al,%eax
  1014a4:	83 e0 01             	and    $0x1,%eax
  1014a7:	85 c0                	test   %eax,%eax
  1014a9:	75 0a                	jne    1014b5 <kbd_proc_data+0x2d>
        return -1;
  1014ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014b0:	e9 56 01 00 00       	jmp    10160b <kbd_proc_data+0x183>
  1014b5:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014be:	89 c2                	mov    %eax,%edx
  1014c0:	ec                   	in     (%dx),%al
  1014c1:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014c4:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014c8:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014cb:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014cf:	75 17                	jne    1014e8 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014d1:	a1 68 e6 11 00       	mov    0x11e668,%eax
  1014d6:	83 c8 40             	or     $0x40,%eax
  1014d9:	a3 68 e6 11 00       	mov    %eax,0x11e668
        return 0;
  1014de:	b8 00 00 00 00       	mov    $0x0,%eax
  1014e3:	e9 23 01 00 00       	jmp    10160b <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014e8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ec:	84 c0                	test   %al,%al
  1014ee:	79 45                	jns    101535 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014f0:	a1 68 e6 11 00       	mov    0x11e668,%eax
  1014f5:	83 e0 40             	and    $0x40,%eax
  1014f8:	85 c0                	test   %eax,%eax
  1014fa:	75 08                	jne    101504 <kbd_proc_data+0x7c>
  1014fc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101500:	24 7f                	and    $0x7f,%al
  101502:	eb 04                	jmp    101508 <kbd_proc_data+0x80>
  101504:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101508:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10150b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150f:	0f b6 80 40 b0 11 00 	movzbl 0x11b040(%eax),%eax
  101516:	0c 40                	or     $0x40,%al
  101518:	0f b6 c0             	movzbl %al,%eax
  10151b:	f7 d0                	not    %eax
  10151d:	89 c2                	mov    %eax,%edx
  10151f:	a1 68 e6 11 00       	mov    0x11e668,%eax
  101524:	21 d0                	and    %edx,%eax
  101526:	a3 68 e6 11 00       	mov    %eax,0x11e668
        return 0;
  10152b:	b8 00 00 00 00       	mov    $0x0,%eax
  101530:	e9 d6 00 00 00       	jmp    10160b <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101535:	a1 68 e6 11 00       	mov    0x11e668,%eax
  10153a:	83 e0 40             	and    $0x40,%eax
  10153d:	85 c0                	test   %eax,%eax
  10153f:	74 11                	je     101552 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101541:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101545:	a1 68 e6 11 00       	mov    0x11e668,%eax
  10154a:	83 e0 bf             	and    $0xffffffbf,%eax
  10154d:	a3 68 e6 11 00       	mov    %eax,0x11e668
    }

    shift |= shiftcode[data];
  101552:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101556:	0f b6 80 40 b0 11 00 	movzbl 0x11b040(%eax),%eax
  10155d:	0f b6 d0             	movzbl %al,%edx
  101560:	a1 68 e6 11 00       	mov    0x11e668,%eax
  101565:	09 d0                	or     %edx,%eax
  101567:	a3 68 e6 11 00       	mov    %eax,0x11e668
    shift ^= togglecode[data];
  10156c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101570:	0f b6 80 40 b1 11 00 	movzbl 0x11b140(%eax),%eax
  101577:	0f b6 d0             	movzbl %al,%edx
  10157a:	a1 68 e6 11 00       	mov    0x11e668,%eax
  10157f:	31 d0                	xor    %edx,%eax
  101581:	a3 68 e6 11 00       	mov    %eax,0x11e668

    c = charcode[shift & (CTL | SHIFT)][data];
  101586:	a1 68 e6 11 00       	mov    0x11e668,%eax
  10158b:	83 e0 03             	and    $0x3,%eax
  10158e:	8b 14 85 40 b5 11 00 	mov    0x11b540(,%eax,4),%edx
  101595:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101599:	01 d0                	add    %edx,%eax
  10159b:	0f b6 00             	movzbl (%eax),%eax
  10159e:	0f b6 c0             	movzbl %al,%eax
  1015a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015a4:	a1 68 e6 11 00       	mov    0x11e668,%eax
  1015a9:	83 e0 08             	and    $0x8,%eax
  1015ac:	85 c0                	test   %eax,%eax
  1015ae:	74 22                	je     1015d2 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015b0:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015b4:	7e 0c                	jle    1015c2 <kbd_proc_data+0x13a>
  1015b6:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015ba:	7f 06                	jg     1015c2 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1015bc:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015c0:	eb 10                	jmp    1015d2 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1015c2:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015c6:	7e 0a                	jle    1015d2 <kbd_proc_data+0x14a>
  1015c8:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015cc:	7f 04                	jg     1015d2 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015ce:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015d2:	a1 68 e6 11 00       	mov    0x11e668,%eax
  1015d7:	f7 d0                	not    %eax
  1015d9:	83 e0 06             	and    $0x6,%eax
  1015dc:	85 c0                	test   %eax,%eax
  1015de:	75 28                	jne    101608 <kbd_proc_data+0x180>
  1015e0:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015e7:	75 1f                	jne    101608 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015e9:	c7 04 24 4f 73 10 00 	movl   $0x10734f,(%esp)
  1015f0:	e8 61 ed ff ff       	call   100356 <cprintf>
  1015f5:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015fb:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ff:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101603:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101606:	ee                   	out    %al,(%dx)
}
  101607:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101608:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10160b:	89 ec                	mov    %ebp,%esp
  10160d:	5d                   	pop    %ebp
  10160e:	c3                   	ret    

0010160f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10160f:	55                   	push   %ebp
  101610:	89 e5                	mov    %esp,%ebp
  101612:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101615:	c7 04 24 88 14 10 00 	movl   $0x101488,(%esp)
  10161c:	e8 9f fd ff ff       	call   1013c0 <cons_intr>
}
  101621:	90                   	nop
  101622:	89 ec                	mov    %ebp,%esp
  101624:	5d                   	pop    %ebp
  101625:	c3                   	ret    

00101626 <kbd_init>:

static void
kbd_init(void) {
  101626:	55                   	push   %ebp
  101627:	89 e5                	mov    %esp,%ebp
  101629:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10162c:	e8 de ff ff ff       	call   10160f <kbd_intr>
    pic_enable(IRQ_KBD);
  101631:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101638:	e8 51 01 00 00       	call   10178e <pic_enable>
}
  10163d:	90                   	nop
  10163e:	89 ec                	mov    %ebp,%esp
  101640:	5d                   	pop    %ebp
  101641:	c3                   	ret    

00101642 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101642:	55                   	push   %ebp
  101643:	89 e5                	mov    %esp,%ebp
  101645:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101648:	e8 4a f8 ff ff       	call   100e97 <cga_init>
    serial_init();
  10164d:	e8 2d f9 ff ff       	call   100f7f <serial_init>
    kbd_init();
  101652:	e8 cf ff ff ff       	call   101626 <kbd_init>
    if (!serial_exists) {
  101657:	a1 48 e4 11 00       	mov    0x11e448,%eax
  10165c:	85 c0                	test   %eax,%eax
  10165e:	75 0c                	jne    10166c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101660:	c7 04 24 5b 73 10 00 	movl   $0x10735b,(%esp)
  101667:	e8 ea ec ff ff       	call   100356 <cprintf>
    }
}
  10166c:	90                   	nop
  10166d:	89 ec                	mov    %ebp,%esp
  10166f:	5d                   	pop    %ebp
  101670:	c3                   	ret    

00101671 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101671:	55                   	push   %ebp
  101672:	89 e5                	mov    %esp,%ebp
  101674:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101677:	e8 8e f7 ff ff       	call   100e0a <__intr_save>
  10167c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10167f:	8b 45 08             	mov    0x8(%ebp),%eax
  101682:	89 04 24             	mov    %eax,(%esp)
  101685:	e8 60 fa ff ff       	call   1010ea <lpt_putc>
        cga_putc(c);
  10168a:	8b 45 08             	mov    0x8(%ebp),%eax
  10168d:	89 04 24             	mov    %eax,(%esp)
  101690:	e8 97 fa ff ff       	call   10112c <cga_putc>
        serial_putc(c);
  101695:	8b 45 08             	mov    0x8(%ebp),%eax
  101698:	89 04 24             	mov    %eax,(%esp)
  10169b:	e8 de fc ff ff       	call   10137e <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016a3:	89 04 24             	mov    %eax,(%esp)
  1016a6:	e8 8b f7 ff ff       	call   100e36 <__intr_restore>
}
  1016ab:	90                   	nop
  1016ac:	89 ec                	mov    %ebp,%esp
  1016ae:	5d                   	pop    %ebp
  1016af:	c3                   	ret    

001016b0 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016b0:	55                   	push   %ebp
  1016b1:	89 e5                	mov    %esp,%ebp
  1016b3:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  1016b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1016bd:	e8 48 f7 ff ff       	call   100e0a <__intr_save>
  1016c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1016c5:	e8 9e fd ff ff       	call   101468 <serial_intr>
        kbd_intr();
  1016ca:	e8 40 ff ff ff       	call   10160f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1016cf:	8b 15 60 e6 11 00    	mov    0x11e660,%edx
  1016d5:	a1 64 e6 11 00       	mov    0x11e664,%eax
  1016da:	39 c2                	cmp    %eax,%edx
  1016dc:	74 31                	je     10170f <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016de:	a1 60 e6 11 00       	mov    0x11e660,%eax
  1016e3:	8d 50 01             	lea    0x1(%eax),%edx
  1016e6:	89 15 60 e6 11 00    	mov    %edx,0x11e660
  1016ec:	0f b6 80 60 e4 11 00 	movzbl 0x11e460(%eax),%eax
  1016f3:	0f b6 c0             	movzbl %al,%eax
  1016f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016f9:	a1 60 e6 11 00       	mov    0x11e660,%eax
  1016fe:	3d 00 02 00 00       	cmp    $0x200,%eax
  101703:	75 0a                	jne    10170f <cons_getc+0x5f>
                cons.rpos = 0;
  101705:	c7 05 60 e6 11 00 00 	movl   $0x0,0x11e660
  10170c:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10170f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101712:	89 04 24             	mov    %eax,(%esp)
  101715:	e8 1c f7 ff ff       	call   100e36 <__intr_restore>
    return c;
  10171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10171d:	89 ec                	mov    %ebp,%esp
  10171f:	5d                   	pop    %ebp
  101720:	c3                   	ret    

00101721 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101721:	55                   	push   %ebp
  101722:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101724:	fb                   	sti    
}
  101725:	90                   	nop
    sti();
}
  101726:	90                   	nop
  101727:	5d                   	pop    %ebp
  101728:	c3                   	ret    

00101729 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101729:	55                   	push   %ebp
  10172a:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  10172c:	fa                   	cli    
}
  10172d:	90                   	nop
    cli();
}
  10172e:	90                   	nop
  10172f:	5d                   	pop    %ebp
  101730:	c3                   	ret    

00101731 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101731:	55                   	push   %ebp
  101732:	89 e5                	mov    %esp,%ebp
  101734:	83 ec 14             	sub    $0x14,%esp
  101737:	8b 45 08             	mov    0x8(%ebp),%eax
  10173a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10173e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101741:	66 a3 50 b5 11 00    	mov    %ax,0x11b550
    if (did_init) {
  101747:	a1 6c e6 11 00       	mov    0x11e66c,%eax
  10174c:	85 c0                	test   %eax,%eax
  10174e:	74 39                	je     101789 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  101750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101753:	0f b6 c0             	movzbl %al,%eax
  101756:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10175c:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10175f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101763:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101767:	ee                   	out    %al,(%dx)
}
  101768:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101769:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10176d:	c1 e8 08             	shr    $0x8,%eax
  101770:	0f b7 c0             	movzwl %ax,%eax
  101773:	0f b6 c0             	movzbl %al,%eax
  101776:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10177c:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10177f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101783:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101787:	ee                   	out    %al,(%dx)
}
  101788:	90                   	nop
    }
}
  101789:	90                   	nop
  10178a:	89 ec                	mov    %ebp,%esp
  10178c:	5d                   	pop    %ebp
  10178d:	c3                   	ret    

0010178e <pic_enable>:

void
pic_enable(unsigned int irq) {
  10178e:	55                   	push   %ebp
  10178f:	89 e5                	mov    %esp,%ebp
  101791:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101794:	8b 45 08             	mov    0x8(%ebp),%eax
  101797:	ba 01 00 00 00       	mov    $0x1,%edx
  10179c:	88 c1                	mov    %al,%cl
  10179e:	d3 e2                	shl    %cl,%edx
  1017a0:	89 d0                	mov    %edx,%eax
  1017a2:	98                   	cwtl   
  1017a3:	f7 d0                	not    %eax
  1017a5:	0f bf d0             	movswl %ax,%edx
  1017a8:	0f b7 05 50 b5 11 00 	movzwl 0x11b550,%eax
  1017af:	98                   	cwtl   
  1017b0:	21 d0                	and    %edx,%eax
  1017b2:	98                   	cwtl   
  1017b3:	0f b7 c0             	movzwl %ax,%eax
  1017b6:	89 04 24             	mov    %eax,(%esp)
  1017b9:	e8 73 ff ff ff       	call   101731 <pic_setmask>
}
  1017be:	90                   	nop
  1017bf:	89 ec                	mov    %ebp,%esp
  1017c1:	5d                   	pop    %ebp
  1017c2:	c3                   	ret    

001017c3 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017c3:	55                   	push   %ebp
  1017c4:	89 e5                	mov    %esp,%ebp
  1017c6:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017c9:	c7 05 6c e6 11 00 01 	movl   $0x1,0x11e66c
  1017d0:	00 00 00 
  1017d3:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017d9:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017dd:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017e1:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017e5:	ee                   	out    %al,(%dx)
}
  1017e6:	90                   	nop
  1017e7:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1017ed:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017f1:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017f5:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017f9:	ee                   	out    %al,(%dx)
}
  1017fa:	90                   	nop
  1017fb:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101801:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101805:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101809:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10180d:	ee                   	out    %al,(%dx)
}
  10180e:	90                   	nop
  10180f:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101815:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101819:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10181d:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101821:	ee                   	out    %al,(%dx)
}
  101822:	90                   	nop
  101823:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101829:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10182d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101831:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101835:	ee                   	out    %al,(%dx)
}
  101836:	90                   	nop
  101837:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  10183d:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101841:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101845:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101849:	ee                   	out    %al,(%dx)
}
  10184a:	90                   	nop
  10184b:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101851:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101855:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101859:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10185d:	ee                   	out    %al,(%dx)
}
  10185e:	90                   	nop
  10185f:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101865:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101869:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10186d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101871:	ee                   	out    %al,(%dx)
}
  101872:	90                   	nop
  101873:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101879:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10187d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101881:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101885:	ee                   	out    %al,(%dx)
}
  101886:	90                   	nop
  101887:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10188d:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101891:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101895:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101899:	ee                   	out    %al,(%dx)
}
  10189a:	90                   	nop
  10189b:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018a1:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018ad:	ee                   	out    %al,(%dx)
}
  1018ae:	90                   	nop
  1018af:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018b5:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018b9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018bd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018c1:	ee                   	out    %al,(%dx)
}
  1018c2:	90                   	nop
  1018c3:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018c9:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018cd:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018d1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018d5:	ee                   	out    %al,(%dx)
}
  1018d6:	90                   	nop
  1018d7:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018dd:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018e1:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018e5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1018e9:	ee                   	out    %al,(%dx)
}
  1018ea:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1018eb:	0f b7 05 50 b5 11 00 	movzwl 0x11b550,%eax
  1018f2:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1018f7:	74 0f                	je     101908 <pic_init+0x145>
        pic_setmask(irq_mask);
  1018f9:	0f b7 05 50 b5 11 00 	movzwl 0x11b550,%eax
  101900:	89 04 24             	mov    %eax,(%esp)
  101903:	e8 29 fe ff ff       	call   101731 <pic_setmask>
    }
}
  101908:	90                   	nop
  101909:	89 ec                	mov    %ebp,%esp
  10190b:	5d                   	pop    %ebp
  10190c:	c3                   	ret    

0010190d <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  10190d:	55                   	push   %ebp
  10190e:	89 e5                	mov    %esp,%ebp
  101910:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101913:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10191a:	00 
  10191b:	c7 04 24 80 73 10 00 	movl   $0x107380,(%esp)
  101922:	e8 2f ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101927:	c7 04 24 8a 73 10 00 	movl   $0x10738a,(%esp)
  10192e:	e8 23 ea ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  101933:	c7 44 24 08 98 73 10 	movl   $0x107398,0x8(%esp)
  10193a:	00 
  10193b:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101942:	00 
  101943:	c7 04 24 ae 73 10 00 	movl   $0x1073ae,(%esp)
  10194a:	e8 81 f3 ff ff       	call   100cd0 <__panic>

0010194f <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10194f:	55                   	push   %ebp
  101950:	89 e5                	mov    %esp,%ebp
  101952:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101955:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10195c:	e9 c4 00 00 00       	jmp    101a25 <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101964:	8b 04 85 e0 b5 11 00 	mov    0x11b5e0(,%eax,4),%eax
  10196b:	0f b7 d0             	movzwl %ax,%edx
  10196e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101971:	66 89 14 c5 e0 e6 11 	mov    %dx,0x11e6e0(,%eax,8)
  101978:	00 
  101979:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197c:	66 c7 04 c5 e2 e6 11 	movw   $0x8,0x11e6e2(,%eax,8)
  101983:	00 08 00 
  101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101989:	0f b6 14 c5 e4 e6 11 	movzbl 0x11e6e4(,%eax,8),%edx
  101990:	00 
  101991:	80 e2 e0             	and    $0xe0,%dl
  101994:	88 14 c5 e4 e6 11 00 	mov    %dl,0x11e6e4(,%eax,8)
  10199b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199e:	0f b6 14 c5 e4 e6 11 	movzbl 0x11e6e4(,%eax,8),%edx
  1019a5:	00 
  1019a6:	80 e2 1f             	and    $0x1f,%dl
  1019a9:	88 14 c5 e4 e6 11 00 	mov    %dl,0x11e6e4(,%eax,8)
  1019b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b3:	0f b6 14 c5 e5 e6 11 	movzbl 0x11e6e5(,%eax,8),%edx
  1019ba:	00 
  1019bb:	80 e2 f0             	and    $0xf0,%dl
  1019be:	80 ca 0e             	or     $0xe,%dl
  1019c1:	88 14 c5 e5 e6 11 00 	mov    %dl,0x11e6e5(,%eax,8)
  1019c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019cb:	0f b6 14 c5 e5 e6 11 	movzbl 0x11e6e5(,%eax,8),%edx
  1019d2:	00 
  1019d3:	80 e2 ef             	and    $0xef,%dl
  1019d6:	88 14 c5 e5 e6 11 00 	mov    %dl,0x11e6e5(,%eax,8)
  1019dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e0:	0f b6 14 c5 e5 e6 11 	movzbl 0x11e6e5(,%eax,8),%edx
  1019e7:	00 
  1019e8:	80 e2 9f             	and    $0x9f,%dl
  1019eb:	88 14 c5 e5 e6 11 00 	mov    %dl,0x11e6e5(,%eax,8)
  1019f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019f5:	0f b6 14 c5 e5 e6 11 	movzbl 0x11e6e5(,%eax,8),%edx
  1019fc:	00 
  1019fd:	80 ca 80             	or     $0x80,%dl
  101a00:	88 14 c5 e5 e6 11 00 	mov    %dl,0x11e6e5(,%eax,8)
  101a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a0a:	8b 04 85 e0 b5 11 00 	mov    0x11b5e0(,%eax,4),%eax
  101a11:	c1 e8 10             	shr    $0x10,%eax
  101a14:	0f b7 d0             	movzwl %ax,%edx
  101a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a1a:	66 89 14 c5 e6 e6 11 	mov    %dx,0x11e6e6(,%eax,8)
  101a21:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101a22:	ff 45 fc             	incl   -0x4(%ebp)
  101a25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a28:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a2d:	0f 86 2e ff ff ff    	jbe    101961 <idt_init+0x12>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101a33:	a1 c4 b7 11 00       	mov    0x11b7c4,%eax
  101a38:	0f b7 c0             	movzwl %ax,%eax
  101a3b:	66 a3 a8 ea 11 00    	mov    %ax,0x11eaa8
  101a41:	66 c7 05 aa ea 11 00 	movw   $0x8,0x11eaaa
  101a48:	08 00 
  101a4a:	0f b6 05 ac ea 11 00 	movzbl 0x11eaac,%eax
  101a51:	24 e0                	and    $0xe0,%al
  101a53:	a2 ac ea 11 00       	mov    %al,0x11eaac
  101a58:	0f b6 05 ac ea 11 00 	movzbl 0x11eaac,%eax
  101a5f:	24 1f                	and    $0x1f,%al
  101a61:	a2 ac ea 11 00       	mov    %al,0x11eaac
  101a66:	0f b6 05 ad ea 11 00 	movzbl 0x11eaad,%eax
  101a6d:	24 f0                	and    $0xf0,%al
  101a6f:	0c 0e                	or     $0xe,%al
  101a71:	a2 ad ea 11 00       	mov    %al,0x11eaad
  101a76:	0f b6 05 ad ea 11 00 	movzbl 0x11eaad,%eax
  101a7d:	24 ef                	and    $0xef,%al
  101a7f:	a2 ad ea 11 00       	mov    %al,0x11eaad
  101a84:	0f b6 05 ad ea 11 00 	movzbl 0x11eaad,%eax
  101a8b:	0c 60                	or     $0x60,%al
  101a8d:	a2 ad ea 11 00       	mov    %al,0x11eaad
  101a92:	0f b6 05 ad ea 11 00 	movzbl 0x11eaad,%eax
  101a99:	0c 80                	or     $0x80,%al
  101a9b:	a2 ad ea 11 00       	mov    %al,0x11eaad
  101aa0:	a1 c4 b7 11 00       	mov    0x11b7c4,%eax
  101aa5:	c1 e8 10             	shr    $0x10,%eax
  101aa8:	0f b7 c0             	movzwl %ax,%eax
  101aab:	66 a3 ae ea 11 00    	mov    %ax,0x11eaae
  101ab1:	c7 45 f8 60 b5 11 00 	movl   $0x11b560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101ab8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101abb:	0f 01 18             	lidtl  (%eax)
}
  101abe:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
  101abf:	90                   	nop
  101ac0:	89 ec                	mov    %ebp,%esp
  101ac2:	5d                   	pop    %ebp
  101ac3:	c3                   	ret    

00101ac4 <trapname>:

static const char *
trapname(int trapno) {
  101ac4:	55                   	push   %ebp
  101ac5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aca:	83 f8 13             	cmp    $0x13,%eax
  101acd:	77 0c                	ja     101adb <trapname+0x17>
        return excnames[trapno];
  101acf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad2:	8b 04 85 40 77 10 00 	mov    0x107740(,%eax,4),%eax
  101ad9:	eb 18                	jmp    101af3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101adb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101adf:	7e 0d                	jle    101aee <trapname+0x2a>
  101ae1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101ae5:	7f 07                	jg     101aee <trapname+0x2a>
        return "Hardware Interrupt";
  101ae7:	b8 bf 73 10 00       	mov    $0x1073bf,%eax
  101aec:	eb 05                	jmp    101af3 <trapname+0x2f>
    }
    return "(unknown trap)";
  101aee:	b8 d2 73 10 00       	mov    $0x1073d2,%eax
}
  101af3:	5d                   	pop    %ebp
  101af4:	c3                   	ret    

00101af5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101af5:	55                   	push   %ebp
  101af6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101af8:	8b 45 08             	mov    0x8(%ebp),%eax
  101afb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aff:	83 f8 08             	cmp    $0x8,%eax
  101b02:	0f 94 c0             	sete   %al
  101b05:	0f b6 c0             	movzbl %al,%eax
}
  101b08:	5d                   	pop    %ebp
  101b09:	c3                   	ret    

00101b0a <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b0a:	55                   	push   %ebp
  101b0b:	89 e5                	mov    %esp,%ebp
  101b0d:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b10:	8b 45 08             	mov    0x8(%ebp),%eax
  101b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b17:	c7 04 24 13 74 10 00 	movl   $0x107413,(%esp)
  101b1e:	e8 33 e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101b23:	8b 45 08             	mov    0x8(%ebp),%eax
  101b26:	89 04 24             	mov    %eax,(%esp)
  101b29:	e8 8f 01 00 00       	call   101cbd <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b31:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b39:	c7 04 24 24 74 10 00 	movl   $0x107424,(%esp)
  101b40:	e8 11 e8 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b45:	8b 45 08             	mov    0x8(%ebp),%eax
  101b48:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b50:	c7 04 24 37 74 10 00 	movl   $0x107437,(%esp)
  101b57:	e8 fa e7 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b67:	c7 04 24 4a 74 10 00 	movl   $0x10744a,(%esp)
  101b6e:	e8 e3 e7 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b73:	8b 45 08             	mov    0x8(%ebp),%eax
  101b76:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7e:	c7 04 24 5d 74 10 00 	movl   $0x10745d,(%esp)
  101b85:	e8 cc e7 ff ff       	call   100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	8b 40 30             	mov    0x30(%eax),%eax
  101b90:	89 04 24             	mov    %eax,(%esp)
  101b93:	e8 2c ff ff ff       	call   101ac4 <trapname>
  101b98:	8b 55 08             	mov    0x8(%ebp),%edx
  101b9b:	8b 52 30             	mov    0x30(%edx),%edx
  101b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  101ba2:	89 54 24 04          	mov    %edx,0x4(%esp)
  101ba6:	c7 04 24 70 74 10 00 	movl   $0x107470,(%esp)
  101bad:	e8 a4 e7 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb5:	8b 40 34             	mov    0x34(%eax),%eax
  101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbc:	c7 04 24 82 74 10 00 	movl   $0x107482,(%esp)
  101bc3:	e8 8e e7 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcb:	8b 40 38             	mov    0x38(%eax),%eax
  101bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd2:	c7 04 24 91 74 10 00 	movl   $0x107491,(%esp)
  101bd9:	e8 78 e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bde:	8b 45 08             	mov    0x8(%ebp),%eax
  101be1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be9:	c7 04 24 a0 74 10 00 	movl   $0x1074a0,(%esp)
  101bf0:	e8 61 e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf8:	8b 40 40             	mov    0x40(%eax),%eax
  101bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bff:	c7 04 24 b3 74 10 00 	movl   $0x1074b3,(%esp)
  101c06:	e8 4b e7 ff ff       	call   100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c12:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c19:	eb 3d                	jmp    101c58 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1e:	8b 50 40             	mov    0x40(%eax),%edx
  101c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c24:	21 d0                	and    %edx,%eax
  101c26:	85 c0                	test   %eax,%eax
  101c28:	74 28                	je     101c52 <print_trapframe+0x148>
  101c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c2d:	8b 04 85 80 b5 11 00 	mov    0x11b580(,%eax,4),%eax
  101c34:	85 c0                	test   %eax,%eax
  101c36:	74 1a                	je     101c52 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c3b:	8b 04 85 80 b5 11 00 	mov    0x11b580(,%eax,4),%eax
  101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c46:	c7 04 24 c2 74 10 00 	movl   $0x1074c2,(%esp)
  101c4d:	e8 04 e7 ff ff       	call   100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c52:	ff 45 f4             	incl   -0xc(%ebp)
  101c55:	d1 65 f0             	shll   -0x10(%ebp)
  101c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c5b:	83 f8 17             	cmp    $0x17,%eax
  101c5e:	76 bb                	jbe    101c1b <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c60:	8b 45 08             	mov    0x8(%ebp),%eax
  101c63:	8b 40 40             	mov    0x40(%eax),%eax
  101c66:	c1 e8 0c             	shr    $0xc,%eax
  101c69:	83 e0 03             	and    $0x3,%eax
  101c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c70:	c7 04 24 c6 74 10 00 	movl   $0x1074c6,(%esp)
  101c77:	e8 da e6 ff ff       	call   100356 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7f:	89 04 24             	mov    %eax,(%esp)
  101c82:	e8 6e fe ff ff       	call   101af5 <trap_in_kernel>
  101c87:	85 c0                	test   %eax,%eax
  101c89:	75 2d                	jne    101cb8 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8e:	8b 40 44             	mov    0x44(%eax),%eax
  101c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c95:	c7 04 24 cf 74 10 00 	movl   $0x1074cf,(%esp)
  101c9c:	e8 b5 e6 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca4:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cac:	c7 04 24 de 74 10 00 	movl   $0x1074de,(%esp)
  101cb3:	e8 9e e6 ff ff       	call   100356 <cprintf>
    }
}
  101cb8:	90                   	nop
  101cb9:	89 ec                	mov    %ebp,%esp
  101cbb:	5d                   	pop    %ebp
  101cbc:	c3                   	ret    

00101cbd <print_regs>:

void
print_regs(struct pushregs *regs) {
  101cbd:	55                   	push   %ebp
  101cbe:	89 e5                	mov    %esp,%ebp
  101cc0:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc6:	8b 00                	mov    (%eax),%eax
  101cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccc:	c7 04 24 f1 74 10 00 	movl   $0x1074f1,(%esp)
  101cd3:	e8 7e e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdb:	8b 40 04             	mov    0x4(%eax),%eax
  101cde:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce2:	c7 04 24 00 75 10 00 	movl   $0x107500,(%esp)
  101ce9:	e8 68 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101cee:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf1:	8b 40 08             	mov    0x8(%eax),%eax
  101cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf8:	c7 04 24 0f 75 10 00 	movl   $0x10750f,(%esp)
  101cff:	e8 52 e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d04:	8b 45 08             	mov    0x8(%ebp),%eax
  101d07:	8b 40 0c             	mov    0xc(%eax),%eax
  101d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0e:	c7 04 24 1e 75 10 00 	movl   $0x10751e,(%esp)
  101d15:	e8 3c e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1d:	8b 40 10             	mov    0x10(%eax),%eax
  101d20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d24:	c7 04 24 2d 75 10 00 	movl   $0x10752d,(%esp)
  101d2b:	e8 26 e6 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d30:	8b 45 08             	mov    0x8(%ebp),%eax
  101d33:	8b 40 14             	mov    0x14(%eax),%eax
  101d36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d3a:	c7 04 24 3c 75 10 00 	movl   $0x10753c,(%esp)
  101d41:	e8 10 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d46:	8b 45 08             	mov    0x8(%ebp),%eax
  101d49:	8b 40 18             	mov    0x18(%eax),%eax
  101d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d50:	c7 04 24 4b 75 10 00 	movl   $0x10754b,(%esp)
  101d57:	e8 fa e5 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5f:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d66:	c7 04 24 5a 75 10 00 	movl   $0x10755a,(%esp)
  101d6d:	e8 e4 e5 ff ff       	call   100356 <cprintf>
}
  101d72:	90                   	nop
  101d73:	89 ec                	mov    %ebp,%esp
  101d75:	5d                   	pop    %ebp
  101d76:	c3                   	ret    

00101d77 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d77:	55                   	push   %ebp
  101d78:	89 e5                	mov    %esp,%ebp
  101d7a:	83 ec 38             	sub    $0x38,%esp
  101d7d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
  101d80:	8b 45 08             	mov    0x8(%ebp),%eax
  101d83:	8b 40 30             	mov    0x30(%eax),%eax
  101d86:	83 f8 79             	cmp    $0x79,%eax
  101d89:	0f 84 f8 02 00 00    	je     102087 <trap_dispatch+0x310>
  101d8f:	83 f8 79             	cmp    $0x79,%eax
  101d92:	0f 87 6c 03 00 00    	ja     102104 <trap_dispatch+0x38d>
  101d98:	83 f8 78             	cmp    $0x78,%eax
  101d9b:	0f 84 5c 02 00 00    	je     101ffd <trap_dispatch+0x286>
  101da1:	83 f8 78             	cmp    $0x78,%eax
  101da4:	0f 87 5a 03 00 00    	ja     102104 <trap_dispatch+0x38d>
  101daa:	83 f8 2f             	cmp    $0x2f,%eax
  101dad:	0f 87 51 03 00 00    	ja     102104 <trap_dispatch+0x38d>
  101db3:	83 f8 2e             	cmp    $0x2e,%eax
  101db6:	0f 83 7d 03 00 00    	jae    102139 <trap_dispatch+0x3c2>
  101dbc:	83 f8 24             	cmp    $0x24,%eax
  101dbf:	74 5e                	je     101e1f <trap_dispatch+0xa8>
  101dc1:	83 f8 24             	cmp    $0x24,%eax
  101dc4:	0f 87 3a 03 00 00    	ja     102104 <trap_dispatch+0x38d>
  101dca:	83 f8 20             	cmp    $0x20,%eax
  101dcd:	74 0a                	je     101dd9 <trap_dispatch+0x62>
  101dcf:	83 f8 21             	cmp    $0x21,%eax
  101dd2:	74 74                	je     101e48 <trap_dispatch+0xd1>
  101dd4:	e9 2b 03 00 00       	jmp    102104 <trap_dispatch+0x38d>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101dd9:	a1 24 e4 11 00       	mov    0x11e424,%eax
  101dde:	40                   	inc    %eax
  101ddf:	a3 24 e4 11 00       	mov    %eax,0x11e424
        if (ticks % TICK_NUM == 0) {
  101de4:	8b 0d 24 e4 11 00    	mov    0x11e424,%ecx
  101dea:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101def:	89 c8                	mov    %ecx,%eax
  101df1:	f7 e2                	mul    %edx
  101df3:	c1 ea 05             	shr    $0x5,%edx
  101df6:	89 d0                	mov    %edx,%eax
  101df8:	c1 e0 02             	shl    $0x2,%eax
  101dfb:	01 d0                	add    %edx,%eax
  101dfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e04:	01 d0                	add    %edx,%eax
  101e06:	c1 e0 02             	shl    $0x2,%eax
  101e09:	29 c1                	sub    %eax,%ecx
  101e0b:	89 ca                	mov    %ecx,%edx
  101e0d:	85 d2                	test   %edx,%edx
  101e0f:	0f 85 27 03 00 00    	jne    10213c <trap_dispatch+0x3c5>
            print_ticks();
  101e15:	e8 f3 fa ff ff       	call   10190d <print_ticks>
        }
        break;
  101e1a:	e9 1d 03 00 00       	jmp    10213c <trap_dispatch+0x3c5>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e1f:	e8 8c f8 ff ff       	call   1016b0 <cons_getc>
  101e24:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e27:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e2b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e37:	c7 04 24 69 75 10 00 	movl   $0x107569,(%esp)
  101e3e:	e8 13 e5 ff ff       	call   100356 <cprintf>
        break;
  101e43:	e9 fe 02 00 00       	jmp    102146 <trap_dispatch+0x3cf>
    case IRQ_OFFSET + IRQ_KBD:
        static int round = 0;
        c = cons_getc();
  101e48:	e8 63 f8 ff ff       	call   1016b0 <cons_getc>
  101e4d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e50:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e54:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e58:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e60:	c7 04 24 7b 75 10 00 	movl   $0x10757b,(%esp)
  101e67:	e8 ea e4 ff ff       	call   100356 <cprintf>
        if (c == '0') {
  101e6c:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101e70:	0f 85 be 00 00 00    	jne    101f34 <trap_dispatch+0x1bd>
            asm volatile (
  101e76:	cd 79                	int    $0x79
  101e78:	89 ec                	mov    %ebp,%esp
                "movl %%ebp, %%esp \n"
                : 
                : "i"(T_SWITCH_TOK)
            );
            uint16_t reg1, reg2, reg3, reg4;
            asm volatile (
  101e7a:	8c 4d f4             	mov    %cs,-0xc(%ebp)
  101e7d:	8c 5d f2             	mov    %ds,-0xe(%ebp)
  101e80:	8c 45 f0             	mov    %es,-0x10(%ebp)
  101e83:	8c 55 ee             	mov    %ss,-0x12(%ebp)
                    "mov %%cs, %0;"
                    "mov %%ds, %1;"
                    "mov %%es, %2;"
                    "mov %%ss, %3;"
                    : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
            cprintf("%d: @ring %d\n", round, reg1 & 3);
  101e86:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  101e8a:	83 e0 03             	and    $0x3,%eax
  101e8d:	89 c2                	mov    %eax,%edx
  101e8f:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101e94:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e9c:	c7 04 24 8a 75 10 00 	movl   $0x10758a,(%esp)
  101ea3:	e8 ae e4 ff ff       	call   100356 <cprintf>
            cprintf("%d:  cs = %x\n", round, reg1);
  101ea8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  101eac:	89 c2                	mov    %eax,%edx
  101eae:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101eb3:	89 54 24 08          	mov    %edx,0x8(%esp)
  101eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ebb:	c7 04 24 98 75 10 00 	movl   $0x107598,(%esp)
  101ec2:	e8 8f e4 ff ff       	call   100356 <cprintf>
            cprintf("%d:  ds = %x\n", round, reg2);
  101ec7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101ecb:	89 c2                	mov    %eax,%edx
  101ecd:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101ed2:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101eda:	c7 04 24 a6 75 10 00 	movl   $0x1075a6,(%esp)
  101ee1:	e8 70 e4 ff ff       	call   100356 <cprintf>
            cprintf("%d:  es = %x\n", round, reg3);
  101ee6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101eea:	89 c2                	mov    %eax,%edx
  101eec:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101ef1:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ef9:	c7 04 24 b4 75 10 00 	movl   $0x1075b4,(%esp)
  101f00:	e8 51 e4 ff ff       	call   100356 <cprintf>
            cprintf("%d:  ss = %x\n", round, reg4);
  101f05:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101f09:	89 c2                	mov    %eax,%edx
  101f0b:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101f10:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f18:	c7 04 24 c2 75 10 00 	movl   $0x1075c2,(%esp)
  101f1f:	e8 32 e4 ff ff       	call   100356 <cprintf>
            round ++;
  101f24:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101f29:	40                   	inc    %eax
  101f2a:	a3 e0 ee 11 00       	mov    %eax,0x11eee0
            cprintf("%d:  ds = %x\n", round, reg2);
            cprintf("%d:  es = %x\n", round, reg3);
            cprintf("%d:  ss = %x\n", round, reg4);
            round ++;
        }
        break;
  101f2f:	e9 0b 02 00 00       	jmp    10213f <trap_dispatch+0x3c8>
        } else if (c == '3') {
  101f34:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101f38:	0f 85 01 02 00 00    	jne    10213f <trap_dispatch+0x3c8>
            asm volatile (
  101f3e:	83 ec 08             	sub    $0x8,%esp
  101f41:	89 ec                	mov    %ebp,%esp
            asm volatile (
  101f43:	8c 4d ec             	mov    %cs,-0x14(%ebp)
  101f46:	8c 5d ea             	mov    %ds,-0x16(%ebp)
  101f49:	8c 45 e8             	mov    %es,-0x18(%ebp)
  101f4c:	8c 55 e6             	mov    %ss,-0x1a(%ebp)
            cprintf("%d: @ring %d\n", round, reg1 & 3);
  101f4f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101f53:	83 e0 03             	and    $0x3,%eax
  101f56:	89 c2                	mov    %eax,%edx
  101f58:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101f5d:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f65:	c7 04 24 8a 75 10 00 	movl   $0x10758a,(%esp)
  101f6c:	e8 e5 e3 ff ff       	call   100356 <cprintf>
            cprintf("%d:  cs = %x\n", round, reg1);
  101f71:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101f75:	89 c2                	mov    %eax,%edx
  101f77:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101f7c:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f80:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f84:	c7 04 24 98 75 10 00 	movl   $0x107598,(%esp)
  101f8b:	e8 c6 e3 ff ff       	call   100356 <cprintf>
            cprintf("%d:  ds = %x\n", round, reg2);
  101f90:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  101f94:	89 c2                	mov    %eax,%edx
  101f96:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  101f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fa3:	c7 04 24 a6 75 10 00 	movl   $0x1075a6,(%esp)
  101faa:	e8 a7 e3 ff ff       	call   100356 <cprintf>
            cprintf("%d:  es = %x\n", round, reg3);
  101faf:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
  101fb3:	89 c2                	mov    %eax,%edx
  101fb5:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101fba:	89 54 24 08          	mov    %edx,0x8(%esp)
  101fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fc2:	c7 04 24 b4 75 10 00 	movl   $0x1075b4,(%esp)
  101fc9:	e8 88 e3 ff ff       	call   100356 <cprintf>
            cprintf("%d:  ss = %x\n", round, reg4);
  101fce:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  101fd2:	89 c2                	mov    %eax,%edx
  101fd4:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101fd9:	89 54 24 08          	mov    %edx,0x8(%esp)
  101fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101fe1:	c7 04 24 c2 75 10 00 	movl   $0x1075c2,(%esp)
  101fe8:	e8 69 e3 ff ff       	call   100356 <cprintf>
            round ++;
  101fed:	a1 e0 ee 11 00       	mov    0x11eee0,%eax
  101ff2:	40                   	inc    %eax
  101ff3:	a3 e0 ee 11 00       	mov    %eax,0x11eee0
        break;
  101ff8:	e9 42 01 00 00       	jmp    10213f <trap_dispatch+0x3c8>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  102000:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102004:	83 f8 1b             	cmp    $0x1b,%eax
  102007:	0f 84 35 01 00 00    	je     102142 <trap_dispatch+0x3cb>
            switchk2u = *tf;
  10200d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  102010:	b8 4c 00 00 00       	mov    $0x4c,%eax
  102015:	83 e0 fc             	and    $0xfffffffc,%eax
  102018:	89 c3                	mov    %eax,%ebx
  10201a:	b8 00 00 00 00       	mov    $0x0,%eax
  10201f:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  102022:	89 90 80 e6 11 00    	mov    %edx,0x11e680(%eax)
  102028:	83 c0 04             	add    $0x4,%eax
  10202b:	39 d8                	cmp    %ebx,%eax
  10202d:	72 f0                	jb     10201f <trap_dispatch+0x2a8>
            switchk2u.tf_cs = USER_CS;
  10202f:	66 c7 05 bc e6 11 00 	movw   $0x1b,0x11e6bc
  102036:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  102038:	66 c7 05 c8 e6 11 00 	movw   $0x23,0x11e6c8
  10203f:	23 00 
  102041:	0f b7 05 c8 e6 11 00 	movzwl 0x11e6c8,%eax
  102048:	66 a3 a8 e6 11 00    	mov    %ax,0x11e6a8
  10204e:	0f b7 05 a8 e6 11 00 	movzwl 0x11e6a8,%eax
  102055:	66 a3 ac e6 11 00    	mov    %ax,0x11e6ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  10205b:	8b 45 08             	mov    0x8(%ebp),%eax
  10205e:	83 c0 44             	add    $0x44,%eax
  102061:	a3 c4 e6 11 00       	mov    %eax,0x11e6c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  102066:	a1 c0 e6 11 00       	mov    0x11e6c0,%eax
  10206b:	0d 00 30 00 00       	or     $0x3000,%eax
  102070:	a3 c0 e6 11 00       	mov    %eax,0x11e6c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  102075:	8b 45 08             	mov    0x8(%ebp),%eax
  102078:	83 e8 04             	sub    $0x4,%eax
  10207b:	ba 80 e6 11 00       	mov    $0x11e680,%edx
  102080:	89 10                	mov    %edx,(%eax)
        }
        break;
  102082:	e9 bb 00 00 00       	jmp    102142 <trap_dispatch+0x3cb>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  102087:	8b 45 08             	mov    0x8(%ebp),%eax
  10208a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10208e:	83 f8 08             	cmp    $0x8,%eax
  102091:	0f 84 ae 00 00 00    	je     102145 <trap_dispatch+0x3ce>
            tf->tf_cs = KERNEL_CS;
  102097:	8b 45 08             	mov    0x8(%ebp),%eax
  10209a:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  1020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1020a3:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  1020a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1020ac:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  1020b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1020b3:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  1020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1020ba:	8b 40 40             	mov    0x40(%eax),%eax
  1020bd:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  1020c2:	89 c2                	mov    %eax,%edx
  1020c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1020c7:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  1020ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1020cd:	8b 40 44             	mov    0x44(%eax),%eax
  1020d0:	83 e8 44             	sub    $0x44,%eax
  1020d3:	a3 cc e6 11 00       	mov    %eax,0x11e6cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  1020d8:	a1 cc e6 11 00       	mov    0x11e6cc,%eax
  1020dd:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  1020e4:	00 
  1020e5:	8b 55 08             	mov    0x8(%ebp),%edx
  1020e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1020ec:	89 04 24             	mov    %eax,(%esp)
  1020ef:	e8 d2 4d 00 00       	call   106ec6 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  1020f4:	8b 15 cc e6 11 00    	mov    0x11e6cc,%edx
  1020fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1020fd:	83 e8 04             	sub    $0x4,%eax
  102100:	89 10                	mov    %edx,(%eax)
        }
        break;
  102102:	eb 41                	jmp    102145 <trap_dispatch+0x3ce>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102104:	8b 45 08             	mov    0x8(%ebp),%eax
  102107:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10210b:	83 e0 03             	and    $0x3,%eax
  10210e:	85 c0                	test   %eax,%eax
  102110:	75 34                	jne    102146 <trap_dispatch+0x3cf>
            print_trapframe(tf);
  102112:	8b 45 08             	mov    0x8(%ebp),%eax
  102115:	89 04 24             	mov    %eax,(%esp)
  102118:	e8 ed f9 ff ff       	call   101b0a <print_trapframe>
            panic("unexpected trap in kernel.\n");
  10211d:	c7 44 24 08 d0 75 10 	movl   $0x1075d0,0x8(%esp)
  102124:	00 
  102125:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  10212c:	00 
  10212d:	c7 04 24 ae 73 10 00 	movl   $0x1073ae,(%esp)
  102134:	e8 97 eb ff ff       	call   100cd0 <__panic>
        break;
  102139:	90                   	nop
  10213a:	eb 0a                	jmp    102146 <trap_dispatch+0x3cf>
        break;
  10213c:	90                   	nop
  10213d:	eb 07                	jmp    102146 <trap_dispatch+0x3cf>
        break;
  10213f:	90                   	nop
  102140:	eb 04                	jmp    102146 <trap_dispatch+0x3cf>
        break;
  102142:	90                   	nop
  102143:	eb 01                	jmp    102146 <trap_dispatch+0x3cf>
        break;
  102145:	90                   	nop
        }
    }
}
  102146:	90                   	nop
  102147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  10214a:	89 ec                	mov    %ebp,%esp
  10214c:	5d                   	pop    %ebp
  10214d:	c3                   	ret    

0010214e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  10214e:	55                   	push   %ebp
  10214f:	89 e5                	mov    %esp,%ebp
  102151:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  102154:	8b 45 08             	mov    0x8(%ebp),%eax
  102157:	89 04 24             	mov    %eax,(%esp)
  10215a:	e8 18 fc ff ff       	call   101d77 <trap_dispatch>
}
  10215f:	90                   	nop
  102160:	89 ec                	mov    %ebp,%esp
  102162:	5d                   	pop    %ebp
  102163:	c3                   	ret    

00102164 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102164:	1e                   	push   %ds
    pushl %es
  102165:	06                   	push   %es
    pushl %fs
  102166:	0f a0                	push   %fs
    pushl %gs
  102168:	0f a8                	push   %gs
    pushal
  10216a:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  10216b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102170:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102172:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102174:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102175:	e8 d4 ff ff ff       	call   10214e <trap>

    # pop the pushed stack pointer
    popl %esp
  10217a:	5c                   	pop    %esp

0010217b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  10217b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  10217c:	0f a9                	pop    %gs
    popl %fs
  10217e:	0f a1                	pop    %fs
    popl %es
  102180:	07                   	pop    %es
    popl %ds
  102181:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102182:	83 c4 08             	add    $0x8,%esp
    iret
  102185:	cf                   	iret   

00102186 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  102186:	6a 00                	push   $0x0
  pushl $0
  102188:	6a 00                	push   $0x0
  jmp __alltraps
  10218a:	e9 d5 ff ff ff       	jmp    102164 <__alltraps>

0010218f <vector1>:
.globl vector1
vector1:
  pushl $0
  10218f:	6a 00                	push   $0x0
  pushl $1
  102191:	6a 01                	push   $0x1
  jmp __alltraps
  102193:	e9 cc ff ff ff       	jmp    102164 <__alltraps>

00102198 <vector2>:
.globl vector2
vector2:
  pushl $0
  102198:	6a 00                	push   $0x0
  pushl $2
  10219a:	6a 02                	push   $0x2
  jmp __alltraps
  10219c:	e9 c3 ff ff ff       	jmp    102164 <__alltraps>

001021a1 <vector3>:
.globl vector3
vector3:
  pushl $0
  1021a1:	6a 00                	push   $0x0
  pushl $3
  1021a3:	6a 03                	push   $0x3
  jmp __alltraps
  1021a5:	e9 ba ff ff ff       	jmp    102164 <__alltraps>

001021aa <vector4>:
.globl vector4
vector4:
  pushl $0
  1021aa:	6a 00                	push   $0x0
  pushl $4
  1021ac:	6a 04                	push   $0x4
  jmp __alltraps
  1021ae:	e9 b1 ff ff ff       	jmp    102164 <__alltraps>

001021b3 <vector5>:
.globl vector5
vector5:
  pushl $0
  1021b3:	6a 00                	push   $0x0
  pushl $5
  1021b5:	6a 05                	push   $0x5
  jmp __alltraps
  1021b7:	e9 a8 ff ff ff       	jmp    102164 <__alltraps>

001021bc <vector6>:
.globl vector6
vector6:
  pushl $0
  1021bc:	6a 00                	push   $0x0
  pushl $6
  1021be:	6a 06                	push   $0x6
  jmp __alltraps
  1021c0:	e9 9f ff ff ff       	jmp    102164 <__alltraps>

001021c5 <vector7>:
.globl vector7
vector7:
  pushl $0
  1021c5:	6a 00                	push   $0x0
  pushl $7
  1021c7:	6a 07                	push   $0x7
  jmp __alltraps
  1021c9:	e9 96 ff ff ff       	jmp    102164 <__alltraps>

001021ce <vector8>:
.globl vector8
vector8:
  pushl $8
  1021ce:	6a 08                	push   $0x8
  jmp __alltraps
  1021d0:	e9 8f ff ff ff       	jmp    102164 <__alltraps>

001021d5 <vector9>:
.globl vector9
vector9:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $9
  1021d7:	6a 09                	push   $0x9
  jmp __alltraps
  1021d9:	e9 86 ff ff ff       	jmp    102164 <__alltraps>

001021de <vector10>:
.globl vector10
vector10:
  pushl $10
  1021de:	6a 0a                	push   $0xa
  jmp __alltraps
  1021e0:	e9 7f ff ff ff       	jmp    102164 <__alltraps>

001021e5 <vector11>:
.globl vector11
vector11:
  pushl $11
  1021e5:	6a 0b                	push   $0xb
  jmp __alltraps
  1021e7:	e9 78 ff ff ff       	jmp    102164 <__alltraps>

001021ec <vector12>:
.globl vector12
vector12:
  pushl $12
  1021ec:	6a 0c                	push   $0xc
  jmp __alltraps
  1021ee:	e9 71 ff ff ff       	jmp    102164 <__alltraps>

001021f3 <vector13>:
.globl vector13
vector13:
  pushl $13
  1021f3:	6a 0d                	push   $0xd
  jmp __alltraps
  1021f5:	e9 6a ff ff ff       	jmp    102164 <__alltraps>

001021fa <vector14>:
.globl vector14
vector14:
  pushl $14
  1021fa:	6a 0e                	push   $0xe
  jmp __alltraps
  1021fc:	e9 63 ff ff ff       	jmp    102164 <__alltraps>

00102201 <vector15>:
.globl vector15
vector15:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $15
  102203:	6a 0f                	push   $0xf
  jmp __alltraps
  102205:	e9 5a ff ff ff       	jmp    102164 <__alltraps>

0010220a <vector16>:
.globl vector16
vector16:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $16
  10220c:	6a 10                	push   $0x10
  jmp __alltraps
  10220e:	e9 51 ff ff ff       	jmp    102164 <__alltraps>

00102213 <vector17>:
.globl vector17
vector17:
  pushl $17
  102213:	6a 11                	push   $0x11
  jmp __alltraps
  102215:	e9 4a ff ff ff       	jmp    102164 <__alltraps>

0010221a <vector18>:
.globl vector18
vector18:
  pushl $0
  10221a:	6a 00                	push   $0x0
  pushl $18
  10221c:	6a 12                	push   $0x12
  jmp __alltraps
  10221e:	e9 41 ff ff ff       	jmp    102164 <__alltraps>

00102223 <vector19>:
.globl vector19
vector19:
  pushl $0
  102223:	6a 00                	push   $0x0
  pushl $19
  102225:	6a 13                	push   $0x13
  jmp __alltraps
  102227:	e9 38 ff ff ff       	jmp    102164 <__alltraps>

0010222c <vector20>:
.globl vector20
vector20:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $20
  10222e:	6a 14                	push   $0x14
  jmp __alltraps
  102230:	e9 2f ff ff ff       	jmp    102164 <__alltraps>

00102235 <vector21>:
.globl vector21
vector21:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $21
  102237:	6a 15                	push   $0x15
  jmp __alltraps
  102239:	e9 26 ff ff ff       	jmp    102164 <__alltraps>

0010223e <vector22>:
.globl vector22
vector22:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $22
  102240:	6a 16                	push   $0x16
  jmp __alltraps
  102242:	e9 1d ff ff ff       	jmp    102164 <__alltraps>

00102247 <vector23>:
.globl vector23
vector23:
  pushl $0
  102247:	6a 00                	push   $0x0
  pushl $23
  102249:	6a 17                	push   $0x17
  jmp __alltraps
  10224b:	e9 14 ff ff ff       	jmp    102164 <__alltraps>

00102250 <vector24>:
.globl vector24
vector24:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $24
  102252:	6a 18                	push   $0x18
  jmp __alltraps
  102254:	e9 0b ff ff ff       	jmp    102164 <__alltraps>

00102259 <vector25>:
.globl vector25
vector25:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $25
  10225b:	6a 19                	push   $0x19
  jmp __alltraps
  10225d:	e9 02 ff ff ff       	jmp    102164 <__alltraps>

00102262 <vector26>:
.globl vector26
vector26:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $26
  102264:	6a 1a                	push   $0x1a
  jmp __alltraps
  102266:	e9 f9 fe ff ff       	jmp    102164 <__alltraps>

0010226b <vector27>:
.globl vector27
vector27:
  pushl $0
  10226b:	6a 00                	push   $0x0
  pushl $27
  10226d:	6a 1b                	push   $0x1b
  jmp __alltraps
  10226f:	e9 f0 fe ff ff       	jmp    102164 <__alltraps>

00102274 <vector28>:
.globl vector28
vector28:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $28
  102276:	6a 1c                	push   $0x1c
  jmp __alltraps
  102278:	e9 e7 fe ff ff       	jmp    102164 <__alltraps>

0010227d <vector29>:
.globl vector29
vector29:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $29
  10227f:	6a 1d                	push   $0x1d
  jmp __alltraps
  102281:	e9 de fe ff ff       	jmp    102164 <__alltraps>

00102286 <vector30>:
.globl vector30
vector30:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $30
  102288:	6a 1e                	push   $0x1e
  jmp __alltraps
  10228a:	e9 d5 fe ff ff       	jmp    102164 <__alltraps>

0010228f <vector31>:
.globl vector31
vector31:
  pushl $0
  10228f:	6a 00                	push   $0x0
  pushl $31
  102291:	6a 1f                	push   $0x1f
  jmp __alltraps
  102293:	e9 cc fe ff ff       	jmp    102164 <__alltraps>

00102298 <vector32>:
.globl vector32
vector32:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $32
  10229a:	6a 20                	push   $0x20
  jmp __alltraps
  10229c:	e9 c3 fe ff ff       	jmp    102164 <__alltraps>

001022a1 <vector33>:
.globl vector33
vector33:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $33
  1022a3:	6a 21                	push   $0x21
  jmp __alltraps
  1022a5:	e9 ba fe ff ff       	jmp    102164 <__alltraps>

001022aa <vector34>:
.globl vector34
vector34:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $34
  1022ac:	6a 22                	push   $0x22
  jmp __alltraps
  1022ae:	e9 b1 fe ff ff       	jmp    102164 <__alltraps>

001022b3 <vector35>:
.globl vector35
vector35:
  pushl $0
  1022b3:	6a 00                	push   $0x0
  pushl $35
  1022b5:	6a 23                	push   $0x23
  jmp __alltraps
  1022b7:	e9 a8 fe ff ff       	jmp    102164 <__alltraps>

001022bc <vector36>:
.globl vector36
vector36:
  pushl $0
  1022bc:	6a 00                	push   $0x0
  pushl $36
  1022be:	6a 24                	push   $0x24
  jmp __alltraps
  1022c0:	e9 9f fe ff ff       	jmp    102164 <__alltraps>

001022c5 <vector37>:
.globl vector37
vector37:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $37
  1022c7:	6a 25                	push   $0x25
  jmp __alltraps
  1022c9:	e9 96 fe ff ff       	jmp    102164 <__alltraps>

001022ce <vector38>:
.globl vector38
vector38:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $38
  1022d0:	6a 26                	push   $0x26
  jmp __alltraps
  1022d2:	e9 8d fe ff ff       	jmp    102164 <__alltraps>

001022d7 <vector39>:
.globl vector39
vector39:
  pushl $0
  1022d7:	6a 00                	push   $0x0
  pushl $39
  1022d9:	6a 27                	push   $0x27
  jmp __alltraps
  1022db:	e9 84 fe ff ff       	jmp    102164 <__alltraps>

001022e0 <vector40>:
.globl vector40
vector40:
  pushl $0
  1022e0:	6a 00                	push   $0x0
  pushl $40
  1022e2:	6a 28                	push   $0x28
  jmp __alltraps
  1022e4:	e9 7b fe ff ff       	jmp    102164 <__alltraps>

001022e9 <vector41>:
.globl vector41
vector41:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $41
  1022eb:	6a 29                	push   $0x29
  jmp __alltraps
  1022ed:	e9 72 fe ff ff       	jmp    102164 <__alltraps>

001022f2 <vector42>:
.globl vector42
vector42:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $42
  1022f4:	6a 2a                	push   $0x2a
  jmp __alltraps
  1022f6:	e9 69 fe ff ff       	jmp    102164 <__alltraps>

001022fb <vector43>:
.globl vector43
vector43:
  pushl $0
  1022fb:	6a 00                	push   $0x0
  pushl $43
  1022fd:	6a 2b                	push   $0x2b
  jmp __alltraps
  1022ff:	e9 60 fe ff ff       	jmp    102164 <__alltraps>

00102304 <vector44>:
.globl vector44
vector44:
  pushl $0
  102304:	6a 00                	push   $0x0
  pushl $44
  102306:	6a 2c                	push   $0x2c
  jmp __alltraps
  102308:	e9 57 fe ff ff       	jmp    102164 <__alltraps>

0010230d <vector45>:
.globl vector45
vector45:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $45
  10230f:	6a 2d                	push   $0x2d
  jmp __alltraps
  102311:	e9 4e fe ff ff       	jmp    102164 <__alltraps>

00102316 <vector46>:
.globl vector46
vector46:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $46
  102318:	6a 2e                	push   $0x2e
  jmp __alltraps
  10231a:	e9 45 fe ff ff       	jmp    102164 <__alltraps>

0010231f <vector47>:
.globl vector47
vector47:
  pushl $0
  10231f:	6a 00                	push   $0x0
  pushl $47
  102321:	6a 2f                	push   $0x2f
  jmp __alltraps
  102323:	e9 3c fe ff ff       	jmp    102164 <__alltraps>

00102328 <vector48>:
.globl vector48
vector48:
  pushl $0
  102328:	6a 00                	push   $0x0
  pushl $48
  10232a:	6a 30                	push   $0x30
  jmp __alltraps
  10232c:	e9 33 fe ff ff       	jmp    102164 <__alltraps>

00102331 <vector49>:
.globl vector49
vector49:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $49
  102333:	6a 31                	push   $0x31
  jmp __alltraps
  102335:	e9 2a fe ff ff       	jmp    102164 <__alltraps>

0010233a <vector50>:
.globl vector50
vector50:
  pushl $0
  10233a:	6a 00                	push   $0x0
  pushl $50
  10233c:	6a 32                	push   $0x32
  jmp __alltraps
  10233e:	e9 21 fe ff ff       	jmp    102164 <__alltraps>

00102343 <vector51>:
.globl vector51
vector51:
  pushl $0
  102343:	6a 00                	push   $0x0
  pushl $51
  102345:	6a 33                	push   $0x33
  jmp __alltraps
  102347:	e9 18 fe ff ff       	jmp    102164 <__alltraps>

0010234c <vector52>:
.globl vector52
vector52:
  pushl $0
  10234c:	6a 00                	push   $0x0
  pushl $52
  10234e:	6a 34                	push   $0x34
  jmp __alltraps
  102350:	e9 0f fe ff ff       	jmp    102164 <__alltraps>

00102355 <vector53>:
.globl vector53
vector53:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $53
  102357:	6a 35                	push   $0x35
  jmp __alltraps
  102359:	e9 06 fe ff ff       	jmp    102164 <__alltraps>

0010235e <vector54>:
.globl vector54
vector54:
  pushl $0
  10235e:	6a 00                	push   $0x0
  pushl $54
  102360:	6a 36                	push   $0x36
  jmp __alltraps
  102362:	e9 fd fd ff ff       	jmp    102164 <__alltraps>

00102367 <vector55>:
.globl vector55
vector55:
  pushl $0
  102367:	6a 00                	push   $0x0
  pushl $55
  102369:	6a 37                	push   $0x37
  jmp __alltraps
  10236b:	e9 f4 fd ff ff       	jmp    102164 <__alltraps>

00102370 <vector56>:
.globl vector56
vector56:
  pushl $0
  102370:	6a 00                	push   $0x0
  pushl $56
  102372:	6a 38                	push   $0x38
  jmp __alltraps
  102374:	e9 eb fd ff ff       	jmp    102164 <__alltraps>

00102379 <vector57>:
.globl vector57
vector57:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $57
  10237b:	6a 39                	push   $0x39
  jmp __alltraps
  10237d:	e9 e2 fd ff ff       	jmp    102164 <__alltraps>

00102382 <vector58>:
.globl vector58
vector58:
  pushl $0
  102382:	6a 00                	push   $0x0
  pushl $58
  102384:	6a 3a                	push   $0x3a
  jmp __alltraps
  102386:	e9 d9 fd ff ff       	jmp    102164 <__alltraps>

0010238b <vector59>:
.globl vector59
vector59:
  pushl $0
  10238b:	6a 00                	push   $0x0
  pushl $59
  10238d:	6a 3b                	push   $0x3b
  jmp __alltraps
  10238f:	e9 d0 fd ff ff       	jmp    102164 <__alltraps>

00102394 <vector60>:
.globl vector60
vector60:
  pushl $0
  102394:	6a 00                	push   $0x0
  pushl $60
  102396:	6a 3c                	push   $0x3c
  jmp __alltraps
  102398:	e9 c7 fd ff ff       	jmp    102164 <__alltraps>

0010239d <vector61>:
.globl vector61
vector61:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $61
  10239f:	6a 3d                	push   $0x3d
  jmp __alltraps
  1023a1:	e9 be fd ff ff       	jmp    102164 <__alltraps>

001023a6 <vector62>:
.globl vector62
vector62:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $62
  1023a8:	6a 3e                	push   $0x3e
  jmp __alltraps
  1023aa:	e9 b5 fd ff ff       	jmp    102164 <__alltraps>

001023af <vector63>:
.globl vector63
vector63:
  pushl $0
  1023af:	6a 00                	push   $0x0
  pushl $63
  1023b1:	6a 3f                	push   $0x3f
  jmp __alltraps
  1023b3:	e9 ac fd ff ff       	jmp    102164 <__alltraps>

001023b8 <vector64>:
.globl vector64
vector64:
  pushl $0
  1023b8:	6a 00                	push   $0x0
  pushl $64
  1023ba:	6a 40                	push   $0x40
  jmp __alltraps
  1023bc:	e9 a3 fd ff ff       	jmp    102164 <__alltraps>

001023c1 <vector65>:
.globl vector65
vector65:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $65
  1023c3:	6a 41                	push   $0x41
  jmp __alltraps
  1023c5:	e9 9a fd ff ff       	jmp    102164 <__alltraps>

001023ca <vector66>:
.globl vector66
vector66:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $66
  1023cc:	6a 42                	push   $0x42
  jmp __alltraps
  1023ce:	e9 91 fd ff ff       	jmp    102164 <__alltraps>

001023d3 <vector67>:
.globl vector67
vector67:
  pushl $0
  1023d3:	6a 00                	push   $0x0
  pushl $67
  1023d5:	6a 43                	push   $0x43
  jmp __alltraps
  1023d7:	e9 88 fd ff ff       	jmp    102164 <__alltraps>

001023dc <vector68>:
.globl vector68
vector68:
  pushl $0
  1023dc:	6a 00                	push   $0x0
  pushl $68
  1023de:	6a 44                	push   $0x44
  jmp __alltraps
  1023e0:	e9 7f fd ff ff       	jmp    102164 <__alltraps>

001023e5 <vector69>:
.globl vector69
vector69:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $69
  1023e7:	6a 45                	push   $0x45
  jmp __alltraps
  1023e9:	e9 76 fd ff ff       	jmp    102164 <__alltraps>

001023ee <vector70>:
.globl vector70
vector70:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $70
  1023f0:	6a 46                	push   $0x46
  jmp __alltraps
  1023f2:	e9 6d fd ff ff       	jmp    102164 <__alltraps>

001023f7 <vector71>:
.globl vector71
vector71:
  pushl $0
  1023f7:	6a 00                	push   $0x0
  pushl $71
  1023f9:	6a 47                	push   $0x47
  jmp __alltraps
  1023fb:	e9 64 fd ff ff       	jmp    102164 <__alltraps>

00102400 <vector72>:
.globl vector72
vector72:
  pushl $0
  102400:	6a 00                	push   $0x0
  pushl $72
  102402:	6a 48                	push   $0x48
  jmp __alltraps
  102404:	e9 5b fd ff ff       	jmp    102164 <__alltraps>

00102409 <vector73>:
.globl vector73
vector73:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $73
  10240b:	6a 49                	push   $0x49
  jmp __alltraps
  10240d:	e9 52 fd ff ff       	jmp    102164 <__alltraps>

00102412 <vector74>:
.globl vector74
vector74:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $74
  102414:	6a 4a                	push   $0x4a
  jmp __alltraps
  102416:	e9 49 fd ff ff       	jmp    102164 <__alltraps>

0010241b <vector75>:
.globl vector75
vector75:
  pushl $0
  10241b:	6a 00                	push   $0x0
  pushl $75
  10241d:	6a 4b                	push   $0x4b
  jmp __alltraps
  10241f:	e9 40 fd ff ff       	jmp    102164 <__alltraps>

00102424 <vector76>:
.globl vector76
vector76:
  pushl $0
  102424:	6a 00                	push   $0x0
  pushl $76
  102426:	6a 4c                	push   $0x4c
  jmp __alltraps
  102428:	e9 37 fd ff ff       	jmp    102164 <__alltraps>

0010242d <vector77>:
.globl vector77
vector77:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $77
  10242f:	6a 4d                	push   $0x4d
  jmp __alltraps
  102431:	e9 2e fd ff ff       	jmp    102164 <__alltraps>

00102436 <vector78>:
.globl vector78
vector78:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $78
  102438:	6a 4e                	push   $0x4e
  jmp __alltraps
  10243a:	e9 25 fd ff ff       	jmp    102164 <__alltraps>

0010243f <vector79>:
.globl vector79
vector79:
  pushl $0
  10243f:	6a 00                	push   $0x0
  pushl $79
  102441:	6a 4f                	push   $0x4f
  jmp __alltraps
  102443:	e9 1c fd ff ff       	jmp    102164 <__alltraps>

00102448 <vector80>:
.globl vector80
vector80:
  pushl $0
  102448:	6a 00                	push   $0x0
  pushl $80
  10244a:	6a 50                	push   $0x50
  jmp __alltraps
  10244c:	e9 13 fd ff ff       	jmp    102164 <__alltraps>

00102451 <vector81>:
.globl vector81
vector81:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $81
  102453:	6a 51                	push   $0x51
  jmp __alltraps
  102455:	e9 0a fd ff ff       	jmp    102164 <__alltraps>

0010245a <vector82>:
.globl vector82
vector82:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $82
  10245c:	6a 52                	push   $0x52
  jmp __alltraps
  10245e:	e9 01 fd ff ff       	jmp    102164 <__alltraps>

00102463 <vector83>:
.globl vector83
vector83:
  pushl $0
  102463:	6a 00                	push   $0x0
  pushl $83
  102465:	6a 53                	push   $0x53
  jmp __alltraps
  102467:	e9 f8 fc ff ff       	jmp    102164 <__alltraps>

0010246c <vector84>:
.globl vector84
vector84:
  pushl $0
  10246c:	6a 00                	push   $0x0
  pushl $84
  10246e:	6a 54                	push   $0x54
  jmp __alltraps
  102470:	e9 ef fc ff ff       	jmp    102164 <__alltraps>

00102475 <vector85>:
.globl vector85
vector85:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $85
  102477:	6a 55                	push   $0x55
  jmp __alltraps
  102479:	e9 e6 fc ff ff       	jmp    102164 <__alltraps>

0010247e <vector86>:
.globl vector86
vector86:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $86
  102480:	6a 56                	push   $0x56
  jmp __alltraps
  102482:	e9 dd fc ff ff       	jmp    102164 <__alltraps>

00102487 <vector87>:
.globl vector87
vector87:
  pushl $0
  102487:	6a 00                	push   $0x0
  pushl $87
  102489:	6a 57                	push   $0x57
  jmp __alltraps
  10248b:	e9 d4 fc ff ff       	jmp    102164 <__alltraps>

00102490 <vector88>:
.globl vector88
vector88:
  pushl $0
  102490:	6a 00                	push   $0x0
  pushl $88
  102492:	6a 58                	push   $0x58
  jmp __alltraps
  102494:	e9 cb fc ff ff       	jmp    102164 <__alltraps>

00102499 <vector89>:
.globl vector89
vector89:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $89
  10249b:	6a 59                	push   $0x59
  jmp __alltraps
  10249d:	e9 c2 fc ff ff       	jmp    102164 <__alltraps>

001024a2 <vector90>:
.globl vector90
vector90:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $90
  1024a4:	6a 5a                	push   $0x5a
  jmp __alltraps
  1024a6:	e9 b9 fc ff ff       	jmp    102164 <__alltraps>

001024ab <vector91>:
.globl vector91
vector91:
  pushl $0
  1024ab:	6a 00                	push   $0x0
  pushl $91
  1024ad:	6a 5b                	push   $0x5b
  jmp __alltraps
  1024af:	e9 b0 fc ff ff       	jmp    102164 <__alltraps>

001024b4 <vector92>:
.globl vector92
vector92:
  pushl $0
  1024b4:	6a 00                	push   $0x0
  pushl $92
  1024b6:	6a 5c                	push   $0x5c
  jmp __alltraps
  1024b8:	e9 a7 fc ff ff       	jmp    102164 <__alltraps>

001024bd <vector93>:
.globl vector93
vector93:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $93
  1024bf:	6a 5d                	push   $0x5d
  jmp __alltraps
  1024c1:	e9 9e fc ff ff       	jmp    102164 <__alltraps>

001024c6 <vector94>:
.globl vector94
vector94:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $94
  1024c8:	6a 5e                	push   $0x5e
  jmp __alltraps
  1024ca:	e9 95 fc ff ff       	jmp    102164 <__alltraps>

001024cf <vector95>:
.globl vector95
vector95:
  pushl $0
  1024cf:	6a 00                	push   $0x0
  pushl $95
  1024d1:	6a 5f                	push   $0x5f
  jmp __alltraps
  1024d3:	e9 8c fc ff ff       	jmp    102164 <__alltraps>

001024d8 <vector96>:
.globl vector96
vector96:
  pushl $0
  1024d8:	6a 00                	push   $0x0
  pushl $96
  1024da:	6a 60                	push   $0x60
  jmp __alltraps
  1024dc:	e9 83 fc ff ff       	jmp    102164 <__alltraps>

001024e1 <vector97>:
.globl vector97
vector97:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $97
  1024e3:	6a 61                	push   $0x61
  jmp __alltraps
  1024e5:	e9 7a fc ff ff       	jmp    102164 <__alltraps>

001024ea <vector98>:
.globl vector98
vector98:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $98
  1024ec:	6a 62                	push   $0x62
  jmp __alltraps
  1024ee:	e9 71 fc ff ff       	jmp    102164 <__alltraps>

001024f3 <vector99>:
.globl vector99
vector99:
  pushl $0
  1024f3:	6a 00                	push   $0x0
  pushl $99
  1024f5:	6a 63                	push   $0x63
  jmp __alltraps
  1024f7:	e9 68 fc ff ff       	jmp    102164 <__alltraps>

001024fc <vector100>:
.globl vector100
vector100:
  pushl $0
  1024fc:	6a 00                	push   $0x0
  pushl $100
  1024fe:	6a 64                	push   $0x64
  jmp __alltraps
  102500:	e9 5f fc ff ff       	jmp    102164 <__alltraps>

00102505 <vector101>:
.globl vector101
vector101:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $101
  102507:	6a 65                	push   $0x65
  jmp __alltraps
  102509:	e9 56 fc ff ff       	jmp    102164 <__alltraps>

0010250e <vector102>:
.globl vector102
vector102:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $102
  102510:	6a 66                	push   $0x66
  jmp __alltraps
  102512:	e9 4d fc ff ff       	jmp    102164 <__alltraps>

00102517 <vector103>:
.globl vector103
vector103:
  pushl $0
  102517:	6a 00                	push   $0x0
  pushl $103
  102519:	6a 67                	push   $0x67
  jmp __alltraps
  10251b:	e9 44 fc ff ff       	jmp    102164 <__alltraps>

00102520 <vector104>:
.globl vector104
vector104:
  pushl $0
  102520:	6a 00                	push   $0x0
  pushl $104
  102522:	6a 68                	push   $0x68
  jmp __alltraps
  102524:	e9 3b fc ff ff       	jmp    102164 <__alltraps>

00102529 <vector105>:
.globl vector105
vector105:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $105
  10252b:	6a 69                	push   $0x69
  jmp __alltraps
  10252d:	e9 32 fc ff ff       	jmp    102164 <__alltraps>

00102532 <vector106>:
.globl vector106
vector106:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $106
  102534:	6a 6a                	push   $0x6a
  jmp __alltraps
  102536:	e9 29 fc ff ff       	jmp    102164 <__alltraps>

0010253b <vector107>:
.globl vector107
vector107:
  pushl $0
  10253b:	6a 00                	push   $0x0
  pushl $107
  10253d:	6a 6b                	push   $0x6b
  jmp __alltraps
  10253f:	e9 20 fc ff ff       	jmp    102164 <__alltraps>

00102544 <vector108>:
.globl vector108
vector108:
  pushl $0
  102544:	6a 00                	push   $0x0
  pushl $108
  102546:	6a 6c                	push   $0x6c
  jmp __alltraps
  102548:	e9 17 fc ff ff       	jmp    102164 <__alltraps>

0010254d <vector109>:
.globl vector109
vector109:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $109
  10254f:	6a 6d                	push   $0x6d
  jmp __alltraps
  102551:	e9 0e fc ff ff       	jmp    102164 <__alltraps>

00102556 <vector110>:
.globl vector110
vector110:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $110
  102558:	6a 6e                	push   $0x6e
  jmp __alltraps
  10255a:	e9 05 fc ff ff       	jmp    102164 <__alltraps>

0010255f <vector111>:
.globl vector111
vector111:
  pushl $0
  10255f:	6a 00                	push   $0x0
  pushl $111
  102561:	6a 6f                	push   $0x6f
  jmp __alltraps
  102563:	e9 fc fb ff ff       	jmp    102164 <__alltraps>

00102568 <vector112>:
.globl vector112
vector112:
  pushl $0
  102568:	6a 00                	push   $0x0
  pushl $112
  10256a:	6a 70                	push   $0x70
  jmp __alltraps
  10256c:	e9 f3 fb ff ff       	jmp    102164 <__alltraps>

00102571 <vector113>:
.globl vector113
vector113:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $113
  102573:	6a 71                	push   $0x71
  jmp __alltraps
  102575:	e9 ea fb ff ff       	jmp    102164 <__alltraps>

0010257a <vector114>:
.globl vector114
vector114:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $114
  10257c:	6a 72                	push   $0x72
  jmp __alltraps
  10257e:	e9 e1 fb ff ff       	jmp    102164 <__alltraps>

00102583 <vector115>:
.globl vector115
vector115:
  pushl $0
  102583:	6a 00                	push   $0x0
  pushl $115
  102585:	6a 73                	push   $0x73
  jmp __alltraps
  102587:	e9 d8 fb ff ff       	jmp    102164 <__alltraps>

0010258c <vector116>:
.globl vector116
vector116:
  pushl $0
  10258c:	6a 00                	push   $0x0
  pushl $116
  10258e:	6a 74                	push   $0x74
  jmp __alltraps
  102590:	e9 cf fb ff ff       	jmp    102164 <__alltraps>

00102595 <vector117>:
.globl vector117
vector117:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $117
  102597:	6a 75                	push   $0x75
  jmp __alltraps
  102599:	e9 c6 fb ff ff       	jmp    102164 <__alltraps>

0010259e <vector118>:
.globl vector118
vector118:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $118
  1025a0:	6a 76                	push   $0x76
  jmp __alltraps
  1025a2:	e9 bd fb ff ff       	jmp    102164 <__alltraps>

001025a7 <vector119>:
.globl vector119
vector119:
  pushl $0
  1025a7:	6a 00                	push   $0x0
  pushl $119
  1025a9:	6a 77                	push   $0x77
  jmp __alltraps
  1025ab:	e9 b4 fb ff ff       	jmp    102164 <__alltraps>

001025b0 <vector120>:
.globl vector120
vector120:
  pushl $0
  1025b0:	6a 00                	push   $0x0
  pushl $120
  1025b2:	6a 78                	push   $0x78
  jmp __alltraps
  1025b4:	e9 ab fb ff ff       	jmp    102164 <__alltraps>

001025b9 <vector121>:
.globl vector121
vector121:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $121
  1025bb:	6a 79                	push   $0x79
  jmp __alltraps
  1025bd:	e9 a2 fb ff ff       	jmp    102164 <__alltraps>

001025c2 <vector122>:
.globl vector122
vector122:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $122
  1025c4:	6a 7a                	push   $0x7a
  jmp __alltraps
  1025c6:	e9 99 fb ff ff       	jmp    102164 <__alltraps>

001025cb <vector123>:
.globl vector123
vector123:
  pushl $0
  1025cb:	6a 00                	push   $0x0
  pushl $123
  1025cd:	6a 7b                	push   $0x7b
  jmp __alltraps
  1025cf:	e9 90 fb ff ff       	jmp    102164 <__alltraps>

001025d4 <vector124>:
.globl vector124
vector124:
  pushl $0
  1025d4:	6a 00                	push   $0x0
  pushl $124
  1025d6:	6a 7c                	push   $0x7c
  jmp __alltraps
  1025d8:	e9 87 fb ff ff       	jmp    102164 <__alltraps>

001025dd <vector125>:
.globl vector125
vector125:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $125
  1025df:	6a 7d                	push   $0x7d
  jmp __alltraps
  1025e1:	e9 7e fb ff ff       	jmp    102164 <__alltraps>

001025e6 <vector126>:
.globl vector126
vector126:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $126
  1025e8:	6a 7e                	push   $0x7e
  jmp __alltraps
  1025ea:	e9 75 fb ff ff       	jmp    102164 <__alltraps>

001025ef <vector127>:
.globl vector127
vector127:
  pushl $0
  1025ef:	6a 00                	push   $0x0
  pushl $127
  1025f1:	6a 7f                	push   $0x7f
  jmp __alltraps
  1025f3:	e9 6c fb ff ff       	jmp    102164 <__alltraps>

001025f8 <vector128>:
.globl vector128
vector128:
  pushl $0
  1025f8:	6a 00                	push   $0x0
  pushl $128
  1025fa:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1025ff:	e9 60 fb ff ff       	jmp    102164 <__alltraps>

00102604 <vector129>:
.globl vector129
vector129:
  pushl $0
  102604:	6a 00                	push   $0x0
  pushl $129
  102606:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10260b:	e9 54 fb ff ff       	jmp    102164 <__alltraps>

00102610 <vector130>:
.globl vector130
vector130:
  pushl $0
  102610:	6a 00                	push   $0x0
  pushl $130
  102612:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102617:	e9 48 fb ff ff       	jmp    102164 <__alltraps>

0010261c <vector131>:
.globl vector131
vector131:
  pushl $0
  10261c:	6a 00                	push   $0x0
  pushl $131
  10261e:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102623:	e9 3c fb ff ff       	jmp    102164 <__alltraps>

00102628 <vector132>:
.globl vector132
vector132:
  pushl $0
  102628:	6a 00                	push   $0x0
  pushl $132
  10262a:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10262f:	e9 30 fb ff ff       	jmp    102164 <__alltraps>

00102634 <vector133>:
.globl vector133
vector133:
  pushl $0
  102634:	6a 00                	push   $0x0
  pushl $133
  102636:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10263b:	e9 24 fb ff ff       	jmp    102164 <__alltraps>

00102640 <vector134>:
.globl vector134
vector134:
  pushl $0
  102640:	6a 00                	push   $0x0
  pushl $134
  102642:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102647:	e9 18 fb ff ff       	jmp    102164 <__alltraps>

0010264c <vector135>:
.globl vector135
vector135:
  pushl $0
  10264c:	6a 00                	push   $0x0
  pushl $135
  10264e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102653:	e9 0c fb ff ff       	jmp    102164 <__alltraps>

00102658 <vector136>:
.globl vector136
vector136:
  pushl $0
  102658:	6a 00                	push   $0x0
  pushl $136
  10265a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10265f:	e9 00 fb ff ff       	jmp    102164 <__alltraps>

00102664 <vector137>:
.globl vector137
vector137:
  pushl $0
  102664:	6a 00                	push   $0x0
  pushl $137
  102666:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10266b:	e9 f4 fa ff ff       	jmp    102164 <__alltraps>

00102670 <vector138>:
.globl vector138
vector138:
  pushl $0
  102670:	6a 00                	push   $0x0
  pushl $138
  102672:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102677:	e9 e8 fa ff ff       	jmp    102164 <__alltraps>

0010267c <vector139>:
.globl vector139
vector139:
  pushl $0
  10267c:	6a 00                	push   $0x0
  pushl $139
  10267e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102683:	e9 dc fa ff ff       	jmp    102164 <__alltraps>

00102688 <vector140>:
.globl vector140
vector140:
  pushl $0
  102688:	6a 00                	push   $0x0
  pushl $140
  10268a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10268f:	e9 d0 fa ff ff       	jmp    102164 <__alltraps>

00102694 <vector141>:
.globl vector141
vector141:
  pushl $0
  102694:	6a 00                	push   $0x0
  pushl $141
  102696:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10269b:	e9 c4 fa ff ff       	jmp    102164 <__alltraps>

001026a0 <vector142>:
.globl vector142
vector142:
  pushl $0
  1026a0:	6a 00                	push   $0x0
  pushl $142
  1026a2:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1026a7:	e9 b8 fa ff ff       	jmp    102164 <__alltraps>

001026ac <vector143>:
.globl vector143
vector143:
  pushl $0
  1026ac:	6a 00                	push   $0x0
  pushl $143
  1026ae:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1026b3:	e9 ac fa ff ff       	jmp    102164 <__alltraps>

001026b8 <vector144>:
.globl vector144
vector144:
  pushl $0
  1026b8:	6a 00                	push   $0x0
  pushl $144
  1026ba:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1026bf:	e9 a0 fa ff ff       	jmp    102164 <__alltraps>

001026c4 <vector145>:
.globl vector145
vector145:
  pushl $0
  1026c4:	6a 00                	push   $0x0
  pushl $145
  1026c6:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1026cb:	e9 94 fa ff ff       	jmp    102164 <__alltraps>

001026d0 <vector146>:
.globl vector146
vector146:
  pushl $0
  1026d0:	6a 00                	push   $0x0
  pushl $146
  1026d2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1026d7:	e9 88 fa ff ff       	jmp    102164 <__alltraps>

001026dc <vector147>:
.globl vector147
vector147:
  pushl $0
  1026dc:	6a 00                	push   $0x0
  pushl $147
  1026de:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1026e3:	e9 7c fa ff ff       	jmp    102164 <__alltraps>

001026e8 <vector148>:
.globl vector148
vector148:
  pushl $0
  1026e8:	6a 00                	push   $0x0
  pushl $148
  1026ea:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1026ef:	e9 70 fa ff ff       	jmp    102164 <__alltraps>

001026f4 <vector149>:
.globl vector149
vector149:
  pushl $0
  1026f4:	6a 00                	push   $0x0
  pushl $149
  1026f6:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1026fb:	e9 64 fa ff ff       	jmp    102164 <__alltraps>

00102700 <vector150>:
.globl vector150
vector150:
  pushl $0
  102700:	6a 00                	push   $0x0
  pushl $150
  102702:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102707:	e9 58 fa ff ff       	jmp    102164 <__alltraps>

0010270c <vector151>:
.globl vector151
vector151:
  pushl $0
  10270c:	6a 00                	push   $0x0
  pushl $151
  10270e:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102713:	e9 4c fa ff ff       	jmp    102164 <__alltraps>

00102718 <vector152>:
.globl vector152
vector152:
  pushl $0
  102718:	6a 00                	push   $0x0
  pushl $152
  10271a:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10271f:	e9 40 fa ff ff       	jmp    102164 <__alltraps>

00102724 <vector153>:
.globl vector153
vector153:
  pushl $0
  102724:	6a 00                	push   $0x0
  pushl $153
  102726:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10272b:	e9 34 fa ff ff       	jmp    102164 <__alltraps>

00102730 <vector154>:
.globl vector154
vector154:
  pushl $0
  102730:	6a 00                	push   $0x0
  pushl $154
  102732:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102737:	e9 28 fa ff ff       	jmp    102164 <__alltraps>

0010273c <vector155>:
.globl vector155
vector155:
  pushl $0
  10273c:	6a 00                	push   $0x0
  pushl $155
  10273e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102743:	e9 1c fa ff ff       	jmp    102164 <__alltraps>

00102748 <vector156>:
.globl vector156
vector156:
  pushl $0
  102748:	6a 00                	push   $0x0
  pushl $156
  10274a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10274f:	e9 10 fa ff ff       	jmp    102164 <__alltraps>

00102754 <vector157>:
.globl vector157
vector157:
  pushl $0
  102754:	6a 00                	push   $0x0
  pushl $157
  102756:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10275b:	e9 04 fa ff ff       	jmp    102164 <__alltraps>

00102760 <vector158>:
.globl vector158
vector158:
  pushl $0
  102760:	6a 00                	push   $0x0
  pushl $158
  102762:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102767:	e9 f8 f9 ff ff       	jmp    102164 <__alltraps>

0010276c <vector159>:
.globl vector159
vector159:
  pushl $0
  10276c:	6a 00                	push   $0x0
  pushl $159
  10276e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102773:	e9 ec f9 ff ff       	jmp    102164 <__alltraps>

00102778 <vector160>:
.globl vector160
vector160:
  pushl $0
  102778:	6a 00                	push   $0x0
  pushl $160
  10277a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10277f:	e9 e0 f9 ff ff       	jmp    102164 <__alltraps>

00102784 <vector161>:
.globl vector161
vector161:
  pushl $0
  102784:	6a 00                	push   $0x0
  pushl $161
  102786:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10278b:	e9 d4 f9 ff ff       	jmp    102164 <__alltraps>

00102790 <vector162>:
.globl vector162
vector162:
  pushl $0
  102790:	6a 00                	push   $0x0
  pushl $162
  102792:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102797:	e9 c8 f9 ff ff       	jmp    102164 <__alltraps>

0010279c <vector163>:
.globl vector163
vector163:
  pushl $0
  10279c:	6a 00                	push   $0x0
  pushl $163
  10279e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1027a3:	e9 bc f9 ff ff       	jmp    102164 <__alltraps>

001027a8 <vector164>:
.globl vector164
vector164:
  pushl $0
  1027a8:	6a 00                	push   $0x0
  pushl $164
  1027aa:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1027af:	e9 b0 f9 ff ff       	jmp    102164 <__alltraps>

001027b4 <vector165>:
.globl vector165
vector165:
  pushl $0
  1027b4:	6a 00                	push   $0x0
  pushl $165
  1027b6:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1027bb:	e9 a4 f9 ff ff       	jmp    102164 <__alltraps>

001027c0 <vector166>:
.globl vector166
vector166:
  pushl $0
  1027c0:	6a 00                	push   $0x0
  pushl $166
  1027c2:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1027c7:	e9 98 f9 ff ff       	jmp    102164 <__alltraps>

001027cc <vector167>:
.globl vector167
vector167:
  pushl $0
  1027cc:	6a 00                	push   $0x0
  pushl $167
  1027ce:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1027d3:	e9 8c f9 ff ff       	jmp    102164 <__alltraps>

001027d8 <vector168>:
.globl vector168
vector168:
  pushl $0
  1027d8:	6a 00                	push   $0x0
  pushl $168
  1027da:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1027df:	e9 80 f9 ff ff       	jmp    102164 <__alltraps>

001027e4 <vector169>:
.globl vector169
vector169:
  pushl $0
  1027e4:	6a 00                	push   $0x0
  pushl $169
  1027e6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1027eb:	e9 74 f9 ff ff       	jmp    102164 <__alltraps>

001027f0 <vector170>:
.globl vector170
vector170:
  pushl $0
  1027f0:	6a 00                	push   $0x0
  pushl $170
  1027f2:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1027f7:	e9 68 f9 ff ff       	jmp    102164 <__alltraps>

001027fc <vector171>:
.globl vector171
vector171:
  pushl $0
  1027fc:	6a 00                	push   $0x0
  pushl $171
  1027fe:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102803:	e9 5c f9 ff ff       	jmp    102164 <__alltraps>

00102808 <vector172>:
.globl vector172
vector172:
  pushl $0
  102808:	6a 00                	push   $0x0
  pushl $172
  10280a:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10280f:	e9 50 f9 ff ff       	jmp    102164 <__alltraps>

00102814 <vector173>:
.globl vector173
vector173:
  pushl $0
  102814:	6a 00                	push   $0x0
  pushl $173
  102816:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10281b:	e9 44 f9 ff ff       	jmp    102164 <__alltraps>

00102820 <vector174>:
.globl vector174
vector174:
  pushl $0
  102820:	6a 00                	push   $0x0
  pushl $174
  102822:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102827:	e9 38 f9 ff ff       	jmp    102164 <__alltraps>

0010282c <vector175>:
.globl vector175
vector175:
  pushl $0
  10282c:	6a 00                	push   $0x0
  pushl $175
  10282e:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102833:	e9 2c f9 ff ff       	jmp    102164 <__alltraps>

00102838 <vector176>:
.globl vector176
vector176:
  pushl $0
  102838:	6a 00                	push   $0x0
  pushl $176
  10283a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10283f:	e9 20 f9 ff ff       	jmp    102164 <__alltraps>

00102844 <vector177>:
.globl vector177
vector177:
  pushl $0
  102844:	6a 00                	push   $0x0
  pushl $177
  102846:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10284b:	e9 14 f9 ff ff       	jmp    102164 <__alltraps>

00102850 <vector178>:
.globl vector178
vector178:
  pushl $0
  102850:	6a 00                	push   $0x0
  pushl $178
  102852:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102857:	e9 08 f9 ff ff       	jmp    102164 <__alltraps>

0010285c <vector179>:
.globl vector179
vector179:
  pushl $0
  10285c:	6a 00                	push   $0x0
  pushl $179
  10285e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102863:	e9 fc f8 ff ff       	jmp    102164 <__alltraps>

00102868 <vector180>:
.globl vector180
vector180:
  pushl $0
  102868:	6a 00                	push   $0x0
  pushl $180
  10286a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10286f:	e9 f0 f8 ff ff       	jmp    102164 <__alltraps>

00102874 <vector181>:
.globl vector181
vector181:
  pushl $0
  102874:	6a 00                	push   $0x0
  pushl $181
  102876:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10287b:	e9 e4 f8 ff ff       	jmp    102164 <__alltraps>

00102880 <vector182>:
.globl vector182
vector182:
  pushl $0
  102880:	6a 00                	push   $0x0
  pushl $182
  102882:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102887:	e9 d8 f8 ff ff       	jmp    102164 <__alltraps>

0010288c <vector183>:
.globl vector183
vector183:
  pushl $0
  10288c:	6a 00                	push   $0x0
  pushl $183
  10288e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102893:	e9 cc f8 ff ff       	jmp    102164 <__alltraps>

00102898 <vector184>:
.globl vector184
vector184:
  pushl $0
  102898:	6a 00                	push   $0x0
  pushl $184
  10289a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10289f:	e9 c0 f8 ff ff       	jmp    102164 <__alltraps>

001028a4 <vector185>:
.globl vector185
vector185:
  pushl $0
  1028a4:	6a 00                	push   $0x0
  pushl $185
  1028a6:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1028ab:	e9 b4 f8 ff ff       	jmp    102164 <__alltraps>

001028b0 <vector186>:
.globl vector186
vector186:
  pushl $0
  1028b0:	6a 00                	push   $0x0
  pushl $186
  1028b2:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1028b7:	e9 a8 f8 ff ff       	jmp    102164 <__alltraps>

001028bc <vector187>:
.globl vector187
vector187:
  pushl $0
  1028bc:	6a 00                	push   $0x0
  pushl $187
  1028be:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1028c3:	e9 9c f8 ff ff       	jmp    102164 <__alltraps>

001028c8 <vector188>:
.globl vector188
vector188:
  pushl $0
  1028c8:	6a 00                	push   $0x0
  pushl $188
  1028ca:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1028cf:	e9 90 f8 ff ff       	jmp    102164 <__alltraps>

001028d4 <vector189>:
.globl vector189
vector189:
  pushl $0
  1028d4:	6a 00                	push   $0x0
  pushl $189
  1028d6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1028db:	e9 84 f8 ff ff       	jmp    102164 <__alltraps>

001028e0 <vector190>:
.globl vector190
vector190:
  pushl $0
  1028e0:	6a 00                	push   $0x0
  pushl $190
  1028e2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1028e7:	e9 78 f8 ff ff       	jmp    102164 <__alltraps>

001028ec <vector191>:
.globl vector191
vector191:
  pushl $0
  1028ec:	6a 00                	push   $0x0
  pushl $191
  1028ee:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1028f3:	e9 6c f8 ff ff       	jmp    102164 <__alltraps>

001028f8 <vector192>:
.globl vector192
vector192:
  pushl $0
  1028f8:	6a 00                	push   $0x0
  pushl $192
  1028fa:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1028ff:	e9 60 f8 ff ff       	jmp    102164 <__alltraps>

00102904 <vector193>:
.globl vector193
vector193:
  pushl $0
  102904:	6a 00                	push   $0x0
  pushl $193
  102906:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10290b:	e9 54 f8 ff ff       	jmp    102164 <__alltraps>

00102910 <vector194>:
.globl vector194
vector194:
  pushl $0
  102910:	6a 00                	push   $0x0
  pushl $194
  102912:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102917:	e9 48 f8 ff ff       	jmp    102164 <__alltraps>

0010291c <vector195>:
.globl vector195
vector195:
  pushl $0
  10291c:	6a 00                	push   $0x0
  pushl $195
  10291e:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102923:	e9 3c f8 ff ff       	jmp    102164 <__alltraps>

00102928 <vector196>:
.globl vector196
vector196:
  pushl $0
  102928:	6a 00                	push   $0x0
  pushl $196
  10292a:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10292f:	e9 30 f8 ff ff       	jmp    102164 <__alltraps>

00102934 <vector197>:
.globl vector197
vector197:
  pushl $0
  102934:	6a 00                	push   $0x0
  pushl $197
  102936:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10293b:	e9 24 f8 ff ff       	jmp    102164 <__alltraps>

00102940 <vector198>:
.globl vector198
vector198:
  pushl $0
  102940:	6a 00                	push   $0x0
  pushl $198
  102942:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102947:	e9 18 f8 ff ff       	jmp    102164 <__alltraps>

0010294c <vector199>:
.globl vector199
vector199:
  pushl $0
  10294c:	6a 00                	push   $0x0
  pushl $199
  10294e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102953:	e9 0c f8 ff ff       	jmp    102164 <__alltraps>

00102958 <vector200>:
.globl vector200
vector200:
  pushl $0
  102958:	6a 00                	push   $0x0
  pushl $200
  10295a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10295f:	e9 00 f8 ff ff       	jmp    102164 <__alltraps>

00102964 <vector201>:
.globl vector201
vector201:
  pushl $0
  102964:	6a 00                	push   $0x0
  pushl $201
  102966:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10296b:	e9 f4 f7 ff ff       	jmp    102164 <__alltraps>

00102970 <vector202>:
.globl vector202
vector202:
  pushl $0
  102970:	6a 00                	push   $0x0
  pushl $202
  102972:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102977:	e9 e8 f7 ff ff       	jmp    102164 <__alltraps>

0010297c <vector203>:
.globl vector203
vector203:
  pushl $0
  10297c:	6a 00                	push   $0x0
  pushl $203
  10297e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102983:	e9 dc f7 ff ff       	jmp    102164 <__alltraps>

00102988 <vector204>:
.globl vector204
vector204:
  pushl $0
  102988:	6a 00                	push   $0x0
  pushl $204
  10298a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10298f:	e9 d0 f7 ff ff       	jmp    102164 <__alltraps>

00102994 <vector205>:
.globl vector205
vector205:
  pushl $0
  102994:	6a 00                	push   $0x0
  pushl $205
  102996:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10299b:	e9 c4 f7 ff ff       	jmp    102164 <__alltraps>

001029a0 <vector206>:
.globl vector206
vector206:
  pushl $0
  1029a0:	6a 00                	push   $0x0
  pushl $206
  1029a2:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1029a7:	e9 b8 f7 ff ff       	jmp    102164 <__alltraps>

001029ac <vector207>:
.globl vector207
vector207:
  pushl $0
  1029ac:	6a 00                	push   $0x0
  pushl $207
  1029ae:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1029b3:	e9 ac f7 ff ff       	jmp    102164 <__alltraps>

001029b8 <vector208>:
.globl vector208
vector208:
  pushl $0
  1029b8:	6a 00                	push   $0x0
  pushl $208
  1029ba:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1029bf:	e9 a0 f7 ff ff       	jmp    102164 <__alltraps>

001029c4 <vector209>:
.globl vector209
vector209:
  pushl $0
  1029c4:	6a 00                	push   $0x0
  pushl $209
  1029c6:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1029cb:	e9 94 f7 ff ff       	jmp    102164 <__alltraps>

001029d0 <vector210>:
.globl vector210
vector210:
  pushl $0
  1029d0:	6a 00                	push   $0x0
  pushl $210
  1029d2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1029d7:	e9 88 f7 ff ff       	jmp    102164 <__alltraps>

001029dc <vector211>:
.globl vector211
vector211:
  pushl $0
  1029dc:	6a 00                	push   $0x0
  pushl $211
  1029de:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1029e3:	e9 7c f7 ff ff       	jmp    102164 <__alltraps>

001029e8 <vector212>:
.globl vector212
vector212:
  pushl $0
  1029e8:	6a 00                	push   $0x0
  pushl $212
  1029ea:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1029ef:	e9 70 f7 ff ff       	jmp    102164 <__alltraps>

001029f4 <vector213>:
.globl vector213
vector213:
  pushl $0
  1029f4:	6a 00                	push   $0x0
  pushl $213
  1029f6:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1029fb:	e9 64 f7 ff ff       	jmp    102164 <__alltraps>

00102a00 <vector214>:
.globl vector214
vector214:
  pushl $0
  102a00:	6a 00                	push   $0x0
  pushl $214
  102a02:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102a07:	e9 58 f7 ff ff       	jmp    102164 <__alltraps>

00102a0c <vector215>:
.globl vector215
vector215:
  pushl $0
  102a0c:	6a 00                	push   $0x0
  pushl $215
  102a0e:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102a13:	e9 4c f7 ff ff       	jmp    102164 <__alltraps>

00102a18 <vector216>:
.globl vector216
vector216:
  pushl $0
  102a18:	6a 00                	push   $0x0
  pushl $216
  102a1a:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102a1f:	e9 40 f7 ff ff       	jmp    102164 <__alltraps>

00102a24 <vector217>:
.globl vector217
vector217:
  pushl $0
  102a24:	6a 00                	push   $0x0
  pushl $217
  102a26:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102a2b:	e9 34 f7 ff ff       	jmp    102164 <__alltraps>

00102a30 <vector218>:
.globl vector218
vector218:
  pushl $0
  102a30:	6a 00                	push   $0x0
  pushl $218
  102a32:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102a37:	e9 28 f7 ff ff       	jmp    102164 <__alltraps>

00102a3c <vector219>:
.globl vector219
vector219:
  pushl $0
  102a3c:	6a 00                	push   $0x0
  pushl $219
  102a3e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102a43:	e9 1c f7 ff ff       	jmp    102164 <__alltraps>

00102a48 <vector220>:
.globl vector220
vector220:
  pushl $0
  102a48:	6a 00                	push   $0x0
  pushl $220
  102a4a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102a4f:	e9 10 f7 ff ff       	jmp    102164 <__alltraps>

00102a54 <vector221>:
.globl vector221
vector221:
  pushl $0
  102a54:	6a 00                	push   $0x0
  pushl $221
  102a56:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102a5b:	e9 04 f7 ff ff       	jmp    102164 <__alltraps>

00102a60 <vector222>:
.globl vector222
vector222:
  pushl $0
  102a60:	6a 00                	push   $0x0
  pushl $222
  102a62:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102a67:	e9 f8 f6 ff ff       	jmp    102164 <__alltraps>

00102a6c <vector223>:
.globl vector223
vector223:
  pushl $0
  102a6c:	6a 00                	push   $0x0
  pushl $223
  102a6e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102a73:	e9 ec f6 ff ff       	jmp    102164 <__alltraps>

00102a78 <vector224>:
.globl vector224
vector224:
  pushl $0
  102a78:	6a 00                	push   $0x0
  pushl $224
  102a7a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102a7f:	e9 e0 f6 ff ff       	jmp    102164 <__alltraps>

00102a84 <vector225>:
.globl vector225
vector225:
  pushl $0
  102a84:	6a 00                	push   $0x0
  pushl $225
  102a86:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102a8b:	e9 d4 f6 ff ff       	jmp    102164 <__alltraps>

00102a90 <vector226>:
.globl vector226
vector226:
  pushl $0
  102a90:	6a 00                	push   $0x0
  pushl $226
  102a92:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102a97:	e9 c8 f6 ff ff       	jmp    102164 <__alltraps>

00102a9c <vector227>:
.globl vector227
vector227:
  pushl $0
  102a9c:	6a 00                	push   $0x0
  pushl $227
  102a9e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102aa3:	e9 bc f6 ff ff       	jmp    102164 <__alltraps>

00102aa8 <vector228>:
.globl vector228
vector228:
  pushl $0
  102aa8:	6a 00                	push   $0x0
  pushl $228
  102aaa:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102aaf:	e9 b0 f6 ff ff       	jmp    102164 <__alltraps>

00102ab4 <vector229>:
.globl vector229
vector229:
  pushl $0
  102ab4:	6a 00                	push   $0x0
  pushl $229
  102ab6:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102abb:	e9 a4 f6 ff ff       	jmp    102164 <__alltraps>

00102ac0 <vector230>:
.globl vector230
vector230:
  pushl $0
  102ac0:	6a 00                	push   $0x0
  pushl $230
  102ac2:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102ac7:	e9 98 f6 ff ff       	jmp    102164 <__alltraps>

00102acc <vector231>:
.globl vector231
vector231:
  pushl $0
  102acc:	6a 00                	push   $0x0
  pushl $231
  102ace:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102ad3:	e9 8c f6 ff ff       	jmp    102164 <__alltraps>

00102ad8 <vector232>:
.globl vector232
vector232:
  pushl $0
  102ad8:	6a 00                	push   $0x0
  pushl $232
  102ada:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102adf:	e9 80 f6 ff ff       	jmp    102164 <__alltraps>

00102ae4 <vector233>:
.globl vector233
vector233:
  pushl $0
  102ae4:	6a 00                	push   $0x0
  pushl $233
  102ae6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102aeb:	e9 74 f6 ff ff       	jmp    102164 <__alltraps>

00102af0 <vector234>:
.globl vector234
vector234:
  pushl $0
  102af0:	6a 00                	push   $0x0
  pushl $234
  102af2:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102af7:	e9 68 f6 ff ff       	jmp    102164 <__alltraps>

00102afc <vector235>:
.globl vector235
vector235:
  pushl $0
  102afc:	6a 00                	push   $0x0
  pushl $235
  102afe:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102b03:	e9 5c f6 ff ff       	jmp    102164 <__alltraps>

00102b08 <vector236>:
.globl vector236
vector236:
  pushl $0
  102b08:	6a 00                	push   $0x0
  pushl $236
  102b0a:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102b0f:	e9 50 f6 ff ff       	jmp    102164 <__alltraps>

00102b14 <vector237>:
.globl vector237
vector237:
  pushl $0
  102b14:	6a 00                	push   $0x0
  pushl $237
  102b16:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102b1b:	e9 44 f6 ff ff       	jmp    102164 <__alltraps>

00102b20 <vector238>:
.globl vector238
vector238:
  pushl $0
  102b20:	6a 00                	push   $0x0
  pushl $238
  102b22:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102b27:	e9 38 f6 ff ff       	jmp    102164 <__alltraps>

00102b2c <vector239>:
.globl vector239
vector239:
  pushl $0
  102b2c:	6a 00                	push   $0x0
  pushl $239
  102b2e:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102b33:	e9 2c f6 ff ff       	jmp    102164 <__alltraps>

00102b38 <vector240>:
.globl vector240
vector240:
  pushl $0
  102b38:	6a 00                	push   $0x0
  pushl $240
  102b3a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102b3f:	e9 20 f6 ff ff       	jmp    102164 <__alltraps>

00102b44 <vector241>:
.globl vector241
vector241:
  pushl $0
  102b44:	6a 00                	push   $0x0
  pushl $241
  102b46:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102b4b:	e9 14 f6 ff ff       	jmp    102164 <__alltraps>

00102b50 <vector242>:
.globl vector242
vector242:
  pushl $0
  102b50:	6a 00                	push   $0x0
  pushl $242
  102b52:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102b57:	e9 08 f6 ff ff       	jmp    102164 <__alltraps>

00102b5c <vector243>:
.globl vector243
vector243:
  pushl $0
  102b5c:	6a 00                	push   $0x0
  pushl $243
  102b5e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102b63:	e9 fc f5 ff ff       	jmp    102164 <__alltraps>

00102b68 <vector244>:
.globl vector244
vector244:
  pushl $0
  102b68:	6a 00                	push   $0x0
  pushl $244
  102b6a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102b6f:	e9 f0 f5 ff ff       	jmp    102164 <__alltraps>

00102b74 <vector245>:
.globl vector245
vector245:
  pushl $0
  102b74:	6a 00                	push   $0x0
  pushl $245
  102b76:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102b7b:	e9 e4 f5 ff ff       	jmp    102164 <__alltraps>

00102b80 <vector246>:
.globl vector246
vector246:
  pushl $0
  102b80:	6a 00                	push   $0x0
  pushl $246
  102b82:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102b87:	e9 d8 f5 ff ff       	jmp    102164 <__alltraps>

00102b8c <vector247>:
.globl vector247
vector247:
  pushl $0
  102b8c:	6a 00                	push   $0x0
  pushl $247
  102b8e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102b93:	e9 cc f5 ff ff       	jmp    102164 <__alltraps>

00102b98 <vector248>:
.globl vector248
vector248:
  pushl $0
  102b98:	6a 00                	push   $0x0
  pushl $248
  102b9a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102b9f:	e9 c0 f5 ff ff       	jmp    102164 <__alltraps>

00102ba4 <vector249>:
.globl vector249
vector249:
  pushl $0
  102ba4:	6a 00                	push   $0x0
  pushl $249
  102ba6:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102bab:	e9 b4 f5 ff ff       	jmp    102164 <__alltraps>

00102bb0 <vector250>:
.globl vector250
vector250:
  pushl $0
  102bb0:	6a 00                	push   $0x0
  pushl $250
  102bb2:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102bb7:	e9 a8 f5 ff ff       	jmp    102164 <__alltraps>

00102bbc <vector251>:
.globl vector251
vector251:
  pushl $0
  102bbc:	6a 00                	push   $0x0
  pushl $251
  102bbe:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102bc3:	e9 9c f5 ff ff       	jmp    102164 <__alltraps>

00102bc8 <vector252>:
.globl vector252
vector252:
  pushl $0
  102bc8:	6a 00                	push   $0x0
  pushl $252
  102bca:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102bcf:	e9 90 f5 ff ff       	jmp    102164 <__alltraps>

00102bd4 <vector253>:
.globl vector253
vector253:
  pushl $0
  102bd4:	6a 00                	push   $0x0
  pushl $253
  102bd6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102bdb:	e9 84 f5 ff ff       	jmp    102164 <__alltraps>

00102be0 <vector254>:
.globl vector254
vector254:
  pushl $0
  102be0:	6a 00                	push   $0x0
  pushl $254
  102be2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102be7:	e9 78 f5 ff ff       	jmp    102164 <__alltraps>

00102bec <vector255>:
.globl vector255
vector255:
  pushl $0
  102bec:	6a 00                	push   $0x0
  pushl $255
  102bee:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102bf3:	e9 6c f5 ff ff       	jmp    102164 <__alltraps>

00102bf8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102bf8:	55                   	push   %ebp
  102bf9:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102bfb:	8b 15 00 ef 11 00    	mov    0x11ef00,%edx
  102c01:	8b 45 08             	mov    0x8(%ebp),%eax
  102c04:	29 d0                	sub    %edx,%eax
  102c06:	c1 f8 02             	sar    $0x2,%eax
  102c09:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102c0f:	5d                   	pop    %ebp
  102c10:	c3                   	ret    

00102c11 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102c11:	55                   	push   %ebp
  102c12:	89 e5                	mov    %esp,%ebp
  102c14:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102c17:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1a:	89 04 24             	mov    %eax,(%esp)
  102c1d:	e8 d6 ff ff ff       	call   102bf8 <page2ppn>
  102c22:	c1 e0 0c             	shl    $0xc,%eax
}
  102c25:	89 ec                	mov    %ebp,%esp
  102c27:	5d                   	pop    %ebp
  102c28:	c3                   	ret    

00102c29 <set_page_ref>:
page_ref(struct Page *page) {
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
  102c29:	55                   	push   %ebp
  102c2a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c32:	89 10                	mov    %edx,(%eax)
}
  102c34:	90                   	nop
  102c35:	5d                   	pop    %ebp
  102c36:	c3                   	ret    

00102c37 <MAX>:
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) (((index) + 1) / 2 - 1)

static struct Page* buddy_base;

static inline uint32_t MAX(uint32_t a, uint32_t b) {return ((a) > (b) ? (a) : (b));}
  102c37:	55                   	push   %ebp
  102c38:	89 e5                	mov    %esp,%ebp
  102c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c40:	39 c2                	cmp    %eax,%edx
  102c42:	0f 43 c2             	cmovae %edx,%eax
  102c45:	5d                   	pop    %ebp
  102c46:	c3                   	ret    

00102c47 <is_pow_of_2>:
static inline bool is_pow_of_2(uint32_t x) { return !(x & (x - 1)); }
  102c47:	55                   	push   %ebp
  102c48:	89 e5                	mov    %esp,%ebp
  102c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c4d:	48                   	dec    %eax
  102c4e:	23 45 08             	and    0x8(%ebp),%eax
  102c51:	85 c0                	test   %eax,%eax
  102c53:	0f 94 c0             	sete   %al
  102c56:	0f b6 c0             	movzbl %al,%eax
  102c59:	5d                   	pop    %ebp
  102c5a:	c3                   	ret    

00102c5b <next_pow_of_2>:
static inline uint32_t next_pow_of_2(uint32_t x)
{
  102c5b:	55                   	push   %ebp
  102c5c:	89 e5                	mov    %esp,%ebp
  102c5e:	83 ec 04             	sub    $0x4,%esp
	if (is_pow_of_2(x)) return x;
  102c61:	8b 45 08             	mov    0x8(%ebp),%eax
  102c64:	89 04 24             	mov    %eax,(%esp)
  102c67:	e8 db ff ff ff       	call   102c47 <is_pow_of_2>
  102c6c:	85 c0                	test   %eax,%eax
  102c6e:	74 05                	je     102c75 <next_pow_of_2+0x1a>
  102c70:	8b 45 08             	mov    0x8(%ebp),%eax
  102c73:	eb 30                	jmp    102ca5 <next_pow_of_2+0x4a>
	x |= x >> 1;
  102c75:	8b 45 08             	mov    0x8(%ebp),%eax
  102c78:	d1 e8                	shr    %eax
  102c7a:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 2;
  102c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c80:	c1 e8 02             	shr    $0x2,%eax
  102c83:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 4;
  102c86:	8b 45 08             	mov    0x8(%ebp),%eax
  102c89:	c1 e8 04             	shr    $0x4,%eax
  102c8c:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 8;
  102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c92:	c1 e8 08             	shr    $0x8,%eax
  102c95:	09 45 08             	or     %eax,0x8(%ebp)
	x |= x >> 16;
  102c98:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9b:	c1 e8 10             	shr    $0x10,%eax
  102c9e:	09 45 08             	or     %eax,0x8(%ebp)
	return x + 1;
  102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ca4:	40                   	inc    %eax
}
  102ca5:	89 ec                	mov    %ebp,%esp
  102ca7:	5d                   	pop    %ebp
  102ca8:	c3                   	ret    

00102ca9 <buddy_init>:

static void
buddy_init(void) {
  102ca9:	55                   	push   %ebp
  102caa:	89 e5                	mov    %esp,%ebp
}
  102cac:	90                   	nop
  102cad:	5d                   	pop    %ebp
  102cae:	c3                   	ret    

00102caf <buddy_init_memmap>:

static void
buddy_init_memmap(struct Page *base, size_t n) {
  102caf:	55                   	push   %ebp
  102cb0:	89 e5                	mov    %esp,%ebp
  102cb2:	83 ec 68             	sub    $0x68,%esp
	assert(n > 0);
  102cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102cb9:	75 24                	jne    102cdf <buddy_init_memmap+0x30>
  102cbb:	c7 44 24 0c 90 77 10 	movl   $0x107790,0xc(%esp)
  102cc2:	00 
  102cc3:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  102cca:	00 
  102ccb:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  102cd2:	00 
  102cd3:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  102cda:	e8 f1 df ff ff       	call   100cd0 <__panic>
	// 最大管理页数：不超过n的最大的2的幂次
	size_t max_pages = 1;
  102cdf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	for (size_t i = 1; i < 31; i++)
  102ce6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  102ced:	eb 1d                	jmp    102d0c <buddy_init_memmap+0x5d>
	{
		// 需要一个存储longest数组的页
		if (max_pages + max_pages / 512 >= n)
  102cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cf2:	c1 e8 09             	shr    $0x9,%eax
  102cf5:	89 c2                	mov    %eax,%edx
  102cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cfa:	01 d0                	add    %edx,%eax
  102cfc:	39 45 0c             	cmp    %eax,0xc(%ebp)
  102cff:	77 05                	ja     102d06 <buddy_init_memmap+0x57>
		{
			max_pages >>= 1;
  102d01:	d1 6d f4             	shrl   -0xc(%ebp)
			break;
  102d04:	eb 0c                	jmp    102d12 <buddy_init_memmap+0x63>
		}
		max_pages <<= 1;
  102d06:	d1 65 f4             	shll   -0xc(%ebp)
	for (size_t i = 1; i < 31; i++)
  102d09:	ff 45 f0             	incl   -0x10(%ebp)
  102d0c:	83 7d f0 1e          	cmpl   $0x1e,-0x10(%ebp)
  102d10:	76 dd                	jbe    102cef <buddy_init_memmap+0x40>
	}
	// 存储longest需要的页数
	size_t longest_array_pages = max_pages / 512 + 1;
  102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d15:	c1 e8 09             	shr    $0x9,%eax
  102d18:	40                   	inc    %eax
  102d19:	89 45 dc             	mov    %eax,-0x24(%ebp)

	buddy_longest = (uint32_t*)KADDR(page2pa(base));
  102d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d1f:	89 04 24             	mov    %eax,(%esp)
  102d22:	e8 ea fe ff ff       	call   102c11 <page2pa>
  102d27:	89 45 d8             	mov    %eax,-0x28(%ebp)
  102d2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102d2d:	c1 e8 0c             	shr    $0xc,%eax
  102d30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  102d33:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  102d38:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  102d3b:	72 23                	jb     102d60 <buddy_init_memmap+0xb1>
  102d3d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d44:	c7 44 24 08 c0 77 10 	movl   $0x1077c0,0x8(%esp)
  102d4b:	00 
  102d4c:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  102d53:	00 
  102d54:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  102d5b:	e8 70 df ff ff       	call   100cd0 <__panic>
  102d60:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102d63:	2d 00 00 00 40       	sub    $0x40000000,%eax
  102d68:	a3 e4 ee 11 00       	mov    %eax,0x11eee4
	buddy_max_pages = max_pages;
  102d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d70:	a3 e8 ee 11 00       	mov    %eax,0x11eee8

	uint32_t node_size = max_pages * 2;
  102d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d78:	01 c0                	add    %eax,%eax
  102d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (uint32_t i = 0; i < 2*max_pages-1; i++)
  102d7d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  102d84:	eb 29                	jmp    102daf <buddy_init_memmap+0x100>
	{
		if (is_pow_of_2(i+1)) node_size >>= 1;
  102d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d89:	40                   	inc    %eax
  102d8a:	89 04 24             	mov    %eax,(%esp)
  102d8d:	e8 b5 fe ff ff       	call   102c47 <is_pow_of_2>
  102d92:	85 c0                	test   %eax,%eax
  102d94:	74 03                	je     102d99 <buddy_init_memmap+0xea>
  102d96:	d1 6d ec             	shrl   -0x14(%ebp)
		buddy_longest[i] = node_size;
  102d99:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  102d9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102da2:	c1 e0 02             	shl    $0x2,%eax
  102da5:	01 c2                	add    %eax,%edx
  102da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102daa:	89 02                	mov    %eax,(%edx)
	for (uint32_t i = 0; i < 2*max_pages-1; i++)
  102dac:	ff 45 e8             	incl   -0x18(%ebp)
  102daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102db2:	01 c0                	add    %eax,%eax
  102db4:	48                   	dec    %eax
  102db5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  102db8:	72 cc                	jb     102d86 <buddy_init_memmap+0xd7>
	}

	for (int i = 0; i < longest_array_pages; i++)
  102dba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102dc1:	eb 34                	jmp    102df7 <buddy_init_memmap+0x148>
	{
		struct Page *p = base + i;
  102dc3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102dc6:	89 d0                	mov    %edx,%eax
  102dc8:	c1 e0 02             	shl    $0x2,%eax
  102dcb:	01 d0                	add    %edx,%eax
  102dcd:	c1 e0 02             	shl    $0x2,%eax
  102dd0:	89 c2                	mov    %eax,%edx
  102dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd5:	01 d0                	add    %edx,%eax
  102dd7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		SetPageReserved(p);
  102dda:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102ddd:	83 c0 04             	add    $0x4,%eax
  102de0:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  102de7:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dea:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102ded:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102df0:	0f ab 10             	bts    %edx,(%eax)
}
  102df3:	90                   	nop
	for (int i = 0; i < longest_array_pages; i++)
  102df4:	ff 45 e4             	incl   -0x1c(%ebp)
  102df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102dfa:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102dfd:	77 c4                	ja     102dc3 <buddy_init_memmap+0x114>
	}

	struct Page *p = base + longest_array_pages;
  102dff:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e02:	89 d0                	mov    %edx,%eax
  102e04:	c1 e0 02             	shl    $0x2,%eax
  102e07:	01 d0                	add    %edx,%eax
  102e09:	c1 e0 02             	shl    $0x2,%eax
  102e0c:	89 c2                	mov    %eax,%edx
  102e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102e11:	01 d0                	add    %edx,%eax
  102e13:	89 45 e0             	mov    %eax,-0x20(%ebp)
	buddy_base = p;
  102e16:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e19:	a3 ec ee 11 00       	mov    %eax,0x11eeec
    for (; p != base + n; p ++) {
  102e1e:	e9 9b 00 00 00       	jmp    102ebe <buddy_init_memmap+0x20f>
		assert(PageReserved(p));
  102e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e26:	83 c0 04             	add    $0x4,%eax
  102e29:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
  102e30:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e33:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102e36:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102e39:	0f a3 10             	bt     %edx,(%eax)
  102e3c:	19 c0                	sbb    %eax,%eax
  102e3e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
  102e41:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102e45:	0f 95 c0             	setne  %al
  102e48:	0f b6 c0             	movzbl %al,%eax
  102e4b:	85 c0                	test   %eax,%eax
  102e4d:	75 24                	jne    102e73 <buddy_init_memmap+0x1c4>
  102e4f:	c7 44 24 0c e3 77 10 	movl   $0x1077e3,0xc(%esp)
  102e56:	00 
  102e57:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  102e5e:	00 
  102e5f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  102e66:	00 
  102e67:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  102e6e:	e8 5d de ff ff       	call   100cd0 <__panic>
		ClearPageReserved(p);
  102e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e76:	83 c0 04             	add    $0x4,%eax
  102e79:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%ebp)
  102e80:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e83:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102e86:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102e89:	0f b3 10             	btr    %edx,(%eax)
}
  102e8c:	90                   	nop
		SetPageProperty(p);
  102e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e90:	83 c0 04             	add    $0x4,%eax
  102e93:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102e9a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102e9d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102ea0:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102ea3:	0f ab 10             	bts    %edx,(%eax)
}
  102ea6:	90                   	nop
		set_page_ref(p, 0);
  102ea7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102eae:	00 
  102eaf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102eb2:	89 04 24             	mov    %eax,(%esp)
  102eb5:	e8 6f fd ff ff       	call   102c29 <set_page_ref>
    for (; p != base + n; p ++) {
  102eba:	83 45 e0 14          	addl   $0x14,-0x20(%ebp)
  102ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ec1:	89 d0                	mov    %edx,%eax
  102ec3:	c1 e0 02             	shl    $0x2,%eax
  102ec6:	01 d0                	add    %edx,%eax
  102ec8:	c1 e0 02             	shl    $0x2,%eax
  102ecb:	89 c2                	mov    %eax,%edx
  102ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed0:	01 d0                	add    %edx,%eax
  102ed2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  102ed5:	0f 85 48 ff ff ff    	jne    102e23 <buddy_init_memmap+0x174>
    }
}
  102edb:	90                   	nop
  102edc:	90                   	nop
  102edd:	89 ec                	mov    %ebp,%esp
  102edf:	5d                   	pop    %ebp
  102ee0:	c3                   	ret    

00102ee1 <buddy_alloc_pages>:

static struct Page *
buddy_alloc_pages(size_t n) {
  102ee1:	55                   	push   %ebp
  102ee2:	89 e5                	mov    %esp,%ebp
  102ee4:	83 ec 38             	sub    $0x38,%esp
  102ee7:	89 5d fc             	mov    %ebx,-0x4(%ebp)
	assert(n > 0);
  102eea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102eee:	75 24                	jne    102f14 <buddy_alloc_pages+0x33>
  102ef0:	c7 44 24 0c 90 77 10 	movl   $0x107790,0xc(%esp)
  102ef7:	00 
  102ef8:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  102eff:	00 
  102f00:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  102f07:	00 
  102f08:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  102f0f:	e8 bc dd ff ff       	call   100cd0 <__panic>
	n = next_pow_of_2(n);
  102f14:	8b 45 08             	mov    0x8(%ebp),%eax
  102f17:	89 04 24             	mov    %eax,(%esp)
  102f1a:	e8 3c fd ff ff       	call   102c5b <next_pow_of_2>
  102f1f:	89 45 08             	mov    %eax,0x8(%ebp)
	if (n > buddy_longest[0]) {
  102f22:	a1 e4 ee 11 00       	mov    0x11eee4,%eax
  102f27:	8b 00                	mov    (%eax),%eax
  102f29:	39 45 08             	cmp    %eax,0x8(%ebp)
  102f2c:	76 0a                	jbe    102f38 <buddy_alloc_pages+0x57>
		return NULL;
  102f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  102f33:	e9 2e 01 00 00       	jmp    103066 <buddy_alloc_pages+0x185>
	}

	// 从根节点遍历二叉树
	uint32_t index = 0;
  102f38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// 当前节点大小 （p->property）
	uint32_t node_size;

	// 寻找合适内存块
	for (node_size = buddy_max_pages; node_size != n; node_size >>= 1) 
  102f3f:	a1 e8 ee 11 00       	mov    0x11eee8,%eax
  102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f47:	eb 2f                	jmp    102f78 <buddy_alloc_pages+0x97>
	{
		if (buddy_longest[LEFT_LEAF(index)] >= n)
  102f49:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  102f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f52:	c1 e0 03             	shl    $0x3,%eax
  102f55:	83 c0 04             	add    $0x4,%eax
  102f58:	01 d0                	add    %edx,%eax
  102f5a:	8b 00                	mov    (%eax),%eax
  102f5c:	39 45 08             	cmp    %eax,0x8(%ebp)
  102f5f:	77 0b                	ja     102f6c <buddy_alloc_pages+0x8b>
			index = LEFT_LEAF(index);
  102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f64:	01 c0                	add    %eax,%eax
  102f66:	40                   	inc    %eax
  102f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f6a:	eb 09                	jmp    102f75 <buddy_alloc_pages+0x94>
		else
			index = RIGHT_LEAF(index);
  102f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f6f:	40                   	inc    %eax
  102f70:	01 c0                	add    %eax,%eax
  102f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (node_size = buddy_max_pages; node_size != n; node_size >>= 1) 
  102f75:	d1 6d f0             	shrl   -0x10(%ebp)
  102f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f7b:	3b 45 08             	cmp    0x8(%ebp),%eax
  102f7e:	75 c9                	jne    102f49 <buddy_alloc_pages+0x68>
	}

	// 分配此节点下的所有页
	buddy_longest[index] = 0;
  102f80:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  102f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f89:	c1 e0 02             	shl    $0x2,%eax
  102f8c:	01 d0                	add    %edx,%eax
  102f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	// 找到页位置
	uint32_t offset = (index + 1) * node_size - buddy_max_pages;
  102f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f97:	40                   	inc    %eax
  102f98:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  102f9c:	8b 15 e8 ee 11 00    	mov    0x11eee8,%edx
  102fa2:	29 d0                	sub    %edx,%eax
  102fa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	struct Page* new_page = buddy_base + offset, * p;
  102fa7:	8b 0d ec ee 11 00    	mov    0x11eeec,%ecx
  102fad:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102fb0:	89 d0                	mov    %edx,%eax
  102fb2:	c1 e0 02             	shl    $0x2,%eax
  102fb5:	01 d0                	add    %edx,%eax
  102fb7:	c1 e0 02             	shl    $0x2,%eax
  102fba:	01 c8                	add    %ecx,%eax
  102fbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (p = new_page; p != new_page+node_size; p++)
  102fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102fc5:	eb 31                	jmp    102ff8 <buddy_alloc_pages+0x117>
	{
		set_page_ref(p, 0); // init时没有设置
  102fc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102fce:	00 
  102fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fd2:	89 04 24             	mov    %eax,(%esp)
  102fd5:	e8 4f fc ff ff       	call   102c29 <set_page_ref>
		ClearPageProperty(p); // 每一页都Clear
  102fda:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fdd:	83 c0 04             	add    $0x4,%eax
  102fe0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102fe7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102fed:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102ff0:	0f b3 10             	btr    %edx,(%eax)
}
  102ff3:	90                   	nop
	for (p = new_page; p != new_page+node_size; p++)
  102ff4:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  102ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102ffb:	89 d0                	mov    %edx,%eax
  102ffd:	c1 e0 02             	shl    $0x2,%eax
  103000:	01 d0                	add    %edx,%eax
  103002:	c1 e0 02             	shl    $0x2,%eax
  103005:	89 c2                	mov    %eax,%edx
  103007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10300a:	01 d0                	add    %edx,%eax
  10300c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  10300f:	75 b6                	jne    102fc7 <buddy_alloc_pages+0xe6>
	}

	// 更新所有父节点
	while (index) {
  103011:	eb 4a                	jmp    10305d <buddy_alloc_pages+0x17c>
		index = PARENT(index);
  103013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103016:	40                   	inc    %eax
  103017:	d1 e8                	shr    %eax
  103019:	48                   	dec    %eax
  10301a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		buddy_longest[index] = MAX(
			buddy_longest[LEFT_LEAF(index)], 
			buddy_longest[RIGHT_LEAF(index)]);
  10301d:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  103023:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103026:	40                   	inc    %eax
  103027:	c1 e0 03             	shl    $0x3,%eax
  10302a:	01 d0                	add    %edx,%eax
		buddy_longest[index] = MAX(
  10302c:	8b 10                	mov    (%eax),%edx
			buddy_longest[LEFT_LEAF(index)], 
  10302e:	8b 0d e4 ee 11 00    	mov    0x11eee4,%ecx
  103034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103037:	c1 e0 03             	shl    $0x3,%eax
  10303a:	83 c0 04             	add    $0x4,%eax
  10303d:	01 c8                	add    %ecx,%eax
		buddy_longest[index] = MAX(
  10303f:	8b 00                	mov    (%eax),%eax
  103041:	8b 1d e4 ee 11 00    	mov    0x11eee4,%ebx
  103047:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  10304a:	c1 e1 02             	shl    $0x2,%ecx
  10304d:	01 cb                	add    %ecx,%ebx
  10304f:	89 54 24 04          	mov    %edx,0x4(%esp)
  103053:	89 04 24             	mov    %eax,(%esp)
  103056:	e8 dc fb ff ff       	call   102c37 <MAX>
  10305b:	89 03                	mov    %eax,(%ebx)
	while (index) {
  10305d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103061:	75 b0                	jne    103013 <buddy_alloc_pages+0x132>
	}
	return new_page;
  103063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  103066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  103069:	89 ec                	mov    %ebp,%esp
  10306b:	5d                   	pop    %ebp
  10306c:	c3                   	ret    

0010306d <buddy_free_pages>:

static void
buddy_free_pages(struct Page *base, size_t n) {
  10306d:	55                   	push   %ebp
  10306e:	89 e5                	mov    %esp,%ebp
  103070:	83 ec 58             	sub    $0x58,%esp
  103073:	89 5d fc             	mov    %ebx,-0x4(%ebp)
	assert(n > 0);
  103076:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10307a:	75 24                	jne    1030a0 <buddy_free_pages+0x33>
  10307c:	c7 44 24 0c 90 77 10 	movl   $0x107790,0xc(%esp)
  103083:	00 
  103084:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  10308b:	00 
  10308c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  103093:	00 
  103094:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  10309b:	e8 30 dc ff ff       	call   100cd0 <__panic>
	n = next_pow_of_2(n);
  1030a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a3:	89 04 24             	mov    %eax,(%esp)
  1030a6:	e8 b0 fb ff ff       	call   102c5b <next_pow_of_2>
  1030ab:	89 45 0c             	mov    %eax,0xc(%ebp)
	// base作为叶节点在longest中的位置
	uint32_t index = (uint32_t)(base - buddy_base) + buddy_max_pages - 1;
  1030ae:	8b 15 ec ee 11 00    	mov    0x11eeec,%edx
  1030b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1030b7:	29 d0                	sub    %edx,%eax
  1030b9:	c1 f8 02             	sar    $0x2,%eax
  1030bc:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
  1030c2:	89 c2                	mov    %eax,%edx
  1030c4:	a1 e8 ee 11 00       	mov    0x11eee8,%eax
  1030c9:	01 d0                	add    %edx,%eax
  1030cb:	48                   	dec    %eax
  1030cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t node_size = 1;
  1030cf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// 向上找到第一个为0的节点
	while (buddy_longest[index] != 0)
  1030d6:	eb 37                	jmp    10310f <buddy_free_pages+0xa2>
	{
		node_size <<= 1;
  1030d8:	d1 65 f0             	shll   -0x10(%ebp)
		assert(index != 0); // 否则出现错误，不存在分配过的节点
  1030db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030df:	75 24                	jne    103105 <buddy_free_pages+0x98>
  1030e1:	c7 44 24 0c f3 77 10 	movl   $0x1077f3,0xc(%esp)
  1030e8:	00 
  1030e9:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1030f0:	00 
  1030f1:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  1030f8:	00 
  1030f9:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103100:	e8 cb db ff ff       	call   100cd0 <__panic>
		index = PARENT(index);
  103105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103108:	40                   	inc    %eax
  103109:	d1 e8                	shr    %eax
  10310b:	48                   	dec    %eax
  10310c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	while (buddy_longest[index] != 0)
  10310f:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  103115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103118:	c1 e0 02             	shl    $0x2,%eax
  10311b:	01 d0                	add    %edx,%eax
  10311d:	8b 00                	mov    (%eax),%eax
  10311f:	85 c0                	test   %eax,%eax
  103121:	75 b5                	jne    1030d8 <buddy_free_pages+0x6b>
	}

	struct Page *p = base;
  103123:	8b 45 08             	mov    0x8(%ebp),%eax
  103126:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (; p != base + n; p ++) {
  103129:	e9 ad 00 00 00       	jmp    1031db <buddy_free_pages+0x16e>
	    assert(!PageReserved(p) && !PageProperty(p));
  10312e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103131:	83 c0 04             	add    $0x4,%eax
  103134:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  10313b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10313e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103141:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103144:	0f a3 10             	bt     %edx,(%eax)
  103147:	19 c0                	sbb    %eax,%eax
  103149:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10314c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  103150:	0f 95 c0             	setne  %al
  103153:	0f b6 c0             	movzbl %al,%eax
  103156:	85 c0                	test   %eax,%eax
  103158:	75 2c                	jne    103186 <buddy_free_pages+0x119>
  10315a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10315d:	83 c0 04             	add    $0x4,%eax
  103160:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  103167:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10316a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10316d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103170:	0f a3 10             	bt     %edx,(%eax)
  103173:	19 c0                	sbb    %eax,%eax
  103175:	89 45 cc             	mov    %eax,-0x34(%ebp)
    return oldbit != 0;
  103178:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  10317c:	0f 95 c0             	setne  %al
  10317f:	0f b6 c0             	movzbl %al,%eax
  103182:	85 c0                	test   %eax,%eax
  103184:	74 24                	je     1031aa <buddy_free_pages+0x13d>
  103186:	c7 44 24 0c 00 78 10 	movl   $0x107800,0xc(%esp)
  10318d:	00 
  10318e:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103195:	00 
  103196:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  10319d:	00 
  10319e:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1031a5:	e8 26 db ff ff       	call   100cd0 <__panic>
        // p->flags = 0;
	    SetPageProperty(p); // 分配时每页都Clear，此时每页都Set
  1031aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031ad:	83 c0 04             	add    $0x4,%eax
  1031b0:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  1031b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1031ba:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1031bd:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1031c0:	0f ab 10             	bts    %edx,(%eax)
}
  1031c3:	90                   	nop
	    set_page_ref(p, 0);
  1031c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1031cb:	00 
  1031cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031cf:	89 04 24             	mov    %eax,(%esp)
  1031d2:	e8 52 fa ff ff       	call   102c29 <set_page_ref>
	for (; p != base + n; p ++) {
  1031d7:	83 45 ec 14          	addl   $0x14,-0x14(%ebp)
  1031db:	8b 55 0c             	mov    0xc(%ebp),%edx
  1031de:	89 d0                	mov    %edx,%eax
  1031e0:	c1 e0 02             	shl    $0x2,%eax
  1031e3:	01 d0                	add    %edx,%eax
  1031e5:	c1 e0 02             	shl    $0x2,%eax
  1031e8:	89 c2                	mov    %eax,%edx
  1031ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ed:	01 d0                	add    %edx,%eax
  1031ef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  1031f2:	0f 85 36 ff ff ff    	jne    10312e <buddy_free_pages+0xc1>
	}

	// 更新longest数组
	buddy_longest[index] = node_size;
  1031f8:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  1031fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103201:	c1 e0 02             	shl    $0x2,%eax
  103204:	01 c2                	add    %eax,%edx
  103206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103209:	89 02                	mov    %eax,(%edx)
	while (index != 0)
  10320b:	eb 7c                	jmp    103289 <buddy_free_pages+0x21c>
	{
		index = PARENT(index);
  10320d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103210:	40                   	inc    %eax
  103211:	d1 e8                	shr    %eax
  103213:	48                   	dec    %eax
  103214:	89 45 f4             	mov    %eax,-0xc(%ebp)
		node_size <<= 1;
  103217:	d1 65 f0             	shll   -0x10(%ebp)
		uint32_t left_size = buddy_longest[LEFT_LEAF(index)];
  10321a:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  103220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103223:	c1 e0 03             	shl    $0x3,%eax
  103226:	83 c0 04             	add    $0x4,%eax
  103229:	01 d0                	add    %edx,%eax
  10322b:	8b 00                	mov    (%eax),%eax
  10322d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		uint32_t right_size = buddy_longest[RIGHT_LEAF(index)];
  103230:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  103236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103239:	40                   	inc    %eax
  10323a:	c1 e0 03             	shl    $0x3,%eax
  10323d:	01 d0                	add    %edx,%eax
  10323f:	8b 00                	mov    (%eax),%eax
  103241:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		if (left_size + right_size == node_size) // 相邻可以合并
  103244:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10324a:	01 d0                	add    %edx,%eax
  10324c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10324f:	75 15                	jne    103266 <buddy_free_pages+0x1f9>
			buddy_longest[index] = node_size;
  103251:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  103257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10325a:	c1 e0 02             	shl    $0x2,%eax
  10325d:	01 c2                	add    %eax,%edx
  10325f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103262:	89 02                	mov    %eax,(%edx)
  103264:	eb 23                	jmp    103289 <buddy_free_pages+0x21c>
		else
			buddy_longest[index] = MAX(left_size, right_size);
  103266:	8b 15 e4 ee 11 00    	mov    0x11eee4,%edx
  10326c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10326f:	c1 e0 02             	shl    $0x2,%eax
  103272:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  103275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103278:	89 44 24 04          	mov    %eax,0x4(%esp)
  10327c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10327f:	89 04 24             	mov    %eax,(%esp)
  103282:	e8 b0 f9 ff ff       	call   102c37 <MAX>
  103287:	89 03                	mov    %eax,(%ebx)
	while (index != 0)
  103289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10328d:	0f 85 7a ff ff ff    	jne    10320d <buddy_free_pages+0x1a0>
	}
}
  103293:	90                   	nop
  103294:	90                   	nop
  103295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  103298:	89 ec                	mov    %ebp,%esp
  10329a:	5d                   	pop    %ebp
  10329b:	c3                   	ret    

0010329c <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
  10329c:	55                   	push   %ebp
  10329d:	89 e5                	mov    %esp,%ebp
    return buddy_longest[0];
  10329f:	a1 e4 ee 11 00       	mov    0x11eee4,%eax
  1032a4:	8b 00                	mov    (%eax),%eax
}
  1032a6:	5d                   	pop    %ebp
  1032a7:	c3                   	ret    

001032a8 <buddy_check>:

static void
buddy_check(void) {
  1032a8:	55                   	push   %ebp
  1032a9:	89 e5                	mov    %esp,%ebp
  1032ab:	81 ec a8 00 00 00    	sub    $0xa8,%esp
	int all_pages = nr_free_pages();
  1032b1:	e8 9d 1b 00 00       	call   104e53 <nr_free_pages>
  1032b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Page* p0, *p1, *p2, *p3, *p4;
	assert(alloc_pages(all_pages + 1) == NULL);
  1032b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032bc:	40                   	inc    %eax
  1032bd:	89 04 24             	mov    %eax,(%esp)
  1032c0:	e8 1f 1b 00 00       	call   104de4 <alloc_pages>
  1032c5:	85 c0                	test   %eax,%eax
  1032c7:	74 24                	je     1032ed <buddy_check+0x45>
  1032c9:	c7 44 24 0c 28 78 10 	movl   $0x107828,0xc(%esp)
  1032d0:	00 
  1032d1:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1032d8:	00 
  1032d9:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  1032e0:	00 
  1032e1:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1032e8:	e8 e3 d9 ff ff       	call   100cd0 <__panic>

	p0 = alloc_pages(1);
  1032ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032f4:	e8 eb 1a 00 00       	call   104de4 <alloc_pages>
  1032f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(p0 != NULL);
  1032fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103300:	75 24                	jne    103326 <buddy_check+0x7e>
  103302:	c7 44 24 0c 4b 78 10 	movl   $0x10784b,0xc(%esp)
  103309:	00 
  10330a:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103311:	00 
  103312:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
  103319:	00 
  10331a:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103321:	e8 aa d9 ff ff       	call   100cd0 <__panic>
	
	p1 = alloc_pages(2);
  103326:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10332d:	e8 b2 1a 00 00       	call   104de4 <alloc_pages>
  103332:	89 45 ec             	mov    %eax,-0x14(%ebp)
	assert(p1 == p0 + 2);
  103335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103338:	83 c0 28             	add    $0x28,%eax
  10333b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  10333e:	74 24                	je     103364 <buddy_check+0xbc>
  103340:	c7 44 24 0c 56 78 10 	movl   $0x107856,0xc(%esp)
  103347:	00 
  103348:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  10334f:	00 
  103350:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  103357:	00 
  103358:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  10335f:	e8 6c d9 ff ff       	call   100cd0 <__panic>
	assert(!PageReserved(p0) && !PageReserved(p1));
  103364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103367:	83 c0 04             	add    $0x4,%eax
  10336a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103371:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10337a:	0f a3 10             	bt     %edx,(%eax)
  10337d:	19 c0                	sbb    %eax,%eax
  10337f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
  103382:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  103386:	0f 95 c0             	setne  %al
  103389:	0f b6 c0             	movzbl %al,%eax
  10338c:	85 c0                	test   %eax,%eax
  10338e:	75 2c                	jne    1033bc <buddy_check+0x114>
  103390:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103393:	83 c0 04             	add    $0x4,%eax
  103396:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  10339d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1033a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1033a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1033a6:	0f a3 10             	bt     %edx,(%eax)
  1033a9:	19 c0                	sbb    %eax,%eax
  1033ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1033ae:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1033b2:	0f 95 c0             	setne  %al
  1033b5:	0f b6 c0             	movzbl %al,%eax
  1033b8:	85 c0                	test   %eax,%eax
  1033ba:	74 24                	je     1033e0 <buddy_check+0x138>
  1033bc:	c7 44 24 0c 64 78 10 	movl   $0x107864,0xc(%esp)
  1033c3:	00 
  1033c4:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1033cb:	00 
  1033cc:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
  1033d3:	00 
  1033d4:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1033db:	e8 f0 d8 ff ff       	call   100cd0 <__panic>
	assert(!PageProperty(p0) && !PageProperty(p1));
  1033e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033e3:	83 c0 04             	add    $0x4,%eax
  1033e6:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  1033ed:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1033f0:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1033f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1033f6:	0f a3 10             	bt     %edx,(%eax)
  1033f9:	19 c0                	sbb    %eax,%eax
  1033fb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
  1033fe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103402:	0f 95 c0             	setne  %al
  103405:	0f b6 c0             	movzbl %al,%eax
  103408:	85 c0                	test   %eax,%eax
  10340a:	75 2c                	jne    103438 <buddy_check+0x190>
  10340c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10340f:	83 c0 04             	add    $0x4,%eax
  103412:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  103419:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10341c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10341f:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103422:	0f a3 10             	bt     %edx,(%eax)
  103425:	19 c0                	sbb    %eax,%eax
  103427:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
  10342a:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  10342e:	0f 95 c0             	setne  %al
  103431:	0f b6 c0             	movzbl %al,%eax
  103434:	85 c0                	test   %eax,%eax
  103436:	74 24                	je     10345c <buddy_check+0x1b4>
  103438:	c7 44 24 0c 8c 78 10 	movl   $0x10788c,0xc(%esp)
  10343f:	00 
  103440:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103447:	00 
  103448:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  10344f:	00 
  103450:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103457:	e8 74 d8 ff ff       	call   100cd0 <__panic>

	p2 = alloc_pages(1);
  10345c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103463:	e8 7c 19 00 00       	call   104de4 <alloc_pages>
  103468:	89 45 e8             	mov    %eax,-0x18(%ebp)
	assert(p2 == p0 + 1);
  10346b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10346e:	83 c0 14             	add    $0x14,%eax
  103471:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103474:	74 24                	je     10349a <buddy_check+0x1f2>
  103476:	c7 44 24 0c b3 78 10 	movl   $0x1078b3,0xc(%esp)
  10347d:	00 
  10347e:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103485:	00 
  103486:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  10348d:	00 
  10348e:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103495:	e8 36 d8 ff ff       	call   100cd0 <__panic>

	p3 = alloc_pages(2);
  10349a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1034a1:	e8 3e 19 00 00       	call   104de4 <alloc_pages>
  1034a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(p3 == p0 + 4);
  1034a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034ac:	83 c0 50             	add    $0x50,%eax
  1034af:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1034b2:	74 24                	je     1034d8 <buddy_check+0x230>
  1034b4:	c7 44 24 0c c0 78 10 	movl   $0x1078c0,0xc(%esp)
  1034bb:	00 
  1034bc:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1034c3:	00 
  1034c4:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
  1034cb:	00 
  1034cc:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1034d3:	e8 f8 d7 ff ff       	call   100cd0 <__panic>
	assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));
  1034d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034db:	83 c0 04             	add    $0x4,%eax
  1034de:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1034e5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1034e8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1034eb:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1034ee:	0f a3 10             	bt     %edx,(%eax)
  1034f1:	19 c0                	sbb    %eax,%eax
  1034f3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1034f6:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1034fa:	0f 95 c0             	setne  %al
  1034fd:	0f b6 c0             	movzbl %al,%eax
  103500:	85 c0                	test   %eax,%eax
  103502:	75 5e                	jne    103562 <buddy_check+0x2ba>
  103504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103507:	83 c0 14             	add    $0x14,%eax
  10350a:	83 c0 04             	add    $0x4,%eax
  10350d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103514:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103517:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10351a:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10351d:	0f a3 10             	bt     %edx,(%eax)
  103520:	19 c0                	sbb    %eax,%eax
  103522:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103525:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103529:	0f 95 c0             	setne  %al
  10352c:	0f b6 c0             	movzbl %al,%eax
  10352f:	85 c0                	test   %eax,%eax
  103531:	75 2f                	jne    103562 <buddy_check+0x2ba>
  103533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103536:	83 c0 28             	add    $0x28,%eax
  103539:	83 c0 04             	add    $0x4,%eax
  10353c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103543:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103546:	8b 45 90             	mov    -0x70(%ebp),%eax
  103549:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10354c:	0f a3 10             	bt     %edx,(%eax)
  10354f:	19 c0                	sbb    %eax,%eax
  103551:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103554:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103558:	0f 95 c0             	setne  %al
  10355b:	0f b6 c0             	movzbl %al,%eax
  10355e:	85 c0                	test   %eax,%eax
  103560:	75 24                	jne    103586 <buddy_check+0x2de>
  103562:	c7 44 24 0c d0 78 10 	movl   $0x1078d0,0xc(%esp)
  103569:	00 
  10356a:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103571:	00 
  103572:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
  103579:	00 
  10357a:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103581:	e8 4a d7 ff ff       	call   100cd0 <__panic>

	free_pages(p1, 2);
  103586:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10358d:	00 
  10358e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103591:	89 04 24             	mov    %eax,(%esp)
  103594:	e8 85 18 00 00       	call   104e1e <free_pages>
	assert(PageProperty(p1) && PageProperty(p1 + 1));
  103599:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10359c:	83 c0 04             	add    $0x4,%eax
  10359f:	c7 45 88 01 00 00 00 	movl   $0x1,-0x78(%ebp)
  1035a6:	89 45 84             	mov    %eax,-0x7c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1035a9:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1035ac:	8b 55 88             	mov    -0x78(%ebp),%edx
  1035af:	0f a3 10             	bt     %edx,(%eax)
  1035b2:	19 c0                	sbb    %eax,%eax
  1035b4:	89 45 80             	mov    %eax,-0x80(%ebp)
    return oldbit != 0;
  1035b7:	83 7d 80 00          	cmpl   $0x0,-0x80(%ebp)
  1035bb:	0f 95 c0             	setne  %al
  1035be:	0f b6 c0             	movzbl %al,%eax
  1035c1:	85 c0                	test   %eax,%eax
  1035c3:	74 41                	je     103606 <buddy_check+0x35e>
  1035c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035c8:	83 c0 14             	add    $0x14,%eax
  1035cb:	83 c0 04             	add    $0x4,%eax
  1035ce:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  1035d5:	00 00 00 
  1035d8:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1035de:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  1035e4:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  1035ea:	0f a3 10             	bt     %edx,(%eax)
  1035ed:	19 c0                	sbb    %eax,%eax
  1035ef:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
    return oldbit != 0;
  1035f5:	83 bd 74 ff ff ff 00 	cmpl   $0x0,-0x8c(%ebp)
  1035fc:	0f 95 c0             	setne  %al
  1035ff:	0f b6 c0             	movzbl %al,%eax
  103602:	85 c0                	test   %eax,%eax
  103604:	75 24                	jne    10362a <buddy_check+0x382>
  103606:	c7 44 24 0c 14 79 10 	movl   $0x107914,0xc(%esp)
  10360d:	00 
  10360e:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103615:	00 
  103616:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  10361d:	00 
  10361e:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103625:	e8 a6 d6 ff ff       	call   100cd0 <__panic>
	assert(p1->ref == 0);
  10362a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10362d:	8b 00                	mov    (%eax),%eax
  10362f:	85 c0                	test   %eax,%eax
  103631:	74 24                	je     103657 <buddy_check+0x3af>
  103633:	c7 44 24 0c 3d 79 10 	movl   $0x10793d,0xc(%esp)
  10363a:	00 
  10363b:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103642:	00 
  103643:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  10364a:	00 
  10364b:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103652:	e8 79 d6 ff ff       	call   100cd0 <__panic>

	free_pages(p0, 1);
  103657:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10365e:	00 
  10365f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103662:	89 04 24             	mov    %eax,(%esp)
  103665:	e8 b4 17 00 00       	call   104e1e <free_pages>
	free_pages(p2, 1);
  10366a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103671:	00 
  103672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103675:	89 04 24             	mov    %eax,(%esp)
  103678:	e8 a1 17 00 00       	call   104e1e <free_pages>

	p4 = alloc_pages(2);
  10367d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103684:	e8 5b 17 00 00       	call   104de4 <alloc_pages>
  103689:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(p4 == p0);
  10368c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10368f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103692:	74 24                	je     1036b8 <buddy_check+0x410>
  103694:	c7 44 24 0c 4a 79 10 	movl   $0x10794a,0xc(%esp)
  10369b:	00 
  10369c:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1036a3:	00 
  1036a4:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  1036ab:	00 
  1036ac:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1036b3:	e8 18 d6 ff ff       	call   100cd0 <__panic>
	free_pages(p4, 2);
  1036b8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1036bf:	00 
  1036c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1036c3:	89 04 24             	mov    %eax,(%esp)
  1036c6:	e8 53 17 00 00       	call   104e1e <free_pages>
	assert((*(p4 + 1)).ref == 0);
  1036cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1036ce:	83 c0 14             	add    $0x14,%eax
  1036d1:	8b 00                	mov    (%eax),%eax
  1036d3:	85 c0                	test   %eax,%eax
  1036d5:	74 24                	je     1036fb <buddy_check+0x453>
  1036d7:	c7 44 24 0c 53 79 10 	movl   $0x107953,0xc(%esp)
  1036de:	00 
  1036df:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1036e6:	00 
  1036e7:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  1036ee:	00 
  1036ef:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1036f6:	e8 d5 d5 ff ff       	call   100cd0 <__panic>

	assert(nr_free_pages() == 16384 /2);
  1036fb:	e8 53 17 00 00       	call   104e53 <nr_free_pages>
  103700:	3d 00 20 00 00       	cmp    $0x2000,%eax
  103705:	74 24                	je     10372b <buddy_check+0x483>
  103707:	c7 44 24 0c 68 79 10 	movl   $0x107968,0xc(%esp)
  10370e:	00 
  10370f:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103716:	00 
  103717:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  10371e:	00 
  10371f:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103726:	e8 a5 d5 ff ff       	call   100cd0 <__panic>

	free_pages(p3, 2);
  10372b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103732:	00 
  103733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103736:	89 04 24             	mov    %eax,(%esp)
  103739:	e8 e0 16 00 00       	call   104e1e <free_pages>

	assert(nr_free_pages() == 16384);
  10373e:	e8 10 17 00 00       	call   104e53 <nr_free_pages>
  103743:	3d 00 40 00 00       	cmp    $0x4000,%eax
  103748:	74 24                	je     10376e <buddy_check+0x4c6>
  10374a:	c7 44 24 0c 84 79 10 	movl   $0x107984,0xc(%esp)
  103751:	00 
  103752:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  103759:	00 
  10375a:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  103761:	00 
  103762:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  103769:	e8 62 d5 ff ff       	call   100cd0 <__panic>

	p1 = alloc_pages(33);
  10376e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
  103775:	e8 6a 16 00 00       	call   104de4 <alloc_pages>
  10377a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	free_pages(p1, 64);
  10377d:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  103784:	00 
  103785:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103788:	89 04 24             	mov    %eax,(%esp)
  10378b:	e8 8e 16 00 00       	call   104e1e <free_pages>

	assert(nr_free_pages() == 16384);
  103790:	e8 be 16 00 00       	call   104e53 <nr_free_pages>
  103795:	3d 00 40 00 00       	cmp    $0x4000,%eax
  10379a:	74 24                	je     1037c0 <buddy_check+0x518>
  10379c:	c7 44 24 0c 84 79 10 	movl   $0x107984,0xc(%esp)
  1037a3:	00 
  1037a4:	c7 44 24 08 96 77 10 	movl   $0x107796,0x8(%esp)
  1037ab:	00 
  1037ac:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  1037b3:	00 
  1037b4:	c7 04 24 ab 77 10 00 	movl   $0x1077ab,(%esp)
  1037bb:	e8 10 d5 ff ff       	call   100cd0 <__panic>
}
  1037c0:	90                   	nop
  1037c1:	89 ec                	mov    %ebp,%esp
  1037c3:	5d                   	pop    %ebp
  1037c4:	c3                   	ret    

001037c5 <page2ppn>:
page2ppn(struct Page *page) {
  1037c5:	55                   	push   %ebp
  1037c6:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1037c8:	8b 15 00 ef 11 00    	mov    0x11ef00,%edx
  1037ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1037d1:	29 d0                	sub    %edx,%eax
  1037d3:	c1 f8 02             	sar    $0x2,%eax
  1037d6:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1037dc:	5d                   	pop    %ebp
  1037dd:	c3                   	ret    

001037de <page2pa>:
page2pa(struct Page *page) {
  1037de:	55                   	push   %ebp
  1037df:	89 e5                	mov    %esp,%ebp
  1037e1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1037e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1037e7:	89 04 24             	mov    %eax,(%esp)
  1037ea:	e8 d6 ff ff ff       	call   1037c5 <page2ppn>
  1037ef:	c1 e0 0c             	shl    $0xc,%eax
}
  1037f2:	89 ec                	mov    %ebp,%esp
  1037f4:	5d                   	pop    %ebp
  1037f5:	c3                   	ret    

001037f6 <page_ref>:
page_ref(struct Page *page) {
  1037f6:	55                   	push   %ebp
  1037f7:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1037f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1037fc:	8b 00                	mov    (%eax),%eax
}
  1037fe:	5d                   	pop    %ebp
  1037ff:	c3                   	ret    

00103800 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  103800:	55                   	push   %ebp
  103801:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103803:	8b 45 08             	mov    0x8(%ebp),%eax
  103806:	8b 55 0c             	mov    0xc(%ebp),%edx
  103809:	89 10                	mov    %edx,(%eax)
}
  10380b:	90                   	nop
  10380c:	5d                   	pop    %ebp
  10380d:	c3                   	ret    

0010380e <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10380e:	55                   	push   %ebp
  10380f:	89 e5                	mov    %esp,%ebp
  103811:	83 ec 10             	sub    $0x10,%esp
  103814:	c7 45 fc f0 ee 11 00 	movl   $0x11eef0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10381b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10381e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  103821:	89 50 04             	mov    %edx,0x4(%eax)
  103824:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103827:	8b 50 04             	mov    0x4(%eax),%edx
  10382a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10382d:	89 10                	mov    %edx,(%eax)
}
  10382f:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  103830:	c7 05 f8 ee 11 00 00 	movl   $0x0,0x11eef8
  103837:	00 00 00 
}
  10383a:	90                   	nop
  10383b:	89 ec                	mov    %ebp,%esp
  10383d:	5d                   	pop    %ebp
  10383e:	c3                   	ret    

0010383f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  10383f:	55                   	push   %ebp
  103840:	89 e5                	mov    %esp,%ebp
  103842:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  103845:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103849:	75 24                	jne    10386f <default_init_memmap+0x30>
  10384b:	c7 44 24 0c cc 79 10 	movl   $0x1079cc,0xc(%esp)
  103852:	00 
  103853:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10385a:	00 
  10385b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  103862:	00 
  103863:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10386a:	e8 61 d4 ff ff       	call   100cd0 <__panic>
    struct Page *p = base;
  10386f:	8b 45 08             	mov    0x8(%ebp),%eax
  103872:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  103875:	eb 7d                	jmp    1038f4 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10387a:	83 c0 04             	add    $0x4,%eax
  10387d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  103884:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10388a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10388d:	0f a3 10             	bt     %edx,(%eax)
  103890:	19 c0                	sbb    %eax,%eax
  103892:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  103895:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103899:	0f 95 c0             	setne  %al
  10389c:	0f b6 c0             	movzbl %al,%eax
  10389f:	85 c0                	test   %eax,%eax
  1038a1:	75 24                	jne    1038c7 <default_init_memmap+0x88>
  1038a3:	c7 44 24 0c fd 79 10 	movl   $0x1079fd,0xc(%esp)
  1038aa:	00 
  1038ab:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1038b2:	00 
  1038b3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1038ba:	00 
  1038bb:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1038c2:	e8 09 d4 ff ff       	call   100cd0 <__panic>
        p->flags = p->property = 0;
  1038c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1038d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038d4:	8b 50 08             	mov    0x8(%eax),%edx
  1038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038da:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1038dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1038e4:	00 
  1038e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038e8:	89 04 24             	mov    %eax,(%esp)
  1038eb:	e8 10 ff ff ff       	call   103800 <set_page_ref>
    for (; p != base + n; p ++) {
  1038f0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1038f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1038f7:	89 d0                	mov    %edx,%eax
  1038f9:	c1 e0 02             	shl    $0x2,%eax
  1038fc:	01 d0                	add    %edx,%eax
  1038fe:	c1 e0 02             	shl    $0x2,%eax
  103901:	89 c2                	mov    %eax,%edx
  103903:	8b 45 08             	mov    0x8(%ebp),%eax
  103906:	01 d0                	add    %edx,%eax
  103908:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10390b:	0f 85 66 ff ff ff    	jne    103877 <default_init_memmap+0x38>
    }
    base->property = n;
  103911:	8b 45 08             	mov    0x8(%ebp),%eax
  103914:	8b 55 0c             	mov    0xc(%ebp),%edx
  103917:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10391a:	8b 45 08             	mov    0x8(%ebp),%eax
  10391d:	83 c0 04             	add    $0x4,%eax
  103920:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  103927:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10392a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10392d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  103930:	0f ab 10             	bts    %edx,(%eax)
}
  103933:	90                   	nop
    nr_free += n;
  103934:	8b 15 f8 ee 11 00    	mov    0x11eef8,%edx
  10393a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10393d:	01 d0                	add    %edx,%eax
  10393f:	a3 f8 ee 11 00       	mov    %eax,0x11eef8
    list_add(&free_list, &(base->page_link));
  103944:	8b 45 08             	mov    0x8(%ebp),%eax
  103947:	83 c0 0c             	add    $0xc,%eax
  10394a:	c7 45 e4 f0 ee 11 00 	movl   $0x11eef0,-0x1c(%ebp)
  103951:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103957:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10395a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10395d:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  103960:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103963:	8b 40 04             	mov    0x4(%eax),%eax
  103966:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103969:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10396c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10396f:	89 55 d0             	mov    %edx,-0x30(%ebp)
  103972:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  103975:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103978:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10397b:	89 10                	mov    %edx,(%eax)
  10397d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103980:	8b 10                	mov    (%eax),%edx
  103982:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103985:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103988:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10398b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10398e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103991:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103994:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103997:	89 10                	mov    %edx,(%eax)
}
  103999:	90                   	nop
}
  10399a:	90                   	nop
}
  10399b:	90                   	nop
}
  10399c:	90                   	nop
  10399d:	89 ec                	mov    %ebp,%esp
  10399f:	5d                   	pop    %ebp
  1039a0:	c3                   	ret    

001039a1 <default_alloc_pages>:

/* along: in FFMA algorithm, the pages should be sorted by address.
 * And the original code just insert the page after allocation 
 * at the beginning of the free_list, so we need to correct it. */
static struct Page *
default_alloc_pages(size_t n) {
  1039a1:	55                   	push   %ebp
  1039a2:	89 e5                	mov    %esp,%ebp
  1039a4:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1039a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1039ab:	75 24                	jne    1039d1 <default_alloc_pages+0x30>
  1039ad:	c7 44 24 0c cc 79 10 	movl   $0x1079cc,0xc(%esp)
  1039b4:	00 
  1039b5:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1039bc:	00 
  1039bd:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  1039c4:	00 
  1039c5:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1039cc:	e8 ff d2 ff ff       	call   100cd0 <__panic>
    if (n > nr_free) {
  1039d1:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  1039d6:	39 45 08             	cmp    %eax,0x8(%ebp)
  1039d9:	76 0a                	jbe    1039e5 <default_alloc_pages+0x44>
        return NULL;
  1039db:	b8 00 00 00 00       	mov    $0x0,%eax
  1039e0:	e9 50 01 00 00       	jmp    103b35 <default_alloc_pages+0x194>
    }
    struct Page *page = NULL;
  1039e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  1039ec:	c7 45 f0 f0 ee 11 00 	movl   $0x11eef0,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1039f3:	eb 1c                	jmp    103a11 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  1039f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1039f8:	83 e8 0c             	sub    $0xc,%eax
  1039fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  1039fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a01:	8b 40 08             	mov    0x8(%eax),%eax
  103a04:	39 45 08             	cmp    %eax,0x8(%ebp)
  103a07:	77 08                	ja     103a11 <default_alloc_pages+0x70>
            page = p;
  103a09:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  103a0f:	eb 18                	jmp    103a29 <default_alloc_pages+0x88>
  103a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  103a17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a1a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a20:	81 7d f0 f0 ee 11 00 	cmpl   $0x11eef0,-0x10(%ebp)
  103a27:	75 cc                	jne    1039f5 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  103a29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103a2d:	0f 84 ff 00 00 00    	je     103b32 <default_alloc_pages+0x191>
    	/*
        list_del(&(page->page_link));
        */
        if (page->property > n) {
  103a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a36:	8b 40 08             	mov    0x8(%eax),%eax
  103a39:	39 45 08             	cmp    %eax,0x8(%ebp)
  103a3c:	0f 83 9c 00 00 00    	jae    103ade <default_alloc_pages+0x13d>
            struct Page *p = page + n;
  103a42:	8b 55 08             	mov    0x8(%ebp),%edx
  103a45:	89 d0                	mov    %edx,%eax
  103a47:	c1 e0 02             	shl    $0x2,%eax
  103a4a:	01 d0                	add    %edx,%eax
  103a4c:	c1 e0 02             	shl    $0x2,%eax
  103a4f:	89 c2                	mov    %eax,%edx
  103a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a54:	01 d0                	add    %edx,%eax
  103a56:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a5c:	8b 40 08             	mov    0x8(%eax),%eax
  103a5f:	2b 45 08             	sub    0x8(%ebp),%eax
  103a62:	89 c2                	mov    %eax,%edx
  103a64:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a67:	89 50 08             	mov    %edx,0x8(%eax)
            // my code
            SetPageProperty(p);
  103a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a6d:	83 c0 04             	add    $0x4,%eax
  103a70:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  103a77:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103a7a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103a7d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  103a80:	0f ab 10             	bts    %edx,(%eax)
}
  103a83:	90                   	nop
            list_add(&(page->page_link), &(p->page_link));
  103a84:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a87:	83 c0 0c             	add    $0xc,%eax
  103a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103a8d:	83 c2 0c             	add    $0xc,%edx
  103a90:	89 55 e0             	mov    %edx,-0x20(%ebp)
  103a93:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103a96:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103a99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  103a9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103a9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
  103aa2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103aa5:	8b 40 04             	mov    0x4(%eax),%eax
  103aa8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103aab:	89 55 d0             	mov    %edx,-0x30(%ebp)
  103aae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  103ab1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  103ab4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
  103ab7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103aba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103abd:	89 10                	mov    %edx,(%eax)
  103abf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103ac2:	8b 10                	mov    (%eax),%edx
  103ac4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103ac7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103aca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103acd:	8b 55 c8             	mov    -0x38(%ebp),%edx
  103ad0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103ad3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103ad6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103ad9:	89 10                	mov    %edx,(%eax)
}
  103adb:	90                   	nop
}
  103adc:	90                   	nop
}
  103add:	90                   	nop
            /*
            list_add(&free_list, &(p->page_link));
            */
        }
        // my code
        list_del(&(page->page_link));
  103ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ae1:	83 c0 0c             	add    $0xc,%eax
  103ae4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
  103ae7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103aea:	8b 40 04             	mov    0x4(%eax),%eax
  103aed:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103af0:	8b 12                	mov    (%edx),%edx
  103af2:	89 55 b0             	mov    %edx,-0x50(%ebp)
  103af5:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  103af8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103afb:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103afe:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103b01:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103b04:	8b 55 b0             	mov    -0x50(%ebp),%edx
  103b07:	89 10                	mov    %edx,(%eax)
}
  103b09:	90                   	nop
}
  103b0a:	90                   	nop
        // -----
        nr_free -= n;
  103b0b:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  103b10:	2b 45 08             	sub    0x8(%ebp),%eax
  103b13:	a3 f8 ee 11 00       	mov    %eax,0x11eef8
        ClearPageProperty(page);
  103b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b1b:	83 c0 04             	add    $0x4,%eax
  103b1e:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  103b25:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103b28:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103b2b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103b2e:	0f b3 10             	btr    %edx,(%eax)
}
  103b31:	90                   	nop
    }
    return page;
  103b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103b35:	89 ec                	mov    %ebp,%esp
  103b37:	5d                   	pop    %ebp
  103b38:	c3                   	ret    

00103b39 <default_free_pages>:

/* along: in FFMA algorithm, the pages should be sorted by address.
 * And the original code just insert the page to be freed 
 * at the beginning of the free_list, so we need to correct it. */
static void
default_free_pages(struct Page *base, size_t n) {
  103b39:	55                   	push   %ebp
  103b3a:	89 e5                	mov    %esp,%ebp
  103b3c:	81 ec b8 00 00 00    	sub    $0xb8,%esp
    assert(n > 0);
  103b42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103b46:	75 24                	jne    103b6c <default_free_pages+0x33>
  103b48:	c7 44 24 0c cc 79 10 	movl   $0x1079cc,0xc(%esp)
  103b4f:	00 
  103b50:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103b57:	00 
  103b58:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  103b5f:	00 
  103b60:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  103b67:	e8 64 d1 ff ff       	call   100cd0 <__panic>
    struct Page *p = base;
  103b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  103b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page *pp = base; // 前一页 my code
  103b72:	8b 45 08             	mov    0x8(%ebp),%eax
  103b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (; p != base + n; p ++) {
  103b78:	e9 9d 00 00 00       	jmp    103c1a <default_free_pages+0xe1>
        assert(!PageReserved(p) && !PageProperty(p));
  103b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b80:	83 c0 04             	add    $0x4,%eax
  103b83:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  103b8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b90:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103b93:	0f a3 10             	bt     %edx,(%eax)
  103b96:	19 c0                	sbb    %eax,%eax
  103b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  103b9b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103b9f:	0f 95 c0             	setne  %al
  103ba2:	0f b6 c0             	movzbl %al,%eax
  103ba5:	85 c0                	test   %eax,%eax
  103ba7:	75 2c                	jne    103bd5 <default_free_pages+0x9c>
  103ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bac:	83 c0 04             	add    $0x4,%eax
  103baf:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  103bb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103bb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103bbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103bbf:	0f a3 10             	bt     %edx,(%eax)
  103bc2:	19 c0                	sbb    %eax,%eax
  103bc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
  103bc7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  103bcb:	0f 95 c0             	setne  %al
  103bce:	0f b6 c0             	movzbl %al,%eax
  103bd1:	85 c0                	test   %eax,%eax
  103bd3:	74 24                	je     103bf9 <default_free_pages+0xc0>
  103bd5:	c7 44 24 0c 10 7a 10 	movl   $0x107a10,0xc(%esp)
  103bdc:	00 
  103bdd:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103be4:	00 
  103be5:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
  103bec:	00 
  103bed:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  103bf4:	e8 d7 d0 ff ff       	call   100cd0 <__panic>
        p->flags = 0;
  103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bfc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  103c03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103c0a:	00 
  103c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c0e:	89 04 24             	mov    %eax,(%esp)
  103c11:	e8 ea fb ff ff       	call   103800 <set_page_ref>
    for (; p != base + n; p ++) {
  103c16:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  103c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  103c1d:	89 d0                	mov    %edx,%eax
  103c1f:	c1 e0 02             	shl    $0x2,%eax
  103c22:	01 d0                	add    %edx,%eax
  103c24:	c1 e0 02             	shl    $0x2,%eax
  103c27:	89 c2                	mov    %eax,%edx
  103c29:	8b 45 08             	mov    0x8(%ebp),%eax
  103c2c:	01 d0                	add    %edx,%eax
  103c2e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103c31:	0f 85 46 ff ff ff    	jne    103b7d <default_free_pages+0x44>
    }
    p = base; // my code
  103c37:	8b 45 08             	mov    0x8(%ebp),%eax
  103c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    base->property = n;
  103c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c40:	8b 55 0c             	mov    0xc(%ebp),%edx
  103c43:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  103c46:	8b 45 08             	mov    0x8(%ebp),%eax
  103c49:	83 c0 04             	add    $0x4,%eax
  103c4c:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  103c53:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103c56:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103c59:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103c5c:	0f ab 10             	bts    %edx,(%eax)
}
  103c5f:	90                   	nop
  103c60:	c7 45 d0 f0 ee 11 00 	movl   $0x11eef0,-0x30(%ebp)
    return listelm->next;
  103c67:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103c6a:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  103c6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    // my code
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
  103c70:	eb 15                	jmp    103c87 <default_free_pages+0x14e>
        pp = p;
  103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c7b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  103c7e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103c81:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  103c84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
  103c87:	81 7d ec f0 ee 11 00 	cmpl   $0x11eef0,-0x14(%ebp)
  103c8e:	74 11                	je     103ca1 <default_free_pages+0x168>
  103c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c93:	83 e8 0c             	sub    $0xc,%eax
  103c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c9c:	3b 45 08             	cmp    0x8(%ebp),%eax
  103c9f:	72 d1                	jb     103c72 <default_free_pages+0x139>
    }

    if ((base + base->property == p) && (pp + pp->property == base)) {
  103ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  103ca4:	8b 50 08             	mov    0x8(%eax),%edx
  103ca7:	89 d0                	mov    %edx,%eax
  103ca9:	c1 e0 02             	shl    $0x2,%eax
  103cac:	01 d0                	add    %edx,%eax
  103cae:	c1 e0 02             	shl    $0x2,%eax
  103cb1:	89 c2                	mov    %eax,%edx
  103cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  103cb6:	01 d0                	add    %edx,%eax
  103cb8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103cbb:	0f 85 9b 00 00 00    	jne    103d5c <default_free_pages+0x223>
  103cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cc4:	8b 50 08             	mov    0x8(%eax),%edx
  103cc7:	89 d0                	mov    %edx,%eax
  103cc9:	c1 e0 02             	shl    $0x2,%eax
  103ccc:	01 d0                	add    %edx,%eax
  103cce:	c1 e0 02             	shl    $0x2,%eax
  103cd1:	89 c2                	mov    %eax,%edx
  103cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cd6:	01 d0                	add    %edx,%eax
  103cd8:	39 45 08             	cmp    %eax,0x8(%ebp)
  103cdb:	75 7f                	jne    103d5c <default_free_pages+0x223>
        pp->property += (base->property + p->property);
  103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103ce0:	8b 50 08             	mov    0x8(%eax),%edx
  103ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  103ce6:	8b 48 08             	mov    0x8(%eax),%ecx
  103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cec:	8b 40 08             	mov    0x8(%eax),%eax
  103cef:	01 c8                	add    %ecx,%eax
  103cf1:	01 c2                	add    %eax,%edx
  103cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cf6:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
  103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  103cfc:	83 c0 04             	add    $0x4,%eax
  103cff:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103d06:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103d09:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103d0c:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103d0f:	0f b3 10             	btr    %edx,(%eax)
}
  103d12:	90                   	nop
        ClearPageProperty(p);
  103d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d16:	83 c0 04             	add    $0x4,%eax
  103d19:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
  103d20:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103d23:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103d26:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103d29:	0f b3 10             	btr    %edx,(%eax)
}
  103d2c:	90                   	nop
  103d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103d30:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
  103d33:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103d36:	8b 40 04             	mov    0x4(%eax),%eax
  103d39:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103d3c:	8b 12                	mov    (%edx),%edx
  103d3e:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103d41:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
  103d44:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103d47:	8b 55 b8             	mov    -0x48(%ebp),%edx
  103d4a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103d4d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103d50:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103d53:	89 10                	mov    %edx,(%eax)
}
  103d55:	90                   	nop
}
  103d56:	90                   	nop
        list_del(le);
  103d57:	e9 95 01 00 00       	jmp    103ef1 <default_free_pages+0x3b8>
    }
    else if (base + base->property == p) {
  103d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  103d5f:	8b 50 08             	mov    0x8(%eax),%edx
  103d62:	89 d0                	mov    %edx,%eax
  103d64:	c1 e0 02             	shl    $0x2,%eax
  103d67:	01 d0                	add    %edx,%eax
  103d69:	c1 e0 02             	shl    $0x2,%eax
  103d6c:	89 c2                	mov    %eax,%edx
  103d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  103d71:	01 d0                	add    %edx,%eax
  103d73:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103d76:	0f 85 a5 00 00 00    	jne    103e21 <default_free_pages+0x2e8>
        base->property += p->property;
  103d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  103d7f:	8b 50 08             	mov    0x8(%eax),%edx
  103d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d85:	8b 40 08             	mov    0x8(%eax),%eax
  103d88:	01 c2                	add    %eax,%edx
  103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  103d8d:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(p);
  103d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d93:	83 c0 04             	add    $0x4,%eax
  103d96:	c7 45 84 01 00 00 00 	movl   $0x1,-0x7c(%ebp)
  103d9d:	89 45 80             	mov    %eax,-0x80(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103da0:	8b 45 80             	mov    -0x80(%ebp),%eax
  103da3:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103da6:	0f b3 10             	btr    %edx,(%eax)
}
  103da9:	90                   	nop
        list_add_before(le, &(base->page_link));
  103daa:	8b 45 08             	mov    0x8(%ebp),%eax
  103dad:	8d 50 0c             	lea    0xc(%eax),%edx
  103db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103db3:	89 45 98             	mov    %eax,-0x68(%ebp)
  103db6:	89 55 94             	mov    %edx,-0x6c(%ebp)
    __list_add(elm, listelm->prev, listelm);
  103db9:	8b 45 98             	mov    -0x68(%ebp),%eax
  103dbc:	8b 00                	mov    (%eax),%eax
  103dbe:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103dc1:	89 55 90             	mov    %edx,-0x70(%ebp)
  103dc4:	89 45 8c             	mov    %eax,-0x74(%ebp)
  103dc7:	8b 45 98             	mov    -0x68(%ebp),%eax
  103dca:	89 45 88             	mov    %eax,-0x78(%ebp)
    prev->next = next->prev = elm;
  103dcd:	8b 45 88             	mov    -0x78(%ebp),%eax
  103dd0:	8b 55 90             	mov    -0x70(%ebp),%edx
  103dd3:	89 10                	mov    %edx,(%eax)
  103dd5:	8b 45 88             	mov    -0x78(%ebp),%eax
  103dd8:	8b 10                	mov    (%eax),%edx
  103dda:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103ddd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103de0:	8b 45 90             	mov    -0x70(%ebp),%eax
  103de3:	8b 55 88             	mov    -0x78(%ebp),%edx
  103de6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103de9:	8b 45 90             	mov    -0x70(%ebp),%eax
  103dec:	8b 55 8c             	mov    -0x74(%ebp),%edx
  103def:	89 10                	mov    %edx,(%eax)
}
  103df1:	90                   	nop
}
  103df2:	90                   	nop
  103df3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103df6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    __list_del(listelm->prev, listelm->next);
  103df9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103dfc:	8b 40 04             	mov    0x4(%eax),%eax
  103dff:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103e02:	8b 12                	mov    (%edx),%edx
  103e04:	89 55 a0             	mov    %edx,-0x60(%ebp)
  103e07:	89 45 9c             	mov    %eax,-0x64(%ebp)
    prev->next = next;
  103e0a:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103e0d:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103e10:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  103e13:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103e16:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103e19:	89 10                	mov    %edx,(%eax)
}
  103e1b:	90                   	nop
}
  103e1c:	e9 d0 00 00 00       	jmp    103ef1 <default_free_pages+0x3b8>
        list_del(le);
    }
    else if (pp + pp->property == base) {
  103e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e24:	8b 50 08             	mov    0x8(%eax),%edx
  103e27:	89 d0                	mov    %edx,%eax
  103e29:	c1 e0 02             	shl    $0x2,%eax
  103e2c:	01 d0                	add    %edx,%eax
  103e2e:	c1 e0 02             	shl    $0x2,%eax
  103e31:	89 c2                	mov    %eax,%edx
  103e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e36:	01 d0                	add    %edx,%eax
  103e38:	39 45 08             	cmp    %eax,0x8(%ebp)
  103e3b:	75 3b                	jne    103e78 <default_free_pages+0x33f>
        pp->property += base->property;
  103e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e40:	8b 50 08             	mov    0x8(%eax),%edx
  103e43:	8b 45 08             	mov    0x8(%ebp),%eax
  103e46:	8b 40 08             	mov    0x8(%eax),%eax
  103e49:	01 c2                	add    %eax,%edx
  103e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e4e:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
  103e51:	8b 45 08             	mov    0x8(%ebp),%eax
  103e54:	83 c0 04             	add    $0x4,%eax
  103e57:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  103e5e:	00 00 00 
  103e61:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103e67:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  103e6d:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  103e73:	0f b3 10             	btr    %edx,(%eax)
}
  103e76:	eb 79                	jmp    103ef1 <default_free_pages+0x3b8>
    }
    else {
        list_add_before(le, &(base->page_link));
  103e78:	8b 45 08             	mov    0x8(%ebp),%eax
  103e7b:	8d 50 0c             	lea    0xc(%eax),%edx
  103e7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e81:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
  103e87:	89 95 70 ff ff ff    	mov    %edx,-0x90(%ebp)
    __list_add(elm, listelm->prev, listelm);
  103e8d:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  103e93:	8b 00                	mov    (%eax),%eax
  103e95:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
  103e9b:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
  103ea1:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
  103ea7:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  103ead:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
    prev->next = next->prev = elm;
  103eb3:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  103eb9:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
  103ebf:	89 10                	mov    %edx,(%eax)
  103ec1:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  103ec7:	8b 10                	mov    (%eax),%edx
  103ec9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  103ecf:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  103ed2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  103ed8:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
  103ede:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103ee1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  103ee7:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
  103eed:	89 10                	mov    %edx,(%eax)
}
  103eef:	90                   	nop
}
  103ef0:	90                   	nop
    }

    nr_free += n;
  103ef1:	8b 15 f8 ee 11 00    	mov    0x11eef8,%edx
  103ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  103efa:	01 d0                	add    %edx,%eax
  103efc:	a3 f8 ee 11 00       	mov    %eax,0x11eef8
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
  103f01:	90                   	nop
  103f02:	89 ec                	mov    %ebp,%esp
  103f04:	5d                   	pop    %ebp
  103f05:	c3                   	ret    

00103f06 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  103f06:	55                   	push   %ebp
  103f07:	89 e5                	mov    %esp,%ebp
    return nr_free;
  103f09:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
}
  103f0e:	5d                   	pop    %ebp
  103f0f:	c3                   	ret    

00103f10 <basic_check>:

static void
basic_check(void) {
  103f10:	55                   	push   %ebp
  103f11:	89 e5                	mov    %esp,%ebp
  103f13:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  103f29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f30:	e8 af 0e 00 00       	call   104de4 <alloc_pages>
  103f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103f38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103f3c:	75 24                	jne    103f62 <basic_check+0x52>
  103f3e:	c7 44 24 0c 35 7a 10 	movl   $0x107a35,0xc(%esp)
  103f45:	00 
  103f46:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103f4d:	00 
  103f4e:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103f55:	00 
  103f56:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  103f5d:	e8 6e cd ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103f62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f69:	e8 76 0e 00 00       	call   104de4 <alloc_pages>
  103f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103f75:	75 24                	jne    103f9b <basic_check+0x8b>
  103f77:	c7 44 24 0c 51 7a 10 	movl   $0x107a51,0xc(%esp)
  103f7e:	00 
  103f7f:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103f86:	00 
  103f87:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  103f8e:	00 
  103f8f:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  103f96:	e8 35 cd ff ff       	call   100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
  103f9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103fa2:	e8 3d 0e 00 00       	call   104de4 <alloc_pages>
  103fa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103faa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103fae:	75 24                	jne    103fd4 <basic_check+0xc4>
  103fb0:	c7 44 24 0c 6d 7a 10 	movl   $0x107a6d,0xc(%esp)
  103fb7:	00 
  103fb8:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103fbf:	00 
  103fc0:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  103fc7:	00 
  103fc8:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  103fcf:	e8 fc cc ff ff       	call   100cd0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  103fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fd7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103fda:	74 10                	je     103fec <basic_check+0xdc>
  103fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fdf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103fe2:	74 08                	je     103fec <basic_check+0xdc>
  103fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103fe7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103fea:	75 24                	jne    104010 <basic_check+0x100>
  103fec:	c7 44 24 0c 8c 7a 10 	movl   $0x107a8c,0xc(%esp)
  103ff3:	00 
  103ff4:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  103ffb:	00 
  103ffc:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104003:	00 
  104004:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10400b:	e8 c0 cc ff ff       	call   100cd0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104010:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104013:	89 04 24             	mov    %eax,(%esp)
  104016:	e8 db f7 ff ff       	call   1037f6 <page_ref>
  10401b:	85 c0                	test   %eax,%eax
  10401d:	75 1e                	jne    10403d <basic_check+0x12d>
  10401f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104022:	89 04 24             	mov    %eax,(%esp)
  104025:	e8 cc f7 ff ff       	call   1037f6 <page_ref>
  10402a:	85 c0                	test   %eax,%eax
  10402c:	75 0f                	jne    10403d <basic_check+0x12d>
  10402e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104031:	89 04 24             	mov    %eax,(%esp)
  104034:	e8 bd f7 ff ff       	call   1037f6 <page_ref>
  104039:	85 c0                	test   %eax,%eax
  10403b:	74 24                	je     104061 <basic_check+0x151>
  10403d:	c7 44 24 0c b0 7a 10 	movl   $0x107ab0,0xc(%esp)
  104044:	00 
  104045:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10404c:	00 
  10404d:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  104054:	00 
  104055:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10405c:	e8 6f cc ff ff       	call   100cd0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104061:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104064:	89 04 24             	mov    %eax,(%esp)
  104067:	e8 72 f7 ff ff       	call   1037de <page2pa>
  10406c:	8b 15 04 ef 11 00    	mov    0x11ef04,%edx
  104072:	c1 e2 0c             	shl    $0xc,%edx
  104075:	39 d0                	cmp    %edx,%eax
  104077:	72 24                	jb     10409d <basic_check+0x18d>
  104079:	c7 44 24 0c ec 7a 10 	movl   $0x107aec,0xc(%esp)
  104080:	00 
  104081:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104088:	00 
  104089:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  104090:	00 
  104091:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104098:	e8 33 cc ff ff       	call   100cd0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  10409d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1040a0:	89 04 24             	mov    %eax,(%esp)
  1040a3:	e8 36 f7 ff ff       	call   1037de <page2pa>
  1040a8:	8b 15 04 ef 11 00    	mov    0x11ef04,%edx
  1040ae:	c1 e2 0c             	shl    $0xc,%edx
  1040b1:	39 d0                	cmp    %edx,%eax
  1040b3:	72 24                	jb     1040d9 <basic_check+0x1c9>
  1040b5:	c7 44 24 0c 09 7b 10 	movl   $0x107b09,0xc(%esp)
  1040bc:	00 
  1040bd:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1040c4:	00 
  1040c5:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  1040cc:	00 
  1040cd:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1040d4:	e8 f7 cb ff ff       	call   100cd0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040dc:	89 04 24             	mov    %eax,(%esp)
  1040df:	e8 fa f6 ff ff       	call   1037de <page2pa>
  1040e4:	8b 15 04 ef 11 00    	mov    0x11ef04,%edx
  1040ea:	c1 e2 0c             	shl    $0xc,%edx
  1040ed:	39 d0                	cmp    %edx,%eax
  1040ef:	72 24                	jb     104115 <basic_check+0x205>
  1040f1:	c7 44 24 0c 26 7b 10 	movl   $0x107b26,0xc(%esp)
  1040f8:	00 
  1040f9:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104100:	00 
  104101:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  104108:	00 
  104109:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104110:	e8 bb cb ff ff       	call   100cd0 <__panic>

    list_entry_t free_list_store = free_list;
  104115:	a1 f0 ee 11 00       	mov    0x11eef0,%eax
  10411a:	8b 15 f4 ee 11 00    	mov    0x11eef4,%edx
  104120:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104123:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104126:	c7 45 dc f0 ee 11 00 	movl   $0x11eef0,-0x24(%ebp)
    elm->prev = elm->next = elm;
  10412d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104130:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104133:	89 50 04             	mov    %edx,0x4(%eax)
  104136:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104139:	8b 50 04             	mov    0x4(%eax),%edx
  10413c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10413f:	89 10                	mov    %edx,(%eax)
}
  104141:	90                   	nop
  104142:	c7 45 e0 f0 ee 11 00 	movl   $0x11eef0,-0x20(%ebp)
    return list->next == list;
  104149:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10414c:	8b 40 04             	mov    0x4(%eax),%eax
  10414f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104152:	0f 94 c0             	sete   %al
  104155:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104158:	85 c0                	test   %eax,%eax
  10415a:	75 24                	jne    104180 <basic_check+0x270>
  10415c:	c7 44 24 0c 43 7b 10 	movl   $0x107b43,0xc(%esp)
  104163:	00 
  104164:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10416b:	00 
  10416c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104173:	00 
  104174:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10417b:	e8 50 cb ff ff       	call   100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
  104180:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  104185:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104188:	c7 05 f8 ee 11 00 00 	movl   $0x0,0x11eef8
  10418f:	00 00 00 

    assert(alloc_page() == NULL);
  104192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104199:	e8 46 0c 00 00       	call   104de4 <alloc_pages>
  10419e:	85 c0                	test   %eax,%eax
  1041a0:	74 24                	je     1041c6 <basic_check+0x2b6>
  1041a2:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  1041a9:	00 
  1041aa:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1041b1:	00 
  1041b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  1041b9:	00 
  1041ba:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1041c1:	e8 0a cb ff ff       	call   100cd0 <__panic>

    free_page(p0);
  1041c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041cd:	00 
  1041ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041d1:	89 04 24             	mov    %eax,(%esp)
  1041d4:	e8 45 0c 00 00       	call   104e1e <free_pages>
    free_page(p1);
  1041d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041e0:	00 
  1041e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1041e4:	89 04 24             	mov    %eax,(%esp)
  1041e7:	e8 32 0c 00 00       	call   104e1e <free_pages>
    free_page(p2);
  1041ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041f3:	00 
  1041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041f7:	89 04 24             	mov    %eax,(%esp)
  1041fa:	e8 1f 0c 00 00       	call   104e1e <free_pages>
    assert(nr_free == 3);
  1041ff:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  104204:	83 f8 03             	cmp    $0x3,%eax
  104207:	74 24                	je     10422d <basic_check+0x31d>
  104209:	c7 44 24 0c 6f 7b 10 	movl   $0x107b6f,0xc(%esp)
  104210:	00 
  104211:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104218:	00 
  104219:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  104220:	00 
  104221:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104228:	e8 a3 ca ff ff       	call   100cd0 <__panic>

    assert((p0 = alloc_page()) != NULL);
  10422d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104234:	e8 ab 0b 00 00       	call   104de4 <alloc_pages>
  104239:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10423c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104240:	75 24                	jne    104266 <basic_check+0x356>
  104242:	c7 44 24 0c 35 7a 10 	movl   $0x107a35,0xc(%esp)
  104249:	00 
  10424a:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104251:	00 
  104252:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104259:	00 
  10425a:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104261:	e8 6a ca ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104266:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10426d:	e8 72 0b 00 00       	call   104de4 <alloc_pages>
  104272:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104279:	75 24                	jne    10429f <basic_check+0x38f>
  10427b:	c7 44 24 0c 51 7a 10 	movl   $0x107a51,0xc(%esp)
  104282:	00 
  104283:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10428a:	00 
  10428b:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  104292:	00 
  104293:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10429a:	e8 31 ca ff ff       	call   100cd0 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10429f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1042a6:	e8 39 0b 00 00       	call   104de4 <alloc_pages>
  1042ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1042ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1042b2:	75 24                	jne    1042d8 <basic_check+0x3c8>
  1042b4:	c7 44 24 0c 6d 7a 10 	movl   $0x107a6d,0xc(%esp)
  1042bb:	00 
  1042bc:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1042c3:	00 
  1042c4:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  1042cb:	00 
  1042cc:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1042d3:	e8 f8 c9 ff ff       	call   100cd0 <__panic>

    assert(alloc_page() == NULL);
  1042d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1042df:	e8 00 0b 00 00       	call   104de4 <alloc_pages>
  1042e4:	85 c0                	test   %eax,%eax
  1042e6:	74 24                	je     10430c <basic_check+0x3fc>
  1042e8:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  1042ef:	00 
  1042f0:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1042f7:	00 
  1042f8:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1042ff:	00 
  104300:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104307:	e8 c4 c9 ff ff       	call   100cd0 <__panic>

    free_page(p0);
  10430c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104313:	00 
  104314:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104317:	89 04 24             	mov    %eax,(%esp)
  10431a:	e8 ff 0a 00 00       	call   104e1e <free_pages>
  10431f:	c7 45 d8 f0 ee 11 00 	movl   $0x11eef0,-0x28(%ebp)
  104326:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104329:	8b 40 04             	mov    0x4(%eax),%eax
  10432c:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10432f:	0f 94 c0             	sete   %al
  104332:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104335:	85 c0                	test   %eax,%eax
  104337:	74 24                	je     10435d <basic_check+0x44d>
  104339:	c7 44 24 0c 7c 7b 10 	movl   $0x107b7c,0xc(%esp)
  104340:	00 
  104341:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104348:	00 
  104349:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  104350:	00 
  104351:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104358:	e8 73 c9 ff ff       	call   100cd0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  10435d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104364:	e8 7b 0a 00 00       	call   104de4 <alloc_pages>
  104369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10436c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10436f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104372:	74 24                	je     104398 <basic_check+0x488>
  104374:	c7 44 24 0c 94 7b 10 	movl   $0x107b94,0xc(%esp)
  10437b:	00 
  10437c:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104383:	00 
  104384:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  10438b:	00 
  10438c:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104393:	e8 38 c9 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  104398:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10439f:	e8 40 0a 00 00       	call   104de4 <alloc_pages>
  1043a4:	85 c0                	test   %eax,%eax
  1043a6:	74 24                	je     1043cc <basic_check+0x4bc>
  1043a8:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  1043af:	00 
  1043b0:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1043b7:	00 
  1043b8:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  1043bf:	00 
  1043c0:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1043c7:	e8 04 c9 ff ff       	call   100cd0 <__panic>

    assert(nr_free == 0);
  1043cc:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  1043d1:	85 c0                	test   %eax,%eax
  1043d3:	74 24                	je     1043f9 <basic_check+0x4e9>
  1043d5:	c7 44 24 0c ad 7b 10 	movl   $0x107bad,0xc(%esp)
  1043dc:	00 
  1043dd:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1043e4:	00 
  1043e5:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1043ec:	00 
  1043ed:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1043f4:	e8 d7 c8 ff ff       	call   100cd0 <__panic>
    free_list = free_list_store;
  1043f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043ff:	a3 f0 ee 11 00       	mov    %eax,0x11eef0
  104404:	89 15 f4 ee 11 00    	mov    %edx,0x11eef4
    nr_free = nr_free_store;
  10440a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10440d:	a3 f8 ee 11 00       	mov    %eax,0x11eef8

    free_page(p);
  104412:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104419:	00 
  10441a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10441d:	89 04 24             	mov    %eax,(%esp)
  104420:	e8 f9 09 00 00       	call   104e1e <free_pages>
    free_page(p1);
  104425:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10442c:	00 
  10442d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104430:	89 04 24             	mov    %eax,(%esp)
  104433:	e8 e6 09 00 00       	call   104e1e <free_pages>
    free_page(p2);
  104438:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10443f:	00 
  104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104443:	89 04 24             	mov    %eax,(%esp)
  104446:	e8 d3 09 00 00       	call   104e1e <free_pages>
}
  10444b:	90                   	nop
  10444c:	89 ec                	mov    %ebp,%esp
  10444e:	5d                   	pop    %ebp
  10444f:	c3                   	ret    

00104450 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104450:	55                   	push   %ebp
  104451:	89 e5                	mov    %esp,%ebp
  104453:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104459:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104460:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104467:	c7 45 ec f0 ee 11 00 	movl   $0x11eef0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10446e:	eb 6a                	jmp    1044da <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104470:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104473:	83 e8 0c             	sub    $0xc,%eax
  104476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10447c:	83 c0 04             	add    $0x4,%eax
  10447f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104486:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104489:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10448c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10448f:	0f a3 10             	bt     %edx,(%eax)
  104492:	19 c0                	sbb    %eax,%eax
  104494:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104497:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10449b:	0f 95 c0             	setne  %al
  10449e:	0f b6 c0             	movzbl %al,%eax
  1044a1:	85 c0                	test   %eax,%eax
  1044a3:	75 24                	jne    1044c9 <default_check+0x79>
  1044a5:	c7 44 24 0c ba 7b 10 	movl   $0x107bba,0xc(%esp)
  1044ac:	00 
  1044ad:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1044b4:	00 
  1044b5:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  1044bc:	00 
  1044bd:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1044c4:	e8 07 c8 ff ff       	call   100cd0 <__panic>
        count ++, total += p->property;
  1044c9:	ff 45 f4             	incl   -0xc(%ebp)
  1044cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1044cf:	8b 50 08             	mov    0x8(%eax),%edx
  1044d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044d5:	01 d0                	add    %edx,%eax
  1044d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1044da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044dd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1044e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1044e3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1044e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1044e9:	81 7d ec f0 ee 11 00 	cmpl   $0x11eef0,-0x14(%ebp)
  1044f0:	0f 85 7a ff ff ff    	jne    104470 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  1044f6:	e8 58 09 00 00       	call   104e53 <nr_free_pages>
  1044fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1044fe:	39 d0                	cmp    %edx,%eax
  104500:	74 24                	je     104526 <default_check+0xd6>
  104502:	c7 44 24 0c ca 7b 10 	movl   $0x107bca,0xc(%esp)
  104509:	00 
  10450a:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104511:	00 
  104512:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  104519:	00 
  10451a:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104521:	e8 aa c7 ff ff       	call   100cd0 <__panic>

    basic_check();
  104526:	e8 e5 f9 ff ff       	call   103f10 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10452b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104532:	e8 ad 08 00 00       	call   104de4 <alloc_pages>
  104537:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  10453a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10453e:	75 24                	jne    104564 <default_check+0x114>
  104540:	c7 44 24 0c e3 7b 10 	movl   $0x107be3,0xc(%esp)
  104547:	00 
  104548:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10454f:	00 
  104550:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104557:	00 
  104558:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10455f:	e8 6c c7 ff ff       	call   100cd0 <__panic>
    assert(!PageProperty(p0));
  104564:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104567:	83 c0 04             	add    $0x4,%eax
  10456a:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104571:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104574:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104577:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10457a:	0f a3 10             	bt     %edx,(%eax)
  10457d:	19 c0                	sbb    %eax,%eax
  10457f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104582:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104586:	0f 95 c0             	setne  %al
  104589:	0f b6 c0             	movzbl %al,%eax
  10458c:	85 c0                	test   %eax,%eax
  10458e:	74 24                	je     1045b4 <default_check+0x164>
  104590:	c7 44 24 0c ee 7b 10 	movl   $0x107bee,0xc(%esp)
  104597:	00 
  104598:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10459f:	00 
  1045a0:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  1045a7:	00 
  1045a8:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1045af:	e8 1c c7 ff ff       	call   100cd0 <__panic>

    list_entry_t free_list_store = free_list;
  1045b4:	a1 f0 ee 11 00       	mov    0x11eef0,%eax
  1045b9:	8b 15 f4 ee 11 00    	mov    0x11eef4,%edx
  1045bf:	89 45 80             	mov    %eax,-0x80(%ebp)
  1045c2:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1045c5:	c7 45 b0 f0 ee 11 00 	movl   $0x11eef0,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1045cc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045cf:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1045d2:	89 50 04             	mov    %edx,0x4(%eax)
  1045d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045d8:	8b 50 04             	mov    0x4(%eax),%edx
  1045db:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1045de:	89 10                	mov    %edx,(%eax)
}
  1045e0:	90                   	nop
  1045e1:	c7 45 b4 f0 ee 11 00 	movl   $0x11eef0,-0x4c(%ebp)
    return list->next == list;
  1045e8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1045eb:	8b 40 04             	mov    0x4(%eax),%eax
  1045ee:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  1045f1:	0f 94 c0             	sete   %al
  1045f4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1045f7:	85 c0                	test   %eax,%eax
  1045f9:	75 24                	jne    10461f <default_check+0x1cf>
  1045fb:	c7 44 24 0c 43 7b 10 	movl   $0x107b43,0xc(%esp)
  104602:	00 
  104603:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10460a:	00 
  10460b:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  104612:	00 
  104613:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10461a:	e8 b1 c6 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  10461f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104626:	e8 b9 07 00 00       	call   104de4 <alloc_pages>
  10462b:	85 c0                	test   %eax,%eax
  10462d:	74 24                	je     104653 <default_check+0x203>
  10462f:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  104636:	00 
  104637:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10463e:	00 
  10463f:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  104646:	00 
  104647:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10464e:	e8 7d c6 ff ff       	call   100cd0 <__panic>

    unsigned int nr_free_store = nr_free;
  104653:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  104658:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  10465b:	c7 05 f8 ee 11 00 00 	movl   $0x0,0x11eef8
  104662:	00 00 00 

    free_pages(p0 + 2, 3);
  104665:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104668:	83 c0 28             	add    $0x28,%eax
  10466b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104672:	00 
  104673:	89 04 24             	mov    %eax,(%esp)
  104676:	e8 a3 07 00 00       	call   104e1e <free_pages>
    assert(alloc_pages(4) == NULL);
  10467b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104682:	e8 5d 07 00 00       	call   104de4 <alloc_pages>
  104687:	85 c0                	test   %eax,%eax
  104689:	74 24                	je     1046af <default_check+0x25f>
  10468b:	c7 44 24 0c 00 7c 10 	movl   $0x107c00,0xc(%esp)
  104692:	00 
  104693:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10469a:	00 
  10469b:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  1046a2:	00 
  1046a3:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1046aa:	e8 21 c6 ff ff       	call   100cd0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1046af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046b2:	83 c0 28             	add    $0x28,%eax
  1046b5:	83 c0 04             	add    $0x4,%eax
  1046b8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1046bf:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1046c2:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1046c5:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1046c8:	0f a3 10             	bt     %edx,(%eax)
  1046cb:	19 c0                	sbb    %eax,%eax
  1046cd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1046d0:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1046d4:	0f 95 c0             	setne  %al
  1046d7:	0f b6 c0             	movzbl %al,%eax
  1046da:	85 c0                	test   %eax,%eax
  1046dc:	74 0e                	je     1046ec <default_check+0x29c>
  1046de:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046e1:	83 c0 28             	add    $0x28,%eax
  1046e4:	8b 40 08             	mov    0x8(%eax),%eax
  1046e7:	83 f8 03             	cmp    $0x3,%eax
  1046ea:	74 24                	je     104710 <default_check+0x2c0>
  1046ec:	c7 44 24 0c 18 7c 10 	movl   $0x107c18,0xc(%esp)
  1046f3:	00 
  1046f4:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1046fb:	00 
  1046fc:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  104703:	00 
  104704:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10470b:	e8 c0 c5 ff ff       	call   100cd0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  104710:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  104717:	e8 c8 06 00 00       	call   104de4 <alloc_pages>
  10471c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10471f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104723:	75 24                	jne    104749 <default_check+0x2f9>
  104725:	c7 44 24 0c 44 7c 10 	movl   $0x107c44,0xc(%esp)
  10472c:	00 
  10472d:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104734:	00 
  104735:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  10473c:	00 
  10473d:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104744:	e8 87 c5 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  104749:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104750:	e8 8f 06 00 00       	call   104de4 <alloc_pages>
  104755:	85 c0                	test   %eax,%eax
  104757:	74 24                	je     10477d <default_check+0x32d>
  104759:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  104760:	00 
  104761:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104768:	00 
  104769:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  104770:	00 
  104771:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104778:	e8 53 c5 ff ff       	call   100cd0 <__panic>
    assert(p0 + 2 == p1);
  10477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104780:	83 c0 28             	add    $0x28,%eax
  104783:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104786:	74 24                	je     1047ac <default_check+0x35c>
  104788:	c7 44 24 0c 62 7c 10 	movl   $0x107c62,0xc(%esp)
  10478f:	00 
  104790:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104797:	00 
  104798:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  10479f:	00 
  1047a0:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1047a7:	e8 24 c5 ff ff       	call   100cd0 <__panic>

    p2 = p0 + 1;
  1047ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047af:	83 c0 14             	add    $0x14,%eax
  1047b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1047b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1047bc:	00 
  1047bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047c0:	89 04 24             	mov    %eax,(%esp)
  1047c3:	e8 56 06 00 00       	call   104e1e <free_pages>
    free_pages(p1, 3);
  1047c8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1047cf:	00 
  1047d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1047d3:	89 04 24             	mov    %eax,(%esp)
  1047d6:	e8 43 06 00 00       	call   104e1e <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1047db:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047de:	83 c0 04             	add    $0x4,%eax
  1047e1:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1047e8:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1047eb:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1047ee:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1047f1:	0f a3 10             	bt     %edx,(%eax)
  1047f4:	19 c0                	sbb    %eax,%eax
  1047f6:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1047f9:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1047fd:	0f 95 c0             	setne  %al
  104800:	0f b6 c0             	movzbl %al,%eax
  104803:	85 c0                	test   %eax,%eax
  104805:	74 0b                	je     104812 <default_check+0x3c2>
  104807:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10480a:	8b 40 08             	mov    0x8(%eax),%eax
  10480d:	83 f8 01             	cmp    $0x1,%eax
  104810:	74 24                	je     104836 <default_check+0x3e6>
  104812:	c7 44 24 0c 70 7c 10 	movl   $0x107c70,0xc(%esp)
  104819:	00 
  10481a:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104821:	00 
  104822:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
  104829:	00 
  10482a:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104831:	e8 9a c4 ff ff       	call   100cd0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  104836:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104839:	83 c0 04             	add    $0x4,%eax
  10483c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  104843:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104846:	8b 45 90             	mov    -0x70(%ebp),%eax
  104849:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10484c:	0f a3 10             	bt     %edx,(%eax)
  10484f:	19 c0                	sbb    %eax,%eax
  104851:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  104854:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  104858:	0f 95 c0             	setne  %al
  10485b:	0f b6 c0             	movzbl %al,%eax
  10485e:	85 c0                	test   %eax,%eax
  104860:	74 0b                	je     10486d <default_check+0x41d>
  104862:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104865:	8b 40 08             	mov    0x8(%eax),%eax
  104868:	83 f8 03             	cmp    $0x3,%eax
  10486b:	74 24                	je     104891 <default_check+0x441>
  10486d:	c7 44 24 0c 98 7c 10 	movl   $0x107c98,0xc(%esp)
  104874:	00 
  104875:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10487c:	00 
  10487d:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  104884:	00 
  104885:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10488c:	e8 3f c4 ff ff       	call   100cd0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  104891:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104898:	e8 47 05 00 00       	call   104de4 <alloc_pages>
  10489d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1048a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048a3:	83 e8 14             	sub    $0x14,%eax
  1048a6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1048a9:	74 24                	je     1048cf <default_check+0x47f>
  1048ab:	c7 44 24 0c be 7c 10 	movl   $0x107cbe,0xc(%esp)
  1048b2:	00 
  1048b3:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1048ba:	00 
  1048bb:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  1048c2:	00 
  1048c3:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1048ca:	e8 01 c4 ff ff       	call   100cd0 <__panic>
    free_page(p0);
  1048cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1048d6:	00 
  1048d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1048da:	89 04 24             	mov    %eax,(%esp)
  1048dd:	e8 3c 05 00 00       	call   104e1e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1048e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1048e9:	e8 f6 04 00 00       	call   104de4 <alloc_pages>
  1048ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1048f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048f4:	83 c0 14             	add    $0x14,%eax
  1048f7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1048fa:	74 24                	je     104920 <default_check+0x4d0>
  1048fc:	c7 44 24 0c dc 7c 10 	movl   $0x107cdc,0xc(%esp)
  104903:	00 
  104904:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10490b:	00 
  10490c:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
  104913:	00 
  104914:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10491b:	e8 b0 c3 ff ff       	call   100cd0 <__panic>

    free_pages(p0, 2);
  104920:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  104927:	00 
  104928:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10492b:	89 04 24             	mov    %eax,(%esp)
  10492e:	e8 eb 04 00 00       	call   104e1e <free_pages>
    free_page(p2);
  104933:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10493a:	00 
  10493b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10493e:	89 04 24             	mov    %eax,(%esp)
  104941:	e8 d8 04 00 00       	call   104e1e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  104946:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10494d:	e8 92 04 00 00       	call   104de4 <alloc_pages>
  104952:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104955:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104959:	75 24                	jne    10497f <default_check+0x52f>
  10495b:	c7 44 24 0c fc 7c 10 	movl   $0x107cfc,0xc(%esp)
  104962:	00 
  104963:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10496a:	00 
  10496b:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
  104972:	00 
  104973:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  10497a:	e8 51 c3 ff ff       	call   100cd0 <__panic>
    assert(alloc_page() == NULL);
  10497f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104986:	e8 59 04 00 00       	call   104de4 <alloc_pages>
  10498b:	85 c0                	test   %eax,%eax
  10498d:	74 24                	je     1049b3 <default_check+0x563>
  10498f:	c7 44 24 0c 5a 7b 10 	movl   $0x107b5a,0xc(%esp)
  104996:	00 
  104997:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  10499e:	00 
  10499f:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
  1049a6:	00 
  1049a7:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1049ae:	e8 1d c3 ff ff       	call   100cd0 <__panic>

    assert(nr_free == 0);
  1049b3:	a1 f8 ee 11 00       	mov    0x11eef8,%eax
  1049b8:	85 c0                	test   %eax,%eax
  1049ba:	74 24                	je     1049e0 <default_check+0x590>
  1049bc:	c7 44 24 0c ad 7b 10 	movl   $0x107bad,0xc(%esp)
  1049c3:	00 
  1049c4:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  1049cb:	00 
  1049cc:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  1049d3:	00 
  1049d4:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  1049db:	e8 f0 c2 ff ff       	call   100cd0 <__panic>
    nr_free = nr_free_store;
  1049e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1049e3:	a3 f8 ee 11 00       	mov    %eax,0x11eef8

    free_list = free_list_store;
  1049e8:	8b 45 80             	mov    -0x80(%ebp),%eax
  1049eb:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1049ee:	a3 f0 ee 11 00       	mov    %eax,0x11eef0
  1049f3:	89 15 f4 ee 11 00    	mov    %edx,0x11eef4
    free_pages(p0, 5);
  1049f9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  104a00:	00 
  104a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104a04:	89 04 24             	mov    %eax,(%esp)
  104a07:	e8 12 04 00 00       	call   104e1e <free_pages>

    le = &free_list;
  104a0c:	c7 45 ec f0 ee 11 00 	movl   $0x11eef0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104a13:	eb 1c                	jmp    104a31 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
  104a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a18:	83 e8 0c             	sub    $0xc,%eax
  104a1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  104a1e:	ff 4d f4             	decl   -0xc(%ebp)
  104a21:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104a24:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104a27:	8b 48 08             	mov    0x8(%eax),%ecx
  104a2a:	89 d0                	mov    %edx,%eax
  104a2c:	29 c8                	sub    %ecx,%eax
  104a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a34:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  104a37:	8b 45 88             	mov    -0x78(%ebp),%eax
  104a3a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104a3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a40:	81 7d ec f0 ee 11 00 	cmpl   $0x11eef0,-0x14(%ebp)
  104a47:	75 cc                	jne    104a15 <default_check+0x5c5>
    }
    assert(count == 0);
  104a49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104a4d:	74 24                	je     104a73 <default_check+0x623>
  104a4f:	c7 44 24 0c 1a 7d 10 	movl   $0x107d1a,0xc(%esp)
  104a56:	00 
  104a57:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104a5e:	00 
  104a5f:	c7 44 24 04 59 01 00 	movl   $0x159,0x4(%esp)
  104a66:	00 
  104a67:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104a6e:	e8 5d c2 ff ff       	call   100cd0 <__panic>
    assert(total == 0);
  104a73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a77:	74 24                	je     104a9d <default_check+0x64d>
  104a79:	c7 44 24 0c 25 7d 10 	movl   $0x107d25,0xc(%esp)
  104a80:	00 
  104a81:	c7 44 24 08 d2 79 10 	movl   $0x1079d2,0x8(%esp)
  104a88:	00 
  104a89:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
  104a90:	00 
  104a91:	c7 04 24 e7 79 10 00 	movl   $0x1079e7,(%esp)
  104a98:	e8 33 c2 ff ff       	call   100cd0 <__panic>
}
  104a9d:	90                   	nop
  104a9e:	89 ec                	mov    %ebp,%esp
  104aa0:	5d                   	pop    %ebp
  104aa1:	c3                   	ret    

00104aa2 <page2ppn>:
page2ppn(struct Page *page) {
  104aa2:	55                   	push   %ebp
  104aa3:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104aa5:	8b 15 00 ef 11 00    	mov    0x11ef00,%edx
  104aab:	8b 45 08             	mov    0x8(%ebp),%eax
  104aae:	29 d0                	sub    %edx,%eax
  104ab0:	c1 f8 02             	sar    $0x2,%eax
  104ab3:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104ab9:	5d                   	pop    %ebp
  104aba:	c3                   	ret    

00104abb <page2pa>:
page2pa(struct Page *page) {
  104abb:	55                   	push   %ebp
  104abc:	89 e5                	mov    %esp,%ebp
  104abe:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  104ac4:	89 04 24             	mov    %eax,(%esp)
  104ac7:	e8 d6 ff ff ff       	call   104aa2 <page2ppn>
  104acc:	c1 e0 0c             	shl    $0xc,%eax
}
  104acf:	89 ec                	mov    %ebp,%esp
  104ad1:	5d                   	pop    %ebp
  104ad2:	c3                   	ret    

00104ad3 <pa2page>:
pa2page(uintptr_t pa) {
  104ad3:	55                   	push   %ebp
  104ad4:	89 e5                	mov    %esp,%ebp
  104ad6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  104adc:	c1 e8 0c             	shr    $0xc,%eax
  104adf:	89 c2                	mov    %eax,%edx
  104ae1:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  104ae6:	39 c2                	cmp    %eax,%edx
  104ae8:	72 1c                	jb     104b06 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  104aea:	c7 44 24 08 60 7d 10 	movl   $0x107d60,0x8(%esp)
  104af1:	00 
  104af2:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  104af9:	00 
  104afa:	c7 04 24 7f 7d 10 00 	movl   $0x107d7f,(%esp)
  104b01:	e8 ca c1 ff ff       	call   100cd0 <__panic>
    return &pages[PPN(pa)];
  104b06:	8b 0d 00 ef 11 00    	mov    0x11ef00,%ecx
  104b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  104b0f:	c1 e8 0c             	shr    $0xc,%eax
  104b12:	89 c2                	mov    %eax,%edx
  104b14:	89 d0                	mov    %edx,%eax
  104b16:	c1 e0 02             	shl    $0x2,%eax
  104b19:	01 d0                	add    %edx,%eax
  104b1b:	c1 e0 02             	shl    $0x2,%eax
  104b1e:	01 c8                	add    %ecx,%eax
}
  104b20:	89 ec                	mov    %ebp,%esp
  104b22:	5d                   	pop    %ebp
  104b23:	c3                   	ret    

00104b24 <page2kva>:
page2kva(struct Page *page) {
  104b24:	55                   	push   %ebp
  104b25:	89 e5                	mov    %esp,%ebp
  104b27:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  104b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  104b2d:	89 04 24             	mov    %eax,(%esp)
  104b30:	e8 86 ff ff ff       	call   104abb <page2pa>
  104b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b3b:	c1 e8 0c             	shr    $0xc,%eax
  104b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b41:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  104b46:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104b49:	72 23                	jb     104b6e <page2kva+0x4a>
  104b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104b52:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  104b59:	00 
  104b5a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  104b61:	00 
  104b62:	c7 04 24 7f 7d 10 00 	movl   $0x107d7f,(%esp)
  104b69:	e8 62 c1 ff ff       	call   100cd0 <__panic>
  104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b71:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  104b76:	89 ec                	mov    %ebp,%esp
  104b78:	5d                   	pop    %ebp
  104b79:	c3                   	ret    

00104b7a <pte2page>:
pte2page(pte_t pte) {
  104b7a:	55                   	push   %ebp
  104b7b:	89 e5                	mov    %esp,%ebp
  104b7d:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  104b80:	8b 45 08             	mov    0x8(%ebp),%eax
  104b83:	83 e0 01             	and    $0x1,%eax
  104b86:	85 c0                	test   %eax,%eax
  104b88:	75 1c                	jne    104ba6 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  104b8a:	c7 44 24 08 b4 7d 10 	movl   $0x107db4,0x8(%esp)
  104b91:	00 
  104b92:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  104b99:	00 
  104b9a:	c7 04 24 7f 7d 10 00 	movl   $0x107d7f,(%esp)
  104ba1:	e8 2a c1 ff ff       	call   100cd0 <__panic>
    return pa2page(PTE_ADDR(pte));
  104ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  104ba9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104bae:	89 04 24             	mov    %eax,(%esp)
  104bb1:	e8 1d ff ff ff       	call   104ad3 <pa2page>
}
  104bb6:	89 ec                	mov    %ebp,%esp
  104bb8:	5d                   	pop    %ebp
  104bb9:	c3                   	ret    

00104bba <pde2page>:
pde2page(pde_t pde) {
  104bba:	55                   	push   %ebp
  104bbb:	89 e5                	mov    %esp,%ebp
  104bbd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  104bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  104bc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104bc8:	89 04 24             	mov    %eax,(%esp)
  104bcb:	e8 03 ff ff ff       	call   104ad3 <pa2page>
}
  104bd0:	89 ec                	mov    %ebp,%esp
  104bd2:	5d                   	pop    %ebp
  104bd3:	c3                   	ret    

00104bd4 <page_ref>:
page_ref(struct Page *page) {
  104bd4:	55                   	push   %ebp
  104bd5:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  104bda:	8b 00                	mov    (%eax),%eax
}
  104bdc:	5d                   	pop    %ebp
  104bdd:	c3                   	ret    

00104bde <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104bde:	55                   	push   %ebp
  104bdf:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104be1:	8b 45 08             	mov    0x8(%ebp),%eax
  104be4:	8b 55 0c             	mov    0xc(%ebp),%edx
  104be7:	89 10                	mov    %edx,(%eax)
}
  104be9:	90                   	nop
  104bea:	5d                   	pop    %ebp
  104beb:	c3                   	ret    

00104bec <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  104bec:	55                   	push   %ebp
  104bed:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  104bef:	8b 45 08             	mov    0x8(%ebp),%eax
  104bf2:	8b 00                	mov    (%eax),%eax
  104bf4:	8d 50 01             	lea    0x1(%eax),%edx
  104bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  104bfa:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  104bff:	8b 00                	mov    (%eax),%eax
}
  104c01:	5d                   	pop    %ebp
  104c02:	c3                   	ret    

00104c03 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  104c03:	55                   	push   %ebp
  104c04:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  104c06:	8b 45 08             	mov    0x8(%ebp),%eax
  104c09:	8b 00                	mov    (%eax),%eax
  104c0b:	8d 50 ff             	lea    -0x1(%eax),%edx
  104c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  104c11:	89 10                	mov    %edx,(%eax)
    return page->ref;
  104c13:	8b 45 08             	mov    0x8(%ebp),%eax
  104c16:	8b 00                	mov    (%eax),%eax
}
  104c18:	5d                   	pop    %ebp
  104c19:	c3                   	ret    

00104c1a <__intr_save>:
__intr_save(void) {
  104c1a:	55                   	push   %ebp
  104c1b:	89 e5                	mov    %esp,%ebp
  104c1d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  104c20:	9c                   	pushf  
  104c21:	58                   	pop    %eax
  104c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  104c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  104c28:	25 00 02 00 00       	and    $0x200,%eax
  104c2d:	85 c0                	test   %eax,%eax
  104c2f:	74 0c                	je     104c3d <__intr_save+0x23>
        intr_disable();
  104c31:	e8 f3 ca ff ff       	call   101729 <intr_disable>
        return 1;
  104c36:	b8 01 00 00 00       	mov    $0x1,%eax
  104c3b:	eb 05                	jmp    104c42 <__intr_save+0x28>
    return 0;
  104c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104c42:	89 ec                	mov    %ebp,%esp
  104c44:	5d                   	pop    %ebp
  104c45:	c3                   	ret    

00104c46 <__intr_restore>:
__intr_restore(bool flag) {
  104c46:	55                   	push   %ebp
  104c47:	89 e5                	mov    %esp,%ebp
  104c49:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  104c4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104c50:	74 05                	je     104c57 <__intr_restore+0x11>
        intr_enable();
  104c52:	e8 ca ca ff ff       	call   101721 <intr_enable>
}
  104c57:	90                   	nop
  104c58:	89 ec                	mov    %ebp,%esp
  104c5a:	5d                   	pop    %ebp
  104c5b:	c3                   	ret    

00104c5c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  104c5c:	55                   	push   %ebp
  104c5d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  104c62:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  104c65:	b8 23 00 00 00       	mov    $0x23,%eax
  104c6a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  104c6c:	b8 23 00 00 00       	mov    $0x23,%eax
  104c71:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  104c73:	b8 10 00 00 00       	mov    $0x10,%eax
  104c78:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  104c7a:	b8 10 00 00 00       	mov    $0x10,%eax
  104c7f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  104c81:	b8 10 00 00 00       	mov    $0x10,%eax
  104c86:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  104c88:	ea 8f 4c 10 00 08 00 	ljmp   $0x8,$0x104c8f
}
  104c8f:	90                   	nop
  104c90:	5d                   	pop    %ebp
  104c91:	c3                   	ret    

00104c92 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  104c92:	55                   	push   %ebp
  104c93:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  104c95:	8b 45 08             	mov    0x8(%ebp),%eax
  104c98:	a3 24 ef 11 00       	mov    %eax,0x11ef24
}
  104c9d:	90                   	nop
  104c9e:	5d                   	pop    %ebp
  104c9f:	c3                   	ret    

00104ca0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  104ca0:	55                   	push   %ebp
  104ca1:	89 e5                	mov    %esp,%ebp
  104ca3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  104ca6:	b8 00 b0 11 00       	mov    $0x11b000,%eax
  104cab:	89 04 24             	mov    %eax,(%esp)
  104cae:	e8 df ff ff ff       	call   104c92 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  104cb3:	66 c7 05 28 ef 11 00 	movw   $0x10,0x11ef28
  104cba:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  104cbc:	66 c7 05 28 ba 11 00 	movw   $0x68,0x11ba28
  104cc3:	68 00 
  104cc5:	b8 20 ef 11 00       	mov    $0x11ef20,%eax
  104cca:	0f b7 c0             	movzwl %ax,%eax
  104ccd:	66 a3 2a ba 11 00    	mov    %ax,0x11ba2a
  104cd3:	b8 20 ef 11 00       	mov    $0x11ef20,%eax
  104cd8:	c1 e8 10             	shr    $0x10,%eax
  104cdb:	a2 2c ba 11 00       	mov    %al,0x11ba2c
  104ce0:	0f b6 05 2d ba 11 00 	movzbl 0x11ba2d,%eax
  104ce7:	24 f0                	and    $0xf0,%al
  104ce9:	0c 09                	or     $0x9,%al
  104ceb:	a2 2d ba 11 00       	mov    %al,0x11ba2d
  104cf0:	0f b6 05 2d ba 11 00 	movzbl 0x11ba2d,%eax
  104cf7:	24 ef                	and    $0xef,%al
  104cf9:	a2 2d ba 11 00       	mov    %al,0x11ba2d
  104cfe:	0f b6 05 2d ba 11 00 	movzbl 0x11ba2d,%eax
  104d05:	24 9f                	and    $0x9f,%al
  104d07:	a2 2d ba 11 00       	mov    %al,0x11ba2d
  104d0c:	0f b6 05 2d ba 11 00 	movzbl 0x11ba2d,%eax
  104d13:	0c 80                	or     $0x80,%al
  104d15:	a2 2d ba 11 00       	mov    %al,0x11ba2d
  104d1a:	0f b6 05 2e ba 11 00 	movzbl 0x11ba2e,%eax
  104d21:	24 f0                	and    $0xf0,%al
  104d23:	a2 2e ba 11 00       	mov    %al,0x11ba2e
  104d28:	0f b6 05 2e ba 11 00 	movzbl 0x11ba2e,%eax
  104d2f:	24 ef                	and    $0xef,%al
  104d31:	a2 2e ba 11 00       	mov    %al,0x11ba2e
  104d36:	0f b6 05 2e ba 11 00 	movzbl 0x11ba2e,%eax
  104d3d:	24 df                	and    $0xdf,%al
  104d3f:	a2 2e ba 11 00       	mov    %al,0x11ba2e
  104d44:	0f b6 05 2e ba 11 00 	movzbl 0x11ba2e,%eax
  104d4b:	0c 40                	or     $0x40,%al
  104d4d:	a2 2e ba 11 00       	mov    %al,0x11ba2e
  104d52:	0f b6 05 2e ba 11 00 	movzbl 0x11ba2e,%eax
  104d59:	24 7f                	and    $0x7f,%al
  104d5b:	a2 2e ba 11 00       	mov    %al,0x11ba2e
  104d60:	b8 20 ef 11 00       	mov    $0x11ef20,%eax
  104d65:	c1 e8 18             	shr    $0x18,%eax
  104d68:	a2 2f ba 11 00       	mov    %al,0x11ba2f

    // reload all segment registers
    lgdt(&gdt_pd);
  104d6d:	c7 04 24 30 ba 11 00 	movl   $0x11ba30,(%esp)
  104d74:	e8 e3 fe ff ff       	call   104c5c <lgdt>
  104d79:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  104d7f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  104d83:	0f 00 d8             	ltr    %ax
}
  104d86:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  104d87:	90                   	nop
  104d88:	89 ec                	mov    %ebp,%esp
  104d8a:	5d                   	pop    %ebp
  104d8b:	c3                   	ret    

00104d8c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  104d8c:	55                   	push   %ebp
  104d8d:	89 e5                	mov    %esp,%ebp
  104d8f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &buddy_pmm_manager;
  104d92:	c7 05 0c ef 11 00 b0 	movl   $0x1079b0,0x11ef0c
  104d99:	79 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  104d9c:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104da1:	8b 00                	mov    (%eax),%eax
  104da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  104da7:	c7 04 24 e0 7d 10 00 	movl   $0x107de0,(%esp)
  104dae:	e8 a3 b5 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  104db3:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104db8:	8b 40 04             	mov    0x4(%eax),%eax
  104dbb:	ff d0                	call   *%eax
}
  104dbd:	90                   	nop
  104dbe:	89 ec                	mov    %ebp,%esp
  104dc0:	5d                   	pop    %ebp
  104dc1:	c3                   	ret    

00104dc2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  104dc2:	55                   	push   %ebp
  104dc3:	89 e5                	mov    %esp,%ebp
  104dc5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  104dc8:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104dcd:	8b 40 08             	mov    0x8(%eax),%eax
  104dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  104dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  104dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  104dda:	89 14 24             	mov    %edx,(%esp)
  104ddd:	ff d0                	call   *%eax
}
  104ddf:	90                   	nop
  104de0:	89 ec                	mov    %ebp,%esp
  104de2:	5d                   	pop    %ebp
  104de3:	c3                   	ret    

00104de4 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  104de4:	55                   	push   %ebp
  104de5:	89 e5                	mov    %esp,%ebp
  104de7:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  104dea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  104df1:	e8 24 fe ff ff       	call   104c1a <__intr_save>
  104df6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  104df9:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104dfe:	8b 40 0c             	mov    0xc(%eax),%eax
  104e01:	8b 55 08             	mov    0x8(%ebp),%edx
  104e04:	89 14 24             	mov    %edx,(%esp)
  104e07:	ff d0                	call   *%eax
  104e09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  104e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e0f:	89 04 24             	mov    %eax,(%esp)
  104e12:	e8 2f fe ff ff       	call   104c46 <__intr_restore>
    return page;
  104e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104e1a:	89 ec                	mov    %ebp,%esp
  104e1c:	5d                   	pop    %ebp
  104e1d:	c3                   	ret    

00104e1e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104e1e:	55                   	push   %ebp
  104e1f:	89 e5                	mov    %esp,%ebp
  104e21:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  104e24:	e8 f1 fd ff ff       	call   104c1a <__intr_save>
  104e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  104e2c:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104e31:	8b 40 10             	mov    0x10(%eax),%eax
  104e34:	8b 55 0c             	mov    0xc(%ebp),%edx
  104e37:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  104e3e:	89 14 24             	mov    %edx,(%esp)
  104e41:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  104e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e46:	89 04 24             	mov    %eax,(%esp)
  104e49:	e8 f8 fd ff ff       	call   104c46 <__intr_restore>
}
  104e4e:	90                   	nop
  104e4f:	89 ec                	mov    %ebp,%esp
  104e51:	5d                   	pop    %ebp
  104e52:	c3                   	ret    

00104e53 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  104e53:	55                   	push   %ebp
  104e54:	89 e5                	mov    %esp,%ebp
  104e56:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  104e59:	e8 bc fd ff ff       	call   104c1a <__intr_save>
  104e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  104e61:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  104e66:	8b 40 14             	mov    0x14(%eax),%eax
  104e69:	ff d0                	call   *%eax
  104e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e71:	89 04 24             	mov    %eax,(%esp)
  104e74:	e8 cd fd ff ff       	call   104c46 <__intr_restore>
    return ret;
  104e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  104e7c:	89 ec                	mov    %ebp,%esp
  104e7e:	5d                   	pop    %ebp
  104e7f:	c3                   	ret    

00104e80 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  104e80:	55                   	push   %ebp
  104e81:	89 e5                	mov    %esp,%ebp
  104e83:	57                   	push   %edi
  104e84:	56                   	push   %esi
  104e85:	53                   	push   %ebx
  104e86:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  104e8c:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  104e93:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  104e9a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  104ea1:	c7 04 24 f7 7d 10 00 	movl   $0x107df7,(%esp)
  104ea8:	e8 a9 b4 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104ead:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104eb4:	e9 0c 01 00 00       	jmp    104fc5 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104eb9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104ebc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ebf:	89 d0                	mov    %edx,%eax
  104ec1:	c1 e0 02             	shl    $0x2,%eax
  104ec4:	01 d0                	add    %edx,%eax
  104ec6:	c1 e0 02             	shl    $0x2,%eax
  104ec9:	01 c8                	add    %ecx,%eax
  104ecb:	8b 50 08             	mov    0x8(%eax),%edx
  104ece:	8b 40 04             	mov    0x4(%eax),%eax
  104ed1:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104ed4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  104ed7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104edd:	89 d0                	mov    %edx,%eax
  104edf:	c1 e0 02             	shl    $0x2,%eax
  104ee2:	01 d0                	add    %edx,%eax
  104ee4:	c1 e0 02             	shl    $0x2,%eax
  104ee7:	01 c8                	add    %ecx,%eax
  104ee9:	8b 48 0c             	mov    0xc(%eax),%ecx
  104eec:	8b 58 10             	mov    0x10(%eax),%ebx
  104eef:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104ef2:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104ef5:	01 c8                	add    %ecx,%eax
  104ef7:	11 da                	adc    %ebx,%edx
  104ef9:	89 45 98             	mov    %eax,-0x68(%ebp)
  104efc:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104eff:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104f02:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104f05:	89 d0                	mov    %edx,%eax
  104f07:	c1 e0 02             	shl    $0x2,%eax
  104f0a:	01 d0                	add    %edx,%eax
  104f0c:	c1 e0 02             	shl    $0x2,%eax
  104f0f:	01 c8                	add    %ecx,%eax
  104f11:	83 c0 14             	add    $0x14,%eax
  104f14:	8b 00                	mov    (%eax),%eax
  104f16:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104f1c:	8b 45 98             	mov    -0x68(%ebp),%eax
  104f1f:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104f22:	83 c0 ff             	add    $0xffffffff,%eax
  104f25:	83 d2 ff             	adc    $0xffffffff,%edx
  104f28:	89 c6                	mov    %eax,%esi
  104f2a:	89 d7                	mov    %edx,%edi
  104f2c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104f2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104f32:	89 d0                	mov    %edx,%eax
  104f34:	c1 e0 02             	shl    $0x2,%eax
  104f37:	01 d0                	add    %edx,%eax
  104f39:	c1 e0 02             	shl    $0x2,%eax
  104f3c:	01 c8                	add    %ecx,%eax
  104f3e:	8b 48 0c             	mov    0xc(%eax),%ecx
  104f41:	8b 58 10             	mov    0x10(%eax),%ebx
  104f44:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  104f4a:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  104f4e:	89 74 24 14          	mov    %esi,0x14(%esp)
  104f52:	89 7c 24 18          	mov    %edi,0x18(%esp)
  104f56:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104f59:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104f5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f60:	89 54 24 10          	mov    %edx,0x10(%esp)
  104f64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  104f68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  104f6c:	c7 04 24 04 7e 10 00 	movl   $0x107e04,(%esp)
  104f73:	e8 de b3 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  104f78:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104f7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104f7e:	89 d0                	mov    %edx,%eax
  104f80:	c1 e0 02             	shl    $0x2,%eax
  104f83:	01 d0                	add    %edx,%eax
  104f85:	c1 e0 02             	shl    $0x2,%eax
  104f88:	01 c8                	add    %ecx,%eax
  104f8a:	83 c0 14             	add    $0x14,%eax
  104f8d:	8b 00                	mov    (%eax),%eax
  104f8f:	83 f8 01             	cmp    $0x1,%eax
  104f92:	75 2e                	jne    104fc2 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  104f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104f9a:	3b 45 98             	cmp    -0x68(%ebp),%eax
  104f9d:	89 d0                	mov    %edx,%eax
  104f9f:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  104fa2:	73 1e                	jae    104fc2 <page_init+0x142>
  104fa4:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  104fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  104fae:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  104fb1:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  104fb4:	72 0c                	jb     104fc2 <page_init+0x142>
                maxpa = end;
  104fb6:	8b 45 98             	mov    -0x68(%ebp),%eax
  104fb9:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104fbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104fbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  104fc2:	ff 45 dc             	incl   -0x24(%ebp)
  104fc5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104fc8:	8b 00                	mov    (%eax),%eax
  104fca:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104fcd:	0f 8c e6 fe ff ff    	jl     104eb9 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104fd3:	ba 00 00 00 38       	mov    $0x38000000,%edx
  104fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  104fdd:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  104fe0:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  104fe3:	73 0e                	jae    104ff3 <page_init+0x173>
        maxpa = KMEMSIZE;
  104fe5:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104fec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104ff3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104ff9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104ffd:	c1 ea 0c             	shr    $0xc,%edx
  105000:	a3 04 ef 11 00       	mov    %eax,0x11ef04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  105005:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  10500c:	b8 8c ef 11 00       	mov    $0x11ef8c,%eax
  105011:	8d 50 ff             	lea    -0x1(%eax),%edx
  105014:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105017:	01 d0                	add    %edx,%eax
  105019:	89 45 bc             	mov    %eax,-0x44(%ebp)
  10501c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10501f:	ba 00 00 00 00       	mov    $0x0,%edx
  105024:	f7 75 c0             	divl   -0x40(%ebp)
  105027:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10502a:	29 d0                	sub    %edx,%eax
  10502c:	a3 00 ef 11 00       	mov    %eax,0x11ef00

    for (i = 0; i < npage; i ++) {
  105031:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105038:	eb 2f                	jmp    105069 <page_init+0x1e9>
        SetPageReserved(pages + i);
  10503a:	8b 0d 00 ef 11 00    	mov    0x11ef00,%ecx
  105040:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105043:	89 d0                	mov    %edx,%eax
  105045:	c1 e0 02             	shl    $0x2,%eax
  105048:	01 d0                	add    %edx,%eax
  10504a:	c1 e0 02             	shl    $0x2,%eax
  10504d:	01 c8                	add    %ecx,%eax
  10504f:	83 c0 04             	add    $0x4,%eax
  105052:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  105059:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10505c:	8b 45 90             	mov    -0x70(%ebp),%eax
  10505f:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105062:	0f ab 10             	bts    %edx,(%eax)
}
  105065:	90                   	nop
    for (i = 0; i < npage; i ++) {
  105066:	ff 45 dc             	incl   -0x24(%ebp)
  105069:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10506c:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  105071:	39 c2                	cmp    %eax,%edx
  105073:	72 c5                	jb     10503a <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  105075:	8b 15 04 ef 11 00    	mov    0x11ef04,%edx
  10507b:	89 d0                	mov    %edx,%eax
  10507d:	c1 e0 02             	shl    $0x2,%eax
  105080:	01 d0                	add    %edx,%eax
  105082:	c1 e0 02             	shl    $0x2,%eax
  105085:	89 c2                	mov    %eax,%edx
  105087:	a1 00 ef 11 00       	mov    0x11ef00,%eax
  10508c:	01 d0                	add    %edx,%eax
  10508e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  105091:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  105098:	77 23                	ja     1050bd <page_init+0x23d>
  10509a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10509d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1050a1:	c7 44 24 08 34 7e 10 	movl   $0x107e34,0x8(%esp)
  1050a8:	00 
  1050a9:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  1050b0:	00 
  1050b1:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1050b8:	e8 13 bc ff ff       	call   100cd0 <__panic>
  1050bd:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1050c0:	05 00 00 00 40       	add    $0x40000000,%eax
  1050c5:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1050c8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1050cf:	e9 53 01 00 00       	jmp    105227 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1050d4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1050d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1050da:	89 d0                	mov    %edx,%eax
  1050dc:	c1 e0 02             	shl    $0x2,%eax
  1050df:	01 d0                	add    %edx,%eax
  1050e1:	c1 e0 02             	shl    $0x2,%eax
  1050e4:	01 c8                	add    %ecx,%eax
  1050e6:	8b 50 08             	mov    0x8(%eax),%edx
  1050e9:	8b 40 04             	mov    0x4(%eax),%eax
  1050ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1050ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1050f2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1050f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1050f8:	89 d0                	mov    %edx,%eax
  1050fa:	c1 e0 02             	shl    $0x2,%eax
  1050fd:	01 d0                	add    %edx,%eax
  1050ff:	c1 e0 02             	shl    $0x2,%eax
  105102:	01 c8                	add    %ecx,%eax
  105104:	8b 48 0c             	mov    0xc(%eax),%ecx
  105107:	8b 58 10             	mov    0x10(%eax),%ebx
  10510a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10510d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105110:	01 c8                	add    %ecx,%eax
  105112:	11 da                	adc    %ebx,%edx
  105114:	89 45 c8             	mov    %eax,-0x38(%ebp)
  105117:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10511a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10511d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105120:	89 d0                	mov    %edx,%eax
  105122:	c1 e0 02             	shl    $0x2,%eax
  105125:	01 d0                	add    %edx,%eax
  105127:	c1 e0 02             	shl    $0x2,%eax
  10512a:	01 c8                	add    %ecx,%eax
  10512c:	83 c0 14             	add    $0x14,%eax
  10512f:	8b 00                	mov    (%eax),%eax
  105131:	83 f8 01             	cmp    $0x1,%eax
  105134:	0f 85 ea 00 00 00    	jne    105224 <page_init+0x3a4>
            if (begin < freemem) {
  10513a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10513d:	ba 00 00 00 00       	mov    $0x0,%edx
  105142:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105145:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105148:	19 d1                	sbb    %edx,%ecx
  10514a:	73 0d                	jae    105159 <page_init+0x2d9>
                begin = freemem;
  10514c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10514f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105152:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  105159:	ba 00 00 00 38       	mov    $0x38000000,%edx
  10515e:	b8 00 00 00 00       	mov    $0x0,%eax
  105163:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  105166:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  105169:	73 0e                	jae    105179 <page_init+0x2f9>
                end = KMEMSIZE;
  10516b:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  105172:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  105179:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10517c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10517f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  105182:	89 d0                	mov    %edx,%eax
  105184:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  105187:	0f 83 97 00 00 00    	jae    105224 <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  10518d:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  105194:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105197:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10519a:	01 d0                	add    %edx,%eax
  10519c:	48                   	dec    %eax
  10519d:	89 45 ac             	mov    %eax,-0x54(%ebp)
  1051a0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1051a3:	ba 00 00 00 00       	mov    $0x0,%edx
  1051a8:	f7 75 b0             	divl   -0x50(%ebp)
  1051ab:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1051ae:	29 d0                	sub    %edx,%eax
  1051b0:	ba 00 00 00 00       	mov    $0x0,%edx
  1051b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1051b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1051bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1051be:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1051c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1051c4:	ba 00 00 00 00       	mov    $0x0,%edx
  1051c9:	89 c7                	mov    %eax,%edi
  1051cb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1051d1:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1051d4:	89 d0                	mov    %edx,%eax
  1051d6:	83 e0 00             	and    $0x0,%eax
  1051d9:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1051dc:	8b 45 80             	mov    -0x80(%ebp),%eax
  1051df:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1051e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1051e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  1051e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1051eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1051ee:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1051f1:	89 d0                	mov    %edx,%eax
  1051f3:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1051f6:	73 2c                	jae    105224 <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1051f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1051fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1051fe:	2b 45 d0             	sub    -0x30(%ebp),%eax
  105201:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  105204:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  105208:	c1 ea 0c             	shr    $0xc,%edx
  10520b:	89 c3                	mov    %eax,%ebx
  10520d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105210:	89 04 24             	mov    %eax,(%esp)
  105213:	e8 bb f8 ff ff       	call   104ad3 <pa2page>
  105218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10521c:	89 04 24             	mov    %eax,(%esp)
  10521f:	e8 9e fb ff ff       	call   104dc2 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  105224:	ff 45 dc             	incl   -0x24(%ebp)
  105227:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10522a:	8b 00                	mov    (%eax),%eax
  10522c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10522f:	0f 8c 9f fe ff ff    	jl     1050d4 <page_init+0x254>
                }
            }
        }
    }
}
  105235:	90                   	nop
  105236:	90                   	nop
  105237:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  10523d:	5b                   	pop    %ebx
  10523e:	5e                   	pop    %esi
  10523f:	5f                   	pop    %edi
  105240:	5d                   	pop    %ebp
  105241:	c3                   	ret    

00105242 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  105242:	55                   	push   %ebp
  105243:	89 e5                	mov    %esp,%ebp
  105245:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  105248:	8b 45 0c             	mov    0xc(%ebp),%eax
  10524b:	33 45 14             	xor    0x14(%ebp),%eax
  10524e:	25 ff 0f 00 00       	and    $0xfff,%eax
  105253:	85 c0                	test   %eax,%eax
  105255:	74 24                	je     10527b <boot_map_segment+0x39>
  105257:	c7 44 24 0c 66 7e 10 	movl   $0x107e66,0xc(%esp)
  10525e:	00 
  10525f:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105266:	00 
  105267:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  10526e:	00 
  10526f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105276:	e8 55 ba ff ff       	call   100cd0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10527b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  105282:	8b 45 0c             	mov    0xc(%ebp),%eax
  105285:	25 ff 0f 00 00       	and    $0xfff,%eax
  10528a:	89 c2                	mov    %eax,%edx
  10528c:	8b 45 10             	mov    0x10(%ebp),%eax
  10528f:	01 c2                	add    %eax,%edx
  105291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105294:	01 d0                	add    %edx,%eax
  105296:	48                   	dec    %eax
  105297:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10529a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10529d:	ba 00 00 00 00       	mov    $0x0,%edx
  1052a2:	f7 75 f0             	divl   -0x10(%ebp)
  1052a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052a8:	29 d0                	sub    %edx,%eax
  1052aa:	c1 e8 0c             	shr    $0xc,%eax
  1052ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1052b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052b3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1052b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1052be:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1052c1:	8b 45 14             	mov    0x14(%ebp),%eax
  1052c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1052c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1052ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1052cf:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1052d2:	eb 68                	jmp    10533c <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1052d4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1052db:	00 
  1052dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1052df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1052e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1052e6:	89 04 24             	mov    %eax,(%esp)
  1052e9:	e8 88 01 00 00       	call   105476 <get_pte>
  1052ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1052f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1052f5:	75 24                	jne    10531b <boot_map_segment+0xd9>
  1052f7:	c7 44 24 0c 92 7e 10 	movl   $0x107e92,0xc(%esp)
  1052fe:	00 
  1052ff:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105306:	00 
  105307:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  10530e:	00 
  10530f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105316:	e8 b5 b9 ff ff       	call   100cd0 <__panic>
        *ptep = pa | PTE_P | perm;
  10531b:	8b 45 14             	mov    0x14(%ebp),%eax
  10531e:	0b 45 18             	or     0x18(%ebp),%eax
  105321:	83 c8 01             	or     $0x1,%eax
  105324:	89 c2                	mov    %eax,%edx
  105326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105329:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10532b:	ff 4d f4             	decl   -0xc(%ebp)
  10532e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  105335:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10533c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105340:	75 92                	jne    1052d4 <boot_map_segment+0x92>
    }
}
  105342:	90                   	nop
  105343:	90                   	nop
  105344:	89 ec                	mov    %ebp,%esp
  105346:	5d                   	pop    %ebp
  105347:	c3                   	ret    

00105348 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  105348:	55                   	push   %ebp
  105349:	89 e5                	mov    %esp,%ebp
  10534b:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10534e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105355:	e8 8a fa ff ff       	call   104de4 <alloc_pages>
  10535a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10535d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105361:	75 1c                	jne    10537f <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  105363:	c7 44 24 08 9f 7e 10 	movl   $0x107e9f,0x8(%esp)
  10536a:	00 
  10536b:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  105372:	00 
  105373:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10537a:	e8 51 b9 ff ff       	call   100cd0 <__panic>
    }
    return page2kva(p);
  10537f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105382:	89 04 24             	mov    %eax,(%esp)
  105385:	e8 9a f7 ff ff       	call   104b24 <page2kva>
}
  10538a:	89 ec                	mov    %ebp,%esp
  10538c:	5d                   	pop    %ebp
  10538d:	c3                   	ret    

0010538e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10538e:	55                   	push   %ebp
  10538f:	89 e5                	mov    %esp,%ebp
  105391:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  105394:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105399:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10539c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1053a3:	77 23                	ja     1053c8 <pmm_init+0x3a>
  1053a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1053ac:	c7 44 24 08 34 7e 10 	movl   $0x107e34,0x8(%esp)
  1053b3:	00 
  1053b4:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  1053bb:	00 
  1053bc:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1053c3:	e8 08 b9 ff ff       	call   100cd0 <__panic>
  1053c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053cb:	05 00 00 00 40       	add    $0x40000000,%eax
  1053d0:	a3 08 ef 11 00       	mov    %eax,0x11ef08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1053d5:	e8 b2 f9 ff ff       	call   104d8c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1053da:	e8 a1 fa ff ff       	call   104e80 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1053df:	e8 5a 04 00 00       	call   10583e <check_alloc_page>

    check_pgdir();
  1053e4:	e8 76 04 00 00       	call   10585f <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1053e9:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  1053ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1053f1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1053f8:	77 23                	ja     10541d <pmm_init+0x8f>
  1053fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1053fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105401:	c7 44 24 08 34 7e 10 	movl   $0x107e34,0x8(%esp)
  105408:	00 
  105409:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  105410:	00 
  105411:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105418:	e8 b3 b8 ff ff       	call   100cd0 <__panic>
  10541d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105420:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  105426:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  10542b:	05 ac 0f 00 00       	add    $0xfac,%eax
  105430:	83 ca 03             	or     $0x3,%edx
  105433:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  105435:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  10543a:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  105441:	00 
  105442:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105449:	00 
  10544a:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  105451:	38 
  105452:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  105459:	c0 
  10545a:	89 04 24             	mov    %eax,(%esp)
  10545d:	e8 e0 fd ff ff       	call   105242 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  105462:	e8 39 f8 ff ff       	call   104ca0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  105467:	e8 91 0a 00 00       	call   105efd <check_boot_pgdir>

    print_pgdir();
  10546c:	e8 0e 0f 00 00       	call   10637f <print_pgdir>

}
  105471:	90                   	nop
  105472:	89 ec                	mov    %ebp,%esp
  105474:	5d                   	pop    %ebp
  105475:	c3                   	ret    

00105476 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  105476:	55                   	push   %ebp
  105477:	89 e5                	mov    %esp,%ebp
  105479:	83 ec 48             	sub    $0x48,%esp
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    pde_t *pdep = pgdir + PDX(la);
  10547c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10547f:	c1 e8 16             	shr    $0x16,%eax
  105482:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105489:	8b 45 08             	mov    0x8(%ebp),%eax
  10548c:	01 d0                	add    %edx,%eax
  10548e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*pdep & PTE_P) {
  105491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105494:	8b 00                	mov    (%eax),%eax
  105496:	83 e0 01             	and    $0x1,%eax
  105499:	85 c0                	test   %eax,%eax
  10549b:	74 68                	je     105505 <get_pte+0x8f>
        pte_t *ptep = (pte_t *)KADDR(*pdep & ~0x0fff) + PTX(la);
  10549d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054a0:	8b 00                	mov    (%eax),%eax
  1054a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1054a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1054aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054ad:	c1 e8 0c             	shr    $0xc,%eax
  1054b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1054b3:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  1054b8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1054bb:	72 23                	jb     1054e0 <get_pte+0x6a>
  1054bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1054c4:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  1054cb:	00 
  1054cc:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
  1054d3:	00 
  1054d4:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1054db:	e8 f0 b7 ff ff       	call   100cd0 <__panic>
  1054e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1054e3:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1054e8:	89 c2                	mov    %eax,%edx
  1054ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054ed:	c1 e8 0c             	shr    $0xc,%eax
  1054f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  1054f5:	c1 e0 02             	shl    $0x2,%eax
  1054f8:	01 d0                	add    %edx,%eax
  1054fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
        return ptep;
  1054fd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105500:	e9 10 01 00 00       	jmp    105615 <get_pte+0x19f>
    }

    struct Page *page;
    if (!create || ((page = alloc_page()) == NULL)) {
  105505:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105509:	74 15                	je     105520 <get_pte+0xaa>
  10550b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105512:	e8 cd f8 ff ff       	call   104de4 <alloc_pages>
  105517:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10551a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10551e:	75 0a                	jne    10552a <get_pte+0xb4>
        return NULL;
  105520:	b8 00 00 00 00       	mov    $0x0,%eax
  105525:	e9 eb 00 00 00       	jmp    105615 <get_pte+0x19f>
    }

    set_page_ref(page, 1);
  10552a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105531:	00 
  105532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105535:	89 04 24             	mov    %eax,(%esp)
  105538:	e8 a1 f6 ff ff       	call   104bde <set_page_ref>
    uintptr_t pa = page2pa(page) & ~0x0fff;
  10553d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105540:	89 04 24             	mov    %eax,(%esp)
  105543:	e8 73 f5 ff ff       	call   104abb <page2pa>
  105548:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10554d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memset((void *)KADDR(pa), 0, PGSIZE);
  105550:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105553:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105556:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105559:	c1 e8 0c             	shr    $0xc,%eax
  10555c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10555f:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  105564:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  105567:	72 23                	jb     10558c <get_pte+0x116>
  105569:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10556c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105570:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  105577:	00 
  105578:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
  10557f:	00 
  105580:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105587:	e8 44 b7 ff ff       	call   100cd0 <__panic>
  10558c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10558f:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105594:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10559b:	00 
  10559c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1055a3:	00 
  1055a4:	89 04 24             	mov    %eax,(%esp)
  1055a7:	e8 d8 18 00 00       	call   106e84 <memset>
    *pdep = pa | PTE_P | PTE_W | PTE_U;
  1055ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055af:	83 c8 07             	or     $0x7,%eax
  1055b2:	89 c2                	mov    %eax,%edx
  1055b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055b7:	89 10                	mov    %edx,(%eax)
    pte_t *ptep = (pte_t *)KADDR(pa) + PTX(la);
  1055b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1055bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1055bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055c2:	c1 e8 0c             	shr    $0xc,%eax
  1055c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1055c8:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  1055cd:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1055d0:	72 23                	jb     1055f5 <get_pte+0x17f>
  1055d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1055d9:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  1055e0:	00 
  1055e1:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
  1055e8:	00 
  1055e9:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1055f0:	e8 db b6 ff ff       	call   100cd0 <__panic>
  1055f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055f8:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1055fd:	89 c2                	mov    %eax,%edx
  1055ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105602:	c1 e8 0c             	shr    $0xc,%eax
  105605:	25 ff 03 00 00       	and    $0x3ff,%eax
  10560a:	c1 e0 02             	shl    $0x2,%eax
  10560d:	01 d0                	add    %edx,%eax
  10560f:	89 45 d8             	mov    %eax,-0x28(%ebp)

    return ptep;
  105612:	8b 45 d8             	mov    -0x28(%ebp),%eax
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  105615:	89 ec                	mov    %ebp,%esp
  105617:	5d                   	pop    %ebp
  105618:	c3                   	ret    

00105619 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  105619:	55                   	push   %ebp
  10561a:	89 e5                	mov    %esp,%ebp
  10561c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10561f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105626:	00 
  105627:	8b 45 0c             	mov    0xc(%ebp),%eax
  10562a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10562e:	8b 45 08             	mov    0x8(%ebp),%eax
  105631:	89 04 24             	mov    %eax,(%esp)
  105634:	e8 3d fe ff ff       	call   105476 <get_pte>
  105639:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10563c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105640:	74 08                	je     10564a <get_page+0x31>
        *ptep_store = ptep;
  105642:	8b 45 10             	mov    0x10(%ebp),%eax
  105645:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105648:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10564a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10564e:	74 1b                	je     10566b <get_page+0x52>
  105650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105653:	8b 00                	mov    (%eax),%eax
  105655:	83 e0 01             	and    $0x1,%eax
  105658:	85 c0                	test   %eax,%eax
  10565a:	74 0f                	je     10566b <get_page+0x52>
        return pte2page(*ptep);
  10565c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10565f:	8b 00                	mov    (%eax),%eax
  105661:	89 04 24             	mov    %eax,(%esp)
  105664:	e8 11 f5 ff ff       	call   104b7a <pte2page>
  105669:	eb 05                	jmp    105670 <get_page+0x57>
    }
    return NULL;
  10566b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105670:	89 ec                	mov    %ebp,%esp
  105672:	5d                   	pop    %ebp
  105673:	c3                   	ret    

00105674 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  105674:	55                   	push   %ebp
  105675:	89 e5                	mov    %esp,%ebp
  105677:	83 ec 28             	sub    $0x28,%esp
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    if (*ptep & PTE_P) {
  10567a:	8b 45 10             	mov    0x10(%ebp),%eax
  10567d:	8b 00                	mov    (%eax),%eax
  10567f:	83 e0 01             	and    $0x1,%eax
  105682:	85 c0                	test   %eax,%eax
  105684:	74 52                	je     1056d8 <page_remove_pte+0x64>
        struct Page *page = pa2page(*ptep & ~0x0fff);
  105686:	8b 45 10             	mov    0x10(%ebp),%eax
  105689:	8b 00                	mov    (%eax),%eax
  10568b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105690:	89 04 24             	mov    %eax,(%esp)
  105693:	e8 3b f4 ff ff       	call   104ad3 <pa2page>
  105698:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  10569b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10569e:	89 04 24             	mov    %eax,(%esp)
  1056a1:	e8 5d f5 ff ff       	call   104c03 <page_ref_dec>
  1056a6:	85 c0                	test   %eax,%eax
  1056a8:	75 13                	jne    1056bd <page_remove_pte+0x49>
            free_page(page);
  1056aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1056b1:	00 
  1056b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056b5:	89 04 24             	mov    %eax,(%esp)
  1056b8:	e8 61 f7 ff ff       	call   104e1e <free_pages>
        }
        *ptep = 0;
  1056bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1056c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  1056c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1056d0:	89 04 24             	mov    %eax,(%esp)
  1056d3:	e8 07 01 00 00       	call   1057df <tlb_invalidate>
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  1056d8:	90                   	nop
  1056d9:	89 ec                	mov    %ebp,%esp
  1056db:	5d                   	pop    %ebp
  1056dc:	c3                   	ret    

001056dd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1056dd:	55                   	push   %ebp
  1056de:	89 e5                	mov    %esp,%ebp
  1056e0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1056e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1056ea:	00 
  1056eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f5:	89 04 24             	mov    %eax,(%esp)
  1056f8:	e8 79 fd ff ff       	call   105476 <get_pte>
  1056fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  105700:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105704:	74 19                	je     10571f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  105706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105709:	89 44 24 08          	mov    %eax,0x8(%esp)
  10570d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105710:	89 44 24 04          	mov    %eax,0x4(%esp)
  105714:	8b 45 08             	mov    0x8(%ebp),%eax
  105717:	89 04 24             	mov    %eax,(%esp)
  10571a:	e8 55 ff ff ff       	call   105674 <page_remove_pte>
    }
}
  10571f:	90                   	nop
  105720:	89 ec                	mov    %ebp,%esp
  105722:	5d                   	pop    %ebp
  105723:	c3                   	ret    

00105724 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  105724:	55                   	push   %ebp
  105725:	89 e5                	mov    %esp,%ebp
  105727:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10572a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  105731:	00 
  105732:	8b 45 10             	mov    0x10(%ebp),%eax
  105735:	89 44 24 04          	mov    %eax,0x4(%esp)
  105739:	8b 45 08             	mov    0x8(%ebp),%eax
  10573c:	89 04 24             	mov    %eax,(%esp)
  10573f:	e8 32 fd ff ff       	call   105476 <get_pte>
  105744:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  105747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10574b:	75 0a                	jne    105757 <page_insert+0x33>
        return -E_NO_MEM;
  10574d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  105752:	e9 84 00 00 00       	jmp    1057db <page_insert+0xb7>
    }
    page_ref_inc(page);
  105757:	8b 45 0c             	mov    0xc(%ebp),%eax
  10575a:	89 04 24             	mov    %eax,(%esp)
  10575d:	e8 8a f4 ff ff       	call   104bec <page_ref_inc>
    if (*ptep & PTE_P) {
  105762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105765:	8b 00                	mov    (%eax),%eax
  105767:	83 e0 01             	and    $0x1,%eax
  10576a:	85 c0                	test   %eax,%eax
  10576c:	74 3e                	je     1057ac <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10576e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105771:	8b 00                	mov    (%eax),%eax
  105773:	89 04 24             	mov    %eax,(%esp)
  105776:	e8 ff f3 ff ff       	call   104b7a <pte2page>
  10577b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10577e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105781:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105784:	75 0d                	jne    105793 <page_insert+0x6f>
            page_ref_dec(page);
  105786:	8b 45 0c             	mov    0xc(%ebp),%eax
  105789:	89 04 24             	mov    %eax,(%esp)
  10578c:	e8 72 f4 ff ff       	call   104c03 <page_ref_dec>
  105791:	eb 19                	jmp    1057ac <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105796:	89 44 24 08          	mov    %eax,0x8(%esp)
  10579a:	8b 45 10             	mov    0x10(%ebp),%eax
  10579d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a4:	89 04 24             	mov    %eax,(%esp)
  1057a7:	e8 c8 fe ff ff       	call   105674 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1057ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057af:	89 04 24             	mov    %eax,(%esp)
  1057b2:	e8 04 f3 ff ff       	call   104abb <page2pa>
  1057b7:	0b 45 14             	or     0x14(%ebp),%eax
  1057ba:	83 c8 01             	or     $0x1,%eax
  1057bd:	89 c2                	mov    %eax,%edx
  1057bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1057c2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1057c4:	8b 45 10             	mov    0x10(%ebp),%eax
  1057c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ce:	89 04 24             	mov    %eax,(%esp)
  1057d1:	e8 09 00 00 00       	call   1057df <tlb_invalidate>
    return 0;
  1057d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1057db:	89 ec                	mov    %ebp,%esp
  1057dd:	5d                   	pop    %ebp
  1057de:	c3                   	ret    

001057df <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1057df:	55                   	push   %ebp
  1057e0:	89 e5                	mov    %esp,%ebp
  1057e2:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1057e5:	0f 20 d8             	mov    %cr3,%eax
  1057e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1057eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1057ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1057f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057f4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1057fb:	77 23                	ja     105820 <tlb_invalidate+0x41>
  1057fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105800:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105804:	c7 44 24 08 34 7e 10 	movl   $0x107e34,0x8(%esp)
  10580b:	00 
  10580c:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  105813:	00 
  105814:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10581b:	e8 b0 b4 ff ff       	call   100cd0 <__panic>
  105820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105823:	05 00 00 00 40       	add    $0x40000000,%eax
  105828:	39 d0                	cmp    %edx,%eax
  10582a:	75 0d                	jne    105839 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  10582c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10582f:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  105832:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105835:	0f 01 38             	invlpg (%eax)
}
  105838:	90                   	nop
    }
}
  105839:	90                   	nop
  10583a:	89 ec                	mov    %ebp,%esp
  10583c:	5d                   	pop    %ebp
  10583d:	c3                   	ret    

0010583e <check_alloc_page>:

static void
check_alloc_page(void) {
  10583e:	55                   	push   %ebp
  10583f:	89 e5                	mov    %esp,%ebp
  105841:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  105844:	a1 0c ef 11 00       	mov    0x11ef0c,%eax
  105849:	8b 40 18             	mov    0x18(%eax),%eax
  10584c:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  10584e:	c7 04 24 b8 7e 10 00 	movl   $0x107eb8,(%esp)
  105855:	e8 fc aa ff ff       	call   100356 <cprintf>
}
  10585a:	90                   	nop
  10585b:	89 ec                	mov    %ebp,%esp
  10585d:	5d                   	pop    %ebp
  10585e:	c3                   	ret    

0010585f <check_pgdir>:

static void
check_pgdir(void) {
  10585f:	55                   	push   %ebp
  105860:	89 e5                	mov    %esp,%ebp
  105862:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  105865:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  10586a:	3d 00 80 03 00       	cmp    $0x38000,%eax
  10586f:	76 24                	jbe    105895 <check_pgdir+0x36>
  105871:	c7 44 24 0c d7 7e 10 	movl   $0x107ed7,0xc(%esp)
  105878:	00 
  105879:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105880:	00 
  105881:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  105888:	00 
  105889:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105890:	e8 3b b4 ff ff       	call   100cd0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  105895:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  10589a:	85 c0                	test   %eax,%eax
  10589c:	74 0e                	je     1058ac <check_pgdir+0x4d>
  10589e:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  1058a3:	25 ff 0f 00 00       	and    $0xfff,%eax
  1058a8:	85 c0                	test   %eax,%eax
  1058aa:	74 24                	je     1058d0 <check_pgdir+0x71>
  1058ac:	c7 44 24 0c f4 7e 10 	movl   $0x107ef4,0xc(%esp)
  1058b3:	00 
  1058b4:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  1058bb:	00 
  1058bc:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  1058c3:	00 
  1058c4:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1058cb:	e8 00 b4 ff ff       	call   100cd0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1058d0:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  1058d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1058dc:	00 
  1058dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1058e4:	00 
  1058e5:	89 04 24             	mov    %eax,(%esp)
  1058e8:	e8 2c fd ff ff       	call   105619 <get_page>
  1058ed:	85 c0                	test   %eax,%eax
  1058ef:	74 24                	je     105915 <check_pgdir+0xb6>
  1058f1:	c7 44 24 0c 2c 7f 10 	movl   $0x107f2c,0xc(%esp)
  1058f8:	00 
  1058f9:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105900:	00 
  105901:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  105908:	00 
  105909:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105910:	e8 bb b3 ff ff       	call   100cd0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  105915:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10591c:	e8 c3 f4 ff ff       	call   104de4 <alloc_pages>
  105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  105924:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105929:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105930:	00 
  105931:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105938:	00 
  105939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10593c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105940:	89 04 24             	mov    %eax,(%esp)
  105943:	e8 dc fd ff ff       	call   105724 <page_insert>
  105948:	85 c0                	test   %eax,%eax
  10594a:	74 24                	je     105970 <check_pgdir+0x111>
  10594c:	c7 44 24 0c 54 7f 10 	movl   $0x107f54,0xc(%esp)
  105953:	00 
  105954:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  10595b:	00 
  10595c:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  105963:	00 
  105964:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10596b:	e8 60 b3 ff ff       	call   100cd0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  105970:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105975:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10597c:	00 
  10597d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105984:	00 
  105985:	89 04 24             	mov    %eax,(%esp)
  105988:	e8 e9 fa ff ff       	call   105476 <get_pte>
  10598d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105990:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105994:	75 24                	jne    1059ba <check_pgdir+0x15b>
  105996:	c7 44 24 0c 80 7f 10 	movl   $0x107f80,0xc(%esp)
  10599d:	00 
  10599e:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  1059a5:	00 
  1059a6:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  1059ad:	00 
  1059ae:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1059b5:	e8 16 b3 ff ff       	call   100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
  1059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059bd:	8b 00                	mov    (%eax),%eax
  1059bf:	89 04 24             	mov    %eax,(%esp)
  1059c2:	e8 b3 f1 ff ff       	call   104b7a <pte2page>
  1059c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1059ca:	74 24                	je     1059f0 <check_pgdir+0x191>
  1059cc:	c7 44 24 0c ad 7f 10 	movl   $0x107fad,0xc(%esp)
  1059d3:	00 
  1059d4:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  1059db:	00 
  1059dc:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  1059e3:	00 
  1059e4:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1059eb:	e8 e0 b2 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p1) == 1);
  1059f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059f3:	89 04 24             	mov    %eax,(%esp)
  1059f6:	e8 d9 f1 ff ff       	call   104bd4 <page_ref>
  1059fb:	83 f8 01             	cmp    $0x1,%eax
  1059fe:	74 24                	je     105a24 <check_pgdir+0x1c5>
  105a00:	c7 44 24 0c c3 7f 10 	movl   $0x107fc3,0xc(%esp)
  105a07:	00 
  105a08:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105a0f:	00 
  105a10:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  105a17:	00 
  105a18:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105a1f:	e8 ac b2 ff ff       	call   100cd0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  105a24:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105a29:	8b 00                	mov    (%eax),%eax
  105a2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a36:	c1 e8 0c             	shr    $0xc,%eax
  105a39:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a3c:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  105a41:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105a44:	72 23                	jb     105a69 <check_pgdir+0x20a>
  105a46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a4d:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  105a54:	00 
  105a55:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  105a5c:	00 
  105a5d:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105a64:	e8 67 b2 ff ff       	call   100cd0 <__panic>
  105a69:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a6c:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105a71:	83 c0 04             	add    $0x4,%eax
  105a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  105a77:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105a7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105a83:	00 
  105a84:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105a8b:	00 
  105a8c:	89 04 24             	mov    %eax,(%esp)
  105a8f:	e8 e2 f9 ff ff       	call   105476 <get_pte>
  105a94:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  105a97:	74 24                	je     105abd <check_pgdir+0x25e>
  105a99:	c7 44 24 0c d8 7f 10 	movl   $0x107fd8,0xc(%esp)
  105aa0:	00 
  105aa1:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105aa8:	00 
  105aa9:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  105ab0:	00 
  105ab1:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105ab8:	e8 13 b2 ff ff       	call   100cd0 <__panic>

    p2 = alloc_page();
  105abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105ac4:	e8 1b f3 ff ff       	call   104de4 <alloc_pages>
  105ac9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  105acc:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105ad1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  105ad8:	00 
  105ad9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105ae0:	00 
  105ae1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ae8:	89 04 24             	mov    %eax,(%esp)
  105aeb:	e8 34 fc ff ff       	call   105724 <page_insert>
  105af0:	85 c0                	test   %eax,%eax
  105af2:	74 24                	je     105b18 <check_pgdir+0x2b9>
  105af4:	c7 44 24 0c 00 80 10 	movl   $0x108000,0xc(%esp)
  105afb:	00 
  105afc:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105b03:	00 
  105b04:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  105b0b:	00 
  105b0c:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105b13:	e8 b8 b1 ff ff       	call   100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  105b18:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105b1d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105b24:	00 
  105b25:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105b2c:	00 
  105b2d:	89 04 24             	mov    %eax,(%esp)
  105b30:	e8 41 f9 ff ff       	call   105476 <get_pte>
  105b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105b3c:	75 24                	jne    105b62 <check_pgdir+0x303>
  105b3e:	c7 44 24 0c 38 80 10 	movl   $0x108038,0xc(%esp)
  105b45:	00 
  105b46:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105b4d:	00 
  105b4e:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  105b55:	00 
  105b56:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105b5d:	e8 6e b1 ff ff       	call   100cd0 <__panic>
    assert(*ptep & PTE_U);
  105b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b65:	8b 00                	mov    (%eax),%eax
  105b67:	83 e0 04             	and    $0x4,%eax
  105b6a:	85 c0                	test   %eax,%eax
  105b6c:	75 24                	jne    105b92 <check_pgdir+0x333>
  105b6e:	c7 44 24 0c 68 80 10 	movl   $0x108068,0xc(%esp)
  105b75:	00 
  105b76:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105b7d:	00 
  105b7e:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  105b85:	00 
  105b86:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105b8d:	e8 3e b1 ff ff       	call   100cd0 <__panic>
    assert(*ptep & PTE_W);
  105b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b95:	8b 00                	mov    (%eax),%eax
  105b97:	83 e0 02             	and    $0x2,%eax
  105b9a:	85 c0                	test   %eax,%eax
  105b9c:	75 24                	jne    105bc2 <check_pgdir+0x363>
  105b9e:	c7 44 24 0c 76 80 10 	movl   $0x108076,0xc(%esp)
  105ba5:	00 
  105ba6:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105bad:	00 
  105bae:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  105bb5:	00 
  105bb6:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105bbd:	e8 0e b1 ff ff       	call   100cd0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  105bc2:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105bc7:	8b 00                	mov    (%eax),%eax
  105bc9:	83 e0 04             	and    $0x4,%eax
  105bcc:	85 c0                	test   %eax,%eax
  105bce:	75 24                	jne    105bf4 <check_pgdir+0x395>
  105bd0:	c7 44 24 0c 84 80 10 	movl   $0x108084,0xc(%esp)
  105bd7:	00 
  105bd8:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105bdf:	00 
  105be0:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  105be7:	00 
  105be8:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105bef:	e8 dc b0 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 1);
  105bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bf7:	89 04 24             	mov    %eax,(%esp)
  105bfa:	e8 d5 ef ff ff       	call   104bd4 <page_ref>
  105bff:	83 f8 01             	cmp    $0x1,%eax
  105c02:	74 24                	je     105c28 <check_pgdir+0x3c9>
  105c04:	c7 44 24 0c 9a 80 10 	movl   $0x10809a,0xc(%esp)
  105c0b:	00 
  105c0c:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105c13:	00 
  105c14:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  105c1b:	00 
  105c1c:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105c23:	e8 a8 b0 ff ff       	call   100cd0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  105c28:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105c2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  105c34:	00 
  105c35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  105c3c:	00 
  105c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c40:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c44:	89 04 24             	mov    %eax,(%esp)
  105c47:	e8 d8 fa ff ff       	call   105724 <page_insert>
  105c4c:	85 c0                	test   %eax,%eax
  105c4e:	74 24                	je     105c74 <check_pgdir+0x415>
  105c50:	c7 44 24 0c ac 80 10 	movl   $0x1080ac,0xc(%esp)
  105c57:	00 
  105c58:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105c5f:	00 
  105c60:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  105c67:	00 
  105c68:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105c6f:	e8 5c b0 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p1) == 2);
  105c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c77:	89 04 24             	mov    %eax,(%esp)
  105c7a:	e8 55 ef ff ff       	call   104bd4 <page_ref>
  105c7f:	83 f8 02             	cmp    $0x2,%eax
  105c82:	74 24                	je     105ca8 <check_pgdir+0x449>
  105c84:	c7 44 24 0c d8 80 10 	movl   $0x1080d8,0xc(%esp)
  105c8b:	00 
  105c8c:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105c93:	00 
  105c94:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  105c9b:	00 
  105c9c:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105ca3:	e8 28 b0 ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  105ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105cab:	89 04 24             	mov    %eax,(%esp)
  105cae:	e8 21 ef ff ff       	call   104bd4 <page_ref>
  105cb3:	85 c0                	test   %eax,%eax
  105cb5:	74 24                	je     105cdb <check_pgdir+0x47c>
  105cb7:	c7 44 24 0c ea 80 10 	movl   $0x1080ea,0xc(%esp)
  105cbe:	00 
  105cbf:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105cc6:	00 
  105cc7:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  105cce:	00 
  105ccf:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105cd6:	e8 f5 af ff ff       	call   100cd0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  105cdb:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105ce7:	00 
  105ce8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105cef:	00 
  105cf0:	89 04 24             	mov    %eax,(%esp)
  105cf3:	e8 7e f7 ff ff       	call   105476 <get_pte>
  105cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105cff:	75 24                	jne    105d25 <check_pgdir+0x4c6>
  105d01:	c7 44 24 0c 38 80 10 	movl   $0x108038,0xc(%esp)
  105d08:	00 
  105d09:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105d10:	00 
  105d11:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  105d18:	00 
  105d19:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105d20:	e8 ab af ff ff       	call   100cd0 <__panic>
    assert(pte2page(*ptep) == p1);
  105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d28:	8b 00                	mov    (%eax),%eax
  105d2a:	89 04 24             	mov    %eax,(%esp)
  105d2d:	e8 48 ee ff ff       	call   104b7a <pte2page>
  105d32:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  105d35:	74 24                	je     105d5b <check_pgdir+0x4fc>
  105d37:	c7 44 24 0c ad 7f 10 	movl   $0x107fad,0xc(%esp)
  105d3e:	00 
  105d3f:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105d46:	00 
  105d47:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  105d4e:	00 
  105d4f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105d56:	e8 75 af ff ff       	call   100cd0 <__panic>
    assert((*ptep & PTE_U) == 0);
  105d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d5e:	8b 00                	mov    (%eax),%eax
  105d60:	83 e0 04             	and    $0x4,%eax
  105d63:	85 c0                	test   %eax,%eax
  105d65:	74 24                	je     105d8b <check_pgdir+0x52c>
  105d67:	c7 44 24 0c fc 80 10 	movl   $0x1080fc,0xc(%esp)
  105d6e:	00 
  105d6f:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105d76:	00 
  105d77:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  105d7e:	00 
  105d7f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105d86:	e8 45 af ff ff       	call   100cd0 <__panic>

    page_remove(boot_pgdir, 0x0);
  105d8b:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105d90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105d97:	00 
  105d98:	89 04 24             	mov    %eax,(%esp)
  105d9b:	e8 3d f9 ff ff       	call   1056dd <page_remove>
    assert(page_ref(p1) == 1);
  105da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105da3:	89 04 24             	mov    %eax,(%esp)
  105da6:	e8 29 ee ff ff       	call   104bd4 <page_ref>
  105dab:	83 f8 01             	cmp    $0x1,%eax
  105dae:	74 24                	je     105dd4 <check_pgdir+0x575>
  105db0:	c7 44 24 0c c3 7f 10 	movl   $0x107fc3,0xc(%esp)
  105db7:	00 
  105db8:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105dbf:	00 
  105dc0:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  105dc7:	00 
  105dc8:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105dcf:	e8 fc ae ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  105dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105dd7:	89 04 24             	mov    %eax,(%esp)
  105dda:	e8 f5 ed ff ff       	call   104bd4 <page_ref>
  105ddf:	85 c0                	test   %eax,%eax
  105de1:	74 24                	je     105e07 <check_pgdir+0x5a8>
  105de3:	c7 44 24 0c ea 80 10 	movl   $0x1080ea,0xc(%esp)
  105dea:	00 
  105deb:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105df2:	00 
  105df3:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  105dfa:	00 
  105dfb:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105e02:	e8 c9 ae ff ff       	call   100cd0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  105e07:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105e0c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105e13:	00 
  105e14:	89 04 24             	mov    %eax,(%esp)
  105e17:	e8 c1 f8 ff ff       	call   1056dd <page_remove>
    assert(page_ref(p1) == 0);
  105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e1f:	89 04 24             	mov    %eax,(%esp)
  105e22:	e8 ad ed ff ff       	call   104bd4 <page_ref>
  105e27:	85 c0                	test   %eax,%eax
  105e29:	74 24                	je     105e4f <check_pgdir+0x5f0>
  105e2b:	c7 44 24 0c 11 81 10 	movl   $0x108111,0xc(%esp)
  105e32:	00 
  105e33:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105e3a:	00 
  105e3b:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  105e42:	00 
  105e43:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105e4a:	e8 81 ae ff ff       	call   100cd0 <__panic>
    assert(page_ref(p2) == 0);
  105e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e52:	89 04 24             	mov    %eax,(%esp)
  105e55:	e8 7a ed ff ff       	call   104bd4 <page_ref>
  105e5a:	85 c0                	test   %eax,%eax
  105e5c:	74 24                	je     105e82 <check_pgdir+0x623>
  105e5e:	c7 44 24 0c ea 80 10 	movl   $0x1080ea,0xc(%esp)
  105e65:	00 
  105e66:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105e6d:	00 
  105e6e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  105e75:	00 
  105e76:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105e7d:	e8 4e ae ff ff       	call   100cd0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  105e82:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105e87:	8b 00                	mov    (%eax),%eax
  105e89:	89 04 24             	mov    %eax,(%esp)
  105e8c:	e8 29 ed ff ff       	call   104bba <pde2page>
  105e91:	89 04 24             	mov    %eax,(%esp)
  105e94:	e8 3b ed ff ff       	call   104bd4 <page_ref>
  105e99:	83 f8 01             	cmp    $0x1,%eax
  105e9c:	74 24                	je     105ec2 <check_pgdir+0x663>
  105e9e:	c7 44 24 0c 24 81 10 	movl   $0x108124,0xc(%esp)
  105ea5:	00 
  105ea6:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105ead:	00 
  105eae:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  105eb5:	00 
  105eb6:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105ebd:	e8 0e ae ff ff       	call   100cd0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  105ec2:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105ec7:	8b 00                	mov    (%eax),%eax
  105ec9:	89 04 24             	mov    %eax,(%esp)
  105ecc:	e8 e9 ec ff ff       	call   104bba <pde2page>
  105ed1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105ed8:	00 
  105ed9:	89 04 24             	mov    %eax,(%esp)
  105edc:	e8 3d ef ff ff       	call   104e1e <free_pages>
    boot_pgdir[0] = 0;
  105ee1:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105ee6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  105eec:	c7 04 24 4b 81 10 00 	movl   $0x10814b,(%esp)
  105ef3:	e8 5e a4 ff ff       	call   100356 <cprintf>
}
  105ef8:	90                   	nop
  105ef9:	89 ec                	mov    %ebp,%esp
  105efb:	5d                   	pop    %ebp
  105efc:	c3                   	ret    

00105efd <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  105efd:	55                   	push   %ebp
  105efe:	89 e5                	mov    %esp,%ebp
  105f00:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  105f03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105f0a:	e9 ca 00 00 00       	jmp    105fd9 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f18:	c1 e8 0c             	shr    $0xc,%eax
  105f1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105f1e:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  105f23:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105f26:	72 23                	jb     105f4b <check_boot_pgdir+0x4e>
  105f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f2f:	c7 44 24 08 90 7d 10 	movl   $0x107d90,0x8(%esp)
  105f36:	00 
  105f37:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  105f3e:	00 
  105f3f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105f46:	e8 85 ad ff ff       	call   100cd0 <__panic>
  105f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f4e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105f53:	89 c2                	mov    %eax,%edx
  105f55:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  105f61:	00 
  105f62:	89 54 24 04          	mov    %edx,0x4(%esp)
  105f66:	89 04 24             	mov    %eax,(%esp)
  105f69:	e8 08 f5 ff ff       	call   105476 <get_pte>
  105f6e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105f71:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105f75:	75 24                	jne    105f9b <check_boot_pgdir+0x9e>
  105f77:	c7 44 24 0c 68 81 10 	movl   $0x108168,0xc(%esp)
  105f7e:	00 
  105f7f:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105f86:	00 
  105f87:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  105f8e:	00 
  105f8f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105f96:	e8 35 ad ff ff       	call   100cd0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  105f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f9e:	8b 00                	mov    (%eax),%eax
  105fa0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105fa5:	89 c2                	mov    %eax,%edx
  105fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105faa:	39 c2                	cmp    %eax,%edx
  105fac:	74 24                	je     105fd2 <check_boot_pgdir+0xd5>
  105fae:	c7 44 24 0c a5 81 10 	movl   $0x1081a5,0xc(%esp)
  105fb5:	00 
  105fb6:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  105fbd:	00 
  105fbe:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  105fc5:	00 
  105fc6:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  105fcd:	e8 fe ac ff ff       	call   100cd0 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  105fd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  105fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fdc:	a1 04 ef 11 00       	mov    0x11ef04,%eax
  105fe1:	39 c2                	cmp    %eax,%edx
  105fe3:	0f 82 26 ff ff ff    	jb     105f0f <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  105fe9:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  105fee:	05 ac 0f 00 00       	add    $0xfac,%eax
  105ff3:	8b 00                	mov    (%eax),%eax
  105ff5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105ffa:	89 c2                	mov    %eax,%edx
  105ffc:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  106001:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106004:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10600b:	77 23                	ja     106030 <check_boot_pgdir+0x133>
  10600d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106010:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106014:	c7 44 24 08 34 7e 10 	movl   $0x107e34,0x8(%esp)
  10601b:	00 
  10601c:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  106023:	00 
  106024:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10602b:	e8 a0 ac ff ff       	call   100cd0 <__panic>
  106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106033:	05 00 00 00 40       	add    $0x40000000,%eax
  106038:	39 d0                	cmp    %edx,%eax
  10603a:	74 24                	je     106060 <check_boot_pgdir+0x163>
  10603c:	c7 44 24 0c bc 81 10 	movl   $0x1081bc,0xc(%esp)
  106043:	00 
  106044:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  10604b:	00 
  10604c:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  106053:	00 
  106054:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10605b:	e8 70 ac ff ff       	call   100cd0 <__panic>

    assert(boot_pgdir[0] == 0);
  106060:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  106065:	8b 00                	mov    (%eax),%eax
  106067:	85 c0                	test   %eax,%eax
  106069:	74 24                	je     10608f <check_boot_pgdir+0x192>
  10606b:	c7 44 24 0c f0 81 10 	movl   $0x1081f0,0xc(%esp)
  106072:	00 
  106073:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  10607a:	00 
  10607b:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  106082:	00 
  106083:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  10608a:	e8 41 ac ff ff       	call   100cd0 <__panic>

    struct Page *p;
    p = alloc_page();
  10608f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  106096:	e8 49 ed ff ff       	call   104de4 <alloc_pages>
  10609b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10609e:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  1060a3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1060aa:	00 
  1060ab:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  1060b2:	00 
  1060b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1060b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1060ba:	89 04 24             	mov    %eax,(%esp)
  1060bd:	e8 62 f6 ff ff       	call   105724 <page_insert>
  1060c2:	85 c0                	test   %eax,%eax
  1060c4:	74 24                	je     1060ea <check_boot_pgdir+0x1ed>
  1060c6:	c7 44 24 0c 04 82 10 	movl   $0x108204,0xc(%esp)
  1060cd:	00 
  1060ce:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  1060d5:	00 
  1060d6:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  1060dd:	00 
  1060de:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1060e5:	e8 e6 ab ff ff       	call   100cd0 <__panic>
    assert(page_ref(p) == 1);
  1060ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060ed:	89 04 24             	mov    %eax,(%esp)
  1060f0:	e8 df ea ff ff       	call   104bd4 <page_ref>
  1060f5:	83 f8 01             	cmp    $0x1,%eax
  1060f8:	74 24                	je     10611e <check_boot_pgdir+0x221>
  1060fa:	c7 44 24 0c 32 82 10 	movl   $0x108232,0xc(%esp)
  106101:	00 
  106102:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  106109:	00 
  10610a:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  106111:	00 
  106112:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  106119:	e8 b2 ab ff ff       	call   100cd0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  10611e:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  106123:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10612a:	00 
  10612b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  106132:	00 
  106133:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106136:	89 54 24 04          	mov    %edx,0x4(%esp)
  10613a:	89 04 24             	mov    %eax,(%esp)
  10613d:	e8 e2 f5 ff ff       	call   105724 <page_insert>
  106142:	85 c0                	test   %eax,%eax
  106144:	74 24                	je     10616a <check_boot_pgdir+0x26d>
  106146:	c7 44 24 0c 44 82 10 	movl   $0x108244,0xc(%esp)
  10614d:	00 
  10614e:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  106155:	00 
  106156:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  10615d:	00 
  10615e:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  106165:	e8 66 ab ff ff       	call   100cd0 <__panic>
    assert(page_ref(p) == 2);
  10616a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10616d:	89 04 24             	mov    %eax,(%esp)
  106170:	e8 5f ea ff ff       	call   104bd4 <page_ref>
  106175:	83 f8 02             	cmp    $0x2,%eax
  106178:	74 24                	je     10619e <check_boot_pgdir+0x2a1>
  10617a:	c7 44 24 0c 7b 82 10 	movl   $0x10827b,0xc(%esp)
  106181:	00 
  106182:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  106189:	00 
  10618a:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  106191:	00 
  106192:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  106199:	e8 32 ab ff ff       	call   100cd0 <__panic>

    const char *str = "ucore: Hello world!!";
  10619e:	c7 45 e8 8c 82 10 00 	movl   $0x10828c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  1061a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061ac:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1061b3:	e8 fc 09 00 00       	call   106bb4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1061b8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1061bf:	00 
  1061c0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1061c7:	e8 60 0a 00 00       	call   106c2c <strcmp>
  1061cc:	85 c0                	test   %eax,%eax
  1061ce:	74 24                	je     1061f4 <check_boot_pgdir+0x2f7>
  1061d0:	c7 44 24 0c a4 82 10 	movl   $0x1082a4,0xc(%esp)
  1061d7:	00 
  1061d8:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  1061df:	00 
  1061e0:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
  1061e7:	00 
  1061e8:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  1061ef:	e8 dc aa ff ff       	call   100cd0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1061f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1061f7:	89 04 24             	mov    %eax,(%esp)
  1061fa:	e8 25 e9 ff ff       	call   104b24 <page2kva>
  1061ff:	05 00 01 00 00       	add    $0x100,%eax
  106204:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  106207:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10620e:	e8 47 09 00 00       	call   106b5a <strlen>
  106213:	85 c0                	test   %eax,%eax
  106215:	74 24                	je     10623b <check_boot_pgdir+0x33e>
  106217:	c7 44 24 0c dc 82 10 	movl   $0x1082dc,0xc(%esp)
  10621e:	00 
  10621f:	c7 44 24 08 7d 7e 10 	movl   $0x107e7d,0x8(%esp)
  106226:	00 
  106227:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
  10622e:	00 
  10622f:	c7 04 24 58 7e 10 00 	movl   $0x107e58,(%esp)
  106236:	e8 95 aa ff ff       	call   100cd0 <__panic>

    free_page(p);
  10623b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  106242:	00 
  106243:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106246:	89 04 24             	mov    %eax,(%esp)
  106249:	e8 d0 eb ff ff       	call   104e1e <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10624e:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  106253:	8b 00                	mov    (%eax),%eax
  106255:	89 04 24             	mov    %eax,(%esp)
  106258:	e8 5d e9 ff ff       	call   104bba <pde2page>
  10625d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  106264:	00 
  106265:	89 04 24             	mov    %eax,(%esp)
  106268:	e8 b1 eb ff ff       	call   104e1e <free_pages>
    boot_pgdir[0] = 0;
  10626d:	a1 e0 b9 11 00       	mov    0x11b9e0,%eax
  106272:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  106278:	c7 04 24 00 83 10 00 	movl   $0x108300,(%esp)
  10627f:	e8 d2 a0 ff ff       	call   100356 <cprintf>
}
  106284:	90                   	nop
  106285:	89 ec                	mov    %ebp,%esp
  106287:	5d                   	pop    %ebp
  106288:	c3                   	ret    

00106289 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  106289:	55                   	push   %ebp
  10628a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10628c:	8b 45 08             	mov    0x8(%ebp),%eax
  10628f:	83 e0 04             	and    $0x4,%eax
  106292:	85 c0                	test   %eax,%eax
  106294:	74 04                	je     10629a <perm2str+0x11>
  106296:	b0 75                	mov    $0x75,%al
  106298:	eb 02                	jmp    10629c <perm2str+0x13>
  10629a:	b0 2d                	mov    $0x2d,%al
  10629c:	a2 88 ef 11 00       	mov    %al,0x11ef88
    str[1] = 'r';
  1062a1:	c6 05 89 ef 11 00 72 	movb   $0x72,0x11ef89
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1062a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1062ab:	83 e0 02             	and    $0x2,%eax
  1062ae:	85 c0                	test   %eax,%eax
  1062b0:	74 04                	je     1062b6 <perm2str+0x2d>
  1062b2:	b0 77                	mov    $0x77,%al
  1062b4:	eb 02                	jmp    1062b8 <perm2str+0x2f>
  1062b6:	b0 2d                	mov    $0x2d,%al
  1062b8:	a2 8a ef 11 00       	mov    %al,0x11ef8a
    str[3] = '\0';
  1062bd:	c6 05 8b ef 11 00 00 	movb   $0x0,0x11ef8b
    return str;
  1062c4:	b8 88 ef 11 00       	mov    $0x11ef88,%eax
}
  1062c9:	5d                   	pop    %ebp
  1062ca:	c3                   	ret    

001062cb <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1062cb:	55                   	push   %ebp
  1062cc:	89 e5                	mov    %esp,%ebp
  1062ce:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1062d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1062d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1062d7:	72 0d                	jb     1062e6 <get_pgtable_items+0x1b>
        return 0;
  1062d9:	b8 00 00 00 00       	mov    $0x0,%eax
  1062de:	e9 98 00 00 00       	jmp    10637b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1062e3:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1062e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1062e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1062ec:	73 18                	jae    106306 <get_pgtable_items+0x3b>
  1062ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1062f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1062f8:	8b 45 14             	mov    0x14(%ebp),%eax
  1062fb:	01 d0                	add    %edx,%eax
  1062fd:	8b 00                	mov    (%eax),%eax
  1062ff:	83 e0 01             	and    $0x1,%eax
  106302:	85 c0                	test   %eax,%eax
  106304:	74 dd                	je     1062e3 <get_pgtable_items+0x18>
    }
    if (start < right) {
  106306:	8b 45 10             	mov    0x10(%ebp),%eax
  106309:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10630c:	73 68                	jae    106376 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  10630e:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  106312:	74 08                	je     10631c <get_pgtable_items+0x51>
            *left_store = start;
  106314:	8b 45 18             	mov    0x18(%ebp),%eax
  106317:	8b 55 10             	mov    0x10(%ebp),%edx
  10631a:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10631c:	8b 45 10             	mov    0x10(%ebp),%eax
  10631f:	8d 50 01             	lea    0x1(%eax),%edx
  106322:	89 55 10             	mov    %edx,0x10(%ebp)
  106325:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10632c:	8b 45 14             	mov    0x14(%ebp),%eax
  10632f:	01 d0                	add    %edx,%eax
  106331:	8b 00                	mov    (%eax),%eax
  106333:	83 e0 07             	and    $0x7,%eax
  106336:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  106339:	eb 03                	jmp    10633e <get_pgtable_items+0x73>
            start ++;
  10633b:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10633e:	8b 45 10             	mov    0x10(%ebp),%eax
  106341:	3b 45 0c             	cmp    0xc(%ebp),%eax
  106344:	73 1d                	jae    106363 <get_pgtable_items+0x98>
  106346:	8b 45 10             	mov    0x10(%ebp),%eax
  106349:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  106350:	8b 45 14             	mov    0x14(%ebp),%eax
  106353:	01 d0                	add    %edx,%eax
  106355:	8b 00                	mov    (%eax),%eax
  106357:	83 e0 07             	and    $0x7,%eax
  10635a:	89 c2                	mov    %eax,%edx
  10635c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10635f:	39 c2                	cmp    %eax,%edx
  106361:	74 d8                	je     10633b <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  106363:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  106367:	74 08                	je     106371 <get_pgtable_items+0xa6>
            *right_store = start;
  106369:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10636c:	8b 55 10             	mov    0x10(%ebp),%edx
  10636f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  106371:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106374:	eb 05                	jmp    10637b <get_pgtable_items+0xb0>
    }
    return 0;
  106376:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10637b:	89 ec                	mov    %ebp,%esp
  10637d:	5d                   	pop    %ebp
  10637e:	c3                   	ret    

0010637f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10637f:	55                   	push   %ebp
  106380:	89 e5                	mov    %esp,%ebp
  106382:	57                   	push   %edi
  106383:	56                   	push   %esi
  106384:	53                   	push   %ebx
  106385:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  106388:	c7 04 24 20 83 10 00 	movl   $0x108320,(%esp)
  10638f:	e8 c2 9f ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  106394:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10639b:	e9 f2 00 00 00       	jmp    106492 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1063a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1063a3:	89 04 24             	mov    %eax,(%esp)
  1063a6:	e8 de fe ff ff       	call   106289 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1063ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1063ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1063b1:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1063b3:	89 d6                	mov    %edx,%esi
  1063b5:	c1 e6 16             	shl    $0x16,%esi
  1063b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1063bb:	89 d3                	mov    %edx,%ebx
  1063bd:	c1 e3 16             	shl    $0x16,%ebx
  1063c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1063c3:	89 d1                	mov    %edx,%ecx
  1063c5:	c1 e1 16             	shl    $0x16,%ecx
  1063c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1063cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  1063ce:	29 fa                	sub    %edi,%edx
  1063d0:	89 44 24 14          	mov    %eax,0x14(%esp)
  1063d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  1063d8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1063dc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1063e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1063e4:	c7 04 24 51 83 10 00 	movl   $0x108351,(%esp)
  1063eb:	e8 66 9f ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  1063f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1063f3:	c1 e0 0a             	shl    $0xa,%eax
  1063f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1063f9:	eb 50                	jmp    10644b <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1063fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1063fe:	89 04 24             	mov    %eax,(%esp)
  106401:	e8 83 fe ff ff       	call   106289 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  106406:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  106409:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  10640c:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10640e:	89 d6                	mov    %edx,%esi
  106410:	c1 e6 0c             	shl    $0xc,%esi
  106413:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  106416:	89 d3                	mov    %edx,%ebx
  106418:	c1 e3 0c             	shl    $0xc,%ebx
  10641b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10641e:	89 d1                	mov    %edx,%ecx
  106420:	c1 e1 0c             	shl    $0xc,%ecx
  106423:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  106426:	8b 7d d8             	mov    -0x28(%ebp),%edi
  106429:	29 fa                	sub    %edi,%edx
  10642b:	89 44 24 14          	mov    %eax,0x14(%esp)
  10642f:	89 74 24 10          	mov    %esi,0x10(%esp)
  106433:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  106437:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10643b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10643f:	c7 04 24 70 83 10 00 	movl   $0x108370,(%esp)
  106446:	e8 0b 9f ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10644b:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  106450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  106453:	8b 55 dc             	mov    -0x24(%ebp),%edx
  106456:	89 d3                	mov    %edx,%ebx
  106458:	c1 e3 0a             	shl    $0xa,%ebx
  10645b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10645e:	89 d1                	mov    %edx,%ecx
  106460:	c1 e1 0a             	shl    $0xa,%ecx
  106463:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  106466:	89 54 24 14          	mov    %edx,0x14(%esp)
  10646a:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10646d:	89 54 24 10          	mov    %edx,0x10(%esp)
  106471:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106475:	89 44 24 08          	mov    %eax,0x8(%esp)
  106479:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10647d:	89 0c 24             	mov    %ecx,(%esp)
  106480:	e8 46 fe ff ff       	call   1062cb <get_pgtable_items>
  106485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10648c:	0f 85 69 ff ff ff    	jne    1063fb <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  106492:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  106497:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10649a:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10649d:	89 54 24 14          	mov    %edx,0x14(%esp)
  1064a1:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1064a4:	89 54 24 10          	mov    %edx,0x10(%esp)
  1064a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1064ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  1064b0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1064b7:	00 
  1064b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1064bf:	e8 07 fe ff ff       	call   1062cb <get_pgtable_items>
  1064c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1064c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1064cb:	0f 85 cf fe ff ff    	jne    1063a0 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1064d1:	c7 04 24 94 83 10 00 	movl   $0x108394,(%esp)
  1064d8:	e8 79 9e ff ff       	call   100356 <cprintf>
}
  1064dd:	90                   	nop
  1064de:	83 c4 4c             	add    $0x4c,%esp
  1064e1:	5b                   	pop    %ebx
  1064e2:	5e                   	pop    %esi
  1064e3:	5f                   	pop    %edi
  1064e4:	5d                   	pop    %ebp
  1064e5:	c3                   	ret    

001064e6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1064e6:	55                   	push   %ebp
  1064e7:	89 e5                	mov    %esp,%ebp
  1064e9:	83 ec 58             	sub    $0x58,%esp
  1064ec:	8b 45 10             	mov    0x10(%ebp),%eax
  1064ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1064f2:	8b 45 14             	mov    0x14(%ebp),%eax
  1064f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1064f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1064fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1064fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106501:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106504:	8b 45 18             	mov    0x18(%ebp),%eax
  106507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10650a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10650d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106510:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106513:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106519:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10651c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  106520:	74 1c                	je     10653e <printnum+0x58>
  106522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106525:	ba 00 00 00 00       	mov    $0x0,%edx
  10652a:	f7 75 e4             	divl   -0x1c(%ebp)
  10652d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  106530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106533:	ba 00 00 00 00       	mov    $0x0,%edx
  106538:	f7 75 e4             	divl   -0x1c(%ebp)
  10653b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10653e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106544:	f7 75 e4             	divl   -0x1c(%ebp)
  106547:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10654a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10654d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106550:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106553:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106556:	89 55 ec             	mov    %edx,-0x14(%ebp)
  106559:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10655c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10655f:	8b 45 18             	mov    0x18(%ebp),%eax
  106562:	ba 00 00 00 00       	mov    $0x0,%edx
  106567:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10656a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10656d:	19 d1                	sbb    %edx,%ecx
  10656f:	72 4c                	jb     1065bd <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  106571:	8b 45 1c             	mov    0x1c(%ebp),%eax
  106574:	8d 50 ff             	lea    -0x1(%eax),%edx
  106577:	8b 45 20             	mov    0x20(%ebp),%eax
  10657a:	89 44 24 18          	mov    %eax,0x18(%esp)
  10657e:	89 54 24 14          	mov    %edx,0x14(%esp)
  106582:	8b 45 18             	mov    0x18(%ebp),%eax
  106585:	89 44 24 10          	mov    %eax,0x10(%esp)
  106589:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10658c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10658f:	89 44 24 08          	mov    %eax,0x8(%esp)
  106593:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106597:	8b 45 0c             	mov    0xc(%ebp),%eax
  10659a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10659e:	8b 45 08             	mov    0x8(%ebp),%eax
  1065a1:	89 04 24             	mov    %eax,(%esp)
  1065a4:	e8 3d ff ff ff       	call   1064e6 <printnum>
  1065a9:	eb 1b                	jmp    1065c6 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1065ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1065ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1065b2:	8b 45 20             	mov    0x20(%ebp),%eax
  1065b5:	89 04 24             	mov    %eax,(%esp)
  1065b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1065bb:	ff d0                	call   *%eax
        while (-- width > 0)
  1065bd:	ff 4d 1c             	decl   0x1c(%ebp)
  1065c0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1065c4:	7f e5                	jg     1065ab <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1065c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1065c9:	05 48 84 10 00       	add    $0x108448,%eax
  1065ce:	0f b6 00             	movzbl (%eax),%eax
  1065d1:	0f be c0             	movsbl %al,%eax
  1065d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1065d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1065db:	89 04 24             	mov    %eax,(%esp)
  1065de:	8b 45 08             	mov    0x8(%ebp),%eax
  1065e1:	ff d0                	call   *%eax
}
  1065e3:	90                   	nop
  1065e4:	89 ec                	mov    %ebp,%esp
  1065e6:	5d                   	pop    %ebp
  1065e7:	c3                   	ret    

001065e8 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1065e8:	55                   	push   %ebp
  1065e9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1065eb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1065ef:	7e 14                	jle    106605 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1065f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1065f4:	8b 00                	mov    (%eax),%eax
  1065f6:	8d 48 08             	lea    0x8(%eax),%ecx
  1065f9:	8b 55 08             	mov    0x8(%ebp),%edx
  1065fc:	89 0a                	mov    %ecx,(%edx)
  1065fe:	8b 50 04             	mov    0x4(%eax),%edx
  106601:	8b 00                	mov    (%eax),%eax
  106603:	eb 30                	jmp    106635 <getuint+0x4d>
    }
    else if (lflag) {
  106605:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106609:	74 16                	je     106621 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10660b:	8b 45 08             	mov    0x8(%ebp),%eax
  10660e:	8b 00                	mov    (%eax),%eax
  106610:	8d 48 04             	lea    0x4(%eax),%ecx
  106613:	8b 55 08             	mov    0x8(%ebp),%edx
  106616:	89 0a                	mov    %ecx,(%edx)
  106618:	8b 00                	mov    (%eax),%eax
  10661a:	ba 00 00 00 00       	mov    $0x0,%edx
  10661f:	eb 14                	jmp    106635 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106621:	8b 45 08             	mov    0x8(%ebp),%eax
  106624:	8b 00                	mov    (%eax),%eax
  106626:	8d 48 04             	lea    0x4(%eax),%ecx
  106629:	8b 55 08             	mov    0x8(%ebp),%edx
  10662c:	89 0a                	mov    %ecx,(%edx)
  10662e:	8b 00                	mov    (%eax),%eax
  106630:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  106635:	5d                   	pop    %ebp
  106636:	c3                   	ret    

00106637 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  106637:	55                   	push   %ebp
  106638:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10663a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10663e:	7e 14                	jle    106654 <getint+0x1d>
        return va_arg(*ap, long long);
  106640:	8b 45 08             	mov    0x8(%ebp),%eax
  106643:	8b 00                	mov    (%eax),%eax
  106645:	8d 48 08             	lea    0x8(%eax),%ecx
  106648:	8b 55 08             	mov    0x8(%ebp),%edx
  10664b:	89 0a                	mov    %ecx,(%edx)
  10664d:	8b 50 04             	mov    0x4(%eax),%edx
  106650:	8b 00                	mov    (%eax),%eax
  106652:	eb 28                	jmp    10667c <getint+0x45>
    }
    else if (lflag) {
  106654:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106658:	74 12                	je     10666c <getint+0x35>
        return va_arg(*ap, long);
  10665a:	8b 45 08             	mov    0x8(%ebp),%eax
  10665d:	8b 00                	mov    (%eax),%eax
  10665f:	8d 48 04             	lea    0x4(%eax),%ecx
  106662:	8b 55 08             	mov    0x8(%ebp),%edx
  106665:	89 0a                	mov    %ecx,(%edx)
  106667:	8b 00                	mov    (%eax),%eax
  106669:	99                   	cltd   
  10666a:	eb 10                	jmp    10667c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10666c:	8b 45 08             	mov    0x8(%ebp),%eax
  10666f:	8b 00                	mov    (%eax),%eax
  106671:	8d 48 04             	lea    0x4(%eax),%ecx
  106674:	8b 55 08             	mov    0x8(%ebp),%edx
  106677:	89 0a                	mov    %ecx,(%edx)
  106679:	8b 00                	mov    (%eax),%eax
  10667b:	99                   	cltd   
    }
}
  10667c:	5d                   	pop    %ebp
  10667d:	c3                   	ret    

0010667e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10667e:	55                   	push   %ebp
  10667f:	89 e5                	mov    %esp,%ebp
  106681:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  106684:	8d 45 14             	lea    0x14(%ebp),%eax
  106687:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10668d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106691:	8b 45 10             	mov    0x10(%ebp),%eax
  106694:	89 44 24 08          	mov    %eax,0x8(%esp)
  106698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10669b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10669f:	8b 45 08             	mov    0x8(%ebp),%eax
  1066a2:	89 04 24             	mov    %eax,(%esp)
  1066a5:	e8 05 00 00 00       	call   1066af <vprintfmt>
    va_end(ap);
}
  1066aa:	90                   	nop
  1066ab:	89 ec                	mov    %ebp,%esp
  1066ad:	5d                   	pop    %ebp
  1066ae:	c3                   	ret    

001066af <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1066af:	55                   	push   %ebp
  1066b0:	89 e5                	mov    %esp,%ebp
  1066b2:	56                   	push   %esi
  1066b3:	53                   	push   %ebx
  1066b4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1066b7:	eb 17                	jmp    1066d0 <vprintfmt+0x21>
            if (ch == '\0') {
  1066b9:	85 db                	test   %ebx,%ebx
  1066bb:	0f 84 bf 03 00 00    	je     106a80 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1066c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1066c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1066c8:	89 1c 24             	mov    %ebx,(%esp)
  1066cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1066ce:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1066d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1066d3:	8d 50 01             	lea    0x1(%eax),%edx
  1066d6:	89 55 10             	mov    %edx,0x10(%ebp)
  1066d9:	0f b6 00             	movzbl (%eax),%eax
  1066dc:	0f b6 d8             	movzbl %al,%ebx
  1066df:	83 fb 25             	cmp    $0x25,%ebx
  1066e2:	75 d5                	jne    1066b9 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1066e4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1066e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1066ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1066f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1066f5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1066fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1066ff:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106702:	8b 45 10             	mov    0x10(%ebp),%eax
  106705:	8d 50 01             	lea    0x1(%eax),%edx
  106708:	89 55 10             	mov    %edx,0x10(%ebp)
  10670b:	0f b6 00             	movzbl (%eax),%eax
  10670e:	0f b6 d8             	movzbl %al,%ebx
  106711:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106714:	83 f8 55             	cmp    $0x55,%eax
  106717:	0f 87 37 03 00 00    	ja     106a54 <vprintfmt+0x3a5>
  10671d:	8b 04 85 6c 84 10 00 	mov    0x10846c(,%eax,4),%eax
  106724:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106726:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10672a:	eb d6                	jmp    106702 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10672c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106730:	eb d0                	jmp    106702 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106732:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106739:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10673c:	89 d0                	mov    %edx,%eax
  10673e:	c1 e0 02             	shl    $0x2,%eax
  106741:	01 d0                	add    %edx,%eax
  106743:	01 c0                	add    %eax,%eax
  106745:	01 d8                	add    %ebx,%eax
  106747:	83 e8 30             	sub    $0x30,%eax
  10674a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10674d:	8b 45 10             	mov    0x10(%ebp),%eax
  106750:	0f b6 00             	movzbl (%eax),%eax
  106753:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106756:	83 fb 2f             	cmp    $0x2f,%ebx
  106759:	7e 38                	jle    106793 <vprintfmt+0xe4>
  10675b:	83 fb 39             	cmp    $0x39,%ebx
  10675e:	7f 33                	jg     106793 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  106760:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  106763:	eb d4                	jmp    106739 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106765:	8b 45 14             	mov    0x14(%ebp),%eax
  106768:	8d 50 04             	lea    0x4(%eax),%edx
  10676b:	89 55 14             	mov    %edx,0x14(%ebp)
  10676e:	8b 00                	mov    (%eax),%eax
  106770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106773:	eb 1f                	jmp    106794 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106775:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106779:	79 87                	jns    106702 <vprintfmt+0x53>
                width = 0;
  10677b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  106782:	e9 7b ff ff ff       	jmp    106702 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  106787:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10678e:	e9 6f ff ff ff       	jmp    106702 <vprintfmt+0x53>
            goto process_precision;
  106793:	90                   	nop

        process_precision:
            if (width < 0)
  106794:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106798:	0f 89 64 ff ff ff    	jns    106702 <vprintfmt+0x53>
                width = precision, precision = -1;
  10679e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1067a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1067a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1067ab:	e9 52 ff ff ff       	jmp    106702 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1067b0:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1067b3:	e9 4a ff ff ff       	jmp    106702 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1067b8:	8b 45 14             	mov    0x14(%ebp),%eax
  1067bb:	8d 50 04             	lea    0x4(%eax),%edx
  1067be:	89 55 14             	mov    %edx,0x14(%ebp)
  1067c1:	8b 00                	mov    (%eax),%eax
  1067c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1067c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1067ca:	89 04 24             	mov    %eax,(%esp)
  1067cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1067d0:	ff d0                	call   *%eax
            break;
  1067d2:	e9 a4 02 00 00       	jmp    106a7b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1067d7:	8b 45 14             	mov    0x14(%ebp),%eax
  1067da:	8d 50 04             	lea    0x4(%eax),%edx
  1067dd:	89 55 14             	mov    %edx,0x14(%ebp)
  1067e0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1067e2:	85 db                	test   %ebx,%ebx
  1067e4:	79 02                	jns    1067e8 <vprintfmt+0x139>
                err = -err;
  1067e6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1067e8:	83 fb 06             	cmp    $0x6,%ebx
  1067eb:	7f 0b                	jg     1067f8 <vprintfmt+0x149>
  1067ed:	8b 34 9d 2c 84 10 00 	mov    0x10842c(,%ebx,4),%esi
  1067f4:	85 f6                	test   %esi,%esi
  1067f6:	75 23                	jne    10681b <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1067f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1067fc:	c7 44 24 08 59 84 10 	movl   $0x108459,0x8(%esp)
  106803:	00 
  106804:	8b 45 0c             	mov    0xc(%ebp),%eax
  106807:	89 44 24 04          	mov    %eax,0x4(%esp)
  10680b:	8b 45 08             	mov    0x8(%ebp),%eax
  10680e:	89 04 24             	mov    %eax,(%esp)
  106811:	e8 68 fe ff ff       	call   10667e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106816:	e9 60 02 00 00       	jmp    106a7b <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  10681b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10681f:	c7 44 24 08 62 84 10 	movl   $0x108462,0x8(%esp)
  106826:	00 
  106827:	8b 45 0c             	mov    0xc(%ebp),%eax
  10682a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10682e:	8b 45 08             	mov    0x8(%ebp),%eax
  106831:	89 04 24             	mov    %eax,(%esp)
  106834:	e8 45 fe ff ff       	call   10667e <printfmt>
            break;
  106839:	e9 3d 02 00 00       	jmp    106a7b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10683e:	8b 45 14             	mov    0x14(%ebp),%eax
  106841:	8d 50 04             	lea    0x4(%eax),%edx
  106844:	89 55 14             	mov    %edx,0x14(%ebp)
  106847:	8b 30                	mov    (%eax),%esi
  106849:	85 f6                	test   %esi,%esi
  10684b:	75 05                	jne    106852 <vprintfmt+0x1a3>
                p = "(null)";
  10684d:	be 65 84 10 00       	mov    $0x108465,%esi
            }
            if (width > 0 && padc != '-') {
  106852:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106856:	7e 76                	jle    1068ce <vprintfmt+0x21f>
  106858:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  10685c:	74 70                	je     1068ce <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10685e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106861:	89 44 24 04          	mov    %eax,0x4(%esp)
  106865:	89 34 24             	mov    %esi,(%esp)
  106868:	e8 16 03 00 00       	call   106b83 <strnlen>
  10686d:	89 c2                	mov    %eax,%edx
  10686f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106872:	29 d0                	sub    %edx,%eax
  106874:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106877:	eb 16                	jmp    10688f <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106879:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  10687d:	8b 55 0c             	mov    0xc(%ebp),%edx
  106880:	89 54 24 04          	mov    %edx,0x4(%esp)
  106884:	89 04 24             	mov    %eax,(%esp)
  106887:	8b 45 08             	mov    0x8(%ebp),%eax
  10688a:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  10688c:	ff 4d e8             	decl   -0x18(%ebp)
  10688f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106893:	7f e4                	jg     106879 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106895:	eb 37                	jmp    1068ce <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  106897:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10689b:	74 1f                	je     1068bc <vprintfmt+0x20d>
  10689d:	83 fb 1f             	cmp    $0x1f,%ebx
  1068a0:	7e 05                	jle    1068a7 <vprintfmt+0x1f8>
  1068a2:	83 fb 7e             	cmp    $0x7e,%ebx
  1068a5:	7e 15                	jle    1068bc <vprintfmt+0x20d>
                    putch('?', putdat);
  1068a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068ae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1068b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1068b8:	ff d0                	call   *%eax
  1068ba:	eb 0f                	jmp    1068cb <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  1068bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068c3:	89 1c 24             	mov    %ebx,(%esp)
  1068c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1068c9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1068cb:	ff 4d e8             	decl   -0x18(%ebp)
  1068ce:	89 f0                	mov    %esi,%eax
  1068d0:	8d 70 01             	lea    0x1(%eax),%esi
  1068d3:	0f b6 00             	movzbl (%eax),%eax
  1068d6:	0f be d8             	movsbl %al,%ebx
  1068d9:	85 db                	test   %ebx,%ebx
  1068db:	74 27                	je     106904 <vprintfmt+0x255>
  1068dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1068e1:	78 b4                	js     106897 <vprintfmt+0x1e8>
  1068e3:	ff 4d e4             	decl   -0x1c(%ebp)
  1068e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1068ea:	79 ab                	jns    106897 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  1068ec:	eb 16                	jmp    106904 <vprintfmt+0x255>
                putch(' ', putdat);
  1068ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1068fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1068ff:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  106901:	ff 4d e8             	decl   -0x18(%ebp)
  106904:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106908:	7f e4                	jg     1068ee <vprintfmt+0x23f>
            }
            break;
  10690a:	e9 6c 01 00 00       	jmp    106a7b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10690f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106912:	89 44 24 04          	mov    %eax,0x4(%esp)
  106916:	8d 45 14             	lea    0x14(%ebp),%eax
  106919:	89 04 24             	mov    %eax,(%esp)
  10691c:	e8 16 fd ff ff       	call   106637 <getint>
  106921:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106924:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106927:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10692a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10692d:	85 d2                	test   %edx,%edx
  10692f:	79 26                	jns    106957 <vprintfmt+0x2a8>
                putch('-', putdat);
  106931:	8b 45 0c             	mov    0xc(%ebp),%eax
  106934:	89 44 24 04          	mov    %eax,0x4(%esp)
  106938:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10693f:	8b 45 08             	mov    0x8(%ebp),%eax
  106942:	ff d0                	call   *%eax
                num = -(long long)num;
  106944:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10694a:	f7 d8                	neg    %eax
  10694c:	83 d2 00             	adc    $0x0,%edx
  10694f:	f7 da                	neg    %edx
  106951:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106954:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106957:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10695e:	e9 a8 00 00 00       	jmp    106a0b <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106963:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106966:	89 44 24 04          	mov    %eax,0x4(%esp)
  10696a:	8d 45 14             	lea    0x14(%ebp),%eax
  10696d:	89 04 24             	mov    %eax,(%esp)
  106970:	e8 73 fc ff ff       	call   1065e8 <getuint>
  106975:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106978:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10697b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106982:	e9 84 00 00 00       	jmp    106a0b <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106987:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10698a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10698e:	8d 45 14             	lea    0x14(%ebp),%eax
  106991:	89 04 24             	mov    %eax,(%esp)
  106994:	e8 4f fc ff ff       	call   1065e8 <getuint>
  106999:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10699c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10699f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1069a6:	eb 63                	jmp    106a0b <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1069a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069af:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1069b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1069b9:	ff d0                	call   *%eax
            putch('x', putdat);
  1069bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1069be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069c2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1069c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1069cc:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1069ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1069d1:	8d 50 04             	lea    0x4(%eax),%edx
  1069d4:	89 55 14             	mov    %edx,0x14(%ebp)
  1069d7:	8b 00                	mov    (%eax),%eax
  1069d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1069dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1069e3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1069ea:	eb 1f                	jmp    106a0b <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1069ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1069ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1069f3:	8d 45 14             	lea    0x14(%ebp),%eax
  1069f6:	89 04 24             	mov    %eax,(%esp)
  1069f9:	e8 ea fb ff ff       	call   1065e8 <getuint>
  1069fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106a01:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106a04:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106a0b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106a0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106a12:	89 54 24 18          	mov    %edx,0x18(%esp)
  106a16:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106a19:	89 54 24 14          	mov    %edx,0x14(%esp)
  106a1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  106a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  106a2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a36:	8b 45 08             	mov    0x8(%ebp),%eax
  106a39:	89 04 24             	mov    %eax,(%esp)
  106a3c:	e8 a5 fa ff ff       	call   1064e6 <printnum>
            break;
  106a41:	eb 38                	jmp    106a7b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a4a:	89 1c 24             	mov    %ebx,(%esp)
  106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  106a50:	ff d0                	call   *%eax
            break;
  106a52:	eb 27                	jmp    106a7b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a5b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106a62:	8b 45 08             	mov    0x8(%ebp),%eax
  106a65:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106a67:	ff 4d 10             	decl   0x10(%ebp)
  106a6a:	eb 03                	jmp    106a6f <vprintfmt+0x3c0>
  106a6c:	ff 4d 10             	decl   0x10(%ebp)
  106a6f:	8b 45 10             	mov    0x10(%ebp),%eax
  106a72:	48                   	dec    %eax
  106a73:	0f b6 00             	movzbl (%eax),%eax
  106a76:	3c 25                	cmp    $0x25,%al
  106a78:	75 f2                	jne    106a6c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106a7a:	90                   	nop
    while (1) {
  106a7b:	e9 37 fc ff ff       	jmp    1066b7 <vprintfmt+0x8>
                return;
  106a80:	90                   	nop
        }
    }
}
  106a81:	83 c4 40             	add    $0x40,%esp
  106a84:	5b                   	pop    %ebx
  106a85:	5e                   	pop    %esi
  106a86:	5d                   	pop    %ebp
  106a87:	c3                   	ret    

00106a88 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106a88:	55                   	push   %ebp
  106a89:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a8e:	8b 40 08             	mov    0x8(%eax),%eax
  106a91:	8d 50 01             	lea    0x1(%eax),%edx
  106a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a97:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a9d:	8b 10                	mov    (%eax),%edx
  106a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106aa2:	8b 40 04             	mov    0x4(%eax),%eax
  106aa5:	39 c2                	cmp    %eax,%edx
  106aa7:	73 12                	jae    106abb <sprintputch+0x33>
        *b->buf ++ = ch;
  106aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  106aac:	8b 00                	mov    (%eax),%eax
  106aae:	8d 48 01             	lea    0x1(%eax),%ecx
  106ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
  106ab4:	89 0a                	mov    %ecx,(%edx)
  106ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  106ab9:	88 10                	mov    %dl,(%eax)
    }
}
  106abb:	90                   	nop
  106abc:	5d                   	pop    %ebp
  106abd:	c3                   	ret    

00106abe <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106abe:	55                   	push   %ebp
  106abf:	89 e5                	mov    %esp,%ebp
  106ac1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106ac4:	8d 45 14             	lea    0x14(%ebp),%eax
  106ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  106ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  106ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  106adf:	8b 45 08             	mov    0x8(%ebp),%eax
  106ae2:	89 04 24             	mov    %eax,(%esp)
  106ae5:	e8 0a 00 00 00       	call   106af4 <vsnprintf>
  106aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106af0:	89 ec                	mov    %ebp,%esp
  106af2:	5d                   	pop    %ebp
  106af3:	c3                   	ret    

00106af4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106af4:	55                   	push   %ebp
  106af5:	89 e5                	mov    %esp,%ebp
  106af7:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106afa:	8b 45 08             	mov    0x8(%ebp),%eax
  106afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b03:	8d 50 ff             	lea    -0x1(%eax),%edx
  106b06:	8b 45 08             	mov    0x8(%ebp),%eax
  106b09:	01 d0                	add    %edx,%eax
  106b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106b15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106b19:	74 0a                	je     106b25 <vsnprintf+0x31>
  106b1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b21:	39 c2                	cmp    %eax,%edx
  106b23:	76 07                	jbe    106b2c <vsnprintf+0x38>
        return -E_INVAL;
  106b25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106b2a:	eb 2a                	jmp    106b56 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106b2c:	8b 45 14             	mov    0x14(%ebp),%eax
  106b2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106b33:	8b 45 10             	mov    0x10(%ebp),%eax
  106b36:	89 44 24 08          	mov    %eax,0x8(%esp)
  106b3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b41:	c7 04 24 88 6a 10 00 	movl   $0x106a88,(%esp)
  106b48:	e8 62 fb ff ff       	call   1066af <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106b50:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106b56:	89 ec                	mov    %ebp,%esp
  106b58:	5d                   	pop    %ebp
  106b59:	c3                   	ret    

00106b5a <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  106b5a:	55                   	push   %ebp
  106b5b:	89 e5                	mov    %esp,%ebp
  106b5d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106b60:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  106b67:	eb 03                	jmp    106b6c <strlen+0x12>
        cnt ++;
  106b69:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  106b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  106b6f:	8d 50 01             	lea    0x1(%eax),%edx
  106b72:	89 55 08             	mov    %edx,0x8(%ebp)
  106b75:	0f b6 00             	movzbl (%eax),%eax
  106b78:	84 c0                	test   %al,%al
  106b7a:	75 ed                	jne    106b69 <strlen+0xf>
    }
    return cnt;
  106b7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106b7f:	89 ec                	mov    %ebp,%esp
  106b81:	5d                   	pop    %ebp
  106b82:	c3                   	ret    

00106b83 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  106b83:	55                   	push   %ebp
  106b84:	89 e5                	mov    %esp,%ebp
  106b86:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106b89:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106b90:	eb 03                	jmp    106b95 <strnlen+0x12>
        cnt ++;
  106b92:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106b95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106b98:	3b 45 0c             	cmp    0xc(%ebp),%eax
  106b9b:	73 10                	jae    106bad <strnlen+0x2a>
  106b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  106ba0:	8d 50 01             	lea    0x1(%eax),%edx
  106ba3:	89 55 08             	mov    %edx,0x8(%ebp)
  106ba6:	0f b6 00             	movzbl (%eax),%eax
  106ba9:	84 c0                	test   %al,%al
  106bab:	75 e5                	jne    106b92 <strnlen+0xf>
    }
    return cnt;
  106bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106bb0:	89 ec                	mov    %ebp,%esp
  106bb2:	5d                   	pop    %ebp
  106bb3:	c3                   	ret    

00106bb4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  106bb4:	55                   	push   %ebp
  106bb5:	89 e5                	mov    %esp,%ebp
  106bb7:	57                   	push   %edi
  106bb8:	56                   	push   %esi
  106bb9:	83 ec 20             	sub    $0x20,%esp
  106bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  106bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  106bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106bce:	89 d1                	mov    %edx,%ecx
  106bd0:	89 c2                	mov    %eax,%edx
  106bd2:	89 ce                	mov    %ecx,%esi
  106bd4:	89 d7                	mov    %edx,%edi
  106bd6:	ac                   	lods   %ds:(%esi),%al
  106bd7:	aa                   	stos   %al,%es:(%edi)
  106bd8:	84 c0                	test   %al,%al
  106bda:	75 fa                	jne    106bd6 <strcpy+0x22>
  106bdc:	89 fa                	mov    %edi,%edx
  106bde:	89 f1                	mov    %esi,%ecx
  106be0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106be3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  106be6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  106be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  106bec:	83 c4 20             	add    $0x20,%esp
  106bef:	5e                   	pop    %esi
  106bf0:	5f                   	pop    %edi
  106bf1:	5d                   	pop    %ebp
  106bf2:	c3                   	ret    

00106bf3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  106bf3:	55                   	push   %ebp
  106bf4:	89 e5                	mov    %esp,%ebp
  106bf6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  106bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  106bfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  106bff:	eb 1e                	jmp    106c1f <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  106c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c04:	0f b6 10             	movzbl (%eax),%edx
  106c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106c0a:	88 10                	mov    %dl,(%eax)
  106c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106c0f:	0f b6 00             	movzbl (%eax),%eax
  106c12:	84 c0                	test   %al,%al
  106c14:	74 03                	je     106c19 <strncpy+0x26>
            src ++;
  106c16:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  106c19:	ff 45 fc             	incl   -0x4(%ebp)
  106c1c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  106c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106c23:	75 dc                	jne    106c01 <strncpy+0xe>
    }
    return dst;
  106c25:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106c28:	89 ec                	mov    %ebp,%esp
  106c2a:	5d                   	pop    %ebp
  106c2b:	c3                   	ret    

00106c2c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  106c2c:	55                   	push   %ebp
  106c2d:	89 e5                	mov    %esp,%ebp
  106c2f:	57                   	push   %edi
  106c30:	56                   	push   %esi
  106c31:	83 ec 20             	sub    $0x20,%esp
  106c34:	8b 45 08             	mov    0x8(%ebp),%eax
  106c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  106c40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c46:	89 d1                	mov    %edx,%ecx
  106c48:	89 c2                	mov    %eax,%edx
  106c4a:	89 ce                	mov    %ecx,%esi
  106c4c:	89 d7                	mov    %edx,%edi
  106c4e:	ac                   	lods   %ds:(%esi),%al
  106c4f:	ae                   	scas   %es:(%edi),%al
  106c50:	75 08                	jne    106c5a <strcmp+0x2e>
  106c52:	84 c0                	test   %al,%al
  106c54:	75 f8                	jne    106c4e <strcmp+0x22>
  106c56:	31 c0                	xor    %eax,%eax
  106c58:	eb 04                	jmp    106c5e <strcmp+0x32>
  106c5a:	19 c0                	sbb    %eax,%eax
  106c5c:	0c 01                	or     $0x1,%al
  106c5e:	89 fa                	mov    %edi,%edx
  106c60:	89 f1                	mov    %esi,%ecx
  106c62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106c65:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106c68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  106c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  106c6e:	83 c4 20             	add    $0x20,%esp
  106c71:	5e                   	pop    %esi
  106c72:	5f                   	pop    %edi
  106c73:	5d                   	pop    %ebp
  106c74:	c3                   	ret    

00106c75 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  106c75:	55                   	push   %ebp
  106c76:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106c78:	eb 09                	jmp    106c83 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  106c7a:	ff 4d 10             	decl   0x10(%ebp)
  106c7d:	ff 45 08             	incl   0x8(%ebp)
  106c80:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106c83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106c87:	74 1a                	je     106ca3 <strncmp+0x2e>
  106c89:	8b 45 08             	mov    0x8(%ebp),%eax
  106c8c:	0f b6 00             	movzbl (%eax),%eax
  106c8f:	84 c0                	test   %al,%al
  106c91:	74 10                	je     106ca3 <strncmp+0x2e>
  106c93:	8b 45 08             	mov    0x8(%ebp),%eax
  106c96:	0f b6 10             	movzbl (%eax),%edx
  106c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c9c:	0f b6 00             	movzbl (%eax),%eax
  106c9f:	38 c2                	cmp    %al,%dl
  106ca1:	74 d7                	je     106c7a <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  106ca3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106ca7:	74 18                	je     106cc1 <strncmp+0x4c>
  106ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  106cac:	0f b6 00             	movzbl (%eax),%eax
  106caf:	0f b6 d0             	movzbl %al,%edx
  106cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cb5:	0f b6 00             	movzbl (%eax),%eax
  106cb8:	0f b6 c8             	movzbl %al,%ecx
  106cbb:	89 d0                	mov    %edx,%eax
  106cbd:	29 c8                	sub    %ecx,%eax
  106cbf:	eb 05                	jmp    106cc6 <strncmp+0x51>
  106cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106cc6:	5d                   	pop    %ebp
  106cc7:	c3                   	ret    

00106cc8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  106cc8:	55                   	push   %ebp
  106cc9:	89 e5                	mov    %esp,%ebp
  106ccb:	83 ec 04             	sub    $0x4,%esp
  106cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cd1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106cd4:	eb 13                	jmp    106ce9 <strchr+0x21>
        if (*s == c) {
  106cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  106cd9:	0f b6 00             	movzbl (%eax),%eax
  106cdc:	38 45 fc             	cmp    %al,-0x4(%ebp)
  106cdf:	75 05                	jne    106ce6 <strchr+0x1e>
            return (char *)s;
  106ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  106ce4:	eb 12                	jmp    106cf8 <strchr+0x30>
        }
        s ++;
  106ce6:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  106cec:	0f b6 00             	movzbl (%eax),%eax
  106cef:	84 c0                	test   %al,%al
  106cf1:	75 e3                	jne    106cd6 <strchr+0xe>
    }
    return NULL;
  106cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106cf8:	89 ec                	mov    %ebp,%esp
  106cfa:	5d                   	pop    %ebp
  106cfb:	c3                   	ret    

00106cfc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  106cfc:	55                   	push   %ebp
  106cfd:	89 e5                	mov    %esp,%ebp
  106cff:	83 ec 04             	sub    $0x4,%esp
  106d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d05:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  106d08:	eb 0e                	jmp    106d18 <strfind+0x1c>
        if (*s == c) {
  106d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  106d0d:	0f b6 00             	movzbl (%eax),%eax
  106d10:	38 45 fc             	cmp    %al,-0x4(%ebp)
  106d13:	74 0f                	je     106d24 <strfind+0x28>
            break;
        }
        s ++;
  106d15:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  106d18:	8b 45 08             	mov    0x8(%ebp),%eax
  106d1b:	0f b6 00             	movzbl (%eax),%eax
  106d1e:	84 c0                	test   %al,%al
  106d20:	75 e8                	jne    106d0a <strfind+0xe>
  106d22:	eb 01                	jmp    106d25 <strfind+0x29>
            break;
  106d24:	90                   	nop
    }
    return (char *)s;
  106d25:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106d28:	89 ec                	mov    %ebp,%esp
  106d2a:	5d                   	pop    %ebp
  106d2b:	c3                   	ret    

00106d2c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106d2c:	55                   	push   %ebp
  106d2d:	89 e5                	mov    %esp,%ebp
  106d2f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  106d32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106d39:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  106d40:	eb 03                	jmp    106d45 <strtol+0x19>
        s ++;
  106d42:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  106d45:	8b 45 08             	mov    0x8(%ebp),%eax
  106d48:	0f b6 00             	movzbl (%eax),%eax
  106d4b:	3c 20                	cmp    $0x20,%al
  106d4d:	74 f3                	je     106d42 <strtol+0x16>
  106d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  106d52:	0f b6 00             	movzbl (%eax),%eax
  106d55:	3c 09                	cmp    $0x9,%al
  106d57:	74 e9                	je     106d42 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  106d59:	8b 45 08             	mov    0x8(%ebp),%eax
  106d5c:	0f b6 00             	movzbl (%eax),%eax
  106d5f:	3c 2b                	cmp    $0x2b,%al
  106d61:	75 05                	jne    106d68 <strtol+0x3c>
        s ++;
  106d63:	ff 45 08             	incl   0x8(%ebp)
  106d66:	eb 14                	jmp    106d7c <strtol+0x50>
    }
    else if (*s == '-') {
  106d68:	8b 45 08             	mov    0x8(%ebp),%eax
  106d6b:	0f b6 00             	movzbl (%eax),%eax
  106d6e:	3c 2d                	cmp    $0x2d,%al
  106d70:	75 0a                	jne    106d7c <strtol+0x50>
        s ++, neg = 1;
  106d72:	ff 45 08             	incl   0x8(%ebp)
  106d75:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106d7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106d80:	74 06                	je     106d88 <strtol+0x5c>
  106d82:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  106d86:	75 22                	jne    106daa <strtol+0x7e>
  106d88:	8b 45 08             	mov    0x8(%ebp),%eax
  106d8b:	0f b6 00             	movzbl (%eax),%eax
  106d8e:	3c 30                	cmp    $0x30,%al
  106d90:	75 18                	jne    106daa <strtol+0x7e>
  106d92:	8b 45 08             	mov    0x8(%ebp),%eax
  106d95:	40                   	inc    %eax
  106d96:	0f b6 00             	movzbl (%eax),%eax
  106d99:	3c 78                	cmp    $0x78,%al
  106d9b:	75 0d                	jne    106daa <strtol+0x7e>
        s += 2, base = 16;
  106d9d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  106da1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  106da8:	eb 29                	jmp    106dd3 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  106daa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106dae:	75 16                	jne    106dc6 <strtol+0x9a>
  106db0:	8b 45 08             	mov    0x8(%ebp),%eax
  106db3:	0f b6 00             	movzbl (%eax),%eax
  106db6:	3c 30                	cmp    $0x30,%al
  106db8:	75 0c                	jne    106dc6 <strtol+0x9a>
        s ++, base = 8;
  106dba:	ff 45 08             	incl   0x8(%ebp)
  106dbd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  106dc4:	eb 0d                	jmp    106dd3 <strtol+0xa7>
    }
    else if (base == 0) {
  106dc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106dca:	75 07                	jne    106dd3 <strtol+0xa7>
        base = 10;
  106dcc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  106dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  106dd6:	0f b6 00             	movzbl (%eax),%eax
  106dd9:	3c 2f                	cmp    $0x2f,%al
  106ddb:	7e 1b                	jle    106df8 <strtol+0xcc>
  106ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  106de0:	0f b6 00             	movzbl (%eax),%eax
  106de3:	3c 39                	cmp    $0x39,%al
  106de5:	7f 11                	jg     106df8 <strtol+0xcc>
            dig = *s - '0';
  106de7:	8b 45 08             	mov    0x8(%ebp),%eax
  106dea:	0f b6 00             	movzbl (%eax),%eax
  106ded:	0f be c0             	movsbl %al,%eax
  106df0:	83 e8 30             	sub    $0x30,%eax
  106df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106df6:	eb 48                	jmp    106e40 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  106df8:	8b 45 08             	mov    0x8(%ebp),%eax
  106dfb:	0f b6 00             	movzbl (%eax),%eax
  106dfe:	3c 60                	cmp    $0x60,%al
  106e00:	7e 1b                	jle    106e1d <strtol+0xf1>
  106e02:	8b 45 08             	mov    0x8(%ebp),%eax
  106e05:	0f b6 00             	movzbl (%eax),%eax
  106e08:	3c 7a                	cmp    $0x7a,%al
  106e0a:	7f 11                	jg     106e1d <strtol+0xf1>
            dig = *s - 'a' + 10;
  106e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  106e0f:	0f b6 00             	movzbl (%eax),%eax
  106e12:	0f be c0             	movsbl %al,%eax
  106e15:	83 e8 57             	sub    $0x57,%eax
  106e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106e1b:	eb 23                	jmp    106e40 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  106e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  106e20:	0f b6 00             	movzbl (%eax),%eax
  106e23:	3c 40                	cmp    $0x40,%al
  106e25:	7e 3b                	jle    106e62 <strtol+0x136>
  106e27:	8b 45 08             	mov    0x8(%ebp),%eax
  106e2a:	0f b6 00             	movzbl (%eax),%eax
  106e2d:	3c 5a                	cmp    $0x5a,%al
  106e2f:	7f 31                	jg     106e62 <strtol+0x136>
            dig = *s - 'A' + 10;
  106e31:	8b 45 08             	mov    0x8(%ebp),%eax
  106e34:	0f b6 00             	movzbl (%eax),%eax
  106e37:	0f be c0             	movsbl %al,%eax
  106e3a:	83 e8 37             	sub    $0x37,%eax
  106e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  106e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106e43:	3b 45 10             	cmp    0x10(%ebp),%eax
  106e46:	7d 19                	jge    106e61 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106e48:	ff 45 08             	incl   0x8(%ebp)
  106e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106e4e:	0f af 45 10          	imul   0x10(%ebp),%eax
  106e52:	89 c2                	mov    %eax,%edx
  106e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106e57:	01 d0                	add    %edx,%eax
  106e59:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106e5c:	e9 72 ff ff ff       	jmp    106dd3 <strtol+0xa7>
            break;
  106e61:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  106e62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106e66:	74 08                	je     106e70 <strtol+0x144>
        *endptr = (char *) s;
  106e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  106e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  106e6e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  106e70:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106e74:	74 07                	je     106e7d <strtol+0x151>
  106e76:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106e79:	f7 d8                	neg    %eax
  106e7b:	eb 03                	jmp    106e80 <strtol+0x154>
  106e7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  106e80:	89 ec                	mov    %ebp,%esp
  106e82:	5d                   	pop    %ebp
  106e83:	c3                   	ret    

00106e84 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106e84:	55                   	push   %ebp
  106e85:	89 e5                	mov    %esp,%ebp
  106e87:	83 ec 28             	sub    $0x28,%esp
  106e8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
  106e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106e90:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106e93:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  106e97:	8b 45 08             	mov    0x8(%ebp),%eax
  106e9a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  106e9d:	88 55 f7             	mov    %dl,-0x9(%ebp)
  106ea0:	8b 45 10             	mov    0x10(%ebp),%eax
  106ea3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106ea6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  106ea9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  106ead:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106eb0:	89 d7                	mov    %edx,%edi
  106eb2:	f3 aa                	rep stos %al,%es:(%edi)
  106eb4:	89 fa                	mov    %edi,%edx
  106eb6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  106eb9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  106ebc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106ebf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  106ec2:	89 ec                	mov    %ebp,%esp
  106ec4:	5d                   	pop    %ebp
  106ec5:	c3                   	ret    

00106ec6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  106ec6:	55                   	push   %ebp
  106ec7:	89 e5                	mov    %esp,%ebp
  106ec9:	57                   	push   %edi
  106eca:	56                   	push   %esi
  106ecb:	53                   	push   %ebx
  106ecc:	83 ec 30             	sub    $0x30,%esp
  106ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  106ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  106ed8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106edb:	8b 45 10             	mov    0x10(%ebp),%eax
  106ede:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  106ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106ee4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  106ee7:	73 42                	jae    106f2b <memmove+0x65>
  106ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106ef8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106efe:	c1 e8 02             	shr    $0x2,%eax
  106f01:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106f03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106f09:	89 d7                	mov    %edx,%edi
  106f0b:	89 c6                	mov    %eax,%esi
  106f0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106f0f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  106f12:	83 e1 03             	and    $0x3,%ecx
  106f15:	74 02                	je     106f19 <memmove+0x53>
  106f17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106f19:	89 f0                	mov    %esi,%eax
  106f1b:	89 fa                	mov    %edi,%edx
  106f1d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  106f20:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  106f23:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  106f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  106f29:	eb 36                	jmp    106f61 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106f2e:	8d 50 ff             	lea    -0x1(%eax),%edx
  106f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106f34:	01 c2                	add    %eax,%edx
  106f36:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106f39:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106f3f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  106f42:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106f45:	89 c1                	mov    %eax,%ecx
  106f47:	89 d8                	mov    %ebx,%eax
  106f49:	89 d6                	mov    %edx,%esi
  106f4b:	89 c7                	mov    %eax,%edi
  106f4d:	fd                   	std    
  106f4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106f50:	fc                   	cld    
  106f51:	89 f8                	mov    %edi,%eax
  106f53:	89 f2                	mov    %esi,%edx
  106f55:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106f58:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106f5b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  106f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106f61:	83 c4 30             	add    $0x30,%esp
  106f64:	5b                   	pop    %ebx
  106f65:	5e                   	pop    %esi
  106f66:	5f                   	pop    %edi
  106f67:	5d                   	pop    %ebp
  106f68:	c3                   	ret    

00106f69 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106f69:	55                   	push   %ebp
  106f6a:	89 e5                	mov    %esp,%ebp
  106f6c:	57                   	push   %edi
  106f6d:	56                   	push   %esi
  106f6e:	83 ec 20             	sub    $0x20,%esp
  106f71:	8b 45 08             	mov    0x8(%ebp),%eax
  106f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106f77:	8b 45 0c             	mov    0xc(%ebp),%eax
  106f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  106f80:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106f86:	c1 e8 02             	shr    $0x2,%eax
  106f89:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106f91:	89 d7                	mov    %edx,%edi
  106f93:	89 c6                	mov    %eax,%esi
  106f95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106f97:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106f9a:	83 e1 03             	and    $0x3,%ecx
  106f9d:	74 02                	je     106fa1 <memcpy+0x38>
  106f9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106fa1:	89 f0                	mov    %esi,%eax
  106fa3:	89 fa                	mov    %edi,%edx
  106fa5:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106fa8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106fab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  106fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106fb1:	83 c4 20             	add    $0x20,%esp
  106fb4:	5e                   	pop    %esi
  106fb5:	5f                   	pop    %edi
  106fb6:	5d                   	pop    %ebp
  106fb7:	c3                   	ret    

00106fb8 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  106fb8:	55                   	push   %ebp
  106fb9:	89 e5                	mov    %esp,%ebp
  106fbb:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  106fc1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  106fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  106fc7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  106fca:	eb 2e                	jmp    106ffa <memcmp+0x42>
        if (*s1 != *s2) {
  106fcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106fcf:	0f b6 10             	movzbl (%eax),%edx
  106fd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106fd5:	0f b6 00             	movzbl (%eax),%eax
  106fd8:	38 c2                	cmp    %al,%dl
  106fda:	74 18                	je     106ff4 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  106fdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106fdf:	0f b6 00             	movzbl (%eax),%eax
  106fe2:	0f b6 d0             	movzbl %al,%edx
  106fe5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106fe8:	0f b6 00             	movzbl (%eax),%eax
  106feb:	0f b6 c8             	movzbl %al,%ecx
  106fee:	89 d0                	mov    %edx,%eax
  106ff0:	29 c8                	sub    %ecx,%eax
  106ff2:	eb 18                	jmp    10700c <memcmp+0x54>
        }
        s1 ++, s2 ++;
  106ff4:	ff 45 fc             	incl   -0x4(%ebp)
  106ff7:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  106ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  106ffd:	8d 50 ff             	lea    -0x1(%eax),%edx
  107000:	89 55 10             	mov    %edx,0x10(%ebp)
  107003:	85 c0                	test   %eax,%eax
  107005:	75 c5                	jne    106fcc <memcmp+0x14>
    }
    return 0;
  107007:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10700c:	89 ec                	mov    %ebp,%esp
  10700e:	5d                   	pop    %ebp
  10700f:	c3                   	ret    

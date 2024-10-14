
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a4010113          	addi	sp,sp,-1472 # 80008a40 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ae70713          	addi	a4,a4,-1874 # 80008900 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	0ac78793          	addi	a5,a5,172 # 80006110 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd960f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	508080e7          	jalr	1288(ra) # 80002634 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8b650513          	addi	a0,a0,-1866 # 80010a40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8a648493          	addi	s1,s1,-1882 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	93690913          	addi	s2,s2,-1738 # 80010ad8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	812080e7          	jalr	-2030(ra) # 800019d2 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	2b6080e7          	jalr	694(ra) # 8000247e <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	ff6080e7          	jalr	-10(ra) # 800021cc <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	3cc080e7          	jalr	972(ra) # 800025de <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	81a50513          	addi	a0,a0,-2022 # 80010a40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	80450513          	addi	a0,a0,-2044 # 80010a40 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72323          	sw	a5,-1946(a4) # 80010ad8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	77450513          	addi	a0,a0,1908 # 80010a40 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	398080e7          	jalr	920(ra) # 8000268a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	74650513          	addi	a0,a0,1862 # 80010a40 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	72270713          	addi	a4,a4,1826 # 80010a40 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	6f878793          	addi	a5,a5,1784 # 80010a40 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7627a783          	lw	a5,1890(a5) # 80010ad8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6b670713          	addi	a4,a4,1718 # 80010a40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6a648493          	addi	s1,s1,1702 # 80010a40 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	66a70713          	addi	a4,a4,1642 # 80010a40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72a23          	sw	a5,1780(a4) # 80010ae0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	62e78793          	addi	a5,a5,1582 # 80010a40 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7a323          	sw	a2,1702(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	69a50513          	addi	a0,a0,1690 # 80010ad8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	dea080e7          	jalr	-534(ra) # 80002230 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5e050513          	addi	a0,a0,1504 # 80010a40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00024797          	auipc	a5,0x24
    8000047c:	be078793          	addi	a5,a5,-1056 # 80024058 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5a07ab23          	sw	zero,1462(a5) # 80010b00 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72123          	sw	a5,834(a4) # 800088c0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	546dad83          	lw	s11,1350(s11) # 80010b00 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	4f050513          	addi	a0,a0,1264 # 80010ae8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	39250513          	addi	a0,a0,914 # 80010ae8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	37648493          	addi	s1,s1,886 # 80010ae8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	33650513          	addi	a0,a0,822 # 80010b08 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0c27a783          	lw	a5,194(a5) # 800088c0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0927b783          	ld	a5,146(a5) # 800088c8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	09273703          	ld	a4,146(a4) # 800088d0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2a8a0a13          	addi	s4,s4,680 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	06048493          	addi	s1,s1,96 # 800088c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	06098993          	addi	s3,s3,96 # 800088d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	99e080e7          	jalr	-1634(ra) # 80002230 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	23a50513          	addi	a0,a0,570 # 80010b08 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fe27a783          	lw	a5,-30(a5) # 800088c0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fe873703          	ld	a4,-24(a4) # 800088d0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fd87b783          	ld	a5,-40(a5) # 800088c8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	20c98993          	addi	s3,s3,524 # 80010b08 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fc448493          	addi	s1,s1,-60 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fc490913          	addi	s2,s2,-60 # 800088d0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	8b0080e7          	jalr	-1872(ra) # 800021cc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1d648493          	addi	s1,s1,470 # 80010b08 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7b523          	sd	a4,-118(a5) # 800088d0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	14c48493          	addi	s1,s1,332 # 80010b08 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00024797          	auipc	a5,0x24
    80000a02:	7f278793          	addi	a5,a5,2034 # 800251f0 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	12290913          	addi	s2,s2,290 # 80010b40 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	08650513          	addi	a0,a0,134 # 80010b40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00024517          	auipc	a0,0x24
    80000ad2:	72250513          	addi	a0,a0,1826 # 800251f0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	05048493          	addi	s1,s1,80 # 80010b40 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	03850513          	addi	a0,a0,56 # 80010b40 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	00c50513          	addi	a0,a0,12 # 80010b40 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e46080e7          	jalr	-442(ra) # 800019b6 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e14080e7          	jalr	-492(ra) # 800019b6 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e08080e7          	jalr	-504(ra) # 800019b6 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	df0080e7          	jalr	-528(ra) # 800019b6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	db0080e7          	jalr	-592(ra) # 800019b6 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d84080e7          	jalr	-636(ra) # 800019b6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b26080e7          	jalr	-1242(ra) # 800019a6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a5070713          	addi	a4,a4,-1456 # 800088d8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b0a080e7          	jalr	-1270(ra) # 800019a6 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	ab6080e7          	jalr	-1354(ra) # 80002974 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	28a080e7          	jalr	650(ra) # 80006150 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	064080e7          	jalr	100(ra) # 80001f32 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9c4080e7          	jalr	-1596(ra) # 800018f2 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	a16080e7          	jalr	-1514(ra) # 8000294c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a36080e7          	jalr	-1482(ra) # 80002974 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	1f4080e7          	jalr	500(ra) # 8000613a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	202080e7          	jalr	514(ra) # 80006150 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	39e080e7          	jalr	926(ra) # 800032f4 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a42080e7          	jalr	-1470(ra) # 800039a0 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	9e0080e7          	jalr	-1568(ra) # 80004946 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	2ea080e7          	jalr	746(ra) # 80006258 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d86080e7          	jalr	-634(ra) # 80001cfc <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72a23          	sw	a5,-1708(a4) # 800088d8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9487b783          	ld	a5,-1720(a5) # 800088e0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	62e080e7          	jalr	1582(ra) # 8000185c <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7b623          	sd	a0,1676(a5) # 800088e0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <random>:
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

////////////////////////
uint random(void) {
    80001836:	1141                	addi	sp,sp,-16
    80001838:	e422                	sd	s0,8(sp)
    8000183a:	0800                	addi	s0,sp,16
    static uint seed = 987654321; // Seed value
    seed = (seed) % 0x7fffffff;
    8000183c:	00007717          	auipc	a4,0x7
    80001840:	03870713          	addi	a4,a4,56 # 80008874 <seed.2>
    80001844:	4308                	lw	a0,0(a4)
    80001846:	800007b7          	lui	a5,0x80000
    8000184a:	fff7c793          	not	a5,a5
    8000184e:	02f5753b          	remuw	a0,a0,a5
    80001852:	c308                	sw	a0,0(a4)
    return seed;
}
    80001854:	2501                	sext.w	a0,a0
    80001856:	6422                	ld	s0,8(sp)
    80001858:	0141                	addi	sp,sp,16
    8000185a:	8082                	ret

000000008000185c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    8000185c:	7139                	addi	sp,sp,-64
    8000185e:	fc06                	sd	ra,56(sp)
    80001860:	f822                	sd	s0,48(sp)
    80001862:	f426                	sd	s1,40(sp)
    80001864:	f04a                	sd	s2,32(sp)
    80001866:	ec4e                	sd	s3,24(sp)
    80001868:	e852                	sd	s4,16(sp)
    8000186a:	e456                	sd	s5,8(sp)
    8000186c:	e05a                	sd	s6,0(sp)
    8000186e:	0080                	addi	s0,sp,64
    80001870:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001872:	0000f497          	auipc	s1,0xf
    80001876:	71e48493          	addi	s1,s1,1822 # 80010f90 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	8b26                	mv	s6,s1
    8000187c:	00006a97          	auipc	s5,0x6
    80001880:	784a8a93          	addi	s5,s5,1924 # 80008000 <etext>
    80001884:	04000937          	lui	s2,0x4000
    80001888:	197d                	addi	s2,s2,-1
    8000188a:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000188c:	00018a17          	auipc	s4,0x18
    80001890:	504a0a13          	addi	s4,s4,1284 # 80019d90 <tickslock>
    char *pa = kalloc();
    80001894:	fffff097          	auipc	ra,0xfffff
    80001898:	252080e7          	jalr	594(ra) # 80000ae6 <kalloc>
    8000189c:	862a                	mv	a2,a0
    if (pa == 0)
    8000189e:	c131                	beqz	a0,800018e2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800018a0:	416485b3          	sub	a1,s1,s6
    800018a4:	858d                	srai	a1,a1,0x3
    800018a6:	000ab783          	ld	a5,0(s5)
    800018aa:	02f585b3          	mul	a1,a1,a5
    800018ae:	2585                	addiw	a1,a1,1
    800018b0:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018b4:	4719                	li	a4,6
    800018b6:	6685                	lui	a3,0x1
    800018b8:	40b905b3          	sub	a1,s2,a1
    800018bc:	854e                	mv	a0,s3
    800018be:	00000097          	auipc	ra,0x0
    800018c2:	880080e7          	jalr	-1920(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018c6:	23848493          	addi	s1,s1,568
    800018ca:	fd4495e3          	bne	s1,s4,80001894 <proc_mapstacks+0x38>
  }
}
    800018ce:	70e2                	ld	ra,56(sp)
    800018d0:	7442                	ld	s0,48(sp)
    800018d2:	74a2                	ld	s1,40(sp)
    800018d4:	7902                	ld	s2,32(sp)
    800018d6:	69e2                	ld	s3,24(sp)
    800018d8:	6a42                	ld	s4,16(sp)
    800018da:	6aa2                	ld	s5,8(sp)
    800018dc:	6b02                	ld	s6,0(sp)
    800018de:	6121                	addi	sp,sp,64
    800018e0:	8082                	ret
      panic("kalloc");
    800018e2:	00007517          	auipc	a0,0x7
    800018e6:	8f650513          	addi	a0,a0,-1802 # 800081d8 <digits+0x198>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	c54080e7          	jalr	-940(ra) # 8000053e <panic>

00000000800018f2 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018f2:	7139                	addi	sp,sp,-64
    800018f4:	fc06                	sd	ra,56(sp)
    800018f6:	f822                	sd	s0,48(sp)
    800018f8:	f426                	sd	s1,40(sp)
    800018fa:	f04a                	sd	s2,32(sp)
    800018fc:	ec4e                	sd	s3,24(sp)
    800018fe:	e852                	sd	s4,16(sp)
    80001900:	e456                	sd	s5,8(sp)
    80001902:	e05a                	sd	s6,0(sp)
    80001904:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001906:	00007597          	auipc	a1,0x7
    8000190a:	8da58593          	addi	a1,a1,-1830 # 800081e0 <digits+0x1a0>
    8000190e:	0000f517          	auipc	a0,0xf
    80001912:	25250513          	addi	a0,a0,594 # 80010b60 <pid_lock>
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	230080e7          	jalr	560(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000191e:	00007597          	auipc	a1,0x7
    80001922:	8ca58593          	addi	a1,a1,-1846 # 800081e8 <digits+0x1a8>
    80001926:	0000f517          	auipc	a0,0xf
    8000192a:	25250513          	addi	a0,a0,594 # 80010b78 <wait_lock>
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	218080e7          	jalr	536(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001936:	0000f497          	auipc	s1,0xf
    8000193a:	65a48493          	addi	s1,s1,1626 # 80010f90 <proc>
  {
    initlock(&p->lock, "proc");
    8000193e:	00007b17          	auipc	s6,0x7
    80001942:	8bab0b13          	addi	s6,s6,-1862 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001946:	8aa6                	mv	s5,s1
    80001948:	00006a17          	auipc	s4,0x6
    8000194c:	6b8a0a13          	addi	s4,s4,1720 # 80008000 <etext>
    80001950:	04000937          	lui	s2,0x4000
    80001954:	197d                	addi	s2,s2,-1
    80001956:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001958:	00018997          	auipc	s3,0x18
    8000195c:	43898993          	addi	s3,s3,1080 # 80019d90 <tickslock>
    initlock(&p->lock, "proc");
    80001960:	85da                	mv	a1,s6
    80001962:	8526                	mv	a0,s1
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	1e2080e7          	jalr	482(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    8000196c:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001970:	415487b3          	sub	a5,s1,s5
    80001974:	878d                	srai	a5,a5,0x3
    80001976:	000a3703          	ld	a4,0(s4)
    8000197a:	02e787b3          	mul	a5,a5,a4
    8000197e:	2785                	addiw	a5,a5,1
    80001980:	00d7979b          	slliw	a5,a5,0xd
    80001984:	40f907b3          	sub	a5,s2,a5
    80001988:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000198a:	23848493          	addi	s1,s1,568
    8000198e:	fd3499e3          	bne	s1,s3,80001960 <procinit+0x6e>
  }
}
    80001992:	70e2                	ld	ra,56(sp)
    80001994:	7442                	ld	s0,48(sp)
    80001996:	74a2                	ld	s1,40(sp)
    80001998:	7902                	ld	s2,32(sp)
    8000199a:	69e2                	ld	s3,24(sp)
    8000199c:	6a42                	ld	s4,16(sp)
    8000199e:	6aa2                	ld	s5,8(sp)
    800019a0:	6b02                	ld	s6,0(sp)
    800019a2:	6121                	addi	sp,sp,64
    800019a4:	8082                	ret

00000000800019a6 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    800019a6:	1141                	addi	sp,sp,-16
    800019a8:	e422                	sd	s0,8(sp)
    800019aa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ac:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ae:	2501                	sext.w	a0,a0
    800019b0:	6422                	ld	s0,8(sp)
    800019b2:	0141                	addi	sp,sp,16
    800019b4:	8082                	ret

00000000800019b6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e422                	sd	s0,8(sp)
    800019ba:	0800                	addi	s0,sp,16
    800019bc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019be:	2781                	sext.w	a5,a5
    800019c0:	079e                	slli	a5,a5,0x7
  return c;
}
    800019c2:	0000f517          	auipc	a0,0xf
    800019c6:	1ce50513          	addi	a0,a0,462 # 80010b90 <cpus>
    800019ca:	953e                	add	a0,a0,a5
    800019cc:	6422                	ld	s0,8(sp)
    800019ce:	0141                	addi	sp,sp,16
    800019d0:	8082                	ret

00000000800019d2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019d2:	1101                	addi	sp,sp,-32
    800019d4:	ec06                	sd	ra,24(sp)
    800019d6:	e822                	sd	s0,16(sp)
    800019d8:	e426                	sd	s1,8(sp)
    800019da:	1000                	addi	s0,sp,32
  push_off();
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	1ae080e7          	jalr	430(ra) # 80000b8a <push_off>
    800019e4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019e6:	2781                	sext.w	a5,a5
    800019e8:	079e                	slli	a5,a5,0x7
    800019ea:	0000f717          	auipc	a4,0xf
    800019ee:	17670713          	addi	a4,a4,374 # 80010b60 <pid_lock>
    800019f2:	97ba                	add	a5,a5,a4
    800019f4:	7b84                	ld	s1,48(a5)
  pop_off();
    800019f6:	fffff097          	auipc	ra,0xfffff
    800019fa:	234080e7          	jalr	564(ra) # 80000c2a <pop_off>
  return p;
}
    800019fe:	8526                	mv	a0,s1
    80001a00:	60e2                	ld	ra,24(sp)
    80001a02:	6442                	ld	s0,16(sp)
    80001a04:	64a2                	ld	s1,8(sp)
    80001a06:	6105                	addi	sp,sp,32
    80001a08:	8082                	ret

0000000080001a0a <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a0a:	1141                	addi	sp,sp,-16
    80001a0c:	e406                	sd	ra,8(sp)
    80001a0e:	e022                	sd	s0,0(sp)
    80001a10:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	fc0080e7          	jalr	-64(ra) # 800019d2 <myproc>
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	270080e7          	jalr	624(ra) # 80000c8a <release>

  if (first)
    80001a22:	00007797          	auipc	a5,0x7
    80001a26:	e4e7a783          	lw	a5,-434(a5) # 80008870 <first.1>
    80001a2a:	eb89                	bnez	a5,80001a3c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a2c:	00001097          	auipc	ra,0x1
    80001a30:	f60080e7          	jalr	-160(ra) # 8000298c <usertrapret>
}
    80001a34:	60a2                	ld	ra,8(sp)
    80001a36:	6402                	ld	s0,0(sp)
    80001a38:	0141                	addi	sp,sp,16
    80001a3a:	8082                	ret
    first = 0;
    80001a3c:	00007797          	auipc	a5,0x7
    80001a40:	e207aa23          	sw	zero,-460(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a44:	4505                	li	a0,1
    80001a46:	00002097          	auipc	ra,0x2
    80001a4a:	eda080e7          	jalr	-294(ra) # 80003920 <fsinit>
    80001a4e:	bff9                	j	80001a2c <forkret+0x22>

0000000080001a50 <allocpid>:
{
    80001a50:	1101                	addi	sp,sp,-32
    80001a52:	ec06                	sd	ra,24(sp)
    80001a54:	e822                	sd	s0,16(sp)
    80001a56:	e426                	sd	s1,8(sp)
    80001a58:	e04a                	sd	s2,0(sp)
    80001a5a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a5c:	0000f917          	auipc	s2,0xf
    80001a60:	10490913          	addi	s2,s2,260 # 80010b60 <pid_lock>
    80001a64:	854a                	mv	a0,s2
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	170080e7          	jalr	368(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a6e:	00007797          	auipc	a5,0x7
    80001a72:	e0a78793          	addi	a5,a5,-502 # 80008878 <nextpid>
    80001a76:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a78:	0014871b          	addiw	a4,s1,1
    80001a7c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a7e:	854a                	mv	a0,s2
    80001a80:	fffff097          	auipc	ra,0xfffff
    80001a84:	20a080e7          	jalr	522(ra) # 80000c8a <release>
}
    80001a88:	8526                	mv	a0,s1
    80001a8a:	60e2                	ld	ra,24(sp)
    80001a8c:	6442                	ld	s0,16(sp)
    80001a8e:	64a2                	ld	s1,8(sp)
    80001a90:	6902                	ld	s2,0(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <proc_pagetable>:
{
    80001a96:	1101                	addi	sp,sp,-32
    80001a98:	ec06                	sd	ra,24(sp)
    80001a9a:	e822                	sd	s0,16(sp)
    80001a9c:	e426                	sd	s1,8(sp)
    80001a9e:	e04a                	sd	s2,0(sp)
    80001aa0:	1000                	addi	s0,sp,32
    80001aa2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa4:	00000097          	auipc	ra,0x0
    80001aa8:	884080e7          	jalr	-1916(ra) # 80001328 <uvmcreate>
    80001aac:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001aae:	c121                	beqz	a0,80001aee <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ab0:	4729                	li	a4,10
    80001ab2:	00005697          	auipc	a3,0x5
    80001ab6:	54e68693          	addi	a3,a3,1358 # 80007000 <_trampoline>
    80001aba:	6605                	lui	a2,0x1
    80001abc:	040005b7          	lui	a1,0x4000
    80001ac0:	15fd                	addi	a1,a1,-1
    80001ac2:	05b2                	slli	a1,a1,0xc
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	5da080e7          	jalr	1498(ra) # 8000109e <mappages>
    80001acc:	02054863          	bltz	a0,80001afc <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ad0:	4719                	li	a4,6
    80001ad2:	05893683          	ld	a3,88(s2)
    80001ad6:	6605                	lui	a2,0x1
    80001ad8:	020005b7          	lui	a1,0x2000
    80001adc:	15fd                	addi	a1,a1,-1
    80001ade:	05b6                	slli	a1,a1,0xd
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	5bc080e7          	jalr	1468(ra) # 8000109e <mappages>
    80001aea:	02054163          	bltz	a0,80001b0c <proc_pagetable+0x76>
}
    80001aee:	8526                	mv	a0,s1
    80001af0:	60e2                	ld	ra,24(sp)
    80001af2:	6442                	ld	s0,16(sp)
    80001af4:	64a2                	ld	s1,8(sp)
    80001af6:	6902                	ld	s2,0(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	b7d5                	j	80001aee <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0c:	4681                	li	a3,0
    80001b0e:	4605                	li	a2,1
    80001b10:	040005b7          	lui	a1,0x4000
    80001b14:	15fd                	addi	a1,a1,-1
    80001b16:	05b2                	slli	a1,a1,0xc
    80001b18:	8526                	mv	a0,s1
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	74a080e7          	jalr	1866(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b22:	4581                	li	a1,0
    80001b24:	8526                	mv	a0,s1
    80001b26:	00000097          	auipc	ra,0x0
    80001b2a:	a06080e7          	jalr	-1530(ra) # 8000152c <uvmfree>
    return 0;
    80001b2e:	4481                	li	s1,0
    80001b30:	bf7d                	j	80001aee <proc_pagetable+0x58>

0000000080001b32 <proc_freepagetable>:
{
    80001b32:	1101                	addi	sp,sp,-32
    80001b34:	ec06                	sd	ra,24(sp)
    80001b36:	e822                	sd	s0,16(sp)
    80001b38:	e426                	sd	s1,8(sp)
    80001b3a:	e04a                	sd	s2,0(sp)
    80001b3c:	1000                	addi	s0,sp,32
    80001b3e:	84aa                	mv	s1,a0
    80001b40:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b42:	4681                	li	a3,0
    80001b44:	4605                	li	a2,1
    80001b46:	040005b7          	lui	a1,0x4000
    80001b4a:	15fd                	addi	a1,a1,-1
    80001b4c:	05b2                	slli	a1,a1,0xc
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	716080e7          	jalr	1814(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b56:	4681                	li	a3,0
    80001b58:	4605                	li	a2,1
    80001b5a:	020005b7          	lui	a1,0x2000
    80001b5e:	15fd                	addi	a1,a1,-1
    80001b60:	05b6                	slli	a1,a1,0xd
    80001b62:	8526                	mv	a0,s1
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	700080e7          	jalr	1792(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b6c:	85ca                	mv	a1,s2
    80001b6e:	8526                	mv	a0,s1
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	9bc080e7          	jalr	-1604(ra) # 8000152c <uvmfree>
}
    80001b78:	60e2                	ld	ra,24(sp)
    80001b7a:	6442                	ld	s0,16(sp)
    80001b7c:	64a2                	ld	s1,8(sp)
    80001b7e:	6902                	ld	s2,0(sp)
    80001b80:	6105                	addi	sp,sp,32
    80001b82:	8082                	ret

0000000080001b84 <freeproc>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
    80001b8e:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b90:	6d28                	ld	a0,88(a0)
    80001b92:	c509                	beqz	a0,80001b9c <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	e56080e7          	jalr	-426(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b9c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ba0:	68a8                	ld	a0,80(s1)
    80001ba2:	c511                	beqz	a0,80001bae <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ba4:	64ac                	ld	a1,72(s1)
    80001ba6:	00000097          	auipc	ra,0x0
    80001baa:	f8c080e7          	jalr	-116(ra) # 80001b32 <proc_freepagetable>
  p->pagetable = 0;
    80001bae:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bb2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bb6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bba:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bbe:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bc2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bca:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bce:	0004ac23          	sw	zero,24(s1)
}
    80001bd2:	60e2                	ld	ra,24(sp)
    80001bd4:	6442                	ld	s0,16(sp)
    80001bd6:	64a2                	ld	s1,8(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <allocproc>:
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	e04a                	sd	s2,0(sp)
    80001be6:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001be8:	0000f497          	auipc	s1,0xf
    80001bec:	3a848493          	addi	s1,s1,936 # 80010f90 <proc>
    80001bf0:	00018917          	auipc	s2,0x18
    80001bf4:	1a090913          	addi	s2,s2,416 # 80019d90 <tickslock>
    acquire(&p->lock);
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	fdc080e7          	jalr	-36(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001c02:	4c9c                	lw	a5,24(s1)
    80001c04:	cf81                	beqz	a5,80001c1c <allocproc+0x40>
      release(&p->lock);
    80001c06:	8526                	mv	a0,s1
    80001c08:	fffff097          	auipc	ra,0xfffff
    80001c0c:	082080e7          	jalr	130(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c10:	23848493          	addi	s1,s1,568
    80001c14:	ff2492e3          	bne	s1,s2,80001bf8 <allocproc+0x1c>
  return 0;
    80001c18:	4481                	li	s1,0
    80001c1a:	a055                	j	80001cbe <allocproc+0xe2>
  p->pid = allocpid();
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	e34080e7          	jalr	-460(ra) # 80001a50 <allocpid>
    80001c24:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c26:	4785                	li	a5,1
    80001c28:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	ebc080e7          	jalr	-324(ra) # 80000ae6 <kalloc>
    80001c32:	892a                	mv	s2,a0
    80001c34:	eca8                	sd	a0,88(s1)
    80001c36:	c959                	beqz	a0,80001ccc <allocproc+0xf0>
  p->pagetable = proc_pagetable(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e5c080e7          	jalr	-420(ra) # 80001a96 <proc_pagetable>
    80001c42:	892a                	mv	s2,a0
    80001c44:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c46:	cd59                	beqz	a0,80001ce4 <allocproc+0x108>
  memset(&p->context, 0, sizeof(p->context));
    80001c48:	07000613          	li	a2,112
    80001c4c:	4581                	li	a1,0
    80001c4e:	06048513          	addi	a0,s1,96
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	080080e7          	jalr	128(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c5a:	00000797          	auipc	a5,0x0
    80001c5e:	db078793          	addi	a5,a5,-592 # 80001a0a <forkret>
    80001c62:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c64:	60bc                	ld	a5,64(s1)
    80001c66:	6705                	lui	a4,0x1
    80001c68:	97ba                	add	a5,a5,a4
    80001c6a:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c6c:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c70:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c74:	00007797          	auipc	a5,0x7
    80001c78:	c7c7a783          	lw	a5,-900(a5) # 800088f0 <ticks>
    80001c7c:	16f4a623          	sw	a5,364(s1)
  p->tickets = 1;  // Default number of tickets
    80001c80:	4705                	li	a4,1
    80001c82:	16e4aa23          	sw	a4,372(s1)
  p->priority = 0; // Start at highest priority
    80001c86:	1604ac23          	sw	zero,376(s1)
  p->ticks_used = 0; // Reset ticks used
    80001c8a:	1604ae23          	sw	zero,380(s1)
  p->arrival_time = ticks; // Record arrival time
    80001c8e:	18f4a023          	sw	a5,384(s1)
  for(int i=0; i<32;i++)
    80001c92:	00018797          	auipc	a5,0x18
    80001c96:	11678793          	addi	a5,a5,278 # 80019da8 <syscall_counts>
    80001c9a:	00018717          	auipc	a4,0x18
    80001c9e:	18e70713          	addi	a4,a4,398 # 80019e28 <bcache>
    syscall_counts[i]=0;
    80001ca2:	0007a023          	sw	zero,0(a5)
  for(int i=0; i<32;i++)
    80001ca6:	0791                	addi	a5,a5,4
    80001ca8:	fee79de3          	bne	a5,a4,80001ca2 <allocproc+0xc6>
  p->running_time=0;
    80001cac:	2204b423          	sd	zero,552(s1)
  p->handle_permission=1;
    80001cb0:	4785                	li	a5,1
    80001cb2:	22f4a023          	sw	a5,544(s1)
  p->alarm_state=0;
    80001cb6:	1a04a023          	sw	zero,416(s1)
  p->current_ticks=0;
    80001cba:	2204a823          	sw	zero,560(s1)
}
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6902                	ld	s2,0(sp)
    80001cc8:	6105                	addi	sp,sp,32
    80001cca:	8082                	ret
    freeproc(p);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	eb6080e7          	jalr	-330(ra) # 80001b84 <freeproc>
    release(&p->lock);
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	fb2080e7          	jalr	-78(ra) # 80000c8a <release>
    return 0;
    80001ce0:	84ca                	mv	s1,s2
    80001ce2:	bff1                	j	80001cbe <allocproc+0xe2>
    freeproc(p);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	00000097          	auipc	ra,0x0
    80001cea:	e9e080e7          	jalr	-354(ra) # 80001b84 <freeproc>
    release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	f9a080e7          	jalr	-102(ra) # 80000c8a <release>
    return 0;
    80001cf8:	84ca                	mv	s1,s2
    80001cfa:	b7d1                	j	80001cbe <allocproc+0xe2>

0000000080001cfc <userinit>:
{
    80001cfc:	1101                	addi	sp,sp,-32
    80001cfe:	ec06                	sd	ra,24(sp)
    80001d00:	e822                	sd	s0,16(sp)
    80001d02:	e426                	sd	s1,8(sp)
    80001d04:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	ed6080e7          	jalr	-298(ra) # 80001bdc <allocproc>
    80001d0e:	84aa                	mv	s1,a0
  initproc = p;
    80001d10:	00007797          	auipc	a5,0x7
    80001d14:	bca7bc23          	sd	a0,-1064(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d18:	03400613          	li	a2,52
    80001d1c:	00007597          	auipc	a1,0x7
    80001d20:	b6458593          	addi	a1,a1,-1180 # 80008880 <initcode>
    80001d24:	6928                	ld	a0,80(a0)
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	630080e7          	jalr	1584(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d2e:	6785                	lui	a5,0x1
    80001d30:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d32:	6cb8                	ld	a4,88(s1)
    80001d34:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d38:	6cb8                	ld	a4,88(s1)
    80001d3a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d3c:	4641                	li	a2,16
    80001d3e:	00006597          	auipc	a1,0x6
    80001d42:	4c258593          	addi	a1,a1,1218 # 80008200 <digits+0x1c0>
    80001d46:	15848513          	addi	a0,s1,344
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	0d2080e7          	jalr	210(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d52:	00006517          	auipc	a0,0x6
    80001d56:	4be50513          	addi	a0,a0,1214 # 80008210 <digits+0x1d0>
    80001d5a:	00002097          	auipc	ra,0x2
    80001d5e:	5e8080e7          	jalr	1512(ra) # 80004342 <namei>
    80001d62:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d66:	4789                	li	a5,2
    80001d68:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	f1e080e7          	jalr	-226(ra) # 80000c8a <release>
}
    80001d74:	60e2                	ld	ra,24(sp)
    80001d76:	6442                	ld	s0,16(sp)
    80001d78:	64a2                	ld	s1,8(sp)
    80001d7a:	6105                	addi	sp,sp,32
    80001d7c:	8082                	ret

0000000080001d7e <growproc>:
{
    80001d7e:	1101                	addi	sp,sp,-32
    80001d80:	ec06                	sd	ra,24(sp)
    80001d82:	e822                	sd	s0,16(sp)
    80001d84:	e426                	sd	s1,8(sp)
    80001d86:	e04a                	sd	s2,0(sp)
    80001d88:	1000                	addi	s0,sp,32
    80001d8a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	c46080e7          	jalr	-954(ra) # 800019d2 <myproc>
    80001d94:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d96:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d98:	01204c63          	bgtz	s2,80001db0 <growproc+0x32>
  else if (n < 0)
    80001d9c:	02094663          	bltz	s2,80001dc8 <growproc+0x4a>
  p->sz = sz;
    80001da0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001da2:	4501                	li	a0,0
}
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6902                	ld	s2,0(sp)
    80001dac:	6105                	addi	sp,sp,32
    80001dae:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001db0:	4691                	li	a3,4
    80001db2:	00b90633          	add	a2,s2,a1
    80001db6:	6928                	ld	a0,80(a0)
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	658080e7          	jalr	1624(ra) # 80001410 <uvmalloc>
    80001dc0:	85aa                	mv	a1,a0
    80001dc2:	fd79                	bnez	a0,80001da0 <growproc+0x22>
      return -1;
    80001dc4:	557d                	li	a0,-1
    80001dc6:	bff9                	j	80001da4 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dc8:	00b90633          	add	a2,s2,a1
    80001dcc:	6928                	ld	a0,80(a0)
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	5fa080e7          	jalr	1530(ra) # 800013c8 <uvmdealloc>
    80001dd6:	85aa                	mv	a1,a0
    80001dd8:	b7e1                	j	80001da0 <growproc+0x22>

0000000080001dda <fork>:
{
    80001dda:	7139                	addi	sp,sp,-64
    80001ddc:	fc06                	sd	ra,56(sp)
    80001dde:	f822                	sd	s0,48(sp)
    80001de0:	f426                	sd	s1,40(sp)
    80001de2:	f04a                	sd	s2,32(sp)
    80001de4:	ec4e                	sd	s3,24(sp)
    80001de6:	e852                	sd	s4,16(sp)
    80001de8:	e456                	sd	s5,8(sp)
    80001dea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	be6080e7          	jalr	-1050(ra) # 800019d2 <myproc>
    80001df4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	de6080e7          	jalr	-538(ra) # 80001bdc <allocproc>
    80001dfe:	12050863          	beqz	a0,80001f2e <fork+0x154>
    80001e02:	89aa                	mv	s3,a0
  np->tickets = p->tickets; // Inherit tickets from parent
    80001e04:	174aa783          	lw	a5,372(s5)
    80001e08:	16f52a23          	sw	a5,372(a0)
  np->arrival_time = ticks; // Set arrival time
    80001e0c:	00007797          	auipc	a5,0x7
    80001e10:	ae47a783          	lw	a5,-1308(a5) # 800088f0 <ticks>
    80001e14:	18f52023          	sw	a5,384(a0)
  np->priority = 0; // Start in the highest priority queue for MLFQ
    80001e18:	16052c23          	sw	zero,376(a0)
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e1c:	048ab603          	ld	a2,72(s5)
    80001e20:	692c                	ld	a1,80(a0)
    80001e22:	050ab503          	ld	a0,80(s5)
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	73e080e7          	jalr	1854(ra) # 80001564 <uvmcopy>
    80001e2e:	04054863          	bltz	a0,80001e7e <fork+0xa4>
  np->sz = p->sz;
    80001e32:	048ab783          	ld	a5,72(s5)
    80001e36:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e3a:	058ab683          	ld	a3,88(s5)
    80001e3e:	87b6                	mv	a5,a3
    80001e40:	0589b703          	ld	a4,88(s3)
    80001e44:	12068693          	addi	a3,a3,288
    80001e48:	0007b803          	ld	a6,0(a5)
    80001e4c:	6788                	ld	a0,8(a5)
    80001e4e:	6b8c                	ld	a1,16(a5)
    80001e50:	6f90                	ld	a2,24(a5)
    80001e52:	01073023          	sd	a6,0(a4)
    80001e56:	e708                	sd	a0,8(a4)
    80001e58:	eb0c                	sd	a1,16(a4)
    80001e5a:	ef10                	sd	a2,24(a4)
    80001e5c:	02078793          	addi	a5,a5,32
    80001e60:	02070713          	addi	a4,a4,32
    80001e64:	fed792e3          	bne	a5,a3,80001e48 <fork+0x6e>
  np->trapframe->a0 = 0;
    80001e68:	0589b783          	ld	a5,88(s3)
    80001e6c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e70:	0d0a8493          	addi	s1,s5,208
    80001e74:	0d098913          	addi	s2,s3,208
    80001e78:	150a8a13          	addi	s4,s5,336
    80001e7c:	a00d                	j	80001e9e <fork+0xc4>
    freeproc(np);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	d04080e7          	jalr	-764(ra) # 80001b84 <freeproc>
    release(&np->lock);
    80001e88:	854e                	mv	a0,s3
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e00080e7          	jalr	-512(ra) # 80000c8a <release>
    return -1;
    80001e92:	597d                	li	s2,-1
    80001e94:	a059                	j	80001f1a <fork+0x140>
  for (i = 0; i < NOFILE; i++)
    80001e96:	04a1                	addi	s1,s1,8
    80001e98:	0921                	addi	s2,s2,8
    80001e9a:	01448b63          	beq	s1,s4,80001eb0 <fork+0xd6>
    if (p->ofile[i])
    80001e9e:	6088                	ld	a0,0(s1)
    80001ea0:	d97d                	beqz	a0,80001e96 <fork+0xbc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ea2:	00003097          	auipc	ra,0x3
    80001ea6:	b36080e7          	jalr	-1226(ra) # 800049d8 <filedup>
    80001eaa:	00a93023          	sd	a0,0(s2)
    80001eae:	b7e5                	j	80001e96 <fork+0xbc>
  np->cwd = idup(p->cwd);
    80001eb0:	150ab503          	ld	a0,336(s5)
    80001eb4:	00002097          	auipc	ra,0x2
    80001eb8:	caa080e7          	jalr	-854(ra) # 80003b5e <idup>
    80001ebc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec0:	4641                	li	a2,16
    80001ec2:	158a8593          	addi	a1,s5,344
    80001ec6:	15898513          	addi	a0,s3,344
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	f52080e7          	jalr	-174(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001ed2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ed6:	854e                	mv	a0,s3
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	db2080e7          	jalr	-590(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ee0:	0000f497          	auipc	s1,0xf
    80001ee4:	c9848493          	addi	s1,s1,-872 # 80010b78 <wait_lock>
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	cec080e7          	jalr	-788(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ef2:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	d92080e7          	jalr	-622(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f00:	854e                	mv	a0,s3
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	cd4080e7          	jalr	-812(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f0a:	4789                	li	a5,2
    80001f0c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f10:	854e                	mv	a0,s3
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d78080e7          	jalr	-648(ra) # 80000c8a <release>
}
    80001f1a:	854a                	mv	a0,s2
    80001f1c:	70e2                	ld	ra,56(sp)
    80001f1e:	7442                	ld	s0,48(sp)
    80001f20:	74a2                	ld	s1,40(sp)
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	69e2                	ld	s3,24(sp)
    80001f26:	6a42                	ld	s4,16(sp)
    80001f28:	6aa2                	ld	s5,8(sp)
    80001f2a:	6121                	addi	sp,sp,64
    80001f2c:	8082                	ret
    return -1;
    80001f2e:	597d                	li	s2,-1
    80001f30:	b7ed                	j	80001f1a <fork+0x140>

0000000080001f32 <scheduler>:
void scheduler(void) {
    80001f32:	7159                	addi	sp,sp,-112
    80001f34:	f486                	sd	ra,104(sp)
    80001f36:	f0a2                	sd	s0,96(sp)
    80001f38:	eca6                	sd	s1,88(sp)
    80001f3a:	e8ca                	sd	s2,80(sp)
    80001f3c:	e4ce                	sd	s3,72(sp)
    80001f3e:	e0d2                	sd	s4,64(sp)
    80001f40:	fc56                	sd	s5,56(sp)
    80001f42:	f85a                	sd	s6,48(sp)
    80001f44:	f45e                	sd	s7,40(sp)
    80001f46:	f062                	sd	s8,32(sp)
    80001f48:	ec66                	sd	s9,24(sp)
    80001f4a:	1880                	addi	s0,sp,112
    80001f4c:	8492                	mv	s1,tp
  int id = r_tp();
    80001f4e:	2481                	sext.w	s1,s1
  c->proc = 0;
    80001f50:	00749b13          	slli	s6,s1,0x7
    80001f54:	0000f797          	auipc	a5,0xf
    80001f58:	c0c78793          	addi	a5,a5,-1012 # 80010b60 <pid_lock>
    80001f5c:	97da                	add	a5,a5,s6
    80001f5e:	0207b823          	sd	zero,48(a5)
printf("mlfq\n");
    80001f62:	00006517          	auipc	a0,0x6
    80001f66:	2b650513          	addi	a0,a0,694 # 80008218 <digits+0x1d8>
    80001f6a:	ffffe097          	auipc	ra,0xffffe
    80001f6e:	61e080e7          	jalr	1566(ra) # 80000588 <printf>
        swtch(&c->context, &p->context);
    80001f72:	0000f797          	auipc	a5,0xf
    80001f76:	c2678793          	addi	a5,a5,-986 # 80010b98 <cpus+0x8>
    80001f7a:	9b3e                	add	s6,s6,a5
 int ticks_since_boost = 0; // Initialize outside the loop to track ticks globally
    80001f7c:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001f7e:	00018917          	auipc	s2,0x18
    80001f82:	e1290913          	addi	s2,s2,-494 # 80019d90 <tickslock>
        c->proc = p;
    80001f86:	049e                	slli	s1,s1,0x7
    80001f88:	0000fa97          	auipc	s5,0xf
    80001f8c:	bd8a8a93          	addi	s5,s5,-1064 # 80010b60 <pid_lock>
    80001f90:	9aa6                	add	s5,s5,s1
        printf("(%d, %d, %d), \n", p->pid, i + 1, ticks);
    80001f92:	00007b97          	auipc	s7,0x7
    80001f96:	95eb8b93          	addi	s7,s7,-1698 # 800088f0 <ticks>
    80001f9a:	a8d5                	j	8000208e <scheduler+0x15c>
      release(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	cec080e7          	jalr	-788(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001fa6:	23848493          	addi	s1,s1,568
    80001faa:	09248663          	beq	s1,s2,80002036 <scheduler+0x104>
      acquire(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	c26080e7          	jalr	-986(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE && p->priority == i) {
    80001fb8:	4c9c                	lw	a5,24(s1)
    80001fba:	ff3791e3          	bne	a5,s3,80001f9c <scheduler+0x6a>
    80001fbe:	1784a783          	lw	a5,376(s1)
    80001fc2:	fd479de3          	bne	a5,s4,80001f9c <scheduler+0x6a>
        p->state = RUNNING;
    80001fc6:	0194ac23          	sw	s9,24(s1)
        c->proc = p;
    80001fca:	029ab823          	sd	s1,48(s5)
        printf("(%d, %d, %d), \n", p->pid, i + 1, ticks);
    80001fce:	000ba683          	lw	a3,0(s7)
    80001fd2:	001a061b          	addiw	a2,s4,1
    80001fd6:	588c                	lw	a1,48(s1)
    80001fd8:	00006517          	auipc	a0,0x6
    80001fdc:	24850513          	addi	a0,a0,584 # 80008220 <digits+0x1e0>
    80001fe0:	ffffe097          	auipc	ra,0xffffe
    80001fe4:	5a8080e7          	jalr	1448(ra) # 80000588 <printf>
        swtch(&c->context, &p->context);
    80001fe8:	06048593          	addi	a1,s1,96
    80001fec:	855a                	mv	a0,s6
    80001fee:	00001097          	auipc	ra,0x1
    80001ff2:	8f4080e7          	jalr	-1804(ra) # 800028e2 <swtch>
        c->proc = 0;
    80001ff6:	020ab823          	sd	zero,48(s5)
        p->ticks_used++;
    80001ffa:	17c4a783          	lw	a5,380(s1)
    80001ffe:	2785                	addiw	a5,a5,1
    80002000:	0007869b          	sext.w	a3,a5
    80002004:	16f4ae23          	sw	a5,380(s1)
        if (p->ticks_used >= time_slices[p->priority]) {
    80002008:	1784a703          	lw	a4,376(s1)
    8000200c:	00271793          	slli	a5,a4,0x2
    80002010:	fa040613          	addi	a2,s0,-96
    80002014:	97b2                	add	a5,a5,a2
    80002016:	ff07a783          	lw	a5,-16(a5)
    8000201a:	00f6c963          	blt	a3,a5,8000202c <scheduler+0xfa>
          if (p->priority < NQUEUE - 1) {
    8000201e:	00e9c563          	blt	s3,a4,80002028 <scheduler+0xf6>
            p->priority++; // Move to lower priority
    80002022:	2705                	addiw	a4,a4,1
    80002024:	16e4ac23          	sw	a4,376(s1)
          p->ticks_used = 0; // Reset ticks used
    80002028:	1604ae23          	sw	zero,380(s1)
        release(&p->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	c5c080e7          	jalr	-932(ra) # 80000c8a <release>
    if (c->proc) break; // Exit outer loop if a process is running
    80002036:	030ab783          	ld	a5,48(s5)
    8000203a:	eb91                	bnez	a5,8000204e <scheduler+0x11c>
  for (int i = 0; i < NQUEUE; i++) {
    8000203c:	2a05                	addiw	s4,s4,1
    8000203e:	4791                	li	a5,4
    80002040:	00fa0763          	beq	s4,a5,8000204e <scheduler+0x11c>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002044:	0000f497          	auipc	s1,0xf
    80002048:	f4c48493          	addi	s1,s1,-180 # 80010f90 <proc>
    8000204c:	b78d                	j	80001fae <scheduler+0x7c>
  ticks_since_boost++;
    8000204e:	2c05                	addiw	s8,s8,1
  if (ticks_since_boost >= 48) {
    80002050:	02f00793          	li	a5,47
    80002054:	0387dd63          	bge	a5,s8,8000208e <scheduler+0x15c>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002058:	0000f497          	auipc	s1,0xf
    8000205c:	f3848493          	addi	s1,s1,-200 # 80010f90 <proc>
      if (p->state == RUNNABLE) {
    80002060:	4989                	li	s3,2
    80002062:	a811                	j	80002076 <scheduler+0x144>
      release(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	c24080e7          	jalr	-988(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    8000206e:	23848493          	addi	s1,s1,568
    80002072:	01248d63          	beq	s1,s2,8000208c <scheduler+0x15a>
      acquire(&p->lock);
    80002076:	8526                	mv	a0,s1
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	b5e080e7          	jalr	-1186(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE) {
    80002080:	4c9c                	lw	a5,24(s1)
    80002082:	ff3791e3          	bne	a5,s3,80002064 <scheduler+0x132>
        p->priority = 0; // Boost to highest priority
    80002086:	1604ac23          	sw	zero,376(s1)
    8000208a:	bfe9                	j	80002064 <scheduler+0x132>
    ticks_since_boost = 0; // Reset boost counter
    8000208c:	4c01                	li	s8,0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000208e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002092:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002096:	10079073          	csrw	sstatus,a5
  int time_slices[] = {1, 4, 8, 16};
    8000209a:	4785                	li	a5,1
    8000209c:	f8f42823          	sw	a5,-112(s0)
    800020a0:	4791                	li	a5,4
    800020a2:	f8f42a23          	sw	a5,-108(s0)
    800020a6:	47a1                	li	a5,8
    800020a8:	f8f42c23          	sw	a5,-104(s0)
    800020ac:	47c1                	li	a5,16
    800020ae:	f8f42e23          	sw	a5,-100(s0)
  for (int i = 0; i < NQUEUE; i++) {
    800020b2:	4a01                	li	s4,0
      if (p->state == RUNNABLE && p->priority == i) {
    800020b4:	4989                	li	s3,2
        p->state = RUNNING;
    800020b6:	4c8d                	li	s9,3
    800020b8:	b771                	j	80002044 <scheduler+0x112>

00000000800020ba <sched>:
{
    800020ba:	7179                	addi	sp,sp,-48
    800020bc:	f406                	sd	ra,40(sp)
    800020be:	f022                	sd	s0,32(sp)
    800020c0:	ec26                	sd	s1,24(sp)
    800020c2:	e84a                	sd	s2,16(sp)
    800020c4:	e44e                	sd	s3,8(sp)
    800020c6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	90a080e7          	jalr	-1782(ra) # 800019d2 <myproc>
    800020d0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	a8a080e7          	jalr	-1398(ra) # 80000b5c <holding>
    800020da:	c93d                	beqz	a0,80002150 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020dc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800020de:	2781                	sext.w	a5,a5
    800020e0:	079e                	slli	a5,a5,0x7
    800020e2:	0000f717          	auipc	a4,0xf
    800020e6:	a7e70713          	addi	a4,a4,-1410 # 80010b60 <pid_lock>
    800020ea:	97ba                	add	a5,a5,a4
    800020ec:	0a87a703          	lw	a4,168(a5)
    800020f0:	4785                	li	a5,1
    800020f2:	06f71763          	bne	a4,a5,80002160 <sched+0xa6>
  if (p->state == RUNNING)
    800020f6:	4c98                	lw	a4,24(s1)
    800020f8:	478d                	li	a5,3
    800020fa:	06f70b63          	beq	a4,a5,80002170 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002102:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002104:	efb5                	bnez	a5,80002180 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002106:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002108:	0000f917          	auipc	s2,0xf
    8000210c:	a5890913          	addi	s2,s2,-1448 # 80010b60 <pid_lock>
    80002110:	2781                	sext.w	a5,a5
    80002112:	079e                	slli	a5,a5,0x7
    80002114:	97ca                	add	a5,a5,s2
    80002116:	0ac7a983          	lw	s3,172(a5)
    8000211a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000211c:	2781                	sext.w	a5,a5
    8000211e:	079e                	slli	a5,a5,0x7
    80002120:	0000f597          	auipc	a1,0xf
    80002124:	a7858593          	addi	a1,a1,-1416 # 80010b98 <cpus+0x8>
    80002128:	95be                	add	a1,a1,a5
    8000212a:	06048513          	addi	a0,s1,96
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	7b4080e7          	jalr	1972(ra) # 800028e2 <swtch>
    80002136:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002138:	2781                	sext.w	a5,a5
    8000213a:	079e                	slli	a5,a5,0x7
    8000213c:	97ca                	add	a5,a5,s2
    8000213e:	0b37a623          	sw	s3,172(a5)
}
    80002142:	70a2                	ld	ra,40(sp)
    80002144:	7402                	ld	s0,32(sp)
    80002146:	64e2                	ld	s1,24(sp)
    80002148:	6942                	ld	s2,16(sp)
    8000214a:	69a2                	ld	s3,8(sp)
    8000214c:	6145                	addi	sp,sp,48
    8000214e:	8082                	ret
    panic("sched p->lock");
    80002150:	00006517          	auipc	a0,0x6
    80002154:	0e050513          	addi	a0,a0,224 # 80008230 <digits+0x1f0>
    80002158:	ffffe097          	auipc	ra,0xffffe
    8000215c:	3e6080e7          	jalr	998(ra) # 8000053e <panic>
    panic("sched locks");
    80002160:	00006517          	auipc	a0,0x6
    80002164:	0e050513          	addi	a0,a0,224 # 80008240 <digits+0x200>
    80002168:	ffffe097          	auipc	ra,0xffffe
    8000216c:	3d6080e7          	jalr	982(ra) # 8000053e <panic>
    panic("sched running");
    80002170:	00006517          	auipc	a0,0x6
    80002174:	0e050513          	addi	a0,a0,224 # 80008250 <digits+0x210>
    80002178:	ffffe097          	auipc	ra,0xffffe
    8000217c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002180:	00006517          	auipc	a0,0x6
    80002184:	0e050513          	addi	a0,a0,224 # 80008260 <digits+0x220>
    80002188:	ffffe097          	auipc	ra,0xffffe
    8000218c:	3b6080e7          	jalr	950(ra) # 8000053e <panic>

0000000080002190 <yield>:
{
    80002190:	1101                	addi	sp,sp,-32
    80002192:	ec06                	sd	ra,24(sp)
    80002194:	e822                	sd	s0,16(sp)
    80002196:	e426                	sd	s1,8(sp)
    80002198:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	838080e7          	jalr	-1992(ra) # 800019d2 <myproc>
    800021a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	a32080e7          	jalr	-1486(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800021ac:	4789                	li	a5,2
    800021ae:	cc9c                	sw	a5,24(s1)
  sched();
    800021b0:	00000097          	auipc	ra,0x0
    800021b4:	f0a080e7          	jalr	-246(ra) # 800020ba <sched>
  release(&p->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	ad0080e7          	jalr	-1328(ra) # 80000c8a <release>
}
    800021c2:	60e2                	ld	ra,24(sp)
    800021c4:	6442                	ld	s0,16(sp)
    800021c6:	64a2                	ld	s1,8(sp)
    800021c8:	6105                	addi	sp,sp,32
    800021ca:	8082                	ret

00000000800021cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800021cc:	7179                	addi	sp,sp,-48
    800021ce:	f406                	sd	ra,40(sp)
    800021d0:	f022                	sd	s0,32(sp)
    800021d2:	ec26                	sd	s1,24(sp)
    800021d4:	e84a                	sd	s2,16(sp)
    800021d6:	e44e                	sd	s3,8(sp)
    800021d8:	1800                	addi	s0,sp,48
    800021da:	89aa                	mv	s3,a0
    800021dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	7f4080e7          	jalr	2036(ra) # 800019d2 <myproc>
    800021e6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	9ee080e7          	jalr	-1554(ra) # 80000bd6 <acquire>
  release(lk);
    800021f0:	854a                	mv	a0,s2
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	a98080e7          	jalr	-1384(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021fa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021fe:	4785                	li	a5,1
    80002200:	cc9c                	sw	a5,24(s1)

  sched();
    80002202:	00000097          	auipc	ra,0x0
    80002206:	eb8080e7          	jalr	-328(ra) # 800020ba <sched>

  // Tidy up.
  p->chan = 0;
    8000220a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	a7a080e7          	jalr	-1414(ra) # 80000c8a <release>
  acquire(lk);
    80002218:	854a                	mv	a0,s2
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	9bc080e7          	jalr	-1604(ra) # 80000bd6 <acquire>
}
    80002222:	70a2                	ld	ra,40(sp)
    80002224:	7402                	ld	s0,32(sp)
    80002226:	64e2                	ld	s1,24(sp)
    80002228:	6942                	ld	s2,16(sp)
    8000222a:	69a2                	ld	s3,8(sp)
    8000222c:	6145                	addi	sp,sp,48
    8000222e:	8082                	ret

0000000080002230 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002230:	7139                	addi	sp,sp,-64
    80002232:	fc06                	sd	ra,56(sp)
    80002234:	f822                	sd	s0,48(sp)
    80002236:	f426                	sd	s1,40(sp)
    80002238:	f04a                	sd	s2,32(sp)
    8000223a:	ec4e                	sd	s3,24(sp)
    8000223c:	e852                	sd	s4,16(sp)
    8000223e:	e456                	sd	s5,8(sp)
    80002240:	0080                	addi	s0,sp,64
    80002242:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002244:	0000f497          	auipc	s1,0xf
    80002248:	d4c48493          	addi	s1,s1,-692 # 80010f90 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000224c:	4985                	li	s3,1
      {
        p->state = RUNNABLE;
    8000224e:	4a89                	li	s5,2
  for (p = proc; p < &proc[NPROC]; p++)
    80002250:	00018917          	auipc	s2,0x18
    80002254:	b4090913          	addi	s2,s2,-1216 # 80019d90 <tickslock>
    80002258:	a811                	j	8000226c <wakeup+0x3c>
      }
      release(&p->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	a2e080e7          	jalr	-1490(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002264:	23848493          	addi	s1,s1,568
    80002268:	03248663          	beq	s1,s2,80002294 <wakeup+0x64>
    if (p != myproc())
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	766080e7          	jalr	1894(ra) # 800019d2 <myproc>
    80002274:	fea488e3          	beq	s1,a0,80002264 <wakeup+0x34>
      acquire(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	95c080e7          	jalr	-1700(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002282:	4c9c                	lw	a5,24(s1)
    80002284:	fd379be3          	bne	a5,s3,8000225a <wakeup+0x2a>
    80002288:	709c                	ld	a5,32(s1)
    8000228a:	fd4798e3          	bne	a5,s4,8000225a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000228e:	0154ac23          	sw	s5,24(s1)
    80002292:	b7e1                	j	8000225a <wakeup+0x2a>
    }
  }
}
    80002294:	70e2                	ld	ra,56(sp)
    80002296:	7442                	ld	s0,48(sp)
    80002298:	74a2                	ld	s1,40(sp)
    8000229a:	7902                	ld	s2,32(sp)
    8000229c:	69e2                	ld	s3,24(sp)
    8000229e:	6a42                	ld	s4,16(sp)
    800022a0:	6aa2                	ld	s5,8(sp)
    800022a2:	6121                	addi	sp,sp,64
    800022a4:	8082                	ret

00000000800022a6 <reparent>:
{
    800022a6:	7179                	addi	sp,sp,-48
    800022a8:	f406                	sd	ra,40(sp)
    800022aa:	f022                	sd	s0,32(sp)
    800022ac:	ec26                	sd	s1,24(sp)
    800022ae:	e84a                	sd	s2,16(sp)
    800022b0:	e44e                	sd	s3,8(sp)
    800022b2:	e052                	sd	s4,0(sp)
    800022b4:	1800                	addi	s0,sp,48
    800022b6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022b8:	0000f497          	auipc	s1,0xf
    800022bc:	cd848493          	addi	s1,s1,-808 # 80010f90 <proc>
      pp->parent = initproc;
    800022c0:	00006a17          	auipc	s4,0x6
    800022c4:	628a0a13          	addi	s4,s4,1576 # 800088e8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022c8:	00018997          	auipc	s3,0x18
    800022cc:	ac898993          	addi	s3,s3,-1336 # 80019d90 <tickslock>
    800022d0:	a029                	j	800022da <reparent+0x34>
    800022d2:	23848493          	addi	s1,s1,568
    800022d6:	01348d63          	beq	s1,s3,800022f0 <reparent+0x4a>
    if (pp->parent == p)
    800022da:	7c9c                	ld	a5,56(s1)
    800022dc:	ff279be3          	bne	a5,s2,800022d2 <reparent+0x2c>
      pp->parent = initproc;
    800022e0:	000a3503          	ld	a0,0(s4)
    800022e4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	f4a080e7          	jalr	-182(ra) # 80002230 <wakeup>
    800022ee:	b7d5                	j	800022d2 <reparent+0x2c>
}
    800022f0:	70a2                	ld	ra,40(sp)
    800022f2:	7402                	ld	s0,32(sp)
    800022f4:	64e2                	ld	s1,24(sp)
    800022f6:	6942                	ld	s2,16(sp)
    800022f8:	69a2                	ld	s3,8(sp)
    800022fa:	6a02                	ld	s4,0(sp)
    800022fc:	6145                	addi	sp,sp,48
    800022fe:	8082                	ret

0000000080002300 <exit>:
{
    80002300:	7179                	addi	sp,sp,-48
    80002302:	f406                	sd	ra,40(sp)
    80002304:	f022                	sd	s0,32(sp)
    80002306:	ec26                	sd	s1,24(sp)
    80002308:	e84a                	sd	s2,16(sp)
    8000230a:	e44e                	sd	s3,8(sp)
    8000230c:	e052                	sd	s4,0(sp)
    8000230e:	1800                	addi	s0,sp,48
    80002310:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	6c0080e7          	jalr	1728(ra) # 800019d2 <myproc>
    8000231a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000231c:	00006797          	auipc	a5,0x6
    80002320:	5cc7b783          	ld	a5,1484(a5) # 800088e8 <initproc>
    80002324:	0d050493          	addi	s1,a0,208
    80002328:	15050913          	addi	s2,a0,336
    8000232c:	02a79363          	bne	a5,a0,80002352 <exit+0x52>
    panic("init exiting");
    80002330:	00006517          	auipc	a0,0x6
    80002334:	f4850513          	addi	a0,a0,-184 # 80008278 <digits+0x238>
    80002338:	ffffe097          	auipc	ra,0xffffe
    8000233c:	206080e7          	jalr	518(ra) # 8000053e <panic>
      fileclose(f);
    80002340:	00002097          	auipc	ra,0x2
    80002344:	6ea080e7          	jalr	1770(ra) # 80004a2a <fileclose>
      p->ofile[fd] = 0;
    80002348:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000234c:	04a1                	addi	s1,s1,8
    8000234e:	01248563          	beq	s1,s2,80002358 <exit+0x58>
    if (p->ofile[fd])
    80002352:	6088                	ld	a0,0(s1)
    80002354:	f575                	bnez	a0,80002340 <exit+0x40>
    80002356:	bfdd                	j	8000234c <exit+0x4c>
  begin_op();
    80002358:	00002097          	auipc	ra,0x2
    8000235c:	206080e7          	jalr	518(ra) # 8000455e <begin_op>
  iput(p->cwd);
    80002360:	1509b503          	ld	a0,336(s3)
    80002364:	00002097          	auipc	ra,0x2
    80002368:	9f2080e7          	jalr	-1550(ra) # 80003d56 <iput>
  end_op();
    8000236c:	00002097          	auipc	ra,0x2
    80002370:	272080e7          	jalr	626(ra) # 800045de <end_op>
  p->cwd = 0;
    80002374:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002378:	0000f497          	auipc	s1,0xf
    8000237c:	80048493          	addi	s1,s1,-2048 # 80010b78 <wait_lock>
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	854080e7          	jalr	-1964(ra) # 80000bd6 <acquire>
  reparent(p);
    8000238a:	854e                	mv	a0,s3
    8000238c:	00000097          	auipc	ra,0x0
    80002390:	f1a080e7          	jalr	-230(ra) # 800022a6 <reparent>
  wakeup(p->parent);
    80002394:	0389b503          	ld	a0,56(s3)
    80002398:	00000097          	auipc	ra,0x0
    8000239c:	e98080e7          	jalr	-360(ra) # 80002230 <wakeup>
  acquire(&p->lock);
    800023a0:	854e                	mv	a0,s3
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	834080e7          	jalr	-1996(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800023aa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023ae:	4791                	li	a5,4
    800023b0:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800023b4:	00006797          	auipc	a5,0x6
    800023b8:	53c7a783          	lw	a5,1340(a5) # 800088f0 <ticks>
    800023bc:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	8c8080e7          	jalr	-1848(ra) # 80000c8a <release>
  sched();
    800023ca:	00000097          	auipc	ra,0x0
    800023ce:	cf0080e7          	jalr	-784(ra) # 800020ba <sched>
  panic("zombie exit");
    800023d2:	00006517          	auipc	a0,0x6
    800023d6:	eb650513          	addi	a0,a0,-330 # 80008288 <digits+0x248>
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	164080e7          	jalr	356(ra) # 8000053e <panic>

00000000800023e2 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023e2:	7179                	addi	sp,sp,-48
    800023e4:	f406                	sd	ra,40(sp)
    800023e6:	f022                	sd	s0,32(sp)
    800023e8:	ec26                	sd	s1,24(sp)
    800023ea:	e84a                	sd	s2,16(sp)
    800023ec:	e44e                	sd	s3,8(sp)
    800023ee:	1800                	addi	s0,sp,48
    800023f0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023f2:	0000f497          	auipc	s1,0xf
    800023f6:	b9e48493          	addi	s1,s1,-1122 # 80010f90 <proc>
    800023fa:	00018997          	auipc	s3,0x18
    800023fe:	99698993          	addi	s3,s3,-1642 # 80019d90 <tickslock>
  {
    acquire(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	7d2080e7          	jalr	2002(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000240c:	589c                	lw	a5,48(s1)
    8000240e:	01278d63          	beq	a5,s2,80002428 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	876080e7          	jalr	-1930(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000241c:	23848493          	addi	s1,s1,568
    80002420:	ff3491e3          	bne	s1,s3,80002402 <kill+0x20>
  }
  return -1;
    80002424:	557d                	li	a0,-1
    80002426:	a821                	j	8000243e <kill+0x5c>
      p->killed = 1;
    80002428:	4785                	li	a5,1
    8000242a:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000242c:	4c98                	lw	a4,24(s1)
    8000242e:	00f70f63          	beq	a4,a5,8000244c <kill+0x6a>
      release(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	856080e7          	jalr	-1962(ra) # 80000c8a <release>
      return 0;
    8000243c:	4501                	li	a0,0
}
    8000243e:	70a2                	ld	ra,40(sp)
    80002440:	7402                	ld	s0,32(sp)
    80002442:	64e2                	ld	s1,24(sp)
    80002444:	6942                	ld	s2,16(sp)
    80002446:	69a2                	ld	s3,8(sp)
    80002448:	6145                	addi	sp,sp,48
    8000244a:	8082                	ret
        p->state = RUNNABLE;
    8000244c:	4789                	li	a5,2
    8000244e:	cc9c                	sw	a5,24(s1)
    80002450:	b7cd                	j	80002432 <kill+0x50>

0000000080002452 <setkilled>:

void setkilled(struct proc *p)
{
    80002452:	1101                	addi	sp,sp,-32
    80002454:	ec06                	sd	ra,24(sp)
    80002456:	e822                	sd	s0,16(sp)
    80002458:	e426                	sd	s1,8(sp)
    8000245a:	1000                	addi	s0,sp,32
    8000245c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	778080e7          	jalr	1912(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002466:	4785                	li	a5,1
    80002468:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	81e080e7          	jalr	-2018(ra) # 80000c8a <release>
}
    80002474:	60e2                	ld	ra,24(sp)
    80002476:	6442                	ld	s0,16(sp)
    80002478:	64a2                	ld	s1,8(sp)
    8000247a:	6105                	addi	sp,sp,32
    8000247c:	8082                	ret

000000008000247e <killed>:

int killed(struct proc *p)
{
    8000247e:	1101                	addi	sp,sp,-32
    80002480:	ec06                	sd	ra,24(sp)
    80002482:	e822                	sd	s0,16(sp)
    80002484:	e426                	sd	s1,8(sp)
    80002486:	e04a                	sd	s2,0(sp)
    80002488:	1000                	addi	s0,sp,32
    8000248a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	74a080e7          	jalr	1866(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002494:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	7f0080e7          	jalr	2032(ra) # 80000c8a <release>
  return k;
}
    800024a2:	854a                	mv	a0,s2
    800024a4:	60e2                	ld	ra,24(sp)
    800024a6:	6442                	ld	s0,16(sp)
    800024a8:	64a2                	ld	s1,8(sp)
    800024aa:	6902                	ld	s2,0(sp)
    800024ac:	6105                	addi	sp,sp,32
    800024ae:	8082                	ret

00000000800024b0 <wait>:
{
    800024b0:	715d                	addi	sp,sp,-80
    800024b2:	e486                	sd	ra,72(sp)
    800024b4:	e0a2                	sd	s0,64(sp)
    800024b6:	fc26                	sd	s1,56(sp)
    800024b8:	f84a                	sd	s2,48(sp)
    800024ba:	f44e                	sd	s3,40(sp)
    800024bc:	f052                	sd	s4,32(sp)
    800024be:	ec56                	sd	s5,24(sp)
    800024c0:	e85a                	sd	s6,16(sp)
    800024c2:	e45e                	sd	s7,8(sp)
    800024c4:	e062                	sd	s8,0(sp)
    800024c6:	0880                	addi	s0,sp,80
    800024c8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	508080e7          	jalr	1288(ra) # 800019d2 <myproc>
    800024d2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024d4:	0000e517          	auipc	a0,0xe
    800024d8:	6a450513          	addi	a0,a0,1700 # 80010b78 <wait_lock>
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	6fa080e7          	jalr	1786(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024e4:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800024e6:	4a11                	li	s4,4
        havekids = 1;
    800024e8:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ea:	00018997          	auipc	s3,0x18
    800024ee:	8a698993          	addi	s3,s3,-1882 # 80019d90 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024f2:	0000ec17          	auipc	s8,0xe
    800024f6:	686c0c13          	addi	s8,s8,1670 # 80010b78 <wait_lock>
    havekids = 0;
    800024fa:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024fc:	0000f497          	auipc	s1,0xf
    80002500:	a9448493          	addi	s1,s1,-1388 # 80010f90 <proc>
    80002504:	a0bd                	j	80002572 <wait+0xc2>
          pid = pp->pid;
    80002506:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000250a:	000b0e63          	beqz	s6,80002526 <wait+0x76>
    8000250e:	4691                	li	a3,4
    80002510:	02c48613          	addi	a2,s1,44
    80002514:	85da                	mv	a1,s6
    80002516:	05093503          	ld	a0,80(s2)
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	14e080e7          	jalr	334(ra) # 80001668 <copyout>
    80002522:	02054563          	bltz	a0,8000254c <wait+0x9c>
          freeproc(pp);
    80002526:	8526                	mv	a0,s1
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	65c080e7          	jalr	1628(ra) # 80001b84 <freeproc>
          release(&pp->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	758080e7          	jalr	1880(ra) # 80000c8a <release>
          release(&wait_lock);
    8000253a:	0000e517          	auipc	a0,0xe
    8000253e:	63e50513          	addi	a0,a0,1598 # 80010b78 <wait_lock>
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	748080e7          	jalr	1864(ra) # 80000c8a <release>
          return pid;
    8000254a:	a0b5                	j	800025b6 <wait+0x106>
            release(&pp->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	73c080e7          	jalr	1852(ra) # 80000c8a <release>
            release(&wait_lock);
    80002556:	0000e517          	auipc	a0,0xe
    8000255a:	62250513          	addi	a0,a0,1570 # 80010b78 <wait_lock>
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	72c080e7          	jalr	1836(ra) # 80000c8a <release>
            return -1;
    80002566:	59fd                	li	s3,-1
    80002568:	a0b9                	j	800025b6 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000256a:	23848493          	addi	s1,s1,568
    8000256e:	03348463          	beq	s1,s3,80002596 <wait+0xe6>
      if (pp->parent == p)
    80002572:	7c9c                	ld	a5,56(s1)
    80002574:	ff279be3          	bne	a5,s2,8000256a <wait+0xba>
        acquire(&pp->lock);
    80002578:	8526                	mv	a0,s1
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	65c080e7          	jalr	1628(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002582:	4c9c                	lw	a5,24(s1)
    80002584:	f94781e3          	beq	a5,s4,80002506 <wait+0x56>
        release(&pp->lock);
    80002588:	8526                	mv	a0,s1
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	700080e7          	jalr	1792(ra) # 80000c8a <release>
        havekids = 1;
    80002592:	8756                	mv	a4,s5
    80002594:	bfd9                	j	8000256a <wait+0xba>
    if (!havekids || killed(p))
    80002596:	c719                	beqz	a4,800025a4 <wait+0xf4>
    80002598:	854a                	mv	a0,s2
    8000259a:	00000097          	auipc	ra,0x0
    8000259e:	ee4080e7          	jalr	-284(ra) # 8000247e <killed>
    800025a2:	c51d                	beqz	a0,800025d0 <wait+0x120>
      release(&wait_lock);
    800025a4:	0000e517          	auipc	a0,0xe
    800025a8:	5d450513          	addi	a0,a0,1492 # 80010b78 <wait_lock>
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	6de080e7          	jalr	1758(ra) # 80000c8a <release>
      return -1;
    800025b4:	59fd                	li	s3,-1
}
    800025b6:	854e                	mv	a0,s3
    800025b8:	60a6                	ld	ra,72(sp)
    800025ba:	6406                	ld	s0,64(sp)
    800025bc:	74e2                	ld	s1,56(sp)
    800025be:	7942                	ld	s2,48(sp)
    800025c0:	79a2                	ld	s3,40(sp)
    800025c2:	7a02                	ld	s4,32(sp)
    800025c4:	6ae2                	ld	s5,24(sp)
    800025c6:	6b42                	ld	s6,16(sp)
    800025c8:	6ba2                	ld	s7,8(sp)
    800025ca:	6c02                	ld	s8,0(sp)
    800025cc:	6161                	addi	sp,sp,80
    800025ce:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025d0:	85e2                	mv	a1,s8
    800025d2:	854a                	mv	a0,s2
    800025d4:	00000097          	auipc	ra,0x0
    800025d8:	bf8080e7          	jalr	-1032(ra) # 800021cc <sleep>
    havekids = 0;
    800025dc:	bf39                	j	800024fa <wait+0x4a>

00000000800025de <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025de:	7179                	addi	sp,sp,-48
    800025e0:	f406                	sd	ra,40(sp)
    800025e2:	f022                	sd	s0,32(sp)
    800025e4:	ec26                	sd	s1,24(sp)
    800025e6:	e84a                	sd	s2,16(sp)
    800025e8:	e44e                	sd	s3,8(sp)
    800025ea:	e052                	sd	s4,0(sp)
    800025ec:	1800                	addi	s0,sp,48
    800025ee:	84aa                	mv	s1,a0
    800025f0:	892e                	mv	s2,a1
    800025f2:	89b2                	mv	s3,a2
    800025f4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f6:	fffff097          	auipc	ra,0xfffff
    800025fa:	3dc080e7          	jalr	988(ra) # 800019d2 <myproc>
  if (user_dst)
    800025fe:	c08d                	beqz	s1,80002620 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002600:	86d2                	mv	a3,s4
    80002602:	864e                	mv	a2,s3
    80002604:	85ca                	mv	a1,s2
    80002606:	6928                	ld	a0,80(a0)
    80002608:	fffff097          	auipc	ra,0xfffff
    8000260c:	060080e7          	jalr	96(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002610:	70a2                	ld	ra,40(sp)
    80002612:	7402                	ld	s0,32(sp)
    80002614:	64e2                	ld	s1,24(sp)
    80002616:	6942                	ld	s2,16(sp)
    80002618:	69a2                	ld	s3,8(sp)
    8000261a:	6a02                	ld	s4,0(sp)
    8000261c:	6145                	addi	sp,sp,48
    8000261e:	8082                	ret
    memmove((char *)dst, src, len);
    80002620:	000a061b          	sext.w	a2,s4
    80002624:	85ce                	mv	a1,s3
    80002626:	854a                	mv	a0,s2
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	706080e7          	jalr	1798(ra) # 80000d2e <memmove>
    return 0;
    80002630:	8526                	mv	a0,s1
    80002632:	bff9                	j	80002610 <either_copyout+0x32>

0000000080002634 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002634:	7179                	addi	sp,sp,-48
    80002636:	f406                	sd	ra,40(sp)
    80002638:	f022                	sd	s0,32(sp)
    8000263a:	ec26                	sd	s1,24(sp)
    8000263c:	e84a                	sd	s2,16(sp)
    8000263e:	e44e                	sd	s3,8(sp)
    80002640:	e052                	sd	s4,0(sp)
    80002642:	1800                	addi	s0,sp,48
    80002644:	892a                	mv	s2,a0
    80002646:	84ae                	mv	s1,a1
    80002648:	89b2                	mv	s3,a2
    8000264a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	386080e7          	jalr	902(ra) # 800019d2 <myproc>
  if (user_src)
    80002654:	c08d                	beqz	s1,80002676 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002656:	86d2                	mv	a3,s4
    80002658:	864e                	mv	a2,s3
    8000265a:	85ca                	mv	a1,s2
    8000265c:	6928                	ld	a0,80(a0)
    8000265e:	fffff097          	auipc	ra,0xfffff
    80002662:	096080e7          	jalr	150(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002666:	70a2                	ld	ra,40(sp)
    80002668:	7402                	ld	s0,32(sp)
    8000266a:	64e2                	ld	s1,24(sp)
    8000266c:	6942                	ld	s2,16(sp)
    8000266e:	69a2                	ld	s3,8(sp)
    80002670:	6a02                	ld	s4,0(sp)
    80002672:	6145                	addi	sp,sp,48
    80002674:	8082                	ret
    memmove(dst, (char *)src, len);
    80002676:	000a061b          	sext.w	a2,s4
    8000267a:	85ce                	mv	a1,s3
    8000267c:	854a                	mv	a0,s2
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	6b0080e7          	jalr	1712(ra) # 80000d2e <memmove>
    return 0;
    80002686:	8526                	mv	a0,s1
    80002688:	bff9                	j	80002666 <either_copyin+0x32>

000000008000268a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000268a:	715d                	addi	sp,sp,-80
    8000268c:	e486                	sd	ra,72(sp)
    8000268e:	e0a2                	sd	s0,64(sp)
    80002690:	fc26                	sd	s1,56(sp)
    80002692:	f84a                	sd	s2,48(sp)
    80002694:	f44e                	sd	s3,40(sp)
    80002696:	f052                	sd	s4,32(sp)
    80002698:	ec56                	sd	s5,24(sp)
    8000269a:	e85a                	sd	s6,16(sp)
    8000269c:	e45e                	sd	s7,8(sp)
    8000269e:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800026a0:	00006517          	auipc	a0,0x6
    800026a4:	a2850513          	addi	a0,a0,-1496 # 800080c8 <digits+0x88>
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	ee0080e7          	jalr	-288(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026b0:	0000f497          	auipc	s1,0xf
    800026b4:	a3848493          	addi	s1,s1,-1480 # 800110e8 <proc+0x158>
    800026b8:	00018917          	auipc	s2,0x18
    800026bc:	83090913          	addi	s2,s2,-2000 # 80019ee8 <bcache+0xc0>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c0:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800026c2:	00006997          	auipc	s3,0x6
    800026c6:	bd698993          	addi	s3,s3,-1066 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    800026ca:	00006a97          	auipc	s5,0x6
    800026ce:	bd6a8a93          	addi	s5,s5,-1066 # 800082a0 <digits+0x260>
    printf("\n");
    800026d2:	00006a17          	auipc	s4,0x6
    800026d6:	9f6a0a13          	addi	s4,s4,-1546 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026da:	00006b97          	auipc	s7,0x6
    800026de:	bfeb8b93          	addi	s7,s7,-1026 # 800082d8 <states.0>
    800026e2:	a00d                	j	80002704 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026e4:	ed86a583          	lw	a1,-296(a3)
    800026e8:	8556                	mv	a0,s5
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	e9e080e7          	jalr	-354(ra) # 80000588 <printf>
    printf("\n");
    800026f2:	8552                	mv	a0,s4
    800026f4:	ffffe097          	auipc	ra,0xffffe
    800026f8:	e94080e7          	jalr	-364(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026fc:	23848493          	addi	s1,s1,568
    80002700:	03248163          	beq	s1,s2,80002722 <procdump+0x98>
    if (p->state == UNUSED)
    80002704:	86a6                	mv	a3,s1
    80002706:	ec04a783          	lw	a5,-320(s1)
    8000270a:	dbed                	beqz	a5,800026fc <procdump+0x72>
      state = "???";
    8000270c:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000270e:	fcfb6be3          	bltu	s6,a5,800026e4 <procdump+0x5a>
    80002712:	1782                	slli	a5,a5,0x20
    80002714:	9381                	srli	a5,a5,0x20
    80002716:	078e                	slli	a5,a5,0x3
    80002718:	97de                	add	a5,a5,s7
    8000271a:	6390                	ld	a2,0(a5)
    8000271c:	f661                	bnez	a2,800026e4 <procdump+0x5a>
      state = "???";
    8000271e:	864e                	mv	a2,s3
    80002720:	b7d1                	j	800026e4 <procdump+0x5a>
  }
}
    80002722:	60a6                	ld	ra,72(sp)
    80002724:	6406                	ld	s0,64(sp)
    80002726:	74e2                	ld	s1,56(sp)
    80002728:	7942                	ld	s2,48(sp)
    8000272a:	79a2                	ld	s3,40(sp)
    8000272c:	7a02                	ld	s4,32(sp)
    8000272e:	6ae2                	ld	s5,24(sp)
    80002730:	6b42                	ld	s6,16(sp)
    80002732:	6ba2                	ld	s7,8(sp)
    80002734:	6161                	addi	sp,sp,80
    80002736:	8082                	ret

0000000080002738 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002738:	711d                	addi	sp,sp,-96
    8000273a:	ec86                	sd	ra,88(sp)
    8000273c:	e8a2                	sd	s0,80(sp)
    8000273e:	e4a6                	sd	s1,72(sp)
    80002740:	e0ca                	sd	s2,64(sp)
    80002742:	fc4e                	sd	s3,56(sp)
    80002744:	f852                	sd	s4,48(sp)
    80002746:	f456                	sd	s5,40(sp)
    80002748:	f05a                	sd	s6,32(sp)
    8000274a:	ec5e                	sd	s7,24(sp)
    8000274c:	e862                	sd	s8,16(sp)
    8000274e:	e466                	sd	s9,8(sp)
    80002750:	e06a                	sd	s10,0(sp)
    80002752:	1080                	addi	s0,sp,96
    80002754:	8b2a                	mv	s6,a0
    80002756:	8bae                	mv	s7,a1
    80002758:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	278080e7          	jalr	632(ra) # 800019d2 <myproc>
    80002762:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002764:	0000e517          	auipc	a0,0xe
    80002768:	41450513          	addi	a0,a0,1044 # 80010b78 <wait_lock>
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	46a080e7          	jalr	1130(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002774:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002776:	4a11                	li	s4,4
        havekids = 1;
    80002778:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000277a:	00017997          	auipc	s3,0x17
    8000277e:	61698993          	addi	s3,s3,1558 # 80019d90 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002782:	0000ed17          	auipc	s10,0xe
    80002786:	3f6d0d13          	addi	s10,s10,1014 # 80010b78 <wait_lock>
    havekids = 0;
    8000278a:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000278c:	0000f497          	auipc	s1,0xf
    80002790:	80448493          	addi	s1,s1,-2044 # 80010f90 <proc>
    80002794:	a059                	j	8000281a <waitx+0xe2>
          pid = np->pid;
    80002796:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000279a:	1684a703          	lw	a4,360(s1)
    8000279e:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800027a2:	16c4a783          	lw	a5,364(s1)
    800027a6:	9f3d                	addw	a4,a4,a5
    800027a8:	1704a783          	lw	a5,368(s1)
    800027ac:	9f99                	subw	a5,a5,a4
    800027ae:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800027b2:	000b0e63          	beqz	s6,800027ce <waitx+0x96>
    800027b6:	4691                	li	a3,4
    800027b8:	02c48613          	addi	a2,s1,44
    800027bc:	85da                	mv	a1,s6
    800027be:	05093503          	ld	a0,80(s2)
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	ea6080e7          	jalr	-346(ra) # 80001668 <copyout>
    800027ca:	02054563          	bltz	a0,800027f4 <waitx+0xbc>
          freeproc(np);
    800027ce:	8526                	mv	a0,s1
    800027d0:	fffff097          	auipc	ra,0xfffff
    800027d4:	3b4080e7          	jalr	948(ra) # 80001b84 <freeproc>
          release(&np->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	4b0080e7          	jalr	1200(ra) # 80000c8a <release>
          release(&wait_lock);
    800027e2:	0000e517          	auipc	a0,0xe
    800027e6:	39650513          	addi	a0,a0,918 # 80010b78 <wait_lock>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	4a0080e7          	jalr	1184(ra) # 80000c8a <release>
          return pid;
    800027f2:	a09d                	j	80002858 <waitx+0x120>
            release(&np->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	494080e7          	jalr	1172(ra) # 80000c8a <release>
            release(&wait_lock);
    800027fe:	0000e517          	auipc	a0,0xe
    80002802:	37a50513          	addi	a0,a0,890 # 80010b78 <wait_lock>
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	484080e7          	jalr	1156(ra) # 80000c8a <release>
            return -1;
    8000280e:	59fd                	li	s3,-1
    80002810:	a0a1                	j	80002858 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002812:	23848493          	addi	s1,s1,568
    80002816:	03348463          	beq	s1,s3,8000283e <waitx+0x106>
      if (np->parent == p)
    8000281a:	7c9c                	ld	a5,56(s1)
    8000281c:	ff279be3          	bne	a5,s2,80002812 <waitx+0xda>
        acquire(&np->lock);
    80002820:	8526                	mv	a0,s1
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	3b4080e7          	jalr	948(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000282a:	4c9c                	lw	a5,24(s1)
    8000282c:	f74785e3          	beq	a5,s4,80002796 <waitx+0x5e>
        release(&np->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	458080e7          	jalr	1112(ra) # 80000c8a <release>
        havekids = 1;
    8000283a:	8756                	mv	a4,s5
    8000283c:	bfd9                	j	80002812 <waitx+0xda>
    if (!havekids || p->killed)
    8000283e:	c701                	beqz	a4,80002846 <waitx+0x10e>
    80002840:	02892783          	lw	a5,40(s2)
    80002844:	cb8d                	beqz	a5,80002876 <waitx+0x13e>
      release(&wait_lock);
    80002846:	0000e517          	auipc	a0,0xe
    8000284a:	33250513          	addi	a0,a0,818 # 80010b78 <wait_lock>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	43c080e7          	jalr	1084(ra) # 80000c8a <release>
      return -1;
    80002856:	59fd                	li	s3,-1
  }
}
    80002858:	854e                	mv	a0,s3
    8000285a:	60e6                	ld	ra,88(sp)
    8000285c:	6446                	ld	s0,80(sp)
    8000285e:	64a6                	ld	s1,72(sp)
    80002860:	6906                	ld	s2,64(sp)
    80002862:	79e2                	ld	s3,56(sp)
    80002864:	7a42                	ld	s4,48(sp)
    80002866:	7aa2                	ld	s5,40(sp)
    80002868:	7b02                	ld	s6,32(sp)
    8000286a:	6be2                	ld	s7,24(sp)
    8000286c:	6c42                	ld	s8,16(sp)
    8000286e:	6ca2                	ld	s9,8(sp)
    80002870:	6d02                	ld	s10,0(sp)
    80002872:	6125                	addi	sp,sp,96
    80002874:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002876:	85ea                	mv	a1,s10
    80002878:	854a                	mv	a0,s2
    8000287a:	00000097          	auipc	ra,0x0
    8000287e:	952080e7          	jalr	-1710(ra) # 800021cc <sleep>
    havekids = 0;
    80002882:	b721                	j	8000278a <waitx+0x52>

0000000080002884 <update_time>:

void update_time()
{
    80002884:	7179                	addi	sp,sp,-48
    80002886:	f406                	sd	ra,40(sp)
    80002888:	f022                	sd	s0,32(sp)
    8000288a:	ec26                	sd	s1,24(sp)
    8000288c:	e84a                	sd	s2,16(sp)
    8000288e:	e44e                	sd	s3,8(sp)
    80002890:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002892:	0000e497          	auipc	s1,0xe
    80002896:	6fe48493          	addi	s1,s1,1790 # 80010f90 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000289a:	498d                	li	s3,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000289c:	00017917          	auipc	s2,0x17
    800028a0:	4f490913          	addi	s2,s2,1268 # 80019d90 <tickslock>
    800028a4:	a811                	j	800028b8 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	3e2080e7          	jalr	994(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800028b0:	23848493          	addi	s1,s1,568
    800028b4:	03248063          	beq	s1,s2,800028d4 <update_time+0x50>
    acquire(&p->lock);
    800028b8:	8526                	mv	a0,s1
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	31c080e7          	jalr	796(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    800028c2:	4c9c                	lw	a5,24(s1)
    800028c4:	ff3791e3          	bne	a5,s3,800028a6 <update_time+0x22>
      p->rtime++;
    800028c8:	1684a783          	lw	a5,360(s1)
    800028cc:	2785                	addiw	a5,a5,1
    800028ce:	16f4a423          	sw	a5,360(s1)
    800028d2:	bfd1                	j	800028a6 <update_time+0x22>
  }
    800028d4:	70a2                	ld	ra,40(sp)
    800028d6:	7402                	ld	s0,32(sp)
    800028d8:	64e2                	ld	s1,24(sp)
    800028da:	6942                	ld	s2,16(sp)
    800028dc:	69a2                	ld	s3,8(sp)
    800028de:	6145                	addi	sp,sp,48
    800028e0:	8082                	ret

00000000800028e2 <swtch>:
    800028e2:	00153023          	sd	ra,0(a0)
    800028e6:	00253423          	sd	sp,8(a0)
    800028ea:	e900                	sd	s0,16(a0)
    800028ec:	ed04                	sd	s1,24(a0)
    800028ee:	03253023          	sd	s2,32(a0)
    800028f2:	03353423          	sd	s3,40(a0)
    800028f6:	03453823          	sd	s4,48(a0)
    800028fa:	03553c23          	sd	s5,56(a0)
    800028fe:	05653023          	sd	s6,64(a0)
    80002902:	05753423          	sd	s7,72(a0)
    80002906:	05853823          	sd	s8,80(a0)
    8000290a:	05953c23          	sd	s9,88(a0)
    8000290e:	07a53023          	sd	s10,96(a0)
    80002912:	07b53423          	sd	s11,104(a0)
    80002916:	0005b083          	ld	ra,0(a1)
    8000291a:	0085b103          	ld	sp,8(a1)
    8000291e:	6980                	ld	s0,16(a1)
    80002920:	6d84                	ld	s1,24(a1)
    80002922:	0205b903          	ld	s2,32(a1)
    80002926:	0285b983          	ld	s3,40(a1)
    8000292a:	0305ba03          	ld	s4,48(a1)
    8000292e:	0385ba83          	ld	s5,56(a1)
    80002932:	0405bb03          	ld	s6,64(a1)
    80002936:	0485bb83          	ld	s7,72(a1)
    8000293a:	0505bc03          	ld	s8,80(a1)
    8000293e:	0585bc83          	ld	s9,88(a1)
    80002942:	0605bd03          	ld	s10,96(a1)
    80002946:	0685bd83          	ld	s11,104(a1)
    8000294a:	8082                	ret

000000008000294c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000294c:	1141                	addi	sp,sp,-16
    8000294e:	e406                	sd	ra,8(sp)
    80002950:	e022                	sd	s0,0(sp)
    80002952:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002954:	00006597          	auipc	a1,0x6
    80002958:	9ac58593          	addi	a1,a1,-1620 # 80008300 <states.0+0x28>
    8000295c:	00017517          	auipc	a0,0x17
    80002960:	43450513          	addi	a0,a0,1076 # 80019d90 <tickslock>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	1e2080e7          	jalr	482(ra) # 80000b46 <initlock>
}
    8000296c:	60a2                	ld	ra,8(sp)
    8000296e:	6402                	ld	s0,0(sp)
    80002970:	0141                	addi	sp,sp,16
    80002972:	8082                	ret

0000000080002974 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002974:	1141                	addi	sp,sp,-16
    80002976:	e422                	sd	s0,8(sp)
    80002978:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000297a:	00003797          	auipc	a5,0x3
    8000297e:	70678793          	addi	a5,a5,1798 # 80006080 <kernelvec>
    80002982:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002986:	6422                	ld	s0,8(sp)
    80002988:	0141                	addi	sp,sp,16
    8000298a:	8082                	ret

000000008000298c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000298c:	1141                	addi	sp,sp,-16
    8000298e:	e406                	sd	ra,8(sp)
    80002990:	e022                	sd	s0,0(sp)
    80002992:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002994:	fffff097          	auipc	ra,0xfffff
    80002998:	03e080e7          	jalr	62(ra) # 800019d2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000299c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029a0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029a6:	00004617          	auipc	a2,0x4
    800029aa:	65a60613          	addi	a2,a2,1626 # 80007000 <_trampoline>
    800029ae:	00004697          	auipc	a3,0x4
    800029b2:	65268693          	addi	a3,a3,1618 # 80007000 <_trampoline>
    800029b6:	8e91                	sub	a3,a3,a2
    800029b8:	040007b7          	lui	a5,0x4000
    800029bc:	17fd                	addi	a5,a5,-1
    800029be:	07b2                	slli	a5,a5,0xc
    800029c0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029c2:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029c8:	180026f3          	csrr	a3,satp
    800029cc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ce:	6d38                	ld	a4,88(a0)
    800029d0:	6134                	ld	a3,64(a0)
    800029d2:	6585                	lui	a1,0x1
    800029d4:	96ae                	add	a3,a3,a1
    800029d6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029d8:	6d38                	ld	a4,88(a0)
    800029da:	00000697          	auipc	a3,0x0
    800029de:	13e68693          	addi	a3,a3,318 # 80002b18 <usertrap>
    800029e2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029e4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029e6:	8692                	mv	a3,tp
    800029e8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ea:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ee:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029f2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029fa:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029fc:	6f18                	ld	a4,24(a4)
    800029fe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a02:	6928                	ld	a0,80(a0)
    80002a04:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a06:	00004717          	auipc	a4,0x4
    80002a0a:	69670713          	addi	a4,a4,1686 # 8000709c <userret>
    80002a0e:	8f11                	sub	a4,a4,a2
    80002a10:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a12:	577d                	li	a4,-1
    80002a14:	177e                	slli	a4,a4,0x3f
    80002a16:	8d59                	or	a0,a0,a4
    80002a18:	9782                	jalr	a5
}
    80002a1a:	60a2                	ld	ra,8(sp)
    80002a1c:	6402                	ld	s0,0(sp)
    80002a1e:	0141                	addi	sp,sp,16
    80002a20:	8082                	ret

0000000080002a22 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	e04a                	sd	s2,0(sp)
    80002a2c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a2e:	00017917          	auipc	s2,0x17
    80002a32:	36290913          	addi	s2,s2,866 # 80019d90 <tickslock>
    80002a36:	854a                	mv	a0,s2
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	19e080e7          	jalr	414(ra) # 80000bd6 <acquire>
  ticks++;
    80002a40:	00006497          	auipc	s1,0x6
    80002a44:	eb048493          	addi	s1,s1,-336 # 800088f0 <ticks>
    80002a48:	409c                	lw	a5,0(s1)
    80002a4a:	2785                	addiw	a5,a5,1
    80002a4c:	c09c                	sw	a5,0(s1)
  update_time();
    80002a4e:	00000097          	auipc	ra,0x0
    80002a52:	e36080e7          	jalr	-458(ra) # 80002884 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002a56:	8526                	mv	a0,s1
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	7d8080e7          	jalr	2008(ra) # 80002230 <wakeup>
  release(&tickslock);
    80002a60:	854a                	mv	a0,s2
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	228080e7          	jalr	552(ra) # 80000c8a <release>
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6902                	ld	s2,0(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret

0000000080002a76 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a80:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002a84:	00074d63          	bltz	a4,80002a9e <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002a88:	57fd                	li	a5,-1
    80002a8a:	17fe                	slli	a5,a5,0x3f
    80002a8c:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002a8e:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a90:	06f70363          	beq	a4,a5,80002af6 <devintr+0x80>
  }
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
      (scause & 0xff) == 9)
    80002a9e:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002aa2:	46a5                	li	a3,9
    80002aa4:	fed792e3          	bne	a5,a3,80002a88 <devintr+0x12>
    int irq = plic_claim();
    80002aa8:	00003097          	auipc	ra,0x3
    80002aac:	6e0080e7          	jalr	1760(ra) # 80006188 <plic_claim>
    80002ab0:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002ab2:	47a9                	li	a5,10
    80002ab4:	02f50763          	beq	a0,a5,80002ae2 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002ab8:	4785                	li	a5,1
    80002aba:	02f50963          	beq	a0,a5,80002aec <devintr+0x76>
    return 1;
    80002abe:	4505                	li	a0,1
    else if (irq)
    80002ac0:	d8f1                	beqz	s1,80002a94 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ac2:	85a6                	mv	a1,s1
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	84450513          	addi	a0,a0,-1980 # 80008308 <states.0+0x30>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	abc080e7          	jalr	-1348(ra) # 80000588 <printf>
      plic_complete(irq);
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	00003097          	auipc	ra,0x3
    80002ada:	6d6080e7          	jalr	1750(ra) # 800061ac <plic_complete>
    return 1;
    80002ade:	4505                	li	a0,1
    80002ae0:	bf55                	j	80002a94 <devintr+0x1e>
      uartintr();
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	eb8080e7          	jalr	-328(ra) # 8000099a <uartintr>
    80002aea:	b7ed                	j	80002ad4 <devintr+0x5e>
      virtio_disk_intr();
    80002aec:	00004097          	auipc	ra,0x4
    80002af0:	b8c080e7          	jalr	-1140(ra) # 80006678 <virtio_disk_intr>
    80002af4:	b7c5                	j	80002ad4 <devintr+0x5e>
    if (cpuid() == 0)
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	eb0080e7          	jalr	-336(ra) # 800019a6 <cpuid>
    80002afe:	c901                	beqz	a0,80002b0e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b00:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b06:	14479073          	csrw	sip,a5
    return 2;
    80002b0a:	4509                	li	a0,2
    80002b0c:	b761                	j	80002a94 <devintr+0x1e>
      clockintr();
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	f14080e7          	jalr	-236(ra) # 80002a22 <clockintr>
    80002b16:	b7ed                	j	80002b00 <devintr+0x8a>

0000000080002b18 <usertrap>:
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	e04a                	sd	s2,0(sp)
    80002b22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b24:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002b28:	1007f793          	andi	a5,a5,256
    80002b2c:	e3b1                	bnez	a5,80002b70 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b2e:	00003797          	auipc	a5,0x3
    80002b32:	55278793          	addi	a5,a5,1362 # 80006080 <kernelvec>
    80002b36:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	e98080e7          	jalr	-360(ra) # 800019d2 <myproc>
    80002b42:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b44:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b46:	14102773          	csrr	a4,sepc
    80002b4a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b4c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002b50:	47a1                	li	a5,8
    80002b52:	02f70763          	beq	a4,a5,80002b80 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	f20080e7          	jalr	-224(ra) # 80002a76 <devintr>
    80002b5e:	892a                	mv	s2,a0
    80002b60:	c92d                	beqz	a0,80002bd2 <usertrap+0xba>
  if (killed(p))
    80002b62:	8526                	mv	a0,s1
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	91a080e7          	jalr	-1766(ra) # 8000247e <killed>
    80002b6c:	c555                	beqz	a0,80002c18 <usertrap+0x100>
    80002b6e:	a045                	j	80002c0e <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002b70:	00005517          	auipc	a0,0x5
    80002b74:	7b850513          	addi	a0,a0,1976 # 80008328 <states.0+0x50>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	9c6080e7          	jalr	-1594(ra) # 8000053e <panic>
    if (killed(p))
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	8fe080e7          	jalr	-1794(ra) # 8000247e <killed>
    80002b88:	ed1d                	bnez	a0,80002bc6 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002b8a:	6cb8                	ld	a4,88(s1)
    80002b8c:	6f1c                	ld	a5,24(a4)
    80002b8e:	0791                	addi	a5,a5,4
    80002b90:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b9a:	10079073          	csrw	sstatus,a5
    syscall();
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	336080e7          	jalr	822(ra) # 80002ed4 <syscall>
  if (killed(p))
    80002ba6:	8526                	mv	a0,s1
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	8d6080e7          	jalr	-1834(ra) # 8000247e <killed>
    80002bb0:	ed31                	bnez	a0,80002c0c <usertrap+0xf4>
  usertrapret();
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	dda080e7          	jalr	-550(ra) # 8000298c <usertrapret>
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6902                	ld	s2,0(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret
      exit(-1);
    80002bc6:	557d                	li	a0,-1
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	738080e7          	jalr	1848(ra) # 80002300 <exit>
    80002bd0:	bf6d                	j	80002b8a <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bd6:	5890                	lw	a2,48(s1)
    80002bd8:	00005517          	auipc	a0,0x5
    80002bdc:	77050513          	addi	a0,a0,1904 # 80008348 <states.0+0x70>
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	9a8080e7          	jalr	-1624(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bec:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf0:	00005517          	auipc	a0,0x5
    80002bf4:	78850513          	addi	a0,a0,1928 # 80008378 <states.0+0xa0>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	990080e7          	jalr	-1648(ra) # 80000588 <printf>
    setkilled(p);
    80002c00:	8526                	mv	a0,s1
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	850080e7          	jalr	-1968(ra) # 80002452 <setkilled>
    80002c0a:	bf71                	j	80002ba6 <usertrap+0x8e>
  if (killed(p))
    80002c0c:	4901                	li	s2,0
    exit(-1);
    80002c0e:	557d                	li	a0,-1
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	6f0080e7          	jalr	1776(ra) # 80002300 <exit>
  if (which_dev == 2 && p->alarm_state==1 && p->handle_permission==1)
    80002c18:	4789                	li	a5,2
    80002c1a:	f8f91ce3          	bne	s2,a5,80002bb2 <usertrap+0x9a>
    80002c1e:	1a04a703          	lw	a4,416(s1)
    80002c22:	4785                	li	a5,1
    80002c24:	00f70b63          	beq	a4,a5,80002c3a <usertrap+0x122>
    if(p->state==RUNNING)
    80002c28:	4c98                	lw	a4,24(s1)
    80002c2a:	478d                	li	a5,3
    80002c2c:	04f70963          	beq	a4,a5,80002c7e <usertrap+0x166>
    yield();
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	560080e7          	jalr	1376(ra) # 80002190 <yield>
    80002c38:	bfad                	j	80002bb2 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_state==1 && p->handle_permission==1)
    80002c3a:	2204a703          	lw	a4,544(s1)
    80002c3e:	fef715e3          	bne	a4,a5,80002c28 <usertrap+0x110>
    struct trapframe* trap_f = kalloc();
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	ea4080e7          	jalr	-348(ra) # 80000ae6 <kalloc>
    80002c4a:	892a                	mv	s2,a0
    memmove(trap_f, p->trapframe, PGSIZE);
    80002c4c:	6605                	lui	a2,0x1
    80002c4e:	6cac                	ld	a1,88(s1)
    80002c50:	ffffe097          	auipc	ra,0xffffe
    80002c54:	0de080e7          	jalr	222(ra) # 80000d2e <memmove>
    p->alarm_tf = trap_f;
    80002c58:	2124bc23          	sd	s2,536(s1)
    p->current_ticks++;
    80002c5c:	2304a783          	lw	a5,560(s1)
    80002c60:	2785                	addiw	a5,a5,1
    80002c62:	22f4a823          	sw	a5,560(s1)
    if(p->current_ticks % p->alarm_interval==0)
    80002c66:	1984a703          	lw	a4,408(s1)
    80002c6a:	02e7e7bb          	remw	a5,a5,a4
    80002c6e:	ffcd                	bnez	a5,80002c28 <usertrap+0x110>
      p->trapframe->epc = p->alarm_handler;
    80002c70:	6cbc                	ld	a5,88(s1)
    80002c72:	1904b703          	ld	a4,400(s1)
    80002c76:	ef98                	sd	a4,24(a5)
      p->handle_permission=0;
    80002c78:	2204a023          	sw	zero,544(s1)
    80002c7c:	b775                	j	80002c28 <usertrap+0x110>
      p->running_time++;
    80002c7e:	2284b783          	ld	a5,552(s1)
    80002c82:	0785                	addi	a5,a5,1
    80002c84:	22f4b423          	sd	a5,552(s1)
    80002c88:	b765                	j	80002c30 <usertrap+0x118>

0000000080002c8a <kerneltrap>:
{
    80002c8a:	7179                	addi	sp,sp,-48
    80002c8c:	f406                	sd	ra,40(sp)
    80002c8e:	f022                	sd	s0,32(sp)
    80002c90:	ec26                	sd	s1,24(sp)
    80002c92:	e84a                	sd	s2,16(sp)
    80002c94:	e44e                	sd	s3,8(sp)
    80002c96:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c98:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c9c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca0:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002ca4:	1004f793          	andi	a5,s1,256
    80002ca8:	cb85                	beqz	a5,80002cd8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002caa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cae:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002cb0:	ef85                	bnez	a5,80002ce8 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	dc4080e7          	jalr	-572(ra) # 80002a76 <devintr>
    80002cba:	cd1d                	beqz	a0,80002cf8 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cbc:	4789                	li	a5,2
    80002cbe:	06f50a63          	beq	a0,a5,80002d32 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cc2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cc6:	10049073          	csrw	sstatus,s1
}
    80002cca:	70a2                	ld	ra,40(sp)
    80002ccc:	7402                	ld	s0,32(sp)
    80002cce:	64e2                	ld	s1,24(sp)
    80002cd0:	6942                	ld	s2,16(sp)
    80002cd2:	69a2                	ld	s3,8(sp)
    80002cd4:	6145                	addi	sp,sp,48
    80002cd6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	6c050513          	addi	a0,a0,1728 # 80008398 <states.0+0xc0>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	85e080e7          	jalr	-1954(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002ce8:	00005517          	auipc	a0,0x5
    80002cec:	6d850513          	addi	a0,a0,1752 # 800083c0 <states.0+0xe8>
    80002cf0:	ffffe097          	auipc	ra,0xffffe
    80002cf4:	84e080e7          	jalr	-1970(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002cf8:	85ce                	mv	a1,s3
    80002cfa:	00005517          	auipc	a0,0x5
    80002cfe:	6e650513          	addi	a0,a0,1766 # 800083e0 <states.0+0x108>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	886080e7          	jalr	-1914(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d0a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d0e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d12:	00005517          	auipc	a0,0x5
    80002d16:	6de50513          	addi	a0,a0,1758 # 800083f0 <states.0+0x118>
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	86e080e7          	jalr	-1938(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	6e650513          	addi	a0,a0,1766 # 80008408 <states.0+0x130>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	814080e7          	jalr	-2028(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	ca0080e7          	jalr	-864(ra) # 800019d2 <myproc>
    80002d3a:	d541                	beqz	a0,80002cc2 <kerneltrap+0x38>
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	c96080e7          	jalr	-874(ra) # 800019d2 <myproc>
    80002d44:	4d18                	lw	a4,24(a0)
    80002d46:	478d                	li	a5,3
    80002d48:	f6f71de3          	bne	a4,a5,80002cc2 <kerneltrap+0x38>
    yield();
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	444080e7          	jalr	1092(ra) # 80002190 <yield>
    80002d54:	b7bd                	j	80002cc2 <kerneltrap+0x38>

0000000080002d56 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d56:	1101                	addi	sp,sp,-32
    80002d58:	ec06                	sd	ra,24(sp)
    80002d5a:	e822                	sd	s0,16(sp)
    80002d5c:	e426                	sd	s1,8(sp)
    80002d5e:	1000                	addi	s0,sp,32
    80002d60:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	c70080e7          	jalr	-912(ra) # 800019d2 <myproc>
  switch (n) {
    80002d6a:	4795                	li	a5,5
    80002d6c:	0497e163          	bltu	a5,s1,80002dae <argraw+0x58>
    80002d70:	048a                	slli	s1,s1,0x2
    80002d72:	00005717          	auipc	a4,0x5
    80002d76:	6ce70713          	addi	a4,a4,1742 # 80008440 <states.0+0x168>
    80002d7a:	94ba                	add	s1,s1,a4
    80002d7c:	409c                	lw	a5,0(s1)
    80002d7e:	97ba                	add	a5,a5,a4
    80002d80:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d82:	6d3c                	ld	a5,88(a0)
    80002d84:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6105                	addi	sp,sp,32
    80002d8e:	8082                	ret
    return p->trapframe->a1;
    80002d90:	6d3c                	ld	a5,88(a0)
    80002d92:	7fa8                	ld	a0,120(a5)
    80002d94:	bfcd                	j	80002d86 <argraw+0x30>
    return p->trapframe->a2;
    80002d96:	6d3c                	ld	a5,88(a0)
    80002d98:	63c8                	ld	a0,128(a5)
    80002d9a:	b7f5                	j	80002d86 <argraw+0x30>
    return p->trapframe->a3;
    80002d9c:	6d3c                	ld	a5,88(a0)
    80002d9e:	67c8                	ld	a0,136(a5)
    80002da0:	b7dd                	j	80002d86 <argraw+0x30>
    return p->trapframe->a4;
    80002da2:	6d3c                	ld	a5,88(a0)
    80002da4:	6bc8                	ld	a0,144(a5)
    80002da6:	b7c5                	j	80002d86 <argraw+0x30>
    return p->trapframe->a5;
    80002da8:	6d3c                	ld	a5,88(a0)
    80002daa:	6fc8                	ld	a0,152(a5)
    80002dac:	bfe9                	j	80002d86 <argraw+0x30>
  panic("argraw");
    80002dae:	00005517          	auipc	a0,0x5
    80002db2:	66a50513          	addi	a0,a0,1642 # 80008418 <states.0+0x140>
    80002db6:	ffffd097          	auipc	ra,0xffffd
    80002dba:	788080e7          	jalr	1928(ra) # 8000053e <panic>

0000000080002dbe <fetchaddr>:
{
    80002dbe:	1101                	addi	sp,sp,-32
    80002dc0:	ec06                	sd	ra,24(sp)
    80002dc2:	e822                	sd	s0,16(sp)
    80002dc4:	e426                	sd	s1,8(sp)
    80002dc6:	e04a                	sd	s2,0(sp)
    80002dc8:	1000                	addi	s0,sp,32
    80002dca:	84aa                	mv	s1,a0
    80002dcc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dce:	fffff097          	auipc	ra,0xfffff
    80002dd2:	c04080e7          	jalr	-1020(ra) # 800019d2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dd6:	653c                	ld	a5,72(a0)
    80002dd8:	02f4f863          	bgeu	s1,a5,80002e08 <fetchaddr+0x4a>
    80002ddc:	00848713          	addi	a4,s1,8
    80002de0:	02e7e663          	bltu	a5,a4,80002e0c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002de4:	46a1                	li	a3,8
    80002de6:	8626                	mv	a2,s1
    80002de8:	85ca                	mv	a1,s2
    80002dea:	6928                	ld	a0,80(a0)
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	908080e7          	jalr	-1784(ra) # 800016f4 <copyin>
    80002df4:	00a03533          	snez	a0,a0
    80002df8:	40a00533          	neg	a0,a0
}
    80002dfc:	60e2                	ld	ra,24(sp)
    80002dfe:	6442                	ld	s0,16(sp)
    80002e00:	64a2                	ld	s1,8(sp)
    80002e02:	6902                	ld	s2,0(sp)
    80002e04:	6105                	addi	sp,sp,32
    80002e06:	8082                	ret
    return -1;
    80002e08:	557d                	li	a0,-1
    80002e0a:	bfcd                	j	80002dfc <fetchaddr+0x3e>
    80002e0c:	557d                	li	a0,-1
    80002e0e:	b7fd                	j	80002dfc <fetchaddr+0x3e>

0000000080002e10 <fetchstr>:
{
    80002e10:	7179                	addi	sp,sp,-48
    80002e12:	f406                	sd	ra,40(sp)
    80002e14:	f022                	sd	s0,32(sp)
    80002e16:	ec26                	sd	s1,24(sp)
    80002e18:	e84a                	sd	s2,16(sp)
    80002e1a:	e44e                	sd	s3,8(sp)
    80002e1c:	1800                	addi	s0,sp,48
    80002e1e:	892a                	mv	s2,a0
    80002e20:	84ae                	mv	s1,a1
    80002e22:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e24:	fffff097          	auipc	ra,0xfffff
    80002e28:	bae080e7          	jalr	-1106(ra) # 800019d2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e2c:	86ce                	mv	a3,s3
    80002e2e:	864a                	mv	a2,s2
    80002e30:	85a6                	mv	a1,s1
    80002e32:	6928                	ld	a0,80(a0)
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	94e080e7          	jalr	-1714(ra) # 80001782 <copyinstr>
    80002e3c:	00054e63          	bltz	a0,80002e58 <fetchstr+0x48>
  return strlen(buf);
    80002e40:	8526                	mv	a0,s1
    80002e42:	ffffe097          	auipc	ra,0xffffe
    80002e46:	00c080e7          	jalr	12(ra) # 80000e4e <strlen>
}
    80002e4a:	70a2                	ld	ra,40(sp)
    80002e4c:	7402                	ld	s0,32(sp)
    80002e4e:	64e2                	ld	s1,24(sp)
    80002e50:	6942                	ld	s2,16(sp)
    80002e52:	69a2                	ld	s3,8(sp)
    80002e54:	6145                	addi	sp,sp,48
    80002e56:	8082                	ret
    return -1;
    80002e58:	557d                	li	a0,-1
    80002e5a:	bfc5                	j	80002e4a <fetchstr+0x3a>

0000000080002e5c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	1000                	addi	s0,sp,32
    80002e66:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e68:	00000097          	auipc	ra,0x0
    80002e6c:	eee080e7          	jalr	-274(ra) # 80002d56 <argraw>
    80002e70:	c088                	sw	a0,0(s1)
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	64a2                	ld	s1,8(sp)
    80002e78:	6105                	addi	sp,sp,32
    80002e7a:	8082                	ret

0000000080002e7c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	1000                	addi	s0,sp,32
    80002e86:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e88:	00000097          	auipc	ra,0x0
    80002e8c:	ece080e7          	jalr	-306(ra) # 80002d56 <argraw>
    80002e90:	e088                	sd	a0,0(s1)
}
    80002e92:	60e2                	ld	ra,24(sp)
    80002e94:	6442                	ld	s0,16(sp)
    80002e96:	64a2                	ld	s1,8(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e9c:	7179                	addi	sp,sp,-48
    80002e9e:	f406                	sd	ra,40(sp)
    80002ea0:	f022                	sd	s0,32(sp)
    80002ea2:	ec26                	sd	s1,24(sp)
    80002ea4:	e84a                	sd	s2,16(sp)
    80002ea6:	1800                	addi	s0,sp,48
    80002ea8:	84ae                	mv	s1,a1
    80002eaa:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002eac:	fd840593          	addi	a1,s0,-40
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	fcc080e7          	jalr	-52(ra) # 80002e7c <argaddr>
  return fetchstr(addr, buf, max);
    80002eb8:	864a                	mv	a2,s2
    80002eba:	85a6                	mv	a1,s1
    80002ebc:	fd843503          	ld	a0,-40(s0)
    80002ec0:	00000097          	auipc	ra,0x0
    80002ec4:	f50080e7          	jalr	-176(ra) # 80002e10 <fetchstr>
}
    80002ec8:	70a2                	ld	ra,40(sp)
    80002eca:	7402                	ld	s0,32(sp)
    80002ecc:	64e2                	ld	s1,24(sp)
    80002ece:	6942                	ld	s2,16(sp)
    80002ed0:	6145                	addi	sp,sp,48
    80002ed2:	8082                	ret

0000000080002ed4 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002ed4:	7179                	addi	sp,sp,-48
    80002ed6:	f406                	sd	ra,40(sp)
    80002ed8:	f022                	sd	s0,32(sp)
    80002eda:	ec26                	sd	s1,24(sp)
    80002edc:	e84a                	sd	s2,16(sp)
    80002ede:	e44e                	sd	s3,8(sp)
    80002ee0:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002ee2:	fffff097          	auipc	ra,0xfffff
    80002ee6:	af0080e7          	jalr	-1296(ra) # 800019d2 <myproc>
    80002eea:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002eec:	05853983          	ld	s3,88(a0)
    80002ef0:	0a89b783          	ld	a5,168(s3)
    80002ef4:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ef8:	37fd                	addiw	a5,a5,-1
    80002efa:	4765                	li	a4,25
    80002efc:	02f76a63          	bltu	a4,a5,80002f30 <syscall+0x5c>
    80002f00:	00391713          	slli	a4,s2,0x3
    80002f04:	00005797          	auipc	a5,0x5
    80002f08:	55478793          	addi	a5,a5,1364 # 80008458 <syscalls>
    80002f0c:	97ba                	add	a5,a5,a4
    80002f0e:	639c                	ld	a5,0(a5)
    80002f10:	c385                	beqz	a5,80002f30 <syscall+0x5c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f12:	9782                	jalr	a5
    80002f14:	06a9b823          	sd	a0,112(s3)
    // incrementSysCount(num);
    if (num >= 0 && num < 32) {
        syscall_counts[num]++;  // Increment the global count for the syscall
    80002f18:	090a                	slli	s2,s2,0x2
    80002f1a:	00017797          	auipc	a5,0x17
    80002f1e:	e8e78793          	addi	a5,a5,-370 # 80019da8 <syscall_counts>
    80002f22:	993e                	add	s2,s2,a5
    80002f24:	00092783          	lw	a5,0(s2)
    80002f28:	2785                	addiw	a5,a5,1
    80002f2a:	00f92023          	sw	a5,0(s2)
    80002f2e:	a005                	j	80002f4e <syscall+0x7a>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f30:	86ca                	mv	a3,s2
    80002f32:	15848613          	addi	a2,s1,344
    80002f36:	588c                	lw	a1,48(s1)
    80002f38:	00005517          	auipc	a0,0x5
    80002f3c:	4e850513          	addi	a0,a0,1256 # 80008420 <states.0+0x148>
    80002f40:	ffffd097          	auipc	ra,0xffffd
    80002f44:	648080e7          	jalr	1608(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f48:	6cbc                	ld	a5,88(s1)
    80002f4a:	577d                	li	a4,-1
    80002f4c:	fbb8                	sd	a4,112(a5)
  }
    80002f4e:	70a2                	ld	ra,40(sp)
    80002f50:	7402                	ld	s0,32(sp)
    80002f52:	64e2                	ld	s1,24(sp)
    80002f54:	6942                	ld	s2,16(sp)
    80002f56:	69a2                	ld	s3,8(sp)
    80002f58:	6145                	addi	sp,sp,48
    80002f5a:	8082                	ret

0000000080002f5c <sys_exit>:

extern int syscall_counts[32];

uint64
sys_exit(void)
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f64:	fec40593          	addi	a1,s0,-20
    80002f68:	4501                	li	a0,0
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	ef2080e7          	jalr	-270(ra) # 80002e5c <argint>
  exit(n);
    80002f72:	fec42503          	lw	a0,-20(s0)
    80002f76:	fffff097          	auipc	ra,0xfffff
    80002f7a:	38a080e7          	jalr	906(ra) # 80002300 <exit>
  return 0; // not reached
}
    80002f7e:	4501                	li	a0,0
    80002f80:	60e2                	ld	ra,24(sp)
    80002f82:	6442                	ld	s0,16(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret

0000000080002f88 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f88:	1141                	addi	sp,sp,-16
    80002f8a:	e406                	sd	ra,8(sp)
    80002f8c:	e022                	sd	s0,0(sp)
    80002f8e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f90:	fffff097          	auipc	ra,0xfffff
    80002f94:	a42080e7          	jalr	-1470(ra) # 800019d2 <myproc>
}
    80002f98:	5908                	lw	a0,48(a0)
    80002f9a:	60a2                	ld	ra,8(sp)
    80002f9c:	6402                	ld	s0,0(sp)
    80002f9e:	0141                	addi	sp,sp,16
    80002fa0:	8082                	ret

0000000080002fa2 <sys_fork>:

uint64
sys_fork(void)
{
    80002fa2:	1141                	addi	sp,sp,-16
    80002fa4:	e406                	sd	ra,8(sp)
    80002fa6:	e022                	sd	s0,0(sp)
    80002fa8:	0800                	addi	s0,sp,16
  return fork();
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	e30080e7          	jalr	-464(ra) # 80001dda <fork>
}
    80002fb2:	60a2                	ld	ra,8(sp)
    80002fb4:	6402                	ld	s0,0(sp)
    80002fb6:	0141                	addi	sp,sp,16
    80002fb8:	8082                	ret

0000000080002fba <sys_wait>:

uint64
sys_wait(void)
{
    80002fba:	1101                	addi	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002fc2:	fe840593          	addi	a1,s0,-24
    80002fc6:	4501                	li	a0,0
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	eb4080e7          	jalr	-332(ra) # 80002e7c <argaddr>
  return wait(p);
    80002fd0:	fe843503          	ld	a0,-24(s0)
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	4dc080e7          	jalr	1244(ra) # 800024b0 <wait>
}
    80002fdc:	60e2                	ld	ra,24(sp)
    80002fde:	6442                	ld	s0,16(sp)
    80002fe0:	6105                	addi	sp,sp,32
    80002fe2:	8082                	ret

0000000080002fe4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fe4:	7179                	addi	sp,sp,-48
    80002fe6:	f406                	sd	ra,40(sp)
    80002fe8:	f022                	sd	s0,32(sp)
    80002fea:	ec26                	sd	s1,24(sp)
    80002fec:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fee:	fdc40593          	addi	a1,s0,-36
    80002ff2:	4501                	li	a0,0
    80002ff4:	00000097          	auipc	ra,0x0
    80002ff8:	e68080e7          	jalr	-408(ra) # 80002e5c <argint>
  addr = myproc()->sz;
    80002ffc:	fffff097          	auipc	ra,0xfffff
    80003000:	9d6080e7          	jalr	-1578(ra) # 800019d2 <myproc>
    80003004:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003006:	fdc42503          	lw	a0,-36(s0)
    8000300a:	fffff097          	auipc	ra,0xfffff
    8000300e:	d74080e7          	jalr	-652(ra) # 80001d7e <growproc>
    80003012:	00054863          	bltz	a0,80003022 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003016:	8526                	mv	a0,s1
    80003018:	70a2                	ld	ra,40(sp)
    8000301a:	7402                	ld	s0,32(sp)
    8000301c:	64e2                	ld	s1,24(sp)
    8000301e:	6145                	addi	sp,sp,48
    80003020:	8082                	ret
    return -1;
    80003022:	54fd                	li	s1,-1
    80003024:	bfcd                	j	80003016 <sys_sbrk+0x32>

0000000080003026 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003026:	7139                	addi	sp,sp,-64
    80003028:	fc06                	sd	ra,56(sp)
    8000302a:	f822                	sd	s0,48(sp)
    8000302c:	f426                	sd	s1,40(sp)
    8000302e:	f04a                	sd	s2,32(sp)
    80003030:	ec4e                	sd	s3,24(sp)
    80003032:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003034:	fcc40593          	addi	a1,s0,-52
    80003038:	4501                	li	a0,0
    8000303a:	00000097          	auipc	ra,0x0
    8000303e:	e22080e7          	jalr	-478(ra) # 80002e5c <argint>
  acquire(&tickslock);
    80003042:	00017517          	auipc	a0,0x17
    80003046:	d4e50513          	addi	a0,a0,-690 # 80019d90 <tickslock>
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	b8c080e7          	jalr	-1140(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003052:	00006917          	auipc	s2,0x6
    80003056:	89e92903          	lw	s2,-1890(s2) # 800088f0 <ticks>
  while (ticks - ticks0 < n)
    8000305a:	fcc42783          	lw	a5,-52(s0)
    8000305e:	cf9d                	beqz	a5,8000309c <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003060:	00017997          	auipc	s3,0x17
    80003064:	d3098993          	addi	s3,s3,-720 # 80019d90 <tickslock>
    80003068:	00006497          	auipc	s1,0x6
    8000306c:	88848493          	addi	s1,s1,-1912 # 800088f0 <ticks>
    if (killed(myproc()))
    80003070:	fffff097          	auipc	ra,0xfffff
    80003074:	962080e7          	jalr	-1694(ra) # 800019d2 <myproc>
    80003078:	fffff097          	auipc	ra,0xfffff
    8000307c:	406080e7          	jalr	1030(ra) # 8000247e <killed>
    80003080:	ed15                	bnez	a0,800030bc <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003082:	85ce                	mv	a1,s3
    80003084:	8526                	mv	a0,s1
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	146080e7          	jalr	326(ra) # 800021cc <sleep>
  while (ticks - ticks0 < n)
    8000308e:	409c                	lw	a5,0(s1)
    80003090:	412787bb          	subw	a5,a5,s2
    80003094:	fcc42703          	lw	a4,-52(s0)
    80003098:	fce7ece3          	bltu	a5,a4,80003070 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000309c:	00017517          	auipc	a0,0x17
    800030a0:	cf450513          	addi	a0,a0,-780 # 80019d90 <tickslock>
    800030a4:	ffffe097          	auipc	ra,0xffffe
    800030a8:	be6080e7          	jalr	-1050(ra) # 80000c8a <release>
  return 0;
    800030ac:	4501                	li	a0,0
}
    800030ae:	70e2                	ld	ra,56(sp)
    800030b0:	7442                	ld	s0,48(sp)
    800030b2:	74a2                	ld	s1,40(sp)
    800030b4:	7902                	ld	s2,32(sp)
    800030b6:	69e2                	ld	s3,24(sp)
    800030b8:	6121                	addi	sp,sp,64
    800030ba:	8082                	ret
      release(&tickslock);
    800030bc:	00017517          	auipc	a0,0x17
    800030c0:	cd450513          	addi	a0,a0,-812 # 80019d90 <tickslock>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	bc6080e7          	jalr	-1082(ra) # 80000c8a <release>
      return -1;
    800030cc:	557d                	li	a0,-1
    800030ce:	b7c5                	j	800030ae <sys_sleep+0x88>

00000000800030d0 <sys_kill>:

uint64
sys_kill(void)
{
    800030d0:	1101                	addi	sp,sp,-32
    800030d2:	ec06                	sd	ra,24(sp)
    800030d4:	e822                	sd	s0,16(sp)
    800030d6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030d8:	fec40593          	addi	a1,s0,-20
    800030dc:	4501                	li	a0,0
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	d7e080e7          	jalr	-642(ra) # 80002e5c <argint>
  return kill(pid);
    800030e6:	fec42503          	lw	a0,-20(s0)
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	2f8080e7          	jalr	760(ra) # 800023e2 <kill>
}
    800030f2:	60e2                	ld	ra,24(sp)
    800030f4:	6442                	ld	s0,16(sp)
    800030f6:	6105                	addi	sp,sp,32
    800030f8:	8082                	ret

00000000800030fa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030fa:	1101                	addi	sp,sp,-32
    800030fc:	ec06                	sd	ra,24(sp)
    800030fe:	e822                	sd	s0,16(sp)
    80003100:	e426                	sd	s1,8(sp)
    80003102:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003104:	00017517          	auipc	a0,0x17
    80003108:	c8c50513          	addi	a0,a0,-884 # 80019d90 <tickslock>
    8000310c:	ffffe097          	auipc	ra,0xffffe
    80003110:	aca080e7          	jalr	-1334(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003114:	00005497          	auipc	s1,0x5
    80003118:	7dc4a483          	lw	s1,2012(s1) # 800088f0 <ticks>
  release(&tickslock);
    8000311c:	00017517          	auipc	a0,0x17
    80003120:	c7450513          	addi	a0,a0,-908 # 80019d90 <tickslock>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	b66080e7          	jalr	-1178(ra) # 80000c8a <release>
  return xticks;
}
    8000312c:	02049513          	slli	a0,s1,0x20
    80003130:	9101                	srli	a0,a0,0x20
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	64a2                	ld	s1,8(sp)
    80003138:	6105                	addi	sp,sp,32
    8000313a:	8082                	ret

000000008000313c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000313c:	7139                	addi	sp,sp,-64
    8000313e:	fc06                	sd	ra,56(sp)
    80003140:	f822                	sd	s0,48(sp)
    80003142:	f426                	sd	s1,40(sp)
    80003144:	f04a                	sd	s2,32(sp)
    80003146:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003148:	fd840593          	addi	a1,s0,-40
    8000314c:	4501                	li	a0,0
    8000314e:	00000097          	auipc	ra,0x0
    80003152:	d2e080e7          	jalr	-722(ra) # 80002e7c <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003156:	fd040593          	addi	a1,s0,-48
    8000315a:	4505                	li	a0,1
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	d20080e7          	jalr	-736(ra) # 80002e7c <argaddr>
  argaddr(2, &addr2);
    80003164:	fc840593          	addi	a1,s0,-56
    80003168:	4509                	li	a0,2
    8000316a:	00000097          	auipc	ra,0x0
    8000316e:	d12080e7          	jalr	-750(ra) # 80002e7c <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003172:	fc040613          	addi	a2,s0,-64
    80003176:	fc440593          	addi	a1,s0,-60
    8000317a:	fd843503          	ld	a0,-40(s0)
    8000317e:	fffff097          	auipc	ra,0xfffff
    80003182:	5ba080e7          	jalr	1466(ra) # 80002738 <waitx>
    80003186:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	84a080e7          	jalr	-1974(ra) # 800019d2 <myproc>
    80003190:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003192:	4691                	li	a3,4
    80003194:	fc440613          	addi	a2,s0,-60
    80003198:	fd043583          	ld	a1,-48(s0)
    8000319c:	6928                	ld	a0,80(a0)
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	4ca080e7          	jalr	1226(ra) # 80001668 <copyout>
    return -1;
    800031a6:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800031a8:	00054f63          	bltz	a0,800031c6 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800031ac:	4691                	li	a3,4
    800031ae:	fc040613          	addi	a2,s0,-64
    800031b2:	fc843583          	ld	a1,-56(s0)
    800031b6:	68a8                	ld	a0,80(s1)
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	4b0080e7          	jalr	1200(ra) # 80001668 <copyout>
    800031c0:	00054a63          	bltz	a0,800031d4 <sys_waitx+0x98>
    return -1;
  return ret;
    800031c4:	87ca                	mv	a5,s2
}
    800031c6:	853e                	mv	a0,a5
    800031c8:	70e2                	ld	ra,56(sp)
    800031ca:	7442                	ld	s0,48(sp)
    800031cc:	74a2                	ld	s1,40(sp)
    800031ce:	7902                	ld	s2,32(sp)
    800031d0:	6121                	addi	sp,sp,64
    800031d2:	8082                	ret
    return -1;
    800031d4:	57fd                	li	a5,-1
    800031d6:	bfc5                	j	800031c6 <sys_waitx+0x8a>

00000000800031d8 <sys_settickets>:

///////////////////////
uint64 
sys_settickets(void) {
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	1000                	addi	s0,sp,32
    int number;
    argint(0, &number);
    800031e0:	fec40593          	addi	a1,s0,-20
    800031e4:	4501                	li	a0,0
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	c76080e7          	jalr	-906(ra) # 80002e5c <argint>
    myproc()->tickets = number; // Set the number of tickets for the current process
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	7e4080e7          	jalr	2020(ra) # 800019d2 <myproc>
    800031f6:	fec42783          	lw	a5,-20(s0)
    800031fa:	16f52a23          	sw	a5,372(a0)
    return number;
}
    800031fe:	853e                	mv	a0,a5
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret

0000000080003208 <sys_getSysCount>:

uint64 
sys_getSysCount(void) {
    80003208:	1101                	addi	sp,sp,-32
    8000320a:	ec06                	sd	ra,24(sp)
    8000320c:	e822                	sd	s0,16(sp)
    8000320e:	1000                	addi	s0,sp,32
    int mask;
    argint(0, &mask);
    80003210:	fec40593          	addi	a1,s0,-20
    80003214:	4501                	li	a0,0
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	c46080e7          	jalr	-954(ra) # 80002e5c <argint>
    // Return the count of the specified syscall
    int syscall_number = -1;
    for (int i = 0; i < 32; i++) {
        if (mask & (1 << i)) {
    8000321e:	fec42683          	lw	a3,-20(s0)
    80003222:	0016f793          	andi	a5,a3,1
    80003226:	eb9d                	bnez	a5,8000325c <sys_getSysCount+0x54>
    for (int i = 0; i < 32; i++) {
    80003228:	4785                	li	a5,1
    8000322a:	02000613          	li	a2,32
        if (mask & (1 << i)) {
    8000322e:	40f6d73b          	sraw	a4,a3,a5
    80003232:	8b05                	andi	a4,a4,1
    80003234:	e711                	bnez	a4,80003240 <sys_getSysCount+0x38>
    for (int i = 0; i < 32; i++) {
    80003236:	2785                	addiw	a5,a5,1
    80003238:	fec79be3          	bne	a5,a2,8000322e <sys_getSysCount+0x26>
        }
    }

    // Check if a valid syscall number was found
    if (syscall_number == -1) {
        return -1;  // No valid syscall found in the mask
    8000323c:	557d                	li	a0,-1
    8000323e:	a819                	j	80003254 <sys_getSysCount+0x4c>
    if (syscall_number == -1) {
    80003240:	577d                	li	a4,-1
    80003242:	00e78f63          	beq	a5,a4,80003260 <sys_getSysCount+0x58>
    }
    return syscall_counts[syscall_number];
    80003246:	078a                	slli	a5,a5,0x2
    80003248:	00017717          	auipc	a4,0x17
    8000324c:	b6070713          	addi	a4,a4,-1184 # 80019da8 <syscall_counts>
    80003250:	97ba                	add	a5,a5,a4
    80003252:	4388                	lw	a0,0(a5)
}
    80003254:	60e2                	ld	ra,24(sp)
    80003256:	6442                	ld	s0,16(sp)
    80003258:	6105                	addi	sp,sp,32
    8000325a:	8082                	ret
    for (int i = 0; i < 32; i++) {
    8000325c:	4781                	li	a5,0
    8000325e:	b7e5                	j	80003246 <sys_getSysCount+0x3e>
        return -1;  // No valid syscall found in the mask
    80003260:	557d                	li	a0,-1
    80003262:	bfcd                	j	80003254 <sys_getSysCount+0x4c>

0000000080003264 <sys_sigalarm>:

uint64 
sys_sigalarm(void) {
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	1000                	addi	s0,sp,32
    int interval;
    uint64 handler;

    // Fetch the arguments
    argint(0, &interval);
    8000326c:	fec40593          	addi	a1,s0,-20
    80003270:	4501                	li	a0,0
    80003272:	00000097          	auipc	ra,0x0
    80003276:	bea080e7          	jalr	-1046(ra) # 80002e5c <argint>
    argaddr(1, &handler);
    8000327a:	fe040593          	addi	a1,s0,-32
    8000327e:	4505                	li	a0,1
    80003280:	00000097          	auipc	ra,0x0
    80003284:	bfc080e7          	jalr	-1028(ra) # 80002e7c <argaddr>

    struct proc *p = myproc();
    80003288:	ffffe097          	auipc	ra,0xffffe
    8000328c:	74a080e7          	jalr	1866(ra) # 800019d2 <myproc>

    // Set the alarm state
    p->alarm_interval = interval;
    80003290:	fec42783          	lw	a5,-20(s0)
    80003294:	18f52c23          	sw	a5,408(a0)
    p->alarm_handler = handler;
    80003298:	fe043783          	ld	a5,-32(s0)
    8000329c:	18f53823          	sd	a5,400(a0)
    p->alarm_state = 1; // Enable the alarm
    800032a0:	4785                	li	a5,1
    800032a2:	1af52023          	sw	a5,416(a0)

    return 0;
}
    800032a6:	4501                	li	a0,0
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	6105                	addi	sp,sp,32
    800032ae:	8082                	ret

00000000800032b0 <sys_sigreturn>:


uint64 
sys_sigreturn(void) {
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	718080e7          	jalr	1816(ra) # 800019d2 <myproc>
    800032c2:	84aa                	mv	s1,a0
    // p->alarm_state = 0; // Disable the alarm

    // // Restore the saved context
    // // Assuming you have saved context in p->saved_context (you need to save it when switching)
    // p->context = p->saved_context;
    memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800032c4:	6605                	lui	a2,0x1
    800032c6:	21853583          	ld	a1,536(a0)
    800032ca:	6d28                	ld	a0,88(a0)
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	a62080e7          	jalr	-1438(ra) # 80000d2e <memmove>
    kfree(p->alarm_tf);
    800032d4:	2184b503          	ld	a0,536(s1)
    800032d8:	ffffd097          	auipc	ra,0xffffd
    800032dc:	712080e7          	jalr	1810(ra) # 800009ea <kfree>
    p->handle_permission=1;
    800032e0:	4785                	li	a5,1
    800032e2:	22f4a023          	sw	a5,544(s1)
    return p->trapframe->a0;
    800032e6:	6cbc                	ld	a5,88(s1)
}
    800032e8:	7ba8                	ld	a0,112(a5)
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret

00000000800032f4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032f4:	7179                	addi	sp,sp,-48
    800032f6:	f406                	sd	ra,40(sp)
    800032f8:	f022                	sd	s0,32(sp)
    800032fa:	ec26                	sd	s1,24(sp)
    800032fc:	e84a                	sd	s2,16(sp)
    800032fe:	e44e                	sd	s3,8(sp)
    80003300:	e052                	sd	s4,0(sp)
    80003302:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003304:	00005597          	auipc	a1,0x5
    80003308:	22c58593          	addi	a1,a1,556 # 80008530 <syscalls+0xd8>
    8000330c:	00017517          	auipc	a0,0x17
    80003310:	b1c50513          	addi	a0,a0,-1252 # 80019e28 <bcache>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	832080e7          	jalr	-1998(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000331c:	0001f797          	auipc	a5,0x1f
    80003320:	b0c78793          	addi	a5,a5,-1268 # 80021e28 <bcache+0x8000>
    80003324:	0001f717          	auipc	a4,0x1f
    80003328:	d6c70713          	addi	a4,a4,-660 # 80022090 <bcache+0x8268>
    8000332c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003330:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003334:	00017497          	auipc	s1,0x17
    80003338:	b0c48493          	addi	s1,s1,-1268 # 80019e40 <bcache+0x18>
    b->next = bcache.head.next;
    8000333c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000333e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003340:	00005a17          	auipc	s4,0x5
    80003344:	1f8a0a13          	addi	s4,s4,504 # 80008538 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003348:	2b893783          	ld	a5,696(s2)
    8000334c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000334e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003352:	85d2                	mv	a1,s4
    80003354:	01048513          	addi	a0,s1,16
    80003358:	00001097          	auipc	ra,0x1
    8000335c:	4c4080e7          	jalr	1220(ra) # 8000481c <initsleeplock>
    bcache.head.next->prev = b;
    80003360:	2b893783          	ld	a5,696(s2)
    80003364:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003366:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000336a:	45848493          	addi	s1,s1,1112
    8000336e:	fd349de3          	bne	s1,s3,80003348 <binit+0x54>
  }
}
    80003372:	70a2                	ld	ra,40(sp)
    80003374:	7402                	ld	s0,32(sp)
    80003376:	64e2                	ld	s1,24(sp)
    80003378:	6942                	ld	s2,16(sp)
    8000337a:	69a2                	ld	s3,8(sp)
    8000337c:	6a02                	ld	s4,0(sp)
    8000337e:	6145                	addi	sp,sp,48
    80003380:	8082                	ret

0000000080003382 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003382:	7179                	addi	sp,sp,-48
    80003384:	f406                	sd	ra,40(sp)
    80003386:	f022                	sd	s0,32(sp)
    80003388:	ec26                	sd	s1,24(sp)
    8000338a:	e84a                	sd	s2,16(sp)
    8000338c:	e44e                	sd	s3,8(sp)
    8000338e:	1800                	addi	s0,sp,48
    80003390:	892a                	mv	s2,a0
    80003392:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003394:	00017517          	auipc	a0,0x17
    80003398:	a9450513          	addi	a0,a0,-1388 # 80019e28 <bcache>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	83a080e7          	jalr	-1990(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033a4:	0001f497          	auipc	s1,0x1f
    800033a8:	d3c4b483          	ld	s1,-708(s1) # 800220e0 <bcache+0x82b8>
    800033ac:	0001f797          	auipc	a5,0x1f
    800033b0:	ce478793          	addi	a5,a5,-796 # 80022090 <bcache+0x8268>
    800033b4:	02f48f63          	beq	s1,a5,800033f2 <bread+0x70>
    800033b8:	873e                	mv	a4,a5
    800033ba:	a021                	j	800033c2 <bread+0x40>
    800033bc:	68a4                	ld	s1,80(s1)
    800033be:	02e48a63          	beq	s1,a4,800033f2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033c2:	449c                	lw	a5,8(s1)
    800033c4:	ff279ce3          	bne	a5,s2,800033bc <bread+0x3a>
    800033c8:	44dc                	lw	a5,12(s1)
    800033ca:	ff3799e3          	bne	a5,s3,800033bc <bread+0x3a>
      b->refcnt++;
    800033ce:	40bc                	lw	a5,64(s1)
    800033d0:	2785                	addiw	a5,a5,1
    800033d2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033d4:	00017517          	auipc	a0,0x17
    800033d8:	a5450513          	addi	a0,a0,-1452 # 80019e28 <bcache>
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800033e4:	01048513          	addi	a0,s1,16
    800033e8:	00001097          	auipc	ra,0x1
    800033ec:	46e080e7          	jalr	1134(ra) # 80004856 <acquiresleep>
      return b;
    800033f0:	a8b9                	j	8000344e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033f2:	0001f497          	auipc	s1,0x1f
    800033f6:	ce64b483          	ld	s1,-794(s1) # 800220d8 <bcache+0x82b0>
    800033fa:	0001f797          	auipc	a5,0x1f
    800033fe:	c9678793          	addi	a5,a5,-874 # 80022090 <bcache+0x8268>
    80003402:	00f48863          	beq	s1,a5,80003412 <bread+0x90>
    80003406:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003408:	40bc                	lw	a5,64(s1)
    8000340a:	cf81                	beqz	a5,80003422 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000340c:	64a4                	ld	s1,72(s1)
    8000340e:	fee49de3          	bne	s1,a4,80003408 <bread+0x86>
  panic("bget: no buffers");
    80003412:	00005517          	auipc	a0,0x5
    80003416:	12e50513          	addi	a0,a0,302 # 80008540 <syscalls+0xe8>
    8000341a:	ffffd097          	auipc	ra,0xffffd
    8000341e:	124080e7          	jalr	292(ra) # 8000053e <panic>
      b->dev = dev;
    80003422:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003426:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000342a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000342e:	4785                	li	a5,1
    80003430:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003432:	00017517          	auipc	a0,0x17
    80003436:	9f650513          	addi	a0,a0,-1546 # 80019e28 <bcache>
    8000343a:	ffffe097          	auipc	ra,0xffffe
    8000343e:	850080e7          	jalr	-1968(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003442:	01048513          	addi	a0,s1,16
    80003446:	00001097          	auipc	ra,0x1
    8000344a:	410080e7          	jalr	1040(ra) # 80004856 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000344e:	409c                	lw	a5,0(s1)
    80003450:	cb89                	beqz	a5,80003462 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003452:	8526                	mv	a0,s1
    80003454:	70a2                	ld	ra,40(sp)
    80003456:	7402                	ld	s0,32(sp)
    80003458:	64e2                	ld	s1,24(sp)
    8000345a:	6942                	ld	s2,16(sp)
    8000345c:	69a2                	ld	s3,8(sp)
    8000345e:	6145                	addi	sp,sp,48
    80003460:	8082                	ret
    virtio_disk_rw(b, 0);
    80003462:	4581                	li	a1,0
    80003464:	8526                	mv	a0,s1
    80003466:	00003097          	auipc	ra,0x3
    8000346a:	fde080e7          	jalr	-34(ra) # 80006444 <virtio_disk_rw>
    b->valid = 1;
    8000346e:	4785                	li	a5,1
    80003470:	c09c                	sw	a5,0(s1)
  return b;
    80003472:	b7c5                	j	80003452 <bread+0xd0>

0000000080003474 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003474:	1101                	addi	sp,sp,-32
    80003476:	ec06                	sd	ra,24(sp)
    80003478:	e822                	sd	s0,16(sp)
    8000347a:	e426                	sd	s1,8(sp)
    8000347c:	1000                	addi	s0,sp,32
    8000347e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003480:	0541                	addi	a0,a0,16
    80003482:	00001097          	auipc	ra,0x1
    80003486:	46e080e7          	jalr	1134(ra) # 800048f0 <holdingsleep>
    8000348a:	cd01                	beqz	a0,800034a2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000348c:	4585                	li	a1,1
    8000348e:	8526                	mv	a0,s1
    80003490:	00003097          	auipc	ra,0x3
    80003494:	fb4080e7          	jalr	-76(ra) # 80006444 <virtio_disk_rw>
}
    80003498:	60e2                	ld	ra,24(sp)
    8000349a:	6442                	ld	s0,16(sp)
    8000349c:	64a2                	ld	s1,8(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret
    panic("bwrite");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	0b650513          	addi	a0,a0,182 # 80008558 <syscalls+0x100>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	094080e7          	jalr	148(ra) # 8000053e <panic>

00000000800034b2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034b2:	1101                	addi	sp,sp,-32
    800034b4:	ec06                	sd	ra,24(sp)
    800034b6:	e822                	sd	s0,16(sp)
    800034b8:	e426                	sd	s1,8(sp)
    800034ba:	e04a                	sd	s2,0(sp)
    800034bc:	1000                	addi	s0,sp,32
    800034be:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034c0:	01050913          	addi	s2,a0,16
    800034c4:	854a                	mv	a0,s2
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	42a080e7          	jalr	1066(ra) # 800048f0 <holdingsleep>
    800034ce:	c92d                	beqz	a0,80003540 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800034d0:	854a                	mv	a0,s2
    800034d2:	00001097          	auipc	ra,0x1
    800034d6:	3da080e7          	jalr	986(ra) # 800048ac <releasesleep>

  acquire(&bcache.lock);
    800034da:	00017517          	auipc	a0,0x17
    800034de:	94e50513          	addi	a0,a0,-1714 # 80019e28 <bcache>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	6f4080e7          	jalr	1780(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800034ea:	40bc                	lw	a5,64(s1)
    800034ec:	37fd                	addiw	a5,a5,-1
    800034ee:	0007871b          	sext.w	a4,a5
    800034f2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034f4:	eb05                	bnez	a4,80003524 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034f6:	68bc                	ld	a5,80(s1)
    800034f8:	64b8                	ld	a4,72(s1)
    800034fa:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034fc:	64bc                	ld	a5,72(s1)
    800034fe:	68b8                	ld	a4,80(s1)
    80003500:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003502:	0001f797          	auipc	a5,0x1f
    80003506:	92678793          	addi	a5,a5,-1754 # 80021e28 <bcache+0x8000>
    8000350a:	2b87b703          	ld	a4,696(a5)
    8000350e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003510:	0001f717          	auipc	a4,0x1f
    80003514:	b8070713          	addi	a4,a4,-1152 # 80022090 <bcache+0x8268>
    80003518:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000351a:	2b87b703          	ld	a4,696(a5)
    8000351e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003520:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003524:	00017517          	auipc	a0,0x17
    80003528:	90450513          	addi	a0,a0,-1788 # 80019e28 <bcache>
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	75e080e7          	jalr	1886(ra) # 80000c8a <release>
}
    80003534:	60e2                	ld	ra,24(sp)
    80003536:	6442                	ld	s0,16(sp)
    80003538:	64a2                	ld	s1,8(sp)
    8000353a:	6902                	ld	s2,0(sp)
    8000353c:	6105                	addi	sp,sp,32
    8000353e:	8082                	ret
    panic("brelse");
    80003540:	00005517          	auipc	a0,0x5
    80003544:	02050513          	addi	a0,a0,32 # 80008560 <syscalls+0x108>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	ff6080e7          	jalr	-10(ra) # 8000053e <panic>

0000000080003550 <bpin>:

void
bpin(struct buf *b) {
    80003550:	1101                	addi	sp,sp,-32
    80003552:	ec06                	sd	ra,24(sp)
    80003554:	e822                	sd	s0,16(sp)
    80003556:	e426                	sd	s1,8(sp)
    80003558:	1000                	addi	s0,sp,32
    8000355a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000355c:	00017517          	auipc	a0,0x17
    80003560:	8cc50513          	addi	a0,a0,-1844 # 80019e28 <bcache>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	672080e7          	jalr	1650(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000356c:	40bc                	lw	a5,64(s1)
    8000356e:	2785                	addiw	a5,a5,1
    80003570:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003572:	00017517          	auipc	a0,0x17
    80003576:	8b650513          	addi	a0,a0,-1866 # 80019e28 <bcache>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	710080e7          	jalr	1808(ra) # 80000c8a <release>
}
    80003582:	60e2                	ld	ra,24(sp)
    80003584:	6442                	ld	s0,16(sp)
    80003586:	64a2                	ld	s1,8(sp)
    80003588:	6105                	addi	sp,sp,32
    8000358a:	8082                	ret

000000008000358c <bunpin>:

void
bunpin(struct buf *b) {
    8000358c:	1101                	addi	sp,sp,-32
    8000358e:	ec06                	sd	ra,24(sp)
    80003590:	e822                	sd	s0,16(sp)
    80003592:	e426                	sd	s1,8(sp)
    80003594:	1000                	addi	s0,sp,32
    80003596:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003598:	00017517          	auipc	a0,0x17
    8000359c:	89050513          	addi	a0,a0,-1904 # 80019e28 <bcache>
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	636080e7          	jalr	1590(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035a8:	40bc                	lw	a5,64(s1)
    800035aa:	37fd                	addiw	a5,a5,-1
    800035ac:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ae:	00017517          	auipc	a0,0x17
    800035b2:	87a50513          	addi	a0,a0,-1926 # 80019e28 <bcache>
    800035b6:	ffffd097          	auipc	ra,0xffffd
    800035ba:	6d4080e7          	jalr	1748(ra) # 80000c8a <release>
}
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	64a2                	ld	s1,8(sp)
    800035c4:	6105                	addi	sp,sp,32
    800035c6:	8082                	ret

00000000800035c8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	e04a                	sd	s2,0(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035d6:	00d5d59b          	srliw	a1,a1,0xd
    800035da:	0001f797          	auipc	a5,0x1f
    800035de:	f2a7a783          	lw	a5,-214(a5) # 80022504 <sb+0x1c>
    800035e2:	9dbd                	addw	a1,a1,a5
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	d9e080e7          	jalr	-610(ra) # 80003382 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035ec:	0074f713          	andi	a4,s1,7
    800035f0:	4785                	li	a5,1
    800035f2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035f6:	14ce                	slli	s1,s1,0x33
    800035f8:	90d9                	srli	s1,s1,0x36
    800035fa:	00950733          	add	a4,a0,s1
    800035fe:	05874703          	lbu	a4,88(a4)
    80003602:	00e7f6b3          	and	a3,a5,a4
    80003606:	c69d                	beqz	a3,80003634 <bfree+0x6c>
    80003608:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000360a:	94aa                	add	s1,s1,a0
    8000360c:	fff7c793          	not	a5,a5
    80003610:	8ff9                	and	a5,a5,a4
    80003612:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003616:	00001097          	auipc	ra,0x1
    8000361a:	120080e7          	jalr	288(ra) # 80004736 <log_write>
  brelse(bp);
    8000361e:	854a                	mv	a0,s2
    80003620:	00000097          	auipc	ra,0x0
    80003624:	e92080e7          	jalr	-366(ra) # 800034b2 <brelse>
}
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	64a2                	ld	s1,8(sp)
    8000362e:	6902                	ld	s2,0(sp)
    80003630:	6105                	addi	sp,sp,32
    80003632:	8082                	ret
    panic("freeing free block");
    80003634:	00005517          	auipc	a0,0x5
    80003638:	f3450513          	addi	a0,a0,-204 # 80008568 <syscalls+0x110>
    8000363c:	ffffd097          	auipc	ra,0xffffd
    80003640:	f02080e7          	jalr	-254(ra) # 8000053e <panic>

0000000080003644 <balloc>:
{
    80003644:	711d                	addi	sp,sp,-96
    80003646:	ec86                	sd	ra,88(sp)
    80003648:	e8a2                	sd	s0,80(sp)
    8000364a:	e4a6                	sd	s1,72(sp)
    8000364c:	e0ca                	sd	s2,64(sp)
    8000364e:	fc4e                	sd	s3,56(sp)
    80003650:	f852                	sd	s4,48(sp)
    80003652:	f456                	sd	s5,40(sp)
    80003654:	f05a                	sd	s6,32(sp)
    80003656:	ec5e                	sd	s7,24(sp)
    80003658:	e862                	sd	s8,16(sp)
    8000365a:	e466                	sd	s9,8(sp)
    8000365c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000365e:	0001f797          	auipc	a5,0x1f
    80003662:	e8e7a783          	lw	a5,-370(a5) # 800224ec <sb+0x4>
    80003666:	10078163          	beqz	a5,80003768 <balloc+0x124>
    8000366a:	8baa                	mv	s7,a0
    8000366c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000366e:	0001fb17          	auipc	s6,0x1f
    80003672:	e7ab0b13          	addi	s6,s6,-390 # 800224e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003676:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003678:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000367a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000367c:	6c89                	lui	s9,0x2
    8000367e:	a061                	j	80003706 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003680:	974a                	add	a4,a4,s2
    80003682:	8fd5                	or	a5,a5,a3
    80003684:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003688:	854a                	mv	a0,s2
    8000368a:	00001097          	auipc	ra,0x1
    8000368e:	0ac080e7          	jalr	172(ra) # 80004736 <log_write>
        brelse(bp);
    80003692:	854a                	mv	a0,s2
    80003694:	00000097          	auipc	ra,0x0
    80003698:	e1e080e7          	jalr	-482(ra) # 800034b2 <brelse>
  bp = bread(dev, bno);
    8000369c:	85a6                	mv	a1,s1
    8000369e:	855e                	mv	a0,s7
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	ce2080e7          	jalr	-798(ra) # 80003382 <bread>
    800036a8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036aa:	40000613          	li	a2,1024
    800036ae:	4581                	li	a1,0
    800036b0:	05850513          	addi	a0,a0,88
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	61e080e7          	jalr	1566(ra) # 80000cd2 <memset>
  log_write(bp);
    800036bc:	854a                	mv	a0,s2
    800036be:	00001097          	auipc	ra,0x1
    800036c2:	078080e7          	jalr	120(ra) # 80004736 <log_write>
  brelse(bp);
    800036c6:	854a                	mv	a0,s2
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	dea080e7          	jalr	-534(ra) # 800034b2 <brelse>
}
    800036d0:	8526                	mv	a0,s1
    800036d2:	60e6                	ld	ra,88(sp)
    800036d4:	6446                	ld	s0,80(sp)
    800036d6:	64a6                	ld	s1,72(sp)
    800036d8:	6906                	ld	s2,64(sp)
    800036da:	79e2                	ld	s3,56(sp)
    800036dc:	7a42                	ld	s4,48(sp)
    800036de:	7aa2                	ld	s5,40(sp)
    800036e0:	7b02                	ld	s6,32(sp)
    800036e2:	6be2                	ld	s7,24(sp)
    800036e4:	6c42                	ld	s8,16(sp)
    800036e6:	6ca2                	ld	s9,8(sp)
    800036e8:	6125                	addi	sp,sp,96
    800036ea:	8082                	ret
    brelse(bp);
    800036ec:	854a                	mv	a0,s2
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	dc4080e7          	jalr	-572(ra) # 800034b2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036f6:	015c87bb          	addw	a5,s9,s5
    800036fa:	00078a9b          	sext.w	s5,a5
    800036fe:	004b2703          	lw	a4,4(s6)
    80003702:	06eaf363          	bgeu	s5,a4,80003768 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003706:	41fad79b          	sraiw	a5,s5,0x1f
    8000370a:	0137d79b          	srliw	a5,a5,0x13
    8000370e:	015787bb          	addw	a5,a5,s5
    80003712:	40d7d79b          	sraiw	a5,a5,0xd
    80003716:	01cb2583          	lw	a1,28(s6)
    8000371a:	9dbd                	addw	a1,a1,a5
    8000371c:	855e                	mv	a0,s7
    8000371e:	00000097          	auipc	ra,0x0
    80003722:	c64080e7          	jalr	-924(ra) # 80003382 <bread>
    80003726:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003728:	004b2503          	lw	a0,4(s6)
    8000372c:	000a849b          	sext.w	s1,s5
    80003730:	8662                	mv	a2,s8
    80003732:	faa4fde3          	bgeu	s1,a0,800036ec <balloc+0xa8>
      m = 1 << (bi % 8);
    80003736:	41f6579b          	sraiw	a5,a2,0x1f
    8000373a:	01d7d69b          	srliw	a3,a5,0x1d
    8000373e:	00c6873b          	addw	a4,a3,a2
    80003742:	00777793          	andi	a5,a4,7
    80003746:	9f95                	subw	a5,a5,a3
    80003748:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000374c:	4037571b          	sraiw	a4,a4,0x3
    80003750:	00e906b3          	add	a3,s2,a4
    80003754:	0586c683          	lbu	a3,88(a3)
    80003758:	00d7f5b3          	and	a1,a5,a3
    8000375c:	d195                	beqz	a1,80003680 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000375e:	2605                	addiw	a2,a2,1
    80003760:	2485                	addiw	s1,s1,1
    80003762:	fd4618e3          	bne	a2,s4,80003732 <balloc+0xee>
    80003766:	b759                	j	800036ec <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	e1850513          	addi	a0,a0,-488 # 80008580 <syscalls+0x128>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	e18080e7          	jalr	-488(ra) # 80000588 <printf>
  return 0;
    80003778:	4481                	li	s1,0
    8000377a:	bf99                	j	800036d0 <balloc+0x8c>

000000008000377c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000377c:	7179                	addi	sp,sp,-48
    8000377e:	f406                	sd	ra,40(sp)
    80003780:	f022                	sd	s0,32(sp)
    80003782:	ec26                	sd	s1,24(sp)
    80003784:	e84a                	sd	s2,16(sp)
    80003786:	e44e                	sd	s3,8(sp)
    80003788:	e052                	sd	s4,0(sp)
    8000378a:	1800                	addi	s0,sp,48
    8000378c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000378e:	47ad                	li	a5,11
    80003790:	02b7e763          	bltu	a5,a1,800037be <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003794:	02059493          	slli	s1,a1,0x20
    80003798:	9081                	srli	s1,s1,0x20
    8000379a:	048a                	slli	s1,s1,0x2
    8000379c:	94aa                	add	s1,s1,a0
    8000379e:	0504a903          	lw	s2,80(s1)
    800037a2:	06091e63          	bnez	s2,8000381e <bmap+0xa2>
      addr = balloc(ip->dev);
    800037a6:	4108                	lw	a0,0(a0)
    800037a8:	00000097          	auipc	ra,0x0
    800037ac:	e9c080e7          	jalr	-356(ra) # 80003644 <balloc>
    800037b0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037b4:	06090563          	beqz	s2,8000381e <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800037b8:	0524a823          	sw	s2,80(s1)
    800037bc:	a08d                	j	8000381e <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037be:	ff45849b          	addiw	s1,a1,-12
    800037c2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037c6:	0ff00793          	li	a5,255
    800037ca:	08e7e563          	bltu	a5,a4,80003854 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037ce:	08052903          	lw	s2,128(a0)
    800037d2:	00091d63          	bnez	s2,800037ec <bmap+0x70>
      addr = balloc(ip->dev);
    800037d6:	4108                	lw	a0,0(a0)
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	e6c080e7          	jalr	-404(ra) # 80003644 <balloc>
    800037e0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037e4:	02090d63          	beqz	s2,8000381e <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037e8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037ec:	85ca                	mv	a1,s2
    800037ee:	0009a503          	lw	a0,0(s3)
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	b90080e7          	jalr	-1136(ra) # 80003382 <bread>
    800037fa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037fc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003800:	02049593          	slli	a1,s1,0x20
    80003804:	9181                	srli	a1,a1,0x20
    80003806:	058a                	slli	a1,a1,0x2
    80003808:	00b784b3          	add	s1,a5,a1
    8000380c:	0004a903          	lw	s2,0(s1)
    80003810:	02090063          	beqz	s2,80003830 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003814:	8552                	mv	a0,s4
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	c9c080e7          	jalr	-868(ra) # 800034b2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000381e:	854a                	mv	a0,s2
    80003820:	70a2                	ld	ra,40(sp)
    80003822:	7402                	ld	s0,32(sp)
    80003824:	64e2                	ld	s1,24(sp)
    80003826:	6942                	ld	s2,16(sp)
    80003828:	69a2                	ld	s3,8(sp)
    8000382a:	6a02                	ld	s4,0(sp)
    8000382c:	6145                	addi	sp,sp,48
    8000382e:	8082                	ret
      addr = balloc(ip->dev);
    80003830:	0009a503          	lw	a0,0(s3)
    80003834:	00000097          	auipc	ra,0x0
    80003838:	e10080e7          	jalr	-496(ra) # 80003644 <balloc>
    8000383c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003840:	fc090ae3          	beqz	s2,80003814 <bmap+0x98>
        a[bn] = addr;
    80003844:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003848:	8552                	mv	a0,s4
    8000384a:	00001097          	auipc	ra,0x1
    8000384e:	eec080e7          	jalr	-276(ra) # 80004736 <log_write>
    80003852:	b7c9                	j	80003814 <bmap+0x98>
  panic("bmap: out of range");
    80003854:	00005517          	auipc	a0,0x5
    80003858:	d4450513          	addi	a0,a0,-700 # 80008598 <syscalls+0x140>
    8000385c:	ffffd097          	auipc	ra,0xffffd
    80003860:	ce2080e7          	jalr	-798(ra) # 8000053e <panic>

0000000080003864 <iget>:
{
    80003864:	7179                	addi	sp,sp,-48
    80003866:	f406                	sd	ra,40(sp)
    80003868:	f022                	sd	s0,32(sp)
    8000386a:	ec26                	sd	s1,24(sp)
    8000386c:	e84a                	sd	s2,16(sp)
    8000386e:	e44e                	sd	s3,8(sp)
    80003870:	e052                	sd	s4,0(sp)
    80003872:	1800                	addi	s0,sp,48
    80003874:	89aa                	mv	s3,a0
    80003876:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003878:	0001f517          	auipc	a0,0x1f
    8000387c:	c9050513          	addi	a0,a0,-880 # 80022508 <itable>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	356080e7          	jalr	854(ra) # 80000bd6 <acquire>
  empty = 0;
    80003888:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000388a:	0001f497          	auipc	s1,0x1f
    8000388e:	c9648493          	addi	s1,s1,-874 # 80022520 <itable+0x18>
    80003892:	00020697          	auipc	a3,0x20
    80003896:	71e68693          	addi	a3,a3,1822 # 80023fb0 <log>
    8000389a:	a039                	j	800038a8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000389c:	02090b63          	beqz	s2,800038d2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038a0:	08848493          	addi	s1,s1,136
    800038a4:	02d48a63          	beq	s1,a3,800038d8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038a8:	449c                	lw	a5,8(s1)
    800038aa:	fef059e3          	blez	a5,8000389c <iget+0x38>
    800038ae:	4098                	lw	a4,0(s1)
    800038b0:	ff3716e3          	bne	a4,s3,8000389c <iget+0x38>
    800038b4:	40d8                	lw	a4,4(s1)
    800038b6:	ff4713e3          	bne	a4,s4,8000389c <iget+0x38>
      ip->ref++;
    800038ba:	2785                	addiw	a5,a5,1
    800038bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038be:	0001f517          	auipc	a0,0x1f
    800038c2:	c4a50513          	addi	a0,a0,-950 # 80022508 <itable>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	3c4080e7          	jalr	964(ra) # 80000c8a <release>
      return ip;
    800038ce:	8926                	mv	s2,s1
    800038d0:	a03d                	j	800038fe <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038d2:	f7f9                	bnez	a5,800038a0 <iget+0x3c>
    800038d4:	8926                	mv	s2,s1
    800038d6:	b7e9                	j	800038a0 <iget+0x3c>
  if(empty == 0)
    800038d8:	02090c63          	beqz	s2,80003910 <iget+0xac>
  ip->dev = dev;
    800038dc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038e0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038e4:	4785                	li	a5,1
    800038e6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038ea:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038ee:	0001f517          	auipc	a0,0x1f
    800038f2:	c1a50513          	addi	a0,a0,-998 # 80022508 <itable>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	394080e7          	jalr	916(ra) # 80000c8a <release>
}
    800038fe:	854a                	mv	a0,s2
    80003900:	70a2                	ld	ra,40(sp)
    80003902:	7402                	ld	s0,32(sp)
    80003904:	64e2                	ld	s1,24(sp)
    80003906:	6942                	ld	s2,16(sp)
    80003908:	69a2                	ld	s3,8(sp)
    8000390a:	6a02                	ld	s4,0(sp)
    8000390c:	6145                	addi	sp,sp,48
    8000390e:	8082                	ret
    panic("iget: no inodes");
    80003910:	00005517          	auipc	a0,0x5
    80003914:	ca050513          	addi	a0,a0,-864 # 800085b0 <syscalls+0x158>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	c26080e7          	jalr	-986(ra) # 8000053e <panic>

0000000080003920 <fsinit>:
fsinit(int dev) {
    80003920:	7179                	addi	sp,sp,-48
    80003922:	f406                	sd	ra,40(sp)
    80003924:	f022                	sd	s0,32(sp)
    80003926:	ec26                	sd	s1,24(sp)
    80003928:	e84a                	sd	s2,16(sp)
    8000392a:	e44e                	sd	s3,8(sp)
    8000392c:	1800                	addi	s0,sp,48
    8000392e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003930:	4585                	li	a1,1
    80003932:	00000097          	auipc	ra,0x0
    80003936:	a50080e7          	jalr	-1456(ra) # 80003382 <bread>
    8000393a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000393c:	0001f997          	auipc	s3,0x1f
    80003940:	bac98993          	addi	s3,s3,-1108 # 800224e8 <sb>
    80003944:	02000613          	li	a2,32
    80003948:	05850593          	addi	a1,a0,88
    8000394c:	854e                	mv	a0,s3
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	3e0080e7          	jalr	992(ra) # 80000d2e <memmove>
  brelse(bp);
    80003956:	8526                	mv	a0,s1
    80003958:	00000097          	auipc	ra,0x0
    8000395c:	b5a080e7          	jalr	-1190(ra) # 800034b2 <brelse>
  if(sb.magic != FSMAGIC)
    80003960:	0009a703          	lw	a4,0(s3)
    80003964:	102037b7          	lui	a5,0x10203
    80003968:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000396c:	02f71263          	bne	a4,a5,80003990 <fsinit+0x70>
  initlog(dev, &sb);
    80003970:	0001f597          	auipc	a1,0x1f
    80003974:	b7858593          	addi	a1,a1,-1160 # 800224e8 <sb>
    80003978:	854a                	mv	a0,s2
    8000397a:	00001097          	auipc	ra,0x1
    8000397e:	b40080e7          	jalr	-1216(ra) # 800044ba <initlog>
}
    80003982:	70a2                	ld	ra,40(sp)
    80003984:	7402                	ld	s0,32(sp)
    80003986:	64e2                	ld	s1,24(sp)
    80003988:	6942                	ld	s2,16(sp)
    8000398a:	69a2                	ld	s3,8(sp)
    8000398c:	6145                	addi	sp,sp,48
    8000398e:	8082                	ret
    panic("invalid file system");
    80003990:	00005517          	auipc	a0,0x5
    80003994:	c3050513          	addi	a0,a0,-976 # 800085c0 <syscalls+0x168>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	ba6080e7          	jalr	-1114(ra) # 8000053e <panic>

00000000800039a0 <iinit>:
{
    800039a0:	7179                	addi	sp,sp,-48
    800039a2:	f406                	sd	ra,40(sp)
    800039a4:	f022                	sd	s0,32(sp)
    800039a6:	ec26                	sd	s1,24(sp)
    800039a8:	e84a                	sd	s2,16(sp)
    800039aa:	e44e                	sd	s3,8(sp)
    800039ac:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039ae:	00005597          	auipc	a1,0x5
    800039b2:	c2a58593          	addi	a1,a1,-982 # 800085d8 <syscalls+0x180>
    800039b6:	0001f517          	auipc	a0,0x1f
    800039ba:	b5250513          	addi	a0,a0,-1198 # 80022508 <itable>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	188080e7          	jalr	392(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800039c6:	0001f497          	auipc	s1,0x1f
    800039ca:	b6a48493          	addi	s1,s1,-1174 # 80022530 <itable+0x28>
    800039ce:	00020997          	auipc	s3,0x20
    800039d2:	5f298993          	addi	s3,s3,1522 # 80023fc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039d6:	00005917          	auipc	s2,0x5
    800039da:	c0a90913          	addi	s2,s2,-1014 # 800085e0 <syscalls+0x188>
    800039de:	85ca                	mv	a1,s2
    800039e0:	8526                	mv	a0,s1
    800039e2:	00001097          	auipc	ra,0x1
    800039e6:	e3a080e7          	jalr	-454(ra) # 8000481c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039ea:	08848493          	addi	s1,s1,136
    800039ee:	ff3498e3          	bne	s1,s3,800039de <iinit+0x3e>
}
    800039f2:	70a2                	ld	ra,40(sp)
    800039f4:	7402                	ld	s0,32(sp)
    800039f6:	64e2                	ld	s1,24(sp)
    800039f8:	6942                	ld	s2,16(sp)
    800039fa:	69a2                	ld	s3,8(sp)
    800039fc:	6145                	addi	sp,sp,48
    800039fe:	8082                	ret

0000000080003a00 <ialloc>:
{
    80003a00:	715d                	addi	sp,sp,-80
    80003a02:	e486                	sd	ra,72(sp)
    80003a04:	e0a2                	sd	s0,64(sp)
    80003a06:	fc26                	sd	s1,56(sp)
    80003a08:	f84a                	sd	s2,48(sp)
    80003a0a:	f44e                	sd	s3,40(sp)
    80003a0c:	f052                	sd	s4,32(sp)
    80003a0e:	ec56                	sd	s5,24(sp)
    80003a10:	e85a                	sd	s6,16(sp)
    80003a12:	e45e                	sd	s7,8(sp)
    80003a14:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a16:	0001f717          	auipc	a4,0x1f
    80003a1a:	ade72703          	lw	a4,-1314(a4) # 800224f4 <sb+0xc>
    80003a1e:	4785                	li	a5,1
    80003a20:	04e7fa63          	bgeu	a5,a4,80003a74 <ialloc+0x74>
    80003a24:	8aaa                	mv	s5,a0
    80003a26:	8bae                	mv	s7,a1
    80003a28:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a2a:	0001fa17          	auipc	s4,0x1f
    80003a2e:	abea0a13          	addi	s4,s4,-1346 # 800224e8 <sb>
    80003a32:	00048b1b          	sext.w	s6,s1
    80003a36:	0044d793          	srli	a5,s1,0x4
    80003a3a:	018a2583          	lw	a1,24(s4)
    80003a3e:	9dbd                	addw	a1,a1,a5
    80003a40:	8556                	mv	a0,s5
    80003a42:	00000097          	auipc	ra,0x0
    80003a46:	940080e7          	jalr	-1728(ra) # 80003382 <bread>
    80003a4a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a4c:	05850993          	addi	s3,a0,88
    80003a50:	00f4f793          	andi	a5,s1,15
    80003a54:	079a                	slli	a5,a5,0x6
    80003a56:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a58:	00099783          	lh	a5,0(s3)
    80003a5c:	c3a1                	beqz	a5,80003a9c <ialloc+0x9c>
    brelse(bp);
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	a54080e7          	jalr	-1452(ra) # 800034b2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a66:	0485                	addi	s1,s1,1
    80003a68:	00ca2703          	lw	a4,12(s4)
    80003a6c:	0004879b          	sext.w	a5,s1
    80003a70:	fce7e1e3          	bltu	a5,a4,80003a32 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a74:	00005517          	auipc	a0,0x5
    80003a78:	b7450513          	addi	a0,a0,-1164 # 800085e8 <syscalls+0x190>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	b0c080e7          	jalr	-1268(ra) # 80000588 <printf>
  return 0;
    80003a84:	4501                	li	a0,0
}
    80003a86:	60a6                	ld	ra,72(sp)
    80003a88:	6406                	ld	s0,64(sp)
    80003a8a:	74e2                	ld	s1,56(sp)
    80003a8c:	7942                	ld	s2,48(sp)
    80003a8e:	79a2                	ld	s3,40(sp)
    80003a90:	7a02                	ld	s4,32(sp)
    80003a92:	6ae2                	ld	s5,24(sp)
    80003a94:	6b42                	ld	s6,16(sp)
    80003a96:	6ba2                	ld	s7,8(sp)
    80003a98:	6161                	addi	sp,sp,80
    80003a9a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a9c:	04000613          	li	a2,64
    80003aa0:	4581                	li	a1,0
    80003aa2:	854e                	mv	a0,s3
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	22e080e7          	jalr	558(ra) # 80000cd2 <memset>
      dip->type = type;
    80003aac:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ab0:	854a                	mv	a0,s2
    80003ab2:	00001097          	auipc	ra,0x1
    80003ab6:	c84080e7          	jalr	-892(ra) # 80004736 <log_write>
      brelse(bp);
    80003aba:	854a                	mv	a0,s2
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	9f6080e7          	jalr	-1546(ra) # 800034b2 <brelse>
      return iget(dev, inum);
    80003ac4:	85da                	mv	a1,s6
    80003ac6:	8556                	mv	a0,s5
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	d9c080e7          	jalr	-612(ra) # 80003864 <iget>
    80003ad0:	bf5d                	j	80003a86 <ialloc+0x86>

0000000080003ad2 <iupdate>:
{
    80003ad2:	1101                	addi	sp,sp,-32
    80003ad4:	ec06                	sd	ra,24(sp)
    80003ad6:	e822                	sd	s0,16(sp)
    80003ad8:	e426                	sd	s1,8(sp)
    80003ada:	e04a                	sd	s2,0(sp)
    80003adc:	1000                	addi	s0,sp,32
    80003ade:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ae0:	415c                	lw	a5,4(a0)
    80003ae2:	0047d79b          	srliw	a5,a5,0x4
    80003ae6:	0001f597          	auipc	a1,0x1f
    80003aea:	a1a5a583          	lw	a1,-1510(a1) # 80022500 <sb+0x18>
    80003aee:	9dbd                	addw	a1,a1,a5
    80003af0:	4108                	lw	a0,0(a0)
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	890080e7          	jalr	-1904(ra) # 80003382 <bread>
    80003afa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003afc:	05850793          	addi	a5,a0,88
    80003b00:	40c8                	lw	a0,4(s1)
    80003b02:	893d                	andi	a0,a0,15
    80003b04:	051a                	slli	a0,a0,0x6
    80003b06:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b08:	04449703          	lh	a4,68(s1)
    80003b0c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b10:	04649703          	lh	a4,70(s1)
    80003b14:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b18:	04849703          	lh	a4,72(s1)
    80003b1c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b20:	04a49703          	lh	a4,74(s1)
    80003b24:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b28:	44f8                	lw	a4,76(s1)
    80003b2a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b2c:	03400613          	li	a2,52
    80003b30:	05048593          	addi	a1,s1,80
    80003b34:	0531                	addi	a0,a0,12
    80003b36:	ffffd097          	auipc	ra,0xffffd
    80003b3a:	1f8080e7          	jalr	504(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b3e:	854a                	mv	a0,s2
    80003b40:	00001097          	auipc	ra,0x1
    80003b44:	bf6080e7          	jalr	-1034(ra) # 80004736 <log_write>
  brelse(bp);
    80003b48:	854a                	mv	a0,s2
    80003b4a:	00000097          	auipc	ra,0x0
    80003b4e:	968080e7          	jalr	-1688(ra) # 800034b2 <brelse>
}
    80003b52:	60e2                	ld	ra,24(sp)
    80003b54:	6442                	ld	s0,16(sp)
    80003b56:	64a2                	ld	s1,8(sp)
    80003b58:	6902                	ld	s2,0(sp)
    80003b5a:	6105                	addi	sp,sp,32
    80003b5c:	8082                	ret

0000000080003b5e <idup>:
{
    80003b5e:	1101                	addi	sp,sp,-32
    80003b60:	ec06                	sd	ra,24(sp)
    80003b62:	e822                	sd	s0,16(sp)
    80003b64:	e426                	sd	s1,8(sp)
    80003b66:	1000                	addi	s0,sp,32
    80003b68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b6a:	0001f517          	auipc	a0,0x1f
    80003b6e:	99e50513          	addi	a0,a0,-1634 # 80022508 <itable>
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	064080e7          	jalr	100(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003b7a:	449c                	lw	a5,8(s1)
    80003b7c:	2785                	addiw	a5,a5,1
    80003b7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b80:	0001f517          	auipc	a0,0x1f
    80003b84:	98850513          	addi	a0,a0,-1656 # 80022508 <itable>
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	102080e7          	jalr	258(ra) # 80000c8a <release>
}
    80003b90:	8526                	mv	a0,s1
    80003b92:	60e2                	ld	ra,24(sp)
    80003b94:	6442                	ld	s0,16(sp)
    80003b96:	64a2                	ld	s1,8(sp)
    80003b98:	6105                	addi	sp,sp,32
    80003b9a:	8082                	ret

0000000080003b9c <ilock>:
{
    80003b9c:	1101                	addi	sp,sp,-32
    80003b9e:	ec06                	sd	ra,24(sp)
    80003ba0:	e822                	sd	s0,16(sp)
    80003ba2:	e426                	sd	s1,8(sp)
    80003ba4:	e04a                	sd	s2,0(sp)
    80003ba6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ba8:	c115                	beqz	a0,80003bcc <ilock+0x30>
    80003baa:	84aa                	mv	s1,a0
    80003bac:	451c                	lw	a5,8(a0)
    80003bae:	00f05f63          	blez	a5,80003bcc <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bb2:	0541                	addi	a0,a0,16
    80003bb4:	00001097          	auipc	ra,0x1
    80003bb8:	ca2080e7          	jalr	-862(ra) # 80004856 <acquiresleep>
  if(ip->valid == 0){
    80003bbc:	40bc                	lw	a5,64(s1)
    80003bbe:	cf99                	beqz	a5,80003bdc <ilock+0x40>
}
    80003bc0:	60e2                	ld	ra,24(sp)
    80003bc2:	6442                	ld	s0,16(sp)
    80003bc4:	64a2                	ld	s1,8(sp)
    80003bc6:	6902                	ld	s2,0(sp)
    80003bc8:	6105                	addi	sp,sp,32
    80003bca:	8082                	ret
    panic("ilock");
    80003bcc:	00005517          	auipc	a0,0x5
    80003bd0:	a3450513          	addi	a0,a0,-1484 # 80008600 <syscalls+0x1a8>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	96a080e7          	jalr	-1686(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bdc:	40dc                	lw	a5,4(s1)
    80003bde:	0047d79b          	srliw	a5,a5,0x4
    80003be2:	0001f597          	auipc	a1,0x1f
    80003be6:	91e5a583          	lw	a1,-1762(a1) # 80022500 <sb+0x18>
    80003bea:	9dbd                	addw	a1,a1,a5
    80003bec:	4088                	lw	a0,0(s1)
    80003bee:	fffff097          	auipc	ra,0xfffff
    80003bf2:	794080e7          	jalr	1940(ra) # 80003382 <bread>
    80003bf6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bf8:	05850593          	addi	a1,a0,88
    80003bfc:	40dc                	lw	a5,4(s1)
    80003bfe:	8bbd                	andi	a5,a5,15
    80003c00:	079a                	slli	a5,a5,0x6
    80003c02:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c04:	00059783          	lh	a5,0(a1)
    80003c08:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c0c:	00259783          	lh	a5,2(a1)
    80003c10:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c14:	00459783          	lh	a5,4(a1)
    80003c18:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c1c:	00659783          	lh	a5,6(a1)
    80003c20:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c24:	459c                	lw	a5,8(a1)
    80003c26:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c28:	03400613          	li	a2,52
    80003c2c:	05b1                	addi	a1,a1,12
    80003c2e:	05048513          	addi	a0,s1,80
    80003c32:	ffffd097          	auipc	ra,0xffffd
    80003c36:	0fc080e7          	jalr	252(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	876080e7          	jalr	-1930(ra) # 800034b2 <brelse>
    ip->valid = 1;
    80003c44:	4785                	li	a5,1
    80003c46:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c48:	04449783          	lh	a5,68(s1)
    80003c4c:	fbb5                	bnez	a5,80003bc0 <ilock+0x24>
      panic("ilock: no type");
    80003c4e:	00005517          	auipc	a0,0x5
    80003c52:	9ba50513          	addi	a0,a0,-1606 # 80008608 <syscalls+0x1b0>
    80003c56:	ffffd097          	auipc	ra,0xffffd
    80003c5a:	8e8080e7          	jalr	-1816(ra) # 8000053e <panic>

0000000080003c5e <iunlock>:
{
    80003c5e:	1101                	addi	sp,sp,-32
    80003c60:	ec06                	sd	ra,24(sp)
    80003c62:	e822                	sd	s0,16(sp)
    80003c64:	e426                	sd	s1,8(sp)
    80003c66:	e04a                	sd	s2,0(sp)
    80003c68:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c6a:	c905                	beqz	a0,80003c9a <iunlock+0x3c>
    80003c6c:	84aa                	mv	s1,a0
    80003c6e:	01050913          	addi	s2,a0,16
    80003c72:	854a                	mv	a0,s2
    80003c74:	00001097          	auipc	ra,0x1
    80003c78:	c7c080e7          	jalr	-900(ra) # 800048f0 <holdingsleep>
    80003c7c:	cd19                	beqz	a0,80003c9a <iunlock+0x3c>
    80003c7e:	449c                	lw	a5,8(s1)
    80003c80:	00f05d63          	blez	a5,80003c9a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c84:	854a                	mv	a0,s2
    80003c86:	00001097          	auipc	ra,0x1
    80003c8a:	c26080e7          	jalr	-986(ra) # 800048ac <releasesleep>
}
    80003c8e:	60e2                	ld	ra,24(sp)
    80003c90:	6442                	ld	s0,16(sp)
    80003c92:	64a2                	ld	s1,8(sp)
    80003c94:	6902                	ld	s2,0(sp)
    80003c96:	6105                	addi	sp,sp,32
    80003c98:	8082                	ret
    panic("iunlock");
    80003c9a:	00005517          	auipc	a0,0x5
    80003c9e:	97e50513          	addi	a0,a0,-1666 # 80008618 <syscalls+0x1c0>
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	89c080e7          	jalr	-1892(ra) # 8000053e <panic>

0000000080003caa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003caa:	7179                	addi	sp,sp,-48
    80003cac:	f406                	sd	ra,40(sp)
    80003cae:	f022                	sd	s0,32(sp)
    80003cb0:	ec26                	sd	s1,24(sp)
    80003cb2:	e84a                	sd	s2,16(sp)
    80003cb4:	e44e                	sd	s3,8(sp)
    80003cb6:	e052                	sd	s4,0(sp)
    80003cb8:	1800                	addi	s0,sp,48
    80003cba:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cbc:	05050493          	addi	s1,a0,80
    80003cc0:	08050913          	addi	s2,a0,128
    80003cc4:	a021                	j	80003ccc <itrunc+0x22>
    80003cc6:	0491                	addi	s1,s1,4
    80003cc8:	01248d63          	beq	s1,s2,80003ce2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003ccc:	408c                	lw	a1,0(s1)
    80003cce:	dde5                	beqz	a1,80003cc6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cd0:	0009a503          	lw	a0,0(s3)
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	8f4080e7          	jalr	-1804(ra) # 800035c8 <bfree>
      ip->addrs[i] = 0;
    80003cdc:	0004a023          	sw	zero,0(s1)
    80003ce0:	b7dd                	j	80003cc6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ce2:	0809a583          	lw	a1,128(s3)
    80003ce6:	e185                	bnez	a1,80003d06 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ce8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cec:	854e                	mv	a0,s3
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	de4080e7          	jalr	-540(ra) # 80003ad2 <iupdate>
}
    80003cf6:	70a2                	ld	ra,40(sp)
    80003cf8:	7402                	ld	s0,32(sp)
    80003cfa:	64e2                	ld	s1,24(sp)
    80003cfc:	6942                	ld	s2,16(sp)
    80003cfe:	69a2                	ld	s3,8(sp)
    80003d00:	6a02                	ld	s4,0(sp)
    80003d02:	6145                	addi	sp,sp,48
    80003d04:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d06:	0009a503          	lw	a0,0(s3)
    80003d0a:	fffff097          	auipc	ra,0xfffff
    80003d0e:	678080e7          	jalr	1656(ra) # 80003382 <bread>
    80003d12:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d14:	05850493          	addi	s1,a0,88
    80003d18:	45850913          	addi	s2,a0,1112
    80003d1c:	a021                	j	80003d24 <itrunc+0x7a>
    80003d1e:	0491                	addi	s1,s1,4
    80003d20:	01248b63          	beq	s1,s2,80003d36 <itrunc+0x8c>
      if(a[j])
    80003d24:	408c                	lw	a1,0(s1)
    80003d26:	dde5                	beqz	a1,80003d1e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d28:	0009a503          	lw	a0,0(s3)
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	89c080e7          	jalr	-1892(ra) # 800035c8 <bfree>
    80003d34:	b7ed                	j	80003d1e <itrunc+0x74>
    brelse(bp);
    80003d36:	8552                	mv	a0,s4
    80003d38:	fffff097          	auipc	ra,0xfffff
    80003d3c:	77a080e7          	jalr	1914(ra) # 800034b2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d40:	0809a583          	lw	a1,128(s3)
    80003d44:	0009a503          	lw	a0,0(s3)
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	880080e7          	jalr	-1920(ra) # 800035c8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d50:	0809a023          	sw	zero,128(s3)
    80003d54:	bf51                	j	80003ce8 <itrunc+0x3e>

0000000080003d56 <iput>:
{
    80003d56:	1101                	addi	sp,sp,-32
    80003d58:	ec06                	sd	ra,24(sp)
    80003d5a:	e822                	sd	s0,16(sp)
    80003d5c:	e426                	sd	s1,8(sp)
    80003d5e:	e04a                	sd	s2,0(sp)
    80003d60:	1000                	addi	s0,sp,32
    80003d62:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d64:	0001e517          	auipc	a0,0x1e
    80003d68:	7a450513          	addi	a0,a0,1956 # 80022508 <itable>
    80003d6c:	ffffd097          	auipc	ra,0xffffd
    80003d70:	e6a080e7          	jalr	-406(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d74:	4498                	lw	a4,8(s1)
    80003d76:	4785                	li	a5,1
    80003d78:	02f70363          	beq	a4,a5,80003d9e <iput+0x48>
  ip->ref--;
    80003d7c:	449c                	lw	a5,8(s1)
    80003d7e:	37fd                	addiw	a5,a5,-1
    80003d80:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d82:	0001e517          	auipc	a0,0x1e
    80003d86:	78650513          	addi	a0,a0,1926 # 80022508 <itable>
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	f00080e7          	jalr	-256(ra) # 80000c8a <release>
}
    80003d92:	60e2                	ld	ra,24(sp)
    80003d94:	6442                	ld	s0,16(sp)
    80003d96:	64a2                	ld	s1,8(sp)
    80003d98:	6902                	ld	s2,0(sp)
    80003d9a:	6105                	addi	sp,sp,32
    80003d9c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d9e:	40bc                	lw	a5,64(s1)
    80003da0:	dff1                	beqz	a5,80003d7c <iput+0x26>
    80003da2:	04a49783          	lh	a5,74(s1)
    80003da6:	fbf9                	bnez	a5,80003d7c <iput+0x26>
    acquiresleep(&ip->lock);
    80003da8:	01048913          	addi	s2,s1,16
    80003dac:	854a                	mv	a0,s2
    80003dae:	00001097          	auipc	ra,0x1
    80003db2:	aa8080e7          	jalr	-1368(ra) # 80004856 <acquiresleep>
    release(&itable.lock);
    80003db6:	0001e517          	auipc	a0,0x1e
    80003dba:	75250513          	addi	a0,a0,1874 # 80022508 <itable>
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	ecc080e7          	jalr	-308(ra) # 80000c8a <release>
    itrunc(ip);
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	ee2080e7          	jalr	-286(ra) # 80003caa <itrunc>
    ip->type = 0;
    80003dd0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dd4:	8526                	mv	a0,s1
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	cfc080e7          	jalr	-772(ra) # 80003ad2 <iupdate>
    ip->valid = 0;
    80003dde:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003de2:	854a                	mv	a0,s2
    80003de4:	00001097          	auipc	ra,0x1
    80003de8:	ac8080e7          	jalr	-1336(ra) # 800048ac <releasesleep>
    acquire(&itable.lock);
    80003dec:	0001e517          	auipc	a0,0x1e
    80003df0:	71c50513          	addi	a0,a0,1820 # 80022508 <itable>
    80003df4:	ffffd097          	auipc	ra,0xffffd
    80003df8:	de2080e7          	jalr	-542(ra) # 80000bd6 <acquire>
    80003dfc:	b741                	j	80003d7c <iput+0x26>

0000000080003dfe <iunlockput>:
{
    80003dfe:	1101                	addi	sp,sp,-32
    80003e00:	ec06                	sd	ra,24(sp)
    80003e02:	e822                	sd	s0,16(sp)
    80003e04:	e426                	sd	s1,8(sp)
    80003e06:	1000                	addi	s0,sp,32
    80003e08:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	e54080e7          	jalr	-428(ra) # 80003c5e <iunlock>
  iput(ip);
    80003e12:	8526                	mv	a0,s1
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	f42080e7          	jalr	-190(ra) # 80003d56 <iput>
}
    80003e1c:	60e2                	ld	ra,24(sp)
    80003e1e:	6442                	ld	s0,16(sp)
    80003e20:	64a2                	ld	s1,8(sp)
    80003e22:	6105                	addi	sp,sp,32
    80003e24:	8082                	ret

0000000080003e26 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e26:	1141                	addi	sp,sp,-16
    80003e28:	e422                	sd	s0,8(sp)
    80003e2a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e2c:	411c                	lw	a5,0(a0)
    80003e2e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e30:	415c                	lw	a5,4(a0)
    80003e32:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e34:	04451783          	lh	a5,68(a0)
    80003e38:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e3c:	04a51783          	lh	a5,74(a0)
    80003e40:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e44:	04c56783          	lwu	a5,76(a0)
    80003e48:	e99c                	sd	a5,16(a1)
}
    80003e4a:	6422                	ld	s0,8(sp)
    80003e4c:	0141                	addi	sp,sp,16
    80003e4e:	8082                	ret

0000000080003e50 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e50:	457c                	lw	a5,76(a0)
    80003e52:	0ed7e963          	bltu	a5,a3,80003f44 <readi+0xf4>
{
    80003e56:	7159                	addi	sp,sp,-112
    80003e58:	f486                	sd	ra,104(sp)
    80003e5a:	f0a2                	sd	s0,96(sp)
    80003e5c:	eca6                	sd	s1,88(sp)
    80003e5e:	e8ca                	sd	s2,80(sp)
    80003e60:	e4ce                	sd	s3,72(sp)
    80003e62:	e0d2                	sd	s4,64(sp)
    80003e64:	fc56                	sd	s5,56(sp)
    80003e66:	f85a                	sd	s6,48(sp)
    80003e68:	f45e                	sd	s7,40(sp)
    80003e6a:	f062                	sd	s8,32(sp)
    80003e6c:	ec66                	sd	s9,24(sp)
    80003e6e:	e86a                	sd	s10,16(sp)
    80003e70:	e46e                	sd	s11,8(sp)
    80003e72:	1880                	addi	s0,sp,112
    80003e74:	8b2a                	mv	s6,a0
    80003e76:	8bae                	mv	s7,a1
    80003e78:	8a32                	mv	s4,a2
    80003e7a:	84b6                	mv	s1,a3
    80003e7c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e7e:	9f35                	addw	a4,a4,a3
    return 0;
    80003e80:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e82:	0ad76063          	bltu	a4,a3,80003f22 <readi+0xd2>
  if(off + n > ip->size)
    80003e86:	00e7f463          	bgeu	a5,a4,80003e8e <readi+0x3e>
    n = ip->size - off;
    80003e8a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e8e:	0a0a8963          	beqz	s5,80003f40 <readi+0xf0>
    80003e92:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e94:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e98:	5c7d                	li	s8,-1
    80003e9a:	a82d                	j	80003ed4 <readi+0x84>
    80003e9c:	020d1d93          	slli	s11,s10,0x20
    80003ea0:	020ddd93          	srli	s11,s11,0x20
    80003ea4:	05890793          	addi	a5,s2,88
    80003ea8:	86ee                	mv	a3,s11
    80003eaa:	963e                	add	a2,a2,a5
    80003eac:	85d2                	mv	a1,s4
    80003eae:	855e                	mv	a0,s7
    80003eb0:	ffffe097          	auipc	ra,0xffffe
    80003eb4:	72e080e7          	jalr	1838(ra) # 800025de <either_copyout>
    80003eb8:	05850d63          	beq	a0,s8,80003f12 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	5f4080e7          	jalr	1524(ra) # 800034b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ec6:	013d09bb          	addw	s3,s10,s3
    80003eca:	009d04bb          	addw	s1,s10,s1
    80003ece:	9a6e                	add	s4,s4,s11
    80003ed0:	0559f763          	bgeu	s3,s5,80003f1e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ed4:	00a4d59b          	srliw	a1,s1,0xa
    80003ed8:	855a                	mv	a0,s6
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	8a2080e7          	jalr	-1886(ra) # 8000377c <bmap>
    80003ee2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ee6:	cd85                	beqz	a1,80003f1e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ee8:	000b2503          	lw	a0,0(s6)
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	496080e7          	jalr	1174(ra) # 80003382 <bread>
    80003ef4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ef6:	3ff4f613          	andi	a2,s1,1023
    80003efa:	40cc87bb          	subw	a5,s9,a2
    80003efe:	413a873b          	subw	a4,s5,s3
    80003f02:	8d3e                	mv	s10,a5
    80003f04:	2781                	sext.w	a5,a5
    80003f06:	0007069b          	sext.w	a3,a4
    80003f0a:	f8f6f9e3          	bgeu	a3,a5,80003e9c <readi+0x4c>
    80003f0e:	8d3a                	mv	s10,a4
    80003f10:	b771                	j	80003e9c <readi+0x4c>
      brelse(bp);
    80003f12:	854a                	mv	a0,s2
    80003f14:	fffff097          	auipc	ra,0xfffff
    80003f18:	59e080e7          	jalr	1438(ra) # 800034b2 <brelse>
      tot = -1;
    80003f1c:	59fd                	li	s3,-1
  }
  return tot;
    80003f1e:	0009851b          	sext.w	a0,s3
}
    80003f22:	70a6                	ld	ra,104(sp)
    80003f24:	7406                	ld	s0,96(sp)
    80003f26:	64e6                	ld	s1,88(sp)
    80003f28:	6946                	ld	s2,80(sp)
    80003f2a:	69a6                	ld	s3,72(sp)
    80003f2c:	6a06                	ld	s4,64(sp)
    80003f2e:	7ae2                	ld	s5,56(sp)
    80003f30:	7b42                	ld	s6,48(sp)
    80003f32:	7ba2                	ld	s7,40(sp)
    80003f34:	7c02                	ld	s8,32(sp)
    80003f36:	6ce2                	ld	s9,24(sp)
    80003f38:	6d42                	ld	s10,16(sp)
    80003f3a:	6da2                	ld	s11,8(sp)
    80003f3c:	6165                	addi	sp,sp,112
    80003f3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f40:	89d6                	mv	s3,s5
    80003f42:	bff1                	j	80003f1e <readi+0xce>
    return 0;
    80003f44:	4501                	li	a0,0
}
    80003f46:	8082                	ret

0000000080003f48 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f48:	457c                	lw	a5,76(a0)
    80003f4a:	10d7e863          	bltu	a5,a3,8000405a <writei+0x112>
{
    80003f4e:	7159                	addi	sp,sp,-112
    80003f50:	f486                	sd	ra,104(sp)
    80003f52:	f0a2                	sd	s0,96(sp)
    80003f54:	eca6                	sd	s1,88(sp)
    80003f56:	e8ca                	sd	s2,80(sp)
    80003f58:	e4ce                	sd	s3,72(sp)
    80003f5a:	e0d2                	sd	s4,64(sp)
    80003f5c:	fc56                	sd	s5,56(sp)
    80003f5e:	f85a                	sd	s6,48(sp)
    80003f60:	f45e                	sd	s7,40(sp)
    80003f62:	f062                	sd	s8,32(sp)
    80003f64:	ec66                	sd	s9,24(sp)
    80003f66:	e86a                	sd	s10,16(sp)
    80003f68:	e46e                	sd	s11,8(sp)
    80003f6a:	1880                	addi	s0,sp,112
    80003f6c:	8aaa                	mv	s5,a0
    80003f6e:	8bae                	mv	s7,a1
    80003f70:	8a32                	mv	s4,a2
    80003f72:	8936                	mv	s2,a3
    80003f74:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f76:	00e687bb          	addw	a5,a3,a4
    80003f7a:	0ed7e263          	bltu	a5,a3,8000405e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f7e:	00043737          	lui	a4,0x43
    80003f82:	0ef76063          	bltu	a4,a5,80004062 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f86:	0c0b0863          	beqz	s6,80004056 <writei+0x10e>
    80003f8a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f8c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f90:	5c7d                	li	s8,-1
    80003f92:	a091                	j	80003fd6 <writei+0x8e>
    80003f94:	020d1d93          	slli	s11,s10,0x20
    80003f98:	020ddd93          	srli	s11,s11,0x20
    80003f9c:	05848793          	addi	a5,s1,88
    80003fa0:	86ee                	mv	a3,s11
    80003fa2:	8652                	mv	a2,s4
    80003fa4:	85de                	mv	a1,s7
    80003fa6:	953e                	add	a0,a0,a5
    80003fa8:	ffffe097          	auipc	ra,0xffffe
    80003fac:	68c080e7          	jalr	1676(ra) # 80002634 <either_copyin>
    80003fb0:	07850263          	beq	a0,s8,80004014 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	780080e7          	jalr	1920(ra) # 80004736 <log_write>
    brelse(bp);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	fffff097          	auipc	ra,0xfffff
    80003fc4:	4f2080e7          	jalr	1266(ra) # 800034b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fc8:	013d09bb          	addw	s3,s10,s3
    80003fcc:	012d093b          	addw	s2,s10,s2
    80003fd0:	9a6e                	add	s4,s4,s11
    80003fd2:	0569f663          	bgeu	s3,s6,8000401e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fd6:	00a9559b          	srliw	a1,s2,0xa
    80003fda:	8556                	mv	a0,s5
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	7a0080e7          	jalr	1952(ra) # 8000377c <bmap>
    80003fe4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fe8:	c99d                	beqz	a1,8000401e <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fea:	000aa503          	lw	a0,0(s5)
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	394080e7          	jalr	916(ra) # 80003382 <bread>
    80003ff6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ff8:	3ff97513          	andi	a0,s2,1023
    80003ffc:	40ac87bb          	subw	a5,s9,a0
    80004000:	413b073b          	subw	a4,s6,s3
    80004004:	8d3e                	mv	s10,a5
    80004006:	2781                	sext.w	a5,a5
    80004008:	0007069b          	sext.w	a3,a4
    8000400c:	f8f6f4e3          	bgeu	a3,a5,80003f94 <writei+0x4c>
    80004010:	8d3a                	mv	s10,a4
    80004012:	b749                	j	80003f94 <writei+0x4c>
      brelse(bp);
    80004014:	8526                	mv	a0,s1
    80004016:	fffff097          	auipc	ra,0xfffff
    8000401a:	49c080e7          	jalr	1180(ra) # 800034b2 <brelse>
  }

  if(off > ip->size)
    8000401e:	04caa783          	lw	a5,76(s5)
    80004022:	0127f463          	bgeu	a5,s2,8000402a <writei+0xe2>
    ip->size = off;
    80004026:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000402a:	8556                	mv	a0,s5
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	aa6080e7          	jalr	-1370(ra) # 80003ad2 <iupdate>

  return tot;
    80004034:	0009851b          	sext.w	a0,s3
}
    80004038:	70a6                	ld	ra,104(sp)
    8000403a:	7406                	ld	s0,96(sp)
    8000403c:	64e6                	ld	s1,88(sp)
    8000403e:	6946                	ld	s2,80(sp)
    80004040:	69a6                	ld	s3,72(sp)
    80004042:	6a06                	ld	s4,64(sp)
    80004044:	7ae2                	ld	s5,56(sp)
    80004046:	7b42                	ld	s6,48(sp)
    80004048:	7ba2                	ld	s7,40(sp)
    8000404a:	7c02                	ld	s8,32(sp)
    8000404c:	6ce2                	ld	s9,24(sp)
    8000404e:	6d42                	ld	s10,16(sp)
    80004050:	6da2                	ld	s11,8(sp)
    80004052:	6165                	addi	sp,sp,112
    80004054:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004056:	89da                	mv	s3,s6
    80004058:	bfc9                	j	8000402a <writei+0xe2>
    return -1;
    8000405a:	557d                	li	a0,-1
}
    8000405c:	8082                	ret
    return -1;
    8000405e:	557d                	li	a0,-1
    80004060:	bfe1                	j	80004038 <writei+0xf0>
    return -1;
    80004062:	557d                	li	a0,-1
    80004064:	bfd1                	j	80004038 <writei+0xf0>

0000000080004066 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004066:	1141                	addi	sp,sp,-16
    80004068:	e406                	sd	ra,8(sp)
    8000406a:	e022                	sd	s0,0(sp)
    8000406c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000406e:	4639                	li	a2,14
    80004070:	ffffd097          	auipc	ra,0xffffd
    80004074:	d32080e7          	jalr	-718(ra) # 80000da2 <strncmp>
}
    80004078:	60a2                	ld	ra,8(sp)
    8000407a:	6402                	ld	s0,0(sp)
    8000407c:	0141                	addi	sp,sp,16
    8000407e:	8082                	ret

0000000080004080 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004080:	7139                	addi	sp,sp,-64
    80004082:	fc06                	sd	ra,56(sp)
    80004084:	f822                	sd	s0,48(sp)
    80004086:	f426                	sd	s1,40(sp)
    80004088:	f04a                	sd	s2,32(sp)
    8000408a:	ec4e                	sd	s3,24(sp)
    8000408c:	e852                	sd	s4,16(sp)
    8000408e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004090:	04451703          	lh	a4,68(a0)
    80004094:	4785                	li	a5,1
    80004096:	00f71a63          	bne	a4,a5,800040aa <dirlookup+0x2a>
    8000409a:	892a                	mv	s2,a0
    8000409c:	89ae                	mv	s3,a1
    8000409e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a0:	457c                	lw	a5,76(a0)
    800040a2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040a4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a6:	e79d                	bnez	a5,800040d4 <dirlookup+0x54>
    800040a8:	a8a5                	j	80004120 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040aa:	00004517          	auipc	a0,0x4
    800040ae:	57650513          	addi	a0,a0,1398 # 80008620 <syscalls+0x1c8>
    800040b2:	ffffc097          	auipc	ra,0xffffc
    800040b6:	48c080e7          	jalr	1164(ra) # 8000053e <panic>
      panic("dirlookup read");
    800040ba:	00004517          	auipc	a0,0x4
    800040be:	57e50513          	addi	a0,a0,1406 # 80008638 <syscalls+0x1e0>
    800040c2:	ffffc097          	auipc	ra,0xffffc
    800040c6:	47c080e7          	jalr	1148(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ca:	24c1                	addiw	s1,s1,16
    800040cc:	04c92783          	lw	a5,76(s2)
    800040d0:	04f4f763          	bgeu	s1,a5,8000411e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040d4:	4741                	li	a4,16
    800040d6:	86a6                	mv	a3,s1
    800040d8:	fc040613          	addi	a2,s0,-64
    800040dc:	4581                	li	a1,0
    800040de:	854a                	mv	a0,s2
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	d70080e7          	jalr	-656(ra) # 80003e50 <readi>
    800040e8:	47c1                	li	a5,16
    800040ea:	fcf518e3          	bne	a0,a5,800040ba <dirlookup+0x3a>
    if(de.inum == 0)
    800040ee:	fc045783          	lhu	a5,-64(s0)
    800040f2:	dfe1                	beqz	a5,800040ca <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040f4:	fc240593          	addi	a1,s0,-62
    800040f8:	854e                	mv	a0,s3
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	f6c080e7          	jalr	-148(ra) # 80004066 <namecmp>
    80004102:	f561                	bnez	a0,800040ca <dirlookup+0x4a>
      if(poff)
    80004104:	000a0463          	beqz	s4,8000410c <dirlookup+0x8c>
        *poff = off;
    80004108:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000410c:	fc045583          	lhu	a1,-64(s0)
    80004110:	00092503          	lw	a0,0(s2)
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	750080e7          	jalr	1872(ra) # 80003864 <iget>
    8000411c:	a011                	j	80004120 <dirlookup+0xa0>
  return 0;
    8000411e:	4501                	li	a0,0
}
    80004120:	70e2                	ld	ra,56(sp)
    80004122:	7442                	ld	s0,48(sp)
    80004124:	74a2                	ld	s1,40(sp)
    80004126:	7902                	ld	s2,32(sp)
    80004128:	69e2                	ld	s3,24(sp)
    8000412a:	6a42                	ld	s4,16(sp)
    8000412c:	6121                	addi	sp,sp,64
    8000412e:	8082                	ret

0000000080004130 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004130:	711d                	addi	sp,sp,-96
    80004132:	ec86                	sd	ra,88(sp)
    80004134:	e8a2                	sd	s0,80(sp)
    80004136:	e4a6                	sd	s1,72(sp)
    80004138:	e0ca                	sd	s2,64(sp)
    8000413a:	fc4e                	sd	s3,56(sp)
    8000413c:	f852                	sd	s4,48(sp)
    8000413e:	f456                	sd	s5,40(sp)
    80004140:	f05a                	sd	s6,32(sp)
    80004142:	ec5e                	sd	s7,24(sp)
    80004144:	e862                	sd	s8,16(sp)
    80004146:	e466                	sd	s9,8(sp)
    80004148:	1080                	addi	s0,sp,96
    8000414a:	84aa                	mv	s1,a0
    8000414c:	8aae                	mv	s5,a1
    8000414e:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004150:	00054703          	lbu	a4,0(a0)
    80004154:	02f00793          	li	a5,47
    80004158:	02f70363          	beq	a4,a5,8000417e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000415c:	ffffe097          	auipc	ra,0xffffe
    80004160:	876080e7          	jalr	-1930(ra) # 800019d2 <myproc>
    80004164:	15053503          	ld	a0,336(a0)
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	9f6080e7          	jalr	-1546(ra) # 80003b5e <idup>
    80004170:	89aa                	mv	s3,a0
  while(*path == '/')
    80004172:	02f00913          	li	s2,47
  len = path - s;
    80004176:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004178:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000417a:	4b85                	li	s7,1
    8000417c:	a865                	j	80004234 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000417e:	4585                	li	a1,1
    80004180:	4505                	li	a0,1
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	6e2080e7          	jalr	1762(ra) # 80003864 <iget>
    8000418a:	89aa                	mv	s3,a0
    8000418c:	b7dd                	j	80004172 <namex+0x42>
      iunlockput(ip);
    8000418e:	854e                	mv	a0,s3
    80004190:	00000097          	auipc	ra,0x0
    80004194:	c6e080e7          	jalr	-914(ra) # 80003dfe <iunlockput>
      return 0;
    80004198:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000419a:	854e                	mv	a0,s3
    8000419c:	60e6                	ld	ra,88(sp)
    8000419e:	6446                	ld	s0,80(sp)
    800041a0:	64a6                	ld	s1,72(sp)
    800041a2:	6906                	ld	s2,64(sp)
    800041a4:	79e2                	ld	s3,56(sp)
    800041a6:	7a42                	ld	s4,48(sp)
    800041a8:	7aa2                	ld	s5,40(sp)
    800041aa:	7b02                	ld	s6,32(sp)
    800041ac:	6be2                	ld	s7,24(sp)
    800041ae:	6c42                	ld	s8,16(sp)
    800041b0:	6ca2                	ld	s9,8(sp)
    800041b2:	6125                	addi	sp,sp,96
    800041b4:	8082                	ret
      iunlock(ip);
    800041b6:	854e                	mv	a0,s3
    800041b8:	00000097          	auipc	ra,0x0
    800041bc:	aa6080e7          	jalr	-1370(ra) # 80003c5e <iunlock>
      return ip;
    800041c0:	bfe9                	j	8000419a <namex+0x6a>
      iunlockput(ip);
    800041c2:	854e                	mv	a0,s3
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	c3a080e7          	jalr	-966(ra) # 80003dfe <iunlockput>
      return 0;
    800041cc:	89e6                	mv	s3,s9
    800041ce:	b7f1                	j	8000419a <namex+0x6a>
  len = path - s;
    800041d0:	40b48633          	sub	a2,s1,a1
    800041d4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041d8:	099c5463          	bge	s8,s9,80004260 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800041dc:	4639                	li	a2,14
    800041de:	8552                	mv	a0,s4
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	b4e080e7          	jalr	-1202(ra) # 80000d2e <memmove>
  while(*path == '/')
    800041e8:	0004c783          	lbu	a5,0(s1)
    800041ec:	01279763          	bne	a5,s2,800041fa <namex+0xca>
    path++;
    800041f0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041f2:	0004c783          	lbu	a5,0(s1)
    800041f6:	ff278de3          	beq	a5,s2,800041f0 <namex+0xc0>
    ilock(ip);
    800041fa:	854e                	mv	a0,s3
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	9a0080e7          	jalr	-1632(ra) # 80003b9c <ilock>
    if(ip->type != T_DIR){
    80004204:	04499783          	lh	a5,68(s3)
    80004208:	f97793e3          	bne	a5,s7,8000418e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000420c:	000a8563          	beqz	s5,80004216 <namex+0xe6>
    80004210:	0004c783          	lbu	a5,0(s1)
    80004214:	d3cd                	beqz	a5,800041b6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004216:	865a                	mv	a2,s6
    80004218:	85d2                	mv	a1,s4
    8000421a:	854e                	mv	a0,s3
    8000421c:	00000097          	auipc	ra,0x0
    80004220:	e64080e7          	jalr	-412(ra) # 80004080 <dirlookup>
    80004224:	8caa                	mv	s9,a0
    80004226:	dd51                	beqz	a0,800041c2 <namex+0x92>
    iunlockput(ip);
    80004228:	854e                	mv	a0,s3
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	bd4080e7          	jalr	-1068(ra) # 80003dfe <iunlockput>
    ip = next;
    80004232:	89e6                	mv	s3,s9
  while(*path == '/')
    80004234:	0004c783          	lbu	a5,0(s1)
    80004238:	05279763          	bne	a5,s2,80004286 <namex+0x156>
    path++;
    8000423c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000423e:	0004c783          	lbu	a5,0(s1)
    80004242:	ff278de3          	beq	a5,s2,8000423c <namex+0x10c>
  if(*path == 0)
    80004246:	c79d                	beqz	a5,80004274 <namex+0x144>
    path++;
    80004248:	85a6                	mv	a1,s1
  len = path - s;
    8000424a:	8cda                	mv	s9,s6
    8000424c:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000424e:	01278963          	beq	a5,s2,80004260 <namex+0x130>
    80004252:	dfbd                	beqz	a5,800041d0 <namex+0xa0>
    path++;
    80004254:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004256:	0004c783          	lbu	a5,0(s1)
    8000425a:	ff279ce3          	bne	a5,s2,80004252 <namex+0x122>
    8000425e:	bf8d                	j	800041d0 <namex+0xa0>
    memmove(name, s, len);
    80004260:	2601                	sext.w	a2,a2
    80004262:	8552                	mv	a0,s4
    80004264:	ffffd097          	auipc	ra,0xffffd
    80004268:	aca080e7          	jalr	-1334(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000426c:	9cd2                	add	s9,s9,s4
    8000426e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004272:	bf9d                	j	800041e8 <namex+0xb8>
  if(nameiparent){
    80004274:	f20a83e3          	beqz	s5,8000419a <namex+0x6a>
    iput(ip);
    80004278:	854e                	mv	a0,s3
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	adc080e7          	jalr	-1316(ra) # 80003d56 <iput>
    return 0;
    80004282:	4981                	li	s3,0
    80004284:	bf19                	j	8000419a <namex+0x6a>
  if(*path == 0)
    80004286:	d7fd                	beqz	a5,80004274 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004288:	0004c783          	lbu	a5,0(s1)
    8000428c:	85a6                	mv	a1,s1
    8000428e:	b7d1                	j	80004252 <namex+0x122>

0000000080004290 <dirlink>:
{
    80004290:	7139                	addi	sp,sp,-64
    80004292:	fc06                	sd	ra,56(sp)
    80004294:	f822                	sd	s0,48(sp)
    80004296:	f426                	sd	s1,40(sp)
    80004298:	f04a                	sd	s2,32(sp)
    8000429a:	ec4e                	sd	s3,24(sp)
    8000429c:	e852                	sd	s4,16(sp)
    8000429e:	0080                	addi	s0,sp,64
    800042a0:	892a                	mv	s2,a0
    800042a2:	8a2e                	mv	s4,a1
    800042a4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042a6:	4601                	li	a2,0
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	dd8080e7          	jalr	-552(ra) # 80004080 <dirlookup>
    800042b0:	e93d                	bnez	a0,80004326 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042b2:	04c92483          	lw	s1,76(s2)
    800042b6:	c49d                	beqz	s1,800042e4 <dirlink+0x54>
    800042b8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ba:	4741                	li	a4,16
    800042bc:	86a6                	mv	a3,s1
    800042be:	fc040613          	addi	a2,s0,-64
    800042c2:	4581                	li	a1,0
    800042c4:	854a                	mv	a0,s2
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	b8a080e7          	jalr	-1142(ra) # 80003e50 <readi>
    800042ce:	47c1                	li	a5,16
    800042d0:	06f51163          	bne	a0,a5,80004332 <dirlink+0xa2>
    if(de.inum == 0)
    800042d4:	fc045783          	lhu	a5,-64(s0)
    800042d8:	c791                	beqz	a5,800042e4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042da:	24c1                	addiw	s1,s1,16
    800042dc:	04c92783          	lw	a5,76(s2)
    800042e0:	fcf4ede3          	bltu	s1,a5,800042ba <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042e4:	4639                	li	a2,14
    800042e6:	85d2                	mv	a1,s4
    800042e8:	fc240513          	addi	a0,s0,-62
    800042ec:	ffffd097          	auipc	ra,0xffffd
    800042f0:	af2080e7          	jalr	-1294(ra) # 80000dde <strncpy>
  de.inum = inum;
    800042f4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042f8:	4741                	li	a4,16
    800042fa:	86a6                	mv	a3,s1
    800042fc:	fc040613          	addi	a2,s0,-64
    80004300:	4581                	li	a1,0
    80004302:	854a                	mv	a0,s2
    80004304:	00000097          	auipc	ra,0x0
    80004308:	c44080e7          	jalr	-956(ra) # 80003f48 <writei>
    8000430c:	1541                	addi	a0,a0,-16
    8000430e:	00a03533          	snez	a0,a0
    80004312:	40a00533          	neg	a0,a0
}
    80004316:	70e2                	ld	ra,56(sp)
    80004318:	7442                	ld	s0,48(sp)
    8000431a:	74a2                	ld	s1,40(sp)
    8000431c:	7902                	ld	s2,32(sp)
    8000431e:	69e2                	ld	s3,24(sp)
    80004320:	6a42                	ld	s4,16(sp)
    80004322:	6121                	addi	sp,sp,64
    80004324:	8082                	ret
    iput(ip);
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	a30080e7          	jalr	-1488(ra) # 80003d56 <iput>
    return -1;
    8000432e:	557d                	li	a0,-1
    80004330:	b7dd                	j	80004316 <dirlink+0x86>
      panic("dirlink read");
    80004332:	00004517          	auipc	a0,0x4
    80004336:	31650513          	addi	a0,a0,790 # 80008648 <syscalls+0x1f0>
    8000433a:	ffffc097          	auipc	ra,0xffffc
    8000433e:	204080e7          	jalr	516(ra) # 8000053e <panic>

0000000080004342 <namei>:

struct inode*
namei(char *path)
{
    80004342:	1101                	addi	sp,sp,-32
    80004344:	ec06                	sd	ra,24(sp)
    80004346:	e822                	sd	s0,16(sp)
    80004348:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000434a:	fe040613          	addi	a2,s0,-32
    8000434e:	4581                	li	a1,0
    80004350:	00000097          	auipc	ra,0x0
    80004354:	de0080e7          	jalr	-544(ra) # 80004130 <namex>
}
    80004358:	60e2                	ld	ra,24(sp)
    8000435a:	6442                	ld	s0,16(sp)
    8000435c:	6105                	addi	sp,sp,32
    8000435e:	8082                	ret

0000000080004360 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004360:	1141                	addi	sp,sp,-16
    80004362:	e406                	sd	ra,8(sp)
    80004364:	e022                	sd	s0,0(sp)
    80004366:	0800                	addi	s0,sp,16
    80004368:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000436a:	4585                	li	a1,1
    8000436c:	00000097          	auipc	ra,0x0
    80004370:	dc4080e7          	jalr	-572(ra) # 80004130 <namex>
}
    80004374:	60a2                	ld	ra,8(sp)
    80004376:	6402                	ld	s0,0(sp)
    80004378:	0141                	addi	sp,sp,16
    8000437a:	8082                	ret

000000008000437c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000437c:	1101                	addi	sp,sp,-32
    8000437e:	ec06                	sd	ra,24(sp)
    80004380:	e822                	sd	s0,16(sp)
    80004382:	e426                	sd	s1,8(sp)
    80004384:	e04a                	sd	s2,0(sp)
    80004386:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004388:	00020917          	auipc	s2,0x20
    8000438c:	c2890913          	addi	s2,s2,-984 # 80023fb0 <log>
    80004390:	01892583          	lw	a1,24(s2)
    80004394:	02892503          	lw	a0,40(s2)
    80004398:	fffff097          	auipc	ra,0xfffff
    8000439c:	fea080e7          	jalr	-22(ra) # 80003382 <bread>
    800043a0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043a2:	02c92683          	lw	a3,44(s2)
    800043a6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043a8:	02d05763          	blez	a3,800043d6 <write_head+0x5a>
    800043ac:	00020797          	auipc	a5,0x20
    800043b0:	c3478793          	addi	a5,a5,-972 # 80023fe0 <log+0x30>
    800043b4:	05c50713          	addi	a4,a0,92
    800043b8:	36fd                	addiw	a3,a3,-1
    800043ba:	1682                	slli	a3,a3,0x20
    800043bc:	9281                	srli	a3,a3,0x20
    800043be:	068a                	slli	a3,a3,0x2
    800043c0:	00020617          	auipc	a2,0x20
    800043c4:	c2460613          	addi	a2,a2,-988 # 80023fe4 <log+0x34>
    800043c8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043ca:	4390                	lw	a2,0(a5)
    800043cc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043ce:	0791                	addi	a5,a5,4
    800043d0:	0711                	addi	a4,a4,4
    800043d2:	fed79ce3          	bne	a5,a3,800043ca <write_head+0x4e>
  }
  bwrite(buf);
    800043d6:	8526                	mv	a0,s1
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	09c080e7          	jalr	156(ra) # 80003474 <bwrite>
  brelse(buf);
    800043e0:	8526                	mv	a0,s1
    800043e2:	fffff097          	auipc	ra,0xfffff
    800043e6:	0d0080e7          	jalr	208(ra) # 800034b2 <brelse>
}
    800043ea:	60e2                	ld	ra,24(sp)
    800043ec:	6442                	ld	s0,16(sp)
    800043ee:	64a2                	ld	s1,8(sp)
    800043f0:	6902                	ld	s2,0(sp)
    800043f2:	6105                	addi	sp,sp,32
    800043f4:	8082                	ret

00000000800043f6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f6:	00020797          	auipc	a5,0x20
    800043fa:	be67a783          	lw	a5,-1050(a5) # 80023fdc <log+0x2c>
    800043fe:	0af05d63          	blez	a5,800044b8 <install_trans+0xc2>
{
    80004402:	7139                	addi	sp,sp,-64
    80004404:	fc06                	sd	ra,56(sp)
    80004406:	f822                	sd	s0,48(sp)
    80004408:	f426                	sd	s1,40(sp)
    8000440a:	f04a                	sd	s2,32(sp)
    8000440c:	ec4e                	sd	s3,24(sp)
    8000440e:	e852                	sd	s4,16(sp)
    80004410:	e456                	sd	s5,8(sp)
    80004412:	e05a                	sd	s6,0(sp)
    80004414:	0080                	addi	s0,sp,64
    80004416:	8b2a                	mv	s6,a0
    80004418:	00020a97          	auipc	s5,0x20
    8000441c:	bc8a8a93          	addi	s5,s5,-1080 # 80023fe0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004420:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004422:	00020997          	auipc	s3,0x20
    80004426:	b8e98993          	addi	s3,s3,-1138 # 80023fb0 <log>
    8000442a:	a00d                	j	8000444c <install_trans+0x56>
    brelse(lbuf);
    8000442c:	854a                	mv	a0,s2
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	084080e7          	jalr	132(ra) # 800034b2 <brelse>
    brelse(dbuf);
    80004436:	8526                	mv	a0,s1
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	07a080e7          	jalr	122(ra) # 800034b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004440:	2a05                	addiw	s4,s4,1
    80004442:	0a91                	addi	s5,s5,4
    80004444:	02c9a783          	lw	a5,44(s3)
    80004448:	04fa5e63          	bge	s4,a5,800044a4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000444c:	0189a583          	lw	a1,24(s3)
    80004450:	014585bb          	addw	a1,a1,s4
    80004454:	2585                	addiw	a1,a1,1
    80004456:	0289a503          	lw	a0,40(s3)
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	f28080e7          	jalr	-216(ra) # 80003382 <bread>
    80004462:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004464:	000aa583          	lw	a1,0(s5)
    80004468:	0289a503          	lw	a0,40(s3)
    8000446c:	fffff097          	auipc	ra,0xfffff
    80004470:	f16080e7          	jalr	-234(ra) # 80003382 <bread>
    80004474:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004476:	40000613          	li	a2,1024
    8000447a:	05890593          	addi	a1,s2,88
    8000447e:	05850513          	addi	a0,a0,88
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	8ac080e7          	jalr	-1876(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000448a:	8526                	mv	a0,s1
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	fe8080e7          	jalr	-24(ra) # 80003474 <bwrite>
    if(recovering == 0)
    80004494:	f80b1ce3          	bnez	s6,8000442c <install_trans+0x36>
      bunpin(dbuf);
    80004498:	8526                	mv	a0,s1
    8000449a:	fffff097          	auipc	ra,0xfffff
    8000449e:	0f2080e7          	jalr	242(ra) # 8000358c <bunpin>
    800044a2:	b769                	j	8000442c <install_trans+0x36>
}
    800044a4:	70e2                	ld	ra,56(sp)
    800044a6:	7442                	ld	s0,48(sp)
    800044a8:	74a2                	ld	s1,40(sp)
    800044aa:	7902                	ld	s2,32(sp)
    800044ac:	69e2                	ld	s3,24(sp)
    800044ae:	6a42                	ld	s4,16(sp)
    800044b0:	6aa2                	ld	s5,8(sp)
    800044b2:	6b02                	ld	s6,0(sp)
    800044b4:	6121                	addi	sp,sp,64
    800044b6:	8082                	ret
    800044b8:	8082                	ret

00000000800044ba <initlog>:
{
    800044ba:	7179                	addi	sp,sp,-48
    800044bc:	f406                	sd	ra,40(sp)
    800044be:	f022                	sd	s0,32(sp)
    800044c0:	ec26                	sd	s1,24(sp)
    800044c2:	e84a                	sd	s2,16(sp)
    800044c4:	e44e                	sd	s3,8(sp)
    800044c6:	1800                	addi	s0,sp,48
    800044c8:	892a                	mv	s2,a0
    800044ca:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044cc:	00020497          	auipc	s1,0x20
    800044d0:	ae448493          	addi	s1,s1,-1308 # 80023fb0 <log>
    800044d4:	00004597          	auipc	a1,0x4
    800044d8:	18458593          	addi	a1,a1,388 # 80008658 <syscalls+0x200>
    800044dc:	8526                	mv	a0,s1
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	668080e7          	jalr	1640(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800044e6:	0149a583          	lw	a1,20(s3)
    800044ea:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044ec:	0109a783          	lw	a5,16(s3)
    800044f0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044f2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044f6:	854a                	mv	a0,s2
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	e8a080e7          	jalr	-374(ra) # 80003382 <bread>
  log.lh.n = lh->n;
    80004500:	4d34                	lw	a3,88(a0)
    80004502:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004504:	02d05563          	blez	a3,8000452e <initlog+0x74>
    80004508:	05c50793          	addi	a5,a0,92
    8000450c:	00020717          	auipc	a4,0x20
    80004510:	ad470713          	addi	a4,a4,-1324 # 80023fe0 <log+0x30>
    80004514:	36fd                	addiw	a3,a3,-1
    80004516:	1682                	slli	a3,a3,0x20
    80004518:	9281                	srli	a3,a3,0x20
    8000451a:	068a                	slli	a3,a3,0x2
    8000451c:	06050613          	addi	a2,a0,96
    80004520:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004522:	4390                	lw	a2,0(a5)
    80004524:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004526:	0791                	addi	a5,a5,4
    80004528:	0711                	addi	a4,a4,4
    8000452a:	fed79ce3          	bne	a5,a3,80004522 <initlog+0x68>
  brelse(buf);
    8000452e:	fffff097          	auipc	ra,0xfffff
    80004532:	f84080e7          	jalr	-124(ra) # 800034b2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004536:	4505                	li	a0,1
    80004538:	00000097          	auipc	ra,0x0
    8000453c:	ebe080e7          	jalr	-322(ra) # 800043f6 <install_trans>
  log.lh.n = 0;
    80004540:	00020797          	auipc	a5,0x20
    80004544:	a807ae23          	sw	zero,-1380(a5) # 80023fdc <log+0x2c>
  write_head(); // clear the log
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	e34080e7          	jalr	-460(ra) # 8000437c <write_head>
}
    80004550:	70a2                	ld	ra,40(sp)
    80004552:	7402                	ld	s0,32(sp)
    80004554:	64e2                	ld	s1,24(sp)
    80004556:	6942                	ld	s2,16(sp)
    80004558:	69a2                	ld	s3,8(sp)
    8000455a:	6145                	addi	sp,sp,48
    8000455c:	8082                	ret

000000008000455e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000455e:	1101                	addi	sp,sp,-32
    80004560:	ec06                	sd	ra,24(sp)
    80004562:	e822                	sd	s0,16(sp)
    80004564:	e426                	sd	s1,8(sp)
    80004566:	e04a                	sd	s2,0(sp)
    80004568:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000456a:	00020517          	auipc	a0,0x20
    8000456e:	a4650513          	addi	a0,a0,-1466 # 80023fb0 <log>
    80004572:	ffffc097          	auipc	ra,0xffffc
    80004576:	664080e7          	jalr	1636(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000457a:	00020497          	auipc	s1,0x20
    8000457e:	a3648493          	addi	s1,s1,-1482 # 80023fb0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004582:	4979                	li	s2,30
    80004584:	a039                	j	80004592 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004586:	85a6                	mv	a1,s1
    80004588:	8526                	mv	a0,s1
    8000458a:	ffffe097          	auipc	ra,0xffffe
    8000458e:	c42080e7          	jalr	-958(ra) # 800021cc <sleep>
    if(log.committing){
    80004592:	50dc                	lw	a5,36(s1)
    80004594:	fbed                	bnez	a5,80004586 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004596:	509c                	lw	a5,32(s1)
    80004598:	0017871b          	addiw	a4,a5,1
    8000459c:	0007069b          	sext.w	a3,a4
    800045a0:	0027179b          	slliw	a5,a4,0x2
    800045a4:	9fb9                	addw	a5,a5,a4
    800045a6:	0017979b          	slliw	a5,a5,0x1
    800045aa:	54d8                	lw	a4,44(s1)
    800045ac:	9fb9                	addw	a5,a5,a4
    800045ae:	00f95963          	bge	s2,a5,800045c0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045b2:	85a6                	mv	a1,s1
    800045b4:	8526                	mv	a0,s1
    800045b6:	ffffe097          	auipc	ra,0xffffe
    800045ba:	c16080e7          	jalr	-1002(ra) # 800021cc <sleep>
    800045be:	bfd1                	j	80004592 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045c0:	00020517          	auipc	a0,0x20
    800045c4:	9f050513          	addi	a0,a0,-1552 # 80023fb0 <log>
    800045c8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	6c0080e7          	jalr	1728(ra) # 80000c8a <release>
      break;
    }
  }
}
    800045d2:	60e2                	ld	ra,24(sp)
    800045d4:	6442                	ld	s0,16(sp)
    800045d6:	64a2                	ld	s1,8(sp)
    800045d8:	6902                	ld	s2,0(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret

00000000800045de <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045de:	7139                	addi	sp,sp,-64
    800045e0:	fc06                	sd	ra,56(sp)
    800045e2:	f822                	sd	s0,48(sp)
    800045e4:	f426                	sd	s1,40(sp)
    800045e6:	f04a                	sd	s2,32(sp)
    800045e8:	ec4e                	sd	s3,24(sp)
    800045ea:	e852                	sd	s4,16(sp)
    800045ec:	e456                	sd	s5,8(sp)
    800045ee:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045f0:	00020497          	auipc	s1,0x20
    800045f4:	9c048493          	addi	s1,s1,-1600 # 80023fb0 <log>
    800045f8:	8526                	mv	a0,s1
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	5dc080e7          	jalr	1500(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004602:	509c                	lw	a5,32(s1)
    80004604:	37fd                	addiw	a5,a5,-1
    80004606:	0007891b          	sext.w	s2,a5
    8000460a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000460c:	50dc                	lw	a5,36(s1)
    8000460e:	e7b9                	bnez	a5,8000465c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004610:	04091e63          	bnez	s2,8000466c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004614:	00020497          	auipc	s1,0x20
    80004618:	99c48493          	addi	s1,s1,-1636 # 80023fb0 <log>
    8000461c:	4785                	li	a5,1
    8000461e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004620:	8526                	mv	a0,s1
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	668080e7          	jalr	1640(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000462a:	54dc                	lw	a5,44(s1)
    8000462c:	06f04763          	bgtz	a5,8000469a <end_op+0xbc>
    acquire(&log.lock);
    80004630:	00020497          	auipc	s1,0x20
    80004634:	98048493          	addi	s1,s1,-1664 # 80023fb0 <log>
    80004638:	8526                	mv	a0,s1
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	59c080e7          	jalr	1436(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004642:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004646:	8526                	mv	a0,s1
    80004648:	ffffe097          	auipc	ra,0xffffe
    8000464c:	be8080e7          	jalr	-1048(ra) # 80002230 <wakeup>
    release(&log.lock);
    80004650:	8526                	mv	a0,s1
    80004652:	ffffc097          	auipc	ra,0xffffc
    80004656:	638080e7          	jalr	1592(ra) # 80000c8a <release>
}
    8000465a:	a03d                	j	80004688 <end_op+0xaa>
    panic("log.committing");
    8000465c:	00004517          	auipc	a0,0x4
    80004660:	00450513          	addi	a0,a0,4 # 80008660 <syscalls+0x208>
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	eda080e7          	jalr	-294(ra) # 8000053e <panic>
    wakeup(&log);
    8000466c:	00020497          	auipc	s1,0x20
    80004670:	94448493          	addi	s1,s1,-1724 # 80023fb0 <log>
    80004674:	8526                	mv	a0,s1
    80004676:	ffffe097          	auipc	ra,0xffffe
    8000467a:	bba080e7          	jalr	-1094(ra) # 80002230 <wakeup>
  release(&log.lock);
    8000467e:	8526                	mv	a0,s1
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	60a080e7          	jalr	1546(ra) # 80000c8a <release>
}
    80004688:	70e2                	ld	ra,56(sp)
    8000468a:	7442                	ld	s0,48(sp)
    8000468c:	74a2                	ld	s1,40(sp)
    8000468e:	7902                	ld	s2,32(sp)
    80004690:	69e2                	ld	s3,24(sp)
    80004692:	6a42                	ld	s4,16(sp)
    80004694:	6aa2                	ld	s5,8(sp)
    80004696:	6121                	addi	sp,sp,64
    80004698:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000469a:	00020a97          	auipc	s5,0x20
    8000469e:	946a8a93          	addi	s5,s5,-1722 # 80023fe0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046a2:	00020a17          	auipc	s4,0x20
    800046a6:	90ea0a13          	addi	s4,s4,-1778 # 80023fb0 <log>
    800046aa:	018a2583          	lw	a1,24(s4)
    800046ae:	012585bb          	addw	a1,a1,s2
    800046b2:	2585                	addiw	a1,a1,1
    800046b4:	028a2503          	lw	a0,40(s4)
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	cca080e7          	jalr	-822(ra) # 80003382 <bread>
    800046c0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046c2:	000aa583          	lw	a1,0(s5)
    800046c6:	028a2503          	lw	a0,40(s4)
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	cb8080e7          	jalr	-840(ra) # 80003382 <bread>
    800046d2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046d4:	40000613          	li	a2,1024
    800046d8:	05850593          	addi	a1,a0,88
    800046dc:	05848513          	addi	a0,s1,88
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	64e080e7          	jalr	1614(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800046e8:	8526                	mv	a0,s1
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	d8a080e7          	jalr	-630(ra) # 80003474 <bwrite>
    brelse(from);
    800046f2:	854e                	mv	a0,s3
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	dbe080e7          	jalr	-578(ra) # 800034b2 <brelse>
    brelse(to);
    800046fc:	8526                	mv	a0,s1
    800046fe:	fffff097          	auipc	ra,0xfffff
    80004702:	db4080e7          	jalr	-588(ra) # 800034b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004706:	2905                	addiw	s2,s2,1
    80004708:	0a91                	addi	s5,s5,4
    8000470a:	02ca2783          	lw	a5,44(s4)
    8000470e:	f8f94ee3          	blt	s2,a5,800046aa <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004712:	00000097          	auipc	ra,0x0
    80004716:	c6a080e7          	jalr	-918(ra) # 8000437c <write_head>
    install_trans(0); // Now install writes to home locations
    8000471a:	4501                	li	a0,0
    8000471c:	00000097          	auipc	ra,0x0
    80004720:	cda080e7          	jalr	-806(ra) # 800043f6 <install_trans>
    log.lh.n = 0;
    80004724:	00020797          	auipc	a5,0x20
    80004728:	8a07ac23          	sw	zero,-1864(a5) # 80023fdc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	c50080e7          	jalr	-944(ra) # 8000437c <write_head>
    80004734:	bdf5                	j	80004630 <end_op+0x52>

0000000080004736 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004736:	1101                	addi	sp,sp,-32
    80004738:	ec06                	sd	ra,24(sp)
    8000473a:	e822                	sd	s0,16(sp)
    8000473c:	e426                	sd	s1,8(sp)
    8000473e:	e04a                	sd	s2,0(sp)
    80004740:	1000                	addi	s0,sp,32
    80004742:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004744:	00020917          	auipc	s2,0x20
    80004748:	86c90913          	addi	s2,s2,-1940 # 80023fb0 <log>
    8000474c:	854a                	mv	a0,s2
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	488080e7          	jalr	1160(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004756:	02c92603          	lw	a2,44(s2)
    8000475a:	47f5                	li	a5,29
    8000475c:	06c7c563          	blt	a5,a2,800047c6 <log_write+0x90>
    80004760:	00020797          	auipc	a5,0x20
    80004764:	86c7a783          	lw	a5,-1940(a5) # 80023fcc <log+0x1c>
    80004768:	37fd                	addiw	a5,a5,-1
    8000476a:	04f65e63          	bge	a2,a5,800047c6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000476e:	00020797          	auipc	a5,0x20
    80004772:	8627a783          	lw	a5,-1950(a5) # 80023fd0 <log+0x20>
    80004776:	06f05063          	blez	a5,800047d6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000477a:	4781                	li	a5,0
    8000477c:	06c05563          	blez	a2,800047e6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004780:	44cc                	lw	a1,12(s1)
    80004782:	00020717          	auipc	a4,0x20
    80004786:	85e70713          	addi	a4,a4,-1954 # 80023fe0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000478a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000478c:	4314                	lw	a3,0(a4)
    8000478e:	04b68c63          	beq	a3,a1,800047e6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004792:	2785                	addiw	a5,a5,1
    80004794:	0711                	addi	a4,a4,4
    80004796:	fef61be3          	bne	a2,a5,8000478c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000479a:	0621                	addi	a2,a2,8
    8000479c:	060a                	slli	a2,a2,0x2
    8000479e:	00020797          	auipc	a5,0x20
    800047a2:	81278793          	addi	a5,a5,-2030 # 80023fb0 <log>
    800047a6:	963e                	add	a2,a2,a5
    800047a8:	44dc                	lw	a5,12(s1)
    800047aa:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047ac:	8526                	mv	a0,s1
    800047ae:	fffff097          	auipc	ra,0xfffff
    800047b2:	da2080e7          	jalr	-606(ra) # 80003550 <bpin>
    log.lh.n++;
    800047b6:	0001f717          	auipc	a4,0x1f
    800047ba:	7fa70713          	addi	a4,a4,2042 # 80023fb0 <log>
    800047be:	575c                	lw	a5,44(a4)
    800047c0:	2785                	addiw	a5,a5,1
    800047c2:	d75c                	sw	a5,44(a4)
    800047c4:	a835                	j	80004800 <log_write+0xca>
    panic("too big a transaction");
    800047c6:	00004517          	auipc	a0,0x4
    800047ca:	eaa50513          	addi	a0,a0,-342 # 80008670 <syscalls+0x218>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	d70080e7          	jalr	-656(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800047d6:	00004517          	auipc	a0,0x4
    800047da:	eb250513          	addi	a0,a0,-334 # 80008688 <syscalls+0x230>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	d60080e7          	jalr	-672(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800047e6:	00878713          	addi	a4,a5,8
    800047ea:	00271693          	slli	a3,a4,0x2
    800047ee:	0001f717          	auipc	a4,0x1f
    800047f2:	7c270713          	addi	a4,a4,1986 # 80023fb0 <log>
    800047f6:	9736                	add	a4,a4,a3
    800047f8:	44d4                	lw	a3,12(s1)
    800047fa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047fc:	faf608e3          	beq	a2,a5,800047ac <log_write+0x76>
  }
  release(&log.lock);
    80004800:	0001f517          	auipc	a0,0x1f
    80004804:	7b050513          	addi	a0,a0,1968 # 80023fb0 <log>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	482080e7          	jalr	1154(ra) # 80000c8a <release>
}
    80004810:	60e2                	ld	ra,24(sp)
    80004812:	6442                	ld	s0,16(sp)
    80004814:	64a2                	ld	s1,8(sp)
    80004816:	6902                	ld	s2,0(sp)
    80004818:	6105                	addi	sp,sp,32
    8000481a:	8082                	ret

000000008000481c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000481c:	1101                	addi	sp,sp,-32
    8000481e:	ec06                	sd	ra,24(sp)
    80004820:	e822                	sd	s0,16(sp)
    80004822:	e426                	sd	s1,8(sp)
    80004824:	e04a                	sd	s2,0(sp)
    80004826:	1000                	addi	s0,sp,32
    80004828:	84aa                	mv	s1,a0
    8000482a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000482c:	00004597          	auipc	a1,0x4
    80004830:	e7c58593          	addi	a1,a1,-388 # 800086a8 <syscalls+0x250>
    80004834:	0521                	addi	a0,a0,8
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	310080e7          	jalr	784(ra) # 80000b46 <initlock>
  lk->name = name;
    8000483e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004842:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004846:	0204a423          	sw	zero,40(s1)
}
    8000484a:	60e2                	ld	ra,24(sp)
    8000484c:	6442                	ld	s0,16(sp)
    8000484e:	64a2                	ld	s1,8(sp)
    80004850:	6902                	ld	s2,0(sp)
    80004852:	6105                	addi	sp,sp,32
    80004854:	8082                	ret

0000000080004856 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	e04a                	sd	s2,0(sp)
    80004860:	1000                	addi	s0,sp,32
    80004862:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004864:	00850913          	addi	s2,a0,8
    80004868:	854a                	mv	a0,s2
    8000486a:	ffffc097          	auipc	ra,0xffffc
    8000486e:	36c080e7          	jalr	876(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004872:	409c                	lw	a5,0(s1)
    80004874:	cb89                	beqz	a5,80004886 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004876:	85ca                	mv	a1,s2
    80004878:	8526                	mv	a0,s1
    8000487a:	ffffe097          	auipc	ra,0xffffe
    8000487e:	952080e7          	jalr	-1710(ra) # 800021cc <sleep>
  while (lk->locked) {
    80004882:	409c                	lw	a5,0(s1)
    80004884:	fbed                	bnez	a5,80004876 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004886:	4785                	li	a5,1
    80004888:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000488a:	ffffd097          	auipc	ra,0xffffd
    8000488e:	148080e7          	jalr	328(ra) # 800019d2 <myproc>
    80004892:	591c                	lw	a5,48(a0)
    80004894:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004896:	854a                	mv	a0,s2
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	3f2080e7          	jalr	1010(ra) # 80000c8a <release>
}
    800048a0:	60e2                	ld	ra,24(sp)
    800048a2:	6442                	ld	s0,16(sp)
    800048a4:	64a2                	ld	s1,8(sp)
    800048a6:	6902                	ld	s2,0(sp)
    800048a8:	6105                	addi	sp,sp,32
    800048aa:	8082                	ret

00000000800048ac <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048ac:	1101                	addi	sp,sp,-32
    800048ae:	ec06                	sd	ra,24(sp)
    800048b0:	e822                	sd	s0,16(sp)
    800048b2:	e426                	sd	s1,8(sp)
    800048b4:	e04a                	sd	s2,0(sp)
    800048b6:	1000                	addi	s0,sp,32
    800048b8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048ba:	00850913          	addi	s2,a0,8
    800048be:	854a                	mv	a0,s2
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	316080e7          	jalr	790(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800048c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048d0:	8526                	mv	a0,s1
    800048d2:	ffffe097          	auipc	ra,0xffffe
    800048d6:	95e080e7          	jalr	-1698(ra) # 80002230 <wakeup>
  release(&lk->lk);
    800048da:	854a                	mv	a0,s2
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	3ae080e7          	jalr	942(ra) # 80000c8a <release>
}
    800048e4:	60e2                	ld	ra,24(sp)
    800048e6:	6442                	ld	s0,16(sp)
    800048e8:	64a2                	ld	s1,8(sp)
    800048ea:	6902                	ld	s2,0(sp)
    800048ec:	6105                	addi	sp,sp,32
    800048ee:	8082                	ret

00000000800048f0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048f0:	7179                	addi	sp,sp,-48
    800048f2:	f406                	sd	ra,40(sp)
    800048f4:	f022                	sd	s0,32(sp)
    800048f6:	ec26                	sd	s1,24(sp)
    800048f8:	e84a                	sd	s2,16(sp)
    800048fa:	e44e                	sd	s3,8(sp)
    800048fc:	1800                	addi	s0,sp,48
    800048fe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004900:	00850913          	addi	s2,a0,8
    80004904:	854a                	mv	a0,s2
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	2d0080e7          	jalr	720(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000490e:	409c                	lw	a5,0(s1)
    80004910:	ef99                	bnez	a5,8000492e <holdingsleep+0x3e>
    80004912:	4481                	li	s1,0
  release(&lk->lk);
    80004914:	854a                	mv	a0,s2
    80004916:	ffffc097          	auipc	ra,0xffffc
    8000491a:	374080e7          	jalr	884(ra) # 80000c8a <release>
  return r;
}
    8000491e:	8526                	mv	a0,s1
    80004920:	70a2                	ld	ra,40(sp)
    80004922:	7402                	ld	s0,32(sp)
    80004924:	64e2                	ld	s1,24(sp)
    80004926:	6942                	ld	s2,16(sp)
    80004928:	69a2                	ld	s3,8(sp)
    8000492a:	6145                	addi	sp,sp,48
    8000492c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000492e:	0284a983          	lw	s3,40(s1)
    80004932:	ffffd097          	auipc	ra,0xffffd
    80004936:	0a0080e7          	jalr	160(ra) # 800019d2 <myproc>
    8000493a:	5904                	lw	s1,48(a0)
    8000493c:	413484b3          	sub	s1,s1,s3
    80004940:	0014b493          	seqz	s1,s1
    80004944:	bfc1                	j	80004914 <holdingsleep+0x24>

0000000080004946 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004946:	1141                	addi	sp,sp,-16
    80004948:	e406                	sd	ra,8(sp)
    8000494a:	e022                	sd	s0,0(sp)
    8000494c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000494e:	00004597          	auipc	a1,0x4
    80004952:	d6a58593          	addi	a1,a1,-662 # 800086b8 <syscalls+0x260>
    80004956:	0001f517          	auipc	a0,0x1f
    8000495a:	7a250513          	addi	a0,a0,1954 # 800240f8 <ftable>
    8000495e:	ffffc097          	auipc	ra,0xffffc
    80004962:	1e8080e7          	jalr	488(ra) # 80000b46 <initlock>
}
    80004966:	60a2                	ld	ra,8(sp)
    80004968:	6402                	ld	s0,0(sp)
    8000496a:	0141                	addi	sp,sp,16
    8000496c:	8082                	ret

000000008000496e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000496e:	1101                	addi	sp,sp,-32
    80004970:	ec06                	sd	ra,24(sp)
    80004972:	e822                	sd	s0,16(sp)
    80004974:	e426                	sd	s1,8(sp)
    80004976:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004978:	0001f517          	auipc	a0,0x1f
    8000497c:	78050513          	addi	a0,a0,1920 # 800240f8 <ftable>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	256080e7          	jalr	598(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004988:	0001f497          	auipc	s1,0x1f
    8000498c:	78848493          	addi	s1,s1,1928 # 80024110 <ftable+0x18>
    80004990:	00020717          	auipc	a4,0x20
    80004994:	72070713          	addi	a4,a4,1824 # 800250b0 <disk>
    if(f->ref == 0){
    80004998:	40dc                	lw	a5,4(s1)
    8000499a:	cf99                	beqz	a5,800049b8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000499c:	02848493          	addi	s1,s1,40
    800049a0:	fee49ce3          	bne	s1,a4,80004998 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049a4:	0001f517          	auipc	a0,0x1f
    800049a8:	75450513          	addi	a0,a0,1876 # 800240f8 <ftable>
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	2de080e7          	jalr	734(ra) # 80000c8a <release>
  return 0;
    800049b4:	4481                	li	s1,0
    800049b6:	a819                	j	800049cc <filealloc+0x5e>
      f->ref = 1;
    800049b8:	4785                	li	a5,1
    800049ba:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049bc:	0001f517          	auipc	a0,0x1f
    800049c0:	73c50513          	addi	a0,a0,1852 # 800240f8 <ftable>
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	2c6080e7          	jalr	710(ra) # 80000c8a <release>
}
    800049cc:	8526                	mv	a0,s1
    800049ce:	60e2                	ld	ra,24(sp)
    800049d0:	6442                	ld	s0,16(sp)
    800049d2:	64a2                	ld	s1,8(sp)
    800049d4:	6105                	addi	sp,sp,32
    800049d6:	8082                	ret

00000000800049d8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049d8:	1101                	addi	sp,sp,-32
    800049da:	ec06                	sd	ra,24(sp)
    800049dc:	e822                	sd	s0,16(sp)
    800049de:	e426                	sd	s1,8(sp)
    800049e0:	1000                	addi	s0,sp,32
    800049e2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049e4:	0001f517          	auipc	a0,0x1f
    800049e8:	71450513          	addi	a0,a0,1812 # 800240f8 <ftable>
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	1ea080e7          	jalr	490(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800049f4:	40dc                	lw	a5,4(s1)
    800049f6:	02f05263          	blez	a5,80004a1a <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049fa:	2785                	addiw	a5,a5,1
    800049fc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049fe:	0001f517          	auipc	a0,0x1f
    80004a02:	6fa50513          	addi	a0,a0,1786 # 800240f8 <ftable>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	284080e7          	jalr	644(ra) # 80000c8a <release>
  return f;
}
    80004a0e:	8526                	mv	a0,s1
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6105                	addi	sp,sp,32
    80004a18:	8082                	ret
    panic("filedup");
    80004a1a:	00004517          	auipc	a0,0x4
    80004a1e:	ca650513          	addi	a0,a0,-858 # 800086c0 <syscalls+0x268>
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	b1c080e7          	jalr	-1252(ra) # 8000053e <panic>

0000000080004a2a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a2a:	7139                	addi	sp,sp,-64
    80004a2c:	fc06                	sd	ra,56(sp)
    80004a2e:	f822                	sd	s0,48(sp)
    80004a30:	f426                	sd	s1,40(sp)
    80004a32:	f04a                	sd	s2,32(sp)
    80004a34:	ec4e                	sd	s3,24(sp)
    80004a36:	e852                	sd	s4,16(sp)
    80004a38:	e456                	sd	s5,8(sp)
    80004a3a:	0080                	addi	s0,sp,64
    80004a3c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a3e:	0001f517          	auipc	a0,0x1f
    80004a42:	6ba50513          	addi	a0,a0,1722 # 800240f8 <ftable>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	190080e7          	jalr	400(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a4e:	40dc                	lw	a5,4(s1)
    80004a50:	06f05163          	blez	a5,80004ab2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a54:	37fd                	addiw	a5,a5,-1
    80004a56:	0007871b          	sext.w	a4,a5
    80004a5a:	c0dc                	sw	a5,4(s1)
    80004a5c:	06e04363          	bgtz	a4,80004ac2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a60:	0004a903          	lw	s2,0(s1)
    80004a64:	0094ca83          	lbu	s5,9(s1)
    80004a68:	0104ba03          	ld	s4,16(s1)
    80004a6c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a70:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a74:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a78:	0001f517          	auipc	a0,0x1f
    80004a7c:	68050513          	addi	a0,a0,1664 # 800240f8 <ftable>
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	20a080e7          	jalr	522(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004a88:	4785                	li	a5,1
    80004a8a:	04f90d63          	beq	s2,a5,80004ae4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a8e:	3979                	addiw	s2,s2,-2
    80004a90:	4785                	li	a5,1
    80004a92:	0527e063          	bltu	a5,s2,80004ad2 <fileclose+0xa8>
    begin_op();
    80004a96:	00000097          	auipc	ra,0x0
    80004a9a:	ac8080e7          	jalr	-1336(ra) # 8000455e <begin_op>
    iput(ff.ip);
    80004a9e:	854e                	mv	a0,s3
    80004aa0:	fffff097          	auipc	ra,0xfffff
    80004aa4:	2b6080e7          	jalr	694(ra) # 80003d56 <iput>
    end_op();
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	b36080e7          	jalr	-1226(ra) # 800045de <end_op>
    80004ab0:	a00d                	j	80004ad2 <fileclose+0xa8>
    panic("fileclose");
    80004ab2:	00004517          	auipc	a0,0x4
    80004ab6:	c1650513          	addi	a0,a0,-1002 # 800086c8 <syscalls+0x270>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	a84080e7          	jalr	-1404(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004ac2:	0001f517          	auipc	a0,0x1f
    80004ac6:	63650513          	addi	a0,a0,1590 # 800240f8 <ftable>
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	1c0080e7          	jalr	448(ra) # 80000c8a <release>
  }
}
    80004ad2:	70e2                	ld	ra,56(sp)
    80004ad4:	7442                	ld	s0,48(sp)
    80004ad6:	74a2                	ld	s1,40(sp)
    80004ad8:	7902                	ld	s2,32(sp)
    80004ada:	69e2                	ld	s3,24(sp)
    80004adc:	6a42                	ld	s4,16(sp)
    80004ade:	6aa2                	ld	s5,8(sp)
    80004ae0:	6121                	addi	sp,sp,64
    80004ae2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ae4:	85d6                	mv	a1,s5
    80004ae6:	8552                	mv	a0,s4
    80004ae8:	00000097          	auipc	ra,0x0
    80004aec:	34c080e7          	jalr	844(ra) # 80004e34 <pipeclose>
    80004af0:	b7cd                	j	80004ad2 <fileclose+0xa8>

0000000080004af2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004af2:	715d                	addi	sp,sp,-80
    80004af4:	e486                	sd	ra,72(sp)
    80004af6:	e0a2                	sd	s0,64(sp)
    80004af8:	fc26                	sd	s1,56(sp)
    80004afa:	f84a                	sd	s2,48(sp)
    80004afc:	f44e                	sd	s3,40(sp)
    80004afe:	0880                	addi	s0,sp,80
    80004b00:	84aa                	mv	s1,a0
    80004b02:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b04:	ffffd097          	auipc	ra,0xffffd
    80004b08:	ece080e7          	jalr	-306(ra) # 800019d2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b0c:	409c                	lw	a5,0(s1)
    80004b0e:	37f9                	addiw	a5,a5,-2
    80004b10:	4705                	li	a4,1
    80004b12:	04f76763          	bltu	a4,a5,80004b60 <filestat+0x6e>
    80004b16:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b18:	6c88                	ld	a0,24(s1)
    80004b1a:	fffff097          	auipc	ra,0xfffff
    80004b1e:	082080e7          	jalr	130(ra) # 80003b9c <ilock>
    stati(f->ip, &st);
    80004b22:	fb840593          	addi	a1,s0,-72
    80004b26:	6c88                	ld	a0,24(s1)
    80004b28:	fffff097          	auipc	ra,0xfffff
    80004b2c:	2fe080e7          	jalr	766(ra) # 80003e26 <stati>
    iunlock(f->ip);
    80004b30:	6c88                	ld	a0,24(s1)
    80004b32:	fffff097          	auipc	ra,0xfffff
    80004b36:	12c080e7          	jalr	300(ra) # 80003c5e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b3a:	46e1                	li	a3,24
    80004b3c:	fb840613          	addi	a2,s0,-72
    80004b40:	85ce                	mv	a1,s3
    80004b42:	05093503          	ld	a0,80(s2)
    80004b46:	ffffd097          	auipc	ra,0xffffd
    80004b4a:	b22080e7          	jalr	-1246(ra) # 80001668 <copyout>
    80004b4e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b52:	60a6                	ld	ra,72(sp)
    80004b54:	6406                	ld	s0,64(sp)
    80004b56:	74e2                	ld	s1,56(sp)
    80004b58:	7942                	ld	s2,48(sp)
    80004b5a:	79a2                	ld	s3,40(sp)
    80004b5c:	6161                	addi	sp,sp,80
    80004b5e:	8082                	ret
  return -1;
    80004b60:	557d                	li	a0,-1
    80004b62:	bfc5                	j	80004b52 <filestat+0x60>

0000000080004b64 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b64:	7179                	addi	sp,sp,-48
    80004b66:	f406                	sd	ra,40(sp)
    80004b68:	f022                	sd	s0,32(sp)
    80004b6a:	ec26                	sd	s1,24(sp)
    80004b6c:	e84a                	sd	s2,16(sp)
    80004b6e:	e44e                	sd	s3,8(sp)
    80004b70:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b72:	00854783          	lbu	a5,8(a0)
    80004b76:	c3d5                	beqz	a5,80004c1a <fileread+0xb6>
    80004b78:	84aa                	mv	s1,a0
    80004b7a:	89ae                	mv	s3,a1
    80004b7c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b7e:	411c                	lw	a5,0(a0)
    80004b80:	4705                	li	a4,1
    80004b82:	04e78963          	beq	a5,a4,80004bd4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b86:	470d                	li	a4,3
    80004b88:	04e78d63          	beq	a5,a4,80004be2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b8c:	4709                	li	a4,2
    80004b8e:	06e79e63          	bne	a5,a4,80004c0a <fileread+0xa6>
    ilock(f->ip);
    80004b92:	6d08                	ld	a0,24(a0)
    80004b94:	fffff097          	auipc	ra,0xfffff
    80004b98:	008080e7          	jalr	8(ra) # 80003b9c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b9c:	874a                	mv	a4,s2
    80004b9e:	5094                	lw	a3,32(s1)
    80004ba0:	864e                	mv	a2,s3
    80004ba2:	4585                	li	a1,1
    80004ba4:	6c88                	ld	a0,24(s1)
    80004ba6:	fffff097          	auipc	ra,0xfffff
    80004baa:	2aa080e7          	jalr	682(ra) # 80003e50 <readi>
    80004bae:	892a                	mv	s2,a0
    80004bb0:	00a05563          	blez	a0,80004bba <fileread+0x56>
      f->off += r;
    80004bb4:	509c                	lw	a5,32(s1)
    80004bb6:	9fa9                	addw	a5,a5,a0
    80004bb8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bba:	6c88                	ld	a0,24(s1)
    80004bbc:	fffff097          	auipc	ra,0xfffff
    80004bc0:	0a2080e7          	jalr	162(ra) # 80003c5e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004bc4:	854a                	mv	a0,s2
    80004bc6:	70a2                	ld	ra,40(sp)
    80004bc8:	7402                	ld	s0,32(sp)
    80004bca:	64e2                	ld	s1,24(sp)
    80004bcc:	6942                	ld	s2,16(sp)
    80004bce:	69a2                	ld	s3,8(sp)
    80004bd0:	6145                	addi	sp,sp,48
    80004bd2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bd4:	6908                	ld	a0,16(a0)
    80004bd6:	00000097          	auipc	ra,0x0
    80004bda:	3c6080e7          	jalr	966(ra) # 80004f9c <piperead>
    80004bde:	892a                	mv	s2,a0
    80004be0:	b7d5                	j	80004bc4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004be2:	02451783          	lh	a5,36(a0)
    80004be6:	03079693          	slli	a3,a5,0x30
    80004bea:	92c1                	srli	a3,a3,0x30
    80004bec:	4725                	li	a4,9
    80004bee:	02d76863          	bltu	a4,a3,80004c1e <fileread+0xba>
    80004bf2:	0792                	slli	a5,a5,0x4
    80004bf4:	0001f717          	auipc	a4,0x1f
    80004bf8:	46470713          	addi	a4,a4,1124 # 80024058 <devsw>
    80004bfc:	97ba                	add	a5,a5,a4
    80004bfe:	639c                	ld	a5,0(a5)
    80004c00:	c38d                	beqz	a5,80004c22 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c02:	4505                	li	a0,1
    80004c04:	9782                	jalr	a5
    80004c06:	892a                	mv	s2,a0
    80004c08:	bf75                	j	80004bc4 <fileread+0x60>
    panic("fileread");
    80004c0a:	00004517          	auipc	a0,0x4
    80004c0e:	ace50513          	addi	a0,a0,-1330 # 800086d8 <syscalls+0x280>
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	92c080e7          	jalr	-1748(ra) # 8000053e <panic>
    return -1;
    80004c1a:	597d                	li	s2,-1
    80004c1c:	b765                	j	80004bc4 <fileread+0x60>
      return -1;
    80004c1e:	597d                	li	s2,-1
    80004c20:	b755                	j	80004bc4 <fileread+0x60>
    80004c22:	597d                	li	s2,-1
    80004c24:	b745                	j	80004bc4 <fileread+0x60>

0000000080004c26 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c26:	715d                	addi	sp,sp,-80
    80004c28:	e486                	sd	ra,72(sp)
    80004c2a:	e0a2                	sd	s0,64(sp)
    80004c2c:	fc26                	sd	s1,56(sp)
    80004c2e:	f84a                	sd	s2,48(sp)
    80004c30:	f44e                	sd	s3,40(sp)
    80004c32:	f052                	sd	s4,32(sp)
    80004c34:	ec56                	sd	s5,24(sp)
    80004c36:	e85a                	sd	s6,16(sp)
    80004c38:	e45e                	sd	s7,8(sp)
    80004c3a:	e062                	sd	s8,0(sp)
    80004c3c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c3e:	00954783          	lbu	a5,9(a0)
    80004c42:	10078663          	beqz	a5,80004d4e <filewrite+0x128>
    80004c46:	892a                	mv	s2,a0
    80004c48:	8aae                	mv	s5,a1
    80004c4a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c4c:	411c                	lw	a5,0(a0)
    80004c4e:	4705                	li	a4,1
    80004c50:	02e78263          	beq	a5,a4,80004c74 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c54:	470d                	li	a4,3
    80004c56:	02e78663          	beq	a5,a4,80004c82 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c5a:	4709                	li	a4,2
    80004c5c:	0ee79163          	bne	a5,a4,80004d3e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c60:	0ac05d63          	blez	a2,80004d1a <filewrite+0xf4>
    int i = 0;
    80004c64:	4981                	li	s3,0
    80004c66:	6b05                	lui	s6,0x1
    80004c68:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c6c:	6b85                	lui	s7,0x1
    80004c6e:	c00b8b9b          	addiw	s7,s7,-1024
    80004c72:	a861                	j	80004d0a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c74:	6908                	ld	a0,16(a0)
    80004c76:	00000097          	auipc	ra,0x0
    80004c7a:	22e080e7          	jalr	558(ra) # 80004ea4 <pipewrite>
    80004c7e:	8a2a                	mv	s4,a0
    80004c80:	a045                	j	80004d20 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c82:	02451783          	lh	a5,36(a0)
    80004c86:	03079693          	slli	a3,a5,0x30
    80004c8a:	92c1                	srli	a3,a3,0x30
    80004c8c:	4725                	li	a4,9
    80004c8e:	0cd76263          	bltu	a4,a3,80004d52 <filewrite+0x12c>
    80004c92:	0792                	slli	a5,a5,0x4
    80004c94:	0001f717          	auipc	a4,0x1f
    80004c98:	3c470713          	addi	a4,a4,964 # 80024058 <devsw>
    80004c9c:	97ba                	add	a5,a5,a4
    80004c9e:	679c                	ld	a5,8(a5)
    80004ca0:	cbdd                	beqz	a5,80004d56 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ca2:	4505                	li	a0,1
    80004ca4:	9782                	jalr	a5
    80004ca6:	8a2a                	mv	s4,a0
    80004ca8:	a8a5                	j	80004d20 <filewrite+0xfa>
    80004caa:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cae:	00000097          	auipc	ra,0x0
    80004cb2:	8b0080e7          	jalr	-1872(ra) # 8000455e <begin_op>
      ilock(f->ip);
    80004cb6:	01893503          	ld	a0,24(s2)
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	ee2080e7          	jalr	-286(ra) # 80003b9c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cc2:	8762                	mv	a4,s8
    80004cc4:	02092683          	lw	a3,32(s2)
    80004cc8:	01598633          	add	a2,s3,s5
    80004ccc:	4585                	li	a1,1
    80004cce:	01893503          	ld	a0,24(s2)
    80004cd2:	fffff097          	auipc	ra,0xfffff
    80004cd6:	276080e7          	jalr	630(ra) # 80003f48 <writei>
    80004cda:	84aa                	mv	s1,a0
    80004cdc:	00a05763          	blez	a0,80004cea <filewrite+0xc4>
        f->off += r;
    80004ce0:	02092783          	lw	a5,32(s2)
    80004ce4:	9fa9                	addw	a5,a5,a0
    80004ce6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cea:	01893503          	ld	a0,24(s2)
    80004cee:	fffff097          	auipc	ra,0xfffff
    80004cf2:	f70080e7          	jalr	-144(ra) # 80003c5e <iunlock>
      end_op();
    80004cf6:	00000097          	auipc	ra,0x0
    80004cfa:	8e8080e7          	jalr	-1816(ra) # 800045de <end_op>

      if(r != n1){
    80004cfe:	009c1f63          	bne	s8,s1,80004d1c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d02:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d06:	0149db63          	bge	s3,s4,80004d1c <filewrite+0xf6>
      int n1 = n - i;
    80004d0a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d0e:	84be                	mv	s1,a5
    80004d10:	2781                	sext.w	a5,a5
    80004d12:	f8fb5ce3          	bge	s6,a5,80004caa <filewrite+0x84>
    80004d16:	84de                	mv	s1,s7
    80004d18:	bf49                	j	80004caa <filewrite+0x84>
    int i = 0;
    80004d1a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d1c:	013a1f63          	bne	s4,s3,80004d3a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d20:	8552                	mv	a0,s4
    80004d22:	60a6                	ld	ra,72(sp)
    80004d24:	6406                	ld	s0,64(sp)
    80004d26:	74e2                	ld	s1,56(sp)
    80004d28:	7942                	ld	s2,48(sp)
    80004d2a:	79a2                	ld	s3,40(sp)
    80004d2c:	7a02                	ld	s4,32(sp)
    80004d2e:	6ae2                	ld	s5,24(sp)
    80004d30:	6b42                	ld	s6,16(sp)
    80004d32:	6ba2                	ld	s7,8(sp)
    80004d34:	6c02                	ld	s8,0(sp)
    80004d36:	6161                	addi	sp,sp,80
    80004d38:	8082                	ret
    ret = (i == n ? n : -1);
    80004d3a:	5a7d                	li	s4,-1
    80004d3c:	b7d5                	j	80004d20 <filewrite+0xfa>
    panic("filewrite");
    80004d3e:	00004517          	auipc	a0,0x4
    80004d42:	9aa50513          	addi	a0,a0,-1622 # 800086e8 <syscalls+0x290>
    80004d46:	ffffb097          	auipc	ra,0xffffb
    80004d4a:	7f8080e7          	jalr	2040(ra) # 8000053e <panic>
    return -1;
    80004d4e:	5a7d                	li	s4,-1
    80004d50:	bfc1                	j	80004d20 <filewrite+0xfa>
      return -1;
    80004d52:	5a7d                	li	s4,-1
    80004d54:	b7f1                	j	80004d20 <filewrite+0xfa>
    80004d56:	5a7d                	li	s4,-1
    80004d58:	b7e1                	j	80004d20 <filewrite+0xfa>

0000000080004d5a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d5a:	7179                	addi	sp,sp,-48
    80004d5c:	f406                	sd	ra,40(sp)
    80004d5e:	f022                	sd	s0,32(sp)
    80004d60:	ec26                	sd	s1,24(sp)
    80004d62:	e84a                	sd	s2,16(sp)
    80004d64:	e44e                	sd	s3,8(sp)
    80004d66:	e052                	sd	s4,0(sp)
    80004d68:	1800                	addi	s0,sp,48
    80004d6a:	84aa                	mv	s1,a0
    80004d6c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d6e:	0005b023          	sd	zero,0(a1)
    80004d72:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d76:	00000097          	auipc	ra,0x0
    80004d7a:	bf8080e7          	jalr	-1032(ra) # 8000496e <filealloc>
    80004d7e:	e088                	sd	a0,0(s1)
    80004d80:	c551                	beqz	a0,80004e0c <pipealloc+0xb2>
    80004d82:	00000097          	auipc	ra,0x0
    80004d86:	bec080e7          	jalr	-1044(ra) # 8000496e <filealloc>
    80004d8a:	00aa3023          	sd	a0,0(s4)
    80004d8e:	c92d                	beqz	a0,80004e00 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	d56080e7          	jalr	-682(ra) # 80000ae6 <kalloc>
    80004d98:	892a                	mv	s2,a0
    80004d9a:	c125                	beqz	a0,80004dfa <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d9c:	4985                	li	s3,1
    80004d9e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004da2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004da6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004daa:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004dae:	00004597          	auipc	a1,0x4
    80004db2:	94a58593          	addi	a1,a1,-1718 # 800086f8 <syscalls+0x2a0>
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	d90080e7          	jalr	-624(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004dbe:	609c                	ld	a5,0(s1)
    80004dc0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004dc4:	609c                	ld	a5,0(s1)
    80004dc6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004dca:	609c                	ld	a5,0(s1)
    80004dcc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004dd0:	609c                	ld	a5,0(s1)
    80004dd2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004dd6:	000a3783          	ld	a5,0(s4)
    80004dda:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004dde:	000a3783          	ld	a5,0(s4)
    80004de2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004de6:	000a3783          	ld	a5,0(s4)
    80004dea:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004dee:	000a3783          	ld	a5,0(s4)
    80004df2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004df6:	4501                	li	a0,0
    80004df8:	a025                	j	80004e20 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dfa:	6088                	ld	a0,0(s1)
    80004dfc:	e501                	bnez	a0,80004e04 <pipealloc+0xaa>
    80004dfe:	a039                	j	80004e0c <pipealloc+0xb2>
    80004e00:	6088                	ld	a0,0(s1)
    80004e02:	c51d                	beqz	a0,80004e30 <pipealloc+0xd6>
    fileclose(*f0);
    80004e04:	00000097          	auipc	ra,0x0
    80004e08:	c26080e7          	jalr	-986(ra) # 80004a2a <fileclose>
  if(*f1)
    80004e0c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e10:	557d                	li	a0,-1
  if(*f1)
    80004e12:	c799                	beqz	a5,80004e20 <pipealloc+0xc6>
    fileclose(*f1);
    80004e14:	853e                	mv	a0,a5
    80004e16:	00000097          	auipc	ra,0x0
    80004e1a:	c14080e7          	jalr	-1004(ra) # 80004a2a <fileclose>
  return -1;
    80004e1e:	557d                	li	a0,-1
}
    80004e20:	70a2                	ld	ra,40(sp)
    80004e22:	7402                	ld	s0,32(sp)
    80004e24:	64e2                	ld	s1,24(sp)
    80004e26:	6942                	ld	s2,16(sp)
    80004e28:	69a2                	ld	s3,8(sp)
    80004e2a:	6a02                	ld	s4,0(sp)
    80004e2c:	6145                	addi	sp,sp,48
    80004e2e:	8082                	ret
  return -1;
    80004e30:	557d                	li	a0,-1
    80004e32:	b7fd                	j	80004e20 <pipealloc+0xc6>

0000000080004e34 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e34:	1101                	addi	sp,sp,-32
    80004e36:	ec06                	sd	ra,24(sp)
    80004e38:	e822                	sd	s0,16(sp)
    80004e3a:	e426                	sd	s1,8(sp)
    80004e3c:	e04a                	sd	s2,0(sp)
    80004e3e:	1000                	addi	s0,sp,32
    80004e40:	84aa                	mv	s1,a0
    80004e42:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	d92080e7          	jalr	-622(ra) # 80000bd6 <acquire>
  if(writable){
    80004e4c:	02090d63          	beqz	s2,80004e86 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e50:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e54:	21848513          	addi	a0,s1,536
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	3d8080e7          	jalr	984(ra) # 80002230 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e60:	2204b783          	ld	a5,544(s1)
    80004e64:	eb95                	bnez	a5,80004e98 <pipeclose+0x64>
    release(&pi->lock);
    80004e66:	8526                	mv	a0,s1
    80004e68:	ffffc097          	auipc	ra,0xffffc
    80004e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004e70:	8526                	mv	a0,s1
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	b78080e7          	jalr	-1160(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004e7a:	60e2                	ld	ra,24(sp)
    80004e7c:	6442                	ld	s0,16(sp)
    80004e7e:	64a2                	ld	s1,8(sp)
    80004e80:	6902                	ld	s2,0(sp)
    80004e82:	6105                	addi	sp,sp,32
    80004e84:	8082                	ret
    pi->readopen = 0;
    80004e86:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e8a:	21c48513          	addi	a0,s1,540
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	3a2080e7          	jalr	930(ra) # 80002230 <wakeup>
    80004e96:	b7e9                	j	80004e60 <pipeclose+0x2c>
    release(&pi->lock);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	df0080e7          	jalr	-528(ra) # 80000c8a <release>
}
    80004ea2:	bfe1                	j	80004e7a <pipeclose+0x46>

0000000080004ea4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ea4:	711d                	addi	sp,sp,-96
    80004ea6:	ec86                	sd	ra,88(sp)
    80004ea8:	e8a2                	sd	s0,80(sp)
    80004eaa:	e4a6                	sd	s1,72(sp)
    80004eac:	e0ca                	sd	s2,64(sp)
    80004eae:	fc4e                	sd	s3,56(sp)
    80004eb0:	f852                	sd	s4,48(sp)
    80004eb2:	f456                	sd	s5,40(sp)
    80004eb4:	f05a                	sd	s6,32(sp)
    80004eb6:	ec5e                	sd	s7,24(sp)
    80004eb8:	e862                	sd	s8,16(sp)
    80004eba:	1080                	addi	s0,sp,96
    80004ebc:	84aa                	mv	s1,a0
    80004ebe:	8aae                	mv	s5,a1
    80004ec0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	b10080e7          	jalr	-1264(ra) # 800019d2 <myproc>
    80004eca:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	d08080e7          	jalr	-760(ra) # 80000bd6 <acquire>
  while(i < n){
    80004ed6:	0b405663          	blez	s4,80004f82 <pipewrite+0xde>
  int i = 0;
    80004eda:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004edc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ede:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ee2:	21c48b93          	addi	s7,s1,540
    80004ee6:	a089                	j	80004f28 <pipewrite+0x84>
      release(&pi->lock);
    80004ee8:	8526                	mv	a0,s1
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	da0080e7          	jalr	-608(ra) # 80000c8a <release>
      return -1;
    80004ef2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ef4:	854a                	mv	a0,s2
    80004ef6:	60e6                	ld	ra,88(sp)
    80004ef8:	6446                	ld	s0,80(sp)
    80004efa:	64a6                	ld	s1,72(sp)
    80004efc:	6906                	ld	s2,64(sp)
    80004efe:	79e2                	ld	s3,56(sp)
    80004f00:	7a42                	ld	s4,48(sp)
    80004f02:	7aa2                	ld	s5,40(sp)
    80004f04:	7b02                	ld	s6,32(sp)
    80004f06:	6be2                	ld	s7,24(sp)
    80004f08:	6c42                	ld	s8,16(sp)
    80004f0a:	6125                	addi	sp,sp,96
    80004f0c:	8082                	ret
      wakeup(&pi->nread);
    80004f0e:	8562                	mv	a0,s8
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	320080e7          	jalr	800(ra) # 80002230 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f18:	85a6                	mv	a1,s1
    80004f1a:	855e                	mv	a0,s7
    80004f1c:	ffffd097          	auipc	ra,0xffffd
    80004f20:	2b0080e7          	jalr	688(ra) # 800021cc <sleep>
  while(i < n){
    80004f24:	07495063          	bge	s2,s4,80004f84 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f28:	2204a783          	lw	a5,544(s1)
    80004f2c:	dfd5                	beqz	a5,80004ee8 <pipewrite+0x44>
    80004f2e:	854e                	mv	a0,s3
    80004f30:	ffffd097          	auipc	ra,0xffffd
    80004f34:	54e080e7          	jalr	1358(ra) # 8000247e <killed>
    80004f38:	f945                	bnez	a0,80004ee8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f3a:	2184a783          	lw	a5,536(s1)
    80004f3e:	21c4a703          	lw	a4,540(s1)
    80004f42:	2007879b          	addiw	a5,a5,512
    80004f46:	fcf704e3          	beq	a4,a5,80004f0e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f4a:	4685                	li	a3,1
    80004f4c:	01590633          	add	a2,s2,s5
    80004f50:	faf40593          	addi	a1,s0,-81
    80004f54:	0509b503          	ld	a0,80(s3)
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	79c080e7          	jalr	1948(ra) # 800016f4 <copyin>
    80004f60:	03650263          	beq	a0,s6,80004f84 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f64:	21c4a783          	lw	a5,540(s1)
    80004f68:	0017871b          	addiw	a4,a5,1
    80004f6c:	20e4ae23          	sw	a4,540(s1)
    80004f70:	1ff7f793          	andi	a5,a5,511
    80004f74:	97a6                	add	a5,a5,s1
    80004f76:	faf44703          	lbu	a4,-81(s0)
    80004f7a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f7e:	2905                	addiw	s2,s2,1
    80004f80:	b755                	j	80004f24 <pipewrite+0x80>
  int i = 0;
    80004f82:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f84:	21848513          	addi	a0,s1,536
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	2a8080e7          	jalr	680(ra) # 80002230 <wakeup>
  release(&pi->lock);
    80004f90:	8526                	mv	a0,s1
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	cf8080e7          	jalr	-776(ra) # 80000c8a <release>
  return i;
    80004f9a:	bfa9                	j	80004ef4 <pipewrite+0x50>

0000000080004f9c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f9c:	715d                	addi	sp,sp,-80
    80004f9e:	e486                	sd	ra,72(sp)
    80004fa0:	e0a2                	sd	s0,64(sp)
    80004fa2:	fc26                	sd	s1,56(sp)
    80004fa4:	f84a                	sd	s2,48(sp)
    80004fa6:	f44e                	sd	s3,40(sp)
    80004fa8:	f052                	sd	s4,32(sp)
    80004faa:	ec56                	sd	s5,24(sp)
    80004fac:	e85a                	sd	s6,16(sp)
    80004fae:	0880                	addi	s0,sp,80
    80004fb0:	84aa                	mv	s1,a0
    80004fb2:	892e                	mv	s2,a1
    80004fb4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	a1c080e7          	jalr	-1508(ra) # 800019d2 <myproc>
    80004fbe:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004fc0:	8526                	mv	a0,s1
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	c14080e7          	jalr	-1004(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fca:	2184a703          	lw	a4,536(s1)
    80004fce:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fd2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fd6:	02f71763          	bne	a4,a5,80005004 <piperead+0x68>
    80004fda:	2244a783          	lw	a5,548(s1)
    80004fde:	c39d                	beqz	a5,80005004 <piperead+0x68>
    if(killed(pr)){
    80004fe0:	8552                	mv	a0,s4
    80004fe2:	ffffd097          	auipc	ra,0xffffd
    80004fe6:	49c080e7          	jalr	1180(ra) # 8000247e <killed>
    80004fea:	e941                	bnez	a0,8000507a <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fec:	85a6                	mv	a1,s1
    80004fee:	854e                	mv	a0,s3
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	1dc080e7          	jalr	476(ra) # 800021cc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ff8:	2184a703          	lw	a4,536(s1)
    80004ffc:	21c4a783          	lw	a5,540(s1)
    80005000:	fcf70de3          	beq	a4,a5,80004fda <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005004:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005006:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005008:	05505363          	blez	s5,8000504e <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000500c:	2184a783          	lw	a5,536(s1)
    80005010:	21c4a703          	lw	a4,540(s1)
    80005014:	02f70d63          	beq	a4,a5,8000504e <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005018:	0017871b          	addiw	a4,a5,1
    8000501c:	20e4ac23          	sw	a4,536(s1)
    80005020:	1ff7f793          	andi	a5,a5,511
    80005024:	97a6                	add	a5,a5,s1
    80005026:	0187c783          	lbu	a5,24(a5)
    8000502a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000502e:	4685                	li	a3,1
    80005030:	fbf40613          	addi	a2,s0,-65
    80005034:	85ca                	mv	a1,s2
    80005036:	050a3503          	ld	a0,80(s4)
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	62e080e7          	jalr	1582(ra) # 80001668 <copyout>
    80005042:	01650663          	beq	a0,s6,8000504e <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005046:	2985                	addiw	s3,s3,1
    80005048:	0905                	addi	s2,s2,1
    8000504a:	fd3a91e3          	bne	s5,s3,8000500c <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000504e:	21c48513          	addi	a0,s1,540
    80005052:	ffffd097          	auipc	ra,0xffffd
    80005056:	1de080e7          	jalr	478(ra) # 80002230 <wakeup>
  release(&pi->lock);
    8000505a:	8526                	mv	a0,s1
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	c2e080e7          	jalr	-978(ra) # 80000c8a <release>
  return i;
}
    80005064:	854e                	mv	a0,s3
    80005066:	60a6                	ld	ra,72(sp)
    80005068:	6406                	ld	s0,64(sp)
    8000506a:	74e2                	ld	s1,56(sp)
    8000506c:	7942                	ld	s2,48(sp)
    8000506e:	79a2                	ld	s3,40(sp)
    80005070:	7a02                	ld	s4,32(sp)
    80005072:	6ae2                	ld	s5,24(sp)
    80005074:	6b42                	ld	s6,16(sp)
    80005076:	6161                	addi	sp,sp,80
    80005078:	8082                	ret
      release(&pi->lock);
    8000507a:	8526                	mv	a0,s1
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>
      return -1;
    80005084:	59fd                	li	s3,-1
    80005086:	bff9                	j	80005064 <piperead+0xc8>

0000000080005088 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005088:	1141                	addi	sp,sp,-16
    8000508a:	e422                	sd	s0,8(sp)
    8000508c:	0800                	addi	s0,sp,16
    8000508e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005090:	8905                	andi	a0,a0,1
    80005092:	c111                	beqz	a0,80005096 <flags2perm+0xe>
      perm = PTE_X;
    80005094:	4521                	li	a0,8
    if(flags & 0x2)
    80005096:	8b89                	andi	a5,a5,2
    80005098:	c399                	beqz	a5,8000509e <flags2perm+0x16>
      perm |= PTE_W;
    8000509a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000509e:	6422                	ld	s0,8(sp)
    800050a0:	0141                	addi	sp,sp,16
    800050a2:	8082                	ret

00000000800050a4 <exec>:

int
exec(char *path, char **argv)
{
    800050a4:	de010113          	addi	sp,sp,-544
    800050a8:	20113c23          	sd	ra,536(sp)
    800050ac:	20813823          	sd	s0,528(sp)
    800050b0:	20913423          	sd	s1,520(sp)
    800050b4:	21213023          	sd	s2,512(sp)
    800050b8:	ffce                	sd	s3,504(sp)
    800050ba:	fbd2                	sd	s4,496(sp)
    800050bc:	f7d6                	sd	s5,488(sp)
    800050be:	f3da                	sd	s6,480(sp)
    800050c0:	efde                	sd	s7,472(sp)
    800050c2:	ebe2                	sd	s8,464(sp)
    800050c4:	e7e6                	sd	s9,456(sp)
    800050c6:	e3ea                	sd	s10,448(sp)
    800050c8:	ff6e                	sd	s11,440(sp)
    800050ca:	1400                	addi	s0,sp,544
    800050cc:	892a                	mv	s2,a0
    800050ce:	dea43423          	sd	a0,-536(s0)
    800050d2:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	8fc080e7          	jalr	-1796(ra) # 800019d2 <myproc>
    800050de:	84aa                	mv	s1,a0

  begin_op();
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	47e080e7          	jalr	1150(ra) # 8000455e <begin_op>

  if((ip = namei(path)) == 0){
    800050e8:	854a                	mv	a0,s2
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	258080e7          	jalr	600(ra) # 80004342 <namei>
    800050f2:	c93d                	beqz	a0,80005168 <exec+0xc4>
    800050f4:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050f6:	fffff097          	auipc	ra,0xfffff
    800050fa:	aa6080e7          	jalr	-1370(ra) # 80003b9c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050fe:	04000713          	li	a4,64
    80005102:	4681                	li	a3,0
    80005104:	e5040613          	addi	a2,s0,-432
    80005108:	4581                	li	a1,0
    8000510a:	8556                	mv	a0,s5
    8000510c:	fffff097          	auipc	ra,0xfffff
    80005110:	d44080e7          	jalr	-700(ra) # 80003e50 <readi>
    80005114:	04000793          	li	a5,64
    80005118:	00f51a63          	bne	a0,a5,8000512c <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000511c:	e5042703          	lw	a4,-432(s0)
    80005120:	464c47b7          	lui	a5,0x464c4
    80005124:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005128:	04f70663          	beq	a4,a5,80005174 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000512c:	8556                	mv	a0,s5
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	cd0080e7          	jalr	-816(ra) # 80003dfe <iunlockput>
    end_op();
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	4a8080e7          	jalr	1192(ra) # 800045de <end_op>
  }
  return -1;
    8000513e:	557d                	li	a0,-1
}
    80005140:	21813083          	ld	ra,536(sp)
    80005144:	21013403          	ld	s0,528(sp)
    80005148:	20813483          	ld	s1,520(sp)
    8000514c:	20013903          	ld	s2,512(sp)
    80005150:	79fe                	ld	s3,504(sp)
    80005152:	7a5e                	ld	s4,496(sp)
    80005154:	7abe                	ld	s5,488(sp)
    80005156:	7b1e                	ld	s6,480(sp)
    80005158:	6bfe                	ld	s7,472(sp)
    8000515a:	6c5e                	ld	s8,464(sp)
    8000515c:	6cbe                	ld	s9,456(sp)
    8000515e:	6d1e                	ld	s10,448(sp)
    80005160:	7dfa                	ld	s11,440(sp)
    80005162:	22010113          	addi	sp,sp,544
    80005166:	8082                	ret
    end_op();
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	476080e7          	jalr	1142(ra) # 800045de <end_op>
    return -1;
    80005170:	557d                	li	a0,-1
    80005172:	b7f9                	j	80005140 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005174:	8526                	mv	a0,s1
    80005176:	ffffd097          	auipc	ra,0xffffd
    8000517a:	920080e7          	jalr	-1760(ra) # 80001a96 <proc_pagetable>
    8000517e:	8b2a                	mv	s6,a0
    80005180:	d555                	beqz	a0,8000512c <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005182:	e7042783          	lw	a5,-400(s0)
    80005186:	e8845703          	lhu	a4,-376(s0)
    8000518a:	c735                	beqz	a4,800051f6 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000518c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000518e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005192:	6a05                	lui	s4,0x1
    80005194:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005198:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000519c:	6d85                	lui	s11,0x1
    8000519e:	7d7d                	lui	s10,0xfffff
    800051a0:	a481                	j	800053e0 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051a2:	00003517          	auipc	a0,0x3
    800051a6:	55e50513          	addi	a0,a0,1374 # 80008700 <syscalls+0x2a8>
    800051aa:	ffffb097          	auipc	ra,0xffffb
    800051ae:	394080e7          	jalr	916(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051b2:	874a                	mv	a4,s2
    800051b4:	009c86bb          	addw	a3,s9,s1
    800051b8:	4581                	li	a1,0
    800051ba:	8556                	mv	a0,s5
    800051bc:	fffff097          	auipc	ra,0xfffff
    800051c0:	c94080e7          	jalr	-876(ra) # 80003e50 <readi>
    800051c4:	2501                	sext.w	a0,a0
    800051c6:	1aa91a63          	bne	s2,a0,8000537a <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800051ca:	009d84bb          	addw	s1,s11,s1
    800051ce:	013d09bb          	addw	s3,s10,s3
    800051d2:	1f74f763          	bgeu	s1,s7,800053c0 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800051d6:	02049593          	slli	a1,s1,0x20
    800051da:	9181                	srli	a1,a1,0x20
    800051dc:	95e2                	add	a1,a1,s8
    800051de:	855a                	mv	a0,s6
    800051e0:	ffffc097          	auipc	ra,0xffffc
    800051e4:	e7c080e7          	jalr	-388(ra) # 8000105c <walkaddr>
    800051e8:	862a                	mv	a2,a0
    if(pa == 0)
    800051ea:	dd45                	beqz	a0,800051a2 <exec+0xfe>
      n = PGSIZE;
    800051ec:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800051ee:	fd49f2e3          	bgeu	s3,s4,800051b2 <exec+0x10e>
      n = sz - i;
    800051f2:	894e                	mv	s2,s3
    800051f4:	bf7d                	j	800051b2 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051f6:	4901                	li	s2,0
  iunlockput(ip);
    800051f8:	8556                	mv	a0,s5
    800051fa:	fffff097          	auipc	ra,0xfffff
    800051fe:	c04080e7          	jalr	-1020(ra) # 80003dfe <iunlockput>
  end_op();
    80005202:	fffff097          	auipc	ra,0xfffff
    80005206:	3dc080e7          	jalr	988(ra) # 800045de <end_op>
  p = myproc();
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	7c8080e7          	jalr	1992(ra) # 800019d2 <myproc>
    80005212:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005214:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005218:	6785                	lui	a5,0x1
    8000521a:	17fd                	addi	a5,a5,-1
    8000521c:	993e                	add	s2,s2,a5
    8000521e:	77fd                	lui	a5,0xfffff
    80005220:	00f977b3          	and	a5,s2,a5
    80005224:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005228:	4691                	li	a3,4
    8000522a:	6609                	lui	a2,0x2
    8000522c:	963e                	add	a2,a2,a5
    8000522e:	85be                	mv	a1,a5
    80005230:	855a                	mv	a0,s6
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	1de080e7          	jalr	478(ra) # 80001410 <uvmalloc>
    8000523a:	8c2a                	mv	s8,a0
  ip = 0;
    8000523c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000523e:	12050e63          	beqz	a0,8000537a <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005242:	75f9                	lui	a1,0xffffe
    80005244:	95aa                	add	a1,a1,a0
    80005246:	855a                	mv	a0,s6
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	3ee080e7          	jalr	1006(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005250:	7afd                	lui	s5,0xfffff
    80005252:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005254:	df043783          	ld	a5,-528(s0)
    80005258:	6388                	ld	a0,0(a5)
    8000525a:	c925                	beqz	a0,800052ca <exec+0x226>
    8000525c:	e9040993          	addi	s3,s0,-368
    80005260:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005264:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005266:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	be6080e7          	jalr	-1050(ra) # 80000e4e <strlen>
    80005270:	0015079b          	addiw	a5,a0,1
    80005274:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005278:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000527c:	13596663          	bltu	s2,s5,800053a8 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005280:	df043d83          	ld	s11,-528(s0)
    80005284:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005288:	8552                	mv	a0,s4
    8000528a:	ffffc097          	auipc	ra,0xffffc
    8000528e:	bc4080e7          	jalr	-1084(ra) # 80000e4e <strlen>
    80005292:	0015069b          	addiw	a3,a0,1
    80005296:	8652                	mv	a2,s4
    80005298:	85ca                	mv	a1,s2
    8000529a:	855a                	mv	a0,s6
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	3cc080e7          	jalr	972(ra) # 80001668 <copyout>
    800052a4:	10054663          	bltz	a0,800053b0 <exec+0x30c>
    ustack[argc] = sp;
    800052a8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052ac:	0485                	addi	s1,s1,1
    800052ae:	008d8793          	addi	a5,s11,8
    800052b2:	def43823          	sd	a5,-528(s0)
    800052b6:	008db503          	ld	a0,8(s11)
    800052ba:	c911                	beqz	a0,800052ce <exec+0x22a>
    if(argc >= MAXARG)
    800052bc:	09a1                	addi	s3,s3,8
    800052be:	fb3c95e3          	bne	s9,s3,80005268 <exec+0x1c4>
  sz = sz1;
    800052c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052c6:	4a81                	li	s5,0
    800052c8:	a84d                	j	8000537a <exec+0x2d6>
  sp = sz;
    800052ca:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052cc:	4481                	li	s1,0
  ustack[argc] = 0;
    800052ce:	00349793          	slli	a5,s1,0x3
    800052d2:	f9040713          	addi	a4,s0,-112
    800052d6:	97ba                	add	a5,a5,a4
    800052d8:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffd9d10>
  sp -= (argc+1) * sizeof(uint64);
    800052dc:	00148693          	addi	a3,s1,1
    800052e0:	068e                	slli	a3,a3,0x3
    800052e2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052e6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800052ea:	01597663          	bgeu	s2,s5,800052f6 <exec+0x252>
  sz = sz1;
    800052ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052f2:	4a81                	li	s5,0
    800052f4:	a059                	j	8000537a <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052f6:	e9040613          	addi	a2,s0,-368
    800052fa:	85ca                	mv	a1,s2
    800052fc:	855a                	mv	a0,s6
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	36a080e7          	jalr	874(ra) # 80001668 <copyout>
    80005306:	0a054963          	bltz	a0,800053b8 <exec+0x314>
  p->trapframe->a1 = sp;
    8000530a:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000530e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005312:	de843783          	ld	a5,-536(s0)
    80005316:	0007c703          	lbu	a4,0(a5)
    8000531a:	cf11                	beqz	a4,80005336 <exec+0x292>
    8000531c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000531e:	02f00693          	li	a3,47
    80005322:	a039                	j	80005330 <exec+0x28c>
      last = s+1;
    80005324:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005328:	0785                	addi	a5,a5,1
    8000532a:	fff7c703          	lbu	a4,-1(a5)
    8000532e:	c701                	beqz	a4,80005336 <exec+0x292>
    if(*s == '/')
    80005330:	fed71ce3          	bne	a4,a3,80005328 <exec+0x284>
    80005334:	bfc5                	j	80005324 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005336:	4641                	li	a2,16
    80005338:	de843583          	ld	a1,-536(s0)
    8000533c:	158b8513          	addi	a0,s7,344
    80005340:	ffffc097          	auipc	ra,0xffffc
    80005344:	adc080e7          	jalr	-1316(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005348:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000534c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005350:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005354:	058bb783          	ld	a5,88(s7)
    80005358:	e6843703          	ld	a4,-408(s0)
    8000535c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000535e:	058bb783          	ld	a5,88(s7)
    80005362:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005366:	85ea                	mv	a1,s10
    80005368:	ffffc097          	auipc	ra,0xffffc
    8000536c:	7ca080e7          	jalr	1994(ra) # 80001b32 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005370:	0004851b          	sext.w	a0,s1
    80005374:	b3f1                	j	80005140 <exec+0x9c>
    80005376:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000537a:	df843583          	ld	a1,-520(s0)
    8000537e:	855a                	mv	a0,s6
    80005380:	ffffc097          	auipc	ra,0xffffc
    80005384:	7b2080e7          	jalr	1970(ra) # 80001b32 <proc_freepagetable>
  if(ip){
    80005388:	da0a92e3          	bnez	s5,8000512c <exec+0x88>
  return -1;
    8000538c:	557d                	li	a0,-1
    8000538e:	bb4d                	j	80005140 <exec+0x9c>
    80005390:	df243c23          	sd	s2,-520(s0)
    80005394:	b7dd                	j	8000537a <exec+0x2d6>
    80005396:	df243c23          	sd	s2,-520(s0)
    8000539a:	b7c5                	j	8000537a <exec+0x2d6>
    8000539c:	df243c23          	sd	s2,-520(s0)
    800053a0:	bfe9                	j	8000537a <exec+0x2d6>
    800053a2:	df243c23          	sd	s2,-520(s0)
    800053a6:	bfd1                	j	8000537a <exec+0x2d6>
  sz = sz1;
    800053a8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ac:	4a81                	li	s5,0
    800053ae:	b7f1                	j	8000537a <exec+0x2d6>
  sz = sz1;
    800053b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053b4:	4a81                	li	s5,0
    800053b6:	b7d1                	j	8000537a <exec+0x2d6>
  sz = sz1;
    800053b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053bc:	4a81                	li	s5,0
    800053be:	bf75                	j	8000537a <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053c0:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053c4:	e0843783          	ld	a5,-504(s0)
    800053c8:	0017869b          	addiw	a3,a5,1
    800053cc:	e0d43423          	sd	a3,-504(s0)
    800053d0:	e0043783          	ld	a5,-512(s0)
    800053d4:	0387879b          	addiw	a5,a5,56
    800053d8:	e8845703          	lhu	a4,-376(s0)
    800053dc:	e0e6dee3          	bge	a3,a4,800051f8 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053e0:	2781                	sext.w	a5,a5
    800053e2:	e0f43023          	sd	a5,-512(s0)
    800053e6:	03800713          	li	a4,56
    800053ea:	86be                	mv	a3,a5
    800053ec:	e1840613          	addi	a2,s0,-488
    800053f0:	4581                	li	a1,0
    800053f2:	8556                	mv	a0,s5
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	a5c080e7          	jalr	-1444(ra) # 80003e50 <readi>
    800053fc:	03800793          	li	a5,56
    80005400:	f6f51be3          	bne	a0,a5,80005376 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005404:	e1842783          	lw	a5,-488(s0)
    80005408:	4705                	li	a4,1
    8000540a:	fae79de3          	bne	a5,a4,800053c4 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000540e:	e4043483          	ld	s1,-448(s0)
    80005412:	e3843783          	ld	a5,-456(s0)
    80005416:	f6f4ede3          	bltu	s1,a5,80005390 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000541a:	e2843783          	ld	a5,-472(s0)
    8000541e:	94be                	add	s1,s1,a5
    80005420:	f6f4ebe3          	bltu	s1,a5,80005396 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005424:	de043703          	ld	a4,-544(s0)
    80005428:	8ff9                	and	a5,a5,a4
    8000542a:	fbad                	bnez	a5,8000539c <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000542c:	e1c42503          	lw	a0,-484(s0)
    80005430:	00000097          	auipc	ra,0x0
    80005434:	c58080e7          	jalr	-936(ra) # 80005088 <flags2perm>
    80005438:	86aa                	mv	a3,a0
    8000543a:	8626                	mv	a2,s1
    8000543c:	85ca                	mv	a1,s2
    8000543e:	855a                	mv	a0,s6
    80005440:	ffffc097          	auipc	ra,0xffffc
    80005444:	fd0080e7          	jalr	-48(ra) # 80001410 <uvmalloc>
    80005448:	dea43c23          	sd	a0,-520(s0)
    8000544c:	d939                	beqz	a0,800053a2 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000544e:	e2843c03          	ld	s8,-472(s0)
    80005452:	e2042c83          	lw	s9,-480(s0)
    80005456:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000545a:	f60b83e3          	beqz	s7,800053c0 <exec+0x31c>
    8000545e:	89de                	mv	s3,s7
    80005460:	4481                	li	s1,0
    80005462:	bb95                	j	800051d6 <exec+0x132>

0000000080005464 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005464:	7179                	addi	sp,sp,-48
    80005466:	f406                	sd	ra,40(sp)
    80005468:	f022                	sd	s0,32(sp)
    8000546a:	ec26                	sd	s1,24(sp)
    8000546c:	e84a                	sd	s2,16(sp)
    8000546e:	1800                	addi	s0,sp,48
    80005470:	892e                	mv	s2,a1
    80005472:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005474:	fdc40593          	addi	a1,s0,-36
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	9e4080e7          	jalr	-1564(ra) # 80002e5c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005480:	fdc42703          	lw	a4,-36(s0)
    80005484:	47bd                	li	a5,15
    80005486:	02e7eb63          	bltu	a5,a4,800054bc <argfd+0x58>
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	548080e7          	jalr	1352(ra) # 800019d2 <myproc>
    80005492:	fdc42703          	lw	a4,-36(s0)
    80005496:	01a70793          	addi	a5,a4,26
    8000549a:	078e                	slli	a5,a5,0x3
    8000549c:	953e                	add	a0,a0,a5
    8000549e:	611c                	ld	a5,0(a0)
    800054a0:	c385                	beqz	a5,800054c0 <argfd+0x5c>
    return -1;
  if(pfd)
    800054a2:	00090463          	beqz	s2,800054aa <argfd+0x46>
    *pfd = fd;
    800054a6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054aa:	4501                	li	a0,0
  if(pf)
    800054ac:	c091                	beqz	s1,800054b0 <argfd+0x4c>
    *pf = f;
    800054ae:	e09c                	sd	a5,0(s1)
}
    800054b0:	70a2                	ld	ra,40(sp)
    800054b2:	7402                	ld	s0,32(sp)
    800054b4:	64e2                	ld	s1,24(sp)
    800054b6:	6942                	ld	s2,16(sp)
    800054b8:	6145                	addi	sp,sp,48
    800054ba:	8082                	ret
    return -1;
    800054bc:	557d                	li	a0,-1
    800054be:	bfcd                	j	800054b0 <argfd+0x4c>
    800054c0:	557d                	li	a0,-1
    800054c2:	b7fd                	j	800054b0 <argfd+0x4c>

00000000800054c4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054c4:	1101                	addi	sp,sp,-32
    800054c6:	ec06                	sd	ra,24(sp)
    800054c8:	e822                	sd	s0,16(sp)
    800054ca:	e426                	sd	s1,8(sp)
    800054cc:	1000                	addi	s0,sp,32
    800054ce:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054d0:	ffffc097          	auipc	ra,0xffffc
    800054d4:	502080e7          	jalr	1282(ra) # 800019d2 <myproc>
    800054d8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054da:	0d050793          	addi	a5,a0,208
    800054de:	4501                	li	a0,0
    800054e0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054e2:	6398                	ld	a4,0(a5)
    800054e4:	cb19                	beqz	a4,800054fa <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054e6:	2505                	addiw	a0,a0,1
    800054e8:	07a1                	addi	a5,a5,8
    800054ea:	fed51ce3          	bne	a0,a3,800054e2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054ee:	557d                	li	a0,-1
}
    800054f0:	60e2                	ld	ra,24(sp)
    800054f2:	6442                	ld	s0,16(sp)
    800054f4:	64a2                	ld	s1,8(sp)
    800054f6:	6105                	addi	sp,sp,32
    800054f8:	8082                	ret
      p->ofile[fd] = f;
    800054fa:	01a50793          	addi	a5,a0,26
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	963e                	add	a2,a2,a5
    80005502:	e204                	sd	s1,0(a2)
      return fd;
    80005504:	b7f5                	j	800054f0 <fdalloc+0x2c>

0000000080005506 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005506:	715d                	addi	sp,sp,-80
    80005508:	e486                	sd	ra,72(sp)
    8000550a:	e0a2                	sd	s0,64(sp)
    8000550c:	fc26                	sd	s1,56(sp)
    8000550e:	f84a                	sd	s2,48(sp)
    80005510:	f44e                	sd	s3,40(sp)
    80005512:	f052                	sd	s4,32(sp)
    80005514:	ec56                	sd	s5,24(sp)
    80005516:	e85a                	sd	s6,16(sp)
    80005518:	0880                	addi	s0,sp,80
    8000551a:	8b2e                	mv	s6,a1
    8000551c:	89b2                	mv	s3,a2
    8000551e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005520:	fb040593          	addi	a1,s0,-80
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	e3c080e7          	jalr	-452(ra) # 80004360 <nameiparent>
    8000552c:	84aa                	mv	s1,a0
    8000552e:	14050f63          	beqz	a0,8000568c <create+0x186>
    return 0;

  ilock(dp);
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	66a080e7          	jalr	1642(ra) # 80003b9c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000553a:	4601                	li	a2,0
    8000553c:	fb040593          	addi	a1,s0,-80
    80005540:	8526                	mv	a0,s1
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	b3e080e7          	jalr	-1218(ra) # 80004080 <dirlookup>
    8000554a:	8aaa                	mv	s5,a0
    8000554c:	c931                	beqz	a0,800055a0 <create+0x9a>
    iunlockput(dp);
    8000554e:	8526                	mv	a0,s1
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	8ae080e7          	jalr	-1874(ra) # 80003dfe <iunlockput>
    ilock(ip);
    80005558:	8556                	mv	a0,s5
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	642080e7          	jalr	1602(ra) # 80003b9c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005562:	000b059b          	sext.w	a1,s6
    80005566:	4789                	li	a5,2
    80005568:	02f59563          	bne	a1,a5,80005592 <create+0x8c>
    8000556c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd9e54>
    80005570:	37f9                	addiw	a5,a5,-2
    80005572:	17c2                	slli	a5,a5,0x30
    80005574:	93c1                	srli	a5,a5,0x30
    80005576:	4705                	li	a4,1
    80005578:	00f76d63          	bltu	a4,a5,80005592 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000557c:	8556                	mv	a0,s5
    8000557e:	60a6                	ld	ra,72(sp)
    80005580:	6406                	ld	s0,64(sp)
    80005582:	74e2                	ld	s1,56(sp)
    80005584:	7942                	ld	s2,48(sp)
    80005586:	79a2                	ld	s3,40(sp)
    80005588:	7a02                	ld	s4,32(sp)
    8000558a:	6ae2                	ld	s5,24(sp)
    8000558c:	6b42                	ld	s6,16(sp)
    8000558e:	6161                	addi	sp,sp,80
    80005590:	8082                	ret
    iunlockput(ip);
    80005592:	8556                	mv	a0,s5
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	86a080e7          	jalr	-1942(ra) # 80003dfe <iunlockput>
    return 0;
    8000559c:	4a81                	li	s5,0
    8000559e:	bff9                	j	8000557c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055a0:	85da                	mv	a1,s6
    800055a2:	4088                	lw	a0,0(s1)
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	45c080e7          	jalr	1116(ra) # 80003a00 <ialloc>
    800055ac:	8a2a                	mv	s4,a0
    800055ae:	c539                	beqz	a0,800055fc <create+0xf6>
  ilock(ip);
    800055b0:	ffffe097          	auipc	ra,0xffffe
    800055b4:	5ec080e7          	jalr	1516(ra) # 80003b9c <ilock>
  ip->major = major;
    800055b8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055bc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800055c0:	4905                	li	s2,1
    800055c2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800055c6:	8552                	mv	a0,s4
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	50a080e7          	jalr	1290(ra) # 80003ad2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055d0:	000b059b          	sext.w	a1,s6
    800055d4:	03258b63          	beq	a1,s2,8000560a <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800055d8:	004a2603          	lw	a2,4(s4)
    800055dc:	fb040593          	addi	a1,s0,-80
    800055e0:	8526                	mv	a0,s1
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	cae080e7          	jalr	-850(ra) # 80004290 <dirlink>
    800055ea:	06054f63          	bltz	a0,80005668 <create+0x162>
  iunlockput(dp);
    800055ee:	8526                	mv	a0,s1
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	80e080e7          	jalr	-2034(ra) # 80003dfe <iunlockput>
  return ip;
    800055f8:	8ad2                	mv	s5,s4
    800055fa:	b749                	j	8000557c <create+0x76>
    iunlockput(dp);
    800055fc:	8526                	mv	a0,s1
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	800080e7          	jalr	-2048(ra) # 80003dfe <iunlockput>
    return 0;
    80005606:	8ad2                	mv	s5,s4
    80005608:	bf95                	j	8000557c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000560a:	004a2603          	lw	a2,4(s4)
    8000560e:	00003597          	auipc	a1,0x3
    80005612:	11258593          	addi	a1,a1,274 # 80008720 <syscalls+0x2c8>
    80005616:	8552                	mv	a0,s4
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	c78080e7          	jalr	-904(ra) # 80004290 <dirlink>
    80005620:	04054463          	bltz	a0,80005668 <create+0x162>
    80005624:	40d0                	lw	a2,4(s1)
    80005626:	00003597          	auipc	a1,0x3
    8000562a:	10258593          	addi	a1,a1,258 # 80008728 <syscalls+0x2d0>
    8000562e:	8552                	mv	a0,s4
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	c60080e7          	jalr	-928(ra) # 80004290 <dirlink>
    80005638:	02054863          	bltz	a0,80005668 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000563c:	004a2603          	lw	a2,4(s4)
    80005640:	fb040593          	addi	a1,s0,-80
    80005644:	8526                	mv	a0,s1
    80005646:	fffff097          	auipc	ra,0xfffff
    8000564a:	c4a080e7          	jalr	-950(ra) # 80004290 <dirlink>
    8000564e:	00054d63          	bltz	a0,80005668 <create+0x162>
    dp->nlink++;  // for ".."
    80005652:	04a4d783          	lhu	a5,74(s1)
    80005656:	2785                	addiw	a5,a5,1
    80005658:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000565c:	8526                	mv	a0,s1
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	474080e7          	jalr	1140(ra) # 80003ad2 <iupdate>
    80005666:	b761                	j	800055ee <create+0xe8>
  ip->nlink = 0;
    80005668:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000566c:	8552                	mv	a0,s4
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	464080e7          	jalr	1124(ra) # 80003ad2 <iupdate>
  iunlockput(ip);
    80005676:	8552                	mv	a0,s4
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	786080e7          	jalr	1926(ra) # 80003dfe <iunlockput>
  iunlockput(dp);
    80005680:	8526                	mv	a0,s1
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	77c080e7          	jalr	1916(ra) # 80003dfe <iunlockput>
  return 0;
    8000568a:	bdcd                	j	8000557c <create+0x76>
    return 0;
    8000568c:	8aaa                	mv	s5,a0
    8000568e:	b5fd                	j	8000557c <create+0x76>

0000000080005690 <sys_dup>:
{
    80005690:	7179                	addi	sp,sp,-48
    80005692:	f406                	sd	ra,40(sp)
    80005694:	f022                	sd	s0,32(sp)
    80005696:	ec26                	sd	s1,24(sp)
    80005698:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000569a:	fd840613          	addi	a2,s0,-40
    8000569e:	4581                	li	a1,0
    800056a0:	4501                	li	a0,0
    800056a2:	00000097          	auipc	ra,0x0
    800056a6:	dc2080e7          	jalr	-574(ra) # 80005464 <argfd>
    return -1;
    800056aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056ac:	02054363          	bltz	a0,800056d2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056b0:	fd843503          	ld	a0,-40(s0)
    800056b4:	00000097          	auipc	ra,0x0
    800056b8:	e10080e7          	jalr	-496(ra) # 800054c4 <fdalloc>
    800056bc:	84aa                	mv	s1,a0
    return -1;
    800056be:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056c0:	00054963          	bltz	a0,800056d2 <sys_dup+0x42>
  filedup(f);
    800056c4:	fd843503          	ld	a0,-40(s0)
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	310080e7          	jalr	784(ra) # 800049d8 <filedup>
  return fd;
    800056d0:	87a6                	mv	a5,s1
}
    800056d2:	853e                	mv	a0,a5
    800056d4:	70a2                	ld	ra,40(sp)
    800056d6:	7402                	ld	s0,32(sp)
    800056d8:	64e2                	ld	s1,24(sp)
    800056da:	6145                	addi	sp,sp,48
    800056dc:	8082                	ret

00000000800056de <sys_read>:
{
    800056de:	7179                	addi	sp,sp,-48
    800056e0:	f406                	sd	ra,40(sp)
    800056e2:	f022                	sd	s0,32(sp)
    800056e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056e6:	fd840593          	addi	a1,s0,-40
    800056ea:	4505                	li	a0,1
    800056ec:	ffffd097          	auipc	ra,0xffffd
    800056f0:	790080e7          	jalr	1936(ra) # 80002e7c <argaddr>
  argint(2, &n);
    800056f4:	fe440593          	addi	a1,s0,-28
    800056f8:	4509                	li	a0,2
    800056fa:	ffffd097          	auipc	ra,0xffffd
    800056fe:	762080e7          	jalr	1890(ra) # 80002e5c <argint>
  if(argfd(0, 0, &f) < 0)
    80005702:	fe840613          	addi	a2,s0,-24
    80005706:	4581                	li	a1,0
    80005708:	4501                	li	a0,0
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	d5a080e7          	jalr	-678(ra) # 80005464 <argfd>
    80005712:	87aa                	mv	a5,a0
    return -1;
    80005714:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005716:	0007cc63          	bltz	a5,8000572e <sys_read+0x50>
  return fileread(f, p, n);
    8000571a:	fe442603          	lw	a2,-28(s0)
    8000571e:	fd843583          	ld	a1,-40(s0)
    80005722:	fe843503          	ld	a0,-24(s0)
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	43e080e7          	jalr	1086(ra) # 80004b64 <fileread>
}
    8000572e:	70a2                	ld	ra,40(sp)
    80005730:	7402                	ld	s0,32(sp)
    80005732:	6145                	addi	sp,sp,48
    80005734:	8082                	ret

0000000080005736 <sys_write>:
{
    80005736:	7179                	addi	sp,sp,-48
    80005738:	f406                	sd	ra,40(sp)
    8000573a:	f022                	sd	s0,32(sp)
    8000573c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000573e:	fd840593          	addi	a1,s0,-40
    80005742:	4505                	li	a0,1
    80005744:	ffffd097          	auipc	ra,0xffffd
    80005748:	738080e7          	jalr	1848(ra) # 80002e7c <argaddr>
  argint(2, &n);
    8000574c:	fe440593          	addi	a1,s0,-28
    80005750:	4509                	li	a0,2
    80005752:	ffffd097          	auipc	ra,0xffffd
    80005756:	70a080e7          	jalr	1802(ra) # 80002e5c <argint>
  if(argfd(0, 0, &f) < 0)
    8000575a:	fe840613          	addi	a2,s0,-24
    8000575e:	4581                	li	a1,0
    80005760:	4501                	li	a0,0
    80005762:	00000097          	auipc	ra,0x0
    80005766:	d02080e7          	jalr	-766(ra) # 80005464 <argfd>
    8000576a:	87aa                	mv	a5,a0
    return -1;
    8000576c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000576e:	0007cc63          	bltz	a5,80005786 <sys_write+0x50>
  return filewrite(f, p, n);
    80005772:	fe442603          	lw	a2,-28(s0)
    80005776:	fd843583          	ld	a1,-40(s0)
    8000577a:	fe843503          	ld	a0,-24(s0)
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	4a8080e7          	jalr	1192(ra) # 80004c26 <filewrite>
}
    80005786:	70a2                	ld	ra,40(sp)
    80005788:	7402                	ld	s0,32(sp)
    8000578a:	6145                	addi	sp,sp,48
    8000578c:	8082                	ret

000000008000578e <sys_close>:
{
    8000578e:	1101                	addi	sp,sp,-32
    80005790:	ec06                	sd	ra,24(sp)
    80005792:	e822                	sd	s0,16(sp)
    80005794:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005796:	fe040613          	addi	a2,s0,-32
    8000579a:	fec40593          	addi	a1,s0,-20
    8000579e:	4501                	li	a0,0
    800057a0:	00000097          	auipc	ra,0x0
    800057a4:	cc4080e7          	jalr	-828(ra) # 80005464 <argfd>
    return -1;
    800057a8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057aa:	02054463          	bltz	a0,800057d2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057ae:	ffffc097          	auipc	ra,0xffffc
    800057b2:	224080e7          	jalr	548(ra) # 800019d2 <myproc>
    800057b6:	fec42783          	lw	a5,-20(s0)
    800057ba:	07e9                	addi	a5,a5,26
    800057bc:	078e                	slli	a5,a5,0x3
    800057be:	97aa                	add	a5,a5,a0
    800057c0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800057c4:	fe043503          	ld	a0,-32(s0)
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	262080e7          	jalr	610(ra) # 80004a2a <fileclose>
  return 0;
    800057d0:	4781                	li	a5,0
}
    800057d2:	853e                	mv	a0,a5
    800057d4:	60e2                	ld	ra,24(sp)
    800057d6:	6442                	ld	s0,16(sp)
    800057d8:	6105                	addi	sp,sp,32
    800057da:	8082                	ret

00000000800057dc <sys_fstat>:
{
    800057dc:	1101                	addi	sp,sp,-32
    800057de:	ec06                	sd	ra,24(sp)
    800057e0:	e822                	sd	s0,16(sp)
    800057e2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057e4:	fe040593          	addi	a1,s0,-32
    800057e8:	4505                	li	a0,1
    800057ea:	ffffd097          	auipc	ra,0xffffd
    800057ee:	692080e7          	jalr	1682(ra) # 80002e7c <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057f2:	fe840613          	addi	a2,s0,-24
    800057f6:	4581                	li	a1,0
    800057f8:	4501                	li	a0,0
    800057fa:	00000097          	auipc	ra,0x0
    800057fe:	c6a080e7          	jalr	-918(ra) # 80005464 <argfd>
    80005802:	87aa                	mv	a5,a0
    return -1;
    80005804:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005806:	0007ca63          	bltz	a5,8000581a <sys_fstat+0x3e>
  return filestat(f, st);
    8000580a:	fe043583          	ld	a1,-32(s0)
    8000580e:	fe843503          	ld	a0,-24(s0)
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	2e0080e7          	jalr	736(ra) # 80004af2 <filestat>
}
    8000581a:	60e2                	ld	ra,24(sp)
    8000581c:	6442                	ld	s0,16(sp)
    8000581e:	6105                	addi	sp,sp,32
    80005820:	8082                	ret

0000000080005822 <sys_link>:
{
    80005822:	7169                	addi	sp,sp,-304
    80005824:	f606                	sd	ra,296(sp)
    80005826:	f222                	sd	s0,288(sp)
    80005828:	ee26                	sd	s1,280(sp)
    8000582a:	ea4a                	sd	s2,272(sp)
    8000582c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000582e:	08000613          	li	a2,128
    80005832:	ed040593          	addi	a1,s0,-304
    80005836:	4501                	li	a0,0
    80005838:	ffffd097          	auipc	ra,0xffffd
    8000583c:	664080e7          	jalr	1636(ra) # 80002e9c <argstr>
    return -1;
    80005840:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005842:	10054e63          	bltz	a0,8000595e <sys_link+0x13c>
    80005846:	08000613          	li	a2,128
    8000584a:	f5040593          	addi	a1,s0,-176
    8000584e:	4505                	li	a0,1
    80005850:	ffffd097          	auipc	ra,0xffffd
    80005854:	64c080e7          	jalr	1612(ra) # 80002e9c <argstr>
    return -1;
    80005858:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000585a:	10054263          	bltz	a0,8000595e <sys_link+0x13c>
  begin_op();
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	d00080e7          	jalr	-768(ra) # 8000455e <begin_op>
  if((ip = namei(old)) == 0){
    80005866:	ed040513          	addi	a0,s0,-304
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	ad8080e7          	jalr	-1320(ra) # 80004342 <namei>
    80005872:	84aa                	mv	s1,a0
    80005874:	c551                	beqz	a0,80005900 <sys_link+0xde>
  ilock(ip);
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	326080e7          	jalr	806(ra) # 80003b9c <ilock>
  if(ip->type == T_DIR){
    8000587e:	04449703          	lh	a4,68(s1)
    80005882:	4785                	li	a5,1
    80005884:	08f70463          	beq	a4,a5,8000590c <sys_link+0xea>
  ip->nlink++;
    80005888:	04a4d783          	lhu	a5,74(s1)
    8000588c:	2785                	addiw	a5,a5,1
    8000588e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005892:	8526                	mv	a0,s1
    80005894:	ffffe097          	auipc	ra,0xffffe
    80005898:	23e080e7          	jalr	574(ra) # 80003ad2 <iupdate>
  iunlock(ip);
    8000589c:	8526                	mv	a0,s1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	3c0080e7          	jalr	960(ra) # 80003c5e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058a6:	fd040593          	addi	a1,s0,-48
    800058aa:	f5040513          	addi	a0,s0,-176
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	ab2080e7          	jalr	-1358(ra) # 80004360 <nameiparent>
    800058b6:	892a                	mv	s2,a0
    800058b8:	c935                	beqz	a0,8000592c <sys_link+0x10a>
  ilock(dp);
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	2e2080e7          	jalr	738(ra) # 80003b9c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058c2:	00092703          	lw	a4,0(s2)
    800058c6:	409c                	lw	a5,0(s1)
    800058c8:	04f71d63          	bne	a4,a5,80005922 <sys_link+0x100>
    800058cc:	40d0                	lw	a2,4(s1)
    800058ce:	fd040593          	addi	a1,s0,-48
    800058d2:	854a                	mv	a0,s2
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	9bc080e7          	jalr	-1604(ra) # 80004290 <dirlink>
    800058dc:	04054363          	bltz	a0,80005922 <sys_link+0x100>
  iunlockput(dp);
    800058e0:	854a                	mv	a0,s2
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	51c080e7          	jalr	1308(ra) # 80003dfe <iunlockput>
  iput(ip);
    800058ea:	8526                	mv	a0,s1
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	46a080e7          	jalr	1130(ra) # 80003d56 <iput>
  end_op();
    800058f4:	fffff097          	auipc	ra,0xfffff
    800058f8:	cea080e7          	jalr	-790(ra) # 800045de <end_op>
  return 0;
    800058fc:	4781                	li	a5,0
    800058fe:	a085                	j	8000595e <sys_link+0x13c>
    end_op();
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	cde080e7          	jalr	-802(ra) # 800045de <end_op>
    return -1;
    80005908:	57fd                	li	a5,-1
    8000590a:	a891                	j	8000595e <sys_link+0x13c>
    iunlockput(ip);
    8000590c:	8526                	mv	a0,s1
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	4f0080e7          	jalr	1264(ra) # 80003dfe <iunlockput>
    end_op();
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	cc8080e7          	jalr	-824(ra) # 800045de <end_op>
    return -1;
    8000591e:	57fd                	li	a5,-1
    80005920:	a83d                	j	8000595e <sys_link+0x13c>
    iunlockput(dp);
    80005922:	854a                	mv	a0,s2
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	4da080e7          	jalr	1242(ra) # 80003dfe <iunlockput>
  ilock(ip);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	26e080e7          	jalr	622(ra) # 80003b9c <ilock>
  ip->nlink--;
    80005936:	04a4d783          	lhu	a5,74(s1)
    8000593a:	37fd                	addiw	a5,a5,-1
    8000593c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005940:	8526                	mv	a0,s1
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	190080e7          	jalr	400(ra) # 80003ad2 <iupdate>
  iunlockput(ip);
    8000594a:	8526                	mv	a0,s1
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	4b2080e7          	jalr	1202(ra) # 80003dfe <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	c8a080e7          	jalr	-886(ra) # 800045de <end_op>
  return -1;
    8000595c:	57fd                	li	a5,-1
}
    8000595e:	853e                	mv	a0,a5
    80005960:	70b2                	ld	ra,296(sp)
    80005962:	7412                	ld	s0,288(sp)
    80005964:	64f2                	ld	s1,280(sp)
    80005966:	6952                	ld	s2,272(sp)
    80005968:	6155                	addi	sp,sp,304
    8000596a:	8082                	ret

000000008000596c <sys_unlink>:
{
    8000596c:	7151                	addi	sp,sp,-240
    8000596e:	f586                	sd	ra,232(sp)
    80005970:	f1a2                	sd	s0,224(sp)
    80005972:	eda6                	sd	s1,216(sp)
    80005974:	e9ca                	sd	s2,208(sp)
    80005976:	e5ce                	sd	s3,200(sp)
    80005978:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000597a:	08000613          	li	a2,128
    8000597e:	f3040593          	addi	a1,s0,-208
    80005982:	4501                	li	a0,0
    80005984:	ffffd097          	auipc	ra,0xffffd
    80005988:	518080e7          	jalr	1304(ra) # 80002e9c <argstr>
    8000598c:	18054163          	bltz	a0,80005b0e <sys_unlink+0x1a2>
  begin_op();
    80005990:	fffff097          	auipc	ra,0xfffff
    80005994:	bce080e7          	jalr	-1074(ra) # 8000455e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005998:	fb040593          	addi	a1,s0,-80
    8000599c:	f3040513          	addi	a0,s0,-208
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	9c0080e7          	jalr	-1600(ra) # 80004360 <nameiparent>
    800059a8:	84aa                	mv	s1,a0
    800059aa:	c979                	beqz	a0,80005a80 <sys_unlink+0x114>
  ilock(dp);
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	1f0080e7          	jalr	496(ra) # 80003b9c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059b4:	00003597          	auipc	a1,0x3
    800059b8:	d6c58593          	addi	a1,a1,-660 # 80008720 <syscalls+0x2c8>
    800059bc:	fb040513          	addi	a0,s0,-80
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	6a6080e7          	jalr	1702(ra) # 80004066 <namecmp>
    800059c8:	14050a63          	beqz	a0,80005b1c <sys_unlink+0x1b0>
    800059cc:	00003597          	auipc	a1,0x3
    800059d0:	d5c58593          	addi	a1,a1,-676 # 80008728 <syscalls+0x2d0>
    800059d4:	fb040513          	addi	a0,s0,-80
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	68e080e7          	jalr	1678(ra) # 80004066 <namecmp>
    800059e0:	12050e63          	beqz	a0,80005b1c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059e4:	f2c40613          	addi	a2,s0,-212
    800059e8:	fb040593          	addi	a1,s0,-80
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	692080e7          	jalr	1682(ra) # 80004080 <dirlookup>
    800059f6:	892a                	mv	s2,a0
    800059f8:	12050263          	beqz	a0,80005b1c <sys_unlink+0x1b0>
  ilock(ip);
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	1a0080e7          	jalr	416(ra) # 80003b9c <ilock>
  if(ip->nlink < 1)
    80005a04:	04a91783          	lh	a5,74(s2)
    80005a08:	08f05263          	blez	a5,80005a8c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a0c:	04491703          	lh	a4,68(s2)
    80005a10:	4785                	li	a5,1
    80005a12:	08f70563          	beq	a4,a5,80005a9c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a16:	4641                	li	a2,16
    80005a18:	4581                	li	a1,0
    80005a1a:	fc040513          	addi	a0,s0,-64
    80005a1e:	ffffb097          	auipc	ra,0xffffb
    80005a22:	2b4080e7          	jalr	692(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a26:	4741                	li	a4,16
    80005a28:	f2c42683          	lw	a3,-212(s0)
    80005a2c:	fc040613          	addi	a2,s0,-64
    80005a30:	4581                	li	a1,0
    80005a32:	8526                	mv	a0,s1
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	514080e7          	jalr	1300(ra) # 80003f48 <writei>
    80005a3c:	47c1                	li	a5,16
    80005a3e:	0af51563          	bne	a0,a5,80005ae8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a42:	04491703          	lh	a4,68(s2)
    80005a46:	4785                	li	a5,1
    80005a48:	0af70863          	beq	a4,a5,80005af8 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	3b0080e7          	jalr	944(ra) # 80003dfe <iunlockput>
  ip->nlink--;
    80005a56:	04a95783          	lhu	a5,74(s2)
    80005a5a:	37fd                	addiw	a5,a5,-1
    80005a5c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a60:	854a                	mv	a0,s2
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	070080e7          	jalr	112(ra) # 80003ad2 <iupdate>
  iunlockput(ip);
    80005a6a:	854a                	mv	a0,s2
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	392080e7          	jalr	914(ra) # 80003dfe <iunlockput>
  end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	b6a080e7          	jalr	-1174(ra) # 800045de <end_op>
  return 0;
    80005a7c:	4501                	li	a0,0
    80005a7e:	a84d                	j	80005b30 <sys_unlink+0x1c4>
    end_op();
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	b5e080e7          	jalr	-1186(ra) # 800045de <end_op>
    return -1;
    80005a88:	557d                	li	a0,-1
    80005a8a:	a05d                	j	80005b30 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a8c:	00003517          	auipc	a0,0x3
    80005a90:	ca450513          	addi	a0,a0,-860 # 80008730 <syscalls+0x2d8>
    80005a94:	ffffb097          	auipc	ra,0xffffb
    80005a98:	aaa080e7          	jalr	-1366(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a9c:	04c92703          	lw	a4,76(s2)
    80005aa0:	02000793          	li	a5,32
    80005aa4:	f6e7f9e3          	bgeu	a5,a4,80005a16 <sys_unlink+0xaa>
    80005aa8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aac:	4741                	li	a4,16
    80005aae:	86ce                	mv	a3,s3
    80005ab0:	f1840613          	addi	a2,s0,-232
    80005ab4:	4581                	li	a1,0
    80005ab6:	854a                	mv	a0,s2
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	398080e7          	jalr	920(ra) # 80003e50 <readi>
    80005ac0:	47c1                	li	a5,16
    80005ac2:	00f51b63          	bne	a0,a5,80005ad8 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ac6:	f1845783          	lhu	a5,-232(s0)
    80005aca:	e7a1                	bnez	a5,80005b12 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005acc:	29c1                	addiw	s3,s3,16
    80005ace:	04c92783          	lw	a5,76(s2)
    80005ad2:	fcf9ede3          	bltu	s3,a5,80005aac <sys_unlink+0x140>
    80005ad6:	b781                	j	80005a16 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005ad8:	00003517          	auipc	a0,0x3
    80005adc:	c7050513          	addi	a0,a0,-912 # 80008748 <syscalls+0x2f0>
    80005ae0:	ffffb097          	auipc	ra,0xffffb
    80005ae4:	a5e080e7          	jalr	-1442(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005ae8:	00003517          	auipc	a0,0x3
    80005aec:	c7850513          	addi	a0,a0,-904 # 80008760 <syscalls+0x308>
    80005af0:	ffffb097          	auipc	ra,0xffffb
    80005af4:	a4e080e7          	jalr	-1458(ra) # 8000053e <panic>
    dp->nlink--;
    80005af8:	04a4d783          	lhu	a5,74(s1)
    80005afc:	37fd                	addiw	a5,a5,-1
    80005afe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b02:	8526                	mv	a0,s1
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	fce080e7          	jalr	-50(ra) # 80003ad2 <iupdate>
    80005b0c:	b781                	j	80005a4c <sys_unlink+0xe0>
    return -1;
    80005b0e:	557d                	li	a0,-1
    80005b10:	a005                	j	80005b30 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b12:	854a                	mv	a0,s2
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	2ea080e7          	jalr	746(ra) # 80003dfe <iunlockput>
  iunlockput(dp);
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	2e0080e7          	jalr	736(ra) # 80003dfe <iunlockput>
  end_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	ab8080e7          	jalr	-1352(ra) # 800045de <end_op>
  return -1;
    80005b2e:	557d                	li	a0,-1
}
    80005b30:	70ae                	ld	ra,232(sp)
    80005b32:	740e                	ld	s0,224(sp)
    80005b34:	64ee                	ld	s1,216(sp)
    80005b36:	694e                	ld	s2,208(sp)
    80005b38:	69ae                	ld	s3,200(sp)
    80005b3a:	616d                	addi	sp,sp,240
    80005b3c:	8082                	ret

0000000080005b3e <sys_open>:

uint64
sys_open(void)
{
    80005b3e:	7131                	addi	sp,sp,-192
    80005b40:	fd06                	sd	ra,184(sp)
    80005b42:	f922                	sd	s0,176(sp)
    80005b44:	f526                	sd	s1,168(sp)
    80005b46:	f14a                	sd	s2,160(sp)
    80005b48:	ed4e                	sd	s3,152(sp)
    80005b4a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b4c:	f4c40593          	addi	a1,s0,-180
    80005b50:	4505                	li	a0,1
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	30a080e7          	jalr	778(ra) # 80002e5c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b5a:	08000613          	li	a2,128
    80005b5e:	f5040593          	addi	a1,s0,-176
    80005b62:	4501                	li	a0,0
    80005b64:	ffffd097          	auipc	ra,0xffffd
    80005b68:	338080e7          	jalr	824(ra) # 80002e9c <argstr>
    80005b6c:	87aa                	mv	a5,a0
    return -1;
    80005b6e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b70:	0a07c963          	bltz	a5,80005c22 <sys_open+0xe4>

  begin_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	9ea080e7          	jalr	-1558(ra) # 8000455e <begin_op>

  if(omode & O_CREATE){
    80005b7c:	f4c42783          	lw	a5,-180(s0)
    80005b80:	2007f793          	andi	a5,a5,512
    80005b84:	cfc5                	beqz	a5,80005c3c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b86:	4681                	li	a3,0
    80005b88:	4601                	li	a2,0
    80005b8a:	4589                	li	a1,2
    80005b8c:	f5040513          	addi	a0,s0,-176
    80005b90:	00000097          	auipc	ra,0x0
    80005b94:	976080e7          	jalr	-1674(ra) # 80005506 <create>
    80005b98:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b9a:	c959                	beqz	a0,80005c30 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b9c:	04449703          	lh	a4,68(s1)
    80005ba0:	478d                	li	a5,3
    80005ba2:	00f71763          	bne	a4,a5,80005bb0 <sys_open+0x72>
    80005ba6:	0464d703          	lhu	a4,70(s1)
    80005baa:	47a5                	li	a5,9
    80005bac:	0ce7ed63          	bltu	a5,a4,80005c86 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	dbe080e7          	jalr	-578(ra) # 8000496e <filealloc>
    80005bb8:	89aa                	mv	s3,a0
    80005bba:	10050363          	beqz	a0,80005cc0 <sys_open+0x182>
    80005bbe:	00000097          	auipc	ra,0x0
    80005bc2:	906080e7          	jalr	-1786(ra) # 800054c4 <fdalloc>
    80005bc6:	892a                	mv	s2,a0
    80005bc8:	0e054763          	bltz	a0,80005cb6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005bcc:	04449703          	lh	a4,68(s1)
    80005bd0:	478d                	li	a5,3
    80005bd2:	0cf70563          	beq	a4,a5,80005c9c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bd6:	4789                	li	a5,2
    80005bd8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bdc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005be0:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005be4:	f4c42783          	lw	a5,-180(s0)
    80005be8:	0017c713          	xori	a4,a5,1
    80005bec:	8b05                	andi	a4,a4,1
    80005bee:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bf2:	0037f713          	andi	a4,a5,3
    80005bf6:	00e03733          	snez	a4,a4
    80005bfa:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bfe:	4007f793          	andi	a5,a5,1024
    80005c02:	c791                	beqz	a5,80005c0e <sys_open+0xd0>
    80005c04:	04449703          	lh	a4,68(s1)
    80005c08:	4789                	li	a5,2
    80005c0a:	0af70063          	beq	a4,a5,80005caa <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c0e:	8526                	mv	a0,s1
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	04e080e7          	jalr	78(ra) # 80003c5e <iunlock>
  end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	9c6080e7          	jalr	-1594(ra) # 800045de <end_op>

  return fd;
    80005c20:	854a                	mv	a0,s2
}
    80005c22:	70ea                	ld	ra,184(sp)
    80005c24:	744a                	ld	s0,176(sp)
    80005c26:	74aa                	ld	s1,168(sp)
    80005c28:	790a                	ld	s2,160(sp)
    80005c2a:	69ea                	ld	s3,152(sp)
    80005c2c:	6129                	addi	sp,sp,192
    80005c2e:	8082                	ret
      end_op();
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	9ae080e7          	jalr	-1618(ra) # 800045de <end_op>
      return -1;
    80005c38:	557d                	li	a0,-1
    80005c3a:	b7e5                	j	80005c22 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c3c:	f5040513          	addi	a0,s0,-176
    80005c40:	ffffe097          	auipc	ra,0xffffe
    80005c44:	702080e7          	jalr	1794(ra) # 80004342 <namei>
    80005c48:	84aa                	mv	s1,a0
    80005c4a:	c905                	beqz	a0,80005c7a <sys_open+0x13c>
    ilock(ip);
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	f50080e7          	jalr	-176(ra) # 80003b9c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c54:	04449703          	lh	a4,68(s1)
    80005c58:	4785                	li	a5,1
    80005c5a:	f4f711e3          	bne	a4,a5,80005b9c <sys_open+0x5e>
    80005c5e:	f4c42783          	lw	a5,-180(s0)
    80005c62:	d7b9                	beqz	a5,80005bb0 <sys_open+0x72>
      iunlockput(ip);
    80005c64:	8526                	mv	a0,s1
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	198080e7          	jalr	408(ra) # 80003dfe <iunlockput>
      end_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	970080e7          	jalr	-1680(ra) # 800045de <end_op>
      return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	b76d                	j	80005c22 <sys_open+0xe4>
      end_op();
    80005c7a:	fffff097          	auipc	ra,0xfffff
    80005c7e:	964080e7          	jalr	-1692(ra) # 800045de <end_op>
      return -1;
    80005c82:	557d                	li	a0,-1
    80005c84:	bf79                	j	80005c22 <sys_open+0xe4>
    iunlockput(ip);
    80005c86:	8526                	mv	a0,s1
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	176080e7          	jalr	374(ra) # 80003dfe <iunlockput>
    end_op();
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	94e080e7          	jalr	-1714(ra) # 800045de <end_op>
    return -1;
    80005c98:	557d                	li	a0,-1
    80005c9a:	b761                	j	80005c22 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c9c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ca0:	04649783          	lh	a5,70(s1)
    80005ca4:	02f99223          	sh	a5,36(s3)
    80005ca8:	bf25                	j	80005be0 <sys_open+0xa2>
    itrunc(ip);
    80005caa:	8526                	mv	a0,s1
    80005cac:	ffffe097          	auipc	ra,0xffffe
    80005cb0:	ffe080e7          	jalr	-2(ra) # 80003caa <itrunc>
    80005cb4:	bfa9                	j	80005c0e <sys_open+0xd0>
      fileclose(f);
    80005cb6:	854e                	mv	a0,s3
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	d72080e7          	jalr	-654(ra) # 80004a2a <fileclose>
    iunlockput(ip);
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	13c080e7          	jalr	316(ra) # 80003dfe <iunlockput>
    end_op();
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	914080e7          	jalr	-1772(ra) # 800045de <end_op>
    return -1;
    80005cd2:	557d                	li	a0,-1
    80005cd4:	b7b9                	j	80005c22 <sys_open+0xe4>

0000000080005cd6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cd6:	7175                	addi	sp,sp,-144
    80005cd8:	e506                	sd	ra,136(sp)
    80005cda:	e122                	sd	s0,128(sp)
    80005cdc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	880080e7          	jalr	-1920(ra) # 8000455e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ce6:	08000613          	li	a2,128
    80005cea:	f7040593          	addi	a1,s0,-144
    80005cee:	4501                	li	a0,0
    80005cf0:	ffffd097          	auipc	ra,0xffffd
    80005cf4:	1ac080e7          	jalr	428(ra) # 80002e9c <argstr>
    80005cf8:	02054963          	bltz	a0,80005d2a <sys_mkdir+0x54>
    80005cfc:	4681                	li	a3,0
    80005cfe:	4601                	li	a2,0
    80005d00:	4585                	li	a1,1
    80005d02:	f7040513          	addi	a0,s0,-144
    80005d06:	00000097          	auipc	ra,0x0
    80005d0a:	800080e7          	jalr	-2048(ra) # 80005506 <create>
    80005d0e:	cd11                	beqz	a0,80005d2a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	0ee080e7          	jalr	238(ra) # 80003dfe <iunlockput>
  end_op();
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	8c6080e7          	jalr	-1850(ra) # 800045de <end_op>
  return 0;
    80005d20:	4501                	li	a0,0
}
    80005d22:	60aa                	ld	ra,136(sp)
    80005d24:	640a                	ld	s0,128(sp)
    80005d26:	6149                	addi	sp,sp,144
    80005d28:	8082                	ret
    end_op();
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	8b4080e7          	jalr	-1868(ra) # 800045de <end_op>
    return -1;
    80005d32:	557d                	li	a0,-1
    80005d34:	b7fd                	j	80005d22 <sys_mkdir+0x4c>

0000000080005d36 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d36:	7135                	addi	sp,sp,-160
    80005d38:	ed06                	sd	ra,152(sp)
    80005d3a:	e922                	sd	s0,144(sp)
    80005d3c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	820080e7          	jalr	-2016(ra) # 8000455e <begin_op>
  argint(1, &major);
    80005d46:	f6c40593          	addi	a1,s0,-148
    80005d4a:	4505                	li	a0,1
    80005d4c:	ffffd097          	auipc	ra,0xffffd
    80005d50:	110080e7          	jalr	272(ra) # 80002e5c <argint>
  argint(2, &minor);
    80005d54:	f6840593          	addi	a1,s0,-152
    80005d58:	4509                	li	a0,2
    80005d5a:	ffffd097          	auipc	ra,0xffffd
    80005d5e:	102080e7          	jalr	258(ra) # 80002e5c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d62:	08000613          	li	a2,128
    80005d66:	f7040593          	addi	a1,s0,-144
    80005d6a:	4501                	li	a0,0
    80005d6c:	ffffd097          	auipc	ra,0xffffd
    80005d70:	130080e7          	jalr	304(ra) # 80002e9c <argstr>
    80005d74:	02054b63          	bltz	a0,80005daa <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d78:	f6841683          	lh	a3,-152(s0)
    80005d7c:	f6c41603          	lh	a2,-148(s0)
    80005d80:	458d                	li	a1,3
    80005d82:	f7040513          	addi	a0,s0,-144
    80005d86:	fffff097          	auipc	ra,0xfffff
    80005d8a:	780080e7          	jalr	1920(ra) # 80005506 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d8e:	cd11                	beqz	a0,80005daa <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d90:	ffffe097          	auipc	ra,0xffffe
    80005d94:	06e080e7          	jalr	110(ra) # 80003dfe <iunlockput>
  end_op();
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	846080e7          	jalr	-1978(ra) # 800045de <end_op>
  return 0;
    80005da0:	4501                	li	a0,0
}
    80005da2:	60ea                	ld	ra,152(sp)
    80005da4:	644a                	ld	s0,144(sp)
    80005da6:	610d                	addi	sp,sp,160
    80005da8:	8082                	ret
    end_op();
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	834080e7          	jalr	-1996(ra) # 800045de <end_op>
    return -1;
    80005db2:	557d                	li	a0,-1
    80005db4:	b7fd                	j	80005da2 <sys_mknod+0x6c>

0000000080005db6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005db6:	7135                	addi	sp,sp,-160
    80005db8:	ed06                	sd	ra,152(sp)
    80005dba:	e922                	sd	s0,144(sp)
    80005dbc:	e526                	sd	s1,136(sp)
    80005dbe:	e14a                	sd	s2,128(sp)
    80005dc0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005dc2:	ffffc097          	auipc	ra,0xffffc
    80005dc6:	c10080e7          	jalr	-1008(ra) # 800019d2 <myproc>
    80005dca:	892a                	mv	s2,a0
  
  begin_op();
    80005dcc:	ffffe097          	auipc	ra,0xffffe
    80005dd0:	792080e7          	jalr	1938(ra) # 8000455e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005dd4:	08000613          	li	a2,128
    80005dd8:	f6040593          	addi	a1,s0,-160
    80005ddc:	4501                	li	a0,0
    80005dde:	ffffd097          	auipc	ra,0xffffd
    80005de2:	0be080e7          	jalr	190(ra) # 80002e9c <argstr>
    80005de6:	04054b63          	bltz	a0,80005e3c <sys_chdir+0x86>
    80005dea:	f6040513          	addi	a0,s0,-160
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	554080e7          	jalr	1364(ra) # 80004342 <namei>
    80005df6:	84aa                	mv	s1,a0
    80005df8:	c131                	beqz	a0,80005e3c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	da2080e7          	jalr	-606(ra) # 80003b9c <ilock>
  if(ip->type != T_DIR){
    80005e02:	04449703          	lh	a4,68(s1)
    80005e06:	4785                	li	a5,1
    80005e08:	04f71063          	bne	a4,a5,80005e48 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e0c:	8526                	mv	a0,s1
    80005e0e:	ffffe097          	auipc	ra,0xffffe
    80005e12:	e50080e7          	jalr	-432(ra) # 80003c5e <iunlock>
  iput(p->cwd);
    80005e16:	15093503          	ld	a0,336(s2)
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	f3c080e7          	jalr	-196(ra) # 80003d56 <iput>
  end_op();
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	7bc080e7          	jalr	1980(ra) # 800045de <end_op>
  p->cwd = ip;
    80005e2a:	14993823          	sd	s1,336(s2)
  return 0;
    80005e2e:	4501                	li	a0,0
}
    80005e30:	60ea                	ld	ra,152(sp)
    80005e32:	644a                	ld	s0,144(sp)
    80005e34:	64aa                	ld	s1,136(sp)
    80005e36:	690a                	ld	s2,128(sp)
    80005e38:	610d                	addi	sp,sp,160
    80005e3a:	8082                	ret
    end_op();
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	7a2080e7          	jalr	1954(ra) # 800045de <end_op>
    return -1;
    80005e44:	557d                	li	a0,-1
    80005e46:	b7ed                	j	80005e30 <sys_chdir+0x7a>
    iunlockput(ip);
    80005e48:	8526                	mv	a0,s1
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	fb4080e7          	jalr	-76(ra) # 80003dfe <iunlockput>
    end_op();
    80005e52:	ffffe097          	auipc	ra,0xffffe
    80005e56:	78c080e7          	jalr	1932(ra) # 800045de <end_op>
    return -1;
    80005e5a:	557d                	li	a0,-1
    80005e5c:	bfd1                	j	80005e30 <sys_chdir+0x7a>

0000000080005e5e <sys_exec>:

uint64
sys_exec(void)
{
    80005e5e:	7145                	addi	sp,sp,-464
    80005e60:	e786                	sd	ra,456(sp)
    80005e62:	e3a2                	sd	s0,448(sp)
    80005e64:	ff26                	sd	s1,440(sp)
    80005e66:	fb4a                	sd	s2,432(sp)
    80005e68:	f74e                	sd	s3,424(sp)
    80005e6a:	f352                	sd	s4,416(sp)
    80005e6c:	ef56                	sd	s5,408(sp)
    80005e6e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e70:	e3840593          	addi	a1,s0,-456
    80005e74:	4505                	li	a0,1
    80005e76:	ffffd097          	auipc	ra,0xffffd
    80005e7a:	006080e7          	jalr	6(ra) # 80002e7c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e7e:	08000613          	li	a2,128
    80005e82:	f4040593          	addi	a1,s0,-192
    80005e86:	4501                	li	a0,0
    80005e88:	ffffd097          	auipc	ra,0xffffd
    80005e8c:	014080e7          	jalr	20(ra) # 80002e9c <argstr>
    80005e90:	87aa                	mv	a5,a0
    return -1;
    80005e92:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e94:	0c07c263          	bltz	a5,80005f58 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e98:	10000613          	li	a2,256
    80005e9c:	4581                	li	a1,0
    80005e9e:	e4040513          	addi	a0,s0,-448
    80005ea2:	ffffb097          	auipc	ra,0xffffb
    80005ea6:	e30080e7          	jalr	-464(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005eaa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eae:	89a6                	mv	s3,s1
    80005eb0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005eb2:	02000a13          	li	s4,32
    80005eb6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005eba:	00391793          	slli	a5,s2,0x3
    80005ebe:	e3040593          	addi	a1,s0,-464
    80005ec2:	e3843503          	ld	a0,-456(s0)
    80005ec6:	953e                	add	a0,a0,a5
    80005ec8:	ffffd097          	auipc	ra,0xffffd
    80005ecc:	ef6080e7          	jalr	-266(ra) # 80002dbe <fetchaddr>
    80005ed0:	02054a63          	bltz	a0,80005f04 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005ed4:	e3043783          	ld	a5,-464(s0)
    80005ed8:	c3b9                	beqz	a5,80005f1e <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	c0c080e7          	jalr	-1012(ra) # 80000ae6 <kalloc>
    80005ee2:	85aa                	mv	a1,a0
    80005ee4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ee8:	cd11                	beqz	a0,80005f04 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005eea:	6605                	lui	a2,0x1
    80005eec:	e3043503          	ld	a0,-464(s0)
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	f20080e7          	jalr	-224(ra) # 80002e10 <fetchstr>
    80005ef8:	00054663          	bltz	a0,80005f04 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005efc:	0905                	addi	s2,s2,1
    80005efe:	09a1                	addi	s3,s3,8
    80005f00:	fb491be3          	bne	s2,s4,80005eb6 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f04:	10048913          	addi	s2,s1,256
    80005f08:	6088                	ld	a0,0(s1)
    80005f0a:	c531                	beqz	a0,80005f56 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f0c:	ffffb097          	auipc	ra,0xffffb
    80005f10:	ade080e7          	jalr	-1314(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f14:	04a1                	addi	s1,s1,8
    80005f16:	ff2499e3          	bne	s1,s2,80005f08 <sys_exec+0xaa>
  return -1;
    80005f1a:	557d                	li	a0,-1
    80005f1c:	a835                	j	80005f58 <sys_exec+0xfa>
      argv[i] = 0;
    80005f1e:	0a8e                	slli	s5,s5,0x3
    80005f20:	fc040793          	addi	a5,s0,-64
    80005f24:	9abe                	add	s5,s5,a5
    80005f26:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f2a:	e4040593          	addi	a1,s0,-448
    80005f2e:	f4040513          	addi	a0,s0,-192
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	172080e7          	jalr	370(ra) # 800050a4 <exec>
    80005f3a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f3c:	10048993          	addi	s3,s1,256
    80005f40:	6088                	ld	a0,0(s1)
    80005f42:	c901                	beqz	a0,80005f52 <sys_exec+0xf4>
    kfree(argv[i]);
    80005f44:	ffffb097          	auipc	ra,0xffffb
    80005f48:	aa6080e7          	jalr	-1370(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f4c:	04a1                	addi	s1,s1,8
    80005f4e:	ff3499e3          	bne	s1,s3,80005f40 <sys_exec+0xe2>
  return ret;
    80005f52:	854a                	mv	a0,s2
    80005f54:	a011                	j	80005f58 <sys_exec+0xfa>
  return -1;
    80005f56:	557d                	li	a0,-1
}
    80005f58:	60be                	ld	ra,456(sp)
    80005f5a:	641e                	ld	s0,448(sp)
    80005f5c:	74fa                	ld	s1,440(sp)
    80005f5e:	795a                	ld	s2,432(sp)
    80005f60:	79ba                	ld	s3,424(sp)
    80005f62:	7a1a                	ld	s4,416(sp)
    80005f64:	6afa                	ld	s5,408(sp)
    80005f66:	6179                	addi	sp,sp,464
    80005f68:	8082                	ret

0000000080005f6a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f6a:	7139                	addi	sp,sp,-64
    80005f6c:	fc06                	sd	ra,56(sp)
    80005f6e:	f822                	sd	s0,48(sp)
    80005f70:	f426                	sd	s1,40(sp)
    80005f72:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f74:	ffffc097          	auipc	ra,0xffffc
    80005f78:	a5e080e7          	jalr	-1442(ra) # 800019d2 <myproc>
    80005f7c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f7e:	fd840593          	addi	a1,s0,-40
    80005f82:	4501                	li	a0,0
    80005f84:	ffffd097          	auipc	ra,0xffffd
    80005f88:	ef8080e7          	jalr	-264(ra) # 80002e7c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f8c:	fc840593          	addi	a1,s0,-56
    80005f90:	fd040513          	addi	a0,s0,-48
    80005f94:	fffff097          	auipc	ra,0xfffff
    80005f98:	dc6080e7          	jalr	-570(ra) # 80004d5a <pipealloc>
    return -1;
    80005f9c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f9e:	0c054463          	bltz	a0,80006066 <sys_pipe+0xfc>
  fd0 = -1;
    80005fa2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fa6:	fd043503          	ld	a0,-48(s0)
    80005faa:	fffff097          	auipc	ra,0xfffff
    80005fae:	51a080e7          	jalr	1306(ra) # 800054c4 <fdalloc>
    80005fb2:	fca42223          	sw	a0,-60(s0)
    80005fb6:	08054b63          	bltz	a0,8000604c <sys_pipe+0xe2>
    80005fba:	fc843503          	ld	a0,-56(s0)
    80005fbe:	fffff097          	auipc	ra,0xfffff
    80005fc2:	506080e7          	jalr	1286(ra) # 800054c4 <fdalloc>
    80005fc6:	fca42023          	sw	a0,-64(s0)
    80005fca:	06054863          	bltz	a0,8000603a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fce:	4691                	li	a3,4
    80005fd0:	fc440613          	addi	a2,s0,-60
    80005fd4:	fd843583          	ld	a1,-40(s0)
    80005fd8:	68a8                	ld	a0,80(s1)
    80005fda:	ffffb097          	auipc	ra,0xffffb
    80005fde:	68e080e7          	jalr	1678(ra) # 80001668 <copyout>
    80005fe2:	02054063          	bltz	a0,80006002 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fe6:	4691                	li	a3,4
    80005fe8:	fc040613          	addi	a2,s0,-64
    80005fec:	fd843583          	ld	a1,-40(s0)
    80005ff0:	0591                	addi	a1,a1,4
    80005ff2:	68a8                	ld	a0,80(s1)
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	674080e7          	jalr	1652(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ffc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ffe:	06055463          	bgez	a0,80006066 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006002:	fc442783          	lw	a5,-60(s0)
    80006006:	07e9                	addi	a5,a5,26
    80006008:	078e                	slli	a5,a5,0x3
    8000600a:	97a6                	add	a5,a5,s1
    8000600c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006010:	fc042503          	lw	a0,-64(s0)
    80006014:	0569                	addi	a0,a0,26
    80006016:	050e                	slli	a0,a0,0x3
    80006018:	94aa                	add	s1,s1,a0
    8000601a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000601e:	fd043503          	ld	a0,-48(s0)
    80006022:	fffff097          	auipc	ra,0xfffff
    80006026:	a08080e7          	jalr	-1528(ra) # 80004a2a <fileclose>
    fileclose(wf);
    8000602a:	fc843503          	ld	a0,-56(s0)
    8000602e:	fffff097          	auipc	ra,0xfffff
    80006032:	9fc080e7          	jalr	-1540(ra) # 80004a2a <fileclose>
    return -1;
    80006036:	57fd                	li	a5,-1
    80006038:	a03d                	j	80006066 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000603a:	fc442783          	lw	a5,-60(s0)
    8000603e:	0007c763          	bltz	a5,8000604c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006042:	07e9                	addi	a5,a5,26
    80006044:	078e                	slli	a5,a5,0x3
    80006046:	94be                	add	s1,s1,a5
    80006048:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000604c:	fd043503          	ld	a0,-48(s0)
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	9da080e7          	jalr	-1574(ra) # 80004a2a <fileclose>
    fileclose(wf);
    80006058:	fc843503          	ld	a0,-56(s0)
    8000605c:	fffff097          	auipc	ra,0xfffff
    80006060:	9ce080e7          	jalr	-1586(ra) # 80004a2a <fileclose>
    return -1;
    80006064:	57fd                	li	a5,-1
}
    80006066:	853e                	mv	a0,a5
    80006068:	70e2                	ld	ra,56(sp)
    8000606a:	7442                	ld	s0,48(sp)
    8000606c:	74a2                	ld	s1,40(sp)
    8000606e:	6121                	addi	sp,sp,64
    80006070:	8082                	ret
	...

0000000080006080 <kernelvec>:
    80006080:	7111                	addi	sp,sp,-256
    80006082:	e006                	sd	ra,0(sp)
    80006084:	e40a                	sd	sp,8(sp)
    80006086:	e80e                	sd	gp,16(sp)
    80006088:	ec12                	sd	tp,24(sp)
    8000608a:	f016                	sd	t0,32(sp)
    8000608c:	f41a                	sd	t1,40(sp)
    8000608e:	f81e                	sd	t2,48(sp)
    80006090:	fc22                	sd	s0,56(sp)
    80006092:	e0a6                	sd	s1,64(sp)
    80006094:	e4aa                	sd	a0,72(sp)
    80006096:	e8ae                	sd	a1,80(sp)
    80006098:	ecb2                	sd	a2,88(sp)
    8000609a:	f0b6                	sd	a3,96(sp)
    8000609c:	f4ba                	sd	a4,104(sp)
    8000609e:	f8be                	sd	a5,112(sp)
    800060a0:	fcc2                	sd	a6,120(sp)
    800060a2:	e146                	sd	a7,128(sp)
    800060a4:	e54a                	sd	s2,136(sp)
    800060a6:	e94e                	sd	s3,144(sp)
    800060a8:	ed52                	sd	s4,152(sp)
    800060aa:	f156                	sd	s5,160(sp)
    800060ac:	f55a                	sd	s6,168(sp)
    800060ae:	f95e                	sd	s7,176(sp)
    800060b0:	fd62                	sd	s8,184(sp)
    800060b2:	e1e6                	sd	s9,192(sp)
    800060b4:	e5ea                	sd	s10,200(sp)
    800060b6:	e9ee                	sd	s11,208(sp)
    800060b8:	edf2                	sd	t3,216(sp)
    800060ba:	f1f6                	sd	t4,224(sp)
    800060bc:	f5fa                	sd	t5,232(sp)
    800060be:	f9fe                	sd	t6,240(sp)
    800060c0:	bcbfc0ef          	jal	ra,80002c8a <kerneltrap>
    800060c4:	6082                	ld	ra,0(sp)
    800060c6:	6122                	ld	sp,8(sp)
    800060c8:	61c2                	ld	gp,16(sp)
    800060ca:	7282                	ld	t0,32(sp)
    800060cc:	7322                	ld	t1,40(sp)
    800060ce:	73c2                	ld	t2,48(sp)
    800060d0:	7462                	ld	s0,56(sp)
    800060d2:	6486                	ld	s1,64(sp)
    800060d4:	6526                	ld	a0,72(sp)
    800060d6:	65c6                	ld	a1,80(sp)
    800060d8:	6666                	ld	a2,88(sp)
    800060da:	7686                	ld	a3,96(sp)
    800060dc:	7726                	ld	a4,104(sp)
    800060de:	77c6                	ld	a5,112(sp)
    800060e0:	7866                	ld	a6,120(sp)
    800060e2:	688a                	ld	a7,128(sp)
    800060e4:	692a                	ld	s2,136(sp)
    800060e6:	69ca                	ld	s3,144(sp)
    800060e8:	6a6a                	ld	s4,152(sp)
    800060ea:	7a8a                	ld	s5,160(sp)
    800060ec:	7b2a                	ld	s6,168(sp)
    800060ee:	7bca                	ld	s7,176(sp)
    800060f0:	7c6a                	ld	s8,184(sp)
    800060f2:	6c8e                	ld	s9,192(sp)
    800060f4:	6d2e                	ld	s10,200(sp)
    800060f6:	6dce                	ld	s11,208(sp)
    800060f8:	6e6e                	ld	t3,216(sp)
    800060fa:	7e8e                	ld	t4,224(sp)
    800060fc:	7f2e                	ld	t5,232(sp)
    800060fe:	7fce                	ld	t6,240(sp)
    80006100:	6111                	addi	sp,sp,256
    80006102:	10200073          	sret
    80006106:	00000013          	nop
    8000610a:	00000013          	nop
    8000610e:	0001                	nop

0000000080006110 <timervec>:
    80006110:	34051573          	csrrw	a0,mscratch,a0
    80006114:	e10c                	sd	a1,0(a0)
    80006116:	e510                	sd	a2,8(a0)
    80006118:	e914                	sd	a3,16(a0)
    8000611a:	6d0c                	ld	a1,24(a0)
    8000611c:	7110                	ld	a2,32(a0)
    8000611e:	6194                	ld	a3,0(a1)
    80006120:	96b2                	add	a3,a3,a2
    80006122:	e194                	sd	a3,0(a1)
    80006124:	4589                	li	a1,2
    80006126:	14459073          	csrw	sip,a1
    8000612a:	6914                	ld	a3,16(a0)
    8000612c:	6510                	ld	a2,8(a0)
    8000612e:	610c                	ld	a1,0(a0)
    80006130:	34051573          	csrrw	a0,mscratch,a0
    80006134:	30200073          	mret
	...

000000008000613a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000613a:	1141                	addi	sp,sp,-16
    8000613c:	e422                	sd	s0,8(sp)
    8000613e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006140:	0c0007b7          	lui	a5,0xc000
    80006144:	4705                	li	a4,1
    80006146:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006148:	c3d8                	sw	a4,4(a5)
}
    8000614a:	6422                	ld	s0,8(sp)
    8000614c:	0141                	addi	sp,sp,16
    8000614e:	8082                	ret

0000000080006150 <plicinithart>:

void
plicinithart(void)
{
    80006150:	1141                	addi	sp,sp,-16
    80006152:	e406                	sd	ra,8(sp)
    80006154:	e022                	sd	s0,0(sp)
    80006156:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006158:	ffffc097          	auipc	ra,0xffffc
    8000615c:	84e080e7          	jalr	-1970(ra) # 800019a6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006160:	0085171b          	slliw	a4,a0,0x8
    80006164:	0c0027b7          	lui	a5,0xc002
    80006168:	97ba                	add	a5,a5,a4
    8000616a:	40200713          	li	a4,1026
    8000616e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006172:	00d5151b          	slliw	a0,a0,0xd
    80006176:	0c2017b7          	lui	a5,0xc201
    8000617a:	953e                	add	a0,a0,a5
    8000617c:	00052023          	sw	zero,0(a0)
}
    80006180:	60a2                	ld	ra,8(sp)
    80006182:	6402                	ld	s0,0(sp)
    80006184:	0141                	addi	sp,sp,16
    80006186:	8082                	ret

0000000080006188 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006188:	1141                	addi	sp,sp,-16
    8000618a:	e406                	sd	ra,8(sp)
    8000618c:	e022                	sd	s0,0(sp)
    8000618e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006190:	ffffc097          	auipc	ra,0xffffc
    80006194:	816080e7          	jalr	-2026(ra) # 800019a6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006198:	00d5179b          	slliw	a5,a0,0xd
    8000619c:	0c201537          	lui	a0,0xc201
    800061a0:	953e                	add	a0,a0,a5
  return irq;
}
    800061a2:	4148                	lw	a0,4(a0)
    800061a4:	60a2                	ld	ra,8(sp)
    800061a6:	6402                	ld	s0,0(sp)
    800061a8:	0141                	addi	sp,sp,16
    800061aa:	8082                	ret

00000000800061ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061ac:	1101                	addi	sp,sp,-32
    800061ae:	ec06                	sd	ra,24(sp)
    800061b0:	e822                	sd	s0,16(sp)
    800061b2:	e426                	sd	s1,8(sp)
    800061b4:	1000                	addi	s0,sp,32
    800061b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061b8:	ffffb097          	auipc	ra,0xffffb
    800061bc:	7ee080e7          	jalr	2030(ra) # 800019a6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061c0:	00d5151b          	slliw	a0,a0,0xd
    800061c4:	0c2017b7          	lui	a5,0xc201
    800061c8:	97aa                	add	a5,a5,a0
    800061ca:	c3c4                	sw	s1,4(a5)
}
    800061cc:	60e2                	ld	ra,24(sp)
    800061ce:	6442                	ld	s0,16(sp)
    800061d0:	64a2                	ld	s1,8(sp)
    800061d2:	6105                	addi	sp,sp,32
    800061d4:	8082                	ret

00000000800061d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061d6:	1141                	addi	sp,sp,-16
    800061d8:	e406                	sd	ra,8(sp)
    800061da:	e022                	sd	s0,0(sp)
    800061dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061de:	479d                	li	a5,7
    800061e0:	04a7cc63          	blt	a5,a0,80006238 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800061e4:	0001f797          	auipc	a5,0x1f
    800061e8:	ecc78793          	addi	a5,a5,-308 # 800250b0 <disk>
    800061ec:	97aa                	add	a5,a5,a0
    800061ee:	0187c783          	lbu	a5,24(a5)
    800061f2:	ebb9                	bnez	a5,80006248 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061f4:	00451613          	slli	a2,a0,0x4
    800061f8:	0001f797          	auipc	a5,0x1f
    800061fc:	eb878793          	addi	a5,a5,-328 # 800250b0 <disk>
    80006200:	6394                	ld	a3,0(a5)
    80006202:	96b2                	add	a3,a3,a2
    80006204:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006208:	6398                	ld	a4,0(a5)
    8000620a:	9732                	add	a4,a4,a2
    8000620c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006210:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006214:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006218:	953e                	add	a0,a0,a5
    8000621a:	4785                	li	a5,1
    8000621c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006220:	0001f517          	auipc	a0,0x1f
    80006224:	ea850513          	addi	a0,a0,-344 # 800250c8 <disk+0x18>
    80006228:	ffffc097          	auipc	ra,0xffffc
    8000622c:	008080e7          	jalr	8(ra) # 80002230 <wakeup>
}
    80006230:	60a2                	ld	ra,8(sp)
    80006232:	6402                	ld	s0,0(sp)
    80006234:	0141                	addi	sp,sp,16
    80006236:	8082                	ret
    panic("free_desc 1");
    80006238:	00002517          	auipc	a0,0x2
    8000623c:	53850513          	addi	a0,a0,1336 # 80008770 <syscalls+0x318>
    80006240:	ffffa097          	auipc	ra,0xffffa
    80006244:	2fe080e7          	jalr	766(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	53850513          	addi	a0,a0,1336 # 80008780 <syscalls+0x328>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	2ee080e7          	jalr	750(ra) # 8000053e <panic>

0000000080006258 <virtio_disk_init>:
{
    80006258:	1101                	addi	sp,sp,-32
    8000625a:	ec06                	sd	ra,24(sp)
    8000625c:	e822                	sd	s0,16(sp)
    8000625e:	e426                	sd	s1,8(sp)
    80006260:	e04a                	sd	s2,0(sp)
    80006262:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006264:	00002597          	auipc	a1,0x2
    80006268:	52c58593          	addi	a1,a1,1324 # 80008790 <syscalls+0x338>
    8000626c:	0001f517          	auipc	a0,0x1f
    80006270:	f6c50513          	addi	a0,a0,-148 # 800251d8 <disk+0x128>
    80006274:	ffffb097          	auipc	ra,0xffffb
    80006278:	8d2080e7          	jalr	-1838(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000627c:	100017b7          	lui	a5,0x10001
    80006280:	4398                	lw	a4,0(a5)
    80006282:	2701                	sext.w	a4,a4
    80006284:	747277b7          	lui	a5,0x74727
    80006288:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000628c:	14f71c63          	bne	a4,a5,800063e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006290:	100017b7          	lui	a5,0x10001
    80006294:	43dc                	lw	a5,4(a5)
    80006296:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006298:	4709                	li	a4,2
    8000629a:	14e79563          	bne	a5,a4,800063e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000629e:	100017b7          	lui	a5,0x10001
    800062a2:	479c                	lw	a5,8(a5)
    800062a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062a6:	12e79f63          	bne	a5,a4,800063e4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062aa:	100017b7          	lui	a5,0x10001
    800062ae:	47d8                	lw	a4,12(a5)
    800062b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062b2:	554d47b7          	lui	a5,0x554d4
    800062b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062ba:	12f71563          	bne	a4,a5,800063e4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062be:	100017b7          	lui	a5,0x10001
    800062c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062c6:	4705                	li	a4,1
    800062c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ca:	470d                	li	a4,3
    800062cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062d0:	c7ffe737          	lui	a4,0xc7ffe
    800062d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd956f>
    800062d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062da:	2701                	sext.w	a4,a4
    800062dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062de:	472d                	li	a4,11
    800062e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800062e2:	5bbc                	lw	a5,112(a5)
    800062e4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800062e8:	8ba1                	andi	a5,a5,8
    800062ea:	10078563          	beqz	a5,800063f4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062ee:	100017b7          	lui	a5,0x10001
    800062f2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800062f6:	43fc                	lw	a5,68(a5)
    800062f8:	2781                	sext.w	a5,a5
    800062fa:	10079563          	bnez	a5,80006404 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062fe:	100017b7          	lui	a5,0x10001
    80006302:	5bdc                	lw	a5,52(a5)
    80006304:	2781                	sext.w	a5,a5
  if(max == 0)
    80006306:	10078763          	beqz	a5,80006414 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000630a:	471d                	li	a4,7
    8000630c:	10f77c63          	bgeu	a4,a5,80006424 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006310:	ffffa097          	auipc	ra,0xffffa
    80006314:	7d6080e7          	jalr	2006(ra) # 80000ae6 <kalloc>
    80006318:	0001f497          	auipc	s1,0x1f
    8000631c:	d9848493          	addi	s1,s1,-616 # 800250b0 <disk>
    80006320:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006322:	ffffa097          	auipc	ra,0xffffa
    80006326:	7c4080e7          	jalr	1988(ra) # 80000ae6 <kalloc>
    8000632a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000632c:	ffffa097          	auipc	ra,0xffffa
    80006330:	7ba080e7          	jalr	1978(ra) # 80000ae6 <kalloc>
    80006334:	87aa                	mv	a5,a0
    80006336:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006338:	6088                	ld	a0,0(s1)
    8000633a:	cd6d                	beqz	a0,80006434 <virtio_disk_init+0x1dc>
    8000633c:	0001f717          	auipc	a4,0x1f
    80006340:	d7c73703          	ld	a4,-644(a4) # 800250b8 <disk+0x8>
    80006344:	cb65                	beqz	a4,80006434 <virtio_disk_init+0x1dc>
    80006346:	c7fd                	beqz	a5,80006434 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006348:	6605                	lui	a2,0x1
    8000634a:	4581                	li	a1,0
    8000634c:	ffffb097          	auipc	ra,0xffffb
    80006350:	986080e7          	jalr	-1658(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006354:	0001f497          	auipc	s1,0x1f
    80006358:	d5c48493          	addi	s1,s1,-676 # 800250b0 <disk>
    8000635c:	6605                	lui	a2,0x1
    8000635e:	4581                	li	a1,0
    80006360:	6488                	ld	a0,8(s1)
    80006362:	ffffb097          	auipc	ra,0xffffb
    80006366:	970080e7          	jalr	-1680(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000636a:	6605                	lui	a2,0x1
    8000636c:	4581                	li	a1,0
    8000636e:	6888                	ld	a0,16(s1)
    80006370:	ffffb097          	auipc	ra,0xffffb
    80006374:	962080e7          	jalr	-1694(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006378:	100017b7          	lui	a5,0x10001
    8000637c:	4721                	li	a4,8
    8000637e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006380:	4098                	lw	a4,0(s1)
    80006382:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006386:	40d8                	lw	a4,4(s1)
    80006388:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000638c:	6498                	ld	a4,8(s1)
    8000638e:	0007069b          	sext.w	a3,a4
    80006392:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006396:	9701                	srai	a4,a4,0x20
    80006398:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000639c:	6898                	ld	a4,16(s1)
    8000639e:	0007069b          	sext.w	a3,a4
    800063a2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063a6:	9701                	srai	a4,a4,0x20
    800063a8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063ac:	4705                	li	a4,1
    800063ae:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063b0:	00e48c23          	sb	a4,24(s1)
    800063b4:	00e48ca3          	sb	a4,25(s1)
    800063b8:	00e48d23          	sb	a4,26(s1)
    800063bc:	00e48da3          	sb	a4,27(s1)
    800063c0:	00e48e23          	sb	a4,28(s1)
    800063c4:	00e48ea3          	sb	a4,29(s1)
    800063c8:	00e48f23          	sb	a4,30(s1)
    800063cc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800063d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d4:	0727a823          	sw	s2,112(a5)
}
    800063d8:	60e2                	ld	ra,24(sp)
    800063da:	6442                	ld	s0,16(sp)
    800063dc:	64a2                	ld	s1,8(sp)
    800063de:	6902                	ld	s2,0(sp)
    800063e0:	6105                	addi	sp,sp,32
    800063e2:	8082                	ret
    panic("could not find virtio disk");
    800063e4:	00002517          	auipc	a0,0x2
    800063e8:	3bc50513          	addi	a0,a0,956 # 800087a0 <syscalls+0x348>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	152080e7          	jalr	338(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800063f4:	00002517          	auipc	a0,0x2
    800063f8:	3cc50513          	addi	a0,a0,972 # 800087c0 <syscalls+0x368>
    800063fc:	ffffa097          	auipc	ra,0xffffa
    80006400:	142080e7          	jalr	322(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006404:	00002517          	auipc	a0,0x2
    80006408:	3dc50513          	addi	a0,a0,988 # 800087e0 <syscalls+0x388>
    8000640c:	ffffa097          	auipc	ra,0xffffa
    80006410:	132080e7          	jalr	306(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006414:	00002517          	auipc	a0,0x2
    80006418:	3ec50513          	addi	a0,a0,1004 # 80008800 <syscalls+0x3a8>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	122080e7          	jalr	290(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006424:	00002517          	auipc	a0,0x2
    80006428:	3fc50513          	addi	a0,a0,1020 # 80008820 <syscalls+0x3c8>
    8000642c:	ffffa097          	auipc	ra,0xffffa
    80006430:	112080e7          	jalr	274(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006434:	00002517          	auipc	a0,0x2
    80006438:	40c50513          	addi	a0,a0,1036 # 80008840 <syscalls+0x3e8>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	102080e7          	jalr	258(ra) # 8000053e <panic>

0000000080006444 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006444:	7119                	addi	sp,sp,-128
    80006446:	fc86                	sd	ra,120(sp)
    80006448:	f8a2                	sd	s0,112(sp)
    8000644a:	f4a6                	sd	s1,104(sp)
    8000644c:	f0ca                	sd	s2,96(sp)
    8000644e:	ecce                	sd	s3,88(sp)
    80006450:	e8d2                	sd	s4,80(sp)
    80006452:	e4d6                	sd	s5,72(sp)
    80006454:	e0da                	sd	s6,64(sp)
    80006456:	fc5e                	sd	s7,56(sp)
    80006458:	f862                	sd	s8,48(sp)
    8000645a:	f466                	sd	s9,40(sp)
    8000645c:	f06a                	sd	s10,32(sp)
    8000645e:	ec6e                	sd	s11,24(sp)
    80006460:	0100                	addi	s0,sp,128
    80006462:	8aaa                	mv	s5,a0
    80006464:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006466:	00c52d03          	lw	s10,12(a0)
    8000646a:	001d1d1b          	slliw	s10,s10,0x1
    8000646e:	1d02                	slli	s10,s10,0x20
    80006470:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006474:	0001f517          	auipc	a0,0x1f
    80006478:	d6450513          	addi	a0,a0,-668 # 800251d8 <disk+0x128>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	75a080e7          	jalr	1882(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006484:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006486:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006488:	0001fb97          	auipc	s7,0x1f
    8000648c:	c28b8b93          	addi	s7,s7,-984 # 800250b0 <disk>
  for(int i = 0; i < 3; i++){
    80006490:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006492:	0001fc97          	auipc	s9,0x1f
    80006496:	d46c8c93          	addi	s9,s9,-698 # 800251d8 <disk+0x128>
    8000649a:	a08d                	j	800064fc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000649c:	00fb8733          	add	a4,s7,a5
    800064a0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064a4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064a6:	0207c563          	bltz	a5,800064d0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064aa:	2905                	addiw	s2,s2,1
    800064ac:	0611                	addi	a2,a2,4
    800064ae:	05690c63          	beq	s2,s6,80006506 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800064b2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064b4:	0001f717          	auipc	a4,0x1f
    800064b8:	bfc70713          	addi	a4,a4,-1028 # 800250b0 <disk>
    800064bc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064be:	01874683          	lbu	a3,24(a4)
    800064c2:	fee9                	bnez	a3,8000649c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800064c4:	2785                	addiw	a5,a5,1
    800064c6:	0705                	addi	a4,a4,1
    800064c8:	fe979be3          	bne	a5,s1,800064be <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800064cc:	57fd                	li	a5,-1
    800064ce:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064d0:	01205d63          	blez	s2,800064ea <virtio_disk_rw+0xa6>
    800064d4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064d6:	000a2503          	lw	a0,0(s4)
    800064da:	00000097          	auipc	ra,0x0
    800064de:	cfc080e7          	jalr	-772(ra) # 800061d6 <free_desc>
      for(int j = 0; j < i; j++)
    800064e2:	2d85                	addiw	s11,s11,1
    800064e4:	0a11                	addi	s4,s4,4
    800064e6:	ffb918e3          	bne	s2,s11,800064d6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064ea:	85e6                	mv	a1,s9
    800064ec:	0001f517          	auipc	a0,0x1f
    800064f0:	bdc50513          	addi	a0,a0,-1060 # 800250c8 <disk+0x18>
    800064f4:	ffffc097          	auipc	ra,0xffffc
    800064f8:	cd8080e7          	jalr	-808(ra) # 800021cc <sleep>
  for(int i = 0; i < 3; i++){
    800064fc:	f8040a13          	addi	s4,s0,-128
{
    80006500:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006502:	894e                	mv	s2,s3
    80006504:	b77d                	j	800064b2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006506:	f8042583          	lw	a1,-128(s0)
    8000650a:	00a58793          	addi	a5,a1,10
    8000650e:	0792                	slli	a5,a5,0x4

  if(write)
    80006510:	0001f617          	auipc	a2,0x1f
    80006514:	ba060613          	addi	a2,a2,-1120 # 800250b0 <disk>
    80006518:	00f60733          	add	a4,a2,a5
    8000651c:	018036b3          	snez	a3,s8
    80006520:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006522:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006526:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000652a:	f6078693          	addi	a3,a5,-160
    8000652e:	6218                	ld	a4,0(a2)
    80006530:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006532:	00878513          	addi	a0,a5,8
    80006536:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006538:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000653a:	6208                	ld	a0,0(a2)
    8000653c:	96aa                	add	a3,a3,a0
    8000653e:	4741                	li	a4,16
    80006540:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006542:	4705                	li	a4,1
    80006544:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006548:	f8442703          	lw	a4,-124(s0)
    8000654c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006550:	0712                	slli	a4,a4,0x4
    80006552:	953a                	add	a0,a0,a4
    80006554:	058a8693          	addi	a3,s5,88
    80006558:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000655a:	6208                	ld	a0,0(a2)
    8000655c:	972a                	add	a4,a4,a0
    8000655e:	40000693          	li	a3,1024
    80006562:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006564:	001c3c13          	seqz	s8,s8
    80006568:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000656a:	001c6c13          	ori	s8,s8,1
    8000656e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006572:	f8842603          	lw	a2,-120(s0)
    80006576:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000657a:	0001f697          	auipc	a3,0x1f
    8000657e:	b3668693          	addi	a3,a3,-1226 # 800250b0 <disk>
    80006582:	00258713          	addi	a4,a1,2
    80006586:	0712                	slli	a4,a4,0x4
    80006588:	9736                	add	a4,a4,a3
    8000658a:	587d                	li	a6,-1
    8000658c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006590:	0612                	slli	a2,a2,0x4
    80006592:	9532                	add	a0,a0,a2
    80006594:	f9078793          	addi	a5,a5,-112
    80006598:	97b6                	add	a5,a5,a3
    8000659a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000659c:	629c                	ld	a5,0(a3)
    8000659e:	97b2                	add	a5,a5,a2
    800065a0:	4605                	li	a2,1
    800065a2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065a4:	4509                	li	a0,2
    800065a6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800065aa:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065ae:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065b2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065b6:	6698                	ld	a4,8(a3)
    800065b8:	00275783          	lhu	a5,2(a4)
    800065bc:	8b9d                	andi	a5,a5,7
    800065be:	0786                	slli	a5,a5,0x1
    800065c0:	97ba                	add	a5,a5,a4
    800065c2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800065c6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065ca:	6698                	ld	a4,8(a3)
    800065cc:	00275783          	lhu	a5,2(a4)
    800065d0:	2785                	addiw	a5,a5,1
    800065d2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065d6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065da:	100017b7          	lui	a5,0x10001
    800065de:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065e2:	004aa783          	lw	a5,4(s5)
    800065e6:	02c79163          	bne	a5,a2,80006608 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800065ea:	0001f917          	auipc	s2,0x1f
    800065ee:	bee90913          	addi	s2,s2,-1042 # 800251d8 <disk+0x128>
  while(b->disk == 1) {
    800065f2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065f4:	85ca                	mv	a1,s2
    800065f6:	8556                	mv	a0,s5
    800065f8:	ffffc097          	auipc	ra,0xffffc
    800065fc:	bd4080e7          	jalr	-1068(ra) # 800021cc <sleep>
  while(b->disk == 1) {
    80006600:	004aa783          	lw	a5,4(s5)
    80006604:	fe9788e3          	beq	a5,s1,800065f4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006608:	f8042903          	lw	s2,-128(s0)
    8000660c:	00290793          	addi	a5,s2,2
    80006610:	00479713          	slli	a4,a5,0x4
    80006614:	0001f797          	auipc	a5,0x1f
    80006618:	a9c78793          	addi	a5,a5,-1380 # 800250b0 <disk>
    8000661c:	97ba                	add	a5,a5,a4
    8000661e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006622:	0001f997          	auipc	s3,0x1f
    80006626:	a8e98993          	addi	s3,s3,-1394 # 800250b0 <disk>
    8000662a:	00491713          	slli	a4,s2,0x4
    8000662e:	0009b783          	ld	a5,0(s3)
    80006632:	97ba                	add	a5,a5,a4
    80006634:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006638:	854a                	mv	a0,s2
    8000663a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000663e:	00000097          	auipc	ra,0x0
    80006642:	b98080e7          	jalr	-1128(ra) # 800061d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006646:	8885                	andi	s1,s1,1
    80006648:	f0ed                	bnez	s1,8000662a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000664a:	0001f517          	auipc	a0,0x1f
    8000664e:	b8e50513          	addi	a0,a0,-1138 # 800251d8 <disk+0x128>
    80006652:	ffffa097          	auipc	ra,0xffffa
    80006656:	638080e7          	jalr	1592(ra) # 80000c8a <release>
}
    8000665a:	70e6                	ld	ra,120(sp)
    8000665c:	7446                	ld	s0,112(sp)
    8000665e:	74a6                	ld	s1,104(sp)
    80006660:	7906                	ld	s2,96(sp)
    80006662:	69e6                	ld	s3,88(sp)
    80006664:	6a46                	ld	s4,80(sp)
    80006666:	6aa6                	ld	s5,72(sp)
    80006668:	6b06                	ld	s6,64(sp)
    8000666a:	7be2                	ld	s7,56(sp)
    8000666c:	7c42                	ld	s8,48(sp)
    8000666e:	7ca2                	ld	s9,40(sp)
    80006670:	7d02                	ld	s10,32(sp)
    80006672:	6de2                	ld	s11,24(sp)
    80006674:	6109                	addi	sp,sp,128
    80006676:	8082                	ret

0000000080006678 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006678:	1101                	addi	sp,sp,-32
    8000667a:	ec06                	sd	ra,24(sp)
    8000667c:	e822                	sd	s0,16(sp)
    8000667e:	e426                	sd	s1,8(sp)
    80006680:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006682:	0001f497          	auipc	s1,0x1f
    80006686:	a2e48493          	addi	s1,s1,-1490 # 800250b0 <disk>
    8000668a:	0001f517          	auipc	a0,0x1f
    8000668e:	b4e50513          	addi	a0,a0,-1202 # 800251d8 <disk+0x128>
    80006692:	ffffa097          	auipc	ra,0xffffa
    80006696:	544080e7          	jalr	1348(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000669a:	10001737          	lui	a4,0x10001
    8000669e:	533c                	lw	a5,96(a4)
    800066a0:	8b8d                	andi	a5,a5,3
    800066a2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066a4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066a8:	689c                	ld	a5,16(s1)
    800066aa:	0204d703          	lhu	a4,32(s1)
    800066ae:	0027d783          	lhu	a5,2(a5)
    800066b2:	04f70863          	beq	a4,a5,80006702 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066b6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066ba:	6898                	ld	a4,16(s1)
    800066bc:	0204d783          	lhu	a5,32(s1)
    800066c0:	8b9d                	andi	a5,a5,7
    800066c2:	078e                	slli	a5,a5,0x3
    800066c4:	97ba                	add	a5,a5,a4
    800066c6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066c8:	00278713          	addi	a4,a5,2
    800066cc:	0712                	slli	a4,a4,0x4
    800066ce:	9726                	add	a4,a4,s1
    800066d0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066d4:	e721                	bnez	a4,8000671c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066d6:	0789                	addi	a5,a5,2
    800066d8:	0792                	slli	a5,a5,0x4
    800066da:	97a6                	add	a5,a5,s1
    800066dc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066de:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066e2:	ffffc097          	auipc	ra,0xffffc
    800066e6:	b4e080e7          	jalr	-1202(ra) # 80002230 <wakeup>

    disk.used_idx += 1;
    800066ea:	0204d783          	lhu	a5,32(s1)
    800066ee:	2785                	addiw	a5,a5,1
    800066f0:	17c2                	slli	a5,a5,0x30
    800066f2:	93c1                	srli	a5,a5,0x30
    800066f4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066f8:	6898                	ld	a4,16(s1)
    800066fa:	00275703          	lhu	a4,2(a4)
    800066fe:	faf71ce3          	bne	a4,a5,800066b6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006702:	0001f517          	auipc	a0,0x1f
    80006706:	ad650513          	addi	a0,a0,-1322 # 800251d8 <disk+0x128>
    8000670a:	ffffa097          	auipc	ra,0xffffa
    8000670e:	580080e7          	jalr	1408(ra) # 80000c8a <release>
}
    80006712:	60e2                	ld	ra,24(sp)
    80006714:	6442                	ld	s0,16(sp)
    80006716:	64a2                	ld	s1,8(sp)
    80006718:	6105                	addi	sp,sp,32
    8000671a:	8082                	ret
      panic("virtio_disk_intr status");
    8000671c:	00002517          	auipc	a0,0x2
    80006720:	13c50513          	addi	a0,a0,316 # 80008858 <syscalls+0x400>
    80006724:	ffffa097          	auipc	ra,0xffffa
    80006728:	e1a080e7          	jalr	-486(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...

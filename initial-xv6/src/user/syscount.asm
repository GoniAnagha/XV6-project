
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <syscall_name>:
#include "kernel/types.h"
#include "user/user.h"

const char* syscall_name(int mask) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    switch(mask) {
   6:	6709                	lui	a4,0x2
   8:	16e50c63          	beq	a0,a4,180 <syscall_name+0x180>
   c:	87aa                	mv	a5,a0
   e:	0aa74763          	blt	a4,a0,bc <syscall_name+0xbc>
  12:	08000713          	li	a4,128
  16:	16e50a63          	beq	a0,a4,18a <syscall_name+0x18a>
  1a:	02a75763          	bge	a4,a0,48 <syscall_name+0x48>
  1e:	40000713          	li	a4,1024
  22:	18e50863          	beq	a0,a4,1b2 <syscall_name+0x1b2>
  26:	06a75863          	bge	a4,a0,96 <syscall_name+0x96>
  2a:	8005071b          	addiw	a4,a0,-2048
        case 1 << 6: return "kill";
        case 1 << 7: return "exec";
        case 1 << 8: return "fstat";
        case 1 << 9: return "chdir";
        case 1 << 10: return "dup";
        case 1 << 11: return "getpid";
  2e:	00001517          	auipc	a0,0x1
  32:	b0250513          	addi	a0,a0,-1278 # b30 <malloc+0x152>
    switch(mask) {
  36:	c341                	beqz	a4,b6 <syscall_name+0xb6>
  38:	6705                	lui	a4,0x1
  3a:	18e79663          	bne	a5,a4,1c6 <syscall_name+0x1c6>
        case 1 << 12: return "sbrk";
  3e:	00001517          	auipc	a0,0x1
  42:	b2a50513          	addi	a0,a0,-1238 # b68 <malloc+0x18a>
  46:	a885                	j	b6 <syscall_name+0xb6>
    switch(mask) {
  48:	02000713          	li	a4,32
  4c:	02a74c63          	blt	a4,a0,84 <syscall_name+0x84>
  50:	4705                	li	a4,1
  52:	14a75163          	bge	a4,a0,194 <syscall_name+0x194>
  56:	02000713          	li	a4,32
  5a:	02a76063          	bltu	a4,a0,7a <syscall_name+0x7a>
  5e:	050a                	slli	a0,a0,0x2
  60:	00001717          	auipc	a4,0x1
  64:	bbc70713          	addi	a4,a4,-1092 # c1c <malloc+0x23e>
  68:	953a                	add	a0,a0,a4
  6a:	411c                	lw	a5,0(a0)
  6c:	97ba                	add	a5,a5,a4
  6e:	8782                	jr	a5
  70:	00001517          	auipc	a0,0x1
  74:	a9050513          	addi	a0,a0,-1392 # b00 <malloc+0x122>
  78:	a83d                	j	b6 <syscall_name+0xb6>
        case 1 << 21: return "close";
        case 1 << 22: return "waitx";
        case 1 << 23: return "settickets";
        case 1 << 24: return "getSysCount";
        // Add more cases for other syscalls as needed
        default: return "unknown syscall";
  7a:	00001517          	auipc	a0,0x1
  7e:	a5650513          	addi	a0,a0,-1450 # ad0 <malloc+0xf2>
  82:	a815                	j	b6 <syscall_name+0xb6>
    switch(mask) {
  84:	04000713          	li	a4,64
  88:	12e51063          	bne	a0,a4,1a8 <syscall_name+0x1a8>
        case 1 << 6: return "kill";
  8c:	00001517          	auipc	a0,0x1
  90:	a9450513          	addi	a0,a0,-1388 # b20 <malloc+0x142>
  94:	a00d                	j	b6 <syscall_name+0xb6>
    switch(mask) {
  96:	10000713          	li	a4,256
        case 1 << 8: return "fstat";
  9a:	00001517          	auipc	a0,0x1
  9e:	a7e50513          	addi	a0,a0,-1410 # b18 <malloc+0x13a>
    switch(mask) {
  a2:	00e78a63          	beq	a5,a4,b6 <syscall_name+0xb6>
  a6:	20000713          	li	a4,512
  aa:	10e79963          	bne	a5,a4,1bc <syscall_name+0x1bc>
        case 1 << 9: return "chdir";
  ae:	00001517          	auipc	a0,0x1
  b2:	a7a50513          	addi	a0,a0,-1414 # b28 <malloc+0x14a>
    }
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret
    switch(mask) {
  bc:	00080737          	lui	a4,0x80
  c0:	10e50863          	beq	a0,a4,1d0 <syscall_name+0x1d0>
  c4:	02a75963          	bge	a4,a0,f6 <syscall_name+0xf6>
  c8:	00400737          	lui	a4,0x400
  cc:	12e50663          	beq	a0,a4,1f8 <syscall_name+0x1f8>
  d0:	06a75863          	bge	a4,a0,140 <syscall_name+0x140>
  d4:	00800737          	lui	a4,0x800
        case 1 << 23: return "settickets";
  d8:	00001517          	auipc	a0,0x1
  dc:	ab850513          	addi	a0,a0,-1352 # b90 <malloc+0x1b2>
    switch(mask) {
  e0:	fce78be3          	beq	a5,a4,b6 <syscall_name+0xb6>
  e4:	01000737          	lui	a4,0x1000
  e8:	12e79263          	bne	a5,a4,20c <syscall_name+0x20c>
        case 1 << 24: return "getSysCount";
  ec:	00001517          	auipc	a0,0x1
  f0:	ab450513          	addi	a0,a0,-1356 # ba0 <malloc+0x1c2>
  f4:	b7c9                	j	b6 <syscall_name+0xb6>
    switch(mask) {
  f6:	6741                	lui	a4,0x10
  f8:	0ee50163          	beq	a0,a4,1da <syscall_name+0x1da>
  fc:	02a75363          	bge	a4,a0,122 <syscall_name+0x122>
 100:	00020737          	lui	a4,0x20
        case 1 << 17: return "mknod";
 104:	00001517          	auipc	a0,0x1
 108:	a5c50513          	addi	a0,a0,-1444 # b60 <malloc+0x182>
    switch(mask) {
 10c:	fae785e3          	beq	a5,a4,b6 <syscall_name+0xb6>
 110:	00040737          	lui	a4,0x40
 114:	0ce79d63          	bne	a5,a4,1ee <syscall_name+0x1ee>
        case 1 << 18: return "unlink";
 118:	00001517          	auipc	a0,0x1
 11c:	a6850513          	addi	a0,a0,-1432 # b80 <malloc+0x1a2>
 120:	bf59                	j	b6 <syscall_name+0xb6>
    switch(mask) {
 122:	6711                	lui	a4,0x4
        case 1 << 14: return "uptime";
 124:	00001517          	auipc	a0,0x1
 128:	a2450513          	addi	a0,a0,-1500 # b48 <malloc+0x16a>
    switch(mask) {
 12c:	f8e785e3          	beq	a5,a4,b6 <syscall_name+0xb6>
 130:	6721                	lui	a4,0x8
 132:	0ae79963          	bne	a5,a4,1e4 <syscall_name+0x1e4>
        case 1 << 15: return "open";
 136:	00001517          	auipc	a0,0x1
 13a:	a2250513          	addi	a0,a0,-1502 # b58 <malloc+0x17a>
 13e:	bfa5                	j	b6 <syscall_name+0xb6>
    switch(mask) {
 140:	00100737          	lui	a4,0x100
        case 1 << 20: return "mkdir";
 144:	00001517          	auipc	a0,0x1
 148:	a3450513          	addi	a0,a0,-1484 # b78 <malloc+0x19a>
    switch(mask) {
 14c:	f6e785e3          	beq	a5,a4,b6 <syscall_name+0xb6>
 150:	00200737          	lui	a4,0x200
 154:	0ae79763          	bne	a5,a4,202 <syscall_name+0x202>
        case 1 << 21: return "close";
 158:	00001517          	auipc	a0,0x1
 15c:	a3050513          	addi	a0,a0,-1488 # b88 <malloc+0x1aa>
 160:	bf99                	j	b6 <syscall_name+0xb6>
        case 1 << 3: return "wait";
 162:	00001517          	auipc	a0,0x1
 166:	98650513          	addi	a0,a0,-1658 # ae8 <malloc+0x10a>
 16a:	b7b1                	j	b6 <syscall_name+0xb6>
        case 1 << 4: return "pipe";
 16c:	00001517          	auipc	a0,0x1
 170:	98450513          	addi	a0,a0,-1660 # af0 <malloc+0x112>
 174:	b789                	j	b6 <syscall_name+0xb6>
        case 1 << 5: return "read";
 176:	00001517          	auipc	a0,0x1
 17a:	98250513          	addi	a0,a0,-1662 # af8 <malloc+0x11a>
 17e:	bf25                	j	b6 <syscall_name+0xb6>
        case 1 << 13: return "sleep";
 180:	00001517          	auipc	a0,0x1
 184:	98850513          	addi	a0,a0,-1656 # b08 <malloc+0x12a>
 188:	b73d                	j	b6 <syscall_name+0xb6>
        case 1 << 7: return "exec";
 18a:	00001517          	auipc	a0,0x1
 18e:	9ae50513          	addi	a0,a0,-1618 # b38 <malloc+0x15a>
 192:	b715                	j	b6 <syscall_name+0xb6>
        default: return "unknown syscall";
 194:	00001517          	auipc	a0,0x1
 198:	93c50513          	addi	a0,a0,-1732 # ad0 <malloc+0xf2>
 19c:	bf29                	j	b6 <syscall_name+0xb6>
        case 1 << 1: return "fork";
 19e:	00001517          	auipc	a0,0x1
 1a2:	94250513          	addi	a0,a0,-1726 # ae0 <malloc+0x102>
 1a6:	bf01                	j	b6 <syscall_name+0xb6>
        default: return "unknown syscall";
 1a8:	00001517          	auipc	a0,0x1
 1ac:	92850513          	addi	a0,a0,-1752 # ad0 <malloc+0xf2>
 1b0:	b719                	j	b6 <syscall_name+0xb6>
        case 1 << 10: return "dup";
 1b2:	00001517          	auipc	a0,0x1
 1b6:	95e50513          	addi	a0,a0,-1698 # b10 <malloc+0x132>
 1ba:	bdf5                	j	b6 <syscall_name+0xb6>
        default: return "unknown syscall";
 1bc:	00001517          	auipc	a0,0x1
 1c0:	91450513          	addi	a0,a0,-1772 # ad0 <malloc+0xf2>
 1c4:	bdcd                	j	b6 <syscall_name+0xb6>
 1c6:	00001517          	auipc	a0,0x1
 1ca:	90a50513          	addi	a0,a0,-1782 # ad0 <malloc+0xf2>
 1ce:	b5e5                	j	b6 <syscall_name+0xb6>
        case 1 << 19: return "link";
 1d0:	00001517          	auipc	a0,0x1
 1d4:	98050513          	addi	a0,a0,-1664 # b50 <malloc+0x172>
 1d8:	bdf9                	j	b6 <syscall_name+0xb6>
        case 1 << 16: return "write";
 1da:	00001517          	auipc	a0,0x1
 1de:	96650513          	addi	a0,a0,-1690 # b40 <malloc+0x162>
 1e2:	bdd1                	j	b6 <syscall_name+0xb6>
        default: return "unknown syscall";
 1e4:	00001517          	auipc	a0,0x1
 1e8:	8ec50513          	addi	a0,a0,-1812 # ad0 <malloc+0xf2>
 1ec:	b5e9                	j	b6 <syscall_name+0xb6>
 1ee:	00001517          	auipc	a0,0x1
 1f2:	8e250513          	addi	a0,a0,-1822 # ad0 <malloc+0xf2>
 1f6:	b5c1                	j	b6 <syscall_name+0xb6>
        case 1 << 22: return "waitx";
 1f8:	00001517          	auipc	a0,0x1
 1fc:	97850513          	addi	a0,a0,-1672 # b70 <malloc+0x192>
 200:	bd5d                	j	b6 <syscall_name+0xb6>
        default: return "unknown syscall";
 202:	00001517          	auipc	a0,0x1
 206:	8ce50513          	addi	a0,a0,-1842 # ad0 <malloc+0xf2>
 20a:	b575                	j	b6 <syscall_name+0xb6>
 20c:	00001517          	auipc	a0,0x1
 210:	8c450513          	addi	a0,a0,-1852 # ad0 <malloc+0xf2>
 214:	b54d                	j	b6 <syscall_name+0xb6>

0000000000000216 <main>:

int main(int argc, char *argv[]) {
 216:	7139                	addi	sp,sp,-64
 218:	fc06                	sd	ra,56(sp)
 21a:	f822                	sd	s0,48(sp)
 21c:	f426                	sd	s1,40(sp)
 21e:	f04a                	sd	s2,32(sp)
 220:	ec4e                	sd	s3,24(sp)
 222:	0080                	addi	s0,sp,64
    char i = '2';
 224:	03200793          	li	a5,50
 228:	fcf407a3          	sb	a5,-49(s0)
    if (argc < 3) {
 22c:	4789                	li	a5,2
 22e:	02a7c163          	blt	a5,a0,250 <main+0x3a>
        printf(&i, "Usage: syscount <mask> <command> [args...]\n");
 232:	00001597          	auipc	a1,0x1
 236:	97e58593          	addi	a1,a1,-1666 # bb0 <malloc+0x1d2>
 23a:	fcf40513          	addi	a0,s0,-49
 23e:	00000097          	auipc	ra,0x0
 242:	6e2080e7          	jalr	1762(ra) # 920 <printf>
        exit(1);
 246:	4505                	li	a0,1
 248:	00000097          	auipc	ra,0x0
 24c:	338080e7          	jalr	824(ra) # 580 <exit>
 250:	84ae                	mv	s1,a1
    }

    int mask = atoi(argv[1]);
 252:	6588                	ld	a0,8(a1)
 254:	00000097          	auipc	ra,0x0
 258:	230080e7          	jalr	560(ra) # 484 <atoi>
 25c:	89aa                	mv	s3,a0
    int pid = fork();
 25e:	00000097          	auipc	ra,0x0
 262:	31a080e7          	jalr	794(ra) # 578 <fork>
 266:	892a                	mv	s2,a0
    if (pid < 0) {
 268:	02054963          	bltz	a0,29a <main+0x84>
        printf(&i, "fork failed\n");
        exit(1);
    }

    if (pid == 0) {  // Child process
 26c:	e531                	bnez	a0,2b8 <main+0xa2>
        exec(argv[2], argv + 2);
 26e:	01048593          	addi	a1,s1,16
 272:	6888                	ld	a0,16(s1)
 274:	00000097          	auipc	ra,0x0
 278:	344080e7          	jalr	836(ra) # 5b8 <exec>
        printf(&i, "exec failed\n");
 27c:	00001597          	auipc	a1,0x1
 280:	97458593          	addi	a1,a1,-1676 # bf0 <malloc+0x212>
 284:	fcf40513          	addi	a0,s0,-49
 288:	00000097          	auipc	ra,0x0
 28c:	698080e7          	jalr	1688(ra) # 920 <printf>
        exit(1);
 290:	4505                	li	a0,1
 292:	00000097          	auipc	ra,0x0
 296:	2ee080e7          	jalr	750(ra) # 580 <exit>
        printf(&i, "fork failed\n");
 29a:	00001597          	auipc	a1,0x1
 29e:	94658593          	addi	a1,a1,-1722 # be0 <malloc+0x202>
 2a2:	fcf40513          	addi	a0,s0,-49
 2a6:	00000097          	auipc	ra,0x0
 2aa:	67a080e7          	jalr	1658(ra) # 920 <printf>
        exit(1);
 2ae:	4505                	li	a0,1
 2b0:	00000097          	auipc	ra,0x0
 2b4:	2d0080e7          	jalr	720(ra) # 580 <exit>
    } else {  // Parent process
        wait(0);
 2b8:	4501                	li	a0,0
 2ba:	00000097          	auipc	ra,0x0
 2be:	2ce080e7          	jalr	718(ra) # 588 <wait>
        int count = getSysCount(mask);
 2c2:	854e                	mv	a0,s3
 2c4:	00000097          	auipc	ra,0x0
 2c8:	36c080e7          	jalr	876(ra) # 630 <getSysCount>
 2cc:	84aa                	mv	s1,a0
        printf("PID %d called %s %d times\n", pid, syscall_name(mask), count);
 2ce:	854e                	mv	a0,s3
 2d0:	00000097          	auipc	ra,0x0
 2d4:	d30080e7          	jalr	-720(ra) # 0 <syscall_name>
 2d8:	862a                	mv	a2,a0
 2da:	86a6                	mv	a3,s1
 2dc:	85ca                	mv	a1,s2
 2de:	00001517          	auipc	a0,0x1
 2e2:	92250513          	addi	a0,a0,-1758 # c00 <malloc+0x222>
 2e6:	00000097          	auipc	ra,0x0
 2ea:	63a080e7          	jalr	1594(ra) # 920 <printf>
    }
    exit(0);
 2ee:	4501                	li	a0,0
 2f0:	00000097          	auipc	ra,0x0
 2f4:	290080e7          	jalr	656(ra) # 580 <exit>

00000000000002f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 300:	00000097          	auipc	ra,0x0
 304:	f16080e7          	jalr	-234(ra) # 216 <main>
  exit(0);
 308:	4501                	li	a0,0
 30a:	00000097          	auipc	ra,0x0
 30e:	276080e7          	jalr	630(ra) # 580 <exit>

0000000000000312 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 318:	87aa                	mv	a5,a0
 31a:	0585                	addi	a1,a1,1
 31c:	0785                	addi	a5,a5,1
 31e:	fff5c703          	lbu	a4,-1(a1)
 322:	fee78fa3          	sb	a4,-1(a5)
 326:	fb75                	bnez	a4,31a <strcpy+0x8>
    ;
  return os;
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret

000000000000032e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 334:	00054783          	lbu	a5,0(a0)
 338:	cb91                	beqz	a5,34c <strcmp+0x1e>
 33a:	0005c703          	lbu	a4,0(a1)
 33e:	00f71763          	bne	a4,a5,34c <strcmp+0x1e>
    p++, q++;
 342:	0505                	addi	a0,a0,1
 344:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 346:	00054783          	lbu	a5,0(a0)
 34a:	fbe5                	bnez	a5,33a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 34c:	0005c503          	lbu	a0,0(a1)
}
 350:	40a7853b          	subw	a0,a5,a0
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <strlen>:

uint
strlen(const char *s)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 360:	00054783          	lbu	a5,0(a0)
 364:	cf91                	beqz	a5,380 <strlen+0x26>
 366:	0505                	addi	a0,a0,1
 368:	87aa                	mv	a5,a0
 36a:	4685                	li	a3,1
 36c:	9e89                	subw	a3,a3,a0
 36e:	00f6853b          	addw	a0,a3,a5
 372:	0785                	addi	a5,a5,1
 374:	fff7c703          	lbu	a4,-1(a5)
 378:	fb7d                	bnez	a4,36e <strlen+0x14>
    ;
  return n;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  for(n = 0; s[n]; n++)
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <strlen+0x20>

0000000000000384 <memset>:

void*
memset(void *dst, int c, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 38a:	ca19                	beqz	a2,3a0 <memset+0x1c>
 38c:	87aa                	mv	a5,a0
 38e:	1602                	slli	a2,a2,0x20
 390:	9201                	srli	a2,a2,0x20
 392:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 396:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 39a:	0785                	addi	a5,a5,1
 39c:	fee79de3          	bne	a5,a4,396 <memset+0x12>
  }
  return dst;
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <strchr>:

char*
strchr(const char *s, char c)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e422                	sd	s0,8(sp)
 3aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	cb99                	beqz	a5,3c6 <strchr+0x20>
    if(*s == c)
 3b2:	00f58763          	beq	a1,a5,3c0 <strchr+0x1a>
  for(; *s; s++)
 3b6:	0505                	addi	a0,a0,1
 3b8:	00054783          	lbu	a5,0(a0)
 3bc:	fbfd                	bnez	a5,3b2 <strchr+0xc>
      return (char*)s;
  return 0;
 3be:	4501                	li	a0,0
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <strchr+0x1a>

00000000000003ca <gets>:

char*
gets(char *buf, int max)
{
 3ca:	711d                	addi	sp,sp,-96
 3cc:	ec86                	sd	ra,88(sp)
 3ce:	e8a2                	sd	s0,80(sp)
 3d0:	e4a6                	sd	s1,72(sp)
 3d2:	e0ca                	sd	s2,64(sp)
 3d4:	fc4e                	sd	s3,56(sp)
 3d6:	f852                	sd	s4,48(sp)
 3d8:	f456                	sd	s5,40(sp)
 3da:	f05a                	sd	s6,32(sp)
 3dc:	ec5e                	sd	s7,24(sp)
 3de:	1080                	addi	s0,sp,96
 3e0:	8baa                	mv	s7,a0
 3e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e4:	892a                	mv	s2,a0
 3e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3e8:	4aa9                	li	s5,10
 3ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3ec:	89a6                	mv	s3,s1
 3ee:	2485                	addiw	s1,s1,1
 3f0:	0344d863          	bge	s1,s4,420 <gets+0x56>
    cc = read(0, &c, 1);
 3f4:	4605                	li	a2,1
 3f6:	faf40593          	addi	a1,s0,-81
 3fa:	4501                	li	a0,0
 3fc:	00000097          	auipc	ra,0x0
 400:	19c080e7          	jalr	412(ra) # 598 <read>
    if(cc < 1)
 404:	00a05e63          	blez	a0,420 <gets+0x56>
    buf[i++] = c;
 408:	faf44783          	lbu	a5,-81(s0)
 40c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 410:	01578763          	beq	a5,s5,41e <gets+0x54>
 414:	0905                	addi	s2,s2,1
 416:	fd679be3          	bne	a5,s6,3ec <gets+0x22>
  for(i=0; i+1 < max; ){
 41a:	89a6                	mv	s3,s1
 41c:	a011                	j	420 <gets+0x56>
 41e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 420:	99de                	add	s3,s3,s7
 422:	00098023          	sb	zero,0(s3)
  return buf;
}
 426:	855e                	mv	a0,s7
 428:	60e6                	ld	ra,88(sp)
 42a:	6446                	ld	s0,80(sp)
 42c:	64a6                	ld	s1,72(sp)
 42e:	6906                	ld	s2,64(sp)
 430:	79e2                	ld	s3,56(sp)
 432:	7a42                	ld	s4,48(sp)
 434:	7aa2                	ld	s5,40(sp)
 436:	7b02                	ld	s6,32(sp)
 438:	6be2                	ld	s7,24(sp)
 43a:	6125                	addi	sp,sp,96
 43c:	8082                	ret

000000000000043e <stat>:

int
stat(const char *n, struct stat *st)
{
 43e:	1101                	addi	sp,sp,-32
 440:	ec06                	sd	ra,24(sp)
 442:	e822                	sd	s0,16(sp)
 444:	e426                	sd	s1,8(sp)
 446:	e04a                	sd	s2,0(sp)
 448:	1000                	addi	s0,sp,32
 44a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 44c:	4581                	li	a1,0
 44e:	00000097          	auipc	ra,0x0
 452:	172080e7          	jalr	370(ra) # 5c0 <open>
  if(fd < 0)
 456:	02054563          	bltz	a0,480 <stat+0x42>
 45a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 45c:	85ca                	mv	a1,s2
 45e:	00000097          	auipc	ra,0x0
 462:	17a080e7          	jalr	378(ra) # 5d8 <fstat>
 466:	892a                	mv	s2,a0
  close(fd);
 468:	8526                	mv	a0,s1
 46a:	00000097          	auipc	ra,0x0
 46e:	13e080e7          	jalr	318(ra) # 5a8 <close>
  return r;
}
 472:	854a                	mv	a0,s2
 474:	60e2                	ld	ra,24(sp)
 476:	6442                	ld	s0,16(sp)
 478:	64a2                	ld	s1,8(sp)
 47a:	6902                	ld	s2,0(sp)
 47c:	6105                	addi	sp,sp,32
 47e:	8082                	ret
    return -1;
 480:	597d                	li	s2,-1
 482:	bfc5                	j	472 <stat+0x34>

0000000000000484 <atoi>:

int
atoi(const char *s)
{
 484:	1141                	addi	sp,sp,-16
 486:	e422                	sd	s0,8(sp)
 488:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 48a:	00054603          	lbu	a2,0(a0)
 48e:	fd06079b          	addiw	a5,a2,-48
 492:	0ff7f793          	andi	a5,a5,255
 496:	4725                	li	a4,9
 498:	02f76963          	bltu	a4,a5,4ca <atoi+0x46>
 49c:	86aa                	mv	a3,a0
  n = 0;
 49e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4a0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4a2:	0685                	addi	a3,a3,1
 4a4:	0025179b          	slliw	a5,a0,0x2
 4a8:	9fa9                	addw	a5,a5,a0
 4aa:	0017979b          	slliw	a5,a5,0x1
 4ae:	9fb1                	addw	a5,a5,a2
 4b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4b4:	0006c603          	lbu	a2,0(a3)
 4b8:	fd06071b          	addiw	a4,a2,-48
 4bc:	0ff77713          	andi	a4,a4,255
 4c0:	fee5f1e3          	bgeu	a1,a4,4a2 <atoi+0x1e>
  return n;
}
 4c4:	6422                	ld	s0,8(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret
  n = 0;
 4ca:	4501                	li	a0,0
 4cc:	bfe5                	j	4c4 <atoi+0x40>

00000000000004ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4ce:	1141                	addi	sp,sp,-16
 4d0:	e422                	sd	s0,8(sp)
 4d2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4d4:	02b57463          	bgeu	a0,a1,4fc <memmove+0x2e>
    while(n-- > 0)
 4d8:	00c05f63          	blez	a2,4f6 <memmove+0x28>
 4dc:	1602                	slli	a2,a2,0x20
 4de:	9201                	srli	a2,a2,0x20
 4e0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4e4:	872a                	mv	a4,a0
      *dst++ = *src++;
 4e6:	0585                	addi	a1,a1,1
 4e8:	0705                	addi	a4,a4,1
 4ea:	fff5c683          	lbu	a3,-1(a1)
 4ee:	fed70fa3          	sb	a3,-1(a4) # 1fffff <base+0x1fefef>
    while(n-- > 0)
 4f2:	fee79ae3          	bne	a5,a4,4e6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4f6:	6422                	ld	s0,8(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret
    dst += n;
 4fc:	00c50733          	add	a4,a0,a2
    src += n;
 500:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 502:	fec05ae3          	blez	a2,4f6 <memmove+0x28>
 506:	fff6079b          	addiw	a5,a2,-1
 50a:	1782                	slli	a5,a5,0x20
 50c:	9381                	srli	a5,a5,0x20
 50e:	fff7c793          	not	a5,a5
 512:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 514:	15fd                	addi	a1,a1,-1
 516:	177d                	addi	a4,a4,-1
 518:	0005c683          	lbu	a3,0(a1)
 51c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 520:	fee79ae3          	bne	a5,a4,514 <memmove+0x46>
 524:	bfc9                	j	4f6 <memmove+0x28>

0000000000000526 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 526:	1141                	addi	sp,sp,-16
 528:	e422                	sd	s0,8(sp)
 52a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 52c:	ca05                	beqz	a2,55c <memcmp+0x36>
 52e:	fff6069b          	addiw	a3,a2,-1
 532:	1682                	slli	a3,a3,0x20
 534:	9281                	srli	a3,a3,0x20
 536:	0685                	addi	a3,a3,1
 538:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 53a:	00054783          	lbu	a5,0(a0)
 53e:	0005c703          	lbu	a4,0(a1)
 542:	00e79863          	bne	a5,a4,552 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 546:	0505                	addi	a0,a0,1
    p2++;
 548:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 54a:	fed518e3          	bne	a0,a3,53a <memcmp+0x14>
  }
  return 0;
 54e:	4501                	li	a0,0
 550:	a019                	j	556 <memcmp+0x30>
      return *p1 - *p2;
 552:	40e7853b          	subw	a0,a5,a4
}
 556:	6422                	ld	s0,8(sp)
 558:	0141                	addi	sp,sp,16
 55a:	8082                	ret
  return 0;
 55c:	4501                	li	a0,0
 55e:	bfe5                	j	556 <memcmp+0x30>

0000000000000560 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 560:	1141                	addi	sp,sp,-16
 562:	e406                	sd	ra,8(sp)
 564:	e022                	sd	s0,0(sp)
 566:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 568:	00000097          	auipc	ra,0x0
 56c:	f66080e7          	jalr	-154(ra) # 4ce <memmove>
}
 570:	60a2                	ld	ra,8(sp)
 572:	6402                	ld	s0,0(sp)
 574:	0141                	addi	sp,sp,16
 576:	8082                	ret

0000000000000578 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 578:	4885                	li	a7,1
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <exit>:
.global exit
exit:
 li a7, SYS_exit
 580:	4889                	li	a7,2
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <wait>:
.global wait
wait:
 li a7, SYS_wait
 588:	488d                	li	a7,3
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 590:	4891                	li	a7,4
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <read>:
.global read
read:
 li a7, SYS_read
 598:	4895                	li	a7,5
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <write>:
.global write
write:
 li a7, SYS_write
 5a0:	48c1                	li	a7,16
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <close>:
.global close
close:
 li a7, SYS_close
 5a8:	48d5                	li	a7,21
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5b0:	4899                	li	a7,6
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5b8:	489d                	li	a7,7
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <open>:
.global open
open:
 li a7, SYS_open
 5c0:	48bd                	li	a7,15
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5c8:	48c5                	li	a7,17
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5d0:	48c9                	li	a7,18
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5d8:	48a1                	li	a7,8
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <link>:
.global link
link:
 li a7, SYS_link
 5e0:	48cd                	li	a7,19
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5e8:	48d1                	li	a7,20
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5f0:	48a5                	li	a7,9
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5f8:	48a9                	li	a7,10
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 600:	48ad                	li	a7,11
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 608:	48b1                	li	a7,12
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 610:	48b5                	li	a7,13
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 618:	48b9                	li	a7,14
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 620:	48d9                	li	a7,22
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 628:	48dd                	li	a7,23
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 630:	48e1                	li	a7,24
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 638:	48e5                	li	a7,25
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 640:	48e9                	li	a7,26
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 648:	1101                	addi	sp,sp,-32
 64a:	ec06                	sd	ra,24(sp)
 64c:	e822                	sd	s0,16(sp)
 64e:	1000                	addi	s0,sp,32
 650:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 654:	4605                	li	a2,1
 656:	fef40593          	addi	a1,s0,-17
 65a:	00000097          	auipc	ra,0x0
 65e:	f46080e7          	jalr	-186(ra) # 5a0 <write>
}
 662:	60e2                	ld	ra,24(sp)
 664:	6442                	ld	s0,16(sp)
 666:	6105                	addi	sp,sp,32
 668:	8082                	ret

000000000000066a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 66a:	7139                	addi	sp,sp,-64
 66c:	fc06                	sd	ra,56(sp)
 66e:	f822                	sd	s0,48(sp)
 670:	f426                	sd	s1,40(sp)
 672:	f04a                	sd	s2,32(sp)
 674:	ec4e                	sd	s3,24(sp)
 676:	0080                	addi	s0,sp,64
 678:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 67a:	c299                	beqz	a3,680 <printint+0x16>
 67c:	0805c863          	bltz	a1,70c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 680:	2581                	sext.w	a1,a1
  neg = 0;
 682:	4881                	li	a7,0
 684:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 688:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 68a:	2601                	sext.w	a2,a2
 68c:	00000517          	auipc	a0,0x0
 690:	61c50513          	addi	a0,a0,1564 # ca8 <digits>
 694:	883a                	mv	a6,a4
 696:	2705                	addiw	a4,a4,1
 698:	02c5f7bb          	remuw	a5,a1,a2
 69c:	1782                	slli	a5,a5,0x20
 69e:	9381                	srli	a5,a5,0x20
 6a0:	97aa                	add	a5,a5,a0
 6a2:	0007c783          	lbu	a5,0(a5)
 6a6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6aa:	0005879b          	sext.w	a5,a1
 6ae:	02c5d5bb          	divuw	a1,a1,a2
 6b2:	0685                	addi	a3,a3,1
 6b4:	fec7f0e3          	bgeu	a5,a2,694 <printint+0x2a>
  if(neg)
 6b8:	00088b63          	beqz	a7,6ce <printint+0x64>
    buf[i++] = '-';
 6bc:	fd040793          	addi	a5,s0,-48
 6c0:	973e                	add	a4,a4,a5
 6c2:	02d00793          	li	a5,45
 6c6:	fef70823          	sb	a5,-16(a4)
 6ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ce:	02e05863          	blez	a4,6fe <printint+0x94>
 6d2:	fc040793          	addi	a5,s0,-64
 6d6:	00e78933          	add	s2,a5,a4
 6da:	fff78993          	addi	s3,a5,-1
 6de:	99ba                	add	s3,s3,a4
 6e0:	377d                	addiw	a4,a4,-1
 6e2:	1702                	slli	a4,a4,0x20
 6e4:	9301                	srli	a4,a4,0x20
 6e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6ea:	fff94583          	lbu	a1,-1(s2)
 6ee:	8526                	mv	a0,s1
 6f0:	00000097          	auipc	ra,0x0
 6f4:	f58080e7          	jalr	-168(ra) # 648 <putc>
  while(--i >= 0)
 6f8:	197d                	addi	s2,s2,-1
 6fa:	ff3918e3          	bne	s2,s3,6ea <printint+0x80>
}
 6fe:	70e2                	ld	ra,56(sp)
 700:	7442                	ld	s0,48(sp)
 702:	74a2                	ld	s1,40(sp)
 704:	7902                	ld	s2,32(sp)
 706:	69e2                	ld	s3,24(sp)
 708:	6121                	addi	sp,sp,64
 70a:	8082                	ret
    x = -xx;
 70c:	40b005bb          	negw	a1,a1
    neg = 1;
 710:	4885                	li	a7,1
    x = -xx;
 712:	bf8d                	j	684 <printint+0x1a>

0000000000000714 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 714:	7119                	addi	sp,sp,-128
 716:	fc86                	sd	ra,120(sp)
 718:	f8a2                	sd	s0,112(sp)
 71a:	f4a6                	sd	s1,104(sp)
 71c:	f0ca                	sd	s2,96(sp)
 71e:	ecce                	sd	s3,88(sp)
 720:	e8d2                	sd	s4,80(sp)
 722:	e4d6                	sd	s5,72(sp)
 724:	e0da                	sd	s6,64(sp)
 726:	fc5e                	sd	s7,56(sp)
 728:	f862                	sd	s8,48(sp)
 72a:	f466                	sd	s9,40(sp)
 72c:	f06a                	sd	s10,32(sp)
 72e:	ec6e                	sd	s11,24(sp)
 730:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 732:	0005c903          	lbu	s2,0(a1)
 736:	18090f63          	beqz	s2,8d4 <vprintf+0x1c0>
 73a:	8aaa                	mv	s5,a0
 73c:	8b32                	mv	s6,a2
 73e:	00158493          	addi	s1,a1,1
  state = 0;
 742:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 744:	02500a13          	li	s4,37
      if(c == 'd'){
 748:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 74c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 750:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 754:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 758:	00000b97          	auipc	s7,0x0
 75c:	550b8b93          	addi	s7,s7,1360 # ca8 <digits>
 760:	a839                	j	77e <vprintf+0x6a>
        putc(fd, c);
 762:	85ca                	mv	a1,s2
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	ee2080e7          	jalr	-286(ra) # 648 <putc>
 76e:	a019                	j	774 <vprintf+0x60>
    } else if(state == '%'){
 770:	01498f63          	beq	s3,s4,78e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 774:	0485                	addi	s1,s1,1
 776:	fff4c903          	lbu	s2,-1(s1)
 77a:	14090d63          	beqz	s2,8d4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 77e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 782:	fe0997e3          	bnez	s3,770 <vprintf+0x5c>
      if(c == '%'){
 786:	fd479ee3          	bne	a5,s4,762 <vprintf+0x4e>
        state = '%';
 78a:	89be                	mv	s3,a5
 78c:	b7e5                	j	774 <vprintf+0x60>
      if(c == 'd'){
 78e:	05878063          	beq	a5,s8,7ce <vprintf+0xba>
      } else if(c == 'l') {
 792:	05978c63          	beq	a5,s9,7ea <vprintf+0xd6>
      } else if(c == 'x') {
 796:	07a78863          	beq	a5,s10,806 <vprintf+0xf2>
      } else if(c == 'p') {
 79a:	09b78463          	beq	a5,s11,822 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 79e:	07300713          	li	a4,115
 7a2:	0ce78663          	beq	a5,a4,86e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7a6:	06300713          	li	a4,99
 7aa:	0ee78e63          	beq	a5,a4,8a6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ae:	11478863          	beq	a5,s4,8be <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7b2:	85d2                	mv	a1,s4
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	e92080e7          	jalr	-366(ra) # 648 <putc>
        putc(fd, c);
 7be:	85ca                	mv	a1,s2
 7c0:	8556                	mv	a0,s5
 7c2:	00000097          	auipc	ra,0x0
 7c6:	e86080e7          	jalr	-378(ra) # 648 <putc>
      }
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b765                	j	774 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7ce:	008b0913          	addi	s2,s6,8
 7d2:	4685                	li	a3,1
 7d4:	4629                	li	a2,10
 7d6:	000b2583          	lw	a1,0(s6)
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e8e080e7          	jalr	-370(ra) # 66a <printint>
 7e4:	8b4a                	mv	s6,s2
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b771                	j	774 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ea:	008b0913          	addi	s2,s6,8
 7ee:	4681                	li	a3,0
 7f0:	4629                	li	a2,10
 7f2:	000b2583          	lw	a1,0(s6)
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	e72080e7          	jalr	-398(ra) # 66a <printint>
 800:	8b4a                	mv	s6,s2
      state = 0;
 802:	4981                	li	s3,0
 804:	bf85                	j	774 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 806:	008b0913          	addi	s2,s6,8
 80a:	4681                	li	a3,0
 80c:	4641                	li	a2,16
 80e:	000b2583          	lw	a1,0(s6)
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	e56080e7          	jalr	-426(ra) # 66a <printint>
 81c:	8b4a                	mv	s6,s2
      state = 0;
 81e:	4981                	li	s3,0
 820:	bf91                	j	774 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 822:	008b0793          	addi	a5,s6,8
 826:	f8f43423          	sd	a5,-120(s0)
 82a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 82e:	03000593          	li	a1,48
 832:	8556                	mv	a0,s5
 834:	00000097          	auipc	ra,0x0
 838:	e14080e7          	jalr	-492(ra) # 648 <putc>
  putc(fd, 'x');
 83c:	85ea                	mv	a1,s10
 83e:	8556                	mv	a0,s5
 840:	00000097          	auipc	ra,0x0
 844:	e08080e7          	jalr	-504(ra) # 648 <putc>
 848:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 84a:	03c9d793          	srli	a5,s3,0x3c
 84e:	97de                	add	a5,a5,s7
 850:	0007c583          	lbu	a1,0(a5)
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	df2080e7          	jalr	-526(ra) # 648 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 85e:	0992                	slli	s3,s3,0x4
 860:	397d                	addiw	s2,s2,-1
 862:	fe0914e3          	bnez	s2,84a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 866:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 86a:	4981                	li	s3,0
 86c:	b721                	j	774 <vprintf+0x60>
        s = va_arg(ap, char*);
 86e:	008b0993          	addi	s3,s6,8
 872:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 876:	02090163          	beqz	s2,898 <vprintf+0x184>
        while(*s != 0){
 87a:	00094583          	lbu	a1,0(s2)
 87e:	c9a1                	beqz	a1,8ce <vprintf+0x1ba>
          putc(fd, *s);
 880:	8556                	mv	a0,s5
 882:	00000097          	auipc	ra,0x0
 886:	dc6080e7          	jalr	-570(ra) # 648 <putc>
          s++;
 88a:	0905                	addi	s2,s2,1
        while(*s != 0){
 88c:	00094583          	lbu	a1,0(s2)
 890:	f9e5                	bnez	a1,880 <vprintf+0x16c>
        s = va_arg(ap, char*);
 892:	8b4e                	mv	s6,s3
      state = 0;
 894:	4981                	li	s3,0
 896:	bdf9                	j	774 <vprintf+0x60>
          s = "(null)";
 898:	00000917          	auipc	s2,0x0
 89c:	40890913          	addi	s2,s2,1032 # ca0 <malloc+0x2c2>
        while(*s != 0){
 8a0:	02800593          	li	a1,40
 8a4:	bff1                	j	880 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8a6:	008b0913          	addi	s2,s6,8
 8aa:	000b4583          	lbu	a1,0(s6)
 8ae:	8556                	mv	a0,s5
 8b0:	00000097          	auipc	ra,0x0
 8b4:	d98080e7          	jalr	-616(ra) # 648 <putc>
 8b8:	8b4a                	mv	s6,s2
      state = 0;
 8ba:	4981                	li	s3,0
 8bc:	bd65                	j	774 <vprintf+0x60>
        putc(fd, c);
 8be:	85d2                	mv	a1,s4
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	d86080e7          	jalr	-634(ra) # 648 <putc>
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	b565                	j	774 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ce:	8b4e                	mv	s6,s3
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	b54d                	j	774 <vprintf+0x60>
    }
  }
}
 8d4:	70e6                	ld	ra,120(sp)
 8d6:	7446                	ld	s0,112(sp)
 8d8:	74a6                	ld	s1,104(sp)
 8da:	7906                	ld	s2,96(sp)
 8dc:	69e6                	ld	s3,88(sp)
 8de:	6a46                	ld	s4,80(sp)
 8e0:	6aa6                	ld	s5,72(sp)
 8e2:	6b06                	ld	s6,64(sp)
 8e4:	7be2                	ld	s7,56(sp)
 8e6:	7c42                	ld	s8,48(sp)
 8e8:	7ca2                	ld	s9,40(sp)
 8ea:	7d02                	ld	s10,32(sp)
 8ec:	6de2                	ld	s11,24(sp)
 8ee:	6109                	addi	sp,sp,128
 8f0:	8082                	ret

00000000000008f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f2:	715d                	addi	sp,sp,-80
 8f4:	ec06                	sd	ra,24(sp)
 8f6:	e822                	sd	s0,16(sp)
 8f8:	1000                	addi	s0,sp,32
 8fa:	e010                	sd	a2,0(s0)
 8fc:	e414                	sd	a3,8(s0)
 8fe:	e818                	sd	a4,16(s0)
 900:	ec1c                	sd	a5,24(s0)
 902:	03043023          	sd	a6,32(s0)
 906:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 90a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 90e:	8622                	mv	a2,s0
 910:	00000097          	auipc	ra,0x0
 914:	e04080e7          	jalr	-508(ra) # 714 <vprintf>
}
 918:	60e2                	ld	ra,24(sp)
 91a:	6442                	ld	s0,16(sp)
 91c:	6161                	addi	sp,sp,80
 91e:	8082                	ret

0000000000000920 <printf>:

void
printf(const char *fmt, ...)
{
 920:	711d                	addi	sp,sp,-96
 922:	ec06                	sd	ra,24(sp)
 924:	e822                	sd	s0,16(sp)
 926:	1000                	addi	s0,sp,32
 928:	e40c                	sd	a1,8(s0)
 92a:	e810                	sd	a2,16(s0)
 92c:	ec14                	sd	a3,24(s0)
 92e:	f018                	sd	a4,32(s0)
 930:	f41c                	sd	a5,40(s0)
 932:	03043823          	sd	a6,48(s0)
 936:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 93a:	00840613          	addi	a2,s0,8
 93e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 942:	85aa                	mv	a1,a0
 944:	4505                	li	a0,1
 946:	00000097          	auipc	ra,0x0
 94a:	dce080e7          	jalr	-562(ra) # 714 <vprintf>
}
 94e:	60e2                	ld	ra,24(sp)
 950:	6442                	ld	s0,16(sp)
 952:	6125                	addi	sp,sp,96
 954:	8082                	ret

0000000000000956 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 956:	1141                	addi	sp,sp,-16
 958:	e422                	sd	s0,8(sp)
 95a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 95c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 960:	00000797          	auipc	a5,0x0
 964:	6a07b783          	ld	a5,1696(a5) # 1000 <freep>
 968:	a805                	j	998 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 96a:	4618                	lw	a4,8(a2)
 96c:	9db9                	addw	a1,a1,a4
 96e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 972:	6398                	ld	a4,0(a5)
 974:	6318                	ld	a4,0(a4)
 976:	fee53823          	sd	a4,-16(a0)
 97a:	a091                	j	9be <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 97c:	ff852703          	lw	a4,-8(a0)
 980:	9e39                	addw	a2,a2,a4
 982:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 984:	ff053703          	ld	a4,-16(a0)
 988:	e398                	sd	a4,0(a5)
 98a:	a099                	j	9d0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98c:	6398                	ld	a4,0(a5)
 98e:	00e7e463          	bltu	a5,a4,996 <free+0x40>
 992:	00e6ea63          	bltu	a3,a4,9a6 <free+0x50>
{
 996:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 998:	fed7fae3          	bgeu	a5,a3,98c <free+0x36>
 99c:	6398                	ld	a4,0(a5)
 99e:	00e6e463          	bltu	a3,a4,9a6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a2:	fee7eae3          	bltu	a5,a4,996 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9a6:	ff852583          	lw	a1,-8(a0)
 9aa:	6390                	ld	a2,0(a5)
 9ac:	02059713          	slli	a4,a1,0x20
 9b0:	9301                	srli	a4,a4,0x20
 9b2:	0712                	slli	a4,a4,0x4
 9b4:	9736                	add	a4,a4,a3
 9b6:	fae60ae3          	beq	a2,a4,96a <free+0x14>
    bp->s.ptr = p->s.ptr;
 9ba:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9be:	4790                	lw	a2,8(a5)
 9c0:	02061713          	slli	a4,a2,0x20
 9c4:	9301                	srli	a4,a4,0x20
 9c6:	0712                	slli	a4,a4,0x4
 9c8:	973e                	add	a4,a4,a5
 9ca:	fae689e3          	beq	a3,a4,97c <free+0x26>
  } else
    p->s.ptr = bp;
 9ce:	e394                	sd	a3,0(a5)
  freep = p;
 9d0:	00000717          	auipc	a4,0x0
 9d4:	62f73823          	sd	a5,1584(a4) # 1000 <freep>
}
 9d8:	6422                	ld	s0,8(sp)
 9da:	0141                	addi	sp,sp,16
 9dc:	8082                	ret

00000000000009de <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9de:	7139                	addi	sp,sp,-64
 9e0:	fc06                	sd	ra,56(sp)
 9e2:	f822                	sd	s0,48(sp)
 9e4:	f426                	sd	s1,40(sp)
 9e6:	f04a                	sd	s2,32(sp)
 9e8:	ec4e                	sd	s3,24(sp)
 9ea:	e852                	sd	s4,16(sp)
 9ec:	e456                	sd	s5,8(sp)
 9ee:	e05a                	sd	s6,0(sp)
 9f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f2:	02051493          	slli	s1,a0,0x20
 9f6:	9081                	srli	s1,s1,0x20
 9f8:	04bd                	addi	s1,s1,15
 9fa:	8091                	srli	s1,s1,0x4
 9fc:	0014899b          	addiw	s3,s1,1
 a00:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a02:	00000517          	auipc	a0,0x0
 a06:	5fe53503          	ld	a0,1534(a0) # 1000 <freep>
 a0a:	c515                	beqz	a0,a36 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0e:	4798                	lw	a4,8(a5)
 a10:	02977f63          	bgeu	a4,s1,a4e <malloc+0x70>
 a14:	8a4e                	mv	s4,s3
 a16:	0009871b          	sext.w	a4,s3
 a1a:	6685                	lui	a3,0x1
 a1c:	00d77363          	bgeu	a4,a3,a22 <malloc+0x44>
 a20:	6a05                	lui	s4,0x1
 a22:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a26:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a2a:	00000917          	auipc	s2,0x0
 a2e:	5d690913          	addi	s2,s2,1494 # 1000 <freep>
  if(p == (char*)-1)
 a32:	5afd                	li	s5,-1
 a34:	a88d                	j	aa6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a36:	00000797          	auipc	a5,0x0
 a3a:	5da78793          	addi	a5,a5,1498 # 1010 <base>
 a3e:	00000717          	auipc	a4,0x0
 a42:	5cf73123          	sd	a5,1474(a4) # 1000 <freep>
 a46:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a48:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a4c:	b7e1                	j	a14 <malloc+0x36>
      if(p->s.size == nunits)
 a4e:	02e48b63          	beq	s1,a4,a84 <malloc+0xa6>
        p->s.size -= nunits;
 a52:	4137073b          	subw	a4,a4,s3
 a56:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a58:	1702                	slli	a4,a4,0x20
 a5a:	9301                	srli	a4,a4,0x20
 a5c:	0712                	slli	a4,a4,0x4
 a5e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a60:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a64:	00000717          	auipc	a4,0x0
 a68:	58a73e23          	sd	a0,1436(a4) # 1000 <freep>
      return (void*)(p + 1);
 a6c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a70:	70e2                	ld	ra,56(sp)
 a72:	7442                	ld	s0,48(sp)
 a74:	74a2                	ld	s1,40(sp)
 a76:	7902                	ld	s2,32(sp)
 a78:	69e2                	ld	s3,24(sp)
 a7a:	6a42                	ld	s4,16(sp)
 a7c:	6aa2                	ld	s5,8(sp)
 a7e:	6b02                	ld	s6,0(sp)
 a80:	6121                	addi	sp,sp,64
 a82:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a84:	6398                	ld	a4,0(a5)
 a86:	e118                	sd	a4,0(a0)
 a88:	bff1                	j	a64 <malloc+0x86>
  hp->s.size = nu;
 a8a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a8e:	0541                	addi	a0,a0,16
 a90:	00000097          	auipc	ra,0x0
 a94:	ec6080e7          	jalr	-314(ra) # 956 <free>
  return freep;
 a98:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a9c:	d971                	beqz	a0,a70 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa0:	4798                	lw	a4,8(a5)
 aa2:	fa9776e3          	bgeu	a4,s1,a4e <malloc+0x70>
    if(p == freep)
 aa6:	00093703          	ld	a4,0(s2)
 aaa:	853e                	mv	a0,a5
 aac:	fef719e3          	bne	a4,a5,a9e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ab0:	8552                	mv	a0,s4
 ab2:	00000097          	auipc	ra,0x0
 ab6:	b56080e7          	jalr	-1194(ra) # 608 <sbrk>
  if(p == (char*)-1)
 aba:	fd5518e3          	bne	a0,s5,a8a <malloc+0xac>
        return 0;
 abe:	4501                	li	a0,0
 ac0:	bf45                	j	a70 <malloc+0x92>


user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	39e080e7          	jalr	926(ra) # 3be <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	392080e7          	jalr	914(ra) # 3c6 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	8b058593          	addi	a1,a1,-1872 # 8f0 <malloc+0xec>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6ce080e7          	jalr	1742(ra) # 718 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	352080e7          	jalr	850(ra) # 3a6 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	89a58593          	addi	a1,a1,-1894 # 908 <malloc+0x104>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	6a0080e7          	jalr	1696(ra) # 718 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	324080e7          	jalr	804(ra) # 3a6 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2) # 1010 <buf>
  ba:	00000097          	auipc	ra,0x0
  be:	32c080e7          	jalr	812(ra) # 3e6 <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	2fc080e7          	jalr	764(ra) # 3ce <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2c4080e7          	jalr	708(ra) # 3a6 <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2b0080e7          	jalr	688(ra) # 3a6 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00001597          	auipc	a1,0x1
 106:	81e58593          	addi	a1,a1,-2018 # 920 <malloc+0x11c>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	60c080e7          	jalr	1548(ra) # 718 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	290080e7          	jalr	656(ra) # 3a6 <exit>

000000000000011e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	00000097          	auipc	ra,0x0
 12a:	f64080e7          	jalr	-156(ra) # 8a <main>
  exit(0);
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	276080e7          	jalr	630(ra) # 3a6 <exit>

0000000000000138 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0x8>
    ;
  return os;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb91                	beqz	a5,172 <strcmp+0x1e>
 160:	0005c703          	lbu	a4,0(a1)
 164:	00f71763          	bne	a4,a5,172 <strcmp+0x1e>
    p++, q++;
 168:	0505                	addi	a0,a0,1
 16a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbe5                	bnez	a5,160 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 172:	0005c503          	lbu	a0,0(a1)
}
 176:	40a7853b          	subw	a0,a5,a0
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x26>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	4685                	li	a3,1
 192:	9e89                	subw	a3,a3,a0
 194:	00f6853b          	addw	a0,a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	fb7d                	bnez	a4,194 <strlen+0x14>
    ;
  return n;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b0:	ca19                	beqz	a2,1c6 <memset+0x1c>
 1b2:	87aa                	mv	a5,a0
 1b4:	1602                	slli	a2,a2,0x20
 1b6:	9201                	srli	a2,a2,0x20
 1b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1bc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c0:	0785                	addi	a5,a5,1
 1c2:	fee79de3          	bne	a5,a4,1bc <memset+0x12>
  }
  return dst;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strchr>:

char*
strchr(const char *s, char c)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb99                	beqz	a5,1ec <strchr+0x20>
    if(*s == c)
 1d8:	00f58763          	beq	a1,a5,1e6 <strchr+0x1a>
  for(; *s; s++)
 1dc:	0505                	addi	a0,a0,1
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbfd                	bnez	a5,1d8 <strchr+0xc>
      return (char*)s;
  return 0;
 1e4:	4501                	li	a0,0
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  return 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strchr+0x1a>

00000000000001f0 <gets>:

char*
gets(char *buf, int max)
{
 1f0:	711d                	addi	sp,sp,-96
 1f2:	ec86                	sd	ra,88(sp)
 1f4:	e8a2                	sd	s0,80(sp)
 1f6:	e4a6                	sd	s1,72(sp)
 1f8:	e0ca                	sd	s2,64(sp)
 1fa:	fc4e                	sd	s3,56(sp)
 1fc:	f852                	sd	s4,48(sp)
 1fe:	f456                	sd	s5,40(sp)
 200:	f05a                	sd	s6,32(sp)
 202:	ec5e                	sd	s7,24(sp)
 204:	1080                	addi	s0,sp,96
 206:	8baa                	mv	s7,a0
 208:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	892a                	mv	s2,a0
 20c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20e:	4aa9                	li	s5,10
 210:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	2485                	addiw	s1,s1,1
 216:	0344d863          	bge	s1,s4,246 <gets+0x56>
    cc = read(0, &c, 1);
 21a:	4605                	li	a2,1
 21c:	faf40593          	addi	a1,s0,-81
 220:	4501                	li	a0,0
 222:	00000097          	auipc	ra,0x0
 226:	19c080e7          	jalr	412(ra) # 3be <read>
    if(cc < 1)
 22a:	00a05e63          	blez	a0,246 <gets+0x56>
    buf[i++] = c;
 22e:	faf44783          	lbu	a5,-81(s0)
 232:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 236:	01578763          	beq	a5,s5,244 <gets+0x54>
 23a:	0905                	addi	s2,s2,1
 23c:	fd679be3          	bne	a5,s6,212 <gets+0x22>
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	a011                	j	246 <gets+0x56>
 244:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 246:	99de                	add	s3,s3,s7
 248:	00098023          	sb	zero,0(s3)
  return buf;
}
 24c:	855e                	mv	a0,s7
 24e:	60e6                	ld	ra,88(sp)
 250:	6446                	ld	s0,80(sp)
 252:	64a6                	ld	s1,72(sp)
 254:	6906                	ld	s2,64(sp)
 256:	79e2                	ld	s3,56(sp)
 258:	7a42                	ld	s4,48(sp)
 25a:	7aa2                	ld	s5,40(sp)
 25c:	7b02                	ld	s6,32(sp)
 25e:	6be2                	ld	s7,24(sp)
 260:	6125                	addi	sp,sp,96
 262:	8082                	ret

0000000000000264 <stat>:

int
stat(const char *n, struct stat *st)
{
 264:	1101                	addi	sp,sp,-32
 266:	ec06                	sd	ra,24(sp)
 268:	e822                	sd	s0,16(sp)
 26a:	e426                	sd	s1,8(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	00000097          	auipc	ra,0x0
 278:	172080e7          	jalr	370(ra) # 3e6 <open>
  if(fd < 0)
 27c:	02054563          	bltz	a0,2a6 <stat+0x42>
 280:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 282:	85ca                	mv	a1,s2
 284:	00000097          	auipc	ra,0x0
 288:	17a080e7          	jalr	378(ra) # 3fe <fstat>
 28c:	892a                	mv	s2,a0
  close(fd);
 28e:	8526                	mv	a0,s1
 290:	00000097          	auipc	ra,0x0
 294:	13e080e7          	jalr	318(ra) # 3ce <close>
  return r;
}
 298:	854a                	mv	a0,s2
 29a:	60e2                	ld	ra,24(sp)
 29c:	6442                	ld	s0,16(sp)
 29e:	64a2                	ld	s1,8(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfc5                	j	298 <stat+0x34>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054603          	lbu	a2,0(a0)
 2b4:	fd06079b          	addiw	a5,a2,-48
 2b8:	0ff7f793          	andi	a5,a5,255
 2bc:	4725                	li	a4,9
 2be:	02f76963          	bltu	a4,a5,2f0 <atoi+0x46>
 2c2:	86aa                	mv	a3,a0
  n = 0;
 2c4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2c8:	0685                	addi	a3,a3,1
 2ca:	0025179b          	slliw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	slliw	a5,a5,0x1
 2d4:	9fb1                	addw	a5,a5,a2
 2d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	0006c603          	lbu	a2,0(a3)
 2de:	fd06071b          	addiw	a4,a2,-48
 2e2:	0ff77713          	andi	a4,a4,255
 2e6:	fee5f1e3          	bgeu	a1,a4,2c8 <atoi+0x1e>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x40>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	slli	a2,a2,0x20
 304:	9201                	srli	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	addi	a1,a1,1
 30e:	0705                	addi	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addiw	a3,a2,-1
 358:	1682                	slli	a3,a3,0x20
 35a:	9281                	srli	a3,a3,0x20
 35c:	0685                	addi	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	addi	a0,a0,1
    p2++;
 36e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 446:	48d9                	li	a7,22
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 44e:	48dd                	li	a7,23
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 456:	48e1                	li	a7,24
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 45e:	48e5                	li	a7,25
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 466:	48e9                	li	a7,26
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46e:	1101                	addi	sp,sp,-32
 470:	ec06                	sd	ra,24(sp)
 472:	e822                	sd	s0,16(sp)
 474:	1000                	addi	s0,sp,32
 476:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47a:	4605                	li	a2,1
 47c:	fef40593          	addi	a1,s0,-17
 480:	00000097          	auipc	ra,0x0
 484:	f46080e7          	jalr	-186(ra) # 3c6 <write>
}
 488:	60e2                	ld	ra,24(sp)
 48a:	6442                	ld	s0,16(sp)
 48c:	6105                	addi	sp,sp,32
 48e:	8082                	ret

0000000000000490 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 490:	7139                	addi	sp,sp,-64
 492:	fc06                	sd	ra,56(sp)
 494:	f822                	sd	s0,48(sp)
 496:	f426                	sd	s1,40(sp)
 498:	f04a                	sd	s2,32(sp)
 49a:	ec4e                	sd	s3,24(sp)
 49c:	0080                	addi	s0,sp,64
 49e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a0:	c299                	beqz	a3,4a6 <printint+0x16>
 4a2:	0805c863          	bltz	a1,532 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a6:	2581                	sext.w	a1,a1
  neg = 0;
 4a8:	4881                	li	a7,0
 4aa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b0:	2601                	sext.w	a2,a2
 4b2:	00000517          	auipc	a0,0x0
 4b6:	48e50513          	addi	a0,a0,1166 # 940 <digits>
 4ba:	883a                	mv	a6,a4
 4bc:	2705                	addiw	a4,a4,1
 4be:	02c5f7bb          	remuw	a5,a1,a2
 4c2:	1782                	slli	a5,a5,0x20
 4c4:	9381                	srli	a5,a5,0x20
 4c6:	97aa                	add	a5,a5,a0
 4c8:	0007c783          	lbu	a5,0(a5)
 4cc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d0:	0005879b          	sext.w	a5,a1
 4d4:	02c5d5bb          	divuw	a1,a1,a2
 4d8:	0685                	addi	a3,a3,1
 4da:	fec7f0e3          	bgeu	a5,a2,4ba <printint+0x2a>
  if(neg)
 4de:	00088b63          	beqz	a7,4f4 <printint+0x64>
    buf[i++] = '-';
 4e2:	fd040793          	addi	a5,s0,-48
 4e6:	973e                	add	a4,a4,a5
 4e8:	02d00793          	li	a5,45
 4ec:	fef70823          	sb	a5,-16(a4)
 4f0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f4:	02e05863          	blez	a4,524 <printint+0x94>
 4f8:	fc040793          	addi	a5,s0,-64
 4fc:	00e78933          	add	s2,a5,a4
 500:	fff78993          	addi	s3,a5,-1
 504:	99ba                	add	s3,s3,a4
 506:	377d                	addiw	a4,a4,-1
 508:	1702                	slli	a4,a4,0x20
 50a:	9301                	srli	a4,a4,0x20
 50c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 510:	fff94583          	lbu	a1,-1(s2)
 514:	8526                	mv	a0,s1
 516:	00000097          	auipc	ra,0x0
 51a:	f58080e7          	jalr	-168(ra) # 46e <putc>
  while(--i >= 0)
 51e:	197d                	addi	s2,s2,-1
 520:	ff3918e3          	bne	s2,s3,510 <printint+0x80>
}
 524:	70e2                	ld	ra,56(sp)
 526:	7442                	ld	s0,48(sp)
 528:	74a2                	ld	s1,40(sp)
 52a:	7902                	ld	s2,32(sp)
 52c:	69e2                	ld	s3,24(sp)
 52e:	6121                	addi	sp,sp,64
 530:	8082                	ret
    x = -xx;
 532:	40b005bb          	negw	a1,a1
    neg = 1;
 536:	4885                	li	a7,1
    x = -xx;
 538:	bf8d                	j	4aa <printint+0x1a>

000000000000053a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53a:	7119                	addi	sp,sp,-128
 53c:	fc86                	sd	ra,120(sp)
 53e:	f8a2                	sd	s0,112(sp)
 540:	f4a6                	sd	s1,104(sp)
 542:	f0ca                	sd	s2,96(sp)
 544:	ecce                	sd	s3,88(sp)
 546:	e8d2                	sd	s4,80(sp)
 548:	e4d6                	sd	s5,72(sp)
 54a:	e0da                	sd	s6,64(sp)
 54c:	fc5e                	sd	s7,56(sp)
 54e:	f862                	sd	s8,48(sp)
 550:	f466                	sd	s9,40(sp)
 552:	f06a                	sd	s10,32(sp)
 554:	ec6e                	sd	s11,24(sp)
 556:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 558:	0005c903          	lbu	s2,0(a1)
 55c:	18090f63          	beqz	s2,6fa <vprintf+0x1c0>
 560:	8aaa                	mv	s5,a0
 562:	8b32                	mv	s6,a2
 564:	00158493          	addi	s1,a1,1
  state = 0;
 568:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 56a:	02500a13          	li	s4,37
      if(c == 'd'){
 56e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 572:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 576:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 57a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57e:	00000b97          	auipc	s7,0x0
 582:	3c2b8b93          	addi	s7,s7,962 # 940 <digits>
 586:	a839                	j	5a4 <vprintf+0x6a>
        putc(fd, c);
 588:	85ca                	mv	a1,s2
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	ee2080e7          	jalr	-286(ra) # 46e <putc>
 594:	a019                	j	59a <vprintf+0x60>
    } else if(state == '%'){
 596:	01498f63          	beq	s3,s4,5b4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 59a:	0485                	addi	s1,s1,1
 59c:	fff4c903          	lbu	s2,-1(s1)
 5a0:	14090d63          	beqz	s2,6fa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a8:	fe0997e3          	bnez	s3,596 <vprintf+0x5c>
      if(c == '%'){
 5ac:	fd479ee3          	bne	a5,s4,588 <vprintf+0x4e>
        state = '%';
 5b0:	89be                	mv	s3,a5
 5b2:	b7e5                	j	59a <vprintf+0x60>
      if(c == 'd'){
 5b4:	05878063          	beq	a5,s8,5f4 <vprintf+0xba>
      } else if(c == 'l') {
 5b8:	05978c63          	beq	a5,s9,610 <vprintf+0xd6>
      } else if(c == 'x') {
 5bc:	07a78863          	beq	a5,s10,62c <vprintf+0xf2>
      } else if(c == 'p') {
 5c0:	09b78463          	beq	a5,s11,648 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5c4:	07300713          	li	a4,115
 5c8:	0ce78663          	beq	a5,a4,694 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5cc:	06300713          	li	a4,99
 5d0:	0ee78e63          	beq	a5,a4,6cc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5d4:	11478863          	beq	a5,s4,6e4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d8:	85d2                	mv	a1,s4
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e92080e7          	jalr	-366(ra) # 46e <putc>
        putc(fd, c);
 5e4:	85ca                	mv	a1,s2
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e86080e7          	jalr	-378(ra) # 46e <putc>
      }
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b765                	j	59a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b0913          	addi	s2,s6,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000b2583          	lw	a1,0(s6)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e8e080e7          	jalr	-370(ra) # 490 <printint>
 60a:	8b4a                	mv	s6,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b771                	j	59a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	008b0913          	addi	s2,s6,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000b2583          	lw	a1,0(s6)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e72080e7          	jalr	-398(ra) # 490 <printint>
 626:	8b4a                	mv	s6,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	bf85                	j	59a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 62c:	008b0913          	addi	s2,s6,8
 630:	4681                	li	a3,0
 632:	4641                	li	a2,16
 634:	000b2583          	lw	a1,0(s6)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e56080e7          	jalr	-426(ra) # 490 <printint>
 642:	8b4a                	mv	s6,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	bf91                	j	59a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 648:	008b0793          	addi	a5,s6,8
 64c:	f8f43423          	sd	a5,-120(s0)
 650:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 654:	03000593          	li	a1,48
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e14080e7          	jalr	-492(ra) # 46e <putc>
  putc(fd, 'x');
 662:	85ea                	mv	a1,s10
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e08080e7          	jalr	-504(ra) # 46e <putc>
 66e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 670:	03c9d793          	srli	a5,s3,0x3c
 674:	97de                	add	a5,a5,s7
 676:	0007c583          	lbu	a1,0(a5)
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	df2080e7          	jalr	-526(ra) # 46e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 684:	0992                	slli	s3,s3,0x4
 686:	397d                	addiw	s2,s2,-1
 688:	fe0914e3          	bnez	s2,670 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 68c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 690:	4981                	li	s3,0
 692:	b721                	j	59a <vprintf+0x60>
        s = va_arg(ap, char*);
 694:	008b0993          	addi	s3,s6,8
 698:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 69c:	02090163          	beqz	s2,6be <vprintf+0x184>
        while(*s != 0){
 6a0:	00094583          	lbu	a1,0(s2)
 6a4:	c9a1                	beqz	a1,6f4 <vprintf+0x1ba>
          putc(fd, *s);
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	dc6080e7          	jalr	-570(ra) # 46e <putc>
          s++;
 6b0:	0905                	addi	s2,s2,1
        while(*s != 0){
 6b2:	00094583          	lbu	a1,0(s2)
 6b6:	f9e5                	bnez	a1,6a6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6b8:	8b4e                	mv	s6,s3
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	bdf9                	j	59a <vprintf+0x60>
          s = "(null)";
 6be:	00000917          	auipc	s2,0x0
 6c2:	27a90913          	addi	s2,s2,634 # 938 <malloc+0x134>
        while(*s != 0){
 6c6:	02800593          	li	a1,40
 6ca:	bff1                	j	6a6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6cc:	008b0913          	addi	s2,s6,8
 6d0:	000b4583          	lbu	a1,0(s6)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	d98080e7          	jalr	-616(ra) # 46e <putc>
 6de:	8b4a                	mv	s6,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd65                	j	59a <vprintf+0x60>
        putc(fd, c);
 6e4:	85d2                	mv	a1,s4
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	d86080e7          	jalr	-634(ra) # 46e <putc>
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b565                	j	59a <vprintf+0x60>
        s = va_arg(ap, char*);
 6f4:	8b4e                	mv	s6,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b54d                	j	59a <vprintf+0x60>
    }
  }
}
 6fa:	70e6                	ld	ra,120(sp)
 6fc:	7446                	ld	s0,112(sp)
 6fe:	74a6                	ld	s1,104(sp)
 700:	7906                	ld	s2,96(sp)
 702:	69e6                	ld	s3,88(sp)
 704:	6a46                	ld	s4,80(sp)
 706:	6aa6                	ld	s5,72(sp)
 708:	6b06                	ld	s6,64(sp)
 70a:	7be2                	ld	s7,56(sp)
 70c:	7c42                	ld	s8,48(sp)
 70e:	7ca2                	ld	s9,40(sp)
 710:	7d02                	ld	s10,32(sp)
 712:	6de2                	ld	s11,24(sp)
 714:	6109                	addi	sp,sp,128
 716:	8082                	ret

0000000000000718 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 718:	715d                	addi	sp,sp,-80
 71a:	ec06                	sd	ra,24(sp)
 71c:	e822                	sd	s0,16(sp)
 71e:	1000                	addi	s0,sp,32
 720:	e010                	sd	a2,0(s0)
 722:	e414                	sd	a3,8(s0)
 724:	e818                	sd	a4,16(s0)
 726:	ec1c                	sd	a5,24(s0)
 728:	03043023          	sd	a6,32(s0)
 72c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 734:	8622                	mv	a2,s0
 736:	00000097          	auipc	ra,0x0
 73a:	e04080e7          	jalr	-508(ra) # 53a <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6161                	addi	sp,sp,80
 744:	8082                	ret

0000000000000746 <printf>:

void
printf(const char *fmt, ...)
{
 746:	711d                	addi	sp,sp,-96
 748:	ec06                	sd	ra,24(sp)
 74a:	e822                	sd	s0,16(sp)
 74c:	1000                	addi	s0,sp,32
 74e:	e40c                	sd	a1,8(s0)
 750:	e810                	sd	a2,16(s0)
 752:	ec14                	sd	a3,24(s0)
 754:	f018                	sd	a4,32(s0)
 756:	f41c                	sd	a5,40(s0)
 758:	03043823          	sd	a6,48(s0)
 75c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	00840613          	addi	a2,s0,8
 764:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 768:	85aa                	mv	a1,a0
 76a:	4505                	li	a0,1
 76c:	00000097          	auipc	ra,0x0
 770:	dce080e7          	jalr	-562(ra) # 53a <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6125                	addi	sp,sp,96
 77a:	8082                	ret

000000000000077c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77c:	1141                	addi	sp,sp,-16
 77e:	e422                	sd	s0,8(sp)
 780:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 782:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	00001797          	auipc	a5,0x1
 78a:	87a7b783          	ld	a5,-1926(a5) # 1000 <freep>
 78e:	a805                	j	7be <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 790:	4618                	lw	a4,8(a2)
 792:	9db9                	addw	a1,a1,a4
 794:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 798:	6398                	ld	a4,0(a5)
 79a:	6318                	ld	a4,0(a4)
 79c:	fee53823          	sd	a4,-16(a0)
 7a0:	a091                	j	7e4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a2:	ff852703          	lw	a4,-8(a0)
 7a6:	9e39                	addw	a2,a2,a4
 7a8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7aa:	ff053703          	ld	a4,-16(a0)
 7ae:	e398                	sd	a4,0(a5)
 7b0:	a099                	j	7f6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e7e463          	bltu	a5,a4,7bc <free+0x40>
 7b8:	00e6ea63          	bltu	a3,a4,7cc <free+0x50>
{
 7bc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7be:	fed7fae3          	bgeu	a5,a3,7b2 <free+0x36>
 7c2:	6398                	ld	a4,0(a5)
 7c4:	00e6e463          	bltu	a3,a4,7cc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c8:	fee7eae3          	bltu	a5,a4,7bc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7cc:	ff852583          	lw	a1,-8(a0)
 7d0:	6390                	ld	a2,0(a5)
 7d2:	02059713          	slli	a4,a1,0x20
 7d6:	9301                	srli	a4,a4,0x20
 7d8:	0712                	slli	a4,a4,0x4
 7da:	9736                	add	a4,a4,a3
 7dc:	fae60ae3          	beq	a2,a4,790 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7e0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e4:	4790                	lw	a2,8(a5)
 7e6:	02061713          	slli	a4,a2,0x20
 7ea:	9301                	srli	a4,a4,0x20
 7ec:	0712                	slli	a4,a4,0x4
 7ee:	973e                	add	a4,a4,a5
 7f0:	fae689e3          	beq	a3,a4,7a2 <free+0x26>
  } else
    p->s.ptr = bp;
 7f4:	e394                	sd	a3,0(a5)
  freep = p;
 7f6:	00001717          	auipc	a4,0x1
 7fa:	80f73523          	sd	a5,-2038(a4) # 1000 <freep>
}
 7fe:	6422                	ld	s0,8(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret

0000000000000804 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 804:	7139                	addi	sp,sp,-64
 806:	fc06                	sd	ra,56(sp)
 808:	f822                	sd	s0,48(sp)
 80a:	f426                	sd	s1,40(sp)
 80c:	f04a                	sd	s2,32(sp)
 80e:	ec4e                	sd	s3,24(sp)
 810:	e852                	sd	s4,16(sp)
 812:	e456                	sd	s5,8(sp)
 814:	e05a                	sd	s6,0(sp)
 816:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 818:	02051493          	slli	s1,a0,0x20
 81c:	9081                	srli	s1,s1,0x20
 81e:	04bd                	addi	s1,s1,15
 820:	8091                	srli	s1,s1,0x4
 822:	0014899b          	addiw	s3,s1,1
 826:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 828:	00000517          	auipc	a0,0x0
 82c:	7d853503          	ld	a0,2008(a0) # 1000 <freep>
 830:	c515                	beqz	a0,85c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 834:	4798                	lw	a4,8(a5)
 836:	02977f63          	bgeu	a4,s1,874 <malloc+0x70>
 83a:	8a4e                	mv	s4,s3
 83c:	0009871b          	sext.w	a4,s3
 840:	6685                	lui	a3,0x1
 842:	00d77363          	bgeu	a4,a3,848 <malloc+0x44>
 846:	6a05                	lui	s4,0x1
 848:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 850:	00000917          	auipc	s2,0x0
 854:	7b090913          	addi	s2,s2,1968 # 1000 <freep>
  if(p == (char*)-1)
 858:	5afd                	li	s5,-1
 85a:	a88d                	j	8cc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 85c:	00001797          	auipc	a5,0x1
 860:	9b478793          	addi	a5,a5,-1612 # 1210 <base>
 864:	00000717          	auipc	a4,0x0
 868:	78f73e23          	sd	a5,1948(a4) # 1000 <freep>
 86c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 872:	b7e1                	j	83a <malloc+0x36>
      if(p->s.size == nunits)
 874:	02e48b63          	beq	s1,a4,8aa <malloc+0xa6>
        p->s.size -= nunits;
 878:	4137073b          	subw	a4,a4,s3
 87c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87e:	1702                	slli	a4,a4,0x20
 880:	9301                	srli	a4,a4,0x20
 882:	0712                	slli	a4,a4,0x4
 884:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 886:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 88a:	00000717          	auipc	a4,0x0
 88e:	76a73b23          	sd	a0,1910(a4) # 1000 <freep>
      return (void*)(p + 1);
 892:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 896:	70e2                	ld	ra,56(sp)
 898:	7442                	ld	s0,48(sp)
 89a:	74a2                	ld	s1,40(sp)
 89c:	7902                	ld	s2,32(sp)
 89e:	69e2                	ld	s3,24(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
 8a6:	6121                	addi	sp,sp,64
 8a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	e118                	sd	a4,0(a0)
 8ae:	bff1                	j	88a <malloc+0x86>
  hp->s.size = nu;
 8b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b4:	0541                	addi	a0,a0,16
 8b6:	00000097          	auipc	ra,0x0
 8ba:	ec6080e7          	jalr	-314(ra) # 77c <free>
  return freep;
 8be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c2:	d971                	beqz	a0,896 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	fa9776e3          	bgeu	a4,s1,874 <malloc+0x70>
    if(p == freep)
 8cc:	00093703          	ld	a4,0(s2)
 8d0:	853e                	mv	a0,a5
 8d2:	fef719e3          	bne	a4,a5,8c4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8d6:	8552                	mv	a0,s4
 8d8:	00000097          	auipc	ra,0x0
 8dc:	b56080e7          	jalr	-1194(ra) # 42e <sbrk>
  if(p == (char*)-1)
 8e0:	fd5518e3          	bne	a0,s5,8b0 <malloc+0xac>
        return 0;
 8e4:	4501                	li	a0,0
 8e6:	bf45                	j	896 <malloc+0x92>

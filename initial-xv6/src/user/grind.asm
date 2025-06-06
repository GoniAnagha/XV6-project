
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e8c080e7          	jalr	-372(ra) # f1c <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	34650513          	addi	a0,a0,838 # 13e0 <malloc+0xee>
      a2:	00001097          	auipc	ra,0x1
      a6:	e5a080e7          	jalr	-422(ra) # efc <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	33650513          	addi	a0,a0,822 # 13e0 <malloc+0xee>
      b2:	00001097          	auipc	ra,0x1
      b6:	e52080e7          	jalr	-430(ra) # f04 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	32c50513          	addi	a0,a0,812 # 13e8 <malloc+0xf6>
      c4:	00001097          	auipc	ra,0x1
      c8:	170080e7          	jalr	368(ra) # 1234 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	dc6080e7          	jalr	-570(ra) # e94 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	33250513          	addi	a0,a0,818 # 1408 <malloc+0x116>
      de:	00001097          	auipc	ra,0x1
      e2:	e26080e7          	jalr	-474(ra) # f04 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	33298993          	addi	s3,s3,818 # 1418 <malloc+0x126>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	32098993          	addi	s3,s3,800 # 1410 <malloc+0x11e>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00002a17          	auipc	s4,0x2
     100:	f24a0a13          	addi	s4,s4,-220 # 2020 <buf.0>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	31650513          	addi	a0,a0,790 # 1420 <malloc+0x12e>
     112:	00001097          	auipc	ra,0x1
     116:	dc2080e7          	jalr	-574(ra) # ed4 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	da2080e7          	jalr	-606(ra) # ebc <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d80080e7          	jalr	-640(ra) # eb4 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cd2080e7          	jalr	-814(ra) # ea4 <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	cc2080e7          	jalr	-830(ra) # ea4 <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c9e080e7          	jalr	-866(ra) # e8c <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c8e080e7          	jalr	-882(ra) # e8c <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	caa080e7          	jalr	-854(ra) # ebc <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c9e080e7          	jalr	-866(ra) # ebc <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c92080e7          	jalr	-878(ra) # ebc <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c6c080e7          	jalr	-916(ra) # eac <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c5a080e7          	jalr	-934(ra) # eac <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c48080e7          	jalr	-952(ra) # eac <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c4c080e7          	jalr	-948(ra) # ebc <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	c20080e7          	jalr	-992(ra) # e9c <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	c14080e7          	jalr	-1004(ra) # e9c <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3fa58593          	addi	a1,a1,1018 # 1698 <malloc+0x3a6>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	998080e7          	jalr	-1640(ra) # c42 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	3de50513          	addi	a0,a0,990 # 16a0 <malloc+0x3ae>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f6a080e7          	jalr	-150(ra) # 1234 <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	bc0080e7          	jalr	-1088(ra) # e94 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	15050513          	addi	a0,a0,336 # 1430 <malloc+0x13e>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bec080e7          	jalr	-1044(ra) # ed4 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bcc080e7          	jalr	-1076(ra) # ebc <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	12650513          	addi	a0,a0,294 # 1420 <malloc+0x12e>
     302:	00001097          	auipc	ra,0x1
     306:	be2080e7          	jalr	-1054(ra) # ee4 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	0d450513          	addi	a0,a0,212 # 13e0 <malloc+0xee>
     314:	00001097          	auipc	ra,0x1
     318:	bf0080e7          	jalr	-1040(ra) # f04 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	12a50513          	addi	a0,a0,298 # 1448 <malloc+0x156>
     326:	00001097          	auipc	ra,0x1
     32a:	bbe080e7          	jalr	-1090(ra) # ee4 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	0da50513          	addi	a0,a0,218 # 1408 <malloc+0x116>
     336:	00001097          	auipc	ra,0x1
     33a:	bce080e7          	jalr	-1074(ra) # f04 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	0a850513          	addi	a0,a0,168 # 13e8 <malloc+0xf6>
     348:	00001097          	auipc	ra,0x1
     34c:	eec080e7          	jalr	-276(ra) # 1234 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b42080e7          	jalr	-1214(ra) # e94 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b60080e7          	jalr	-1184(ra) # ebc <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0e850513          	addi	a0,a0,232 # 1450 <malloc+0x15e>
     370:	00001097          	auipc	ra,0x1
     374:	b64080e7          	jalr	-1180(ra) # ed4 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b3e080e7          	jalr	-1218(ra) # ebc <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	0d650513          	addi	a0,a0,214 # 1460 <malloc+0x16e>
     392:	00001097          	auipc	ra,0x1
     396:	b42080e7          	jalr	-1214(ra) # ed4 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	b0e080e7          	jalr	-1266(ra) # eb4 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	af4080e7          	jalr	-1292(ra) # eac <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	05e50513          	addi	a0,a0,94 # 1420 <malloc+0x12e>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b32080e7          	jalr	-1230(ra) # efc <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	0a250513          	addi	a0,a0,162 # 1478 <malloc+0x186>
     3de:	00001097          	auipc	ra,0x1
     3e2:	af6080e7          	jalr	-1290(ra) # ed4 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	ad6080e7          	jalr	-1322(ra) # ebc <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	09a50513          	addi	a0,a0,154 # 1488 <malloc+0x196>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	aee080e7          	jalr	-1298(ra) # ee4 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	09050513          	addi	a0,a0,144 # 1490 <malloc+0x19e>
     408:	00001097          	auipc	ra,0x1
     40c:	af4080e7          	jalr	-1292(ra) # efc <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	08450513          	addi	a0,a0,132 # 1498 <malloc+0x1a6>
     41c:	00001097          	auipc	ra,0x1
     420:	ab8080e7          	jalr	-1352(ra) # ed4 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a98080e7          	jalr	-1384(ra) # ebc <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	07c50513          	addi	a0,a0,124 # 14a8 <malloc+0x1b6>
     434:	00001097          	auipc	ra,0x1
     438:	ab0080e7          	jalr	-1360(ra) # ee4 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	03250513          	addi	a0,a0,50 # 1470 <malloc+0x17e>
     446:	00001097          	auipc	ra,0x1
     44a:	a9e080e7          	jalr	-1378(ra) # ee4 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	ffa58593          	addi	a1,a1,-6 # 1448 <malloc+0x156>
     456:	00001517          	auipc	a0,0x1
     45a:	05a50513          	addi	a0,a0,90 # 14b0 <malloc+0x1be>
     45e:	00001097          	auipc	ra,0x1
     462:	a96080e7          	jalr	-1386(ra) # ef4 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	06050513          	addi	a0,a0,96 # 14c8 <malloc+0x1d6>
     470:	00001097          	auipc	ra,0x1
     474:	a74080e7          	jalr	-1420(ra) # ee4 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	fd858593          	addi	a1,a1,-40 # 1450 <malloc+0x15e>
     480:	00001517          	auipc	a0,0x1
     484:	05850513          	addi	a0,a0,88 # 14d8 <malloc+0x1e6>
     488:	00001097          	auipc	ra,0x1
     48c:	a6c080e7          	jalr	-1428(ra) # ef4 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9fa080e7          	jalr	-1542(ra) # e8c <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9fa080e7          	jalr	-1542(ra) # e9c <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9e8080e7          	jalr	-1560(ra) # e94 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	02c50513          	addi	a0,a0,44 # 14e0 <malloc+0x1ee>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d78080e7          	jalr	-648(ra) # 1234 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9ce080e7          	jalr	-1586(ra) # e94 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9be080e7          	jalr	-1602(ra) # e8c <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9be080e7          	jalr	-1602(ra) # e9c <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	9a4080e7          	jalr	-1628(ra) # e8c <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	99c080e7          	jalr	-1636(ra) # e8c <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	99a080e7          	jalr	-1638(ra) # e94 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	fde50513          	addi	a0,a0,-34 # 14e0 <malloc+0x1ee>
     50a:	00001097          	auipc	ra,0x1
     50e:	d2a080e7          	jalr	-726(ra) # 1234 <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	980080e7          	jalr	-1664(ra) # e94 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <digits+0xab>
     522:	00001097          	auipc	ra,0x1
     526:	9fa080e7          	jalr	-1542(ra) # f1c <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9ee080e7          	jalr	-1554(ra) # f1c <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9e0080e7          	jalr	-1568(ra) # f1c <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9d4080e7          	jalr	-1580(ra) # f1c <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	93a080e7          	jalr	-1734(ra) # e8c <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f9650513          	addi	a0,a0,-106 # 14f8 <malloc+0x206>
     56a:	00001097          	auipc	ra,0x1
     56e:	99a080e7          	jalr	-1638(ra) # f04 <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	94e080e7          	jalr	-1714(ra) # ec4 <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	91c080e7          	jalr	-1764(ra) # e9c <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	f3250513          	addi	a0,a0,-206 # 14c0 <malloc+0x1ce>
     596:	00001097          	auipc	ra,0x1
     59a:	93e080e7          	jalr	-1730(ra) # ed4 <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	91e080e7          	jalr	-1762(ra) # ebc <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8ec080e7          	jalr	-1812(ra) # e94 <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f3050513          	addi	a0,a0,-208 # 14e0 <malloc+0x1ee>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c7c080e7          	jalr	-900(ra) # 1234 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8d2080e7          	jalr	-1838(ra) # e94 <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	f3e50513          	addi	a0,a0,-194 # 1508 <malloc+0x216>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c62080e7          	jalr	-926(ra) # 1234 <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8b8080e7          	jalr	-1864(ra) # e94 <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	8a8080e7          	jalr	-1880(ra) # e8c <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	8a8080e7          	jalr	-1880(ra) # e9c <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	916080e7          	jalr	-1770(ra) # f14 <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8be080e7          	jalr	-1858(ra) # ec4 <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	884080e7          	jalr	-1916(ra) # e94 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	ec850513          	addi	a0,a0,-312 # 14e0 <malloc+0x1ee>
     620:	00001097          	auipc	ra,0x1
     624:	c14080e7          	jalr	-1004(ra) # 1234 <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	86a080e7          	jalr	-1942(ra) # e94 <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	86e080e7          	jalr	-1938(ra) # ea4 <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	84a080e7          	jalr	-1974(ra) # e8c <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	868080e7          	jalr	-1944(ra) # ebc <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	85c080e7          	jalr	-1956(ra) # ebc <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	832080e7          	jalr	-1998(ra) # e9c <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	eac50513          	addi	a0,a0,-340 # 1520 <malloc+0x22e>
     67c:	00001097          	auipc	ra,0x1
     680:	bb8080e7          	jalr	-1096(ra) # 1234 <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00001097          	auipc	ra,0x1
     68a:	80e080e7          	jalr	-2034(ra) # e94 <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7fe080e7          	jalr	2046(ra) # e8c <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7f6080e7          	jalr	2038(ra) # e8c <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e9858593          	addi	a1,a1,-360 # 1538 <malloc+0x246>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00001097          	auipc	ra,0x1
     6b0:	808080e7          	jalr	-2040(ra) # eb4 <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7e8080e7          	jalr	2024(ra) # eac <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7c0080e7          	jalr	1984(ra) # e94 <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e6450513          	addi	a0,a0,-412 # 1540 <malloc+0x24e>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b50080e7          	jalr	-1200(ra) # 1234 <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e7250513          	addi	a0,a0,-398 # 1560 <malloc+0x26e>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b3e080e7          	jalr	-1218(ra) # 1234 <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	de050513          	addi	a0,a0,-544 # 14e0 <malloc+0x1ee>
     708:	00001097          	auipc	ra,0x1
     70c:	b2c080e7          	jalr	-1236(ra) # 1234 <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	782080e7          	jalr	1922(ra) # e94 <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	772080e7          	jalr	1906(ra) # e8c <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	772080e7          	jalr	1906(ra) # e9c <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d8c50513          	addi	a0,a0,-628 # 14c0 <malloc+0x1ce>
     73c:	00000097          	auipc	ra,0x0
     740:	7a8080e7          	jalr	1960(ra) # ee4 <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d7c50513          	addi	a0,a0,-644 # 14c0 <malloc+0x1ce>
     74c:	00000097          	auipc	ra,0x0
     750:	7b0080e7          	jalr	1968(ra) # efc <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d6c50513          	addi	a0,a0,-660 # 14c0 <malloc+0x1ce>
     75c:	00000097          	auipc	ra,0x0
     760:	7a8080e7          	jalr	1960(ra) # f04 <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	cc450513          	addi	a0,a0,-828 # 1428 <malloc+0x136>
     76c:	00000097          	auipc	ra,0x0
     770:	778080e7          	jalr	1912(ra) # ee4 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	dc050513          	addi	a0,a0,-576 # 1538 <malloc+0x246>
     780:	00000097          	auipc	ra,0x0
     784:	754080e7          	jalr	1876(ra) # ed4 <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	db050513          	addi	a0,a0,-592 # 1538 <malloc+0x246>
     790:	00000097          	auipc	ra,0x0
     794:	754080e7          	jalr	1876(ra) # ee4 <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6fa080e7          	jalr	1786(ra) # e94 <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	d3e50513          	addi	a0,a0,-706 # 14e0 <malloc+0x1ee>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a8a080e7          	jalr	-1398(ra) # 1234 <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6e0080e7          	jalr	1760(ra) # e94 <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	dc450513          	addi	a0,a0,-572 # 1580 <malloc+0x28e>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	720080e7          	jalr	1824(ra) # ee4 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	db050513          	addi	a0,a0,-592 # 1580 <malloc+0x28e>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6fc080e7          	jalr	1788(ra) # ed4 <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d5058593          	addi	a1,a1,-688 # 1538 <malloc+0x246>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6c4080e7          	jalr	1732(ra) # eb4 <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6e8080e7          	jalr	1768(ra) # eec <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	696080e7          	jalr	1686(ra) # ebc <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d5250513          	addi	a0,a0,-686 # 1580 <malloc+0x28e>
     836:	00000097          	auipc	ra,0x0
     83a:	6ae080e7          	jalr	1710(ra) # ee4 <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d4850513          	addi	a0,a0,-696 # 1588 <malloc+0x296>
     848:	00001097          	auipc	ra,0x1
     84c:	9ec080e7          	jalr	-1556(ra) # 1234 <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	642080e7          	jalr	1602(ra) # e94 <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d4650513          	addi	a0,a0,-698 # 15a0 <malloc+0x2ae>
     862:	00001097          	auipc	ra,0x1
     866:	9d2080e7          	jalr	-1582(ra) # 1234 <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	628080e7          	jalr	1576(ra) # e94 <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	d4450513          	addi	a0,a0,-700 # 15b8 <malloc+0x2c6>
     87c:	00001097          	auipc	ra,0x1
     880:	9b8080e7          	jalr	-1608(ra) # 1234 <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	60e080e7          	jalr	1550(ra) # e94 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	d4050513          	addi	a0,a0,-704 # 15d0 <malloc+0x2de>
     898:	00001097          	auipc	ra,0x1
     89c:	99c080e7          	jalr	-1636(ra) # 1234 <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5f2080e7          	jalr	1522(ra) # e94 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d4e50513          	addi	a0,a0,-690 # 15f8 <malloc+0x306>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	982080e7          	jalr	-1662(ra) # 1234 <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5d8080e7          	jalr	1496(ra) # e94 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c5c58593          	addi	a1,a1,-932 # 1520 <malloc+0x22e>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	938080e7          	jalr	-1736(ra) # 1206 <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	5bc080e7          	jalr	1468(ra) # e94 <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	c4058593          	addi	a1,a1,-960 # 1520 <malloc+0x22e>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	91c080e7          	jalr	-1764(ra) # 1206 <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	5a0080e7          	jalr	1440(ra) # e94 <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	5bc080e7          	jalr	1468(ra) # ebc <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	5b0080e7          	jalr	1456(ra) # ebc <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	5a4080e7          	jalr	1444(ra) # ebc <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	59a080e7          	jalr	1434(ra) # ebc <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5de080e7          	jalr	1502(ra) # f0c <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	ce458593          	addi	a1,a1,-796 # 1620 <malloc+0x32e>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	8c0080e7          	jalr	-1856(ra) # 1206 <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	544080e7          	jalr	1348(ra) # e94 <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	560080e7          	jalr	1376(ra) # ebc <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	cd478793          	addi	a5,a5,-812 # 1638 <malloc+0x346>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	cd078793          	addi	a5,a5,-816 # 1640 <malloc+0x34e>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	cc450513          	addi	a0,a0,-828 # 1648 <malloc+0x356>
     98c:	00000097          	auipc	ra,0x0
     990:	540080e7          	jalr	1344(ra) # ecc <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	cc458593          	addi	a1,a1,-828 # 1658 <malloc+0x366>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	868080e7          	jalr	-1944(ra) # 1206 <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4ec080e7          	jalr	1260(ra) # e94 <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	b3058593          	addi	a1,a1,-1232 # 14e0 <malloc+0x1ee>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	84c080e7          	jalr	-1972(ra) # 1206 <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4d0080e7          	jalr	1232(ra) # e94 <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4ec080e7          	jalr	1260(ra) # ebc <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4e0080e7          	jalr	1248(ra) # ebc <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4d6080e7          	jalr	1238(ra) # ebc <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	51a080e7          	jalr	1306(ra) # f0c <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	c2458593          	addi	a1,a1,-988 # 1620 <malloc+0x32e>
     a04:	4509                	li	a0,2
     a06:	00001097          	auipc	ra,0x1
     a0a:	800080e7          	jalr	-2048(ra) # 1206 <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	484080e7          	jalr	1156(ra) # e94 <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	4a0080e7          	jalr	1184(ra) # ebc <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	496080e7          	jalr	1174(ra) # ebc <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4da080e7          	jalr	1242(ra) # f0c <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	be058593          	addi	a1,a1,-1056 # 1620 <malloc+0x32e>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	7bc080e7          	jalr	1980(ra) # 1206 <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	440080e7          	jalr	1088(ra) # e94 <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	45c080e7          	jalr	1116(ra) # ebc <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	c0878793          	addi	a5,a5,-1016 # 1670 <malloc+0x37e>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	bfc50513          	addi	a0,a0,-1028 # 1678 <malloc+0x386>
     a84:	00000097          	auipc	ra,0x0
     a88:	448080e7          	jalr	1096(ra) # ecc <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bf458593          	addi	a1,a1,-1036 # 1680 <malloc+0x38e>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	770080e7          	jalr	1904(ra) # 1206 <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3f4080e7          	jalr	1012(ra) # e94 <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	a3858593          	addi	a1,a1,-1480 # 14e0 <malloc+0x1ee>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	754080e7          	jalr	1876(ra) # 1206 <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3d8080e7          	jalr	984(ra) # e94 <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9f050513          	addi	a0,a0,-1552 # 14c0 <malloc+0x1ce>
     ad8:	00000097          	auipc	ra,0x0
     adc:	40c080e7          	jalr	1036(ra) # ee4 <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	99050513          	addi	a0,a0,-1648 # 1470 <malloc+0x17e>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3fc080e7          	jalr	1020(ra) # ee4 <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	39c080e7          	jalr	924(ra) # e8c <fork>
  if(pid1 < 0){
     af8:	02054163          	bltz	a0,b1a <iter+0x56>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e91d                	bnez	a0,b34 <iter+0x70>
    rand_next ^= 31;
     b00:	00001717          	auipc	a4,0x1
     b04:	50070713          	addi	a4,a4,1280 # 2000 <rand_next>
     b08:	631c                	ld	a5,0(a4)
     b0a:	01f7c793          	xori	a5,a5,31
     b0e:	e31c                	sd	a5,0(a4)
    go(0);
     b10:	4501                	li	a0,0
     b12:	fffff097          	auipc	ra,0xfffff
     b16:	566080e7          	jalr	1382(ra) # 78 <go>
    printf("grind: fork failed\n");
     b1a:	00001517          	auipc	a0,0x1
     b1e:	9c650513          	addi	a0,a0,-1594 # 14e0 <malloc+0x1ee>
     b22:	00000097          	auipc	ra,0x0
     b26:	712080e7          	jalr	1810(ra) # 1234 <printf>
    exit(1);
     b2a:	4505                	li	a0,1
     b2c:	00000097          	auipc	ra,0x0
     b30:	368080e7          	jalr	872(ra) # e94 <exit>
    exit(0);
  }

  int pid2 = fork();
     b34:	00000097          	auipc	ra,0x0
     b38:	358080e7          	jalr	856(ra) # e8c <fork>
     b3c:	892a                	mv	s2,a0
  if(pid2 < 0){
     b3e:	02054263          	bltz	a0,b62 <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b42:	ed0d                	bnez	a0,b7c <iter+0xb8>
    rand_next ^= 7177;
     b44:	00001697          	auipc	a3,0x1
     b48:	4bc68693          	addi	a3,a3,1212 # 2000 <rand_next>
     b4c:	629c                	ld	a5,0(a3)
     b4e:	6709                	lui	a4,0x2
     b50:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x539>
     b54:	8fb9                	xor	a5,a5,a4
     b56:	e29c                	sd	a5,0(a3)
    go(1);
     b58:	4505                	li	a0,1
     b5a:	fffff097          	auipc	ra,0xfffff
     b5e:	51e080e7          	jalr	1310(ra) # 78 <go>
    printf("grind: fork failed\n");
     b62:	00001517          	auipc	a0,0x1
     b66:	97e50513          	addi	a0,a0,-1666 # 14e0 <malloc+0x1ee>
     b6a:	00000097          	auipc	ra,0x0
     b6e:	6ca080e7          	jalr	1738(ra) # 1234 <printf>
    exit(1);
     b72:	4505                	li	a0,1
     b74:	00000097          	auipc	ra,0x0
     b78:	320080e7          	jalr	800(ra) # e94 <exit>
    exit(0);
  }

  int st1 = -1;
     b7c:	57fd                	li	a5,-1
     b7e:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b82:	fdc40513          	addi	a0,s0,-36
     b86:	00000097          	auipc	ra,0x0
     b8a:	316080e7          	jalr	790(ra) # e9c <wait>
  if(st1 != 0){
     b8e:	fdc42783          	lw	a5,-36(s0)
     b92:	ef99                	bnez	a5,bb0 <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b94:	57fd                	li	a5,-1
     b96:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b9a:	fd840513          	addi	a0,s0,-40
     b9e:	00000097          	auipc	ra,0x0
     ba2:	2fe080e7          	jalr	766(ra) # e9c <wait>

  exit(0);
     ba6:	4501                	li	a0,0
     ba8:	00000097          	auipc	ra,0x0
     bac:	2ec080e7          	jalr	748(ra) # e94 <exit>
    kill(pid1);
     bb0:	8526                	mv	a0,s1
     bb2:	00000097          	auipc	ra,0x0
     bb6:	312080e7          	jalr	786(ra) # ec4 <kill>
    kill(pid2);
     bba:	854a                	mv	a0,s2
     bbc:	00000097          	auipc	ra,0x0
     bc0:	308080e7          	jalr	776(ra) # ec4 <kill>
     bc4:	bfc1                	j	b94 <iter+0xd0>

0000000000000bc6 <main>:
}

int
main()
{
     bc6:	1101                	addi	sp,sp,-32
     bc8:	ec06                	sd	ra,24(sp)
     bca:	e822                	sd	s0,16(sp)
     bcc:	e426                	sd	s1,8(sp)
     bce:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     bd0:	00001497          	auipc	s1,0x1
     bd4:	43048493          	addi	s1,s1,1072 # 2000 <rand_next>
     bd8:	a829                	j	bf2 <main+0x2c>
      iter();
     bda:	00000097          	auipc	ra,0x0
     bde:	eea080e7          	jalr	-278(ra) # ac4 <iter>
    sleep(20);
     be2:	4551                	li	a0,20
     be4:	00000097          	auipc	ra,0x0
     be8:	340080e7          	jalr	832(ra) # f24 <sleep>
    rand_next += 1;
     bec:	609c                	ld	a5,0(s1)
     bee:	0785                	addi	a5,a5,1
     bf0:	e09c                	sd	a5,0(s1)
    int pid = fork();
     bf2:	00000097          	auipc	ra,0x0
     bf6:	29a080e7          	jalr	666(ra) # e8c <fork>
    if(pid == 0){
     bfa:	d165                	beqz	a0,bda <main+0x14>
    if(pid > 0){
     bfc:	fea053e3          	blez	a0,be2 <main+0x1c>
      wait(0);
     c00:	4501                	li	a0,0
     c02:	00000097          	auipc	ra,0x0
     c06:	29a080e7          	jalr	666(ra) # e9c <wait>
     c0a:	bfe1                	j	be2 <main+0x1c>

0000000000000c0c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e406                	sd	ra,8(sp)
     c10:	e022                	sd	s0,0(sp)
     c12:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c14:	00000097          	auipc	ra,0x0
     c18:	fb2080e7          	jalr	-78(ra) # bc6 <main>
  exit(0);
     c1c:	4501                	li	a0,0
     c1e:	00000097          	auipc	ra,0x0
     c22:	276080e7          	jalr	630(ra) # e94 <exit>

0000000000000c26 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c26:	1141                	addi	sp,sp,-16
     c28:	e422                	sd	s0,8(sp)
     c2a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c2c:	87aa                	mv	a5,a0
     c2e:	0585                	addi	a1,a1,1
     c30:	0785                	addi	a5,a5,1
     c32:	fff5c703          	lbu	a4,-1(a1)
     c36:	fee78fa3          	sb	a4,-1(a5)
     c3a:	fb75                	bnez	a4,c2e <strcpy+0x8>
    ;
  return os;
}
     c3c:	6422                	ld	s0,8(sp)
     c3e:	0141                	addi	sp,sp,16
     c40:	8082                	ret

0000000000000c42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c42:	1141                	addi	sp,sp,-16
     c44:	e422                	sd	s0,8(sp)
     c46:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c48:	00054783          	lbu	a5,0(a0)
     c4c:	cb91                	beqz	a5,c60 <strcmp+0x1e>
     c4e:	0005c703          	lbu	a4,0(a1)
     c52:	00f71763          	bne	a4,a5,c60 <strcmp+0x1e>
    p++, q++;
     c56:	0505                	addi	a0,a0,1
     c58:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c5a:	00054783          	lbu	a5,0(a0)
     c5e:	fbe5                	bnez	a5,c4e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c60:	0005c503          	lbu	a0,0(a1)
}
     c64:	40a7853b          	subw	a0,a5,a0
     c68:	6422                	ld	s0,8(sp)
     c6a:	0141                	addi	sp,sp,16
     c6c:	8082                	ret

0000000000000c6e <strlen>:

uint
strlen(const char *s)
{
     c6e:	1141                	addi	sp,sp,-16
     c70:	e422                	sd	s0,8(sp)
     c72:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c74:	00054783          	lbu	a5,0(a0)
     c78:	cf91                	beqz	a5,c94 <strlen+0x26>
     c7a:	0505                	addi	a0,a0,1
     c7c:	87aa                	mv	a5,a0
     c7e:	4685                	li	a3,1
     c80:	9e89                	subw	a3,a3,a0
     c82:	00f6853b          	addw	a0,a3,a5
     c86:	0785                	addi	a5,a5,1
     c88:	fff7c703          	lbu	a4,-1(a5)
     c8c:	fb7d                	bnez	a4,c82 <strlen+0x14>
    ;
  return n;
}
     c8e:	6422                	ld	s0,8(sp)
     c90:	0141                	addi	sp,sp,16
     c92:	8082                	ret
  for(n = 0; s[n]; n++)
     c94:	4501                	li	a0,0
     c96:	bfe5                	j	c8e <strlen+0x20>

0000000000000c98 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c98:	1141                	addi	sp,sp,-16
     c9a:	e422                	sd	s0,8(sp)
     c9c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c9e:	ca19                	beqz	a2,cb4 <memset+0x1c>
     ca0:	87aa                	mv	a5,a0
     ca2:	1602                	slli	a2,a2,0x20
     ca4:	9201                	srli	a2,a2,0x20
     ca6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     caa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cae:	0785                	addi	a5,a5,1
     cb0:	fee79de3          	bne	a5,a4,caa <memset+0x12>
  }
  return dst;
}
     cb4:	6422                	ld	s0,8(sp)
     cb6:	0141                	addi	sp,sp,16
     cb8:	8082                	ret

0000000000000cba <strchr>:

char*
strchr(const char *s, char c)
{
     cba:	1141                	addi	sp,sp,-16
     cbc:	e422                	sd	s0,8(sp)
     cbe:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cc0:	00054783          	lbu	a5,0(a0)
     cc4:	cb99                	beqz	a5,cda <strchr+0x20>
    if(*s == c)
     cc6:	00f58763          	beq	a1,a5,cd4 <strchr+0x1a>
  for(; *s; s++)
     cca:	0505                	addi	a0,a0,1
     ccc:	00054783          	lbu	a5,0(a0)
     cd0:	fbfd                	bnez	a5,cc6 <strchr+0xc>
      return (char*)s;
  return 0;
     cd2:	4501                	li	a0,0
}
     cd4:	6422                	ld	s0,8(sp)
     cd6:	0141                	addi	sp,sp,16
     cd8:	8082                	ret
  return 0;
     cda:	4501                	li	a0,0
     cdc:	bfe5                	j	cd4 <strchr+0x1a>

0000000000000cde <gets>:

char*
gets(char *buf, int max)
{
     cde:	711d                	addi	sp,sp,-96
     ce0:	ec86                	sd	ra,88(sp)
     ce2:	e8a2                	sd	s0,80(sp)
     ce4:	e4a6                	sd	s1,72(sp)
     ce6:	e0ca                	sd	s2,64(sp)
     ce8:	fc4e                	sd	s3,56(sp)
     cea:	f852                	sd	s4,48(sp)
     cec:	f456                	sd	s5,40(sp)
     cee:	f05a                	sd	s6,32(sp)
     cf0:	ec5e                	sd	s7,24(sp)
     cf2:	1080                	addi	s0,sp,96
     cf4:	8baa                	mv	s7,a0
     cf6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cf8:	892a                	mv	s2,a0
     cfa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cfc:	4aa9                	li	s5,10
     cfe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d00:	89a6                	mv	s3,s1
     d02:	2485                	addiw	s1,s1,1
     d04:	0344d863          	bge	s1,s4,d34 <gets+0x56>
    cc = read(0, &c, 1);
     d08:	4605                	li	a2,1
     d0a:	faf40593          	addi	a1,s0,-81
     d0e:	4501                	li	a0,0
     d10:	00000097          	auipc	ra,0x0
     d14:	19c080e7          	jalr	412(ra) # eac <read>
    if(cc < 1)
     d18:	00a05e63          	blez	a0,d34 <gets+0x56>
    buf[i++] = c;
     d1c:	faf44783          	lbu	a5,-81(s0)
     d20:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d24:	01578763          	beq	a5,s5,d32 <gets+0x54>
     d28:	0905                	addi	s2,s2,1
     d2a:	fd679be3          	bne	a5,s6,d00 <gets+0x22>
  for(i=0; i+1 < max; ){
     d2e:	89a6                	mv	s3,s1
     d30:	a011                	j	d34 <gets+0x56>
     d32:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d34:	99de                	add	s3,s3,s7
     d36:	00098023          	sb	zero,0(s3)
  return buf;
}
     d3a:	855e                	mv	a0,s7
     d3c:	60e6                	ld	ra,88(sp)
     d3e:	6446                	ld	s0,80(sp)
     d40:	64a6                	ld	s1,72(sp)
     d42:	6906                	ld	s2,64(sp)
     d44:	79e2                	ld	s3,56(sp)
     d46:	7a42                	ld	s4,48(sp)
     d48:	7aa2                	ld	s5,40(sp)
     d4a:	7b02                	ld	s6,32(sp)
     d4c:	6be2                	ld	s7,24(sp)
     d4e:	6125                	addi	sp,sp,96
     d50:	8082                	ret

0000000000000d52 <stat>:

int
stat(const char *n, struct stat *st)
{
     d52:	1101                	addi	sp,sp,-32
     d54:	ec06                	sd	ra,24(sp)
     d56:	e822                	sd	s0,16(sp)
     d58:	e426                	sd	s1,8(sp)
     d5a:	e04a                	sd	s2,0(sp)
     d5c:	1000                	addi	s0,sp,32
     d5e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d60:	4581                	li	a1,0
     d62:	00000097          	auipc	ra,0x0
     d66:	172080e7          	jalr	370(ra) # ed4 <open>
  if(fd < 0)
     d6a:	02054563          	bltz	a0,d94 <stat+0x42>
     d6e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d70:	85ca                	mv	a1,s2
     d72:	00000097          	auipc	ra,0x0
     d76:	17a080e7          	jalr	378(ra) # eec <fstat>
     d7a:	892a                	mv	s2,a0
  close(fd);
     d7c:	8526                	mv	a0,s1
     d7e:	00000097          	auipc	ra,0x0
     d82:	13e080e7          	jalr	318(ra) # ebc <close>
  return r;
}
     d86:	854a                	mv	a0,s2
     d88:	60e2                	ld	ra,24(sp)
     d8a:	6442                	ld	s0,16(sp)
     d8c:	64a2                	ld	s1,8(sp)
     d8e:	6902                	ld	s2,0(sp)
     d90:	6105                	addi	sp,sp,32
     d92:	8082                	ret
    return -1;
     d94:	597d                	li	s2,-1
     d96:	bfc5                	j	d86 <stat+0x34>

0000000000000d98 <atoi>:

int
atoi(const char *s)
{
     d98:	1141                	addi	sp,sp,-16
     d9a:	e422                	sd	s0,8(sp)
     d9c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d9e:	00054603          	lbu	a2,0(a0)
     da2:	fd06079b          	addiw	a5,a2,-48
     da6:	0ff7f793          	andi	a5,a5,255
     daa:	4725                	li	a4,9
     dac:	02f76963          	bltu	a4,a5,dde <atoi+0x46>
     db0:	86aa                	mv	a3,a0
  n = 0;
     db2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     db4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     db6:	0685                	addi	a3,a3,1
     db8:	0025179b          	slliw	a5,a0,0x2
     dbc:	9fa9                	addw	a5,a5,a0
     dbe:	0017979b          	slliw	a5,a5,0x1
     dc2:	9fb1                	addw	a5,a5,a2
     dc4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dc8:	0006c603          	lbu	a2,0(a3)
     dcc:	fd06071b          	addiw	a4,a2,-48
     dd0:	0ff77713          	andi	a4,a4,255
     dd4:	fee5f1e3          	bgeu	a1,a4,db6 <atoi+0x1e>
  return n;
}
     dd8:	6422                	ld	s0,8(sp)
     dda:	0141                	addi	sp,sp,16
     ddc:	8082                	ret
  n = 0;
     dde:	4501                	li	a0,0
     de0:	bfe5                	j	dd8 <atoi+0x40>

0000000000000de2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     de2:	1141                	addi	sp,sp,-16
     de4:	e422                	sd	s0,8(sp)
     de6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     de8:	02b57463          	bgeu	a0,a1,e10 <memmove+0x2e>
    while(n-- > 0)
     dec:	00c05f63          	blez	a2,e0a <memmove+0x28>
     df0:	1602                	slli	a2,a2,0x20
     df2:	9201                	srli	a2,a2,0x20
     df4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     df8:	872a                	mv	a4,a0
      *dst++ = *src++;
     dfa:	0585                	addi	a1,a1,1
     dfc:	0705                	addi	a4,a4,1
     dfe:	fff5c683          	lbu	a3,-1(a1)
     e02:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e06:	fee79ae3          	bne	a5,a4,dfa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e0a:	6422                	ld	s0,8(sp)
     e0c:	0141                	addi	sp,sp,16
     e0e:	8082                	ret
    dst += n;
     e10:	00c50733          	add	a4,a0,a2
    src += n;
     e14:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e16:	fec05ae3          	blez	a2,e0a <memmove+0x28>
     e1a:	fff6079b          	addiw	a5,a2,-1
     e1e:	1782                	slli	a5,a5,0x20
     e20:	9381                	srli	a5,a5,0x20
     e22:	fff7c793          	not	a5,a5
     e26:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e28:	15fd                	addi	a1,a1,-1
     e2a:	177d                	addi	a4,a4,-1
     e2c:	0005c683          	lbu	a3,0(a1)
     e30:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e34:	fee79ae3          	bne	a5,a4,e28 <memmove+0x46>
     e38:	bfc9                	j	e0a <memmove+0x28>

0000000000000e3a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e3a:	1141                	addi	sp,sp,-16
     e3c:	e422                	sd	s0,8(sp)
     e3e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e40:	ca05                	beqz	a2,e70 <memcmp+0x36>
     e42:	fff6069b          	addiw	a3,a2,-1
     e46:	1682                	slli	a3,a3,0x20
     e48:	9281                	srli	a3,a3,0x20
     e4a:	0685                	addi	a3,a3,1
     e4c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e4e:	00054783          	lbu	a5,0(a0)
     e52:	0005c703          	lbu	a4,0(a1)
     e56:	00e79863          	bne	a5,a4,e66 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e5a:	0505                	addi	a0,a0,1
    p2++;
     e5c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e5e:	fed518e3          	bne	a0,a3,e4e <memcmp+0x14>
  }
  return 0;
     e62:	4501                	li	a0,0
     e64:	a019                	j	e6a <memcmp+0x30>
      return *p1 - *p2;
     e66:	40e7853b          	subw	a0,a5,a4
}
     e6a:	6422                	ld	s0,8(sp)
     e6c:	0141                	addi	sp,sp,16
     e6e:	8082                	ret
  return 0;
     e70:	4501                	li	a0,0
     e72:	bfe5                	j	e6a <memcmp+0x30>

0000000000000e74 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e74:	1141                	addi	sp,sp,-16
     e76:	e406                	sd	ra,8(sp)
     e78:	e022                	sd	s0,0(sp)
     e7a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e7c:	00000097          	auipc	ra,0x0
     e80:	f66080e7          	jalr	-154(ra) # de2 <memmove>
}
     e84:	60a2                	ld	ra,8(sp)
     e86:	6402                	ld	s0,0(sp)
     e88:	0141                	addi	sp,sp,16
     e8a:	8082                	ret

0000000000000e8c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e8c:	4885                	li	a7,1
 ecall
     e8e:	00000073          	ecall
 ret
     e92:	8082                	ret

0000000000000e94 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e94:	4889                	li	a7,2
 ecall
     e96:	00000073          	ecall
 ret
     e9a:	8082                	ret

0000000000000e9c <wait>:
.global wait
wait:
 li a7, SYS_wait
     e9c:	488d                	li	a7,3
 ecall
     e9e:	00000073          	ecall
 ret
     ea2:	8082                	ret

0000000000000ea4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ea4:	4891                	li	a7,4
 ecall
     ea6:	00000073          	ecall
 ret
     eaa:	8082                	ret

0000000000000eac <read>:
.global read
read:
 li a7, SYS_read
     eac:	4895                	li	a7,5
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <write>:
.global write
write:
 li a7, SYS_write
     eb4:	48c1                	li	a7,16
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <close>:
.global close
close:
 li a7, SYS_close
     ebc:	48d5                	li	a7,21
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ec4:	4899                	li	a7,6
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <exec>:
.global exec
exec:
 li a7, SYS_exec
     ecc:	489d                	li	a7,7
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <open>:
.global open
open:
 li a7, SYS_open
     ed4:	48bd                	li	a7,15
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     edc:	48c5                	li	a7,17
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ee4:	48c9                	li	a7,18
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     eec:	48a1                	li	a7,8
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <link>:
.global link
link:
 li a7, SYS_link
     ef4:	48cd                	li	a7,19
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     efc:	48d1                	li	a7,20
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f04:	48a5                	li	a7,9
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <dup>:
.global dup
dup:
 li a7, SYS_dup
     f0c:	48a9                	li	a7,10
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f14:	48ad                	li	a7,11
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f1c:	48b1                	li	a7,12
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f24:	48b5                	li	a7,13
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f2c:	48b9                	li	a7,14
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     f34:	48d9                	li	a7,22
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
     f3c:	48dd                	li	a7,23
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
     f44:	48e1                	li	a7,24
 ecall
     f46:	00000073          	ecall
 ret
     f4a:	8082                	ret

0000000000000f4c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
     f4c:	48e5                	li	a7,25
 ecall
     f4e:	00000073          	ecall
 ret
     f52:	8082                	ret

0000000000000f54 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
     f54:	48e9                	li	a7,26
 ecall
     f56:	00000073          	ecall
 ret
     f5a:	8082                	ret

0000000000000f5c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f5c:	1101                	addi	sp,sp,-32
     f5e:	ec06                	sd	ra,24(sp)
     f60:	e822                	sd	s0,16(sp)
     f62:	1000                	addi	s0,sp,32
     f64:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f68:	4605                	li	a2,1
     f6a:	fef40593          	addi	a1,s0,-17
     f6e:	00000097          	auipc	ra,0x0
     f72:	f46080e7          	jalr	-186(ra) # eb4 <write>
}
     f76:	60e2                	ld	ra,24(sp)
     f78:	6442                	ld	s0,16(sp)
     f7a:	6105                	addi	sp,sp,32
     f7c:	8082                	ret

0000000000000f7e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f7e:	7139                	addi	sp,sp,-64
     f80:	fc06                	sd	ra,56(sp)
     f82:	f822                	sd	s0,48(sp)
     f84:	f426                	sd	s1,40(sp)
     f86:	f04a                	sd	s2,32(sp)
     f88:	ec4e                	sd	s3,24(sp)
     f8a:	0080                	addi	s0,sp,64
     f8c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f8e:	c299                	beqz	a3,f94 <printint+0x16>
     f90:	0805c863          	bltz	a1,1020 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f94:	2581                	sext.w	a1,a1
  neg = 0;
     f96:	4881                	li	a7,0
     f98:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f9c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f9e:	2601                	sext.w	a2,a2
     fa0:	00000517          	auipc	a0,0x0
     fa4:	73050513          	addi	a0,a0,1840 # 16d0 <digits>
     fa8:	883a                	mv	a6,a4
     faa:	2705                	addiw	a4,a4,1
     fac:	02c5f7bb          	remuw	a5,a1,a2
     fb0:	1782                	slli	a5,a5,0x20
     fb2:	9381                	srli	a5,a5,0x20
     fb4:	97aa                	add	a5,a5,a0
     fb6:	0007c783          	lbu	a5,0(a5)
     fba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fbe:	0005879b          	sext.w	a5,a1
     fc2:	02c5d5bb          	divuw	a1,a1,a2
     fc6:	0685                	addi	a3,a3,1
     fc8:	fec7f0e3          	bgeu	a5,a2,fa8 <printint+0x2a>
  if(neg)
     fcc:	00088b63          	beqz	a7,fe2 <printint+0x64>
    buf[i++] = '-';
     fd0:	fd040793          	addi	a5,s0,-48
     fd4:	973e                	add	a4,a4,a5
     fd6:	02d00793          	li	a5,45
     fda:	fef70823          	sb	a5,-16(a4)
     fde:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fe2:	02e05863          	blez	a4,1012 <printint+0x94>
     fe6:	fc040793          	addi	a5,s0,-64
     fea:	00e78933          	add	s2,a5,a4
     fee:	fff78993          	addi	s3,a5,-1
     ff2:	99ba                	add	s3,s3,a4
     ff4:	377d                	addiw	a4,a4,-1
     ff6:	1702                	slli	a4,a4,0x20
     ff8:	9301                	srli	a4,a4,0x20
     ffa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     ffe:	fff94583          	lbu	a1,-1(s2)
    1002:	8526                	mv	a0,s1
    1004:	00000097          	auipc	ra,0x0
    1008:	f58080e7          	jalr	-168(ra) # f5c <putc>
  while(--i >= 0)
    100c:	197d                	addi	s2,s2,-1
    100e:	ff3918e3          	bne	s2,s3,ffe <printint+0x80>
}
    1012:	70e2                	ld	ra,56(sp)
    1014:	7442                	ld	s0,48(sp)
    1016:	74a2                	ld	s1,40(sp)
    1018:	7902                	ld	s2,32(sp)
    101a:	69e2                	ld	s3,24(sp)
    101c:	6121                	addi	sp,sp,64
    101e:	8082                	ret
    x = -xx;
    1020:	40b005bb          	negw	a1,a1
    neg = 1;
    1024:	4885                	li	a7,1
    x = -xx;
    1026:	bf8d                	j	f98 <printint+0x1a>

0000000000001028 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1028:	7119                	addi	sp,sp,-128
    102a:	fc86                	sd	ra,120(sp)
    102c:	f8a2                	sd	s0,112(sp)
    102e:	f4a6                	sd	s1,104(sp)
    1030:	f0ca                	sd	s2,96(sp)
    1032:	ecce                	sd	s3,88(sp)
    1034:	e8d2                	sd	s4,80(sp)
    1036:	e4d6                	sd	s5,72(sp)
    1038:	e0da                	sd	s6,64(sp)
    103a:	fc5e                	sd	s7,56(sp)
    103c:	f862                	sd	s8,48(sp)
    103e:	f466                	sd	s9,40(sp)
    1040:	f06a                	sd	s10,32(sp)
    1042:	ec6e                	sd	s11,24(sp)
    1044:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1046:	0005c903          	lbu	s2,0(a1)
    104a:	18090f63          	beqz	s2,11e8 <vprintf+0x1c0>
    104e:	8aaa                	mv	s5,a0
    1050:	8b32                	mv	s6,a2
    1052:	00158493          	addi	s1,a1,1
  state = 0;
    1056:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1058:	02500a13          	li	s4,37
      if(c == 'd'){
    105c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1060:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1064:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1068:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    106c:	00000b97          	auipc	s7,0x0
    1070:	664b8b93          	addi	s7,s7,1636 # 16d0 <digits>
    1074:	a839                	j	1092 <vprintf+0x6a>
        putc(fd, c);
    1076:	85ca                	mv	a1,s2
    1078:	8556                	mv	a0,s5
    107a:	00000097          	auipc	ra,0x0
    107e:	ee2080e7          	jalr	-286(ra) # f5c <putc>
    1082:	a019                	j	1088 <vprintf+0x60>
    } else if(state == '%'){
    1084:	01498f63          	beq	s3,s4,10a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1088:	0485                	addi	s1,s1,1
    108a:	fff4c903          	lbu	s2,-1(s1)
    108e:	14090d63          	beqz	s2,11e8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1092:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1096:	fe0997e3          	bnez	s3,1084 <vprintf+0x5c>
      if(c == '%'){
    109a:	fd479ee3          	bne	a5,s4,1076 <vprintf+0x4e>
        state = '%';
    109e:	89be                	mv	s3,a5
    10a0:	b7e5                	j	1088 <vprintf+0x60>
      if(c == 'd'){
    10a2:	05878063          	beq	a5,s8,10e2 <vprintf+0xba>
      } else if(c == 'l') {
    10a6:	05978c63          	beq	a5,s9,10fe <vprintf+0xd6>
      } else if(c == 'x') {
    10aa:	07a78863          	beq	a5,s10,111a <vprintf+0xf2>
      } else if(c == 'p') {
    10ae:	09b78463          	beq	a5,s11,1136 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10b2:	07300713          	li	a4,115
    10b6:	0ce78663          	beq	a5,a4,1182 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10ba:	06300713          	li	a4,99
    10be:	0ee78e63          	beq	a5,a4,11ba <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10c2:	11478863          	beq	a5,s4,11d2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10c6:	85d2                	mv	a1,s4
    10c8:	8556                	mv	a0,s5
    10ca:	00000097          	auipc	ra,0x0
    10ce:	e92080e7          	jalr	-366(ra) # f5c <putc>
        putc(fd, c);
    10d2:	85ca                	mv	a1,s2
    10d4:	8556                	mv	a0,s5
    10d6:	00000097          	auipc	ra,0x0
    10da:	e86080e7          	jalr	-378(ra) # f5c <putc>
      }
      state = 0;
    10de:	4981                	li	s3,0
    10e0:	b765                	j	1088 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10e2:	008b0913          	addi	s2,s6,8
    10e6:	4685                	li	a3,1
    10e8:	4629                	li	a2,10
    10ea:	000b2583          	lw	a1,0(s6)
    10ee:	8556                	mv	a0,s5
    10f0:	00000097          	auipc	ra,0x0
    10f4:	e8e080e7          	jalr	-370(ra) # f7e <printint>
    10f8:	8b4a                	mv	s6,s2
      state = 0;
    10fa:	4981                	li	s3,0
    10fc:	b771                	j	1088 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10fe:	008b0913          	addi	s2,s6,8
    1102:	4681                	li	a3,0
    1104:	4629                	li	a2,10
    1106:	000b2583          	lw	a1,0(s6)
    110a:	8556                	mv	a0,s5
    110c:	00000097          	auipc	ra,0x0
    1110:	e72080e7          	jalr	-398(ra) # f7e <printint>
    1114:	8b4a                	mv	s6,s2
      state = 0;
    1116:	4981                	li	s3,0
    1118:	bf85                	j	1088 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    111a:	008b0913          	addi	s2,s6,8
    111e:	4681                	li	a3,0
    1120:	4641                	li	a2,16
    1122:	000b2583          	lw	a1,0(s6)
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	e56080e7          	jalr	-426(ra) # f7e <printint>
    1130:	8b4a                	mv	s6,s2
      state = 0;
    1132:	4981                	li	s3,0
    1134:	bf91                	j	1088 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1136:	008b0793          	addi	a5,s6,8
    113a:	f8f43423          	sd	a5,-120(s0)
    113e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1142:	03000593          	li	a1,48
    1146:	8556                	mv	a0,s5
    1148:	00000097          	auipc	ra,0x0
    114c:	e14080e7          	jalr	-492(ra) # f5c <putc>
  putc(fd, 'x');
    1150:	85ea                	mv	a1,s10
    1152:	8556                	mv	a0,s5
    1154:	00000097          	auipc	ra,0x0
    1158:	e08080e7          	jalr	-504(ra) # f5c <putc>
    115c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    115e:	03c9d793          	srli	a5,s3,0x3c
    1162:	97de                	add	a5,a5,s7
    1164:	0007c583          	lbu	a1,0(a5)
    1168:	8556                	mv	a0,s5
    116a:	00000097          	auipc	ra,0x0
    116e:	df2080e7          	jalr	-526(ra) # f5c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1172:	0992                	slli	s3,s3,0x4
    1174:	397d                	addiw	s2,s2,-1
    1176:	fe0914e3          	bnez	s2,115e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    117a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    117e:	4981                	li	s3,0
    1180:	b721                	j	1088 <vprintf+0x60>
        s = va_arg(ap, char*);
    1182:	008b0993          	addi	s3,s6,8
    1186:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    118a:	02090163          	beqz	s2,11ac <vprintf+0x184>
        while(*s != 0){
    118e:	00094583          	lbu	a1,0(s2)
    1192:	c9a1                	beqz	a1,11e2 <vprintf+0x1ba>
          putc(fd, *s);
    1194:	8556                	mv	a0,s5
    1196:	00000097          	auipc	ra,0x0
    119a:	dc6080e7          	jalr	-570(ra) # f5c <putc>
          s++;
    119e:	0905                	addi	s2,s2,1
        while(*s != 0){
    11a0:	00094583          	lbu	a1,0(s2)
    11a4:	f9e5                	bnez	a1,1194 <vprintf+0x16c>
        s = va_arg(ap, char*);
    11a6:	8b4e                	mv	s6,s3
      state = 0;
    11a8:	4981                	li	s3,0
    11aa:	bdf9                	j	1088 <vprintf+0x60>
          s = "(null)";
    11ac:	00000917          	auipc	s2,0x0
    11b0:	51c90913          	addi	s2,s2,1308 # 16c8 <malloc+0x3d6>
        while(*s != 0){
    11b4:	02800593          	li	a1,40
    11b8:	bff1                	j	1194 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11ba:	008b0913          	addi	s2,s6,8
    11be:	000b4583          	lbu	a1,0(s6)
    11c2:	8556                	mv	a0,s5
    11c4:	00000097          	auipc	ra,0x0
    11c8:	d98080e7          	jalr	-616(ra) # f5c <putc>
    11cc:	8b4a                	mv	s6,s2
      state = 0;
    11ce:	4981                	li	s3,0
    11d0:	bd65                	j	1088 <vprintf+0x60>
        putc(fd, c);
    11d2:	85d2                	mv	a1,s4
    11d4:	8556                	mv	a0,s5
    11d6:	00000097          	auipc	ra,0x0
    11da:	d86080e7          	jalr	-634(ra) # f5c <putc>
      state = 0;
    11de:	4981                	li	s3,0
    11e0:	b565                	j	1088 <vprintf+0x60>
        s = va_arg(ap, char*);
    11e2:	8b4e                	mv	s6,s3
      state = 0;
    11e4:	4981                	li	s3,0
    11e6:	b54d                	j	1088 <vprintf+0x60>
    }
  }
}
    11e8:	70e6                	ld	ra,120(sp)
    11ea:	7446                	ld	s0,112(sp)
    11ec:	74a6                	ld	s1,104(sp)
    11ee:	7906                	ld	s2,96(sp)
    11f0:	69e6                	ld	s3,88(sp)
    11f2:	6a46                	ld	s4,80(sp)
    11f4:	6aa6                	ld	s5,72(sp)
    11f6:	6b06                	ld	s6,64(sp)
    11f8:	7be2                	ld	s7,56(sp)
    11fa:	7c42                	ld	s8,48(sp)
    11fc:	7ca2                	ld	s9,40(sp)
    11fe:	7d02                	ld	s10,32(sp)
    1200:	6de2                	ld	s11,24(sp)
    1202:	6109                	addi	sp,sp,128
    1204:	8082                	ret

0000000000001206 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1206:	715d                	addi	sp,sp,-80
    1208:	ec06                	sd	ra,24(sp)
    120a:	e822                	sd	s0,16(sp)
    120c:	1000                	addi	s0,sp,32
    120e:	e010                	sd	a2,0(s0)
    1210:	e414                	sd	a3,8(s0)
    1212:	e818                	sd	a4,16(s0)
    1214:	ec1c                	sd	a5,24(s0)
    1216:	03043023          	sd	a6,32(s0)
    121a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    121e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1222:	8622                	mv	a2,s0
    1224:	00000097          	auipc	ra,0x0
    1228:	e04080e7          	jalr	-508(ra) # 1028 <vprintf>
}
    122c:	60e2                	ld	ra,24(sp)
    122e:	6442                	ld	s0,16(sp)
    1230:	6161                	addi	sp,sp,80
    1232:	8082                	ret

0000000000001234 <printf>:

void
printf(const char *fmt, ...)
{
    1234:	711d                	addi	sp,sp,-96
    1236:	ec06                	sd	ra,24(sp)
    1238:	e822                	sd	s0,16(sp)
    123a:	1000                	addi	s0,sp,32
    123c:	e40c                	sd	a1,8(s0)
    123e:	e810                	sd	a2,16(s0)
    1240:	ec14                	sd	a3,24(s0)
    1242:	f018                	sd	a4,32(s0)
    1244:	f41c                	sd	a5,40(s0)
    1246:	03043823          	sd	a6,48(s0)
    124a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    124e:	00840613          	addi	a2,s0,8
    1252:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1256:	85aa                	mv	a1,a0
    1258:	4505                	li	a0,1
    125a:	00000097          	auipc	ra,0x0
    125e:	dce080e7          	jalr	-562(ra) # 1028 <vprintf>
}
    1262:	60e2                	ld	ra,24(sp)
    1264:	6442                	ld	s0,16(sp)
    1266:	6125                	addi	sp,sp,96
    1268:	8082                	ret

000000000000126a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    126a:	1141                	addi	sp,sp,-16
    126c:	e422                	sd	s0,8(sp)
    126e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1270:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1274:	00001797          	auipc	a5,0x1
    1278:	d9c7b783          	ld	a5,-612(a5) # 2010 <freep>
    127c:	a805                	j	12ac <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    127e:	4618                	lw	a4,8(a2)
    1280:	9db9                	addw	a1,a1,a4
    1282:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1286:	6398                	ld	a4,0(a5)
    1288:	6318                	ld	a4,0(a4)
    128a:	fee53823          	sd	a4,-16(a0)
    128e:	a091                	j	12d2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1290:	ff852703          	lw	a4,-8(a0)
    1294:	9e39                	addw	a2,a2,a4
    1296:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1298:	ff053703          	ld	a4,-16(a0)
    129c:	e398                	sd	a4,0(a5)
    129e:	a099                	j	12e4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12a0:	6398                	ld	a4,0(a5)
    12a2:	00e7e463          	bltu	a5,a4,12aa <free+0x40>
    12a6:	00e6ea63          	bltu	a3,a4,12ba <free+0x50>
{
    12aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12ac:	fed7fae3          	bgeu	a5,a3,12a0 <free+0x36>
    12b0:	6398                	ld	a4,0(a5)
    12b2:	00e6e463          	bltu	a3,a4,12ba <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b6:	fee7eae3          	bltu	a5,a4,12aa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12ba:	ff852583          	lw	a1,-8(a0)
    12be:	6390                	ld	a2,0(a5)
    12c0:	02059713          	slli	a4,a1,0x20
    12c4:	9301                	srli	a4,a4,0x20
    12c6:	0712                	slli	a4,a4,0x4
    12c8:	9736                	add	a4,a4,a3
    12ca:	fae60ae3          	beq	a2,a4,127e <free+0x14>
    bp->s.ptr = p->s.ptr;
    12ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12d2:	4790                	lw	a2,8(a5)
    12d4:	02061713          	slli	a4,a2,0x20
    12d8:	9301                	srli	a4,a4,0x20
    12da:	0712                	slli	a4,a4,0x4
    12dc:	973e                	add	a4,a4,a5
    12de:	fae689e3          	beq	a3,a4,1290 <free+0x26>
  } else
    p->s.ptr = bp;
    12e2:	e394                	sd	a3,0(a5)
  freep = p;
    12e4:	00001717          	auipc	a4,0x1
    12e8:	d2f73623          	sd	a5,-724(a4) # 2010 <freep>
}
    12ec:	6422                	ld	s0,8(sp)
    12ee:	0141                	addi	sp,sp,16
    12f0:	8082                	ret

00000000000012f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12f2:	7139                	addi	sp,sp,-64
    12f4:	fc06                	sd	ra,56(sp)
    12f6:	f822                	sd	s0,48(sp)
    12f8:	f426                	sd	s1,40(sp)
    12fa:	f04a                	sd	s2,32(sp)
    12fc:	ec4e                	sd	s3,24(sp)
    12fe:	e852                	sd	s4,16(sp)
    1300:	e456                	sd	s5,8(sp)
    1302:	e05a                	sd	s6,0(sp)
    1304:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1306:	02051493          	slli	s1,a0,0x20
    130a:	9081                	srli	s1,s1,0x20
    130c:	04bd                	addi	s1,s1,15
    130e:	8091                	srli	s1,s1,0x4
    1310:	0014899b          	addiw	s3,s1,1
    1314:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1316:	00001517          	auipc	a0,0x1
    131a:	cfa53503          	ld	a0,-774(a0) # 2010 <freep>
    131e:	c515                	beqz	a0,134a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1320:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1322:	4798                	lw	a4,8(a5)
    1324:	02977f63          	bgeu	a4,s1,1362 <malloc+0x70>
    1328:	8a4e                	mv	s4,s3
    132a:	0009871b          	sext.w	a4,s3
    132e:	6685                	lui	a3,0x1
    1330:	00d77363          	bgeu	a4,a3,1336 <malloc+0x44>
    1334:	6a05                	lui	s4,0x1
    1336:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    133a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    133e:	00001917          	auipc	s2,0x1
    1342:	cd290913          	addi	s2,s2,-814 # 2010 <freep>
  if(p == (char*)-1)
    1346:	5afd                	li	s5,-1
    1348:	a88d                	j	13ba <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    134a:	00001797          	auipc	a5,0x1
    134e:	0be78793          	addi	a5,a5,190 # 2408 <base>
    1352:	00001717          	auipc	a4,0x1
    1356:	caf73f23          	sd	a5,-834(a4) # 2010 <freep>
    135a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    135c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1360:	b7e1                	j	1328 <malloc+0x36>
      if(p->s.size == nunits)
    1362:	02e48b63          	beq	s1,a4,1398 <malloc+0xa6>
        p->s.size -= nunits;
    1366:	4137073b          	subw	a4,a4,s3
    136a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    136c:	1702                	slli	a4,a4,0x20
    136e:	9301                	srli	a4,a4,0x20
    1370:	0712                	slli	a4,a4,0x4
    1372:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1374:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1378:	00001717          	auipc	a4,0x1
    137c:	c8a73c23          	sd	a0,-872(a4) # 2010 <freep>
      return (void*)(p + 1);
    1380:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1384:	70e2                	ld	ra,56(sp)
    1386:	7442                	ld	s0,48(sp)
    1388:	74a2                	ld	s1,40(sp)
    138a:	7902                	ld	s2,32(sp)
    138c:	69e2                	ld	s3,24(sp)
    138e:	6a42                	ld	s4,16(sp)
    1390:	6aa2                	ld	s5,8(sp)
    1392:	6b02                	ld	s6,0(sp)
    1394:	6121                	addi	sp,sp,64
    1396:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1398:	6398                	ld	a4,0(a5)
    139a:	e118                	sd	a4,0(a0)
    139c:	bff1                	j	1378 <malloc+0x86>
  hp->s.size = nu;
    139e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13a2:	0541                	addi	a0,a0,16
    13a4:	00000097          	auipc	ra,0x0
    13a8:	ec6080e7          	jalr	-314(ra) # 126a <free>
  return freep;
    13ac:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13b0:	d971                	beqz	a0,1384 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13b4:	4798                	lw	a4,8(a5)
    13b6:	fa9776e3          	bgeu	a4,s1,1362 <malloc+0x70>
    if(p == freep)
    13ba:	00093703          	ld	a4,0(s2)
    13be:	853e                	mv	a0,a5
    13c0:	fef719e3          	bne	a4,a5,13b2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13c4:	8552                	mv	a0,s4
    13c6:	00000097          	auipc	ra,0x0
    13ca:	b56080e7          	jalr	-1194(ra) # f1c <sbrk>
  if(p == (char*)-1)
    13ce:	fd5518e3          	bne	a0,s5,139e <malloc+0xac>
        return 0;
    13d2:	4501                	li	a0,0
    13d4:	bf45                	j	1384 <malloc+0x92>

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include"syscall.h"

extern int syscall_counts[32];

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

///////////////////////
uint64 
sys_settickets(void) {
    int number;
    argint(0, &number);
    myproc()->tickets = number; // Set the number of tickets for the current process
    return number;
}

uint64 
sys_getSysCount(void) {
    int mask;
    argint(0, &mask);
    // Return the count of the specified syscall
    int syscall_number = -1;
    for (int i = 0; i < 32; i++) {
        if (mask & (1 << i)) {
            syscall_number = i;  // Found the syscall number
            break;
        }
    }

    // Check if a valid syscall number was found
    if (syscall_number == -1) {
        return -1;  // No valid syscall found in the mask
    }
    return syscall_counts[syscall_number];
}

uint64 
sys_sigalarm(void) {
    int interval;
    uint64 handler;

    // Fetch the arguments
    argint(0, &interval);
    argaddr(1, &handler);

    struct proc *p = myproc();

    // Set the alarm state
    p->alarm_interval = interval;
    p->alarm_handler = handler;
    p->alarm_state = 1; // Enable the alarm

    return 0;
}


uint64 
sys_sigreturn(void) {
    struct proc *p = myproc();

    // Reset the alarm state
    // p->alarm_handler = 0;
    // p->alarm_interval = 0;
    // p->ticks = 0;
    // p->alarm_state = 0; // Disable the alarm

    // // Restore the saved context
    // // Assuming you have saved context in p->saved_context (you need to save it when switching)
    // p->context = p->saved_context;
    memmove(p->trapframe, p->alarm_tf, PGSIZE);
    kfree(p->alarm_tf);
    p->handle_permission=1;
    return p->trapframe->a0;
}


//////////////////////
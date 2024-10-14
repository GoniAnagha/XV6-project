#include "kernel/types.h"
#include "user/user.h"

const char* syscall_name(int mask) {
    switch(mask) {
        case 1 << 1: return "fork";
        case 1 << 2: return "exit";
        case 1 << 3: return "wait";
        case 1 << 4: return "pipe";
        case 1 << 5: return "read";
        case 1 << 6: return "kill";
        case 1 << 7: return "exec";
        case 1 << 8: return "fstat";
        case 1 << 9: return "chdir";
        case 1 << 10: return "dup";
        case 1 << 11: return "getpid";
        case 1 << 12: return "sbrk";
        case 1 << 13: return "sleep";
        case 1 << 14: return "uptime";
        case 1 << 15: return "open";
        case 1 << 16: return "write";
        case 1 << 17: return "mknod";
        case 1 << 18: return "unlink";
        case 1 << 19: return "link";
        case 1 << 20: return "mkdir";
        case 1 << 21: return "close";
        case 1 << 22: return "waitx";
        case 1 << 23: return "settickets";
        case 1 << 24: return "getSysCount";
        // Add more cases for other syscalls as needed
        default: return "unknown syscall";
    }
}

int main(int argc, char *argv[]) {
    char i = '2';
    if (argc < 3) {
        printf(&i, "Usage: syscount <mask> <command> [args...]\n");
        exit(1);
    }

    int mask = atoi(argv[1]);
    int pid = fork();
    if (pid < 0) {
        printf(&i, "fork failed\n");
        exit(1);
    }

    if (pid == 0) {  // Child process
        exec(argv[2], argv + 2);
        printf(&i, "exec failed\n");
        exit(1);
    } else {  // Parent process
        wait(0);
        int count = getSysCount(mask);
        printf("PID %d called %s %d times\n", pid, syscall_name(mask), count);
    }
    exit(0);
}

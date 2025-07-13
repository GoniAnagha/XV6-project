### XV6 code is present in initial xv6 folder

### Networks folder contains other part of the entire assignment

# XV6 Enhancements - OS Mini Project

This repository contains modifications and enhancements to the XV6 Operating System, implementing system calls, scheduling policies, and networking-based multiplayer games.

---

## Part 1: System Calls

### 1.`syscount` - Count System Call Usage

**Functionality:**
- Tracks the number of times a specific system call is invoked by a process and all of its children.
- Usage: `syscount <mask> command [args]`
- Outputs:  
  `PID <caller pid> called <syscall name> <n> times.`

**Implementation Summary:**
- Added an array in `struct proc` to maintain syscall count (max 31).
- Incremented syscall count in `syscall()` dispatcher.
- System call registration:
  - Defined syscall number in `syscall.h`
  - Added to syscall table in `syscall.c`
  - User-side function added in `usys.pl`, `user.h`, and `ulib.c`.
- Initialized count array in `allocproc()` in `proc.c`.

---

### 2.`sigalarm` and `sigreturn` - Periodic Alerts

**Functionality:**
- `sigalarm(interval, handler)`: sets up a timer-based alert system.
- `sigreturn()`: restores process context to resume normal execution.

**Implementation Summary:**
- Added fields in `struct proc`:
  - Interval
  - Tick count
  - Alarm state
  - Handler address
  - Trapframe backup
- Set and reset logic in `sigalarm()` and `sigreturn()` syscalls in `sysproc.c`.
- Integrated with `trap.c` to:
  - Check on timer interrupt
  - Trigger handler when interval ticks are met
  - Yield control post-handler
- User-facing code via `user.h`, `usys.pl`, and syscall table.

---

## Part 2: Scheduling 

### 1. Lottery Based Scheduling (LBS)

**Features:**
- Each process has a "ticket" count.
- Random winner is chosen weighted by tickets.
- In case of a tie (same ticket count), the process with **earlier arrival time** wins.

**System Call:**
- `settickets(int n)`: sets ticket count for calling process.

**Implementation Summary:**
- Fields added to `struct proc`:
  - `tickets`, `arrival_time`
- In `allocproc()`:
  - Default 1 ticket, set arrival time.
- Lottery logic:
  - Only `RUNNABLE` processes participate.
  - Tie-breaker uses `arrival_time`.
- Pseudo-random number generator added.
- `settickets()` syscall created and registered.

---

### 2. Multi-Level Feedback Queue (MLFQ)

**Queue Structure:**
- 4 queues (priority 0 - highest to 3 - lowest)
- Time slices:
  - Q0: 1 tick
  - Q1: 4 ticks
  - Q2: 8 ticks
  - Q3: 16 ticks

**Features:**
- New processes start in queue 0.
- Preemption occurs if higher-priority process enters.
- Voluntary relinquishment → return to same queue.
- Full slice usage → demotion to lower queue.
- **Priority Boosting**: every 48 ticks, all processes promoted to queue 0.

**Implementation Summary:**
- Fields in `struct proc`: `priority`, `ticks_used`
- Queue arrays and macros defined.
- `scheduler()` modified to implement MLFQ logic.
- Boosting logic based on global tick count.
- Round-robin within lowest queue (Q3).
- `procdump()` modified to help debugging.

## Design Considerations

### ➤ Arrival Time in LBS:
- Ensures fairness and prevents starvation.
- Allows deterministic scheduling when tickets are tied.

### ➤ Pitfalls to Watch Out For:
- Over-prioritizing early processes can starve new ones.
- If arrival times are close, they don’t help much in distinction.

### ➤ If All Processes Have Same Tickets:
- Lottery becomes purely random.
- Equal probability for all → fair but possibly inefficient.
- Doesn’t favor I/O-bound or interactive processes.

---

## Part 3: Networking

### Multiplayer Tic-Tac-Toe

**Features:**
- 3x3 board, two clients (Player X and Player O).
- Server controls turn flow, game state, and outcome.
- Clients send moves (row, col) → receive updated board.
- Handles invalid moves, win/draw detection, replay option.

**Game Flow:**
1. Server waits for 2 clients.
2. Assigns X and O.
3. Alternates turns.
4. Sends board to both after each move.
5. Checks for win/draw → announces result.
6. Offers replay → restarts or exits.

**Implementation:**
- Both **TCP** and **UDP** versions created.
- File Structure:
  - `networks/tcp_server.c`
  - `networks/tcp_client.c`
  - `networks/udp_server.c`
  - `networks/udp_client.c`

---

### TCP Features Over UDP

**Goals:**
Simulate basic TCP features using UDP sockets.

**Implemented Functionalities:**
- **Data Sequencing**:
  - Text is split into numbered chunks.
  - Sequence number and total count sent with data.
- **Acknowledgements & Retransmission**:
  - Receiver sends ACK for each chunk.
  - Sender retransmits if no ACK in 0.1s.
  - Non-blocking sockets ensure pipelined sending.

**Testing:**
- Randomly skip every 3rd ACK to test retransmission logic. (Commented for final version.)

**Implementation:**
- Files:
  - `networks/partB/client_udp_tcp.c`
  - `networks/partB/server_udp_tcp.c`

---

---

## How to Compile

```bash
# Round Robin (default)
make clean && make qemu

# Lottery Based Scheduling
make clean && make qemu SCHEDULER=LBS

# Multi-Level Feedback Queue
make clean && make qemu SCHEDULER=MLFQ


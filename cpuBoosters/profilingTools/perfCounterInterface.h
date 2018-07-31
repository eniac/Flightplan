/**
 *
 * Basic functions for performance monitoring with CPU counters. 
 * For more info, see: http://man7.org/linux/man-pages/man2/perf_event_open.2.html
 */

#ifndef PERFCOUNTERINTERFACE_H
#define PERFCOUNTERINTERFACE_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <linux/perf_event.h>
#include <asm/unistd.h>


#define COUNTERTYPE PERF_COUNT_HW_REF_CPU_CYCLES
char * counterTypeStr = "PERF_COUNT_HW_REF_CPU_CYCLES";
/**
 *
 * counter types: (set pe.config to one of these)
 * 
   PERF_COUNT_HW_CPU_CYCLES
          Total cycles.  Be wary of what happens during CPU
          frequency scaling.

   PERF_COUNT_HW_INSTRUCTIONS
          Retired instructions.  Be careful, these can be
          affected by various issues, most notably hardware
          interrupt counts.

   PERF_COUNT_HW_CACHE_REFERENCES
          Cache accesses.  Usually this indicates Last Level
          Cache accesses but this may vary depending on your
          CPU.  This may include prefetches and coherency
          messages; again this depends on the design of your
          CPU.

   PERF_COUNT_HW_CACHE_MISSES
          Cache misses.  Usually this indicates Last Level
          Cache misses; this is intended to be used in con‐
          junction with the PERF_COUNT_HW_CACHE_REFERENCES
          event to calculate cache miss rates.

   PERF_COUNT_HW_BRANCH_INSTRUCTIONS
          Retired branch instructions.  Prior to Linux
          2.6.35, this used the wrong event on AMD processors.

   PERF_COUNT_HW_BRANCH_MISSES
          Mispredicted branch instructions.

   PERF_COUNT_HW_BUS_CYCLES
          Bus cycles, which can be different from total
          cycles.

   PERF_COUNT_HW_STALLED_CYCLES_FRONTEND (since Linux 3.0)
          Stalled cycles during issue.

   PERF_COUNT_HW_STALLED_CYCLES_BACKEND (since Linux 3.0)
          Stalled cycles during retirement.

   PERF_COUNT_HW_REF_CPU_CYCLES (since Linux 3.3)
          Total cycles; not affected by CPU frequency scaling.
 * 
 */

// Start counting and get FD.
int startCounter(uint64_t counterType);

// Stop counting, get counter, and close FD.
long long stopCounter(int fd);






// Helper.
static long perf_event_open(struct perf_event_attr *hw_event, pid_t pid,
               int cpu, int group_fd, unsigned long flags);




static long
perf_event_open(struct perf_event_attr *hw_event, pid_t pid,
               int cpu, int group_fd, unsigned long flags)
{
   int ret;

   ret = syscall(__NR_perf_event_open, hw_event, pid, cpu,
                  group_fd, flags);
   return ret;
}



int startCounter(uint64_t counterType){
  // Set up call to monitor instruction count using perf.
  struct perf_event_attr pe;
  int fd;
  memset(&pe, 0, sizeof(struct perf_event_attr));
  pe.type = PERF_TYPE_HARDWARE;
  pe.size = sizeof(struct perf_event_attr);
  pe.config = counterType;
  pe.disabled = 1;
  pe.exclude_kernel = 1;
  pe.exclude_hv = 1;

  fd = perf_event_open(&pe, 0, -1, -1, 0);
  if (fd == -1) {
    fprintf(stderr, "Error opening leader %llx\n", pe.config);
    exit(EXIT_FAILURE);
  }
  ioctl(fd, PERF_EVENT_IOC_RESET, 0);
  ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
  return fd;  
}

// Get CPU cycle timer.
long long stopCounter(int fd) {
     ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
     long long count;
     int retVal = read(fd, &count, sizeof(long long));
     close(fd);    
     return count;
}

void stopCounterAndPrint(const char * label, int fd) {
     ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
     long long count;
     int retVal = read(fd, &count, sizeof(long long));
     close(fd);   
     printf("%s%lli\n",label, count); 
}

int resetCounterAndPrint(const char * label, int fd, uint64_t counterType) {
     ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
     long long count;
     int retVal = read(fd, &count, sizeof(long long));
     close(fd);   
     printf("%s%lli\n",label, count); 
     return startCounter(counterType);
}


#endif // PERFCOUNTERINTERFACE_H
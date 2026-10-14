/* IP-2A R13 research-only process resource-control feasibility probe.
 * No route, parser, schema, file input, network, or product IPC is used.
 */
#define _DARWIN_C_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <libproc.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/proc_info.h>
#include <sys/resource.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define MIB (1024ULL * 1024ULL)
#define AS_BUDGET (128ULL * MIB)
#define DATA_LIMIT (256ULL * MIB)
#define AS_TARGET (384ULL * MIB)
#define DATA_TARGET (192ULL * MIB)
#define CHUNK (4ULL * MIB)
#define CHILD_WATCHDOG_MS 6000
#define TERM_GRACE_MS 250
#define OUTPUT_CAP 4096

typedef struct {
    int resource;
    int set_errno;
    uint64_t soft;
    uint64_t hard;
    uint64_t previous_soft;
    uint64_t previous_hard;
    uint64_t baseline_virtual;
    uint64_t applied_limit;
} control_record;

static uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static int task_sizes(pid_t pid, uint64_t *resident, uint64_t *virtual_size) {
    struct proc_taskinfo info;
    int n = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, sizeof(info));
    if (n != (int)sizeof(info)) return -1;
    *resident = info.pti_resident_size;
    *virtual_size = info.pti_virtual_size;
    return 0;
}

static int write_all(int fd, const void *buf, size_t size) {
    const char *p = buf;
    while (size) {
        ssize_t n = write(fd, p, size);
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) return -1;
        p += n;
        size -= (size_t)n;
    }
    return 0;
}

static void child_limits_and_exec(const char *self, const char *mode,
                                  int control_fd) {
    control_record rec;
    memset(&rec, 0, sizeof(rec));
    uint64_t resident = 0, virtual_size = 0;
    (void)task_sizes(getpid(), &resident, &virtual_size);
    rec.baseline_virtual = virtual_size;

    struct rlimit lim;
    struct rlimit previous;
    if (strcmp(mode, "cpu") == 0 || strcmp(mode, "cpu-watchdog") == 0) {
        rec.resource = RLIMIT_CPU;
    } else if (strcmp(mode, "mem-as") == 0) {
        rec.resource = RLIMIT_AS;
        rec.applied_limit = virtual_size + AS_BUDGET;
    } else {
        rec.resource = RLIMIT_DATA;
        rec.applied_limit = DATA_LIMIT;
    }
    if (getrlimit(rec.resource, &previous) != 0) {
        rec.set_errno = errno;
        (void)write_all(control_fd, &rec, sizeof(rec));
        _exit(91);
    }
    rec.previous_soft = (uint64_t)previous.rlim_cur;
    rec.previous_hard = (uint64_t)previous.rlim_max;
    if (strcmp(mode, "cpu") == 0) rec.applied_limit = 1;
    if (strcmp(mode, "cpu-watchdog") == 0) rec.applied_limit = 30;
    if (previous.rlim_max != RLIM_INFINITY && rec.applied_limit > (uint64_t)previous.rlim_max)
        rec.applied_limit = (uint64_t)previous.rlim_max;
    lim.rlim_cur = (rlim_t)rec.applied_limit;
    if (previous.rlim_cur != RLIM_INFINITY && previous.rlim_cur < lim.rlim_cur)
        lim.rlim_cur = previous.rlim_cur;
    lim.rlim_max = lim.rlim_cur;
    if (previous.rlim_max != RLIM_INFINITY && previous.rlim_max < lim.rlim_max)
        lim.rlim_max = previous.rlim_max;
    if (strcmp(mode, "cpu") == 0) {
        lim.rlim_cur = previous.rlim_cur == RLIM_INFINITY || previous.rlim_cur > 1 ? 1 : previous.rlim_cur;
        lim.rlim_max = previous.rlim_max == RLIM_INFINITY || previous.rlim_max > 2 ? 2 : previous.rlim_max;
        if (lim.rlim_cur > lim.rlim_max) lim.rlim_cur = lim.rlim_max;
    } else if (strcmp(mode, "cpu-watchdog") == 0) {
        lim.rlim_cur = previous.rlim_cur == RLIM_INFINITY || previous.rlim_cur > 30 ? 30 : previous.rlim_cur;
        lim.rlim_max = previous.rlim_max == RLIM_INFINITY || previous.rlim_max > 31 ? 31 : previous.rlim_max;
        if (lim.rlim_cur > lim.rlim_max) lim.rlim_cur = lim.rlim_max;
    }
    rec.soft = (uint64_t)lim.rlim_cur;
    rec.hard = (uint64_t)lim.rlim_max;
    rec.soft = (uint64_t)lim.rlim_cur;
    rec.hard = (uint64_t)lim.rlim_max;
    if (setrlimit(rec.resource, &lim) != 0) rec.set_errno = errno;
    if (write_all(control_fd, &rec, sizeof(rec)) != 0) _exit(90);
    close(control_fd);
    if (rec.set_errno) _exit(91);
    char *const args[] = {(char *)self, (char *)"--child", (char *)mode, NULL};
    execv(self, args);
    _exit(92);
}

static int child_work(const char *mode) {
    uint64_t resident = 0, virtual_size = 0;
    (void)task_sizes(getpid(), &resident, &virtual_size);
    dprintf(STDOUT_FILENO, "CHILD_STARTED baseline_virtual_bytes=%llu\n",
            (unsigned long long)virtual_size);

    if (strcmp(mode, "cpu") == 0 || strcmp(mode, "cpu-watchdog") == 0) {
        if (strcmp(mode, "cpu-watchdog") == 0) signal(SIGTERM, SIG_IGN);
        volatile uint64_t value = 0x9e3779b97f4a7c15ULL;
        for (;;) value = value * 2862933555777941757ULL + 3037000493ULL;
    }

    const uint64_t target = strcmp(mode, "mem-as") == 0 ? AS_TARGET : DATA_TARGET;
    void *blocks[AS_TARGET / CHUNK + 1];
    size_t used = 0;
    uint64_t grown = 0;
    long page = sysconf(_SC_PAGESIZE);
    if (page <= 0) page = 4096;
    while (grown < target && used < sizeof(blocks) / sizeof(blocks[0])) {
        size_t amount = (size_t)((target - grown) < CHUNK ? target - grown : CHUNK);
        void *p;
        if (strcmp(mode, "mem-as") == 0) {
            p = mmap(NULL, amount, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
            if (p == MAP_FAILED) p = NULL;
        } else {
            p = sbrk((intptr_t)amount);
            if (p == (void *)-1) p = NULL;
        }
        if (!p) {
            int e = errno;
            dprintf(STDOUT_FILENO,
                    "SYNTHETIC_ALLOCATION_FAILED errno=%d errno_name=%s growth_bytes=%llu\n",
                    e, e == ENOMEM ? "ENOMEM" : "OTHER",
                    (unsigned long long)grown);
            return 20;
        }
        if (strcmp(mode, "mem-as") == 0) blocks[used++] = p;
        for (size_t off = 0; off < amount; off += (size_t)page)
            ((volatile unsigned char *)p)[off] = (unsigned char)(used + off);
        grown += amount;
        (void)task_sizes(getpid(), &resident, &virtual_size);
    }
    dprintf(STDOUT_FILENO,
            "SYNTHETIC_WORK_COMPLETE growth_bytes=%llu\n",
            (unsigned long long)grown);
    for (size_t i = 0; i < used; i++) munmap(blocks[i], CHUNK);
    return 0;
}

typedef struct {
    char mode[16];
    control_record control;
    int control_received;
    int status;
    int reaped;
    int watchdog_fired;
    int term_sent;
    int kill_sent;
    int no_orphan;
    uint64_t started_ns;
    uint64_t stopped_ns;
    uint64_t termination_requested_ns;
    uint64_t max_resident;
    uint64_t max_virtual;
    uint64_t child_user_us;
    uint64_t child_system_us;
    long child_ru_maxrss;
    char child_output[OUTPUT_CAP];
    size_t output_len;
    int output_truncated;
} run_record;

static void drain_fd(int fd, run_record *r) {
    char buf[512];
    for (;;) {
        ssize_t n = read(fd, buf, sizeof(buf));
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) break;
        size_t room = OUTPUT_CAP - r->output_len - 1;
        size_t take = (size_t)n < room ? (size_t)n : room;
        if (take) {
            memcpy(r->child_output + r->output_len, buf, take);
            r->output_len += take;
            r->child_output[r->output_len] = '\0';
        }
        if (take < (size_t)n) r->output_truncated = 1;
    }
}

static int run_one(const char *self, const char *mode, run_record *r) {
    memset(r, 0, sizeof(*r));
    snprintf(r->mode, sizeof(r->mode), "%s", mode);
    int cp[2], op[2];
    if (pipe(cp) || pipe(op)) return -1;
    fcntl(cp[0], F_SETFL, O_NONBLOCK);
    fcntl(op[0], F_SETFL, O_NONBLOCK);
    pid_t pid = fork();
    if (pid < 0) return -1;
    if (pid == 0) {
        close(cp[0]); close(op[0]);
        dup2(op[1], STDOUT_FILENO);
        close(op[1]);
        child_limits_and_exec(self, mode, cp[1]);
        _exit(93);
    }
    close(cp[1]); close(op[1]);
    r->started_ns = now_ns();
    uint64_t watchdog_ms = strcmp(mode, "cpu-watchdog") == 0 ? 2000 : CHILD_WATCHDOG_MS;
    uint64_t watchdog_at = r->started_ns + watchdog_ms * 1000000ULL;
    uint64_t kill_at = 0;
    int status_ready = 0;
    struct rusage usage;
    memset(&usage, 0, sizeof(usage));

    while (!status_ready) {
        control_record cr;
        ssize_t cn = read(cp[0], &cr, sizeof(cr));
        if (cn == (ssize_t)sizeof(cr)) {
            r->control = cr;
            r->control_received = 1;
            close(cp[0]); cp[0] = -1;
        }
        drain_fd(op[0], r);
        uint64_t rss = 0, vs = 0;
        if (task_sizes(pid, &rss, &vs) == 0) {
            if (rss > r->max_resident) r->max_resident = rss;
            if (vs > r->max_virtual) r->max_virtual = vs;
        }
        pid_t w = wait4(pid, &r->status, WNOHANG, &usage);
        if (w == pid) {
            status_ready = 1;
            r->reaped = 1;
            r->stopped_ns = now_ns();
            break;
        }
        uint64_t now = now_ns();
        if (!r->watchdog_fired && now >= watchdog_at) {
            r->watchdog_fired = 1;
            r->term_sent = kill(pid, SIGTERM) == 0;
            r->termination_requested_ns = now;
            kill_at = now + TERM_GRACE_MS * 1000000ULL;
        } else if (r->watchdog_fired && !r->kill_sent && now >= kill_at) {
            r->kill_sent = kill(pid, SIGKILL) == 0;
        }
        struct pollfd fds[2];
        nfds_t count = 0;
        if (cp[0] >= 0) fds[count++] = (struct pollfd){cp[0], POLLIN, 0};
        fds[count++] = (struct pollfd){op[0], POLLIN, 0};
        (void)poll(fds, count, 5);
    }
    if (cp[0] >= 0) close(cp[0]);
    drain_fd(op[0], r);
    close(op[0]);
    r->child_user_us = (uint64_t)usage.ru_utime.tv_sec * 1000000ULL + (uint64_t)usage.ru_utime.tv_usec;
    r->child_system_us = (uint64_t)usage.ru_stime.tv_sec * 1000000ULL + (uint64_t)usage.ru_stime.tv_usec;
    r->child_ru_maxrss = usage.ru_maxrss;
    if (r->reaped) r->no_orphan = (kill(pid, 0) == -1 && errno == ESRCH);
    return 0;
}

static void print_string(const char *s) {
    putchar('"');
    for (; *s; s++) {
        if (*s == '"' || *s == '\\') { putchar('\\'); putchar(*s); }
        else if (*s == '\n') fputs("\\n", stdout);
        else if ((unsigned char)*s >= 0x20) putchar(*s);
    }
    putchar('"');
}

static void print_run(const run_record *r) {
    uint64_t elapsed_ms = (r->stopped_ns - r->started_ns) / 1000000ULL;
    printf("{\"mode\":"); print_string(r->mode);
    printf(",\"control\":{\"resource_id\":%d,\"setrlimit_errno\":%d,\"soft_limit\":%llu,\"hard_limit\":%llu,\"previous_soft_limit\":%llu,\"previous_hard_limit\":%llu,\"baseline_virtual_bytes\":%llu,\"applied_limit_bytes\":%llu,\"setrlimit_accepted\":%s}",
           r->control.resource, r->control.set_errno,
           (unsigned long long)r->control.soft, (unsigned long long)r->control.hard,
           (unsigned long long)r->control.previous_soft, (unsigned long long)r->control.previous_hard,
           (unsigned long long)r->control.baseline_virtual,
           (unsigned long long)r->control.applied_limit,
           r->control_received && !r->control.set_errno ? "true" : "false");
    printf(",\"wall_start_to_reap_ms\":%llu,\"watchdog_fired\":%s,\"term_sent\":%s,\"kill_escalation_sent\":%s,\"request_to_reap_ms\":",
           (unsigned long long)elapsed_ms, r->watchdog_fired ? "true" : "false",
           r->term_sent ? "true" : "false", r->kill_sent ? "true" : "false");
    if (r->termination_requested_ns && r->stopped_ns >= r->termination_requested_ns)
        printf("%llu", (unsigned long long)((r->stopped_ns-r->termination_requested_ns)/1000000ULL));
    else fputs("null", stdout);
    printf(",\"wait_status\":%d,\"signal\":%d,\"exit_code\":%d,\"reaped\":%s,\"no_orphan_observed\":%s,\"child_user_cpu_us\":%llu,\"child_system_cpu_us\":%llu,\"wait4_ru_maxrss_bytes\":%ld,\"sampled_peak_resident_bytes\":%llu,\"sampled_peak_virtual_bytes\":%llu,\"child_output\":",
           r->status, WIFSIGNALED(r->status) ? WTERMSIG(r->status) : 0,
           WIFEXITED(r->status) ? WEXITSTATUS(r->status) : -1,
           r->reaped ? "true" : "false", r->no_orphan ? "true" : "false",
           (unsigned long long)r->child_user_us, (unsigned long long)r->child_system_us,
           r->child_ru_maxrss, (unsigned long long)r->max_resident,
           (unsigned long long)r->max_virtual);
    print_string(r->child_output);
    printf(",\"child_output_truncated\":%s}", r->output_truncated ? "true" : "false");
}

static void get_sysctl_string(const char *name, char *out, size_t cap) {
    size_t len = cap;
    if (sysctlbyname(name, out, &len, NULL, 0) != 0 || len == 0) snprintf(out, cap, "unavailable");
    else out[cap - 1] = '\0';
}

int main(int argc, char **argv) {
    if (argc == 3 && strcmp(argv[1], "--child") == 0) return child_work(argv[2]);
    if (argc != 1) return 64;
    char product[64] = "unavailable", build[64] = "unavailable";
    get_sysctl_string("kern.osproductversion", product, sizeof(product));
    get_sysctl_string("kern.osversion", build, sizeof(build));
    struct utsname un;
    memset(&un, 0, sizeof(un));
    uname(&un);
    run_record cpu, mem_as, mem_data;
    run_record cpu_watchdog;
    if (run_one(argv[0], "cpu", &cpu) || run_one(argv[0], "cpu-watchdog", &cpu_watchdog) ||
        run_one(argv[0], "mem-as", &mem_as) || run_one(argv[0], "mem-data", &mem_data)) return 70;
    printf("{\"experiment\":\"IP-2A-R13\",\"os_product_version\":"); print_string(product);
    printf(",\"os_build\":"); print_string(build);
    printf(",\"kernel\":"); print_string(un.release);
    printf(",\"architecture\":\"arm64\",\"compiler\":"); print_string(__VERSION__);
    printf(",\"signing_mode\":\"ad-hoc code signature\",\"entitlements\":\"none\",\"controls\":[\"RLIMIT_CPU (soft=1s, hard=2s)\",\"RLIMIT_CPU (soft=30s, hard=31s) for ignored-SIGTERM watchdog case\",\"parent wall watchdog=2000ms for ignored-SIGTERM case; otherwise 6000ms; SIGTERM then SIGKILL after %dms\",\"RLIMIT_AS (SDK maps RLIMIT_RSS to RLIMIT_AS)\",\"RLIMIT_DATA\"],\"child_output_cap_bytes\":%d,\"runs\":[", TERM_GRACE_MS, OUTPUT_CAP);
    print_run(&cpu); putchar(','); print_run(&cpu_watchdog); putchar(','); print_run(&mem_as); putchar(','); print_run(&mem_data);
    printf("]}\n");
    return 0;
}

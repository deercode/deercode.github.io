---
layout: post
lang: en
title:  "Linux Disk Performance Monitoring (Using df, du, iostat, pidstat)"
date:   2023-01-21
excerpt: "Monitoring disk performance on Linux"
categories: [Linux]
tags: [linux, df, du, iostat, pidstat, performance monitoring]
comments: true
---

# Linux Disk Performance Monitoring

While I've used Linux frequently, understanding the performance of Linux itself has always been challenging and confusing. When operating servers on Linux, I often encounter questions like these:

- How much available disk space does the server currently have?
- What is the status of Disk IO on the server?
- Which process is consuming the most Disk IO right now?
- How much memory is the system currently using?
- What is the memory usage of each process?
- What is the current network speed?
- How fast should the network speed be considered acceptable?
- Which process is consuming the most network bandwidth?

To answer these questions, I search on Google and run commands each time. However, many times I don't fully understand the meaning of the numerous metrics in the command's output. I just say to myself, "Okay, roughly like this," and move on. So, in celebration (?) of this Lunar New Year, let's take a look at how to measure overall Linux performance and understand the meaning of each command, focusing on the `disk` aspect in this post.

## Before we begin
```bash
# cat /etc/issue
Ubuntu 18.04.4 LTS \n \l
```
The performance monitoring commands and interpretations below are based on `Ubuntu 18.04`.

## Checking Available Disk Space on the Server
---
There are several commands to check the available disk space on the server. The most common ones are `df` and `du`.

* `df` command: Shows the disk usage of the entire Linux system (mounted).
* `du` command: While `df` shows disk space for the entire system, `du` focuses on disk usage for a specific directory.

If you want to know the overall disk usage of the system, you can use the `df` command. If you want to know the disk space usage for specific directories, use `du`.

### df (disk free)
`df` stands for disk free. Let's use the `df` command to check the system's disk capacity.

```bash
# df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            1.9G     0  1.9G   0% /dev
tmpfs           395M  864K  394M   1% /run
/dev/vda1        79G   20G   56G  27% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
tmpfs           395M     0  395M   0% /run/user/111
tmpfs           395M     0  395M   0% /run/user/0
overlay          79G   20G   56G  27% /var/lib/docker/overlay2/bdbab02421d9c034584c15c70b6b199b8a9d52994a7969093ccfe7def03cc7d8/merged
overlay          79G   20G   56G  27% /var/lib/docker/overlay2/e085f26a8b95d761006b6d8ffe46bfca8843e3a5aee8a1d381912ed47e45a2ac/merged
```

This is the current disk usage of the cloud PC in use. Note that the `-h` option displays sizes in gigabytes, `-m` displays in megabytes, and `-k` displays in kilobytes. The meaning of each field is as follows:

   

### df Field Meanings

| Filesystem | Size | Used | Avail | Use% | Mounted on |
|------------|------|------|-------|------|------------|
| Filesystem name | Total size | Used space | Available space | Usage percentage | Mount point |

Currently, the `/dev/vda1` mounted on root (`/`) is the actual space used by the Linux machine, with 20GB used out of 79GB.

### What about tmpfs, udev, overlay?

- **tmpfs**: Stands for temporary file system. It allows the use of memory as a file system, meaning the data is stored in RAM. Since it's not a physical storage medium, the data disappears when the power is turned off and back on. It is used for tasks that demand fast input/output operations.

- **udev**: Manages the creation and deletion of file nodes in the `/dev` directory for actual physical devices.

- **overlay**: Space used by Docker. 

### du (disk usage)

Let's use `du` to display disk usage for directories.

```bash
# In the home directory, run the following command:
# du -sh
4.4G    .
```

The `du -sh` command displays the total disk usage of the current directory in gigabytes. (Using `du` alone displays the sizes of all files in subdirectories, making it less readable.)

```bash
# In the home directory, run the following command:
# The following command displays the size based on the subdirectories in the current directory.
# du -sh *
1.5G    surfer
63M     deercode
876K    elk_test
191M    fss-data
8.0K    why
224M    Moview
272M    open
61M     openvscode-server-v1.73.0-linux-x64.tar.gz
39M     selenium
4.0K    sym
4.0K    temp
4.0K    test.py
53M     A.py
```

## Checking Disk IO on the Server

There are various methods to measure Disk IO on a server, including `iotop`, `dstat`, and `iostat`. Here, we will introduce `iostat`. To use `iostat`, the `sysstat` package needs to be installed.

### Installing sysstat
```bash
# apt install sysstat
```

### Checking DISK IO with iostat
```bash
# iostat
Linux 4.15.0-76-generic (vultr.guest)   01/21/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.67    0.00    0.19    0.02    0.00   99.13

Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.00         0.00         0.00          1          0
vda               2.97         0.94        22.82   28651719  695587005
```

When you run `iostat`, you'll see the above output. What does this screen mean?


#### iostat Metrics

Let's start by examining the `avg-cpu` metrics.

- **avg-cpu**

| Metric | Description |
|--------|-------------|
| %user | Percentage of CPU time spent in user mode |
| %nice | Percentage of CPU time spent on low-priority processes |
| %system | Percentage of CPU time spent in kernel mode |
| %iowait | Percentage of time CPU is waiting for I/O operations |
| %steal | Percentage of CPU time stolen by virtualization hypervisor |
| %idle | Percentage of time CPU is idle and not performing any tasks |

- **Disk Usage Information**

| Metric | Description |
|--------|-------------|
| tps | Transactions per second, the number of I/O operations per second |
| kB_read/s | Kilobytes read per second from the disk device |
| kB_wrtn/s | Kilobytes written per second to the disk device |
| kB_read | Total kilobytes read from the disk device |
| kB_wrtn | Total kilobytes written to the disk device |

#### Disk IO Monitoring at 1-second Intervals

If you want to monitor devices at 1-second intervals, you can use `watch` in combination with `iostat`.

```bash
# Watch disk IO metrics at 1-second intervals
# watch -n 1 iostat -d
Every 1.0s: iostat -d                                                                                                  vultr.guest: Sat Jan 21 03:32:42 2023

Linux 4.15.0-76-generic (vultr.guest)   01/21/2023      _x86_64_        (2 CPU)

Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.00         0.00         0.00          1          0
vda               2.97         0.94        22.82   28651747  695610233
```

## Checking Disk IO for Each Process

To find out Disk IO for each process, you can use the `pidstat` command. The `pidstat` command is included in the `sysstat` package. Therefore, you need to install `sysstat` first.

### Checking Process-wise Disk IO with pidstat

```bash
# pidstat -d -p ALL
Linux 4.15.0-76-generic (vultr.guest)   01/21/2023      _x86_64_        (2 CPU)

03:40:22 AM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command
03:40:22 AM     0         1      0.67      6.84      0.07      23  systemd
03:40:22 AM     0         2      0.00      0.00      0.00       0  kthreadd
03:40:22 AM     0         4      0.00      0.00      0.00       0  kworker/0:0H
03:40:22 AM     0         6      0.00      0.00      0.00       0  mm_percpu_wq
03:40:22 AM     0         7      0.00      0.00      0.00       0  ksoftirqd/0
03:40:22 AM     0         8      0.00      0.00      0.00       0  rcu_sched
03:40:22 AM     0         9      0.00      0.00      0.00       0  rcu_bh
03:40:22 AM     0        10      0.00      0.00      0.00       0  migration/0

...
```

In the above command, `-d` indicates disk IO, and `-p ALL` specifies to display statistics for all processes.

#### pidstat Metrics

| Metric | Description |
|--------|-------------|
| kB_rd/s | Amount of data (in kilobytes) read by the process per second |
| kB_wd/s | Amount of data (in kilobytes) written by the process per second |
| kB_ccwr/s | Amount of dirty page cache written back by the process (canceled write) |
| iodelay | Disk delay caused by the process, including the time for disk synchronization |

#### Disk IO at the Thread Level

```bash
# pidstat -d -t -p ALL
```

If you use the `-t` option, you can monitor disk IO at the thread level.

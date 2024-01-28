---
layout: post
lang: en
title:  "Linux Memory Performance Monitoring (Using free, ps)"
date:   2023-02-17
excerpt: "Monitoring Linux Memory Performance"
categories: [Linux]
tags: [linux, free, du, process-wise memory usage, performance monitoring]
comments: true
permalink: /linux_memory_monitoring
---

# Linux Memory Performance Monitoring

While I've been using Linux frequently, understanding the performance of Linux itself has always been challenging and confusing. When operating a server on Linux, I often encounter questions like:

- How much available disk space does the server have now?
- How is the Disk IO on the server at the moment?
- Which process is currently consuming the most Disk IO?
- How much memory is the system currently using?
- What is the process-wise memory usage at the moment?
- How is the network speed right now?
- What network speed is considered acceptable?
- Which process is consuming the most network bandwidth?
- ...

To answer these questions, I often search on Google and execute commands on the terminal each time. However, many metrics shown in the commands are not always clear to me, and I often proceed with a vague understanding. So, in commemoration of this Lunar New Year (maybe?), let's explore methods to measure Linux performance comprehensively and understand the meanings of various commands. In this post, we will focus on the `memory` aspect of Linux performance monitoring. For information on disk-related topics, refer to [this post](https://deercode.github.io/linux_disk_monitoring/).

## Before We Begin
---
```bash
# cat /etc/issue
Ubuntu 18.04.4 LTS \n \l
```
The performance monitoring commands and interpretations presented below follow `Ubuntu 18.04`. 

## How Much Memory Is the System Currently Using?
---
How can we find out the total memory usage on the system? This can be determined using the `free` command.

```bash
# free
              total        used        free      shared  buff/cache   available
Mem:        4039172     1516096      395560       46248     2127516     2189400
Swap:             0           0           0

# free -h
              total        used        free      shared  buff/cache   available
Mem:           3.9G        1.4G        386M         45M        2.0G        2.1G
Swap:            0B          0B          0B
```

The default `free` command displays values in KB. If you want a more readable format, you can use the `-h (human-readable)` option.

|Metric|Description|
|----|----------------|
|total|Total memory size|
|used|Used memory (total - free - buff/cache)|
|free|Free memory (total - free - buff/cache)|
|shared|Shared memory that can be used by multiple processes (used by tmpfs, ramfs, etc.)|
|buff/cache|Sum of buffer and cache, indicating used memory|
|available|Estimated size of memory that can be allocated to new processes without swapping|

### Interpretation
The current total memory is 3.9GB, of which 1.4GB is in use. Approximately 2GB is stored in the buffer and cache areas. As there is still plenty of memory space available, the system uses buffer and cache areas extensively for performance. However, if memory usage increases in the future, the buff/cache area will decrease. The current swap area is set to 0. Swap is a separately designated space used when there is insufficient memory space; it utilizes disk space. In other words, the current system does not have a swap set up, but if memory usage increases in the future, consider enabling swap.

Reference: [https://brunch.co.kr/@dreaminz/2](https://brunch.co.kr/@dreaminz/2)

## What Is the Current Process-wise Memory Usage?
---
```bash
ps -aux --sort -rss
```

This command reveals the memory usage of processes. The `--sort -rss` option sorts the processes based on actual memory usage in descending order.

```bash
# ps -aux --sort -rss
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
jenkins    956  0.5 20.7 3627804 837644 ?      Sl    2022 2957:09 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/jenkins/jenkins.war --webroot=/var/
999      27540  0.1  6.9 1586708 282124 ?      Ssl   2022  98:40 mysqld
www-data 19109  0.0  1.9 345772 77016 ?        S    Jan20   1:59 apache2 -DFOREGROUND
www-data  4599  0.0  1.8 345776 76648 ?        S    Jan21   1:24 apache2 -DFOREGROUND
www-data 19111  0.0  1.7 319808 70984 ?        S    Jan20   2:01 apache2 -DFOREGROUND
www-data 10153  0.0  1.7 319808 69968 ?        S    Jan17   2:36 apache2 -DFOREGROUND
www-data 11457  0.0  1.7 319800 69512 ?        S    Jan17   2:46 apache2 -DFOREGROUND
www-data  4597  0.0  1.7 319580 69476 ?        S    Jan21   1:17 apache2 -DFOREGROUND
www-data 11462  0.0  1.6 319804 68088 ?        S    Jan17   3:00 apache2 -DFOREGROUND
www-data 18331  0.0  1.6 319508 67596 ?        S    Jan22   0:09 apache2 -DFOREGROUND
www-data 18327  

 0.0  1.6 319492 67308 ?        S    Jan22   0:09 apache2 -DFOREGROUND
www-data 16708  0.0  1.6 319228 65752 ?        S    Jan22   0:10 apache2 -DFOREGROUND
```

|Metric|Description|
|----|----------------|
|USER|Username of the process|
|PID|Process ID|
|%CPU|CPU usage percentage|
|%MEM|Memory usage percentage|
|VSZ|Virtual memory usage (KiB)|
|RSS|Actual memory usage (KiB)|
|STAT|Current process state (R: Running, S: Sleeping, I: Idle, T: Terminated)|
|TIME|Total CPU time|
|COMMAND|Executable command|

### Interpretation
In my current system, the process that occupies the most memory is Jenkins, utilizing 20.7% of the total memory and using 837644KiB (857MB) of actual memory. Regarding virtual memory, it seems to represent the maximum memory space that the process can utilize. Virtual memory, in this case, can extend up to 3627804KiB (3.71GB).

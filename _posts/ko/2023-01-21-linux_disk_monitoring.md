---
layout: post
lang: ko
title:  "리눅스 디스크 성능 모니터링(df,du,iostat,pidstat 사용법)"
date:   2023-01-21
excerpt: "linux 디스크 성능 모니터링"
categories: [Linux]
tags: [linux, df, du, iostat, pidstat, 성능모니터링]
comments: true
permalink: linux_disk_monitoring
---

# 리눅스 디스크 성능 모니터링

리눅스를 자주 쓰긴했지만, 리눅스 자체의 성능을 파악하는건 항상 어렵고 헷갈렸다. 리눅스에 서버를 운영하다보면 아래와 같은 질문들은 자주 마주한다.

- 지금 서버의 가용 디스크는 얼마나 남아있나?
- 지금 서버의 Disk IO는 어떻지?
- 지금 어떤 프로세스가 Disk IO가 제일 많지?
- 지금 시스템은 메모리를 얼마나 사용중인가?
- 지금 프로세스별 메모리를 사용량은 어떻게 될까?
- 지금 네트워크 속도는 어떻지?
- 네트워크 속도가 어느정도여야 괜찮다고 판단할 수 있지?
- 어떤 프로세스가 네트워크를 제일 많이 잡아먹고 있지?
- ...

이런 질문에 대한 답을 해결하기 위해서 구글을 검색하고 그때그때마다 명령어를 친다. 하지만 명령어에서 나오는 수많은 지표들이 무슨 의미인지, 정확히 알지 못하고 ‘아 대략 이렇군’하고 넘어간 적이 많다. 그래서 이번 설 연휴를 기념(?)하여 리눅스 성능을 전반적으로 측정할 수 있는 방법과 각 명령어가 나타내는 의미에 대해서 한번 알아보자. 이번 포스팅에서는 리눅스 성능 모니터링 중 `디스크`에 대한 부분만 다뤄본다.



## 들어가기에 앞서
```
# cat /etc/issue
Ubuntu 18.04.4 LTS \n \l
```
아래 나오는 성능 모니터링 명령어 및 해석은 `Ubuntu 18.04`를 따릅니다.   
    
      
   
## 서버의 가용 디스크 확인하기
---
서버의 가용 디스크를 확인하기 위한 명령어들이 몇가지가 있다.
대표적으로 `df`, `du` 명령어가 있다. 


* df명령어 : 리눅스 시스템 전체의(마운트된) 디스크 사용량 확인 가능
* du명령어 : df명령어가 시스템 전체의 디스크 공간을 확인하는 명령어라면, du명령어는 특정 디렉토리를 기준으로 디스크 사용량을 확인 가능

즉 시스템 전반적인 디스크 사용량을 알고 싶다면 df 명령어를 쓰면되고, 디렉토리별 용량을 알고 싶다면 du를 쓰면된다. 

   

### df(disk free)
df는 disk free의 약자다.
한번 df 명령어를 통해서 시스템의 용량을 확인해보자.

```
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

현재 사용하고 있는 클라우트 PC의 디스크 사용량이다. 
참고로 `-h` 옵션은 기가 단위, `-m`은 메가 단위, `-k` 는 킬로바이트 단위로 보여준다.
각각의 필드가 의미하는 바는 아래와 같다. 

   

#### df 필드별 의미

|Filesystem|Size|Used|Avail|Use%|Mounted on|
|---|---|---|---|---|---|
|파일시스템명|총사이즈|사용중인 용량|사용 가능한 용량|사용율|마운트 위치|

현재 루트(/)에 마운트된 /dev/vda1이 실제로 리눅스 머신이 사용하고 있는 공간이고, 현재 79GB에 20GB를 사용중이다.

   

#### 그렇다면 tmpfs, udev, overlay 이런애들은 뭘까?
* tmpfs
temp file system의 약자로 임시 파일 시스템을 뜻한다. 이곳은 메모리를 파일 처럼 사용할 수 있게 해주는 파일 시스템이다. 즉 물리적인 저장 매체가 아니고 메모리(RAM)라서 전원이 내려갔다 올라오면 해당 데이터는 사라진다. 빠른 입출력을 요구하는 작업을 위해 사용된다.
* udev
실제 물리장치에 대한 file node를 /dev디렉터리에 생성하고 삭제하는 작업을 위한 공간
* overlay
Docker에서 사용하는 overlay 공간

   
   

### du(disk usage)
디렉터리 별로 사용 공간을 나타내는 `du`도 한번 써보자.
```
# 홈폴더에서 아래 명령어를 써보자.
# du -sh
4.4G    .
```
`du -sh` 명령어는 현재 디렉터리의 총 디스크 사용량을 GB 단위로 보여준다. (du만 치면 현재 폴더의 하위 디렉터리에 있는 모든 파일의 용량을 보여주므로 가독성이 좋지 않음)

```
# 홈폴더에서 아래 명령어를 써보자.
# 아래 명령어는 현재 디렉터리에서 한단계 서브 디렉터리 기준으로 용량을 보여준다. 
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
   
   

## 서버의 Disk IO확인하기
---
서버의 Disk IO를 측정하는 방법은 검색해보니 꽤나 여러가지가 있었다. iotop, dstat, iostat 등등 여기서는 iostat에 대해서 소개하겠다. `iostat`을 사용하기 위해서는 먼저 systat 패키지를 설치해주어야 한다.

### sysstat 설치
```
# apt install sysstat
```

### iostat을 통한 DISK IO 확인
```
# iostat
Linux 4.15.0-76-generic (vultr.guest)   01/21/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.67    0.00    0.19    0.02    0.00   99.13

Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.00         0.00         0.00          1          0
vda               2.97         0.94        22.82   28651719  695587005
```
iostat을 쳐보니 위와 같은 화면이 나온다. 이 화면이 의미하는 바가 뭘까? 

   
   


#### iostat 메트릭
먼저 avg-gpu 부터 살펴보자.

* avg-gpu

|메트릭|설명|
|----|----------------|
|%user|CPU가 사용자 모드에서 사용된 시간의 비율의 출력값|
|%nice|작업 우선순위 정책에 의하여 우선순위가 바뀐 프로세서가 사용한 시간의 비율|
|%system|CPU가 시스템 모드에서 사용된 시간의 비율|
|%iowait|디스크의 입출력을 대기하는데 사용된 시간의 비율|
|%steal|Steal CPU의 사용시간을 비율로 출력|
|%idle|디스크의 입출력을 대기하지 않은 유휴상태의 시간|

* 디스크 사용량 정보

|메트릭|설명|
|----|----------------|
|tps|디스크 장치에서 초당 처리한 입출력의 작업수|
|kB_read/s|디스크 장치에서 초당 읽어들인 데이터 블록 단위|
|kB_wrtn/s|디스크 장치에서 초당 쓴 데이터 블록 단위|
|kB_read|디스크 장치에서 읽어들인 데이터 블록 단위|
|kB_wrtn|디스크 장치에서 쓴 데이터 블록 단위|

   


#### 1초 간격으로 disk IO 모니터링
만약 1초 간격으로 device만 모니터링하고 싶다면 watch와 조합해서 사용할 수도 있다.
```
#watch -n 1 iostat -d
Every 1.0s: iostat -d                                                                                                  vultr.guest: Sat Jan 21 03:32:42 2023

Linux 4.15.0-76-generic (vultr.guest)   01/21/2023      _x86_64_        (2 CPU)

Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.00         0.00         0.00          1          0
vda               2.97         0.94        22.82   28651747  695610233
```

   
   
   


## 프로세스별 Disk IO 확인하기
---
프로세스별 Disk IO를 알 수 있다면 `pidstat` 명령어를 사용할 수 있다.
pidstat 명령어는 앞서 설명한 sysstat 패키지 안에 포함된 명령어다. 
즉 pidstat을 사용하기 위해서는 sysstat을 먼저 설치해야 한다.

   

### pidstat를 통한 프로세스별 Disk IO 확인
```
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

위 명령어에서 -d는 disk IO를 -p ALL은 모든 프로세스를 출력하라는 의미다.

   


#### pidstat 메트릭 확인

|메트릭|설명|
|----|----------------|
|kB_rd/s|해당 Process의 초당 읽은 Data의 양(KB단위)|
|kB_wd/s|해당 Process의 초당 쓴 Data의 양(KB단위)|
|kB_ccwr/s|해당 Process의 Dirty Page Cache로 인해서 Write가 취소된 Data의 양(KB단위)|
|iodelay|해당 Process의 Disk Delay를 나타냄. Delay에는 Disk가 Sync가 되기까지의 시간도 포함하고 있음|

   
   

#### 스레드 단위로 Disk IO 확인
```
# pidstat -d -t -p ALL
```
만약 -t 옵션을 주면 스레드 단위까지 disk IO를 확인할 수 있다. 



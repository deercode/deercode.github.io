---
layout: post
lang: ko
title:  "리눅스 메모리 성능 모니터링(free,ps 사용법)"
date:   2023-02-17
excerpt: "linux 메모리 성능 모니터링"
categories: [Linux]
tags: [linux, free, du, 프로세스별 메모리 사용량, 성능모니터링]
comments: true
---

# 리눅스 메모리 성능 모니터링

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

이런 질문에 대한 답을 해결하기 위해서 구글을 검색하고 그때그때마다 명령어를 친다. 하지만 명령어에서 나오는 수많은 지표들이 무슨 의미인지, 정확히 알지 못하고 ‘아 대략 이렇군’하고 넘어간 적이 많다. 그래서 이번 설 연휴를 기념(?)하여 리눅스 성능을 전반적으로 측정할 수 있는 방법과 각 명령어가 나타내는 의미에 대해서 한번 알아보자. 이번 포스팅에서는 리눅스 성능 모니터링 중 `메모리`에 대한 부분만 다뤄본다. 디스크 편에 대해 정리한 자료는 [이 포스팅](https://deercode.github.io/linux_disk_monitoring/)을 참고해보자.



## 들어가기에 앞서
---
```
# cat /etc/issue
Ubuntu 18.04.4 LTS \n \l
```
아래 나오는 성능 모니터링 명령어 및 해석은 `Ubuntu 18.04`를 따릅니다.   
    
      
   
## 지금 시스템은 메모리를 얼마나 사용중인가?
---
지금 시스템에서 전체 메모리 사용량은 어떻게 알 수 있을까? 이는 `free` 명령어를 통해 확인할 수 있다. 

```
# free
              total        used        free      shared  buff/cache   available
Mem:        4039172     1516096      395560       46248     2127516     2189400
Swap:             0           0           0


# free -h
              total        used        free      shared  buff/cache   available
Mem:           3.9G        1.4G        386M         45M        2.0G        2.1G
Swap:            0B          0B          0B

```

기본 `free` 명령어는 KB 기준으로 보여주는데, 좀 더 읽기 편한 형식으로 보고 싶다면 `-h(human readable)` 옵션을 주면된다.


|메트릭|설명|
|----|----------------|
|total|총 메모리 크키|
|used|total에서 free, buff/cache를 뺀 사용중인 메모리|
|free|total에서 free, buff/cache를 뺀 사용 가능한 메모리|
|shared|여러 프로세스에서 사용할 수 있는 공유 메모리 (tmpsf, ramfs 등으로 사용하는 메모리)|
|buff/cache|버퍼와 캐시를 더한 사용중인 메모리|
|available|swapping 없이 새로운 프로세스에서 할당 가능한 메모리의 예상 크기.|



### 해석
현재 총 메모리는 3.9GB이고, 1.4GB를 사용중이다. 현재 버퍼와 캐시에는 2GB 정도가 저장이 되어있다. 아직 메모리 공간이 여유가 있어서 성능을 위해 버퍼와 캐시영역을 많이 사용하고 있지만, 추후 메모리 사용량이 늘어나게 되면 buff/cache 영역은 줄어들 것이다. 현재 swap 영역은 0으로 설정되어 있는데, swap이란 메모리 공간이 부족할떄 Disk 공간을 활용하기 위해 따로 설정된 공간이다. 즉 현재 시스템에는 따로 swap이 설정되어 있지 않지만 추후 메모리 사용량이 많아지면 swap 영역 사용도 고려해 볼 수 있다.

참고 : [https://brunch.co.kr/@dreaminz/2](https://brunch.co.kr/@dreaminz/2)


## 지금 프로세스별 메모리를 사용량은 어떻게 될까?   
---
```
ps -aux --sort -rss
```
위 명령어를 통해서 프로세스별 메모리 사용량을 알 수 있다. `--sort -rss` 옵션은 실제 메모리 사용량을 기준으로 내림차순으로 정렬해준다. 

```
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
www-data 18327  0.0  1.6 319492 67308 ?        S    Jan22   0:09 apache2 -DFOREGROUND
www-data 16708  0.0  1.6 319228 65752 ?        S    Jan22   0:10 apache2 -DFOREGROUND
```

|메트릭|설명|
|----|----------------|
|USER|프로세스 유저명|
|PID|프로세스 ID|
|%CPU|CPU 사용비율|
|%MEM|MEM 사용비율|
|VSZ|가상 메모리 사용량 (KiB)|
|RSS|실제 메모리 사용량(KiB)|
|STAT|현재 프로세스 상태(R:Running, S:Sleeping, i:idle, T:terminated |
|TIME|총 CPU 시간|
|COMMAND|실행 명령어|



### 해석
즉 현재 나의 시스템에서 가장 메모리를 많이 점유하고 있는 프로세스는 Jenkins이며 총 메모리의 20.7%를 사용중이고, 실제 메모리는 837644KiB(857MB)를 사용한다. 가상메모리에 대한 내용은 찾아보니 해당 프로세스가 최대로 사용할 수 있는 메모리 공간임을 뜻하는 듯 하다. 가상메모리는 즉 최대 3627804KiB(3.71GB)까지 메모리가 확장될 수 있다는 듯..
---
layout: post
lang: ko
title:  "[linux] update-alternatives로 프로그램 버전 관리하기"
date:   2024-01-02
excerpt: "update-alternatives로 프로그램 버전 관리하기"
categories: [Linux]
tags: [linux]
comments: true
permalink: /update-alternative
---

## update-alternatives 명령어
이 명령어를 처음 알게 된 것은 로컬에 여러 버전의 php가 깔렸을때 버전을 쉽게 바꾸는 방법을 찾다가 알게 되었다. 
`update-alternatives` 명령어는 심볼링 링크를 관리해주는 리눅스 프로그램이다. 

그럼 여러 php 버전이 설치된 상황에서 `update-alternatives`를 사용하는 시나리오를 살펴보자.  

## update-alternatives 명령어로 php 버전 관리하기
#### 등록된 심볼릭 링크 확인
```bash
$ sudo update-alternatives --config php
update-alternatives: error: no alternatives for php
```
먼저 php에 대해서 설정된 정보가 있는지 확인해본다. 
현재 없는 것을 알 수 잇다.

#### 심볼릭 링크 등록
```bash
sudo update-alternatives --install /usr/bin/php php /usr/bin/php7.2 1
sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.2 2
```
로컬에 php7.2와 8.2가 설치된 상황에서 기본 명령어 php를 관리하는 상황을 생각해보자.
위 명령어는 /usr/bin/php에 대한 심볼릭 옵션을 추가한다. 
php7.2와 php8.2는 각각 PHP 7.2 및 PHP 8.2의 실행 파일 경로이고, 숫자 1 및 2는 우선 순위를 나타낸다. 

#### 심볼릭 링크 확인 및 선택
```bash
$ sudo update-alternatives --config php
There are 2 choices for the alternative php (providing /usr/bin/php).

  Selection    Path                      Priority   Status
------------------------------------------------------------
* 0            /usr/bin/php7.2            2         auto mode
  1            /usr/bin/php8.2            1         manual mode
  2            /usr/bin/php7.2            2         manual mode
Press <enter> to keep the current choice[*], or type selection number: 1
```
이 명령을 실행하면 시스템에서 사용 가능한 PHP 버전 목록이 표시된다. 각 버전 옆에 있는 번호를 입력하여 기본 PHP 버전을 선택할 수 있다. 
1을 선택하면 `php -v`명령어를 사용했을때 버전이 변경되는 것을 확인할 수 있다.

```bash
$ php -v
PHP 8.2.13 (cli) (built: Dec  9 2023 00:20:40) (NTS)
Copyright (c) The PHP Group
```

위와 같이 여러가지 버전의 프로그램이 설치되었을때 update-alternatives는 쉽고 빠르게 버전을 관리할 수 있게 해준다. 하지만 프로그램 언어 단에서 가상환경을 제공하는 경우 이를 통해 관리하는 것이 더 효과적일 수 있다. 

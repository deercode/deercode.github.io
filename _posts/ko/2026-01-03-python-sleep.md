---
layout: post
lang: ko
title:  "[Python] Python에서 sleep 하는 방법"
date:   2026-01-03
excerpt: "[Python] Python에서 sleep 하는 방법"
categories: [python]
tags: [python]
comments: true
permalink: /python-sleep
---

# [Python] Python에서 sleep 하는 방법

---

Python에서 프로그램 실행을 일시 중지하거나 지연시키고 싶을 때 `time` 모듈의 `sleep` 함수를 사용할 수 있습니다. 이번 포스트에서는 Python에서 sleep을 사용하는 다양한 방법을 알아보겠습니다.

## 기본 사용법

Python에서 sleep을 사용하려면 `time` 모듈을 import하고 `time.sleep()` 함수를 호출하면 됩니다.

```python
import time

print("시작")
time.sleep(2)  # 2초 대기
print("2초 후")
```

`time.sleep()`은 초(second) 단위의 숫자를 인자로 받습니다. 위 예제에서는 `2`로 2초 동안 대기합니다.

## 다양한 시간 단위

Python의 `time.sleep()`은 초 단위만 지원하지만, 다른 시간 단위를 사용하려면 계산을 통해 변환할 수 있습니다:

```python
import time

print("시작")

# 밀리초 단위 (0.5초 = 500밀리초)
time.sleep(0.5)
print("500밀리초 후")

# 초 단위
time.sleep(2)
print("2초 후")

# 분 단위 (60초 = 1분)
time.sleep(60)
print("1분 후")

# 시간 단위 (3600초 = 1시간)
time.sleep(3600)
print("1시간 후")
```

## 시간 단위 변환

| 단위 | 초로 변환 | 예제 |
|------|----------|------|
| 밀리초 | 1ms = 0.001초 | `time.sleep(0.5)` (500ms) |
| 초 | 1s = 1초 | `time.sleep(2)` (2초) |
| 분 | 1m = 60초 | `time.sleep(60)` (1분) |
| 시간 | 1h = 3600초 | `time.sleep(3600)` (1시간) |

## 실제 사용 예제

### 1. 반복 작업 사이에 대기

```python
import time

for i in range(1, 6):
    print(f"작업 {i} 실행 중...")
    time.sleep(1)  # 1초 대기

print("모든 작업 완료")
```

### 2. API 호출 간 지연

```python
import time

def call_api():
    print("API 호출 중...")
    # API 호출 로직

for i in range(3):
    call_api()
    # API 호출 간 2초 대기 (Rate limiting)
    time.sleep(2)
```

### 3. 스레드와 함께 사용

```python
import time
import threading

def worker(worker_id):
    for i in range(3):
        print(f"Worker {worker_id}: 작업 {i}")
        time.sleep(1)

# 여러 스레드 실행
thread1 = threading.Thread(target=worker, args=(1,))
thread2 = threading.Thread(target=worker, args=(2,))

thread1.start()
thread2.start()

# 메인 스레드가 종료되지 않도록 대기
thread1.join()
thread2.join()
print("모든 작업 완료")
```

### 4. 비동기 프로그래밍과 함께 사용 (asyncio)

```python
import asyncio

async def main():
    print("시작")
    await asyncio.sleep(2)  # 비동기 sleep
    print("2초 후")

# Python 3.7+
asyncio.run(main())
```

## 주의사항

- `time.sleep()`은 현재 스레드를 블로킹합니다. 다른 스레드는 계속 실행됩니다.
- 정확한 시간을 보장하지 않습니다. 시스템 스케줄러에 따라 실제 대기 시간이 약간 다를 수 있습니다.
- 매우 짧은 시간(나노초 단위)의 sleep은 정확도가 떨어질 수 있습니다.
- 비동기 프로그래밍에서는 `asyncio.sleep()`을 사용해야 합니다. `time.sleep()`은 이벤트 루프를 블로킹합니다.

## time.sleep() vs asyncio.sleep()

### time.sleep() - 동기 블로킹

```python
import time

print("시작")
time.sleep(2)  # 블로킹
print("2초 후")
```

### asyncio.sleep() - 비동기 논블로킹

```python
import asyncio

async def main():
    print("시작")
    await asyncio.sleep(2)  # 논블로킹
    print("2초 후")

asyncio.run(main())
```

비동기 프로그래밍에서는 `asyncio.sleep()`을 사용하면 다른 코루틴이 실행될 수 있어 효율적입니다.

## 실용적인 팁

### 1. 밀리초 단위로 sleep

```python
import time

# 500밀리초 대기
time.sleep(0.5)
```

### 2. 변수를 사용한 동적 sleep

```python
import time

delay = 2.5  # 초 단위
time.sleep(delay)
```

### 3. 랜덤 지연 (Rate limiting)

```python
import time
import random

# 1초에서 3초 사이의 랜덤한 시간 대기
delay = random.uniform(1, 3)
time.sleep(delay)
```

이 글이 Python에서 sleep을 사용하는 방법을 이해하는 데 도움이 되길 바랍니다!


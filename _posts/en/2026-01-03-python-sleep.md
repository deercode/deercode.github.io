---
layout: post
lang: en
title:  "[Python] How to Sleep in Python"
date:   2026-01-03
excerpt: "[Python] How to Sleep in Python"
categories: [python]
tags: [python]
comments: true
permalink: /python-sleep
---

# [Python] How to Sleep in Python

---

When you want to pause or delay program execution in Python, you can use the `sleep` function from the `time` module. In this post, we will learn various ways to use sleep in Python.

## Basic Usage

To use sleep in Python, import the `time` module and call the `time.sleep()` function.

```python
import time

print("Start")
time.sleep(2)  # Wait 2 seconds
print("After 2 seconds")
```

`time.sleep()` takes a number in seconds as an argument. In the example above, `2` waits for 2 seconds.

## Various Time Units

Python's `time.sleep()` only supports seconds, but you can convert other time units through calculation:

```python
import time

print("Start")

# Milliseconds (0.5 seconds = 500 milliseconds)
time.sleep(0.5)
print("After 500 milliseconds")

# Seconds
time.sleep(2)
print("After 2 seconds")

# Minutes (60 seconds = 1 minute)
time.sleep(60)
print("After 1 minute")

# Hours (3600 seconds = 1 hour)
time.sleep(3600)
print("After 1 hour")
```

## Time Unit Conversion

| Unit | Conversion to Seconds | Example |
|------|----------------------|---------|
| Milliseconds | 1ms = 0.001s | `time.sleep(0.5)` (500ms) |
| Seconds | 1s = 1s | `time.sleep(2)` (2s) |
| Minutes | 1m = 60s | `time.sleep(60)` (1m) |
| Hours | 1h = 3600s | `time.sleep(3600)` (1h) |

## Practical Examples

### 1. Waiting Between Repeated Tasks

```python
import time

for i in range(1, 6):
    print(f"Executing task {i}...")
    time.sleep(1)  # Wait 1 second

print("All tasks completed")
```

### 2. Delaying Between API Calls

```python
import time

def call_api():
    print("Calling API...")
    # API call logic

for i in range(3):
    call_api()
    # Wait 2 seconds between API calls (Rate limiting)
    time.sleep(2)
```

### 3. Using with Threads

```python
import time
import threading

def worker(worker_id):
    for i in range(3):
        print(f"Worker {worker_id}: Task {i}")
        time.sleep(1)

# Run multiple threads
thread1 = threading.Thread(target=worker, args=(1,))
thread2 = threading.Thread(target=worker, args=(2,))

thread1.start()
thread2.start()

# Wait so main thread doesn't exit
thread1.join()
thread2.join()
print("All tasks completed")
```

### 4. Using with Asynchronous Programming (asyncio)

```python
import asyncio

async def main():
    print("Start")
    await asyncio.sleep(2)  # Asynchronous sleep
    print("After 2 seconds")

# Python 3.7+
asyncio.run(main())
```

## Important Notes

- `time.sleep()` blocks the current thread. Other threads continue to run.
- It does not guarantee exact timing. The actual wait time may vary slightly depending on the system scheduler.
- Sleep for very short durations (nanoseconds) may have reduced accuracy.
- In asynchronous programming, you must use `asyncio.sleep()`. `time.sleep()` blocks the event loop.

## time.sleep() vs asyncio.sleep()

### time.sleep() - Synchronous Blocking

```python
import time

print("Start")
time.sleep(2)  # Blocking
print("After 2 seconds")
```

### asyncio.sleep() - Asynchronous Non-blocking

```python
import asyncio

async def main():
    print("Start")
    await asyncio.sleep(2)  # Non-blocking
    print("After 2 seconds")

asyncio.run(main())
```

In asynchronous programming, using `asyncio.sleep()` allows other coroutines to run, making it more efficient.

## Practical Tips

### 1. Sleep in Milliseconds

```python
import time

# Wait 500 milliseconds
time.sleep(0.5)
```

### 2. Dynamic Sleep Using Variables

```python
import time

delay = 2.5  # In seconds
time.sleep(delay)
```

### 3. Random Delay (Rate Limiting)

```python
import time
import random

# Wait for a random time between 1 and 3 seconds
delay = random.uniform(1, 3)
time.sleep(delay)
```

I hope this post helps you understand how to use sleep in Python!


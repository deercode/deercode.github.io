---
layout: post
lang: ja
title:  "[Python] Pythonでsleepする方法"
date:   2026-01-03
excerpt: "[Python] Pythonでsleepする方法"
categories: [python]
tags: [python]
comments: true
permalink: /python-sleep
---

# [Python] Pythonでsleepする方法

---

Pythonでプログラムの実行を一時停止したり遅延させたい場合、`time`モジュールの`sleep`関数を使用できます。この記事では、Pythonでsleepを使用する様々な方法を学びます。

## 基本的な使用方法

Pythonでsleepを使用するには、`time`モジュールをインポートして`time.sleep()`関数を呼び出します。

```python
import time

print("開始")
time.sleep(2)  # 2秒待機
print("2秒後")
```

`time.sleep()`は秒単位の数値を引数として受け取ります。上記の例では、`2`で2秒間待機します。

## 様々な時間単位

Pythonの`time.sleep()`は秒単位のみをサポートしますが、計算を通じて他の時間単位を変換できます：

```python
import time

print("開始")

# ミリ秒単位（0.5秒 = 500ミリ秒）
time.sleep(0.5)
print("500ミリ秒後")

# 秒単位
time.sleep(2)
print("2秒後")

# 分単位（60秒 = 1分）
time.sleep(60)
print("1分後")

# 時間単位（3600秒 = 1時間）
time.sleep(3600)
print("1時間後")
```

## 時間単位の変換

| 単位 | 秒への変換 | 例 |
|------|-----------|-----|
| ミリ秒 | 1ms = 0.001秒 | `time.sleep(0.5)` (500ms) |
| 秒 | 1s = 1秒 | `time.sleep(2)` (2秒) |
| 分 | 1m = 60秒 | `time.sleep(60)` (1分) |
| 時間 | 1h = 3600秒 | `time.sleep(3600)` (1時間) |

## 実用的な例

### 1. 繰り返し作業の間に待機

```python
import time

for i in range(1, 6):
    print(f"作業 {i} 実行中...")
    time.sleep(1)  # 1秒待機

print("すべての作業完了")
```

### 2. API呼び出し間の遅延

```python
import time

def call_api():
    print("API呼び出し中...")
    # API呼び出しロジック

for i in range(3):
    call_api()
    # API呼び出し間に2秒待機（レート制限）
    time.sleep(2)
```

### 3. スレッドと一緒に使用

```python
import time
import threading

def worker(worker_id):
    for i in range(3):
        print(f"Worker {worker_id}: 作業 {i}")
        time.sleep(1)

# 複数のスレッドを実行
thread1 = threading.Thread(target=worker, args=(1,))
thread2 = threading.Thread(target=worker, args=(2,))

thread1.start()
thread2.start()

# メインスレッドが終了しないように待機
thread1.join()
thread2.join()
print("すべての作業完了")
```

### 4. 非同期プログラミングと一緒に使用（asyncio）

```python
import asyncio

async def main():
    print("開始")
    await asyncio.sleep(2)  # 非同期sleep
    print("2秒後")

# Python 3.7+
asyncio.run(main())
```

## 注意事項

- `time.sleep()`は現在のスレッドをブロックします。他のスレッドは引き続き実行されます。
- 正確な時間を保証しません。システムスケジューラによって実際の待機時間が若干異なる場合があります。
- 非常に短い時間（ナノ秒単位）のsleepは精度が低下する可能性があります。
- 非同期プログラミングでは`asyncio.sleep()`を使用する必要があります。`time.sleep()`はイベントループをブロックします。

## time.sleep() vs asyncio.sleep()

### time.sleep() - 同期ブロッキング

```python
import time

print("開始")
time.sleep(2)  # ブロッキング
print("2秒後")
```

### asyncio.sleep() - 非同期ノンブロッキング

```python
import asyncio

async def main():
    print("開始")
    await asyncio.sleep(2)  # ノンブロッキング
    print("2秒後")

asyncio.run(main())
```

非同期プログラミングでは、`asyncio.sleep()`を使用すると他のコルーチンが実行できるため、より効率的です。

## 実用的なヒント

### 1. ミリ秒単位でsleep

```python
import time

# 500ミリ秒待機
time.sleep(0.5)
```

### 2. 変数を使用した動的sleep

```python
import time

delay = 2.5  # 秒単位
time.sleep(delay)
```

### 3. ランダム遅延（レート制限）

```python
import time
import random

# 1秒から3秒の間のランダムな時間待機
delay = random.uniform(1, 3)
time.sleep(delay)
```

この記事がPythonでsleepを使用する方法を理解するのに役立つことを願っています！


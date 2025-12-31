---
layout: post
lang: ja
title:  "[Go] ゴルーチン(Goroutine)完全ガイド - 初心者のための並行プログラミング"
date:   2026-01-10
excerpt: "[Go] ゴルーチン(Goroutine)完全ガイド - 初心者のための並行プログラミング"
categories: [go]
tags: [go, goroutine, concurrency]
comments: true
permalink: /go-goroutine
---

# [Go] ゴルーチン(Goroutine)完全ガイド - 初心者のための並行プログラミング

---

Go言語の最も強力な機能の一つである**ゴルーチン(Goroutine)**について学びましょう。ゴルーチンは、Goで並行性(Concurrency)プログラミングを簡単にするコア機能です。この記事では、ゴルーチンとは何か、どのように使用するか、そして実際にどのように活用できるかを、初心者でも簡単に理解できるように説明します。

## ゴルーチン(Goroutine)とは？

ゴルーチンは、Goランタイムによって管理される軽量スレッド(lightweight thread)です。`go`キーワードを使用して関数を呼び出すと、その関数は新しいゴルーチンで実行されます。

### 簡単な例で理解する

まず、通常の関数呼び出しとゴルーチンの違いを見てみましょう。

```go
package main

import (
    "fmt"
    "time"
)

func sayHello() {
    for i := 0; i < 3; i++ {
        fmt.Println("Hello", i)
        time.Sleep(100 * time.Millisecond)
    }
}

func main() {
    // 通常の関数呼び出し（順次実行）
    fmt.Println("=== 通常の関数呼び出し ===")
    sayHello()
    sayHello()
    
    fmt.Println("\n=== ゴルーチン使用 ===")
    // ゴルーチンで実行（並行実行）
    go sayHello()
    go sayHello()
    
    // メイン関数が終了しないように待機
    time.Sleep(1 * time.Second)
}
```

**実行結果:**
```
=== 通常の関数呼び出し ===
Hello 0
Hello 1
Hello 2
Hello 0
Hello 1
Hello 2

=== ゴルーチン使用 ===
Hello 0
Hello 0
Hello 1
Hello 1
Hello 2
Hello 2
```

通常の関数呼び出しは順次実行されますが、ゴルーチンを使用すると、2つの関数が同時に実行され、出力が混在することを確認できます。

## ゴルーチンの特徴

1. **軽量(Lightweight)**: ゴルーチンは非常に軽量です。数千、数万個のゴルーチンを簡単に作成できます。
2. **非同期実行**: ゴルーチンはメインプログラムから独立して実行されます。
3. **低コスト**: スレッドよりもはるかに少ないメモリとリソースを使用します。

## 基本的な使用方法

### 1. 単一ゴルーチンの実行

```go
package main

import (
    "fmt"
    "time"
)

func printNumbers() {
    for i := 1; i <= 5; i++ {
        fmt.Printf("数字: %d\n", i)
        time.Sleep(200 * time.Millisecond)
    }
}

func main() {
    fmt.Println("メイン関数開始")
    
    // ゴルーチンで関数実行
    go printNumbers()
    
    // メイン関数がすぐに終了しないように待機
    time.Sleep(2 * time.Second)
    
    fmt.Println("メイン関数終了")
}
```

### 2. 複数のゴルーチンの実行

```go
package main

import (
    "fmt"
    "time"
)

func worker(id int) {
    for i := 1; i <= 3; i++ {
        fmt.Printf("Worker %d: 作業 %d\n", id, i)
        time.Sleep(500 * time.Millisecond)
    }
}

func main() {
    // 複数のゴルーチンを同時実行
    for i := 1; i <= 3; i++ {
        go worker(i)
    }
    
    // すべてのゴルーチンが完了するまで待機
    time.Sleep(3 * time.Second)
}
```

## WaitGroupでゴルーチンを待つ

`time.Sleep()`で待機するのは良い方法ではありません。`sync.WaitGroup`を使用すると、ゴルーチンが完了するまで待つことができます。

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done()  // 作業完了シグナル
    
    fmt.Printf("Worker %d 開始\n", id)
    time.Sleep(1 * time.Second)
    fmt.Printf("Worker %d 完了\n", id)
}

func main() {
    var wg sync.WaitGroup
    
    for i := 1; i <= 3; i++ {
        wg.Add(1)  // 待機するゴルーチン数を増加
        go worker(i, &wg)
    }
    
    wg.Wait()  // すべてのゴルーチンが完了するまで待機
    fmt.Println("すべての作業完了！")
}
```

**WaitGroupメソッド:**
- `Add(n)`: 待機するゴルーチン数をn個増加
- `Done()`: ゴルーチン1つが完了したことを通知（Add(-1)と同じ）
- `Wait()`: すべてのゴルーチンが完了するまで待機

## チャネル(Channel)と一緒に使用する

ゴルーチン間でデータをやり取りするには、**チャネル(Channel)**を使用します。

### 基本的なチャネル使用法

```go
package main

import "fmt"

func sendData(ch chan string) {
    ch <- "Hello"  // チャネルにデータ送信
    ch <- "World"
    close(ch)  // チャネルを閉じる
}

func main() {
    ch := make(chan string)  // 文字列チャネル作成
    
    go sendData(ch)
    
    // チャネルからデータ受信
    for msg := range ch {
        fmt.Println(msg)
    }
}
```

### バッファ付きチャネル

```go
package main

import "fmt"

func main() {
    // バッファサイズが2のチャネル
    ch := make(chan string, 2)
    
    ch <- "最初"
    ch <- "2番目"
    // ch <- "3番目"  // バッファが満杯になるとブロックされる
    
    fmt.Println(<-ch)  // "最初"
    fmt.Println(<-ch)  // "2番目"
}
```

## 実用的な例

### 1. Webリクエストの並行処理

```go
package main

import (
    "fmt"
    "net/http"
    "sync"
    "time"
)

func fetchURL(url string, wg *sync.WaitGroup) {
    defer wg.Done()
    
    start := time.Now()
    resp, err := http.Get(url)
    if err != nil {
        fmt.Printf("Error fetching %s: %v\n", url, err)
        return
    }
    defer resp.Body.Close()
    
    duration := time.Since(start)
    fmt.Printf("%s 完了（所要時間: %v）\n", url, duration)
}

func main() {
    urls := []string{
        "https://www.google.com",
        "https://www.github.com",
        "https://www.stackoverflow.com",
    }
    
    var wg sync.WaitGroup
    
    for _, url := range urls {
        wg.Add(1)
        go fetchURL(url, &wg)
    }
    
    wg.Wait()
    fmt.Println("すべてのリクエスト完了！")
}
```

### 2. ジョブキュー処理

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

func worker(id int, jobs <-chan int, results chan<- int, wg *sync.WaitGroup) {
    defer wg.Done()
    
    for job := range jobs {
        fmt.Printf("Worker %d: 作業 %d 開始\n", id, job)
        time.Sleep(500 * time.Millisecond)  // 作業シミュレーション
        results <- job * 2  // 結果送信
        fmt.Printf("Worker %d: 作業 %d 完了\n", id, job)
    }
}

func main() {
    jobs := make(chan int, 5)
    results := make(chan int, 5)
    var wg sync.WaitGroup
    
    // 3つのワーカーゴルーチンを開始
    for w := 1; w <= 3; w++ {
        wg.Add(1)
        go worker(w, jobs, results, &wg)
    }
    
    // ジョブ送信
    for j := 1; j <= 5; j++ {
        jobs <- j
    }
    close(jobs)
    
    // 結果受信
    go func() {
        wg.Wait()
        close(results)
    }()
    
    // 結果出力
    for result := range results {
        fmt.Printf("結果: %d\n", result)
    }
}
```

### 3. タイムアウト処理

```go
package main

import (
    "fmt"
    "time"
)

func doWork() {
    time.Sleep(3 * time.Second)
    fmt.Println("作業完了")
}

func main() {
    done := make(chan bool)
    
    go func() {
        doWork()
        done <- true
    }()
    
    select {
    case <-done:
        fmt.Println("作業が正常に完了しました")
    case <-time.After(2 * time.Second):
        fmt.Println("タイムアウト！作業が長すぎます")
    }
}
```

## 注意事項とベストプラクティス

### 1. ゴルーチンリークの防止

```go
// 悪い例: ゴルーチンが完了する前にメイン関数が終了する
func main() {
    go someFunction()
    // メイン関数がすぐに終了し、ゴルーチンが実行されない可能性がある
}

// 良い例: WaitGroupやチャネルで待機
func main() {
    var wg sync.WaitGroup
    wg.Add(1)
    go func() {
        defer wg.Done()
        someFunction()
    }()
    wg.Wait()
}
```

### 2. チャネルを閉じる

```go
// チャネルを閉じないと、受信者が永遠に待機する可能性がある
ch := make(chan int)
go func() {
    ch <- 1
    ch <- 2
    close(ch)  // 必ず閉じる必要がある
}()
```

### 3. 共有リソースへのアクセス時の注意

```go
package main

import (
    "fmt"
    "sync"
)

var counter int
var mutex sync.Mutex

func increment(wg *sync.WaitGroup) {
    defer wg.Done()
    
    mutex.Lock()  // ロック取得
    counter++
    mutex.Unlock()  // ロック解放
}

func main() {
    var wg sync.WaitGroup
    
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go increment(&wg)
    }
    
    wg.Wait()
    fmt.Printf("最終カウンター値: %d\n", counter)
}
```

## ゴルーチン vs スレッド

| 特徴 | ゴルーチン | スレッド |
|------|-----------|---------|
| 作成コスト | 非常に低い（2KB） | 高い（1-2MB） |
| 作成速度 | 非常に速い | 比較的遅い |
| スケジューリング | Goランタイム | OSカーネル |
| 通信 | チャネル（安全） | 共有メモリ（危険） |

## まとめ

- **ゴルーチン**は`go`キーワードで作成する軽量スレッドです。
- **WaitGroup**を使用してゴルーチンが完了するまで待つことができます。
- **チャネル**を使用してゴルーチン間で安全にデータをやり取りできます。
- 共有リソースにアクセスする際は**ミューテックス**を使用して並行性の問題を防ぐ必要があります。

ゴルーチンはGoのコア機能であり、これをうまく活用すれば、効率的で安全な並行プログラムを書くことができます。最初は難しいかもしれませんが、例に従って実際にコードを書いてみれば、すぐに慣れるでしょう！

この記事がGoのゴルーチンを理解するのに役立つことを願っています！


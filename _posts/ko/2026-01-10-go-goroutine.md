---
layout: post
lang: ko
title:  "[Go] 고루틴(Goroutine) 완벽 가이드 - 초보자를 위한 동시성 프로그래밍"
date:   2026-01-10
excerpt: "[Go] 고루틴(Goroutine) 완벽 가이드 - 초보자를 위한 동시성 프로그래밍"
categories: [go]
tags: [go, goroutine, concurrency]
comments: true
permalink: /go-goroutine
---

# [Go] 고루틴(Goroutine) 완벽 가이드 - 초보자를 위한 동시성 프로그래밍

---

Go 언어의 가장 강력한 기능 중 하나인 **고루틴(Goroutine)**에 대해 알아보겠습니다. 고루틴은 Go에서 동시성(Concurrency) 프로그래밍을 쉽게 만들어주는 핵심 기능입니다. 이번 포스트에서는 고루틴이 무엇인지, 어떻게 사용하는지, 그리고 실제로 어떻게 활용할 수 있는지 초보자도 쉽게 이해할 수 있도록 설명하겠습니다.

## 고루틴(Goroutine)이란?

고루틴은 Go 런타임에 의해 관리되는 경량 스레드(lightweight thread)입니다. `go` 키워드를 사용하여 함수를 호출하면, 그 함수는 새로운 고루틴에서 실행됩니다.

### 간단한 예제로 이해하기

먼저 일반적인 함수 호출과 고루틴의 차이를 살펴보겠습니다.

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
    // 일반 함수 호출 (순차 실행)
    fmt.Println("=== 일반 함수 호출 ===")
    sayHello()
    sayHello()
    
    fmt.Println("\n=== 고루틴 사용 ===")
    // 고루틴으로 실행 (동시 실행)
    go sayHello()
    go sayHello()
    
    // 메인 함수가 종료되지 않도록 대기
    time.Sleep(1 * time.Second)
}
```

**실행 결과:**
```
=== 일반 함수 호출 ===
Hello 0
Hello 1
Hello 2
Hello 0
Hello 1
Hello 2

=== 고루틴 사용 ===
Hello 0
Hello 0
Hello 1
Hello 1
Hello 2
Hello 2
```

일반 함수 호출은 순차적으로 실행되지만, 고루틴을 사용하면 두 함수가 동시에 실행되어 출력이 섞여 나오는 것을 확인할 수 있습니다.

## 고루틴의 특징

1. **경량(Lightweight)**: 고루틴은 매우 가볍습니다. 수천, 수만 개의 고루틴을 쉽게 생성할 수 있습니다.
2. **비동기 실행**: 고루틴은 메인 프로그램과 독립적으로 실행됩니다.
3. **저렴한 비용**: 스레드보다 훨씬 적은 메모리와 리소스를 사용합니다.

## 기본 사용법

### 1. 단일 고루틴 실행

```go
package main

import (
    "fmt"
    "time"
)

func printNumbers() {
    for i := 1; i <= 5; i++ {
        fmt.Printf("숫자: %d\n", i)
        time.Sleep(200 * time.Millisecond)
    }
}

func main() {
    fmt.Println("메인 함수 시작")
    
    // 고루틴으로 함수 실행
    go printNumbers()
    
    // 메인 함수가 바로 종료되지 않도록 대기
    time.Sleep(2 * time.Second)
    
    fmt.Println("메인 함수 종료")
}
```

### 2. 여러 고루틴 실행

```go
package main

import (
    "fmt"
    "time"
)

func worker(id int) {
    for i := 1; i <= 3; i++ {
        fmt.Printf("Worker %d: 작업 %d\n", id, i)
        time.Sleep(500 * time.Millisecond)
    }
}

func main() {
    // 여러 고루틴 동시 실행
    for i := 1; i <= 3; i++ {
        go worker(i)
    }
    
    // 모든 고루틴이 완료될 때까지 대기
    time.Sleep(3 * time.Second)
}
```

## WaitGroup으로 고루틴 기다리기

`time.Sleep()`으로 대기하는 것은 좋은 방법이 아닙니다. `sync.WaitGroup`을 사용하면 고루틴이 완료될 때까지 기다릴 수 있습니다.

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done()  // 작업 완료 시그널
    
    fmt.Printf("Worker %d 시작\n", id)
    time.Sleep(1 * time.Second)
    fmt.Printf("Worker %d 완료\n", id)
}

func main() {
    var wg sync.WaitGroup
    
    for i := 1; i <= 3; i++ {
        wg.Add(1)  // 대기할 고루틴 수 증가
        go worker(i, &wg)
    }
    
    wg.Wait()  // 모든 고루틴이 완료될 때까지 대기
    fmt.Println("모든 작업 완료!")
}
```

**WaitGroup 메서드:**
- `Add(n)`: 대기할 고루틴 수를 n개 증가
- `Done()`: 고루틴 하나가 완료됨을 알림 (Add(-1)과 동일)
- `Wait()`: 모든 고루틴이 완료될 때까지 대기

## 채널(Channel)과 함께 사용하기

고루틴 간 데이터를 주고받을 때는 **채널(Channel)**을 사용합니다.

### 기본 채널 사용법

```go
package main

import "fmt"

func sendData(ch chan string) {
    ch <- "Hello"  // 채널에 데이터 전송
    ch <- "World"
    close(ch)  // 채널 닫기
}

func main() {
    ch := make(chan string)  // 문자열 채널 생성
    
    go sendData(ch)
    
    // 채널에서 데이터 수신
    for msg := range ch {
        fmt.Println(msg)
    }
}
```

### 버퍼가 있는 채널

```go
package main

import "fmt"

func main() {
    // 버퍼 크기가 2인 채널
    ch := make(chan string, 2)
    
    ch <- "첫 번째"
    ch <- "두 번째"
    // ch <- "세 번째"  // 버퍼가 가득 차면 블로킹됨
    
    fmt.Println(<-ch)  // "첫 번째"
    fmt.Println(<-ch)  // "두 번째"
}
```

## 실제 사용 예제

### 1. 웹 요청 동시 처리

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
    fmt.Printf("%s 완료 (소요 시간: %v)\n", url, duration)
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
    fmt.Println("모든 요청 완료!")
}
```

### 2. 작업 큐 처리

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
        fmt.Printf("Worker %d: 작업 %d 시작\n", id, job)
        time.Sleep(500 * time.Millisecond)  // 작업 시뮬레이션
        results <- job * 2  // 결과 전송
        fmt.Printf("Worker %d: 작업 %d 완료\n", id, job)
    }
}

func main() {
    jobs := make(chan int, 5)
    results := make(chan int, 5)
    var wg sync.WaitGroup
    
    // 3개의 워커 고루틴 시작
    for w := 1; w <= 3; w++ {
        wg.Add(1)
        go worker(w, jobs, results, &wg)
    }
    
    // 작업 전송
    for j := 1; j <= 5; j++ {
        jobs <- j
    }
    close(jobs)
    
    // 결과 수신
    go func() {
        wg.Wait()
        close(results)
    }()
    
    // 결과 출력
    for result := range results {
        fmt.Printf("결과: %d\n", result)
    }
}
```

### 3. 타임아웃 처리

```go
package main

import (
    "fmt"
    "time"
)

func doWork() {
    time.Sleep(3 * time.Second)
    fmt.Println("작업 완료")
}

func main() {
    done := make(chan bool)
    
    go func() {
        doWork()
        done <- true
    }()
    
    select {
    case <-done:
        fmt.Println("작업이 정상적으로 완료되었습니다")
    case <-time.After(2 * time.Second):
        fmt.Println("타임아웃! 작업이 너무 오래 걸립니다")
    }
}
```

## 주의사항과 베스트 프랙티스

### 1. 고루틴 누수 방지

```go
// 나쁜 예: 고루틴이 완료되기 전에 메인 함수가 종료됨
func main() {
    go someFunction()
    // 메인 함수가 바로 종료되어 고루틴이 실행되지 않을 수 있음
}

// 좋은 예: WaitGroup이나 채널로 대기
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

### 2. 채널 닫기

```go
// 채널을 닫지 않으면 수신자가 영원히 대기할 수 있음
ch := make(chan int)
go func() {
    ch <- 1
    ch <- 2
    close(ch)  // 반드시 닫아야 함
}()
```

### 3. 공유 자원 접근 시 주의

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
    
    mutex.Lock()  // 락 획득
    counter++
    mutex.Unlock()  // 락 해제
}

func main() {
    var wg sync.WaitGroup
    
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go increment(&wg)
    }
    
    wg.Wait()
    fmt.Printf("최종 카운터 값: %d\n", counter)
}
```

## 고루틴 vs 스레드

| 특징 | 고루틴 | 스레드 |
|------|--------|--------|
| 생성 비용 | 매우 낮음 (2KB) | 높음 (1-2MB) |
| 생성 속도 | 매우 빠름 | 상대적으로 느림 |
| 스케줄링 | Go 런타임 | OS 커널 |
| 통신 | 채널 (안전) | 공유 메모리 (위험) |

## 요약

- **고루틴**은 `go` 키워드로 생성하는 경량 스레드입니다.
- **WaitGroup**을 사용하여 고루틴이 완료될 때까지 기다릴 수 있습니다.
- **채널**을 사용하여 고루틴 간 안전하게 데이터를 주고받을 수 있습니다.
- 공유 자원 접근 시 **뮤텍스**를 사용하여 동시성 문제를 방지해야 합니다.

고루틴은 Go의 핵심 기능이며, 이를 잘 활용하면 효율적이고 안전한 동시성 프로그램을 작성할 수 있습니다. 처음에는 어려울 수 있지만, 예제를 따라해보고 직접 코드를 작성해보면 금방 익숙해질 것입니다!

이 글이 Go의 고루틴을 이해하는 데 도움이 되길 바랍니다!


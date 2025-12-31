---
layout: post
lang: en
title:  "[Go] Complete Guide to Goroutines - Concurrency Programming for Beginners"
date:   2026-01-10
excerpt: "[Go] Complete Guide to Goroutines - Concurrency Programming for Beginners"
categories: [go]
tags: [go, goroutine, concurrency]
comments: true
permalink: /go-goroutine
---

# [Go] Complete Guide to Goroutines - Concurrency Programming for Beginners

---

Let's explore **Goroutines**, one of the most powerful features of the Go language. Goroutines are a core feature that makes concurrent programming easy in Go. In this post, we'll explain what goroutines are, how to use them, and how to apply them in practice in a way that beginners can easily understand.

## What is a Goroutine?

A goroutine is a lightweight thread managed by the Go runtime. When you call a function with the `go` keyword, that function runs in a new goroutine.

### Understanding with a Simple Example

Let's first look at the difference between a regular function call and a goroutine.

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
    // Regular function call (sequential execution)
    fmt.Println("=== Regular Function Call ===")
    sayHello()
    sayHello()
    
    fmt.Println("\n=== Using Goroutines ===")
    // Execution with goroutines (concurrent execution)
    go sayHello()
    go sayHello()
    
    // Wait so main function doesn't exit
    time.Sleep(1 * time.Second)
}
```

**Output:**
```
=== Regular Function Call ===
Hello 0
Hello 1
Hello 2
Hello 0
Hello 1
Hello 2

=== Using Goroutines ===
Hello 0
Hello 0
Hello 1
Hello 1
Hello 2
Hello 2
```

Regular function calls execute sequentially, but when using goroutines, you can see that both functions run concurrently, with their outputs interleaved.

## Characteristics of Goroutines

1. **Lightweight**: Goroutines are very lightweight. You can easily create thousands or tens of thousands of them.
2. **Asynchronous Execution**: Goroutines run independently of the main program.
3. **Low Cost**: They use much less memory and resources than threads.

## Basic Usage

### 1. Running a Single Goroutine

```go
package main

import (
    "fmt"
    "time"
)

func printNumbers() {
    for i := 1; i <= 5; i++ {
        fmt.Printf("Number: %d\n", i)
        time.Sleep(200 * time.Millisecond)
    }
}

func main() {
    fmt.Println("Main function started")
    
    // Execute function as goroutine
    go printNumbers()
    
    // Wait so main function doesn't exit immediately
    time.Sleep(2 * time.Second)
    
    fmt.Println("Main function ended")
}
```

### 2. Running Multiple Goroutines

```go
package main

import (
    "fmt"
    "time"
)

func worker(id int) {
    for i := 1; i <= 3; i++ {
        fmt.Printf("Worker %d: Task %d\n", id, i)
        time.Sleep(500 * time.Millisecond)
    }
}

func main() {
    // Run multiple goroutines concurrently
    for i := 1; i <= 3; i++ {
        go worker(i)
    }
    
    // Wait for all goroutines to complete
    time.Sleep(3 * time.Second)
}
```

## Waiting for Goroutines with WaitGroup

Using `time.Sleep()` to wait is not a good approach. Using `sync.WaitGroup`, you can wait for goroutines to complete.

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done()  // Signal completion
    
    fmt.Printf("Worker %d started\n", id)
    time.Sleep(1 * time.Second)
    fmt.Printf("Worker %d completed\n", id)
}

func main() {
    var wg sync.WaitGroup
    
    for i := 1; i <= 3; i++ {
        wg.Add(1)  // Increment number of goroutines to wait for
        go worker(i, &wg)
    }
    
    wg.Wait()  // Wait for all goroutines to complete
    fmt.Println("All tasks completed!")
}
```

**WaitGroup Methods:**
- `Add(n)`: Increase the number of goroutines to wait for by n
- `Done()`: Signal that one goroutine has completed (same as Add(-1))
- `Wait()`: Wait until all goroutines complete

## Using with Channels

To exchange data between goroutines, use **Channels**.

### Basic Channel Usage

```go
package main

import "fmt"

func sendData(ch chan string) {
    ch <- "Hello"  // Send data to channel
    ch <- "World"
    close(ch)  // Close channel
}

func main() {
    ch := make(chan string)  // Create string channel
    
    go sendData(ch)
    
    // Receive data from channel
    for msg := range ch {
        fmt.Println(msg)
    }
}
```

### Buffered Channels

```go
package main

import "fmt"

func main() {
    // Channel with buffer size of 2
    ch := make(chan string, 2)
    
    ch <- "First"
    ch <- "Second"
    // ch <- "Third"  // Blocks when buffer is full
    
    fmt.Println(<-ch)  // "First"
    fmt.Println(<-ch)  // "Second"
}
```

## Practical Examples

### 1. Concurrent Web Request Processing

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
    fmt.Printf("%s completed (Duration: %v)\n", url, duration)
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
    fmt.Println("All requests completed!")
}
```

### 2. Job Queue Processing

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
        fmt.Printf("Worker %d: Task %d started\n", id, job)
        time.Sleep(500 * time.Millisecond)  // Simulate work
        results <- job * 2  // Send result
        fmt.Printf("Worker %d: Task %d completed\n", id, job)
    }
}

func main() {
    jobs := make(chan int, 5)
    results := make(chan int, 5)
    var wg sync.WaitGroup
    
    // Start 3 worker goroutines
    for w := 1; w <= 3; w++ {
        wg.Add(1)
        go worker(w, jobs, results, &wg)
    }
    
    // Send jobs
    for j := 1; j <= 5; j++ {
        jobs <- j
    }
    close(jobs)
    
    // Receive results
    go func() {
        wg.Wait()
        close(results)
    }()
    
    // Print results
    for result := range results {
        fmt.Printf("Result: %d\n", result)
    }
}
```

### 3. Timeout Handling

```go
package main

import (
    "fmt"
    "time"
)

func doWork() {
    time.Sleep(3 * time.Second)
    fmt.Println("Work completed")
}

func main() {
    done := make(chan bool)
    
    go func() {
        doWork()
        done <- true
    }()
    
    select {
    case <-done:
        fmt.Println("Work completed successfully")
    case <-time.After(2 * time.Second):
        fmt.Println("Timeout! Work is taking too long")
    }
}
```

## Important Notes and Best Practices

### 1. Preventing Goroutine Leaks

```go
// Bad: Main function exits before goroutine completes
func main() {
    go someFunction()
    // Main function exits immediately, goroutine may not execute
}

// Good: Wait using WaitGroup or channel
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

### 2. Closing Channels

```go
// If channel is not closed, receiver may wait forever
ch := make(chan int)
go func() {
    ch <- 1
    ch <- 2
    close(ch)  // Must close
}()
```

### 3. Careful Access to Shared Resources

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
    
    mutex.Lock()  // Acquire lock
    counter++
    mutex.Unlock()  // Release lock
}

func main() {
    var wg sync.WaitGroup
    
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go increment(&wg)
    }
    
    wg.Wait()
    fmt.Printf("Final counter value: %d\n", counter)
}
```

## Goroutines vs Threads

| Feature | Goroutine | Thread |
|---------|-----------|--------|
| Creation Cost | Very Low (2KB) | High (1-2MB) |
| Creation Speed | Very Fast | Relatively Slow |
| Scheduling | Go Runtime | OS Kernel |
| Communication | Channels (Safe) | Shared Memory (Risky) |

## Summary

- **Goroutines** are lightweight threads created with the `go` keyword.
- Use **WaitGroup** to wait for goroutines to complete.
- Use **Channels** to safely exchange data between goroutines.
- Use **Mutex** when accessing shared resources to prevent concurrency issues.

Goroutines are a core feature of Go, and by using them well, you can write efficient and safe concurrent programs. It may be difficult at first, but if you follow the examples and write code yourself, you'll get used to it quickly!

I hope this post helps you understand Go's goroutines!


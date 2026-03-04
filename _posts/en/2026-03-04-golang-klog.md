---
layout: post
lang: en
title:  "Using klog in Golang"
date:   2026-03-04
excerpt: "Learn how to implement structured logging using Kubernetes' klog library in Golang."
categories: [Backend]
tags: [Golang, klog, logging, kubernetes]
comments: true
permalink: /golang-klog
---

## Introduction

When implementing logging in Golang, there are several libraries you can use. From the `log` package to `logrus`, `zap`, `zerolog`, and more, there are many options available. `klog`, widely used in the Kubernetes ecosystem, is a powerful tool that provides structured logging and various log levels.

In this article, we'll explore how to use klog in Golang with practical examples.

## What is klog?

klog is a structured logging library used in the Kubernetes project. Based on Google's glog library, it has the following characteristics:

- **Structured Logging**: Systematic logging support by log level
- **Performance Optimization**: Minimizes impact on application performance through asynchronous logging
- **Flexible Configuration**: Runtime log level adjustment through flags
- **File Output**: Easy log management by saving logs to files

## Installation

To use klog, you first need to install the package:

```bash
go get k8s.io/klog/v2
```

Or if using Go modules:

```bash
go mod tidy
```

## Basic Usage

### Simple Example

Let's start with the most basic usage:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    // Flag parsing (klog uses flags internally)
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    klog.Info("Application started")
    klog.Infof("User ID: %d", 12345)
    klog.Warning("Warning message")
    klog.Error("An error occurred")
}
```

### Log Levels

klog provides the following log levels:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    // Info level: General informational logs
    klog.Info("Info message")
    klog.Infof("Formatted info: %s", "value")

    // Warning level: Warning messages
    klog.Warning("Warning message")
    klog.Warningf("Formatted warning: %d", 42)

    // Error level: Error messages
    klog.Error("Error message")
    klog.Errorf("Formatted error: %v", err)

    // Fatal level: Fatal error (program termination)
    klog.Fatal("Fatal error - program termination")
    klog.Fatalf("Formatted fatal error: %s", "message")

    // V level: Verbose logs
    klog.V(1).Info("Verbose log level 1")
    klog.V(2).Info("Verbose log level 2")
    klog.V(3).Infof("Verbose log level 3: %s", "value")
}
```

## Log Level Configuration

klog allows you to adjust log levels through command-line flags:

```bash
# Basic execution
go run main.go

# Set log level
go run main.go -v=2

# Set log level for specific module
go run main.go -v=2 -vmodule=user=3

# Output logs to file
go run main.go -logtostderr=false -log_dir=./logs
```

### Setting Log Level in Code

You can also set log levels within your program:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // Set log level in code
    flag.Set("v", "2")
    flag.Set("logtostderr", "true")
    
    flag.Parse()
    defer klog.Flush()

    klog.V(1).Info("This message will only be printed at v=1 or higher")
    klog.V(2).Info("This message will only be printed at v=2 or higher")
}
```

## Structured Logging

klog provides functions like `InfoS` and `ErrorS` for structured logging:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    // Structured logging with key-value pairs
    klog.InfoS("User login successful",
        "userID", 12345,
        "username", "hyungsun",
        "ip", "192.168.1.1",
    )

    klog.ErrorS(nil, "Database connection failed",
        "host", "localhost",
        "port", 5432,
        "database", "mydb",
    )

    // Logging with error object
    err := someFunction()
    if err != nil {
        klog.ErrorS(err, "Function execution failed",
            "function", "someFunction",
            "retryCount", 3,
        )
    }
}
```

## Practical Examples

### Using klog in HTTP Server

Let's look at an example of using klog in a real web server:

```go
package main

import (
    "encoding/json"
    "flag"
    "net/http"
    "time"

    "k8s.io/klog/v2"
)

type User struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}

func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    http.HandleFunc("/users", handleUsers)
    http.HandleFunc("/health", handleHealth)

    klog.InfoS("HTTP server started",
        "port", 8080,
        "env", "production",
    )

    if err := http.ListenAndServe(":8080", nil); err != nil {
        klog.Fatalf("Server start failed: %v", err)
    }
}

func handleUsers(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    klog.V(2).InfoS("User list request",
        "method", r.Method,
        "path", r.URL.Path,
        "remoteAddr", r.RemoteAddr,
    )

    // Business logic
    users := []User{
        {ID: 1, Name: "Alice"},
        {ID: 2, Name: "Bob"},
    }

    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(users); err != nil {
        klog.ErrorS(err, "JSON encoding failed",
            "path", r.URL.Path,
        )
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
        return
    }

    duration := time.Since(start)
    klog.V(1).InfoS("User list response completed",
        "path", r.URL.Path,
        "status", http.StatusOK,
        "duration", duration,
    )
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    klog.V(3).Info("Health check request")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}
```

### Database Operation Logging

Example of logging database operations:

```go
package main

import (
    "database/sql"
    "flag"
    "time"

    _ "github.com/lib/pq"
    "k8s.io/klog/v2"
)

type DBService struct {
    db *sql.DB
}

func (s *DBService) GetUser(id int) (*User, error) {
    start := time.Now()
    
    klog.V(2).InfoS("User query started",
        "userID", id,
    )

    var user User
    query := "SELECT id, name FROM users WHERE id = $1"
    err := s.db.QueryRow(query, id).Scan(&user.ID, &user.Name)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "User query failed",
            "userID", id,
            "query", query,
            "duration", duration,
        )
        return nil, err
    }

    klog.V(1).InfoS("User query successful",
        "userID", id,
        "duration", duration,
    )

    return &user, nil
}

func (s *DBService) CreateUser(user *User) error {
    start := time.Now()
    
    klog.InfoS("User creation started",
        "username", user.Name,
    )

    query := "INSERT INTO users (name) VALUES ($1) RETURNING id"
    err := s.db.QueryRow(query, user.Name).Scan(&user.ID)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "User creation failed",
            "username", user.Name,
            "query", query,
            "duration", duration,
        )
        return err
    }

    klog.InfoS("User creation successful",
        "userID", user.ID,
        "username", user.Name,
        "duration", duration,
    )

    return nil
}
```

## Log File Management

klog provides functionality to save logs to files and rotate them:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // Save logs to file
    flag.Set("logtostderr", "false")
    flag.Set("log_dir", "./logs")
    flag.Set("alsologtostderr", "true") // Output to both file and stderr
    
    flag.Parse()
    defer klog.Flush()

    klog.Info("This log will be recorded in both file and stderr")
}
```

You can also configure it via flags when running:

```bash
go run main.go -logtostderr=false -log_dir=./logs -alsologtostderr=true
```

## Important Notes

### 1. Calling klog.Flush()

You must call `klog.Flush()` before program termination. Since klog processes logs asynchronously, some logs may be lost if Flush is not called:

```go
func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush() // Must call!

    // ... application logic ...
}
```

### 2. Flag Parsing Order

Since klog uses the `flag` package internally, it may conflict with other flags. You must call `klog.InitFlags(nil)` first, then `flag.Parse()`:

```go
func main() {
    // Correct order
    klog.InitFlags(nil)
    flag.Parse()
    
    // Incorrect order (flag conflict possible)
    // flag.Parse()
    // klog.InitFlags(nil)
}
```

### 3. Caution When Using V Levels

Since V levels are for conditional logging, you should avoid expensive operations:

```go
// Good example: String formatting only executes after V level check
if klog.V(2).Enabled() {
    klog.V(2).Infof("Complex formatting: %s", expensiveStringFormat())
}

// Bad example: expensiveStringFormat() always executes
klog.V(2).Infof("Complex formatting: %s", expensiveStringFormat())
```

## Comparison with Other Logging Libraries

### klog vs logrus

| Feature | klog | logrus |
|---------|------|--------|
| Structured Logging | ✅ | ✅ |
| Performance | High | Medium |
| Kubernetes Integration | ✅ | ❌ |
| Configuration Complexity | Low | Medium |

### klog vs zap

| Feature | klog | zap |
|---------|------|-----|
| Performance | High | Very High |
| Structured Logging | ✅ | ✅ |
| Kubernetes Integration | ✅ | ❌ |
| Learning Curve | Low | Medium |

## Conclusion

klog is a powerful logging library proven in the Kubernetes ecosystem. It's particularly useful for Kubernetes-related projects or when structured logging is needed.

### Key Advantages

- **Simple API**: Intuitive and easy-to-use interface
- **Performance**: Minimizes impact on application performance through asynchronous logging
- **Flexibility**: Runtime log level adjustment capability
- **Kubernetes Integration**: Natural integration with Kubernetes projects

### Recommended Use Cases

- Kubernetes-related projects
- Applications requiring structured logging
- Cases where log levels need to be adjusted at runtime
- Production environments where performance is critical

Build a better logging system using klog! 🚀

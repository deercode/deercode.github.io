---
layout: post
lang: ko
title:  "Golang에서 klog 사용하기"
date:   2026-03-04
excerpt: "Golang에서 Kubernetes의 klog 라이브러리를 사용하여 구조화된 로깅을 구현하는 방법을 알아봅니다."
categories: [Backend]
tags: [Golang, klog, logging, kubernetes]
comments: true
permalink: /golang-klog
---

## 들어가며

Golang에서 로깅을 구현할 때 여러 라이브러리를 사용할 수 있습니다. `log` 패키지부터 `logrus`, `zap`, `zerolog` 등 다양한 선택지가 있는데, Kubernetes 생태계에서 널리 사용되는 `klog`는 구조화된 로깅과 다양한 로그 레벨을 제공하는 강력한 도구입니다.

이 글에서는 Golang에서 klog를 사용하는 방법을 실무 예제와 함께 알아보겠습니다.

## klog란?

klog는 Kubernetes 프로젝트에서 사용하는 구조화된 로깅 라이브러리입니다. Google의 glog 라이브러리를 기반으로 하며, 다음과 같은 특징을 가지고 있습니다:

- **구조화된 로깅**: 로그 레벨별로 체계적인 로깅 지원
- **성능 최적화**: 비동기 로깅으로 애플리케이션 성능에 미치는 영향 최소화
- **유연한 설정**: 플래그를 통한 런타임 로그 레벨 조정
- **파일 출력**: 로그를 파일로 저장하여 관리 용이

## 설치하기

klog를 사용하기 위해서는 먼저 패키지를 설치해야 합니다:

```bash
go get k8s.io/klog/v2
```

또는 Go modules를 사용하는 경우:

```bash
go mod tidy
```

## 기본 사용법

### 간단한 예제

가장 기본적인 사용법부터 살펴보겠습니다:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    // 플래그 파싱 (klog가 내부적으로 플래그를 사용)
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    klog.Info("애플리케이션이 시작되었습니다")
    klog.Infof("사용자 ID: %d", 12345)
    klog.Warning("경고 메시지입니다")
    klog.Error("에러가 발생했습니다")
}
```

### 로그 레벨

klog는 다음과 같은 로그 레벨을 제공합니다:

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

    // Info 레벨: 일반적인 정보성 로그
    klog.Info("정보 메시지")
    klog.Infof("포맷된 정보: %s", "값")

    // Warning 레벨: 경고 메시지
    klog.Warning("경고 메시지")
    klog.Warningf("포맷된 경고: %d", 42)

    // Error 레벨: 에러 메시지
    klog.Error("에러 메시지")
    klog.Errorf("포맷된 에러: %v", err)

    // Fatal 레벨: 치명적 에러 (프로그램 종료)
    klog.Fatal("치명적 에러 - 프로그램 종료")
    klog.Fatalf("포맷된 치명적 에러: %s", "메시지")

    // V 레벨: 상세 로그 (Verbose)
    klog.V(1).Info("상세 로그 레벨 1")
    klog.V(2).Info("상세 로그 레벨 2")
    klog.V(3).Infof("상세 로그 레벨 3: %s", "값")
}
```

## 로그 레벨 설정

klog는 명령줄 플래그를 통해 로그 레벨을 조정할 수 있습니다:

```bash
# 기본 실행
go run main.go

# 로그 레벨 설정
go run main.go -v=2

# 특정 모듈의 로그 레벨 설정
go run main.go -v=2 -vmodule=user=3

# 로그를 파일로 출력
go run main.go -logtostderr=false -log_dir=./logs
```

### 코드에서 로그 레벨 설정

프로그램 내에서도 로그 레벨을 설정할 수 있습니다:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // 로그 레벨을 코드에서 설정
    flag.Set("v", "2")
    flag.Set("logtostderr", "true")
    
    flag.Parse()
    defer klog.Flush()

    klog.V(1).Info("이 메시지는 v=1 이상에서만 출력됩니다")
    klog.V(2).Info("이 메시지는 v=2 이상에서만 출력됩니다")
}
```

## 구조화된 로깅

klog는 구조화된 로깅을 위한 `InfoS`, `ErrorS` 등의 함수를 제공합니다:

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

    // 키-값 쌍으로 구조화된 로깅
    klog.InfoS("사용자 로그인 성공",
        "userID", 12345,
        "username", "hyungsun",
        "ip", "192.168.1.1",
    )

    klog.ErrorS(nil, "데이터베이스 연결 실패",
        "host", "localhost",
        "port", 5432,
        "database", "mydb",
    )

    // 에러 객체와 함께 로깅
    err := someFunction()
    if err != nil {
        klog.ErrorS(err, "함수 실행 실패",
            "function", "someFunction",
            "retryCount", 3,
        )
    }
}
```

## 실무 예제

### HTTP 서버에서 klog 사용하기

실제 웹 서버에서 klog를 사용하는 예제를 살펴보겠습니다:

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

    klog.InfoS("HTTP 서버 시작",
        "port", 8080,
        "env", "production",
    )

    if err := http.ListenAndServe(":8080", nil); err != nil {
        klog.Fatalf("서버 시작 실패: %v", err)
    }
}

func handleUsers(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    klog.V(2).InfoS("사용자 목록 요청",
        "method", r.Method,
        "path", r.URL.Path,
        "remoteAddr", r.RemoteAddr,
    )

    // 비즈니스 로직
    users := []User{
        {ID: 1, Name: "Alice"},
        {ID: 2, Name: "Bob"},
    }

    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(users); err != nil {
        klog.ErrorS(err, "JSON 인코딩 실패",
            "path", r.URL.Path,
        )
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
        return
    }

    duration := time.Since(start)
    klog.V(1).InfoS("사용자 목록 응답 완료",
        "path", r.URL.Path,
        "status", http.StatusOK,
        "duration", duration,
    )
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    klog.V(3).Info("헬스 체크 요청")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}
```

### 데이터베이스 작업 로깅

데이터베이스 작업을 로깅하는 예제:

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
    
    klog.V(2).InfoS("사용자 조회 시작",
        "userID", id,
    )

    var user User
    query := "SELECT id, name FROM users WHERE id = $1"
    err := s.db.QueryRow(query, id).Scan(&user.ID, &user.Name)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "사용자 조회 실패",
            "userID", id,
            "query", query,
            "duration", duration,
        )
        return nil, err
    }

    klog.V(1).InfoS("사용자 조회 성공",
        "userID", id,
        "duration", duration,
    )

    return &user, nil
}

func (s *DBService) CreateUser(user *User) error {
    start := time.Now()
    
    klog.InfoS("사용자 생성 시작",
        "username", user.Name,
    )

    query := "INSERT INTO users (name) VALUES ($1) RETURNING id"
    err := s.db.QueryRow(query, user.Name).Scan(&user.ID)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "사용자 생성 실패",
            "username", user.Name,
            "query", query,
            "duration", duration,
        )
        return err
    }

    klog.InfoS("사용자 생성 성공",
        "userID", user.ID,
        "username", user.Name,
        "duration", duration,
    )

    return nil
}
```

## 로그 파일 관리

klog는 로그를 파일로 저장하고 로테이션하는 기능을 제공합니다:

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // 로그를 파일로 저장
    flag.Set("logtostderr", "false")
    flag.Set("log_dir", "./logs")
    flag.Set("alsologtostderr", "true") // 파일과 stderr 모두에 출력
    
    flag.Parse()
    defer klog.Flush()

    klog.Info("이 로그는 파일과 stderr 모두에 기록됩니다")
}
```

실행 시 플래그로도 설정 가능합니다:

```bash
go run main.go -logtostderr=false -log_dir=./logs -alsologtostderr=true
```

## 주의사항

### 1. klog.Flush() 호출

프로그램 종료 전에 반드시 `klog.Flush()`를 호출해야 합니다. klog는 비동기로 로그를 처리하기 때문에, Flush를 호출하지 않으면 일부 로그가 손실될 수 있습니다:

```go
func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush() // 반드시 호출!

    // ... 애플리케이션 로직 ...
}
```

### 2. 플래그 파싱 순서

klog는 내부적으로 `flag` 패키지를 사용하므로, 다른 플래그와 충돌할 수 있습니다. `klog.InitFlags(nil)`을 먼저 호출하고, 그 다음에 `flag.Parse()`를 호출해야 합니다:

```go
func main() {
    // 올바른 순서
    klog.InitFlags(nil)
    flag.Parse()
    
    // 잘못된 순서 (플래그 충돌 가능)
    // flag.Parse()
    // klog.InitFlags(nil)
}
```

### 3. V 레벨 사용 시 주의

V 레벨은 조건부 로깅을 위한 것이므로, 비용이 많이 드는 연산을 피해야 합니다:

```go
// 좋은 예: 문자열 포맷팅은 V 레벨 체크 후에만 실행
if klog.V(2).Enabled() {
    klog.V(2).Infof("복잡한 포맷팅: %s", expensiveStringFormat())
}

// 나쁜 예: 항상 expensiveStringFormat()이 실행됨
klog.V(2).Infof("복잡한 포맷팅: %s", expensiveStringFormat())
```

## 다른 로깅 라이브러리와 비교

### klog vs logrus

| 특징 | klog | logrus |
|------|------|--------|
| 구조화된 로깅 | ✅ | ✅ |
| 성능 | 높음 | 중간 |
| Kubernetes 통합 | ✅ | ❌ |
| 설정 복잡도 | 낮음 | 중간 |

### klog vs zap

| 특징 | klog | zap |
|------|------|-----|
| 성능 | 높음 | 매우 높음 |
| 구조화된 로깅 | ✅ | ✅ |
| Kubernetes 통합 | ✅ | ❌ |
| 학습 곡선 | 낮음 | 중간 |

## 결론

klog는 Kubernetes 생태계에서 검증된 강력한 로깅 라이브러리입니다. 특히 Kubernetes 관련 프로젝트나 구조화된 로깅이 필요한 경우에 매우 유용합니다.

### 주요 장점

- **간단한 API**: 직관적이고 사용하기 쉬운 인터페이스
- **성능**: 비동기 로깅으로 애플리케이션 성능에 미치는 영향 최소화
- **유연성**: 런타임에 로그 레벨 조정 가능
- **Kubernetes 통합**: Kubernetes 프로젝트와의 자연스러운 통합

### 사용 권장 사례

- Kubernetes 관련 프로젝트
- 구조화된 로깅이 필요한 애플리케이션
- 로그 레벨을 런타임에 조정해야 하는 경우
- 성능이 중요한 프로덕션 환경

klog를 활용하여 더 나은 로깅 시스템을 구축해보세요! 🚀

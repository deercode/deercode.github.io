---
layout: post
lang: ja
title:  "Golangでklogを使用する"
date:   2026-03-04
excerpt: "GolangでKubernetesのklogライブラリを使用して構造化ロギングを実装する方法を学びます。"
categories: [Backend]
tags: [Golang, klog, logging, kubernetes]
comments: true
permalink: /golang-klog
---

## はじめに

Golangでロギングを実装する際、複数のライブラリを使用できます。`log`パッケージから`logrus`、`zap`、`zerolog`など、様々な選択肢がありますが、Kubernetesエコシステムで広く使用されている`klog`は、構造化ロギングと多様なログレベルを提供する強力なツールです。

この記事では、実践的な例とともにGolangでklogを使用する方法を探ります。

## klogとは？

klogは、Kubernetesプロジェクトで使用される構造化ロギングライブラリです。Googleのglogライブラリを基にしており、以下の特徴があります：

- **構造化ロギング**: ログレベル別の体系的なロギングサポート
- **パフォーマンス最適化**: 非同期ロギングによるアプリケーションパフォーマンスへの影響を最小化
- **柔軟な設定**: フラグによるランタイムログレベル調整
- **ファイル出力**: ログをファイルに保存して管理が容易

## インストール

klogを使用するには、まずパッケージをインストールする必要があります：

```bash
go get k8s.io/klog/v2
```

または、Go modulesを使用する場合：

```bash
go mod tidy
```

## 基本的な使用方法

### 簡単な例

最も基本的な使用方法から見ていきましょう：

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    // フラグのパース（klogは内部的にフラグを使用）
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush()

    klog.Info("アプリケーションが開始されました")
    klog.Infof("ユーザーID: %d", 12345)
    klog.Warning("警告メッセージです")
    klog.Error("エラーが発生しました")
}
```

### ログレベル

klogは以下のログレベルを提供します：

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

    // Infoレベル: 一般的な情報ログ
    klog.Info("情報メッセージ")
    klog.Infof("フォーマットされた情報: %s", "値")

    // Warningレベル: 警告メッセージ
    klog.Warning("警告メッセージ")
    klog.Warningf("フォーマットされた警告: %d", 42)

    // Errorレベル: エラーメッセージ
    klog.Error("エラーメッセージ")
    klog.Errorf("フォーマットされたエラー: %v", err)

    // Fatalレベル: 致命的なエラー（プログラム終了）
    klog.Fatal("致命的なエラー - プログラム終了")
    klog.Fatalf("フォーマットされた致命的なエラー: %s", "メッセージ")

    // Vレベル: 詳細ログ（Verbose）
    klog.V(1).Info("詳細ログレベル1")
    klog.V(2).Info("詳細ログレベル2")
    klog.V(3).Infof("詳細ログレベル3: %s", "値")
}
```

## ログレベルの設定

klogはコマンドラインフラグを通じてログレベルを調整できます：

```bash
# 基本的な実行
go run main.go

# ログレベルの設定
go run main.go -v=2

# 特定のモジュールのログレベル設定
go run main.go -v=2 -vmodule=user=3

# ログをファイルに出力
go run main.go -logtostderr=false -log_dir=./logs
```

### コードでログレベルを設定

プログラム内でログレベルを設定することもできます：

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // コードでログレベルを設定
    flag.Set("v", "2")
    flag.Set("logtostderr", "true")
    
    flag.Parse()
    defer klog.Flush()

    klog.V(1).Info("このメッセージはv=1以上でのみ出力されます")
    klog.V(2).Info("このメッセージはv=2以上でのみ出力されます")
}
```

## 構造化ロギング

klogは構造化ロギングのための`InfoS`、`ErrorS`などの関数を提供します：

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

    // キー値ペアによる構造化ロギング
    klog.InfoS("ユーザーログイン成功",
        "userID", 12345,
        "username", "hyungsun",
        "ip", "192.168.1.1",
    )

    klog.ErrorS(nil, "データベース接続失敗",
        "host", "localhost",
        "port", 5432,
        "database", "mydb",
    )

    // エラーオブジェクトとともにロギング
    err := someFunction()
    if err != nil {
        klog.ErrorS(err, "関数実行失敗",
            "function", "someFunction",
            "retryCount", 3,
        )
    }
}
```

## 実践的な例

### HTTPサーバーでklogを使用する

実際のWebサーバーでklogを使用する例を見てみましょう：

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

    klog.InfoS("HTTPサーバー開始",
        "port", 8080,
        "env", "production",
    )

    if err := http.ListenAndServe(":8080", nil); err != nil {
        klog.Fatalf("サーバー開始失敗: %v", err)
    }
}

func handleUsers(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    klog.V(2).InfoS("ユーザーリストリクエスト",
        "method", r.Method,
        "path", r.URL.Path,
        "remoteAddr", r.RemoteAddr,
    )

    // ビジネスロジック
    users := []User{
        {ID: 1, Name: "Alice"},
        {ID: 2, Name: "Bob"},
    }

    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(users); err != nil {
        klog.ErrorS(err, "JSONエンコーディング失敗",
            "path", r.URL.Path,
        )
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
        return
    }

    duration := time.Since(start)
    klog.V(1).InfoS("ユーザーリスト応答完了",
        "path", r.URL.Path,
        "status", http.StatusOK,
        "duration", duration,
    )
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    klog.V(3).Info("ヘルスチェックリクエスト")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}
```

### データベース操作のロギング

データベース操作をロギングする例：

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
    
    klog.V(2).InfoS("ユーザー照会開始",
        "userID", id,
    )

    var user User
    query := "SELECT id, name FROM users WHERE id = $1"
    err := s.db.QueryRow(query, id).Scan(&user.ID, &user.Name)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "ユーザー照会失敗",
            "userID", id,
            "query", query,
            "duration", duration,
        )
        return nil, err
    }

    klog.V(1).InfoS("ユーザー照会成功",
        "userID", id,
        "duration", duration,
    )

    return &user, nil
}

func (s *DBService) CreateUser(user *User) error {
    start := time.Now()
    
    klog.InfoS("ユーザー作成開始",
        "username", user.Name,
    )

    query := "INSERT INTO users (name) VALUES ($1) RETURNING id"
    err := s.db.QueryRow(query, user.Name).Scan(&user.ID)
    
    duration := time.Since(start)
    
    if err != nil {
        klog.ErrorS(err, "ユーザー作成失敗",
            "username", user.Name,
            "query", query,
            "duration", duration,
        )
        return err
    }

    klog.InfoS("ユーザー作成成功",
        "userID", user.ID,
        "username", user.Name,
        "duration", duration,
    )

    return nil
}
```

## ログファイル管理

klogはログをファイルに保存し、ローテーションする機能を提供します：

```go
package main

import (
    "flag"
    "k8s.io/klog/v2"
)

func main() {
    klog.InitFlags(nil)
    
    // ログをファイルに保存
    flag.Set("logtostderr", "false")
    flag.Set("log_dir", "./logs")
    flag.Set("alsologtostderr", "true") // ファイルとstderrの両方に出力
    
    flag.Parse()
    defer klog.Flush()

    klog.Info("このログはファイルとstderrの両方に記録されます")
}
```

実行時にフラグで設定することもできます：

```bash
go run main.go -logtostderr=false -log_dir=./logs -alsologtostderr=true
```

## 注意事項

### 1. klog.Flush()の呼び出し

プログラム終了前に必ず`klog.Flush()`を呼び出す必要があります。klogは非同期でログを処理するため、Flushを呼び出さないと一部のログが失われる可能性があります：

```go
func main() {
    klog.InitFlags(nil)
    flag.Parse()
    defer klog.Flush() // 必ず呼び出す！

    // ... アプリケーションロジック ...
}
```

### 2. フラグパースの順序

klogは内部的に`flag`パッケージを使用するため、他のフラグと競合する可能性があります。`klog.InitFlags(nil)`を最初に呼び出し、その後に`flag.Parse()`を呼び出す必要があります：

```go
func main() {
    // 正しい順序
    klog.InitFlags(nil)
    flag.Parse()
    
    // 間違った順序（フラグ競合の可能性）
    // flag.Parse()
    // klog.InitFlags(nil)
}
```

### 3. Vレベルの使用時の注意

Vレベルは条件付きロギングのためのものなので、コストがかかる操作を避ける必要があります：

```go
// 良い例: 文字列フォーマットはVレベルチェック後にのみ実行
if klog.V(2).Enabled() {
    klog.V(2).Infof("複雑なフォーマット: %s", expensiveStringFormat())
}

// 悪い例: 常にexpensiveStringFormat()が実行される
klog.V(2).Infof("複雑なフォーマット: %s", expensiveStringFormat())
```

## 他のロギングライブラリとの比較

### klog vs logrus

| 特徴 | klog | logrus |
|------|------|--------|
| 構造化ロギング | ✅ | ✅ |
| パフォーマンス | 高い | 中程度 |
| Kubernetes統合 | ✅ | ❌ |
| 設定の複雑さ | 低い | 中程度 |

### klog vs zap

| 特徴 | klog | zap |
|------|------|-----|
| パフォーマンス | 高い | 非常に高い |
| 構造化ロギング | ✅ | ✅ |
| Kubernetes統合 | ✅ | ❌ |
| 学習曲線 | 低い | 中程度 |

## 結論

klogは、Kubernetesエコシステムで実証された強力なロギングライブラリです。特にKubernetes関連のプロジェクトや構造化ロギングが必要な場合に非常に有用です。

### 主な利点

- **シンプルなAPI**: 直感的で使いやすいインターフェース
- **パフォーマンス**: 非同期ロギングによるアプリケーションパフォーマンスへの影響を最小化
- **柔軟性**: ランタイムにログレベルを調整可能
- **Kubernetes統合**: Kubernetesプロジェクトとの自然な統合

### 推奨される使用例

- Kubernetes関連のプロジェクト
- 構造化ロギングが必要なアプリケーション
- ランタイムにログレベルを調整する必要がある場合
- パフォーマンスが重要な本番環境

klogを活用して、より良いロギングシステムを構築しましょう！ 🚀

---
layout: post
lang: ja
title:  "Elasticsearchで特定の時間範囲のデータを検索・削除するクエリコマンド"
date:   2025-12-29
excerpt: "Elasticsearchで特定の時間範囲のデータを検索・削除するクエリコマンド"
categories: [elasticsearch]
tags: [elasticsearch]
comments: true
permalink: /elasticsearch-time-range
---

# Elasticsearchで特定の時間範囲のデータを検索・削除するクエリコマンド

---

Elasticsearchで特定の時間範囲のデータを検索したり削除する必要がある場合があります。この記事では、`range`クエリを活用して時間ベースでデータを検索・削除する方法を学びます。

## 特定の時間範囲のデータを削除する

インデックスから特定の時間基準でドキュメントを削除したい場合は、`_delete_by_query`で`range`に時間条件を追加して削除できます。

例を通して見てみましょう。

### 特定の日付以降のデータを削除

`user`というインデックスで`@timestamp`が2020年7月1日以降のドキュメントを削除したい場合は、以下のようにクエリを使用します。

```json
POST user/_delete_by_query
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2020-07-01T00:00:00+09:00"
      }
    }
  }
}
```

`range`の`gte`は**greater than or equal**（以上）を意味し、指定した値以上を表します。範囲条件のパラメータは以下の通りです。

| パラメータ | 意味 |
|-----------|------|
| `gt` | より大きい（greater than） |
| `lt` | より小さい（less than） |
| `gte` | 以上（greater than or equal） |
| `lte` | 以下（less than or equal） |

### 特定の時間範囲のデータを削除

`user`というインデックスで`@timestamp`が2020年7月1日以降（0時0分0秒を含む）で2020年10月以前のデータを削除したい場合は、以下のように条件を指定できます。

```json
POST user/_delete_by_query
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2020-07-01T00:00:00+09:00",
        "lt": "2020-10-01T00:00:00+09:00"
      }
    }
  }
}
```

2020年10月1日0時より小さい範囲である`lt`パラメータを追加することで、上記の時間範囲に該当するドキュメントを削除できます。

## 特定の時間範囲のデータを検索する

データを削除する前に、まず検索して確認したい場合は、`_search` APIを使用できます。

### 特定の日付以降のデータを検索

```json
GET user/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2020-07-01T00:00:00+09:00"
      }
    }
  }
}
```

### 特定の時間範囲のデータを検索

```json
GET user/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2020-07-01T00:00:00+09:00",
        "lt": "2020-10-01T00:00:00+09:00"
      }
    }
  }
}
```

## 注意事項

- `_delete_by_query`は大量のデータを削除する際に時間がかかることがあります。
- 削除作業の前に、必ず検索クエリで対象データを確認することを推奨します。
- 本番環境では、まずテストインデックスで検証してから実行してください。
- タイムゾーン（timezone）の設定に注意してください。例では`+09:00`（日本標準時）を使用しています。

この記事がElasticsearchでの時間ベースのデータ管理に役立つことを願っています！


---
layout: post
lang: ko
title:  "Elasticsearch 특정 시간 구간 데이터 조회, 삭제하는 쿼리 명령어"
date:   2025-12-29
excerpt: "Elasticsearch 특정 시간 구간 데이터 조회, 삭제하는 쿼리 명령어"
categories: [elasticsearch]
tags: [elasticsearch]
comments: true
permalink: /elasticsearch-time-range
---

# Elasticsearch 특정 시간 구간 데이터 조회, 삭제하는 쿼리 명령어

---

Elasticsearch에서 특정 시간 구간의 데이터를 조회하거나 삭제해야 하는 경우가 있습니다. 이번 포스트에서는 `range` 쿼리를 활용하여 시간 기반으로 데이터를 조회하고 삭제하는 방법을 알아보겠습니다.

## 특정 시간 구간 데이터 삭제하기

인덱스에서 특정 시간 기준으로 document를 지우고 싶다면, `_delete_by_query`에서 `range`에 시간 조건을 추가해서 지울 수 있습니다.

예제를 통해서 살펴보겠습니다.

### 특정 날짜 이후 데이터 삭제

만약 `user`라는 인덱스에서 `@timestamp`가 2020년 7월 1일 이후인 document를 지우고 싶다면 아래와 같이 쿼리를 사용합니다.

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

`range`에서 `gte`는 **greater than or equal**로 같거나 큰 값을 뜻합니다. 범위 조건에 대한 내용은 아래와 같습니다.

| 파라미터 | 의미 |
|---------|------|
| `gt` | 크다 (greater than) |
| `lt` | 작다 (less than) |
| `gte` | 크거나 같다 (greater than or equal) |
| `lte` | 작거나 같다 (less than or equal) |

### 특정 시간 구간 데이터 삭제

만약 `user`라는 인덱스에서 `@timestamp`가 2020년 7월 1일 이후(0시 0분 0초 포함)와 2020년 10월 이전의 데이터를 삭제하고 싶다면 아래와 같이 조건을 줄 수 있습니다.

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

2020년 10월 1일 0시보다 작은 구간인 `lt` 파라미터를 추가하여 위의 시간 구간에 해당하는 document들을 삭제할 수 있습니다.

## 특정 시간 구간 데이터 조회하기

데이터를 삭제하기 전에 먼저 조회하여 확인하고 싶다면, `_search` API를 사용할 수 있습니다.

### 특정 날짜 이후 데이터 조회

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

### 특정 시간 구간 데이터 조회

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

## 주의사항

- `_delete_by_query`는 대량의 데이터를 삭제할 때 시간이 오래 걸릴 수 있습니다.
- 삭제 작업 전에 반드시 조회 쿼리로 대상 데이터를 확인하는 것을 권장합니다.
- 프로덕션 환경에서는 먼저 테스트 인덱스에서 검증 후 실행하세요.
- 시간대(timezone) 설정에 주의하세요. 예제에서는 `+09:00` (한국 시간)을 사용했습니다.

이 글이 Elasticsearch에서 시간 기반 데이터 관리에 도움이 되길 바랍니다!

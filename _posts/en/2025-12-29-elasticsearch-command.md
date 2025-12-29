---
layout: post
lang: en
title:  "Elasticsearch Query Commands for Querying and Deleting Data by Time Range"
date:   2025-12-29
excerpt: "Elasticsearch Query Commands for Querying and Deleting Data by Time Range"
categories: [elasticsearch]
tags: [elasticsearch]
comments: true
permalink: /elasticsearch-time-range
---

# Elasticsearch Query Commands for Querying and Deleting Data by Time Range

---

There are cases where you need to query or delete data within a specific time range in Elasticsearch. In this post, we will learn how to query and delete data based on time using the `range` query.

## Deleting Data by Time Range

If you want to delete documents from an index based on a specific time, you can add a time condition to the `range` query in `_delete_by_query`.

Let's look at some examples.

### Deleting Data After a Specific Date

If you want to delete documents from the `user` index where `@timestamp` is after July 1, 2020, you can use the following query:

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

In `range`, `gte` means **greater than or equal**, indicating values that are equal to or greater than the specified value. The range condition parameters are as follows:

| Parameter | Meaning |
|-----------|---------|
| `gt` | Greater than |
| `lt` | Less than |
| `gte` | Greater than or equal |
| `lte` | Less than or equal |

### Deleting Data Within a Specific Time Range

If you want to delete data from the `user` index where `@timestamp` is after July 1, 2020 (including 00:00:00) and before October 2020, you can specify the conditions as follows:

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

By adding the `lt` parameter for times less than October 1, 2020 00:00, you can delete documents that fall within the above time range.

## Querying Data by Time Range

If you want to query and verify the data before deleting it, you can use the `_search` API.

### Querying Data After a Specific Date

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

### Querying Data Within a Specific Time Range

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

## Important Notes

- `_delete_by_query` can take a long time when deleting large amounts of data.
- It is recommended to verify the target data using a query before performing the delete operation.
- In production environments, test on a test index first before executing.
- Pay attention to timezone settings. The examples use `+09:00` (Korea Standard Time).

I hope this post helps you manage time-based data in Elasticsearch!


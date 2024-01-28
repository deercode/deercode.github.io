---
layout: post
lang: ja
title:  "[python] DFS/BFS Pythonの基本テンプレートコードを学ぶ"
date:   2023-08-10
excerpt: "DFS/BFS Pythonの基本テンプレートコードを学ぶ"
categories: [Algorithm]
tags: [python, Algorithm]
comments: true
permalink: /dfs-by-python
---

## グラフの探索
グラフの各頂点を訪れるグラフの探索には一般的に**深さ優先探索（DFS, Deep-first Search）**と**幅優先探索（BFS, Breadth-First Search）**があります。通常、DFSはBFSよりも広く使用され、コーディングテストではよく出題されるカテゴリーの1つです。DFSは主にスタックまたは再帰を使用して実装し、バックトラッキングに優れた効果を発揮します。一方、BFSはキューを使用して実装し、グラフの最短経路を見つけるのに役立ちます。この記事では、基本的なDFSとBFSのPythonコードについて説明します。

```python
graph = {
    1: [2, 3, 4],
    2: [5],
    3: [5],
    4: [],
    5: [6, 7],
    6: [],
    7: [3]
}
```
このようなグラフのすべての頂点を探索することを考えてみましょう。

## DFS Pythonのテンプレートコード
DFSは再帰またはスタックを使用して実装すると述べました。以下に、それぞれのテンプレートコードを紹介します。実際のコーディングテストではDFSアルゴリズムがすぐに思いつかないこともあり、条件が変わるため、基本的なテンプレート程度は把握しておくと良いでしょう。

### 再帰で実装されたDFS

```python
def recursive_dfs(v, discovered=[]):
    discovered.append(v)
    for next_item in graph[v]:
        if next_item not in discovered:
            discovered = recursive_dfs(next_item, discovered)
    return discovered

print(recursive_dfs(1, []))
```

`recursive_dfs`の引数は探索する頂点`v`と既に訪れた頂点を累積して保存している`discovered`リストが必要です。
1) 関数の開始部分では、その頂点を訪れたことを示すために`discovered`に変数を追加します。
2) その頂点から移動できるすべての頂点を探索し、
3) すでに訪れた頂点であれば探索しません。
4) 次の頂点と既に訪れた頂点のリストを引数にして再帰的に呼び出します。この値は、すべての探索が終わった後に割り当てられます。
5) もう探索する頂点がない場合は、リストを返して渡します。

DFSは深さ優先探索のため、グラフの最下層まで探索した後、上に戻って未探索の場所を探し直します。これはスタックと深い関連性があります。なぜなら、DFSで3番目の深さに到達し、もはや探索する頂点がない場合は、1番目ではなく2番目の深さに戻って残りの頂点を探索する必要があるからです。

### スタックで実装されたDFSコード

```python
def stack_dfs(v):
    discovered = []
    stack = [v]
    
    while stack:
        vx = stack.pop()
        if vx not in discovered:
            discovered.append(vx)
            for w in graph[vx]:
                stack.append(w)
    
    return discovered

print(stack_dfs(1))
```

DFSをスタックを使って実装すると、再帰関数よりも実行速度が速く、直感的です。ただし、スタックで実装する場合、再帰関数と探索の順序がわずかに異なることがあります。


## BFS Pythonのテンプレートコード

BFSはキューを使って実装します。

```python
def bfs(v):
    queue = [v]
    discovered = []
    
    while queue:
        vx = queue.pop(0)
        if vx not in discovered:
            discovered.append(vx)
            for w in graph[vx]:
                queue.append(w)
    
    return discovered

print(bfs(1))
```

上記は`pop(0)`のキューの操作を使用していますが、これはO(n)のパフォーマンスを要求します。性能を向上させるには、`collections`モジュールの`deque`データ型を使用することができます。

```python
import collections
def bfs(v):
    queue = collections.deque()
    queue.append(v)
    discovered = []
    
    while queue:
        vx = queue.popleft()
        if vx not in discovered:
            discovered.append(vx)
            for w in graph[vx]:
                queue.append(w)
    
    return discovered
```
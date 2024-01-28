---
layout: post
lang: ko
title:  "[python] DFS/BFS 파이썬 기본 템플릿 코드 익히기"
date:   2023-08-10
excerpt: "DFS/BFS 파이썬 기본 템플릿 코드 익히기"
categories: [Algorithm]
tags: [python, Algorithm]
comments: true
permalink: /dfs-by-python
---

## 그래프 순회
그래프의 각 정점을 방문하는 그래프 순회에는 일반적으로 **깊이 우선 탐색(DFS, Deep-first Search)**와 **너비 우선 탐색(BFS, Bread-First Search)**가 있다. 일반적으로 DFS가 BFS보다 널리 쓰이고, 코딩 테스트시에 자주 출제되는 유형중 하나다. DFS는 주로 스택이나 재귀로 구현하고 백트래킹에 뛰어난 효과를 보인다. 반면 BFS는 큐를 통해 구현하고, 그래프의 최단 경로를 찾는데 유용하다. 본 글에서는 DFS와 BFS를 구현하는 기본적인 파이썬 코드에 대해서 설명한다.

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
위와 같은 그래프의 모든 정점을 탐색한다고 가정해보자.

## DFS 파이썬 템플릿 코드
앞서 DFS는 재귀 또는 스택을 통해 구현한다고 했다. 여기서는 각각의 템플릿 코드를 소개한다. 막상 코딩 테스트에 나가면 DFS 알고리즘이 바로 생각이 안날때도 있고, 조건들이 달라지기 때문에 기본 템플릿 정도는 숙지를 하고 가는 것이 좋다. 

### 재귀로 구현한 DFS

```python
def recursive_dfs(v, discovered = []):
    # 1) 방문한 정점 방문 기록에 추가
    discovered.append(v)

    # 2) 해당 정점이 갈 수 있는 경로 진행
    for next_item in graph[v]:
        # 3) 만약 다음 정점이 이미 방문한 곳이라면 방문하지 않음
        if next_item not in discovered:
            4) 다음 정점과 방문 리스트를 인자로 넘김
            discovered = recursive_dfs(next_item, discovered)

    # 5) 더이상 방문할 정점이 없으면 리스트를 return 하여 넘김
    return discovered

print(recursive_dfs(1,[]))

>>>
[1, 2, 5, 6, 7, 3, 4]
```

discovered_dfs의 인자는 방문할 정점 `v`와 방문한 정점을 누적하여 저장하고 있는 `discovered` 리스트가 필요하다. 
1) 함수의 시작 부분에는 해당 정점을 방문했다는 것을 표시하기 위해 discovered에 변수를 추가한다.
2) 해당 정점에서 다음 정점으로 갈 수 있는 모든 정점을 탐색하고
3) 이미 방문한 정점이면 방문하지 않는다.
4) 다음 정점과 이미 방문한 정점 리스트를 인자로 주고, 리턴 값을 discovered에 담는다. 해당 값은 하위 프로시저들이 모든 탐색을 끝나고 나면 값이 할당된다.
5) 더이상 방문할 정점이 없으면 리스트를 return 하여 넘김

DFS는 깊이 우선 탐색으로 말그대로 그래프의 최하단까지 탐색한후, 더이상 탐색할 곳이 없으면 다시 위로 올라와 탐색하지 못한 곳을 더 탐색한다. 이러한 매커니즘은 스택과 연관성이 깊다. 왜냐하면 DFS로 3번째 깊이에 도달하고 더이상 방문할 정점이 없이면 1번째가 아닌 2번째 깊이로 돌아가서 남은 정점을 탐색해야 하기 때문이다. 즉 이는 Stack 자료 구조와 연관성이 있다. 

### Stack으로 구현한 DFS 코드

```python
def stack_dfs(v):
    discovered = []
    stack = [v]

    # stack이 비어있을때 까지 탐색
    while stack:
        # stack에서 마지막에 삽입된 원소를 가져옴
        vx = stack.pop()

        # 해당 정점이 이미 탐색된것이 아니면
        if vx not in discovered:
            # 탐색 리스트에 추가하고
            discovered.append(vx)

            # 다음 정점들을 stack에 추가함
            for w in graph[vx]:
                stack.append(w)
    
    return discovered
print(stack_dfs(1))

>>>
[1, 4, 3, 5, 7, 6, 2]
```

stack을 통해 DFS를 구현하면 재귀함수보다 실행 속도는 더 빠르고 직관적이다. 하지만 스택으로 구현하다보니 재귀함수와 탐색 순서를 조금 다른것을 알 수 있다. 


## BFS 파이썬 템플릿 코드

BFS는 큐를 통해서 구현한다.

```python
def bfs(v):
    queue = [v]
    discovered = []

    # queue에 데이터가 있으면
    while queue:
        # 가장 첫 원소를 가져옴
        vx = queue.pop(0)

        # 해당 원소가 discovered에 없으면
        if vx not in discovered:
            # discovered에 원소를 추가하고
            discovered.append(vx)

            # 다음 정점들을 탐색하여 큐에 넣음
            for w in graph[vx]:
                queue.append(w)
    
    return discovered

print(bfs(1))
>>>
[1, 2, 3, 4, 5, 6, 7]
```
위는 pop(0)의 큐의 연산을 사용했는데, 이는  O(n)의 성능을 요구한다. 좀 더 성능을 높히려면 collections 모듈의 deque 자료형을 사용해볼 수 있다. 

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




파이썬 알고리즘 인터뷰 참고


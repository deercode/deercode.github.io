---
layout: post
lang: en
title:  "[python] Learn Basic Template Codes for DFS/BFS in Python"
date:   2023-08-10
excerpt: "Learn Basic Template Codes for DFS/BFS in Python"
categories: [Algorithm]
tags: [python, Algorithm]
comments: true
permalink: /dfs-by-python
---

## Graph Traversal
When it comes to graph traversal, there are commonly used techniques: **Depth-First Search (DFS)** and **Breadth-First Search (BFS)**. DFS is generally more widely used than BFS, and it's a common type of problem in coding interviews. DFS is often implemented using a stack or recursion and excels in backtracking. On the other hand, BFS is implemented using a queue and is useful for finding the shortest path in a graph. In this article, I will explain basic Python codes for implementing DFS and BFS.

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
Let's assume we want to traverse all vertices of the graph above.

## DFS Python Template Code
As mentioned earlier, DFS can be implemented using recursion or a stack. Here, I'll introduce template codes for each. When you go for a coding test, you might not always recall the DFS algorithm immediately, and conditions may vary, so it's good to have a grasp of the basic template.

### DFS Implemented with Recursion

```python
def recursive_dfs(v, discovered=[]):
    # 1) Add the visited vertex to the discovered list
    discovered.append(v)

    # 2) Explore paths from the current vertex
    for next_item in graph[v]:
        # 3) Do not visit if the next vertex is already discovered
        if next_item not in discovered:
            # 4) Pass the next vertex and the discovered list as arguments
            discovered = recursive_dfs(next_item, discovered)

    # 5) If there are no more vertices to visit, return the list
    return discovered

print(recursive_dfs(1,[]))

>>>
[1, 2, 5, 6, 7, 3, 4]
```

The arguments for `discovered_dfs` are the vertex to visit `v` and the list that accumulates the visited vertices `discovered`. 
1) At the beginning of the function, add a variable to indicate that the vertex has been visited to the `discovered` list.
2) Explore all vertices that can be visited from the current vertex.
3) Do not explore if the next vertex is already visited.
4) Pass the next vertex and the list of already visited vertices as arguments, and assign the return value to `discovered`. This value is assigned after all sub-procedures finish all explorations.
5) If there are no more vertices to visit, return the list.

DFS, being depth-first, traverses down to the bottom of the graph and then comes back up to explore the remaining unvisited places. This mechanism has a deep connection with the stack. This is because after reaching the third depth with DFS, if there are no more vertices to visit, it needs to go back to the second depth instead of the first to explore the remaining vertices. Hence, it is associated with the Stack data structure.

### DFS Implemented with Stack

```python
def stack_dfs(v):
    discovered = []
    stack = [v]

    # Traverse until the stack is empty
    while stack:
        # Get the last inserted element from the stack
        vx = stack.pop()

        # If the vertex is not visited yet
        if vx not in discovered:
            # Add it to the list of visited vertices
            discovered.append(vx)

            # Add the next vertices to the stack
            for w in graph[vx]:
                stack.append(w)
    
    return discovered
print(stack_dfs(1))

>>>
[1, 4, 3, 5, 7, 6, 2]
```

Implementing DFS with a stack is faster and more intuitive than a recursive function. However, when implementing with a stack, you may notice a slight difference in exploration order compared to a recursive function.

## BFS Python Template Code

BFS is implemented using a queue.

```python
def bfs(v):
    queue = [v]
    discovered = []

    # If there are elements in the queue
    while queue:
        # Get the first element
        vx = queue.pop(0)

        # If the element is not in discovered
        if vx not in discovered:
            # Add the element to discovered
            discovered.append(vx)

            # Explore the next vertices and add them to the queue
            for w in graph[vx]:
                queue.append(w)
    
    return discovered

print(bfs(1))
>>>
[1, 2, 3, 4, 5, 6, 7]
```
The above code uses the `pop(0)` operation of the queue, which requires O(n) performance. To improve performance, you can use the `deque` data type from the `collections` module.

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
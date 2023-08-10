---
layout: post
title:  "Effective Python 파이썬 코딩의 기술 요약 정리 (Chapter 3. 함수)"
date:   2023-08-06
excerpt: "Effective Python 파이썬 코딩의 기술 요약 정리"
categories: [Python]
tags: [python, 책리뷰]
comments: true
---

## 19. 함수가 여러 값을 반환하는 경우에는 절대로 네 값 이상을 언패킹하지 말라

이건 그냥 함수 리턴 값을 아래와 같이 많이 쓰지 말라는 얘기.

```python
min, max, avg, med, count = get_stats(lengths)
```

개발자가 헷갈릴 가능성이 크다. 이건 너무 당연한거라 패쓰.

## 20. None을 반환하기 보다는 예외를 발생시켜라

```python
def careful_divide(a, b):
    try:
        return a/b
    except ZeroDivisionError:
        return None
```
파이썬 프로그래머들은 반환 값을 None으로 하면 이 값에 특별한 의미를 부여하는 경향이 있다. 예를들어 a와 b를 나누는 함수를 위와 같이 작성했다고 하자. 만약 b에 0이 들어오면 None 값을 리턴하게 된다. 그리고 이 함수를 사용하는 부분에서 적절히 None 값을 처리한다.

```python
x, y = 1, 0
result = careful_divide(x, y)
if not result:
    print("잘못된 입력")
```
그런데 만약 여기서 x에 0 값이 들어가고 y에 5라는 값이 들어가면 어떻게 될까? 이 경우에는 careful_divide에서 0을 반환하는데, 조건문에서 이를 False로 인식하여 의도하지 않은 동작을 나타낸다. 이러한 실수를 방지하기 위한 방법은 두가지가 있다.

### 1. 반환값을 2-튜플로 분리한다.
이 방법은 첫번쨰 부분은 연산의 성공, 실패 여부를 나타내고 두번째 부분은 실제 결과값을 저장한다. 

```python
x, y = 1, 0
success, result = careful_divide(x, y)
if not success:
    print("잘못된 입력")
```

### 2. Exception을 호출한 쪽으로 발생시킨다.
```python
def careful_divide(a, b):
    try:
        return a/b
    except ZeroDivisionError as e:
        raise ValueError("잘못된 입력")
```
호출한 부분에서는 조건문을 사용하지 않고, try의 else 부분에서 이를 사용할 수 있다. 

```
x, y = 5, 2
try:
    result = careful_divide(x, y)
except ValueError:
    print("잘못된 입력")
else :
    print(f"결과 {result}")
```

## 21. 변수 영역과 클로저의 상호작용 방식을 이해하라

숫자로 이뤄진 list를 정렬하되, 정렬한 리스트의 앞 쪽에는 우선순위를 보여한 숫자를 위치시키자. 그리고 만약 group에 있는 숫자가 나타나면 True를 아니면 False를 리턴하자.

```python
def sort_priority(values, group):
    found = False
    def helper(x):
        if x in group:
            found = True
            return (0, x)
        return (1, x)
    values.sort(key=helper)
    return found
    

numbers = [8, 3, 1, 2, 5, 4, 7, 6]
group = {2, 3, 5, 7}
found = sort_priority(numbers, group)

print('발견', found)
print(numbers)

>>>
발견 False
[2, 3, 5, 7, 1, 4, 6, 8]
```
정렬결과는 맞지만 왜 found 변수가 False일까? 이는 변수의 Scope로 생긴 문제이다. helper 내의 found 변수는 해당 영역에서 True로 대입된다. 즉 helper 영역에서 새로운 변수를 정의하는 것으로 취급하지 set_priority의 변수를 대입하는 것으로 취급하지 않는다. 이는 함수에서 사용한 지역변수가 그 함수를 포함한 모듈 영역을 더럽히지 않도록 의도된 동작이다. 그래서 이렇게 변수의 스코프로 의도치 않은 버그를 만드는 상황을 `영역 지정 버그(scoping bug)`라고 부른다. 파이썬에서는 클로저 밖으로 변수를 끌어내는 구문이 있다. 바로 'nonlocal'이다. 

```python
def sort_priority(values, group):
    found = False
    def helper(x):
        nonlocal found    # 추가 
        if x in group:
            found = True
            return (0, x)
        return (1, x)
    values.sort(key=helper)
    return found
```
nonlocal 문을 대입할 데이터가 클로저 밖에 있다는 것을 명시한다. 하지만 함수가 복잡해지는 경우 nonlocal은 코드 이해를 어렵게 만든다. 그래서 nonlocal 변수 사용이 복잡해지면 도우미 함수로 상태를 감싸는 편이 더 낫다.

```python
class Sorter:
    def __init__(self, group):
        self.group = group
        self.found = False
    
    def __call__(self, x):
        if x in self.group:
            self.found = True
            return (0, x)
        return (1, x)


numbers = [8, 3, 1, 2, 5, 4, 7, 6]
group = {2, 3, 5, 7}

sorter = Sorter(group)
numbers.sort(key=sorter)

print('발견', sorter.found)
print(numbers)

```

## 22. 변수 위치 인자를 사용해 시각적인 잡음을 줄여라.

```python
def log(message, *values):
    if not values:
        print(message)
    else:
        value_str = ', '.join(str(x) for x in values)
        print(f"{message}: {value_str}")
        

log('nums', 1, 2, 3)
log('nums', 5, 6, 8, 10, 11)
log('end')

>>>
nums: 1, 2, 3
nums: 5, 6, 8, 10, 11
end
```
위와 같이 가변 인자를 받을 수 있다면 다양한 길이의 value들이 와도 처리할 수 있다. 시각적으로 매우 깔끔하다는 장점이 있지만, 두가지 문제가 있다. 첫번째는 함수에 가변 인자가 전달되기 전에 항상 튜플로 변환된다는 것이다. 

```python
def my_generator():
    for i in range(10):
        yield i
        
def my_func(*args):
    print(args)
    
it = my_generator()
my_func(*it)

>>>
(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
```
위와 같이 args에 들어가는 인자수가 충분히 적다는 것을 인지했을때는 가변인자를 사용하는 것이 좋지만, 데이터가 큰 경우 제너레이터의 모든 원소를 호출하기 때문에 메모리를 소진할 가능성이 있다.

두번쨰 문제는 함수에 새로운 위치 인자를 추가하게 되면, 해당 함수를 호출하는 모든 코드를 변경해야 한다. 
```python
def log(sequence, message, *values):
    if not values:
        print(f"{sequence} - {message}")
    else:
        value_str = ', '.join(str(x) for x in values)
        print(f"{sequence} - {message}: {value_str}")
        
log(1, 'start')
log(2, 'nums', 6, 12)
log('Hi', 'start')   # 예전 방식의 코드 문제가 생김
>>>
1 - start
2 - nums: 6, 12
Hi - start
```
세번쨰 로그는 기존 방식의 로그 함수로 사용하기 떄문에 적절하지 않게 동작한다. 심지어 예외도 발생하지 않기 때문에 추적하기도 어렵다. 이런 가능성을 없애기 위해서는 *args를 받아들이는 함수를 확장할 때는 키워드 기반의 인자만 사용해야 한다. 더 방어적으로 하려면 타입 애너테이션을 사용해도 된다. 

---
layout: post
lang: ko
title:  "Effective Python 파이썬 코딩의 기술 요약 정리 (Chapter 2. 리스트와 딕셔너리)"
date:   2023-08-01
excerpt: "Effective Python 파이썬 코딩의 기술 요약 정리"
categories: [Python]
tags: [python, 책리뷰]
comments: true
---

## 11. 시퀀스를 슬라이싱하는 방법을 익혀라
슬라이싱이란 시퀀스를 여러 조각으로 나누는 방법이다. 슬라이싱은 최소한의 노력으로 시퀀스에 들어있는 아이템의 부분집합에 접근할 수 있게 해준다. 

슬라이싱의 기본 형태는 `리스트[시작:끝]`이다. 시작인덱스는 포함되지만, 끝 인덱스는 포함되지 않는다.

```python
a = [1, 2, 3, 4, 5]

print(a[3:5])   # 3, 4 번째 원소 가져오기
print(a[:3])    # 처음부터 2번쨰까지
print(a[2:])    # 2번째부터 끝까지

>>>
[4, 5]
[1, 2, 3]
[3, 4, 5]
```

슬라이싱에서 시작과 끝 인덱스를 모두 없애면 원래 리스트를 복사한 새 리스트를 얻는다.
```python
b = a[:]  # a의 내용을 복사한 새로운 리스트 b가 만들어짐
assert b == a and b is not a 
```

시작과 끝 인덱스가 없는 슬라이스에 대입하면 연산자 오른쪽의 슬라이스가 참조하는 리스트의 내용을 덮어쓴다. 아래 예제로 살펴보자.

```python
a = [1, 2, 3, 4, 5]

b = a
print("이전 a", a)
print("이전 b", b)

a[:] = [101, 102, 103]
assert a is b       # a와 b는 여전히 같음

print("이후 a", a)
print("이후 b", b)
>>>
이전 a [1, 2, 3, 4, 5]
이전 b [1, 2, 3, 4, 5]
이후 a [101, 102, 103]
이후 b [101, 102, 103]
```

## 12. 스트라이드와 슬라이스를 한 식에 함께 사용하지 말라

파이썬은 `리스트[시작:끝:증가값]`으로 일정한 간격을 두고 슬라이싱할 수 있는 특별한 구문을 제공한다. 이를 스트라이드(stride)라고 하는데, 시퀀스를 슬라이싱하면서 매 n번째 원소만 가져올 수 있다. 

```python
a = [1, 2, 3, 4, 5, 6, 7, 8]

odds = a[::2]
evens = a[1::2]

print(odds)
print(evens)
>>>
[1, 3, 5, 7]
[2, 4, 6, 8]
```
스트라이드 구문은 예기치 못한 동작이 일어나 버그를 야기할 수 있다. 스트라이드를 사용하면 간단한 방법으로 문자열을 뒤집을 수 있다.

```python
en_string = "human"
ko_string = "인간"

en_reverse = en_string[::-1]
ko_reverse = ko_string[::-1]

print(en_reverse)
print(ko_reverse)

```
하지만 유니코드 데이터를 UTF-8로 인코딩한 문자열에서는 위 코드가 동작하지 않는다. 

```python
ko_string = "인간"
ko_string_encoded = ko_string.encode('utf-8')
ko_reverse = ko_string_encoded[::-1].decode('utf-8')
print(ko_reverse)

>>>
Traceback (most recent call last):
  File "<string>", line 6, in <module>
UnicodeDecodeError: 'utf-8' codec can't decode byte 0x84 in position 0: invalid start byte
```
위는 utf-8 인코딩의 바이트 순서를 뒤집으면 2바이트 이상으로 이뤄졌던 문자들은 코드가 깨지기 때문에 생기는 문제다. 1바이트로 이뤄진 아스키 코드 범위안의 문자들은 아무 문제가 없을 수 있다.

```python
x[2::2]
x[-2::-2]
x[-2:2:-2]
x[2:2:-2]
```
제일 중요한 단점은 슬라이싱에 스르라이드가 들어가면 매우 혼란스럽다. 이런 문제를 방지하기 위해 시작값이나 끝값을 스트라이드와 같이 사용하지 말 것을 권한다. 굳이 슬라이싱과 스트라이드를 같이 사용해야 한다면, 스트라이딩 한 결과를 변수에 대입한 다음 스트라이딩하자.

```python
a = [1, 2, 3, 4, 5, 6, 7, 8]

x = a[::2]   # 스트라이딩 한 후 [1, 3, 5, 7]
z = x[1:-1]  # 슬라이싱 [3, 5]
```

## 13. 슬라이싱보다는 나머지를 모두 잡아내는 언패킹을 사용하라

```python
car_ages_descending = [20, 19, 18, 17, 10, 5, 4, 3, 2, 0]
oldest = car_ages_descending[0]
second_oldest = car_ages_descending[1]
others = car_ages_descending[2:]
```
리스트에서 가장 오래된 자동차와 두번째로 오래된 자동차 그리고 나머지를 나누는 코드다. 위 코드는 잘 작동하지만 슬라이스와 인덱스로 인해 시각적으로 이해하기 어렵다. 이런 코드는 오류를 발생시키기 쉽다. 이런 상황을 더 잘 다룰 수 있도록 파이썬에서는 `별표식(starred expression)`을 제공한다. 

```python
oldest, second_oldest, *others = car_ages_descending

>>>
oldest # 20
second_oldest # 19
others # [18, 17, 10, 5, 4, 3, 2, 0]
```
위 코드를 쓰면 car_aged_descending 리스트의 첫번째는 oldest, 두번째는 second_oldest, 나머지 원소는 others에 리스트 형식으로 들어간다. 마지막 뿐만 아니라 중간에도 넣을 수 있다.


```python
oldest, *others, youngest = car_ages_descending

>>>
oldest # 20
youngest # 0
others # [18, 19, 17, 10, 5, 4, 3, 2]
```
이렇게 되면 처음과 끝값만 oldest, youngest에 들어가고 나머지는 others에 들어간다. 

별표식을 사용하면 이터레이터의 값을 깔끔하게 가져올 수 있다. 만약 중고차 매매상에서 판매한 자동차 내역이 들어 있는 csv 파일 각 줄을 읽어 내보내는 제너레이터가 있다고 하자.
```python
def generate_csv():
    yield ('날짜', '제조사', '모델', '가격')

it = generator_csv()
header, *rows = it    # 헤더와 내용을 나눔
```
위와 같이 별표식을 사용해서 행과 열을 깔끔하게 나눌 수 있다. 하지만 별표 식은 항상 리스트를 만들기 때문에 결과 데이터가 메모리에 모두 들어갈 수 있다고 확신할 때만 언패킹을 사용해야 한다.

## 14. 복잡한 기준을 사용해 정렬할 때는 key 파라미터를 사용하라

```python
nums = [6, 3, 9, 10, 1]
nums.sort()

print(nums)
>>>
[1, 3, 6, 9, 10]
```
list 내장 타입에는 원소를 기준에 따라 정렬할 수 있는 `sort` 메서드가 들어 있다. 기본적으로는 오름차순으로 정렬한다. 그렇다면 아래와 같은 클래스는 어떻게 소팅할 수 있을까? 

```python
class Tool:
    def __init__(self, name, weight):
        self.name = name
        self.weight = weight
        
    def __repr__(self):
        return f'Tool({self.name!r}, {self.weight})'
    

tools = [
    Tool('수준계', 3.5),
    Tool('해머', 1.25),
    Tool('스쿠류드라이버', 0.5),
    Tool('끌', 0.25)
]

tools.sort()

>>>
Traceback (most recent call last):
  File "<string>", line 17, in <module>
TypeError: '<' not supported between instances of 'Tool' and 'Tool'
```

클래스는 객체 비교 메서드가 정의되어 있지 않아서 이런 타입의 객체를 정렬할 수는 없다. 이런 상황을 지원하기 위해서 sort에는 'key'라는 파라미터가 있다. 여기서 key는 함수여야 한다. 

```python
print('미정렬', repr(tools))
tools.sort(key = lambda x: x.name)
print('정렬', tools)
>>>
미정렬 [Tool('수준계', 3.5), Tool('해머', 1.25), Tool('스쿠류드라이버', 0.5), Tool('끌', 0.25)]
정렬 [Tool('끌', 0.25), Tool('수준계', 3.5), Tool('스쿠류드라이버', 0.5), Tool('해머', 1.25)]
```
위 처럼 람다 키워드로 함수를 정릐하고 이 함수를 key로 정의하면 Tool 객체를 name에 따라 정렬한다. weight에 따라서 정렬하고 싶다면 `lambda x: x.weight`로 하면 weight에 따라 정렬한다. 그럼 weight로 먼저 정렬한 다음 name으로 정렬하려면 어떻게 해야할까? 가장 쉬운 해법은 튜플(tuple)을 사용하는 것이다. 튜플 비교는 첫번째의 값 기준으로 정렬한후, 첫번째 값이 같으면 두번째 위치의 값을 비교하는 방식으로 동작한다. 

```python
class Tool:
    def __init__(self, name, weight):
        self.name = name
        self.weight = weight
        
    def __repr__(self):
        return f'Tool({self.name!r}, {self.weight})'
    

tools = [
    Tool('드릴', 4),
    Tool('톱', 5),
    Tool('착암기', 40),
    Tool('연마기', 4)
]

print('미정렬', repr(tools))
tools.sort(key = lambda x: (x.weight, x.name))
print('정렬', tools)

>>>
미정렬 [Tool('드릴', 4), Tool('톱', 5), Tool('착암기', 40), Tool('연마기', 4)]
정렬 [Tool('드릴', 4), Tool('연마기', 4), Tool('톱', 5), Tool('착암기', 40)]
```

위 방식은 name, weight 모두 오름차순으로 정렬했다. 그렇다면 weight 기준 내림차순으로 정렬한 다음, name 기준 오름차순으로 정렬하려면 어떻게 할 수 있을까? 이때는 weight에 부호 반전을 사용할 수 있다. 


```python
print('미정렬', repr(tools))
tools.sort(key = lambda x: (-x.weight, x.name))
print('정렬', tools)

>>>
미정렬 [Tool('드릴', 4), Tool('톱', 5), Tool('착암기', 40), Tool('연마기', 4)]
정렬 [Tool('착암기', 40), Tool('톱', 5), Tool('드릴', 4), Tool('연마기', 4)]
```
위 경우에는 원하는 대로 정렬을 이뤄냈다. 하지만 x.name과 같은 str에는 부호 반전을 할 수가 없다. 만약 위 예제에서 weight가 str 형이었다면 위 코드는 작동하지 않았을 것이다. 파이썬은 이런 상황을 위해 안정적인(stable) 정렬 알고리즘을 제공한다. 안정적인 정렬 알고리즘이란 sort시 key 함수가 반환하는 값이 서로 같은 경우 리스트에 있던 원래 순서를 그대로 유지한다. 코드로 살펴보자.

```python
print('미정렬', repr(tools))
tools.sort(key = lambda x: x.name)
tools.sort(key = lambda x: x.weight, reverse = True)
print('정렬', tools)

>>>
미정렬 [Tool('드릴', 4), Tool('톱', 5), Tool('착암기', 40), Tool('연마기', 4)]
정렬 [Tool('착암기', 40), Tool('톱', 5), Tool('드릴', 4), Tool('연마기', 4)]
```

위 코드의 동작을 자세히 살펴보자. 먼저 
```python
tools.sort(key = lambda x: x.name)
>>>
[Tool('드릴', 4), Tool('연마기', 4), Tool('착암기', 40), Tool('톱', 5)]
```
함수를 호출하면 위처럼 이름 순으로 정렬된다. 여기서 '드릴'과 '연마기'는 weight가 4로 같다. 
여기서 다음 weight 기준으로 sort 함수를 또 호출하면 원래 있던 순서 '드릴-연마기'를 유지한채 weight 기준으로 정렬한다. 즉 아래와 같은 결과를 얻을 수 있다.

```python
tools.sort(key = lambda x: x.name)
tools.sort(key = lambda x: x.weight, reverse = True)
print('정렬', tools)
>>>
정렬 [Tool('착암기', 40), Tool('톱', 5), Tool('드릴', 4), Tool('연마기', 4)]
```
위 방법을 통해 순서를 보존할 수 있다. 

## 15. 딕셔너리 삽입 순서에 의존할 때는 조심하라

python 3.6 부터는 딕셔너리가 삽입 순서를 보존하도록 동작이 개선되었고, 3.7부터는 명세에 해당 내용이 포함되었다. 

```python
baby_names = {
    'cat' : 'kitten',
    'dog' : 'puppy'
}

print(list(baby_names.keys()))
print(list(baby_names.values()))
print(list(baby_names.items()))

>>>
['cat', 'dog']
['kitten', 'puppy']
[('cat', 'kitten'), ('dog', 'puppy')]
```
하지만 딕셔너리를 처리할 때는 삽입 순서 관련 동작이 항상 성립한다고 가정해서는 안된다. 파이썬에서는 프로그래머가 list, dict 등의 프로토콜을 흉내내는 커스텀 컨테이너 타입을 쉽게 정의할 수 있다. 예를들어 가장 귀여운 아기 동물을 뽑는 콘테스트의 결과를 보여주는 프로그램을 만든다고 하자. 

```python
votes = {
    'otter': 1281,
    'polar bear' : 587,
    'fox' : 863
}
```
동물의 이름과 순위를 빈 딕셔너리에 저장하는 함수를 정의해보자. (populate_ranks) 그리고 가장 winner를 찾는 함수를 작성해보자.(get_winner)

```python
votes = {
    'otter': 1281,
    'polar bear' : 587,
    'fox' : 863
}

def populate_ranks(votes, ranks):
    names = list(votes.keys())
    names.sort(key=votes.get, reverse=True)
    for i, name in enumerate(names, 1):
        ranks[name] = i

def get_winner(ranks):
    return next(iter(ranks))
    
ranks = {}
populate_ranks(votes, ranks)
print(ranks)
winner = get_winner(ranks)
print(winner)

>>>
{'otter': 1, 'fox': 2, 'polar bear': 3}
otter
```
위 코드는 otter를 가장 많은 득표수를 가진 동물로 제대로된 결과를 출력했다. 그런데 프로그램의 요구사항이 바뀌었다고 가정해보자. 알파벳 순서대로 이터레이션해주는 클래스를 새로 정의해서 사용하는 시나리오가 추가되었다고 가정하자

```python
from collections.abc import MutableMapping

class SortedDict(MutableMapping):
    def __init__(self):
        self.data = {}
    
    def __getitem__(self, key):
        return self.data[key]
    
    def __setitem__(self, key, value):
        self.data[key] = value
        
    def __delitem__(self, key):
        del self.data[key]
        
    def __iter__(self):
        keys = list(self.data.keys())
        keys.sort()
        for key in keys:
            yield key
            
    def __len__(self):
        return len(self.data)

sorted_ranks = SortedDict()
populate_ranks(votes, sorted_ranks)
print(sorted_ranks.data)
winner = get_winner(sorted_ranks)
print(winner)

>>>
{'otter': 1, 'fox': 2, 'polar bear': 3}
fox

```
위 코드는 SortedDict를 삽입 순서가 아닌 알파벳 기준으로 순서를 유지하기 때문에 위 코드는 요구사항과 다르게 동작한다. 이러한 문제를 해결하는 데에는 3가지 방법이 있는데, 첫번째는 애초부터 특정 순서로 이터레이션 된다고 가정하지 않는 것이다. 

```python
def get_winner(ranks):
    for name, rank in ranks.items():
        if rank == 1 :
            return name
```

두번째 방법은 ranks의 타입을 검사하고 아닌 경우 예외를 던진다. 이 해법은 첫번째 방법보다 성능이 좋다. 

```python
def get_winner(ranks):
    if not isinstance(ranks, dict):
        raise TypeError("Needs dict instance")
    return next(iter(ranks))
```

세번째 방법은 타입 애너테이션을 사용해서 get_winner에 전달되는 값이 딕셔너리와 비슷한 동작을 하는 MutableMapping 인스턴스가 아니라 dict 인스턴스가 되도록 강제하는 것이다.

```python
from collections.abc import MutableMapping
from typing import Dict, MutableMapping
class SortedDict(MutableMapping[str, int]):
    def __init__(self):
        self.data = {}
    
    def __getitem__(self, key):
        return self.data[key]
    
    def __setitem__(self, key, value):
        self.data[key] = value
        
    def __delitem__(self, key):
        del self.data[key]
        
    def __iter__(self):
        keys = list(self.data.keys())
        keys.sort()
        for key in keys:
            yield key
            
    def __len__(self):
        return len(self.data)

def populate_ranks(votes: Dict[str, int], 
                   ranks: Dict[str, int]) -> None:
    names = list(votes.keys())
    names.sort(key=votes.get, reverse=True)
    for i, name in enumerate(names, 1):
        ranks[name] = i

def get_winner(ranks: Dict[str, int]) -> str:
    return next(iter(ranks))
    
sorted_ranks = SortedDict()
populate_ranks(votes, sorted_ranks)
print(sorted_ranks.data)
winner = get_winner(sorted_ranks)
print(winner)

# 실행시 mypy를 strict로 실행
>>> python3 -m mypy --strict example.py
incompatible type 에러 발생
```
위 코드는 mypy 도구를 strict 모드로 실행했을때 올바로 타입을 감지해서 적절한 타입을 사용하지 않을때 오류를 발생시킨다. 


## 16. in을 사용하고 딕셔너리 키가 없을떄 KeyError를 처리하기보다는 get을 사용하라

파이썬에서는 딕셔너리에 키가 있을떄 in 을 사용해서 확인할 수 있다. 아래 예제를 살펴보자.

```python
votes = {
    '바게트' : ['철수', '순이'],
    '치아바타' : ['하니', '유리']
}

key = '브리오슈'
who = '단이'

if key in votes:
    names = votes[key]
else:
    votes[key] = names = []

names.append(who)
print(votes)

>>>
{'바게트': ['철수', '순이'], '치아바타': ['하니', '유리'], '브리오슈': ['단이']}
```
in을 사용하면 키가 있는 경우에는 키를 두 번 읽어야 하고, 키가 없는 경우에는 값을 한번 대입한다. 아래와 같이 keyError 예외를 사용해서 처리할 수 있도 있다.

```python
try:
    names = votes[key]
except KeyError:
    votes[key] = names = []
names.append(who)
```
이 방법은 key가 있을때 한번만 접근하므로 in 조건문 보다 효과적이다. 

```python
names = votes.get(key)
if names in None:
    notes[key] = names = []

names.append(who)
```
get을 사용해 리스트를 가져오는 이 방식은 if 문 안에 대입식을 사용하면 저 짧게 쓸 수 있다. 

```python
if (names := votes.get(key)) is None:
    votes[key] = names = []
names.append(who)
```
dict 타입은 이 패턴을 더 간단히 사용할 수 있게 해주는 `setdefault` 메서드를 제공한다. setdefault 메서드는 딕셔너리에서 키를 사용해 값을 가져오려고 시도한다. 이 메서드는 키가 없으면 제공받은 디폴트 값을 키에 연관시켜 딕셔너리에 대입한 다음, 키에 연관된 값을 반환한다. 

```python
names = votes.setdefault(key, [])
names.append(who)
```
위 코드는 더 짧지만, 가독성은 좋지 않다. 또 한가지 여기에는 한가지 함정이 있다. 키가 없는 경우 setdefault에 전달된 디폴트 값이 별도로 복사되지 않고, 딕셔너리에 직접 대입된다는 것이다. 

```python
data = {}
key = 'foo'
value = []
data.setdefault(key, value)
print('이전:', data)
value.append('hello')
print('이후:', data)

>>>
이전: {'foo': []}
이후: {'foo': ['hello']}
```

이런 코드는 디폴트 값에 사용하는 객체를 재활용하는 경우 예상치 못한 문제를 야기할 수 있다. setdefault를 사용하는 것이 딕셔너리 키를 처리하는 지름길인 경우는 드물다. 디폴트 값이 만들어 내기 쉽거나, 디폴트 값이 변경 가능한 값이 거나, 리스트 인스턴스처럼 값을 만들어 낼 때 예외가 없는 경우 setdeafult를 사용할 수 있다. 


## 17. 내부 상태에서 원소가 없는 경우를 처리할 때는 setdefault보다 defaultdict를 사용하라

```python

class Visits:
    def __init__(self):
        self.data = {}
        
    def add(self, country, city):
        city_set = self.data.setdefault(country, set())
        city_set.add(city)
        
visits = Visits()
visits.add('러시아', '예카테린부르크')
visits.add('탄자니아', '잔지바르')
print(visits.data)

>>>
{'러시아': {'예카테린부르크'}, '탄자니아': {'잔지바르'}}

```
위 클래스는 setdefault의 호출 복잡도를 줄여서 프로그래머에게 좋은 인터페이스를 제공한다. 하지만 setdefault라는 이름은 여전히 헷갈리며 data 딕셔너리에 값이 있든 없든 set을 만들기 때문에 비효율적이다. 이런 문제를 해결하기 위해 collections 내장 모듈에 있는 defaultdict라는 클래스를 사용할 수 있다. 해당 클래스는 키가 없을때 자동으로 디폴트 값을 저장한다. 

```python
from collections import defaultdict

class Visits:
    def __init__(self):
        self.data = defaultdict(set)
        
    def add(self, country, city):
        self.data[country].add(city)
        
visits = Visits()
visits.add('러시아', '예카테린부르크')
visits.add('탄자니아', '잔지바르')
print(visits.data)

>>>
defaultdict(<class 'set'>, {'러시아': {'예카테린부르크'}, '탄자니아': {'잔지바르'}})
```

add 구현이 더 짧고 간단해졌다. 키로 어떤 값이 들어올지 모르는 딕셔너리를 관리해야 하는 경우 defaultdict 인스턴스 사용을 고려해보자.

## 18. __missing__을 사용해 키에 따라 다른 디폴트 값을 생성하는 방법을 알아두자.
사용하는 키에 따라 deafult 값이 생성되는 경우에는 __missing__ 특별 메서드를 사용해보자. 아래는 dict형 하위클래스로 Pictures 클래스를 정의하고 path를 key로, path에 대한 handle을 value로 갖는 예제다. 

```python
class Pictures(dict):
    def __missing__(self, key):
        values = open_picture(key)
        self[key] = value
        return value

pictures = Pictures()
handle = pictures[path]
handle.seek(0)
image_data = handle.read()
```
위 처럼 dict타입의 하위 클래스를 만들고 __missing__ 특별 메서드를 구현하면 키가 없는 경우를 커스텀할 수 있다. 위 코드는 pictures[path]라는 딕셔너리 접근에서 path가 딕셔너리에 없으면 __missing__ 메서드가 호출된다. 해당 원소가 있는 경우 해당 메서드는 호출되지 않는다. 

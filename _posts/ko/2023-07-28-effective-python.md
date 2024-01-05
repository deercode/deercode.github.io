---
layout: post
lang: ko
title:  "Effective Python 파이썬 코딩의 기술 요약 정리 (Chapter 1. 파이썬 답게 생각하기)"
date:   2023-07-28
excerpt: "Effective Python 파이썬 코딩의 기술 요약 정리"
categories: [Python]
tags: [python, 책리뷰]
comments: true
---

# Ch1. 파이썬 답게 생각하기
가장 `파이썬다운(pythonic)` 프로그래밍 방법이란 무엇일까?

## 1. 사용중인 파이썬의 버전을 알자

현재 사용중인 파이썬 버전을 정확히 알고 싶으면 --version 플래그를 통해 알 수 있다. 
참고로 파이썬 2 버전대는 더이상 지원하지 않으니, 더이상 사용하지 말라.

```python
python --version
Python 2.7.10

python3 --version
Python 3.8.0
```

내장 모듈인 sys의 값을 통해 현재 실행 중인 파이썬의 버전을 알 수 있다.

```python
import sys
print(sys.version_info)
print(sys.version)
```

## 2. PEP 8 스타일 가이드를 따르라

파이썬 개선 제안(Python Enhancement Proposal) #8 또는 PEP8은 파이썬 코드의 스타일 가이드다. 일관된 스타일 가이드는 가독성을 높힘과 동시에 많은 사람들과 협력할 때 도움이 된다. 
[PEP8 가이드](https://www.python.org/dev/peps/pep-0008/)는 꼭 읽어보자.


## 3. bytes와 str의 차이를 알아두라

파이썬에는 문자열 데이터의 시퀀스를 표현하기 위해 bytes와 str을 사용한다. 
* bytes : 부호 없는 8 바이트 데이터가 그대로 들어간다. 
* str : 유니코드 코드 포인트가 들어있다. 

두가지는 똑같이 동작하는 듯 보이지만, 각각의 인스턴스는 호환되지 않기 때문에 전달되는 문자 시퀀스가 어떤 타입인지를 잘 알 고 있어야 한다. 

## 4. C 스타일 형식 문자열을 str.format과 쓰기보다는 f-문자열을 통한 인터폴레이션을 사용하라

파이썬 3.6 부터는 `인터폴레이션(interpolation)`을 통한 형식 문자열 (`f-문자열` 이라고함)이 도입됐다. f-문자열은 형식 문자열의 표현력을 극대화하고, 중복을 줄일 수 있다.  

```python
>>> key = 'my_var'
>>> val = 1.234 
>>> formatted = f"{key} = {val}" 
>>> print(formatted)
my_var = 1.234
```
위와 같이 앞에 f라고 한후 문자열을 주고 그 안에 사용하고자 하는 변수를 중괄호 안에 넣으면 f-문자열을 쓸 수 있다.

```python
>>> places = 3
>>> num = 1.2345
>>> print(f"The number i choose {num:.{places}f}")    
The number i choose 1.234
```
위와 같이 형식 지정자 옵션도 사용할 수 있다. 

## 5. 복잡한 식을 쓰는 대신 도우미 함수를 작성하라

'반복하지 말라(Don't Repeat Yourself)'라는 DRY원칙에 맞게 코드를 작성하자. 예를들어 아래와 같은 코드가 있다고 하자. 

```python
my_values = {'red': ['5'], 'blue':['0'], 'green':['']}
```
위 변수에서 각각의 key에 있는 첫번째 원소를 가져오는데, 값이 없는 경우 0으로 처리하려면 아래와 같은 방법이 있다.

```python
# 아래와 or로 처리하는 방법 
>>> red = int(my_values.get('red', [''])[0] or 0)  
>>> blue = int(my_values.get('blue', [''])[0] or 0) 
>>> green = int(my_values.get('green', [''])[0] or 0) 

# if else로 처리
# if else가 오히려 더 가독성면에서 괜찮음
>>> red_str = my_values.get('red', [''])
>>> if red_str[0]:
       red = int(red_str[0])
    else:
       red = 0

# green, blue에 대해서 반복...
# 하지만 코드가 반복되고 지저분 해짐
....

```

그래서 간단하더라도 두번, 세번 반복되는 코드는 아래와 같이 도우미 함수를 작성하자.

```python
def get_first_int(values, key, default=0):
    found = values.get(key, [''])
    if found[0]:
        return int(found[0])
    else:
        default

green = get_first_int(my_values, 'green')

```
위 코드는 명확할뿐더러 반복 사용을 줄여주기 때문에 DRY 원칙에 맞다.

## 6. 인덱스를 사용하는 대신 대입을 사용해 데이터를 언패킹하라

파이썬에는 언패킹(unpacking) 구문이 있다. 

```python
item = ('호박엿', '식혜')
first, second = item
print(first, '&', second)

# 호박엿 & 식혜
```
튜플 인덱스보다 시각적인 잡음이 없고, 리스트, 시컨스, 이터러블 안에 여러 계층으로 이터러블이 들어간 경우 등 다양한 패턴을 언패킹 구문에 사용할 수 있다. 아래 예제는 언패킹 구문을 사용해서 버블 소트를 구현한 예제다.


```python
def bubble_sort(a):
    for _ in range(len(a)):
        for i in range(1, len(a)):
            if a[i] < a[i-1]:
                a[i-1], a[i] = a[i], a[i-1] # 맞바꾸기
                
names = ['프레즐', '당근', '쑷갓', '베이컨']
bubble_sort(names)

print(names)

>>>['당근', '베이컨', '쑷갓', '프레즐']
```
어떻게 이런 것이 가능할까
첫번째로 #맞바꾸기로 주석처리된 라인의 코드를 실행한다고 하자. 
1) a[1], a[0] ('프레즐', '당근')의 값이 이름 없는 튜플 어딘가에 할당이 되고
2) 이름없는 튜플은 좌변의 a[0], a[1] 에 각각 할당된다.
3) 이름 없는 튜플은 사라짐

for루프 또는 컴프리헨션이나 제너레이터 식의 대상인 리스트 원소를 언패킹하는 용도로도 사용할 수 있다. 

아래 코드는 언패킹을 사용하지 않은 코드다.

```python
snacks = [('베이컨', 350), ('도넛', 240), ('머핀', 190)]

for i in range(len(snacks)):
    item = snacks[i]
    name = item[0]
    calories = item[1]
    print(f"#{i+1} : {name}은 {calories}입니다.")

>>> #1 : 베이컨은 350입니다.
#2 : 도넛은 240입니다.
#3 : 머핀은 190입니다.
```
snacks 구조 내부의 데이터를 인덱스로 찾으면 코드가 길어지는 단점이 있다. 
enumerate 내장 함수와 언패킹함수를 사용하면 더 간단하게 코드를 작성할 수 있다.


```
snacks = [('베이컨', 350), ('도넛', 240), ('머핀', 190)]

for i, (name, calories) in enumerate(snacks, 1):
    print(f"{i}: {name}은 {calories}입니다")
```
위 코드가 짧고 이해하기도 쉬운 `파이썬 다운(pythonic)` 방식이다. 언패킹을 현명하게 사용하면 가능한 인덱스 사용을 피할 수 있고, 더 명확하고 파이썬 다운 코드를 작성할 수 있다. 

## 7. range보다는 enumerate를 사용하라

리스트를 이터레이션하면서 리스트의 몇번쨰 원소를 처리중인지 알아야 할 때가 있다. 예를들어 아이스크림 맛의 순위를 출력하고 싶을때 range를 사용하는 방법도 있다. 

```python
flavor_list = ['바닐라', '초콜릿', '피칸']

for i in range(len(flavor_list)):
    flavor = flavor_list[i]
    print(f"{i+1}: {flavor}")

>>>
1: 바닐라
2: 초콜릿
3: 피칸
> 
```
위 코드는 list의 길이를 알아야 하고, 인덱스를 사용해 배열 원소에 접근해야 하기 때문에 코드를 읽기 어렵다. 파이썬은 이런 문제를 해결하기 위한 enumerate 내장함수를 제공한다. 

```python
for i, flavor in enumerate(flavor_list, 1):
    print(f'{i}: {flavor}')
```
enumerate 두번째 인자로 어디부터 수를 세기 시작할지 지정할 수 있다. 이를 활용하면 코드를 더 깔끔하게 만들 수 있다. 

## 8. 여러 이터레이터에 대해 나란히 루프를 수행하려면 zip을 사용하라

파이썬 'zip'이라는 내장 함수는 둘 이상의 이터레이터를 묶어준다. zip 제너레이터는 각 이터레이터의 다음 값이 들어있는 튜플을 반환한다.

```python
names = ['Cecilia', '남궁민수', 'ronaldo']
counts = [len(n) for n in names]
longest_name = None
max_count = 0

for name, count in zip(names, counts):
    if count > max_count:
        longest_name = name
        max_count = count 

print(longest_name)
>>>
Cecilia
```
위 코드는 이름을 가진 리스트로 부터 이름의 길이를 나타내는 counts리스트를 만들고, 두 개의 리스트를 zip으로 묶어서 가장 긴 문자열을 찾는 예제다.
하지만 zip 함수는 두개 리스트의 길이가 같지 않은 경우 예상치 못한 결과를 초래할 수 있다. zip은 가장 짧은 리스트를 기준으로 동작한다. 즉 긴 이터레이터의 뒷부분을 버리게 되는데, 이런 경우에는 itertools 내장 모듈에 있는 `zip_longest`를 고려할 수 있다. 

```python
import itertools

names = ['Cecilia', '남궁민수', 'ronaldo']
counts = [len(n) for n in names]

names.append('James') # names 리스트에 원소 추가

for name, count in itertools.zip_longest(names, counts):
    print(f'{name} : {count}')

>>>
Cecilia : 7
남궁민수 : 4
ronaldo : 7
James : None
```
zip_longest는 존재하지 않는 값을 자신에게 전달된 fillvalue로 대신한다. 디폴트는 None이다. 

## 9. for나 while 루프 뒤에 else블록을 사용하지 말라

몰랐던 사실이지만 파이썬에서는 반복문 뒤에 else블록을 쓸 수 있다. 

```python
for i in range(3):
    print(i)
else:
    print("Else block")
>>>
0
1
2
Else block
```
하지만 이런 코드는 그 자체로 의미가 명확하지 않아서 보는 이들을 당황하게 만든다. 그래서 절대로 루프 뒤에 else블록을 사용하지 말자.

## 10. 대입식을 사용해 반복을 피하라

대입식(assignment expression), 왈러스 연산자라고도 부른다. 이는 파이썬의 고질적인 코드 중복 문제를 해결하고자 `파이썬 3.8` 버전에 터음으로 탑재되었다. 왈러스 연산자는 아래와 같이 사용한다.

```python
a := b  # a 왈러스 b라고 읽는다. 
```

### 왈러스 연산자가 필요한 이유 1
```python
fresh_fruit = {
    '사과': 10,
    '바나나': 8,
    '레몬': 5,
}

count = fresh_fruit.get('레몬', 0)
if count:
    make_lemonade(count)
else:
    out_of_stock()
```

위 코드의 count 변수는 if 문의 첫번째 블록에서만 사용된다. 파이썬에서는 이런 식으로 값을 가져와서 if문에서 해당 값을 검사하는 패턴이 자주 발생한다. 이런 패턴을 단순화, 명확하하기 위해 만든 기능이 '왈러스 연산자'이다. 

```python
if count := fresh_fruit.get('레몬', 0) :
    make_lemonade(count)
else:
    out_of_stock()
```
위 코드는 1) 한줄더 짧다는 장점 2) count가 if문에서만 의미있다고 말해주는 점 에서 읽기 쉬운 코드다. 이런 두 단계의 동작(대입 후 평가)가 왈러스 연산자의 핵심이다. 

### 왈러스 연산자가 필요한 이유 2
파이썬에는 swtich/case 문이 없기 때문에 if, elif, else 문을 깊게 내포시켜서 가독성을 해친다.

```python

count = fresh_fruit.get('바나나', 0)
if count >= 2:
    pieces = slice_bananas(count)
    to_enjoy = make_smoothies(pieces)
else:
    count = fresh_fruit.get('사과', 0)
    if count >= 4:
        to_enjoy = make_cider(count)
    else:
        count = fresh_fruit.get('레몬', 0)
        if count:
            to_enjoy = make_lemonade(count)
        else:
            to_enjoy = '아무것도 없음'
```
위와 같은 코드는 매우 지저분하다. 왈러스 연산자를 사용하면 위 코드를 switch/case와 비슷하게 만들 수 있다. 

```python
if (count := fresh_fruit.get('바나나', 0)) >= 2:
    pieces = slice_bananas(count)
    to_enjoy = make_smoothies(pieces)
elif (count := fresh_fruit.get('사과', 0)) >= 4:
    to_enjoy = make_cider(count)
elif count := fresh_fruit.get('레몬', 0):
    to_enjoy = make_lemonade(count)
else:
    to_enjoy = '아무것도 없음'
```

### 왈러스 연산자가 필요한 이유 3

do/while 루프가 없어서 파이썬 코드가 지저분해질때도 있다. 아래 코드는 신선한 과일이 배달되어서 이 과일을 모두 주스로 만든후 병에 담는 코드이다. 
```python
bottles = []
fresh_fruit = pick_fruit()
while fresh_fruit:
    for fruit, count in fresh_fruit.items():
        batch = make_juice(fruit, count)
        bottles.extend(batch)
    fresh_fruit = pick_fruit()
```

위 코드는 fresh_fruit = pick_fruit()을 두번 호출하므로 반복적이다. 이를 왈러스를 통해 간단히 만들 수 있다. 


```python
bottles = []
while fresh_fruit := pick_fruit():
    for fruit, count in fresh_fruit.items():
        batch = make_juice(fruit, count)
        bottles.extend(batch)
```

이 해법이 더 짧고 쉽기 떄문에 이 방식을 우선적으로 사용해야 한다. 


Chapter 1 끝


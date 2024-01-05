---
layout: post
lang: ko
title:  "[Elasticsearch] enrich policy execute시 주의사항"
date:   2022-10-20
excerpt: "enrich policy execute시 주의사항"
categories: [DataEngineering, Elasticsearch]
tags: [elasticsearch]
comments: true
---

## enrich를 사용하는 이유

SQL에서는 서로 다른 테이블을 결합(Join)하여 두 테이블의 정보를 한번에 가져올 수 있는 방법을 제공한다.
하지만 Elasticsearch에서 여러 인덱스간 Join은 불가능하며, SQL Join과 같은 효과를 얻으려면 데이터를 Denomalization 하여 입력시에 연관 데이터를 넣어주는 방식으로 얻을 수 있다. 

Elasticsearch 7.5 버전 부터 다른 인덱스의 데이터를 새로 인덱싱 되는 데이터에 추가하는 기능인, Enrich Processor가 도입이 되었다. 예를들어 특정 인덱스에 유저에 대한 주문 정보를 저장하고, 다른 인덱스에는 유저 상세 정보가 저장되어 있을때, Enrich processor를 사용하면 주문 정보가 들어올때 유저 ID에 매칭 되는 상세 정보를 추가적으로 주문 정보에 붙혀줄 수 있는 기능인 것이다. 


## enrich에서의 execute

여러 Enrich 관련된 post 들에는 주로 아래와 같은 흐름으로 enrich를 적용할 것을 가이드한다.

1) 소스 인덱스 마련
2) Enrich policy 생성
3) Enrich policy execute
4) Ingest pipeline 생성


실제로 수행해보면 원하는 대로 enrich processor가 추가적인 정보를 붙혀서 인덱싱을 해준다.

## enrich execute 수행시 주의 사항

문제는 소스 인덱스의 내용이 업데이트 될때이다.
위에서 처럼 enrich processor 구성을 마치고 기존에 하던대로 데이터를 넣게 되면 과거의 데이터가 붙어서 인덱싱되는 것을 알 수 있다.
이는 enrich policy execute를 해주지 않으면 과거 데이터를 가지고 인덱싱을 하기 때문에 생기는 문제이다.

즉 갱신된 소스 인덱스의 정보를 활용하고 싶다면 소스 인덱스 갱신떄마다, enrich를 execute해주어야 한다.

문제는 enrich execute가 시간이 좀 걸리는 작업이기 때문에 소스 인덱스가 자주 갱신이 되는 상황이라면 enrich를 사용하기가 좀 곤란하다. 
enrich policy를 execute하고 반영되기 전에 새로운 데이터가 들어오면 해당 데이터는 과거 소스 데이터를 가지고 인덱싱될 것이기 때문이다. 


## 그래서 내린 결론...

그래서 내린 결론은 소스 인덱스의 변화가 잦은 경우에는 enrich processor를 쓰지 않는 것이 좋다.
내가 진행하던 프로젝트에서도 비슷한 문제가 있어서 결국 데이터 수집 단에서 아예 데이터를 denomalization해서 인덱싱하는 무식하지만 깔끔한 방법으로 수정했다.

대신 소스 인덱스의 변화가 없거나 해당 정보의 변화가 그렇게 크리티컬 하지 않은 경우에는 enrich processor를 사용하고 있다. 확실히 pipeline만 지정해주면 애초에 설정한 데이터를 elasticsearch에서 알아서 넣어주므로 이런 부분은 굉장히 편했다. 


## 참고
https://www.elastic.co/guide/en/elasticsearch/reference/current/execute-enrich-policy-api.html

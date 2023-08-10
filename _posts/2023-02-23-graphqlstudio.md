---
layout: post
title:  "graphql 스튜디오 로컬 서버 접속으로 인한 Unable to reach server문제 해결"
date:   2023-02-23
excerpt: "graphql 스튜디오 로컬 서버 접속으로 인한 Unable to reach server문제 해결"
categories: [Linux, Server]
tags: [linux,graphql]
comments: true
---

## 문제 상황

![Problem](/assets/img/2023-02-23/1.PNG)

Graphql 환경 구성을 시작하려고 하는데 graphql studio가 계속 외부 서버로 리다이렉트 되는 문제가 있었다. https://studio.apollographql.com/ 주소로 계속 리다이렉션 되는데, 내가 구성한 graphql 서버는 개발망 내부에 존재하고 있어서 외부 서버에서 요청을 할 수가 없다. 리다이렉션 없이 로컬 서버에서만 테스트를 하고 싶었다. 


## 해결방법

https://www.apollographql.com/blog/tooling/graphql-ide/how-to-use-apollo-sandbox-on-your-localhost/ 문서에 있는대로 추가적인 코드를 넣어주었다. 

```
const {
 ApolloServerPluginLandingPageProductionDefault,
 ApolloServerPluginLandingPageLocalDefault
} = require('apollo-server-core');

const server = new ApolloServer({
 ...
 plugins: [
    process.env.NODE_ENV === "production"
      ? ApolloServerPluginLandingPageProductionDefault({
          embed: true,
          graphRef: "plaid-gufzoj@current"
        })
      : ApolloServerPluginLandingPageLocalDefault({ embed: true })
 ]
});

```


### 해결된 상황
![Solved](/assets/img/2023-02-23/2.PNG)

위와 같이 로컬에서 테스트할 수 있는 Graphql Studio UI를 볼 수 있다.  
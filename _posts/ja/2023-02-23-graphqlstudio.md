---
layout: post
lang: ja
title:  "ローカルサーバーへの接続によるUnable to reach serverのGraphQL Studio問題の解決"
date:   2023-02-23
excerpt: "ローカルサーバーへの接続によるUnable to reach serverのGraphQL Studio問題の解決"
categories: [Linux, Server]
tags: [linux, graphql]
comments: true
permalink: /graphqlstudio
---

## 問題の状況

![Problem](/assets/img/2023-02-23/1.PNG)

GraphQL環境を構築しようとしたところ、GraphQL Studioが常に外部サーバーにリダイレクトされる問題が発生しました。 https://studio.apollographql.com/ に常にリダイレクトされ、私が構築したGraphQLサーバーは内部の開発ネットワークに存在しているため、外部サーバーからのリクエストを受け取ることはできません。リダイレクションなしでローカルサーバーでのみテストしたかったのです。

## 解決策

https://www.apollographql.com/blog/tooling/graphql-ide/how-to-use-apollo-sandbox-on-your-localhost/ のドキュメントにある通り、追加のコードを挿入しました。

```javascript
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

### 解決した状況

![Solved](/assets/img/2023-02-23/2.PNG)

上記のように、ローカルでテストできるGraphQL Studio UIを確認できます。
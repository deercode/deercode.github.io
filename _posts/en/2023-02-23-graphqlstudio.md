---
layout: post
lang: en
title:  "Resolution of 'Unable to reach server' issue in GraphQL Studio due to local server connection"
date:   2023-02-23
excerpt: "Resolution of 'Unable to reach server' issue in GraphQL Studio due to local server connection"
categories: [Linux, Server]
tags: [linux, graphql]
comments: true
---

## Problem Situation

![Problem](/assets/img/2023-02-23/1.PNG)

I encountered an issue while setting up a GraphQL environment where GraphQL Studio kept redirecting to an external server. It consistently redirected to https://studio.apollographql.com/, and since the GraphQL server I configured exists within an internal development network, it couldn't receive requests from an external server. I wanted to test it locally without redirection.

## Solution

I added additional code as mentioned in the document [How to Use Apollo Sandbox on Your Localhost](https://www.apollographql.com/blog/tooling/graphql-ide/how-to-use-apollo-sandbox-on-your-localhost/).

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

### Resolved Situation

![Solved](/assets/img/2023-02-23/2.PNG)

Now, as shown above, you can see the GraphQL Studio UI for local testing without redirection.
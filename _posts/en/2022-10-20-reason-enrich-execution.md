---
layout: post
lang: en
title:  "[Elasticsearch] Precautions when executing enrich policy"
date:   2022-10-20
excerpt: "Precautions when executing enrich policy"
categories: [DataEngineering, Elasticsearch]
tags: [elasticsearch]
comments: true
permalink: /reason-enrich-execution
---

## Purpose of Using Enrich

In SQL, you can use Join to combine different tables and retrieve information from two tables at once. However, Elasticsearch does not support Join between multiple indexes, and to achieve a similar effect to SQL Join, you need to denormalize the data by inserting related data at the time of input.

Since Elasticsearch version 7.5, the Enrich Processor has been introduced, which allows adding data from different indexes to newly indexed data. For example, if you store order information for a user in a specific index and detailed user information in another index, the Enrich processor can be used to add detailed information matching the user ID to the order information when it is received.

## Execution in Enrich

Many posts related to Enrich typically guide the application of enrich in the following flow:

1) Prepare the source index
2) Create an enrich policy
3) Execute the enrich policy
4) Create an ingest pipeline

When executed, the enrich processor effectively adds additional information to the indexing.

## Precautions when executing enrich

The problem arises when the content of the source index is updated. As configured with the enrich processor, if you insert data as usual after preparing, you can see that past data is appended and indexed. This issue occurs because enrich policy execution is not performed, leading to indexing with past data.

In other words, if you want to utilize the updated information of the source index, you need to execute enrich every time the source index is updated.

The challenge is that enrich execution takes some time, so if the source index is frequently updated, using enrich can be challenging. If new data comes in before the enrich policy is executed and reflected, that data will be indexed using past source data.

## So, the conclusion is...

So, the conclusion is that it is not advisable to use the enrich processor if the source index changes frequently. In a project I was working on with a similar issue, I ultimately chose a brute-force but clean method of denormalizing the data during the data collection phase for indexing.

Instead, if there is no frequent change in the source index or the change in that information is not critical, using the enrich processor is convenient. Specifying only the pipeline makes Elasticsearch automatically insert the initially configured data, which is quite convenient.

## Reference
https://www.elastic.co/guide/en/elasticsearch/reference/current/execute-enrich-policy-api.html
---
layout: post
lang: ja
title:  "[Elasticsearch] enrichポリシーの実行時の注意事項"
date:   2022-10-20
excerpt: "enrichポリシーの実行時の注意事項"
categories: [DataEngineering, Elasticsearch]
tags: [elasticsearch]
comments: true
permalink: /reason-enrich-execution
---

## enrichの利用目的

SQLでは異なるテーブルを結合（Join）して、2つのテーブルの情報を一度に取得する方法が提供されています。ただし、Elasticsearchでは異なるインデックス間のJoinは不可能であり、SQL Joinと同じ効果を得るには、データをDenormalizationして入力時に関連データを挿入する方法でのみ実現できます。

Elasticsearch 7.5以降、異なるインデックスのデータを新しくインデクシングされるデータに追加するEnrich Processorと呼ばれる機能が導入されました。たとえば、特定のインデックスにはユーザーの注文情報が保存され、別のインデックスにはユーザーの詳細情報が保存されている場合、Enrich Processorを使用すると注文情報が入力される際にユーザーIDに一致する詳細情報を追加で注文情報に結合できる機能です。

## enrichにおけるexecute

多くのEnrich関連のポストでは、通常以下のような流れでenrichを適用することをガイドしています。

1) ソースインデックスの準備
2) Enrichポリシーの作成
3) Enrichポリシーの実行
4) Ingestパイプラインの作成

実際に実行してみると、希望通りにenrichプロセッサが追加情報を付与してインデキシングしてくれます。

## enrich executeの際の注意事項

問題はソースインデックスの内容が更新されるときです。前述のようにenrichプロセッサの構成を整え、通常通りデータを挿入し始めると、過去のデータが付加されてインデキシングされることがわかります。これはenrichポリシーの実行を行わないと、過去のデータを使用してインデキシングされるためです。

つまり、更新されたソースインデックスの情報を利用したい場合は、ソースインデックスを更新するたびにenrichを実行する必要があります。

問題はenrichの実行が時間がかかる作業であるため、ソースインデックスが頻繁に更新される状況であれば、enrichを使用することがやや難しいことです。enrichポリシーを実行して反映される前に新しいデータが入ると、そのデータは過去のソースデータを使用してインデキシングされることになります。

## 結論...

したがって、ソースインデックスの変化が頻繁な場合はenrichプロセッサを使用しない方が良いです。私が進行していたプロジェクトでも類似の問題があり、最終的にはデータ収集段階でデータを完全にdenormalizationしてインデキシングする、少々無駄かもしれませんがクリーンな方法に修正しました。

代わりに、ソースインデックスの変化がないか、その情報の変化がそれほど重要でない場合は、enrichプロセッサを使用しています。確かにパイプラインを指定するだけで、elasticsearchがデータを自動的に挿入してくれるため、この部分は非常に便利でした。

## 参考
https://www.elastic.co/guide/en/elasticsearch/reference/current/execute-enrich-policy-api.html
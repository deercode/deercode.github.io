---
layout: post
lang: ja
title:  "[kubernetes] k8s クライアント構成証明書の有効期限を確認する方法"
date:   2024-01-12
excerpt: "[kubernetes] k8s クライアント構成証明書の有効期限を確認する方法"
categories: [kubernetes]
tags: [linux, kubernetes]
comments: true
---

## Kubernetes 証明書有効期限アラート
```bash
Kubernetes API サーバーへの認証に使用されるクライアント証明書が 7.0 日以内に期限切れになります。
```
もし上記のようなメッセージが k8s クラスタで表示された場合、それは kube config で指定された証明書が有効期限切れ寸前であることを示しています。

## Kubernetes 証明書有効期限の確認
#### シェル スクリプト
kube config の有効期限を確認するには、以下のシェル コマンドを使用できます：
```bash
$ cat config | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | base64 -d | openssl x509 -text -out - | grep "Not After"
>> Not After: Mar 24 06:01:12 2024 GMT
```
コマンドの説明：

1) 最初に config があるフォルダに移動します（例: .kube フォルダ）。
2) config を出力します。
3) k8s 証明書情報を含む client-certificate-data を出力します。
4) `cut -f2 -d : | tr -d ' '` を使用して証明書情報を抽出します。
5) base64 でエンコードされた内容をデコードし、OpenSSL を使用してクライアント証明書の詳細を出力します。
6) "Not After" の後に続く文字列が証明書の有効期限を表示します。

#### 1 つの config に複数のクラスタ情報がある場合は？
上記のコマンドは config に 1 つのクラスタ情報しかない場合に使用できます。1 つの config に複数のクラスタ証明書情報を管理する場合は、次のスクリプトを使用できます：
```bash
#!/bin/bash

# config ファイルのパス
CONFIG_FILE="config"

# config を抽出して処理
cat $CONFIG_FILE | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | while read -r line; do
    echo "Line: $line"
    echo "$line" | base64 -d | openssl x509 -text -out -
    echo ""
done
```
このコマンドは bash ファイルとして保存して実行する必要があります。

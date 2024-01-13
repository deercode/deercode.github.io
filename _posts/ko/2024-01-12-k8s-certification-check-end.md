---
layout: post
lang: ko
title:  "[kubernetes] k8s client config 인증서 만료일 확인하는 방법"
date:   2024-01-12
excerpt: "[kubernetes] k8s client config 인증서 만료일 확인하는 방법"
categories: [kubernetes]
tags: [linux, kubernetes]
comments: true
---

## Kubernetes certificate 인증 만료 알람
```
a client certificate used to authenticate to kubernetes apiserver is expiring in less than 7.0 days.
```
k8s 클러스터에 위와 같은 메세지가 뜨면 kube config에 명시된 인증서가 만료일이 다가오고 있다는 것이다. 

## Kubernetes certificate 인증 만료일 확인하기
#### shell script
kube config의 만료일을 확인하려면 아래 쉘명령어로 확인할 수 있다. 
```
$ cat config | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | base64 -d | openssl x509 -text -out - | grep "Not After"
>> Not After : Mar 24 06:01:12 2024 GMT
```
위 명령어를 설명하면

1) 먼저 config가 있는 폴더로 이동 (ex. .kube 폴더)
2) config 출력후
3) k8s certificate가 담겨 있는 client-certificate-data 데이터를 출력함.
4) cut -f2 -d : | tr -d ' '를 통해 인증서 정보를 가져오고
5) base64로 인코딩된 내용을 decrypt하고 이를 OpenSSL을 사용하여 클라이언트 인증서의 내용을 출력합니다.
6) Not after 이후 문자열을 출력하면 인증서의 만료일을 가져올 수 있음

#### 만약 하나의 config에 여러 클러스터 정보가 있다면?
위 명령어는 config에 하나의 클러스터 정보만 있을때 사용할 수 있고, 만약 하나의 config에 여러 클러스터 인증서 정보를 관리한다면 아래와 같이 사용할 수 있다. 
``` bash
#!/bin/bash

# config 파일 경로
CONFIG_FILE="config"

# config 추출 및 처리
cat $CONFIG_FILE | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | while read -r line; do
    echo "Line: $line"
    echo "$line" | base64 -d | openssl x509 -text -out -
    echo ""
done

```
위 명령어는 bash 파일로 만든후 실행해야 한다. 

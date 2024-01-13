---
layout: post
lang: en
title:  "[kubernetes] How to Check Expiry Date of k8s Client Config Certificates"
date:   2024-01-12
excerpt: "[kubernetes] How to Check Expiry Date of k8s Client Config Certificates"
categories: [kubernetes]
tags: [linux, kubernetes]
comments: true
---

## Kubernetes Certificate Expiry Alert
```bash
A client certificate used to authenticate to the Kubernetes API server is expiring in less than 7.0 days.
```
If you see a message like the one above on your k8s cluster, it indicates that the certificate specified in the kube config is nearing its expiration date.

## Checking Kubernetes Certificate Expiry Date
#### Shell Script
To check the expiry date of the kube config, you can use the following shell command:
```bash
$ cat config | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | base64 -d | openssl x509 -text -out - | grep "Not After"
>> Not After: Mar 24 06:01:12 2024 GMT
```
Explanation of the command:

1) First, navigate to the folder where the config is located (e.g., the .kube folder).
2) Output the config.
3) Output the client-certificate-data containing k8s certificate information.
4) Use `cut -f2 -d : | tr -d ' '` to extract certificate information.
5) Decrypt the base64-encoded content and use OpenSSL to output the details of the client certificate.
6) The string following "Not After" will show the certificate's expiration date.

#### If there are multiple cluster details in a single config?
The above command is suitable when there is only one cluster information in the config. If you manage multiple cluster certificate information in a single config, you can use the following script:
```bash
#!/bin/bash

# Config file path
CONFIG_FILE="config"

# Extract and process config
cat $CONFIG_FILE | grep client-certificate-data | cut -f2 -d : | tr -d ' ' | while read -r line; do
    echo "Line: $line"
    echo "$line" | base64 -d | openssl x509 -text -out -
    echo ""
done
```
This command should be saved as a bash file and executed.
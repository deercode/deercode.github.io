---
layout: post
lang: ja
title:  "Linuxメモリパフォーマンスモニタリング(free, psコマンドの使用方法)"
date:   2023-02-17
excerpt: "Linuxメモリパフォーマンスモニタリング"
categories: [Linux]
tags: [linux, free, du, プロセスごとのメモリ使用量, パフォーマンスモニタリング]
comments: true
---

# Linuxメモリパフォーマンスモニタリング

Linuxを頻繁に使用していますが、Linux自体のパフォーマンスを理解するのは常に難しく、分かりづらいことがありました。 Linuxサーバーを運用すると、次のような質問が頻繁に発生します。

- 現在のサーバーの利用可能なディスク容量はいくらですか？
- 現在のサーバーのディスクIOはどうですか？
- 現在、どのプロセスが最もディスクIOを使用していますか？
- 現在のシステムのメモリ使用率はどれくらいですか？
- 現在、プロセスごとのメモリ使用量はどうですか？
- 現在のネットワーク速度はどうですか？
- ネットワーク速度がどれくらいであれば十分だと判断できますか？
- どのプロセスがネットワークを最も多く消費していますか？
- ...

こうした質問に答えるためには、Googleで検索して都度コマンドを実行する必要がありました。しかし、コマンドから出力される多くの数値がどのような意味を持っているのか、正確には理解せずに「おおよそこんな感じか」と進んだことがよくありました。そこで、今回のセット休暇を記念して、Linuxの全体的なパフォーマンスを測定する方法と、各コマンドが示す意味について一度確認してみましょう。今回の投稿では、Linuxパフォーマンスモニタリングの中で`メモリ`に焦点を当てます。ディスクに関する情報については、[この投稿](https://deercode.github.io/linux_disk_monitoring/)を参照してください。


## はじめに
---
```
# cat /etc/issue
Ubuntu 18.04.4 LTS \n \l
```
以下に示すパフォーマンスモニタリングコマンドと解釈は、`Ubuntu 18.04`に基づいています。

    
      
   
## 現在のシステムはどれくらいメモリを使用していますか？

---
現在のシステムでの総メモリ使用量は、どのようにして確認できるでしょうか？ これは `free` コマンドを使用して確認できます。

```bash
# free
              total        used        free      shared  buff/cache   available
Mem:        4039172     1516096      395560       46248     2127516     2189400
Swap:             0           0           0


# free -h
              total        used        free      shared  buff/cache   available
Mem:           3.9G        1.4G        386M         45M        2.0G        2.1G
Swap:            0B          0B          0B

```

デフォルトの `free` コマンドはKB単位で表示されますが、もう少し読みやすい形式で表示したい場合は、`-h(human readable)` オプションを付けます。

|メトリクス|説明|
|----|----------------|
|total|総メモリサイズ|
|used|totalからfree、buff/cacheを引いた使用中のメモリ|
|free|totalからfree、buff/cacheを引いた使用可能なメモリ|
|shared|複数のプロセスで使用できる共有メモリ（tmpsf、ramfsなどで使用されるメモリ）|
|buff/cache|バッファとキャッシュを合算した使用中のメモリ|
|available|スワップなしで新しいプロセスに割り当て可能なメモリの推定サイズ|

### 解釈
現在、総メモリは3.9GBで、そのうち1.4GBが使用されています。現在、バッファとキャッシュ領域には約2GB保存されています。まだメモリスペースが余裕があるため、パフォーマンスのためにバッファとキャッシュ領域を多く使用していますが、将来的にはメモリ使用量が増えると、バッファ/キャッシュ領域は減少するでしょう。現在のスワップ領域は0に設定されていますが、スワップはメモリスペースが不足するときにディスクスペースを利用するためのものです。つまり、現在のシステムにはスワップが設定されていませんが、将来的にメモリ使用量が増える場合はスワップ領域の使用も検討する余地があります。

参照: [https://brunch.co.kr/@dreaminz/2](https://brunch.co.kr/@dreaminz/2)


## 現在のプロセスごとのメモリ使用量はどうなっていますか？

---

```bash
ps -aux --sort -rss
```
上記のコマンドを使用して、プロセスごとのメモリ使用量を確認できます。 `--sort -rss` オプションは、実際のメモリ使用量を基準に降順でソートします。

```bash
# ps -aux --sort -rss
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
jenkins    956  0.5 20.7 3627804 837644 ?      Sl    2022 2957:09 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/jenkins/jenkins.war --webroot=/var/
999      27540  0.1  6.9 1586708 282124 ?      Ssl   2022  98:40 mysqld
www-data 19109  0.0  1.9 345772 77016 ?        S    Jan20   1:59 apache2 -DFOREGROUND
www-data  4599  0.0  1.8 345776 76648 ?        S    Jan21   1:24 apache2 -DFOREGROUND
www-data 19111  0.0  1.7 319808 70984 ?        S    Jan20   2:01 apache2 -DFOREGROUND
www-data 10153  0.0  1.7 319808 69968 ?        S    Jan17   2:36 apache2 -DFOREGROUND
www-data 11457  0.0  1.7 319800 69512 ?        S    Jan17   2:46 apache2 -DFOREGROUND
www-data  4597  0.0  1.7 319580 69476 ?        S    Jan21   1:17 apache2 -DFOREGROUND
www-data 11462  0.0  1.6 319804 68088 ?        S    Jan17   3:00 apache2 -DFOREGROUND
www-data 18331  0.0  1.6 319508 67596 ?        S    Jan22   0:09 apache2 -DFOREGROUND
www-data 18327  0.0  1.6 319492 67308 ?        S    Jan22   0:09 apache2 -DFOREGROUND
www-data 16708  0.0  1.6 319228 65752 ?        S    Jan22   0:10 apache2 -DFOREGROUND
```

|メトリクス|説明|
|----|----------------|
|USER|プロセスのユーザー名|
|PID|プロセスID|
|%CPU|CPU使用率|
|%MEM|MEM使用率|
|VSZ|仮想メモリ使用量（KiB）|
|RSS|実際のメモリ使用量（KiB）|
|STAT|現在のプ

ロセスの状態（R:Running, S:Sleeping, i:Idle, T:Terminated）|
|TIME|合計CPU時間|
|COMMAND|実行コマンド|


### 解釈
つまり、現在のシステムで最もメモリを多く使用しているプロセスはJenkinsで、総メモリの20.7%を使用しており、実際のメモリ使用量は837644KiB（857MB）です。仮想メモリに関する情報は調査したところ、そのプロセスが最大で使用できるメモリスペースを指すようです。仮想メモリは、つまり最大で3627804KiB（3.71GB）までメモリが拡張される可能性があることを示しているようです。


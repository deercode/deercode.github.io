---
layout: post
lang: ja
title:  "[Linux] update-alternativesを使用してプログラムのバージョンを管理する"
date:   2024-01-02
excerpt: "update-alternativesを使用してプログラムのバージョンを管理する"
categories: [Linux]
tags: [linux]
comments: true
permalink: /update-alternative
---

## update-alternativesコマンド
このコマンドに初めて出会ったのは、ローカルに複数のバージョンのPHPがインストールされているとき、これを簡単に切り替える方法を探しているときでした。
`update-alternatives`コマンドは、シンボリックリンクを管理するためのLinuxプログラムです。

それでは、複数のPHPバージョンがインストールされている状態で`update-alternatives`を使用するシナリオを見てみましょう。

## update-alternativesコマンドを使用してPHPバージョンを管理する
#### 登録されたシンボリックリンクの確認
```bash
$ sudo update-alternatives --config php
update-alternatives: error: no alternatives for php
```
まず、PHPに関する設定情報があるかどうかを確認します。
現在、存在しないことがわかります。

#### シンボリックリンクの登録
```bash
sudo update-alternatives --install /usr/bin/php php /usr/bin/php7.2 1
sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.2 2
```
ローカルにPHP 7.2および8.2がインストールされた状況で、基本的な`php`コマンドをどのように管理するかを考えてみましょう。
上記のコマンドは、`/usr/bin/php`に対するシンボリックオプションを追加します。
`php7.2`および`php8.2`はそれぞれPHP 7.2およびPHP 8.2の実行ファイルのパスであり、数字1および2は優先順位を示します。

#### シンボリックリンクの確認および選択
```bash
$ sudo update-alternatives --config php
There are 2 choices for the alternative php (providing /usr/bin/php).

  Selection    Path                      Priority   Status
------------------------------------------------------------
* 0            /usr/bin/php7.2            2         auto mode
  1            /usr/bin/php8.2            1         manual mode
  2            /usr/bin/php7.2            2         manual mode
Press <enter> to keep the current choice[*], or type selection number: 1
```
このコマンドを実行すると、システムで使用可能なPHPバージョンの一覧が表示されます。各バージョンの横にある番号を入力して、デフォルトのPHPバージョンを選択できます。
1を選択すると、`php -v`コマンドを使用してバージョンが変更されることが確認できます。

```bash
$ php -v
PHP 8.2.13 (cli) (built: Dec  9 2023 00:20:40) (NTS)
Copyright (c) The PHP Group
```

上記のように、複数のバージョンのプログラムがインストールされている場合、`update-alternatives`を使用すると簡単かつ迅速にバージョンを切り替えることができます。ただし、プログラム言語のレベルで仮想環境を提供する場合、それを通じて管理する方が効果的かもしれません。

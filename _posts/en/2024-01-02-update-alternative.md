---
layout: post
lang: en
title:  "[Linux] Managing Program Versions with update-alternatives"
date:   2024-01-02
excerpt: "Managing Program Versions with update-alternatives"
categories: [Linux]
tags: [linux]
comments: true
---

## update-alternatives Command
I first came across this command when I was looking for an easy way to switch between multiple versions of PHP installed locally. The `update-alternatives` command is a Linux program that manages symbolic links.

Let's look at a scenario of using `update-alternatives` in a situation where multiple PHP versions are installed.

## Managing PHP Versions with update-alternatives Command
#### Checking registered symbolic links
```bash
$ sudo update-alternatives --config php
update-alternatives: error: no alternatives for php
```
First, check if there is any information set for PHP.
Currently, it indicates that there is none.

#### Registering symbolic links
```bash
sudo update-alternatives --install /usr/bin/php php /usr/bin/php7.2 1
sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.2 2
```
Let's consider a situation where PHP 7.2 and 8.2 are installed locally, and we want to manage the default `php` command.
The above commands add symbolic options for `/usr/bin/php`.
`php7.2` and `php8.2` are the executable paths for PHP 7.2 and PHP 8.2, respectively, and the numbers 1 and 2 represent priorities.

#### Checking and selecting symbolic links
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
Running this command displays a list of available PHP versions on the system. You can input the number next to each version to choose the default PHP version.
Selecting 1 changes the version when using the `php -v` command.

```bash
$ php -v
PHP 8.2.13 (cli) (built: Dec  9 2023 00:20:40) (NTS)
Copyright (c) The PHP Group
```

When multiple program versions are installed, `update-alternatives` allows for easy and quick management of versions. However, if the program language provides virtual environments, managing them through that method might be more effective.

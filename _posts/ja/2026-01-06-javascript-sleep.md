---
layout: post
lang: ja
title:  "[JavaScript] JavaScriptでsleepする方法"
date:   2026-01-06
excerpt: "[JavaScript] JavaScriptでsleepする方法"
categories: [javascript]
tags: [javascript]
comments: true
permalink: /javascript-sleep
---

# [JavaScript] JavaScriptでsleepする方法

---

JavaScriptでプログラムの実行を一時停止したり遅延させたい場合、`setTimeout`や`Promise`を活用してsleep機能を実装できます。この記事では、JavaScriptでsleepを実装し使用する様々な方法を学びます。

## 基本的な使用方法

JavaScriptには基本的に`sleep()`関数がありませんが、`Promise`と`setTimeout`を組み合わせて簡単に実装できます。

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("開始");
    await sleep(2000);  // 2秒待機
    console.log("2秒後");
}

main();
```

`sleep()`関数はミリ秒（ms）単位の数値を引数として受け取ります。上記の例では、`2000`で2秒間待機します。

## 様々な時間単位

JavaScriptの`setTimeout`はミリ秒単位を使用しますが、他の時間単位を使用するには計算を通じて変換できます：

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("開始");
    
    // ミリ秒単位
    await sleep(500);
    console.log("500ミリ秒後");
    
    // 秒単位（1000ms = 1秒）
    await sleep(2000);
    console.log("2秒後");
    
    // 分単位（60000ms = 1分）
    await sleep(60000);
    console.log("1分後");
    
    // 時間単位（3600000ms = 1時間）
    await sleep(3600000);
    console.log("1時間後");
}

main();
```

## 時間単位の変換

| 単位 | ミリ秒への変換 | 例 |
|------|--------------|-----|
| ミリ秒 | 1ms = 1ms | `await sleep(500)` (500ms) |
| 秒 | 1s = 1000ms | `await sleep(2000)` (2秒) |
| 分 | 1m = 60000ms | `await sleep(60000)` (1分) |
| 時間 | 1h = 3600000ms | `await sleep(3600000)` (1時間) |

## 実用的な例

### 1. 繰り返し作業の間に待機

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    for (let i = 1; i <= 5; i++) {
        console.log(`作業 ${i} 実行中...`);
        await sleep(1000);  // 1秒待機
    }
    console.log("すべての作業完了");
}

main();
```

### 2. API呼び出し間の遅延

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function callAPI() {
    console.log("API呼び出し中...");
    // API呼び出しロジック
}

async function main() {
    for (let i = 0; i < 3; i++) {
        await callAPI();
        // API呼び出し間に2秒待機（レート制限）
        await sleep(2000);
    }
}

main();
```

### 3. 複数の非同期作業を順次実行

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function task1() {
    console.log("作業 1 開始");
    await sleep(1000);
    console.log("作業 1 完了");
}

async function task2() {
    console.log("作業 2 開始");
    await sleep(1000);
    console.log("作業 2 完了");
}

async function main() {
    await task1();
    await task2();
    console.log("すべての作業完了");
}

main();
```

### 4. setTimeoutを直接使用（コールバック方式）

```javascript
console.log("開始");
setTimeout(() => {
    console.log("2秒後");
}, 2000);
```

## 注意事項

- `sleep()`関数は`async/await`と一緒に使用する必要があります。
- `setTimeout`は正確な時間を保証しません。システムスケジューラによって実際の待機時間が若干異なる場合があります。
- 非常に短い時間（1ms未満）のsleepは精度が低下する可能性があります。
- Node.jsとブラウザ環境の両方で同じように動作します。

## setTimeout vs Promiseベースのsleep

### setTimeout - コールバック方式

```javascript
console.log("開始");
setTimeout(() => {
    console.log("2秒後");
}, 2000);
```

### Promiseベースのsleep - async/await

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("開始");
    await sleep(2000);
    console.log("2秒後");
}

main();
```

`async/await`を使用すると、コードがより読みやすく保守しやすくなります。

## 実用的なヒント

### 1. ユーティリティ関数として作成

```javascript
// utils.js
export function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// 使用
import { sleep } from './utils.js';

async function main() {
    await sleep(1000);
}
```

### 2. 変数を使用した動的sleep

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    const delay = 2500;  // ミリ秒単位
    await sleep(delay);
}

main();
```

### 3. ランダム遅延（レート制限）

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function randomDelay(min, max) {
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return sleep(delay);
}

async function main() {
    // 1秒から3秒の間のランダムな時間待機
    await randomDelay(1000, 3000);
    console.log("ランダム遅延後");
}

main();
```

### 4. 条件付きsleep

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function retryWithDelay(fn, maxRetries = 3, delay = 1000) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            return await fn();
        } catch (error) {
            if (i === maxRetries - 1) throw error;
            console.log(`再試行 ${i + 1}/${maxRetries}...`);
            await sleep(delay);
        }
    }
}
```

この記事がJavaScriptでsleepを実装し使用する方法を理解するのに役立つことを願っています！


---
layout: post
lang: ko
title:  "[JavaScript] JavaScript에서 sleep 하는 방법"
date:   2026-01-06
excerpt: "[JavaScript] JavaScript에서 sleep 하는 방법"
categories: [javascript]
tags: [javascript]
comments: true
permalink: /javascript-sleep
---

# [JavaScript] JavaScript에서 sleep 하는 방법

---

JavaScript에서 프로그램 실행을 일시 중지하거나 지연시키고 싶을 때 `setTimeout`이나 `Promise`를 활용하여 sleep 기능을 구현할 수 있습니다. 이번 포스트에서는 JavaScript에서 sleep을 구현하고 사용하는 다양한 방법을 알아보겠습니다.

## 기본 사용법

JavaScript에는 기본적으로 `sleep()` 함수가 없지만, `Promise`와 `setTimeout`을 조합하여 쉽게 구현할 수 있습니다.

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("시작");
    await sleep(2000);  // 2초 대기
    console.log("2초 후");
}

main();
```

`sleep()` 함수는 밀리초(ms) 단위의 숫자를 인자로 받습니다. 위 예제에서는 `2000`으로 2초 동안 대기합니다.

## 다양한 시간 단위

JavaScript의 `setTimeout`은 밀리초 단위를 사용하지만, 다른 시간 단위를 사용하려면 계산을 통해 변환할 수 있습니다:

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("시작");
    
    // 밀리초 단위
    await sleep(500);
    console.log("500밀리초 후");
    
    // 초 단위 (1000ms = 1초)
    await sleep(2000);
    console.log("2초 후");
    
    // 분 단위 (60000ms = 1분)
    await sleep(60000);
    console.log("1분 후");
    
    // 시간 단위 (3600000ms = 1시간)
    await sleep(3600000);
    console.log("1시간 후");
}

main();
```

## 시간 단위 변환

| 단위 | 밀리초로 변환 | 예제 |
|------|-------------|------|
| 밀리초 | 1ms = 1ms | `await sleep(500)` (500ms) |
| 초 | 1s = 1000ms | `await sleep(2000)` (2초) |
| 분 | 1m = 60000ms | `await sleep(60000)` (1분) |
| 시간 | 1h = 3600000ms | `await sleep(3600000)` (1시간) |

## 실제 사용 예제

### 1. 반복 작업 사이에 대기

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    for (let i = 1; i <= 5; i++) {
        console.log(`작업 ${i} 실행 중...`);
        await sleep(1000);  // 1초 대기
    }
    console.log("모든 작업 완료");
}

main();
```

### 2. API 호출 간 지연

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function callAPI() {
    console.log("API 호출 중...");
    // API 호출 로직
}

async function main() {
    for (let i = 0; i < 3; i++) {
        await callAPI();
        // API 호출 간 2초 대기 (Rate limiting)
        await sleep(2000);
    }
}

main();
```

### 3. 여러 비동기 작업 순차 실행

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function task1() {
    console.log("작업 1 시작");
    await sleep(1000);
    console.log("작업 1 완료");
}

async function task2() {
    console.log("작업 2 시작");
    await sleep(1000);
    console.log("작업 2 완료");
}

async function main() {
    await task1();
    await task2();
    console.log("모든 작업 완료");
}

main();
```

### 4. setTimeout을 직접 사용 (콜백 방식)

```javascript
console.log("시작");
setTimeout(() => {
    console.log("2초 후");
}, 2000);
```

## 주의사항

- `sleep()` 함수는 `async/await`와 함께 사용해야 합니다.
- `setTimeout`은 정확한 시간을 보장하지 않습니다. 시스템 스케줄러에 따라 실제 대기 시간이 약간 다를 수 있습니다.
- 매우 짧은 시간(1ms 미만)의 sleep은 정확도가 떨어질 수 있습니다.
- Node.js와 브라우저 환경 모두에서 동일하게 작동합니다.

## setTimeout vs Promise 기반 sleep

### setTimeout - 콜백 방식

```javascript
console.log("시작");
setTimeout(() => {
    console.log("2초 후");
}, 2000);
```

### Promise 기반 sleep - async/await

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("시작");
    await sleep(2000);
    console.log("2초 후");
}

main();
```

`async/await`를 사용하면 코드가 더 읽기 쉽고 유지보수하기 좋습니다.

## 실용적인 팁

### 1. 유틸리티 함수로 만들기

```javascript
// utils.js
export function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// 사용
import { sleep } from './utils.js';

async function main() {
    await sleep(1000);
}
```

### 2. 변수를 사용한 동적 sleep

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    const delay = 2500;  // 밀리초 단위
    await sleep(delay);
}

main();
```

### 3. 랜덤 지연 (Rate limiting)

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function randomDelay(min, max) {
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return sleep(delay);
}

async function main() {
    // 1초에서 3초 사이의 랜덤한 시간 대기
    await randomDelay(1000, 3000);
    console.log("랜덤 지연 후");
}

main();
```

### 4. 조건부 sleep

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
            console.log(`재시도 ${i + 1}/${maxRetries}...`);
            await sleep(delay);
        }
    }
}
```

이 글이 JavaScript에서 sleep을 구현하고 사용하는 방법을 이해하는 데 도움이 되길 바랍니다!


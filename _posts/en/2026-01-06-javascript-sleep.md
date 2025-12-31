---
layout: post
lang: en
title:  "[JavaScript] How to Sleep in JavaScript"
date:   2026-01-06
excerpt: "[JavaScript] How to Sleep in JavaScript"
categories: [javascript]
tags: [javascript]
comments: true
permalink: /javascript-sleep
---

# [JavaScript] How to Sleep in JavaScript

---

When you want to pause or delay program execution in JavaScript, you can implement sleep functionality using `setTimeout` or `Promise`. In this post, we will learn various ways to implement and use sleep in JavaScript.

## Basic Usage

JavaScript doesn't have a built-in `sleep()` function, but you can easily implement it by combining `Promise` and `setTimeout`.

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("Start");
    await sleep(2000);  // Wait 2 seconds
    console.log("After 2 seconds");
}

main();
```

The `sleep()` function takes a number in milliseconds (ms) as an argument. In the example above, `2000` waits for 2 seconds.

## Various Time Units

JavaScript's `setTimeout` uses milliseconds, but you can convert other time units through calculation:

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("Start");
    
    // Milliseconds
    await sleep(500);
    console.log("After 500 milliseconds");
    
    // Seconds (1000ms = 1 second)
    await sleep(2000);
    console.log("After 2 seconds");
    
    // Minutes (60000ms = 1 minute)
    await sleep(60000);
    console.log("After 1 minute");
    
    // Hours (3600000ms = 1 hour)
    await sleep(3600000);
    console.log("After 1 hour");
}

main();
```

## Time Unit Conversion

| Unit | Conversion to Milliseconds | Example |
|------|----------------------------|---------|
| Milliseconds | 1ms = 1ms | `await sleep(500)` (500ms) |
| Seconds | 1s = 1000ms | `await sleep(2000)` (2s) |
| Minutes | 1m = 60000ms | `await sleep(60000)` (1m) |
| Hours | 1h = 3600000ms | `await sleep(3600000)` (1h) |

## Practical Examples

### 1. Waiting Between Repeated Tasks

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    for (let i = 1; i <= 5; i++) {
        console.log(`Executing task ${i}...`);
        await sleep(1000);  // Wait 1 second
    }
    console.log("All tasks completed");
}

main();
```

### 2. Delaying Between API Calls

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function callAPI() {
    console.log("Calling API...");
    // API call logic
}

async function main() {
    for (let i = 0; i < 3; i++) {
        await callAPI();
        // Wait 2 seconds between API calls (Rate limiting)
        await sleep(2000);
    }
}

main();
```

### 3. Sequential Execution of Multiple Async Tasks

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function task1() {
    console.log("Task 1 started");
    await sleep(1000);
    console.log("Task 1 completed");
}

async function task2() {
    console.log("Task 2 started");
    await sleep(1000);
    console.log("Task 2 completed");
}

async function main() {
    await task1();
    await task2();
    console.log("All tasks completed");
}

main();
```

### 4. Using setTimeout Directly (Callback Style)

```javascript
console.log("Start");
setTimeout(() => {
    console.log("After 2 seconds");
}, 2000);
```

## Important Notes

- The `sleep()` function must be used with `async/await`.
- `setTimeout` does not guarantee exact timing. The actual wait time may vary slightly depending on the system scheduler.
- Sleep for very short durations (less than 1ms) may have reduced accuracy.
- Works the same in both Node.js and browser environments.

## setTimeout vs Promise-based sleep

### setTimeout - Callback Style

```javascript
console.log("Start");
setTimeout(() => {
    console.log("After 2 seconds");
}, 2000);
```

### Promise-based sleep - async/await

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    console.log("Start");
    await sleep(2000);
    console.log("After 2 seconds");
}

main();
```

Using `async/await` makes the code more readable and maintainable.

## Practical Tips

### 1. Creating a Utility Function

```javascript
// utils.js
export function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Usage
import { sleep } from './utils.js';

async function main() {
    await sleep(1000);
}
```

### 2. Dynamic Sleep Using Variables

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    const delay = 2500;  // In milliseconds
    await sleep(delay);
}

main();
```

### 3. Random Delay (Rate Limiting)

```javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function randomDelay(min, max) {
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return sleep(delay);
}

async function main() {
    // Wait for a random time between 1 and 3 seconds
    await randomDelay(1000, 3000);
    console.log("After random delay");
}

main();
```

### 4. Conditional Sleep

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
            console.log(`Retry ${i + 1}/${maxRetries}...`);
            await sleep(delay);
        }
    }
}
```

I hope this post helps you understand how to implement and use sleep in JavaScript!


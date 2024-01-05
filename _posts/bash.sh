#!/bin/bash

# 특정 폴더의 모든 md 파일에 대해 반복
for file in ./ko/*.md; do
    # sed 명령어를 사용하여 lang:ko 라인 추가
    sed -i '/^title:/i\lang: ko' "$file"
done

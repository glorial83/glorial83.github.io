---
title: "Codelabs View 추가"
categories: devops
tags: codelab
last_modified_at: 2024-09-03T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 1. 폴더 생성

`\site\app\views`하위에 임의의 폴더를 생성한다

![folder](/images/2024-09-03-devops-Codelabs-6-view/2024-09-09-15-04-16.png)

## 2. view.json 생성

```json
{
  "title": "Sample", //제목
  "description": "샘플입니다", //설명
  "categories": ["sample"], //보여줄 카테고리
  "tags": ["react", "javascript"], //보여줄 태그
  "exclude": [], //제외할 태그
  "logoUrl": "/default/logo.png", //기본로고
  "sort": "mainCategory"
}
```

## 3. 조회

추가한 view를 Event로 선택할 수 있다

![result](/images/2024-09-03-devops-Codelabs-6-view/2024-09-09-16-03-33.png)

---
title: "Codelabs 문서 작성하기"
categories: devops
tags: codelab
last_modified_at: 2024-08-28T11:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 1. claat 설치

    go install github.com/googlecodelabs/tools/claat@latest

    # 설치경로
    C:\Users\사용자\go\pkg\mod\github.com\googlecodelabs\tools\claat@v0.0.0-20240220115335-873fe39d02dc

## 2. Codelab example doc 사본저장

[https://docs.google.com/document/d/1E6XMcdTexh5O8JwGy42SY3Ehzi8gOfUGiqTiUX6N04o](https://docs.google.com/document/d/1E6XMcdTexh5O8JwGy42SY3Ehzi8gOfUGiqTiUX6N04o)

## 3. doc 사본의 id를 사용해 Codelab 예제 생성

![docid](/images/2024-08-28-devops-Codelabs-manage/2024-08-28-16-39-51.png)

    cd site
    claat export 10yxMNK2Uo4_zCV9_fXfA7xNmz7litTevr9bVzDj2W00

## 4. `your-first-app` 폴더가 생성 된다

![your-first-app](/images/2024-08-28-devops-Codelabs-manage/2024-08-28-16-41-18.png)

## 5. claat 서버 실행

    cd site
    claat serve

![claat-serve](/images/2024-08-28-devops-Codelabs-manage/2024-08-28-16-44-30.png)

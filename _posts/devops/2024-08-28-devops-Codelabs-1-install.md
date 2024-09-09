---
title: "Self-Hosted Codelabs 만들기"
categories: devops
tags: codelab
last_modified_at: 2024-08-28T09:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 구동환경

_[excellent tutorial](https://medium.com/@zarinlo/publish-technical-tutorials-in-google-codelab-format-b07ef76972cd) 을 참고해서 진행했습니다._

- Go language
- Node.js v10+ and npm
- claat (open source command line tool maintained by Google)

## GO 설치

1.  https://golang.org/dl/ 접속 후 zip 다운로드

    ![GO](/images/2024-08-28-devops-Codelabs/2024-08-28-13-00-04.png)

2.  압축해제 후 환경설정 등록

    ![GOROOT](/images/2024-08-28-devops-Codelabs/2024-08-28-14-55-19.png)

    ![GOPATH](/images/2024-08-28-devops-Codelabs/2024-08-28-14-57-08.png)

    ![GOENV](/images/2024-08-28-devops-Codelabs/2024-08-28-14-59-47.png)

         #환경변수 확인
         go env

## Codelabs Git Repository 클론

```bash
git clone https://github.com/googlecodelabs/tools
```

## Dependencies 설치

```bash
cd site
npm install
npm install -g gulp-cli
npm install gulp
```

### Node version 오류

1.  NVM 설치

    [https://github.com/coreybutler/nvm-windows/releases](https://github.com/coreybutler/nvm-windows/releases) 에 접속

2.  Node 추가 설치

        nvm install 18.12.1
        nvm use 18.12.1

### Python2 경로 오류

1. Python2 설치

   [https://www.python.org/downloads/release/python-2718/](https://www.python.org/downloads/release/python-2718/)

2. Python.exe를 Python2.exe로 변경

   ![python2](/images/2024-08-28-devops-Codelabs/2024-08-28-14-05-58.png)

3. Python2 환경변수 등록

   ![python2path](/images/2024-08-28-devops-Codelabs/2024-08-28-14-07-20.png)

4. ( _선택_ ) Python3가 있다면 Python.exe를 Python3.exe로 변경

   ![python3path](/images/2024-08-28-devops-Codelabs/2024-08-28-14-09-06.png)

## Codelabs 실행(관리자권한)

    cd site
    gulp serve

    Webserver started at http://localhost:8000

---
title: "Minimal mistakes 테마를 이용해 github.io 블로그 만들기"
categories: blog
tags: blog
last_modified_at: 2018-07-01T13:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 블로그 개설이유

> 진짜 엄청 기억력이 단순해져서 기록용으로 만들게 되었습니다.  
> 예전엔 티스토리를 이용했었는데 아이를 낳고 점차 개인시간이 줄어들면서 어느새  
> 게을러지기 시작하더군요.  
> 사실 작년부터 만들어 놓았는데 이번에 다시 테마도 바꾸고 새롭게 시작하려 합니다.

## 1. GitHub 회원가입

먼저 GitHub <https://github.com> 에 접속 후 아래 그림과 같이 `Sign Up` 버튼을 클릭하여 회원가입을 진행합니다.  
Username, E-mail, Password 등 간단한 정보를 입력하면 됩니다.

![그림1](/images/2020-09-18-11-42-47.png)

## 2. Repository 생성

우측 상단의 `+` 클릭 후 New Repository를 클릭합니다.

![그림2](/images/2020-09-18-11-51-37.png)

`Repository name`에 아이디.github.io를 입력하고 `Create repository` 를 클릭합니다.

![그림3](/images/2020-09-18-11-57-36.png)

## 3. GitKraken 설치

Repository를 관리 할 수 있는 툴입니다. 명령어를 몰라도 되니 저는 간단한 작업은 이걸로 진행합니다.  
<https://www.gitkraken.com/> 에서 다운로드하여 설치합니다.  
설치 후에는 GitKraken을 실행하여 GitHub 계정연동하면 간단하게 회원가입이 끝납니다.

![그림4](/images/2020-09-18-12-07-19.png)

## 4. Repository Clone

Clone a repo 를 선택합니다.

![그림5](/images/2020-09-18-12-13-33.png)

`Where clone to`에 적당한 경로를 지정한 뒤  
아까 만들어 두었던 Repository의 URL(https://github.com/아이디/아이디.github.io.git)을 입력합니다.  
`Clone the repo! `를 클릭하면 됩니다.

![그림6](/images/2020-09-18-12-17-58.png)

## 5. Minimal mistakes Theme 다운로드

<https://github.com/mmistakes/minimal-mistakes> 사이트로 이동하여 Code -> Download ZIP을 클릭합니다.

![그림7](/images/2020-09-18-12-21-36.png)

다운로드 한 파일을 GitKraken에서 지정했던 경로에 압축해제합니다.  
중복파일은 덮어씌우기 합니다.

![그림8](/images/2020-09-18-12-25-22.png)

## 6. Ruby 설치

<https://rubyinstaller.org/downloads/> 로 이동하여 설치파일을 다운로드합니다.

![그림9](/images/2020-09-18-12-30-20.png)

세가지 모두 체크 합니다.

![그림10](/images/2020-09-18-12-33-44.png)

## 7. VSCode 설치

<https://code.visualstudio.com/download> 로 이동하여 vscode를 설치해줍니다.

## 8. Jekyll 설치

다시 한 번 GitKraken에서 지정했던 경로로 이동하여 탑색기 빈공간 우클릭 후 Code로 열기를 클릭합니다.

![그림11](/images/2020-09-18-12-41-46.png)

VSCode의 Terminal을 열어 준 다음 아래 명령어를 입력합니다.

```ruby
  gem install jekyll bundle
```

## 9. Gemfile 수정

아래 그림처럼 Gemfile을 열어 다음 명령어를 삽입합니다.

```bash
  gem "minimal-mistakes-jekyll"
```

![그림12](/images/2020-09-18-12-48-47.png)

![그림13](/images/2020-09-18-12-50-55.png)

Terminal에서 아래 명령어를 입력합니다.

```bash
  bundle
```

## 10. Jekyll 서버 실행

Github에 push하기 전 로컬서버에서 확인 할 수 있습니다.  
Terminal 창에서 아래 명령어를 입력하면 서버가 실행됩니다.  
<http://127.0.0.1:4000> 이 기본 URL입니다.

```bash
  jekyll serve
```

![그림14](/images/2020-09-18-13-03-42.png)

## 11. \_config.yml 수정

테마를 지정할 수 있습니다.

```yaml
minimal_mistakes_skin: "dark" # "air", "aqua", "contrast", "dark", "dirt", "neon", "mint", "plum", "sunrise"
```

사이트에 기본 설정입니다.

```yaml
locale: "ko-KR" #로케일
title: "머리나쁜 개발자 블로그" #블로그 메인 제목
name: "glorial" #이름
url: "https://glorial83.github.io" #블로그 URL
repository: glorial83/glorial83.github.io # GitHub 아이디/Repository이름
```

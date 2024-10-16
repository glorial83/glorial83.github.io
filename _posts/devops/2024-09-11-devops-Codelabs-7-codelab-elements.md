---
title: "Codelabs Elements 커스터마이징"
categories: devops
tags: codelab
last_modified_at: 2024-09-11T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

> codelab의 markdown(또는 google doc)을 claat를 통해 html로 변환해야 한다  
> 변환된 html의 주요 영역은 커스텀태그(google-codelab-about, google-codelab-step 등)으로 작성되어진다  
> 그리고 커스텀태그의 실제 구현부는 codelab-elements에 존재한다  
> codelab-elements의 구성요소는 다음과 같다
>
> > google-codelab #공통  
> > google-codelab-about #작성정보  
> > google-codelab-analytics  
> > google-codelab-index  
> > google-codelab-step #단계  
> > google-codelab-survey #설문조사
>
> `codelab-elements`는 아래 기술한 내용에 따라 js와 css로 빌드된다  
> 그러므로 주요 영역을 수정할 때는 **해당 구성요소의 js,scss,soy파일을 먼저 수정** 해야 한다

## 주요 커스터마이징

- codelab의 타이틀 언더바 제거
  - google_codelab.scss : google-codelab #codelab-title h1 a:hover
- material-icons의 가로 정렬
  - google_codelab.scss : google-codelab .metadata .material-icons
- 주요 문구의 한글화
  - google_codelab.soy : report a bug
  - google_codelab.soy : min left, mins left
  - google_codelab_about.soy : About this codelab, Written by
- 기본 텍스트 색상
  - index.scss : body
  - google_codelab_step.scss : google-codelab-step h2.step-title

## bazelisk 설치

```bash
C:\> choco install bazelisk
```

![choco-bazelisk](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-11-16-53-51.png)

## codelab\\.bazelversion 파일생성

```
0.18.1
```

## msys2 설치

```bash
C:\>choco install msys2
```

![choco-msys2](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-11-17-19-20.png)

## BAZEL_SH 사용자변수 생성

![BAZEL_SH](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-11-17-21-51.png)

## google_codelab_analytics.js 원복

왜인지 모르겠으나 빌드 시 오류가 발생한다.

`C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14.16.27023\include` 에

[getopt.h](https://stackoverflow.com/questions/35242826/cannot-open-include-file-getopt-h)를 넣어줬지만 계속해서 다른 오류가 발생했다.

Github의 [예전 소스](https://github.com/googlecodelabs/tools/blob/b2931352b95c6a4d8d70c47b6c0bdc57a2d7c0c9/codelab-elements/google-codelab-analytics/google_codelab_analytics.js)로 원복해서 원인을 제거했다.

## 커스터마이징

### codelab의 타이틀 언더바 제거

google_codelab.scss : google-codelab #codelab-title h1 a:hover

```css
google-codelab #codelab-title h1 a:focus,
google-codelab #codelab-title h1 a:hover {
  color: #212121;
  /* text-decoration: underline; */
  text-decoration: none;
}
```

### material-icons의 가로 정렬

google_codelab.scss : google-codelab .metadata .material-icons

```css
google-codelab .metadata .material-icons {
  vertical-align: bottom;
}
```

### 주요 문구의 한글화

google_codelab.soy : report a bug

```html
<div class="metadata">
  <a {if $feedback}target="_blank" href="{$feedback}"{else}href="#" id="codelab-feedback"{/if}>
    <i class="material-icons">bug_report</i> {msg desc="Button that the user can click to report
        an bug or error."}
      오류 신고
    {/msg}
  </a>
</div>
```

google_codelab.soy : min left, mins left

```html
<div
  class="time-remaining"
  tabindex="0"
  role="timer"
  title="남은 예상 시간: {$time}분"
>
  <i class="material-icons">access_time</i>
  {$time}분 남음
</div>
```

google_codelab_about.soy : About this codelab, Written by

```html
<div class="about-card">
  <h2 class="title">
    {msg desc="Text explaining that this card is about this codelab"} 이 Codelab
    정보 {/msg}
  </h2>

  <div class="authors">
    <i class="material-icons">account_circle</i>
    {if $authors} {msg desc="Tells who is the author of the document"}작성자:
    {$authors}{/msg} {else} {msg desc="Says that the document was written by a
    Google employee"} Written by a Googler {/msg} {/if}
  </div>
</div>
```

### 기본 텍스트 색상

index.scss : body

```css
body {
  font-family: "Roboto", sans-serif;
  transition: opacity ease-in 0.2s;
  color: #4e5256;
}
```

google_codelab_step.scss : google-codelab-step h2.step-title

```css
google-codelab-step h2.step-title {
  font-family: "Google Sans", Arial, sans-serif !important;
  font-size: 28px !important;
  font-weight: 400 !important;
  line-height: 1em !important;
  margin: 0 0 30px !important;
  color: #3c4043;
}
```

### google_codelab.js 파일의 build 오류

@suppress 처리

```css
/** @const {string}
 * @suppress {unusedLocalVariables}
 */
const DONT_SET_HISTORY_ATTR = 'dsh';
```

- [@suppress-annotations](https://github.com/google/closure-compiler/wiki/@suppress-annotations)

## build

codelab\codelab-elements> bazel build :all

## Generate 결과

```
cd bazel-genfiles\codelab-elements

codelab-elements.css
codelab-elements.js
codelab-index.css
codelab-index.js
```

![bazel-generate](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-11-18-46.png)

## 파일 이동

site\app\elements\codelab-elements 로 css와 js를 덮어씌운다

## 😥 추가작업

하지만!!! 이런다고해서 끝이 아니다  
기본적으로 사용하는 `template.html`에서 `codelab-elements`의 css와 js를 [https://storage.googleapis.com](https://storage.googleapis.com) 에서 참조하기 때문이다  
그렇기 때문에 우리는 아래와 같은 단계를 거쳐 수정된 CSS를 사용하도록 처리해야한다

- `template.html` 에서 사용하는 css와 js를 `site/app/elements/codelab-elements` 하위의 것으로 교체
- `claat` 컴파일
- `claat export 실행`

### 1. `template.html` 수정

[Codelabs 문서 작성하기]({% link _posts/devops/2024-08-28-devops-Codelabs-2-manage.md %})에서 설치했던 go의 claat의 render 폴더로 이동한다

![render](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-14-12-04.png)

`template.html`을 수정한다

{% highlight html%}
{% raw %}

<html>
  <head>
    ... 중략 ...
    <!-- <link rel="stylesheet" href="{{.Prefix}}/claat-public/codelab-elements.css"> -->
    <link
      rel="stylesheet"
      href="/elements/codelab-elements/codelab-elements.css"
    />
  </head>
  <body>
    ... 중략 ...
    <script src="{{.Prefix}}/claat-public/native-shim.js"></script>
    <script src="{{.Prefix}}/claat-public/custom-elements.min.js"></script>
    <script src="{{.Prefix}}/claat-public/prettify.js"></script>
    <!-- <script src="{{.Prefix}}/claat-public/codelab-elements.js"></script> -->
    <script src="/elements/codelab-elements/codelab-elements.js"></script>
    <script src="//support.google.com/inapp/api.js"></script>
  </body>
</html>
{% endraw %}
{% endhighlight %}

### 2. `claat` 컴파일

> Access denied 오류가 나온다면 폴더의 읽기전용을 해제한다

윈도우에서 실행 한다면 `Makefile`의 리눅스 명령어가 오류를 일으키므로 아래처럼 VERSION을 수정하자

```bash
#SHA     := $(shell git rev-parse --short HEAD)
#DATE    := $(shell TZ=UTC date +%FT%T)Z
#VERSION := $(shell cat VERSION)-$(DATE)-$(SHA)
VERSION := $(shell type VERSION)
```

명령프롬프트창에서 `make`를 실행한다

```bash
C:\...\claat@v0.0.0-20240220115335-873fe39d02dc> make
go build -o bin/claat -ldflags "-X main.version=2.2.5" # 실행결과
```

### 3. `claat` 교체

새롭게 만들어진 `claat`를 `claat.exe`로 이름을 변경한다

![claat-new](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-14-42-14.png)

`claat.exe`를 `%GOPATH%\bin`으로 이동한다

> GOPATH C:\users\사용자\go

![go-home](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-14-44-12.png)

### 4. claat export 실행 하여 테스트

```bash
claat export 테스트.md
```

이렇게 정상적으로 생성된걸 확인 할 수 있다

![result](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-16-19-33.png)

## ✨ about 추가

`template.html` 을 아래처럼 수정하면 about을 확인 할 수 있다

{% highlight html%}
{% raw %}
<google-codelab-step label="{{ .Title }}" duration="{{ .Duration.Minutes }}">

<!-- about 추가 -->

{{if eq $i 0}}
<google-codelab-about codelab-title="{{$.Meta.Title}}" authors="{{$.Meta.Authors}}"> </google-codelab-about>
{{end}}

<!-- about 추가 -->

{{.Content | renderHTML $.Context}}
</google-codelab-step>
{% endraw %}
{% endhighlight %}

![about-result](/images/2024-09-11-devops-Codelabs-7-codelab-elements/2024-09-12-16-23-57.png)

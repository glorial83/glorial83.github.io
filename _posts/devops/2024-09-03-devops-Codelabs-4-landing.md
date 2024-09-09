---
title: "Codelabs 랜딩페이지 편집"
categories: devops
tags: codelab
last_modified_at: 2024-09-03T10:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 랜딩페이지 view.json 수정

`/site/app/views/default/view.json` 을 편집

```json
{
  "title": "Codelabs", // 사이트 제목
  "description": "Codelabs provide a guided", //사이트 설명
  "tags": [],
  "categories": [],
  "exclude": ["^lang-.*"],
  "logoUrl": "/images/logo.png", //사이트 로고
  "toolbarBgColor": "#37474F", //메뉴 배경 색
  "sort": "mainCategory",
  "pins": []
}
```

## 로고 교체

`/site/app/images/logo.png`를 교체

## 랜딩페이지 수정

`/site/app/views/default/index.html` 을 편집하여 자기만의 사이트를 구성할 수 있다

### 언어 수정

`en`을 `ko`로 변경한다

```html
<html lang="ko"></html>
```

### Google Analystics 제거

아래 구문을 제거한다

```html
<link rel="preconnect" href="https://www.google-analytics.com" />

<script>
  window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
  ga('create', '{{ga}}', 'auto');
  ga('send', 'pageview');
  {% if view.ga %}
  ga('create', '{{view.ga}}', 'auto', { name: 'view' });
  ga('view.send', 'pageview');
  {% endif %}
</script>
<script async src="https://www.google-analytics.com/analytics.js"></script>
```

### Header 수정

나는 불필요한 설명은 제거했다

변경 전
{% highlight html%}
{% raw %}

<header id="banner"  {% if view.id != 'default' -%}down{%- else %}down$="[[_toBoolean(selectedFilter)]]"{%- endif %}>
  <div class="site-width">
    {% if view.id == 'default' %}
    <h2 class="banner-title">Welcome to Codelabs!</h2>
    <div class="banner-description"
          data-filter-selected$="[[_toBoolean(selectedFilter)]]">
      <p class="banner-info">
        Codelabs provide a guided, tutorial, hands-on
        coding experience. Most codelabs will step you through the process
        of building a small application, or adding a new feature to an
        existing application.
        <br>
        <a href="https://github.com/googlecodelabs/tools">Codelab tools on GitHub</a>
      </p>
    {%- else -%}
      <div class="banner-description">
        <img id="logo" src="{{view.logoUrl}}" alt="Event logo">
        <div class="banner-meta">
          <h3>{{view.title}}</h3>
          {% if view.description -%}
            <p>{{view.description}}</p>
          {%- endif %}
        </div>
    {%- endif %}
      </div>
  </div>
</header>
{% endraw %}
{% endhighlight %}

변경 후
{% highlight html%}
{% raw %}

<header id="banner"  {% if view.id != 'default' -%}down{%- else %}down$="[[_toBoolean(selectedFilter)]]"{%- endif %}>
  <div class="site-width">
    <div class="banner-description">
      <div class="banner-meta">
        <h1>{{view.title}}</h1>
      </div>
    </div>
  </div>
</header>
{% endraw %}
{% endhighlight %}

### Main view filter 활성화

default view일 때만 활성화되는 filter를 항상 나오게 변경했다

변경 전
{% highlight html%}
{% raw %}
{% if view.id == 'default' && views|length > 1 %}
<paper-dropdown-menu label="Choose an event" class="dropdown-filter" no-label-float noink  no-animations>
...중략...
</paper-dropdown-menu>
{% endif %}
{% endraw %}
{% endhighlight %}

변경 후
{% highlight html%}
{% raw %}
{% if views|length > 1 %}
<paper-dropdown-menu label="Choose an event" class="dropdown-filter" no-label-float noink  no-animations>
...중략...
</paper-dropdown-menu>
{% endif %}
{% endraw %}
{% endhighlight %}

### Footer 제거

불필요한 영역을 제거했다

```html
<footer id="footer"></footer>
```

### Address 수정

주소와 연락처를 수정했다

```html
<div class="footerbar">
  <div class="site-width layout horizontal center justified">
    <span>
      서울특별시 &nbsp; | &nbsp;대표이사 : 000&nbsp; | &nbsp;사업자등록번호 :
      000-87-00000&nbsp; | &nbsp;대표번호 : 02-000-0000&nbsp; | &nbsp;Fax :
      02-000-0000<br />
      COPYRIGHTⓒ 00000 CORP. ALL RIGHTS RESERVED
    </span>
  </div>
</div>
```

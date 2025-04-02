---
title: "Ruby 업그레이드"
categories: blog
tags: blog
last_modified_at: 2025-04-01T13:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 오래된 Ruby를 업그레이드 하자

> 다른 테마로 변경하거나 요즘 테스트 하고 있는 `Docusaurus`를 해보려 하는데 Ruby 버전이 너무 오래돼서 실행이 되지 않았다.  
> 무턱대고 버전을 올렸다간 문제가 생길것이 뻔히 보였지만 해보았다.

## 1. Ruby 설치

대체적으로 지난번 글과 비슷하다.

전에는 못봤던것 같은데 `1,2,3`을 입력했었는데 지나고 보니 `1,3`만 입력해도 될것 같다.

![ruby-1](/images/2025-04-01-blog-Ruby-upgrade/2025-04-02-10-45-36.png)

명령 프롬프트에서도 버전이 변경된 걸 확인해 보았다.

![ruby-2](/images/2025-04-01-blog-Ruby-upgrade/2025-04-02-10-47-53.png)

## 2. Bundle Update

아니나 다를까 구동을 했더니 `could not find xxx`오류가 발생했다.

`bundle update` 명령어를 입력해주고 다시 구동했더니 오류가 사라졌다.

```bash
  bundle update
```

## 3. 경고 발생

구동은 잘 되었는데 무수히 많은 Deprecation 경고가 떴다!!!

`minimal-mistakes` jekyll 테마를 업그레이드 해야 할 것 같았지만 과감히 무시했다.

왜냐하면 나는 `Docusaurus`로 갈아탈꺼니까😁

![ruby-3](/images/2025-04-01-blog-Ruby-upgrade/2025-04-02-11-11-15.png)

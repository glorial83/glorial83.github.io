# gem jekyll 설치

```
gem "minimal-mistakes-jekyll"
```

# gem plug-in 삭제

```
gem uninstall -aIx
```

# bundler 설치

```
gem install bundler -> bundle
```

# bundler를 이용한 plug-in 설치

```
gem "minimal-mistakes-jekyll"
bundle
theme: minimal-mistakes-jekyll

bundle update
gem install jekyll jekyll-gist jekyll-sitemap jekyll-seo-tag
```

# uglyfy-js \_main.js 난독화

npm install uglify-js
npm run uglify && npm run add-banner

# glorial83.github.io

아래 내용 확인해서 변경하기

```
category_archive:
type: liquid
path: /categories/
tag_archive:
type: liquid
path: /tags/
```

- https://imreplay.com/blogging/minimal-mistakes-%ED%85%8C%EB%A7%88%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%B4-githubio-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0/
- https://theorydb.github.io/tag/dev-statisticsr/
- https://honbabzone.com/jekyll/start-gitHubBlog/
- https://wormwlrm.github.io/2018/07/13/How-to-set-Github-and-Jekyll-environment-on-Windows.html
- https://ansohxxn.github.io/blog/jekyll-directory-structure/#site-nav
- 포스트 링크 https://jekyllrb.com/docs/liquid/tags/

# 테스트

```
jekyll serve
```

# 포스트 내 링크

```
[랜딩페이지 수정]({% link _posts/devops/2024-09-03-devops-Codelabs-5-categories.md %}#랜딩페이지-수정)
[Codelabs 문서 작성하기]({% link _posts/devops/2024-08-28-devops-Codelabs-2-manage.md %})
[시스템구조](#-시스템구조)
```

---
title: "Codelabs 배포"
categories: devops
tags: codelab
last_modified_at: 2024-09-01T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 배포용 소스로 로컬테스트

    #./site
    gulp serve:dist

- [https://github.com/googlecodelabs/tools/tree/main/site#development](https://github.com/googlecodelabs/tools/tree/main/site#development)

### 권한 오류

아래 처럼 오류가 난다면....

```
EPERM: operation not permitted, symlink
```

VSCode를 관리자 권한으로 실행 하면 된다

![runas-admin](/images/2024-08-28-devops-Codelabs-deploy/2024-09-03-11-14-00.png)

## 배포용 소스 생성

    cd site

    #./site/dist 폴더로 배포용 소스 빌드 됨
    gulp dist

    #기본 URL을 지정
    gulp dist --base-url=https://test.github.io

- [https://github.com/googlecodelabs/tools/tree/main/site#deploy-to-staging](https://github.com/googlecodelabs/tools/tree/main/site#deploy-to-staging)

- [https://github.com/googlecodelabs/tools/blob/main/site/README.md#options](https://github.com/googlecodelabs/tools/blob/main/site/README.md#options)

## `gulp:serve`와 `gulp serve:dist`의 결과가 다르게 나올 경우

### dist 옵션 조정 : browser

`./site/tasks/helpers/opts.js`

    #수정 전
    exports.postcss = () => {
      return [
        autoprefixer({
          browsers: [
            'ie >= 10',
            'ie_mob >= 10',
            'ff >= 30',
            'chrome >= 34',
            'safari >= 7',
            'opera >= 23',
            'ios >= 7.1',
            'android >= 4.4',
            'bb >= 10',
          ],

    #수정 후
    exports.postcss = () => {
      return [
        autoprefixer({
          overrideBrowserslist: [
            "defaults and fully supports es6-module",
            "maintained node versions"
          ],

### dist 옵션 조정 : minify

`site/gulpfile.js` 일부 주석

😭minify:html을 수행하면 압축하면서 소스가 망가진다

    gulp.task('minify', gulp.parallel(
      'minify:css',
      //'minify:html',
      //'minify:js',
    ));

## 배포대상 추출

1. dist 폴더(codelabs제외) 전체를 root로

   ![dist](/images/2024-08-28-devops-Codelabs-deploy/2024-09-03-12-04-57.png)

2. site/{view} 를 codelabs폴더로 복사

   ![view](/images/2024-08-28-devops-Codelabs-deploy/2024-09-03-12-08-12.png)

3. 결과물

   ```
   .
   ├── bower_components
   │   ├── google-codelab-elements
   │   ├── google-prettify
   │   │   └── src
   │   └── webcomponentsjs
   ├── codelabs
   │   └── your-first-pwapp
   │       └── img
   ├── default
   ├── elements
   │   └── codelab-elements
   ├── images
   │   ├── favicons
   │   └── icons
   ├── scripts
   ├── styles
   └── vslive
   ```

## 배포결과

![github-io](/images/2024-08-28-devops-Codelabs-deploy/2024-09-03-12-25-35.png)

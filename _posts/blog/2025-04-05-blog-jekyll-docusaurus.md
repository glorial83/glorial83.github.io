---
title: "Jekyll & Docusaurus 멀티모듈 구성"
categories: blog
tags: blog jekyll docusaurus node workspaces
last_modified_at: 2025-04-05T13:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## my-docs-project, my-jekyll-project 생성

## 기존 블로그용 파일을 모두 `my-jekyll-project` 폴더로 이동

단, `node_modules`는 삭제하고 `.github, .vscode, .editorconfig, .gitattributes, .gitignore` 제외한다.

![folder](/images/2025-04-05-blog-jekyll-docusaurus/2025-04-02-14-04-17.png)

## root 폴더에서 package.json 생성

```bash
D:\projects\git\blog-test>npm init -y
Wrote to D:\projects\git\blog-test\package.json:

{
  "name": "blog-test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "git+https://take-glorial@github.com/take-glorial/take-glorial.github.io.git"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/take-glorial/take-glorial.github.io/issues"
  },
  "homepage": "https://github.com/take-glorial/take-glorial.github.io#readme"
}
```

## workspaces 등록

```json
{
  "name": "blog-test",
  "private": true,
  "workspaces": [
    "my-docs-project",
    "my-jekyll-project"
  ],
  ...
}
```

## 의존성 설치

의존성을 설치하기 위해 아래 명령어를 실행한다.

```bash
npm i
```

실행 후에 확인 해 보면 node_modules가 root폴더에 생성된 것을 확인 할 수 있다.

![node-modules](/images/2025-04-05-blog-jekyll-docusaurus/2025-04-02-14-05-25.png)

## jekyll 빌드오류 해결

jekyll프로젝트를 빌드해본다.

```bash
cd my-jekyll-project && npm run build
```

빌드를 하고 나면 css 빌드 중에 오류가 발생한다.

이 오류를 해결하지 않으면 `production`빌드 시 또 다른 오류가 발생한다.

```bash
[css] Error during PurgeCSS process: TypeError: Cannot read properties of undefined (reading 'css')
[css]     at D:\projects\git\blog-test\my-jekyll-project\purgecss.js:23:45
[css] npm run build:css exited with code 0
```

- production 빌드 중 오류

  ```bash
  Error: Can't find stylesheet to import.
    ╷
  1 │ @use 'vendors/bootstrap';
    │ ^^^^^^^^^^^^^^^^^^^^^^^^
    ╵
    main.bundle.scss 1:1
  ```

원인은 `purgecss.js` 파일의 `bootstrap.min.css` 경로를 잘못 가져오고 있었기 때문이다.

나는 멀티모듈 구조를 채택했기 때문에 root에서 node_modules를 갖고 있는데 root가 아닌 곳에서 찾고 있었기에 오류가 발생했던 것이다.

다음과 같이 수정해준다.

```javascript
const fs = require("fs").promises;
const { PurgeCSS } = require("purgecss");
const DIST_PATH = "_sass/vendors";
const output = `${DIST_PATH}/_bootstrap.scss`;

const config = {
  content: ["_includes/**/*.html", "_layouts/**/*.html", "_javascript/**/*.js"],
  css: ["../node_modules/bootstrap/dist/css/bootstrap.min.css"], // 이 부분을 수정해준다
  keyframes: true,
  variables: true,
  // The `safelist` should be changed appropriately for future development
  safelist: {
    standard: [/^collaps/, /^w-/, "shadow", "border", "kbd"],
    greedy: [/^col-/, /tooltip/],
  },
};
```

## Docusaurus 설치

루트로 이동하여 설치한다.
이미 디렉토리가 존재한다면 과감히 삭제 후 진행한다.

```bash
npx create-docusaurus@latest my-docs-project classic
```

## github workflow

### Docusaurus docusaurus.config.js 수정

xxx.github.io 에 접속 했을 땐 jekyll 사이트가 뜨고

xxx.github.io/document 에 접속 했을 땐 docusaurus 사이트가 뜨게 하려 한다.

따라서 `DOCU_ENV` 환경변수를 사용할 예정이고

`production`여부에 따라 `baseUrl`을 분기처리 한다

```javascript
import { themes as prismThemes } from "prism-react-renderer";

const isProd = process.env.DOCU_ENV === "production";

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "My Site",
  tagline: "Dinosaurs are cool",
  favicon: "img/favicon.ico",

  // Set the production url of your site here
  url: "https://your-docusaurus-site.example.com",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: isProd ? "/document/" : "/",

  // 중략
};
```

### workflow yml 생성

예제로 들어있던 ./github/workflows/starter/pages-deploy.yml을 ./github/workflows/jekyll.yml 로 덮어 씌우고

아래 절차대로 스크립트를 작성해주었다.

**진행순서**

1. test job을 제거
2. Ruby는 `my-jekyll-project`에 설치
3. Node 설치
4. 각각의 프로젝트 빌드 전 `npm i`를 실행
5. `my-jekyll-project`로 이동하여 빌드 + `JEKYLL_ENV: "production"` 환경변수
6. `my-docs-project`로 이동하여 빌드 + `DOCU_ENV: "production"` 환경변수
7. `_site/document`로 `my-docs-project/build` 파일을 이동
8. 아티팩트 업로드
9. 배포

```yml
name: "Build and Deploy"
on:
  push:
    branches:
      - main
      - master
    paths-ignore:
      - .gitignore
      - README.md
      - LICENSE

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

# Allow one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
          bundler-cache: true
          working-directory: my-jekyll-project

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: lts/*

      - name: Instsall Node
        run: npm i

      - name: Build jekyll Assets
        run: cd my-jekyll-project && npm run build

      #- name: Test site
      #  run: |
      #    bundle exec htmlproofer _site \
      #      \-\-disable-external \
      #      \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

      - name: Build jekyll Site
        run: cd my-jekyll-project && bundle exec jekyll b -d "../_site${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: "production"

      - name: Build Docusaurus Site
        run: cd my-docs-project && npm run build
        env:
          DOCU_ENV: "production"

      - name: Combine outputs
        run: |
          mkdir -p "_site${{ steps.pages.outputs.base_path }}/document"
          cp -r my-docs-project/build/* "_site${{ steps.pages.outputs.base_path }}/document/"

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "_site${{ steps.pages.outputs.base_path }}"

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## 참고 사이트

- [docusaurus를 이용해보자](https://velog.io/@doldory55/docusaurus%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%B4%EB%B3%B4%EC%9E%90)

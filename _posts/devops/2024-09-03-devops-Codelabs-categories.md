---
title: "Codelabs Categories 추가"
categories: devops
tags: codelab
last_modified_at: 2024-09-03T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

# 색상, 아이콘 추가

`/site/app/styles/_categories.scss` 를 수정한다

## 색상코드 추가

```scss
$color-amqp-blue: #20329f;
$color-boomi-blue: #043d58;
$color-kafka-black: #000;
$color-java-red: #dc403d;
$color-jms-red: #dc403d;
$color-mqtt-purple: #751b84;
$color-rest-grey: #a2a7ab;
$color-solace-green: #00c895;
$color-spring-green: #6db33f;
$color-k8s-blue: #2f6ce6;
$color-js-yellow: #f5de19;
$color-helm-blue: #277a9f;
$color-azure-blue: #038ad7;
$color-opentel-orange: #f7a71b;
$color-mule-blue: #04a0de;
$color-rabbit-orange: #f76302;
$color-keda-blue: #326de6;
$color-apama-blue: #0098cf;
$color-hermesjms-yellow: #fef200;
$color-flink-pink: #e6516f;
$color-nifi-blue: #6a8691;
$color-nagios-black: black;
$color-jboss-red: red;
$color-weblogic-red: red;
$color-websphere-purple: purple;
$color-webspherelib-blue: #6a8691;
$color-spark-orange: #e77215;
$color-sap-blue: #00418d;
```

## 아이콘 추가

```scss
@include codelab-card([ "java"], $color-java-red, "java.svg");
@include codelab-card([ "spring"], $color-spring-green, "spring.svg");
@include codelab-card([ "kubernetes"], $color-k8s-blue, "k8s.svg");
@include codelab-card([ "javascript"], $color-js-yellow, "js.svg");
@include codelab-card([ "sap"], $color-sap-blue, "sap.png");
```

# 아이콘 이미지 추가

`/site/app/images/icons` 경로에 실제 사용될 아이콘 이미지를 추가한다  
`.svg` 또는 `.png` 등 이미지 파일을 추가한다

> SVG 아이콘  
> [https://www.svgrepo.com](https://www.svgrepo.com)

> 색상코드 추출  
> [https://imagecolorpicker.com](https://imagecolorpicker.com)

# 여러 카테고리가 보이게 처리

코드랩에 카테고리를 추가하면 대표 하나만 보이게 설정되어있다

![original](/images/2024-09-03-devops-Codelabs-categories/2024-09-09-13-09-58.png)

이걸 구글의 코드랩처럼 여러 카테고리가 나오도록 변경해 보자

![google-codelab](/images/2024-09-03-devops-Codelabs-categories/2024-09-09-13-10-47.png)

## scss 수정

`/site/app/styles/_codelab-card.scss` 파일을 열어  
card-footer하위에 `category-icon-container` Class를 추가하자

![icon-container](/images/2024-09-03-devops-Codelabs-categories/2024-09-09-13-14-20.png)

## 랜딩페이지 수정

`/site/app/views/default/index.html` 파일을 열어 아래처럼 반복문을 추가하자

![card-footer](/images/2024-09-03-devops-Codelabs-categories/2024-09-09-13-17-00.png)

# 최종결과

category가 모두 아이콘형태로 변환된 걸 확인 할 수 있다😁

![final](/images/2024-09-03-devops-Codelabs-categories/2024-09-09-13-23-25.png)

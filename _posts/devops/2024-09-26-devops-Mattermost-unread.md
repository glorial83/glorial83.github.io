---
title: "Mattermost 읽지 않은 멤버 조회"
categories: devops
tags: mattermost
last_modified_at: 2024-09-26T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 읽지 않은 멤버 조회

> 사내에 `Slack`을 대체 할 솔루션이 필요했고  
> 예전부터 미루고 미루던 `Mattermost`를 설치하여 운영하기로 했다  
> 그런데 공지용 쓰레드를 올렸을 때 누가 읽었는지 확인이 되지 않았다  
> 카카오톡에 이미 길들여져있던 나는 간절하게 기능이 필요했다

## API & Plug-in 검색

API 또는 Plug-in이 있나 검색하던 중에 해당 글을 발견!!!!  
API를 활용하여 개발하기로 했다  
_Plug-in은 모바일에서는 사용할 수 없었다😥_

![mattermost-community](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-14-50-30.png)
_<https://github.com/mattermost/mattermost/issues/20510>_

## 구현방식

- `Mattermost`의 봇을 생성하고 그 봇의 토큰으로 `Mattermost` API 호출 시 사용한다
- `AWS Lambda`를 활용하여 자체 API를 제공한다
- [`Slash Command`](https://developers.mattermost.com/integrate/slash-commands/)를 활용

## 프로세스

`Slash Command`를 호출하게 되면 아래와 같은 흐름으로 동작한다  
Slash Command -> AWS API Gateway -> AWS Lambda -> Mattermost API

## 구현시작🍟

### 1. 봇 생성

봇을 생성한다  
시스템 관리자권한과 모든 채널에 게시할 수 있는 권한을 부여했다  
![create-bot](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-15-04-20.png)

토큰 생성  
📢 토큰을 생성하게 되면 만든 직후에만 획득 할 수 있으니 관리에 주의한다  
![bot-token](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-15-06-44.png)

### 2. Lambda 생성

node로 만들어 주었다  
![lambda-create](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-15-09-47.png)

스크립트는 대충 저런 구조로 작성하였다  
최신 포스트를 가져와 채널멤버를 조회하고 작성일과 접속일을 비교하여  
작성일 이전에 접속한 멤버는 읽지 않은 멤버로 식별하였다

```javascript
/*
 * 가장 최근 포스트의 생성일자 조회
 * 가장 최근 포스트가 없다면 오늘날짜 반환
 */
const getLatestPost = async (options, channel_id){...}

/*
 * 채널 멤버 조회
 */
const getChannelMembers = async (options, channel_id) => {...}

/*
 * 채널 멤버 조회(+이름)
 */
const getChannelMemberNames = async (options, channel_id) => {...}

/*
 * 읽지 않은 멤버 판별
 */
const getUnreadMember = (members, latestPostDate) => {...}
```

**_사용한 API_**

- `채널 조회` /api/v4/channels
- `채널 포스트 조회` api/v4/channels/:channel_id/posts
- `채널 멤버 조회` /api/v4/channels/:channel_id/members
- `채널 멤버 이름 조회` /api/v4/users

### 3. API Gateway 생성

`Slash Command`로 발생한 Request는 Content-Type이 `application/x-www-form-urlencoded`이고  
Accept-Content-Type은 `application/json`이다  
그래서 REST API로 생성해야 한다  
![api-rest](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-15-16-27.png)

Post로 메서드를 생성하고 이전에 생성한 Lambda 함수를 지정한다
![api-method](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-16-00-14.png)

`Content-Type`과 `application/x-www-form-urlencoded`을 추가한다  
![api-header](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-16-01-35.png)

다시 Lambda의 구성-트리거를 확인해 보면 API Gateway의 URL을 확인 할 수 있다  
`Slash Command`가 입력되면 이 URL로 요청이 발송되도록 해야 한다  
![lambda-trigger](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-16-05-42.png)

### 4. `Slash Command` 생성

Mattermost의 `통합` 메뉴로 접속한다  
아래처럼 `Slash Command`를 생성한다  
**요청 URL에 반드시 `API Gateway`의 URL을 입력해야 한다**  
![matter-slash](/images/2024-09-26-devops-Mattermost-unread/2024-09-26-16-08-41.png)

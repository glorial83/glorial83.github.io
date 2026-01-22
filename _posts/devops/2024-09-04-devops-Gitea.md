---
title: "Gitea 설치"
categories: devops
tags: gitea
last_modified_at: 2024-09-04T11:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## Gitea 선택 이유

> 현재 사내 Git으로 `Gitlab-CE`를 사용 중인데 램을 할당하면 할당 해줄 수록 🦛하마처럼 먹어치웠다😪  
> 리소스를 덜 사용한다고 하길래 적용해 봄

## Docker Compose 사용

[Installation with Docker](https://docs.gitea.com/installation/install-with-docker)

```docker
version: "3"

networks:
  gitea:
    external: false

services:
  server:
    image: gitea/gitea:1.22.1
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - TZ=Asia/Seoul
    restart: "no"
    networks:
      - gitea
    volumes:
      - ./data:/data
    ports:
      - "3000:3000"
      - "222:22"
```

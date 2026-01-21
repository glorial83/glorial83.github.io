---
title: "VSCode Server 구축"
categories: devops
tags: vscode code-server remote serve-web code
last_modified_at: 2025-03-24T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 어느날 문득

> VSCode를 가상화 환경으로 구성하고 싶었다  
> 예전부터 눈독들이고 있었던 참에 `Gitlab Web IDE`를 보고 어느정도 무르익었다고 판단되었길래 적용해보았다

![gitlab-web-ide](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-14-13-37.png)

## Serve web 방식

[Serve web](https://hsgpublic.hashnode.dev/10#heading-2-2-serve-web) 을 소개해준 블로그가 있어 참고하며 적용해보았다.

`VSCode`의 `CLI` 를 활용하는 방식인데 원격지에서 사용하는 방식이다.

### 1. 폴더구조

이런 형태로 폴더구조를 구성하였다.

`Ubuntu`기반의 `Tomcat, Maven, Temurin17`을 사용하는 `Spring MVC` 프로젝트 환경을 구축 할 것이다.

아마 `Spring Boot`를 사용하면 좀 더 간소화 할 수 있을 것이다.

```bash
code-server
 ┣ data                       # VSCode의 AppData
 ┃ ┣ vscode
 ┃ ┣ vscode-server
 ┃ ┗ workspace                # 프로젝트 위치
 ┣ tools                      # Docker 구성 시 필요한 어플리케이션
 ┃ ┣ apache-maven-3.6.3-bin.tar.gz
 ┃ ┣ apache-tomcat-9.0.80.tar.gz
 ┃ ┣ OpenJDK17U-jdk_x64_linux_hotspot_17.0.6_10.tar.gz
 ┃ ┗ vscode_cli_alpine_x64_cli.tar.gz
 ┣ scripts                    # 컨테이너 구동 스크립트
 ┃ ┗ entrypoint.sh
 ┣ Dockerfile
 ┗ docker-compose.yml
```

### 2. data 폴더

`code-server` 하위에 `vscode, vscode-server, workspace`를 만들었다.

`vscode, vscode-server`는 `VSCode`가 실행되면 실행환경들이 구축되는 폴더이다.

`workspace` 하위에 `Spring MVC` 프로젝트를 생성 할 것이다.

### 3. tools 폴더

`code-server` 하위에 `tools`를 만들고 아래 어플리케이션들을 다운로드 받았다.

- [apache-maven-3.6.3](https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.tar.gz)
- [apache-tomcat-9.0.80](https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz)
- [OpenJDK17U](https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6+10/OpenJDK17U-jdk_x64_linux_hotspot_17.0.6_10.tar.gz)
- [vscode_cli_alpine_x64_cli](https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64)

### 4. entrypoint.sh

`code-server` 하위에 `scripts`를 만들고

Docker 컨테이너 구동 시 필요한 과정을 위해 `entrypoint.sh`를 작성했다.

`/usr/local/bin`에 설치한 `VSCode`를 실행 시켰다.

```bash
#!/bin/sh

/usr/local/bin/code serve-web --host 0.0.0.0 --port 8000 --accept-server-license-terms --without-connection-token
```

| args                        | desc                                 |
| --------------------------- | ------------------------------------ |
| serve-web                   | GitHub 등의 인증 없이 바로 접속 가능 |
| host                        | 구동할 IP                            |
| port                        | 구동할 PORT                          |
| accept-server-license-terms | 자동동의                             |
| without-connection-token    | 인증생략                             |

### 5. Dockerfile

#### 5-1. Ubuntu

`Ubuntu` 기반에 내가 사용할 툴과 언어, 시간을 설정하였다.

```bash
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y language-pack-ko sudo curl git nodejs

RUN locale-gen ko_KR.UTF-8
ENV LANG ko_KR.UTF-8
ENV LANGUAGE ko_KR:ko:en_US:en
ENV LC_ALL ko_KR.UTF-8

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
```

#### 5-2. JDK

`tools` 폴더에 다운로드 했던 JDK를 `/opt/temurin` 하위에 설치했다.

```bash
# Temurin JDK 설치
#RUN curl -L -o /tmp/temurin-jdk.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6+10/OpenJDK17U-jdk_x64_linux_hotspot_17.0.6_10.tar.gz
COPY ./tools/OpenJDK17U-jdk_x64_linux_hotspot_17.0.6_10.tar.gz /tmp/temurin-jdk.tar.gz
RUN mkdir /opt/temurin && \
    tar -xvzf /tmp/temurin-jdk.tar.gz -C /opt/temurin && \
    rm /tmp/temurin-jdk.tar.gz
```

#### 5-3. Maven

`tools` 폴더에 다운로드 했던 Maven을 `/opt/maven` 하위에 설치했다.

```bash
COPY ./tools/apache-maven-3.6.3-bin.tar.gz /tmp/maven.tar.gz
RUN mkdir /opt/maven && \
    tar -xvzf /tmp/maven.tar.gz -C /opt/maven && \
    rm /tmp/maven.tar.gz
```

#### 5-4. 환경 변수 설정

어디서든 접근 할 수 있도록 `JDK, Maven` 의 `PATH`를 등록했다.

```bash
ENV JAVA_HOME=/opt/temurin/jdk-17.0.6+10
ENV M2_HOME=/opt/maven/apache-maven-3.6.3
ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
```

#### 5-5. Apache Tomcat

`tools` 폴더에 다운로드 했던 Tomcat을 `/opt/tomcat` 하위에 설치했다.

```bash
#RUN curl -L -o /tmp/tomcat.tar.gz https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
COPY ./tools/apache-tomcat-9.0.80.tar.gz /tmp/tomcat.tar.gz
RUN mkdir /opt/tomcat && \
    tar -xvzf /tmp/tomcat.tar.gz -C /opt/tomcat && \
    rm /tmp/tomcat.tar.gz
```

#### 5-6. alias

버전명까지 입력하여 이동하고 싶지 않아 별칭과 바로가기를 등록했다.

```bash
# alias 추가
RUN echo "alias tomcat='cd ~/tomcat'" >> /etc/profile && \
    echo "alias java='/opt/temurin/jdk-17.0.6+10/bin/java'" >> /etc/profile

# 심볼릭 링크 추가
RUN ln -s /opt/tomcat/apache-tomcat-9.0.80 /root/tomcat && \
    ln -s /opt/temurin/jdk-17.0.6+10/bin/java /usr/bin/java
```

#### 5-7. VSCode CLI

`tools` 폴더에 다운로드 했던 VSCode CLI를 `/usr/local/bin` 하위에 설치했다.

```bash
COPY ./tools/vscode_cli_alpine_x64_cli.tar.gz /tmp/vscode_cli.tar.gz
RUN tar -xvzf /tmp/vscode_cli.tar.gz -C /tmp && rm /tmp/vscode_cli.tar.gz
RUN mv /tmp/code /usr/local/bin/code
RUN code version use stable --install-dir /usr/local/bin/code
```

#### 5-8. 컨테이너 구동

workspace폴더와 entrypoint.sh를 지정했다.

```bash
RUN mkdir /code-server
COPY ./scripts /code-server/scripts
RUN chmod +x /code-server/scripts/*

RUN mkdir -p /code-server/workspace
WORKDIR /code-server

ENTRYPOINT /code-server/scripts/entrypoint.sh
```

### 6. docker-compose.yml

VSCode CLI에서 사용하게 될 폴더를 내 로컬PC의 폴더로 매핑해주었고

VSCode CLI의 port와 Tomcat의 port를 각각 9000, 9080 으로 지정했다.

```yml
version: "3"
services:
  my-code-server:
    image: my-code-server
    container_name: my-code-server
    restart: unless-stopped
    volumes:
      - ./data/vscode:/root/.vscode
      - ./data/vscode-server:/root/.vscode-server
      - ./data/workspace:/code-server/workspace
    ports:
      - "9000:8000"
      - "9080:8080"
```

### 7. 이미지 생성

`Dockerfile`이 있는 폴더로 이동해 이미지를 생성했다.

```bash
docker build --no-cache -t my-code-server -f ./Dockerfile .
```

### 8. 컨테이너 구동

```bash
docker compose up -d
```

### 9. VSCode 접속

`9000` 포트로 expose했기 때문에 [http://localhost:9000](http://localhost:9000)으로 접속하면 아래처럼 VSCode가 나온다👍

![vscode-cli-1](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-04-08.png)

### 10. extenstion 설치

#### 10-1. Extension Pack for Java

Java용 extenstion을 설치한다.

![ext-1](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-05-11.png)

#### 10-2. Community Server Connectors

Tomcat을 위한 extension을 설치한다.

![ext-2](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-06-07.png)

#### 10-3. Tomcat

파일 저장 시 자동으로 deploy하기 위한 extension을 설치한다.

![ext-3](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-11-13.png)

#### 10-4. Decompiler for Java(선택)

클래스를 조회하기 위해 extenstion을 설치한다.

![ext-4](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-07-44.png)

### 11. VSCode 설정

파일 저장 시 자동으로 deploy하기 위해 자동저장을 비활성화 해주었고

**Tomcat**의 기본경로와 빌드종류를 지정해주었다.

- 이 설정은 Apache Tomcat이 아니라 위에서 설치했던 자동 deploy용 extension의 환경설정이다

```json
{
  "tomcat.defaultDeployMode": "On Save",
  "tomcat.home": "/opt/tomcat/apache-tomcat-9.0.80",
  "tomcat.defaultBuildType": "Maven",
  "files.autoSave": "off"
}
```

### 12. Spring MVC 프로젝트

`code-server/data/workspace` 에 내가 사용할 어플리케이션을 옮겨주었다.

![spring-mvc](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-15-55-18.png)

### 13. 프로젝트 설정

#### 13-1. JDK 지정

우측하단의 Java를 클릭한다.

![jdk-1](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-15-30.png)

Open Project Settings를 클릭한다.

![jdk-2](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-16-06.png)

JDK Runtime이 올바로 지정되었는지 확인한다.

![jdk-3](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-17-08.png)

#### 13-2. Maven 빌드

Java Projects에서 내 프로젝트를 우클릭 하여 `Run Maven Command`를 클릭한다.

![maven-1](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-17-47.png)

Custom 선택 후 `clean compile`을 입력하여 실행한다.

![maven-2](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-19-38.png)

### 14. Tomcat 추가

Server에서 추가 버튼을 클릭한다.

![tomcat-1](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-22-23.png)

우리는 이미 설치되어 있으므로 `No, use server on disk`를 선택한다.

![tomcat-2](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-23-17.png)

`/opt/tomcat/apache-tomcat-9.0.80/`를 입력 후 저장한다.

![tomcat-3](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-24-06.png)

Finish를 클릭하여 마무리한다.

![tomcat-4](/images/2025-03-24-devops-vscode-remote-old/2025-03-25-16-24-48.png)

### 15. 자동 deploy 오류

자동배포가 안되어 확인해 보니 finalName을 내가 artifactId로 해놓았기 때문에 안되었다.

Tomcat extension은 프로젝트 이름을 사용하기 때문에 해당 부분을 ${finalName}으로 override 해주었다.

```xml
    <properties>
        <java.version>17</java.version>
        <maven.resources.overwrite>true</maven.resources.overwrite>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <env>local</env>
        <spring.profiles.active>${env}</spring.profiles.active>

        <!--warName>${project.artifactId}</warName-->
        <warName>${finalName}</warName>
	</properties>

  <!-- 생략 -->
  <build>
      <defaultGoal>install</defaultGoal>
      <directory>${project.basedir}/target</directory>
      <finalName>${warName}</finalName>
  </build>
```

## 후기

근데 왜 MSDN이든 어디든 serve-web에 대한 공식 설명이 없었다.

~~왜일까 궁금했는데 옛날 방식이라고 하더라.........구성 다해놨는데........~~

~~힘이 빠지지만 새로운 방식으로 다음 글을 작성해보겠다!!!!~~

현재까지도 CLI에서 동작하는걸 봐선 그냥 공식 설명이 누락된것 같다.

암튼 Docker도 지원 되니 [coder code-server](https://github.com/coder/code-server) 요걸 사용하면 조금 더 간편할 듯 하다.

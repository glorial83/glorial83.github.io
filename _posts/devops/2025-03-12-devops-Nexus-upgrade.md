---
title: "Nexus 업그레이드"
categories: devops
tags: nexus
last_modified_at: 2025-03-12T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## 어느날 문득

> 사내에 `Nexus`를 사용중이다  
> 강력해보이는 Noti를 보고 예전부터 미루고 미루던 `Nexus`를 업그레이드 하기로 했다  
> 절차가 생각보다 복잡해져서 기록을 남긴다

![nexus-notification](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-14-49-22.png)

## Upgrade Path 확인

[find-your-upgrade-path](https://help.sonatype.com/en/upgrading-to-nexus-repository-3-71-0-and-beyond.html#find-your-upgrade-path)를 보고 업그레이드 절차를 확인해보았다.

![upgrade-path](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-14-51-19.png)

1. `nexus3:3.70.0` 으로 업그레이드
2. DB 이관
3. Java 업그레이드
4. `nexus3:3.71.0` 로 업그레이드

## 1. nexus3:3.70.0 으로 업그레이드

윈도우 PC에 Docker Desktop으로 `sonatype/nexus3:3.38.0​`을 사용하고 있었다.

냅다 image를 `3.70.0`으로 올려 실행했다.

다행히 별 이상없이 실행되었다.

```bash
docker rm nexus
docker run --name nexus -d --restart=always -p 0**0:8081 -p 0**0:5000 -v D:/docker/nexus/data:/nexus-data -u root sonatype/nexus3:3.70.0
```

## 2. DB 이관

주의사항을 대충 흘겨버리고 [여기](https://help.sonatype.com/en/upgrading-to-nexus-repository-3-71-0-and-beyond.html#migrating-from-orientdb-to-h2-252162-1) 절차를 따라 진행했다.

`OrientDB`를 어떤 데이터베이스로 변경할까 심고끝에 `H2` 데이터베이스로 내마음대로 결정했다.

![migration-procedure](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-10-01.png)

### 2-1. DB 백업

`Export databases for backup` Task를 실행하였다.

![backup-run](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-04-29.png)

### 2-2. Nexus Repository 중단

```bash
# docker 쉘로 접속
docker exec -it nexus bash

# docker 내부의 nexus 실행파일 경로 이동
$ cd /opt/sonatype/nexus

# docker 내부의 nexus 중단
$ exec ./bin/nexus stop
```

### 2-3. nexus-db-migrator 다운로드

[여기](https://help.sonatype.com/en/orientdb-downloads.html#database-migrator-utility-for-3-70-x)에서 다운로드 받는다

### 2-4. nexus-db-migrator 이동

백업파일이 있는 곳으로 이동한다

![backup-location](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-45-31.png)

### 2-5. nexus-db-migrator 실행

다시 한 번 쉘로 접속하여 migrator를 실행한다.

```bash
# docker 쉘로 접속
docker exec -it nexus bash

# 백업파일이 있는 곳으로 이동
$ cd /nexus-data/backup

# migrator 실행
$ java -Xmx16G -Xms16G -XX:+UseG1GC -XX:MaxDirectMemorySize=28672M -jar nexus-db-migrator-*.jar --migration_type=h2
```

생각보다 migration은 빨리 끝났다.

![migration-1](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-48-12.png)

![migration-2](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-48-48.png)

### 2-6. nexus.mv.db 파일 이동

migration 결과로 생성된 `nexus.mv.db` 파일을 `/nexus-data/db` 폴더로 옮겨주었다.

```bash
$ cp /nexus-data/backup/nexus.mv.db /nexus-data/db
```

### 2-7. nexus.properties 수정

`nexus.properties` 파일을 열어 `nexus.datastore.enabled=true` 를 추가해주자.

```bash
$ vi /nexus-data/etc/nexus.properties
```

### 2-8. Nexus를 재시작

귀찮아서 그냥 Docker Desktop으로 Nexus를 재시작 해주었다.

반쯤 쫄아서 로그를 보니 뭔가를 막 하고 있는것 같았다.

![restore-log](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-15-59-04.png)

Nexus에 접속하여 DataStore가 있는지 확인해보았으나 아직 메뉴가 보이지 않았다.

![check-menu](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-16-17-22.png)

뭐지? 마이그레이션이 안되었나 싶어 `Support - System Information` 으로 이동하여 OrientDB가 사용중인지 확인해 보았다.

`nexus.orient.enabled`가 `true`면 `OrientDB`이라는 뜻인데 다행히 `false`로 되어있었다.

![orient](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-16-16-24.png)

## 3. Java 업그레이드

Docker로 구동중이라 jdk17 이미지로 다시 시작해주었다.

`alpine`과 `ubi` 이미지가 있는데 사내에서 사용하는거라 `nexus3:3.70.0-java17-alpine`을 선택해주었다.

다만 보안이 중요한 곳이라면 `ubi`를 사용하길 추천한다고함.

```bash
docker rm nexus
docker run --name nexus -d --restart=always -p 0**0:8081 -p 0**0:5000 -v D:/docker/nexus/data:/nexus-data -u root sonatype/nexus3:3.70.0-java17-alpine
```

## 4. nexus3:3.71.0 로 업그레이드

`sonatype/nexus3:3.71.0-java17-alpine` 으로 다시 시작해주었다.

그래도 `DataStore`가 보이지 않았다. 😱😱😱😱😱😱

[Stackoverflow](https://stackoverflow.com/questions/78892810/sonatype-nexus-menu-option-data-store-is-not-shown) 나만 그런게 아니었다. 😱😱😱😱😱😱

```bash
docker rm nexus
docker run --name nexus -d --restart=always -p 0**0:8081 -p 0**0:5000 -v D:/docker/nexus/data:/nexus-data -u root sonatype/nexus3:3.71.0-java17-alpine
```

## 5. nexus3:3.78 로 업그레이드

이왕 이렇게 된거 최신버전으로 올려보자!!

이제부터는 java17이 기본이라 tag명이 좀 더 간결해졌다.

그리고 속도가 훨씬 빨라졌다. 기분탓이 아니다.

```bash
docker rm nexus
docker run --name nexus -d --restart=always -p 0**0:8081 -p 0**0:5000 -v D:/docker/nexus/data:/nexus-data -u root sonatype/nexus3:3.78.1-alpine
```

이제야 DataStore가 나온다. 😍😍😍😍😍😍

![datastores](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-17-11-23.png)

## 번외

백업 Task가 변경되었다.

원래는 `Export databases for backup` 를 사용중이었는데

`Backup H2 Databases` 를 사용해야 한다.

백업된 파일도 35메가에서 8메가로 5배 정도 줄었다.

![backup](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-17-17-39.png)

잘가라 `OrientDB`

![old-artifacts](/images/2025-03-12-devops-Nexus-upgrade/2025-03-12-17-21-43.png)

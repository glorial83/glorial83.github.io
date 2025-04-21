---
title: "Gitlab Repository check error"
categories: devops
tags: gitlab
last_modified_at: 2025-04-21T11:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## Gitlab Repository check error 발생 ⚠️

> 사내 Gitlab을 Docker로 구동중인데  
> 어느날 부터인가 오류가 발생해서 확인해 봄😪

### Admin 페이지

이런 경고가 사이트와 이메일로 보고되고 있었다.

![repository-error-1](/images/2024-09-04-devops-Gitlab-repository-check/2025-04-21-09-51-03.png)

```bash
E, [2025-04-19T21:20:10.217821 #653] ERROR -- :  Could not fsck repository: warning: unable to find all commit-graph files
warning: unable to find all commit-graph files
```

## 해결책 구글링

다행히 동일한 현상이 기재되어 있었고 다행히 해결책도 나와있었다.

[Repository Check error](https://forum.gitlab.com/t/gitlab-projects-failed-their-last-repository-check/19147)

### 해결책

```bash
/opt/gitlab/embedded/bin/git config --global --add safe.directory /var/opt/gitlab/git-data/repositories/RELATIVE_PATH
/opt/gitlab/embedded/bin/git -C /var/opt/gitlab/git-data/repositories/RELATIVE_PATH fsck
/opt/gitlab/embedded/bin/git -C /var/opt/gitlab/git-data/repositories/RELATIVE_PATH gc
/opt/gitlab/embedded/bin/git -C /var/opt/gitlab/git-data/repositories/RELATIVE_PATH fsck
```

## 스크립트 작성

대략 22개의 Repo가 에러를 내뿜고 있었는데 일일이 모든 프로젝트에 대한 커맨드를 입력하기 귀찮아서

모든 Repo를 수행하는 스크립트를 작성하였다.

```bash
#!/bin/bash

# Git 저장소가 있는 기본 디렉터리 (GitLab의 hashed 디렉토리)
BASE_DIR="/var/opt/gitlab/git-data/repositories/@hashed"

# 모든 Git 저장소 경로 가져오기
REPO_PATHS=$(find "$BASE_DIR" -type d -name "*.git")

# 명령어 반복 실행
for REPO in $REPO_PATHS; do
    echo "Processing repository: $REPO"

    /opt/gitlab/embedded/bin/git config --global --add safe.directory "$REPO"
    /opt/gitlab/embedded/bin/git -C "$REPO" fsck
    /opt/gitlab/embedded/bin/git -C "$REPO" gc
    /opt/gitlab/embedded/bin/git -C "$REPO" fsck

    echo "Done processing $REPO"
    echo "--------------------------------"
done
```

> 만약 Permission Denied 오류가 발생한다면 아래처럼 실행 권한을 주자

```bash
chmod -R 775 /var/opt/gitlab/git-data/repositories/RELATIVE_PATH/objects/pack
```

## 스크립트 수행결과 확인

### 에러가 발생중인 Repo 췍

`http://yourgitlab_link/admin/projects?last_repository_check_failed=1` 로 접속하여 에러가 발생된 Repo를 조회한다.

![repo-list1](/images/2024-09-04-devops-Gitlab-repository-check/2025-04-21-09-59-44.png)

### Repository check 실행

상세로 이동하여 `Repository check`을 클릭한다.

![repo-view1](/images/2024-09-04-devops-Gitlab-repository-check/2025-04-21-10-00-16.png)

이렇게 `Passed` 메세지가 나오면 된다🎉✨

![repo-passwd](/images/2024-09-04-devops-Gitlab-repository-check/2025-04-21-10-02-01.png)

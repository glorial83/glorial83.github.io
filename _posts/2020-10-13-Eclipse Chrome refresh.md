---
title: "Eclipse Build 후 Chrome 자동 새로고침"
categories: java
tags: ide eclipse 이클립스 브라우저 크롬 chrome 새로고침 자동 refresh
last_modified_at: 2020-10-13T21:00:00+09:00
# classes: wide
# toc: true
# toc_sticky: true
---

## 1. 명령어로 프로그램을 실행 할 수 있는 유틸이 필요합니다.

<http://www.nirsoft.net/utils/nircmd.html> 에 접속 후 다운로드 합니다.  
`Download NirCmd` 또는 `Download NirCmd 64-bit`를 클릭합니다.

![그림0](/images/2020-10-13-14-20-13.png)

## 2. 적당한 경로에 압축 해제 후 `nircmd.exe` 를 실행하여 `Copy to Windows Directory`를 클릭합니다.

![그림1](/images/2020-10-13-14-21-37.png)

## 3. Eclipse의 프로젝트에 `reload.bat` 파일을 생성합니다.

![그림2](/images/2020-10-13-14-28-19.png)

```bash
ECHO Off
REM reload.bat

nircmd.exe win activate ititle "chrome"
nircmd.exe win max ititle "chrome"
nircmd.exe sendkey f5 press
```

## 4. Eclipse의 프로젝트 우클릭 -> Properties -> Builders -> New 클릭 합니다.

![그림3](/images/2020-10-13-14-16-35.png)

## 5. `Program`을 선택 후 `OK`를 클릭합니다.

![그림4](/images/2020-10-13-14-17-38.png)

## 6. 적당한 Name을 지정해준 뒤 `Browse Workspace`를 클릭하여 좀전에 생성한 `reload.bat`를 선택합니다.

![그림5](/images/2020-10-13-14-39-13.png)

## 7. Build Option 탭으로 이동 하여 `During Auto Build`에 체크 해줍니다.

![그림6](/images/2020-10-13-14-41-55.png)

## 8. 이제 제대로 동작하는지 확인해 봅시다.

크롬을 오픈하여 로컬서버로 접속 한 다음  
다시 Eclipse의 소스를 수정하게 되면 새로고침이 자동으로 진행됩니다.  
`reload.bat`의 `ititle` 을 `whale,internet explorer` 등으로 교체하게 되면  
다른 브라우저에서도 자동 새로고침을 적용할 수 있습니다.

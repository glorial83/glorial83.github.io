---
title: "Tomcat 멀티 어플리케이션 구동"
categories: devops
tags: tomcat
last_modified_at: 2026-01-22T12:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

## Tomcat 멀티 어플리케이션 구성 방식 개요

- Tomcat 멀티 Instance 구성
- Tomcat Service 분리 (싱글 Instance)
- ~~Tomcat 다중 설치 방식~~

## Tomcat 멀티 Instance 구성

### Tomcat 멀티 Instance 구조 설명

Tomcat의 바이너리(CATALINA_HOME)는 공유하고 어플리케이션별 개별 환경을 구성

### Tomcat 멀티 Instance 장점과 단점

**장점**

- 각 어플리케이션의 배포, 재시작, 설정 변경을 독립적 수행 가능
- 특정 Instance에 장애가 발생해도 다른 Instance에 영향 주지 않음
- 별도의 프로세스 / 클래스로더로 구동되므로 종속성 관리가 수월함
- 설정이 분리되어 있으므로 Tomcat 버전 관리에 유연

**단점**

- Instance와 포트가 많아지므로 관리가 복잡함
- 메모리 사용량이 싱글 Instance보다 높음

### CATALINA_HOME 과 CATALINA_BASE 차이

- **CATALINA_HOME**
  - Tomcat 바이너리 및 공통 엔진 영역
  - 여러 Instance가 공유
- **CATALINA_BASE**
  - Instance별 설정, 로그, 웹 애플리케이션 디렉토리
  - 하나의 Tomcat 프로세스 = 하나의 CATALINA_BASE

### Tomcat 멀티 Instance 구성 방법

아래와 같은 경로로 구성을 해볼까 합니다.

```
- CATALINA_HOME : /app/tomcat9
- CATALINA_BASE : /app/app1, /app/app2
  - bin : setenv.sh, startup.sh, shutdown.sh
  - logs : Instance 로그
  - webapps : 어플리케이션을 담을 컨테이너 디렉토리 **본 예제에서는 단일 애플리케이션만 운영**
  - lib : was lib(ex, jdbc)
  - work : 동적 콘텐츠 컴파일 폴더
  - temp : Tomcat 임시파일
```

```bash
mkdir -p /app/app1/{bin,logs,webapps,lib,work,temp}
cp -r /app/tomcat9/conf /app/app1
```

#### conf/server.xml 수정

- tomcat.server.port : Tomcat Shutdown용 포트
- tomcat.http.port : Tomcat HTTP 포트
- tomcat.web.root : 어플리케이션 webroot 폴더
- jvmRoute : sticky 로드밸런서용 유일값

```xml
<Server port="${tomcat.server.port}" shutdown="SHUTDOWN">
```

```xml
<Connector port="${tomcat.http.port}" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />
```

```xml
<Engine name="Catalina" defaultHost="localhost" jvmRoute="${jvmRoute}">
```

```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    prefix="localhost_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
  <Context path="" docBase="${tomcat.web.root}" reloadable="false"></Context>
</Host>
```

#### Tomcat 환경 변수 설정

Tomcat 환경 변수 설정을 위해 bin/env.sh 를 작성합니다

```bash
#!/bin/sh

export JRE_HOME=/usr/lib/jvm/temurin-17-jdk
export JVM_ROUTE=app1
export CATALINA_HOME=/app/tomcat9
export CATALINA_BASE=/app/$JVM_ROUTE
export WEB_ROOT=$CATALINA_BASE/webapps/$JVM_ROUTE
export SERVER_PORT=8005
export HTTP_PORT=8080

JAVA_OPTS="-Dtomcat.server.port=${SERVER_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dtomcat.http.port=${HTTP_PORT}"
JAVA_OPTS="${JAVA_OPTS} -Dtomcat.web.root=${WEB_ROOT}"
JAVA_OPTS="${JAVA_OPTS} -DjvmRoute=${JVM_ROUTE}"
JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
#JAVA_OPTS="${JAVA_OPTS} -Djava.util.prefs.systemRoot=/home/insasvn/app"
#JAVA_OPTS="${JAVA_OPTS} -Djava.util.prefs.userRoot=/home/insasvn/app"
export JAVA_OPTS

CATALINA_OPTS="${CATALINA_OPTS} -Djava.awt.headless=true"
CATALINA_OPTS="${CATALINA_OPTS} -Djava.security.egd=file:///dev/urandom"
#===========================================================
#JVM Memory Setting
#===========================================================
#CATALINA_OPTS="-server"
#CATALINA_OPTS="${CATALINA_OPTS} -Xms256m"
#CATALINA_OPTS="${CATALINA_OPTS} -Xmx256m"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:MetaspaceSize=128m"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:MaxMetaspaceSize=128m"


#===========================================================
#GC, Heapdump Setting
#===========================================================
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+UseG1GC"
#CATALINA_OPTS="${CATALINA_OPTS} -verbose:gc"
#CATALINA_OPTS="${CATALINA_OPTS} -Xloggc:${LOG_DIR}/gc.log_$(date +%Y%m%d%H%M%S)"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+PrintGCDetails"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+PrintGCTimeStamps"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+PrintGCDateStamps"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:HeapDumpPath=${LOG_DIR}/java_pid.hprof"
#CATALINA_OPTS="${CATALINA_OPTS} -XX:+PrintAdaptiveSizePolicy"

export CATALINA_OPTS

export CATALINA_PID=${CATALINA_BASE}/temp/tomcat.pid
export CATALINA_OUT="/dev/null"
```

#### Tomcat Instance 구동 스크립트

bin/startup.sh 를 작성합니다.

```bash
#!/bin/sh

. ./env.sh

# remove temp
rm -Rf ${CATALINA_BASE}/temp/*

# check running
if [ -f "${CATALINA_PID}" ]; then
    PID=$(cat "${CATALINA_PID}")

    # 해당 PID를 가진 프로세스가 실제로 살아있는지 확인
    if ps -p ${PID} > /dev/null; then
        echo "Tomcat SERVER - ${JVM_ROUTE} is already RUNNING"
        exit;
    fi
fi

${CATALINA_HOME}/bin/startup.sh
```

#### Tomcat Instance 중지 스크립트

bin/shutdown.sh 를 작성합니다.

```bash
#!/bin/sh

. ./env.sh

# check running
if [ -f "${CATALINA_PID}" ]; then
    PID=$(cat "${CATALINA_PID}")

    # 해당 PID를 가진 프로세스가 실제로 살아있는지 확인
    if ps -p ${PID} > /dev/null; then
        $CATALINA_HOME/bin/shutdown.sh
    else
        exit 1
    fi
else
    echo "NOT RUNNING!!!"
    exit 1
fi
```

### Tomcat 멀티 Instance 구동/중지 스크립트 호출법

```bash
/app/app1/bin/startup.sh
/app/app1/bin/shutdown.sh
```

### Tomcat Thread Dump 및 CPU Dump 방법 (번외)

Tomcat Thread Dump 를 위해 bin/dump.sh 를 작성합니다.

[TDA - Thread Dump Analyzer](https://github.com/irockel/tda) 사용 해서 분석 가능합니다.

```bash
#!/bin/sh

. ./env.sh

for count in 1 2 3 4 5; do
    echo "Thread Dump : $count"
    for i in `ps -ef | grep java | grep "base=$CATALINA_BASE " | awk '{print $2}'`;do
        date
        #echo "+kill -3 $i"
        echo "+jstack -l $i >> $CATALINA_BASE/logs/thread_dump.$i"
        #kill -3 $i
        jstack -l $i >> $CATALINA_BASE/logs/thread_dump.$i.tdump
        #echo "sleep 1 sec"
        #sleep 1
    done

    echo "done"
    sleep 3
done
```

CPU Dump 를 위해 bin/dump_cpu.sh 를 작성합니다.

```bash
#!/bin/sh

. ./env.sh

for count in 1 2 3 4 5; do
    echo "Thread Dump : $count"
    for i in `ps -ef | grep java | grep "base=$CATALINA_BASE " | awk '{print $2}'`;do
        top -H -b -n1 >> $CATALINA_BASE/logs/dump_high_cpu_$i.txt
        date
  echo "+jstack -l $i >> $CATALINA_BASE/logs/dump_high_cpu_$i.txt"
        jstack -l $i >> $CATALINA_BASE/logs/dump_high_cpu_$i.txt
        echo "cpu snapshot and thread dump done. #"
    done

    echo "done"
    sleep 3
done
```

## Tomcat Service 분리 방식 (싱글 Instance)

### Tomcat Service 분리 구조 설명

하나의 Tomcat Instance 내에서 여러 어플리케이션을 포트로 분리하여 구동한다.

### Tomcat Service 분리 장점과 단점

**장점**

- JVM을 공유하므로 메모리 사용 오버헤드 감소
- Tomcat 프로세스가 하나이므로 시작, 중지, 모니터링이 단순

**단점**

- 하나의 어플리케이션에 문제 발생 시 전체 Instance가 다운되거나 구동 불가
- Tomcat 버전 업그레이드에 유연하지 않음

### Tomcat server.xml 설정 (Service 분리)

%CATALINA_HOME%/conf/server.xml의 서비스명, 포트, 엔진명, 로그, 컨텍스트경로를 각각 지정해줍니다.

```xml
server.xml

<Service name="CatalinaApp1"> <!-- app1 서비스명  -->
  <Connector port="8080" protocol="HTTP/1.1" <!-- app1 포트 -->
          connectionTimeout="20000"
          redirectPort="8443"
          maxParameterCount="524288000"
          />
  <Engine name="CatalinaApp1" defaultHost="localhost"> <!-- app1 엔진명 -->
    <Realm className="org.apache.catalina.realm.LockOutRealm">
      <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
    </Realm>

    <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
      <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
          prefix="app1_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" /> <!-- app1 로그 -->
      <Context path="/" docBase="/app/app1" reloadable="false"></Context> <!-- app1 -->
    </Host>
  </Engine>
</Service>

<Service name="CatalinaApp2"> <!-- app2 서비스명  -->
  <Connector port="8081" protocol="HTTP/1.1" <!-- app2 포트 -->
          connectionTimeout="20000"
          redirectPort="8443"
          maxParameterCount="524288000"
          />
  <Engine name="CatalinaApp2" defaultHost="localhost"> <!-- app2 엔진명 -->
    <Realm className="org.apache.catalina.realm.LockOutRealm">
      <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
    </Realm>

    <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
      <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
          prefix="app2_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" /> <!-- app2 로그 -->
      <Context path="/" docBase="/app/app2" reloadable="false"></Context> <!-- app2 -->
    </Host>
  </Engine>
</Service>
```

## 내가 Tomcat 멀티 Instance를 선택 한 이유

[java.lang.NoClassDefFoundError: Unable to find Log4j2 as default logging library]({% link _posts/java/2026-01-21-log4jdbc.md %}) 이 것 때문에

싱글 Instance에 Context-path로 분리 돼있던 어플리케이션을 개별 Instance로 하려다 시도해 본것임

근데 사실 귀찮아 아주 귀찮아 죽겠어서 스크립트로 짜놓고 변수만 쌱쌱 대입해서 구축하려고 ㅋㅋㅋㅋ

자동화 스크립트는 AI시켜서 작성해봐야겠음

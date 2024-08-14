---
title: "Proxmox 설치 후 Tailscale 설정"
categories: devops
tags: proxmox tailscale
last_modified_at: 2024-08-14T07:11:50+09:00
classes: wide
# toc: true
# toc_sticky: true
---

> Openstack은 Cloud로써 굉장히 기능이 강력하였다  
> 하지만 소규모이기 때문에 좀 더 가벼운 리소스로 Cloud를 구성하고 싶었다  
> 그래서 기억을 더듬던 중 예전에 Youtube에서 보았던 댓글을 힌트 삼아 Proxmox를 설정해 보았다  
> 외부에서 접속하기 위해 `pfSense + NPM` 도 추가해 보았지만 HTTP와 HTTPS에 특화되었기 때문에 ❌
> `Tailscale`을 발견하고 route를 활용하여 외부 접속도 성공 할 수 있었다 🔆

## Proxmox 설치를 먼저 진행

[Proxmox 설치](Proxmox)

## [Proxmox VE Helper](https://tteck.github.io/Proxmox)의 Talescale 설치 명령어 검색

![proxmox-ve-helper](/images/2024-08-14-16-54-34.png)

## PVE Shell에 접속

![pve-shell](/images/2024-08-14-16-56-27.png)

## Ubuntu LXC 템플릿 검색

```
pveam available | grep ubuntu
```

![pveam-available](/images/2024-08-14-17-04-05.png)

## Ubuntu LXC 템플릿 다운로드

```
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

## Ubuntu 컨테이너 생성

General : `Unprivileged, Nesting` 체크  
![ct-general](/images/2024-08-14-17-08-15.png)

Template : `ubuntu` 선택  
![ct-template](/images/2024-08-14-17-09-37.png)

Disks : `hdd` 선택  
![ct-disks](/images/2024-08-14-17-09-59.png)

CPU  
![ct-cpu](/images/2024-08-14-17-10-11.png)

Memory  
![ct-memory](/images/2024-08-14-17-10-23.png)

Network : 우선 `DHCP`로 지정 (추후 변경)  
![ct-network](/images/2024-08-14-17-10-37.png)

DNS  
![ct-dns](/images/2024-08-14-17-10-52.png)

## Ubuntu 컨테이너 Console 접속

![tail-console](/images/2024-08-14-17-16-02.png)

## IP 정보 조회

```
#eth0의 IP를 조회
ip a
```

![tail-ip](/images/2024-08-14-17-17-03.png)

## IP 고정

Gateway는 공유기에서 제공하는 IP를 지정한다

![tail-gateway](/images/2024-08-14-17-20-44.png)

![tail-static](/images/2024-08-14-17-18-42.png)

## 컨테이너 재부팅 후 업데이트

```
apt update && upgrade -y
apt install curl -y
```

## Tailscale 다운로드 명령어 조회

![tail-script](/images/2024-08-14-17-23-37.png)

## 컨테이너 Console에 접속하여 Talescale 설치 명령어 실행

```
curl -fsSL https://tailscale.com/install.sh | sh
```

## Forward 허용

net.ipv4.ip_forward, net.ipv6.conf.all.forwarding 주석 해제

```
nano /etc/sysctl.conf
```

![tail-sysctl](/images/2024-08-14-17-25-47.png)

## 컨테이너 Shutdown

```
shutdown now
```

## PVE Shell 접속

![unprivileged-shell](/images/2024-08-14-17-32-02.png)

## Unprivileged의 호스트 경로 접근허용

```
nano /etc/pve/local/lxc/컨테이너아이디.conf

lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

![unprivileged-script](/images/2024-08-14-17-30-14.png)

## 컨테이너 Start 후 Console에서 Tailscale 구동

```
tailscale up --advertise-routes=172.30.1.0/24 --advertise-exit-node

#등록용 URL이 나옴
https://login.tailscale.com/a/임의아이디
```

## 외부에서 사용할 PC에서 Tailscale 가입 후 등록용 URL로 이동

이 과정에서 현재 PC도 등록을 해야 한다  
그래야 위에서 생성한 컨테이너를 VPN처럼 사용 할 수 있다

## Tailscale admin console - `Edit route settings`

![tailscale-edit](/images/2024-08-14-18-07-38.png)

## `Subnet routes`와 `Exit node`를 체크한다

![tailscale-option](/images/2024-08-14-18-08-24.png)

## 외부에서 사용할 PC의 `exit nodes`를 컨테이너로 지정해준다

![tailscale-exit](/images/2024-08-14-18-10-51.png)

# 기타 명령어

```
# 등록 상태
tailscale status

# 컨테이너의 tailscale 구동 중지
tailscale down

# ping
tailscale ping {Tailscale에서 발급해준 IP}
```

# 참고URL

- https://tailscale.com/kb/1019/subnets#enable-ip-forwarding
- https://tailscale.com/kb/1019/subnets#advertise-subnet-routes
- https://tailscale.com/kb/1130/lxc-unprivileged?q=unpri
- https://www.youtube.com/watch?v=QJzjJozAYJo

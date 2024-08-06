---
title: "OPENSTACK 2024.1 설치 + VirtualBox"
categories: Devops
tags: openstack microstack devstack
last_modified_at: 2024-08-06T08:00:00+09:00
classes: wide
# toc: true
# toc_sticky: true
---

# OPENSTACK 2024.1 설치 + VirtualBox

- Microstack, Devstack 모두 설치해 보았지만 성공하지 못했다
- 정확히 말하자면 절반의 성공이었다
- 그러던 와중에 Microstack이 실패한 원인을 찾던 중 계정이 제대로 생성이 되지 않은것을 발견했다
- 어쩌면 Openstack도 계정이 정해져 있는게 아닐까? 라는 추론을 했고
- 여러번의 시행착오 끝에 계정명이 핵심이란 것을 알았다

## Ubuntu 22.04.4 LTS (Jammy Jellyfish) 다운로드

[ubuntu-22.04.4-live-server-amd64.iso](https://ubuntu.com/download/server/thank-you?version=22.04.4&architecture=amd64&lts=true)

## VirtualBox Host전용 네트워크 세팅

도구 - 네트워크 - 만들기

- 수동으로어댑터 설정
- IPv4 : 192.168.56.1
- IPv4 서브넷 마스크 : 255.255.255.0

## VirtualBox VM 만들기

- ubuntu-22.04.4-live-server-amd64.iso 지정
- ✅ 무인설치 건너뛰기
- 메모리 : 8096 MB
- 프로세서 : 8개
- 지금 새 가상 하드디스크 만들기 : 100GB, ✅ 미리 전체크기 할당

## VirtualBox VM 설정

시스템 - 프로세서

- ✅ 네스티드 VT-x
- 네트워크 어댑터1 : `NAT`
- 네트워크 어댑터2 : `호스트전용 어댑터` (무작위모드 `허용`)

## VirtualBox VM 시작

- 언어/키보드 : `모두 영어`
- 네트워크 : `기본설정 그대로`
- 사용자명 : `ubuntu` **_(반드시 ubuntu로 해야 됨!!!!)_**
- ✅ Install OpenSSH Server

## Ubuntu 기본 세팅

업데이트

```
sudo apt update -y
sudo apt upgrade -y
sudo apt-get update -y
sudo apt-get upgrade -y
```

메모리 Swap

```
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Swap 적용(부팅 시)

```
#sudo vi /etc/fstab
/swapfile              none            swap    sw              0       0
```

## Openstack 설치

```
sudo snap install openstack --channel 2024.1/edge
sunbeam prepare-node-script | bash -x && newgrp snap_daemon
sunbeam cluster bootstrap --accept-defaults

#이걸 빼먹으면 안된다
sunbeam openrc > admin_openrc

#관리자용 정보가 나온다
cat admin_openrc

#잘되었나 확인해보자1
source admin_openrc
openstack catalog list
openstack hypervisor list --long
openstack server list --all-projects

#잘되었나 확인해보자2
juju status
#please enter password for node07.maas on sunbeam-controller: 가 나오는 경우
#이 파일의 비밀번호를 입력하면 된다
cat ~/snap/openstack/current/account.yaml
```

## 데모 Instance 생성

```
sunbeam configure --accept-defaults --openrc demo-openrc
sunbeam launch ubuntu --name test
```

## Ubuntu instance 접속

```
ssh -i /home/ubuntu/snap/openstack/current/sunbeam ubuntu@10.20.20.15
```

## 호스트PC에서 Openstack Dashboard 접속

```
sunbeam dashboard-url
http://10.20.21.13/openstack-horizon
```

admin으로 접속하려 할 때(계정정보)

```
cat ~/admin_openrc
```

demo로 접속하려 할 때(계정정보)

```
cat ~/demo-openrc
```

10.20.21.13은 Openstack의 가상 IP이므로

호스트에서 접속하려면 Openstack이 설치된 VM으로 접근 할 수 있는 IP로 라우팅해준다

호스트의 명령프롬프트에서 아래를 입력한다

```
route add 10.20.21.0/24 192.168.56.120  -p
```

## 호스트PC에서 Ubuntu Instance 접속

위와 마찬가지로 VM으로 접근 할 수 있는 IP로 라우팅해준다

```
route add 10.20.20.0/24 192.168.56.120  -p //instance
ssh -i /home/ubuntu/snap/openstack/current/sunbeam ubuntu@10.20.20.15
```

---

# Windows 10 이미지 생성

- Hyper-V가 활성화
- Windows Assessment and Deployment Kit 설치
- [Stable virtio-win ISO](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md)
- Windows Image

## PowerShell 실행

```powershell
git clone https://github.com/cloudbase/windows-openstack-imaging-tools.git
pushd windows-openstack-imaging-tools
Import-Module .\WinImageBuilder.psm1
Import-Module .\Config.psm1
Import-Module .\UnattendResources\ini.psm1
```

```powershell
$ConfigFilePath = ".\config.ini"
New-WindowsImageConfig -ConfigFilePath $ConfigFilePath
```

config.ini

```ini
[DEFAULT]
# The location of the WIM file from the mounted Windows ISO.
wim_file_path=E:\Sources\install.wim
# This is the complete name of the Windows version that will be generated.
# In order to find the possible options, use the Get-WimFileImagesInfo command
# and look for the Name property.
image_name=Windows 10 Pro
# The destination of the generated image.
image_path=D:\qcow2\win-10-pro.qcow2
# Select between VHD, VHDX, QCOW2, VMDK or RAW formats.
virtual_disk_format=QCOW2
# This parameter allows to choose between MAAS, KVM, VMware and Hyper-V specific images.
# For HYPER-V, cloudbase-init will be installed and the generated image should be in vhd or vhdx format.
# For MAAS, in addition to cloudbase-init, the curtin tools are installed
# and the generated image should be in raw.tgz format.
# For KVM, in addition to cloudbase-init, the VirtIO drivers are installed
# and the generated image should be in qcow2 format.
image_type=KVM
# This parameter can be set to either BIOS or UEFI.
disk_layout=BIOS
# The product key for the selected OS. If the value is default_kms_key and the Windows image is
# ServerStandard or ServerDatacenter (Core), the appropiate KMS key will be used.
product_key=""
# A comma separated array of extra features that will be enabled on the resulting image.
# These features need to be present in the ISO file.
extra_features=""
# A comma separated array of extra capabilities that will be enabled on the resulting image.
# These capabilities need to be present in the ISO file.
extra_capabilities=""
# It will force the image generation when RunSysprep is False or the selected SwitchName
# is not an external one. Use this parameter with caution because it can easily generate
# unstable images.
force=False
# If set to true, MAAS Windows curtin hooks will be copied to the image root directory.
install_maas_hooks=False
# Select between tar, gz, zip formats or any combination between these.
compression_format=""
# If this parameter is set, after the image is generated,
# a password protected zip archive with the image will be created.
# compression_format must contain zip in order for this parameter to be used
zip_password=""
# It will stop the image generation after the updates are installed and cleaned.
gold_image=False
# This is the full path of the already generated golden image.
# It should be a valid VHDX path.
gold_image_path=""
# This is a full path to the VMware-tools.exe version that you want to install.
vmware_tools_path=""
# If set to true, .NET Framework 3.5 will be installed before the windows updates.
# This feature applies only ot Windows server 2012 R2.
install_net_3_5=False
# This is the full path of a folder with custom resources which will be used by
# the custom scripts.
# The resources found at this path will be copied recursively to the image
# UnattendResources\CustomResources folder.
custom_resources_path=""
# This is the full path of the folder which can contain a set of PS scripts,
# that will be copied and executed during the online generation part on the VM.
# The PowerShell scripts, if existent, will be started by Logon.ps1 script,
# at different moments during image generation.
# The purpose of these scripts is to offer to the user a fully
# customizable way of defining additional logic for tweaking the final image.
# The scripts files can have the following names: RunBeforeWindowsUpdates.ps1,
# RunAfterWindowsUpdates.ps1, RunBeforeCloudbaseInitInstall.ps1, RunAfterCloudbaseInitInstall.ps1,
# RunBeforeSysprep.ps1, RunAfterSysprep.ps1.
# The script names contain the information on when the script will be executed.
# One can define only some of the hook scripts and it is not mandatory to define all of them.
# If a script does not exist, it will not be executed.
custom_scripts_path=""
# If set to true the Administrator account will be enabled on the client
# versions of Windows, which have the Administrator account disabled by default
enable_administrator_account=True
# Whether to shrink the image partition and disk after the image generation is complete.
shrink_image_to_minimum_size=True
# If set to true, a custom wallpaper will be set according to the values of configuration options
# wallpaper_path and wallpaper_solid_color
enable_custom_wallpaper=False
# If set, it will replace the Cloudbase Solutions wallpaper to the one specified.
# The wallpaper needs to be a valid .jpg/.jpeg image.
wallpaper_path=""
# If set, it will replace the Cloudbase Solutions wallpaper to a solid color.
# Currently, the only allowed solid color is '0 0 0' (black).
# If both wallpaper_path and wallpaper_solid_color are set,
# the script will throw an error.
wallpaper_solid_color=""
# If set, the animation displayed during the first login on Windows Client versions will be disabled.
disable_first_logon_animation=False
# If set to true and the target image format is QCOW2, the image conversion will
# use qemu-img built-in compression. The compressed qcow2 image will be smaller, but the conversion
# will take longer time.
compress_qcow2=True
# If set to true, during final cleanup, https://github.com/felfert/ntfszapfree will be used to zero unused space.
# This helps qemu-img to minimize image size. In order to benefit from this, an additional invocation
# of qemu-img convert must be performed after the initial run of the image has shutdown.
zero_unused_volume_sectors=False
# A comma separated list of extra packages (referenced by filepath)
# to slipstream into the underlying image.
# This allows additional local packages, like security updates, to be added to the image.
extra_packages=""
# Ignore failures from DISM when installing extra_packages, such as when
# updates are skipped which are not applicable to the image.
extra_packages_ignore_errors=False
# Enables shutdown of the Windows instance from the logon console.
enable_shutdown_without_logon=True
# If set to true, firewall rules will be added to enable ping requests (ipv4 and ipv6).
enable_ping_requests=True
# If set to true, use EUI-64 derived IDs and disable privacy extensions for IPv6.
# If set to false, the IPv6 protocol might not work on OpenStack or CloudStack.
# See https://github.com/cloudbase/windows-openstack-imaging-tools/issues/192
enable_ipv6_eui64=False
# If set to true, it will set the High Performance mode and some power mode
# and registry tweaks to prevent the machine from sleeping / hibernating.
enable_active_mode=False
[vm]
# This will be the Administrator user's, so that AutoLogin can be performed on the instance,
# in order to install the required products,
# updates and perform the generation tasks like sysprep.
administrator_password=Pa$$w0rd
# Used to specify the virtual switch the VM will be using.
# If it is specified but it is not external or if the switch does not exist,
# you will get an error message.
external_switch=external
# The number of CPU cores assigned to the VM used to generate the image.
cpu_count=4
# RAM (in bytes) assigned to the VM used to generate the image.
ram_size=8589934592
# Disk space (in bytes) assigned to the boot disk for the VM used to generate the image.
disk_size=53687091200
# If set to true and the disk layout is UEFI, the secure boot firmware option will be disabled.
disable_secure_boot=False
[drivers]
# The path to the ISO file containing the VirtIO drivers.
virtio_iso_path=""
# The location where the VirtIO drivers are found.
# For example, the location of a mounted VirtIO ISO. VirtIO versions supported >=0.1.6.x
virtio_base_path="C:\windows-imaging-tools-master\images\virtio-win-0.1.240.iso"
# The location where additional drivers that are needed for the image are located.
drivers_path=""
[custom]
# Installs QEMU guest agent services from the Fedora VirtIO website.
# Defaults to 'False' (no installation will be performed).
# If set to 'True', the following MSI installer will be downloaded and installed:
# * for x86: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-qemu-ga/qemu-ga-win-100.0.0.0-3.el7ev/qemu-ga-x86.msi
# * for x64: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-qemu-ga/qemu-ga-win-100.0.0.0-3.el7ev/qemu-ga-x64.msi
# The value can be changed to a custom URL, to allow other QEMU guest agent versions to be installed.
# Note: QEMU guest agent requires VirtIO drivers to be present on the image.
install_qemu_ga=True
# Set a custom timezone for the Windows image.
time_zone="Korea Standard Time"
# Set custom ntp servers(space separated) for the Windows image
ntp_servers=""
[updates]
# If set to true, the latest updates will be downloaded and installed.
install_updates=False
# If set to true, will run DISM with /resetbase option. This will reduce the size of
# WinSXS folder, but after that Windows updates cannot be uninstalled.
purge_updates=False
# Clean up the updates / components by running a DISM Cleanup-Image command.
# This is useful when updates or capabilities are installed offline.
clean_updates_offline=False
# Clean up the updates / components by running a DISM Cleanup-Image command.
# This is useful when updates or other packages are installed when the instance is running.
clean_updates_online=True
[sysprep]
# Used to clean the OS on the VM, and to prepare it for a first-time use.
run_sysprep=True
# The path to the Unattend XML template file used for sysprep.
unattend_xml_path=UnattendTemplate.xml
# DisableSwap option will disable the swap when the image is generated and will add a setting
# in the Unattend.xml file which will enable swap at boot time during specialize step.
# This is required, as by default, the amount of swap space on Windows machine is directly
# proportional to the RAM size and if the image has in the initial stage low disk space,
# the first boot will fail due to not enough disk space. The swap is set to the default
# automatic setting right after the resize of the partitions is performed by cloudbase-init.
disable_swap=False
# In case the hardware on which the image is generated will also be the hardware on
# which the image will be deployed this can be set to true, otherwise the spawned
# instance is prone to BSOD.
persist_drivers_install=True
[cloudbase_init]
# This is a switch that allows the selection of Cloudbase-Init branches. If set to true, the
# beta branch will be used:
# https://cloudbase.it/downloads/CloudbaseInitSetup_<arch>.msi, where arch can be x86 or x64
# otherwise the stable branch will be used:
# https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_<arch>.msi, where arch can be x86 or x64
beta_release=False
# Serial log port for Cloudbase-Init.
# If set to null, the first serial port (if any) from the generation VM will be used
serial_logging_port=COM1
# If set, the Cloudbase-Init msi at this path will be used.
# The path needs to be a locally accessible file path.
msi_path=""
# If set, the cloudbase-init.conf is replaced with the file at the path.
cloudbase_init_config_path=""
# If set, the cloudbase-init-unattend.conf is replaced with the file at the path.
cloudbase_init_unattended_config_path=""
# If set, the Cloudbase-Init service will be run under Local System account.
# By default, a user named cloudbase-init with admin rights is created and used.
cloudbase_init_use_local_system=False
# If set, the Cloudbase-Init service startup type will be set to delayed-auto
cloudbase_init_delayed_start=False
```

```powershell
Set-IniFileValue -Path (Resolve-Path $ConfigFilePath) -Section "DEFAULT" `
                                      -Key "wim_file_path" `
                                      -Value "E:\Sources\install.wim"

New-WindowsOnlineImage -ConfigFilePath $ConfigFilePath
```

## VirtualBox VM 접속

scp 명령어로 win-10-pro.qcow2를 VM으로 보낸 뒤 image create를 한다

```shell
openstack image create --disk-format qcow2 --file win-10-pro.qcow2 win-10-pro --debug
```

**_반드시 Exceeded관련 오류가 날 것이다_**

왜냐하면 Openstack이 사용하는 Glance는 이미지를 관리하는 역할을 하는데

공식 문서에서는 `image-size-cap`이 1TB로 지정된다고 나와있지만

어째서인지 확인해보면 5GB로 지정되어있다

아래 명령어로 Openstack의 Glance 설정 정보를 확인 후 변경하자

```shell
juju debug-log -m openstack -i unit-glance-0 --replay
juju config -m openstack glance
juju config -m openstack glance image-size-cap
juju config -m openstack glance image-size-cap=1TB
```

**_이제 Windows Image를 Instance로 만들면 된다_**

## (번외) Windows를 Image를 만들기 번거롭다면 아래 링크를 통해 영문 윈도우 Image를 받을 수 있다

https://docs.bigstack.co/docs/downloads/cloud_image/

## 호스트PC가 아닌 (동일 네트워크 대역)PC에서 Windows RDP 접속

호스트PC에서 포트포워딩을 해준다

```cmd
netsh interface portproxy add v4tov4 listenaddress=172.30.1.52 listenport=3400 connectaddress=10.20.20.63 connectport=3389
```

다른PC에서 172.30.1.52:3400 으로 RDP를 접속한다

---

# VDI 용량 추가 (+LVM 볼륨 확장)

1. VirtualBox에서 용량을 증가시킨다
1. VM에 접속
1. 용량 조회 : `df -h` (증가 전 용량이 보임)
1. 빈공간이 확보되어 있는지 조회 : `sudo fdisk -l`
1. 볼륨 조회 : `sudo lsblk`
1. 그룹 조회 : `sudo pvscan`
1. 그룹 상세 조회 : `sudo vgdisplay`
1. 확장시킬 디바이스 경로 확인 : `sudo lvscan`
1. 확장(위의 경로를 100% 확장) : `sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv`
1. 용량,타입 조회 : `df -Th`
1. (ext4 타입) 용량 증가 : `sudo resize2fs /dev/ubuntu-vg/ubuntu-lv`

   (xfs 타입) 용량 증가 : `sudo xfs_growfs /dev/ubuntu-vg/ubuntu-lv`

1. 용량 조회 : `df -h`

---

# Openstack 관련 명령어

k8s

```
kubectl describe -n openstack pod glance-0
kubectl describe -n openstack pod horizon-0

kubectl exec -it -n openstack glance-0 -c glance-api -- /bin/bash
kubectl exec -it -n openstack horizon-0 -c horizon -- /bin/bash
kubectl exec -it -n openstack nova-0 -c nova-api -- /bin/bash
juju debug-log -m openstack -i unit-nova-0 --replay

kubectl logs -n openstack glance-0 -f
kubectl logs -n openstack horizon-0 -c horizon -f
kubectl logs -n openstack glance-0 -c glance-api -f

#재시작
kubectl rollout restart statefulset/glance -n openstack

kubectl exec -it -n openstack glance-0 -- /bin/bash
/charm/containers/glance-api/pebble/layers

#기본설정 확인
kubectl get statefulset glance -n openstack -o yaml
```

```
# 하위폴더의 yaml파일중에서 glance 찾기
sudo find / -name "*.yaml" | xargs grep "glance" | tee findresult2.log
sudo find ./ -name "*.py" | xargs grep "glance"
sudo find / -name "*.yaml" | xargs grep "image-size-cap" | tee findresult2.log
```

sunbeam log

```
~/snap/openstack/common/logs
```

# Microstack 관련 명령어

```
sudo snap start microstack
sudo snap restart microstack
sudo snap remove microstack


sudo apt update -y
sudo apt upgrade -y

sudo apt-get update -y
sudo apt-get upgrade -y

sudo snap install microstack --devmode --beta

sudo snap get microstack config.credentials.keystone-password | tee ~/keystone.bak
sudo snap set microstack config.credentials.keystone-password=a123456A

sudo microstack init --auto --control --setup-loop-based-cinder-lvm-backend --loop-device-file-size 50
sudo tee /var/snap/microstack/common/etc/cinder/cinder.conf.d/glance.conf <<EOF
[DEFAULT]
glance_ca_certificates_file = /var/snap/microstack/common/etc/ssl/certs/cacert.pem
EOF

sudo snap restart microstack.cinder-{uwsgi,scheduler,volume}


#nginx conf proxytimeout 증가
sudo vi /var/snap/microstack/common/etc/nginx/snap/nginx.conf

proxy_connect_timeout 300s;
proxy_read_timeout 600s;
proxy_send_timeout 600s;

/var/snap/microstack/common/log/nginx-access.log
/var/snap/microstack/common/log/nginx-error.log

###########이게 된다고?
snapctl start microstack.
```

오류를 찾게된 계기

```
[안해도됨]계정생성
    sudo adduser openstackuser
    echo "openstackuser ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
    sudo -u openstackuser -i

[안해도됨]오류나서 reboot
    openstackuser로 다시 로그인
    sunbeam prepare-node-script | bash -x && newgrp snap_daemon 했더니 그룹추가하라고 함
    sudo usermod -a -G snap_daemon openstackuser
    sudo reboot
```

# 기타 명령어

```
계정 sudo 없이
    #chmod 640 /etc/sudoers
    #vi /etc/sudoers 또는 sudo visudo -f /etc/sudoers
    #제일 하단에 위치시켜야 최종적으로 적용됨
    takeubuntu    ALL=NOPASSWD:   ALL
    #chmod 440 /etc/sudoers

    또는 파일을 추가한다
    echo "takeubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/takeubuntu

SSH 설정
    # /etc/ssh/sshd_config
    PubkeyAuthentication yes
    AuthorizedKeysFile
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    UsePAM no

SSH용 인증서 생성
    ssh-keygen -m PEM -b 4096 -f ~/.ssh/id_rsa -t rsa -N ""

    #인증서 등록
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

IP
    $(hostname -I)
    $(hostname --all-ip-address)
    ip a

    ssh-keyscan -H $(hostname -I) >> ~/.ssh/known_hosts

네트워크
    cd /etc/netplan

    # 수정 전 백업
    mv 00-installer-config.yaml 00-installer-config.yaml.bak

    # 설정파일 편집
    sudo vi /etc/netplan/00-installer-config.yaml

    # 적용
    sudo netplan apply

    아이피 192.168.56.115
    서브넷마스크 255.255.255.0
    브로드캐스트 192.168.56.255

    grep -E 'HTTPS?_PROXY' /etc/environment
```

# 참고URL

- FAQ : https://app.element.io/#/room/#openstack-sunbeam:ubuntu.com
- openstack cli : https://natony.tistory.com/7
- windows image
  - https://yooniks9.medium.com/openstack-create-windows-server-2016-2019-image-iso-29d9ec877a3b
  - https://yooniks9.medium.com/openstack-install-windows-server-2016-2019-with-image-iso-d8c17c8cfc36
  - https://docs.bigstack.co/docs/downloads/cloud_image/
- virtualbox 용량 : https://aeong-dev.tistory.com/6

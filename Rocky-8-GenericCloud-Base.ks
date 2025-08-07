# Platform setup
text
lang en_US.UTF-8
keyboard us
timezone UTC --isUtc

# Bootloader config
bootloader --location=mbr --boot-drive=nvme0n1 --append="console=ttyS0,115200 console=tty0 crashkernel=auto"

# Network config
network --bootproto=dhcp --device=link --activate --onboot=on
network --hostname=rocky.localdomain

# Security settings
auth --enableshadow --passalgo=sha512
selinux --enforcing
firewall --enabled --service=ssh
firstboot --disable

# Partitioning for RAID
# Clear both disks
clearpart --all --initlabel
ignoredisk --only-use=nvme0n1,nvme1n1

# Create partitions on each drive
part raid.01 --size=1024 --ondisk=nvme0n1
part raid.02 --size=1024 --ondisk=nvme1n1

part raid.11 --size=8192 --ondisk=nvme0n1
part raid.12 --size=8192 --ondisk=nvme1n1

part raid.21 --size=8192 --grow --ondisk=nvme0n1
part raid.22 --size=8192 --grow --ondisk=nvme1n1

# Create RAID arrays
raid /boot --device=md0 --level=1 --fstype=xfs raid.01 raid.02
raid /     --device=md1 --level=1 --fstype=xfs raid.11 raid.12
raid /var  --device=md2 --level=1 --fstype=xfs raid.21 raid.22

shutdown
url --url https://download.rockylinux.org/stg/rocky/8/BaseOS/$basearch/os/

%packages
@core
chrony
dnf
yum
cloud-init
cloud-utils-growpart
NetworkManager
dracut-config-generic
dracut-norescue
firewalld
gdisk
grub2
kernel
nfs-utils
rsync
tar
dnf-utils
yum-utils
-aic94xx-firmware
-alsa-firmware
-alsa-lib
-alsa-tools-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-libertas-sd8686-firmware
-libertas-sd8787-firmware
-libertas-usb8388-firmware
-biosdevname
-iprutils
-plymouth

python3-jsonschema
qemu-guest-agent
dhcp-client
cockpit-ws
cockpit-system
-langpacks-*
-langpacks-en

rocky-release
rng-tools
%end


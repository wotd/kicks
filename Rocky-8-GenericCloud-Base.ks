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

# Wipe and initialize disks
zerombr
clearpart --all --initlabel --drives=nvme0n1,nvme1n1

# Partitioning for RAID
part /boot --fstype="xfs" --size=1024 --ondisk=nvme0n1
part /boot --fstype="xfs" --size=1024 --ondisk=nvme1n1

part raid.01 --size=10240 --grow --ondisk=nvme0n1
part raid.02 --size=10240 --grow --ondisk=nvme1n1

part raid.11 --size=4096 --ondisk=nvme0n1
part raid.12 --size=4096 --ondisk=nvme1n1

raid / --device=md0 --level=1 --fstype=xfs raid.01 raid.02
raid /var --device=md1 --level=1 --fstype=xfs raid.11 raid.12

# Root password (locked)
rootpw --iscrypted thereisnopasswordanditslocked

# Services
services --enabled="sshd,chronyd,rsyslog,NetworkManager,cloud-init" --disabled="kdump"

# Install source
url --url=https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/

# Package selection
%packages
@core
chrony
dnf
yum
cloud-init
cloud-utils-growpart
dracut-config-generic
dracut-norescue
gdisk
grub2
kernel
nfs-utils
rsync
tar
cockpit
cockpit-system
cockpit-ws
rng-tools
NetworkManager
qemu-guest-agent
-aic94xx-firmware
-alsa-*
-iwl*-firmware
-libertas-*
-biosdevname
-plymouth
-langpacks-*
-langpacks-en
%end

# Post-installation
%post --erroronfail
# Disable root password and lock it
passwd -d root
passwd -l root

# Disable firstboot
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

# Console settings
sed -i 's/console=tty0/console=tty0 console=ttyS0,115200n8/' /boot/grub2/grub.cfg

# Networking config
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

# Cloud-init tweaks
sed -i '1i # Modified for cloud image' /etc/cloud/cloud.cfg
sed -i 's/name: cloud-user/name: rocky/g' /etc/cloud/cloud.cfg
echo -e 'rocky\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers

# Machine ID reset
truncate -s 0 /etc/machine-id

# Set default target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# Clean up logs
rm -rf /root/anaconda-ks.cfg /var/log/anaconda/*

%end

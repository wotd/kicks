# Platform setup
text
lang en_US.UTF-8
keyboard us
timezone UTC --isUtc

# Bootloader config
bootloader --location=mbr --boot-drive=nvme0n1 --driveorder=nvme0n1,nvme1n1 --append="console=ttyS0,115200 console=tty0 crashkernel=auto"

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
@^minimal-environment
chrony
wget
curl
vim
%end

%post
echo "Post install config here" > /root/postinstall.log
%end
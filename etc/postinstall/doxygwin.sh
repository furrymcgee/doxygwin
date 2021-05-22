#!/bin/bash
cygrunsrv -L | xargs -t -r -L1 cygrunsrv -R
sed -i /etc/fstab -e /^none/s/posix=0/posix=1/ -e '$a//samba/share /mnt smbfs noacl 0 0' 
ssh-host-config --yes --pwd cyg_server 
pwd
make -C /etc/postinstall
mkdir /var/cache/dwww
crontab -l | cut -f2- | sh

net start cygserver
net start httpd
net start sshd
net start cron

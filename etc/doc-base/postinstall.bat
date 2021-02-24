@ECHO OFF
ECHO %~n0: start ssh server and make config
SET X=%~dp0

c:/doxygwin/bin/bash -l -c "cygrunsrv -L | xargs -t -r -L1 cygrunsrv -R"
c:/doxygwin/bin/bash -l -c "sed -i /etc/fstab -e /^none/s/posix=0/posix=1/ -e '$a//samba/share /mnt smbfs noacl 0 0'"
c:/doxygwin/bin/bash -l -c "ssh-host-config --yes --pwd cyg_server"
c:/doxygwin/bin/bash -l -c "cygpath '%X:\=\\%' | xargs -t make -C"

net start cygserver
net start httpd
net start sshd
net start cron

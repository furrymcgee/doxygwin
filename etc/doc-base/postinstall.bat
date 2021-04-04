@ECHO OFF
ECHO %~n0: start ssh server and make config
SET X=%~dp0

(
c:\doxygwin\bin\bash -l -c "cygrunsrv -L | xargs -t -r -L1 cygrunsrv -R 2>&1"
c:\doxygwin\bin\sed -i /etc/fstab -e /^none/s/posix=0/posix=1/ -e '$a//samba/share /mnt smbfs noacl 0 0' 
c:\doxygwin\bin\bash -l ssh-host-config --yes --pwd cyg_server 2>&1 
c:\doxygwin\bin\bash -l -c "cygpath '%X:\=\\%' | xargs -t make -C 2>&1"
c:\doxygwin\bin\bash -l -c "mkdir /var/cache/dwww && crontab -l | cut -f2- | sh"
) | ^
c:\doxygwin\bin\sed 's/$/\x0D/'


net start cygserver
net start httpd
net start sshd
net start cron

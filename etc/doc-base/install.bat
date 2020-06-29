ECHO.
ECHO %~n0: start ssh server and install documents
SET X=%~dp0
c:/doxygwin/bin/bash -l -c "sed -i /etc/fstab -e /^none/s/posix=0/posix=1/ -e '$a//samba/share /mnt smbfs noacl 0 0'"
c:/doxygwin/bin/bash -l -c "make -C \"$( cygpath '%X:\=\\%' )\""
c:/doxygwin/bin/bash -l -c "ssh-host-config --yes && cygrunsrv -S sshd"
exit /b

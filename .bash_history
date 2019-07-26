net use z: \\\\samba\\share
cygserver-config 
cygrunsrv.exe -L
ps -ef
cygserver-config -h
cygserver-config --yes --debug
cygrunsrv.exe -L
ps -ef
sed     -i /etc/httpd/conf/httpd.conf     -e /#ServerName/aServerName\ 192.168.33.152     -e /slotmem_shm_module/s/^#//     -e /cgi_module/s/#//
cygrunsrv.exe -S cygserver
ps -ef
cygrunsrv -I apache2 -p /usr/sbin/httpd
cygrunsrv.exe -S apache2
tail /var/log/httpd/error_log 
cygrunsrv.exe -R apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -x -X
cygrunsrv.exe -R apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -X
cygrunsrv.exe -L
cygrunsrv.exe -Q apache2
/usr/sbin/httpd.exe -h
/usr/sbin/httpd.exe -t
/usr/sbin/httpd.exe -L
/usr/sbin/httpd.exe -L
cygrunsrv.exe -L
ps -ef
history
cygrunsrv.exe -E apache2
ps -ef
cygrunsrv.exe -E apache2
ps -ef
pidof httpd | xargs -r kill
ps -ef
cygrunsrv.exe -S apache2
ps -ef
cygrunsrv.exe -E apache2
cygrunsrv.exe -Q apache2
cygrunsrv.exe -R apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -DONE_PROCESS
cygrunsrv.exe -S apache2
ps -ef
ps -ef
cygrunsrv.exe -E apache2
ps -ef
cygrunsrv.exe -Q apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
cygrunsrv.exe -S apache2
cygrunsrv.exe -R apache2
ps -ef
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -DONE_PROCESS
cygrunsrv.exe -S apache2
cygrunsrv.exe -E apache2
ls /var/run/
ls /var/run/ -la/
ls /var/run/httpd/
rm /var/run/httpd/httpd.pid 
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
ps -ef
cygrunsrv.exe -S apache2
ps -ef
ps -ef
ps -ef
ps -ef
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -h
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
cygrunsrv.exe -S apache2
ps -ef
more /var/run/httpd/httpd.pid 
ps -ef
tail /var/log/httpd/error_log 
cygrunsrv.exe -R apache2
ps -ef
rm /var/run/httpd/httpd.pid 
rm /var/run/httpd/httpd.pid 
rm /var/run/httpd/httpd.pid 
cygrunsrv.exe -S apache2
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
cygrunsrv.exe -S apache2
ps -ef
more /var/run/httpd/httpd.pid 
tail /var/log/httpd/error_log 
cygrunsrv.exe -E apache2
cygrunsrv.exe -E apache2
cygrunsrv.exe -E apache2
cygrunsrv.exe -R apache2
rm /var/run/httpd/httpd.pid 
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -DONE_PROCESS
cygrunsrv.exe -S apache2
ps -ef
tail /var/log/httpd/error_log 
cygrunsrv.exe -E cygserver
cygrunsrv.exe -E cygserver
cygrunsrv.exe -S cygserver
cygrunsrv.exe -S cygserver
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -DONE_PROCESS
cygrunsrv.exe -S apache2
tail /var/log/httpd/error_log 
ps -ef
cygrunsrv.exe -E apache2
cygrunsrv.exe -E cygserver
cygrunsrv.exe -R apache2
cygrunsrv.exe -S cygserver
cygrunsrv.exe -I apache2 -p /usr/sbin/httpd -x /var/run/httpd/httpd.pid -a -DONE_PROCESS
cygrunsrv.exe -S apache2
ps -ef
cygrunsrv.exe -E cygserver
cygrunsrv.exe -S cygserver
ls
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -R apache2
cygrunsrv.exe -E apache2
cygrunsrv.exe -E apache2
cygrunsrv -I apache2 -p /usr/sbin/httpd -a -DONE_PROCESS
cygrunsrv.exe -S cygserver
ps -ef
cygrunsrv.exe -Q apache2
cygrunsrv.exe -S cygserver
cygrunsrv.exe -S apache2
ps -ef
mount
mount \\\\samba\\share /mnt -o noacl
mount
mkdir /etc/apache2/conf-enabled
ln -s /etc/apache2/conf-{available,enabled}/dwww.conf
httpd --help
/usr/sbin/httpd.exe -h
/usr/sbin/httpd.exe -v
/usr/sbin/apachectl -h
/usr/sbin/apachectl -t
cd /mnt/cygwin-dwww/
ls
more Makefile 
ls
vim Makefile 
make
fg
make
fg
ls
more Makefile 
ls dwww/
fg
ls
more swish++/
ls swish++/
ls swish++/
vim swish++/README
ls swish++/
fg
ls
ls doc-base/
fg
make -n
make -n --debug
fg
make -n --debug
make -n
fg
make -n --debug
ls
fg
make -n
fg
make -n
make -n --debug
fg
make
cd publib/
git clean -dix
cd -
tmux a
tmux
fg

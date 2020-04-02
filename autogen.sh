#!/bin/sh
# This script builds https://github.com/furrymcgee/doxie-search
# First submodules are patched then make is called
# build tar --clamp-time 

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

git config core.filemode false
git submodule foreach git config core.filemode false
git submodule update --init --force --checkout

cat \
0001-cygwin.patch.~1~ \
0002-samba.patch \
| \
GIT_WORK_TREE=sensible-utils GIT_DIR=sensible-utils/.git git am

cat \
0001-index-on-no-branch-fa850df-Bump-version-to-0.25.0.patch \
| \
GIT_WORK_TREE=cygport GIT_DIR=cygport/.git git am

cat \
0001-index-on-no-branch-d7885fe-Fix-check-for-attempt-to-.patch \
| \
GIT_WORK_TREE=calm GIT_DIR=calm/.git git am

cat \
0001-fixup-Release-1.19.7.patch \
0002-error-cannot-get-project-version.patch \
0003-dpkg-architecture.pl-error-dpkg-print-architecture-f.patch \
0004-error-Unknown-architecture-cannot-build-start-stop-d.patch \
0005-fixup-libcompat-Only-test-the-strerror-if-sys_errlis.patch \
0006-dpkg-genbuildinfo-warning-unknown-CC-system-type-i68.patch \
0007-dpkg-genbuildinfo-error-cannot-open-var-lib-dpkg-sta.patch \
0008-dpkg-error-requested-operation-requires-superuser-pr.patch \
| \
GIT_WORK_TREE=dpkg GIT_DIR=dpkg/.git git am

cat \
0001-dpkg-architecture-warning-unknown-CC-system-type-i68.patch \
| \
GIT_WORK_TREE=debhelper GIT_DIR=debhelper/.git git am

GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git config core.filemode false
cat \
0001-apt-get-install-cvs2svn-cvs.patch \
0002-mkdir-cannot-create-directory-_-usr_-Read-only-file-.patch \
0003-Package-docx2txt.patch \
| \
GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git am

cat \
0001-cygwin.patch.~2~ \
0002-usr-bin-install-missing-destination-file-operand-aft.patch \
0003-doc.patch.~1~ \
| \
GIT_WORK_TREE=swish++ GIT_DIR=swish++/.git git am

rm -rf debconf/debconf debconf/Debconf
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git config core.symlinks false
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git config core.filemode false
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git checkout Debconf

cat \
0001-munge.patch \
0002-No-candidate-position-for-the-addendum.patch \
0003-prefix.patch \
| \
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git am

cat \
0001-e6b3ba4-dh_testroot-root_requirements-no-longer-read.patch \
0002-Can-t-exec-dh_strip_nondeterminism-No-such-file-or-d.patch \
| \
GIT_WORK_TREE=dh-autoreconf GIT_DIR=dh-autoreconf/.git git am

cat \
0001-cygwin.patch.~3~ \
0002-root.patch \
0003-doc.patch \
0004-error.patch \
| \
GIT_WORK_TREE=doc-base GIT_DIR=doc-base/.git git am

cat \
0001-cygwin.patch \
0002-httpd.patch \
0003-libpub.a.patch \
0004-pdf.patch \
0005-doc.patch \
0006-xls.patch \
0007-convert.patch \
0008-type.patch \
0009-redirect.patch \
0010-cgi.patch \
0011-fileparse.patch \
0012-msg.patch \
0013-doxie.patch \
0014-revert.patch \
0015-distributor.patch \
| \
GIT_WORK_TREE=dwww GIT_DIR=dwww/.git git am

cat \
0001-usr-bin-install-cannot-stat-.-fakeroot.1-No-such-fil.patch \
0002-i686-pc-cygwin.patch \
| \
GIT_WORK_TREE=fakeroot GIT_DIR=fakeroot/.git git am

net user www-data /ADD || true

xargs -t -L1 make \
DISTRIBUTOR=doxie \
PERL5LIB=/usr/share/perl5 \
DH_COMPAT=10 \
prefix=/usr \
<<-'MAKE'
	-B tar/configure
	tar
	install -C tar
	dpkg/configure dpkg
	install -C dpkg
	~/.cpan
	install -C debhelper
	intltool-debian
	install -C intltool-debian
	publib/configure
	publib
	install -C publib
	doc-base
	install -C doc-base
	debconf
	install -C debconf
	swish++
	install -C swish++
	dwww
	install -C dwww
	po-debconf
	/var/cache/debconf /var/lib/doc-base/documents
MAKE


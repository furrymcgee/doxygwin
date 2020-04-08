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

GIT_WORK_TREE=dpkg GIT_DIR=dpkg/.git git am < dpkg.patch

GIT_WORK_TREE=debhelper GIT_DIR=debhelper/.git git am < debhelper.patch

GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git config core.filemode false

GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git am < docx2txt.patch

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

GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git am < debconf.patch

GIT_WORK_TREE=dh-autoreconf GIT_DIR=dh-autoreconf/.git git am < dh-autoreconf.patch

GIT_WORK_TREE=doc-base GIT_DIR=doc-base/.git git am < doc-base.patch

GIT_WORK_TREE=dwww GIT_DIR=dwww/.git git am < dwww.patch

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


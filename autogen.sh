#!/bin/sh
# This script builds https://github.com/furrymcgee/doxygwin
# First submodules are patched then make is called

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

git config core.filemode false
git submodule foreach git config core.filemode false
git submodule update --init --force --checkout

GIT_WORK_TREE=sensible-utils GIT_DIR=sensible-utils/.git git am < sensible-utils.patch

GIT_WORK_TREE=cygport GIT_DIR=cygport/.git git am < cygport.patch

GIT_WORK_TREE=calm GIT_DIR=calm/.git git am < calm.patch

GIT_WORK_TREE=dpkg GIT_DIR=dpkg/.git git am < dpkg.patch

GIT_WORK_TREE=debhelper GIT_DIR=debhelper/.git git am < debhelper.patch

GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git config core.filemode false

GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git am < docx2txt.patch

GIT_WORK_TREE=swish++ GIT_DIR=swish++/.git git am < swish++.patch

rm -rf debconf/debconf debconf/Debconf

GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git config core.symlinks false
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git config core.filemode false
GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git checkout Debconf

GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git am < debconf.patch

GIT_WORK_TREE=dh-autoreconf GIT_DIR=dh-autoreconf/.git git am < dh-autoreconf.patch

GIT_WORK_TREE=doc-base GIT_DIR=doc-base/.git git am < doc-base.patch

GIT_WORK_TREE=dwww GIT_DIR=dwww/.git git am < dwww.patch

GIT_WORK_TREE=fakeroot GIT_DIR=fakeroot/.git git am < fakeroot.patch

net user www-data /ADD || true

xargs -t -L1 make \
DISTRIBUTOR=doxygwin \
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


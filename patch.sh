#!/bin/sh

git submodule update

cat \
0001-cygwin.patch.~1~ \
0002-samba.patch \
| GIT_WORK_TREE=sensible-utils GIT_DIR=sensible-utils/.git git am

cat \
0001-index-on-no-branch-fa850df-Bump-version-to-0.25.0.patch \
| GIT_WORK_TREE=cygport GIT_DIR=cygport/.git git am

cat \
0001-index-on-no-branch-d7885fe-Fix-check-for-attempt-to-.patch \
| GIT_WORK_TREE=calm GIT_DIR=calm/.git git am

cat \
0001-fixup-Release-1.19.7.patch \
0002-error-cannot-get-project-version.patch \
0003-dpkg-architecture.pl-error-dpkg-print-architecture-f.patch \
0004-error-Unknown-architecture-cannot-build-start-stop-d.patch \
0005-fixup-libcompat-Only-test-the-strerror-if-sys_errlis.patch \
0006-dpkg-genbuildinfo-warning-unknown-CC-system-type-i68.patch \
0007-dpkg-genbuildinfo-error-cannot-open-var-lib-dpkg-sta.patch \
| GIT_WORK_TREE=dpkg GIT_DIR=dpkg/.git git am

cat \
0001-apt-get-install-cvs2svn-cvs.patch \
0002-mkdir-cannot-create-directory-_-usr_-Read-only-file-.patch \
0003-Package-docx2txt.patch \
| GIT_WORK_TREE=docx2txt GIT_DIR=docx2txt/.git git am

cat \
0001-cygwin.patch \
0002-usr-bin-install-missing-destination-file-operand-aft.patch \
0003-doc.patch \
| GIT_WORK_TREE=swish++ GIT_DIR=swish++/.git git am

cat \
0001-munge.patch \
| GIT_WORK_TREE=debconf GIT_DIR=debconf/.git git am

cat \
0001-e6b3ba4-dh_testroot-root_requirements-no-longer-read.patch \
0002-Can-t-exec-dh_strip_nondeterminism-No-such-file-or-d.patch \
| GIT_WORK_TREE=dh-autoreconf GIT_DIR=dh-autoreconf/.git git am

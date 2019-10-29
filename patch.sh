#!/bin/sh

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

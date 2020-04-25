#!/bin/sh
# This script builds https://github.com/furrymcgee/doxygwin
# First submodules are patched then make is called

git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config core.filemode false
git config core.symlinks false
git submodule foreach git config core.filemode false
git submodule update --init --force --checkout

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


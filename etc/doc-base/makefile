#!/usr/bin/make -f
# This makefile installs doxygwin documents
# https://github.com/furrymcgee/doxygwin

export DISTRIBUTOR?=default
export PERL5LIB?=/usr/share/perl5:/usr/lib/perl5/vendor_perl/5.22/i686-cygwin-threads-64int/Data
export DH_COMPAT?=10
export prefix?=/usr
export PATH:=/usr/sbin:$(PATH)
	
.DEFAULT_GOAL:=.

REQUISITES:=\
	/usr/local \
	/var/lib \
	/etc/httpd/conf/httpd.conf \
	/etc/xml/catalog \
	/etc/doc-base \
	/var/cache \

.PHONY: $(.DEFAULT_GOAL) $(REQUISITES) test

/etc/httpd/conf/httpd.conf:
	net user www-data /ADD || true
	sed \
		-i $@ \
		-e s/^#*ServerName\ .*/ServerName\ localhost/ \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//

/etc/xml/catalog:
	xmlcatalog --create > $@
	xmlcatalog --noout \
		--add rewriteURI \
		http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd \
		/usr/share/sgml/docbook/xml-dtd-4.5/docbookx.dtd $@
	xmlcatalog --noout \
		--add rewriteURI \
		http://docbook.sourceforge.net/release/xsl/current \
		/usr/share/sgml/docbook/xsl-stylesheets $@

/etc/doc-base: documents
	rsync -av $^ /etc/doc-base/
	find $@ \
		-type f \
		-newer $@/$^/README \
		-exec \
			install-docs --verbose --install {} \+

/usr/local: \
		../../bin/mailexplode \
		/usr/share/doc/libmime-tools-perl/examples/mimeexplode
	install --mode=755 --target-directory=$@/bin $^
	mkdir -p $@/share
	ln -s "$$(cygpath --mydocs)" $@/share/doc

/var/lib:
	mkdir -p \
		$@/doc-base/info \
		$@/doc-base/documents \
		$@/dpkg/updates \
		$@/dwww
	test -r $@/dpkg/status || \
	touch $@/dpkg/status

/var/cache: /etc/doc-base
	mkdir -p $@/dwww
	dwww-build
	dwww-build-menu
	dwww-refresh-cache
	dwww-index++ -v -f -- -v4

$(.DEFAULT_GOAL): $(REQUISITES)
	cygserver-config --yes \
		|| true
	cygrunsrv \
		-I httpd \
		-p /usr/sbin/httpd \
		-a -DONE_PROCESS \
		|| true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

test:
	REQUEST_METHOD=GET \
	QUERY_STRING=search='$@&programsubmit=Search&searchtype=d' \
	/srv/www/cgi-bin/dwww

dump:
	/usr/bin/search++ --config-file=/usr/share/dwww/swish++.conf --index-file=/var/cache/dwww/dwww.swish++.index --skip-results=0 -m 50 -D

#!/usr/bin/make -f
# This makefiles installs https://github.com/furrymcgee/doxygwin

export DISTRIBUTOR?=doxygwin
export PERL5LIB?=/usr/share/perl5
export DH_COMPAT?=10
export prefix?=/usr
	
.DEFAULT_GOAL:=.

REQUISITES:=\
	/etc/httpd/conf/httpd.conf \
	/etc/xml/catalog \
	/var/cache/debconf \
	/var/lib/doc-base/documents 

.PHONY: $(.DEFAULT_GOAL) $(REQUISITES)

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

/etc/httpd/conf/httpd.conf:
	sed \
		-i $@ \
		-e s/^#*ServerName\ .*/ServerName\ localhost/ \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//

/var/lib/doc-base/documents:
	mkdir $@ || true
	find documents/* | \
	xargs -r install -p --target-directory=/etc/doc-base/documents
	mkdir /usr/local/share /usr/local/share/doc || true
	find doc/* | \
	xargs -r install -p --target-directory=/usr/local/share/doc
	find /etc/doc-base/documents \
		-type f \
		-newer /etc/doc-base/documents/README | \
	xargs -r /usr/sbin/install-docs --verbose --install
	test -d /usr/var/lib/dpkg || \
	mkdir -p /usr/var/lib/dpkg
	test -r /usr/var/lib/dpkg/status || \
	touch /usr/var/lib/dpkg/status
	/usr/sbin/dwww-build
	/usr/sbin/dwww-build-menu
	/usr/sbin/dwww-refresh-cache
	/usr/sbin/dwww-index++ -v -f -- -v4

$(.DEFAULT_GOAL): $(REQUISITES)
	net user www-data /ADD || true
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes || true
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS || true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd


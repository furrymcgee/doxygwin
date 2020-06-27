#!/usr/bin/make -f
# This makefile installs doxygwin documents https://github.com/furrymcgee/doxygwin

export DISTRIBUTOR?=default
export PERL5LIB?=/usr/share/perl5:/usr/lib/perl5/vendor_perl/5.22/i686-cygwin-threads-64int/Data
export DH_COMPAT?=10
export prefix?=/usr
	
.DEFAULT_GOAL:=.

REQUISITES:=\
	~/.cpan \
	/etc/httpd/conf/httpd.conf \
	/etc/xml/catalog \
	/var/lib/doc-base \ 

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

~/.cpan: ../../CPAN/MyConfig.pm
	mkdir $@ $(shell dirname $@/$<) || true
	install --target-directory=$(shell dirname $@/$<) $<
	cpan -T \
		Encode
	find /usr/share/doc/libmime-tools-perl/examples/mimeexplode | \
	xargs install --mode=755 --target-directory=/usr/local/bin

/etc/httpd/conf/httpd.conf:
	net user www-data /ADD || true
	sed \
		-i $@ \
		-e s/^#*ServerName\ .*/ServerName\ localhost/ \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//

/var/lib/doc-base:
	mkdir \
		$@ \
		$@/documents \
		/var/cache/dwww \
		/var/lib/doc-base/info \
		/var/lib/dpkg \
		/var/lib/dpkg/updates \
		/var/lib/dwww \
	|| true
	find documents/* | \
	xargs -r -I@ \
		install -p --target-directory=/etc/doc-base/documents @
	mkdir /usr/local/share /usr/local/share/doc || true
	rsync -av doc/* /usr/local/share/doc/
	find /etc/doc-base/documents \
		-type f \
		-newer /etc/doc-base/documents/README | \
	xargs -I@ -r /usr/sbin/install-docs --verbose --install @
	test -r /var/lib/dpkg/status || \
	touch /var/lib/dpkg/status
	/usr/sbin/dwww-build
	/usr/sbin/dwww-build-menu
	/usr/sbin/dwww-refresh-cache
	/usr/sbin/dwww-index++ -v -f -- -v4

$(.DEFAULT_GOAL): $(REQUISITES)
	install --mode=755 --target-directory=/usr/local/bin ../../bin/mailexplode
	cygserver-config --yes \
		|| true
	cygrunsrv \
		-I httpd \
		-p /usr/sbin/httpd \
		-a -DONE_PROCESS \
		|| true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd


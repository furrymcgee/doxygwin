#!/usr/bin/make -f
# This script installs https://github.com/furrymcgee/doxygwin

.DEFAULT_GOAL:=.

export DISTRIBUTOR?=doxygwin
export PERL5LIB?=/usr/share/perl5
export DH_COMPAT?=10
export prefix?=/usr
	
ETC:=/var/cache/debconf /var/lib/doc-base/documents /usr

.PHONY: $(ETC) $(.DEFAULT_GOAL)

/usr:
	$(MAKE) -B tar/configure
	$(MAKE) tar
	$(MAKE) install -C tar
	$(MAKE) dpkg/configure dpkg
	$(MAKE) install -C dpkg
	$(MAKE) install -C debhelper
	$(MAKE) intltool-debian
	$(MAKE) install -C intltool-debian
	$(MAKE) publib/configure
	$(MAKE) publib
	$(MAKE) install -C publib
	$(MAKE) doc-base
	$(MAKE) install -C doc-base
	$(MAKE) debconf
	$(MAKE) install -C debconf
	$(MAKE) swish++
	$(MAKE) install -C swish++
	$(MAKE) dwww
	$(MAKE) install -C dwww
	$(MAKE) po-debconf
	$(MAKE) /var/cache/debconf /var/lib/doc-base/documents


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

/var/cache/debconf: dwww/debian/dwww.config
	mkdir $@ || true
	po-debconf/po2debconf --output $<.templates \
		dwww/debian/dwww.templates
	touch \
		$@/templates.dat \
		$@/passwords.dat \
		$@/config.dat
	echo "\
		unknown dwww/docrootdir string /var/www\
		unknown dwww/cgiuser    string Guest\
		unknown dwww/servername string localhost\
		unknown dwww/nosuchdir  note\
		unknown dwww/cgidir     string /usr/lib/cgi-bin\
		unknown dwww/badport    note\
		unknown dwww/index_docs boolean false\
		unknown dwww/nosuchuser note\
		unknown dwww/serverport string 80\
	" | \
	tr \\t \\n | \
	debconf-set-selections
	perl $<
	sed \
		-i /etc/httpd/conf/httpd.conf \
		-e s/^#*ServerName\ .*/ServerName\ 192.168.33.152/ \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//

$(.DEFAULT_GOAL): $(ETC)
	net user www-data /ADD || true
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes || true
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS || true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

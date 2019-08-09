
.DEFAULT_GOAL = .

SUBDIRS = publib doc-base debconf swish++ dwww 

CONFIGURE =  publib/configure sensible-utils/configure

ETC = ~/.cpan /etc/dwww /var/lib/doc-base/documents /etc/apache2 

.PHONY: $(.DEFAULT_GOAL) $(CONFIGURE) $(SUBDIRS) $(ETC)

$(.DEFAULT_GOAL): $(SUBDIRS) $(ETC)
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes --debug
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

$(CONFIGURE):
	cd $(shell dirname $@) && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin

$(SUBDIRS):
	DISTRIBUTOR=doxie $(MAKE) $(MAKECMDGOALS) --directory=$@

doc-base: /etc/xml/catalog sensible-utils/configure sensible-utils

publib: publib/configure

dwww:

~/.cpan: CPAN/MyConfig.pm
	mkdir $@ $(shell dirname $@/$<) || true
	install --target-directory=$(shell dirname $@/$<) $<
	cpan File::NCopy YAML::Tiny MIME::Tools UUID Email::Outlook::Message
	find ~/.cpan -name mimeexplode | \
	xargs install --mode=755 --target-directory=/usr/local/bin

/var/lib/doc-base/documents: /etc/dwww
	mkdir $@ || true
	cp -avu documents/* /etc/doc-base/documents
	cp -avu doc/* /usr/local/share/doc
	find /etc/doc-base/documents \
		-type f \
		-newer /etc/doc-base/documents/README | \
	xargs /usr/sbin/install-docs --verbose --install
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

/var/cache/debconf:
	mkdir $@ || true
	touch \
		$@/templates.dat \
		$@/passwords.dat \
		$@/config.dat
	echo "\
		unknown dwww/docrootdir string  /var/www \
		unknown dwww/cgiuser    string  Guest \
		unknown dwww/servername string  localhost \
		unknown dwww/nosuchdir  note \
		unknown dwww/cgidir     string  /usr/lib/cgi-bin \
		unknown dwww/badport    note \
		unknown dwww/index_docs boolean false \
		unknown dwww/nosuchuser note \
		unknown dwww/serverport string  80 \
	" | \
	tr \\t \\n | \
	debconf-set-selections

/etc/dwww: dwww/debian/dwww.config /var/cache/debconf
	mkdir $@ || true
	DEBIAN_FRONTEND=noninteractive perl $<
	sed \
		-i /etc/httpd/conf/httpd.conf \
		-e /#ServerName/aServerName\ 192.168.33.152 \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//


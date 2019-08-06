
.DEFAULT_GOAL = .

SUBDIRS = publib doc-base debconf swish++ dwww 

CONFIGURE =  publib/configure sensible-utils/configure

.PHONY: $(.DEFAULT_GOAL) $(CONFIGURE) $(SUBDIRS)

$(.DEFAULT_GOAL): $(SUBDIRS) ~/.cpan /etc/dwww /var/lib/doc-base/documents /etc/apache2 
	install --mode=755 --target-directory=/usr/local/bin mailexplode
	cygserver-config --yes --debug
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

$(CONFIGURE):
	cd $(shell dirname $@) && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin

$(SUBDIRS):
	$(MAKE) $(MAKECMDGOALS) --directory=$@

doc-base: /etc/xml/catalog sensible-utils/configure sensible-utils

publib: publib/configure

dwww: /etc/dwww

~/.cpan:
	mkdir ~/.cpan
	cp -av .cpan/CPAN ~/.cpan
	cpan File::NCopy YAML::Tiny MIME::Tools UUID Email::Outlook::Message
	find ~/.cpan -name mimeexplode | \
	xargs install --mode=755 --target-directory=/usr/local/bin

/var/lib/doc-base/documents:
	mkdir /var/lib/doc-base/documents
	cp -avu documents /etc/doc-base/documents
	cp -avu doc /usr/local/share/doc
	/usr/sbin/install-docs -v -i /etc/doc-base/documents/toolmonitor
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

/etc/dwww: dwww/debian/dwww.config
	mkdir $@
	install --target-directory=$@ $^

/etc/apache2:
	mkdir $@
	mkdir $@/conf-enabled
	ln -s ../conf/available/dwww-conf $@/conf-enabled
	sed \
		-i /etc/httpd/conf/httpd.conf \
		-e /#ServerName/aServerName\ 192.168.33.152 \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//


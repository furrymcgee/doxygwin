
.DEFAULT_GOAL := install

.PHONY: publib sensible-utils dwww swish++ debconf doc-base install run

dwww: debconf publib swish++ doc-base
doc-base: sensible-utils
	xmlcatalog --create > /etc/xml/catalog
	xmlcatalog --noout \
		--add rewriteURI \
		http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd \
		/usr/share/sgml/docbook/xml-dtd-4.5/docbookx.dtd \
	/etc/xml/catalog
	xmlcatalog --noout \
		--add rewriteURI \
		http://docbook.sourceforge.net/release/xsl/current \
		/usr/share/sgml/docbook/xsl-stylesheets \
	/etc/xml/catalog
	$(MAKE) $(MAKECMDGOALS) --directory=$@

dwww debconf swish++:
	$(MAKE) $(MAKECMDGOALS) --directory=$@

publib sensible-utils: 
	cd $@ && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin
	$(MAKE) $(MAKECMDGOALS) --directory=$@

~/.cpan:
	mkdir ~/.cpan
	cp -av .cpan/CPAN ~/.cpan
	cpan File::NCopy YAML::Tiny MIME::Tools UUID Email::Outlook::Message
	find ~/.cpan -name mimeexplode | \
	xargs install --mode=755 --target-directory=/usr/local/bin

# /usr/share/doc/doc-base/doc-base.html/interface.html
/var/lib/doc-base/documents: documents doc
	mkdir /var/lib/doc-base/documents
	cp -avu documents /etc/doc-base/documents
	cp -avu doc /usr/local/share/doc
	/usr/sbin/install-docs -v -i /etc/doc-base/documents/toolmonitor
	/usr/sbin/dwww-build
	/usr/sbin/dwww-build-menu
	/usr/sbin/dwww-refresh-cache
	/usr/sbin/dwww-index++ -v -f -- -v4

/etc/dwww: emldump
	mkdir /etc/dwww
	sed n < dwww/debian/dwww.config > /etc/dwww/dwww.conf
	install --mode=755 --target-directory=/usr/local/bin

/etc/apache2:
	mkdir /etc/apache2
	mkdir /etc/apache2/conf-enabled
	ln -s ../conf/available/dwww-conf /etc/apache2/conf-enabled
	sed \
		-i /etc/httpd/conf/httpd.conf \
		-e /#ServerName/aServerName\ 192.168.33.152 \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#//

install: dwww ~/.cpan

run: /etc/dwww /var/lib/doc-base
	cygserver-config --yes
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS
	cygrunsrv -S cygserver
	cygrunsrv -S httpd


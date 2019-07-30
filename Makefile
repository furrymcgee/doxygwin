
.DEFAULT_GOAL := install

.PHONY: publib sensible-utils dwww swish++ debconf doc-base install

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

install: dwww
	mkdir ~/.cpan && \
	cp -av .cpan/CPAN ~/.cpan && \
	cpan File::NCopy YAML::Tiny UUID || \
	true
	mkdir /var/lib/doc-base/documents && \
	/usr/sbin/dwww-build && \
	/usr/sbin/dwww-build-menu && \
	/usr/sbin/dwww-refresh-cache || \
	true
	mkdir /etc/dwww && \
	sed p < dwww/debian/dwww.config > /etc/dwww/dwww.conf || \
	true
	mkdir /etc/apache2/conf-enabled && \
	ln -s ../conf/available/dwww-conf /etc/apache2/conf-enabled && \
	sed \
		-i /etc/httpd/conf/httpd.conf \
		-e /#ServerName/aServerName\ 192.168.33.152 \
		-e /slotmem_shm_module/s/^#// \
		-e /cgi_module/s/#// || \
	true
	cygserver-config --yes
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS
	cygrunsrv -S cygserver
	cygrunsrv -S httpd




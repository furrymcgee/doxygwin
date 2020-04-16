.DEFAULT_GOAL = install

TARGETS= \
	automake_1.16.1.noarch \
	autotools-dev_20180224.1.noarch \
	base-files_10.3+deb10u3.i686 \
	calm_20160730.noarch \
	cygport_0.22.0.noarch \
	dctrl-tools_2.24-3.i686 \
	debconf_1.5.71.noarch \
	debhelper_12.1.1.noarch \
	dh-autoreconf_19.noarch \
	dh-exec_0.23.1.i686 \
	dh-python_3.20190308.noarch \
	doc-base_0.10.8.noarch \
	docx2txt_1.4-1.noarch \
	dpkg_1.19.7.i686 \
	dwww_1.13.4+nmu3.i686 \
	intltool-debian_0.35.0+20060710.5.noarch \
	libfile-stripnondeterminism-perl_1.1.2-1.noarch \
	po-debconf_1.0.21.noarch \
	publib_0.40-3.i686 \
	recutils_1.7-3.i686 \
	sensible-utils_0.0.12.noarch \
	swish++_6.1.5-5.i686 \
	tar_1.30+dfsg-6.i686 \

ETC = /etc/xml/catalog ~/.cpan /var/cache/debconf /var/lib/doc-base/documents po-debconf

.PHONY: $(.DEFAULT_GOAL) $(TARGETS) $(ETC) clean

$(.DEFAULT_GOAL): $(ETC)
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes || true
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS || true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

~/.cpan: CPAN/MyConfig.pm
	mkdir $@ $(shell dirname $@/$<) || true
	install --target-directory=$(shell dirname $@/$<) $<
	cpan -T \
		File::NCopy \
		YAML::Tiny \
		MIME::Tools UUID \
		Email::Outlook::Message \
		Devel::Cover \
		Archive::Cpio
	find ~/.cpan -name mimeexplode | \
	xargs install --mode=755 --target-directory=/usr/local/bin

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


clean:
	net user www-data /delete || true
	rm -rf ~/.cpan
	git submodule foreach | \
	cut -d\' -f2 | \
	grep -v cygwin-auto-install | \
	xargs -I@ \
		git --git-dir=@/.git --work-tree=@ clean -dfx

Sources:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/source/Sources.gz | \
	gunzip > $@

Packages:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/binary-amd64/Packages.gz | \
	gunzip > $@

%.cygport: Packages Sources
	cat Sources | grep-dctrl -n -s Package \
	-F Package $(word 1, $(subst _, , $*)) -a \
	-F Version $(word 2, $(subst _, , $*)) | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

%.dsc: %.cygport
	cygport --32 $*.cygport download && touch -r $@ $<

$(filter %.noarch,$(TARGETS)): %.noarch: %.dsc
	cygport --32 $*.cygport all

$(filter %.i686,$(TARGETS)): %.i686: %.dsc
	cygport --32 $*.cygport all

%.i686 %.noarch: %.dsc
	cygport --32 $*.cygport all

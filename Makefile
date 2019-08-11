.DEFAULT_GOAL = install

SUBDIRS = \
	dpkg \
	fakeroot \
	strip-nondeterminism \
	intltool-debian \
	publib \
	doc-base \
	debconf \
	swish++ \
	dwww \

CONFIGURE = dpkg/configure publib/configure sensible-utils/configure

ETC = ~/.cpan /var/cache/debconf /var/lib/doc-base/documents po-debconf

DEBIAN = strip-nondeterminism/debian

.PHONY: $(.DEFAULT_GOAL) $(CONFIGURE) $(SUBDIRS) $(ETC) $(DEBIAN)

$(.DEFAULT_GOAL): $(SUBDIRS) $(ETC)
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes || true
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS || true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

$(CONFIGURE):
	cd $(shell dirname $@) && \
	autoreconf -i && \
	sh configure \
		--host=i686-pc-cygwin \
		--prefix=/usr \
		CFLAGS=-D_STAT_VER=0

$(SUBDIRS):
	DISTRIBUTOR=doxie $(MAKE) --directory=$@ prefix=/usr $(MAKECMDGOALS)

doc-base: /etc/xml/catalog sensible-utils/configure sensible-utils

publib: publib/configure

~/.cpan: CPAN/MyConfig.pm
	mkdir $@ $(shell dirname $@/$<) || true
	install --target-directory=$(shell dirname $@/$<) $<
	cpan \
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


#dpkg-genchanges: error: binary build with no binary artifacts found; cannot distribute
$(DEBIAN):
	cd $(shell dirname $@) || exit 1 && \
	mkdir debian/tmp debian/tmp/DEBIAN || true && \
	git archive --format=tar --prefix=strip-nondeterminism-0.039/ debian/0.039-1 | bzip2 -9 > ../strip-nondeterminism_0.039.orig.tar.bz2 && \
	perl -e " \
		use Dpkg::Control::Info; \
		print join qq/\n/, map { \$$_->{package} } \
			Dpkg::Control::Info->new()->get_packages(); \
	" | xargs -I@ dpkg-gencontrol -p@ && \
	dpkg-deb.exe -b debian/tmp .. && \
	dpkg-buildpackage -rsh\ -c -d

%/debian:
	#dpkg-genchanges: error: binary build with no binary artifacts found; cannot distribute
	git archive --format=tar --prefix=strip-nondeterminism-0.039/ debian/0.039-1 | bzip2 -9 > ../strip-nondeterminism_0.039.orig.tar.bz2
	DEB_RULES_REQUIRES_ROOT=no dpkg-buildpackage -rsh\ -c -d
	DEB_RULES_REQUIRES_ROOT=no dh binary --without autoreconf
	#dpkg-source -b .

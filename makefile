.DEFAULT_GOAL = install

SUBDIRS = \
	debconf \
	debhelper \
	doc-base \
	dpkg \
	dwww \
	fakeroot \
	intltool-debian \
	po-debconf \
	publib \
	swish++ \
	tar \

CONFIGURE = dpkg/configure publib/configure sensible-utils/configure fakeroot/configure tar/configure

ETC = ~/.cpan /var/cache/debconf /var/lib/doc-base/documents po-debconf

DEBIAN = strip-nondeterminism/debian

.PHONY: $(.DEFAULT_GOAL) $(SUBDIRS) $(ETC) $(DEBIAN) clean

$(.DEFAULT_GOAL): $(SUBDIRS) $(ETC)
	install --mode=755 --target-directory=/usr/local/bin bin/mailexplode
	cygserver-config --yes || true
	cygrunsrv.exe -I httpd -p /usr/sbin/httpd -a -DONE_PROCESS || true
	cygrunsrv -S cygserver
	cygrunsrv -S httpd

$(CONFIGURE):
	cd $(shell dirname $@) && \
	autoreconf -fi && \
	sh configure \
		--host=i686-pc-cygwin \
		--prefix=/usr \
		CFLAGS=-D_STAT_VER=0

$(SUBDIRS):
	DISTRIBUTOR=doxie $(MAKE) --directory=$@ prefix=/usr 

doc-base: /etc/xml/catalog sensible-utils/configure sensible-utils

publib: publib/configure

dpkg: dpkg/configure

tar: tar/configure

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


#dpkg-genchanges: error: binary build with no binary artifacts found; cannot distribute
$(DEBIAN):
	dpkg --ignore-depends=libtool,perl:any,debhelper,autoconf,automake,autopoint -i dh-autoreconf_19_all.deb && \
	cd $(shell dirname $@) || exit 1 && \
	mkdir debian/tmp debian/tmp/DEBIAN || true && \
	git -c core.symlinks reset --hard && \
	git archive --format=tar --prefix=strip-nondeterminism-0.039/ debian/0.039-1 | bzip2 -9 > ../strip-nondeterminism_0.039.orig.tar.bz2 && \
	perl -e " \
		use Dpkg::Control::Info; \
		print join qq/\n/, map { \$$_->{package} } \
			Dpkg::Control::Info->new()->get_packages(); \
	" | xargs -I@ dpkg-gencontrol -p@ && \
	: PERL5LIB=/usr/share/perl5 dpkg-buildpackage -rsh\ -c -d -a i386 -t i686-pc-cygwin

clean:
	net user www-data /delete || true
	rm -rf ~/.cpan
	git submodule foreach | \
	cut -d\' -f2 | \
	grep -v cygwin-auto-install | \
	xargs -I@ \
		git --git-dir=@/.git --work-tree=@ clean -dfx


Sources.gz:
	wget -c \
		http://deb.debian.org/debian/dists/stable/main/source/Sources.gz

Packages.gz:
	wget -c \
		http://deb.debian.org/debian/dists/stable/main/binary-amd64/Packages.gz

%.cygport: cygport.sh Packages.gz Sources.gz
	sh $< $(basename $@) > $@

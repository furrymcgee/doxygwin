.DEFAULT_GOAL = install

PACKAGES:= \
	apache2 \
	automake \
	base-files \
	calm \
	cygport \
	debconf \
	debhelper \
	dh-autoreconf \
	dh-exec \
	dh-python \
	doc-base \
	docx2txt \
	dpkg \
	dwww \
	intltool-debian \
	po-debconf \
	publib-dev \
	sensible-utils \
	strip-nondeterminism \
	swish++ \
	tar \

ETC =  /etc/xml/catalog ~/.cpan /var/cache/debconf /var/lib/doc-base/documents po-debconf

.PHONY: $(.DEFAULT_GOAL) $(ETC) clean

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

%.cygport %.cygport: cygport.sh Packages Sources
	cat Sources | \
	grep-dctrl -n -s Package \
	-F Package $(word 1, $(subst _, , $(basename $@))) \
	-a \
	-F Version $(word 2, $(subst _, , $(basename $@))) | \
	xargs sh $< > $@ || { unlink $@ && exit 1 ; }

%.dsc: %.cygport
	cygport --32 $(basename $@) download

%.script: %.dsc
	cygport --32 $(basename $@).cygport --all


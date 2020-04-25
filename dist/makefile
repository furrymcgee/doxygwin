.DEFAULT_GOAL = x86

NOARCH = calm debconf doc-base sensible-utils strip-nondeterminism

I686 = dh-exec dpkg publib-dev recutils swish++

$(.DEFAULT_GOAL): $(I686) $(NOARCH)
	$(MAKE) $^

Sources:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/source/Sources.gz | \
	gunzip > $@

Packages:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/binary-amd64/Packages.gz | \
	gunzip > $@

%.cygport:
	grep-dctrl -n -s Package -F Package $(basename $@) Packages | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

%.dsc:
	cygport --32 $(word 1, $(subst _, , $@)).cygport download

%.i686 %.noarch:
	$(MAKE) $(word 1, $(subst _, ,$@)).cygport
	$(MAKE) $(word 1, $(subst _, ,$@))_$(word 2, $(subst _, , $@)).dsc
	grep -H ^PATCH_URI $(word 1, $(subst _, ,$@)).cygport | \
	cut -d= -f2 | xargs | xargs -L1 -r $(MAKE)
	cygport --32 $(word 1, $(subst _, , $@)).cygport all
	
%: %.cygport
	grep -H ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH $< | \
	cut -d= -f2 | paste - - - - | \
	xargs -L4 printf %s_%s_%s.%s\\\n | xargs $(MAKE)
	mv $(subst _,-,$@)/dist/* .

ETC = /etc/xml/catalog ~/.cpan /var/cache/debconf /var/lib/doc-base/documents po-debconf

.PHONY: $(ETC) clean

install: $(ETC)
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


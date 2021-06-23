
PACKAGE=doxygwin
VERSION=0.0.1
RELEASE=1
ARCH=noarch

.DEFAULT_GOAL=debian

%.html: %
	asciidoc -a toc -o - $^ > $@

${.DEFAULT_GOAL}: doc/$(PACKAGE)/index.html
	dh_make --indep --yes --createorig --copyright=artistic
	cp -av $(PACKAGE).install debian
	dpkg-buildpackage -uc -us -d -S
	cp -av $(PACKAGE).cygport ..
	cygport --32 ../$(PACKAGE).cygport download
	cygport --32 ../$(PACKAGE).cygport all
	cp -av ../$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH)/dist/$(PACKAGE)/* ..
	cygport --32 ../$(PACKAGE).cygport finish

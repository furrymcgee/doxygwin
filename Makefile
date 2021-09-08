
PACKAGE=doxygwin
VERSION=0.0.1
RELEASE=1
ARCH=noarch

export PERL5LIB?=/usr/share/perl5:/usr/lib/perl5/vendor_perl/5.22/i686-cygwin-threads-64int/Data
export PATH:=/usr/sbin:$(PATH)

.DEFAULT_GOAL=debian

doc/$(PACKAGE)/index.html:
	$(MAKE) -C doc/doxygwin index.html

${.DEFAULT_GOAL}: doc/$(PACKAGE)/index.html
	dh_make --indep --yes --createorig --copyright=artistic
	cp -av $(PACKAGE).install debian
	dpkg-buildpackage -uc -us -d -S
	cp -av $(PACKAGE).cygport ..
	cygport --32 ../$(PACKAGE).cygport download
	cygport --32 ../$(PACKAGE).cygport all
	cp -av ../$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH)/dist/$(PACKAGE)/* ..
	cygport --32 ../$(PACKAGE).cygport finish

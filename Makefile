PACKAGE=doxygwin
VERSION=0.0.1
RELEASE=1
FILES=$(shell git ls-files --stage | grep -v ^160000 | cut -f2)

.DEFAULT_GOAL=doxygwin

.PHONY: ${.DEFAULT_GOAL}

${.DEFAULT_GOAL}: setup.hint $(PACKAGE)-$(VERSION)-$(RELEASE).tar.xz $(PACKAGE)-$(VERSION)-$(RELEASE)-src.tar.xz
	mkdir repository/Y%3a%2f/noarch/release/doxygwin
	install $^ repository/Y%3a%2f/noarch/release/doxygwin

$(PACKAGE)-$(VERSION)-$(RELEASE).tar.xz: bin doc etc autorun.inf autorun.bat Cygwin.ico index.html
	tar Jc $^ > $@

$(PACKAGE)-$(VERSION)-$(RELEASE)-src.tar.xz: $(FILES)
	tar Jc $^ > $@

debian:
	dh_make --indep --yes --createorig
	dpkg-buildpackage -uc -us

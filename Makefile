
.DEFAULT_GOAL := dwww

.PHONY: publib sensible-utils dwww swish++ doc-base install

dwww: publib swish++ doc-base
doc-base: sensible-utils

dwww doc-base swish++:
	make install -C $@

publib sensible-utils: 
	cd $@ && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin && \
	make install

install:
	mkdir /var/lib/doc-base/documents
	cpan File::NCopy YAML::Tiny UUID
	/usr/sbin/dwww-build
	/usr/sbin/dwww-build-menu
	/usr/sbin/dwww-refresh-cache



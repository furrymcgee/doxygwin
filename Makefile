
.DEFAULT_GOAL := dwww

.PHONY: publib sensible-utils dwww swish++ doc-base

dwww: publib swish++ doc-base
doc-base: sensible-utils

dwww doc-base swish++:
	make install -C $@

publib sensible-utils: 
	cd $@ && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin && \
	make install



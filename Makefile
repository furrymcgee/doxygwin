
publib:
	cd $@ && \
	autoreconf -i && \
	sh configure --host=i686-pc-cygwin && \
	make install

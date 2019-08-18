#!/bin/sh
# https://cygwin.com/package-server.html

PACKAGE=custompackage-0.0.1-1

<<-BASH \
5<<-"HINT" \
6<<MAKE \
bash -x 
	#!/bin/bash
	mkdir custom-cygwin || true
	cd custom-cygwin

	cat > ${PACKAGE}.hint <&5
	<&6 sed s/^\\\t// | make -f -
	exit 1

	for ARCH in x86 x86_64 noarch ; do
		mkdir -p ${ARCH}/release
		cd ${ARCH}/release
		ln -s /var/www/cygwin/${ARCH}/release/* .
		cd ../..
	done

	cd /var/www/custom-cygwin/
	for ARCH in x86 x86_64 ; do
		mksetupini --arch ${ARCH} --inifile=${ARCH}/setup.ini --releasearea=.
		bzip2 <${ARCH}/setup.ini >${ARCH}/setup.bz2
		xz -6e <${ARCH}/setup.ini >${ARCH}/setup.xz
	done
BASH
	sdesc: "My favorite packages"
	ldesc: "My favorite packages"
	category: Base
	requires: bzip2 clear cygwin-doc file less openssh pinfo rxvt wget
HINT
	#!/bin/make -f
	.DEFAULT_GOAL=${PACKAGE}

	\${.DEFAULT_GOAL}: custompackage-0.0.1-1.tar.xz

	.PHONY: \${.DEFAULT_GOAL}

	%-src.tar.xz:
		tar -Jcf \$@ --files-from /dev/null

	%.tar.xz: %-src.tar.xz %.hint
		tar -Jcf \$@ --files-from /dev/null
MAKE


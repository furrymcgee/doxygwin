#!/bin/sh

make

cpan File::NCopy YAML::Tiny UUID

/usr/sbin/dwww-build
/usr/sbin/dwww-build-menu
/usr/sbin/dwww-refresh-cache

mkdir /var/lib/doc-base/documents
< /usr/share/doc/doc-base/doc-base.html/interface.html \
grep "Document: foo" -A7 -m1 | \
sed \
	-e s/Foo/Dwww/g \
	-e /Files:/s-/.*-/usr/share/doc/dwww/README- \
> /etc/doc-base/documents/dwww

/usr/sbin/install-docs --install-changed
/usr/sbin/dwww-index++ -f -v -- -v4





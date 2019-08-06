#!/bin/sh
/usr/sbin/install-docs -v -i /etc/doc-base/documents/foo
: /usr/sbin/dwww-index++ -v -f -- -v4
: /usr/bin/search --config-file /usr/share/dwww/swish++.conf --index-file /var/cache/dwww/dwww.swish++.index -D


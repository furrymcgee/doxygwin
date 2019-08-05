#!/bin/sh
: ln -s /mnt/doc /usr/local/share
/usr/sbin/install-docs -R
/usr/sbin/install-docs -v -c /etc/doc-base/documents/toolmonitor
: /usr/sbin/dwww-index++ -v -l
/usr/bin/index --follow-links --no-recurse --config-file /usr/share/dwww/swish++.conf --index-file /var/cache/dwww/dwww.swish++.index.tmp -v4 -
: /usr/bin/search --config-file /usr/share/dwww/swish++.conf --index-file /var/cache/dwww/dwww.swish++.index -D

bash -x <<-'EOF'
        export PATH=/usr/local/bin:$PATH
        find ../*.msg -printf %f\\\0 -maxdepth 0 |
		xargs -0 printf %q\\\n |
		while read REPLY
        do
            msgconvert --outfile - ../$REPLY |
            mimeexplode - |
			grep Part: |
            tr \( : |
			cut -d: -f2 |
			grep txt\\\|pdf |
			grep -o \\w.*\\w |
            index -c /etc/swish++.conf -p101 -v4 - &&
            search -D | 
			grep ^\\w > $REPLY.txt
        done
EOF

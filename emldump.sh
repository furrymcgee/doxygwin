#!/bin/sh
PATH=/usr/local/bin:$PATH
find ../*.msg -maxdepth 0 -printf %f\\\0 |
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


#!/bin/sh


: ln -s /mnt/doc /usr/local/share

# /usr/share/doc/doc-base/doc-base.html/interface.html
cat <<-'DOC' > /etc/doc-base/documents/toolmonitor
	Document: toolmonitor
	Title: Toolmonitor
	Author: Nordmann GmbH
	Abstract: Werkzeugüberwachung
	Section: Text

	Format: html
	Files: /usr/local/share/doc/*.html
	Index: /usr/local/share/doc/Atlas--Beric-Service-durch-Plxmer.html
	
	Format: pdf
	Files: /usr/local/share/doc/*.pdf
	
	Format: doc
	Files: /usr/local/share/doc/*.doc
	
	Format: xls
	Files: /usr/local/share/doc/*.xls
	
	Format: xlsx
	Files: /usr/local/share/doc/*.xlsx
	
	Format: msg
	Files: /usr/local/share/doc/*.msg
DOC

/usr/sbin/install-docs -R
/usr/sbin/install-docs -v -c /etc/doc-base/documents/toolmonitor
/usr/sbin/install-docs -v -i /etc/doc-base/documents/toolmonitor
/usr/sbin/dwww-index++ -v -f -- -v4
: /usr/sbin/dwww-index++ -v -l
: /usr/bin/search --config-file /usr/share/dwww/swish++.conf --index-file /var/cache/dwww/dwww.swish++.index -D


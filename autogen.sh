#!/bin/sh

# /usr/share/doc/doc-base/doc-base.html/interface.html
cat <<-'DOC' > /etc/doc-base/documents/toolmonitor
	Document: toolmonitor
	Title: Toolmonitor
	Author: Nordmann GmbH
	Abstract: Werkzeugüberwachung
	Section: Text

	Format: html
	Files: /usr/share/doc/toolmonitor/*.html
	Index: /usr/share/doc/toolmonitor/Atlas--Beric-Service-durch-Plxmer.html
	
	Format: pdf
	Files: /usr/share/doc/toolmonitor/*.pdf
	
	Format: doc
	Files: /usr/share/doc/toolmonitor/*.doc
	
	Format: xls
	Files: /usr/share/doc/toolmonitor/*.xls
	
	Format: xlsx
	Files: /usr/share/doc/toolmonitor/*.xlsx
	
	Format: msg
	Files: /usr/share/doc/toolmonitor/*.msg
DOC

/usr/sbin/install-docs -v -c /etc/doc-base/documents/toolmonitor
/usr/sbin/dwww-index++ -v -f -- -v4
/usr/sbin/dwww-index++ -v -l


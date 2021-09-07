%.html: %
	asciidoc -a toc -o - $^ > $@

# https://bugs.archlinux.org/task/45741
# sudo /usr/share/texlive/texmf-dist/web2c/mktexdir /var/cache/fonts/pk/ljfour/jknappen/ec
# sudo mktexpk --mfmode / --bdpi 600 --mag 1+0/600 --dpi 600 ectt1095
%.tex: %
	asciidoc -b latex -o - -v $^ | \
	sed \
		-e 's/begin{figure}/&[H]/' \
		-e '/pagestyle/a\\\\usepackage{float}\r' \
		-e /Generator:/d > $@

%.pdf: %.tex
	pdflatex $^	


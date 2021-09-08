
%.html: %
	asciidoc -a toc -o - $^ > $@

# https://bugs.archlinux.org/task/45741
# sudo bash < missfont.log
%.tex: %
	asciidoc -b latex -o - -v $^ | \
	sed \
		-e '/^\\section/i\\\clearpage\r' \
		-e '/includegraphics/s/\[\]/\[height=2in\]/' \
		-e 's/begin{figure}/&[H]/' \
		-e '/pagestyle/a\\\\usepackage{float}\r' \
		-e /Generator:/d > $@

%.pdf: %.tex
	pdflatex $^	




all: nasa-fm-2017.pdf

nasa-fm-2017.pdf: nasa-fm-2017.md om1_diagram.pdf
	pandoc -t beamer --template=default.beamer --variable fontsize=12pt \
			-V theme=boxes $< -o $@

om1_diagram.pdf: om1_diagram.tex
	pdflatex $<

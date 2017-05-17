all: nasa-fm-2017.pdf

nasa-fm-2017.pdf: nasa-fm-2017.md om1_diagram.pdf proof-structure.pdf adsl.pdf \
					fstate.pdf
	pandoc -t beamer --template=default.beamer --variable fontsize=12pt \
			-V theme=boxes $< -o $@

om1_diagram.pdf: om1_diagram.tex
	pdflatex $<

adsl.pdf: adsl.tex
	pdflatex $<

fstate.pdf: fstate.tex
	pdflatex $<

proof-structure.pdf: proof-structure.tex
	pdflatex $<

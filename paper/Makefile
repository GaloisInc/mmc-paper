.PHONY: clean veryclean

WORK_DIR=pdflatex
TGT=paper
BIB=paper
#latex=TEXINPUTS=".:./style:" pdflatex -output-directory $(WORK_DIR)
latex=pdflatex -output-directory $(WORK_DIR)
tex=latex -output-directory $(WORK_DIR) --interaction=batchmode

all: $(TGT).pdf

$(TGT).pdf: $(WORK_DIR) *.tex *.bib llncs
	$(latex) $(TGT)
	bibtex $(WORK_DIR)/$(TGT).aux
	$(latex) $(TGT)
	$(latex) $(TGT)
	cp $(WORK_DIR)/$(TGT).pdf .

$(TGT).dvi: $(WORK_DIR) $(TGT).tex *.bib llncs
	$(tex) $(TGT)
	bibtex $(WORK_DIR)/$(TGT).aux
	$(tex) $(TGT)
	$(tex) $(TGT)
	cp $(WORK_DIR)/$(TGT).pdf .

$(WORK_DIR):
	mkdir -p $(WORK_DIR)

llncs:
	mkdir -p llncs; cd llncs; \
		curl ftp://ftp.springer.de/pub/tex/latex/llncs/latex2e/llncs2e.zip > llncs.zip; \
		unzip llncs.zip

clean:
	-rm -rf $(WORK_DIR)

veryclean: clean
	-rm $(TGT).pdf
	-rm $(TGT).dvi
	-rm -rf llncs

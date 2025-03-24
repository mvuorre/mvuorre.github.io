all: bibliography/bibliography.bib

bibliography/bibliography.bib: bibliography.R
	Rscript "$<"

publish:
	quarto publish gh-pages

.PHONY: all	bibliography/bibliography.bib publish

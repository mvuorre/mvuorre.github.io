all: bibliography/bibliography.bib

bibliography/bibliography.bib: bibliography.R
	Rscript "$<"

publish:
	quarto publish gh-pages --no-prompt

.PHONY: all	bibliography/bibliography.bib publish

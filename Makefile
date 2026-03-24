all: bibliography/openalex.yaml

bibliography/openalex.yaml: bibliography/openalex.R
	Rscript "$<"

publish:
	quarto publish gh-pages --no-prompt

.PHONY: publish bibliography/openalex.yaml all

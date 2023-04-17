FILENAME=vonLaszewski-frontiers
DIR=paper-frontier

# .PHONY: $(FILENAME).pdf

.PHONY: images

all: $(FILENAME).pdf

# MAIN LATEXMK RULE

$(FILENAME).pdf: $(FILENAME).tex
	latexmk -quiet -deps -bibtex $(PREVIEW_CONTINUOUSLY) -f -pdf -pdflatex="pdflatex -synctex=1 -interaction=nonstopmode" -use-make $(FILENAME).tex

.PRECIOUS: %.pdf
.PHONY: watch

watch: PREVIEW_CONTINUOUSLY=-pvc
watch: $(FILENAME).pdf

.PHONY: clean

images:
	python bin/pdf-to-jpg.py

# | xargs convert -density 300 -trim test.pdf -quality 100


txt:
	#detex $(FILENAME).tex | cat -s > $(FILENAME).txt
	pdftotext -layout $(FILENAME).pdf $(FILENAME).txt

edit:
	emacs $(FILENAME).tex

clean:
	latexmk -C -bibtex
	rm -rf $(FILENAME).spl
	rm -f *_bibertool.bib
	rm -f *.ttt
	rm -f *.blg


regular:
	pdflatex $(FILENAME)
	bibtex $(FILENAME)
	pdflatex $(FILENAME)
	pdflatex $(FILENAME)

biber:
	@echo
	biber -V --tool cloud-scheduling.bib | fgrep -v INFO
	@echo
	biber -V --tool cloud-scheduling_bibertool.bib | fgrep -v INFO
	@echo
	biber -V --tool strings.bib | fgrep -v INFO
	@echo
	biber -V --tool vonlaszewski.bib | fgrep -v INFO
	@make -f Makefile clean

zip: clean
	cd ..; zip -x "*/.DS*" "*/*.git*" "*/*bin*" "*/*zip" "*/*.md" "*/Makefile" -r $(DIR)/$(FILENAME).zip $(DIR)

flatzip: clean
	zip -x "*.git*" "*bin*" "*zip" "*.md" "Makefile" -r $(FILENAME).zip .

publish:
	cp $(FILENAME).pdf ../../../laszewski/laszewski.github.io/papers/
	cd ../../../laszewski/laszewski.github.io/papers; git add $(FILENAME).pdf
	cd ../../../laszewski/laszewski.github.io/papers; git commit -m "update $(FILENAME)" $(FILENAME).pdf
	cd ../../../laszewski/laszewski.github.io/papers; git push

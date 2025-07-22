SHELL := /bin/bash
PROJECT := $(notdir $(PWD))

index.html : index.tmpl tmpl2html img/* # *.pl *.pm
	tmpl2html index.tmpl index.html

.PHONY: validate
validate: *.html
	xsh <<< 'for my $$h in { glob "*.html */*.html" } open :F html $$h'
	xsh <<< 'for my $$x in { glob "*.xml img/*.svg" }  open $$x'

ZIPPED := index.html generated/*.html graphics/* help/help.html img/* scripts/slidy.js styles/*.css
.PHONY: zip
zip: $(PROJECT).zip
$(PROJECT).zip: $(ZIPPED)
	rm -f $@
	cd .. && zip -r $(PROJECT)/$@ $(foreach f,$(ZIPPED),$(PROJECT)/$(f))

img/%.png: %.dot
	dot -Tpng $< > $@

.PHONY: clean
clean:
	rm -f index.html *~ generated/*.html $(PROJECT).zip
	git status --ignored --porcelain img \
	| perl -wlnE 'unlink if s/^!! //'

.PHONY: loop
loop:
	while inotifywait -e modify -e move -e create -e delete --exclude '^\./\.git/|\.#|~$$' -r . ; do $(MAKE) ; done

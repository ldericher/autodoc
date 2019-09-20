#@SRCPAT \.md$

.PHONY: all
all: simple.pdf simple.html

simple.pdf: simple.md
	pandoc -s -f markdown -t latex -o $@ $<

simple.html: simple.md
	pandoc -s -f markdown -t html -o $@ $<

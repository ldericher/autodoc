#%SRCPAT% \.url$

.PHONY: all
all: eisvogel.pdf

.PHONY: eisvogel.pdf
eisvogel.pdf: document.md.url
	wget -O- '$(file < $<)' | pandoc -s -f markdown -t latex -o $@ --template eisvogel

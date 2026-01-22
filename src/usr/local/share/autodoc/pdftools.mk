# use pandoc to process markdown
#
# params:
#   1. input file
#   2. pandoc template
#   3. output format (e.g. pdf, latex, ...)
#   4. output file
#
# vars:
# 	- PANDOCVARS: template variables given as "name:value", separated by space
# 	- PANDOCFLAGS: additional flags for `pandoc` commands
pdftools_pdmd = pandoc \
	$(1) \
	--standalone \
	--from markdown \
	--to $(3) \
	--template $(2) \
	$(addprefix --variable ,$(PANDOCVARS) csquotes:true hyperrefoptions:pdfa) \
	--output $(4) \
	$(PANDOCFLAGS)

# common flags for `gs` invocations (internal)
__PDFTOOLS_GSFLAGS := \
	-sDEVICE=pdfwrite \
	-dSAFER \
	-dNOPAUSE \
	-dQUIET \
	-dBATCH

# use ghostscript to concatenate and/or adjust PDF file(s)
#
# params:
#   1. input file(s)
#   2. output file
#
# vars:
#   - GS_CompatibilityLevel (default: 1.7): Refer to gs "dCompatibilityLevel"
#   - GSNOFORCE: Set to anything to avoid forcing the paper size
#   - GS_PAPERSIZE (if GSNOFORCE is unset, default: a4): Refer to gs "sPAPERSIZE"
#   - GSNOCOMPRESS: Set to anything to avoid "distilling" the PDF
#   - GS_PDFSETTINGS (if GSNOCOMPRESS is unset, default: /ebook): Refer to gs "dPDFSETTINGS"
#   - GSFLAGS: additional flags for `gs` commands
pdftools_pdfcat = gs \
	$(__PDFTOOLS_GSFLAGS) \
	-dCompatibilityLevel=$(or $(GS_CompatibilityLevel),1.7) \
	$(if $(GSNOFORCE),,-sPAPERSIZE=$(or $(GS_PAPERSIZE),a4) -dFIXEDMEDIA -dPDFFitPage) \
	$(if $(GSNOCOMPRESS),,-dPDFSETTINGS=$(or $(GS_PDFSETTINGS),/ebook)) \
	-sOutputFile=$(2) \
	$(GSFLAGS) \
	$(1)

# use ghostscript to concatenate PDF file(s) into a PDF/A
#
# params:
#   1. input file(s)
#   2. output file
#
# vars:
#   - GS_PDFA (default: 3): Refer to gs "dPDFA"
#   - GS_PDFACompatibilityPolicy (default: 1): Refer to gs "dPDFACompatibilityPolicy"
#   - GSFLAGS: additional flags for `gs` commands
pdftools_mkpdfa = gs \
	$(__PDFTOOLS_GSFLAGS) \
	-dPDFA=$(or $(GS_PDFA),3) \
	-dPDFACompatibilityPolicy=$(or $(GS_PDFACompatibilityPolicy),1) \
	-sColorConversionStrategy=RGB \
	--permit-file-read=/usr/local/share/autodoc/ \
	-sOutputFile=$(2) \
	$(GSFLAGS) \
	/usr/local/share/autodoc/PDFA_def.ps \
	$(1)

# shorthands for `pdftools_pdfcat` and `pdftools_mkpdfa` reading from stdin (param is just output file, vars applicable)
pdftools_pdfpipe = $(call pdftools_pdfcat,-,$(1))
pdftools_pdfapipe = $(call pdftools_mkpdfa,-,$(1))

# shorthands for `pdftools_pdmd` to compile into LaTeX, PDF and PDF/A
#
# vars applicable from `pdftools_pdmd`, `pdftools_pdfcat` and `pdftools_mkpdfa` as expected
#
# params:
#   1. input file
#   2. pandoc template
#   3. output file
pdftools_md2tex = $(call pdftools_pdmd,$(1),$(2),latex,$(3))
pdftools_md2pdf = $(call pdftools_pdmd,$(1),$(2),pdf,-) | $(call pdftools_pdfpipe,$(3))
pdftools_md2pdfa = $(call pdftools_md2pdf,$(1),$(2),-) | $(call pdftools_pdfapipe,$(3))

# shorthands based on automatic Make variables
pdftools_pdfcat_auto = $(call pdftools_pdfcat,$^,$@)
pdftools_mkpdfa_auto = $(call pdftools_mkpdfa,$^,$@)

# params:
#   1. pandoc template
pdftools_md2tex_auto = $(call pdftools_md2tex,$<,$(1),$@)
pdftools_md2pdf_auto = $(call pdftools_md2pdf,$<,$(1),$@)
pdftools_md2pdfa_auto = $(call pdftools_md2pdfa,$<,$(1),$@)

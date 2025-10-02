#############
# FUNCTIONS #
#############

PDFTOOLS_GSFLAGS := \
	-sDEVICE=pdfwrite \
	-dNOOUTERSAVE \
	-dNOPAUSE \
	-dQUIET \
	-dBATCH

pdftools_pdfcat = gs \
	$(PDFTOOLS_GSFLAGS) \
	-sPAPERSIZE=a4 \
	-dFIXEDMEDIA \
	-dPDFFitPage \
	-dCompatibilityLevel=1.7 \
	-dPDFSETTINGS=/ebook \
	-sOutputFile=$(2) \
	$(1)

pdftools_mkpdfa = gs \
	$(PDFTOOLS_GSFLAGS) \
	-dPDFA=$(1) \
	-sColorConversionStrategy=RGB \
	-dPDFACompatibilityPolicy=1 \
	--permit-file-read=/usr/local/share/autodoc/ \
	-sOutputFile=$(3) \
	/usr/local/share/autodoc/PDFA_def.ps \
	$(2)

############
# PATTERNS #
############

# convert PDF to PDF/A-2B
%_pdfa2.pdf: %.pdf
	$(call pdftools_mkpdfa,2,$<,$@)

# convert PDF to PDF/A-3B
%_pdfa3.pdf: %.pdf
	$(call pdftools_mkpdfa,3,$<,$@)

# convert PDF to PDF/A (default variant 3B)
%_pdfa.pdf: %.pdf
	$(call pdftools_mkpdfa,3,$<,$@)

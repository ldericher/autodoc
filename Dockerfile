FROM pandoc/extra:latest

RUN set -ex; \
    \
    apk add --no-cache \
      bash \
      ghostscript \
      inotify-tools \
      make \
    ; \
    \
    tlmgr install \
      kpfonts \
      lastpage \
      latexmk \
    ;

COPY src/usr /usr

WORKDIR /docs
ENTRYPOINT ["autodoc"]
CMD ["-bw"]

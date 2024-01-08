FROM pandoc/extra:latest

RUN set -ex; \
    \
    apk add --no-cache \
      bash \
      inotify-tools \
      make \
    ;

COPY usr /usr

CMD ["autodoc", "-bw"]

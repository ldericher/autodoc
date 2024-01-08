FROM pandoc/extra:latest

RUN set -ex; \
    \
    apk add --no-cache \
      bash \
      inotify-tools \
      make \
    ;

COPY src/usr /usr

ENTRYPOINT ["autodoc"]
CMD ["-bw"]

FROM ldericher/pandocker:latest

RUN set -ex; \
    apt-get update && apt-get -y install \
      inotify-tools \
    ; rm -rf /var/lib/apt/lists/*;

COPY usr /usr

CMD ["autodoc", "-bw"]

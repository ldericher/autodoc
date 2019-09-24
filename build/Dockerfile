FROM ldericher/pandocker:latest

RUN apt-get update && apt-get -y install \
      inotify-tools \
&&  rm -rf /var/lib/apt/lists/*

COPY autodoc /usr/local/bin/autodoc
RUN chmod +x /usr/local/bin/autodoc

CMD ["autodoc"]

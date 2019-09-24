FROM ldericher/pandocker:latest

RUN apt-get update && apt-get -y install \
      inotify-tools \
&&  rm -rf /var/lib/apt/lists/*

COPY usr /usr

CMD ["autodoc"]

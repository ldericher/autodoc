FROM ldericher/pandocker:latest

RUN apt-get update && apt-get -y install \
      inotify-tools \
      lsof \
&&  rm -rf /var/lib/apt/lists/*

COPY autodoc.sh /usr/local/bin/autodoc
RUN chmod +x /usr/local/bin/autodoc

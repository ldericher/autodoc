# autodoc

[![Build Status](https://github.drone.yavook.de/api/badges/ldericher/autodoc/status.svg)](https://github.drone.yavook.de/ldericher/autodoc)

[`autodoc`](https://github.com/ldericher/autodoc) is a simple [CI](https://en.wikipedia.org/wiki/Continuous_integration) system optimized for document creation.

In general, any file-sharing solution -- preferably on top of `docker-compose` -- can be made into an automatic document distribution system by adding an `autodoc` instance.

## Quick Start Guide using Docker

The `autodoc` image [available on Docker Hub](https://hub.docker.com/r/ldericher/autodoc) is based on [pandocker](https://hub.docker.com/r/ldericher/pandocker) providing Ubuntu's TeXlive `LaTeX` and `pandoc` in a simple box.

01. Install [Docker CE](https://docs.docker.com/install/)

01. Clone or download the `autodoc` repository, open a terminal inside the [examples](https://github.com/ldericher/autodoc/tree/master/examples) directory

01. Deploy an `autodoc` container:

    ```bash
    docker run --rm -it \
     --volume "${PWD}":/docs \
     --user "$(id -u):$(id -g)" \
     ldericher/autodoc
    ```

    The contents of the directory are now being watched by `autodoc`!

    When deploying an `autodoc` container, just mount your document root to `/docs`. You *should* also set the container's UID and GID. These are seen above.

01. Edit some stuff, save -- and watch the magic happen (and the terminal output).

    On each file change, `autodoc` searches relevant build instruction files (Makefiles etc.) and kicks off build processes accordingly.

### How *not* to use `autodoc`

`autodoc` is **not** a solution for Continuous Integration of large scale systems software! `autodoc` excels at building a large number of independent, small files.

### Deploying without Docker

`autodoc` only hard-depends on `inotifywait` from [inotify-tools](https://github.com/rvoicilas/inotify-tools) to recursively watch Linux file system directories.

You will usually want to install a `LaTeX` distribution and setup `pandoc`.

## Prime use case: Nextcloud

Nextcloud is a "safe home for all your data" that can [easily be deployed using docker-compose](https://hub.docker.com/_/nextcloud).  
Add an `autodoc` container to create directories where PDFs are automatically held up to date for all your documents. This extends upon the "[Base version - apache](https://hub.docker.com/_/nextcloud#base-version---apache)" of the Nextcloud compose deployment.

```yaml
version: '2'

volumes:
  documents:

services:
  app:
    volumes:
      - documents:/opt/autodoc

  autodoc:
    restart: always
    image: ldericher/autodoc
    user: "UID:GID"
    volumes:
      - documents:/docs
```

The "user" key should be set to the same numeric IDs used for the nextcloud worker processes! To find the right IDs, issue `docker-compose exec app sh -c 'id -u www-data; id -g www-data'`.  
For the apache containers, this should evaluate to "33:33".

To begin, add the mounted `/opt/autodoc` as a 'local type' external storage to your Nextcloud instance.  
You might need to setup the permissions on your new volume using `docker-compose exec app chown -R www-data:www-data /opt/autodoc`.

## Concept: Source patterns

To avoid unnecessary rebuilds and self-triggering, `autodoc` uses "source patterns" to filter for the relevant build instructions.  
A source pattern is a `bash` regular expression matching any filename that should be regarded as a "source file" to the build instruction file.

For instance, if a Makefile instructs how to build from Markdown source files, that Makefile's source pattern should likely be `\.md$`.

## Creating an automated build

In general, just put your source files into any (sub-)directory watched by `autodoc`. Add a build instruction file.

On each file change, its containing directory is searched for a build instruction file. Watched parent directories are also probed for further build instructions.  
Every relevant instruction file will be executed as found.

You may combine build instruction systems to your liking.

## Build instruction systems

### GNU Make (Makefiles)

`autodoc` supports GNU Makefiles.  
However, Makefiles must contain a SRCPAT annotation comment as follows, where `<regex>` is a source pattern as above.

```Makefile
#%SRCPAT% <regex>
```

If there are multiple SRCPAT annotations, the lowermost one will be used.

You *may* add a PHONY target "autodoc" which will be built *instead* of the default target. This is demonstrated in [examples/automatic directory listing/a directory in space/Makefile](https://github.com/ldericher/autodoc/blob/develop/examples/automatic%20directory%20listing/a%20directory%20in%20space/Makefile).

```Makefile
.PHONY: autodoc
autodoc:
  @echo "Hello World!"
```

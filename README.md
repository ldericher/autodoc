# autodoc

[`autodoc`](https://github.com/ldericher/autodoc) is a simple [CI](https://en.wikipedia.org/wiki/Continuous_integration) script, primarily aimed at document creation.

## Basics

`autodoc` relies upon [inotify-tools](https://github.com/rvoicilas/inotify-tools) to recursively watch a Linux file system directory.

For each file change, `autodoc` searches corresponding build instruction files (Makefiles etc.) and kicks off build processes accordingly.

## Usage

`autodoc` is designed to run in a server-side, containerized context.

### Deploy a container

`autodoc` can be pulled from the docker hub using `docker pull ldericher/autodoc`.

When deploying an `autodoc` container, mount your document root to `/docs`. You *should* also set the container's UID and GID.

#### Included software

TODO `ldericher/autodoc` contains `pandoc`.

#### tl;dr

Deploy an `autodoc` instance in your current working dir:

    docker run --name autodoc -d -v "${PWD}":/docs --user "$(id -u):$(id -g)" ldericher/autodoc

### Automating builds

Example automated builds can be found [here](https://github.com/ldericher/autodoc/tree/master/example_docs).

In general, just put a build instruction file into any (sub-)directory watched by `autodoc` and add your source files.

On each file change, its containing directory is searched for a build instruction file. Watched parent directories are also probed for further build instructions.  
Every relevant instruction file will be executed as found.

You may combine build instruction systems to your liking.

#### SRCPAT concept, "relevant" build instructions

To avoid unnecessary rebuilds and self-triggering, `autodoc` uses "source patterns" to decide which build instructions are relevant.

For instance, if a build instruction file describes building anything from Markdown files, its source pattern should be something like `\.md$` to match files with ".md" as last extension. Source patterns are `bash` regular expressions.

#### GNU Make (Makefiles)

`autodoc` supports standard Makefiles.  
`Makefile`s must contain a SRCPAT annotation comment as follows, where `<regex>` is the source pattern as above.

```Makefile
#@SRCPAT <regex>
```

If there are multiple SRCPAT annotations, the lowermost one will be used.

##### Advanced options

You may add a PHONY target "autodoc" which will be built *instead* of the default target.

```Makefile
.PHONY: autodoc
autodoc:
  @echo "Hello World!"
```

## What not to use `autodoc` for

`autodoc` excels at building a large number of independent small files. It is **not** a solution for Continuous Integration of large scale software systems!

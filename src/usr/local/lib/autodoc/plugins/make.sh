#!/bin/bash

# plugin name
g_build_systems+=(make)

# build instruction file globs for this plugin
g_build_systems_glob[make]="Makefile *.mk"

# srcpat annotation prefix for this plugin
g_build_systems_annotations[make]='#%SRCPAT%'

# try to compile file OBJECT
do_make() { # $DIR $OBJECT $MAKEFILE
  # extract params
  local dir="$1"
  local makefile="$2"
  local object="$3"

  # only run if "object" is source file
  if do_check_srcpat "${dir}" "${makefile}" "${g_build_systems_annotations[make]}" "${object}"; then
    do_run_make "${dir}" "${makefile}"
  fi
}

# try running make for MAKEFILE inside DIRectory
do_make_all() { # $DIR $MAKEFILE
  # extract params
  local dir="$1"
  local makefile="$2"

  # only run if "makefile" is relevant for autodoc
  if do_check_srcpat "${dir}" "${makefile}" "${g_build_systems_annotations[make]}" ""; then
    do_run_make "${dir}" "${makefile}"
  fi
}

# actually run GNU Make with MAKEFILE inside DIRectory
do_run_make() { # $DIR $MAKEFILE
  # extract params
  local dir="$1"
  local makefile="$2"

  # check for autodoc target
  local target="$(grep -E "^autodoc:" "${dir}/${makefile}" | sed -r "s/:.*$//")"

  if [ -z "${target}" ]; then
    logline_append "Running 'make'!"
  else
    logline_append "Making '${target}'!"
  fi

  # actually run "make" and save (truncated) output
  local makelog="$(make --no-print-directory -C "${dir}" -f "${makefile}" -j ${target})"
  logline_append "$(echo "${makelog}" | head -n 10 | sed 's/$/;/g' | tr '\n' ' ' | sed 's/ *$//')"

  logline_append "Done."
}

echo -n "GNU Make plugin ... "

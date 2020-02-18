#!/bin/bash

# plugin name
g_build_systems+=(make)

# build instruction file globs for this plugin
g_build_systems_glob[make]="Makefile *.mk"

# compile using bare make command
do_make() { # $DIR $OBJECT $MAKEFILE
  # extract params
  local dir="$1"
  local object="$2"
  local makefile="$3"

  # check Makefile 'source pattern'
  local srcpat="$(grep -E "^#%SRCPAT%" "${dir}/${makefile}" | tail -n 1 | sed -r "s/^#%SRCPAT%\s+//")"

  if [ -z "${srcpat}" ]; then
    logline_append "Empty source pattern, check '#%SRCPAT%' annotation!"
    return 1

  elif [[ "${object}" =~ ${srcpat} ]]; then
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

  else
    logline_append "SRCPAT '${srcpat}' mismatch."
    return 1
  fi

  return 0
}

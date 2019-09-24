#!/bin/bash

# plugin name
g_build_systems+=(make)

# build instruction file globs for this plugin
g_build_systems_glob[make]="Makefile *.mk"

# compile using bare make command
do_make() { # $1:MAKEFILE $2:DIR $3:OBJECT
  # extract params
  local makefile="$1"
  local dir="$2"
  local object="$3"

  # check Makefile 'source pattern'
  local srcpat="$(grep -E "^#%SRCPAT%" "${dir}/${makefile}" | tail -n 1 | sed -r "s/^#%SRCPAT%\s+//")"

  if [ -z "${srcpat}" ]; then
    echo -n "Empty source pattern, check '#%SRCPAT%' annotation! "
    return 1

  elif [[ "${object}" =~ ${srcpat} ]]; then
    # check for autodoc target
    local target="$(grep -E "^autodoc:" "${dir}/${makefile}" | sed -r "s/:.*$//")"

    if [ -z "${target}" ]; then
      echo "Running 'make'. "
    else
      echo "Making '${target}'. "
    fi

    make --no-print-directory -C "${dir}" -f "${makefile}" -j ${target}

  else
    echo -n "SRCPAT '${srcpat}' mismatch. "
    return 1
  fi

  return 0
}

#!/bin/bash

g_build_systems+=(make)

# compile using bare make command
do_make() { # $1:DIR $2:MAKEFILE $3:OBJECT
  # extract params
  local dir="$1"
  local makefile="$2"
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

try_make() { # $1:DIR $2:OBJECT
  # extract params
  local dir="$1"
  local object="$2"
  local retval=1

  for FILE in "${dir}"/Makefile "${dir}"/*.mk; do
    if [ -r "${FILE}" ]; then
      echo -n "Found '${FILE}': "
      do_make "${dir}" "$(basename "${FILE}")" "${object}" \
      && local retval=0
      echo ""
    fi
  done

  return ${retval}
}

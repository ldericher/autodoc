#!/bin/bash

# $1:WATCHROOT (default: ".")
g_watchroot="$(readlink -f "${1:-.}")"

# compile using bare make command
do_make() { # $1:DIR $2:MAKEFILE $3:OBJECT
  # extract params
  local dir="$1"
  local makefile="$2"
  local object="$3"

  # check Makefile 'source pattern'
  local srcpat="$(grep -E "^#@SRCPAT" "${dir}/${makefile}" | tail -n 1 | sed -r "s/^#@SRCPAT\s+//")"

  if [ -z "${srcpat}" ]; then
    echo -n "Empty source pattern, check '#@SRCPAT' annotation! "
    return 1

  elif [[ "${object}" =~ ${srcpat} ]]; then
    # check for autodoc target
    local target="$(grep -E "^autodoc:" "${dir}/${makefile}" | sed -r "s/:.*$//")"

    if [ -z "${target}" ]; then
      echo "Running 'make'. "
    else
      echo "Making '${target}'. "
    fi

    make --no-print-directory -C "${dir}" -j ${target}

  else
    echo -n "SRCPAT '${srcpat}' mismatch. "
    return 1
  fi

  return 0
}

# compile a directory
do_compile() { # $1:DIR $2:OBJECT $3:DONE
  # extract params
  local dir="$1"
  local object="$2"
  local done="${3:-0}"

  # build systems

  if [ -r "${dir}/Makefile" ]; then
    # Makefile found
    echo -n "Found '${dir}/Makefile': "
    do_make "${dir}" "Makefile" "${object}" \
    && local done="1"
  fi

  # never leave $g_watchroot
  if [ "${dir}" != "${g_watchroot}" ]; then
    # search parent dir for more build instructions
    do_compile "$(dirname "${dir}")" "${object}" "${done}"

  elif [ "${done}" == "0" ]; then
    # hit $g_watchroot
    echo "No build instructions found!"
  fi
}

# process an inotify event
do_handle() { # $1:FLAGS $2:OBJECT
  # extract params
  local flags="$1"
  shift 1
  local dir="$(dirname "$*")"
  local object="$(basename "$*")"

  if [[ "${flags}" =~ "ISDIR" ]]; then
    # object refers to directory
    local dir="${dir}/${object}"
    local object="."
  fi

  # start using toolchain
  echo -n "'${object}': '${flags}' in '${dir}'. "
  do_compile "${dir}" "${object}"
}

#
# MAIN
#

echo "Booting ${0} in '${g_watchroot}'."
# setup inotify:
#   -mrq monitor, recursive, quiet
#   -e events
#   --format %e eventlist csv, %w workdir, %f filename
inotifywait -mrq \
  -e create -e delete -e moved_to -e close_write \
  --format '%e %w%f' \
  "${g_watchroot}" | \
\
while read FILE; do
  do_handle ${FILE}
done

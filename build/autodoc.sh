#!/bin/bash

# $1:WATCHROOT (default: ".")
g_watchroot="$(readlink -f "${1:-.}")"

# compile using bare make command
do_make() { # $1:DIR $2:OBJECT
  # extract params
  local dir="$1"
  local object="$2"

  # extract Makefile 'source pattern'
  local srcpat="$(grep -E "^#@SRCPAT" "${dir}/Makefile" | tail -n 1 | sed -r "s/^#@SRCPAT\s+//")"

  if [ -z "${srcpat}" ]; then
    echo "Empty source pattern! Makefile needs '#@SRCPAT' annotation!"

  elif [[ "${object}" =~ ${srcpat} ]]; then
    # check for autodoc target
    local target="$(grep -E "^autodoc:" "${dir}/Makefile" | sed -r "s/:.*$//")"
    local target="${target:-all}"

    echo "SRCPAT OK, building '${target}'."
    make --no-print-directory -C "${dir}" -j "${target}"

  else
    echo "SRCPAT mismatch '${srcpat}'."
  fi
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
    echo -n "Using '${dir}/Makefile'. "
    do_make "${dir}" "${object}"
    local done="1"
  fi

  # search parent dir for more build instructions
  if [ "${dir}" != "${g_watchroot}" ]; then
    # never leave $g_watchroot
    local dir="$(dirname "${dir}")"
    do_compile "${dir}" "${object}" "${done}"

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

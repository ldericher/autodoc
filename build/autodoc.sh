#!/bin/bash

# $1:WATCHROOT (default: ".")
g_watchroot="$(readlink -f "${1:-.}")"

# compile using bare make command
do_make() { # $1:DIR $2:OBJECT
  # extract params
  local dir="$1"
  local object="$2"

  # enter build directory
  local olddir="$(pwd)"
  cd "${dir}"

  # extract Makefile 'source pattern'
  local srcpat="$(grep -E "^#@SRCPAT" Makefile | sed -r "s/^#@SRCPAT\s+//")"

  if [ -z "${srcpat}" ]; then
    echo "Empty source pattern! Make sure Makefile has '#@SRCPAT' annotation!"
  elif [[ "${object}" =~ ${srcpat} ]]; then
    make -j # source pattern matched
  else
    echo "'${object}' does not match source pattern '${srcpat}'!"
  fi

  cd "${olddir}"
}

# compile a directory
do_compile() { # $1:DIR $2:OBJECT
  # extract params
  local dir="$1"
  local object="$2"

  if [ -e "${dir}/Makefile" ]; then
    # compile using Makefile
    echo "using 'make' in '$(basename "${dir}")'."
    do_make "${dir}" "${object}"

  elif [ "${dir}" != "${g_watchroot}" ]; then
    # search parent dir for build instructions (don't leave g_watchroot)
    local dir="$(dirname "${dir}")"
    echo -n "moving up … "
    do_compile "${dir}" "${object}"

  else
    # stop otherwise
    echo "no build instruction found!"
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
  echo -n "Flags '${flags}' for '${object}' in '${dir}' … "
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

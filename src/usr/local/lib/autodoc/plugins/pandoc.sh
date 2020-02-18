#!/bin/bash

# plugin name
g_build_systems+=(pandoc)

# build instruction file globs for this plugin
g_build_systems_glob[pandoc]="Pandocfile *.pandoc"

extract_var() { # $FILE $VARNAME
  (source "${1}"; echo "${!2}")
}

# compile using pandoc command
do_pandoc() { # $DIR $OBJECT $PANDOCFILE
  # extract params
  local dir="$1"
  local object="$2"
  local pandocfile="$3"

  # check Pandocfile 'source pattern'
  local srcpat="$(extract_var "${dir}/${pandocfile}" "SRCPAT")"
  local target="$(extract_var "${dir}/${pandocfile}" "TARGET")"
  local from="$(extract_var "${dir}/${pandocfile}" "FROM")"
  local template="$(extract_var "${dir}/${pandocfile}" "TEMPLATE")"
  local extra="$(extract_var "${dir}/${pandocfile}" "EXTRA")"

  if [ -z "${srcpat}" ]; then
    logline_append "Empty source pattern, check '%SRCPAT%' directive!"
    return 1

  elif [[ "${object}" =~ ${srcpat} ]]; then
    # actually run "pandoc" and save (truncated) output
    for target in ${target}; do
      local buildlog="$(cd "${dir}" && pandoc -s "${object}" -o "${object%.*}.${target}" -f "${from}" --template "${template}" ${extra})"
      logline_append "$(echo "${buildlog}" | head -n 10 | sed 's/$/;/g' | tr '\n' ' ' | sed 's/ *$//')"
    done

    logline_append "Done."

  else
    logline_append "SRCPAT '${srcpat}' mismatch."
    return 1
  fi

  return 0
}

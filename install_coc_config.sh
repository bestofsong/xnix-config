#!/usr/bin/env bash
set -eu
this_file="${BASH_SOURCE[0]}"
if ! [ -e "$this_file" ] ; then
  this_file="$(type -p "$this_file")"
fi
if ! [ -e "$this_file" ] ; then
  echo "Failed to resolve file."
  exit 1
fi
if ! [[ "$this_file" =~ ^/ ]] ; then
  this_file="$(pwd)/$this_file"
fi
while [ -h "$this_file" ] ; do
    ls_res="$(ls -ld "$this_file")"
    link_target=$(expr "$ls_res" : '.*-> \(.*\)$')
    if [[ "$link_target" =~ ^/ ]] ; then
      this_file="$link_target"
    else
      this_file="$(dirname "$this_file")/$link_target"
    fi
done
this_dir="$(dirname "$this_file")"

coc_config_tmpl_file="${this_dir}/coc_config.tmpl.json"
coc_config_output="${this_dir}/coc_config.json"

{
  while read -r line ; do
    if ! [[ "$line" =~ (.+) ]] ; then
      echo "$line"
      continue
    fi
    placeholder_cmd="${BASH_REMATCH[1]}"
    if [ -z "$placeholder_cmd" ] ; then
      echo "$line"
      continue
    fi
    replaced=$(eval "$placeholder_cmd" || true)
    echo "${line/$placeholder_cmd/$replaced}"
  done
} <"$coc_config_tmpl_file" | jq  >"$coc_config_output"

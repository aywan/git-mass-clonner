#!/usr/bin/env bash

set -e
BASE_DIR=vendor-bak
PROTOCOL=https
NO_FETCH=0

## Utils

get_current_date() {
    echo $(date "+%F %T %Z")
}

show_info() {
    echo -e "$(get_current_date) [\033[0;34mI\033[0m]: $*"
}

show_warning() {
    echo -e "$(get_current_date) [\033[0;33mW\033[0m]: $*"
}

show_error() {
    echo -e "$(get_current_date) [\033[0;31mE\033[0m]: $*"
    exit 1
}

join_by() { local IFS="$1"; shift; echo "$*"; }

build_repo() {
  dir=${1}
  name=${2}
  line=${3}

  case $PROTOCOL in
    unchange)
      out=$line
      ;;

    http|https)
      out="${PROTOCOL}://${dir}/${name}.git"
      ;;

    git)
      dir=$(echo $dir | sed '0,/\//{s/\//:/}')
      out="git@${dir}/${name}.git"
      ;;
  esac

  echo $out
}

## Cloning

do_clone() {
    show_info "cloning repos"
    for line in $(< "${1:-/dev/stdin}"); do
      line=$(echo "$line" | sed 's/, /,/' | awk '{print tolower($0)}')

      if [[ $line = http* ]]; then
        cleared=$(echo "$line" | sed 's/https\?:\/\/\(.*\).git/\1/')
      elif [[ $line = git@* ]]; then
        cleared=$(echo "$line" | sed 's/git@\(.*\):\(.*\).git/\1\/\2/')
      else
        show_error "can't parse line: ${line}"
      fi

      parts=(${cleared//\// })
      name=${parts[-1]}
      unset 'parts[-1]'
      dir=$(join_by / "${parts[@]}")

      repo=$(build_repo $dir $name $line)

      full_path="${BASE_DIR}/${dir}/${name}"
      if [ -d "${full_path}/.git" ]; then
        if [[ $NO_FETCH -eq 1 ]]; then
          show_warning "already exists at {$full_path}"
        else
          show_info "fetching at ${full_path}"
          git -C "${full_path}" fetch --all --prune
        fi
      else
        show_info "cloning $repo into $full_path"
        mkdir -p "${full_path}"
        git clone "${repo}" "${full_path}"
      fi
    done
}

## Fetching

do_fetch() {
    show_warning $BASE_DIR
    show_info "fetch"

    all=$(find ${BASE_DIR} -type d -name '.git' | sed -r 's|/[^/]+$||')

    for line in $all; do
      show_info "fetching in ${line}"
      git -C "${line}" fetch --all --prune
    done
}


## Main

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      BASE_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--protocol)
      PROTOCOL="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--no-fetch)
      NO_FETCH=1
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

declare -A protocols=(
 [http]=1 [https]=1 [git]=1 [unchange]=1
)

if [[ -z "${protocols[$PROTOCOL]}" ]]; then
  show_error "unknown protocol ${PROTOCOL}"
  exit 1
fi


set -- "${POSITIONAL_ARGS[@]}"

case $1 in
  clone)
    shift
    do_clone $@
    ;;

  fetch)
    shift
    do_fetch $@
    ;;

  *)
    echo "Unknown command $1"
    exit 1
    ;;
esac



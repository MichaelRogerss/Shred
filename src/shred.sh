#!/usr/bin/env bash
set -euo pipefail

usage(){ 
  cat <<EOF
Usage: $0 [-v] [-n N] [-z] [-k] FILE|DIR
Securely overwrite FILE or all files in DIR. By default files are removed after overwriting.
Options:
  -v        verbose
  -n N      overwrite N times (default 3)
  -z        add final zero pass
  -k        keep files after overwriting (do not delete)
  -h        help
EOF
  exit 1
}

VERBOSE=0
ITERATIONS=3
ZERO=0
KEEP=0
BS=4096

while getopts ":vn:zkh" opt; do
  case $opt in
    v) VERBOSE=1 ;;
    n) ITERATIONS="$OPTARG" ;;
    z) ZERO=1 ;;
    k) KEEP=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))
[ $# -eq 1 ] || usage
TARGET=$1


get_size(){
  local f="$1"
  if stat --version >/dev/null 2>&1; then
    stat -c%s -- "$f"
  else
    stat -f%z -- "$f" 2>/dev/null || wc -c <"$f"
  fi
}

is_positive_int(){
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
    *) [ "$1" -ge 1 ] 2>/dev/null ;;
  esac
}

if ! is_positive_int "$ITERATIONS"; then
  echo "Invalid iterations: must be positive integer" >&2
  exit 1
fi

overwrite_file(){
  local file="$1"; local it="$2"; local zero="$3"
  local size count i

  if [ ! -f "$file" ]; then
    if [ "${VERBOSE:-0}" -eq 1 ]; then
      echo "Skipping non-regular file: $file"
    fi
    return 0
  fi

  size=$(get_size "$file" || echo 0)
  count=$(((size + BS - 1) / BS))
  [ "$count" -ge 1 ] || count=1

  for ((i=0;i<it;i++)); do
    if [ "${VERBOSE:-0}" -eq 1 ]; then
      echo "Random pass $((i+1))/$it -> $file"
    fi
    dd if=/dev/urandom of="$file" bs="$BS" count="$count" conv=notrunc status=none || {
      echo "dd failed writing random to $file" >&2
      return 1
    }
    sync
  done

  if [ "$zero" -eq 1 ]; then
    if [ "${VERBOSE:-0}" -eq 1 ]; then
      echo "Zero pass -> $file"
    fi
    dd if=/dev/zero of="$file" bs="$BS" count="$count" conv=notrunc status=none || {
      echo "dd failed writing zeros to $file" >&2
      return 1
    }
    sync
  fi

  if [ "${VERBOSE:-0}" -eq 1 ]; then
    if [ "$KEEP" -eq 1 ]; then
      echo "Keeping (not removing) $file"
    else
      echo "Removing $file"
    fi
  fi

  if [ "$KEEP" -eq 0 ]; then
    rm -f -- "$file"
  fi
}

process_directory(){
  local dir="$1"
  find "$dir" -type f -print0 | while IFS= read -r -d '' f; do
    overwrite_file "$f" "$ITERATIONS" "$ZERO"
  done

  if [ "$KEEP" -eq 0 ]; then
    find "$dir" -depth -type d -print0 | xargs -0r rmdir -- 2>/dev/null || true
  else
    if [ "${VERBOSE:-0}" -eq 1 ]; then
      echo "Keeping directories under $dir"
    fi
  fi
}

if [ -f "$TARGET" ]; then
  overwrite_file "$TARGET" "$ITERATIONS" "$ZERO"
elif [ -d "$TARGET" ]; then
  process_directory "$TARGET"
else
  echo "Error: $TARGET is not a regular file or directory" >&2
  exit 1
fi

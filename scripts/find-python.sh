#!/usr/bin/env bash
# Cross-platform Python resolver
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    exec python "$@"
    ;;
  *)
    if command -v python3 >/dev/null 2>&1; then
      exec python3 "$@"
    else
      exec python "$@"
    fi
    ;;
esac

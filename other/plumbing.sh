#!/bin/bash

# This script is just for testing purposes, may be deleted.

set -euo pipefail
IFS=$'\n\t'

REMOTES=$(git remote)
BRANCH=$(git branch --show-current)

echo "Remotes:"; echo "${REMOTES^^}"; echo
echo "Branch:"; echo "${BRANCH^^}"; echo

for REMOTE in $REMOTES; do
  echo "remote show ${REMOTE^^}"; git remote --verbose show $REMOTE \
    | sed "/Remote branches:/,/Local ref configured for 'git push':/{/Remote branches:/{N;N;d};/Local ref configured for 'git push'/!d}"; echo;
done

for REMOTE in $REMOTES; do
  echo "fetch ${REMOTE^^} ${BRANCH^^}"; git fetch --dry-run --porcelain --verbose $REMOTE $BRANCH; echo;
done

for REMOTE in $REMOTES; do
  echo "ls-remote ${REMOTE^^} ${BRANCH^^}"; git ls-remote --heads $REMOTE $BRANCH HEAD \
    | awk '{print $1}'; echo
done

echo "rev-pasres head LOCAL"; git rev-parse HEAD
echo "log -1 LOCAL"; git log -1 --oneline --no-abbrev-commit \
  | awk '{print $1}'; echo

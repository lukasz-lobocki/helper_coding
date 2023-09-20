#!/bin/bash

# This script is just for testing purposes, may be deleted.

set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

REMOTES=$(git remote)
BRANCH=$(git branch --show-current)

echo -e "${YELLOW}remotes${NC}";

for REMOTE in $REMOTES; do
  echo -e "${REMOTE^^} ${BRANCH^^}"
done; echo

for REMOTE in $REMOTES; do
  echo -e "${YELLOW}remote show ${REMOTE^^}${NC}"; git remote --verbose show $REMOTE \
    | sed "/Remote branches:/,/Local ref configured for 'git push':/{/Remote branches:/{N;N;d};/Local ref configured for 'git push'/!d}";
done; echo

for REMOTE in $REMOTES; do
  echo -e "${YELLOW}fetch ${REMOTE^^} ${BRANCH^^}${NC}"; git fetch --dry-run --porcelain --verbose $REMOTE $BRANCH;
done; echo

for REMOTE in $REMOTES; do
  echo -e "${YELLOW}ls-remote ${REMOTE^^} ${BRANCH^^}${NC}"; git ls-remote --heads $REMOTE $BRANCH HEAD \
    | awk '{print $1}';
done

echo -e "${YELLOW}rev-parse head LOCAL${NC}"; git rev-parse HEAD; echo
echo -e "${YELLOW}log -1 LOCAL${NC}"; git log -1 --oneline --no-abbrev-commit \
  | awk '{print $1}'; echo

#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
NC='\033[0m' # No Color

git rev-parse --is-inside-work-tree > /dev/null 2>&1 #  || { echo "no repo" ; exit 1; }
GITSTATUS=$?

if [[ $GITSTATUS == "0" ]]; then  # repo exists
  REPLY=$(whiptail --title "Git" --menu "Choose an option" 15 78 6 --notags \
    "info" "info" \
    "git-add commit-fix POETRY" "git-add commit-fix POETRY" \
    "git-add commit-chore PUSH" "git-add commit-chore PUSH" \
  3>&1 1>&2 2>&3)
else  # no repo
  REPLY=$(whiptail --title "Git" --menu "Choose an option" 15 78 6 --notags \
    "setup module" "setup module" \
  3>&1 1>&2 2>&3)
fi

MENUSTATUS=$?
if [ $MENUSTATUS != 0 ]; then
  exit 1
fi

case $REPLY in
  "git-add commit-fix POETRY")
    git add -u
    git commit -m "fix: change"
    poetry run semantic-release version
    git fetch
    ;;
  "git-add commit-chore PUSH")
    git add -u
    MESSAGE=$(whiptail --inputbox "What is your commit message?" 8 39 "chore: update" --title "Commit message" --nocancel\
      3>&1 1>&2 2>&3)
    git commit -m "${MESSAGE}"
    git push
    ;;
  "info")
    git log -n 1 --graph --decorate --oneline
    git remote show origin
    ;;
  "setup module")
    ~/Code/helper/coding/other/setup_module.sh NAME
    ;;
esac

if [[ $GITSTATUS == "0" ]]; then  # repo exists
  git status -sb
  echo -e "option ${GREEN}${REPLY}${NC} completed on ${GREEN}$(git config --get remote.origin.url)${NC}"
else
  echo -e "option ${GREEN}${REPLY}${NC} completed"
fi

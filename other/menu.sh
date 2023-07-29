#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
NC='\033[0m' # No Color

git rev-parse --is-inside-work-tree > /dev/null 2>&1
GITSTATUS=$?

if [[ $GITSTATUS == "0" ]]; then  # repo exists
  REPLY=$(whiptail --title "Git" --menu "Choose option then press Ok" 15 78 6 --notags \
    "info" " info " \
    "git-add-update commit push" " git-add-update commit [push] " \
  3>&1 1>&2 2>&3)
else  # no repo
  REPLY=$(whiptail --title "Git" --menu "Choose an option then press Ok" 15 78 6 --notags \
    "setup module" " setup module " \
  3>&1 1>&2 2>&3)
fi

MENUSTATUS=$?
if [ $MENUSTATUS != 0 ]; then
  exit 1
fi

case $REPLY in
  "git-add-update commit push")
    git add -u
    TYPE=$(whiptail --title "Commit message type" --menu \
      "Choose commit type then press Ok" 20 78 8 \
      "chore" "Changes to the auxiliary tools and libraries" \
      "fix" "A bug fix" \
      "feat" "A new feature" \
      "build" "Changes to the build process" \
      "docs" "Documentation only changes" \
      "perf" "A code change that improves performance" \
      "style" "Changes formatting that do not affect the meaning" \
      "refactor" "A code change that is not a bug fix nor a feature " \
      "test" "Adding missing or correcting existing tests" \
    3>&1 1>&2 2>&3)

    MENUSTATUS=$?
    if [ $MENUSTATUS != 0 ]; then
      exit 1
    fi

    OUTPUT=$(whiptail --inputbox "What is your commit message?" 8 39 "${TYPE}: Updating." --title "Commit message"\
      3>&1 1>&2 2>&3)

    MENUSTATUS=$?
    if [ $MENUSTATUS != 0 ]; then
      exit 1
    fi

    git commit -m "${OUTPUT}" > /dev/null 2>&1

    poetry env list > /dev/null 2>&1

    POETRYSTATUS=$?

    if [[ $POETRYSTATUS == "0" ]]; then  # repo is poetry managed
      OUTPUT=$(whiptail --title "Action" --menu --notags \
        "Choose action then press Ok" 20 78 3 \
        "nop" " Just commit " \
        "poetry" " Commit and poetry run semantic-release version " \
        "push" " Commit git push " \
      3>&1 1>&2 2>&3)
    else  # repo not poetry managed
      OUTPUT=$(whiptail --title "Action" --menu --notags \
        "Choose action then press Ok" 20 78 3 \
        "nop" " Just commit " \
        "push" " Commit git push " \
      3>&1 1>&2 2>&3)
    fi

    MENUSTATUS=$?
    if [ $MENUSTATUS != 0 ]; then
      exit 1
    fi

    case $OUTPUT in
      "nop")
        ;;
      "poetry")
        poetry run semantic-release version
        git push
        ;;
      "push")
        git push
        ;;
    esac
    ;;
  "info")
    git log -n 1 --graph --decorate --oneline
    git remote show origin
    ;;
  "setup module")
    OUTPUT=$(whiptail --inputbox "What is your module name?" 8 39 --title "Module name" \
      3>&1 1>&2 2>&3)

    MENUSTATUS=$?
    if [ $MENUSTATUS != 0 ]; then
      exit 1
    fi

    ~/Code/helper/coding/other/setup_module.sh "${OUTPUT}"
    ;;
esac

if [[ $GITSTATUS == "0" ]]; then  # repo exists
  git status -sb
  echo -e "option ${GREEN}${REPLY}${NC} completed on ${GREEN}$(git config --get remote.origin.url)${NC}"
else
  echo -e "option ${GREEN}${REPLY}${NC} completed"
fi

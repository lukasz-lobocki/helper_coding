#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# gets_

get_git_status() {
  local GITSTATUS
  git rev-parse --is-inside-work-tree > /dev/null 2>&1
  GITSTATUS=$?
  echo "${GITSTATUS}"
  return 0
}

get_poetry_status(){
  local POETRYSTATUS
  poetry check > /dev/null 2>&1
  POETRYSTATUS=$?
  echo "${POETRYSTATUS}"
  return 0
}

# choice_menus_

get_choice_action(){
  local REPLY
  local QUESTION
  QUESTION=("$@")
  REPLY=$(whiptail --title "Git" --menu "Choose option then press Ok" 15 78 6 --notags \
    "${QUESTION[@]}" \
  3>&1 1>&2 2>&3)

  MENUSTATUS=$?

  echo "${REPLY}"
  return ${MENUSTATUS}
}

# inputboxes_

get_commit_message(){
  local REPLY
  local COMMIT_TYPE
  local QUESTION
  QUESTION=( \
    "chore" "chore: Changes to the auxiliary tools" \
    "fix" "fix: Bug fix" \
    "feat" "feat: New feature" \
    "build" "build: Changes to the build process" \
    "docs" "docs: Documentation only changes" \
    "perf" "perf: Code change that improves performance" \
    "style" "style: Changes formatting that do not affect the meaning" \
    "refactor" "refactor: Code change that is not a bug fix nor a feature " \
    "test" "test: Adding missing or correcting existing tests" \
  )
  COMMIT_TYPE=$(get_choice_action "${QUESTION[@]}") || exit $?
  REPLY=$(whiptail --inputbox "What is your commit message?" 8 39 "$COMMIT_TYPE: $(echo "$COMMIT_TYPE." | sed -e 's/\b\(.\)/\u\1/g')" \
    --title "Commit message" \
  3>&1 1>&2 2>&3)
  MENUSTATUS=$?

  echo "${REPLY}"
  return ${MENUSTATUS}
}

get_module_name(){
  local REPLY
  REPLY=$(whiptail --inputbox "What is your module name?" 8 39 --title "Module name" \
    3>&1 1>&2 2>&3)
  MENUSTATUS=$?

  echo "${REPLY}"
  return ${MENUSTATUS}
}

# shows_

show_git_info(){
  echo -e "\n${RED}>>> ${NC}Git log top entry.\n"
  git log -n 1 --decorate --oneline
  echo -e "\n${RED}>>> ${NC}Git subtrees.\n"
  git log | grep git-subtree-dir | tr -d ' ' | cut -d ":" -f2 | sort | uniq
  echo -e "\n${RED}>>> ${NC}Git remote show.\n"
  git remote show origin
  return $?
}

# runs_

run_push(){
  echo -e "\n${RED}>>> ${NC}Git pushing.\n"
  git push
  return $?
}

run_poetry_push(){
  echo -e "\n${RED}>>> ${NC}Running poetry.\n"
  poetry run semantic-release version
  echo -e "\n${RED}>>> ${NC}Git pushing.\n"
  git push
  return $?
}

run_gital(){
  gita shell \
  "{ \
    git log --pretty=format:'^%ct^%cr^' --date-order -n 1; \
    git config --get remote.origin.url \
      | tr -d '\n' \
      | sed 's/^git@github.com:/ssh@https:\/\/github.com\//'; \
    git branch -v \
      | grep -o '\[[^]]*\]' \
      | sed 's/^/\^/'; \
  };" \
  | grep --invert-match '^$' \
  | sort --ignore-leading-blanks --field-separator='^' --key=2 --reverse \
  | cut --delimiter='^' --fields=2 --complement \
  | column --table --separator '^' --output-separator '  ' \
    --table-columns 'Repo,Last commit,Github,Local is'
  return $?
}

########
# MAIN #
########

main() {
  local GITSTATUS
  local REPLY
  local MODULE_NAME
  local COMMIT_MESSAGE
  local POETRYSTATUS
  local ACTION
  local URL
  local HTTPSURL
  local QUESTION

  GITSTATUS=$(get_git_status) || exit $?

  # Question that is always valid
  QUESTION=( \
    "gital" " gital " \
  )

  if [[ $GITSTATUS == "0" ]]; then  # repo exists
    # Adding questions valid for repo
    QUESTION+=( \
      "info" " info " \
      "git:add-update commit push" " git:add-update commit [push] " \
    )
  else  # no repo
    # Adding questions valid for no repo
    QUESTION+=( \
      "setup module" " setup module " \
    )
  fi

  REPLY=$(get_choice_action "${QUESTION[@]}") || exit $?

  echo -e "\n${RED}>>> ${NC}${GREEN}${REPLY}${NC} chosen.\n"

  case $REPLY in
    "info")
      echo -e "\n${RED}>>> ${NC}Show git info.\n"
      show_git_info  || exit $?
      ;;
    "gital")
      echo -e "\n${RED}>>> ${NC}Run gital.\n"
      run_gital || exit $?
      ;;
    "setup module")
      MODULE_NAME=$(get_module_name) || exit $?

      echo -e "\n${RED}>>> ${NC}Run setup_module.\n"
      ~/Code/helper/coding/other/setup_module.sh "${MODULE_NAME}"
      ;;
    "git:add-update commit push")
      echo -e "\n${RED}>>> ${NC}Git add update.\n"
      git add -u

      COMMIT_MESSAGE=$(get_commit_message)  || exit $?
      echo -e "\n${RED}>>> ${NC}${GREEN}${COMMIT_MESSAGE}${NC} chosen.\n"

      echo -e "\n${RED}>>> ${NC}Commiting.\n"
      git commit -m "${COMMIT_MESSAGE}"

    # Question that is always valid
    QUESTION=( \
      "nop" " Just commit " \
      "push" " git:commit push " \
    )

      POETRYSTATUS=$(get_poetry_status) || exit $?
      if [[ $POETRYSTATUS == "0" ]]; then  # repo is poetry managed
        # Adding questions valid for poetry
        QUESTION+=( \
          "poetry" " git:commit poetry:run semantic-release version " \
        )
      else  # repo not poetry managed
        :
      fi

      ACTION=$(get_choice_action "${QUESTION[@]}") || exit $?

      echo -e "\n${RED}>>> ${NC}${GREEN}${ACTION}${NC} chosen.\n"
      case $ACTION in
        "nop")
          ;;
        "poetry")
          run_poetry_push || exit $?
          ;;
        "push")
          run_push || exit $?
          ;;
      esac
      ;;
  esac

  if [[ $GITSTATUS == "0" ]]; then  # repo exists
    echo -e "\n${RED}>>> ${NC}Git status.\n"
    git status --short --branch
    URL=$(git config --get remote.origin.url)
    HTTPSURL="https://github.com/${URL#*:}"
    echo -e "\n${RED}>>> ${NC}Option ${GREEN}${REPLY}${NC} completed on ${GREEN}${HTTPSURL}${NC}\n"
  else
    echo -e "\n${RED}>>> ${NC}Option ${GREEN}${REPLY}${NC} completed\n"
  fi
}

main "$@"
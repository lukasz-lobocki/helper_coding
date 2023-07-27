#!/bin/bash
# Bash Menu Script Example

GREEN='\033[0;32m'
NC='\033[0m' # No Color

PS3='Please enter your choice: '
options=( "$(echo -e "git-add commit-${GREEN}fix${NC} POETRY")" \
  "$(echo -e "git-add commit-${GREEN}chore${NC} PUSH")" )
select opt in "${options[@]}"
do
    case $REPLY in
        1)
            git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { echo "no repo" ; break; }
            git add -u
            git commit -m "fix: change"
            poetry run semantic-release version
            echo -e "option ${REPLY} ${GREEN}completed${NC}" ; break
            ;;
        2)
            git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { echo "no repo" ; break; }
            git add -u
            git commit -m "chore: update"
            git push
            echo -e "option ${REPLY} ${GREEN}completed${NC}" ; break
            ;;
        *)
            echo -e "${GREEN}exit${NC}" ; break
            ;;
    esac
done

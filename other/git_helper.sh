#!/bin/bash

#   ██████  ██ ████████ ██   ██ ███████ ██      ██████  ███████ ██████  
#  ██       ██    ██    ██   ██ ██      ██      ██   ██ ██      ██   ██ 
#  ██   ███ ██    ██    ███████ █████   ██      ██████  █████   ██████  
#  ██    ██ ██    ██    ██   ██ ██      ██      ██      ██      ██   ██ 
#   ██████  ██    ██    ██   ██ ███████ ███████ ██      ███████ ██   ██ 

# Not so usefull script to recursively operate on git repositories in directory tree.

set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NOBOLD=$(tput sgr0)
UNDERLINE="\e[4m"
NOUNDERLINE="\e[0m"

function pull_or_push () {

echo -e "${RED}***${NC} pull or push: $1"

UPSTREAM=${2:-'@{u}'}
LOCAL=$(git -C $1 rev-parse @)
REMOTE=$(git -C $1 rev-parse "$UPSTREAM")
BASE=$(git -C $1 merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    echo -e "${GREEN}Up-to-date.${NC}"
elif [ $LOCAL = $BASE ]; then
    echo -e "${RED}Need to PULL.${NC}"
elif [ $REMOTE = $BASE ]; then
    echo -e "${UNDERLINE}Need to push.${NOUNDERLINE}"
else
    echo -e "${BOLD}Diverged.${NOBOLD}"
fi
}

function show_menu () {
# Display menu choice
echo -e "
${BOLD}GIT HELPER${NOBOLD}
Performs actions on ${UNDERLINE}all${NOUNDERLINE} repositories in ${UNDERLINE}subdirectories${NOUNDERLINE} of current ${GREEN}`pwd`${NC}

Actions:
s	${UNDERLINE}s${NOUNDERLINE}tatus				ss	${UNDERLINE}s${NOUNDERLINE}hort ${UNDERLINE}s${NOUNDERLINE}tatus
u	s${UNDERLINE}u${NOUNDERLINE}bmodule status		su	${UNDERLINE}s${NOUNDERLINE}ubmodule ${UNDERLINE}u${NOUNDERLINE}pdate

f	${UNDERLINE}f${NOUNDERLINE}etch				d	${UNDERLINE}d${NOUNDERLINE}iff
m	${UNDERLINE}m${NOUNDERLINE}erge				ru	${UNDERLINE}r${NOUNDERLINE}emote ${UNDERLINE}u${NOUNDERLINE}pdate

a	${UNDERLINE}a${NOUNDERLINE}dd .				aa	${UNDERLINE}a${NOUNDERLINE}dd -${UNDERLINE}a${NOUNDERLINE}ll
c	${UNDERLINE}c${NOUNDERLINE}ommit				ys	s${UNDERLINE}y${NOUNDERLINE}nc ${UNDERLINE}s${NOUNDERLINE}tatus

h	pus${UNDERLINE}h${NOUNDERLINE}				l	pul${UNDERLINE}l${NOUNDERLINE}

x	e${UNDERLINE}x${NOUNDERLINE}it				?	show ${UNDERLINE}menu${NOUNDERLINE}"
}

show_menu

while [[ $option != "x" ]]; do

echo
read -p "Select action: " option

# Prepare the command
case $option in
	"s")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} status: ${GREEN}'{}'${NC}' && git -C {} status -uno | awk NF"
		;;
	"ss")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} short status: ${GREEN}'{}'${NC}' && git -C {} status -s | awk NF"
		;;
	"u")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} submodule status: ${GREEN}'{}'${NC}' && git -C {} submodule status | awk NF"
		;;
	"su")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} submodule update: ${GREEN}'{}'${NC}' && git -C {} submodule update --remote --merge --recursive | awk NF"
		;;
	"f")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} fetch: ${GREEN}'{}'${NC}' && git -C {} fetch origin main | awk NF"
		;;
	"d")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} diff: ${GREEN}'{}'${NC}' && git -C {} diff main origin | awk NF"
		;;
	"m")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} merge: ${GREEN}'{}'${NC}' && git -C {} merge | awk NF"
		;;
	"ru")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} remote update: ${GREEN}'{}'${NC}' && git -C {} remote -v update | awk NF"
		;;
	"l")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} pull: ${GREEN}'{}'${NC}' && git -C {} pull origin main | awk NF"
		;;
	"a")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} add .: ${GREEN}'{}'${NC}' && git -C {} add . | awk NF"
		;;
	"aa")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} add --all: ${GREEN}'{}'${NC}' && git -C {} add --all | awk NF"
		;;
	"c")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} commit: ${GREEN}'{}'${NC}' && git -C {} commit -m 'mass commit' | awk NF"
		;;
	"ys")
		find . -type d -name .git | sed 's/\/.git//' | while read in; do pull_or_push "$in"; done
		;;
	"h")
		find . -type d -name .git | sed 's/\/.git//' | xargs -P1 -I{} bash -c "echo -e '${RED}***${NC} push: ${GREEN}'{}'${NC}' && git -C {} push -u origin main | awk NF"
		;;
	"x")
		exit 0
		;;
	"?")
		show_menu
		continue
		;;
	*)
		echo -e "${RED}Unknown action.${NC}"
		show_menu
		continue
		;;
esac


done

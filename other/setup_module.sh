#!/bin/bash

#  ███    ███  ██████  ██████  ██    ██ ██      ███████     ███████ ███████ ████████ ██    ██ ██████  
#  ████  ████ ██    ██ ██   ██ ██    ██ ██      ██          ██      ██         ██    ██    ██ ██   ██ 
#  ██ ████ ██ ██    ██ ██   ██ ██    ██ ██      █████       ███████ █████      ██    ██    ██ ██████  
#  ██  ██  ██ ██    ██ ██   ██ ██    ██ ██      ██               ██ ██         ██    ██    ██ ██      
#  ██      ██  ██████  ██████   ██████  ███████ ███████     ███████ ███████    ██     ██████  ██      

# Performs creation of Poetry enabled Python module environment.

set -euo pipefail
IFS=$'\n\t'

# chmod u+x __self__.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NOBOLD=$(tput sgr0)
UNDERLINE="\e[4m"
NOUNDERLINE="\e[0m"

echo -e "
Welcome to ${BOLD}$(basename "$0")${NOBOLD}
"

read -r -e -p "Enter package name: " -i "lobo_$1" NAME

# Just emitting message.
echo -e "
${RED}>>> ${NC}Package name: ${BOLD}${NAME}${NOBOLD}"

echo -e "
${RED}>>> ${NC}Cookiecutting the folder structure.
"
cookiecutter git+ssh://git@github.com/lukasz-lobocki/py-pkgs-cookiecutter.git package_name="${NAME}"
cd "${NAME}"

echo -e "
${RED}>>> ${NC}Initiating repo and setting its description.
"
git init

echo -e "
${RED}>>> ${NC}Configuring virtualenvs of poetry."
poetry config virtualenvs.in-project true
poetry config virtualenvs.create true

echo -e "
${RED}>>> ${NC}Configuring PyPI as primary source."
poetry source add --priority=primary PyPI

echo -e "
${RED}>>> ${NC}Adding semantic release versionining."
poetry add --lock --group dev python-semantic-release@latest

echo -e "
${RED}>>> ${NC}Adding PyPI publishing."
poetry add --lock --group dev twine@latest

echo -e "
${RED}>>> ${NC}Adding microcontroller communication suite."
# poetry add --quiet --lock --group dev esptool@latest  # used only for micropython flashin, other modules do not need it.
poetry add --lock --group dev adafruit-ampy@latest

echo -e "
${RED}>>> ${NC}Installing all.
"
poetry install --no-interaction

echo -e "
${RED}>>> ${NC}Adding and commiting ${GREEN}feat:${NC} all.
"
git add --all
git commit -m "feat: Repo initiation."

echo -e "
${RED}>>> ${NC}Creating remote on GitHub.
"
gh repo create "${NAME}" --private --disable-issues --disable-wiki \
  --description "$(grep "^description =" pyproject.toml | awk -F'"' '{print $2}')"
git branch --move --force main
git remote add origin git@github.com:lukasz-lobocki/"${NAME}"
git tag --annotate v$(grep -o '^version = "[0-9]\+\.[0-9]\+\.[0-9]\+"' pyproject.toml | awk -F'"' '{print $2}') \
  -m "Manual version bump."
git push --set-upstream --tags origin main


echo -e "
${RED}>>> ${NC}Releasing first ${GREEN}feat${NC} version.
"
poetry run semantic-release version

echo -e "
${RED}>>> ${NC}Repo pushing.
"
git push

echo -e "
${RED}>>> ${NC}Top entry should read ${BOLD}HEAD -> main, tag: v$(grep -o 'version = "[0-9]\+\.[0-9]\+\.[0-9]\+"' pyproject.toml | awk -F'"' '{print $2}'), origin/main${NOBOLD}
"
{ git log -n 1 --decorate --oneline \
  | grep --color "HEAD -> main, tag: v$(grep -o '^version = "[0-9]\+\.[0-9]\+\.[0-9]\+"' pyproject.toml \
  | awk -F'"' '{print $2}'), origin/main"; } \
  || echo -e "
${RED}>>> ${NC}${BOLD}ERROR.${NOBOLD}
"
git remote show origin

{ git status -sb | grep 'main...origin/main'; } \
  || echo -e "
${RED}>>> ${NC}${BOLD}ERROR.${NOBOLD}
"

# Just emitting message.
echo -e "
${RED}>>> ${NC}To add ${BOLD}your own modules${NOBOLD} from GitHub.
poetry ${BOLD}add${NOBOLD} --editable ${GREEN}git+ssh://git@github.com:lukasz-lobocki/...${NC}

${RED}>>> ${NC}To ${BOLD}make symlinks${NOBOLD} to your own modules.
poetry ${BOLD}update${NOBOLD}
${BOLD}find${NOBOLD} ${GREEN}.venv/src/*/src/*${NC} -type f \( -iname '*.py' ! -iname '__init__.py' \) -print0 | xargs -0I@ ${BOLD}ln${NOBOLD} --relative --symbolic @ ${GREEN}sub${NC}

${RED}>>> ${NC}To add ${BOLD}your own repositories${NOBOLD} from GitHub.
git ${BOLD}subtree${NOBOLD} add --prefix git-subtree/${GREEN}<name> git@github.com:lukasz-lobocki/<name>${NC} main --squash

${RED}>>> ${NC}Upload to testPyPI.
poetry ${BOLD}run${NOBOLD} twine upload ${GREEN}--repository testpypi${NC} dist/*

${RED}>>> ${NC}Upload to PyPI - PRODUCTION.
poetry ${BOLD}run${NOBOLD} twine upload dist/*

${RED}>>> ${NC}Typical workflow.
git ${BOLD}add${NOBOLD} --update ${RED}&&${NC} git ${BOLD}commit${NOBOLD} -m \"${GREEN}fix: change${NC}\"
poetry ${BOLD}run${NOBOLD} semantic-release ${GREEN}version${NC}
git ${BOLD}push${NOBOLD}"

# Just emitting message.
echo -e "
${RED}>>> ${NC}Finished ${GREEN}cd ${NAME}${NC}.
"
